import atcoder/extra/structure/internal/sparse_segment_tree_core

type
  Payload = object
    stamp: int
    writes: int

template check(condition: untyped) =
  if not (condition):
    raise newException(ValueError, "sparse segment tree core contract check failed")

proc nextRand(state: var uint64): uint64 =
  state = state xor (state shl 13)
  state = state xor (state shr 7)
  state = state xor (state shl 17)
  state

proc randomPoint(state: var uint64, n: int): int =
  check n > 0
  int(nextRand(state) mod uint64(n))

proc randomBoundary(state: var uint64, n: int): int =
  check n >= 0
  int(nextRand(state) mod (uint64(n) + 1'u64))

proc materializePoint(
    arena: var SparseIntervalArena[Payload],
    point: int,
    stamp: int
): int =
  check 0 <= point
  check point < arena.domainSize()

  var node = arena.ensureRoot(
    Payload(stamp: stamp, writes: 0)
  )

  var lo = 0
  var hi = arena.domainSize()

  while hi - lo > 1:
    let mid = sparseIntervalMidpoint(lo, hi)

    if point < mid:
      let child = arena.readLeftChild(node)
      if child == -1:
        node = arena.ensureLeftChild(
          node,
          Payload(stamp: stamp, writes: 0)
        )
      else:
        node = child
      hi = mid
    else:
      let child = arena.readRightChild(node)
      if child == -1:
        node = arena.ensureRightChild(
          node,
          Payload(stamp: stamp, writes: 0)
        )
      else:
        node = child
      lo = mid

  let oldPayload = arena.readPayload(node)

  arena.setPayload(
    node,
    Payload(
      stamp: oldPayload.stamp,
      writes: oldPayload.writes + 1
    )
  )

  node

proc readPointPath(
    arena: SparseIntervalArena[Payload],
    point: int
): int =
  check 0 <= point
  check point < arena.domainSize()

  var node = arena.rootIndex()

  if node == -1:
    return -1

  var lo = 0
  var hi = arena.domainSize()

  while hi - lo > 1:
    let mid = sparseIntervalMidpoint(lo, hi)

    var child: int

    if point < mid:
      child = arena.readLeftChild(node)
      hi = mid
    else:
      child = arena.readRightChild(node)
      lo = mid

    if child == -1:
      return -1

    node = child

  node

proc canonicalCover(
    n, ql, qr: int
): seq[(int, int)] =
  check 0 <= ql
  check ql <= qr
  check qr <= n

  if n == 0:
    return @[]

  var stack = @[(0, n)]

  while stack.len > 0:
    let current = stack.pop()
    let lo = current[0]
    let hi = current[1]

    if qr <= lo or hi <= ql:
      continue

    if ql <= lo and hi <= qr:
      result.add((lo, hi))
      continue

    if hi - lo <= 1:
      continue

    let mid = sparseIntervalMidpoint(lo, hi)

    stack.add((mid, hi))
    stack.add((lo, mid))

block negativeSize:
  var raised = false

  try:
    discard initSparseIntervalArena[Payload](-1)
  except ValueError:
    raised = true

  check raised

block zeroSize:
  var arena = initSparseIntervalArena[Payload](0)

  check arena.domainSize() == 0
  check arena.rootIndex() == -1
  check arena.nodeCount() == 0
  check not arena.hasRoot()

  var raised = false

  try:
    discard arena.ensureRoot(
      Payload(stamp: 1, writes: 0)
    )
  except ValueError:
    raised = true

  check raised
  check arena.rootIndex() == -1
  check arena.nodeCount() == 0

block midpoint:
  check sparseIntervalMidpoint(0, 1) == 0
  check sparseIntervalMidpoint(0, 2) == 1
  check sparseIntervalMidpoint(1, 3) == 2

  check sparseIntervalMidpoint(
    0,
    high(int)
  ) == high(int) shr 1

  check sparseIntervalMidpoint(
    high(int) - 1,
    high(int)
  ) == high(int) - 1

block primitiveMaterialization:
  var arena = initSparseIntervalArena[Payload](8)

  let root0 = arena.ensureRoot(
    Payload(stamp: 11, writes: 0)
  )

  check root0 == 0
  check arena.nodeCount() == 1
  check arena.hasRoot()
  check arena.rootIndex() == root0
  check arena.readPayload(root0).stamp == 11

  let root1 = arena.ensureRoot(
    Payload(stamp: 99, writes: 0)
  )

  check root1 == root0
  check arena.nodeCount() == 1
  check arena.readPayload(root0).stamp == 11

  let left0 = arena.ensureLeftChild(
    root0,
    Payload(stamp: 21, writes: 0)
  )

  check left0 == 1
  check arena.nodeCount() == 2
  check arena.readLeftChild(root0) == left0
  check arena.readRightChild(root0) == -1

  let left1 = arena.ensureLeftChild(
    root0,
    Payload(stamp: 88, writes: 0)
  )

  check left1 == left0
  check arena.nodeCount() == 2
  check arena.readPayload(left0).stamp == 21

  let right0 = arena.ensureRightChild(
    root0,
    Payload(stamp: 31, writes: 0)
  )

  check right0 == 2
  check arena.nodeCount() == 3

  arena.setPayload(
    right0,
    Payload(stamp: 32, writes: 7)
  )

  check arena.readPayload(right0).stamp == 32
  check arena.readPayload(right0).writes == 7

var state = 0x8b8b8b8b12345678'u64

let sizes = @[
  1,
  2,
  3,
  7,
  8,
  9,
  31,
  32,
  33,
  1_000_003,
  (1 shl 40) + 123,
  high(int)
]

var writeTrials = 0
var readTrials = 0
var coverTrials = 0

for n in sizes:
  var arena = initSparseIntervalArena[Payload](n)

  for trial in 0 ..< 64:
    var point: int

    case trial
    of 0:
      point = 0
    of 1:
      point = n - 1
    of 2:
      point = n div 2
    else:
      point = randomPoint(state, n)

    let before = arena.nodeCount()

    let leaf = arena.materializePoint(
      point,
      writeTrials + 1
    )

    let after = arena.nodeCount()

    check 0 <= leaf
    check leaf < after
    check after >= before

    inc writeTrials

  let count = arena.nodeCount()

  check arena.rootIndex() == 0
  check count > 0

  for node in 0 ..< count:
    let left = arena.readLeftChild(node)
    let right = arena.readRightChild(node)

    check (
      left == -1 or
      (node < left and left < count)
    )

    check (
      right == -1 or
      (node < right and right < count)
    )

  for _ in 0 ..< 500:
    let point = randomPoint(state, n)

    let before = arena.nodeCount()

    discard arena.readPointPath(point)

    let after = arena.nodeCount()

    check after == before

    inc readTrials

  for _ in 0 ..< 1000:
    let a = randomBoundary(state, n)
    let b = randomBoundary(state, n)

    let l = min(a, b)
    let r = max(a, b)

    let cover = canonicalCover(
      n,
      l,
      r
    )

    var cursor = l
    var total = 0

    for interval in cover:
      let lo = interval[0]
      let hi = interval[1]

      check l <= lo
      check lo < hi
      check hi <= r
      check lo == cursor

      total += hi - lo
      cursor = hi

    check total == r - l

    if l == r:
      check cover.len == 0
    else:
      check cursor == r

    inc coverTrials

check writeTrials == 768
check readTrials == 6000
check coverTrials == 12000

echo(
  "SPARSE_SEGMENT_TREE_CORE_CONTRACT_OK",
  " writes=", writeTrials,
  " reads=", readTrials,
  " covers=", coverTrials
)
