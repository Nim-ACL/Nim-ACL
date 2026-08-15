# CompressedFenwickTree2D

## Overview

`CompressedFenwickTree2D` is a two-dimensional Fenwick tree for online
point additions and rectangle sums over a sparse set of coordinates that is
registered in advance.

All usable coordinates are supplied during initialization. This is not a
fully dynamic structure that accepts previously unknown coordinates after
construction.

## Import

```nim
import atcoder/extra/structure/compressed_fenwicktree_2d
```

## Algebraic requirement

An arbitrary rectangle is recovered from four prefix aggregates, so the value
operation must form a **commutative group**. The caller supplies the identity,
associative operation, inverse, and commutativity as the algebraic contract.

## Coordinates and rectangles

- Coordinate order is always `(x, y)`.
- Rectangles use `[x1, x2) × [y1, y2)`.
- The four-integer overload uses `x1, x2, y1, y2`.
- Every updated point must have been registered during initialization.
- Duplicate registered points are normalized while the topology is built.
- An empty registered point set is valid.

## Operations

- `add`: Adds a delta at the registered coordinate `(x, y)`.
- `prefixSum`: Returns the aggregate over an origin-anchored half-open rectangle.
- `sum`: Returns the aggregate over `[x1, x2) × [y1, y2)`.
- `get`: Returns the current value at one point.
- `allSum`: Returns the aggregate over the complete registered domain.

## Public API

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

## Complexity

For `P` registered points, point updates, prefix queries, and rectangle
queries are logarithmic in both compressed dimensions and are typically
`O(log² P)`. Memory is the total size of the compressed `y` lists and value
arrays stored by the Fenwick nodes.

## Notes

This structure is intended for point-add and rectangle-sum workloads. Use
`CompressedSegTree2D` when a segment-tree interface is required.
