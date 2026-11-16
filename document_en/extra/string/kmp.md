# KMP / Prefix Function

KMP searches for a pattern in linear time by reusing previous match information through the prefix function.

## Import and API

~~~nim
import atcoder/extra/string/kmp

proc prefixFunction(s): seq[int]
proc initKMP(pattern): KMPMatcher
proc findAll(matcher, text): seq[int]
proc findFirst(matcher, text): int
proc countMatches(matcher, text): int
~~~

## Example

~~~nim
let matcher = initKMP("aba")

doAssert matcher.findAll("ababa") == @[0, 2]
doAssert matcher.findFirst("zzabazz") == 2
~~~

## Complexity

- preprocessing: `O(m)`
- search: `O(n)`; `findFirst` / `contains` stop at the first match
- matcher storage: `O(m)`
- extra search storage: `O(k)` for `findAll` with k matches, `O(1)` otherwise

The string overloads view the text without copying it to a character sequence.
Patterns must be non-empty; empty texts are supported. The legacy
`KnuthMorrisPratt(text, pattern)` entry point delegates to the same scanner.

<!-- NIM_ACL_PROBLEM_EXAMPLES_V1 -->
## Practice problems

<details class="problem-examples">
<summary>Show problems that can use this library (may reveal the intended technique)</summary>
<ul>
  <li><a href="https://atcoder.jp/contests/abc257/tasks/abc257_g" target="_blank" rel="noopener">AtCoder Beginner Contest 257 G - Prefix Concatenation</a></li>
</ul>
</details>
<!-- /NIM_ACL_PROBLEM_EXAMPLES_V1 -->
