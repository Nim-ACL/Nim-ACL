import std/tables


type
  SparseFenwickTree2D*[
      T
  ] =
    object
      heightValue:
        int

      widthValue:
        int

      data:
        Table[
          tuple[
            rowIndex:
              int,
            colIndex:
              int
          ],
          T
        ]


proc initSparseFenwickTree2D*[
    T
](
    height,
    width:
      int
): SparseFenwickTree2D[T] =
  ## Builds a fixed-size sparse two-dimensional Fenwick tree.
  ##
  ## The logical grid has size (height, width). Storage is allocated
  ## only for internal Fenwick nodes touched by point additions.

  doAssert height >= 0
  doAssert width >= 0

  result.heightValue =
    height

  result.widthValue =
    width

  result.data =
    initTable[
      tuple[
        rowIndex:
          int,
        colIndex:
          int
      ],
      T
    ]()


proc height*[
    T
](
    tree:
      SparseFenwickTree2D[T]
): int =
  tree.heightValue


proc width*[
    T
](
    tree:
      SparseFenwickTree2D[T]
): int =
  tree.widthValue


proc sparseFenwickAdvance(
    index,
    limit:
      int
): int =
  doAssert index > 0
  doAssert index <= limit

  let step =
    index and -index

  if index > limit - step:
    0
  else:
    index + step


proc add*[
    T
](
    tree:
      var SparseFenwickTree2D[T],
    row,
    col:
      int,
    delta:
      T
) =
  ## Adds delta to the point (row, col).

  mixin `+`

  doAssert 0 <= row
  doAssert row < tree.heightValue
  doAssert 0 <= col
  doAssert col < tree.widthValue

  var rowIndex =
    row + 1

  while rowIndex > 0:
    var colIndex =
      col + 1

    while colIndex > 0:
      let key =
        (
          rowIndex:
            rowIndex,
          colIndex:
            colIndex,
        )

      tree.data[
        key
      ] =
        tree.data.getOrDefault(
          key
        ) +
        delta

      let nextCol =
        sparseFenwickAdvance(
          colIndex,
          tree.widthValue,
        )

      if nextCol == 0:
        break

      colIndex =
        nextCol

    let nextRow =
      sparseFenwickAdvance(
        rowIndex,
        tree.heightValue,
      )

    if nextRow == 0:
      break

    rowIndex =
      nextRow


proc prefixSum*[
    T
](
    tree:
      SparseFenwickTree2D[T],
    rowEnd,
    colEnd:
      int
): T =
  ## Returns the sum over [0, rowEnd) x [0, colEnd).

  mixin `+`

  doAssert 0 <= rowEnd
  doAssert rowEnd <= tree.heightValue
  doAssert 0 <= colEnd
  doAssert colEnd <= tree.widthValue

  var rowIndex =
    rowEnd

  while rowIndex > 0:
    var colIndex =
      colEnd

    while colIndex > 0:
      result =
        result +
        tree.data.getOrDefault(
          (
            rowIndex:
              rowIndex,
            colIndex:
              colIndex,
          )
        )

      colIndex -=
        colIndex and -colIndex

    rowIndex -=
      rowIndex and -rowIndex


proc sum*[
    T
](
    tree:
      SparseFenwickTree2D[T],
    rowBegin,
    rowEnd,
    colBegin,
    colEnd:
      int
): T =
  ## Returns the sum over
  ## [rowBegin, rowEnd) x [colBegin, colEnd).

  mixin `+`, `-`

  doAssert 0 <= rowBegin
  doAssert rowBegin <= rowEnd
  doAssert rowEnd <= tree.heightValue
  doAssert 0 <= colBegin
  doAssert colBegin <= colEnd
  doAssert colEnd <= tree.widthValue

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


proc get*[
    T
](
    tree:
      SparseFenwickTree2D[T],
    row,
    col:
      int
): T =
  ## Returns the value at (row, col).

  doAssert 0 <= row
  doAssert row < tree.heightValue
  doAssert 0 <= col
  doAssert col < tree.widthValue

  tree.sum(
    row,
    row + 1,
    col,
    col + 1,
  )


proc allSum*[
    T
](
    tree:
      SparseFenwickTree2D[T]
): T =
  ## Returns the sum over the whole logical grid.

  tree.prefixSum(
    tree.heightValue,
    tree.widthValue,
  )


proc `[]`*[
    T
](
    tree:
      SparseFenwickTree2D[T],
    row,
    col:
      int
): T =
  ## Alias for get(row, col).

  tree.get(
    row,
    col,
  )
