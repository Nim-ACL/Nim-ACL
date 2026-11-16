# `sparse_range_fenwicktree_2d`

`atcoder/extra/structure/sparse_range_fenwicktree_2d` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## インポート

```nim
import atcoder/extra/structure/sparse_range_fenwicktree_2d
```

## 2D API 規約

二次元サイズは `(height, width)`、添字・範囲は `(row, col)` の順で扱います。

## dense 版との共通処理と格納方式

両版とも `initDenseRangeFenwickTree2D[T]` / `initSparseRangeFenwickTree2D[T]`
で構築し、`add(rowBegin, rowEnd, colBegin, colEnd, delta)`、
`sum(rowBegin, rowEnd, colBegin, colEnd)`、`get(row, col)` を使います。
矩形は半開区間です。空範囲への加算は何もせず、空範囲の和は `T(0)` です。
公開型は別々で、相互変換や型の別名化は行いません。

| 特性 | dense 版 | sparse 版 |
|---|---|---|
| 内部格納 | 二次元配列 4 本 | ハッシュテーブル 4 個 |
| 初期化 | O((H+1)(W+1)) | O(1) |
| 矩形加算・矩形和・一点取得 | O(log(H+1) log(W+1)) | 期待 O(log(H+1) log(W+1)) |
| メモリ | 4(H+1)(W+1) 個の T と行管理領域 | 更新で触れた内部節点分。ハッシュ管理領域を含む |

表の対数計算量は H, W > 0 の場合です。空範囲の操作は O(1) です。

sparse 版の節点数は、矩形更新回数を k とすると
O(min(HW, k log(H+1) log(W+1))) です。読み取りでは節点を追加しません。
格子全体を使う場合は dense 版がハッシュの費用を避けられます。
巨大な座標領域で更新箇所が少ない場合は sparse 版が適しています。
sparse 版は `high(int)` に近い添字での安全な節点移動も維持しています。

`internal/range_fenwicktree_2d_core.nim` のテンプレートで、四隅の係数、
prefix 和の数式、範囲検査だけを共通化しています。構築処理、格納方式、
Fenwick 木の節点移動は各バックエンドに残しています。
テンプレートは既存 proc の本体へ展開され、追加の作業バッファや実行時の呼び出し層は作りません。
数値型 T の演算順序と変換順序も従来どおりです。共通化による速度向上は目的としていません。

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `type` | `SparseRangeFenwickTree2D` | 8 |
| `proc` | `initSparseRangeFenwickTree2D` | 16 |
| `proc` | `add` | 65 |
| `proc` | `sum` | 75 |
| `proc` | `get` | 84 |

## 検証

関連する tracked test / contract:

- `tests/extra/structure/sparse_range_fenwicktree_2d_contract.nim`
- `tests/test_range_fenwick_2d_shared.nim`
- `tests/test_extra_range_fenwick_2d_coexistence.nim`

## ソース

- `src/atcoder/extra/structure/sparse_range_fenwicktree_2d.nim`
