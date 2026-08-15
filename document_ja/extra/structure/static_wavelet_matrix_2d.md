# `static_wavelet_matrix_2d`

`atcoder/extra/structure/static_wavelet_matrix_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Builds a static multiset of two-dimensional integer points.
Duplicate points are retained as distinct records.

## インポート

```nim
import atcoder/extra/structure/static_wavelet_matrix_2d
```

## 2D API 規約

座標平面上の点は `(x, y)` の順で扱います。矩形範囲を指定する API では x 方向の範囲を先、y 方向の範囲を後に指定します。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `type` | `StaticWaveletMatrix2D` | 12 |
| `proc` | `initStaticWaveletMatrix2D` | 48 |
| `proc` | `pointCount` | 107 |
| `proc` | `rangeFreq` | 141 |
| `proc` | `kthSmallest` | 171 |
| `proc` | `kthLargest` | 200 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/static_wavelet_matrix_2d_contract.nim`

## ソース

- `src/atcoder/extra/structure/static_wavelet_matrix_2d.nim`
