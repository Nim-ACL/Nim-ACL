#!/usr/bin/env bash
set -u

LOG="${NACL_QUICK_VERIFY_LOG:-/tmp/nacl_quick_verify.log}"
STATUS=OK
STEP=init

{
  set -e

  STEP="enter repo"
  cd "$(dirname "$0")/.."

  STEP="check nim"
  nim -v >/dev/null

  STEP="targeted tests"
  tests=(
    tests/test_extra_fps.nim
    tests/test_extra_formal_power_series.nim
    tests/test_extra_monoid.nim
    tests/test_extra_graph_template.nim
    tests/test_extra_graph_template_directed_undirected.nim
    tests/test_extra_static_graph.nim
    tests/test_extra_boruvka.nim
    tests/test_extra_chu_liu_edmonds.nim
    tests/test_extra_ja_facades.nim
    tests/test_extra_dp_basic.nim
    tests/test_extra_monotone_minima.nim
    tests/test_extra_dp_2d_edit_rectangle.nim
    tests/test_extra_math_basic.nim
    tests/test_extra_xor_basis.nim
    tests/test_extra_xor_basis_random.nim
    tests/test_extra_arbitrary_mod_combination.nim
    tests/test_extra_geometry_template.nim
    tests/test_extra_geometry_polygon.nim
    tests/test_extra_geometry_triangle_tangent.nim
    tests/test_extra_geometry_facade.nim
    tests/test_extra_radix_heap.nim
    tests/test_extra_sparse_table.nim
    tests/test_extra_dual_fenwicktree.nim
    tests/test_extra_weighted_union_find.nim
    tests/test_extra_convex_hull_trick_add_monotone.nim
    tests/test_extra_li_chao_tree.nim
    tests/test_extra_segtree_2d.nim
    tests/test_extra_wavelet_matrix.nim
    tests/test_extra_partially_persistent_dsu.nim
    tests/test_extra_succinct_indexable_dictionary.nim
    tests/test_extra_binary_trie.nim
    tests/test_extra_binary_trie_random.nim
    tests/test_extra_rollback_dsu.nim
    tests/test_extra_rollback_dsu_random.nim
    tests/test_extra_offline_dynamic_connectivity.nim
    tests/test_extra_virtual_tree.nim
    tests/test_extra_euler_tour.nim
    tests/test_extra_persistent_segment_tree.nim
    tests/test_extra_persistent_segment_tree_static_api.nim
    tests/test_extra_sqrt_tree.nim
    tests/test_extra_dsu_on_tree.nim
    tests/test_extra_undirected_decomposition.nim
    tests/test_extra_rerooting_dp.nim
    tests/test_extra_functional_graph.nim
    tests/test_extra_functional_graph_random.nim
    tests/test_extra_manacher.nim
    tests/test_extra_manacher_random.nim
    tests/test_extra_aho_corasick.nim
    tests/test_extra_aho_corasick_random.nim
    tests/test_extra_kmp.nim
    tests/test_extra_kmp_random.nim
    tests/test_extra_minimum_rotation.nim
    tests/test_extra_suffix_automaton.nim
    tests/test_extra_suffix_automaton_random.nim
    tests/test_extra_palindromic_tree.nim
    tests/test_extra_cartesian_tree.nim
    tests/test_extra_fast_set.nim
    tests/test_extra_fast_set_random.nim
    tests/test_extra_disjoint_sparse_table.nim
    tests/test_extra_mo.nim
    tests/test_extra_coordinate_compression.nim
    tests/test_extra_run_length_encoding.nim
    tests/test_extra_mex_set.nim
    tests/test_extra_sorted_set_map.nim
    tests/test_extra_set_map.nim
    tests/test_extra_tree_backend_common_interface.nim
    tests/test_extra_graph_shortest_paths.nim
    tests/test_extra_graph_structural.nim
    tests/test_extra_universal_segtree.nim
    tests/test_extra_universal_segtree_stress.nim
    tests/test_dsu.nim
    tests/test_fenwicktree.nim
    tests/test_segtree.nim
    tests/test_lazysegtree.nim
    tests/test_modint.nim
    tests/test_convolution.nim
    tests/test_scc.nim
    tests/test_maxflow.nim
    tests/test_mincostflow.nim
  )

  for t in "${tests[@]}"; do
    STEP="test $t"
    nim cpp -r "$t"
  done

  STEP="cleanup generated test artifacts"
  for t in "${tests[@]}"; do
    rm -f "${t%.nim}"
  done
  rm -rf nimcache

  STEP="generate docs"
  if [ -x .venv-docs/bin/python ]; then
    .venv-docs/bin/python tools/generate_document.py
  else
    python3 tools/generate_document.py
# NIM_ACL_DOCUMENT_HIGHLIGHT_FALLBACK_V1
python3 tools/postprocess_document_html.py
  fi

  STEP="check generated docs"
  doc_changes="$(git status --porcelain document_ja document_en)"
  if [ -n "$doc_changes" ]; then
    echo "Generated documentation changed:"
    echo "$doc_changes"
    git --no-pager diff --stat -- document_ja document_en || true

    if [ "${CI:-}" = "true" ] && [ "${NACL_STRICT_DOCS:-0}" != "1" ]; then
      echo
      echo "CI non-strict docs mode:"
      echo "  The documentation generator ran successfully."
      echo "  Generated documentation diffs are reset in CI."
      echo "  Use tools/publish_docs.sh to regenerate, commit, and publish documentation."
      git checkout -- document_ja document_en
      git clean -fd -- document_ja document_en
    else
      echo
      echo "Generated docs are not committed."
      echo "Run:"
      echo "  bash tools/publish_docs.sh"
      echo "or commit the regenerated documentation."
      false
    fi
  fi

  STEP="cleanup generated files after docs"
  rm -rf nimcache

  # >>> BERLEKAMP_MASSEY_AUDIT >>>
if ! python3 tools/audit_berlekamp_massey.py
then
  STATUS="NG"
  STEP="Berlekamp-Massey audit"
fi
# <<< BERLEKAMP_MASSEY_AUDIT <<<

# >>> PST_VERSION_FIRST_CROSS_TEST >>>
PST_VERSION_FIRST_TMP="/tmp/nacl_pst_version_first_quick_$$"

rm -rf "$PST_VERSION_FIRST_TMP"
mkdir -p "$PST_VERSION_FIRST_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$PST_VERSION_FIRST_TMP/nimcache-static" \
  --out:"$PST_VERSION_FIRST_TMP/static-test" \
  tests/test_extra_persistent_segment_tree_static_api.nim
then
  STATUS="NG"
  STEP="PersistentSegTree version-first static test"

elif ! "$PST_VERSION_FIRST_TMP/static-test"
then
  STATUS="NG"
  STEP="PersistentSegTree version-first static run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$PST_VERSION_FIRST_TMP/nimcache-cross" \
  --out:"$PST_VERSION_FIRST_TMP/cross-test" \
  tests/test_extra_persistent_segment_tree_version_first_cross_module.nim
then
  STATUS="NG"
  STEP="PersistentSegTree version-first cross test"

elif ! "$PST_VERSION_FIRST_TMP/cross-test"
then
  STATUS="NG"
  STEP="PersistentSegTree version-first cross run"
fi

rm -rf "$PST_VERSION_FIRST_TMP"
# <<< PST_VERSION_FIRST_CROSS_TEST <<<

# >>> POLYNOMIAL_INTERPOLATION_TEST >>>
POLYNOMIAL_INTERPOLATION_TMP="/tmp/nacl_polynomial_interpolation_quick_$$"

rm -rf "$POLYNOMIAL_INTERPOLATION_TMP"
mkdir -p "$POLYNOMIAL_INTERPOLATION_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$POLYNOMIAL_INTERPOLATION_TMP/nimcache-main" \
  --out:"$POLYNOMIAL_INTERPOLATION_TMP/main-test" \
  tests/test_extra_polynomial_interpolation.nim
then
  STATUS="NG"
  STEP="Polynomial Interpolation test compile"

elif ! "$POLYNOMIAL_INTERPOLATION_TMP/main-test"
then
  STATUS="NG"
  STEP="Polynomial Interpolation test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$POLYNOMIAL_INTERPOLATION_TMP/nimcache-cross" \
  --out:"$POLYNOMIAL_INTERPOLATION_TMP/cross-test" \
  tests/test_extra_polynomial_interpolation_cross_module.nim
then
  STATUS="NG"
  STEP="Polynomial Interpolation cross compile"

elif ! "$POLYNOMIAL_INTERPOLATION_TMP/cross-test"
then
  STATUS="NG"
  STEP="Polynomial Interpolation cross run"
fi

rm -rf "$POLYNOMIAL_INTERPOLATION_TMP"
# <<< POLYNOMIAL_INTERPOLATION_TEST <<<

# >>> SUBSET_CONVOLUTION_TEST >>>
SUBSET_CONVOLUTION_TMP="/tmp/nacl_subset_convolution_quick_$$"

rm -rf "$SUBSET_CONVOLUTION_TMP"
mkdir -p "$SUBSET_CONVOLUTION_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$SUBSET_CONVOLUTION_TMP/nimcache-main" \
  --out:"$SUBSET_CONVOLUTION_TMP/main-test" \
  tests/test_extra_subset_convolution.nim
then
  STATUS="NG"
  STEP="Subset Convolution test compile"

elif ! "$SUBSET_CONVOLUTION_TMP/main-test"
then
  STATUS="NG"
  STEP="Subset Convolution test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$SUBSET_CONVOLUTION_TMP/nimcache-cross" \
  --out:"$SUBSET_CONVOLUTION_TMP/cross-test" \
  tests/test_extra_subset_convolution_cross_module.nim
then
  STATUS="NG"
  STEP="Subset Convolution cross compile"

elif ! "$SUBSET_CONVOLUTION_TMP/cross-test"
then
  STATUS="NG"
  STEP="Subset Convolution cross run"
fi

rm -rf "$SUBSET_CONVOLUTION_TMP"
# <<< SUBSET_CONVOLUTION_TEST <<<

# >>> EXP_OF_SET_POWER_SERIES_TEST >>>
EXP_SET_POWER_SERIES_TMP="/tmp/nacl_exp_set_power_series_quick_$$"

rm -rf "$EXP_SET_POWER_SERIES_TMP"
mkdir -p "$EXP_SET_POWER_SERIES_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$EXP_SET_POWER_SERIES_TMP/nimcache-main" \
  --out:"$EXP_SET_POWER_SERIES_TMP/main-test" \
  tests/test_extra_exp_of_set_power_series.nim
then
  STATUS="NG"
  STEP="Exp of Set Power Series test compile"

elif ! "$EXP_SET_POWER_SERIES_TMP/main-test"
then
  STATUS="NG"
  STEP="Exp of Set Power Series test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$EXP_SET_POWER_SERIES_TMP/nimcache-cross" \
  --out:"$EXP_SET_POWER_SERIES_TMP/cross-test" \
  tests/test_extra_exp_of_set_power_series_cross_module.nim
then
  STATUS="NG"
  STEP="Exp of Set Power Series cross compile"

elif ! "$EXP_SET_POWER_SERIES_TMP/cross-test"
then
  STATUS="NG"
  STEP="Exp of Set Power Series cross run"
fi

rm -rf "$EXP_SET_POWER_SERIES_TMP"
# <<< EXP_OF_SET_POWER_SERIES_TEST <<<

# >>> SMAWK_TEST >>>
SMAWK_TMP="/tmp/nacl_smawk_quick_$$"

rm -rf "$SMAWK_TMP"
mkdir -p "$SMAWK_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$SMAWK_TMP/nimcache-main" \
  --out:"$SMAWK_TMP/main-test" \
  tests/test_extra_smawk.nim
then
  STATUS="NG"
  STEP="SMAWK test compile"

elif ! "$SMAWK_TMP/main-test"
then
  STATUS="NG"
  STEP="SMAWK test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$SMAWK_TMP/nimcache-cross" \
  --out:"$SMAWK_TMP/cross-test" \
  tests/test_extra_smawk_cross_module.nim
then
  STATUS="NG"
  STEP="SMAWK cross compile"

elif ! "$SMAWK_TMP/cross-test"
then
  STATUS="NG"
  STEP="SMAWK cross run"
fi

rm -rf "$SMAWK_TMP"
# <<< SMAWK_TEST <<<

# >>> BIPARTITE_EDGE_COLORING_TEST >>>
BIPARTITE_EDGE_COLORING_TMP="/tmp/nacl_bipartite_edge_coloring_quick_$$"

rm -rf "$BIPARTITE_EDGE_COLORING_TMP"
mkdir -p "$BIPARTITE_EDGE_COLORING_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$BIPARTITE_EDGE_COLORING_TMP/nimcache-main" \
  --out:"$BIPARTITE_EDGE_COLORING_TMP/main-test" \
  tests/test_extra_bipartite_edge_coloring.nim
then
  STATUS="NG"
  STEP="bipartite edge coloring test compile"

elif ! "$BIPARTITE_EDGE_COLORING_TMP/main-test"
then
  STATUS="NG"
  STEP="bipartite edge coloring test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$BIPARTITE_EDGE_COLORING_TMP/nimcache-cross" \
  --out:"$BIPARTITE_EDGE_COLORING_TMP/cross-test" \
  tests/test_extra_bipartite_edge_coloring_cross_module.nim
then
  STATUS="NG"
  STEP="bipartite edge coloring cross compile"

elif ! "$BIPARTITE_EDGE_COLORING_TMP/cross-test"
then
  STATUS="NG"
  STEP="bipartite edge coloring cross run"
fi

rm -rf "$BIPARTITE_EDGE_COLORING_TMP"
# <<< BIPARTITE_EDGE_COLORING_TEST <<<

# >>> IMPLICIT_TREAP_TEST >>>
IMPLICIT_TREAP_TMP="/tmp/nacl_implicit_treap_quick_$$"

rm -rf "$IMPLICIT_TREAP_TMP"
mkdir -p "$IMPLICIT_TREAP_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$IMPLICIT_TREAP_TMP/nimcache-main" \
  --out:"$IMPLICIT_TREAP_TMP/main-test" \
  tests/test_extra_implicit_treap.nim
then
  STATUS="NG"
  STEP="Implicit Treap test compile"

elif ! "$IMPLICIT_TREAP_TMP/main-test"
then
  STATUS="NG"
  STEP="Implicit Treap test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$IMPLICIT_TREAP_TMP/nimcache-cross" \
  --out:"$IMPLICIT_TREAP_TMP/cross-test" \
  tests/test_extra_implicit_treap_cross_module.nim
then
  STATUS="NG"
  STEP="Implicit Treap cross compile"

elif ! "$IMPLICIT_TREAP_TMP/cross-test"
then
  STATUS="NG"
  STEP="Implicit Treap cross run"
fi

rm -rf "$IMPLICIT_TREAP_TMP"
# <<< IMPLICIT_TREAP_TEST <<<

# >>> LOG_OF_SET_POWER_SERIES_TEST >>>
LOG_OF_SET_POWER_SERIES_TMP="/tmp/nacl_log_of_set_power_series_quick_$$"

rm -rf "$LOG_OF_SET_POWER_SERIES_TMP"
mkdir -p "$LOG_OF_SET_POWER_SERIES_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$LOG_OF_SET_POWER_SERIES_TMP/nimcache-main" \
  --out:"$LOG_OF_SET_POWER_SERIES_TMP/main-test" \
  tests/test_extra_log_of_set_power_series.nim
then
  STATUS="NG"
  STEP="Log of Set Power Series test compile"

elif ! "$LOG_OF_SET_POWER_SERIES_TMP/main-test"
then
  STATUS="NG"
  STEP="Log of Set Power Series test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$LOG_OF_SET_POWER_SERIES_TMP/nimcache-cross" \
  --out:"$LOG_OF_SET_POWER_SERIES_TMP/cross-test" \
  tests/test_extra_log_of_set_power_series_cross_module.nim
then
  STATUS="NG"
  STEP="Log of Set Power Series cross compile"

elif ! "$LOG_OF_SET_POWER_SERIES_TMP/cross-test"
then
  STATUS="NG"
  STEP="Log of Set Power Series cross run"
fi

rm -rf "$LOG_OF_SET_POWER_SERIES_TMP"
# <<< LOG_OF_SET_POWER_SERIES_TEST <<<

# >>> BFLOW_TEST >>>
BFLOW_TMP="/tmp/nacl_bflow_quick_$$"

rm -rf "$BFLOW_TMP"
mkdir -p "$BFLOW_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$BFLOW_TMP/nimcache-main" \
  --out:"$BFLOW_TMP/main-test" \
  tests/test_extra_bflow.nim
then
  STATUS="NG"
  STEP="BFlow test compile"

elif ! "$BFLOW_TMP/main-test"
then
  STATUS="NG"
  STEP="BFlow test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$BFLOW_TMP/nimcache-cross" \
  --out:"$BFLOW_TMP/cross-test" \
  tests/test_extra_bflow_cross_module.nim
then
  STATUS="NG"
  STEP="BFlow cross compile"

elif ! "$BFLOW_TMP/cross-test"
then
  STATUS="NG"
  STEP="BFlow cross run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$BFLOW_TMP/nimcache-verify" \
  --out:"$BFLOW_TMP/verify-test" \
  src/verify/extra/graph/min_cost_b_flow_test.nim
then
  STATUS="NG"
  STEP="BFlow verifier compile"
fi

rm -rf "$BFLOW_TMP"
# <<< BFLOW_TEST <<<

# >>> KD_TREE_AND_MINKOWSKI_SUM_TEST >>>
KD_MINKOWSKI_TMP="/tmp/nacl_kd_minkowski_quick_$$"

rm -rf "$KD_MINKOWSKI_TMP"
mkdir -p "$KD_MINKOWSKI_TMP"

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$KD_MINKOWSKI_TMP/nimcache-kd" \
  --out:"$KD_MINKOWSKI_TMP/kd-test" \
  tests/test_extra_kd_tree.nim
then
  STATUS="NG"
  STEP="KD-tree test compile"

elif ! "$KD_MINKOWSKI_TMP/kd-test"
then
  STATUS="NG"
  STEP="KD-tree test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$KD_MINKOWSKI_TMP/nimcache-kd-cross" \
  --out:"$KD_MINKOWSKI_TMP/kd-cross-test" \
  tests/test_extra_kd_tree_cross_module.nim
then
  STATUS="NG"
  STEP="KD-tree cross compile"

elif ! "$KD_MINKOWSKI_TMP/kd-cross-test"
then
  STATUS="NG"
  STEP="KD-tree cross run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$KD_MINKOWSKI_TMP/nimcache-minkowski" \
  --out:"$KD_MINKOWSKI_TMP/minkowski-test" \
  tests/test_extra_minkowski_sum.nim
then
  STATUS="NG"
  STEP="Minkowski Sum test compile"

elif ! "$KD_MINKOWSKI_TMP/minkowski-test"
then
  STATUS="NG"
  STEP="Minkowski Sum test run"
fi

if ! nim cpp \
  -d:release \
  --path:src \
  --path:tests \
  --hints:off \
  --verbosity:0 \
  --nimcache:"$KD_MINKOWSKI_TMP/nimcache-minkowski-cross" \
  --out:"$KD_MINKOWSKI_TMP/minkowski-cross-test" \
  tests/test_extra_minkowski_sum_cross_module.nim
then
  STATUS="NG"
  STEP="Minkowski Sum cross compile"

elif ! "$KD_MINKOWSKI_TMP/minkowski-cross-test"
then
  STATUS="NG"
  STEP="Minkowski Sum cross run"
fi

rm -rf "$KD_MINKOWSKI_TMP"
# <<< KD_TREE_AND_MINKOWSKI_SUM_TEST <<<

# >>> DOCS_HOMEPAGE_AUDIT >>>
if ! python3 tools/audit_docs_homepage.py --html
then
  STATUS="NG"
  STEP="documentation homepage audit"
fi
# <<< DOCS_HOMEPAGE_AUDIT <<<


# <<< BITUTILS_THREE_DEFECTS_REGRESSION_V1 >>>
STEP="BitUtils dedicated regression"

for mm in refc orc
do
  output="/tmp/nacl_bitutils_regression_${mm}_$$"
  cache="/tmp/nacl_bitutils_regression_${mm}_cache_$$"

  nim cpp \
    -r \
    --hints:off \
    --verbosity:0 \
    --path:src \
    -d:release \
    --mm:"$mm" \
    --nimcache:"$cache" \
    -o:"$output" \
    tests/test_extra_bitutils.nim \
    >>"$LOG" 2>&1

  rm -rf "$output" "$cache"
done

# <<< BITUTILS_THREE_DEFECTS_REGRESSION_V1_END >>>


# <<< BITSET_CONTRACT_REGRESSION_V1 >>>
STEP="BitSet dedicated contract regression"

python3 tools/audit_bit_utility_contract.py \
  >>"$LOG" 2>&1

for mm in refc orc
do
  output="/tmp/nacl_bitset_contract_${mm}_$$"
  cache="/tmp/nacl_bitset_contract_${mm}_cache_$$"

  nim cpp \
    -r \
    --hints:off \
    --verbosity:0 \
    --path:src \
    -d:release \
    --mm:"$mm" \
    --nimcache:"$cache" \
    -o:"$output" \
    tests/test_extra_bitset.nim \
    >>"$LOG" 2>&1

  rm -rf "$output" "$cache"
done


# <<< BIT_UTILITY_CANONICAL_AND_COMPATIBILITY_IMPORTS_V1 >>>

python3 \
  tools/audit_document_catalog_link_normalization.py \
  >>"$LOG" 2>&1

for bit_api_test in \
  tests/test_bit_utility_canonical_api.nim \
  tests/test_bit_utility_legacy_compatibility.nim
do
  test_name="$(
    basename "$bit_api_test" .nim
  )"

  for mm in refc orc
  do
    output="/tmp/nacl_${test_name}_${mm}_$$"
    cache="/tmp/nacl_${test_name}_${mm}_cache_$$"

    nim cpp \
      -r \
      --hints:off \
      --verbosity:0 \
      --path:src \
      -d:release \
      --mm:"$mm" \
      --nimcache:"$cache" \
      -o:"$output" \
      "$bit_api_test" \
      >>"$LOG" 2>&1

    rm -rf "$output" "$cache"
  done
done

# <<< BIT_UTILITY_CANONICAL_AND_COMPATIBILITY_IMPORTS_V1_END >>>

# <<< BITSET_CONTRACT_REGRESSION_V1_END >>>


# <<< RANGE_SLICE_CONTRACT_REGRESSION_V2 >>>

STEP="Range and Slice validated contract regression"

python3 tools/audit_range_slice_contract.py \
  >>"$LOG" 2>&1

for range_slice_test in \
  tests/test_rangeutils.nim \
  tests/test_sliceutils.nim
do
  range_slice_name="$(
    basename "$range_slice_test" .nim
  )"

  for range_slice_mm in refc orc
  do
    range_slice_output="/tmp/nacl_${range_slice_name}_${range_slice_mm}_$$"
    range_slice_cache="/tmp/nacl_${range_slice_name}_${range_slice_mm}_cache_$$"

    nim cpp \
      -r \
      --hints:off \
      --verbosity:0 \
      --path:src \
      -d:release \
      --mm:"$range_slice_mm" \
      --nimcache:"$range_slice_cache" \
      -o:"$range_slice_output" \
      "$range_slice_test" \
      >>"$LOG" 2>&1

    rm -rf \
      "$range_slice_output" \
      "$range_slice_cache"
  done
done

for range_overflow_mm in refc orc
do
  range_overflow_output="/tmp/nacl_range_overflow_${range_overflow_mm}_$$"
  range_overflow_cache="/tmp/nacl_range_overflow_${range_overflow_mm}_cache_$$"
  range_overflow_log="/tmp/nacl_range_overflow_${range_overflow_mm}_$$.log"

  if nim cpp \
    -r \
    --hints:off \
    --verbosity:0 \
    --path:src \
    -d:release \
    --overflowChecks:on \
    --mm:"$range_overflow_mm" \
    --nimcache:"$range_overflow_cache" \
    -o:"$range_overflow_output" \
    tests/test_rangeutils_overflow.nim \
    >"$range_overflow_log" 2>&1
  then
    cat "$range_overflow_log" >>"$LOG"
    echo \
      "RANGE_SLICE_CONTRACT_ERROR: checked overflow unexpectedly passed" \
      >>"$LOG"
    false
  fi

  cat "$range_overflow_log" >>"$LOG"

  grep -Eiq \
    'OverflowDefect|overflow' \
    "$range_overflow_log"

  rm -rf \
    "$range_overflow_output" \
    "$range_overflow_cache" \
    "$range_overflow_log"
done

# <<< RANGE_SLICE_CONTRACT_REGRESSION_V2_END >>>


# <<< ITERTOOLS_CONTRACT_REGRESSION_V1 >>>

STEP="Canonical Itertools and AlgorithmUtils regression"

python3 tools/audit_itertools_contract.py \
  >>"$LOG" 2>&1

for itertools_test in \
  tests/test_itertools.nim \
  tests/test_itertools_coexistence.nim \
  tests/test_algorithmutils.nim \
  tests/test_algorithmutils_importer.nim \
  tests/test_itertools_header.nim
do
  itertools_name="$(
    basename "$itertools_test" .nim
  )"

  for itertools_mm in refc orc
  do
    itertools_output="/tmp/nacl_${itertools_name}_${itertools_mm}_$$"
    itertools_cache="/tmp/nacl_${itertools_name}_${itertools_mm}_cache_$$"

    nim cpp \
      -r \
      --hints:off \
      --verbosity:0 \
      --path:src \
      -d:release \
      --mm:"$itertools_mm" \
      --nimcache:"$itertools_cache" \
      -o:"$itertools_output" \
      "$itertools_test" \
      >>"$LOG" 2>&1

    rm -rf \
      "$itertools_output" \
      "$itertools_cache"
  done
done

# <<< ITERTOOLS_CONTRACT_REGRESSION_V1_END >>>


# <<< MONOID_SEGTREE_FACADE_REGRESSION_V1 >>>

STEP="Monoid SegTree facade regression"

python3 tools/audit_monoid_segtree_facade.py \
  >>"$LOG" 2>&1

for facade_test in \
  tests/test_action_monoid_alias.nim \
  tests/test_monoid_segtree_facade.nim \
  tests/test_monoid_segtree_header.nim
do
  facade_name="$(
    basename "$facade_test" .nim
  )"

  for facade_mm in refc orc
  do
    facade_output="/tmp/nacl_${facade_name}_${facade_mm}_$$"
    facade_cache="/tmp/nacl_${facade_name}_${facade_mm}_cache_$$"

    nim cpp \
      -r \
      --hints:off \
      --verbosity:0 \
      --path:src \
      -d:release \
      --mm:"$facade_mm" \
      --nimcache:"$facade_cache" \
      -o:"$facade_output" \
      "$facade_test" \
      >>"$LOG" 2>&1

    rm -rf \
      "$facade_output" \
      "$facade_cache"
  done
done

# <<< MONOID_SEGTREE_FACADE_REGRESSION_V1_END >>>

# BEGIN SORTED_SET_MAP_ALWAYS_COUNTABLE_CONTRACT
STEP="sorted set map always-countable and iterator contract"
echo "[quick] Sorted Set / Map always-countable and iterator contract"


sorted_set_map_contract_tmp="$(
  mktemp -d "${TMPDIR:-/tmp}/nim_acl_sorted_set_map_contract.XXXXXX"
)"

nim cpp \
  --hints:off \
  --verbosity:0 \
  --path:src \
  -d:release \
  --mm:refc \
  --nimcache:"$sorted_set_map_contract_tmp/refc_cache" \
  -o:"$sorted_set_map_contract_tmp/refc" \
  tests/extra/structure/sorted_set_map_always_countable_contract.nim

"$sorted_set_map_contract_tmp/refc" \
  >"$sorted_set_map_contract_tmp/refc.out"

nim cpp \
  --hints:off \
  --verbosity:0 \
  --path:src \
  -d:release \
  --mm:orc \
  --nimcache:"$sorted_set_map_contract_tmp/orc_cache" \
  -o:"$sorted_set_map_contract_tmp/orc" \
  tests/extra/structure/sorted_set_map_always_countable_contract.nim

"$sorted_set_map_contract_tmp/orc" \
  >"$sorted_set_map_contract_tmp/orc.out"

cmp \
  "$sorted_set_map_contract_tmp/refc.out" \
  "$sorted_set_map_contract_tmp/orc.out"

grep -qx \
  'SORTED_ALWAYS_COUNTABLE_OK' \
  "$sorted_set_map_contract_tmp/refc.out"

grep -qx \
  'SORTED_ORDER_ACCESS_OK' \
  "$sorted_set_map_contract_tmp/refc.out"

grep -qx \
  'SORTED_MAP_KEY_VS_INDEX_OK' \
  "$sorted_set_map_contract_tmp/refc.out"

grep -qx \
  'SORTED_ITERATOR_API_OK' \
  "$sorted_set_map_contract_tmp/refc.out"

rm -rf "$sorted_set_map_contract_tmp"
# END SORTED_SET_MAP_ALWAYS_COUNTABLE_CONTRACT

# BEGIN COMPRESSED_SEGTREE_2D_CONTRACT_V1
STEP="compressed segtree 2d canonical and compatibility contracts"
echo "[quick] CompressedSegTree2Dの可換性・set再計算・legacy互換性を確認します"

compressed_segtree_2d_tmp="$(
  mktemp -d "${TMPDIR:-/tmp}/nim_acl_compressed_segtree_2d.XXXXXX"
)"

for compressed_segtree_2d_test in \
  tests/extra/structure/compressed_segtree_2d_contract.nim \
  tests/extra/structure/segtree_2d_legacy_contract.nim
do
  compressed_segtree_2d_name="$(
    basename "$compressed_segtree_2d_test" .nim
  )"

  for compressed_segtree_2d_mm in refc orc
  do
    compressed_segtree_2d_binary="$compressed_segtree_2d_tmp/${compressed_segtree_2d_name}_${compressed_segtree_2d_mm}"
    compressed_segtree_2d_cache="$compressed_segtree_2d_tmp/${compressed_segtree_2d_name}_${compressed_segtree_2d_mm}_cache"
    compressed_segtree_2d_output="$compressed_segtree_2d_tmp/${compressed_segtree_2d_name}_${compressed_segtree_2d_mm}.out"

    nim cpp \
      --hints:off \
      --verbosity:0 \
      --path:src \
      -d:release \
      --mm:"$compressed_segtree_2d_mm" \
      --nimcache:"$compressed_segtree_2d_cache" \
      -o:"$compressed_segtree_2d_binary" \
      "$compressed_segtree_2d_test"

    "$compressed_segtree_2d_binary" \
      >"$compressed_segtree_2d_output"
  done

  cmp \
    "$compressed_segtree_2d_tmp/${compressed_segtree_2d_name}_refc.out" \
    "$compressed_segtree_2d_tmp/${compressed_segtree_2d_name}_orc.out"
done

grep -qx \
  'COMPRESSED_SEGTREE_2D_DUPLICATE_Y_SET_OK' \
  "$compressed_segtree_2d_tmp/compressed_segtree_2d_contract_refc.out"

grep -qx \
  'COMPRESSED_SEGTREE_2D_POINT_COUNT_OK' \
  "$compressed_segtree_2d_tmp/compressed_segtree_2d_contract_refc.out"

grep -qx \
  'COMPRESSED_SEGTREE_2D_BUILDER_OK' \
  "$compressed_segtree_2d_tmp/compressed_segtree_2d_contract_refc.out"

grep -qx \
  'COMPRESSED_SEGTREE_2D_GENERIC_OK' \
  "$compressed_segtree_2d_tmp/compressed_segtree_2d_contract_refc.out"

grep -qx \
  'COMPRESSED_SEGTREE_2D_EMPTY_OK' \
  "$compressed_segtree_2d_tmp/compressed_segtree_2d_contract_refc.out"

grep -qx \
  'SEGTREE_2D_LEGACY_OK' \
  "$compressed_segtree_2d_tmp/segtree_2d_legacy_contract_refc.out"

rm -rf "$compressed_segtree_2d_tmp"
# END COMPRESSED_SEGTREE_2D_CONTRACT_V1

# BEGIN CUMULATIVE_SUM_2D_CONTRACT_V1
STEP="cumulative sum 2d half-open and compatibility contracts"
echo "[quick] CumulativeSum2Dの半開矩形APIとlegacy Slice互換性を確認します"

cumulative_sum_2d_tmp="$(
  mktemp -d "${TMPDIR:-/tmp}/nim_acl_cumulative_sum_2d.XXXXXX"
)"

for cumulative_sum_2d_test in \
  tests/extra/dp/cumulative_sum_2d_contract.nim \
  tests/extra/dp/dual_cumulative_sum_2d_contract.nim
do
  cumulative_sum_2d_name="$(
    basename "$cumulative_sum_2d_test" .nim
  )"

  for cumulative_sum_2d_mm in refc orc
  do
    cumulative_sum_2d_binary="$cumulative_sum_2d_tmp/${cumulative_sum_2d_name}_${cumulative_sum_2d_mm}"
    cumulative_sum_2d_cache="$cumulative_sum_2d_tmp/${cumulative_sum_2d_name}_${cumulative_sum_2d_mm}_cache"
    cumulative_sum_2d_output="$cumulative_sum_2d_tmp/${cumulative_sum_2d_name}_${cumulative_sum_2d_mm}.out"

    nim cpp \
      --hints:off \
      --verbosity:0 \
      --path:src \
      -d:release \
      --mm:"$cumulative_sum_2d_mm" \
      --nimcache:"$cumulative_sum_2d_cache" \
      -o:"$cumulative_sum_2d_binary" \
      "$cumulative_sum_2d_test"

    "$cumulative_sum_2d_binary" \
      >"$cumulative_sum_2d_output"
  done

  cmp \
    "$cumulative_sum_2d_tmp/${cumulative_sum_2d_name}_refc.out" \
    "$cumulative_sum_2d_tmp/${cumulative_sum_2d_name}_orc.out"
done

grep -qx \
  'CUMULATIVE_SUM_2D_MATRIX_OK' \
  "$cumulative_sum_2d_tmp/cumulative_sum_2d_contract_refc.out"

grep -qx \
  'DUAL_CUMULATIVE_SUM_2D_LEGACY_OK' \
  "$cumulative_sum_2d_tmp/dual_cumulative_sum_2d_contract_refc.out"

rm -rf "$cumulative_sum_2d_tmp"
# END CUMULATIVE_SUM_2D_CONTRACT_V1

# BEGIN DENSE_FENWICKTREE_2D_CONTRACT_V1
STEP="dense fenwicktree 2d contract"
echo "[quick] DenseFenwickTree2Dの点加算・半開矩形和・generic加法型を確認します"

dense_fenwicktree_2d_tmp="$(
  mktemp -d "${TMPDIR:-/tmp}/nim_acl_dense_fenwicktree_2d.XXXXXX"
)"

for dense_fenwicktree_2d_mm in refc orc
do
  dense_fenwicktree_2d_binary="$dense_fenwicktree_2d_tmp/program_${dense_fenwicktree_2d_mm}"
  dense_fenwicktree_2d_cache="$dense_fenwicktree_2d_tmp/cache_${dense_fenwicktree_2d_mm}"
  dense_fenwicktree_2d_output="$dense_fenwicktree_2d_tmp/output_${dense_fenwicktree_2d_mm}.txt"

  nim cpp \
    --hints:off \
    --verbosity:0 \
    --path:src \
    -d:release \
    --mm:"$dense_fenwicktree_2d_mm" \
    --nimcache:"$dense_fenwicktree_2d_cache" \
    -o:"$dense_fenwicktree_2d_binary" \
    tests/extra/structure/dense_fenwicktree_2d_contract.nim

  "$dense_fenwicktree_2d_binary" \
    >"$dense_fenwicktree_2d_output"
done

cmp \
  "$dense_fenwicktree_2d_tmp/output_refc.txt" \
  "$dense_fenwicktree_2d_tmp/output_orc.txt"

grep -qx \
  'DENSE_FENWICKTREE_2D_DIMENSIONS_OK' \
  "$dense_fenwicktree_2d_tmp/output_refc.txt"

grep -qx \
  'DENSE_FENWICKTREE_2D_RECTANGLE_OK' \
  "$dense_fenwicktree_2d_tmp/output_refc.txt"

grep -qx \
  'DENSE_FENWICKTREE_2D_EMPTY_OK' \
  "$dense_fenwicktree_2d_tmp/output_refc.txt"

grep -qx \
  'DENSE_FENWICKTREE_2D_GENERIC_OK' \
  "$dense_fenwicktree_2d_tmp/output_refc.txt"

rm -rf "$dense_fenwicktree_2d_tmp"
# END DENSE_FENWICKTREE_2D_CONTRACT_V1

STEP="cleanup compiler runtime after final Nim tests"
rm -rf .nim_runtime nimcache

STEP="final clean"
  if [ -n "$(git status --porcelain)" ]; then
    git status --short
    false
  fi

} >"$LOG" 2>&1 || STATUS=NG

echo
echo "===== NACL RESULT START ====="
echo "STATUS: $STATUS"
echo "STEP: $STEP"
echo "LOG: $LOG"

if [ "$STATUS" = OK ]; then
  echo "SUMMARY: quick verify passed"
else
  echo "SUMMARY: quick verify failed"
  echo "LAST_LOG_LINES:"
  tail -n 120 "$LOG"
fi

echo "===== NACL RESULT END ====="

[ "$STATUS" = OK ]

# NIM_ACL_GENERATED_DOCUMENT_AUDIT_V1
python3 tools/postprocess_document_links.py
python3 tools/audit_generated_document_html.py

# NIM_ACL_STRICT_HIGHLIGHT_COUNT_AUDIT_V1
NIM_ACL_DOC_AUDIT_OUTPUT="$(
  python3 tools/audit_generated_document_html.py
)"
printf '%s\n' "$NIM_ACL_DOC_AUDIT_OUTPUT"

nim_acl_read_count() {
  printf '%s\n' "$NIM_ACL_DOC_AUDIT_OUTPUT" \
    | sed -n "s/^$1=\([0-9][0-9]*\)$/\1/p"
}

NIM_ACL_HIGHLIGHTED="$(
  nim_acl_read_count HIGHLIGHTED_BLOCKS
)"
NIM_ACL_TOKENS="$(
  nim_acl_read_count TOKEN_SPANS
)"
NIM_ACL_NUMBERED="$(
  nim_acl_read_count NUMBERED_BLOCKS
)"
NIM_ACL_LINES="$(
  nim_acl_read_count CODE_LINES
)"
NIM_ACL_MARKERS="$(
  nim_acl_read_count MARKED_EXAMPLES
)"
NIM_ACL_NIM_BLOCKS="$(
  nim_acl_read_count NIM_CODE_BLOCKS
)"

test -n "$NIM_ACL_HIGHLIGHTED"
test -n "$NIM_ACL_TOKENS"
test -n "$NIM_ACL_NUMBERED"
test -n "$NIM_ACL_LINES"
test -n "$NIM_ACL_MARKERS"
test -n "$NIM_ACL_NIM_BLOCKS"

test "$NIM_ACL_HIGHLIGHTED" -gt 0
test "$NIM_ACL_TOKENS" -gt 0
test "$NIM_ACL_NIM_BLOCKS" -gt 0

if [ "$NIM_ACL_MARKERS" -gt 0 ]; then
  test "$NIM_ACL_NUMBERED" -gt 0
  test "$NIM_ACL_LINES" -gt 0
fi

# NIM_ACL_SPECIFIC_LECTURE_LINK_AUDIT_V1
python3 tools/audit_atcoder_lecture_links.py
# NIM_ACL_PROBLEM_EXAMPLES_AUDIT_V1
python3 tools/audit_problem_examples.py
# NIM_ACL_DP_OPTIMIZATION_AUDIT_V1
python3 tools/audit_dp_optimization.py
# NIM_ACL_CURATED_DOCS_AUDIT_V1
python3 tools/audit_curated_docs.py
# NIM_ACL_PERSISTENT_SEGTREE_API_AUDIT_V1
python3 tools/audit_persistent_segment_tree_api.py
# NIM_ACL_TUNING_PARAMETER_DOC_AUDIT_V1
python3 tools/audit_tuning_parameters.py
# NIM_ACL_JAPANESE_FACADE_AUDIT_V1
python3 tools/audit_japanese_facades.py

# NIM_ACL_NIM_VERSION_MATRIX_AUDIT_V1
python3 tools/audit_nim_version_matrix.py

