# Compile both orders with -d:rhReverseImports, including expanded sources.
when defined(rhReverseImports):
  import atcoder/extra/string/rolling_hash
  import std/[hashes, sets, tables, random]
else:
  import std/[hashes, sets, tables, random]
  import atcoder/extra/string/rolling_hash

const HashMod = (1'u shl 61) - 1

# An independent oracle: no multRaw/calcMod, and no overflowing products.
proc expectedHash(text: string, base: uint): uint =
  for c in text:
    var x = result
    var multiplier = base
    result = 0
    while multiplier != 0:
      if (multiplier and 1'u) != 0:
        result = (result + x) mod HashMod
      x = (x + x) mod HashMod
      multiplier = multiplier shr 1
    result = (result + uint(c)) mod HashMod

proc checkScalarHash() =
  var keys = initHashSet[RH_Base]()
  var values = initTable[RH_Base, int]()
  var words = @[0'u, 1'u, HashMod - 1, HashMod, HashMod + 1, high(uint)]
  var rng = initRand(20261116)
  for i in 0 ..< 1000:
    words.add(uint(rng.next()))
  for i, word in words:
    let a = RH_Base(word)
    let equal = RH_Base(word)
    doAssert a == equal
    doAssert hash(a) == hash(equal)
    doAssert hash(a) == hash(word)
    keys.incl(a)
    values[a] = i
    doAssert equal in keys
    doAssert values[equal] == i
    values[equal] = -i
    doAssert values[a] == -i
  # Equality is on the stored word, without an implicit modular reduction.
  doAssert RH_Base(0'u) != RH_Base(HashMod)
  doAssert RH_Base(1'u) != RH_Base(HashMod + 1)
  for word in words:
    keys.excl(RH_Base(word))
  doAssert keys.len == 0

proc checkValue(part: PartialRollingHash, text: string, base: uint) =
  doAssert part.len == text.len
  doAssert uint(part.h) == expectedHash(text, base)

proc checkConcatenation(base: static[uint]) =
  let empty = initRollingHash("", base)[0 ..< 0]
  checkValue(empty, "", base)
  var samples = @["", "a", "abracadabra", "\0", "\0\xffa\0", "日本語"]
  var rng = initRand(37)
  for i in 0 ..< 120:
    var s = newString(rng.rand(32))
    for c in s.mitems:
      c = char(rng.rand(255))
    samples.add(s)
  for text in samples:
    let whole = initRollingHash(text, base)
    doAssert whole.len == text.len
    checkValue(whole[0 .. ^1], text, base)
    doAssert (empty & text) == whole[0 .. ^1]
    doAssert (text & empty) == whole[0 .. ^1]
    for unused in 0 ..< 8:
      let l = rng.rand(text.len)
      let r = l + rng.rand(text.len - l)
      let part = whole[l ..< r]
      let middle = text[l ..< r]
      let prefix = samples[rng.rand(samples.high)]
      let suffix = samples[rng.rand(samples.high)]
      let before = part
      checkValue(part, middle, base)
      checkValue(part & suffix, middle & suffix, base)
      checkValue(prefix & part, prefix & middle, base)
      checkValue((prefix & part) & suffix, prefix & middle & suffix, base)
      checkValue(prefix & (part & suffix), prefix & middle & suffix, base)
      doAssert part == before
      doAssert (part & "") == part
      doAssert ("" & part) == part
      doAssert (whole[0 ..< l] & part & whole[r ..< text.len]) == whole[0 .. ^1]
      for c in [char(0), 'x', char(255)]:
        checkValue(part & c, middle & c, base)
        checkValue(c & part, c & middle, base)
        checkValue(part & ord(c), middle & c, base)
        var appended = part
        appended &= c
        doAssert appended == (part & c)

  type Part = PartialRollingHash[base]
  var keys = initHashSet[Part]()
  var values = initTable[Part, int]()
  let nul = initRollingHash("\0", base)[0 ..< 1]
  # Equal scalar hashes need not mean equal partial hashes: length matters.
  doAssert empty.h == nul.h
  doAssert empty != nul
  keys.incl(empty)
  keys.incl(nul)
  values[empty] = 1
  values[nul] = 2
  doAssert keys.len == 2
  doAssert values[empty] == 1 and values[nul] == 2
  let a = initRollingHash("zabcz", base)[1 ..< 4]
  let b = initRollingHash("abc", base)[0 ..< 3]
  doAssert a == b
  doAssert hash(a) == hash(b)
  keys.incl(a)
  doAssert b in keys
  doAssert LCP(initRollingHash("abcx", base), initRollingHash("abcy", base),
               0 ..< 4, 0 ..< 4) == 3
  doAssert LCP(initRollingHash("", base), initRollingHash("abc", base),
               0 ..< 0, 0 ..< 3) == 0

proc checkLarge() =
  const base = 37'u
  var text = newString(200_000)
  for i in 0 ..< text.len:
    text[i] = char((i * 131 + 17) mod 256)
  let whole = initRollingHash(text, base)[0 .. ^1]
  var suffixes = initRollingHash("", base)[0 ..< 0]
  var prefixes = suffixes
  const chunk = 4096
  for l in countup(0, text.high, chunk):
    suffixes = suffixes & text[l ..< min(l + chunk, text.len)]
  var r = text.len
  while r > 0:
    let l = max(0, r - chunk)
    prefixes = text[l ..< r] & prefixes
    r = l
  doAssert suffixes == whole and prefixes == whole
  checkValue(whole, text, base)

checkScalarHash()
checkConcatenation(1000000007'u)
checkConcatenation(37'u)
checkConcatenation(911382323'u)
checkConcatenation(HashMod - 1)
checkConcatenation(0'u)
checkConcatenation(1'u)
checkLarge()
echo "OK"
