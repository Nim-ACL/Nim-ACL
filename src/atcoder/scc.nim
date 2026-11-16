when not declared ATCODER_SCC_HPP:
  const ATCODER_SCC_HPP* = 1

  import atcoder/internal_scc

  type SCCGraph* = object
    internal: internal_scc_graph

  proc initSccGraph*(n:int):auto =
    SCCGraph(internal:init_internal_scc_graph(n))
  
  proc add_edge*(self:var SCCgraph, src, dst:int) =
    self.internal.add_edge(src, dst)

  proc scc*(self:SCCGraph):auto = self.internal.scc()
