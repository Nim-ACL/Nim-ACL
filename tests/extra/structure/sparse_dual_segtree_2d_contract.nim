import atcoder/extra/monoid/monoid
import atcoder/extra/structure/sparse_dual_segtree_2d

template check(condition: untyped) =
  if not (condition):
    raise newException(
      ValueError,
      "SparseDualSegTree2D temporary candidate contract failure",
    )


func addInt(
    a,
    b: int
): int =
  a + b


func zeroInt(): int =
  0


type
  AddMonoid =
    CommutativeMonoidOf(
      int,
      addInt,
      zeroInt,
    )


proc nextState(
    state:
      var uint64
): uint64 =
  state =
    state xor (
      state shl 13
    )

  state =
    state xor (
      state shr 7
    )

  state =
    state xor (
      state shl 17
    )

  state


proc nextInt(
    state:
      var uint64,
    bound: int
): int =
  check bound > 0

  int(
    state.nextState mod
    uint64(bound)
  )


block negativeDimensions:
  var raised =
    false

  try:
    discard initSparseDualSegTree2D(
      -1,
      3,
      AddMonoid,
    )

  except ValueError:
    raised =
      true

  check raised


block zeroDimensions:
  var zeroZero =
    initSparseDualSegTree2D(
      0,
      0,
      AddMonoid,
    )

  check zeroZero.height == 0
  check zeroZero.width == 0
  check zeroZero.debugOuterNodeCount == 0
  check zeroZero.debugTotalInnerNodeCount == 0

  zeroZero.apply(
    0,
    0,
    0,
    0,
    9,
  )

  check zeroZero.debugOuterNodeCount == 0
  check zeroZero.debugTotalInnerNodeCount == 0

  var zeroHeight =
    initSparseDualSegTree2D(
      0,
      7,
      AddMonoid,
    )

  zeroHeight.apply(
    0,
    0,
    0,
    7,
    5,
  )

  check zeroHeight.debugOuterNodeCount == 0
  check zeroHeight.debugTotalInnerNodeCount == 0

  var zeroWidth =
    initSparseDualSegTree2D(
      5,
      0,
      AddMonoid,
    )

  zeroWidth.apply(
    0,
    5,
    0,
    0,
    5,
  )

  check zeroWidth.debugOuterNodeCount == 0
  check zeroWidth.debugTotalInnerNodeCount == 0


const
  H =
    11

  W =
    13


var naive =
  newSeq[
    seq[
      int
    ]
  ](
    H
  )

for row in 0 ..< H:
  naive[row] =
    newSeq[int](
      W
    )


var tree =
  initSparseDualSegTree2D(
    H,
    W,
    AddMonoid,
  )


check tree.height == H
check tree.width == W
check tree.debugOuterNodeCount == 0
check tree.debugTotalInnerNodeCount == 0


var
  state =
    0x76D2A1175EED1234'u64

  updateTrials =
    0

  getTrials =
    0

  readNoAllocTrials =
    0

  emptyUpdateTrials =
    0


for step in 0 ..< 5000:
  if step mod 2 == 0:
    let ra =
      state.nextInt(
        H + 1
      )

    let rb =
      state.nextInt(
        H + 1
      )

    let ca =
      state.nextInt(
        W + 1
      )

    let cb =
      state.nextInt(
        W + 1
      )

    let rowLeft =
      min(
        ra,
        rb
      )

    let rowRight =
      max(
        ra,
        rb
      )

    let colLeft =
      min(
        ca,
        cb
      )

    let colRight =
      max(
        ca,
        cb
      )

    let delta =
      state.nextInt(
        2001
      ) - 1000

    let beforeOuter =
      tree.debugOuterNodeCount

    let beforeInner =
      tree.debugTotalInnerNodeCount

    tree.apply(
      rowLeft,
      rowRight,
      colLeft,
      colRight,
      delta,
    )

    if (
      rowLeft == rowRight or
      colLeft == colRight
    ):
      check (
        tree.debugOuterNodeCount ==
        beforeOuter
      )

      check (
        tree.debugTotalInnerNodeCount ==
        beforeInner
      )

      inc emptyUpdateTrials

    else:
      check (
        tree.debugOuterNodeCount >=
        beforeOuter
      )

      check (
        tree.debugTotalInnerNodeCount >=
        beforeInner
      )

    for row in rowLeft ..< rowRight:
      for col in colLeft ..< colRight:
        naive[row][col] +=
          delta

    inc updateTrials

  else:
    let row =
      state.nextInt(
        H
      )

    let col =
      state.nextInt(
        W
      )

    let beforeOuter =
      tree.debugOuterNodeCount

    let beforeInner =
      tree.debugTotalInnerNodeCount

    if step mod 4 == 1:
      check tree.get(
        row,
        col,
      ) == naive[row][col]

    else:
      check tree[
        row,
        col
      ] == naive[row][col]

    check (
      tree.debugOuterNodeCount ==
      beforeOuter
    )

    check (
      tree.debugTotalInnerNodeCount ==
      beforeInner
    )

    inc getTrials
    inc readNoAllocTrials


let beforeSweepOuter =
  tree.debugOuterNodeCount

let beforeSweepInner =
  tree.debugTotalInnerNodeCount

var fullSweep =
  0

for row in 0 ..< H:
  for col in 0 ..< W:
    check tree.get(
      row,
      col,
    ) == naive[row][col]

    inc fullSweep

check (
  tree.debugOuterNodeCount ==
  beforeSweepOuter
)

check (
  tree.debugTotalInnerNodeCount ==
  beforeSweepInner
)


block hugeFixedGrid:
  let hugeH =
    high(int)

  let hugeW =
    high(int) - 16

  var huge =
    initSparseDualSegTree2D(
      hugeH,
      hugeW,
      AddMonoid,
    )

  huge.apply(
    0,
    hugeH,
    0,
    hugeW,
    2,
  )

  huge.apply(
    0,
    1,
    0,
    1,
    3,
  )

  huge.apply(
    hugeH - 1,
    hugeH,
    hugeW - 1,
    hugeW,
    5,
  )

  let middleRow =
    hugeH div 2

  let middleCol =
    hugeW div 2

  huge.apply(
    middleRow,
    middleRow + 2,
    middleCol,
    middleCol + 2,
    11,
  )

  let beforeOuter =
    huge.debugOuterNodeCount

  let beforeInner =
    huge.debugTotalInnerNodeCount

  check huge.get(
    0,
    0,
  ) == 5

  check huge[
    hugeH - 1,
    hugeW - 1
  ] == 7

  check huge.get(
    middleRow,
    middleCol,
  ) == 13

  check huge.get(
    middleRow + 1,
    middleCol + 1,
  ) == 13

  check huge.get(
    12345,
    67890,
  ) == 2

  check (
    huge.debugOuterNodeCount ==
    beforeOuter
  )

  check (
    huge.debugTotalInnerNodeCount ==
    beforeInner
  )


type
  Box =
    object
      value:
        int


func combineBox(
    a,
    b: Box
): Box =
  Box(
    value:
      a.value + b.value
  )


func emptyBox(): Box =
  Box(
    value:
      0
  )


type
  BoxMonoid =
    CommutativeMonoidOf(
      Box,
      combineBox,
      emptyBox,
    )


block genericPayload:
  var boxes =
    initSparseDualSegTree2D(
      4,
      5,
      BoxMonoid,
    )

  boxes.apply(
    0,
    4,
    0,
    5,
    Box(value: 3),
  )

  boxes.apply(
    1,
    3,
    2,
    5,
    Box(value: 7),
  )

  check boxes.get(
    1,
    2,
  ).value == 10

  check boxes[
    0,
    0
  ].value == 3


check updateTrials == 2500
check getTrials == 2500
check readNoAllocTrials == 2500
check fullSweep == H * W


echo(
  "SPARSE_DUAL_SEGTREE_2D_CONTRACT_OK",
  " updates=",
  updateTrials,
  " gets=",
  getTrials,
  " readNoAlloc=",
  readNoAllocTrials,
  " fullSweep=",
  fullSweep,
  " emptyUpdates=",
  emptyUpdateTrials,
)
