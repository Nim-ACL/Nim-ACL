# compress

HashSet で重複を除いてから異なる値だけをソートする、legacy の座標圧縮 API です。
戻り値は `seq[T]` と同じ表現です。複数の seq をまとめて構築できます。
header や標準ライブラリを別に import する必要はありません。

## import

    import atcoder/extra/other/compress

## 公開 API

    const ATCODER_COMPRESS_HPP* = 1
    proc build*[T](v:var Compress[T]) =
    proc initCompress*[T](a:varargs[seq[T]]):Compress[T] =
    proc id*[T](c:Compress[T], a:T):int =
    proc `{}`*[T](c:Compress[T], a:T):int = c.id(a)
    proc val*[T](c:Compress[T], i:int):T = c[i]

## 概要

`initCompress[T](a: varargs[seq[T]])` は各入力を連結し、昇順・重複なしの seq を返します。
引数がない場合も空 seq を返します。`Compress[T]` はモジュール内部の seq 別名で、
型名自体は export していません。戻り値には `len`、`[]`、反復、`add` などの seq 操作を使えます。

`build(v)` は通常の `seq[T]` にも使え、生成を別 seq で完了してから `v` を置き換えます。
検索の前には昇順に整列しておく必要があります。

| API | 契約 |
|---|---|
| `id(c, a)` / `c{a}` | 標準 `binarySearch` が返す一致位置。欠損時は `assert` |
| `val(c, i)` | `c[i]` と同じ。範囲検査が有効なら不正添字は `IndexDefect` |

欠損時のメッセージには `Error: No such value:` と値を含みます。
`--assertions:off` では欠損時に `-1` を返します。
構築には T の hash・等値比較・順序比較が必要です。
`id` / `{}` は assertion が有効な場合、診断用の `$` も必要とします。

## 使用例

```nim
import atcoder/extra/other/compress

var c = initCompress[int](@[100, -5, 100], @[7, -5])
doAssert c == @[-5, 7, 100]
doAssert c{7} == 1
doAssert c.val(2) == 100

c.add -10
c.build()
doAssert c == @[-10, -5, 7, 100]
```

## 注意

総入力長を n、異なる値の個数を u とすると、ハッシュ操作を期待 O(1) として、
構築は **期待 O(n + u log u)** です。入力全体 n 個をソートする形には変えていません。
検索は O(log u)、`val` は O(1)、結果の保存領域は O(u) です。
構築時の一時領域は O(n + u) です。標準 HashSet は入力長 n を基準に容量を確保します。

## 新 API との違い

[CoordinateCompression](../algorithm/coordinate_compression.md) は object と公開 `values` を持ち、
hash を使わず入力全体をソートする O(n log n) の構築を行います。
hash を持たない順序型にも使えます。境界検索は `<` のみで利用できます。

両 API の型・構築法・欠損時の契約を維持するため、一方を他方の型別名にはしていません。
legacy の検索は標準 `binarySearch` へ委譲しています。
手動で重複を含む整列 seq を渡した場合、一致位置は必ずしも先頭ではありません。
新 API の `indexOf` は最初の一致位置を返すため、単純な置き換えは互換になりません。

## 検証

- `tests/test_compress_contract.nim`
- `tests/test_compress_legacy_standalone.nim`
- `tests/test_compress_header.nim`
- `tools/bench_compress.nim`
