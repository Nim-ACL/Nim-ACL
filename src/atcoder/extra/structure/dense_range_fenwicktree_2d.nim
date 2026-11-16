when not declared ATCODER_EXTRA_STRUCTURE_DENSE_RANGE_FENWICKTREE_2D_HPP:
  const ATCODER_EXTRA_STRUCTURE_DENSE_RANGE_FENWICKTREE_2D_HPP = 1

  import atcoder/extra/structure/dense_fenwicktree_2d
  import atcoder/extra/structure/internal/range_fenwicktree_2d_core

  type
    DenseRangeFenwickTree2D*[T] = object
      heightValue: int
      widthValue: int
      b00: DenseFenwickTree2D[T]
      b10: DenseFenwickTree2D[T]
      b01: DenseFenwickTree2D[T]
      b11: DenseFenwickTree2D[T]

  proc initDenseRangeFenwickTree2D*[T](
      height,
      width: int,
  ): DenseRangeFenwickTree2D[T] =
    assert height >= 0
    assert width >= 0

    result.heightValue = height
    result.widthValue = width

    result.b00 =
      initDenseFenwickTree2D[T](
        height,
        width,
      )

    result.b10 =
      initDenseFenwickTree2D[T](
        height,
        width,
      )

    result.b01 =
      initDenseFenwickTree2D[T](
        height,
        width,
      )

    result.b11 =
      initDenseFenwickTree2D[T](
        height,
        width,
      )

  proc addCorner[T](
      self: var DenseRangeFenwickTree2D[T],
      row,
      col: int,
      delta: T,
  ) =
    rangeFenwickAddCornerBody(self, T, row, col, delta)

  proc prefixSum[T](
      self: DenseRangeFenwickTree2D[T],
      rowEnd,
      colEnd: int,
  ): T =
    rangeFenwickPrefixSumBody(self, T, rowEnd, colEnd)

  proc add*[T](
      self: var DenseRangeFenwickTree2D[T],
      rowBegin,
      rowEnd,
      colBegin,
      colEnd: int,
      delta: T,
  ) =
    rangeFenwickAddBody(self, T, rowBegin, rowEnd, colBegin, colEnd, delta)

  proc sum*[T](
      self: DenseRangeFenwickTree2D[T],
      rowBegin,
      rowEnd,
      colBegin,
      colEnd: int,
  ): T =
    rangeFenwickSumBody(self, T, rowBegin, rowEnd, colBegin, colEnd)

  proc get*[T](
      self: DenseRangeFenwickTree2D[T],
      row,
      col: int,
  ): T {.inline.} =
    rangeFenwickGetBody(self, T, row, col)
