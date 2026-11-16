# KMP / Prefix Function

KMP は、pattern を text 内から線形時間で検索するアルゴリズムです。

一致に失敗したとき、pattern の先頭から比較をやり直すのではなく、それまでの一致情報を `prefix function` から再利用します。

## 使いどころ

- 文字列内の pattern 検索
- 重なりを許した全出現位置の列挙
- 文字列の周期・border の検出
- prefix と suffix の関係を使う問題
- 一般 sequence の部分列検索

## Prefix Function

`prefixFunction(s)[i]` は、`s[0 .. i]` の proper prefix であり suffix でもある最長文字列の長さです。

例えば比較に失敗したとき、この値をたどることで、すでに分かっている一致部分を捨てずに次の比較位置を決められます。

## import

~~~nim
import atcoder/extra/string/kmp
~~~

## API

~~~nim
proc prefixFunction[T](s: openArray[T]): seq[int]
proc prefixFunction(s: string): seq[int]

proc initKMP[T](pattern: openArray[T]): KMPMatcher[T]
proc initKMP(pattern: string): KMPMatcher[char]

proc findAll(matcher, text): seq[int]
proc findFirst(matcher, text): int
proc countMatches(matcher, text): int
proc contains(matcher, text): bool
~~~

pattern は空にできません。

## 使用例

<!-- nim-line-numbers -->
~~~nim
let matcher = initKMP("aba")

doAssert matcher.findAll("ababa") == @[0, 2]
doAssert matcher.findFirst("zzabazz") == 2
doAssert matcher.countMatches("abababa") == 3
doAssert "xxabayy" in matcher
~~~

整数列などにも使えます。

~~~nim
let matcher = initKMP(@[1, 2, 1])

doAssert matcher.findAll(@[1, 2, 1, 2, 1]) == @[0, 2]
~~~

## 計算量

pattern 長を `m`、text 長を `n` とすると、

- 前処理: `O(m)`
- 検索: `O(n)`（`findFirst` / `contains` は最初の一致で終了）
- matcherの保存領域: `O(m)`
- 検索の追加領域: `findAll` は一致数kに対して `O(k)`、その他は `O(1)`

string版もtext全体をchar列へコピーしません。空textの検索に対応します。
旧 `KnuthMorrisPratt(text, pattern)` は同じ検索実装へ委譲します。

<!-- NIM_ACL_PROBLEM_EXAMPLES_V1 -->
## このライブラリが使える問題

<details class="problem-examples">
<summary>問題例を表示する（解法のネタバレを含む可能性があります）</summary>
<ul>
  <li><a href="https://atcoder.jp/contests/abc257/tasks/abc257_g" target="_blank" rel="noopener">AtCoder Beginner Contest 257 G - Prefix Concatenation</a></li>
</ul>
</details>
<!-- /NIM_ACL_PROBLEM_EXAMPLES_V1 -->

## 関連資料・他言語ライブラリ

- [cp-algorithms: Prefix Function](https://cp-algorithms.com/string/prefix-function.html)
- KACTL: KMP
- Nyaan Library: KMP
