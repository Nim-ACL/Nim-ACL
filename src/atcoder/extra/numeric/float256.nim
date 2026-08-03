## Project-local binary256-style raw representation.
##
## This core packet intentionally provides only:
## - exact raw-bit construction and decomposition
## - sign, exponent and fraction extraction
## - encoding classification
## - signed zero, infinity and NaN constants
## - sign manipulation
## - total ordering and adjacent-value operations
##
## Arithmetic, conversions and formatting are intentionally deferred.

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
