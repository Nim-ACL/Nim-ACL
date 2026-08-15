# Curated graph facade

`atcoder/extra/graph/graph` is a curated convenience facade for commonly used graph algorithms.
It re-exports a deliberately bounded set of existing modules; it does not reimplement algorithms or add wrapper APIs.

```nim
import atcoder/extra/graph/graph
```

## Compatibility policy

- Existing direct imports remain supported.
- Direct module imports remain the advanced-user path when precise control or an unselected algorithm is needed.
- Existing modules are not renamed, moved, deleted or deprecated by this facade.
- The facade is curated rather than export-all.

## Included modules

| Category | Module | Direct import |
| --- | --- | --- |
| Graph representation | `graph_template` | `import atcoder/extra/graph/graph_template` |
| Shortest paths | `dijkstra` | `import atcoder/extra/graph/dijkstra` |
| Shortest paths | `bellman_ford` | `import atcoder/extra/graph/bellman_ford` |
| All-pairs shortest paths | `warshall_floyd` | `import atcoder/extra/graph/warshall_floyd` |
| DAG utilities | `topological_sort` | `import atcoder/extra/graph/topological_sort` |
| Connectivity | `lowlink` | `import atcoder/extra/graph/lowlink` |
| Cycle detection | `cycle_detection` | `import atcoder/extra/graph/cycle_detection` |
| Minimum spanning trees | `kruskal` | `import atcoder/extra/graph/kruskal` |
| Minimum spanning trees | `prim` | `import atcoder/extra/graph/prim` |
| Functional graphs | `functional_graph` | `import atcoder/extra/graph/functional_graph` |
| Offline connectivity | `offline_dynamic_connectivity` | `import atcoder/extra/graph/offline_dynamic_connectivity` |

## Name collisions

Several generic exported names occur in more than one selected module: ``<``, ``[]``, `dst`, `id`, `len`, `path`, `src`, `weight`.
The complete facade and representative symbols were compiled on Nim 2.2.10 and 2.2.4 with the C and C++ backends.
When an unqualified generic name is ambiguous, use the corresponding direct module import.

## Deferred scope

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
