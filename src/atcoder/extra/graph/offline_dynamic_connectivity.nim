when not declared ATCODER_EXTRA_GRAPH_OFFLINE_DYNAMIC_CONNECTIVITY_HPP:
  const ATCODER_EXTRA_GRAPH_OFFLINE_DYNAMIC_CONNECTIVITY_HPP* = 1

  import atcoder/extra/structure/rollback_dsu
  export rollback_dsu

  type
    OfflineDCEdge* = tuple[u, v: int]

    OfflineDynamicConnectivity* = object
      n*: int
      q*: int
      size*: int
      seg*: seq[seq[OfflineDCEdge]]

  proc normalizeEdge(u, v: int): OfflineDCEdge {.inline.} =
    if u <= v:
      (u: u, v: v)
    else:
      (u: v, v: u)

  proc initOfflineDynamicConnectivity*(n, q: int): OfflineDynamicConnectivity =
    ## Creates an offline dynamic connectivity helper.
    ##
    ## `q` is the number of time points.
    doAssert n >= 0
    doAssert q >= 0

    result.n = n
    result.q = q
    result.size = 1

    while result.size < max(1, q):
      result.size *= 2

    result.seg = newSeq[seq[OfflineDCEdge]](2 * result.size)

  proc addEdgeInterval*(dc: var OfflineDynamicConnectivity, l, r, u, v: int) =
    ## Adds an undirected edge `(u, v)` active during the half-open interval `[l, r)`.
    doAssert 0 <= l and l <= r and r <= dc.q
    doAssert 0 <= u and u < dc.n
    doAssert 0 <= v and v < dc.n

    if l == r:
      return

    let e = normalizeEdge(u, v)

    var
      a = l + dc.size
      b = r + dc.size

    while a < b:
      if (a and 1) != 0:
        dc.seg[a].add e
        a.inc

      if (b and 1) != 0:
        b.dec
        dc.seg[b].add e

      a = a shr 1
      b = b shr 1

  proc run*(dc: OfflineDynamicConnectivity, f: proc(t: int, uf: RollbackDSU) {.closure.}) =
    ## Runs `f(t, uf)` for every time `t`.
    ##
    ## Inside the callback, `uf` represents the graph state at time `t`.
    var uf = initRollbackDSU(dc.n)

    proc dfs(k: int) =
      let snap = uf.snapshot

      for e in dc.seg[k]:
        discard uf.merge(e.u, e.v)

      if k >= dc.size:
        let t = k - dc.size

        if t < dc.q:
          f(t, uf)
      else:
        dfs(k * 2)
        dfs(k * 2 + 1)

      uf.rollback(snap)

    dfs(1)

  proc componentCounts*(dc: OfflineDynamicConnectivity): seq[int] =
    ## Returns the number of connected components at each time.
    var counts = newSeq[int](dc.q)

    dc.run(proc(t: int, uf: RollbackDSU) =
      counts[t] = uf.componentCount
    )

    counts
