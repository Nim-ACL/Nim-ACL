# Implicit Treap

乱択priorityを持つ暗黙Treapによって、動的な列を管理します。

位置による挿入・削除、要素取得・更新、区間反転、区間積をサポートします。
平衡は期待計算量で保証されます。

## 一般形

~~~nim
proc op(
    left,
    right: S,
): S =
  ...

proc e(): S =
  ...

type
  Treap =
    ImplicitTreapType[S](
      op,
      e,
    )

var tree =
  Treap.init(
    values,
  )
~~~

空の木は次のように初期化できます。

~~~nim
var tree =
  Treap.init()
~~~

## 引数・型

- `S`: 列要素および区間積の型
- `op(left, right)`: Monoidの二項演算
- `e()`: Monoidの単位元
- `values`: 初期列
- `seed`: priority生成に使う64-bit seed

`op`は結合的で、`e()`は左右の単位元である必要があります。
可換性は不要です。

`seed`の既定値は`DefaultImplicitTreapSeed`です。既定seedは固定されており、
同じ操作列から再現可能な木を作ります。seedは木の形と実行時間にだけ影響し、
返り値や正しさには影響しません。

初期列を与えた場合、その長さに合わせてノード領域を事前確保します。
削除したノードの領域は後の挿入で再利用します。

## 前提条件

長さを`n = tree.len`とします。

- `insert(position, value)`: `0 <= position <= n`
- `erase(position)`, `get(position)`, `set(position, value)`,
  `tree[position]`: `0 <= position < n`
- `reverse(left, right)`, `prod(left, right)`:
  `0 <= left <= right <= n`

違反した場合は`ValueError`を送出します。

## 返り値と副作用

- `tree.len`: 現在の長さ
- `tree.insert(position, value)`: 指定位置の直前へ挿入
- `tree.erase(position)`: 要素を削除し、その値を返す
- `tree.get(position)`, `tree[position]`: 要素を返す
- `tree.set(position, value)`, `tree[position] = value`: 要素を更新
- `tree.reverse(left, right)`: 半開区間`[left, right)`を反転
- `tree.prod(left, right)`: 半開区間`[left, right)`の積
- `tree.allProd()`: 全要素の積
- `tree.toSeq()`: 現在の列を`seq[S]`として返す

空区間の`prod`は`e()`を返します。

各部分木に順方向と逆方向の積を保持するため、非可換Monoidでも区間反転を
正しく処理できます。反転後の積を計算する追加callbackは不要です。

## 具体例

~~~nim
import atcoder/extra/structure/implicit_treap

proc op(
    left,
    right: int,
): int =
  left + right

proc e(): int =
  0

type
  SumTreap =
    ImplicitTreapType[int](
      op,
      e,
    )

var tree =
  SumTreap.init(
    @[1, 2, 3, 4]
  )

tree.insert(
  2,
  10,
)

doAssert tree.toSeq() ==
  @[1, 2, 10, 3, 4]

tree.reverse(
  1,
  4,
)

doAssert tree.toSeq() ==
  @[1, 3, 10, 2, 4]

doAssert tree.prod(
  1,
  4,
) == 15
~~~

## 関連API

- `SplayTree`: 自己調整木による動的列。Lazy Action版やLink-Cut Tree基盤も提供
- `PersistentSegTree`: 過去versionを保持する永続セグメント木
- `LazySegTree`: 長さが固定された列に対する区間更新・区間積

このImplicit Treapは所有権を持つコンテナです。内部ノードやrootを公開せず、
split・mergeは内部操作として使用します。

最初の公開版は区間反転とMonoid積を対象とし、Lazy Actionは含みません。

## 計算量と内部実装

現在の長さを`n`とします。

期待計算量:

- `insert`, `erase`, `get`, `set`: `O(log n)`
- `reverse`, `prod`: `O(log n)`
- `allProd`, `len`: `O(1)`
- `toSeq`: `O(n)`
- 長さ`n`の初期列からの構築: `O(n log n)`

最悪計算量は木が偏った場合の`O(n)`です。

メモリ使用量は、後述の保持slot数`h`に対する`O(h)`です。
削除済みノードはfree listで再利用します。

## 値の寿命

削除slotとその値は、再利用・再初期化・上書き・pool破棄まで保持します。
削除済みを含む保持slot数を`h`とします。値代入ではpoolを独立に複製し、
再初期化や代入先への上書きでは旧要素と集計値を破棄します。
独自の寿命hookがある場合、poolの破棄・再初期化は`O(h)`、値代入は
`O(h_destination + h_source)`に各hookの費用が加わります。
Nim 2.2.4/2.2.10のrefcでは、このようなpoolのmoveもslotを走査する場合があります。

refcでノード値が単純コピーできない場合、pool破棄は要素のdestructorを直接呼び、
Nimの`wasMoved`処理で列参照を外します。空値でも利用者のsink hookが資源を
確保できるため、既定ノードの代入は行いません。木をGC管理コンテナに入れた場合も
write barrierを維持します。単純コピーできる値とorcの格納経路は従来どおりです。

値のhookはNimの所有権規則を満たす必要があります。この破棄処理は、`toSeq()`の
返す列や利用者側の列に対するコンパイラの寿命管理を置き換えません。
