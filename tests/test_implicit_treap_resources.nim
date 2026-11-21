import std/[algorithm, random, tables, unittest]
import atcoder/extra/structure/implicit_treap

# A native allocation oracle, independent of Nim's GC and of the tree's pool.
# The ledger contains raw pointers only, so it cannot keep a Nim object alive.
var live = initTable[pointer, int]()
var allocations, releases: int
type Owner = object
  data: ptr int

proc `=destroy`(x: var Owner) =
  if x.data != nil:
    doAssert live.hasKey(cast[pointer](x.data)), "double release"
    live.del(cast[pointer](x.data))
    dealloc(x.data)
    inc releases
    x.data = nil

proc acquire(value: int): Owner =
  result.data = cast[ptr int](alloc(sizeof(int)))
  result.data[] = value
  live[cast[pointer](result.data)] = value
  inc allocations

proc `=copy`(dest: var Owner, source: Owner) =
  if dest.data == source.data: return
  var replacement: ptr int
  if source.data != nil:
    doAssert live.hasKey(cast[pointer](source.data)), "read after release"
    replacement = cast[ptr int](alloc(sizeof(int)))
    replacement[] = source.data[]
    live[cast[pointer](replacement)] = source.data[]
    inc allocations
  `=destroy`(dest)
  dest.data = replacement

type
  Value = tuple[sum, len: int, owner: Owner]
proc op(x, y: Value): Value =
  if x.len == 0: return y
  if y.len == 0: return x
  (x.sum + y.sum, x.len + y.len, default(Owner))
proc e(): Value = (0, 0, default(Owner))

type Plain = ImplicitTreapType[Value](op, e)
proc value(x: int): Value = (x, 1, acquire(x))

proc checkReleased() =
  for round in 0..<8: GC_fullCollect()
  doAssert live.len == 0, "native allocations still alive: " & $live.len
  doAssert allocations == releases

proc minimalInit() =
  var t = Plain.init()
  t.insert(0, value(7))
  t.init()
  doAssert t.len == 0

proc copiesAndMoves() =
  var a = Plain.init(@[value(1), value(2)])
  var b = Plain.init(@[value(3)])
  a = b
  a.set(0, value(9))
  doAssert a.get(0).sum == 9 and b.get(0).sum == 3
  a = a
  b = b
  a = move(b)
  doAssert a.get(0).sum == 3
  b.init()
  b.insert(0, value(12))
  swap(a, b)
  doAssert a.get(0).sum == 12 and b.get(0).sum == 3
  reset(a)
  a.init()
  a = Plain.init()
  b.init(@[value(1), value(2)])
  doAssert b.allProd().sum == 3

proc growthAndDestruction() =
  var trees: seq[Plain]
  for i in 0..<128:
    var t = Plain.init()
    for j in 0..<8: t.insert(j, value(i + j))
    trees.add(move(t))
    if i mod 8 == 0: GC_fullCollect()
  for i in 0..<trees.len:
    doAssert trees[i].allProd().sum == 8 * i + 28
    if i mod 2 == 0: trees[i].init()
  var large = Plain.init()
  for i in 0..<2048: large.insert(i, value(i))
  for i in 0..<2048: doAssert large.erase(0).sum == i
  # The RC retains erased slots until reuse or pool destruction.
  large.init()

proc sequenceResults() =
  var t = Plain.init(@[value(1), value(2), value(3)])
  let snapshot = t.toSeq()
  t.set(0, value(9))
  t.init()
  doAssert snapshot.len == 3
  for i, x in snapshot:
    doAssert x.sum == i + 1
    doAssert x.owner.data != nil
    doAssert live.hasKey(cast[pointer](x.owner.data))
    doAssert x.owner.data[] == i + 1

proc randomOracle(seed: int) =
  var rng = initRand(seed)
  var t = Plain.init()
  var expected: seq[int]
  for step in 0..<600:
    let kind = rng.rand(0..8)
    if expected.len == 0 or kind == 0:
      let k = rng.rand(0..expected.len)
      let x = rng.rand(-20..20)
      t.insert(k, value(x)); expected.insert(x, k)
    elif kind == 1:
      let k = rng.rand(0..<expected.len)
      doAssert t.erase(k).sum == expected[k]
      expected.delete(k)
    elif kind == 2:
      let k = rng.rand(0..<expected.len)
      let x = rng.rand(-20..20)
      t.set(k, value(x)); expected[k] = x
    elif kind in [3, 4]:
      let l = rng.rand(0..expected.len)
      let r = rng.rand(l..expected.len)
      if kind == 3:
        t.reverse(l, r)
        if l < r: expected.reverse(l, r - 1)
      else:
        var total = 0
        for i in l..<r: total += expected[i]
        doAssert t.prod(l, r).sum == total
    elif kind == 5:
      var copy = t
      copy.set(0, value(99))
      doAssert t.get(0).sum == expected[0]
      copy = t
      doAssert copy.allProd().sum == t.allProd().sum
    elif kind == 6:
      t.init(); expected.setLen(0)
    elif kind == 7:
      t = t
    else:
      t = Plain.init(); expected.setLen(0)
    doAssert t.len == expected.len
    var total = 0
    for i, x in expected:
      total += x
      doAssert t.get(i).sum == x
    doAssert t.allProd().sum == total

suite "implicit treap native resource lifetime":
  test "one element reinitialization releases old node payloads":
    minimalInit(); checkReleased()
  test "copy move self assignment reset swap and init values":
    copiesAndMoves(); checkReleased()
  test "pool growth erase retained slots and pool destruction":
    growthAndDestruction(); checkReleased()
  test "returned sequence keeps independent owners after pool destruction":
    sequenceResults(); checkReleased()
  test "native owners against an independent integer seq oracle":
    for seed in 0..<8:
      randomOracle(0x3817 + seed)
      checkReleased()
