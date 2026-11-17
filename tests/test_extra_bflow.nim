import std/[unittest, random]

import atcoder/extra/graph/bflow
import atcoder/extra/graph/mcf_costscaling
import atcoder/extra/numeric/int128

type TinyEdge = tuple[src, dst, lower, upper, cost: int]

proc enumerateFlows(n: int, edges: seq[TinyEdge], supply: seq[int]): tuple[feasible: bool, cost: int] =
  var balances = newSeq[int](n)
  var found = false
  var best = high(int)
  proc visit(index, cost: int) =
    if index == edges.len:
      if balances == supply:
        found = true
        best = min(best, cost)
      return
    let e = edges[index]
    for amount in e.lower .. e.upper:
      balances[e.src] += amount
      balances[e.dst] -= amount
      visit(index + 1, cost + amount * e.cost)
      balances[e.src] -= amount
      balances[e.dst] += amount
  visit(0, 0)
  (found, best)

proc checkModel[Cost](n: int, edges: seq[TinyEdge], supply: seq[int], expected: tuple[feasible: bool, cost: int]) =
  var graph = initBFlow[int, Cost](n)
  for v in 0 ..< n:
    graph.add_supply(v, supply[v])
  for e in edges:
    graph.add_edge(e.src, e.dst, e.lower, e.upper, Cost(e.cost))
  let answer = graph.solve()
  doAssert answer[0] == expected.feasible
  if not answer[0]: return
  doAssert answer[1] == Cost(expected.cost)
  doAssert graph.f.len == edges.len
  var balances = newSeq[int](n)
  var actualCost = 0
  for i, e in edges:
    let amount = graph.f[i]
    doAssert e.lower <= amount and amount <= e.upper
    balances[e.src] += amount
    balances[e.dst] -= amount
    actualCost += amount * e.cost
    let reduced = Cost(e.cost) + graph.potential[e.src] - graph.potential[e.dst]
    if amount < e.upper: doAssert reduced >= Cost(0)
    if amount > e.lower: doAssert reduced <= Cost(0)
  doAssert balances == supply
  doAssert actualCost == expected.cost

proc checkZeroCostScaling[Cost; Scaling: static[int]]() =
  var graph = initMCFCostScaling[int, Cost, Scaling](2)
  graph.addSupply(0, 2)
  graph.addDemand(1, 2)
  discard graph.addEdge(0, 1, 3, Cost(0))
  doAssert graph.solve() == Cost(0)
  doAssert graph.getEdge(0).flow == 2


suite "minimum-cost B-flow":
  test "zero costs route nonzero balances":
    let edges: seq[TinyEdge] = @[(0, 1, 0, 3, 0)]
    let expected = enumerateFlows(2, edges, @[2, -2])
    checkModel[int](2, edges, @[2, -2], expected)
    checkModel[Int128](2, edges, @[2, -2], expected)
    checkZeroCostScaling[int, 1]()
    checkZeroCostScaling[int, 2]()
    checkZeroCostScaling[int64, 63]()
    checkZeroCostScaling[Int128, 1]()
    checkZeroCostScaling[Int128, 3]()
    checkZeroCostScaling[Int128, 127]()

  test "Int128 costs preserve empty and signed-cost results":
    checkModel[Int128](1, @[], @[0], (true, 0))
    checkModel[Int128](0, @[], @[], (true, 0))
    for cost in [-3, 0, 3]:
      let edges: seq[TinyEdge] = @[(0, 1, 0, 3, cost)]
      checkModel[Int128](2, edges, @[2, -2], enumerateFlows(2, edges, @[2, -2]))

  test "bounded flows match exhaustive integer oracle":
    var rng = initRand(0xB10F2)
    for iteration in 0 ..< 120:
      let n = rng.rand(1 .. 4)
      var edges: seq[TinyEdge]
      var supply = newSeq[int](n)
      for _ in 0 ..< rng.rand(0 .. 5):
        let s = rng.rand(n - 1)
        let t = rng.rand(n - 1)
        let lower = rng.rand(-2 .. 2)
        let upper = lower + rng.rand(0 .. 3)
        let amount = rng.rand(lower .. upper)
        edges.add((s, t, lower, upper, rng.rand(-4 .. 4)))
        supply[s] += amount
        supply[t] -= amount
      if iteration mod 2 == 0:
        for v in 0 ..< n: supply[v] = rng.rand(-3 .. 3)
      let expected = enumerateFlows(n, edges, supply)
      checkModel[int](n, edges, supply, expected)
      checkModel[Int128](n, edges, supply, expected)

  test "lower bound, cost, flow order, and potentials":
    var flow =
      initBFlow[int, int](2)

    flow.add_supply(
      0,
      2,
    )

    flow.add_demand(
      1,
      2,
    )

    flow.add_edge(
      0,
      1,
      2,
      5,
      3,
    )

    let answer =
      flow.solve()

    check answer ==
      (true, 6)

    check flow.f ==
      @[2]

    check flow.potential.len ==
      2

    check not flow.infeasible

  test "parallel edges use input-edge order":
    var flow =
      initBFlow[int, int](2)

    flow.add_supply(
      0,
      3,
    )

    flow.add_demand(
      1,
      3,
    )

    flow.add_edge(
      0,
      1,
      0,
      3,
      1,
    )

    flow.add_edge(
      0,
      1,
      0,
      3,
      5,
    )

    let answer =
      flow.solve()

    check answer ==
      (true, 3)

    check flow.f ==
      @[3, 0]

  test "negative edge costs":
    var flow =
      initBFlow[int, int](2)

    flow.add_supply(
      0,
      2,
    )

    flow.add_demand(
      1,
      2,
    )

    flow.add_edge(
      0,
      1,
      0,
      2,
      -1,
    )

    flow.add_edge(
      0,
      1,
      0,
      2,
      4,
    )

    let answer =
      flow.solve()

    check answer ==
      (true, -2)

    check flow.f ==
      @[2, 0]

  test "capacity shortage is reported by solve":
    var flow =
      initBFlow[int, int](2)

    flow.add_supply(
      0,
      2,
    )

    flow.add_demand(
      1,
      2,
    )

    flow.add_edge(
      0,
      1,
      0,
      1,
      7,
    )

    let answer =
      flow.solve()

    check not answer[0]

    # This public field only records an immediately invalid
    # lower/upper-bound pair.
    check not flow.infeasible

  test "unbalanced total supply and demand":
    var flow =
      initBFlow[int, int](2)

    flow.add_supply(
      0,
      2,
    )

    flow.add_demand(
      1,
      1,
    )

    flow.add_edge(
      0,
      1,
      0,
      5,
      1,
    )

    let answer =
      flow.solve()

    check not answer[0]
    check not flow.infeasible

  test "invalid lower and upper bounds":
    var flow =
      initBFlow[int, int](2)

    flow.add_edge(
      0,
      1,
      3,
      2,
      5,
    )

    check flow.infeasible

    let answer =
      flow.solve()

    check not answer[0]
