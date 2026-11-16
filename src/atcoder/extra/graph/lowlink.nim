when not declared ATCODER_LOWLINK_HPP:
  const ATCODER_LOWLINK_HPP* = 1
  import std/tables
  import atcoder/extra/graph/graph_template
  import atcoder/extra/graph/undirected_decomposition

  proc LowLink*(g:Graph):tuple[articulation:seq[int], bridge:seq[(int,int)]] =
    # Preserve adjacency order (and hence legacy DFS result order). Pair
    # undirected arcs by endpoints so manually added arcs with rev == -1 also
    # work. Parallel edges get distinct ids; self-loops cannot be bridges or
    # affect articulation vertices and can be omitted from the adapter.
    var common = initUndirectedGraph(g.len)
    var pending = initTable[(int, int), seq[int]]()
    for u in 0 ..< g.len:
      for e in g[u]:
        let v = e.dst
        if u == v:
          continue
        var edgeId: int
        if u < v:
          edgeId = common.edges.len
          common.edges.add UndirectedEdge(u: u, v: v)
          pending.mgetOrPut((u, v), @[]).add edgeId
        else:
          edgeId = pending[(v, u)].pop()
        common.adj[u].add UndirectedAdjEdge(to: v, id: edgeId)

    let data = common.lowLinkUndirected()
    result.articulation = data.articulation
    for edgeId in data.bridges:
      let e = common.edges[edgeId]
      result.bridge.add (e.u, e.v)
