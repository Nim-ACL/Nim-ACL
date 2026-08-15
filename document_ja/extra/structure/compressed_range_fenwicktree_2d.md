# `compressed_range_fenwicktree_2d`

`atcoder/extra/structure/compressed_range_fenwicktree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## インポート

```nim
import atcoder/extra/structure/compressed_range_fenwicktree_2d
```

## 2D API 規約

座標平面上の点は `(x, y)` の順で扱います。矩形範囲を指定する API では x 方向の範囲を先、y 方向の範囲を後に指定します。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `proc` | `initCompressedRangeFenwickTree2D` | 79 |
| `proc` | `add` | 162 |
| `proc` | `sum` | 284 |
| `proc` | `get` | 331 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/compressed_range_fenwicktree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/compressed_range_fenwicktree_2d.nim`
