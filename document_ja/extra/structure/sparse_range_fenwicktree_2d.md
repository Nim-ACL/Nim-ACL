# `sparse_range_fenwicktree_2d`

`atcoder/extra/structure/sparse_range_fenwicktree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## インポート

```nim
import atcoder/extra/structure/sparse_range_fenwicktree_2d
```

## 2D API 規約

二次元サイズは `(height, width)`、添字・範囲は `(row, col)` の順で扱います。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `type` | `SparseRangeFenwickTree2D` | 7 |
| `proc` | `initSparseRangeFenwickTree2D` | 15 |
| `proc` | `add` | 132 |
| `proc` | `sum` | 177 |
| `proc` | `get` | 215 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/sparse_range_fenwicktree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/sparse_range_fenwicktree_2d.nim`
