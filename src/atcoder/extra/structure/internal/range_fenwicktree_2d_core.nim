when not declared ATCODER_EXTRA_STRUCTURE_INTERNAL_RANGE_FENWICKTREE_2D_CORE_HPP:
  const ATCODER_EXTRA_STRUCTURE_INTERNAL_RANGE_FENWICKTREE_2D_CORE_HPP* = 1

  # Expand inside the owning proc so private fields, helpers and generic
  # operators keep their original scope. Each body is the only statement in
  # that proc; arguments are its locals, with no repeated side effects.
  # Storage and Fenwick traversal belong to the dense/sparse backends.

  template rangeFenwickAddCornerBody*(tree, ValueType, row, col, delta: untyped) {.dirty.} =
    mixin `*`

    assert 0 <= row
    assert row <= tree.heightValue
    assert 0 <= col
    assert col <= tree.widthValue

    if row == tree.heightValue or
        col == tree.widthValue:
      return

    let
      rowValue = ValueType(row)
      colValue = ValueType(col)

    tree.b00.add(
      row,
      col,
      delta,
    )

    tree.b10.add(
      row,
      col,
      delta * rowValue,
    )

    tree.b01.add(
      row,
      col,
      delta * colValue,
    )

    tree.b11.add(
      row,
      col,
      delta * rowValue * colValue,
    )

  template rangeFenwickPrefixSumBody*(tree, ValueType, rowEnd, colEnd: untyped) {.dirty.} =
    mixin `+`, `-`, `*`

    assert 0 <= rowEnd
    assert rowEnd <= tree.heightValue
    assert 0 <= colEnd
    assert colEnd <= tree.widthValue

    let
      rowValue = ValueType(rowEnd)
      colValue = ValueType(colEnd)
      q00 = tree.b00.prefixSum(
        rowEnd,
        colEnd,
      )
      q10 = tree.b10.prefixSum(
        rowEnd,
        colEnd,
      )
      q01 = tree.b01.prefixSum(
        rowEnd,
        colEnd,
      )
      q11 = tree.b11.prefixSum(
        rowEnd,
        colEnd,
      )

    result =
      rowValue * colValue * q00 -
      colValue * q10 -
      rowValue * q01 +
      q11

  template rangeFenwickAddBody*(tree, ValueType, rowBegin, rowEnd, colBegin, colEnd, delta: untyped) {.dirty.} =
    mixin `-`

    assert 0 <= rowBegin
    assert rowBegin <= rowEnd
    assert rowEnd <= tree.heightValue
    assert 0 <= colBegin
    assert colBegin <= colEnd
    assert colEnd <= tree.widthValue

    if rowBegin == rowEnd or
        colBegin == colEnd:
      return

    tree.addCorner(
      rowBegin,
      colBegin,
      delta,
    )

    tree.addCorner(
      rowBegin,
      colEnd,
      -delta,
    )

    tree.addCorner(
      rowEnd,
      colBegin,
      -delta,
    )

    tree.addCorner(
      rowEnd,
      colEnd,
      delta,
    )

  template rangeFenwickSumBody*(tree, ValueType, rowBegin, rowEnd, colBegin, colEnd: untyped) {.dirty.} =
    mixin `+`, `-`

    assert 0 <= rowBegin
    assert rowBegin <= rowEnd
    assert rowEnd <= tree.heightValue
    assert 0 <= colBegin
    assert colBegin <= colEnd
    assert colEnd <= tree.widthValue

    if rowBegin == rowEnd or
        colBegin == colEnd:
      return ValueType(0)

    result =
      tree.prefixSum(
        rowEnd,
        colEnd,
      ) -
      tree.prefixSum(
        rowBegin,
        colEnd,
      ) -
      tree.prefixSum(
        rowEnd,
        colBegin,
      ) +
      tree.prefixSum(
        rowBegin,
        colBegin,
      )

  template rangeFenwickGetBody*(tree, ValueType, row, col: untyped) {.dirty.} =
    assert 0 <= row
    assert row < tree.heightValue
    assert 0 <= col
    assert col < tree.widthValue

    tree.sum(
      row,
      row + 1,
      col,
      col + 1,
    )
