# Lazy Segtree

[モノイド](https://ja.wikipedia.org/wiki/%E3%83%A2%E3%83%8E%E3%82%A4%E3%83%89) $(S, \cdot: S \times S \to S, e \in S)$と、$S$ から $S$ への写像の集合 $F$ であって、以下の条件を満たすようなものについて使用できるデータ構造です。

- $F$ は恒等写像 $\mathrm{id}$ を含む。つまり、任意の $x \in S$ に対し $\mathrm{id}(x) = x$ をみたす。
- $F$ は写像の合成について閉じている。つまり、任意の $f, g \in F$ に対し $f \circ g \in F$ である。
- 任意の $f \in F, x, y \in S$ に対し $f(x \cdot y) = f(x) \cdot f(y)$ をみたす。

長さ $N$ の $S$ の配列に対し、

- 区間の要素に一括で $F$ の要素 $f$ を作用($x = f(x)$ )
- 区間の要素の総積の取得

を $O(\log N)$ で行うことが出来ます。詳細な要件は [Appendix](./appendix.html) を参照してください。

また、このライブラリはオラクルとして`op, e, mapping, composition, id`を使用しますが、これらが定数時間で動くものと仮定したときの計算量を記述します。オラクル内部の計算量が $O(f(n))$ である場合はすべての計算量が $O(f(n))$ 倍となります。

## コンストラクタ

```nim
(1) var seg = initLazySegTree[S, F](n:int, op, e, mapping, composition, id)
    var seg = LazySegTreeType[S, F](op, e, mapping, composition, id).init(n)
    var seg = LazySegTree.getType(S, F, op, e, mapping, composition, id).init(n)
(2) var seg = initLazySegTree[S, F](v:seq[S], op, e, mapping, composition, id)
    var seg = LazySegTreeType[S, F](op, e, mapping, composition, id).init(v)
    var seg = LazySegTree.getType(S, F, op, e, mapping, composition, id).init(v)
```

- モノイドの型 `S`
- $\cdot: S \times S \to S$ を計算する関数 `S op(S a, S b)`
- $e$ を返す関数 `e():S`
- 写像の型 `F`
- $f(x)$ を返す関数 `mapping(f:F, x:S):S`
- $f \circ g$ を返す関数 `composition(f:F, f:F):F`
- $id$ を返す関数 `id():F`

を定義する必要があります。
詳しくは、使用例や [こちら](https://atcoder.jp/contests/practice2/editorial) も参照してください。

- (1): 長さ `n` の数列 `a` を作ります。初期値は全部`e()`です。
- (2): 長さ `n = v.len` の数列 `a` を作ります。`v` の内容が初期値となります。

**@{keyword.constraints}**

- $0 \leq n \leq 10^8$

**@{keyword.complexity}**

- $O(n)$

## set

```nim
seg.set(p:int, x:S):void
seg[p:int] = x:S
```

`a[p] = x`

**@{keyword.constraints}**

- $0 \leq p < n$

**@{keyword.complexity}**

- $O(\log n)$

## get

```nim
seg.get(p:int):S
seg[p:int]:S
```

`a[p]` を返します。

**@{keyword.constraints}**

- $0 \leq p < n$

**@{keyword.complexity}**

- $O(\log n)$

## prod

```nim
seg.prod(l..<r):S
seg[l..<r]:S
```

`op(a[l], ..., a[r - 1])` を、モノイドの性質を満たしていると仮定して計算します。$l = r$ のときは `e()` を返します。

**@{keyword.constraints}**

- $0 \leq l \leq r \leq n$

**@{keyword.complexity}**

- $O(\log n)$

## all_prod

```nim
seg.all_prod():S
```

`op(a[0], ..., a[n-1])` を計算します。$n = 0$ のときは `e()` を返します。

**@{keyword.complexity}**

- $O(1)$

## apply

```nim
(1) seg.apply(p:int, f:F):void
(2) seg.apply(l..<r, f:F):void
```

- (1) `a[p] = f(a[p])`
- (2) `i = l..r-1`について`a[i] = f(a[i])`

**@{keyword.constraints}**

- (1) $0 \leq p < n$
- (2) $0 \leq l \leq r \leq n$

**@{keyword.complexity}**

- $O(\log n)$

## max_right

```nim
(1) seg.max_right(l:int, g:(S)->bool):int
(2💻) seg.max_right(l:int, g:(S)->bool):int
```

- (1): 関数 `g(x:S):bool` を定義する必要があります。segtreeの上で二分探索をします。  
- (2): `S`を引数にとり`bool`を返す関数オブジェクトを渡して使用します。  

以下の条件を両方満たす `r` を(いずれか一つ)返します。

- `r = l` もしくは `g(op(a[l], a[l + 1], ..., a[r - 1])) = true`
- `r = n` もしくは `g(op(a[l], a[l + 1], ..., a[r])) = false`

`g`が単調だとすれば、`g(op(a[l], a[l + 1], ..., a[r - 1])) = true` となる最大の `r`、と解釈することが可能です。

**@{keyword.constraints}**

- `g`を同じ引数で呼んだ時、返り値は等しい(=副作用はない)
- `g(e()) = true`
- $0 \leq l \leq n$

**@{keyword.complexity}**

- $O(\log n)$

## min_left

```nim
(1) seg.min_left(r:int, g:(S)->bool):int
(2💻) int seg.min_left(r:int, g:(S)->bool):int
```

- (1): 関数 `bool g(S x)` を定義する必要があります。segtreeの上で二分探索をします。  
- (2): `S`を引数にとり`bool`を返す関数オブジェクトを渡して使用します。  

以下の条件を両方満たす `l` を(いずれか一つ)返します。

- `l = r` もしくは `g(op(a[l], a[l + 1], ..., a[r - 1])) = true`
- `l = 0` もしくは `g(op(a[l - 1], a[l], ..., a[r - 1])) = false`

`g`が単調だとすれば、`g(op(a[l], a[l + 1], ..., a[r - 1])) = true` となる最小の `l`、と解釈することが可能です。

**@{keyword.constraints}**

- `g`を同じ引数で呼んだ時、返り値は等しい(=副作用はない)
- `g(e()) = true`
- $0 \leq r \leq n$

**@{keyword.complexity}**

- $O(\log n)$

## @{keyword.examples}

@{example.lazyseg_practice1}

@{example.lazyseg_practice2}

<!-- NIM_ACL_LAZY_MONOID_SEGTREE_FACADE_START -->

## ActionMonoid記述子による構築

`atcoder/extra/structure/monoid_segtree`をimportすると、
ActionMonoid記述子からLazySegTreeを構築できます。

```nim
useActionMonoid(
  RangeAddMax,
  AddMonoid,
  MaxMonoid,
  mapping,
)

var tree = RangeAddMax.initLazySegTree(values)
```

公開上は作用Monoid `F`を値Monoid `S`より先に記述します。
作用合成`composition(f, g)`は`f` after `g`です。

従来の`useActedMonoid(Name, S, F, mapping)`と
callback constructorも維持されます。

<!-- NIM_ACL_LAZY_MONOID_SEGTREE_FACADE_END -->
