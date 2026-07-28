import atcoder/extra/graph/graph

when not declared(ADJTYPE_SEQ):
  {.error: "missing graph facade symbol: ADJTYPE_SEQ".}

when not declared(DijkstraObj):
  {.error: "missing graph facade symbol: DijkstraObj".}

when not declared(BellmanFordResult):
  {.error: "missing graph facade symbol: BellmanFordResult".}

when not declared(WarshallFloydResult):
  {.error: "missing graph facade symbol: WarshallFloydResult".}

when not declared(topologicalSort):
  {.error: "missing graph facade symbol: topologicalSort".}

when not declared(LowLink):
  {.error: "missing graph facade symbol: LowLink".}

when not declared(cycleDetection):
  {.error: "missing graph facade symbol: cycleDetection".}

when not declared(kruskal):
  {.error: "missing graph facade symbol: kruskal".}

when not declared(prim):
  {.error: "missing graph facade symbol: prim".}

when not declared(Doubling):
  {.error: "missing graph facade symbol: Doubling".}

when not declared(OfflineDCEdge):
  {.error: "missing graph facade symbol: OfflineDCEdge".}

static:
  doAssert declared(ADJTYPE_SEQ)
  doAssert declared(DijkstraObj)
  doAssert declared(BellmanFordResult)
  doAssert declared(WarshallFloydResult)
  doAssert declared(topologicalSort)
  doAssert declared(LowLink)
  doAssert declared(cycleDetection)
  doAssert declared(kruskal)
  doAssert declared(prim)
  doAssert declared(Doubling)
  doAssert declared(OfflineDCEdge)
