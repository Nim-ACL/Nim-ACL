when not declared ATCODER_INTERNAL_SCC_HPP:
  const ATCODER_INTERNAL_SCC_HPP* = 1
  
  import std/sequtils
  import atcoder/internal_csr

  
  type edge* = object
    dst:int
  # Reference:
  # R. Tarjan,
  # Depth-First Search and Linear Graph Algorithms
  type internal_scc_graph* = object
    n:int
    edges:seq[(int,edge)]

  proc init_internal_scc_graph*(n:int):auto =
    assert n >= 0
    internal_scc_graph(n:n, edges:newSeq[(int,edge)]())
  
  proc num_vertices*(self: internal_scc_graph):int =  self.n

  proc add_edge*(self: var internal_scc_graph, src, dst:int) =
    assert 0 <= src and src < self.n
    assert 0 <= dst and dst < self.n
    self.edges.add((src, edge(dst:dst)))

  # @return pair of (# of scc, scc id)
  #
  # Tarjan's algorithm implemented with an explicit DFS frame stack.
  # This avoids depending on the process call-stack depth.
  proc scc_ids*(self: internal_scc_graph):(int,seq[int]) =
    type DfsFrame = object
      vertex, nextEdge, endEdge, parent: int

    let g =
      initCsr[edge](
        self.n,
        self.edges,
      )

    var
      nowOrd = 0
      groupNum = 0

      active =
        newSeqOfCap[int](self.n)

      frames =
        newSeqOfCap[DfsFrame](self.n)

      low =
        newSeq[int](self.n)

      ord =
        newSeqWith(
          self.n,
          -1,
        )

      ids =
        newSeq[int](self.n)

    for root in 0 ..< self.n:
      if ord[root] != -1:
        continue

      low[root] =
        nowOrd

      ord[root] =
        nowOrd

      nowOrd.inc

      active.add(root)

      frames.add(
        DfsFrame(
          vertex: root,
          nextEdge: g.start[root],
          endEdge: g.start[root + 1],
          parent: -1,
        )
      )

      while frames.len > 0:
        let
          frameIndex =
            frames.high

          vertex =
            frames[frameIndex].vertex

        if frames[frameIndex].nextEdge <
            frames[frameIndex].endEdge:

          let edgeIndex =
            frames[frameIndex].nextEdge

          frames[frameIndex].nextEdge.inc

          let dst =
            g.elist[edgeIndex].dst

          if ord[dst] == -1:
            low[dst] =
              nowOrd

            ord[dst] =
              nowOrd

            nowOrd.inc

            active.add(dst)

            frames.add(
              DfsFrame(
                vertex: dst,
                nextEdge: g.start[dst],
                endEdge: g.start[dst + 1],
                parent: vertex,
              )
            )

          elif ord[dst] < self.n:
            low[vertex] =
              min(
                low[vertex],
                ord[dst],
              )

        else:
          let parent =
            frames[frameIndex].parent

          if low[vertex] ==
              ord[vertex]:

            while true:
              let componentVertex =
                active[^1]

              discard active.pop()

              ord[componentVertex] =
                self.n

              ids[componentVertex] =
                groupNum

              if componentVertex ==
                  vertex:

                break

            groupNum.inc

          discard frames.pop()

          if parent >= 0:
            low[parent] =
              min(
                low[parent],
                low[vertex],
              )

    ids.applyIt(
      groupNum - 1 - it
    )

    return (
      groupNum,
      ids,
    )

  proc scc*(self: internal_scc_graph):auto =
    let
      ids = self.scc_ids()
      group_num = ids[0]
    var counts = newSeq[int](group_num)
    for x in ids[1]: counts[x].inc
    result = newSeq[seq[int]](ids[0])
    for i in 0..<group_num:
      result[i] = newSeqOfCap[int](counts[i])
    for i in 0..<self.n:
      result[ids[1][i]].add(i)
