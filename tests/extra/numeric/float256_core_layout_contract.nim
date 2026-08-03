import atcoder/extra/numeric/float256

type
  RefBits =
    array[4, uint64]

  RefClass =
    enum
      rZero
      rSubnormal
      rNormal
      rInfinity
      rQuietNaN
      rSignalingNaN

const
  GeneratedCaseCount =
    4096

  ExpectedPublicSymbolCount =
    40

  SplitMixSeed =
    0x0000f256c0de4096'u64

  ExpectedGeneratorFinalState =
    0x9b4c11ce9dee0096'u64

  ExpectedGeneratorChecksum =
    0x9834c3431a764c7e'u64

  BaseEncodings:
    array[24, RefBits] = [
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x8000000000000000'u64],
    [0x0000000000000001'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64],
    [0x0000000000000001'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x8000000000000000'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0x00000fffffffffff'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0x80000fffffffffff'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000100000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x8000100000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x3ffff00000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0xbffff00000000000'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0x7fffefffffffffff'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffefffffffffff'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x7ffff00000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0xfffff00000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x7ffff80000000000'u64],
    [0x0000000000000000'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0xfffff80000000000'u64],
    [0x0000000000000001'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0x7ffff00000000000'u64],
    [0x0000000000000001'u64, 0x0000000000000000'u64, 0x0000000000000000'u64, 0xfffff00000000000'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0x7fffffffffffffff'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0x7ffff7ffffffffff'u64],
    [0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xffffffffffffffff'u64, 0xfffff7ffffffffff'u64],
    [0xaa55aa55aa55aa55'u64, 0x55aa55aa55aa55aa'u64, 0x0fedcba987654321'u64, 0x400106789abcdef0'u64],
    [0xaa55aa55aa55aa55'u64, 0x55aa55aa55aa55aa'u64, 0x0fedcba987654321'u64, 0xc00106789abcdef0'u64],
  ]

# REFERENCE_MODEL_BEGIN

func refGetBit(
    value: RefBits;
    index: int,
): int =
  if index < 0 or index >= 256:
    return 0

  let
    wordIndex =
      index shr 6

    bitIndex =
      index and 63

  if (
    value[wordIndex] and
    (1'u64 shl bitIndex)
  ) != 0'u64:
    1
  else:
    0

proc refAssignBit(
    value: var RefBits;
    index: int;
    bit: int,
) =
  if index < 0 or index >= 256:
    return

  let
    wordIndex =
      index shr 6

    bitIndex =
      index and 63

    mask =
      1'u64 shl bitIndex

  if bit == 0:
    value[wordIndex] =
      value[wordIndex] and
      not mask
  else:
    value[wordIndex] =
      value[wordIndex] or
      mask

func refSame(
    a,
    b: RefBits,
): bool =
  for index in 0 ..< 4:
    if a[index] != b[index]:
      return false

  true

func refSign(
    value: RefBits,
): bool =
  refGetBit(
    value,
    255,
  ) != 0

func refBiasedExponent(
    value: RefBits,
): uint32 =
  for offset in 0 ..< 19:
    if refGetBit(
      value,
      236 + offset,
    ) != 0:
      result =
        result or
        (
          1'u32 shl offset
        )

func refFractionHighBits(
    value: RefBits,
): uint64 =
  for offset in 0 ..< 44:
    if refGetBit(
      value,
      192 + offset,
    ) != 0:
      result =
        result or
        (
          1'u64 shl offset
        )

func refFractionIsZero(
    value: RefBits,
): bool =
  for index in 0 ..< 236:
    if refGetBit(
      value,
      index,
    ) != 0:
      return false

  true

func refClass(
    value: RefBits,
): RefClass =
  let exponent =
    refBiasedExponent(value)

  if exponent == 0'u32:
    if refFractionIsZero(value):
      rZero
    else:
      rSubnormal
  elif exponent != 0x0007_ffff'u32:
    rNormal
  elif refFractionIsZero(value):
    rInfinity
  elif refGetBit(
      value,
      235,
  ) != 0:
    rQuietNaN
  else:
    rSignalingNaN

func refIsNaN(
    value: RefBits,
): bool =
  refClass(value) in {
    rQuietNaN,
    rSignalingNaN,
  }

func refIsZero(
    value: RefBits,
): bool =
  refClass(value) == rZero

func refWithSign(
    value: RefBits;
    negative: bool,
): RefBits =
  result = value

  refAssignBit(
    result,
    255,
    if negative:
      1
    else:
      0,
  )

func refNegateSign(
    value: RefBits,
): RefBits =
  result = value

  refAssignBit(
    result,
    255,
    1 - refGetBit(
      value,
      255,
    ),
  )

func refTotalKeyBit(
    value: RefBits;
    index: int,
): int =
  let bit =
    refGetBit(
      value,
      index,
    )

  if refSign(value):
    1 - bit
  elif index == 255:
    1 - bit
  else:
    bit

func refTotalOrder(
    x,
    y: RefBits,
): bool =
  for index in countdown(255, 0):
    let
      xBit =
        refTotalKeyBit(
          x,
          index,
        )

      yBit =
        refTotalKeyBit(
          y,
          index,
        )

    if xBit < yBit:
      return true

    if xBit > yBit:
      return false

  true

func refMagnitude(
    value: RefBits,
): RefBits =
  refWithSign(
    value,
    false,
  )

func refTotalOrderMag(
    x,
    y: RefBits,
): bool =
  refTotalOrder(
    refMagnitude(x),
    refMagnitude(y),
  )

func refNumericEqual(
    x,
    y: RefBits,
): bool =
  if refIsNaN(x) or
      refIsNaN(y):
    return false

  if refIsZero(x) and
      refIsZero(y):
    return true

  refSame(x, y)

func refNumericLess(
    x,
    y: RefBits,
): bool =
  if refIsNaN(x) or
      refIsNaN(y) or
      refNumericEqual(
        x,
        y,
      ):
    return false

  refTotalOrder(x, y)

func refIncrement(
    value: RefBits,
): RefBits =
  result = value

  var carry = 1

  for index in 0 ..< 256:
    if carry == 0:
      break

    let bit =
      refGetBit(
        result,
        index,
      )

    if bit == 0:
      refAssignBit(
        result,
        index,
        1,
      )

      carry = 0
    else:
      refAssignBit(
        result,
        index,
        0,
      )

func refDecrement(
    value: RefBits,
): RefBits =
  result = value

  var borrow = 1

  for index in 0 ..< 256:
    if borrow == 0:
      break

    let bit =
      refGetBit(
        result,
        index,
      )

    if bit == 0:
      refAssignBit(
        result,
        index,
        1,
      )
    else:
      refAssignBit(
        result,
        index,
        0,
      )

      borrow = 0

func refQuietNaN(
    value: RefBits,
): RefBits =
  result = value

  refAssignBit(
    result,
    235,
    1,
  )

func refNextUp(
    value: RefBits,
): RefBits =
  if refIsNaN(value):
    return value

  if refSame(
      value,
      BaseEncodings[12],
  ):
    return value

  if refIsZero(value):
    result[0] = 1'u64
    return

  if refSign(value):
    refDecrement(value)
  else:
    refIncrement(value)

func refNextDown(
    value: RefBits,
): RefBits =
  if refIsNaN(value):
    return value

  if refSame(
      value,
      BaseEncodings[13],
  ):
    return value

  if refIsZero(value):
    result[0] = 1'u64
    result[3] =
      0x8000_0000_0000_0000'u64
    return

  if refSign(value):
    refIncrement(value)
  else:
    refDecrement(value)

func refNextAfter(
    x,
    y: RefBits,
): RefBits =
  if refIsNaN(x):
    return refQuietNaN(x)

  if refIsNaN(y):
    return refQuietNaN(y)

  if refNumericEqual(
      x,
      y,
  ):
    return y

  if refNumericLess(
      x,
      y,
  ):
    refNextUp(x)
  else:
    refNextDown(x)

# REFERENCE_MODEL_END

func candidateFromRef(
    value: RefBits,
): Float256 =
  fromBits(
    value[3],
    value[2],
    value[1],
    value[0],
  )

func candidateToRef(
    value: Float256,
): RefBits =
  let bits =
    toBits(value)

  [
    bits.word0,
    bits.word1,
    bits.word2,
    bits.word3,
  ]

func candidateClass(
    value: Float256,
): RefClass =
  case classify(value)
  of f256Zero:
    rZero
  of f256Subnormal:
    rSubnormal
  of f256Normal:
    rNormal
  of f256Infinity:
    rInfinity
  of f256QuietNaN:
    rQuietNaN
  of f256SignalingNaN:
    rSignalingNaN

proc splitMix64(
    state: var uint64,
): uint64 =
  state =
    state +
    0x9e37_79b9_7f4a_7c15'u64

  var value =
    state

  value =
    (
      value xor
      (value shr 30)
    ) *
    0xbf58_476d_1ce4_e5b9'u64

  value =
    (
      value xor
      (value shr 27)
    ) *
    0x94d0_49bb_1331_11eb'u64

  result =
    value xor
    (value shr 31)

proc randomRef(
    state: var uint64,
): RefBits =
  for index in 0 ..< 4:
    result[index] =
      splitMix64(state)

proc checkValue(
    bits: RefBits,
) =
  let value =
    candidateFromRef(bits)

  doAssert candidateToRef(value) ==
    bits

  doAssert sameBits(
    value,
    candidateFromRef(bits),
  )

  doAssert signBit(value) ==
    refSign(bits)

  doAssert biasedExponent(value) ==
    refBiasedExponent(bits)

  doAssert fractionHighBits(value) ==
    refFractionHighBits(bits)

  doAssert fractionWord2Bits(value) ==
    bits[2]

  doAssert fractionWord1Bits(value) ==
    bits[1]

  doAssert fractionLowBits(value) ==
    bits[0]

  let expectedClass =
    refClass(bits)

  doAssert candidateClass(value) ==
    expectedClass

  doAssert isZero(value) ==
    (expectedClass == rZero)

  doAssert isSubnormal(value) ==
    (expectedClass == rSubnormal)

  doAssert isNormal(value) ==
    (expectedClass == rNormal)

  doAssert isInfinite(value) ==
    (expectedClass == rInfinity)

  doAssert isQuietNaN(value) ==
    (expectedClass == rQuietNaN)

  doAssert isSignalingNaN(value) ==
    (expectedClass == rSignalingNaN)

  doAssert isNaN(value) ==
    (
      expectedClass in {
        rQuietNaN,
        rSignalingNaN,
      }
    )

  doAssert isFinite(value) ==
    (
      expectedClass notin {
        rInfinity,
        rQuietNaN,
        rSignalingNaN,
      }
    )

  doAssert candidateToRef(
    withSign(
      value,
      false,
    )
  ) == refWithSign(
    bits,
    false,
  )

  doAssert candidateToRef(
    withSign(
      value,
      true,
    )
  ) == refWithSign(
    bits,
    true,
  )

  doAssert candidateToRef(
    negateSign(value)
  ) == refNegateSign(bits)

  doAssert candidateToRef(
    nextUp(value)
  ) == refNextUp(bits)

  doAssert candidateToRef(
    nextDown(value)
  ) == refNextDown(bits)

proc checkPair(
    xBits,
    yBits: RefBits,
) =
  let
    x =
      candidateFromRef(xBits)

    y =
      candidateFromRef(yBits)

  doAssert totalOrder(
    x,
    y,
  ) == refTotalOrder(
    xBits,
    yBits,
  )

  doAssert totalOrderMag(
    x,
    y,
  ) == refTotalOrderMag(
    xBits,
    yBits,
  )

  doAssert candidateToRef(
    nextAfter(
      x,
      y,
    )
  ) == refNextAfter(
    xBits,
    yBits,
  )

  doAssert candidateToRef(
    copySign(
      x,
      y,
    )
  ) == refWithSign(
    xBits,
    refSign(yBits),
  )

doAssert sizeof(Float256) == 32

doAssert Float256ExponentBits == 19
doAssert Float256FractionBits == 236
doAssert Float256PrecisionBits == 237
doAssert Float256ExponentBias == 262143

doAssert candidateToRef(
  positiveZeroFloat256
) == BaseEncodings[0]

doAssert candidateToRef(
  negativeZeroFloat256
) == BaseEncodings[1]

doAssert candidateToRef(
  positiveInfinityFloat256
) == BaseEncodings[12]

doAssert candidateToRef(
  negativeInfinityFloat256
) == BaseEncodings[13]

doAssert candidateToRef(
  canonicalQuietNaNFloat256
) == BaseEncodings[14]

doAssert candidateToRef(
  canonicalSignalingNaNFloat256
) == BaseEncodings[16]

doAssert candidateToRef(
  zeroFloat256()
) == BaseEncodings[0]

doAssert candidateToRef(
  zeroFloat256(true)
) == BaseEncodings[1]

doAssert candidateToRef(
  infinityFloat256()
) == BaseEncodings[12]

doAssert candidateToRef(
  infinityFloat256(true)
) == BaseEncodings[13]

var
  baseEncodingCount = 0
  pairwiseCaseCount = 0

for bits in BaseEncodings:
  checkValue(bits)
  inc baseEncodingCount

for xBits in BaseEncodings:
  for yBits in BaseEncodings:
    checkPair(
      xBits,
      yBits,
    )

    inc pairwiseCaseCount

var
  generatorState =
    SplitMixSeed

  generatorChecksum =
    0'u64

  generatedCaseCount =
    0

for _ in 0 ..< GeneratedCaseCount:
  let
    xBits =
      randomRef(
        generatorState
      )

    yBits =
      randomRef(
        generatorState
      )

    zBits =
      randomRef(
        generatorState
      )

  for word in xBits:
    generatorChecksum =
      generatorChecksum xor
      word

  for word in yBits:
    generatorChecksum =
      generatorChecksum xor
      word

  for word in zBits:
    generatorChecksum =
      generatorChecksum xor
      word

  checkValue(xBits)
  checkValue(yBits)
  checkValue(zBits)

  checkPair(
    xBits,
    yBits,
  )

  checkPair(
    yBits,
    zBits,
  )

  inc generatedCaseCount

doAssert baseEncodingCount == 24
doAssert pairwiseCaseCount == 576

doAssert generatedCaseCount ==
  GeneratedCaseCount

doAssert generatorState ==
  ExpectedGeneratorFinalState

doAssert generatorChecksum ==
  ExpectedGeneratorChecksum

doAssert ExpectedPublicSymbolCount == 40

echo "F256_CORE_LAYOUT_CONTRACT_OK",
  "\t", baseEncodingCount,
  "\t", pairwiseCaseCount,
  "\t", generatedCaseCount,
  "\t", ExpectedPublicSymbolCount,
  "\t", sizeof(Float256)
