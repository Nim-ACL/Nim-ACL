import atcoder/extra/monoid/monoid
import atcoder/extra/structure/sparse_segtree_2d

template check(condition: untyped) =
  if not (condition):
    raise newException(
      ValueError,
      "SparseSegTree2D contract failure",
    )

func m70r1Add(
    a,
    b: int
): int =
  a + b

func m70r1Zero(): int =
  0

type
  M70R1AdditiveMonoid =
    CommutativeMonoidOf(
      int,
      m70r1Add,
      m70r1Zero,
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
    state.nextState mod uint64(bound)
  )


block dimensions:
  var raised =
    false

  try:
    discard initSparseSegTree2D(
      -1,
      3,
      M70R1AdditiveMonoid,
    )

  except ValueError:
    raised =
      true

  check raised


block zeroDimensions:
  let zeroZero =
    initSparseSegTree2D(
      0,
      0,
      M70R1AdditiveMonoid,
    )

  check zeroZero.height == 0
  check zeroZero.width == 0
  check zeroZero.prod(
    0,
    0,
    0,
    0,
  ) == 0
  check zeroZero.allProd == 0
  check zeroZero.debugOuterNodeCount == 0
  check zeroZero.debugTotalInnerNodeCount == 0

  let zeroHeight =
    initSparseSegTree2D(
      0,
      7,
      M70R1AdditiveMonoid,
    )

  check zeroHeight.prod(
    0,
    0,
    0,
    7,
  ) == 0

  check zeroHeight.debugOuterNodeCount == 0

  let zeroWidth =
    initSparseSegTree2D(
      5,
      0,
      M70R1AdditiveMonoid,
    )

  check zeroWidth.prod(
    0,
    5,
    0,
    0,
  ) == 0

  check zeroWidth.debugOuterNodeCount == 0


const
  SmallH =
    7

  SmallW =
    9


var naive =
  newSeq[
    seq[
      int
    ]
  ](
    SmallH
  )

for row in 0 ..< SmallH:
  naive[row] =
    newSeq[int](
      SmallW
    )


var tree =
  initSparseSegTree2D(
    SmallH,
    SmallW,
    M70R1AdditiveMonoid,
  )


check tree.height == SmallH
check tree.width == SmallW
check tree.debugOuterNodeCount == 0
check tree.debugTotalInnerNodeCount == 0


var
  state =
    0x70A11CE5D2D12345'u64

  setTrials =
    0

  prodTrials =
    0

  getTrials =
    0

  readNoAllocTrials =
    0


for step in 0 ..< 3000:
  if step mod 3 == 0:
    let row =
      state.nextInt(
        SmallH
      )

    let col =
      state.nextInt(
        SmallW
      )

    let value =
      state.nextInt(
        2001
      ) - 1000

    let beforeOuter =
      tree.debugOuterNodeCount

    let beforeInner =
      tree.debugTotalInnerNodeCount

    if step mod 2 == 0:
      tree.set(
        row,
        col,
        value,
      )
    else:
      tree[
        row,
        col
      ] =
        value

    naive[row][col] =
      value

    check (
      tree.debugOuterNodeCount >=
      beforeOuter
    )

    check (
      tree.debugTotalInnerNodeCount >=
      beforeInner
    )

    inc setTrials

  else:
    let a =
      state.nextInt(
        SmallH + 1
      )

    let b =
      state.nextInt(
        SmallH + 1
      )

    let c =
      state.nextInt(
        SmallW + 1
      )

    let d =
      state.nextInt(
        SmallW + 1
      )

    let rowLeft =
      min(
        a,
        b
      )

    let rowRight =
      max(
        a,
        b
      )

    let colLeft =
      min(
        c,
        d
      )

    let colRight =
      max(
        c,
        d
      )

    var expected =
      0

    for row in rowLeft ..< rowRight:
      for col in colLeft ..< colRight:
        expected +=
          naive[row][col]

    let beforeOuter =
      tree.debugOuterNodeCount

    let beforeInner =
      tree.debugTotalInnerNodeCount

    check tree.prod(
      rowLeft,
      rowRight,
      colLeft,
      colRight,
    ) == expected

    check (
      tree.debugOuterNodeCount ==
      beforeOuter
    )

    check (
      tree.debugTotalInnerNodeCount ==
      beforeInner
    )

    inc prodTrials
    inc readNoAllocTrials

  if step mod 11 == 0:
    let row =
      state.nextInt(
        SmallH
      )

    let col =
      state.nextInt(
        SmallW
      )

    let beforeOuter =
      tree.debugOuterNodeCount

    let beforeInner =
      tree.debugTotalInnerNodeCount

    check tree.get(
      row,
      col,
    ) == naive[row][col]

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


var fullExpected =
  0

for row in 0 ..< SmallH:
  for col in 0 ..< SmallW:
    fullExpected +=
      naive[row][col]

let beforeAllOuter =
  tree.debugOuterNodeCount

let beforeAllInner =
  tree.debugTotalInnerNodeCount

check tree.allProd == fullExpected

check (
  tree.debugOuterNodeCount ==
  beforeAllOuter
)

check (
  tree.debugTotalInnerNodeCount ==
  beforeAllInner
)

inc readNoAllocTrials


block hugeGrid:
  let hugeH =
    (1 shl 40) + 123

  let hugeW =
    (1 shl 39) + 77

  var huge =
    initSparseSegTree2D(
      hugeH,
      hugeW,
      M70R1AdditiveMonoid,
    )

  huge[
    0,
    0
  ] =
    5

  huge[
    hugeH - 1,
    hugeW - 1
  ] =
    7

  huge.set(
    hugeH div 2,
    hugeW div 2,
    -3,
  )

  huge.set(
    hugeH div 2,
    hugeW div 2,
    11,
  )

  check huge.get(
    0,
    0,
  ) == 5

  check huge[
    hugeH - 1,
    hugeW - 1
  ] == 7

  check huge.get(
    hugeH div 2,
    hugeW div 2,
  ) == 11

  check huge.get(
    12345,
    67890,
  ) == 0

  let beforeOuter =
    huge.debugOuterNodeCount

  let beforeInner =
    huge.debugTotalInnerNodeCount

  check huge.allProd == 23

  check huge.prod(
    0,
    1,
    0,
    1,
  ) == 5

  check huge.prod(
    hugeH - 1,
    hugeH,
    hugeW - 1,
    hugeW,
  ) == 7

  check huge.prod(
    hugeH div 2,
    hugeH div 2 + 1,
    hugeW div 2,
    hugeW div 2 + 1,
  ) == 11

  check huge.prod(
    1,
    hugeH - 1,
    1,
    hugeW - 1,
  ) == 11

  check (
    huge.debugOuterNodeCount ==
    beforeOuter
  )

  check (
    huge.debugTotalInnerNodeCount ==
    beforeInner
  )

  readNoAllocTrials +=
    9


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
  var boxTree =
    initSparseSegTree2D(
      4,
      5,
      BoxMonoid,
    )

  boxTree.set(
    1,
    2,
    Box(value: 4),
  )

  boxTree.set(
    3,
    4,
    Box(value: 9),
  )

  check boxTree.allProd.value == 13

  check boxTree.prod(
    1,
    4,
    2,
    5,
  ).value == 13


check setTrials == 1000
check prodTrials == 2000
check getTrials == 273
check readNoAllocTrials == 2283


echo(
  "SPARSE_SEGTREE_2D_CONTRACT_OK",
  " sets=",
  setTrials,
  " prods=",
  prodTrials,
  " gets=",
  getTrials,
  " readNoAlloc=",
  readNoAllocTrials,
)
