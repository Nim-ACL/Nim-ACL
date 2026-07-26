discard """
  cmd: "nim cpp -r $file"
"""

import std/unittest
import atcoder/extra/graph/functional_graph

proc bruteJump(to: seq[int], v: int, k: int): int =
  result = v
  for _ in 0 ..< k:
    result = to[result]

test "Doubling basic":
  let to = @[1, 2, 0, 4, 4]
  let db = initDoubling(to, maxLog = 10)

  check db.jump(0, 0) == 0
  check db.jump(0, 1) == 1
  check db.jump(0, 2) == 2
  check db.jump(0, 3) == 0
  check db.jump(3, 100) == 4

  check db[(0, 5)] == 2
  check db[(3, 7)] == 4

test "FunctionalGraph jump":
  let to = @[1, 2, 3, 1, 5, 5]
  let fg = initFunctionalGraph(to, maxLog = 40)

  check fg.len == 6

  for v in 0 ..< to.len:
    for k in 0 .. 100:
      check fg.jump(v, k) == bruteJump(to, v, k)

  check fg.jump(0, 1_000_000_000_000'u64) == fg.jump(0, 1_000_000_000_000'u64 mod 3'u64 + 0'u64)
  check fg[(4, 100)] == 5

test "FunctionalGraph orbit and cycleInfo":
  let fg = initFunctionalGraph(@[1, 2, 3, 1, 5, 5], maxLog = 20)

  let info0 = fg.cycleInfo(0)
  check info0.tail == 1
  check info0.period == 3

  let orb0 = fg.orbit(0)
  check orb0.prefix == @[0]
  check orb0.cycle == @[1, 2, 3]

  let info4 = fg.cycleInfo(4)
  check info4.tail == 1
  check info4.period == 1

  let orb4 = fg.orbit(4)
  check orb4.prefix == @[4]
  check orb4.cycle == @[5]

test "FunctionalGraph self loops":
  let fg = initFunctionalGraph(@[0, 1, 2], maxLog = 6)

  for v in 0 ..< 3:
    check fg.jump(v, 0) == v
    check fg.jump(v, 100) == v

    let info = fg.cycleInfo(v)
    check info.tail == 0
    check info.period == 1

    let orb = fg.orbit(v)
    check orb.prefix == newSeq[int](0)
    check orb.cycle == @[v]
