import atcoder/extra/numeric/int128

proc checkMixed[W: UInt128 or Int128; I: SomeInteger](a: W, b: I, order: int) =
  doAssert (a == b) == (order == 0)
  doAssert (a != b) == (order != 0)
  doAssert (a < b) == (order < 0)
  doAssert (a <= b) == (order <= 0)
  doAssert (a > b) == (order > 0)
  doAssert (a >= b) == (order >= 0)
  doAssert cmp(a, b) == order
  doAssert (b == a) == (order == 0)
  doAssert (b != a) == (order != 0)
  doAssert (b < a) == (order > 0)
  doAssert (b <= a) == (order >= 0)
  doAssert (b > a) == (order < 0)
  doAssert (b >= a) == (order <= 0)
  doAssert cmp(b, a) == -order
  # Retain the existing explicit generic calls and converter behavior.
  doAssert `<=`[W](a, W(b)) == (order <= 0)
  doAssert `>`[W](a, W(b)) == (order > 0)
  doAssert `>=`[W](a, W(b)) == (order >= 0)
  doAssert int128.cmp[W](a, W(b)) == order

proc checkIntegerType[I: SomeInteger](_: typedesc[I]) =
  let signedMin = parseInt128("-170141183460469231731687303715884105728")
  let signedMax = parseInt128("170141183460469231731687303715884105727")
  let unsignedMax = parseUInt128("340282366920938463463374607431768211455")
  checkMixed(toInt128(0), I(0), 0)
  checkMixed(toInt128(-1), I(0), -1)
  checkMixed(signedMin, low(I), -1)
  checkMixed(signedMin, high(I), -1)
  checkMixed(signedMax, low(I), 1)
  checkMixed(signedMax, high(I), 1)
  checkMixed(toInt128(low(I)), low(I), 0)
  checkMixed(toInt128(high(I)), high(I), 0)
  checkMixed(toUInt128(0), I(0), 0)
  checkMixed(toUInt128(0), high(I), -1)
  checkMixed(unsignedMax, high(I), 1)
  when I is SomeSignedInt:
    checkMixed(toInt128(0), I(-1), 1)
    checkMixed(toInt128(-2), I(-1), -1)
    # Conversion of negative native integers to UInt128 still wraps modulo 2^128.
    checkMixed(toUInt128(0), I(-1), -1)
    checkMixed(unsignedMax, I(-1), 0)
  for i in 0 .. 100:
    checkMixed(toInt128(i - 50), I(i), -1)
    checkMixed(toInt128(i + 1), I(i), 1)
    checkMixed(toUInt128(i + 1), I(i), 1)

checkIntegerType(int8)
checkIntegerType(int16)
checkIntegerType(int32)
checkIntegerType(int64)
checkIntegerType(int)
checkIntegerType(uint8)
checkIntegerType(uint16)
checkIntegerType(uint32)
checkIntegerType(uint64)
checkIntegerType(uint)

block sameTypeBoundaries:
  let lo = parseInt128("-170141183460469231731687303715884105728")
  let hi = parseInt128("170141183460469231731687303715884105727")
  doAssert lo < toInt128(0) and lo <= hi and hi > lo and hi >= lo
  doAssert int128.cmp[Int128](lo, hi) == -1
  let top = parseUInt128("170141183460469231731687303715884105728")
  let maximum = parseUInt128("340282366920938463463374607431768211455")
  doAssert top > toUInt128(0) and top <= maximum and maximum >= top
  doAssert int128.cmp[UInt128](top, maximum) == -1

static:
  # Direct Int128/UInt128 comparison was ambiguous and still needs an explicit
  # choice of signed/unsigned interpretation; this fix does not add that API.
  doAssert not compiles(toInt128(-1) < toUInt128(0))

echo "INT128_MIXED_COMPARISONS=PASS"
