# Mo's Algorithm

`Mo` は、静的配列に対する多数の offline 区間 query を、区間端点の移動回数が少なくなる順序に並べ替える technique です。

各 query を独立に処理すると重い場合でも、現在区間に要素を1個追加・削除する操作が軽ければ、全 query をまとめて高速に処理できます。

## 使いどころ

- 区間内の異なる値の個数
- 区間内の頻度情報
- 区間 query がすべて先に与えられる
- update がない静的配列
- add/remove が `O(1)` または軽い問題

## 考え方

左端を block に分け、同じ block 内では右端順に query を並べます。さらに block ごとに右端の昇順・降順を交互にすると、端点移動が減ります。

現在区間 `[currentL, currentR)` を query 区間へ少しずつ移動し、そのたびに callback を呼びます。

## import

~~~nim
import atcoder/extra/algorithm/mo
~~~

## API

~~~nim
proc initMo(n: int, blockSize = 0): Mo
proc addQuery(mo: var Mo, l, r: int): int
proc orderedQueries(mo: Mo): seq[MoQuery]

proc run(
  mo: Mo,
  addLeft: proc(index: int),
  addRight: proc(index: int),
  removeLeft: proc(index: int),
  removeRight: proc(index: int),
  answer: proc(queryId: int)
)

proc run(
  mo: Mo,
  add: proc(index: int),
  remove: proc(index: int),
  answer: proc(queryId: int)
)
~~~

query 区間は半開区間 `[l, r)` です。

## 使用例

<!-- nim-line-numbers -->
~~~nim
import std/tables
import atcoder/extra/algorithm/mo

let a = @[1, 2, 1, 3, 2]

var queries = initMo(a.len)

discard queries.addQuery(0, 3)
discard queries.addQuery(1, 5)

var
  freq = initTable[int, int]()
  distinctCount = 0
  ans = newSeq[int](queries.len)

proc add(index: int) =
  let x = a[index]
  let old = freq.getOrDefault(x, 0)

  if old == 0:
    distinctCount.inc

  freq[x] = old + 1

proc remove(index: int) =
  let x = a[index]
  let old = freq[x]

  if old == 1:
    freq.del(x)
    distinctCount.dec
  else:
    freq[x] = old - 1

proc save(id: int) =
  ans[id] = distinctCount

queries.run(add, remove, save)
~~~

## 計算量

通常の block size では、おおよそ

```text
O(q log q + (q B + n^2 / B) * add/remove のコスト)
B = block size（既定値は max(1, floor(sqrt(n)))）
```

です。query 保存に `O(q)`、並べ替え用に `O(q)` の領域を使います。

## 旧APIとの関係

`atcoder/extra/structure/mo` は同じ内部コアへ委譲する互換入口です。
旧 `initMo(N, Q)` の第2引数はquery数、新APIの第2引数はblock sizeです。
両方をimportする場合は `initMo(N = n, Q = q)` または
`initMo(n, blockSize = b)` と名前付き引数で区別してください。

## 注意

- query はすべて先に登録します。
- 配列 update のない基本形です。
- `add` と `remove` は互いに整合する必要があります。
- query ID 順に答えを保存してください。

## 関連資料・他言語ライブラリ

- [cp-algorithms: Mo's Algorithm](https://cp-algorithms.com/data_structures/sqrt_decomposition.html#mos-algorithm)
- ei1333 Library: Mo
- Nyaan Library: Mo
