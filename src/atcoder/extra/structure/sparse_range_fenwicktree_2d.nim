when not declared ATCODER_EXTRA_STRUCTURE_DENSE_RANGE_FENWICKTREE_2D_HPP:
  const ATCODER_EXTRA_STRUCTURE_DENSE_RANGE_FENWICKTREE_2D_HPP = 1

  import atcoder/extra/structure/sparse_fenwicktree_2d

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
    mixin `*`

    assert 0 <= row
    assert row <= self.heightValue
    assert 0 <= col
    assert col <= self.widthValue

    if row == self.heightValue or
        col == self.widthValue:
      return

    let
      rowValue = T(row)
      colValue = T(col)

    self.b00.add(
      row,
      col,
      delta,
    )

    self.b10.add(
      row,
      col,
      delta * rowValue,
    )

    self.b01.add(
      row,
      col,
      delta * colValue,
    )

    self.b11.add(
      row,
      col,
      delta * rowValue * colValue,
    )

  proc prefixSum[T](
      self: SparseRangeFenwickTree2D[T],
      rowEnd,
      colEnd: int,
  ): T =
    mixin `+`, `-`, `*`

    assert 0 <= rowEnd
    assert rowEnd <= self.heightValue
    assert 0 <= colEnd
    assert colEnd <= self.widthValue

    let
      rowValue = T(rowEnd)
      colValue = T(colEnd)
      q00 = self.b00.prefixSum(
        rowEnd,
        colEnd,
      )
      q10 = self.b10.prefixSum(
        rowEnd,
        colEnd,
      )
      q01 = self.b01.prefixSum(
        rowEnd,
        colEnd,
      )
      q11 = self.b11.prefixSum(
        rowEnd,
        colEnd,
      )

    result =
      rowValue * colValue * q00 -
      colValue * q10 -
      rowValue * q01 +
      q11

  proc add*[T](
      self: var SparseRangeFenwickTree2D[T],
      rowBegin,
      rowEnd,
      colBegin,
      colEnd: int,
      delta: T,
  ) =
    mixin `-`

    assert 0 <= rowBegin
    assert rowBegin <= rowEnd
    assert rowEnd <= self.heightValue
    assert 0 <= colBegin
    assert colBegin <= colEnd
    assert colEnd <= self.widthValue

    if rowBegin == rowEnd or
        colBegin == colEnd:
      return

    self.addCorner(
      rowBegin,
      colBegin,
      delta,
    )

    self.addCorner(
      rowBegin,
      colEnd,
      -delta,
    )

    self.addCorner(
      rowEnd,
      colBegin,
      -delta,
    )

    self.addCorner(
      rowEnd,
      colEnd,
      delta,
    )

  proc sum*[T](
      self: SparseRangeFenwickTree2D[T],
      rowBegin,
      rowEnd,
      colBegin,
      colEnd: int,
  ): T =
    mixin `+`, `-`

    assert 0 <= rowBegin
    assert rowBegin <= rowEnd
    assert rowEnd <= self.heightValue
    assert 0 <= colBegin
    assert colBegin <= colEnd
    assert colEnd <= self.widthValue

    if rowBegin == rowEnd or
        colBegin == colEnd:
      return T(0)

    result =
      self.prefixSum(
        rowEnd,
        colEnd,
      ) -
      self.prefixSum(
        rowBegin,
        colEnd,
      ) -
      self.prefixSum(
        rowEnd,
        colBegin,
      ) +
      self.prefixSum(
        rowBegin,
        colBegin,
      )

  proc get*[T](
      self: SparseRangeFenwickTree2D[T],
      row,
      col: int,
  ): T {.inline.} =
    assert 0 <= row
    assert row < self.heightValue
    assert 0 <= col
    assert col < self.widthValue

    self.sum(
      row,
      row + 1,
      col,
      col + 1,
    )
