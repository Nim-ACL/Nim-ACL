type
  SparseIntervalNode*[P] = object
    left: int
    right: int
    payload: P

  SparseIntervalArena*[P] = object
    n: int
    root: int
    nodes: seq[SparseIntervalNode[P]]

proc initSparseIntervalArena*[P](n: int): SparseIntervalArena[P] =
  if n < 0:
    raise newException(ValueError, "sparse interval arena size must be nonnegative")
  result.n = n
  result.root = -1
  result.nodes = @[]

proc domainSize*[P](self: SparseIntervalArena[P]): int {.inline.} =
  self.n

proc rootIndex*[P](self: SparseIntervalArena[P]): int {.inline.} =
  self.root

proc nodeCount*[P](self: SparseIntervalArena[P]): int {.inline.} =
  self.nodes.len

proc hasRoot*[P](self: SparseIntervalArena[P]): bool {.inline.} =
  self.root != -1

func sparseIntervalMidpoint*(lo, hi: int): int {.inline.} =
  lo + ((hi - lo) shr 1)

proc newNode[P](
    self: var SparseIntervalArena[P],
    payload: P
): int {.inline.} =
  result = self.nodes.len
  self.nodes.add SparseIntervalNode[P](
    left: -1,
    right: -1,
    payload: payload
  )

proc readLeftChild*[P](
    self: SparseIntervalArena[P],
    node: int
): int {.inline.} =
  self.nodes[node].left

proc readRightChild*[P](
    self: SparseIntervalArena[P],
    node: int
): int {.inline.} =
  self.nodes[node].right

proc readPayload*[P](
    self: SparseIntervalArena[P],
    node: int
): P {.inline.} =
  self.nodes[node].payload

proc setPayload*[P](
    self: var SparseIntervalArena[P],
    node: int,
    payload: P
) {.inline.} =
  self.nodes[node].payload = payload

proc ensureRoot*[P](
    self: var SparseIntervalArena[P],
    payload: P
): int {.inline.} =
  if self.n == 0:
    raise newException(ValueError, "zero-sized sparse interval arena has no writable root")
  if self.root == -1:
    self.root = self.newNode(payload)
  self.root

proc ensureLeftChild*[P](
    self: var SparseIntervalArena[P],
    node: int,
    payload: P
): int {.inline.} =
  if self.nodes[node].left == -1:
    let child = self.newNode(payload)
    self.nodes[node].left = child
  self.nodes[node].left

proc ensureRightChild*[P](
    self: var SparseIntervalArena[P],
    node: int,
    payload: P
): int {.inline.} =
  if self.nodes[node].right == -1:
    let child = self.newNode(payload)
    self.nodes[node].right = child
  self.nodes[node].right
