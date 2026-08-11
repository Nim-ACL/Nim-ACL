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

# NACL-M80-DUAL-CUMULATIVE-SUM-2D-CONTRACT-EXTENSION

proc m80NewGrid(
    height,
    width: int
): seq[seq[int]] =
  result =
    newSeq[
      seq[int]
    ](
      height
    )

  for row in 0 ..< height:
    result[row] =
      newSeq[int](
        width
      )


proc m80ApplyInclusive(
    values:
      var seq[
        seq[int]
      ],
    height,
    width,
    rowA,
    rowB,
    colA,
    colB,
    delta: int
) =
  let rowBegin =
    max(
      rowA,
      0,
    )

  let rowEnd =
    min(
      rowB + 1,
      height,
    )

  let colBegin =
    max(
      colA,
      0,
    )

  let colEnd =
    min(
      colB + 1,
      width,
    )

  if (
    rowBegin >= rowEnd or
    colBegin >= colEnd
  ):
    return

  for row in rowBegin ..< rowEnd:
    for col in colBegin ..< colEnd:
      values[row][col] +=
        delta


proc m80ApplyHalfOpen(
    values:
      var seq[
        seq[int]
      ],
    rowBegin,
    rowEnd,
    colBegin,
    colEnd,
    delta: int
) =
  for row in rowBegin ..< rowEnd:
    for col in colBegin ..< colEnd:
      values[row][col] +=
        delta


proc m80CheckModel(
    tree:
      DualCumulativeSum2D[int],
    values:
      seq[
        seq[int]
      ],
    height,
    width: int
) =
  for row in 0 ..< height:
    for col in 0 ..< width:
      doAssert tree[
        row,
        col
      ] == values[row][col]

      doAssert tree.get(
        row,
        col,
      ) == values[row][col]

  doAssert tree[
    -1,
    0
  ] == 0

  doAssert tree[
    0,
    -1
  ] == 0

  doAssert tree[
    height,
    0
  ] == 0

  doAssert tree[
    0,
    width
  ] == 0

  doAssert tree.get(
    height,
    width,
  ) == 0


block m80ClippingOverlapAndBuildIdempotence:
  const
    height =
      4

    width =
      5

  var tree =
    initDualCumulativeSum2D[int](
      height = height,
      width = width,
    )

  var values =
    m80NewGrid(
      height,
      width,
    )

  tree.add(
    rowBegin = 0,
    rowEnd = height,
    colBegin = 0,
    colEnd = width,
    value = 1,
  )

  m80ApplyHalfOpen(
    values,
    0,
    height,
    0,
    width,
    1,
  )

  tree.add(
    -2 .. 2,
    1 .. 8,
    3,
  )

  m80ApplyInclusive(
    values,
    height,
    width,
    -2,
    2,
    1,
    8,
    3,
  )

  tree.add(
    row = 0,
    col = 4,
    value = 7,
  )

  m80ApplyInclusive(
    values,
    height,
    width,
    0,
    0,
    4,
    4,
    7,
  )

  tree.add(
    -1,
    0,
    100,
  )

  m80ApplyInclusive(
    values,
    height,
    width,
    -1,
    -1,
    0,
    0,
    100,
  )

  tree.add(
    3 .. 10,
    -5 .. 0,
    -4,
  )

  m80ApplyInclusive(
    values,
    height,
    width,
    3,
    10,
    -5,
    0,
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

  m80CheckModel(
    tree,
    values,
    height,
    width,
  )


block m80ZeroShapes:
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

  doAssert zeroHeight[
    0,
    0
  ] == 0

  doAssert zeroHeight[
    -1,
    2
  ] == 0

  doAssert zeroHeight.get(
    0,
    4,
  ) == 0


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
  zeroWidth.build()

  doAssert zeroWidth[
    0,
    0
  ] == 0

  doAssert zeroWidth[
    4,
    -1
  ] == 0

  doAssert zeroWidth.get(
    4,
    0,
  ) == 0


  var zeroZero =
    initDualCumulativeSum2D[int](
      0,
      0,
    )

  zeroZero.build()
  zeroZero.build()

  doAssert zeroZero[
    0,
    0
  ] == 0


block m80GenericType:
  var tree =
    initDualCumulativeSum2D[int64](
      2,
      2,
    )

  tree.add(
    0,
    2,
    0,
    2,
    int64(3),
  )

  tree.add(
    1,
    1,
    int64(-8),
  )

  tree.build()

  doAssert tree[
    0,
    0
  ] == int64(3)

  doAssert tree[
    1,
    1
  ] == int64(-5)


block m80AssertionPolicy:
  var postBuild =
    initDualCumulativeSum2D[int](
      2,
      2,
    )

  postBuild.build()

  var postBuildRejected =
    false

  try:
    postBuild.add(
      0,
      0,
      1,
    )

  except AssertionDefect:
    postBuildRejected =
      true

  doAssert postBuildRejected


  var invalidRange =
    initDualCumulativeSum2D[int](
      2,
      2,
    )

  var invalidRangeRejected =
    false

  try:
    invalidRange.add(
      rowBegin = -1,
      rowEnd = 1,
      colBegin = 0,
      colEnd = 1,
      value = 1,
    )

  except AssertionDefect:
    invalidRangeRejected =
      true

  doAssert invalidRangeRejected


type
  M80TinyRng =
    object
      state:
        uint64


proc m80NextU64(
    rng:
      var M80TinyRng
): uint64 =
  rng.state =
    rng.state *
    6364136223846793005'u64 +
    1442695040888963407'u64

  rng.state


proc m80NextInt(
    rng:
      var M80TinyRng,
    low,
    high: int
): int =
  doAssert low <= high

  low +
    int(
      rng.m80NextU64 mod
      uint64(
        high - low + 1
      )
    )


block m80Randomized:
  var rng =
    M80TinyRng(
      state:
        0x80DCA11C0FFEE123'u64
    )

  for caseIndex in 0 ..< 120:
    let height =
      rng.m80NextInt(
        0,
        8,
      )

    let width =
      rng.m80NextInt(
        0,
        8,
      )

    var tree =
      initDualCumulativeSum2D[int](
        height,
        width,
      )

    var values =
      m80NewGrid(
        height,
        width,
      )

    for operationIndex in 0 ..< 40:
      let mode =
        rng.m80NextInt(
          0,
          2,
        )

      let delta =
        rng.m80NextInt(
          -20,
          20,
        )

      case mode
      of 0:
        let rowA =
          rng.m80NextInt(
            -3,
            height + 2,
          )

        let rowB =
          rng.m80NextInt(
            rowA,
            height + 3,
          )

        let colA =
          rng.m80NextInt(
            -3,
            width + 2,
          )

        let colB =
          rng.m80NextInt(
            colA,
            width + 3,
          )

        tree.add(
          rowA .. rowB,
          colA .. colB,
          delta,
        )

        m80ApplyInclusive(
          values,
          height,
          width,
          rowA,
          rowB,
          colA,
          colB,
          delta,
        )

      of 1:
        let firstRow =
          rng.m80NextInt(
            0,
            height,
          )

        let secondRow =
          rng.m80NextInt(
            0,
            height,
          )

        let firstCol =
          rng.m80NextInt(
            0,
            width,
          )

        let secondCol =
          rng.m80NextInt(
            0,
            width,
          )

        let rowBegin =
          min(
            firstRow,
            secondRow,
          )

        let rowEnd =
          max(
            firstRow,
            secondRow,
          )

        let colBegin =
          min(
            firstCol,
            secondCol,
          )

        let colEnd =
          max(
            firstCol,
            secondCol,
          )

        tree.add(
          rowBegin,
          rowEnd,
          colBegin,
          colEnd,
          delta,
        )

        m80ApplyHalfOpen(
          values,
          rowBegin,
          rowEnd,
          colBegin,
          colEnd,
          delta,
        )

      else:
        let row =
          rng.m80NextInt(
            -2,
            height + 1,
          )

        let col =
          rng.m80NextInt(
            -2,
            width + 1,
          )

        tree.add(
          row,
          col,
          delta,
        )

        m80ApplyInclusive(
          values,
          height,
          width,
          row,
          row,
          col,
          col,
          delta,
        )

    tree.build()
    tree.build()

    m80CheckModel(
      tree,
      values,
      height,
      width,
    )


block m80WriteOrder:
  var tree =
    initDualCumulativeSum2D[int](
      2,
      3,
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

  echo "DUAL_CUMULATIVE_SUM_2D_M80_CONTRACT_EXTENSION_OK"
