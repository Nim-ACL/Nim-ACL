discard """
  cmd: "nim cpp -r $file"
"""

import std/unittest
import std/[random, sequtils]

import atcoder/scc
import atcoder/internal_scc

test "SCCTest, Empty":
  var graph0:SCCGraph
  check newSeq[seq[int]]() == graph0.scc()
  var graph1 = initSCCGraph(0)
  check newSeq[seq[int]]() == graph1.scc()

test "SCCTest, Assign":
  var graph:SCCGraph
  graph = initSCCGraph(10)

test "SCCTest, Simple":
  var graph = initSCCGraph(2)
  graph.add_edge(0, 1)
  graph.add_edge(1, 0)
  let scc = graph.scc()
  check 1 == scc.len

test "SCCTest, SelfLoop":
  var graph = initSCCGraph(2)
  graph.add_edge(0, 0)
  graph.add_edge(0, 0)
  graph.add_edge(1, 1)
  let scc = graph.scc()
  check 2 == scc.len

test "SCCTest, Invalid":
  for (src, dst) in [(-1, 0), (2, 0), (0, -1), (0, 2)]:
    var graph = initSCCGraph(2)
    var internal = init_internal_scc_graph(2)
    expect AssertionDefect:
      graph.add_edge(src, dst)
    expect AssertionDefect:
      internal.add_edge(src, dst)
    # Rejected edges must not mutate either graph.
    check graph.scc() == @[@[1], @[0]]
    check internal.scc() == graph.scc()
  expect AssertionDefect:
    discard init_internal_scc_graph(-1)
  expect AssertionDefect:
    discard initSCCGraph(-1)
  var empty = init_internal_scc_graph(0)
  expect AssertionDefect:
    empty.add_edge(0, 0)

test "SCCTest, Random reachability and topological ids":
  var rng = initRand(20261116)
  for trial in 0 ..< 1000:
    let n = rng.rand(0 .. 10)
    var graph = initSCCGraph(n)
    var internal = init_internal_scc_graph(n)
    var reachable = newSeqWith(n, newSeq[bool](n))
    var edges: seq[(int, int)]
    for v in 0 ..< n: reachable[v][v] = true
    if n > 0:
      for i in 0 ..< rng.rand(0 .. 40):
        let (u, v) = (rng.rand(n - 1), rng.rand(n - 1))
        edges.add (u, v)
        graph.add_edge(u, v)
        internal.add_edge(u, v)
        reachable[u][v] = true
    for k in 0 ..< n:
      for u in 0 ..< n:
        for v in 0 ..< n:
          reachable[u][v] = reachable[u][v] or
            (reachable[u][k] and reachable[k][v])

    let (count, ids) = internal.scc_ids()
    let groups = graph.scc()
    check groups.len == count
    check internal.scc() == groups
    check graph.scc() == groups # Repeated calls must not retain DFS state.
    var seen = newSeq[bool](n)
    for id, group in groups:
      doAssert group.len > 0
      for v in group:
        doAssert not seen[v]
        seen[v] = true
        doAssert ids[v] == id
    for u in 0 ..< n:
      doAssert seen[u]
      for v in 0 ..< n:
        doAssert (ids[u] == ids[v]) == (reachable[u][v] and reachable[v][u])
    for (u, v) in edges:
      doAssert ids[u] <= ids[v]
