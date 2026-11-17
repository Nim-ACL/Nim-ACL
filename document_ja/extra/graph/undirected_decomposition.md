# Undirected Graph Decomposition

この module は、無向グラフに対する次の分解をまとめて提供します。

- articulation point と bridge
- vertex-biconnected components
- two-edge-connected components
- block-cut tree

いずれも DFS tree と low-link 値を利用します。

## Low-link の考え方

DFS で頂点 `v` を訪問した時刻を `ord[v]` とします。

`low[v]` は、`v` の subtree から tree edge を下り、back edge を高々1本使って到達できる最小の `ord` です。

tree edge `v -> to` について、

- `low[to] > ord[v]` なら、その edge は bridge
- `low[to] >= ord[v]` なら、そこで biconnected component を区切れる

と判定できます。

## import

用途に応じて facade を選べます。

~~~nim
import atcoder/extra/graph/biconnected_components
import atcoder/extra/graph/two_edge_connected_components
import atcoder/extra/graph/block_cut_tree
~~~

全機能を直接使う場合はこちらです。

~~~nim
import atcoder/extra/graph/undirected_decomposition
~~~

## グラフの構築

~~~nim
proc initUndirectedGraph(n: int): UndirectedGraph
proc addEdge(g: var UndirectedGraph, u, v: int): int
~~~

`addEdge` は edge id を返します。

parallel edge は使用できます。self-loop は使用できません。

## Low-linkのみを取得する低水準API

~~~nim
proc lowLinkUndirected(
  g: UndirectedGraph,
  buildComponents: static bool = false
): BiconnectedComponentsResult
~~~

既定では`ord`・`low`・`articulation`・`bridges`を求めます。
`articulation`と`bridges`はDFSの完了順で、ソート順は保証しません。
component用の3フィールドは空列です。`buildComponents = true`では
全componentを構築し、関節点と橋をソートします。通常の全分解には
`biconnectedComponents`を使えます。DFSは明示スタックによる反復実装です。

## Biconnected Components

~~~nim
proc biconnectedComponents(
  g: UndirectedGraph
): BiconnectedComponentsResult
~~~

結果には次が含まれます。

~~~nim
ord, low: seq[int]
articulation: seq[int]
bridges: seq[int]
edgeComponents: seq[seq[int]]
vertexComponents: seq[seq[int]]
componentOfEdge: seq[int]
~~~

- `articulation` は関節点
- `bridges` は橋の edge id
- `edgeComponents[i]` は component `i` に属する edge id
- `vertexComponents[i]` は component `i` に属する頂点

## Two-Edge-Connected Components

橋を取り除いて得られる連結成分です。

~~~nim
proc twoEdgeConnectedComponents(
  g: UndirectedGraph
): TwoEdgeConnectedComponentsResult
~~~

~~~nim
component: seq[int]
groups: seq[seq[int]]
bridgeIds: seq[int]
forest: seq[seq[int]]
~~~

`forest` は各 component を縮約して得られる bridge forest です。

## Block-Cut Tree

Biconnected component node と articulation vertex node からなる二部 forest です。

~~~nim
proc blockCutTree(
  g: UndirectedGraph
): BlockCutTreeResult
~~~

~~~nim
tree: seq[seq[int]]
blockVertices: seq[seq[int]]
articulationVertices: seq[int]
articulationNode: seq[int]
vertexNode: seq[int]
blockNodeCount: int
~~~

block node は `0 ..< blockNodeCount` に置かれ、その後ろに articulation node が置かれます。

## 使用例

<!-- nim-line-numbers -->
~~~nim
var g = initUndirectedGraph(6)

discard g.addEdge(0, 1)
discard g.addEdge(1, 2)
discard g.addEdge(2, 0)

let bridge = g.addEdge(1, 3)

discard g.addEdge(3, 4)
discard g.addEdge(4, 5)
discard g.addEdge(5, 3)

let bcc = g.biconnectedComponents()

doAssert bcc.articulation == @[1, 3]
doAssert bcc.bridges == @[bridge]

let tecc = g.twoEdgeConnectedComponents(bcc)
let blockCut = g.blockCutTree(bcc)
~~~

## 計算量

頂点数を `n`、辺数を `m` とすると、

- Biconnected Components: `O(n + m)`
- Two-Edge-Connected Components: `O(n + m)`
- Block-Cut Tree: `O(n + m)`
- memory: `O(n + m)`

## 注意

- 無向グラフ用です。
- disconnected graph にも対応し、結果は forest になります。
- parallel edge に対応します。
- self-loop は使用できません。
- DFSは明示スタックによる反復実装です。深いpath graphでもDFSの再帰呼び出しは使いません。

## 関連資料・他言語ライブラリ

- cp-algorithms: Cutpoints and Bridges
- Library Checker: Biconnected Components
- Library Checker: Two-Edge-Connected Components
- Nyaan Library: LowLink / Block-Cut Tree
- ei1333 Library: LowLink / BiConnected Components
