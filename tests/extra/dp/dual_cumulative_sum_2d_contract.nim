import atcoder/extra/dp/dual_cumulative_sum_2d

block rectangleAdd:
  var cumulative =
    initDualCumulativeSum2D[int](
      height = 3,
      width = 4,
    )

  cumulative.add(
    rowBegin = 1,
    rowEnd = 3,
    colBegin = 0,
    colEnd = 2,
    value = 2,
  )

  cumulative.add(
    row = 2,
    col = 3,
    value = 5,
  )

  cumulative.add(
    0,
    0,
    0,
    4,
    100,
  )

  cumulative.build()

  doAssert cumulative.get(
    row = 0,
    col = 0,
  ) == 0

  doAssert cumulative.get(1, 0) == 2
  doAssert cumulative.get(2, 1) == 2
  doAssert cumulative.get(2, 3) == 5
  doAssert cumulative[1, 1] == 2

  echo "DUAL_CUMULATIVE_SUM_2D_HALF_OPEN_OK"

block inclusiveSlice:
  var cumulative =
    initDualCumulativeSum2D[int](
      3,
      4,
    )

  cumulative.add(
    0 .. 1,
    1 .. 3,
    4,
  )

  cumulative.build()

  doAssert cumulative[0, 1] == 4
  doAssert cumulative[1, 3] == 4
  doAssert cumulative[2, 3] == 0
  doAssert cumulative[-1, 0] == 0
  doAssert cumulative[3, 0] == 0
  doAssert cumulative[0, 4] == 0

  echo "DUAL_CUMULATIVE_SUM_2D_INCLUSIVE_OK"
# NACL-DUAL-CUMULATIVE-SUM-2D-FOCUSED-CONTRACT-EXTENSION-V1-BEGIN

block focusedOverlapClippingAndBuildIdempotence:
  const
    height = 4
    width = 5

  var tree =
    initDualCumulativeSum2D[int](
      height = height,
      width = width,
    )

  tree.add(
    rowBegin = 0,
    rowEnd = height,
    colBegin = 0,
    colEnd = width,
    value = 1,
  )

  tree.add(
    -2 .. 2,
    1 .. 8,
    3,
  )

  tree.add(
    row = 0,
    col = 4,
    value = 7,
  )

  tree.add(
    -1,
    0,
    100,
  )

  tree.add(
    3 .. 10,
    -5 .. 0,
    -4,
  )

  tree.add(
    rowBegin = 2,
    rowEnd = 2,
    colBegin = 0,
    colEnd = width,
    value = 999,
  )

  tree.build()
  tree.build()

  let expected = @[
    @[1, 4, 4, 4, 11],
    @[1, 4, 4, 4, 4],
    @[1, 4, 4, 4, 4],
    @[-3, 1, 1, 1, 1],
  ]

  for row in 0 ..< height:
    for col in 0 ..< width:
      doAssert tree[row, col] == expected[row][col]
      doAssert tree.get(row, col) == expected[row][col]

  doAssert tree[-1, 0] == 0
  doAssert tree[0, -1] == 0
  doAssert tree[height, 0] == 0
  doAssert tree[0, width] == 0
  doAssert tree.get(-1, -1) == 0
  doAssert tree.get(height, width) == 0

block initializerProcedure:
  var tree: DualCumulativeSum2D[int]

  tree.init(
    height = 2,
    width = 3,
  )

  tree.add(
    0 .. 1,
    0 .. 2,
    2,
  )

  tree.add(
    rowBegin = 1,
    rowEnd = 2,
    colBegin = 1,
    colEnd = 3,
    value = -5,
  )

  tree.build()

  doAssert tree[0, 0] == 2
  doAssert tree[0, 1] == 2
  doAssert tree[0, 2] == 2
  doAssert tree[1, 0] == 2
  doAssert tree[1, 1] == -3
  doAssert tree[1, 2] == -3

block zeroDimensionShapes:
  var zeroHeight =
    initDualCumulativeSum2D[int](
      height = 0,
      width = 5,
    )

  zeroHeight.add(
    -4 .. 8,
    -4 .. 8,
    7,
  )

  zeroHeight.add(
    rowBegin = 0,
    rowEnd = 0,
    colBegin = 0,
    colEnd = 5,
    value = 11,
  )

  zeroHeight.build()
  zeroHeight.build()

  doAssert zeroHeight[0, 0] == 0
  doAssert zeroHeight[-1, 2] == 0
  doAssert zeroHeight.get(0, 4) == 0

  var zeroWidth =
    initDualCumulativeSum2D[int](
      height = 5,
      width = 0,
    )

  zeroWidth.add(
    -4 .. 8,
    -4 .. 8,
    7,
  )

  zeroWidth.add(
    rowBegin = 0,
    rowEnd = 5,
    colBegin = 0,
    colEnd = 0,
    value = 11,
  )

  zeroWidth.build()

  doAssert zeroWidth[0, 0] == 0
  doAssert zeroWidth[4, -1] == 0
  doAssert zeroWidth.get(4, 0) == 0

  var zeroBoth =
    initDualCumulativeSum2D[int](
      height = 0,
      width = 0,
    )

  zeroBoth.build()

  doAssert zeroBoth[0, 0] == 0
  doAssert zeroBoth.get(-1, -1) == 0

block genericInt64ValueType:
  var tree =
    initDualCumulativeSum2D[int64](
      height = 2,
      width = 2,
    )

  tree.add(
    rowBegin = 0,
    rowEnd = 2,
    colBegin = 0,
    colEnd = 2,
    value = int64(3),
  )

  tree.add(
    row = 1,
    col = 1,
    value = int64(-8),
  )

  tree.build()

  doAssert tree[0, 0] == int64(3)
  doAssert tree[0, 1] == int64(3)
  doAssert tree[1, 0] == int64(3)
  doAssert tree[1, 1] == int64(-5)

when defined(
  naclDualCumulativeSum2DPostBuildAddMustReject
):
  block postBuildAddMustReject:
    var tree =
      initDualCumulativeSum2D[int](
        height = 2,
        width = 2,
      )

    tree.build()

    tree.add(
      row = 0,
      col = 0,
      value = 1,
    )

    echo "POST_BUILD_ADD_UNEXPECTEDLY_ACCEPTED"

when defined(
  naclDualCumulativeSum2DInvalidHalfOpenMustReject
):
  block invalidHalfOpenRangeMustReject:
    var tree =
      initDualCumulativeSum2D[int](
        height = 2,
        width = 2,
      )

    tree.add(
      rowBegin = -1,
      rowEnd = 1,
      colBegin = 0,
      colEnd = 1,
      value = 1,
    )

    echo "INVALID_HALF_OPEN_RANGE_UNEXPECTEDLY_ACCEPTED"

block writeUsesRowMajorOrder:
  var tree =
    initDualCumulativeSum2D[int](
      height = 2,
      width = 3,
    )

  for row in 0 ..< 2:
    for col in 0 ..< 3:
      tree.add(
        row,
        col,
        row * 3 + col + 1,
      )

  tree.build()
  tree.write()

# NACL-DUAL-CUMULATIVE-SUM-2D-FOCUSED-CONTRACT-EXTENSION-V1-END
