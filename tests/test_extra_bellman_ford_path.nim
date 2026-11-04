import atcoder/extra/graph/graph_template
import atcoder/extra/graph/bellman_ford

proc vertexId(u: (int, int)): int = u[0] * 2 + u[1]

block tupleVertices:
  let source = (1, 1)
  let first = (0, 0)
  let middle = (1, 0)
  let target = (0, 1)
  var g = initGraph(4, vertexId)
  g.addEdge(source, first, 5)
  g.addEdge(source, first, 2) # Parallel edges with different weights.
  g.addEdge(source, target, 10)
  g.addEdge(first, middle, -3)
  g.addEdge(middle, target, 4)

  let d = bellman_ford(g, source)
  doAssert not d.negative_cycle
  doAssert d[source] == 0
  doAssert d[first] == 2
  doAssert d[middle] == -1
  doAssert d[target] == 3
  doAssert d.path(source) == @[source]
  doAssert d.path(first) == @[source, first]
  doAssert d.path(target) == @[source, first, middle, target]

block integerVertices:
  var g = initGraph(4)
  g.addEdge(3, 0, 5)
  g.addEdge(3, 0, 2)
  g.addEdge(3, 1, 10)
  g.addEdge(0, 2, -3)
  g.addEdge(2, 1, 4)

  let d = bellman_ford(g, 3)
  doAssert not d.negative_cycle
  doAssert d[1] == 3
  doAssert d.path(3) == @[3]
  doAssert d.path(0) == @[3, 0]
  doAssert d.path(1) == @[3, 0, 2, 1]
  doAssert d.path(-1).len == 0

block integerNegativeSentinel:
  # Preserve the existing traversal stop condition for public result objects.
  let d = BellmanFordResult[int, int](dist: @[0, 1, 2], prev: @[-1, 0, 1])
  doAssert d.path(-1).len == 0
  doAssert d.path(0) == @[0]
  doAssert d.path(2) == @[0, 1, 2]

echo "OK"
