import std/[math, random, unittest]
import atcoder/extra/other/divutils

# Use the independent standard-library floor operations as the signed oracle.
proc verifySigned[T: SomeSignedInt](a, b: T) =
  if a == low(T) and b == -1:
    expect OverflowDefect:
      discard divutils.ceilDiv(a, b)
    doAssert ceilMod(a, b) == 0
    return
  let
    r = floorMod(a, b)
    wantQ = floorDiv(a, b) + T(ord(r != 0))
    wantR = if r == 0: T(0) else: r - b
  doAssert divutils.ceilDiv(a, b) == wantQ
  doAssert ceilMod(a, b) == wantR
  doAssert (a /^ b) == wantQ
  doAssert (a %^ b) == wantR
  doAssert (a /. b) == floorDiv(a, b)
  doAssert (a %. b) == r

proc signedBoundaries[T: SomeSignedInt]() =
  let values = [low(T), low(T) + 1, T(-7), T(-2), T(-1),
                T(0), T(1), T(2), T(7), high(T) - 1, high(T)]
  for a in values:
    for b in values:
      if b != 0: verifySigned(a, b)
  expect AssertionDefect:
    discard divutils.ceilDiv(T(1), T(0))
  expect AssertionDefect:
    discard ceilMod(T(1), T(0))

proc unsignedBoundaries[T: SomeUnsignedInt]() =
  doAssert divutils.ceilDiv(high(T), T(2)) == high(T) div 2 + 1
  doAssert divutils.ceilDiv(high(T), high(T)) == 1
  doAssert divutils.ceilDiv(T(0), T(1)) == 0
  doAssert divutils.ceilDiv(T(1), high(T)) == 1
  doAssert divutils.ceilDiv(high(T) - 1, T(2)) == (high(T) - 1) div 2
  doAssert ceilMod(T(0), high(T)) == 0
  doAssert ceilMod(high(T), high(T)) == 0
  expect RangeDefect:
    discard ceilMod(T(1), T(2))
  expect AssertionDefect:
    discard divutils.ceilDiv(T(1), T(0))
  expect AssertionDefect:
    discard ceilMod(T(1), T(0))

suite "overflow-safe division utilities":
  test "all signed widths and extreme divisors":
    signedBoundaries[int8]()
    signedBoundaries[int16]()
    signedBoundaries[int32]()
    signedBoundaries[int64]()
    signedBoundaries[int]()

  test "all unsigned widths and unrepresentable ceiling remainder":
    unsignedBoundaries[uint8]()
    unsignedBoundaries[uint16]()
    unsignedBoundaries[uint32]()
    unsignedBoundaries[uint64]()
    unsignedBoundaries[uint]()

  test "exhaustive int8 against widened mathematical reference":
    for a in -128 .. 127:
      for b in -128 .. 127:
        if b == 0: continue
        let wantQ = int(ceil(float(a) / float(b)))
        let wantR = a - wantQ * b
        if wantQ > 127:
          expect OverflowDefect:
            discard divutils.ceilDiv(int8(a), int8(b))
        else:
          doAssert int(divutils.ceilDiv(int8(a), int8(b))) == wantQ
        doAssert int(ceilMod(int8(a), int8(b))) == wantR

  test "full-width random signed differential checks":
    var rng = initRand(20261116)
    for i in 0 ..< 20_000:
      let a = cast[int64](rng.next())
      let b = cast[int64](rng.next())
      if b != 0: verifySigned(a, b)
      # Small divisors exercise large quotients and rounding near the limits.
      let small = int64(rng.rand(-100 .. 100))
      if small != 0: verifySigned(a, small)

  test "random unsigned quotients match floating reference in exact range":
    var rng = initRand(1162026)
    for i in 0 ..< 10_000:
      let a = uint64(rng.rand(0 .. 1_000_000))
      let b = uint64(rng.rand(1 .. 1_000_000))
      doAssert divutils.ceilDiv(a, b) == uint64(ceil(float(a) / float(b)))
