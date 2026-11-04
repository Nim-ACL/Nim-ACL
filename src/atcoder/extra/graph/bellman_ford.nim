when not declared ATCODER_BELLMAN_FORD_HPP:
  const ATCODER_BELLMAN_FORD_HPP* = 1
  import std/sequtils, std/algorithm
  import atcoder/extra/other/inf
  import atcoder/extra/graph/graph_template

  type BellmanFordResult*[T, U] = object
    negative_cycle*:bool
    dist*: seq[T]
    prev*: seq[U]
    when U isnot int:
      id*: proc(u:U):int
  proc `[]`*[T, U](d:BellmanFordResult[T, U], u:U):T =
    let u = when U isnot int: d.id(u) else: u
    d.dist[u]
  proc path*[T, U](d:BellmanFordResult[T, U], t:U): seq[U] = 
    var u = t
    while true:
      when U is int:
        if u < 0: break
      let i = when U isnot int: d.id(u) else: u
      result.add(u)
      if u == d.prev[i]: break
      u = d.prev[i]
    result.reverse()

  proc bellman_ford*[G:Graph](g:G, s:G.U or seq[G.U]): auto =
    let n = g.len
    var
      dist = newSeqWith(n, G.T.inf)
      prev = newSeq[G.U](n)
      negative_cycle = false
    when s is G.U:
      dist[g.id(s)] = G.T(0)
      prev[g.id(s)] = s
    else:
      for s in s:
        dist[g.id(s)] = G.T(0)
        prev[g.id(s)] = s
    for k in 0..<n:
      for u in 0..<n:
        if dist[u] == G.T.inf: continue
        for e in g.adj_by_id(u):
          let idst = g.id(e.dst)
          let t = dist[u] + e.weight
          if dist[idst] > t:
            dist[idst] = t
            prev[idst] = e.src
            if k == n-1:
              dist[idst] = -G.T.inf
              negative_cycle = true
    if negative_cycle:
      for k in 0..<n:
        for u in 0..<n:
          if dist[u] != -G.T.inf: continue
          for e in g.adj[u]:
            dist[g.id(e.dst)] = -G.T.inf
    result = BellmanFordResult[G.T, G.U](negative_cycle:negative_cycle, dist:dist, prev:prev)
    when G.U isnot int: result.id = g.id
