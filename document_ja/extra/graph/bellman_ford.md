# ベルマンフォード法

重みが任意のグラフの単一始点最短距離を計算します。

```nim
var d = bellman_ford(g:Graph, s:U or seq[U])
```

グラフ$g$の頂点$s$を始点とするベルマンフォード法を実行。
$s$はseqでも指定することができます。その場合は複数始点($s$の元はすべて距離0)で実行できます。
$d$は内部的にはBellmanFordResultというobjectで渡されていて、下記のような呼び出しが可能である。

## 距離の取得
```nim
d[u:U]:T
```
$s$から$u$までの距離を返します。
## 直前ノードの取得
```nim
d.prev(u):U
```
$s$から$u$までの最短経路上で$u$の前のノード(の1つ)を返します。
## 最短経路の取得
```nim
d.path(t:U):seq[U]
```
頂点$t$までの最短経路を取得。
戻り値は$s$で始まり$t$で終わるノード列となる。(Edge[T]で返すべきか。。。)



**@{keyword.constraints}**

- $0 \leq n \leq 10^8$

**@{keyword.complexity}**

追加した辺の本数を $m$ として
- $O(n * m)$だと思う(たぶん)

## 基本例

`bellman_ford(g, s)` は負辺を含む graph に対して、始点 `s` からの最短距離を計算します。

```nim
import atcoder/extra/graph/graph_template
import atcoder/extra/graph/bellman_ford

var g = initGraph(4)
g.addEdge(0, 1, 1)
g.addEdge(1, 2, -2)
g.addEdge(0, 2, 5)
g.addEdge(2, 3, 3)

let d = bellman_ford(g, 0)

doAssert d[2] == -1
doAssert d[3] == 2
doAssert d.path(3) == @[0, 1, 2, 3]
```
