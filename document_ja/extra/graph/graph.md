# グラフ facade

`atcoder/extra/graph/graph` は、利用頻度の高いグラフアルゴリズムをまとめてimportするための curated facadeです。
既存moduleのうち凍結済みの範囲だけをre-exportし、アルゴリズムの再実装やwrapper APIの追加は行いません。

```nim
import atcoder/extra/graph/graph
```

## 互換性方針

- 既存のdirect importは引き続き利用できます。
- 細かな制御や未収録algorithmが必要な場合、direct module importが上級利用者向けの正式経路です。
- 既存moduleの改名・移動・削除・自動deprecationは行いません。
- export-allではなく、選定済みmoduleだけを公開します。

## 収録module

| 分類 | Module | Direct import |
| --- | --- | --- |
| グラフ表現 | `graph_template` | `import atcoder/extra/graph/graph_template` |
| 最短路 | `dijkstra` | `import atcoder/extra/graph/dijkstra` |
| 最短路 | `bellman_ford` | `import atcoder/extra/graph/bellman_ford` |
| 全点対最短路 | `warshall_floyd` | `import atcoder/extra/graph/warshall_floyd` |
| DAG | `topological_sort` | `import atcoder/extra/graph/topological_sort` |
| 連結性 | `lowlink` | `import atcoder/extra/graph/lowlink` |
| 閉路検出 | `cycle_detection` | `import atcoder/extra/graph/cycle_detection` |
| 最小全域木 | `kruskal` | `import atcoder/extra/graph/kruskal` |
| 最小全域木 | `prim` | `import atcoder/extra/graph/prim` |
| functional graph | `functional_graph` | `import atcoder/extra/graph/functional_graph` |
| offline connectivity | `offline_dynamic_connectivity` | `import atcoder/extra/graph/offline_dynamic_connectivity` |

## 名前の衝突

複数moduleに現れる一般的なexport名があります: ``<``, ``[]``, `dst`, `id`, `len`, `path`, `src`, `weight`。
facade全体と代表symbolは、Nim 2.2.10／2.2.4およびC／C++ backendでcompile確認されています。
曖昧な一般名を使う場合は、対象moduleをdirect importしてください。

## 今回の対象外

- `STATIC_GRAPH_ALTERNATIVE_REPRESENTATION`
- `DIJKSTRA_RADIX_HEAP`
- `MULTI_DIMENSIONAL_DIJKSTRA`
- `FLOW_AND_MIN_COST_FLOW`
- `MATCHING_AND_ASSIGNMENT`
- `ADVANCED_UNDIRECTED_DECOMPOSITION`
- `EULER_TOUR_AND_TREE_ALGORITHMS`
- `REROOTING`
- `GRAPH_VISUALIZATION`
- `CHROMATIC_NUMBER`
- `MAXIMUM_INDEPENDENT_SET`
- `BIPARTITE_EDGE_COLORING`
- `MINIMUM_ARBORESCENCE`
- `RAW_ADD_REMOVE_ODC_EVENT_BUILDER`
- `GLOBAL_ALL_LIBRARY_FACADE`
