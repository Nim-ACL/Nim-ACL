import std/[random, sequtils]
import atcoder/extra/string/kmp
import atcoder/extra/string/knuth_morris_pratt

proc brute(text, pattern: string): seq[int] =
  if pattern.len > text.len: return
  for start in 0 .. text.len - pattern.len:
    if text[start ..< start + pattern.len] == pattern: result.add(start)

var rng = initRand(208)
for sample in 0 ..< 500:
  var text = newString(rand(rng, 0 .. 50))
  var pattern = newString(rand(rng, 1 .. 12))
  for c in text.mitems: c = char(rand(rng, 0 .. 3))
  for c in pattern.mitems: c = char(rand(rng, 0 .. 3))
  let expected = brute(text, pattern)
  let matcher = initKMP(pattern)
  doAssert KnuthMorrisPratt(t = text, p = pattern) == expected
  doAssert matcher.findAll(text) == expected
  doAssert matcher.countMatches(text) == expected.len
  doAssert matcher.findFirst(text) == (if expected.len == 0: -1 else: expected[0])
  doAssert matcher.contains(text) == (expected.len > 0)

doAssert prefixFunction("") == @[]
doAssert initKMP("abc").findAll("") == @[]
doAssert initKMP("abc").findFirst("") == -1
doAssert initKMP("abc").countMatches("") == 0
doAssert not initKMP("abc").contains("")
doAssert KnuthMorrisPratt("", "") == @[]
doAssert KnuthMorrisPratt("", "abc") == @[]
doAssert KnuthMorrisPratt("aaaaa", "aa") == @[0, 1, 2, 3]
doAssert KnuthMorrisPratt("あああ", "ああ") == @[0, 3]
let legacy: proc(t, p: string): seq[int] = KnuthMorrisPratt
doAssert legacy("ababa", "aba") == @[0, 2]
var rejected = false
try:
  discard initKMP("")
except AssertionDefect:
  rejected = true
doAssert rejected

# Detect a full-text scan in first-match and membership queries.
type Probe = object
  value: int
var comparisons = 0
proc `==`(a, b: Probe): bool =
  comparisons.inc
  a.value == b.value
let matcher = initKMP(@[Probe(value: 1)])
let text = newSeqWith(10000, Probe(value: 1))
comparisons = 0
doAssert matcher.findFirst(text) == 0
doAssert comparisons == 1
comparisons = 0
doAssert matcher.contains(text)
doAssert comparisons == 1
doAssert matcher.countMatches(text) == text.len

echo "KMP legacy/canonical compatibility and early exit OK"
