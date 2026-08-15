# `offline_rectangle_add_rectangle_sum`

`atcoder/extra/structure/offline_rectangle_add_rectangle_sum` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## インポート

```nim
import atcoder/extra/structure/offline_rectangle_add_rectangle_sum
```

## 2D API 規約
座標平面上の点は `(x, y)` の順で扱います。矩形範囲を指定する API では x 方向の範囲を先、y 方向の範囲を後に指定します。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `const` | `ATCODER_EXTRA_STRUCTURE_OFFLINE_RECTANGLE_ADD_RECTANGLE_SUM_HPP` | 2 |
| `proc` | `initOfflineRectangleAddRectangleSum` | 482 |
| `proc` | `addRectangle` | 540 |
| `proc` | `addRectangleQuery` | 574 |
| `proc` | `queryCount` | 611 |
| `proc` | `solve` | 621 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/offline_rectangle_add_rectangle_sum_contract.nim`

## ソース

- `src/atcoder/extra/structure/offline_rectangle_add_rectangle_sum.nim`
