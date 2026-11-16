import std/[random, sequtils]
import atcoder/extra/algorithm/mo
import atcoder/extra/structure/mo

proc checkQueries[M](mo: M, left, right: seq[int]) =
  var current: seq[int] = @[]
  var visits = newSeq[int](left.len)
  proc addLeft(index: int) = current.insert(index, 0)
  proc addRight(index: int) = current.add(index)
  proc removeLeft(index: int) =
    doAssert current.len > 0 and current[0] == index
    current.delete(0)
  proc removeRight(index: int) =
    doAssert current.len > 0 and current[^1] == index
    discard current.pop()
  proc save(id: int) =
    doAssert current == toSeq(left[id] ..< right[id])
    visits[id].inc
  mo.run(addLeft, addRight, removeLeft, removeRight, save)
  doAssert visits == newSeqWith(left.len, 1)

var rng = initRand(208)
for sample in 0 ..< 100:
  let n = rand(rng, 0 .. 35)
  let q = rand(rng, 0 .. 50)
  var left, right: seq[int] = @[]
  var modern = initMo(n, blockSize = 3)
  var legacy = initMo(N = n, Q = q)
  for id in 0 ..< q:
    let l = rand(rng, 0 .. n)
    let r = rand(rng, l .. n)
    left.add(l)
    right.add(r)
    doAssert modern.addQuery(l, r) == id
    legacy.insert(l, r)
  let batch = initMo(N = n, l = left, r = right)
  # Re-running must not mutate query registration or IDs.
  for repeat in 0 .. 1:
    checkQueries(modern, left, right)
    checkQueries(legacy, left, right)
    checkQueries(batch, left, right)

block:
  let old = initMo(N = 10, l = @[0, 0, 0, 0], r = @[2, 8, 4, 6])
  var order: seq[int] = @[]
  proc ignore(index: int) = discard
  proc save(id: int) = order.add(id)
  old.run(ignore, ignore, ignore, ignore, save)
  doAssert order == @[1, 3, 2, 0]

block:
  let old = initMo(N = 10, Q = 1)
  proc ignore(index: int) = discard
  var rejected = false
  try:
    old.run(ignore, ignore, ignore, ignore, ignore)
  except AssertionDefect:
    rejected = true
  doAssert rejected

echo "Mo legacy/canonical compatibility OK"

block:
  # Both historical sets of named callback parameters remain accepted.
  var modern = initMo(3)
  discard modern.addQuery(0, 3)
  let legacy = initMo(N = 3, l = @[0], r = @[3])
  var sum = 0
  proc add(index: int) = sum += index + 1
  proc remove(index: int) = sum -= index + 1
  proc save(id: int) = doAssert id == 0 and sum == 6
  run(mo = modern, addLeft = add, addRight = add,
    removeLeft = remove, removeRight = remove, answer = save)
  sum = 0
  run(self = legacy, add_left = add, add_right = add,
    delete_left = remove, delete_right = remove, rem = save)

block:
  # Width is 5: even blocks descend, odd blocks ascend.
  let old = initMo(N = 10, l = @[0, 0, 0, 5, 5, 5], r = @[1, 3, 2, 8, 10, 9])
  var order: seq[int] = @[]
  proc ignore(index: int) = discard
  proc save(id: int) = order.add(id)
  old.run(ignore, ignore, ignore, ignore, save)
  doAssert order == @[1, 2, 0, 3, 5, 4]
