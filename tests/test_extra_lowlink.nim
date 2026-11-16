import std/[algorithm, random, unittest]
import atcoder/extra/graph/[graph_template, lowlink, undirected_decomposition]

type Endpoints = tuple[u, v: int]

# Independent oracle: count components after deleting a vertex or one edge.
proc componentCount(n: int, edges: seq[Endpoints],
                    removedVertex = -1, removedEdge = -1): int =
  var seen = newSeq[bool](n)
  for start in 0 ..< n:
    if start == removedVertex or seen[start]: continue
    inc result
    var stack = @[start]
    seen[start] = true
    while stack.len > 0:
      let v = stack.pop()
      for id, e in edges:
        if id == removedEdge or e.u == removedVertex or e.v == removedVertex:
          continue
        let to = if e.u == v: e.v elif e.v == v: e.u else: -1
        if to >= 0 and not seen[to]:
          seen[to] = true
          stack.add to

suite "shared LowLink":
  test "empty, isolated vertices and self-loops":
    for n in 0 .. 3:
      var g = initGraph(n)
      for v in 0 ..< n: g.addBiEdge(v, v)
      let ll = LowLink(g)
      check ll.articulation.len == 0
      check ll.bridge.len == 0

  test "parallel edges and a remaining bridge":
    var g = initGraph(3)
    g.addBiEdge(0, 1)
    g.addBiEdge(0, 1)
    g.addBiEdge(1, 2)
    check LowLink(g) == (@[1], @[(1, 2)])

  test "legacy completion order and manually paired arcs":
    var g = initGraph(5)
    for (u, v) in [(0, 1), (1, 3), (0, 2), (2, 4)]:
      g.addEdge(u, v)
      g.addEdge(v, u)
    let ll = LowLink(g)
    check ll.articulation == @[1, 2, 0]
    check ll.bridge == @[(1, 3), (0, 1), (2, 4), (0, 2)]

  test "random multigraphs match vertex and edge deletion oracle":
    var rng = initRand(20261116)
    for trial in 0 ..< 1000:
      let n = rng.rand(1 .. 9)
      var g = initGraph(n)
      var common = initUndirectedGraph(n)
      var edges: seq[Endpoints]
      var commonIds: seq[int]
      for i in 0 ..< rng.rand(0 .. 25):
        let (u, v) = (rng.rand(n - 1), rng.rand(n - 1))
        edges.add (u, v)
        if u != v:
          commonIds.add common.addEdge(u, v)
        else:
          commonIds.add -1
        # Exercise both graph construction APIs, including rev == -1.
        if trial mod 2 == 0:
          g.addBiEdge(u, v)
        else:
          g.addEdge(u, v)
          g.addEdge(v, u)

      let baseline = componentCount(n, edges)
      var wantArt: seq[int]
      var wantBridges: seq[(int, int)]
      var wantIds: seq[int]
      for v in 0 ..< n:
        if componentCount(n, edges, removedVertex = v) > baseline:
          wantArt.add v
      for id, e in edges:
        if componentCount(n, edges, removedEdge = id) > baseline:
          wantBridges.add (min(e.u, e.v), max(e.u, e.v))
          wantIds.add commonIds[id]

      var ll = LowLink(g)
      ll.articulation.sort()
      ll.bridge.sort()
      wantBridges.sort()
      check ll.articulation == wantArt
      check ll.bridge == wantBridges
      let bcc = common.biconnectedComponents()
      check bcc.articulation == wantArt
      check bcc.bridges == wantIds
      for id in 0 ..< common.edgeCount:
        let component = bcc.componentOfEdge[id]
        doAssert component >= 0
        doAssert id in bcc.edgeComponents[component]

  test "deep path uses the shared explicit stack":
    const n = 200_000
    var g = initGraph(n)
    for v in 1 ..< n: g.addBiEdge(v - 1, v)
    let ll = LowLink(g)
    check ll.articulation.len == n - 2
    check ll.articulation[0] == n - 2
    check ll.articulation[^1] == 1
    check ll.bridge.len == n - 1
    check ll.bridge[0] == (n - 2, n - 1)
    check ll.bridge[^1] == (0, 1)

  test "biconnected components also use the shared explicit stack":
    const n = 100_000
    var g = initUndirectedGraph(n)
    for v in 1 ..< n: discard g.addEdge(v - 1, v)
    let bcc = g.biconnectedComponents()
    check bcc.articulation.len == n - 2
    check bcc.articulation[0] == 1
    check bcc.articulation[^1] == n - 2
    check bcc.bridges.len == n - 1
    check bcc.edgeComponents.len == n - 1
    for id in 0 ..< n - 1:
      doAssert bcc.bridges[id] == id
      doAssert bcc.edgeComponents[bcc.componentOfEdge[id]] == @[id]
