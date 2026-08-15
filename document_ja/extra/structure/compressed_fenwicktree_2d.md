# CompressedFenwickTree2D

## 概要

`CompressedFenwickTree2D` は、事前に登録した疎な二次元座標に対して、
オンラインの一点加算と矩形和を行う二次元 Fenwick tree です。

使用する座標は初期化時にすべて登録します。構築後に未知の座標を追加する
fully dynamic な構造ではありません。

## Import

```nim
import atcoder/extra/structure/compressed_fenwicktree_2d
```

## 代数的要件

任意の矩形を四つの prefix 値から復元するため、値の演算には
**可換群 (commutative group)** を要求します。単位元、結合則、逆元に加えて、
二次元分割順序に依存しない可換性を呼び出し側の contract として与えます。

## 座標と矩形

- 座標順は常に `(x, y)` です。
- 矩形は半開区間 `[x1, x2) × [y1, y2)` です。
- 四整数形式の引数順は `x1, x2, y1, y2` です。
- 更新対象の点は初期化時に登録されていなければなりません。
- 登録点の重複は内部の座標構築時に正規化されます。
- 空の登録集合も有効です。

## 操作

- `add`: 登録済み座標 `(x, y)` の値に差分を加えます。
- `prefixSum`: 原点側の半開矩形に対する累積値を返します。
- `sum`: 半開矩形 `[x1, x2) × [y1, y2)` の値を返します。
- `get`: 一点の現在値を返します。
- `allSum`: 登録空間全体の値を返します。

## 公開 API

```nim
    CompressedFenwickPoint2D* =

    CompressedFenwickTree2DBuilder* =

  proc initCompressedFenwickTree2D*[
      CG: CommutativeGroup
  ](
      points:
        openArray[
          CompressedFenwickPoint2D
        ],
      _: typedesc[CG]
  ): CompressedFenwickTree2D[CG] =

  proc initCompressedFenwickTree2DBuilder*():

  proc addPoint*(
      builder:
        var CompressedFenwickTree2DBuilder,
      x,
      y: int
  ) =

  proc registerPoint*(
      builder:
        var CompressedFenwickTree2DBuilder,
      x,
      y: int
  ) {.inline.} =

  proc addPoints*(
      builder:
        var CompressedFenwickTree2DBuilder,
      points:
        openArray[
          CompressedFenwickPoint2D
        ]
  ) =

  proc build*[
      CG: CommutativeGroup
  ](
      builder:
        CompressedFenwickTree2DBuilder,
      _: typedesc[CG]
  ): CompressedFenwickTree2D[CG] =

  proc containsPoint*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG],
      x,
      y: int
  ): bool {.inline.} =

  proc pointCount*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG]
  ): int {.inline.} =

  proc add*[
      CG: CommutativeGroup
  ](
      tree:
        var CompressedFenwickTree2D[CG],
      x,
      y: int,
      delta:
        CG.value_type
  ) =

  proc prefixSum*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG],
      xRight,
      yRight: int
  ): CG.value_type =

  proc sum*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG],
      xLeft,
      xRight,
      yLeft,
      yRight: int
  ): CG.value_type =

  proc get*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG],
      x,
      y: int
  ): CG.value_type =

  proc allSum*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG]
  ): CG.value_type {.inline.} =

  proc `[]`*[
      CG: CommutativeGroup
  ](
      tree:
        CompressedFenwickTree2D[CG],
      x,
      y: int
  ): CG.value_type {.inline.} =
```

## 計算量

登録点数を `P` とすると、通常の一点更新、prefix query、矩形 query は
圧縮された各軸に対して対数時間で動作し、典型的には `O(log² P)` です。
内部メモリは各 Fenwick node が保持する圧縮済み `y` 座標列と値配列の総和です。

## 注意

この構造は一点加算・矩形和用です。一般の segment-tree interface が必要な場合は
`CompressedSegTree2D` を使用してください。
