when not declared ATCODER_EXTRA_GRAPH_DSU_ON_TREE_HPP:
  const ATCODER_EXTRA_GRAPH_DSU_ON_TREE_HPP* = 1

  type
    DSUOnTree* = object
      n*: int
      root*: int
      graph*: seq[seq[int]]
      parent*, depth*: seq[int]
      subtreeSize*, heavy*: seq[int]
      tin*, tout*, order*: seq[int]

    DSUOnTreeRunFrame = object
      v: int
      keep: bool
      phase: int

  proc initDSUOnTree*(graph: seq[seq[int]], root: int = 0): DSUOnTree =
    ## Builds metadata for DSU on Tree.
    ##
    ## `graph` must be an undirected tree.
    let n = graph.len

    doAssert n > 0
    doAssert 0 <= root and root < n

    result.n = n
    result.root = root
    result.graph = graph
    result.parent = newSeq[int](n)
    result.depth = newSeq[int](n)
    result.subtreeSize = newSeq[int](n)
    result.heavy = newSeq[int](n)
    result.tin = newSeq[int](n)
    result.tout = newSeq[int](n)
    result.order = @[]

    for i in 0 ..< n:
      result.parent[i] = -1
      result.heavy[i] = -1

    var stack = @[root]
    result.parent[root] = root

    while stack.len > 0:
      let v = stack[^1]
      stack.setLen(stack.len - 1)

      result.order.add v

      for to in graph[v]:
        if to == result.parent[v]:
          continue

        doAssert 0 <= to and to < n
        doAssert result.parent[to] == -1

        result.parent[to] = v
        result.depth[to] = result.depth[v] + 1
        stack.add to

    doAssert result.order.len == n

    for i, v in result.order:
      result.tin[v] = i

    for idx in countdown(n - 1, 0):
      let v = result.order[idx]
      result.subtreeSize[v] = 1

      var best = 0

      for to in graph[v]:
        if result.parent[to] == v:
          result.subtreeSize[v] += result.subtreeSize[to]

          if result.subtreeSize[to] > best:
            best = result.subtreeSize[to]
            result.heavy[v] = to

      result.tout[v] = result.tin[v] + result.subtreeSize[v]

  proc len*(dt: DSUOnTree): int {.inline.} =
    dt.n

  proc subtreeVertices*(dt: DSUOnTree, v: int): seq[int] =
    ## Returns vertices in the subtree of `v`.
    doAssert 0 <= v and v < dt.n

    for i in dt.tin[v] ..< dt.tout[v]:
      result.add dt.order[i]

  proc run*(
    dt: DSUOnTree,
    add: proc(v: int) {.closure.},
    remove: proc(v: int) {.closure.},
    answer: proc(v: int) {.closure.}
  ) =
    ## Runs DSU on Tree callbacks.
    ##
    ## At `answer(v)`, all vertices in the subtree of `v` have been added,
    ## and no vertex outside the subtree of `v` is present.
    var stack = @[DSUOnTreeRunFrame(v: dt.root, keep: true, phase: 0)]

    while stack.len > 0:
      let fr = stack[^1]
      stack.setLen(stack.len - 1)

      let v = fr.v

      if fr.phase == 0:
        system.add(stack, DSUOnTreeRunFrame(v: v, keep: fr.keep, phase: 1))

        if dt.heavy[v] >= 0:
          system.add(stack, DSUOnTreeRunFrame(v: dt.heavy[v], keep: true, phase: 0))

        var i = dt.graph[v].len

        while i > 0:
          i.dec

          let to = dt.graph[v][i]

          if dt.parent[to] == v and to != dt.heavy[v]:
            system.add(stack, DSUOnTreeRunFrame(v: to, keep: false, phase: 0))
      else:
        for to in dt.graph[v]:
          if dt.parent[to] == v and to != dt.heavy[v]:
            for i in dt.tin[to] ..< dt.tout[to]:
              add(dt.order[i])

        add(v)
        answer(v)

        if not fr.keep:
          for i in dt.tin[v] ..< dt.tout[v]:
            remove(dt.order[i])

  proc runDSUOnTree*(
    dt: DSUOnTree,
    add: proc(v: int) {.closure.},
    remove: proc(v: int) {.closure.},
    answer: proc(v: int) {.closure.}
  ) =
    ## Alias of `run`.
    dt.run(add, remove, answer)
