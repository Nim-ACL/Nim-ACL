# AC(AtCoder) Library Document


<!-- NIM_ACL_HOME_NAV_START -->
## ライブラリマップ

[English documentation](../document_en/index.html)

Nim-ACLはAtCoder Library互換APIに加えて、
競技プログラミング向けの追加アルゴリズムと
データ構造を提供します。

### まず使う標準API

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| 区間積 | [Segment Tree](./segtree.html) | `import atcoder/segtree` | `SegTree`, `prod`, `set` |
| 遅延伝播 | [Lazy Segment Tree](./lazysegtree.html) | `import atcoder/lazysegtree` | `LazySegTree`, `apply`, `prod` |
| 累積和 | [Fenwick Tree](./fenwicktree.html) | `import atcoder/fenwicktree` | `FenwickTree`, `add`, `sum` |
| 2次元累積和 | [CumulativeSum2D](./extra/dp/cumulative_sum_2d.html) | `import atcoder/extra/dp/cumulative_sum_2d` | `initCumulativeSum2D`, `sum`, `allSum` |
| 密な2次元Fenwick Tree | [DenseFenwickTree2D](./extra/structure/dense_fenwicktree_2d.html) | `import atcoder/extra/structure/dense_fenwicktree_2d` | `initDenseFenwickTree2D`, `add`, `prefixSum`, `sum` |
| 畳み込み | [Convolution](./convolution.html) | `import atcoder/convolution` | `convolution` |
| 最大流 | [Max Flow](./maxflow.html) | `import atcoder/maxflow` | `MFGraph`, `flow` |
| 最小費用流 | [Min-Cost Flow](./mincostflow.html) | `import atcoder/mincostflow` | `MCFGraph`, `flow`, `slope` |
| 素集合データ構造 | [DSU](./dsu.html) | `import atcoder/dsu` | `DSU`, `merge`, `leader` |
| 強連結成分 | [SCC](./scc.html) | `import atcoder/scc` | `SCCGraph`, `scc` |
| 2-SAT | [TwoSAT](./twosat.html) | `import atcoder/twosat` | `add_clause`, `satisfiable` |
| 文字列 | [String Algorithms](./string.html) | `import atcoder/string` | `suffix_array`, `lcp_array`, `z_algorithm` |
| mod整数 | [ModInt](./modint.html) | `import atcoder/modint` | static／dynamic modint |

### 最近追加・整備されたAPI

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| 多次元探索 | [KD-tree](./extra/structure/kd_tree.html) | `import atcoder/extra/structure/kd_tree` | `initKDTree`, `nearest`, `rangeSearch` |
| 最小包含円 | [Minimum Enclosing Circle](./extra/geometry/minimum_enclosing_circle.html) | `import atcoder/extra/geometry/minimum_enclosing_circle` | `minimumEnclosingCircle` |
| Minkowski和 | [Minkowski Sum](./extra/geometry/minkowski_sum.html) | `import atcoder/extra/geometry/minkowski_sum` | `minkowskiSum` |
| min-plus畳み込み | [Min-Plus Convolution](./extra/math/min_plus_convolution.html) | `import atcoder/extra/math/min_plus_convolution` | `minPlusConvolutionConvexArbitrary` |
| 集合冪級数 | [Set Power Series Exp](./extra/math/exp_of_set_power_series.html)／[Log](./extra/math/log_of_set_power_series.html) | `import atcoder/extra/math/exp_of_set_power_series` | `expOfSetPowerSeries`, `logOfSetPowerSeries` |
| 最小費用B-flow | [Minimum-Cost B-Flow](./extra/graph/bflow.html) | `import atcoder/extra/graph/bflow` | `BFlow`, `solve` |
| 永続セグメント木 | [Persistent Segment Tree](./extra/structure/persistent_segment_tree.html) | `import atcoder/extra/structure/persistent_segment_tree` | `initialVersion`, `set`, `prod` |
| 座標圧縮2次元セグメント木 | [CompressedSegTree2D](./extra/structure/compressed_segtree_2d.html) | `import atcoder/extra/structure/compressed_segtree_2d` | `initCompressedSegTree2D`, `set`, `combineAt`, `prod` |
| 動的列 | [Implicit Treap](./extra/structure/implicit_treap.html) | `import atcoder/extra/structure/implicit_treap` | `insert`, `erase`, `reverse`, `prod` |
| XOR Trie | [Binary Trie](./extra/structure/binary_trie.html) | `import atcoder/extra/structure/binary_trie` | `insert`, `erase`, `minElement`, `maxElement` |
| FPS facade | [FPS](./extra/math/fps.html) | `import atcoder/extra/math/fps` | `useFPS`, `useFPSDecl` |

### 分野別追加ライブラリ

以下の完全一覧は、すべて同じ4列で掲載しています。

#### 標準ライブラリ

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| 2-SATを解きます。 変数 $x0, x1, \cdots, x{N - 1}$ に関して、 | [2-SAT](./twosat.html) | `import atcoder/twosat` | `add_clause, satisfiable, answer` |
| 畳み込みを行います。数列 $a0, a1, \cdots, a{N - 1}$ と数列 $b0, b1, \cdots, b{M - 1}$ から、長さ $N + M - 1… | [Convolution](./convolution.html) | `import atcoder/convolution` | `convolution, convolution_ll` |
| 無向グラフに対して、 | [DSU](./dsu.html) | `import atcoder/dsu` | `merge, same, leader, size, groups` |
| dynamiclazysegtree は、実行時に op, e, mapping, composition, id を渡して使う遅延セグメント木です。 | [DynamicLazySegTree](./dynamic_lazysegtree.html) | `import atcoder/dynamic_lazysegtree` | `prod, apply, all_prod` |
| dynamicsegtree は、実行時に op と e を渡して使うセグメント木です。 | [DynamicSegTree](./dynamic_segtree.html) | `import atcoder/dynamic_segtree` | `set, get, prod, all_prod` |
| このページは自動生成された下書きです。 | [element_concepts](./element_concepts.html) | `import atcoder/element_concepts` | `inv, HasInitInt, HasIntConverter, AdditiveGroupElem, MultiplicativeGroupElem` |
| 長さ $N$ の配列に対し、 | [Fenwick Tree](./fenwicktree.html) | `import atcoder/fenwicktree` | `add, sum` |
| このページは自動生成された下書きです。 | [header](./header.html) | `import atcoder/header` | `scanf, getchar, nextInt, nextFloat, nextString` |
| モノイド $(S, \cdot: S \times S \to S, e \in S)$と、$S$ から $S$ への写像の集合 $F$ であって、以下の条件を満たすようなも… | [Lazy Segtree](./lazysegtree.html) | `import atcoder/lazysegtree` | `set, get, prod, all_prod, apply` |
| 数論的アルゴリズム詰め合わせです。 | [Math](./math.html) | `import atcoder/math` | `pow_mod, inv_mod, crt, floor_sum` |
| 最大フロー問題 を解くライブラリです。 | [MaxFlow](./maxflow.html) | `import atcoder/maxflow` | `add_edge, flow, min_cut, change_edge` |
| Minimum-cost flow problemを扱うライブラリです。 | [MinCostFlow](./mincostflow.html) | `import atcoder/mincostflow` | `add_edge, edges` |
| 自動でmodを取る構造体です。AC Libraryはmodintを使わなくとも全アルゴリズムが使えるように整備しているので、必ずしもこのファイルの内容を把握する必要はありません。 | [Modint](./modint.html) | `import atcoder/modint` | `mod, val, inv, raw` |
| Nimのclosed・half-open・末尾相対rangeを共通の半開区間へ正規化します。 | [Range utilities](./rangeutils.html) | `import atcoder/rangeutils` | `RangeType, IndexType, halfOpenEndpoints` |
| 有向グラフを強連結成分分解します。 | [SCC](./scc.html) | `import atcoder/scc` | `add_edge, scc` |
| モノイド $(S, \cdot: S \times S \to S, e \in S)$、つまり | [Segtree](./segtree.html) | `import atcoder/segtree` | `set, get, prod, all_prod, max_right` |
| 文字列アルゴリズム詰め合わせです。 文字列に関する様々なアルゴリズムが入っています。 | [String](./string.html) | `import atcoder/string` | `suffix_array, lcp_array, z_algorithm` |

#### Extra / データ構造

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| このページは自動生成された下書きです。 | [binary_tree_node_utils](./extra/structure/binary_tree_node_utils.html) | `import atcoder/extra/structure/binary_tree_node_utils` | `BinaryTreeNode, BinaryTree, greater_func, isLeaf, leftMost` |
| このページは自動生成された下書きです。 | [binary_tree_utils](./extra/structure/binary_tree_utils.html) | `import atcoder/extra/structure/binary_tree_utils` | `SomeSortedTree, SomeSortedSet, SomeSortedMap, SomeSortedMultiSet, SomeSortedMultiMap` |
| BinaryTrie は、整数を二進表記した bit 列として Trie に入れる data structure です。 | [BinaryTrie](./extra/structure/binary_trie.html) | `import atcoder/extra/structure/binary_trie` | `BinaryTrieNode, initBinaryTrie, empty, add, insert` |
| CartesianTree は、配列の index 順序を inorder traversal として保ちながら、値について heap 条件を満たす二分木です。 | [CartesianTree](./extra/structure/cartesian_tree.html) | `import atcoder/extra/structure/cartesian_tree` | `CartesianTree, initCartesianTree, initMinCartesianTree, initMaxCartesianTree, empty` |
| ConvexHullTrickAddMonotone は、傾きが単調に追加される一次関数集合に対して、指定した x における最小値または最大値を求める data struct… | [ConvexHullTrickAddMonotone](./extra/structure/convex_hull_trick_add_monotone.html) | `import atcoder/extra/structure/convex_hull_trick_add_monotone` | `ConvexHullTrickAddMonotone, initConvexHullTrickAddMonotone, empty, add, query` |
| DisjointSparseTable は、静的配列に対する結合的演算の区間積を O(1) で求める data structure です。 | [DisjointSparseTable](./extra/structure/disjoint_sparse_table.html) | `import atcoder/extra/structure/disjoint_sparse_table` | `DisjointSparseTable, initDisjointSparseTable, prod` |
| DualFenwickTree は、区間加算・一点取得を行う Fenwick Tree です。 | [DualFenwickTree](./extra/structure/dual_fenwicktree.html) | `import atcoder/extra/structure/dual_fenwicktree` | `DualFenwickTree, DualFenwickTreeType, getType, initDualFenwickTree, add` |
| FastSet は、整数 universe [0, n) 上の集合を階層化 bitset で管理する data structure です。 | [FastSet](./extra/structure/fast_set.html) | `import atcoder/extra/structure/fast_set` | `FastSet, initFastSet, empty, contains, insert` |
| このページは自動生成された下書きです。 | [generalized_slope_trick](./extra/structure/generalized_slope_trick.html) | `import atcoder/extra/structure/generalized_slope_trick` | `split_lower_bound, merge_wuh, insert_lower_bound, GeneralizedSlopeTrick, initGeneralizedSlopeTrick` |
| 乱択priorityを持つ暗黙Treapによって、動的な列を管理します。 | [Implicit Treap](./extra/structure/implicit_treap.html) | `import atcoder/extra/structure/implicit_treap` | `ImplicitTreapType, insert, erase, reverse, prod` |
| 固定された多次元点集合に対して、最近傍点探索と直交範囲探索を行います。 | [KD-tree](./extra/structure/kd_tree.html) | `import atcoder/extra/structure/kd_tree` | `nearest, rangeSearch, len` |
| LiChaoTree は、一次関数を追加し、指定した座標での最小値を求める data structure です。 | [LiChaoTree](./extra/structure/li_chao_tree.html) | `import atcoder/extra/structure/li_chao_tree` | `Line, initLine, over, initLiChaoTree, query` |
| このページは自動生成された下書きです。 | [link_cut_tree](./extra/structure/link_cut_tree.html) | `import atcoder/extra/structure/link_cut_tree` | `LinkCutTree, expose, link, cut, evert` |
| MexSet は、整数 multiset の mex を動的に管理します。 | [MexSet](./extra/structure/mex_set.html) | `import atcoder/extra/structure/mex_set` | `MexSet, initMexSet, empty, count, contains` |
| このページは自動生成された下書きです。 | [mo](./extra/structure/mo.html) | `import atcoder/extra/structure/mo` | `Mo, initMo, insert, run` |
| PartiallyPersistentDSU は、過去の時刻に対して連結判定・連結成分サイズ取得ができる Union-Find です。 | [PartiallyPersistentDSU](./extra/structure/partially_persistent_dsu.html) | `import atcoder/extra/structure/partially_persistent_dsu` | `PartiallyPersistentDSU, initPartiallyPersistentDSU, leader, merge, same` |
| 1個の木がすべてのノードを管理し、PersistentVersionが各時点の 根を表します。 | [Persistent Segment Tree（永続セグメント木）](./extra/structure/persistent_segment_tree.html) | `import atcoder/extra/structure/persistent_segment_tree` | `PersistentSegmentTreeNode, initPersistentSegmentTree, nodeCount, setValue, prod` |
| RadixHeap は、整数 key 用の優先度付き queue です。 | [RadixHeap](./extra/structure/radix_heap.html) | `import atcoder/extra/structure/radix_heap` | `RadixHeap, getbit, initRadixHeap, empty, pop` |
| > 使い方の概要と RedBlackTree / RBST / SplayTree の比較は Tree backends も参照してください。 | [randomized_binary_search_tree_with_parent](./extra/structure/randomized_binary_search_tree_with_parent.html) | `import atcoder/extra/structure/randomized_binary_search_tree_with_parent` | `RBSTNode, RBSTType, RandomizedBinarySearchTree, LazyRandomizedBinarySearchTree, SomeRBST` |
| このページは自動生成された下書きです。 | [range_chmin_chmax_add_range_sum](./extra/structure/range_chmin_chmax_add_range_sum.html) | `import atcoder/extra/structure/range_chmin_chmax_add_range_sum` | `RCCARS_S, initS, RangeChminChmaxAddRangeSum, Chmin, Chmax` |
| > 使い方の概要と RedBlackTree / RBST / SplayTree の比較は Tree backends も参照してください。 | [red_black_tree](./extra/structure/red_black_tree.html) | `import atcoder/extra/structure/red_black_tree` | `Color, getleaf, newNode, isRoot, write` |
| RollbackDSU は、merge 操作を巻き戻せる Union-Find です。 | [RollbackDSU](./extra/structure/rollback_dsu.html) | `import atcoder/extra/structure/rollback_dsu` | `undo` |
| CompressedSegTree2D は、登録済み二次元座標に対して点更新と半開矩形積を行う座標圧縮data structureです。 | [CompressedSegTree2D](./extra/structure/compressed_segtree_2d.html) | `import atcoder/extra/structure/compressed_segtree_2d` | `CompressedSegTree2D, initCompressedSegTree2D, set, combineAt, prod, allProd` |
| DenseFenwickTree2D は、固定された二次元格子上で点加算と半開矩形和を処理します。 | [DenseFenwickTree2D](./extra/structure/dense_fenwicktree_2d.html) | `import atcoder/extra/structure/dense_fenwicktree_2d` | `DenseFenwickTree2D, initDenseFenwickTree2D, width, height, add, prefixSum, sum, get, allSum` |
| SegTree2D compatibility APIは、従来constructor・add・inclusive Slice queryを維持します。 | [SegTree2D compatibility](./extra/structure/segtree_2d.html) | `import atcoder/extra/structure/segtree_2d` | `SegTree2D, initSegTree2D, add, prod` |
| > これは RBST backend による古い順序付き set / map 実装です。新規コードでは通常 sortedsetmap を推奨します。RBST 自体を直接使う場… | [set_map_by_randomized_binary_search_tree](./extra/structure/set_map_by_randomized_binary_search_tree.html) | `import atcoder/extra/structure/set_map_by_randomized_binary_search_tree` | `SortedMultiSet, SortedSet, SortedMultiMap, SortedMap, getType` |
| このページは自動生成された下書きです。 | [skew_heap](./extra/structure/skew_heap.html) | `import atcoder/extra/structure/skew_heap` | `initSkewHeap, propagate, merge, top, pop` |
| このページは自動生成された下書きです。 | [sliding_window_aggregation](./extra/structure/sliding_window_aggregation.html) | `import atcoder/extra/structure/sliding_window_aggregation` | `initSlidingWindowAggregation, empty, fold_all, pop` |
| このページは自動生成された下書きです。 | [slope_trick](./extra/structure/slope_trick.html) | `import atcoder/extra/structure/slope_trick` | `SlopeTrick, initSlopeTrick, push_R, top_R, pop_R` |
| SparseTable は、静的な列に対して区間集約を高速に行う data structure です。 | [SparseTable](./extra/structure/sparse_table.html) | `import atcoder/extra/structure/sparse_table` | `SparseTable, initSparseTable, prod` |
| > 使い方の概要と RedBlackTree / RBST / SplayTree の比較は Tree backends も参照してください。 | [splay_tree](./extra/structure/splay_tree.html) | `import atcoder/extra/structure/splay_tree` | `SplayTreeNode, SplayTreeType, SplayTree, SomeSplayTree, calc_op` |
| SqrtTree は、静的なモノイド列を再帰的に平方分割し、区間積 query を高速に処理する data structure です。 | [Sqrt Tree](./extra/structure/sqrt_tree.html) | `import atcoder/extra/structure/sqrt_tree` | `initSqrtTree, prod, allProd` |
| SuccinctIndexableDictionary は、bit 列に対して rank query を高速に処理するための data structure です。 | [SuccinctIndexableDictionary](./extra/structure/succinct_indexable_dictionary.html) | `import atcoder/extra/structure/succinct_indexable_dictionary` | `SuccinctIndexableDictionary, initSuccinctIndexableDictionary, rank` |
| このページは自動生成された下書きです。 | [trie](./extra/structure/trie.html) | `import atcoder/extra/structure/trie` | `TrieNode, initTrieNode, Trie, initTrie, update_direct` |
| Universal SegTree は、通常のセグメント木、遅延セグメント木、双対セグメント木、区間長依存の遅延セグメント木、SegTree Beats 風の構造を、共通の実… | [UniversalSegTree](./extra/structure/universal_segtree.html) | `import atcoder/extra/structure/universal_segtree` | `all_prod` |
| Monoid記述子からSegTree・LazySegTreeを構築し、作用型Fを値型Sより先に提示するActionMonoid facadeです。 | [Monoid SegTree facade](./extra/structure/monoid_segtree.html) | `import atcoder/extra/structure/monoid_segtree` | `useActionMonoid, initSegTree, initLazySegTree` |
| [Sorted Set / Map](extra/structure/sorted_set_map.html) | 常時利用可能な順序統計と、比較順での反復・直接iterator操作を備えた連想コンテナ |  |  |
| WaveletMatrix は、静的な整数列に対して、区間内の順位統計や出現回数を高速に求める data structure です。 | [WaveletMatrix](./extra/structure/wavelet_matrix.html) | `import atcoder/extra/structure/wavelet_matrix` | `CompressedWaveletMatrix` |
| WeightedUnionFind は、各頂点に potential を持たせる Union-Find です。 | [WeightedUnionFind](./extra/structure/weighted_union_find.html) | `import atcoder/extra/structure/weighted_union_find` | `WeightedUnionFind, initWeightedUnionFind, root, weight, unionSet` |
| 永続配列と同様に、=演算子で、ある時点でのDSUの状態を「コピー」してそれぞれ別のデータ構造として更新が可能です。 当然中身をすべてコピーしないため、高速です。 | [永続DSU](./extra/structure/persistent_dsu.html) | `import atcoder/extra/structure/persistent_dsu` | `merge, leader` |
| 通常の配列の機能と同様、=演算子で、ある時点での配列変数を「コピー」してそれぞれ別の配列として更新が可能です。 | [永続配列](./extra/structure/persistent_array.html) | `import atcoder/extra/structure/persistent_array` | `PersistentArrayNode, initPersistentArray` |

#### Extra / グラフ

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| 根付き木から必要な頂点と、それらのLCAだけを取り出して圧縮木を構築します。 | [Auxiliary Tree（Virtual Tree／仮想木）](./extra/graph/virtual_tree.html) | `import atcoder/extra/graph/virtual_tree` | `buildVirtualTree` |
| Boruvka は、各連結成分から出る最小辺を反復的に選んで最小全域木の重みを求めるための補助構造です。 | [Boruvka](./extra/graph/boruvka.html) | `import atcoder/extra/graph/boruvka` | `Boruvka, initBoruvka, find` |
| このページは自動生成された下書きです。 | [chromatic_number](./extra/graph/chromatic_number.html) | `import atcoder/extra/graph/chromatic_number` | `chromatic_number` |
| minimumSpanningTreeArborescence(es, V, start) は、有向 graph の最小全域有向木、つまり rooted directed M… | [Chu-Liu/Edmonds](./extra/graph/chu_liu_edmonds.html) | `import atcoder/extra/graph/chu_liu_edmonds` | `minimumSpanningTreeArborescence` |
| このページは自動生成された下書きです。 | [cycle_detection](./extra/graph/cycle_detection.html) | `import atcoder/extra/graph/cycle_detection` | `cycleDetection, cycleDetectionUndirected` |
| このページは自動生成された下書きです。 | [dijkstra_multi_dimensional](./extra/graph/dijkstra_multi_dimensional.html) | `import atcoder/extra/graph/dijkstra_multi_dimensional` | `TupleSeq, dijkstra` |
| このページは自動生成された下書きです。 | [dijkstra_result](./extra/graph/dijkstra_result.html) | `import atcoder/extra/graph/dijkstra_result` | `DijkstraResult, contains, prev, path` |
| DSUOnTree は、木の各頂点 v について「v の subtree に含まれる情報」を効率よく集計する technique です。 | [DSUOnTree](./extra/graph/dsu_on_tree.html) | `import atcoder/extra/graph/dsu_on_tree` | `DSUOnTree, initDSUOnTree, subtreeVertices, run, runDSUOnTree` |
| このページは自動生成された下書きです。 | [ear_decomposition](./extra/graph/ear_decomposition.html) | `import atcoder/extra/graph/ear_decomposition` | `ear_decomposition` |
| EulerTour は、木をDFSし、各subtreeをpreorder上の連続区間へ変換するutilityです。 | [Euler Tour](./extra/graph/euler_tour.html) | `import atcoder/extra/graph/euler_tour` | `initEulerTour, subtreeRange, subtreeSize, isAncestor, vertexAt` |
| このページは自動生成された下書きです。 | [eulerian_trail](./extra/graph/eulerian_trail.html) | `import atcoder/extra/graph/eulerian_trail` | `EulerianTrail, initEulerianTrail, get_edge, enumerate_eulerian_trail, enumerate_semi_eulerian_trail` |
| FunctionalGraph は、各頂点から出る辺がちょうど 1 本の有向グラフです。 | [FunctionalGraph / Doubling](./extra/graph/functional_graph.html) | `import atcoder/extra/graph/functional_graph` | `Doubling, initDoubling, jump, initFunctionalGraph, cycleInfo` |
| このページは自動生成された下書きです。 | [gabow_edmonds](./extra/graph/gabow_edmonds.html) | `import atcoder/extra/graph/gabow_edmonds` | `initGabowEdmonds, maxMatching` |
| このページは自動生成された下書きです。 | [graph_concept](./extra/graph/graph_concept.html) | `import atcoder/extra/graph/graph_concept` | `GraphC` |
| このページは自動生成された下書きです。 | [graph_template_directed_undirected](./extra/graph/graph_template_directed_undirected.html) | `import atcoder/extra/graph/graph_template_directed_undirected` | `initEdge, initUndirectedGraph, initDirectedGraph, addEdge` |
| このページは自動生成された下書きです。 | [graphviz](./extra/graph/graphviz.html) | `import atcoder/extra/graph/graphviz` | `graphviz` |
| このページは自動生成された下書きです。 | [kruskal](./extra/graph/kruskal.html) | `import atcoder/extra/graph/kruskal` | `kruskal` |
| このページは自動生成された下書きです。 | [lowlink](./extra/graph/lowlink.html) | `import atcoder/extra/graph/lowlink` | `LowLink` |
| このページは自動生成された下書きです。 | [maxflow_lowerbound](./extra/graph/maxflow_lowerbound.html) | `import atcoder/extra/graph/maxflow_lowerbound` | `MaxFlowLowerBound, initMaxFlowLowerBound, can_flow, max_flow` |
| このページは自動生成された下書きです。 | [maximum_independent_set](./extra/graph/maximum_independent_set.html) | `import atcoder/extra/graph/maximum_independent_set` | `maximum_independent_set` |
| このページは自動生成された下書きです。 | [mcf_costscaling](./extra/graph/mcf_costscaling.html) | `import atcoder/extra/graph/mcf_costscaling` | `MCFEdge, initMCFCostScaling, addEdge, addSupply, addDemand` |
| このページは自動生成された下書きです。 | [mincostflow_generalized](./extra/graph/mincostflow_generalized.html) | `import atcoder/extra/graph/mincostflow_generalized` | `GRAPHTYPE_POSITIVEEDGE, MCFEdge, MCFGraph, initMCFGraph, initMinCostFLow` |
| このページは自動生成された下書きです。 | [mincostflow_lowerbound](./extra/graph/mincostflow_lowerbound.html) | `import atcoder/extra/graph/mincostflow_lowerbound` | `MinCostFlowLowerBound, initMinCostFlowLowerBound, can_flow, max_flow, slope` |
| minimumArborescence(es, vertexCount, root) は、Chu–Liu/Edmonds 実装の機能名による別名です。 | [Minimum Arborescence](./extra/graph/minimum_arborescence.html) | `import atcoder/extra/graph/minimum_arborescence` | `minimumArborescence` |
| OfflineDynamicConnectivity は、辺の追加・削除があるグラフを offline に処理するための helper です。 | [OfflineDynamicConnectivity](./extra/graph/offline_dynamic_connectivity.html) | `import atcoder/extra/graph/offline_dynamic_connectivity` | `OfflineDCEdge, initOfflineDynamicConnectivity, addEdgeInterval, run, componentCounts` |
| このページは自動生成された下書きです。 | [prim](./extra/graph/prim.html) | `import atcoder/extra/graph/prim` | `prim` |
| dijkstraradixheap(g, s) は、Radix Heap を用いて非負整数重み graph の単一始点最短路を求めます。 | [Radix Heap Dijkstra](./extra/graph/dijkstra_radix_heap.html) | `import atcoder/extra/graph/dijkstra_radix_heap` | `dijkstra_radix_heap` |
| Rerooting DP は、木 DP をすべての頂点を root とした場合について高速に求める technique です。 | [Rerooting DP](./extra/graph/rerooting_dp.html) | `import atcoder/extra/graph/rerooting_dp` | `RerootingEdge, initRerootingGraph, addEdge, rerooting, rerootingDP` |
| StaticGraph は、辺を追加してから build() することで隣接リストを構築する graph です。 | [Static Graph](./extra/graph/static_graph.html) | `import atcoder/extra/graph/static_graph` | `addBiEdge, build` |
| このページは自動生成された下書きです。 | [topological_sort](./extra/graph/topological_sort.html) | `import atcoder/extra/graph/topological_sort` | `topologicalSort` |
| この module は、無向グラフに対する次の分解をまとめて提供します。 | [Undirected Graph Decomposition](./extra/graph/undirected_decomposition.html) | `import atcoder/extra/graph/undirected_decomposition` | `UndirectedEdge, initUndirectedGraph, edgeCount, addEdge, other` |
| このページは自動生成された下書きです。 | [visualizer](./extra/graph/visualizer.html) | `import atcoder/extra/graph/visualizer` | `visualize` |
| グラフを作成します。ノードの型を$U$, 重みの型を$T$としています。 | [グラフのテンプレート](./extra/graph/graph_template.html) | `import atcoder/extra/graph/graph_template` | `ADJTYPE_SEQ, initEdge, initGraph, addBiEdge, addEdge` |
| 重みが非負のグラフの単一始点最短距離を計算します。 | [ダイクストラ法](./extra/graph/dijkstra.html) | `import atcoder/extra/graph/dijkstra` | `DijkstraObj, dijkstra01, dijkstra` |
| 割当問題をハンガリアンで解きます | [ハンガリアン法](./extra/graph/hungarian.html) | `import atcoder/extra/graph/hungarian` | `hungarian` |
| 重みが任意のグラフの単一始点最短距離を計算します。 | [ベルマンフォード法](./extra/graph/bellman_ford.html) | `import atcoder/extra/graph/bellman_ford` | `BellmanFordResult, path, bellman_ford` |
| 重みが任意のグラフの全頂点間最短距離を計算します。 | [ワーシャル・フロイト法](./extra/graph/warshall_floyd.html) | `import atcoder/extra/graph/warshall_floyd` | `WarshallFloydResult, warshallFloyd, path` |
| Hopcroft-Karp法によって二部グラフの最大マッチングを求めます。 | [二部グラフの最大マッチング・最小頂点被覆](./extra/graph/hopcroft_karp.html) | `import atcoder/extra/graph/hopcroft_karp` | `HopcroftKarp, initHopcroftKarp, maximum_matching, minimum_vertex_cover, maximum_stable_set` |
| 二部多重グラフの各辺を、同じ頂点に接続する辺同士が異なる色になるように 彩色します。使用する色数は最大次数 Δ であり、最適です。 | [二部グラフ辺彩色](./extra/graph/bipartite_edge_coloring.html) | `import atcoder/extra/graph/bipartite_edge_coloring` | `bipartiteEdgeColoring` |
| 橋のない無向グラフ$G$とその辺のリスト$es$が与えられたときに、$G$を強連結有向グラフとなるような$es$の向きを返す。 | [強連結な向き付け](./extra/graph/strong_orientation.html) | `import atcoder/extra/graph/strong_orientation` | `strong_orienation` |
| 下限・上限付き有向辺、各頂点の供給量・需要量、および辺費用を持つ 最小費用B-flow問題を解きます。 | [最小費用B-flow](./extra/graph/bflow.html) | `import atcoder/extra/graph/bflow` | `BFlow, initBFlow, add_supply, add_demand, solve` |

#### Extra / 木

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| このページは自動生成された下書きです。 | [centroid_decomposition](./extra/tree/centroid_decomposition.html) | `import atcoder/extra/tree/centroid_decomposition` | `centroidDecomposition` |
| このページは自動生成された下書きです。 | [doubling_lowest_common_ancestor](./extra/tree/doubling_lowest_common_ancestor.html) | `import atcoder/extra/tree/doubling_lowest_common_ancestor` | `DoublingLowestCommonAncestor, initDoublingLowestCommonAncestor, ancestor, lca, dist` |
| このページは自動生成された下書きです。 | [heavy_light_decomposition](./extra/tree/heavy_light_decomposition.html) | `import atcoder/extra/tree/heavy_light_decomposition` | `initHeavyLightDecomposition, la, lca, dist, query` |
| このページは自動生成された下書きです。 | [tree_diameter](./extra/tree/tree_diameter.html) | `import atcoder/extra/tree/tree_diameter` | `treeDiameter, centroid` |
| 木に対して、全方位木DPを行います。全方位DPについては例えばhttps://algo-logic.info/tree-dp/をご覧ください。 | [全方位木DP](./extra/tree/rerooting.html) | `import atcoder/extra/tree/rerooting` | `ReRooting, initReRootingImpl, initReRooting, add_bi_edge, dfs1` |

#### Extra / 数学

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| ArbitraryModBinomial は、任意 mod で二項係数 n choose k を計算するための構造です。 | [Arbitrary Mod Combination](./extra/math/arbitrary_mod_combination.html) | `import atcoder/extra/math/arbitrary_mod_combination` | `initArbitraryModBinomial, C` |
| このページは自動生成された下書きです。 | [arbitrary_mod_convolution](./extra/math/arbitrary_mod_convolution.html) | `import atcoder/extra/math/arbitrary_mod_convolution` | `ArbitraryModConvolution, ArbitraryModFFTElem, setLen, fft, inplace_partial_dot` |
| 有限列のprefixから、そのprefixを生成する最短の線形漸化式を求めます。 | [Berlekamp–Massey（線形漸化式の推定）](./extra/math/berlekamp_massey.html) | `import atcoder/extra/math/berlekamp_massey` | `berlekampMassey` |
| このページは自動生成された下書きです。 | [bigint](./extra/math/bigint.html) | `import atcoder/extra/math/bigint` | `bigint, initbigint, toBigInt, size, inner_mul_fft` |
| このページは自動生成された下書きです。 | [bitwise_convolution](./extra/math/bitwise_convolution.html) | `import atcoder/extra/math/bitwise_convolution` | `AndConvolution, OrConvolution` |
| このページは自動生成された下書きです。 | [characteristic_polynomial](./extra/math/characteristic_polynomial.html) | `import atcoder/extra/math/characteristic_polynomial` | `characteristicPolynomial` |
| このページは自動生成された下書きです。 | [chirp_z](./extra/math/chirp_z.html) | `import atcoder/extra/math/chirp_z` | `ChirpZ` |
| このページは自動生成された下書きです。 | [coef_of_generating_function](./extra/math/coef_of_generating_function.html) | `import atcoder/extra/math/coef_of_generating_function` | `RationalFormalPowerSeries` |
| combinationtable は、二項係数や階乗を必要に応じて遅延構築する小さな補助 module です。 | [Combination Table](./extra/math/combination_table.html) | `import atcoder/extra/math/combination_table` | `C, H, P, fact, resetCombination` |
| このページは自動生成された下書きです。 | [composition](./extra/math/composition.html) | `import atcoder/extra/math/composition` | `composition` |
| このページは自動生成された下書きです。 | [composition_kinoshita_li](./extra/math/composition_kinoshita_li.html) | `import atcoder/extra/math/composition_kinoshita_li` | `composition` |
| toSeq と toInt は、整数と基数 b 表現の digit 列を相互変換します。 | [Convert Base](./extra/math/convert_base.html) | `import atcoder/extra/math/convert_base` | `toInt, toSeq` |
| このページは自動生成された下書きです。 | [convolution_int128](./extra/math/convolution_int128.html) | `import atcoder/extra/math/convolution_int128` | `convolution_int128` |
| このページは自動生成された下書きです。 | [convolution_universal](./extra/math/convolution_universal.html) | `import atcoder/extra/math/convolution_universal` | `fft_info, initFFTInfo, butterfly, butterfly_inv, convolution_naive` |
| このページは自動生成された下書きです。 | [estimate_modint_frac](./extra/math/estimate_modint_frac.html) | `import atcoder/extra/math/estimate_modint_frac` | `estimate` |
| 集合冪級数fの指数関数を計算します。 | [Exp of Set Power Series（集合冪級数の指数関数）](./extra/math/exp_of_set_power_series.html) | `import atcoder/extra/math/exp_of_set_power_series` | `expOfSetPowerSeries` |
| factorialModInt は、modint 上で n! を求めます。 | [Factorial](./extra/math/factorial.html) | `import atcoder/extra/math/factorial` | `factorial` |
| このページは自動生成された下書きです。 | [fft](./extra/math/fft.html) | `import atcoder/extra/math/fft` | `initComplex, conj, initSeqComplex, setLen, swap` |
| このページは自動生成された下書きです。 | [fft2d](./extra/math/fft2d.html) | `import atcoder/extra/math/fft2d` | `fft2d, ifft2d, multiply2d_naive, multiply2d_partially_naive, multiply2d` |
| floorsumsquare(n, m, a, b) は、次の 3 つの和を同時に求めます。 | [Floor Sum Square](./extra/math/floor_sum_square.html) | `import atcoder/extra/math/floor_sum_square` | `floor_sum_square` |
| このページは自動生成された下書きです。 | [floor_sum_general](./extra/math/floor_sum_general.html) | `import atcoder/extra/math/floor_sum_general` | `monoid_pow, floor_monoid_product, MonoidForFloorSum, op, unit` |
| このページは自動生成された下書きです。 | [formal_power_series_differential_equation](./extra/math/formal_power_series_differential_equation.html) | `import atcoder/extra/math/formal_power_series_differential_equation` | `DifferentialEquation` |
| このページは自動生成された下書きです。 | [formal_power_series_sqrt](./extra/math/formal_power_series_sqrt.html) | `import atcoder/extra/math/formal_power_series_sqrt` | `sqrt` |
| atcoder/extra/math/fps は、modint 係数の形式的べき級数を短く書くための convenience facade です。 | [FPS facade](./extra/math/fps.html) | `import atcoder/extra/math/fps` | `useFPSPrecTemplate, F, useFPS, useFPSDecl` |
| このページは自動生成された下書きです。 | [gaussian_elimination_bit](./extra/math/gaussian_elimination_bit.html) | `import atcoder/extra/math/gaussian_elimination_bit` | `base` |
| このページは自動生成された下書きです。 | [int128](./extra/math/int128.html) | `import atcoder/extra/math/int128` | `Int128, Uint128, to_Int128, to_Uint128, to_int` |
| このページは自動生成された下書きです。 | [int128 (numeric)](./extra/numeric/int128.html) | `import atcoder/extra/numeric/int128` | `Int128, Uint128, to_Int128, to_Uint128, to_int` |
| このページは自動生成された下書きです。 | [int256 (numeric)](./extra/numeric/int256.html) | `import atcoder/extra/numeric/int256` | `UInt256, Int256, parseUInt256, parseInt256` |
| このページは自動生成された下書きです。 | [kitamasa](./extra/math/kitamasa.html) | `import atcoder/extra/math/kitamasa` | `kitamasa` |
| このページは自動生成された下書きです。 | [lagrange_polynomial](./extra/math/lagrange_polynomial.html) | `import atcoder/extra/math/lagrange_polynomial` | `lagrange_polynomial` |
| このページは自動生成された下書きです。 | [matrix](./extra/math/matrix.html) | `import atcoder/extra/math/matrix` | `StaticMatrix, DynamicMatrix, DynamicVector, StaticMatrixObj, StaticVector` |
| modSqrt(a) は、modint 上で x^2 = a を満たす x をひとつ求めます。 | [Mod Sqrt](./extra/math/mod_sqrt.html) | `import atcoder/extra/math/mod_sqrt` | `modSqrt` |
| このページは自動生成された下書きです。 | [modint61](./extra/math/modint61.html) | `import atcoder/extra/math/modint61` | `modint61, getMod, inv, pow` |
| このページは自動生成された下書きです。 | [modint_asm](./extra/math/modint_asm.html) | `import atcoder/extra/math/modint_asm` | `ModInt, initModInt, declareModInt, DMint, setModSub` |
| このページは自動生成された下書きです。 | [modint_montgomery](./extra/math/modint_montgomery.html) | `import atcoder/extra/math/modint_montgomery` | `StaticLazyMontgomeryModInt, DynamicLazyMontgomeryModInt, isStaticModInt, isDynamicModInt, isStatic` |
| このページは自動生成された下書きです。 | [multipoint_evaluation](./extra/math/multipoint_evaluation.html) | `import atcoder/extra/math/multipoint_evaluation` | `multipointEvaluation` |
| このページは自動生成された下書きです。 | [multipoint_evaluation_slow](./extra/math/multipoint_evaluation_slow.html) | `import atcoder/extra/math/multipoint_evaluation_slow` | `initProductTree, multipointEvaluationImpl, multipointEvaluation` |
| このページは自動生成された下書きです。 | [newton_method](./extra/math/newton_method.html) | `import atcoder/extra/math/newton_method` | `newtonMethod` |
| このページは自動生成された下書きです。 | [ntt](./extra/math/ntt.html) | `import atcoder/extra/math/ntt` | `get_fft_type, fft, ifft, dot, inplace_partial_dot` |
| このページは自動生成された下書きです。 | [ntt_quadratic_field](./extra/math/ntt_quadratic_field.html) | `import atcoder/extra/math/ntt_quadratic_field` | `inplace_fft, fft, inplace_ifft, ifft, dot` |
| このページは自動生成された下書きです。 | [particular_mod_convolution](./extra/math/particular_mod_convolution.html) | `import atcoder/extra/math/particular_mod_convolution` | `ParticularModConvolution, fft, inplace_fft, inplace_partial_dot, dot` |
| このページは自動生成された下書きです。 | [polynomial](./extra/math/polynomial.html) | `import atcoder/extra/math/polynomial` | `poly, eval, integral` |
| 相異なる点 (xs[i], ys[i]) をすべて通る、次数が xs.len 未満の 一意な多項式を構成します。 | [Polynomial Interpolation（多項式補間）](./extra/math/polynomial_interpolation.html) | `import atcoder/extra/math/polynomial_interpolation` | `polynomialInterpolation` |
| このページは自動生成された下書きです。 | [polynomial_taylor_shift](./extra/math/polynomial_taylor_shift.html) | `import atcoder/extra/math/polynomial_taylor_shift` | `taylor_shift` |
| このページは自動生成された下書きです。 | [power_projection](./extra/math/power_projection.html) | `import atcoder/extra/math/power_projection` | `power_projection` |
| このページは自動生成された下書きです。 | [quadratic_field](./extra/math/quadratic_field.html) | `import atcoder/extra/math/quadratic_field` | `QF, inv, pow, get_pow2_root` |
| このページは自動生成された下書きです。 | [rational_approximation](./extra/math/rational_approximation.html) | `import atcoder/extra/math/rational_approximation` | `rational_approximation` |
| このページは自動生成された下書きです。 | [simplex](./extra/math/simplex.html) | `import atcoder/extra/math/simplex` | `TwoStageSimplexResult, twoStageSimplex` |
| このページは自動生成された下書きです。 | [sqrt_int](./extra/math/sqrt_int.html) | `import atcoder/extra/math/sqrt_int` | `sqrt_int` |
| このページは自動生成された下書きです。 | [static_eratosthenes](./extra/math/static_eratosthenes.html) | `import atcoder/extra/math/static_eratosthenes` | `Eratosthenes, initEratosthenes, isPrime, primeDivisor, factor` |
| このページは自動生成された下書きです。 | [subproduct_tree](./extra/math/subproduct_tree.html) | `import atcoder/extra/math/subproduct_tree` | `subproduct_tree` |
| 集合関数f, gの部分集合畳み込みを計算します。 | [Subset Convolution（部分集合畳み込み）](./extra/math/subset_convolution.html) | `import atcoder/extra/math/subset_convolution` | `subsetConvolution` |
| XorBasis は、整数集合から XOR で作れる値の集合を「線形基底」として管理する data structure です。 | [XorBasis](./extra/math/xor_basis.html) | `import atcoder/extra/math/xor_basis` | `merge` |
| このページは自動生成された下書きです。 | [zeta_transform](./extra/math/zeta_transform.html) | `import atcoder/extra/math/zeta_transform` | `zeta_transform, movius_transform, zeta_superset, movius_superset, zeta_subset` |
| エラトステネス法で素数を列挙したり、与えられた整数を素因数分解したり約数を列挙したりします。 | [エラトステネス法](./extra/math/eratosthenes.html) | `import atcoder/extra/math/eratosthenes` | `Eratosthenes, initEratosthenes, isPrime, primeDivisor, factor` |
| 形式的べき級数を扱うライブラリです。加減乗除や逆元、exp, logなどが計算できます。 形式的べき級数についてはhttps://trap.jp/post/1657/を参照し… | [形式的べき級数ライブラリ](./extra/math/formal_power_series.html) | `import atcoder/extra/math/formal_power_series` | `FormalPowerSeries, Poly, FPS, toStr, hasFFTC` |
| 約数を列挙したりします。基本$O(\sqrt n)$の計算量がかかります。 扱う整数$n$が100万程度と小さく、$O(n)$の計算量と空間をかけていいのであれば、エラトステ… | [約数列挙](./extra/math/divisor.html) | `import atcoder/extra/math/divisor` | `divisor, prime_factorization` |
| pollardrho法による素因数分解を行います。 $O(\sqrt n)$でも間に合わない大きな数を分解しない限りは遅いと思われるので、エラトステネス法等のアルゴリズムを用… | [素因数分解](./extra/math/factorization.html) | `import atcoder/extra/math/factorization` | `isPrime, factor` |
| これ一つで階乗、階乗の逆元、ならし$O(1)$の逆元、組み合わせ($nCr$, $nPr$, $nHr$)のすべてが求められるライブラリです。 配列の確保更新は倍々に自動で行… | [組み合わせライブラリ](./extra/math/combination.html) | `import atcoder/extra/math/combination` | `Combination, CombinationC, zero, fact, rfact` |
| 空集合の係数が 1 である集合冪級数の対数を計算します。 | [集合冪級数の対数](./extra/math/log_of_set_power_series.html) | `import atcoder/extra/math/log_of_set_power_series` | `logOfSetPowerSeries` |
| 凸列と任意列のmin-plus convolutionを計算します。 | [Min-Plus Convolution](./extra/math/min_plus_convolution.html) | `import atcoder/extra/math/min_plus_convolution` | `minPlusConvolutionConvexArbitrary` |

#### Extra / DP

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| CumulativeSum は、点加算と区間和取得を行うための一次元累積和です。 | [Cumulative Sum](./extra/dp/cumulative_sum.html) | `import atcoder/extra/dp/cumulative_sum` | `initCumulativeSum, add, sum` |
| CumulativeSum2D は、二次元配列の矩形和を求めるための二次元累積和です。 | [Cumulative Sum 2D](./extra/dp/cumulative_sum_2d.html) | `import atcoder/extra/dp/cumulative_sum_2d` | `initCumulativeSum2D, add, build` |
| DualCumulativeSum は、区間加算・一点取得を行うための一次元 imos 構造です。 | [Dual Cumulative Sum](./extra/dp/dual_cumulative_sum.html) | `import atcoder/extra/dp/dual_cumulative_sum` | `initDualCumulativeSum, add` |
| DualCumulativeSum2D は、矩形加算後に各点の値を取得します。 | [Dual Cumulative Sum 2D](./extra/dp/dual_cumulative_sum_2d.html) | `import atcoder/extra/dp/dual_cumulative_sum_2d` | `initDualCumulativeSum2D, add, build, get` |
| editDistance(S, T) は、文字列 S を T に変換するための編集距離を求めます。 | [Edit Distance](./extra/dp/edit_distance.html) | `import atcoder/extra/dp/edit_distance` | `editDistance` |
| largestRectangle(height) は、histogram に含まれる最大長方形の面積を求めます。 | [Largest Rectangle](./extra/dp/largest_rectangle.html) | `import atcoder/extra/dp/largest_rectangle` | `largestRectangle` |
| longestIncreasingSubsequence は、最長増加部分列、LIS を求めます。 | [Longest Increasing Subsequence](./extra/dp/longest_increasing_subsequence.html) | `import atcoder/extra/dp/longest_increasing_subsequence` | `longestIncreasingSubsequence` |
| 各行の最小値を取る列が単調非減少になる行列について、各行の最小列を分割統治で求めます。 | [Monotone Minima](./extra/dp/monotone_minima.html) | `import atcoder/extra/dp/monotone_minima` | `monotoneMinima, divideAndConquerOptimization, divideAndConquerDpLayer` |
| slideMin は、長さ k の sliding window minimum を求めます。 slideMax は sliding window maximum を求めます。 | [Slide Min / Slide Max](./extra/dp/slide_min.html) | `import atcoder/extra/dp/slide_min` | `slideMin, slideMax` |
| totally monotoneな暗黙行列について、各行の最小要素の列を求めます。 | [SMAWK](./extra/dp/smawk.html) | `import atcoder/extra/dp/smawk` | `smawk` |
| Monotone Minimaを分割統治DP最適化の名前で利用します。 | [Divide-and-Conquer Optimization](./extra/dp/divide_and_conquer_optimization.html) | `import atcoder/extra/dp/divide_and_conquer_optimization` | `monotoneMinima`, `divideAndConquerOptimization`, `divideAndConquerDpLayer` |

#### Extra / 文字列

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| Aho-Corasick は、複数の pattern 文字列をまとめて検索するためのアルゴリズムです。 | [Aho-Corasick](./extra/string/aho_corasick.html) | `import atcoder/extra/string/aho_corasick` | `AhoCorasickNode, initAhoCorasick, addPattern, patternCount, nextState` |
| KMP は、pattern を text 内から線形時間で検索するアルゴリズムです。 | [KMP / Prefix Function](./extra/string/kmp.html) | `import atcoder/extra/string/kmp` | `KMPMatcher, prefixFunction, initKMP, findAll, findFirst` |
| このページは自動生成された下書きです。 | [knuth_morris_pratt](./extra/string/knuth_morris_pratt.html) | `import atcoder/extra/string/knuth_morris_pratt` | `KnuthMorrisPratt` |
| Manacher は、文字列中のすべての回文半径を線形時間で求めるアルゴリズムです。 | [Manacher](./extra/string/manacher.html) | `import atcoder/extra/string/manacher` | `Manacher, manacherOdd, manacherEven, palindromeRadii, initManacher` |
| Minimum Rotation は、文字列または sequence の巡回 shift のうち、辞書順最小のものを線形時間で求めます。 | [Minimum Rotation / Booth](./extra/string/minimum_rotation.html) | `import atcoder/extra/string/minimum_rotation` | `minimumRotationIndex, minimalRotationIndex, maximumRotationIndex, rotated, minimumRotation` |
| PalindromicTree は、文字列に含まれる異なる回文 substring を状態として管理する data structure です。Eertree とも呼ばれます。 | [PalindromicTree / Eertree](./extra/string/palindromic_tree.html) | `import atcoder/extra/string/palindromic_tree` | `PalindromicTreeNode, initPalindromicTree, add, buildOccurrences, distinctPalindromeCount` |
| このページは自動生成された下書きです。 | [rolling_hash](./extra/string/rolling_hash.html) | `import atcoder/extra/string/rolling_hash` | `MASK, RH_Base, multRaw, calcMod, hash` |
| このページは自動生成された下書きです。 | [run_enumerate](./extra/string/run_enumerate.html) | `import atcoder/extra/string/run_enumerate` | `reversed, RunEnumerate` |
| このページは自動生成された下書きです。 | [run_length_compress](./extra/string/run_length_compress.html) | `import atcoder/extra/string/run_length_compress` | `encode, decode` |
| このページは自動生成された下書きです。 | [suffix_array_utils](./extra/string/suffix_array_utils.html) | `import atcoder/extra/string/suffix_array_utils` | `lt_substr, initSuffixArray, size, lowerBound, lowerUpperBound` |
| SuffixAutomaton は、1つの文字列に含まれるすべての substring を受理する最小 DFA です。 | [SuffixAutomaton](./extra/string/suffix_automaton.html) | `import atcoder/extra/string/suffix_automaton` | `SuffixAutomatonState, initSuffixAutomaton, extend, add, buildOccurrences` |

#### Extra / 幾何

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| closestpair(ps) は、二次元点集合の最近点対距離を求めます。 | [Closest Pair](./extra/geometry/closest_pair.html) | `import atcoder/extra/geometry/closest_pair` | `inplace_merge, closest_pair` |
| atcoder/extra/geometry/geometry は、二次元幾何 library を使いやすくするための facade module です。 | [Geometry](./extra/geometry/geometry.html) | `import atcoder/extra/geometry/geometry` | `Point2, point, line, segment, circle` |
| geometrytemplate は、二次元幾何で使う基本型と基本関数を提供します。 | [Geometry Template](./extra/geometry/geometry_template.html) | `import atcoder/extra/geometry/geometry_template` | `Point, Circle, ccw` |
| 2つの点集合の凸包についてMinkowski和を計算します。 | [Minkowski Sum](./extra/geometry/minkowski_sum.html) | `import atcoder/extra/geometry/minkowski_sum` | `minkowskiSum` |
| polygon は、二次元 polygon に対する基本操作を提供します。 | [Polygon](./extra/geometry/polygon.html) | `import atcoder/extra/geometry/polygon` | `Polygon, isConvex, convexHull, convex_cut, convex_diameter` |
| このページは自動生成された下書きです。 | [segment_graph](./extra/geometry/segment_graph.html) | `import atcoder/extra/geometry/segment_graph` | `merge_segments, segment_arrangement` |
| tangent は、円に対する接線を求める module です。 | [Tangent](./extra/geometry/tangent.html) | `import atcoder/extra/geometry/tangent` | `tangent` |
| triangle は三角形の代表的な中心や円を求める module です。 | [Triangle](./extra/geometry/triangle.html) | `import atcoder/extra/geometry/triangle` | `centroid, incircle, incenter, excircle, excenter` |
| このページは自動生成された下書きです。 | [visualizer](./extra/geometry/visualizer.html) | `import atcoder/extra/geometry/visualizer` | `initCanvas, add, show` |
| 二次元点集合を含む最小半径の円を求めます。 | [Minimum Enclosing Circle（最小包含円）](./extra/geometry/minimum_enclosing_circle.html) | `import atcoder/extra/geometry/minimum_enclosing_circle` | `minimumEnclosingCircle` |

#### Extra / Monoid

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| MonoidType は、型 E、二項演算 op、単位元 e から monoid 型を作るための helper です。 | [monoid](./extra/monoid/monoid.html) | `import atcoder/extra/monoid/monoid` | `Monoid, InversibleMonoid, ActedMonoid, MonoidBase, MonoidType` |

#### Extra / アルゴリズム

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| 座標圧縮は、大きい値や飛び飛びの値を、大小関係を保ったまま 0, 1, ..., k-1 に置き換える technique です。 | [Coordinate Compression](./extra/algorithm/coordinate_compression.html) | `import atcoder/extra/algorithm/coordinate_compression` | `CoordinateCompression, initCoordinateCompression, empty, lowerBoundIndex, upperBoundIndex` |
| Mo は、静的配列に対する多数の offline 区間 query を、区間端点の移動回数が少なくなる順序に並べ替える technique です。 | [Mo's Algorithm](./extra/algorithm/mo.html) | `import atcoder/extra/algorithm/mo` | `MoQuery, initMo, addQuery, orderedQueries, run` |
| Run-Length Encoding, RLE は、連続する同じ値を | [Run-Length Encoding](./extra/algorithm/run_length_encoding.html) | `import atcoder/extra/algorithm/run_length_encoding` | `Run, runLengthEncode, rle, runLengthDecode, runLengthDecodeString` |

#### Extra / その他

| 用途 | ドキュメント | import方法 | 主なAPI |
|---|---|---|---|
| 旧iterator名、nth_element、集合utilityを提供する互換moduleです。新規列挙コードではItertoolsを推奨します。 | [Algorithm utilities](./extra/other/algorithmutils.html) | `import atcoder/extra/other/algorithmutils` | `permutation, combination, nth_element, setUnion` |
| permutation・combination・直積を遅延列挙し、Cartesian power構文も提供します。 | [Itertools](./extra/other/itertools.html) | `import atcoder/extra/other/itertools` | `permutations, combinations, product, cartesianProduct, cartesianPower, ^` |
| このページは自動生成された下書きです。 | [assignment_operator](./extra/other/assignment_operator.html) | `import atcoder/extra/other/assignment_operator` | `generateAssignmentOperator` |
| このページは自動生成された下書きです。 | [binary_search](./extra/other/binary_search.html) | `import atcoder/extra/other/binary_search` | `minLeft, maxRight` |
| このページは自動生成された下書きです。 | [binary_search_float](./extra/other/binary_search_float.html) | `import atcoder/extra/other/binary_search_float` | `minLeft, maxRight` |
| 固定長・可変長の密な bit 列を、64 bit word 列で管理します。 | [Dense BitSet](./extra/structure/dense_bitset.html) | `import atcoder/extra/structure/dense_bitset` | `BitSet, DynamicBitSet, initBitSet, initFullBitSet, initDynamicBitSet` |
| 整数型の bit mask 構築・変換・列挙を提供します。 | [Bitmask](./extra/bit/bitmask.html) | `import atcoder/extra/bit/bitmask` | `maskFromBitIndices, bitIndices, lowBitsMask, submasks, subsetMasks` |
| このページは自動生成された下書きです。 | [cfor](./extra/other/cfor.html) | `import atcoder/extra/other/cfor` | `For, cfor` |
| このページは自動生成された下書きです。 | [compress](./extra/other/compress.html) | `import atcoder/extra/other/compress` | `initCompress, id, val` |
| このページは自動生成された下書きです。 | [copy_proc](./extra/other/copy_proc.html) | `import atcoder/extra/other/copy_proc` | `copyProc0, copyProc1, copyProc2, copyProc3` |
| このページは自動生成された下書きです。 | [debug](./extra/other/debug.html) | `import atcoder/extra/other/debug` | `debugImpl, debug` |
| このページは自動生成された下書きです。 | [decimal](./extra/other/decimal.html) | `import atcoder/extra/other/decimal` | `calcPi, exp, initPrec, sin_impl, sin` |
| このページは自動生成された下書きです。 | [decimal_gmp](./extra/other/decimal_gmp.html) | `import atcoder/extra/other/decimal_gmp` | `Decimal, setPrec, finalizeDecimal, clone, newDecimal` |
| このページは自動生成された下書きです。 | [decimal_mp](./extra/other/decimal_mp.html) | `import atcoder/extra/other/decimal_mp` | `toDecimal, calcPi, initPrec, sin_impl, sin` |
| このページは自動生成された下書きです。 | [decimal_mpfr](./extra/other/decimal_mpfr.html) | `import atcoder/extra/other/decimal_mpfr` | `mpfr_init2, mpfr_clear, mpfr_free_cache, mpfr_set_prec, mpfr_get_emin` |
| このページは自動生成された下書きです。 | [dice](./extra/other/dice.html) | `import atcoder/extra/other/dice` | `FACE, dice, initDice, roll, roll_x` |
| このページは自動生成された下書きです。 | [direction](./extra/other/direction.html) | `import atcoder/extra/other/direction` | `neighbor` |
| このページは自動生成された下書きです。 | [divutils](./extra/other/divutils.html) | `import atcoder/extra/other/divutils` | `ceilDiv, ceilMod` |
| このページは自動生成された下書きです。 | [floatutils](./extra/other/floatutils.html) | `import atcoder/extra/other/floatutils` | `getParameters, floatConverter, float64Converter, float32Converter, getPi` |
| このページは自動生成された下書きです。 | [fold](./extra/other/fold.html) | `import atcoder/extra/other/fold` | `fold_associative, fold_staircase_sum` |
| このページは自動生成された下書きです。 | [format_expression](./extra/other/format_expression.html) | `import atcoder/extra/other/format_expression` | `formatExpression` |
| このページは自動生成された下書きです。 | [inf](./extra/other/inf.html) | `import atcoder/extra/other/inf` | `inf, infRepr, isInf` |
| このページは自動生成された下書きです。 | [interactive](./extra/other/interactive.html) | `import atcoder/extra/other/interactive` | `solveInteractive` |
| このページは自動生成された下書きです。 | [listutils](./extra/other/listutils.html) | `import atcoder/extra/other/listutils` | `split, merge` |
| このページは自動生成された下書きです。 | [operator](./extra/other/operator.html) | `import atcoder/extra/other/operator` | `getOperator, OperatorType, zero, unit, add` |
| このページは自動生成された下書きです。 | [random_tree](./extra/other/random_tree.html) | `import atcoder/extra/other/random_tree` | `pruefer_decode, random_tree, enumerate_tree` |
| このページは自動生成された下書きです。 | [reader](./extra/other/reader.html) | `import atcoder/extra/other/reader` | `nextString, nextInt, nextFloat, toStr, print0` |
| このページは自動生成された下書きです。 | [reference](./extra/other/reference.html) | `import atcoder/extra/other/reference` | `byaddr` |
| このページは自動生成された下書きです。 | [return_type](./extra/other/return_type.html) | `import atcoder/extra/other/return_type` | `ReturnType` |
| このページは自動生成された下書きです。 | [seq_array_utils](./extra/other/seq_array_utils.html) | `import atcoder/extra/other/seq_array_utils` | `fill, makeSeq, makeArray` |
| このページは自動生成された下書きです。 | [shadowing](./extra/other/shadowing.html) | `import atcoder/extra/other/shadowing` | `shadow` |
| Sliceの逆順・step列挙、部分取得とstep付き代入を提供します。 | [Slice utilities](./extra/other/sliceutils.html) | `import atcoder/extra/other/sliceutils` | `index, rev, items, >>, <<, low, high` |
| このページは自動生成された下書きです。 | [solve_proc](./extra/other/solve_proc.html) | `import atcoder/extra/other/solve_proc` | `compare_answer_string, solveProc, procName` |
| このページは自動生成された下書きです。 | [special_judge](./extra/other/special_judge.html) | `import atcoder/extra/other/special_judge` | `echo, check` |
| このページは自動生成された下書きです。 | [static_var](./extra/other/static_var.html) | `import atcoder/extra/other/static_var` | `staticVar` |
| このページは自動生成された下書きです。 | [uncompress](./extra/other/uncompress.html) | `import atcoder/extra/other/uncompress` | `Uint, inflate, inflateEnd, inflateInit2u, uncompress` |
| このページは自動生成された下書きです。 | [warlus_operator](./extra/other/warlus_operator.html) | `import atcoder/extra/other/warlus_operator` | `discardableId` |
| このページは自動生成された下書きです。 | [zip](./extra/other/zip.html) | `import atcoder/extra/other/zip` | `zip, unzip` |

### ガイド

- [AtCoderレベル別ガイド](./guide/atcoder_level_guide.html)
- [AtCoderアルゴリズム講座カバレッジ](./guide/atcoder_algorithm_lectures_coverage.html)

### ドキュメントの構成

公開APIのページは原則として、次の順序で記載します。

1. 型付きの完全なsignature
2. 引数名・型・意味
3. 返り値の型・意味
4. 制約
5. 計算量
6. 使用例

<!-- NIM_ACL_HOME_NAV_END -->

## ガイド

- [AtCoder 色別ライブラリガイド](./guide/atcoder_level_guide.html)
- [AtCoder Algorithm Lectures 対応表](./guide/atcoder_algorithm_lectures_coverage.html)

## インストール方法

- zipファイルを解凍すると、`ac-library`フォルダ, そしてその中に`atcoder`フォルダが入っているはずです。
- g++を使っている場合, `atcoder`フォルダを`main.nim`と同じ場所に置いて、`nim cpp main.nim --include:.`でコンパイルできます。  
- 詳しくは [Appendix](./appendix.html) を参照してください。

## お約束

- 制約外の入力を入れたときの挙動はすべて未定義です。
- このドキュメントでは長い型を便宜上短く書きます
  - `unsigned int` → `uint`
  - `long long` → `ll`
  - `unsigned long long` → `ull`
- $0^0$ は $1$ です
- 明記されていない場合、多重辺や自己ループも入力可能です。

## リスト

`import atcoder/all` : 一括include

### データ構造

- [`import atcoder/fenwicktree`](./fenwicktree.html)
- [`import atcoder/segtree`](./segtree.html)
- [`import atcoder/lazysegtree`](./lazysegtree.html)
- [`import atcoder/string`](./string.html)

### 数学

- [`import atcoder/math`](./math.html)
- [`import atcoder/convolution`](./convolution.html)
- 💻[`import atcoder/modint`](./modint.html)

### グラフ

- [`import atcoder/dsu`](./dsu.html)
- [`import atcoder/maxflow`](./maxflow.html)
- [`import atcoder/mincostflow`](./mincostflow.html)
- [`import atcoder/scc`](./scc.html)
- [`import atcoder/twosat`](./twosat.html)

## エキストラライブラリ

ACLには収録されていないが、使用頻度が高そうなライブラリを追加しました。

### データ構造
- Skew Heap
- dual fenwick tree
- Splay Tree
- Tree backends [`import atcoder/extra/structure/tree_backends`](./extra/structure/tree_backends.html)
- Universal SegTree
- Wavelet Matrix
- weighted Union Find
- Sliding Window Aggregation
- Radix Heap
- 二分木関係
  - Link Cut Tree
  - Randomized Binary Search Tree
- Sparse Table
- 永続関係
  - 永続配列 [`import atcoder/extra/structure/persistent_array`](./extra/structure/persistent_array.html)
  - 永続DSU [`import atcoder/extra/structure/persistent_dsu`](./extra/structure/persistent_dsu.html)
  - Partially Persistent DSU


### 数学
- 約数系
  - 約数列挙 [`import atcoder/extra/math/divisor`](./extra/math/divisor.html)
  - エラトステネス [`import atcoder/extra/math/eratosthenes`](./extra/math/eratosthenes.html)
  - 素因数分解(pollard-rho法)[`import atcoder/extra/math/factorization`](./extra/math/factorization.html)
- 畳み込み関係
  - 任意modの畳み込み
  - 高速フーリエ変換
  - NTT
  - bitwise畳み込み
- 形式的べき級数関係
  - 形式的べき級数 [`import atcoder/extra/math/formal_power_series`](./extra/math/formal_power_series.html)
  - 形式的べき級数(sparse)
- 行列
- 順列・組み合わせ関係
  - コンビネーション(階乗・逆元)[`import atcoder/extra/math/combination`](./extra/math/combination.html)
  - コンビネーションテーブル
- 進数変換
- 大きな数の階乗
- modint関係
  - モンゴメリ演算によるmodint
  - modintによる平方根
  - modintの分数推測

### グラフ
- [`import atcoder/extra/graph/graph_template`](./extra/graph/graph_template.html)
- [`import atcoder/extra/graph/static_graph`](./extra/graph/static_graph.html)
- 最短経路問題
  - dijkstra法
    - [`import atcoder/extra/graph/dijkstra`](./extra/graph/dijkstra.html)
- [`import atcoder/extra/graph/dijkstra_radix_heap`](./extra/graph/dijkstra_radix_heap.html)
  - bellman-ford法
    - [`import atcoder/extra/graph/bellman_ford`](./extra/graph/bellman_ford.html)
  - warshall-floyd法
    - [`import atcoder/extra/graph/warshall_floyd`](./extra/graph/warshall_floyd.html)
- 最小木問題
  - prim法
  - kruskal法
- [`import atcoder/extra/graph/boruvka`](./extra/graph/boruvka.html)
  - Boruvka法
- 有向グラフの最小木問題
  - [`import atcoder/extra/graph/chu_liu_edmonds`](./extra/graph/chu_liu_edmonds.html)
- 二部グラフの最大マッチング・最小頂点被覆(hopcroft-karp法)
  - [`import atcoder/extra/graph/hopcroft_karp`](./extra/graph/hopcroft_karp.html)
- 一般グラフのマッチング(gabow-edmonds法)
- 割当問題(ハンガリアン法)
  - [`import atcoder/extra/graph/hungarian`](./extra/graph/hungarian.html)
- 橋と結節点(lowlink)
- 最大独立集合
- サイクルの検出
- オイラー周回
- 彩色数
- トポロジカルソート
- 強連結の向き付け
  - [`import atcoder/extra/graph/strong_orientation`](./extra/graph/strong_orientation.html)

### 木
- 木の直径
- 重心分解
- lowest common ancestor
- Heavy-Light Decomposition
- 全方位DP(rerooting): [`import atcoder/extra/tree/rerooting`](./extra/tree/rerooting.html)

### その他
- Assignment Operator
- 二分探索
  - 整数版
  - 不動小数版
- dense_bitset
- bitmask
- 座標圧縮
- debug.nim
- decimal.nim
- サイコロ
- 方向(direction.nim)
- floatutils.nim
- 無限(inf.nim)
- インタラクティブ用マクロ
- internal関係
  - internal_complex.nim
  - internal_sugar.nim
- listutils
- 読み込み用(reader.nim)
- 参照渡し
- seq_array_utils
- sliceutils
- solve関数用マクロ
- special_judge.nim
- static_var.nim
- セイウチ演算子
- zip.nim

<!-- PROMOTED-EXTRA-LIBRARY-DOCS:BEGIN -->
- [set_map](extra/structure/set_map.html)
- [universal_segtree](extra/structure/universal_segtree.html)
- [weighted_union_find](extra/structure/weighted_union_find.html)
- [dual_fenwicktree](extra/structure/dual_fenwicktree.html)
- [sparse_table](extra/structure/sparse_table.html)
- [radix_heap](extra/structure/radix_heap.html)
- [partially_persistent_dsu](extra/structure/partially_persistent_dsu.html)
- [compressed_segtree_2d](extra/structure/compressed_segtree_2d.html)
- [dense_fenwicktree_2d](extra/structure/dense_fenwicktree_2d.html)
- [segtree_2d](extra/structure/segtree_2d.html)
- [wavelet_matrix](extra/structure/wavelet_matrix.html)
- [succinct_indexable_dictionary](extra/structure/succinct_indexable_dictionary.html)
- [li_chao_tree](extra/structure/li_chao_tree.html)
- [convex_hull_trick_add_monotone](extra/structure/convex_hull_trick_add_monotone.html)
- [dynamic_segtree](dynamic_segtree.html)
- [dynamic_lazysegtree](dynamic_lazysegtree.html)
<!-- PROMOTED-EXTRA-LIBRARY-DOCS:END -->

## 付録

- [Appendix / FAQ](./appendix.html)

## テスト

- [こちら](https://atcoder.jp/contests/practice2) で実際にこの Library を使う問題を解いてみることができます。

## ライセンス

ヘッダファイル群(同梱の `atcoder` フォルダ以下)はCC0ライセンスで公開しています。詳しくは`atcoder/LICENSE`を参照してください。

<!-- NIM_ACL_CURATED_JA_FACADE_V1 -->
## 日本語facade

### グラフ

- [Minimum Spanning Tree（最小全域木）](extra/ja/graph/最小全域木.md)
- [Minimum Arborescence（Directed MST／最小全域有向木）](extra/ja/graph/最小全域有向木.md)

### データ構造

- [Disjoint Set Union（Union-Find／素集合データ構造）](extra/ja/structure/素集合データ構造.md)
<!-- /NIM_ACL_CURATED_JA_FACADE_V1 -->

<!-- NIM_ACL_CURATED_AUXILIARY_TREE_V1 -->
## 木アルゴリズム

- [Auxiliary Tree（Virtual Tree／仮想木）](extra/graph/virtual_tree.md)
<!-- /NIM_ACL_CURATED_AUXILIARY_TREE_V1 -->

<!-- NIM_ACL_CURATED_DP_OPTIMIZATION_V1 -->
## DP最適化

- [Monotone Minima](extra/dp/monotone_minima.md)
- [Divide-and-Conquer Optimization](extra/dp/divide_and_conquer_optimization.md)
<!-- /NIM_ACL_CURATED_DP_OPTIMIZATION_V1 -->

<!-- AUTO-GENERATED-DOC-LINKS:BEGIN -->

## 自動生成ドキュメント一覧

この節は `tools/create_missing_docs_and_update_index.py` により自動更新されます。

### 標準ライブラリ

- [monoid](monoid.md)

### Extra / グラフ

- [biconnected_components](extra/graph/biconnected_components.md)
- [block_cut_tree](extra/graph/block_cut_tree.md)
- [two_edge_connected_components](extra/graph/two_edge_connected_components.md)

### Extra / 数学

- [formal_pwoer_series](extra/math/formal_pwoer_series.md)

### Extra / その他

- [curly_init](extra/other/curly_init.md)
- [tuple_index](extra/other/tuple_index.md)
- [tuple_indexing](extra/other/tuple_indexing.md)

<!-- AUTO-GENERATED-DOC-LINKS:END -->

## Extra / Math

- FPS facade [`import atcoder/extra/math/fps`](./extra/math/fps.html)

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

- [`import atcoder/extra/math/convert_base`](./extra/math/convert_base.html)
- [`import atcoder/extra/math/mod_sqrt`](./extra/math/mod_sqrt.html)
- [`import atcoder/extra/math/combination_table`](./extra/math/combination_table.html)
- [`import atcoder/extra/math/arbitrary_mod_combination`](./extra/math/arbitrary_mod_combination.html)
- [`import atcoder/extra/math/floor_sum_square`](./extra/math/floor_sum_square.html)
- [`import atcoder/extra/math/factorial`](./extra/math/factorial.html)

## extra/geometry

- [Geometry Guide](./extra/geometry/geometry_guide.html)

- [`import atcoder/extra/geometry/geometry_template`](./extra/geometry/geometry_template.html)
- [`import atcoder/extra/geometry/closest_pair`](./extra/geometry/closest_pair.html)
- [`import atcoder/extra/geometry/polygon`](./extra/geometry/polygon.html)
- [`import atcoder/extra/geometry/triangle`](./extra/geometry/triangle.html)
- [`import atcoder/extra/geometry/tangent`](./extra/geometry/tangent.html)

## extra/algorithm

- [`import atcoder/extra/algorithm/coordinate_compression`](./extra/algorithm/coordinate_compression.html)
- [`import atcoder/extra/algorithm/run_length_encoding`](./extra/algorithm/run_length_encoding.html)
- [`import atcoder/extra/algorithm/mo`](./extra/algorithm/mo.html)

<!-- NIM_ACL_JAPANESE_FACADE_INDEX_V1 -->
## 日本語API（試験的）

Nim-ACL の正式APIを、日本語のimport名と
関数名から利用できます。

- [日本語API一覧](extra/ja/index.md)
<!-- /NIM_ACL_JAPANESE_FACADE_INDEX_V1 -->

<!-- GRAPH_FACADE_PACKET_ONE_START -->
## グラフ facade

| 概要 | ドキュメント | Import |
| --- | --- | --- |
| グラフ表現、最短路、連結性、最小全域木、functional graph、offline connectivityをまとめたcurated facadeです。既存のdirect importも維持します。 | [Graph facade](./extra/graph/graph.html) | `import atcoder/extra/graph/graph` |
<!-- GRAPH_FACADE_PACKET_ONE_END -->
