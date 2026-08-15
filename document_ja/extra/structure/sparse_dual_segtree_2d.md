# `sparse_dual_segtree_2d`

`atcoder/extra/structure/sparse_dual_segtree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Sparse online rectangle-apply / point-get structure over a huge
fixed `(height, width)` grid.
Update values form a commutative monoid.  Commutativity is required
because a point query combines tags from the Cartesian product of
outer and inner root-to-leaf paths.
Temporary candidate: exact public API is not frozen.

## インポート

```nim
import atcoder/extra/structure/sparse_dual_segtree_2d
```

## 2D API 規約

二次元サイズは `(height, width)`、添字・範囲は `(row, col)` の順で扱います。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `const` | `ATCODER_EXTRA_STRUCTURE_SPARSE_DUAL_SEGTREE_2D_HPP` | 2 |
| `proc` | `initSparseDualSegTree2D` | 360 |
| `proc` | `height` | 389 |
| `proc` | `width` | 398 |
| `proc` | `apply` | 451 |
| `proc` | `get` | 499 |
| `proc` | ``[]`` | 576 |
| `proc` | `debugOuterNodeCount` | 593 |
| `proc` | `debugTotalInnerNodeCount` | 604 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/sparse_dual_segtree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/sparse_dual_segtree_2d.nim`
