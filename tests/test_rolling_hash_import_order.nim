# Keep the two distinct public representations qualified in both import orders.
when defined(rhReverseImports):
  import atcoder/extra/string/rolling_hash_old as legacy
  import atcoder/extra/string/rolling_hash as modern
else:
  import atcoder/extra/string/rolling_hash as modern
  import atcoder/extra/string/rolling_hash_old as legacy

for text in ["", "a", "abracadabra", "\0\xffa\0", "日本語"]:
  let current = modern.initRollingHash(text)
  let old = legacy.initRollingHash(text)
  for l in 0 .. text.len:
    for r in l .. text.len:
      let a = modern.`[]`(current, l ..< r)
      let b = legacy.`[]`(old, l ..< r)
      doAssert uint(a.h) == b.h
      doAssert modern.hash(a.h) == legacy.hash(b)
  let p = modern.`[]`(current, 0 .. ^1)
  doAssert modern.`==`(modern.`&`("", p), modern.`&`(p, ""))
let custom = modern.initRollingHash("ab", 37'u)[0 .. ^1]
let combined = modern.`&`("x", modern.`&`(custom, "y"))
doAssert modern.`==`(combined, modern.initRollingHash("xaby", 37'u)[0 .. ^1])
echo "OK"
