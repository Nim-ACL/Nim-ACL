# `offline_rectangle_add_point_get`

`atcoder/extra/structure/offline_rectangle_add_point_get` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Constructs an offline rectangle-add and point-get
event solver.
Initial rectangles are active before the first
registered event.

## インポート

```nim
import atcoder/extra/structure/offline_rectangle_add_point_get
```

## 2D API 規約
座標平面上の点は `(x, y)` の順で扱います。矩形範囲を指定する API では x 方向の範囲を先、y 方向の範囲を後に指定します。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `const` | `ATCODER_EXTRA_STRUCTURE_OFFLINE_RECTANGLE_ADD_POINT_GET_HPP` | 2 |
| `proc` | `initOfflineRectangleAddPointGet` | 52 |
| `proc` | `addRectangle` | 105 |
| `proc` | `addPointQuery` | 139 |
| `proc` | `queryCount` | 168 |
| `proc` | `solve` | 178 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/offline_rectangle_add_point_get_contract.nim`

## ソース

- `src/atcoder/extra/structure/offline_rectangle_add_point_get.nim`
