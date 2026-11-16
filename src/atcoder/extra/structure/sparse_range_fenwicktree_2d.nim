when not declared ATCODER_EXTRA_STRUCTURE_SPARSE_RANGE_FENWICKTREE_2D_HPP:
  const ATCODER_EXTRA_STRUCTURE_SPARSE_RANGE_FENWICKTREE_2D_HPP = 1

  import atcoder/extra/structure/sparse_fenwicktree_2d
  import atcoder/extra/structure/internal/range_fenwicktree_2d_core

  type
    SparseRangeFenwickTree2D*[T] = object
      heightValue: int
      widthValue: int
      b00: SparseFenwickTree2D[T]
      b10: SparseFenwickTree2D[T]
      b01: SparseFenwickTree2D[T]
      b11: SparseFenwickTree2D[T]

  proc initSparseRangeFenwickTree2D*[T](
      height,
      width: int,
  ): SparseRangeFenwickTree2D[T] =
    assert height >= 0
    assert width >= 0

    result.heightValue = height
    result.widthValue = width

    result.b00 =
      initSparseFenwickTree2D[T](
        height,
        width,
      )

    result.b10 =
      initSparseFenwickTree2D[T](
        height,
        width,
      )

    result.b01 =
      initSparseFenwickTree2D[T](
        height,
        width,
      )

    result.b11 =
      initSparseFenwickTree2D[T](
        height,
        width,
      )

  proc addCorner[T](
      self: var SparseRangeFenwickTree2D[T],
      row,
      col: int,
      delta: T,
  ) =
    rangeFenwickAddCornerBody(self, T, row, col, delta)

  proc prefixSum[T](
      self: SparseRangeFenwickTree2D[T],
      rowEnd,
      colEnd: int,
  ): T =
    rangeFenwickPrefixSumBody(self, T, rowEnd, colEnd)

  proc add*[T](
      self: var SparseRangeFenwickTree2D[T],
      rowBegin,
      rowEnd,
      colBegin,
      colEnd: int,
      delta: T,
  ) =
    rangeFenwickAddBody(self, T, rowBegin, rowEnd, colBegin, colEnd, delta)

  proc sum*[T](
      self: SparseRangeFenwickTree2D[T],
      rowBegin,
      rowEnd,
      colBegin,
      colEnd: int,
  ): T =
    rangeFenwickSumBody(self, T, rowBegin, rowEnd, colBegin, colEnd)

  proc get*[T](
      self: SparseRangeFenwickTree2D[T],
      row,
      col: int,
  ): T {.inline.} =
    rangeFenwickGetBody(self, T, row, col)
