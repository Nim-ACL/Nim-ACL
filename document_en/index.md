# AC(AtCoder) Library Document


<!-- NIM_ACL_HOME_NAV_START -->

## Library map

[日本語ドキュメント](../document_ja/index.html)

Nim-ACL provides AtCoder Library-compatible APIs together with additional
competitive-programming algorithms, data structures, and Japanese/English
documentation.

### Start with the standard APIs

| Purpose | Documentation | Main APIs |
|---|---|---|
| Range products | [Segment Tree](./segtree.html) | `SegTree`, `prod`, `set` |
| Lazy propagation | [Lazy Segment Tree](./lazysegtree.html) | `LazySegTree`, `apply`, `prod` |
| Prefix sums | [Fenwick Tree](./fenwicktree.html) | `FenwickTree`, `add`, `sum` |
| Convolution | [Convolution](./convolution.html) | `convolution` |
| Maximum flow | [Max Flow](./maxflow.html) | `MFGraph`, `flow` |
| Minimum-cost flow | [Min-Cost Flow](./mincostflow.html) | `MCFGraph`, `flow`, `slope` |
| Disjoint sets | [DSU](./dsu.html) | `DSU`, `merge`, `leader` |
| Strongly connected components | [SCC](./scc.html) | `SCCGraph`, `scc` |
| Strings | [String Algorithms](./string.html) | suffix array, LCP, Z algorithm |
| Modular arithmetic | [ModInt](./modint.html) | static and dynamic modint |

### Recently added or substantially improved

| Area | API | Purpose |
|---|---|---|
| Multidimensional search | [KD-tree](./extra/structure/kd_tree.html) | nearest neighbor and half-open orthogonal ranges |
| Computational geometry | [Minkowski Sum](./extra/geometry/minkowski_sum.html) | Minkowski sum of arbitrary point-set hulls |
| Set power series | [Set Power Series Exp](./extra/math/exp_of_set_power_series.html) / [Log](./extra/math/log_of_set_power_series.html) | exponential and logarithm |
| Flow | [Minimum-Cost B-Flow](./extra/graph/bflow.html) | lower/upper bounds, supplies, demands, and costs |
| Persistent structures | [Persistent Segment Tree](./extra/structure/persistent_segment_tree.html) | versioned updates and range products |
| Sequence structures | [Implicit Treap](./extra/structure/implicit_treap.html) | split/merge and sequence operations |
| Trie | [Binary Trie](./extra/structure/binary_trie.html) | XOR minimum/maximum and multiset operations |
| FPS | [Formal Power Series facade](./extra/math/fps.html) | a unified entry point for FPS APIs |

### Additional libraries by category

| Category | Documentation |
|---|---|
| DP optimization | [Monotone Minima](./extra/dp/monotone_minima.html) · [Divide and Conquer Optimization](./extra/dp/divide_and_conquer_optimization.html) · [SMAWK](./extra/dp/smawk.html) |
| Mathematics and polynomials | [Berlekamp–Massey](./extra/math/berlekamp_massey.html) · [Polynomial Interpolation](./extra/math/polynomial_interpolation.html) · [Subset Convolution](./extra/math/subset_convolution.html) · [FPS](./extra/math/fps.html) |
| Data structures | [Persistent Segment Tree](./extra/structure/persistent_segment_tree.html) · [Implicit Treap](./extra/structure/implicit_treap.html) · [KD-tree](./extra/structure/kd_tree.html) · [Binary Trie](./extra/structure/binary_trie.html) |
| Graphs | [Bipartite Edge Coloring](./extra/graph/bipartite_edge_coloring.html) · [Minimum-Cost B-Flow](./extra/graph/bflow.html) |
| Computational geometry | [Minkowski Sum](./extra/geometry/minkowski_sum.html) |

### Guides

- [AtCoder level guide](./guide/atcoder_level_guide.html)
- [AtCoder algorithm-lecture coverage](./guide/atcoder_algorithm_lectures_coverage.html)

### Documentation structure

Additional-library pages generally follow this order: general form, parameters
and types, preconditions, return values and side effects, example, related
APIs, and complexity and implementation.

<!-- NIM_ACL_HOME_NAV_END -->

## Guides

- [AtCoder level-based library guide](./guide/atcoder_level_guide.html)
- [AtCoder Algorithm Lectures coverage](./guide/atcoder_algorithm_lectures_coverage.html)

## How to Install

- There is `atcoder` folder in the `ac-library` folder, after extracting the zip file.
- With g++, you can compile by `g++ main.cpp -std=c++14 -I .` with putting `atcoder` folder on the same place as `main.cpp`.
  - You should compile with `-std=c++14` or `-std=c++17`.
- See [Appendix](./appendix.html) for further details.

## Note

- The behavior is undefined if the input does not match the constraints.
- For simplicity, we abbreviate the types as follows.
  - `unsigned int` → `uint`
  - `long long` → `ll`
  - `unsigned long long` → `ull`
- $0^0=1$.
- Multiple edges and self-loops are allowed unless specified.

## List

`#include <atcoder/all>` : include everything

### Data Structures

- [`#include <atcoder/fenwicktree>`](./fenwicktree.html)
- [`#include <atcoder/segtree>`](./segtree.html)
- [`#include <atcoder/lazysegtree>`](./lazysegtree.html)
- [`#include <atcoder/string>`](./string.html)

### Math

- [`#include <atcoder/math>`](./math.html)
- [`#include <atcoder/convolution>`](./convolution.html)
- 💻[`#include <atcoder/modint>`](./modint.html)

### Graphs

- [`#include <atcoder/dsu>`](./dsu.html)
- [`#include <atcoder/maxflow>`](./maxflow.html)
- [`#include <atcoder/mincostflow>`](./mincostflow.html)
- [`#include <atcoder/scc>`](./scc.html)
- [`#include <atcoder/twosat>`](./twosat.html)

## Appendix

- [Appendix / FAQ](./appendix.html)

## Test

- You can test this Library [here](https://atcoder.jp/contests/practice2?lang=en).


## License

The header files in `atcoder` folder are licensed under a CC0 license. See `atcoder/LICENSE` for further details.

## Extra / Math

- FPS facade [`import atcoder/extra/math/fps`](./extra/math/fps.html)
- [`import atcoder/extra/graph/boruvka`](./extra/graph/boruvka.html)

## extra/dp

- [`import atcoder/extra/dp/cumulative_sum`](./extra/dp/cumulative_sum.html)
- [`import atcoder/extra/dp/cumulative_sum_2d`](./extra/dp/cumulative_sum_2d.html)
- [`import atcoder/extra/dp/dual_cumulative_sum_2d`](./extra/dp/dual_cumulative_sum_2d.html)
- [`import atcoder/extra/dp/edit_distance`](./extra/dp/edit_distance.html)
- [`import atcoder/extra/dp/largest_rectangle`](./extra/dp/largest_rectangle.html)
- [`import atcoder/extra/dp/dual_cumulative_sum`](./extra/dp/dual_cumulative_sum.html)
- [`import atcoder/extra/dp/longest_increasing_subsequence`](./extra/dp/longest_increasing_subsequence.html)
- [`import atcoder/extra/dp/slide_min`](./extra/dp/slide_min.html)

## extra/math

- [`import atcoder/extra/math/xor_basis`](./extra/math/xor_basis.html)
- [`import atcoder/extra/math/convert_base`](./extra/math/convert_base.html)
- [`import atcoder/extra/math/mod_sqrt`](./extra/math/mod_sqrt.html)
- [`import atcoder/extra/math/combination_table`](./extra/math/combination_table.html)
- [`import atcoder/extra/math/arbitrary_mod_combination`](./extra/math/arbitrary_mod_combination.html)
- [`import atcoder/extra/math/floor_sum_square`](./extra/math/floor_sum_square.html)
- [`import atcoder/extra/math/factorial`](./extra/math/factorial.html)

## extra/geometry

- [`import atcoder/extra/geometry/geometry`](./extra/geometry/geometry.html)
- [Geometry Guide](./extra/geometry/geometry_guide.html)

- [`import atcoder/extra/geometry/geometry_template`](./extra/geometry/geometry_template.html)
- [`import atcoder/extra/geometry/closest_pair`](./extra/geometry/closest_pair.html)
- [`import atcoder/extra/geometry/polygon`](./extra/geometry/polygon.html)
- [`import atcoder/extra/geometry/triangle`](./extra/geometry/triangle.html)
- [`import atcoder/extra/geometry/tangent`](./extra/geometry/tangent.html)

## extra/structure

- [`import atcoder/extra/structure/persistent_segment_tree`](./extra/structure/persistent_segment_tree.html)
- [`import atcoder/extra/structure/sqrt_tree`](./extra/structure/sqrt_tree.html)
- [`import atcoder/extra/structure/mex_set`](./extra/structure/mex_set.html)
- [`import atcoder/extra/structure/fast_set`](./extra/structure/fast_set.html)
- [`import atcoder/extra/structure/disjoint_sparse_table`](./extra/structure/disjoint_sparse_table.html)
- [`import atcoder/extra/structure/cartesian_tree`](./extra/structure/cartesian_tree.html)
- [`import atcoder/extra/structure/rollback_dsu`](./extra/structure/rollback_dsu.html)
- [`import atcoder/extra/structure/binary_trie`](./extra/structure/binary_trie.html)
- [`import atcoder/extra/structure/sorted_set_map`](./extra/structure/sorted_set_map.html)
- [`import atcoder/extra/structure/set_map`](./extra/structure/set_map.html)
- [`import atcoder/extra/structure/tree_backends`](./extra/structure/tree_backends.html)
- [`import atcoder/extra/structure/partially_persistent_dsu`](./extra/structure/partially_persistent_dsu.html)
- [`import atcoder/extra/structure/succinct_indexable_dictionary`](./extra/structure/succinct_indexable_dictionary.html)
- [`import atcoder/extra/structure/convex_hull_trick_add_monotone`](./extra/structure/convex_hull_trick_add_monotone.html)
- [`import atcoder/extra/structure/li_chao_tree`](./extra/structure/li_chao_tree.html)
- [`import atcoder/extra/structure/segtree_2d`](./extra/structure/segtree_2d.html)
- [`import atcoder/extra/structure/wavelet_matrix`](./extra/structure/wavelet_matrix.html)
- [`import atcoder/extra/structure/radix_heap`](./extra/structure/radix_heap.html)
- [`import atcoder/extra/structure/sparse_table`](./extra/structure/sparse_table.html)
- [`import atcoder/extra/structure/dual_fenwicktree`](./extra/structure/dual_fenwicktree.html)
- [`import atcoder/extra/structure/weighted_union_find`](./extra/structure/weighted_union_find.html)

## extra/graph

- [`import atcoder/extra/graph/euler_tour`](./extra/graph/euler_tour.html)
- [`import atcoder/extra/graph/undirected_decomposition`](./extra/graph/undirected_decomposition.html)
- [`import atcoder/extra/graph/biconnected_components`](./extra/graph/biconnected_components.html)
- [`import atcoder/extra/graph/two_edge_connected_components`](./extra/graph/two_edge_connected_components.html)
- [`import atcoder/extra/graph/block_cut_tree`](./extra/graph/block_cut_tree.html)
- [`import atcoder/extra/graph/rerooting_dp`](./extra/graph/rerooting_dp.html)
- [`import atcoder/extra/graph/dsu_on_tree`](./extra/graph/dsu_on_tree.html)
- [`import atcoder/extra/graph/offline_dynamic_connectivity`](./extra/graph/offline_dynamic_connectivity.html)
- [`import atcoder/extra/graph/functional_graph`](./extra/graph/functional_graph.html)

## extra/string

- [`import atcoder/extra/string/kmp`](./extra/string/kmp.html)
- [`import atcoder/extra/string/rolling_hash`](./extra/string/rolling_hash.html)
- [`import atcoder/extra/string/minimum_rotation`](./extra/string/minimum_rotation.html)
- [`import atcoder/extra/string/suffix_automaton`](./extra/string/suffix_automaton.html)
- [`import atcoder/extra/string/palindromic_tree`](./extra/string/palindromic_tree.html)
- [`import atcoder/extra/string/aho_corasick`](./extra/string/aho_corasick.html)
- [`import atcoder/extra/string/manacher`](./extra/string/manacher.html)

## extra/algorithm

- [`import atcoder/extra/algorithm/coordinate_compression`](./extra/algorithm/coordinate_compression.html)
- [`import atcoder/extra/algorithm/run_length_encoding`](./extra/algorithm/run_length_encoding.html)
- [`import atcoder/extra/algorithm/mo`](./extra/algorithm/mo.html)

<!-- NIM_ACL_JAPANESE_FACADE_INDEX_V1 -->
## Japanese API facades (experimental)

Canonical Nim-ACL implementations can also be reached
through Japanese import paths and API names.

- [Japanese API facade index](extra/ja/index.md)
<!-- /NIM_ACL_JAPANESE_FACADE_INDEX_V1 -->

<!-- NIM_ACL_CURATED_AUXILIARY_TREE_V1 -->
## Tree algorithms

- [Auxiliary Tree (Virtual Tree)](extra/graph/virtual_tree.md)
<!-- /NIM_ACL_CURATED_AUXILIARY_TREE_V1 -->

<!-- NIM_ACL_CURATED_DP_OPTIMIZATION_V1 -->
## DP optimization

- [Monotone Minima](extra/dp/monotone_minima.md)
- [Divide-and-Conquer Optimization](extra/dp/divide_and_conquer_optimization.md)
<!-- /NIM_ACL_CURATED_DP_OPTIMIZATION_V1 -->

<!-- GRAPH_FACADE_PACKET_ONE_START -->
## Curated graph facade

| Description | Documentation | Import |
| --- | --- | --- |
| Curated graph representation, shortest-path, connectivity, spanning-tree, functional-graph and offline-connectivity modules. Existing direct imports remain supported. | [Graph facade](./extra/graph/graph.html) | `import atcoder/extra/graph/graph` |
<!-- GRAPH_FACADE_PACKET_ONE_END -->
