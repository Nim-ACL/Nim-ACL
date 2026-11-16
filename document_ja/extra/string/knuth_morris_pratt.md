# KnuthMorrisPrattの旧API互換入口

検索本体は[kmp](./kmp.html)に統合されています。
このmoduleは既存のimport pathと関数名・引数順を維持する薄い互換層です。

## API

~~~nim
proc KnuthMorrisPratt(t, p: string): seq[int]
~~~

## 使用例

~~~nim
import atcoder/extra/string/knuth_morris_pratt

doAssert KnuthMorrisPratt("ababa", "aba") == @[0, 2]
~~~

第1引数tがtext、第2引数pがpatternです。重なる一致もすべて返します。
文字列はbyte単位で比較し、返り値は0始まりのbyte位置です。
空textは空の結果を返し、従来の `KnuthMorrisPratt("", "") == @[]` も維持します。
textが空でない場合、patternは空にできません。

長さnのtext・長さmのpatternに対して `O(n + m)` 時間、
matcherの `O(m)` と一致位置の `O(k)` の領域を使います。
新規コードや同じpatternで繰り返し検索する場合は `initKMP(p)` を使ってください。
