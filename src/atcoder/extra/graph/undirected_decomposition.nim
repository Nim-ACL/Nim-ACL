when not declared ATCODER_EXTRA_GRAPH_UNDIRECTED_DECOMPOSITION_HPP:
  const ATCODER_EXTRA_GRAPH_UNDIRECTED_DECOMPOSITION_HPP* = 1

  import std/algorithm

  type
    UndirectedEdge* = object
      u*, v*: int

    UndirectedAdjEdge* = object
      to*, id*: int

    UndirectedGraph* = object
      n*: int
      edges*: seq[UndirectedEdge]
      adj*: seq[seq[UndirectedAdjEdge]]

    BiconnectedComponentsResult* = object
      ord*, low*: seq[int]
      articulation*: seq[int]
      bridges*: seq[int]
      edgeComponents*: seq[seq[int]]
      vertexComponents*: seq[seq[int]]
      componentOfEdge*: seq[int]

    TwoEdgeConnectedComponentsResult* = object
      component*: seq[int]
      groups*: seq[seq[int]]
      bridgeIds*: seq[int]
      forest*: seq[seq[int]]

    BlockCutTreeResult* = object
      tree*: seq[seq[int]]
      blockVertices*: seq[seq[int]]
      articulationVertices*: seq[int]
      articulationNode*: seq[int]
      vertexNode*: seq[int]
      blockNodeCount*: int

  proc initUndirectedGraph*(n: int): UndirectedGraph =
    ## Creates an undirected graph with `n` vertices.
    doAssert n >= 0

    result.n = n
    result.edges = @[]
    result.adj = newSeq[seq[UndirectedAdjEdge]](n)

  proc len*(g: UndirectedGraph): int {.inline.} =
    g.n

  proc edgeCount*(g: UndirectedGraph): int {.inline.} =
    g.edges.len

  proc addEdge*(g: var UndirectedGraph, u, v: int): int =
    ## Adds an undirected edge and returns its edge id.
    ##
    ## Parallel edges are supported. Self-loops are intentionally rejected.
    doAssert 0 <= u and u < g.n
    doAssert 0 <= v and v < g.n
    doAssert u != v

    result = g.edges.len

    g.edges.add UndirectedEdge(u: u, v: v)
    g.adj[u].add UndirectedAdjEdge(to: v, id: result)
    g.adj[v].add UndirectedAdjEdge(to: u, id: result)

  proc other*(g: UndirectedGraph, edgeId, v: int): int =
    ## Returns the opposite endpoint of an edge.
    doAssert 0 <= edgeId and edgeId < g.edgeCount
    doAssert g.edges[edgeId].u == v or g.edges[edgeId].v == v

    if g.edges[edgeId].u == v:
      g.edges[edgeId].v
    else:
      g.edges[edgeId].u

  proc sortedUnique(values: seq[int]): seq[int] =
    var a = values
    a.sort()

    for x in a:
      if result.len == 0 or result[^1] != x:
        result.add x

  proc biconnectedComponents*(
    g: UndirectedGraph
  ): BiconnectedComponentsResult =
    ## Computes vertex-biconnected components, articulation vertices,
    ## and bridges with Tarjan's low-link algorithm.
    let n = g.n

    result.ord = newSeq[int](n)
    result.low = newSeq[int](n)
    result.componentOfEdge = newSeq[int](g.edgeCount)

    for v in 0 ..< n:
      result.ord[v] = -1
      result.low[v] = -1

    for edgeId in 0 ..< g.edgeCount:
      result.componentOfEdge[edgeId] = -1

    var
      timer = 0
      edgeStack: seq[int] = @[]
      articulationFlag = newSeq[bool](n)

    proc emitComponent(stopEdge: int, state: var BiconnectedComponentsResult) =
      var component: seq[int] = @[]

      while edgeStack.len > 0:
        let edgeId = edgeStack[^1]
        edgeStack.setLen(edgeStack.len - 1)

        component.add edgeId

        if edgeId == stopEdge:
          break

      doAssert component.len > 0

      let componentId = state.edgeComponents.len

      for edgeId in component:
        doAssert state.componentOfEdge[edgeId] < 0
        state.componentOfEdge[edgeId] = componentId

      var vertices: seq[int] = @[]

      for edgeId in component:
        vertices.add g.edges[edgeId].u
        vertices.add g.edges[edgeId].v

      state.edgeComponents.add component
      state.vertexComponents.add sortedUnique(vertices)

    proc dfs(v, parentEdge: int, state: var BiconnectedComponentsResult) =
      state.ord[v] = timer
      state.low[v] = timer
      timer.inc

      var childCount = 0

      for e in g.adj[v]:
        if e.id == parentEdge:
          continue

        let to = e.to

        if state.ord[to] < 0:
          childCount.inc
          edgeStack.add e.id

          dfs(to, e.id, state)

          state.low[v] = min(state.low[v], state.low[to])

          if state.low[to] >= state.ord[v]:
            if parentEdge >= 0 or childCount > 1:
              articulationFlag[v] = true

            emitComponent(e.id, state)

          if state.low[to] > state.ord[v]:
            state.bridges.add e.id

        elif state.ord[to] < state.ord[v]:
          # Back edge to an ancestor. Edge ids make parallel edges safe.
          edgeStack.add e.id
          state.low[v] = min(state.low[v], state.ord[to])

    for start in 0 ..< n:
      if result.ord[start] >= 0:
        continue

      dfs(start, -1, result)
      doAssert edgeStack.len == 0

    for v in 0 ..< n:
      if articulationFlag[v]:
        result.articulation.add v

    result.articulation.sort()
    result.bridges.sort()

    # Add singleton blocks for isolated vertices.
    var belongs = newSeq[bool](n)

    for component in result.vertexComponents:
      for v in component:
        belongs[v] = true

    for v in 0 ..< n:
      if not belongs[v]:
        result.edgeComponents.add @[]
        result.vertexComponents.add @[v]

  proc twoEdgeConnectedComponents*(
    g: UndirectedGraph,
    bcc: BiconnectedComponentsResult
  ): TwoEdgeConnectedComponentsResult =
    ## Contracts every maximal subgraph containing no bridge.
    let n = g.n

    result.component = newSeq[int](n)
    result.bridgeIds = bcc.bridges

    for v in 0 ..< n:
      result.component[v] = -1

    var isBridge = newSeq[bool](g.edgeCount)

    for edgeId in bcc.bridges:
      isBridge[edgeId] = true

    for start in 0 ..< n:
      if result.component[start] >= 0:
        continue

      let componentId = result.groups.len

      result.groups.add @[]
      result.component[start] = componentId

      var stack = @[start]

      while stack.len > 0:
        let v = stack[^1]
        stack.setLen(stack.len - 1)

        result.groups[componentId].add v

        for e in g.adj[v]:
          if isBridge[e.id]:
            continue

          if result.component[e.to] < 0:
            result.component[e.to] = componentId
            stack.add e.to

    result.forest = newSeq[seq[int]](result.groups.len)

    for edgeId in bcc.bridges:
      let
        edge = g.edges[edgeId]
        a = result.component[edge.u]
        b = result.component[edge.v]

      doAssert a != b

      result.forest[a].add b
      result.forest[b].add a

  proc twoEdgeConnectedComponents*(
    g: UndirectedGraph
  ): TwoEdgeConnectedComponentsResult =
    ## Convenience overload computing low-link data internally.
    let bcc = g.biconnectedComponents()
    g.twoEdgeConnectedComponents(bcc)

  proc blockCutTree*(
    g: UndirectedGraph,
    bcc: BiconnectedComponentsResult
  ): BlockCutTreeResult =
    ## Builds the bipartite block-cut forest.
    ##
    ## Block nodes come first, followed by articulation-vertex nodes.
    let n = g.n

    result.blockVertices = bcc.vertexComponents
    result.blockNodeCount = result.blockVertices.len
    result.articulationVertices = bcc.articulation
    result.articulationNode = newSeq[int](n)
    result.vertexNode = newSeq[int](n)

    for v in 0 ..< n:
      result.articulationNode[v] = -1
      result.vertexNode[v] = -1

    var isArticulation = newSeq[bool](n)

    for i, v in result.articulationVertices:
      let node = result.blockNodeCount + i

      isArticulation[v] = true
      result.articulationNode[v] = node
      result.vertexNode[v] = node

    result.tree = newSeq[seq[int]](
      result.blockNodeCount + result.articulationVertices.len
    )

    for blockIndex, vertices in result.blockVertices:
      for v in vertices:
        if isArticulation[v]:
          let articulationNode = result.articulationNode[v]

          result.tree[blockIndex].add articulationNode
          result.tree[articulationNode].add blockIndex
        else:
          if result.vertexNode[v] < 0:
            result.vertexNode[v] = blockIndex
          else:
            doAssert result.vertexNode[v] == blockIndex

    for v in 0 ..< n:
      doAssert result.vertexNode[v] >= 0

  proc blockCutTree*(
    g: UndirectedGraph
  ): BlockCutTreeResult =
    ## Convenience overload computing biconnected components internally.
    let bcc = g.biconnectedComponents()
    g.blockCutTree(bcc)
