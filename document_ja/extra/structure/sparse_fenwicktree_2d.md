# `sparse_fenwicktree_2d`

`atcoder/extra/structure/sparse_fenwicktree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Builds a fixed-size sparse two-dimensional Fenwick tree.
The logical grid has size (height, width). Storage is allocated
only for internal Fenwick nodes touched by point additions.

## インポート

```nim
import atcoder/extra/structure/sparse_fenwicktree_2d
```

## 2D API 規約

二次元サイズは `(height, width)`、添字・範囲は `(row, col)` の順で扱います。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `proc` | `initSparseFenwickTree2D` | 27 |
| `proc` | `height` | 60 |
| `proc` | `width` | 69 |
| `proc` | `add` | 95 |
| `proc` | `prefixSum` | 164 |
| `proc` | `sum` | 208 |
| `proc` | `get` | 249 |
| `proc` | `allSum` | 273 |
| `proc` | ``[]`` | 287 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/sparse_fenwicktree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/sparse_fenwicktree_2d.nim`
