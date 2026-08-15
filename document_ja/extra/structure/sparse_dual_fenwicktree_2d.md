# `sparse_dual_fenwicktree_2d`

`atcoder/extra/structure/sparse_dual_fenwicktree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Builds a fixed-size sparse two-dimensional dual Fenwick tree.
Rectangle additions are represented by a sparse two-dimensional
difference surface. Only touched internal Fenwick nodes are stored.

## インポート

```nim
import atcoder/extra/structure/sparse_dual_fenwicktree_2d
```

## 2D API 規約

二次元サイズは `(height, width)`、添字・範囲は `(row, col)` の順で扱います。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `proc` | `initSparseDualFenwickTree2D` | 13 |
| `proc` | `height` | 37 |
| `proc` | `width` | 46 |
| `proc` | `add` | 55 |
| `proc` | `get` | 118 |
| `proc` | ``[]`` | 143 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/sparse_dual_fenwicktree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/sparse_dual_fenwicktree_2d.nim`
