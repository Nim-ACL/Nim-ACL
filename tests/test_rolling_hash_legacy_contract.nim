import std/[hashes, sets, tables]
import atcoder/extra/string/rolling_hash_old

const HashMod = (1'u shl 61) - 1

proc expectedHash(text: string): uint =
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

var keys = initHashSet[RH]()
var values = initTable[RH, int]()
for i, word in [0'u, 1'u, HashMod - 1, HashMod, high(uint)]:
  let a = RH(h: word)
  let b = RH(h: word)
  doAssert a == b
  doAssert hash(a) == hash(b) and hash(a) == hash(word)
  keys.incl(a)
  values[a] = i
  doAssert b in keys and values[b] == i
doAssert toRH('a').h == uint('a')
doAssert toRH(123).h == 123'u

for text in ["", "a", "abracadabra", "\0\xffa\0", "日本語"]:
  let rh = initRollingHash(text)
  doAssert rh.len == text.len
  doAssert rh[0 .. ^1].h == expectedHash(text)
  var appended = RH(h: 0)
  for c in text:
    appended &= c
  doAssert appended == rh[0 .. ^1]
  for l in 0 .. text.len:
    for r in l .. text.len:
      doAssert rh[l ..< r].h == expectedHash(text[l ..< r])
    doAssert rh.connect(rh[0 ..< l].h, rh[l ..< text.len].h, text.len - l) == rh[0 .. ^1]
doAssert LCP(initRollingHash("abcx"), initRollingHash("abcy"), 0 ..< 4, 0 ..< 4) == 3
doAssert LCP(initRollingHash(""), initRollingHash("abc"), 0 ..< 0, 0 ..< 3) == 0
echo "OK"
