# `compressed_dual_segtree_2d`

`atcoder/extra/structure/compressed_dual_segtree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## インポート

```nim
import atcoder/extra/structure/compressed_dual_segtree_2d
```

## 2D API 規約

座標平面上の点は `(x, y)` の順で扱います。矩形範囲を指定する API では x 方向の範囲を先、y 方向の範囲を後に指定します。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `proc` | `initCompressedDualSegTree2DBuilder` | 113 |
| `proc` | `addPoint` | 132 |
| `proc` | `build` | 161 |
| `proc` | `pointCount` | 302 |
| `proc` | `containsPoint` | 317 |
| `proc` | `apply` | 417 |
| `proc` | `get` | 515 |
| `proc` | ``[]`` | 609 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/compressed_dual_segtree_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/compressed_dual_segtree_2d.nim`
