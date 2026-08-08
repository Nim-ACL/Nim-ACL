import atcoder/extra/structure/sparse_fenwicktree_2d


type
  SparseDualFenwickTree2D*[
      T
  ] =
    object
      difference:
        SparseFenwickTree2D[T]


proc initSparseDualFenwickTree2D*[
    T
](
    height,
    width:
      int
): SparseDualFenwickTree2D[T] =
  ## Builds a fixed-size sparse two-dimensional dual Fenwick tree.
  ##
  ## Rectangle additions are represented by a sparse two-dimensional
  ## difference surface. Only touched internal Fenwick nodes are stored.

  doAssert height >= 0
  doAssert width >= 0

  result.difference =
    initSparseFenwickTree2D[
      T
    ](
      height,
      width,
    )


proc height*[
    T
](
    tree:
      SparseDualFenwickTree2D[T]
): int =
  tree.difference.height()


proc width*[
    T
](
    tree:
      SparseDualFenwickTree2D[T]
): int =
  tree.difference.width()


proc add*[
    T
](
    tree:
      var SparseDualFenwickTree2D[T],
    rowBegin,
    rowEnd,
    colBegin,
    colEnd:
      int,
    delta:
      T
) =
  ## Adds delta over
  ## [rowBegin, rowEnd) x [colBegin, colEnd).

  mixin `+`, `-`

  doAssert 0 <= rowBegin
  doAssert rowBegin <= rowEnd
  doAssert rowEnd <= tree.height()

  doAssert 0 <= colBegin
  doAssert colBegin <= colEnd
  doAssert colEnd <= tree.width()

  if rowBegin == rowEnd or colBegin == colEnd:
    return

  var zero:
    T

  let negativeDelta =
    zero - delta

  tree.difference.add(
    rowBegin,
    colBegin,
    delta,
  )

  if rowEnd < tree.height():
    tree.difference.add(
      rowEnd,
      colBegin,
      negativeDelta,
    )

  if colEnd < tree.width():
    tree.difference.add(
      rowBegin,
      colEnd,
      negativeDelta,
    )

  if rowEnd < tree.height() and colEnd < tree.width():
    tree.difference.add(
      rowEnd,
      colEnd,
      delta,
    )


proc get*[
    T
](
    tree:
      SparseDualFenwickTree2D[T],
    row,
    col:
      int
): T =
  ## Returns the value at (row, col).

  mixin `+`

  doAssert 0 <= row
  doAssert row < tree.height()

  doAssert 0 <= col
  doAssert col < tree.width()

  tree.difference.prefixSum(
    row + 1,
    col + 1,
  )


proc `[]`*[
    T
](
    tree:
      SparseDualFenwickTree2D[T],
    row,
    col:
      int
): T =
  ## Alias for get(row, col).

  mixin `+`

  tree.get(
    row,
    col,
  )
