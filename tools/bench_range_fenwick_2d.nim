## Compile with -d:release --opt:speed; args: dense|sparse [operation count].
## The same source can be compiled against the baseline via --path.
import std/[os, strutils, times]
import atcoder/extra/structure/dense_range_fenwicktree_2d
import atcoder/extra/structure/sparse_range_fenwicktree_2d

proc next(state: var uint64): int =
  state = state xor (state shl 13)
  state = state xor (state shr 7)
  state = state xor (state shl 17)
  int(state and 0x7FFFFFFF'u64)

proc exercise[Tree](tree: var Tree, size, operations: int): int64 =
  mixin add, sum
  var state = 20261116'u64
  for i in 0 ..< operations:
    let
      a = state.next mod size
      b = state.next mod size
      c = state.next mod size
      d = state.next mod size
      r0 = min(a, b)
      r1 = max(a, b) + 1
      c0 = min(c, d)
      c1 = max(c, d) + 1
    if i mod 2 == 0:
      tree.add(r0, r1, c0, c1, int64(i mod 7 - 3))
    else:
      result = result xor tree.sum(r0, r1, c0, c1)

let operations = if paramCount() >= 2: parseInt(paramStr(2)) else: 100_000
let started = cpuTime()
var checksum: int64
var objectBytes: int
if paramStr(1) == "dense":
  var tree = initDenseRangeFenwickTree2D[int64](512, 512)
  objectBytes = sizeof(tree)
  checksum = tree.exercise(512, operations)
else:
  doAssert paramStr(1) == "sparse"
  var tree = initSparseRangeFenwickTree2D[int64](256, 256)
  objectBytes = sizeof(tree)
  checksum = tree.exercise(256, operations)
echo paramStr(1), " seconds=", cpuTime() - started,
     " checksum=", checksum, " objectBytes=", objectBytes
