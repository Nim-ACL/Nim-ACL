## Project-local binary256-style raw representation.
##
## This module provides:
## - exact raw-bit construction and decomposition
## - sign, exponent and fraction extraction
## - encoding classification
## - signed zero, infinity and NaN constants
## - sign manipulation
## - total ordering and adjacent-value operations
##
## Multiplication, division, conversions and formatting are intentionally deferred.

import atcoder/extra/numeric/internal/limbs

const
  Float256ExponentBits* = 19
  Float256FractionBits* = 236
  Float256PrecisionBits* = 237
  Float256ExponentBias* = 262143

  float256SignMask =
    0x8000_0000_0000_0000'u64

  float256ExponentMask =
    0x7FFF_F000_0000_0000'u64

  float256FractionHighMask =
    0x0000_0FFF_FFFF_FFFF'u64

  float256QuietNaNMask =
    0x0000_0800_0000_0000'u64

  float256MaxBiasedExponent =
    0x0007_FFFF'u32

type
  Float256* = object
    ## Raw 256-bit storage. All words remain private.
    word3: uint64
    word2: uint64
    word1: uint64
    word0: uint64

  Float256Class* = enum
    f256Zero
    f256Subnormal
    f256Normal
    f256Infinity
    f256QuietNaN
    f256SignalingNaN

const
  positiveZeroFloat256* =
    Float256(
      word3: 0'u64,
      word2: 0'u64,
      word1: 0'u64,
      word0: 0'u64,
    )

  negativeZeroFloat256* =
    Float256(
      word3: 0x8000_0000_0000_0000'u64,
      word2: 0'u64,
      word1: 0'u64,
      word0: 0'u64,
    )

  positiveInfinityFloat256* =
    Float256(
      word3: 0x7FFF_F000_0000_0000'u64,
      word2: 0'u64,
      word1: 0'u64,
      word0: 0'u64,
    )

  negativeInfinityFloat256* =
    Float256(
      word3: 0xFFFF_F000_0000_0000'u64,
      word2: 0'u64,
      word1: 0'u64,
      word0: 0'u64,
    )

  canonicalQuietNaNFloat256* =
    Float256(
      word3: 0x7FFF_F800_0000_0000'u64,
      word2: 0'u64,
      word1: 0'u64,
      word0: 0'u64,
    )

  canonicalSignalingNaNFloat256* =
    Float256(
      word3: 0x7FFF_F000_0000_0000'u64,
      word2: 0'u64,
      word1: 0'u64,
      word0: 1'u64,
    )

func fromBits*(
    word3,
    word2,
    word1,
    word0: uint64,
): Float256 {.inline.} =
  Float256(
    word3: word3,
    word2: word2,
    word1: word1,
    word0: word0,
  )

func toBits*(
    value: Float256,
): tuple[
    word3,
    word2,
    word1,
    word0: uint64,
] {.inline.} =
  (
    word3: value.word3,
    word2: value.word2,
    word1: value.word1,
    word0: value.word0,
  )

func sameBits*(
    a,
    b: Float256,
): bool {.inline.} =
  a.word3 == b.word3 and
    a.word2 == b.word2 and
    a.word1 == b.word1 and
    a.word0 == b.word0

func signBit*(
    value: Float256,
): bool {.inline.} =
  (
    value.word3 and
    float256SignMask
  ) != 0'u64

func biasedExponent*(
    value: Float256,
): uint32 {.inline.} =
  uint32(
    (
      value.word3 and
      float256ExponentMask
    ) shr 44
  )

func fractionHighBits*(
    value: Float256,
): uint64 {.inline.} =
  value.word3 and
    float256FractionHighMask

func fractionWord2Bits*(
    value: Float256,
): uint64 {.inline.} =
  value.word2

func fractionWord1Bits*(
    value: Float256,
): uint64 {.inline.} =
  value.word1

func fractionLowBits*(
    value: Float256,
): uint64 {.inline.} =
  value.word0

func fractionIsZero(
    value: Float256,
): bool {.inline.} =
  fractionHighBits(value) == 0'u64 and
    value.word2 == 0'u64 and
    value.word1 == 0'u64 and
    value.word0 == 0'u64

func isZero*(
    value: Float256,
): bool {.inline.} =
  biasedExponent(value) == 0'u32 and
    fractionIsZero(value)

func isSubnormal*(
    value: Float256,
): bool {.inline.} =
  biasedExponent(value) == 0'u32 and
    not fractionIsZero(value)

func isNormal*(
    value: Float256,
): bool {.inline.} =
  let exponent =
    biasedExponent(value)

  exponent != 0'u32 and
    exponent != float256MaxBiasedExponent

func isInfinite*(
    value: Float256,
): bool {.inline.} =
  biasedExponent(value) ==
    float256MaxBiasedExponent and
    fractionIsZero(value)

func isNaN*(
    value: Float256,
): bool {.inline.} =
  biasedExponent(value) ==
    float256MaxBiasedExponent and
    not fractionIsZero(value)

func isQuietNaN*(
    value: Float256,
): bool {.inline.} =
  isNaN(value) and
    (
      fractionHighBits(value) and
      float256QuietNaNMask
    ) != 0'u64

func isSignalingNaN*(
    value: Float256,
): bool {.inline.} =
  isNaN(value) and
    (
      fractionHighBits(value) and
      float256QuietNaNMask
    ) == 0'u64

func isFinite*(
    value: Float256,
): bool {.inline.} =
  biasedExponent(value) !=
    float256MaxBiasedExponent

func classify*(
    value: Float256,
): Float256Class =
  let exponent =
    biasedExponent(value)

  if exponent == 0'u32:
    if fractionIsZero(value):
      result = f256Zero
    else:
      result = f256Subnormal
  elif exponent !=
      float256MaxBiasedExponent:
    result = f256Normal
  elif fractionIsZero(value):
    result = f256Infinity
  elif isQuietNaN(value):
    result = f256QuietNaN
  else:
    result = f256SignalingNaN

func withSign*(
    value: Float256;
    negative: bool,
): Float256 {.inline.} =
  var word3 =
    value.word3 and
    not float256SignMask

  if negative:
    word3 =
      word3 or
      float256SignMask

  Float256(
    word3: word3,
    word2: value.word2,
    word1: value.word1,
    word0: value.word0,
  )

func negateSign*(
    value: Float256,
): Float256 {.inline.} =
  Float256(
    word3:
      value.word3 xor
      float256SignMask,
    word2:
      value.word2,
    word1:
      value.word1,
    word0:
      value.word0,
  )

func float256IncrementBits(
    value: Float256,
): Float256 {.inline.} =
  result = value

  if result.word0 != high(uint64):
    result.word0 += 1'u64
    return

  result.word0 = 0'u64

  if result.word1 != high(uint64):
    result.word1 += 1'u64
    return

  result.word1 = 0'u64

  if result.word2 != high(uint64):
    result.word2 += 1'u64
    return

  result.word2 = 0'u64

  if result.word3 != high(uint64):
    result.word3 += 1'u64
  else:
    result.word3 = 0'u64

func float256DecrementBits(
    value: Float256,
): Float256 {.inline.} =
  result = value

  if result.word0 != 0'u64:
    result.word0 -= 1'u64
    return

  result.word0 =
    high(uint64)

  if result.word1 != 0'u64:
    result.word1 -= 1'u64
    return

  result.word1 =
    high(uint64)

  if result.word2 != 0'u64:
    result.word2 -= 1'u64
    return

  result.word2 =
    high(uint64)

  if result.word3 != 0'u64:
    result.word3 -= 1'u64
  else:
    result.word3 =
      high(uint64)

func nextUp*(
    value: Float256,
): Float256 {.inline.} =
  if isNaN(value) or
      sameBits(
        value,
        positiveInfinityFloat256,
      ):
    return value

  if isZero(value):
    return fromBits(
      0'u64,
      0'u64,
      0'u64,
      1'u64,
    )

  if signBit(value):
    float256DecrementBits(value)
  else:
    float256IncrementBits(value)

func nextDown*(
    value: Float256,
): Float256 {.inline.} =
  if isNaN(value) or
      sameBits(
        value,
        negativeInfinityFloat256,
      ):
    return value

  if isZero(value):
    return fromBits(
      float256SignMask,
      0'u64,
      0'u64,
      1'u64,
    )

  if signBit(value):
    float256IncrementBits(value)
  else:
    float256DecrementBits(value)

func copySign*(
    magnitude,
    sign: Float256,
): Float256 {.inline.} =
  withSign(
    magnitude,
    signBit(sign),
  )

func float256TotalOrderKey(
    value: Float256,
): tuple[
    word3,
    word2,
    word1,
    word0: uint64,
] {.inline.} =
  if signBit(value):
    (
      word3: not value.word3,
      word2: not value.word2,
      word1: not value.word1,
      word0: not value.word0,
    )
  else:
    (
      word3:
        value.word3 xor
        float256SignMask,
      word2:
        value.word2,
      word1:
        value.word1,
      word0:
        value.word0,
    )

func totalOrder*(
    x,
    y: Float256,
): bool {.inline.} =
  let
    xKey =
      float256TotalOrderKey(x)

    yKey =
      float256TotalOrderKey(y)

  if xKey.word3 != yKey.word3:
    return xKey.word3 < yKey.word3

  if xKey.word2 != yKey.word2:
    return xKey.word2 < yKey.word2

  if xKey.word1 != yKey.word1:
    return xKey.word1 < yKey.word1

  xKey.word0 <= yKey.word0

func float256QuietNaN(
    value: Float256,
): Float256 {.inline.} =
  Float256(
    word3:
      value.word3 or
      float256QuietNaNMask,
    word2:
      value.word2,
    word1:
      value.word1,
    word0:
      value.word0,
  )

func float256PreferredQuietNaN(
    x,
    y: Float256,
): Float256 {.inline.} =
  if isNaN(x):
    float256QuietNaN(x)
  else:
    float256QuietNaN(y)

func float256NumericEqual(
    x,
    y: Float256,
): bool {.inline.} =
  if isNaN(x) or
      isNaN(y):
    return false

  if isZero(x) and
      isZero(y):
    return true

  sameBits(x, y)

func float256NumericLess(
    x,
    y: Float256,
): bool {.inline.} =
  if isNaN(x) or
      isNaN(y) or
      float256NumericEqual(
        x,
        y,
      ):
    return false

  totalOrder(x, y)

func float256Magnitude(
    value: Float256,
): Float256 {.inline.} =
  withSign(
    value,
    false,
  )

func nextAfter*(
    x,
    y: Float256,
): Float256 {.inline.} =
  if isNaN(x) or
      isNaN(y):
    return float256PreferredQuietNaN(
      x,
      y,
    )

  if float256NumericEqual(
      x,
      y,
  ):
    return y

  if float256NumericLess(
      x,
      y,
  ):
    nextUp(x)
  else:
    nextDown(x)

func totalOrderMag*(
    x,
    y: Float256,
): bool {.inline.} =
  totalOrder(
    float256Magnitude(x),
    float256Magnitude(y),
  )

func zeroFloat256*(
    negative: bool = false,
): Float256 {.inline.} =
  if negative:
    negativeZeroFloat256
  else:
    positiveZeroFloat256

func infinityFloat256*(
    negative: bool = false,
): Float256 {.inline.} =
  if negative:
    negativeInfinityFloat256
  else:
    positiveInfinityFloat256

# ----------------------------------------------------------------------
# Project-local binary256-style addition and subtraction
# ----------------------------------------------------------------------

type
  Float256FiniteParts = object
    sign: bool
    exponent: int
    significand: UInt512Limbs

func float256FiniteParts(
    value: Float256,
): Float256FiniteParts =
  result.sign =
    signBit(value)

  let exponentField =
    int(biasedExponent(value))

  result.significand[0] =
    fractionLowBits(value)

  result.significand[1] =
    fractionWord1Bits(value)

  result.significand[2] =
    fractionWord2Bits(value)

  result.significand[3] =
    fractionHighBits(value)

  if exponentField == 0:
    var highest =
      -1

    for limbIndex in countdown(3, 0):
      if result.significand[limbIndex] == 0'u64:
        continue

      for bitIndex in countdown(63, 0):
        if (
          result.significand[limbIndex] and
          (1'u64 shl bitIndex)
        ) != 0'u64:
          highest =
            limbIndex * 64 +
            bitIndex
          break

      if highest >= 0:
        break

    let normalizationShift =
      Float256FractionBits -
      highest

    result.significand =
      shiftLeft8(
        result.significand,
        normalizationShift,
      )

    result.exponent =
      1 -
      Float256ExponentBias -
      normalizationShift
  else:
    result.significand[3] =
      result.significand[3] or
      (1'u64 shl 44)

    result.exponent =
      exponentField -
      Float256ExponentBias

func float256ShiftRightJam(
    value: UInt512Limbs;
    distance: int,
): UInt512Limbs =
  var nonzero =
    false

  for limb in value:
    if limb != 0'u64:
      nonzero =
        true
      break

  if not nonzero:
    return

  if distance <= 0:
    return value

  if distance >= 512:
    result[0] =
      1'u64
    return

  result =
    shiftRight8(
      value,
      distance,
    )

  let restored =
    shiftLeft8(
      result,
      distance,
    )

  if compare8(
      restored,
      value,
  ) != 0:
    result[0] =
      result[0] or
      1'u64

func float256RoundPack(
    sign: bool;
    sourceExponent: int;
    sourceExtended: UInt512Limbs,
): Float256 =
  let
    minimumExponent =
      1 -
      Float256ExponentBias

    maximumExponent =
      int(float256MaxBiasedExponent) -
      1 -
      Float256ExponentBias

    signBits =
      if sign:
        float256SignMask
      else:
        0'u64

    zero =
      default(UInt512Limbs)

  var one =
    default(UInt512Limbs)

  one[0] =
    1'u64

  let
    hiddenBit =
      shiftLeft8(
        one,
        Float256FractionBits,
      )

    carryBit =
      shiftLeft8(
        one,
        Float256PrecisionBits,
      )

  if compare8(
      sourceExtended,
      zero,
  ) == 0:
    return fromBits(
      signBits,
      0'u64,
      0'u64,
      0'u64,
    )

  var
    exponent =
      sourceExponent

    extended =
      sourceExtended

  if exponent < minimumExponent:
    extended =
      float256ShiftRightJam(
        extended,
        minimumExponent -
          exponent,
      )

    exponent =
      minimumExponent

  var retained =
    shiftRight8(
      extended,
      3,
    )

  let rounding =
    guardRoundSticky8(
      extended,
      3,
    )

  if rounding.guard and
      (
        rounding.roundBit or
        rounding.sticky or
        ((retained[0] and 1'u64) != 0'u64)
      ):
    let incremented =
      add8(
        retained,
        one,
      )

    doAssert not incremented.carry

    retained =
      incremented.value

  if compare8(
      retained,
      carryBit,
  ) >= 0:
    retained =
      shiftRight8(
        retained,
        1,
      )

    inc exponent

  if exponent > maximumExponent:
    return fromBits(
      signBits or
        float256ExponentMask,
      0'u64,
      0'u64,
      0'u64,
    )

  if compare8(
      retained,
      zero,
  ) == 0:
    return fromBits(
      signBits,
      0'u64,
      0'u64,
      0'u64,
    )

  if exponent == minimumExponent and
      compare8(
        retained,
        hiddenBit,
      ) < 0:
    return fromBits(
      signBits or
        (
          retained[3] and
          float256FractionHighMask
        ),
      retained[2],
      retained[1],
      retained[0],
    )

  let fractionResult =
    sub8(
      retained,
      hiddenBit,
    )

  doAssert not fractionResult.borrow

  let
    fraction =
      fractionResult.value

    exponentField =
      uint64(
        exponent +
        Float256ExponentBias
      )

  fromBits(
    signBits or
      (exponentField shl 44) or
      (
        fraction[3] and
        float256FractionHighMask
      ),
    fraction[2],
    fraction[1],
    fraction[0],
  )

func float256AddSubFinite(
    lhs,
    rhs: Float256FiniteParts,
): Float256 =
  var
    larger =
      lhs

    smaller =
      rhs

  if larger.exponent < smaller.exponent or
      (
        larger.exponent == smaller.exponent and
        compare8(
          larger.significand,
          smaller.significand,
        ) < 0
      ):
    swap(
      larger,
      smaller,
    )

  let
    exponentDifference =
      larger.exponent -
      smaller.exponent

    largerExtended =
      shiftLeft8(
        larger.significand,
        3,
      )

    smallerExtended =
      float256ShiftRightJam(
        shiftLeft8(
          smaller.significand,
          3,
        ),
        exponentDifference,
      )

  if larger.sign == smaller.sign:
    let addition =
      add8(
        largerExtended,
        smallerExtended,
      )

    doAssert not addition.carry

    var
      sum =
        addition.value

      exponent =
        larger.exponent

      highest =
        -1

    for limbIndex in countdown(7, 0):
      if sum[limbIndex] == 0'u64:
        continue

      for bitIndex in countdown(63, 0):
        if (
          sum[limbIndex] and
          (1'u64 shl bitIndex)
        ) != 0'u64:
          highest =
            limbIndex * 64 +
            bitIndex
          break

      if highest >= 0:
        break

    let targetHighest =
      Float256FractionBits +
      3

    if highest > targetHighest:
      let shift =
        highest -
        targetHighest

      sum =
        float256ShiftRightJam(
          sum,
          shift,
        )

      exponent +=
        shift

    return float256RoundPack(
      larger.sign,
      exponent,
      sum,
    )

  let subtraction =
    sub8(
      largerExtended,
      smallerExtended,
    )

  doAssert not subtraction.borrow

  var difference =
    subtraction.value

  if compare8(
      difference,
      default(UInt512Limbs),
  ) == 0:
    return positiveZeroFloat256

  var
    exponent =
      larger.exponent

    highest =
      -1

  for limbIndex in countdown(7, 0):
    if difference[limbIndex] == 0'u64:
      continue

    for bitIndex in countdown(63, 0):
      if (
        difference[limbIndex] and
        (1'u64 shl bitIndex)
      ) != 0'u64:
        highest =
          limbIndex * 64 +
          bitIndex
        break

    if highest >= 0:
      break

  let targetHighest =
    Float256FractionBits +
    3

  if highest < targetHighest:
    let shift =
      targetHighest -
      highest

    difference =
      shiftLeft8(
        difference,
        shift,
      )

    exponent -=
      shift

  float256RoundPack(
    larger.sign,
    exponent,
    difference,
  )

func float256AddSub(
    lhs,
    rhs: Float256;
    subtract: bool,
): Float256 =
  if isNaN(lhs):
    return float256QuietNaN(lhs)

  if isNaN(rhs):
    return float256QuietNaN(rhs)

  let effectiveRhs =
    if subtract:
      negateSign(rhs)
    else:
      rhs

  let
    lhsInfinity =
      isInfinite(lhs)

    rhsInfinity =
      isInfinite(effectiveRhs)

  if lhsInfinity and
      rhsInfinity:
    if signBit(lhs) !=
        signBit(effectiveRhs):
      return canonicalQuietNaNFloat256

    return lhs

  if lhsInfinity:
    return lhs

  if rhsInfinity:
    return effectiveRhs

  let
    lhsZero =
      isZero(lhs)

    rhsZero =
      isZero(effectiveRhs)

  if lhsZero and
      rhsZero:
    if signBit(lhs) ==
        signBit(effectiveRhs):
      return zeroFloat256(
        signBit(lhs)
      )

    return positiveZeroFloat256

  if lhsZero:
    return effectiveRhs

  if rhsZero:
    return lhs

  float256AddSubFinite(
    float256FiniteParts(lhs),
    float256FiniteParts(effectiveRhs),
  )

func `-`*(
    value: Float256,
): Float256 {.inline.} =
  negateSign(value)

func `+`*(
    lhs,
    rhs: Float256,
): Float256 =
  float256AddSub(
    lhs,
    rhs,
    false,
  )

func `-`*(
    lhs,
    rhs: Float256,
): Float256 =
  float256AddSub(
    lhs,
    rhs,
    true,
  )
