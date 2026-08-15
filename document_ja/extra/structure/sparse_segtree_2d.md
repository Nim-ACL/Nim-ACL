# `sparse_segtree_2d`

`atcoder/extra/structure/sparse_segtree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## インポート

```nim
import atcoder/extra/structure/sparse_segtree_2d
```

## 2D API 規約

二次元サイズは `(height, width)`、添字・範囲は `(row, col)` の順で扱います。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `const` | `ATCODER_EXTRA_STRUCTURE_SPARSE_SEGTREE_2D_HPP` | 2 |
| `proc` | `initSparseSegTree2D` | 607 |
| `proc` | `height` | 636 |
| `proc` | `width` | 645 |
| `proc` | `set` | 698 |
| `proc` | `get` | 734 |
| `proc` | `prod` | 804 |
| `proc` | `allProd` | 847 |
| `proc` | ``[]`` | 861 |
| `proc` | ``[]=`` | 875 |
| `proc` | `debugOuterNodeCount` | 895 |
| `proc` | `debugTotalInnerNodeCount` | 906 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/sparse_segtree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/sparse_segtree_2d.nim`
