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
## Native float32 / float64, Float128 and fixed-width integer conversion is available.
## Parsing and formatting are available.

import atcoder/extra/numeric/float128 as binary128
import atcoder/extra/numeric/int128
import atcoder/extra/numeric/int256
import atcoder/extra/numeric/internal/limbs
import atcoder/extra/numeric/internal/wide_mul
import atcoder/extra/numeric/internal/wide_div

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
# Fixed-width integer conversion
# ----------------------------------------------------------------------

type
  Float256IntegerLimbs =
    array[4, uint64]

func float256IntegerLimbs(
    value: UInt128,
): Float256IntegerLimbs {.inline.} =
  [
    low64(value),
    high64(value),
    0'u64,
    0'u64,
  ]

func float256IntegerLimbs(
    value: UInt256,
): Float256IntegerLimbs {.inline.} =
  [
    word64(value, 0),
    word64(value, 1),
    word64(value, 2),
    word64(value, 3),
  ]

func float256IntegerBit(
    limbs: Float256IntegerLimbs,
    index: int,
): bool {.inline.} =
  if index < 0 or
      index >= 256:
    return false

  (
    (
      limbs[index shr 6] shr
      (index and 63)
    ) and
    1'u64
  ) != 0'u64

func float256IntegerBitLength(
    limbs: Float256IntegerLimbs,
): int {.inline.} =
  for index in countdown(255, 0):
    if float256IntegerBit(
        limbs,
        index,
    ):
      return index + 1

  0

func float256IntegerAnyBitsBelow(
    limbs: Float256IntegerLimbs,
    highExclusive: int,
): bool {.inline.} =
  if highExclusive <= 0:
    return false

  for index in 0 ..<
      min(
        highExclusive,
        256,
      ):
    if float256IntegerBit(
        limbs,
        index,
    ):
      return true

  false

func float256IntegerSetBit(
    limbs: var Float256IntegerLimbs,
    index: int,
) {.inline.} =
  doAssert index >= 0
  doAssert index < 256

  limbs[index shr 6] =
    limbs[index shr 6] or
    (
      1'u64 shl
      (index and 63)
    )

func float256IntegerIncrement(
    limbs: var Float256IntegerLimbs,
) {.inline.} =
  for index in 0 .. 3:
    limbs[index] =
      limbs[index] +
      1'u64

    if limbs[index] != 0'u64:
      return

func toFloat256FromIntegerLimbs(
    limbs: Float256IntegerLimbs,
    negative: bool,
): Float256 =
  let bitLength =
    float256IntegerBitLength(
      limbs
    )

  if bitLength == 0:
    return positiveZeroFloat256

  var
    exponent =
      bitLength - 1

    significand:
      Float256IntegerLimbs

  if bitLength <=
      Float256PrecisionBits:
    let leftShift =
      Float256PrecisionBits -
      bitLength

    for sourceBit in 0 ..<
        bitLength:
      if float256IntegerBit(
          limbs,
          sourceBit,
      ):
        float256IntegerSetBit(
          significand,
          sourceBit +
            leftShift,
        )

  else:
    let rightShift =
      bitLength -
      Float256PrecisionBits

    for destinationBit in 0 ..<
        Float256PrecisionBits:
      if float256IntegerBit(
          limbs,
          destinationBit +
            rightShift,
      ):
        float256IntegerSetBit(
          significand,
          destinationBit,
        )

    let
      guardBit =
        float256IntegerBit(
          limbs,
          rightShift - 1,
        )

      stickyBit =
        float256IntegerAnyBitsBelow(
          limbs,
          rightShift - 1,
        )

      retainedLeastBitIsOdd =
        (
          significand[0] and
          1'u64
        ) != 0'u64

    if guardBit and
        (
          stickyBit or
          retainedLeastBitIsOdd
        ):
      float256IntegerIncrement(
        significand
      )

      if (
        significand[3] and
        (
          1'u64 shl 45
        )
      ) != 0'u64:
        significand = [
          0'u64,
          0'u64,
          0'u64,
          1'u64 shl 44,
        ]

        inc exponent

  var word3 =
    (
      uint64(
        exponent +
        Float256ExponentBias
      ) shl 44
    ) or
    (
      significand[3] and
      0x0000_0FFF_FFFF_FFFF'u64
    )

  if negative:
    word3 =
      word3 or
      0x8000_0000_0000_0000'u64

  fromBits(
    word3,
    significand[2],
    significand[1],
    significand[0],
  )

func toFloat256*(
    value: UInt128,
): Float256 =
  ## Converts UInt128 exactly to binary256.

  toFloat256FromIntegerLimbs(
    float256IntegerLimbs(value),
    false,
  )

func toFloat256*(
    value: Int128,
): Float256 =
  ## Converts Int128 exactly to binary256.

  let
    bits =
      toUInt128(value)

    negative =
      (
        high64(bits) and
        0x8000_0000_0000_0000'u64
      ) != 0'u64

    magnitude =
      if negative:
        toUInt128(0'u64) -
          bits
      else:
        bits

  toFloat256FromIntegerLimbs(
    float256IntegerLimbs(
      magnitude
    ),
    negative,
  )

func toFloat256*(
    value: UInt256,
): Float256 =
  ## Converts UInt256 using IEEE 754 roundTiesToEven.

  toFloat256FromIntegerLimbs(
    float256IntegerLimbs(value),
    false,
  )

func toFloat256*(
    value: Int256,
): Float256 =
  ## Converts Int256 using its two's-complement magnitude and
  ## IEEE 754 roundTiesToEven when required.

  let
    bits =
      asUInt256(value)

    negative =
      (
        word64(bits, 3) and
        0x8000_0000_0000_0000'u64
      ) != 0'u64

    magnitude =
      if negative:
        toUInt256(0'u64) -
          bits
      else:
        bits

  toFloat256FromIntegerLimbs(
    float256IntegerLimbs(
      magnitude
    ),
    negative,
  )

proc float256IntegerMagnitude128(
    value: Float256;
    destination: var UInt128;
    negative: var bool;
    unbiasedExponent: var int;
    sourceFractionNonzero: var bool;
): bool =
  destination =
    toUInt128(0'u64)

  let
    raw =
      toBits(value)

    exponentField =
      int(
        (
          raw.word3 shr 44
        ) and
        0x0007_FFFF'u64
      )

    fractionHigh =
      raw.word3 and
      0x0000_0FFF_FFFF_FFFF'u64

  negative =
    (
      raw.word3 and
      0x8000_0000_0000_0000'u64
    ) != 0'u64

  sourceFractionNonzero =
    fractionHigh != 0'u64 or
    raw.word2 != 0'u64 or
    raw.word1 != 0'u64 or
    raw.word0 != 0'u64

  unbiasedExponent =
    -Float256ExponentBias

  if exponentField ==
      0x0007_FFFF:
    return false

  if exponentField == 0:
    return true

  unbiasedExponent =
    exponentField -
    Float256ExponentBias

  if unbiasedExponent < 0:
    return true

  if unbiasedExponent > 127:
    return false

  let
    significand =
      fromUInt64Words(
        fractionHigh or
          (
            1'u64 shl 44
          ),
        raw.word2,
        raw.word1,
        raw.word0,
      )

    shifted =
      significand shr
      (
        Float256FractionBits -
        unbiasedExponent
      )

  destination =
    low128(shifted)

  true

proc float256IntegerMagnitude256(
    value: Float256;
    destination: var UInt256;
    negative: var bool;
    unbiasedExponent: var int;
    sourceFractionNonzero: var bool;
): bool =
  destination =
    toUInt256(0'u64)

  let
    raw =
      toBits(value)

    exponentField =
      int(
        (
          raw.word3 shr 44
        ) and
        0x0007_FFFF'u64
      )

    fractionHigh =
      raw.word3 and
      0x0000_0FFF_FFFF_FFFF'u64

  negative =
    (
      raw.word3 and
      0x8000_0000_0000_0000'u64
    ) != 0'u64

  sourceFractionNonzero =
    fractionHigh != 0'u64 or
    raw.word2 != 0'u64 or
    raw.word1 != 0'u64 or
    raw.word0 != 0'u64

  unbiasedExponent =
    -Float256ExponentBias

  if exponentField ==
      0x0007_FFFF:
    return false

  if exponentField == 0:
    return true

  unbiasedExponent =
    exponentField -
    Float256ExponentBias

  if unbiasedExponent < 0:
    return true

  if unbiasedExponent > 255:
    return false

  let significand =
    fromUInt64Words(
      fractionHigh or
        (
          1'u64 shl 44
        ),
      raw.word2,
      raw.word1,
      raw.word0,
    )

  if unbiasedExponent >=
      Float256FractionBits:
    destination =
      significand shl
      (
        unbiasedExponent -
        Float256FractionBits
      )
  else:
    destination =
      significand shr
      (
        Float256FractionBits -
        unbiasedExponent
      )

  true

proc tryToUInt128*(
    value: Float256;
    destination: var UInt128;
): bool =
  destination =
    toUInt128(0'u64)

  var
    magnitude: UInt128
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float256IntegerMagnitude128(
      value,
      magnitude,
      negative,
      unbiasedExponent,
      sourceFractionNonzero,
  ):
    return false

  if negative and
      unbiasedExponent >= 0:
    return false

  destination =
    magnitude

  true

proc tryToInt128*(
    value: Float256;
    destination: var Int128;
): bool =
  destination =
    toInt128(0'i64)

  var
    magnitude: UInt128
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float256IntegerMagnitude128(
      value,
      magnitude,
      negative,
      unbiasedExponent,
      sourceFractionNonzero,
  ):
    return false

  if unbiasedExponent == 127:
    if not negative or
        high64(magnitude) !=
          0x8000_0000_0000_0000'u64 or
        low64(magnitude) != 0'u64:
      return false

  if negative:
    destination =
      toInt128(
        toUInt128(0'u64) -
        magnitude
      )
  else:
    destination =
      toInt128(magnitude)

  true

proc tryToUInt256*(
    value: Float256;
    destination: var UInt256;
): bool =
  destination =
    toUInt256(0'u64)

  var
    magnitude: UInt256
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float256IntegerMagnitude256(
      value,
      magnitude,
      negative,
      unbiasedExponent,
      sourceFractionNonzero,
  ):
    return false

  if negative and
      unbiasedExponent >= 0:
    return false

  destination =
    magnitude

  true

proc tryToInt256*(
    value: Float256;
    destination: var Int256;
): bool =
  destination =
    toInt256(0'i64)

  var
    magnitude: UInt256
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float256IntegerMagnitude256(
      value,
      magnitude,
      negative,
      unbiasedExponent,
      sourceFractionNonzero,
  ):
    return false

  if unbiasedExponent == 255:
    if not negative or
        word64(magnitude, 3) !=
          0x8000_0000_0000_0000'u64 or
        word64(magnitude, 2) != 0'u64 or
        word64(magnitude, 1) != 0'u64 or
        word64(magnitude, 0) != 0'u64:
      return false

  if negative:
    destination =
      asInt256(
        toUInt256(0'u64) -
        magnitude
      )
  else:
    destination =
      asInt256(magnitude)

  true

# ----------------------------------------------------------------------
# Exact native binary32 / binary64 conversion
# ----------------------------------------------------------------------

type
  Float256NativeConversionLimbs =
    array[4, uint64]

func float256NativeSourceHighestBit32(
    value: uint32,
): int {.inline.} =
  for index in countdown(31, 0):
    if (
      (
        value shr index
      ) and
      1'u32
    ) != 0'u32:
      return index

  -1

func float256NativeSourceHighestBit64(
    value: uint64,
): int {.inline.} =
  for index in countdown(63, 0):
    if (
      (
        value shr index
      ) and
      1'u64
    ) != 0'u64:
      return index

  -1

func float256PackNativeFraction(
    value: uint64,
    bitWidth: int,
): tuple[
    word3,
    word2: uint64,
] {.inline.} =
  if bitWidth <= 0:
    return (
      word3: 0'u64,
      word2: 0'u64,
    )

  doAssert bitWidth <= 64

  if bitWidth <= 44:
    return (
      word3:
        value shl
        (
          44 -
          bitWidth
        ),
      word2: 0'u64,
    )

  let spill =
    bitWidth -
    44

  (
    word3:
      value shr spill,
    word2:
      value shl
      (
        64 -
        spill
      ),
  )

func toFloat256*(
    value: float32,
): Float256 =
  ## Converts an IEEE 754 binary32 value exactly to binary256.
  ##
  ## NaN sign, quiet/signaling state and payload bits are preserved by
  ## left-aligning the binary32 fraction in the binary256 fraction.

  let
    sourceBits =
      cast[uint32](value)

    sourceSign =
      uint64(
        sourceBits shr 31
      ) shl 63

    sourceExponent =
      (
        sourceBits shr 23
      ) and
      0xFF'u32

    sourceFraction =
      sourceBits and
      0x007F_FFFF'u32

  if sourceExponent == 0'u32:
    if sourceFraction == 0'u32:
      return fromBits(
        sourceSign,
        0'u64,
        0'u64,
        0'u64,
      )

    let
      highestBit =
        float256NativeSourceHighestBit32(
          sourceFraction
        )

      targetExponent =
        uint64(
          highestBit +
          261994
        )

      remainder =
        sourceFraction xor
        (
          1'u32 shl
          highestBit
        )

      packed =
        float256PackNativeFraction(
          uint64(remainder),
          highestBit,
        )

    return fromBits(
      sourceSign or
        (
          targetExponent shl 44
        ) or
        packed.word3,
      packed.word2,
      0'u64,
      0'u64,
    )

  let
    targetExponent =
      if sourceExponent == 0xFF'u32:
        0x0007_FFFF'u64
      else:
        uint64(sourceExponent) +
          262016'u64

    packed =
      float256PackNativeFraction(
        uint64(sourceFraction),
        23,
      )

  fromBits(
    sourceSign or
      (
        targetExponent shl 44
      ) or
      packed.word3,
    packed.word2,
    0'u64,
    0'u64,
  )

func toFloat256*(
    value: float64,
): Float256 =
  ## Converts an IEEE 754 binary64 value exactly to binary256.
  ##
  ## NaN sign, quiet/signaling state and payload bits are preserved by
  ## left-aligning the binary64 fraction in the binary256 fraction.

  let
    sourceBits =
      cast[uint64](value)

    sourceSign =
      sourceBits and
      0x8000_0000_0000_0000'u64

    sourceExponent =
      (
        sourceBits shr 52
      ) and
      0x7FF'u64

    sourceFraction =
      sourceBits and
      0x000F_FFFF_FFFF_FFFF'u64

  if sourceExponent == 0'u64:
    if sourceFraction == 0'u64:
      return fromBits(
        sourceSign,
        0'u64,
        0'u64,
        0'u64,
      )

    let
      highestBit =
        float256NativeSourceHighestBit64(
          sourceFraction
        )

      targetExponent =
        uint64(
          highestBit +
          261069
        )

      remainder =
        sourceFraction xor
        (
          1'u64 shl
          highestBit
        )

      packed =
        float256PackNativeFraction(
          remainder,
          highestBit,
        )

    return fromBits(
      sourceSign or
        (
          targetExponent shl 44
        ) or
        packed.word3,
      packed.word2,
      0'u64,
      0'u64,
    )

  let
    targetExponent =
      if sourceExponent == 0x7FF'u64:
        0x0007_FFFF'u64
      else:
        sourceExponent +
          261120'u64

    packed =
      float256PackNativeFraction(
        sourceFraction,
        52,
      )

  fromBits(
    sourceSign or
      (
        targetExponent shl 44
      ) or
      packed.word3,
    packed.word2,
    0'u64,
    0'u64,
  )

func float256NativeBit(
    limbs: Float256NativeConversionLimbs,
    index: int,
): bool {.inline.} =
  if index < 0 or
      index >= 256:
    return false

  let
    limbIndex =
      index shr 6

    bitIndex =
      index and 63

  (
    (
      limbs[limbIndex] shr
      bitIndex
    ) and
    1'u64
  ) != 0'u64

func float256NativeAnyBitsBelow(
    limbs: Float256NativeConversionLimbs,
    highExclusive: int,
): bool {.inline.} =
  if highExclusive <= 0:
    return false

  let limit =
    min(
      highExclusive,
      256,
    )

  for index in 0 ..< limit:
    if float256NativeBit(
        limbs,
        index,
    ):
      return true

  false

func float256NativeHighestBit(
    limbs: Float256NativeConversionLimbs,
): int {.inline.} =
  for limbIndex in countdown(3, 0):
    if limbs[limbIndex] == 0'u64:
      continue

    for bitIndex in countdown(63, 0):
      if (
        limbs[limbIndex] and
        (
          1'u64 shl bitIndex
        )
      ) != 0'u64:
        return
          limbIndex * 64 +
          bitIndex

  -1

func float256NativeShiftRightToUInt64(
    limbs: Float256NativeConversionLimbs,
    shift: int,
): uint64 {.inline.} =
  for destinationBit in 0 ..< 64:
    let sourceBit =
      destinationBit +
      shift

    if float256NativeBit(
        limbs,
        sourceBit,
    ):
      result =
        result or
        (
          1'u64 shl
          destinationBit
        )

func float256NativeRoundShiftToUInt64(
    limbs: Float256NativeConversionLimbs,
    shift: int,
): uint64 {.inline.} =
  if shift <= 0:
    return
      float256NativeShiftRightToUInt64(
        limbs,
        shift,
      )

  if shift > 256:
    return 0'u64

  let
    retained =
      float256NativeShiftRightToUInt64(
        limbs,
        shift,
      )

    guard =
      float256NativeBit(
        limbs,
        shift - 1,
      )

    sticky =
      float256NativeAnyBitsBelow(
        limbs,
        shift - 1,
      )

  if guard and
      (
        sticky or
        (
          retained and
          1'u64
        ) != 0'u64
      ):
    return retained + 1'u64

  retained

func float256ToNativeBinaryBits(
    value: Float256,
    targetFractionBits: int,
    targetBias: int,
    targetMinimumExponent: int,
    targetMaximumExponent: int,
    targetSignShift: int,
    targetExponentAllOnes: uint64,
): uint64 =
  let
    source =
      toBits(value)

    sourceSign =
      source.word3 shr 63

    sourceExponent =
      int(
        (
          source.word3 shr 44
        ) and
        0x0007_FFFF'u64
      )

    sourceFraction:
      Float256NativeConversionLimbs =
        [
          source.word0,
          source.word1,
          source.word2,
          source.word3 and
            0x0000_0FFF_FFFF_FFFF'u64,
        ]

    targetSign =
      sourceSign shl
      targetSignShift

  if sourceExponent == 0x0007_FFFF:
    if sourceFraction[0] == 0'u64 and
        sourceFraction[1] == 0'u64 and
        sourceFraction[2] == 0'u64 and
        sourceFraction[3] == 0'u64:
      return
        targetSign or
        (
          targetExponentAllOnes shl
          targetFractionBits
        )

    let payloadShift =
      Float256FractionBits -
      targetFractionBits

    var targetFraction =
      float256NativeShiftRightToUInt64(
        sourceFraction,
        payloadShift,
      )

    if targetFraction == 0'u64:
      targetFraction = 1'u64

    return
      targetSign or
      (
        targetExponentAllOnes shl
        targetFractionBits
      ) or
      targetFraction

  if sourceExponent == 0 and
      sourceFraction[0] == 0'u64 and
      sourceFraction[1] == 0'u64 and
      sourceFraction[2] == 0'u64 and
      sourceFraction[3] == 0'u64:
    return targetSign

  var
    significand =
      sourceFraction

    highestBit: int
    binaryExponent: int

  if sourceExponent == 0:
    highestBit =
      float256NativeHighestBit(
        significand
      )

    binaryExponent =
      1 -
      Float256ExponentBias -
      Float256FractionBits

  else:
    significand[3] =
      significand[3] or
      (
        1'u64 shl 44
      )

    highestBit =
      Float256FractionBits

    binaryExponent =
      sourceExponent -
      Float256ExponentBias -
      Float256FractionBits

  let resultExponent =
    highestBit +
    binaryExponent

  if resultExponent >
      targetMaximumExponent:
    return
      targetSign or
      (
        targetExponentAllOnes shl
        targetFractionBits
      )

  let
    targetHiddenBit =
      1'u64 shl
      targetFractionBits

    targetSignificandLimit =
      targetHiddenBit shl 1

  if resultExponent >=
      targetMinimumExponent:
    let shift =
      highestBit -
      targetFractionBits

    var
      roundedSignificand =
        float256NativeRoundShiftToUInt64(
          significand,
          shift,
        )

      targetExponent =
        resultExponent

    if roundedSignificand >=
        targetSignificandLimit:
      roundedSignificand =
        roundedSignificand shr 1

      inc targetExponent

      if targetExponent >
          targetMaximumExponent:
        return
          targetSign or
          (
            targetExponentAllOnes shl
            targetFractionBits
          )

    let
      targetFraction =
        roundedSignificand and
        (
          targetHiddenBit -
          1'u64
        )

      targetExponentField =
        uint64(
          targetExponent +
          targetBias
        )

    return
      targetSign or
      (
        targetExponentField shl
        targetFractionBits
      ) or
      targetFraction

  let
    targetQuantumExponent =
      targetMinimumExponent -
      targetFractionBits

    shift =
      targetQuantumExponent -
      binaryExponent

    roundedFraction =
      float256NativeRoundShiftToUInt64(
        significand,
        shift,
      )

  if roundedFraction == 0'u64:
    return targetSign

  if roundedFraction >=
      targetHiddenBit:
    return
      targetSign or
      (
        1'u64 shl
        targetFractionBits
      )

  targetSign or
    roundedFraction

func toFloat32*(
    value: Float256,
): float32 =
  ## Converts binary256 to binary32 using roundTiesToEven.
  ##
  ## Signed zero and infinity are preserved. NaN sign and the most
  ## significant representable payload bits are retained.

  let bits =
    uint32(
      float256ToNativeBinaryBits(
        value,
        23,
        127,
        -126,
        127,
        31,
        0xFF'u64,
      )
    )

  cast[float32](bits)

func toFloat64*(
    value: Float256,
): float64 =
  ## Converts binary256 to binary64 using roundTiesToEven.
  ##
  ## Signed zero and infinity are preserved. NaN sign and the most
  ## significant representable payload bits are retained.

  let bits =
    float256ToNativeBinaryBits(
      value,
      52,
      1023,
      -1022,
      1023,
      63,
      0x7FF'u64,
    )

  cast[float64](bits)


# ----------------------------------------------------------------------
# Exact Float128 / Float256 conversion
# ----------------------------------------------------------------------

type
  Float256Float128Pair =
    tuple[
      high,
      low: uint64,
    ]

func float128FractionToFloat256Words(
    sourceHigh,
    sourceLow: uint64,
    shift: int,
    skipSourceBit: int = -1,
): Float256NativeConversionLimbs {.inline.} =
  for sourceBit in 0 ..<
      binary128.Float128FractionBits:
    if sourceBit == skipSourceBit:
      continue

    let bitPresent =
      if sourceBit < 64:
        (
          (
            sourceLow shr
            sourceBit
          ) and
          1'u64
        ) != 0'u64
      else:
        (
          (
            sourceHigh shr
            (
              sourceBit -
              64
            )
          ) and
          1'u64
        ) != 0'u64

    if not bitPresent:
      continue

    let targetBit =
      sourceBit +
      shift

    doAssert targetBit >= 0
    doAssert targetBit <
      Float256FractionBits

    result[
      targetBit shr 6
    ] =
      result[
        targetBit shr 6
      ] or
      (
        1'u64 shl
        (
          targetBit and 63
        )
      )

func toFloat256*(
    value: binary128.Float128,
): Float256 =
  ## Converts an IEEE 754 binary128 value exactly to binary256.
  ##
  ## Signed zero, infinity, NaN sign, quiet/signaling state and every
  ## binary128 payload bit are preserved.

  let
    source =
      binary128.toBits(value)

    sourceSign =
      source.high and
      0x8000_0000_0000_0000'u64

    sourceExponent =
      (
        source.high shr 48
      ) and
      0x7FFF'u64

    sourceFractionHigh =
      source.high and
      0x0000_FFFF_FFFF_FFFF'u64

    sourceFractionLow =
      source.low

  if sourceExponent == 0'u64:
    if sourceFractionHigh == 0'u64 and
        sourceFractionLow == 0'u64:
      return fromBits(
        sourceSign,
        0'u64,
        0'u64,
        0'u64,
      )

    let
      highestBit =
        if sourceFractionHigh != 0'u64:
          64 +
            float256NativeSourceHighestBit64(
              sourceFractionHigh
            )
        else:
          float256NativeSourceHighestBit64(
            sourceFractionLow
          )

      targetExponent =
        uint64(
          highestBit +
          245649
        )

      packed =
        float128FractionToFloat256Words(
          sourceFractionHigh,
          sourceFractionLow,
          Float256FractionBits -
            highestBit,
          highestBit,
        )

    return fromBits(
      sourceSign or
        (
          targetExponent shl 44
        ) or
        packed[3],
      packed[2],
      packed[1],
      packed[0],
    )

  let
    targetExponent =
      if sourceExponent == 0x7FFF'u64:
        0x0007_FFFF'u64
      else:
        sourceExponent +
          245760'u64

    packed =
      float128FractionToFloat256Words(
        sourceFractionHigh,
        sourceFractionLow,
        124,
      )

  fromBits(
    sourceSign or
      (
        targetExponent shl 44
      ) or
      packed[3],
    packed[2],
    packed[1],
    packed[0],
  )

func float256ShiftRightToUInt128Pair(
    limbs: Float256NativeConversionLimbs,
    shift: int,
): Float256Float128Pair {.inline.} =
  for destinationBit in 0 ..< 128:
    let sourceBit =
      destinationBit +
      shift

    if not float256NativeBit(
        limbs,
        sourceBit,
    ):
      continue

    if destinationBit < 64:
      result.low =
        result.low or
        (
          1'u64 shl
          destinationBit
        )
    else:
      result.high =
        result.high or
        (
          1'u64 shl
          (
            destinationBit -
            64
          )
        )

func float256IncrementUInt128Pair(
    value: var Float256Float128Pair,
) {.inline.} =
  if value.low == high(uint64):
    value.low = 0'u64
    value.high =
      value.high +
      1'u64
  else:
    value.low =
      value.low +
      1'u64

func float256RoundShiftToUInt128Pair(
    limbs: Float256NativeConversionLimbs,
    shift: int,
): Float256Float128Pair {.inline.} =
  result =
    float256ShiftRightToUInt128Pair(
      limbs,
      shift,
    )

  if shift <= 0 or
      shift > 256:
    return

  let
    guard =
      float256NativeBit(
        limbs,
        shift - 1,
      )

    sticky =
      float256NativeAnyBitsBelow(
        limbs,
        shift - 1,
      )

  if guard and
      (
        sticky or
        (
          result.low and
          1'u64
        ) != 0'u64
      ):
    float256IncrementUInt128Pair(
      result
    )

func float256PackFloat128Result(
    negative: bool,
    exponentField: uint64,
    significand: Float256Float128Pair,
): binary128.Float128 {.inline.} =
  var highWord =
    (
      exponentField shl 48
    ) or
    (
      significand.high and
      0x0000_FFFF_FFFF_FFFF'u64
    )

  if negative:
    highWord =
      highWord or
      0x8000_0000_0000_0000'u64

  binary128.fromBits(
    highWord,
    significand.low,
  )

func toFloat128*(
    value: Float256,
): binary128.Float128 =
  ## Converts binary256 to binary128 using roundTiesToEven.
  ##
  ## Signed zero and infinity are preserved. NaN sign and the most
  ## significant 112 payload bits are retained.

  let
    source =
      toBits(value)

    sourceNegative =
      (
        source.word3 and
        0x8000_0000_0000_0000'u64
      ) != 0'u64

    sourceExponent =
      int(
        (
          source.word3 shr 44
        ) and
        0x0007_FFFF'u64
      )

    sourceFraction:
      Float256NativeConversionLimbs =
        [
          source.word0,
          source.word1,
          source.word2,
          source.word3 and
            0x0000_0FFF_FFFF_FFFF'u64,
        ]

    sourceFractionIsZero =
      sourceFraction[0] == 0'u64 and
      sourceFraction[1] == 0'u64 and
      sourceFraction[2] == 0'u64 and
      sourceFraction[3] == 0'u64

  if sourceExponent == 0x0007_FFFF:
    if sourceFractionIsZero:
      return
        float256PackFloat128Result(
          sourceNegative,
          0x7FFF'u64,
          (
            high: 0'u64,
            low: 0'u64,
          ),
        )

    var payload =
      float256ShiftRightToUInt128Pair(
        sourceFraction,
        124,
      )

    if payload.high == 0'u64 and
        payload.low == 0'u64:
      payload.low = 1'u64

    return
      float256PackFloat128Result(
        sourceNegative,
        0x7FFF'u64,
        payload,
      )

  if sourceExponent == 0 and
      sourceFractionIsZero:
    return
      float256PackFloat128Result(
        sourceNegative,
        0'u64,
        (
          high: 0'u64,
          low: 0'u64,
        ),
      )

  var
    significand =
      sourceFraction

    highestBit: int
    binaryExponent: int

  if sourceExponent == 0:
    highestBit =
      float256NativeHighestBit(
        significand
      )

    binaryExponent =
      1 -
      Float256ExponentBias -
      Float256FractionBits

  else:
    significand[3] =
      significand[3] or
      (
        1'u64 shl 44
      )

    highestBit =
      Float256FractionBits

    binaryExponent =
      sourceExponent -
      Float256ExponentBias -
      Float256FractionBits

  let resultExponent =
    highestBit +
    binaryExponent

  if resultExponent > 16383:
    return
      float256PackFloat128Result(
        sourceNegative,
        0x7FFF'u64,
        (
          high: 0'u64,
          low: 0'u64,
        ),
      )

  if resultExponent >= -16382:
    let shift =
      highestBit -
      binary128.Float128FractionBits

    var
      roundedSignificand =
        float256RoundShiftToUInt128Pair(
          significand,
          shift,
        )

      targetExponent =
        resultExponent

    if roundedSignificand.high >=
        0x0002_0000_0000_0000'u64:
      roundedSignificand =
        (
          high:
            roundedSignificand.high shr 1,
          low:
            (
              roundedSignificand.low shr 1
            ) or
            (
              roundedSignificand.high shl 63
            ),
        )

      inc targetExponent

      if targetExponent > 16383:
        return
          float256PackFloat128Result(
            sourceNegative,
            0x7FFF'u64,
            (
              high: 0'u64,
              low: 0'u64,
            ),
          )

    return
      float256PackFloat128Result(
        sourceNegative,
        uint64(
          targetExponent +
          binary128.Float128ExponentBias
        ),
        roundedSignificand,
      )

  let
    targetQuantumExponent =
      -16494

    shift =
      targetQuantumExponent -
      binaryExponent

    roundedFraction =
      float256RoundShiftToUInt128Pair(
        significand,
        shift,
      )

  if roundedFraction.high == 0'u64 and
      roundedFraction.low == 0'u64:
    return
      float256PackFloat128Result(
        sourceNegative,
        0'u64,
        roundedFraction,
      )

  if roundedFraction.high >=
      0x0001_0000_0000_0000'u64:
    return
      float256PackFloat128Result(
        sourceNegative,
        1'u64,
        (
          high: 0'u64,
          low: 0'u64,
        ),
      )

  float256PackFloat128Result(
    sourceNegative,
    0'u64,
    roundedFraction,
  )

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

# ----------------------------------------------------------------------
# Project-local binary256-style multiplication
# ----------------------------------------------------------------------

func float256MultiplySignificand(
    lhs,
    rhs: UInt512Limbs,
): UInt512Limbs =
  var
    lhs256 =
      default(UInt256Limbs)

    rhs256 =
      default(UInt256Limbs)

  for index in 0 ..< 4:
    lhs256[index] =
      lhs[index]

    rhs256[index] =
      rhs[index]

  multiplyWide4x4(
    lhs256,
    rhs256,
  )

func float256MultiplyFinite(
    lhs,
    rhs: Float256FiniteParts,
): Float256 =
  let product =
    float256MultiplySignificand(
      lhs.significand,
      rhs.significand,
    )

  var highest =
    -1

  for limbIndex in countdown(7, 0):
    if product[limbIndex] == 0'u64:
      continue

    for bitIndex in countdown(63, 0):
      if (
        product[limbIndex] and
        (1'u64 shl bitIndex)
      ) != 0'u64:
        highest =
          limbIndex * 64 +
          bitIndex
        break

    if highest >= 0:
      break

  doAssert highest == 472 or
    highest == 473

  let
    normalizationShift =
      highest -
      (
        Float256FractionBits +
        3
      )

    extended =
      float256ShiftRightJam(
        product,
        normalizationShift,
      )

    resultExponent =
      lhs.exponent +
      rhs.exponent +
      highest -
      (
        2 *
        Float256FractionBits
      )

  float256RoundPack(
    lhs.sign xor rhs.sign,
    resultExponent,
    extended,
  )

func float256Multiply(
    lhs,
    rhs: Float256,
): Float256 =
  if isNaN(lhs):
    return float256QuietNaN(lhs)

  if isNaN(rhs):
    return float256QuietNaN(rhs)

  let
    resultSign =
      signBit(lhs) xor
      signBit(rhs)

    lhsInfinity =
      isInfinite(lhs)

    rhsInfinity =
      isInfinite(rhs)

    lhsZero =
      isZero(lhs)

    rhsZero =
      isZero(rhs)

  if (
    lhsInfinity and
    rhsZero
  ) or (
    rhsInfinity and
    lhsZero
  ):
    return canonicalQuietNaNFloat256

  if lhsInfinity or
      rhsInfinity:
    return infinityFloat256(
      resultSign
    )

  if lhsZero or
      rhsZero:
    return zeroFloat256(
      resultSign
    )

  float256MultiplyFinite(
    float256FiniteParts(lhs),
    float256FiniteParts(rhs),
  )

func `*`*(
    lhs,
    rhs: Float256,
): Float256 =
  float256Multiply(
    lhs,
    rhs,
  )


# ----------------------------------------------------------------------
# Project-local binary256-style division
# ----------------------------------------------------------------------

func float256DivideFinite(
    lhs,
    rhs: Float256FiniteParts,
): Float256 =
  var denominator =
    default(UInt256Limbs)

  for index in 0 ..< 4:
    denominator[index] =
      rhs.significand[index]

  var
    exponent =
      lhs.exponent -
      rhs.exponent

    numerator =
      default(UInt512Limbs)

  if compare8(
      lhs.significand,
      rhs.significand,
  ) >= 0:
    numerator =
      shiftLeft8(
        lhs.significand,
        239,
      )
  else:
    numerator =
      shiftLeft8(
        lhs.significand,
        240,
      )

    dec exponent

  let division =
    divRemWide8x4(
      numerator,
      denominator,
    )

  var quotient =
    division.quotient

  for limb in division.remainder:
    if limb != 0'u64:
      quotient[0] =
        quotient[0] or
        1'u64
      break

  float256RoundPack(
    lhs.sign xor rhs.sign,
    exponent,
    quotient,
  )

func float256Divide(
    lhs,
    rhs: Float256,
): Float256 =
  if isNaN(lhs):
    return float256QuietNaN(lhs)

  if isNaN(rhs):
    return float256QuietNaN(rhs)

  let
    resultSign =
      signBit(lhs) xor
      signBit(rhs)

    lhsInfinity =
      isInfinite(lhs)

    rhsInfinity =
      isInfinite(rhs)

    lhsZero =
      isZero(lhs)

    rhsZero =
      isZero(rhs)

  if (
    lhsInfinity and
    rhsInfinity
  ) or (
    lhsZero and
    rhsZero
  ):
    return canonicalQuietNaNFloat256

  if lhsInfinity:
    return infinityFloat256(
      resultSign
    )

  if rhsInfinity:
    return zeroFloat256(
      resultSign
    )

  if rhsZero:
    return infinityFloat256(
      resultSign
    )

  if lhsZero:
    return zeroFloat256(
      resultSign
    )

  float256DivideFinite(
    float256FiniteParts(lhs),
    float256FiniteParts(rhs),
  )

func `/`*(
    lhs,
    rhs: Float256,
): Float256 =
  float256Divide(
    lhs,
    rhs,
  )
# ----------------------------------------------------------------------
# Exact raw hexadecimal and correctly rounded decimal parsing
# ----------------------------------------------------------------------

const
  float256DecimalMaximumInputBytes =
    10_000

  float256DecimalMaximumExponentDigits =
    9

  float256DecimalMaximumAbsoluteExponent =
    100_000

  float256DecimalPowerOfFiveChunkExponent =
    13

  float256DecimalPowerOfFiveChunk =
    1_220_703_125'u32

type
  Float256DecimalBigUInt =
    object
      limbs: seq[uint32]

func float256HexNibble(
    value: char,
): int {.inline.} =
  case value
  of '0'..'9':
    ord(value) - ord('0')
  of 'A'..'F':
    ord(value) - ord('A') + 10
  of 'a'..'f':
    ord(value) - ord('a') + 10
  else:
    -1

proc tryParseHexFloat256*(
    text: string;
    destination: var Float256;
): bool =
  ## Parses a 0x-prefixed exact 256-bit raw encoding.

  destination =
    positiveZeroFloat256

  if text.len != 66:
    return false

  if text[0] != '0' or
      (
        text[1] != 'x' and
        text[1] != 'X'
      ):
    return false

  var words:
    array[4, uint64]

  for wordIndex in 0 ..< 4:
    for digitIndex in 0 ..< 16:
      let nibble =
        float256HexNibble(
          text[
            2 +
            wordIndex * 16 +
            digitIndex
          ]
        )

      if nibble < 0:
        return false

      words[wordIndex] =
        (
          words[wordIndex] shl 4
        ) or
        uint64(nibble)

  destination =
    fromBits(
      words[0],
      words[1],
      words[2],
      words[3],
    )

  true

func float256DecimalIsZero(
    value: Float256DecimalBigUInt,
): bool {.inline.} =
  value.limbs.len == 0

proc float256DecimalNormalize(
    value: var Float256DecimalBigUInt,
) =
  while value.limbs.len > 0 and
      value.limbs[^1] == 0'u32:
    value.limbs.setLen(
      value.limbs.len - 1
    )

proc float256DecimalAddSmall(
    value: var Float256DecimalBigUInt;
    addend: uint32;
) =
  if addend == 0'u32:
    return

  if value.limbs.len == 0:
    value.limbs =
      @[addend]

    return

  var
    index = 0
    carry =
      uint64(addend)

  while carry != 0'u64:
    if index == value.limbs.len:
      value.limbs.add(
        0'u32
      )

    let total =
      uint64(
        value.limbs[index]
      ) +
      carry

    value.limbs[index] =
      uint32(
        total and
        0xFFFF_FFFF'u64
      )

    carry =
      total shr 32

    inc index

proc float256DecimalMultiplySmall(
    value: var Float256DecimalBigUInt;
    factor: uint32;
) =
  if value.float256DecimalIsZero or
      factor == 1'u32:
    return

  if factor == 0'u32:
    value.limbs.setLen(0)
    return

  var carry =
    0'u64

  for index in 0 ..<
      value.limbs.len:
    let product =
      uint64(
        value.limbs[index]
      ) *
      uint64(factor) +
      carry

    value.limbs[index] =
      uint32(
        product and
        0xFFFF_FFFF'u64
      )

    carry =
      product shr 32

  if carry != 0'u64:
    value.limbs.add(
      uint32(carry)
    )

proc float256DecimalMultiplyPowerOfFive(
    value: var Float256DecimalBigUInt;
    exponent: int;
) =
  doAssert exponent >= 0

  var remaining =
    exponent

  while remaining >=
      float256DecimalPowerOfFiveChunkExponent:
    value.float256DecimalMultiplySmall(
      float256DecimalPowerOfFiveChunk
    )

    remaining -=
      float256DecimalPowerOfFiveChunkExponent

  for _ in 0 ..<
      remaining:
    value.float256DecimalMultiplySmall(
      5'u32
    )

func float256DecimalPowerOfFive(
    exponent: int,
): Float256DecimalBigUInt =
  doAssert exponent >= 0

  result.limbs =
    @[1'u32]

  result.float256DecimalMultiplyPowerOfFive(
    exponent
  )

func float256DecimalFromDigits(
    digits: string;
    first,
    pastLast: int;
): Float256DecimalBigUInt =
  for index in first ..<
      pastLast:
    result.float256DecimalMultiplySmall(
      10'u32
    )

    result.float256DecimalAddSmall(
      uint32(
        ord(digits[index]) -
        ord('0')
      )
    )

  result.float256DecimalNormalize()

func float256DecimalCompare(
    lhs,
    rhs: Float256DecimalBigUInt,
): int =
  if lhs.limbs.len !=
      rhs.limbs.len:
    if lhs.limbs.len <
        rhs.limbs.len:
      return -1

    return 1

  if lhs.limbs.len == 0:
    return 0

  for index in countdown(
      lhs.limbs.len - 1,
      0,
  ):
    if lhs.limbs[index] <
        rhs.limbs[index]:
      return -1

    if lhs.limbs[index] >
        rhs.limbs[index]:
      return 1

  0

func float256DecimalLimbBitLength(
    value: uint32,
): int =
  var remaining =
    value

  while remaining != 0'u32:
    inc result
    remaining =
      remaining shr 1

func float256DecimalBitLength(
    value: Float256DecimalBigUInt,
): int =
  if value.float256DecimalIsZero:
    return 0

  (
    value.limbs.len - 1
  ) * 32 +
  float256DecimalLimbBitLength(
    value.limbs[^1]
  )

func float256DecimalShiftLeft(
    value: Float256DecimalBigUInt;
    distance: int;
): Float256DecimalBigUInt =
  doAssert distance >= 0

  if value.float256DecimalIsZero:
    return

  if distance == 0:
    return value

  let
    limbShift =
      distance div 32

    bitShift =
      distance mod 32

  result.limbs =
    newSeq[uint32](
      value.limbs.len +
      limbShift +
      1
    )

  var carry =
    0'u64

  for index in 0 ..<
      value.limbs.len:
    let combined =
      (
        uint64(
          value.limbs[index]
        ) shl bitShift
      ) or
      carry

    result.limbs[
      index + limbShift
    ] =
      uint32(
        combined and
        0xFFFF_FFFF'u64
      )

    carry =
      combined shr 32

  if carry != 0'u64:
    result.limbs[
      value.limbs.len +
      limbShift
    ] =
      uint32(carry)

  result.float256DecimalNormalize()

proc float256DecimalShiftLeftOne(
    value: var Float256DecimalBigUInt,
) =
  if value.float256DecimalIsZero:
    return

  var carry =
    0'u64

  for index in 0 ..<
      value.limbs.len:
    let combined =
      (
        uint64(
          value.limbs[index]
        ) shl 1
      ) or
      carry

    value.limbs[index] =
      uint32(
        combined and
        0xFFFF_FFFF'u64
      )

    carry =
      combined shr 32

  if carry != 0'u64:
    value.limbs.add(
      uint32(carry)
    )

proc float256DecimalSubtractAssign(
    value: var Float256DecimalBigUInt;
    subtrahend: Float256DecimalBigUInt;
) =
  doAssert float256DecimalCompare(
    value,
    subtrahend,
  ) >= 0

  var borrow =
    0'u64

  for index in 0 ..<
      value.limbs.len:
    let
      lhs =
        uint64(
          value.limbs[index]
        )

      rhs =
        (
          if index <
              subtrahend.limbs.len:
            uint64(
              subtrahend.limbs[index]
            )
          else:
            0'u64
        ) +
        borrow

    if lhs >= rhs:
      value.limbs[index] =
        uint32(
          lhs - rhs
        )

      borrow =
        0'u64
    else:
      value.limbs[index] =
        uint32(
          (
            1'u64 shl 32
          ) +
          lhs -
          rhs
        )

      borrow =
        1'u64

  doAssert borrow == 0'u64

  value.float256DecimalNormalize()

proc float256DecimalSetExtendedBit(
    value: var UInt512Limbs;
    position: int;
) =
  doAssert position >= 0
  doAssert position < 512

  value[position shr 6] =
    value[position shr 6] or
    (
      1'u64 shl
      (
        position and 63
      )
    )

func float256DecimalNormalizedRatio(
    numerator,
    denominator: Float256DecimalBigUInt,
): tuple[
    exponent: int,
    extended: UInt512Limbs,
    remainderNonzero: bool,
] =
  doAssert not numerator.float256DecimalIsZero
  doAssert not denominator.float256DecimalIsZero

  var exponent =
    numerator.float256DecimalBitLength -
    denominator.float256DecimalBitLength

  if exponent >= 0:
    let scaledDenominator =
      denominator.float256DecimalShiftLeft(
        exponent
      )

    if float256DecimalCompare(
        numerator,
        scaledDenominator,
    ) < 0:
      dec exponent
  else:
    let scaledNumerator =
      numerator.float256DecimalShiftLeft(
        -exponent
      )

    if float256DecimalCompare(
        scaledNumerator,
        denominator,
    ) < 0:
      dec exponent

  var
    normalizedDenominator:
      Float256DecimalBigUInt

    remainder:
      Float256DecimalBigUInt

  if exponent >= 0:
    normalizedDenominator =
      denominator.float256DecimalShiftLeft(
        exponent
      )

    remainder =
      numerator

    remainder.float256DecimalSubtractAssign(
      normalizedDenominator
    )
  else:
    remainder =
      numerator.float256DecimalShiftLeft(
        -exponent
      )

    normalizedDenominator =
      denominator

    remainder.float256DecimalSubtractAssign(
      normalizedDenominator
    )

  result.exponent =
    exponent

  result.extended.float256DecimalSetExtendedBit(
    239
  )

  for position in countdown(
      238,
      1,
  ):
    remainder.float256DecimalShiftLeftOne()

    if float256DecimalCompare(
        remainder,
        normalizedDenominator,
    ) >= 0:
      remainder.float256DecimalSubtractAssign(
        normalizedDenominator
      )

      result.extended.float256DecimalSetExtendedBit(
        position
      )

  remainder.float256DecimalShiftLeftOne()

  if float256DecimalCompare(
      remainder,
      normalizedDenominator,
  ) >= 0:
    remainder.float256DecimalSubtractAssign(
      normalizedDenominator
    )

    result.extended.float256DecimalSetExtendedBit(
      0
    )

  result.remainderNonzero =
    not remainder.float256DecimalIsZero

  if result.remainderNonzero:
    result.extended.float256DecimalSetExtendedBit(
      0
    )

func float256DecimalAsciiLower(
    value: char,
): char {.inline.} =
  if value >= 'A' and
      value <= 'Z':
    char(
      ord(value) +
      ord('a') -
      ord('A')
    )
  else:
    value

func float256DecimalEqualsIgnoreCase(
    text: string;
    first: int;
    expected: string;
): bool =
  if text.len - first !=
      expected.len:
    return false

  for index in 0 ..<
      expected.len:
    if float256DecimalAsciiLower(
        text[first + index]
    ) != expected[index]:
      return false

  true

proc tryParseFloat256*(
    text: string;
    destination: var Float256;
): bool =
  ## Parses an ASCII decimal binary256 value using roundTiesToEven.
  ##
  ## Accepted finite forms are digits, digits., digits.fraction,
  ## .fraction, and an optional e/E exponent. Optional leading signs
  ## and the case-insensitive specials inf, infinity, and nan are
  ## accepted. Whitespace and digit separators are rejected.

  destination =
    positiveZeroFloat256

  if text.len == 0 or
      text.len >
        float256DecimalMaximumInputBytes:
    return false

  var
    index = 0
    negative = false

  if text[index] == '+' or
      text[index] == '-':
    negative =
      text[index] == '-'

    inc index

    if index == text.len:
      return false

  let signBits =
    if negative:
      float256SignMask
    else:
      0'u64

  if float256DecimalEqualsIgnoreCase(
      text,
      index,
      "inf",
  ) or
      float256DecimalEqualsIgnoreCase(
        text,
        index,
        "infinity",
      ):
    destination =
      fromBits(
        signBits or
          float256ExponentMask,
        0'u64,
        0'u64,
        0'u64,
      )

    return true

  if float256DecimalEqualsIgnoreCase(
      text,
      index,
      "nan",
  ):
    destination =
      fromBits(
        signBits or
          float256ExponentMask or
          float256QuietNaNMask,
        0'u64,
        0'u64,
        0'u64,
      )

    return true

  var
    digits =
      newStringOfCap(
        text.len
      )

    fractionalDigitCount =
      0

    sawDigit =
      false

    sawPoint =
      false

  while index < text.len and
      text[index] != 'e' and
      text[index] != 'E':
    let character =
      text[index]

    if character >= '0' and
        character <= '9':
      sawDigit =
        true

      digits.add(
        character
      )

      if sawPoint:
        inc fractionalDigitCount
    elif character == '.' and
        not sawPoint:
      sawPoint =
        true
    else:
      return false

    inc index

  if not sawDigit:
    return false

  var explicitExponent =
    0

  if index < text.len:
    inc index

    if index == text.len:
      return false

    var exponentNegative =
      false

    if text[index] == '+' or
        text[index] == '-':
      exponentNegative =
        text[index] == '-'

      inc index

      if index == text.len:
        return false

    var exponentDigitCount =
      0

    while index < text.len:
      let character =
        text[index]

      if character < '0' or
          character > '9':
        return false

      inc exponentDigitCount

      if exponentDigitCount >
          float256DecimalMaximumExponentDigits:
        return false

      explicitExponent =
        explicitExponent * 10 +
        ord(character) -
        ord('0')

      if explicitExponent >
          float256DecimalMaximumAbsoluteExponent:
        return false

      inc index

    if exponentDigitCount == 0:
      return false

    if exponentNegative:
      explicitExponent =
        -explicitExponent

  var firstNonzero =
    -1

  for digitIndex in 0 ..<
      digits.len:
    if digits[digitIndex] != '0':
      firstNonzero =
        digitIndex

      break

  if firstNonzero < 0:
    destination =
      fromBits(
        signBits,
        0'u64,
        0'u64,
        0'u64,
      )

    return true

  var
    trailingZeroCount =
      0

    trailingIndex =
      digits.len - 1

  while trailingIndex >=
      firstNonzero and
      digits[trailingIndex] == '0':
    inc trailingZeroCount
    dec trailingIndex

  let
    significantPastLast =
      digits.len -
      trailingZeroCount

    significantDigitCount =
      significantPastLast -
      firstNonzero

    decimalExponent =
      explicitExponent -
      fractionalDigitCount +
      trailingZeroCount

    decimalOrder =
      significantDigitCount -
      1 +
      decimalExponent

  if decimalOrder > 78913:
    destination =
      fromBits(
        signBits or
          float256ExponentMask,
        0'u64,
        0'u64,
        0'u64,
      )

    return true

  if decimalOrder < -78984:
    destination =
      fromBits(
        signBits,
        0'u64,
        0'u64,
        0'u64,
      )

    return true

  var
    numerator =
      float256DecimalFromDigits(
        digits,
        firstNonzero,
        significantPastLast,
      )

    denominator:
      Float256DecimalBigUInt

    binaryExponent =
      decimalExponent

  if decimalExponent >= 0:
    numerator.float256DecimalMultiplyPowerOfFive(
      decimalExponent
    )

    denominator.limbs =
      @[1'u32]
  else:
    denominator =
      float256DecimalPowerOfFive(
        -decimalExponent
      )

  let extracted =
    float256DecimalNormalizedRatio(
      numerator,
      denominator,
    )

  destination =
    float256RoundPack(
      negative,
      extracted.exponent +
        binaryExponent,
      extracted.extended,
    )

  true

proc parseFloat256*(
    text: string,
): Float256 =
  ## Parses an ASCII decimal binary256 value or raises ValueError.

  if not tryParseFloat256(
      text,
      result,
  ):
    raise newException(
      ValueError,
      "invalid Float256 decimal text",
    )

# ----------------------------------------------------------------------
# Exact and round-trip decimal formatting for Float256
# ----------------------------------------------------------------------

func float256FormatHexDigit(
    value: uint64,
): char {.inline.} =
  if value < 10'u64:
    char(ord('0') + int(value))
  else:
    char(ord('A') + int(value - 10'u64))

func toHexString*(
    value: Float256,
): string =
  ## Returns the exact raw binary256 encoding as 0xWWWW...WWWW.
  let bits = toBits(value)

  result = newString(66)
  result[0] = '0'
  result[1] = 'x'

  for index in 0 ..< 16:
    let shift = (15 - index) * 4

    result[2 + index] =
      float256FormatHexDigit(
        (bits.word3 shr shift) and 0xF'u64
      )

    result[18 + index] =
      float256FormatHexDigit(
        (bits.word2 shr shift) and 0xF'u64
      )

    result[34 + index] =
      float256FormatHexDigit(
        (bits.word1 shr shift) and 0xF'u64
      )

    result[50 + index] =
      float256FormatHexDigit(
        (bits.word0 shr shift) and 0xF'u64
      )

func float256FormatClone(
    value: Float256DecimalBigUInt,
): Float256DecimalBigUInt =
  result.limbs =
    newSeq[uint32](
      value.limbs.len
    )

  for index in 0 ..<
      value.limbs.len:
    result.limbs[index] =
      value.limbs[index]

func float256FormatFromSignificand(
    value: UInt512Limbs,
): Float256DecimalBigUInt =
  for wordIndex in 0 ..< 8:
    let word =
      value[wordIndex]

    result.limbs.add(
      uint32(
        word and
        0xFFFF_FFFF'u64
      )
    )

    result.limbs.add(
      uint32(
        word shr 32
      )
    )

  result.float256DecimalNormalize()

func float256FormatMultiplyBig(
    lhs,
    rhs: Float256DecimalBigUInt,
): Float256DecimalBigUInt =
  if lhs.float256DecimalIsZero or
      rhs.float256DecimalIsZero:
    return

  result.limbs =
    newSeq[uint32](
      lhs.limbs.len +
      rhs.limbs.len +
      1
    )

  for lhsIndex in 0 ..<
      lhs.limbs.len:
    if lhs.limbs[
        lhsIndex
    ] == 0'u32:
      continue

    var carry =
      0'u64

    for rhsIndex in 0 ..<
        rhs.limbs.len:
      let
        position =
          lhsIndex +
          rhsIndex

        total =
          uint64(
            result.limbs[
              position
            ]
          ) +
          uint64(
            lhs.limbs[
              lhsIndex
            ]
          ) *
          uint64(
            rhs.limbs[
              rhsIndex
            ]
          ) +
          carry

      result.limbs[
        position
      ] =
        uint32(
          total and
          0xFFFF_FFFF'u64
        )

      carry =
        total shr 32

    var position =
      lhsIndex +
      rhs.limbs.len

    while carry != 0'u64:
      let total =
        uint64(
          result.limbs[
            position
          ]
        ) +
        carry

      result.limbs[
        position
      ] =
        uint32(
          total and
          0xFFFF_FFFF'u64
        )

      carry =
        total shr 32

      inc position

  result.float256DecimalNormalize()

func float256FormatPowerOfTen(
    exponent: int,
): Float256DecimalBigUInt =
  doAssert exponent >= 0

  result =
    float256DecimalPowerOfFive(
      exponent
    )

  if exponent != 0:
    result =
      result.float256DecimalShiftLeft(
        exponent
      )

func float256FormatCompareRatioPowerOfTen(
    numerator,
    denominator: Float256DecimalBigUInt;
    decimalExponent: int,
): int =
  let power =
    float256FormatPowerOfTen(
      abs(
        decimalExponent
      )
    )

  if decimalExponent >= 0:
    let scaledDenominator =
      float256FormatMultiplyBig(
        denominator,
        power,
      )

    return
      float256DecimalCompare(
        numerator,
        scaledDenominator,
      )

  let scaledNumerator =
    float256FormatMultiplyBig(
      numerator,
      power,
    )

  float256DecimalCompare(
    scaledNumerator,
    denominator,
  )

func float256FormatFloorLog10Estimate(
    binaryExponent: int,
): int =
  let product =
    binaryExponent *
    78_913

  if product >= 0:
    product div 262_144
  else:
    -(
      (
        -product +
        262_143
      ) div 262_144
    )

proc float256FormatIncrementDigits(
    digits: var string;
    decimalExponent: var int,
) =
  var index =
    digits.len - 1

  while index >= 0 and
      digits[index] == '9':
    digits[index] = '0'
    dec index

  if index >= 0:
    digits[index] =
      char(
        ord(
          digits[index]
        ) +
        1
      )
  else:
    digits[0] = '1'

    for position in 1 ..<
        digits.len:
      digits[position] = '0'

    inc decimalExponent

func toScientificString*(
    value: Float256,
): string =
  ## Returns 73 significant decimal digits in scientific notation.
  ##
  ## Every finite output round-trips through tryParseFloat256.
  let negative =
    signBit(value)

  if isNaN(value):
    if negative:
      return "-nan"

    return "nan"

  if isInfinite(value):
    if negative:
      return "-inf"

    return "inf"

  if isZero(value):
    if negative:
      return "-0"

    return "0"

  let
    parts =
      float256FiniteParts(
        value
      )

    binaryExponent =
      parts.exponent -
      Float256FractionBits

  var
    numerator =
      float256FormatFromSignificand(
        parts.significand
      )

    denominator:
      Float256DecimalBigUInt

  denominator.limbs =
    @[1'u32]

  if binaryExponent >= 0:
    numerator =
      numerator.float256DecimalShiftLeft(
        binaryExponent
      )
  else:
    denominator =
      denominator.float256DecimalShiftLeft(
        -binaryExponent
      )

  var decimalExponent =
    float256FormatFloorLog10Estimate(
      parts.exponent
    )

  while
      float256FormatCompareRatioPowerOfTen(
        numerator,
        denominator,
        decimalExponent,
      ) < 0:
    dec decimalExponent

  while
      float256FormatCompareRatioPowerOfTen(
        numerator,
        denominator,
        decimalExponent + 1,
      ) >= 0:
    inc decimalExponent

  var
    scaledNumerator:
      Float256DecimalBigUInt

    scaledDenominator:
      Float256DecimalBigUInt

  if decimalExponent >= 0:
    scaledNumerator =
      numerator.float256FormatClone()

    scaledDenominator =
      float256FormatMultiplyBig(
        denominator,
        float256FormatPowerOfTen(
          decimalExponent
        ),
      )
  else:
    scaledNumerator =
      float256FormatMultiplyBig(
        numerator,
        float256FormatPowerOfTen(
          -decimalExponent
        ),
      )

    scaledDenominator =
      denominator.float256FormatClone()

  var
    remainder =
      scaledNumerator.float256FormatClone()

    digits =
      newString(73)

  for position in 0 ..< 73:
    var digit = 0

    while
        float256DecimalCompare(
          remainder,
          scaledDenominator,
        ) >= 0:
      remainder.float256DecimalSubtractAssign(
        scaledDenominator
      )

      inc digit

    doAssert digit >= 0 and
      digit <= 9

    digits[position] =
      char(
        ord('0') +
        digit
      )

    if position != 72:
      remainder.float256DecimalMultiplySmall(
        10'u32
      )

  var doubledRemainder =
    remainder.float256FormatClone()

  doubledRemainder.float256DecimalShiftLeftOne()

  let roundingComparison =
    float256DecimalCompare(
      doubledRemainder,
      scaledDenominator,
    )

  if roundingComparison > 0 or
      (
        roundingComparison == 0 and
        (
          (
            ord(
              digits[^1]
            ) -
            ord('0')
          ) and 1
        ) != 0
      ):
    digits.float256FormatIncrementDigits(
      decimalExponent
    )

  result =
    newStringOfCap(84)

  if negative:
    result.add('-')

  result.add(
    digits[0]
  )

  result.add('.')

  result.add(
    digits[1 .. ^1]
  )

  result.add('e')

  if decimalExponent >= 0:
    result.add('+')

  result.add(
    $decimalExponent
  )

type
  Float256ShortestRatio = object
    numerator:
      Float256DecimalBigUInt
    denominator:
      Float256DecimalBigUInt

  Float256ShortestPrepared = object
    numerator:
      Float256DecimalBigUInt
    denominator:
      Float256DecimalBigUInt
    lowerNumerator:
      Float256DecimalBigUInt
    upperNumerator:
      Float256DecimalBigUInt
    boundaryDenominator:
      Float256DecimalBigUInt
    decimalExponent:
      int
    midpointInclusive:
      bool

  Float256ShortestCandidate = object
    digits:
      string
    decimalPower:
      int
    significantDigits:
      int
    coefficientOdd:
      bool

proc float256ShortestOne():
    Float256DecimalBigUInt =
  result.limbs =
    @[1'u32]

proc float256ShortestClone(
    value: Float256DecimalBigUInt,
): Float256DecimalBigUInt =
  result =
    value.float256FormatClone()

proc float256ShortestFromSignificand(
    value: UInt512Limbs,
): Float256DecimalBigUInt =
  result =
    float256FormatFromSignificand(
      value
    )

proc float256ShortestShiftLeft(
    value: Float256DecimalBigUInt;
    distance: int,
): Float256DecimalBigUInt =
  result =
    value.float256DecimalShiftLeft(
      distance
    )

proc float256ShortestMultiplyBig(
    lhs,
    rhs: Float256DecimalBigUInt,
): Float256DecimalBigUInt =
  result =
    float256FormatMultiplyBig(
      lhs,
      rhs,
    )

proc float256ShortestPowerOfTen(
    exponent: int,
): Float256DecimalBigUInt =
  result =
    float256FormatPowerOfTen(
      exponent
    )

proc float256ShortestAddBig(
    lhs,
    rhs: Float256DecimalBigUInt,
): Float256DecimalBigUInt =
  result =
    lhs.float256ShortestClone()

  var
    index = 0
    carry = 0'u64

  while index <
      rhs.limbs.len or
      carry != 0'u64:
    if index ==
        result.limbs.len:
      result.limbs.add(
        0'u32
      )

    let
      rhsWord =
        if index <
            rhs.limbs.len:
          uint64(
            rhs.limbs[index]
          )
        else:
          0'u64

      total =
        uint64(
          result.limbs[index]
        ) +
        rhsWord +
        carry

    result.limbs[index] =
      uint32(
        total and
        0xFFFF_FFFF'u64
      )

    carry =
      total shr 32

    inc index

  result.float256DecimalNormalize()

proc float256ShortestDyadicRatio(
    significand: UInt512Limbs;
    binaryExponent: int,
): Float256ShortestRatio =
  result.numerator =
    significand.float256ShortestFromSignificand()

  result.denominator =
    float256ShortestOne()

  if binaryExponent >= 0:
    result.numerator =
      result.numerator.float256ShortestShiftLeft(
        binaryExponent
      )
  else:
    result.denominator =
      result.denominator.float256ShortestShiftLeft(
        -binaryExponent
      )

proc float256ShortestAlignedInteger(
    significand: UInt512Limbs;
    binaryExponent,
    commonBinaryExponent: int,
): Float256DecimalBigUInt =
  result =
    significand.float256ShortestFromSignificand()

  let shift =
    binaryExponent -
    commonBinaryExponent

  doAssert shift >= 0

  if shift != 0:
    result =
      result.float256ShortestShiftLeft(
        shift
      )

proc float256ShortestPrepare(
    value: Float256,
): Float256ShortestPrepared =
  let
    magnitude =
      withSign(
        value,
        false,
      )

    magnitudeBits =
      toBits(
        magnitude
      )

    targetParts =
      float256FiniteParts(
        magnitude
      )

    targetBinaryExponent =
      targetParts.exponent -
      Float256FractionBits

  var targetRatio =
    float256ShortestDyadicRatio(
      targetParts.significand,
      targetBinaryExponent,
    )

  var decimalExponent =
    float256FormatFloorLog10Estimate(
      targetParts.exponent
    )

  while
      float256FormatCompareRatioPowerOfTen(
        targetRatio.numerator,
        targetRatio.denominator,
        decimalExponent,
      ) < 0:
    dec decimalExponent

  while
      float256FormatCompareRatioPowerOfTen(
        targetRatio.numerator,
        targetRatio.denominator,
        decimalExponent + 1,
      ) >= 0:
    inc decimalExponent

  let decimalScale =
    float256ShortestPowerOfTen(
      abs(
        decimalExponent
      )
    )

  if decimalExponent >= 0:
    result.numerator =
      targetRatio.numerator

    result.denominator =
      float256ShortestMultiplyBig(
        targetRatio.denominator,
        decimalScale,
      )
  else:
    result.numerator =
      float256ShortestMultiplyBig(
        targetRatio.numerator,
        decimalScale,
      )

    result.denominator =
      targetRatio.denominator

  let previousValue =
    nextDown(
      magnitude
    )

  var
    previousSignificand =
      default(
        UInt512Limbs
      )

    previousBinaryExponent =
      targetBinaryExponent

  if not isZero(
      previousValue
  ):
    let previousParts =
      float256FiniteParts(
        previousValue
      )

    previousSignificand =
      previousParts.significand

    previousBinaryExponent =
      previousParts.exponent -
      Float256FractionBits

  var
    nextSignificand:
      UInt512Limbs

    nextBinaryExponent:
      int

  let maximumFinite =
    magnitudeBits.word3 ==
      0x7FFF_EFFF_FFFF_FFFF'u64 and
    magnitudeBits.word2 ==
      high(uint64) and
    magnitudeBits.word1 ==
      high(uint64) and
    magnitudeBits.word0 ==
      high(uint64)

  if maximumFinite:
    nextSignificand[3] =
      1'u64 shl 44

    nextBinaryExponent =
      262_144 -
      Float256FractionBits
  else:
    let
      nextValue =
        nextUp(
          magnitude
        )

      nextParts =
        float256FiniteParts(
          nextValue
        )

    nextSignificand =
      nextParts.significand

    nextBinaryExponent =
      nextParts.exponent -
      Float256FractionBits

  var commonBinaryExponent =
    min(
      targetBinaryExponent,
      nextBinaryExponent,
    )

  if previousSignificand !=
      default(UInt512Limbs):
    commonBinaryExponent =
      min(
        commonBinaryExponent,
        previousBinaryExponent,
      )

  let
    previousAligned =
      float256ShortestAlignedInteger(
        previousSignificand,
        previousBinaryExponent,
        commonBinaryExponent,
      )

    targetAligned =
      float256ShortestAlignedInteger(
        targetParts.significand,
        targetBinaryExponent,
        commonBinaryExponent,
      )

    nextAligned =
      float256ShortestAlignedInteger(
        nextSignificand,
        nextBinaryExponent,
        commonBinaryExponent,
      )

  var
    lowerNumerator =
      float256ShortestAddBig(
        previousAligned,
        targetAligned,
      )

    upperNumerator =
      float256ShortestAddBig(
        targetAligned,
        nextAligned,
      )

    boundaryDenominator =
      float256ShortestOne()

  let boundaryBinaryExponent =
    commonBinaryExponent - 1

  if boundaryBinaryExponent >= 0:
    lowerNumerator =
      lowerNumerator.float256ShortestShiftLeft(
        boundaryBinaryExponent
      )

    upperNumerator =
      upperNumerator.float256ShortestShiftLeft(
        boundaryBinaryExponent
      )
  else:
    boundaryDenominator =
      boundaryDenominator.float256ShortestShiftLeft(
        -boundaryBinaryExponent
      )

  if decimalExponent >= 0:
    boundaryDenominator =
      float256ShortestMultiplyBig(
        boundaryDenominator,
        decimalScale,
      )
  else:
    lowerNumerator =
      float256ShortestMultiplyBig(
        lowerNumerator,
        decimalScale,
      )

    upperNumerator =
      float256ShortestMultiplyBig(
        upperNumerator,
        decimalScale,
      )

  result.lowerNumerator =
    lowerNumerator

  result.upperNumerator =
    upperNumerator

  result.boundaryDenominator =
    boundaryDenominator

  result.decimalExponent =
    decimalExponent

  result.midpointInclusive =
    (
      magnitudeBits.word0 and
      1'u64
    ) == 0'u64

proc float256ShortestNormalizedCandidate(
    rawDigits: string;
    candidateExponent: int,
): Float256ShortestCandidate =
  result.digits =
    rawDigits

  result.decimalPower =
    candidateExponent -
    rawDigits.len +
    1

  while result.digits.len > 1 and
      result.digits[^1] == '0':
    result.digits.setLen(
      result.digits.len - 1
    )

    inc result.decimalPower

  result.significantDigits =
    result.digits.len

  result.coefficientOdd =
    (
      (
        ord(
          result.digits[^1]
        ) -
        ord('0')
      ) and 1
    ) != 0

proc float256ShortestRender(
    candidate:
      Float256ShortestCandidate,
): string =
  let
    digits =
      candidate.digits

    scientificExponent =
      digits.len -
      1 +
      candidate.decimalPower

  if (
    -4 <= scientificExponent and
    scientificExponent <
      digits.len
  ):
    let pointPosition =
      digits.len +
      candidate.decimalPower

    if pointPosition <= 0:
      result = "0."

      for _ in 0 ..<
          -pointPosition:
        result.add('0')

      result.add(
        digits
      )

      return

    if pointPosition >=
        digits.len:
      result =
        digits

      for _ in 0 ..<
          (
            pointPosition -
            digits.len
          ):
        result.add('0')

      return

    result.add(
      digits[
        0 ..<
        pointPosition
      ]
    )

    result.add('.')

    result.add(
      digits[
        pointPosition ..
        digits.high
      ]
    )

    return

  result.add(
    digits[0]
  )

  if digits.len > 1:
    result.add('.')

    result.add(
      digits[
        1 ..
        digits.high
      ]
    )

  result.add('e')

  result.add(
    $scientificExponent
  )

func float256ShortestFormat(
    value: Float256,
): string =
  let negative =
    signBit(
      value
    )

  if isNaN(value):
    result =
      if negative:
        "-nan"
      else:
        "nan"

    return

  if isInfinite(value):
    result =
      if negative:
        "-inf"
      else:
        "inf"

    return

  if isZero(value):
    result =
      if negative:
        "-0"
      else:
        "0"

    return

  let prepared =
    float256ShortestPrepare(
      value
    )

  var
    remainder =
      prepared.numerator.float256ShortestClone()

    floorCoefficient:
      Float256DecimalBigUInt

    decimalGridPower =
      float256ShortestOne()

    digits = ""

  for digitStep in 1 .. 73:
    var digit = 0

    while
        float256DecimalCompare(
          remainder,
          prepared.denominator,
        ) >= 0:
      remainder.float256DecimalSubtractAssign(
        prepared.denominator
      )

      inc digit

    doAssert digit >= 0 and
      digit <= 9

    floorCoefficient.float256DecimalMultiplySmall(
      10'u32
    )

    floorCoefficient.float256DecimalAddSmall(
      uint32(
        digit
      )
    )

    digits.add(
      char(
        ord('0') +
        digit
      )
    )

    let
      lowerRight =
        float256ShortestMultiplyBig(
          prepared.lowerNumerator,
          decimalGridPower,
        )

      upperRight =
        float256ShortestMultiplyBig(
          prepared.upperNumerator,
          decimalGridPower,
        )

      floorLeft =
        float256ShortestMultiplyBig(
          floorCoefficient,
          prepared.boundaryDenominator,
        )

    var ceilCoefficient =
      floorCoefficient.float256ShortestClone()

    ceilCoefficient.float256DecimalAddSmall(
      1'u32
    )

    let
      ceilLeft =
        float256ShortestMultiplyBig(
          ceilCoefficient,
          prepared.boundaryDenominator,
        )

      floorLowerComparison =
        float256DecimalCompare(
          floorLeft,
          lowerRight,
        )

      floorUpperComparison =
        float256DecimalCompare(
          floorLeft,
          upperRight,
        )

      ceilLowerComparison =
        float256DecimalCompare(
          ceilLeft,
          lowerRight,
        )

      ceilUpperComparison =
        float256DecimalCompare(
          ceilLeft,
          upperRight,
        )

      floorValid =
        (
          floorLowerComparison > 0 or
          (
            floorLowerComparison == 0 and
            prepared.midpointInclusive
          )
        ) and
        (
          floorUpperComparison < 0 or
          (
            floorUpperComparison == 0 and
            prepared.midpointInclusive
          )
        )

      ceilValid =
        (
          ceilLowerComparison > 0 or
          (
            ceilLowerComparison == 0 and
            prepared.midpointInclusive
          )
        ) and
        (
          ceilUpperComparison < 0 or
          (
            ceilUpperComparison == 0 and
            prepared.midpointInclusive
          )
        )

    var
      floorCandidate:
        Float256ShortestCandidate

      ceilCandidate:
        Float256ShortestCandidate

    if floorValid:
      floorCandidate =
        float256ShortestNormalizedCandidate(
          digits,
          prepared.decimalExponent,
        )

    if ceilValid:
      var
        ceilDigits =
          digits

        ceilExponent =
          prepared.decimalExponent

      ceilDigits.float256FormatIncrementDigits(
        ceilExponent
      )

      ceilCandidate =
        float256ShortestNormalizedCandidate(
          ceilDigits,
          ceilExponent,
        )

    if floorValid or
        ceilValid:
      var selected:
        Float256ShortestCandidate

      if floorValid and
          not ceilValid:
        selected =
          floorCandidate

      elif ceilValid and
          not floorValid:
        selected =
          ceilCandidate

      elif floorCandidate.significantDigits <
          ceilCandidate.significantDigits:
        selected =
          floorCandidate

      elif ceilCandidate.significantDigits <
          floorCandidate.significantDigits:
        selected =
          ceilCandidate

      else:
        var doubledRemainder =
          remainder.float256ShortestClone()

        doubledRemainder.float256DecimalShiftLeftOne()

        let distanceComparison =
          float256DecimalCompare(
            doubledRemainder,
            prepared.denominator,
          )

        if distanceComparison < 0:
          selected =
            floorCandidate

        elif distanceComparison > 0:
          selected =
            ceilCandidate

        elif floorCandidate.coefficientOdd !=
            ceilCandidate.coefficientOdd:
          if floorCandidate.coefficientOdd:
            selected =
              ceilCandidate
          else:
            selected =
              floorCandidate

        else:
          selected =
            floorCandidate

      result =
        float256ShortestRender(
          selected
        )

      if negative:
        result =
          "-" &
          result

      return

    remainder.float256DecimalMultiplySmall(
      10'u32
    )

    decimalGridPower.float256DecimalMultiplySmall(
      10'u32
    )

  raise newException(
    AssertionDefect,
    "Float256 shortest formatting exceeded 73 digits",
  )

func toShortestString*(
    value: Float256,
): string =
  float256ShortestFormat(
    value
  )
