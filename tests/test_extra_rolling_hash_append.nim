import atcoder/extra/string/rolling_hash

const HashMod = (1'u shl 61) - 1

# Repeated doubling keeps the oracle independent of multRaw/calcMod.
# Both addends stay below HashMod, so the additions fit in uint64.
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

proc checkAppends(base: static[uint]) =
  var part = initRollingHash("", base)[0 ..< 0]
  var text = ""
  doAssert part.len == 0
  doAssert uint(part.h) == 0

  for c in "abracadabra":
    let original = part
    let byChar = part & c
    let byInt = part & ord(c)
    doAssert part == original
    part &= c
    text.add(c)
    doAssert part.len == text.len
    doAssert uint(part.h) == expectedHash(text, base)
    doAssert part == initRollingHash(text, base)[0 ..< text.len]
    doAssert byChar == part
    doAssert byInt == part

  var byInts = initRollingHash("", base)[0 ..< 0]
  var bytes = ""
  for value in [0, 65, 255, 97]:
    byInts &= value
    bytes.add(char(value))
    doAssert byInts.len == bytes.len
    doAssert uint(byInts.h) == expectedHash(bytes, base)
    doAssert byInts == initRollingHash(bytes, base)[0 ..< bytes.len]

  var slice = initRollingHash("zabz", base)[1 ..< 3]
  slice &= 'c'
  doAssert slice.len == 3
  doAssert uint(slice.h) == expectedHash("abc", base)
  doAssert slice == initRollingHash("abc", base)[0 ..< 3]

checkAppends(1000000007'u)
checkAppends(37'u)
echo "OK"
