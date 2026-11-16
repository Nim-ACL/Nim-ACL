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

  proc lowLinkUndirected*(
    g: UndirectedGraph,
    buildComponents: static bool = false
  ): BiconnectedComponentsResult =
    ## Shared iterative low-link traversal. Without components, articulation
    ## vertices and bridge ids are returned in DFS completion order.
    ## The legacy Graph adapter also uses this traversal.
    type DfsFrame = object
      vertex, parentEdge, nextEdge, childCount: int

    let n = g.n

    result.ord = newSeq[int](n)
    result.low = newSeq[int](n)
    when buildComponents:
      result.componentOfEdge = newSeq[int](g.edgeCount)

    for v in 0 ..< n:
      result.ord[v] = -1
      result.low[v] = -1

    when buildComponents:
      for edgeId in 0 ..< g.edgeCount:
        result.componentOfEdge[edgeId] = -1

    var
      timer = 0
      edgeStack: seq[int] = @[]
      articulationFlag = newSeq[bool](n)
      frames = newSeqOfCap[DfsFrame](n)

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

    for start in 0 ..< n:
      if result.ord[start] >= 0:
        continue

      result.ord[start] = timer
      result.low[start] = timer
      timer.inc
      frames.add DfsFrame(vertex: start, parentEdge: -1)

      while frames.len > 0:
        let v = frames[^1].vertex
        if frames[^1].nextEdge < g.adj[v].len:
          let e = g.adj[v][frames[^1].nextEdge]
          frames[^1].nextEdge.inc
          if e.id == frames[^1].parentEdge:
            continue

          if result.ord[e.to] < 0:
            frames[^1].childCount.inc
            when buildComponents:
              edgeStack.add e.id
            result.ord[e.to] = timer
            result.low[e.to] = timer
            timer.inc
            frames.add DfsFrame(vertex: e.to, parentEdge: e.id)
          elif result.ord[e.to] < result.ord[v]:
            # Skip only the parent edge, not other edges to the parent vertex.
            when buildComponents:
              edgeStack.add e.id
            result.low[v] = min(result.low[v], result.ord[e.to])
        else:
          let finished = frames.pop()
          if articulationFlag[v]:
            result.articulation.add v
          if finished.parentEdge >= 0:
            let parent = frames[^1].vertex
            result.low[parent] = min(result.low[parent], result.low[v])
            if result.low[v] >= result.ord[parent]:
              if frames[^1].parentEdge >= 0 or frames[^1].childCount > 1:
                articulationFlag[parent] = true
              when buildComponents:
                emitComponent(finished.parentEdge, result)
            if result.low[v] > result.ord[parent]:
              result.bridges.add finished.parentEdge

      when buildComponents:
        doAssert edgeStack.len == 0

    when buildComponents:
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

  proc biconnectedComponents*(
    g: UndirectedGraph
  ): BiconnectedComponentsResult =
    ## Computes vertex-biconnected components, articulation vertices,
    ## and bridges with the shared low-link traversal.
    g.lowLinkUndirected(buildComponents = true)

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
