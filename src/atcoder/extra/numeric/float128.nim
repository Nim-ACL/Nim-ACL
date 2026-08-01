## Portable IEEE 754 binary128 bit representation.
##
## Phase F0 intentionally provides only:
## - raw bit construction and decomposition
## - sign, exponent and fraction extraction
## - value classification
## - signed zero, infinity and NaN construction
##
## Arithmetic and numeric conversions are intentionally deferred.

import atcoder/extra/numeric/int128
import atcoder/extra/numeric/int256

const
  Float128ExponentBits* = 15
  Float128FractionBits* = 112
  Float128PrecisionBits* = 113
  Float128ExponentBias* = 16383

  float128SignMask = 0x8000_0000_0000_0000'u64
  float128ExponentMask = 0x7FFF_0000_0000_0000'u64
  float128FractionHighMask = 0x0000_FFFF_FFFF_FFFF'u64
  float128QuietNaNMask = 0x0000_8000_0000_0000'u64
  float128SignalingPayloadHighMask = 0x0000_7FFF_FFFF_FFFF'u64
  float128MaxBiasedExponent = 0x7FFF'u16

type
  Float128* = object
    ## Raw binary128 storage. Fields remain private.
    high: uint64
    low: uint64

  Float128Class* = enum
    f128Zero
    f128Subnormal
    f128Normal
    f128Infinity
    f128QuietNaN
    f128SignalingNaN

const
  positiveZeroFloat128* =
    Float128(high: 0x0000_0000_0000_0000'u64, low: 0'u64)

  negativeZeroFloat128* =
    Float128(high: 0x8000_0000_0000_0000'u64, low: 0'u64)

  positiveInfinityFloat128* =
    Float128(high: 0x7FFF_0000_0000_0000'u64, low: 0'u64)

  negativeInfinityFloat128* =
    Float128(high: 0xFFFF_0000_0000_0000'u64, low: 0'u64)

  canonicalQuietNaNFloat128* =
    Float128(high: 0x7FFF_8000_0000_0000'u64, low: 0'u64)

  canonicalSignalingNaNFloat128* =
    Float128(high: 0x7FFF_0000_0000_0000'u64, low: 1'u64)

func fromBits*(high, low: uint64): Float128 {.inline.} =
  ## Constructs a Float128 from its exact binary representation.
  Float128(high: high, low: low)

func toBits*(value: Float128): tuple[high, low: uint64] {.inline.} =
  ## Returns the exact binary representation.
  (high: value.high, low: value.low)

func sameBits*(a, b: Float128): bool {.inline.} =
  ## Tests bitwise identity rather than IEEE numeric equality.
  a.high == b.high and a.low == b.low

func signBit*(value: Float128): bool {.inline.} =
  (value.high and float128SignMask) != 0'u64

func biasedExponent*(value: Float128): uint16 {.inline.} =
  uint16((value.high and float128ExponentMask) shr 48)

func fractionHighBits*(value: Float128): uint64 {.inline.} =
  value.high and float128FractionHighMask

func fractionLowBits*(value: Float128): uint64 {.inline.} =
  value.low

func fractionIsZero(value: Float128): bool {.inline.} =
  fractionHighBits(value) == 0'u64 and value.low == 0'u64

func isZero*(value: Float128): bool {.inline.} =
  biasedExponent(value) == 0'u16 and fractionIsZero(value)

func isSubnormal*(value: Float128): bool {.inline.} =
  biasedExponent(value) == 0'u16 and not fractionIsZero(value)

func isNormal*(value: Float128): bool {.inline.} =
  let exponent = biasedExponent(value)
  exponent != 0'u16 and exponent != float128MaxBiasedExponent

func isInfinite*(value: Float128): bool {.inline.} =
  biasedExponent(value) == float128MaxBiasedExponent and
    fractionIsZero(value)

func isNaN*(value: Float128): bool {.inline.} =
  biasedExponent(value) == float128MaxBiasedExponent and
    not fractionIsZero(value)

func isQuietNaN*(value: Float128): bool {.inline.} =
  isNaN(value) and
    (fractionHighBits(value) and float128QuietNaNMask) != 0'u64

func isSignalingNaN*(value: Float128): bool {.inline.} =
  isNaN(value) and
    (fractionHighBits(value) and float128QuietNaNMask) == 0'u64

func isFinite*(value: Float128): bool {.inline.} =
  biasedExponent(value) != float128MaxBiasedExponent

func classify*(value: Float128): Float128Class =
  let exponent = biasedExponent(value)

  if exponent == 0'u16:
    if fractionIsZero(value):
      result = f128Zero
    else:
      result = f128Subnormal
  elif exponent != float128MaxBiasedExponent:
    result = f128Normal
  elif fractionIsZero(value):
    result = f128Infinity
  elif isQuietNaN(value):
    result = f128QuietNaN
  else:
    result = f128SignalingNaN

func withSign*(value: Float128, negative: bool): Float128 {.inline.} =
  var high = value.high and not float128SignMask

  if negative:
    high = high or float128SignMask

  Float128(high: high, low: value.low)

func negateSign*(value: Float128): Float128 {.inline.} =
  Float128(
    high: value.high xor float128SignMask,
    low: value.low
  )

func float128IncrementBits(
    value: Float128;
): Float128 {.inline.} =
  if value.low == high(uint64):
    Float128(
      high: value.high + 1'u64,
      low: 0'u64,
    )
  else:
    Float128(
      high: value.high,
      low: value.low + 1'u64,
    )

func float128DecrementBits(
    value: Float128;
): Float128 {.inline.} =
  if value.low == 0'u64:
    Float128(
      high: value.high - 1'u64,
      low: high(uint64),
    )
  else:
    Float128(
      high: value.high,
      low: value.low - 1'u64,
    )

func nextUp*(value: Float128): Float128 {.inline.} =
  ## Returns the adjacent representable value toward positive infinity.
  ##
  ## NaN encodings are returned bit-for-bit unchanged. Both signed zeros
  ## advance to the positive minimum subnormal.

  if isNaN(value) or sameBits(
      value,
      positiveInfinityFloat128,
  ):
    return value

  if isZero(value):
    return fromBits(
      0'u64,
      1'u64,
    )

  if signBit(value):
    result =
      float128DecrementBits(
        value,
      )
  else:
    result =
      float128IncrementBits(
        value,
      )

func nextDown*(value: Float128): Float128 {.inline.} =
  ## Returns the adjacent representable value toward negative infinity.
  ##
  ## NaN encodings are returned bit-for-bit unchanged. Both signed zeros
  ## advance to the negative minimum subnormal.

  if isNaN(value) or sameBits(
      value,
      negativeInfinityFloat128,
  ):
    return value

  if isZero(value):
    return fromBits(
      float128SignMask,
      1'u64,
    )

  if signBit(value):
    result =
      float128IncrementBits(
        value,
      )
  else:
    result =
      float128DecrementBits(
        value,
      )

func copySign*(magnitude, sign: Float128): Float128 {.inline.} =
  ## Copies only the sign bit from sign to magnitude.
  ##
  ## Every other magnitude bit is preserved, including a NaN payload and
  ## its quiet or signaling state.

  withSign(
    magnitude,
    signBit(sign),
  )

func float128TotalOrderKey(
    value: Float128;
): tuple[high, low: uint64] {.inline.} =
  if signBit(value):
    (
      high: not value.high,
      low: not value.low,
    )
  else:
    (
      high: value.high xor float128SignMask,
      low: value.low,
    )

func totalOrder*(x, y: Float128): bool {.inline.} =
  ## Applies an inclusive total ordering to every binary128 encoding.
  ##
  ## The order distinguishes signed zeros, signaling and quiet NaNs,
  ## NaN signs, and NaN payloads.

  let
    xKey =
      float128TotalOrderKey(x)
    yKey =
      float128TotalOrderKey(y)

  xKey.high < yKey.high or
    (
      xKey.high == yKey.high and
      xKey.low <= yKey.low
    )

func float128PacketTwoQuietNaN(
    value: Float128;
): Float128 {.inline.} =
  let bits =
    toBits(value)

  fromBits(
    bits.high or
      float128QuietNaNMask,
    bits.low,
  )

func float128PacketTwoPreferredQuietNaN(
    x,
    y: Float128;
): Float128 {.inline.} =
  if isNaN(x):
    float128PacketTwoQuietNaN(x)
  else:
    float128PacketTwoQuietNaN(y)

func float128PacketTwoNumericEqual(
    x,
    y: Float128;
): bool {.inline.} =
  if isNaN(x) or
      isNaN(y):
    return false

  if isZero(x) and
      isZero(y):
    return true

  sameBits(x, y)

func float128PacketTwoNumericLess(
    x,
    y: Float128;
): bool {.inline.} =
  if isNaN(x) or
      isNaN(y) or
      float128PacketTwoNumericEqual(
        x,
        y,
      ):
    return false

  totalOrder(x, y)

func float128PacketTwoMagnitude(
    value: Float128;
): Float128 {.inline.} =
  withSign(
    value,
    false,
  )

func nextAfter*(x, y: Float128): Float128 {.inline.} =
  ## Returns the adjacent encoding from x in the direction of y.
  ##
  ## Numerically equal operands return the exact encoding of y. A NaN
  ## result uses the left NaN when present and otherwise the right NaN;
  ## signaling NaNs are quieted while their sign and payload are preserved.

  if isNaN(x) or
      isNaN(y):
    return float128PacketTwoPreferredQuietNaN(
      x,
      y,
    )

  if float128PacketTwoNumericEqual(
      x,
      y,
  ):
    return y

  if float128PacketTwoNumericLess(
      x,
      y,
  ):
    nextUp(x)
  else:
    nextDown(x)

func totalOrderMag*(x, y: Float128): bool {.inline.} =
  ## Applies totalOrder after clearing both sign bits.

  totalOrder(
    float128PacketTwoMagnitude(x),
    float128PacketTwoMagnitude(y),
  )

func minimum*(x, y: Float128): Float128 {.inline.} =
  ## Returns the NaN-propagating numeric minimum.
  ##
  ## Equal numeric values are resolved by totalOrder, selecting negative
  ## zero over positive zero.

  if isNaN(x) or
      isNaN(y):
    return float128PacketTwoPreferredQuietNaN(
      x,
      y,
    )

  if float128PacketTwoNumericLess(
      x,
      y,
  ):
    return x

  if float128PacketTwoNumericLess(
      y,
      x,
  ):
    return y

  if totalOrder(x, y):
    x
  else:
    y

func maximum*(x, y: Float128): Float128 {.inline.} =
  ## Returns the NaN-propagating numeric maximum.
  ##
  ## Equal numeric values are resolved by totalOrder, selecting positive
  ## zero over negative zero.

  if isNaN(x) or
      isNaN(y):
    return float128PacketTwoPreferredQuietNaN(
      x,
      y,
    )

  if float128PacketTwoNumericLess(
      x,
      y,
  ):
    return y

  if float128PacketTwoNumericLess(
      y,
      x,
  ):
    return x

  if totalOrder(x, y):
    y
  else:
    x

func minimumNumber*(x, y: Float128): Float128 {.inline.} =
  ## Prefers the numeric operand when exactly one operand is NaN.

  let
    xNaN =
      isNaN(x)
    yNaN =
      isNaN(y)

  if xNaN and
      yNaN:
    return float128PacketTwoQuietNaN(x)

  if xNaN:
    return y

  if yNaN:
    return x

  minimum(x, y)

func maximumNumber*(x, y: Float128): Float128 {.inline.} =
  ## Prefers the numeric operand when exactly one operand is NaN.

  let
    xNaN =
      isNaN(x)
    yNaN =
      isNaN(y)

  if xNaN and
      yNaN:
    return float128PacketTwoQuietNaN(x)

  if xNaN:
    return y

  if yNaN:
    return x

  maximum(x, y)

func minimumMagnitude*(x, y: Float128): Float128 {.inline.} =
  ## Returns the operand with smaller magnitude and propagates NaNs.

  if isNaN(x) or
      isNaN(y):
    return float128PacketTwoPreferredQuietNaN(
      x,
      y,
    )

  let
    xMagnitude =
      float128PacketTwoMagnitude(x)
    yMagnitude =
      float128PacketTwoMagnitude(y)

  if float128PacketTwoNumericLess(
      xMagnitude,
      yMagnitude,
  ):
    return x

  if float128PacketTwoNumericLess(
      yMagnitude,
      xMagnitude,
  ):
    return y

  minimum(x, y)

func maximumMagnitude*(x, y: Float128): Float128 {.inline.} =
  ## Returns the operand with larger magnitude and propagates NaNs.

  if isNaN(x) or
      isNaN(y):
    return float128PacketTwoPreferredQuietNaN(
      x,
      y,
    )

  let
    xMagnitude =
      float128PacketTwoMagnitude(x)
    yMagnitude =
      float128PacketTwoMagnitude(y)

  if float128PacketTwoNumericLess(
      xMagnitude,
      yMagnitude,
  ):
    return y

  if float128PacketTwoNumericLess(
      yMagnitude,
      xMagnitude,
  ):
    return x

  maximum(x, y)

func minimumMagnitudeNumber*(x, y: Float128): Float128 {.inline.} =
  ## Prefers the numeric operand when exactly one operand is NaN.

  let
    xNaN =
      isNaN(x)
    yNaN =
      isNaN(y)

  if xNaN and
      yNaN:
    return float128PacketTwoQuietNaN(x)

  if xNaN:
    return y

  if yNaN:
    return x

  minimumMagnitude(x, y)

func maximumMagnitudeNumber*(x, y: Float128): Float128 {.inline.} =
  ## Prefers the numeric operand when exactly one operand is NaN.

  let
    xNaN =
      isNaN(x)
    yNaN =
      isNaN(y)

  if xNaN and
      yNaN:
    return float128PacketTwoQuietNaN(x)

  if xNaN:
    return y

  if yNaN:
    return x

  maximumMagnitude(x, y)

func zeroFloat128*(negative: bool = false): Float128 {.inline.} =
  if negative:
    negativeZeroFloat128
  else:
    positiveZeroFloat128

func infinityFloat128*(negative: bool = false): Float128 {.inline.} =
  if negative:
    negativeInfinityFloat128
  else:
    positiveInfinityFloat128

# ----------------------------------------------------------------------
# Exact integer conversion using IEEE 754 roundTiesToEven
# ----------------------------------------------------------------------

type
  Float128IntegerLimbs = array[4, uint64]

func integerLimbs(value: UInt128): Float128IntegerLimbs {.inline.} =
  result = [
    low64(value),
    high64(value),
    0'u64,
    0'u64
  ]

func integerLimbs(value: UInt256): Float128IntegerLimbs {.inline.} =
  let lowHalf = low128(value)
  let highHalf = high128(value)

  result = [
    low64(lowHalf),
    high64(lowHalf),
    low64(highHalf),
    high64(highHalf)
  ]

func integerBit(
    limbs: Float128IntegerLimbs,
    index: int
  ): bool {.inline.} =
  let limbIndex = index shr 6
  let bitIndex = index and 63

  ((limbs[limbIndex] shr bitIndex) and 1'u64) != 0'u64

func integerBitLength(
    limbs: Float128IntegerLimbs
  ): int =
  for index in countdown(255, 0):
    if integerBit(limbs, index):
      return index + 1

  0

func anyIntegerBitsBelow(
    limbs: Float128IntegerLimbs,
    highExclusive: int
  ): bool =
  if highExclusive <= 0:
    return false

  for index in 0 ..< highExclusive:
    if integerBit(limbs, index):
      return true

  false

func setSignificandBit(
    significandHigh: var uint64,
    significandLow: var uint64,
    index: int
  ) {.inline.} =
  if index < 64:
    significandLow =
      significandLow or (1'u64 shl index)
  else:
    significandHigh =
      significandHigh or (1'u64 shl (index - 64))

func toFloat128FromIntegerLimbs(
    limbs: Float128IntegerLimbs,
    negative: bool
  ): Float128 =
  let bitLength = integerBitLength(limbs)

  if bitLength == 0:
    return positiveZeroFloat128

  var exponent = bitLength - 1
  var significandHigh = 0'u64
  var significandLow = 0'u64

  if bitLength <= Float128PrecisionBits:
    let leftShift = Float128PrecisionBits - bitLength

    for sourceBit in 0 ..< bitLength:
      if integerBit(limbs, sourceBit):
        setSignificandBit(
          significandHigh,
          significandLow,
          sourceBit + leftShift
        )
  else:
    let rightShift = bitLength - Float128PrecisionBits

    for destinationBit in 0 ..< Float128PrecisionBits:
      if integerBit(
          limbs,
          destinationBit + rightShift
        ):
        setSignificandBit(
          significandHigh,
          significandLow,
          destinationBit
        )

    let guardBit =
      integerBit(limbs, rightShift - 1)

    let stickyBit =
      anyIntegerBitsBelow(
        limbs,
        rightShift - 1
      )

    let retainedLeastBitIsOdd =
      (significandLow and 1'u64) != 0'u64

    if guardBit and
        (stickyBit or retainedLeastBitIsOdd):
      significandLow = significandLow + 1'u64

      if significandLow == 0'u64:
        significandHigh = significandHigh + 1'u64

      if significandHigh ==
          0x0002_0000_0000_0000'u64:
        significandHigh =
          0x0001_0000_0000_0000'u64

        significandLow = 0'u64
        exponent += 1

  let fractionHigh =
    significandHigh and
    0x0000_FFFF_FFFF_FFFF'u64

  var high =
    (uint64(exponent + Float128ExponentBias) shl 48) or
    fractionHigh

  if negative:
    high = high or 0x8000_0000_0000_0000'u64

  fromBits(high, significandLow)

func toFloat128*(value: UInt128): Float128 =
  ## Converts UInt128 exactly when possible and otherwise uses
  ## IEEE 754 roundTiesToEven.
  toFloat128FromIntegerLimbs(
    integerLimbs(value),
    false
  )

func toFloat128*(value: Int128): Float128 =
  ## Converts Int128 using its two's-complement magnitude.
  let bits = cast[UInt128](value)

  let negative =
    (high64(bits) and 0x8000_0000_0000_0000'u64) !=
    0'u64

  let magnitude =
    if negative:
      toUInt128(0'u64) - bits
    else:
      bits

  toFloat128FromIntegerLimbs(
    integerLimbs(magnitude),
    negative
  )

func toFloat128*(value: UInt256): Float128 =
  ## Converts UInt256 using IEEE 754 roundTiesToEven.
  toFloat128FromIntegerLimbs(
    integerLimbs(value),
    false
  )

func toFloat128*(value: Int256): Float128 =
  ## Converts Int256 using its two's-complement magnitude.
  let bits = cast[UInt256](value)
  let highHalf = high128(bits)

  let negative =
    (high64(highHalf) and 0x8000_0000_0000_0000'u64) !=
    0'u64

  let magnitude =
    if negative:
      toUInt256(0'u64) - bits
    else:
      bits

  toFloat128FromIntegerLimbs(
    integerLimbs(magnitude),
    negative
  )

# ----------------------------------------------------------------------
# Exact float32 / float64 conversion
# ----------------------------------------------------------------------

func float32SourceHighestBit(value: uint32): int {.inline.} =
  for index in countdown(31, 0):
    if ((value shr index) and 1'u32) != 0'u32:
      return index

  -1

func float64SourceHighestBit(value: uint64): int {.inline.} =
  for index in countdown(63, 0):
    if ((value shr index) and 1'u64) != 0'u64:
      return index

  -1

func toFloat128*(value: float32): Float128 =
  ## Converts an IEEE 754 binary32 value exactly to binary128.
  ##
  ## NaN sign, quiet/signaling state and payload bits are preserved by
  ## left-aligning the binary32 fraction in the binary128 fraction.
  let
    sourceBits = cast[uint32](value)
    sourceSign = uint64(sourceBits shr 31) shl 63
    sourceExponent = (sourceBits shr 23) and 0xFF'u32
    sourceFraction = sourceBits and 0x007F_FFFF'u32

  if sourceExponent == 0'u32:
    if sourceFraction == 0'u32:
      return fromBits(sourceSign, 0'u64)

    let
      highestBit = float32SourceHighestBit(sourceFraction)
      targetExponent = uint64(highestBit + 16234)
      remainder =
        sourceFraction xor (1'u32 shl highestBit)
      targetFractionHigh =
        uint64(remainder) shl (48 - highestBit)

    return fromBits(
      sourceSign or
        (targetExponent shl 48) or
        targetFractionHigh,
      0'u64
    )

  let targetExponent =
    if sourceExponent == 0xFF'u32:
      0x7FFF'u64
    else:
      uint64(sourceExponent) + 16256'u64

  fromBits(
    sourceSign or
      (targetExponent shl 48) or
      (uint64(sourceFraction) shl 25),
    0'u64
  )

func toFloat128*(value: float64): Float128 =
  ## Converts an IEEE 754 binary64 value exactly to binary128.
  ##
  ## NaN sign, quiet/signaling state and payload bits are preserved by
  ## left-aligning the binary64 fraction in the binary128 fraction.
  let
    sourceBits = cast[uint64](value)
    sourceSign = sourceBits and 0x8000_0000_0000_0000'u64
    sourceExponent =
      (sourceBits shr 52) and 0x7FF'u64
    sourceFraction =
      sourceBits and 0x000F_FFFF_FFFF_FFFF'u64

  if sourceExponent == 0'u64:
    if sourceFraction == 0'u64:
      return fromBits(sourceSign, 0'u64)

    let
      highestBit = float64SourceHighestBit(sourceFraction)
      targetExponent = uint64(highestBit + 15309)
      remainder =
        sourceFraction xor (1'u64 shl highestBit)

    var
      targetFractionHigh: uint64
      targetFractionLow: uint64

    if highestBit <= 48:
      targetFractionHigh =
        remainder shl (48 - highestBit)
      targetFractionLow = 0'u64
    else:
      targetFractionHigh =
        remainder shr (highestBit - 48)
      targetFractionLow =
        remainder shl (112 - highestBit)

    return fromBits(
      sourceSign or
        (targetExponent shl 48) or
        targetFractionHigh,
      targetFractionLow
    )

  let targetExponent =
    if sourceExponent == 0x7FF'u64:
      0x7FFF'u64
    else:
      sourceExponent + 15360'u64

  fromBits(
    sourceSign or
      (targetExponent shl 48) or
      (sourceFraction shr 4),
    sourceFraction shl 60
  )

# ----------------------------------------------------------------------
# Checked Float128 to fixed-width integer conversion
# ----------------------------------------------------------------------

proc float128IntegerMagnitude128(
    value: Float128;
    destination: var UInt128;
    negative: var bool;
    unbiasedExponent: var int;
    sourceFractionNonzero: var bool;
): bool =
  destination = toUInt128(0'u64)

  let
    raw = toBits(value)
    exponentField =
      int((raw.high shr 48) and 0x7FFF'u64)
    fractionHigh =
      raw.high and 0x0000_FFFF_FFFF_FFFF'u64

  negative =
    (raw.high and 0x8000_0000_0000_0000'u64) != 0'u64

  sourceFractionNonzero =
    fractionHigh != 0'u64 or raw.low != 0'u64

  unbiasedExponent = -16383

  if exponentField == 0x7FFF:
    return false

  if exponentField == 0:
    return true

  unbiasedExponent = exponentField - 16383

  if unbiasedExponent < 0:
    return true

  if unbiasedExponent > 127:
    return false

  let significand =
    (
      toUInt128(
        fractionHigh or 0x0001_0000_0000_0000'u64
      ) shl 64
    ) or toUInt128(raw.low)

  if unbiasedExponent >= 112:
    destination =
      significand shl (unbiasedExponent - 112)
  else:
    destination =
      significand shr (112 - unbiasedExponent)

  true

proc float128IntegerMagnitude256(
    value: Float128;
    destination: var UInt256;
    negative: var bool;
    unbiasedExponent: var int;
    sourceFractionNonzero: var bool;
): bool =
  destination = toUInt256(0'u64)

  let
    raw = toBits(value)
    exponentField =
      int((raw.high shr 48) and 0x7FFF'u64)
    fractionHigh =
      raw.high and 0x0000_FFFF_FFFF_FFFF'u64

  negative =
    (raw.high and 0x8000_0000_0000_0000'u64) != 0'u64

  sourceFractionNonzero =
    fractionHigh != 0'u64 or raw.low != 0'u64

  unbiasedExponent = -16383

  if exponentField == 0x7FFF:
    return false

  if exponentField == 0:
    return true

  unbiasedExponent = exponentField - 16383

  if unbiasedExponent < 0:
    return true

  if unbiasedExponent > 255:
    return false

  let significand128 =
    (
      toUInt128(
        fractionHigh or 0x0001_0000_0000_0000'u64
      ) shl 64
    ) or toUInt128(raw.low)

  let significand =
    toUInt256(significand128)

  if unbiasedExponent >= 112:
    destination =
      significand shl (unbiasedExponent - 112)
  else:
    destination =
      significand shr (112 - unbiasedExponent)

  true

proc tryToUInt128*(
    value: Float128;
    destination: var UInt128;
): bool =
  destination = toUInt128(0'u64)

  var
    magnitude: UInt128
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float128IntegerMagnitude128(
    value,
    magnitude,
    negative,
    unbiasedExponent,
    sourceFractionNonzero,
  ):
    return false

  if negative and unbiasedExponent >= 0:
    return false

  destination = magnitude
  true

proc tryToInt128*(
    value: Float128;
    destination: var Int128;
): bool =
  destination =
    cast[Int128](toUInt128(0'u64))

  var
    magnitude: UInt128
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float128IntegerMagnitude128(
    value,
    magnitude,
    negative,
    unbiasedExponent,
    sourceFractionNonzero,
  ):
    return false

  if unbiasedExponent == 127:
    if not negative or sourceFractionNonzero:
      return false

  if negative:
    destination =
      cast[Int128](
        toUInt128(0'u64) - magnitude
      )
  else:
    destination = cast[Int128](magnitude)

  true

proc tryToUInt256*(
    value: Float128;
    destination: var UInt256;
): bool =
  destination = toUInt256(0'u64)

  var
    magnitude: UInt256
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float128IntegerMagnitude256(
    value,
    magnitude,
    negative,
    unbiasedExponent,
    sourceFractionNonzero,
  ):
    return false

  if negative and unbiasedExponent >= 0:
    return false

  destination = magnitude
  true

proc tryToInt256*(
    value: Float128;
    destination: var Int256;
): bool =
  destination =
    cast[Int256](toUInt256(0'u64))

  var
    magnitude: UInt256
    negative: bool
    unbiasedExponent: int
    sourceFractionNonzero: bool

  if not float128IntegerMagnitude256(
    value,
    magnitude,
    negative,
    unbiasedExponent,
    sourceFractionNonzero,
  ):
    return false

  if unbiasedExponent == 255:
    if not negative or sourceFractionNonzero:
      return false

  if negative:
    destination =
      cast[Int256](
        toUInt256(0'u64) - magnitude
      )
  else:
    destination = cast[Int256](magnitude)

  true

# ----------------------------------------------------------------------
# Exact binary128 downconversion
# ----------------------------------------------------------------------

func float128HighestBit64(value: uint64): int {.inline.} =
  for index in countdown(63, 0):
    if ((value shr index) and 1'u64) != 0'u64:
      return index

  -1

func float128HighestBit112(
    high, low: uint64;
): int {.inline.} =
  if high != 0'u64:
    return 64 + float128HighestBit64(high)

  float128HighestBit64(low)

func float128ShiftRightToUInt64(
    high, low: uint64;
    shift: int;
): uint64 {.inline.} =
  if shift <= 0:
    if shift == 0:
      return low

    let leftShift = -shift

    if high == 0'u64 and leftShift < 64:
      return low shl leftShift

    return 0'u64

  if shift < 64:
    return
      (low shr shift) or
      (high shl (64 - shift))

  if shift == 64:
    return high

  if shift < 128:
    return high shr (shift - 64)

  0'u64

func float128RoundShiftToUInt64(
    high, low: uint64;
    shift: int;
): uint64 {.inline.} =
  if shift <= 0:
    return float128ShiftRightToUInt64(
      high,
      low,
      shift,
    )

  if shift > 128:
    return 0'u64

  let
    retained =
      float128ShiftRightToUInt64(
        high,
        low,
        shift,
      )
    guardPosition = shift - 1

  var
    guard = 0'u64
    sticky = false

  if guardPosition < 64:
    guard =
      (low shr guardPosition) and 1'u64

    if guardPosition > 0:
      let mask =
        (1'u64 shl guardPosition) - 1'u64

      sticky = (low and mask) != 0'u64
  else:
    let highPosition = guardPosition - 64

    guard =
      (high shr highPosition) and 1'u64

    sticky = low != 0'u64

    if highPosition > 0:
      let mask =
        (1'u64 shl highPosition) - 1'u64

      sticky =
        sticky or
        ((high and mask) != 0'u64)

  if guard != 0'u64 and
      (sticky or ((retained and 1'u64) != 0'u64)):
    return retained + 1'u64

  retained

func float128ToBinaryBits(
    value: Float128;
    targetFractionBits: int;
    targetBias: int;
    targetMinimumExponent: int;
    targetMaximumExponent: int;
    targetSignShift: int;
    targetExponentAllOnes: uint64;
): uint64 =
  let
    source = toBits(value)
    sourceHigh = source.high
    sourceLow = source.low
    sourceSign = sourceHigh shr 63
    sourceExponent =
      int((sourceHigh shr 48) and 0x7FFF'u64)
    sourceFractionHigh =
      sourceHigh and 0x0000_FFFF_FFFF_FFFF'u64
    targetSign =
      sourceSign shl targetSignShift

  if sourceExponent == 0x7FFF:
    if sourceFractionHigh == 0'u64 and
        sourceLow == 0'u64:
      return
        targetSign or
        (targetExponentAllOnes shl targetFractionBits)

    let payloadShift =
      112 - targetFractionBits

    var targetFraction =
      float128ShiftRightToUInt64(
        sourceFractionHigh,
        sourceLow,
        payloadShift,
      )

    if targetFraction == 0'u64:
      targetFraction = 1'u64

    return
      targetSign or
      (targetExponentAllOnes shl targetFractionBits) or
      targetFraction

  if sourceExponent == 0 and
      sourceFractionHigh == 0'u64 and
      sourceLow == 0'u64:
    return targetSign

  var
    significandHigh: uint64
    significandLow = sourceLow
    highestBit: int
    binaryExponent: int

  if sourceExponent == 0:
    significandHigh = sourceFractionHigh
    highestBit =
      float128HighestBit112(
        significandHigh,
        significandLow,
      )
    binaryExponent = -16494
  else:
    significandHigh =
      sourceFractionHigh or
      (1'u64 shl 48)
    highestBit = 112
    binaryExponent =
      sourceExponent - 16383 - 112

  let resultExponent =
    highestBit + binaryExponent

  if resultExponent > targetMaximumExponent:
    return
      targetSign or
      (targetExponentAllOnes shl targetFractionBits)

  let targetHiddenBit =
    1'u64 shl targetFractionBits

  if resultExponent >= targetMinimumExponent:
    let shift =
      highestBit - targetFractionBits

    var
      roundedSignificand =
        float128RoundShiftToUInt64(
          significandHigh,
          significandLow,
          shift,
        )
      normalizedExponent = resultExponent

    if roundedSignificand ==
        (targetHiddenBit shl 1):
      roundedSignificand =
        roundedSignificand shr 1
      inc normalizedExponent

    if normalizedExponent > targetMaximumExponent:
      return
        targetSign or
        (targetExponentAllOnes shl targetFractionBits)

    let
      targetExponent =
        uint64(normalizedExponent + targetBias)
      targetFraction =
        roundedSignificand - targetHiddenBit

    return
      targetSign or
      (targetExponent shl targetFractionBits) or
      targetFraction

  let
    targetQuantumExponent =
      targetMinimumExponent - targetFractionBits
    shift =
      targetQuantumExponent - binaryExponent
    roundedFraction =
      float128RoundShiftToUInt64(
        significandHigh,
        significandLow,
        shift,
      )

  if roundedFraction == 0'u64:
    return targetSign

  if roundedFraction >= targetHiddenBit:
    return
      targetSign or
      (1'u64 shl targetFractionBits)

  targetSign or roundedFraction

func toFloat32*(value: Float128): float32 =
  ## Converts binary128 to binary32 using roundTiesToEven.
  ##
  ## Signed zero and infinity are preserved. NaN sign and the most
  ## significant representable payload bits are retained. A signaling
  ## NaN remains signaling when its retained payload is nonzero.
  let bits =
    uint32(
      float128ToBinaryBits(
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

func toFloat64*(value: Float128): float64 =
  ## Converts binary128 to binary64 using roundTiesToEven.
  ##
  ## Signed zero and infinity are preserved. NaN sign and the most
  ## significant representable payload bits are retained. A signaling
  ## NaN remains signaling when its retained payload is nonzero.
  let bits =
    float128ToBinaryBits(
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
# IEEE 754 binary128 unary minus, addition and subtraction
# ----------------------------------------------------------------------

type Float128FiniteParts = object
  sign: bool
  exponent: int
  significand: UInt256

func float128UInt256One(): UInt256 {.inline.} =
  toUInt256(1'u64)

func float128IsZeroBits(
    high, low: uint64;
): bool {.inline.} =
  (high and 0x7FFF_FFFF_FFFF_FFFF'u64) == 0'u64 and
    low == 0'u64

func float128IsInfinityBits(
    high, low: uint64;
): bool {.inline.} =
  (high and 0x7FFF_FFFF_FFFF_FFFF'u64) ==
      0x7FFF_0000_0000_0000'u64 and
    low == 0'u64

func float128IsNaNBits(
    high, low: uint64;
): bool {.inline.} =
  ((high shr 48) and 0x7FFF'u64) == 0x7FFF'u64 and
    (
      (high and 0x0000_FFFF_FFFF_FFFF'u64) != 0'u64 or
      low != 0'u64
    )

func float128QuietNaNBits(
    high, low: uint64;
): Float128 {.inline.} =
  fromBits(
    high or 0x0000_8000_0000_0000'u64,
    low,
  )

func float128CanonicalQuietNaN(): Float128 {.inline.} =
  fromBits(
    0x7FFF_8000_0000_0000'u64,
    0'u64,
  )

func float128HighestBit256(
    value: UInt256;
): int {.inline.} =
  for index in countdown(255, 0):
    if (toUInt(value shr index) and 1'u64) != 0'u64:
      return index

  -1

func float128ShiftRightJam256(
    value: UInt256;
    distance: int;
): UInt256 {.inline.} =
  let zero = default(UInt256)

  if value == zero:
    return zero

  if distance <= 0:
    return value shl (-distance)

  if distance >= 256:
    return float128UInt256One()

  var shifted = value shr distance

  if (shifted shl distance) != value:
    shifted = shifted or float128UInt256One()

  shifted

func float128DecodeFiniteBits(
    high, low: uint64;
): Float128FiniteParts =
  result.sign =
    (high and 0x8000_0000_0000_0000'u64) != 0'u64

  let
    exponentField =
      int((high shr 48) and 0x7FFF'u64)
    fraction =
      (
        toUInt256(
          high and 0x0000_FFFF_FFFF_FFFF'u64
        ) shl 64
      ) or
      toUInt256(low)

  if exponentField == 0:
    let highest = float128HighestBit256(fraction)
    let normalizationShift = 112 - highest

    result.exponent =
      -16382 - normalizationShift
    result.significand =
      fraction shl normalizationShift
  else:
    result.exponent =
      exponentField - 16383
    result.significand =
      fraction or
      (float128UInt256One() shl 112)

func float128MagnitudeLess(
    lhs, rhs: Float128FiniteParts;
): bool {.inline.} =
  if lhs.exponent != rhs.exponent:
    return lhs.exponent < rhs.exponent

  lhs.significand < rhs.significand

func float128PackRounded(
    sign: bool;
    sourceExponent: int;
    sourceExtended: UInt256;
): Float128 =
  let
    zero = default(UInt256)
    one = float128UInt256One()
    hiddenBit = one shl 112
    carryBit = one shl 113
    signBits =
      if sign:
        0x8000_0000_0000_0000'u64
      else:
        0'u64

  if sourceExtended == zero:
    return fromBits(signBits, 0'u64)

  var
    exponent = sourceExponent
    extended = sourceExtended

  if exponent < -16382:
    extended =
      float128ShiftRightJam256(
        extended,
        -16382 - exponent,
      )
    exponent = -16382

  var retained = extended shr 3
  let roundBits = toUInt(extended) and 7'u64

  if roundBits > 4'u64 or
      (
        roundBits == 4'u64 and
        ((toUInt(retained) and 1'u64) != 0'u64)
      ):
    retained = retained + one

  if retained >= carryBit:
    retained = retained shr 1
    inc exponent

  if exponent > 16383:
    return fromBits(
      signBits or 0x7FFF_0000_0000_0000'u64,
      0'u64,
    )

  if retained == zero:
    return fromBits(signBits, 0'u64)

  if exponent == -16382 and retained < hiddenBit:
    return fromBits(
      signBits or
        (
          toUInt(retained shr 64) and
          0x0000_FFFF_FFFF_FFFF'u64
        ),
      toUInt(retained),
    )

  let
    fraction = retained - hiddenBit
    exponentField = uint64(exponent + 16383)

  fromBits(
    signBits or
      (exponentField shl 48) or
      (
        toUInt(fraction shr 64) and
        0x0000_FFFF_FFFF_FFFF'u64
      ),
    toUInt(fraction),
  )

func float128AddSub(
    lhs, rhs: Float128;
    subtract: bool;
): Float128 =
  let
    lhsBits = toBits(lhs)
    rhsBits = toBits(rhs)

  if float128IsNaNBits(lhsBits.high, lhsBits.low):
    return float128QuietNaNBits(
      lhsBits.high,
      lhsBits.low,
    )

  if float128IsNaNBits(rhsBits.high, rhsBits.low):
    return float128QuietNaNBits(
      rhsBits.high,
      rhsBits.low,
    )

  let
    effectiveRhsHigh =
      if subtract:
        rhsBits.high xor 0x8000_0000_0000_0000'u64
      else:
        rhsBits.high
    lhsInfinity =
      float128IsInfinityBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsInfinity =
      float128IsInfinityBits(
        effectiveRhsHigh,
        rhsBits.low,
      )

  if lhsInfinity and rhsInfinity:
    let
      lhsSign = lhsBits.high shr 63
      rhsSign = effectiveRhsHigh shr 63

    if lhsSign != rhsSign:
      return float128CanonicalQuietNaN()

    return lhs

  if lhsInfinity:
    return lhs

  if rhsInfinity:
    return fromBits(
      effectiveRhsHigh,
      rhsBits.low,
    )

  let
    lhsZero =
      float128IsZeroBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsZero =
      float128IsZeroBits(
        effectiveRhsHigh,
        rhsBits.low,
      )

  if lhsZero and rhsZero:
    let
      lhsSign = lhsBits.high shr 63
      rhsSign = effectiveRhsHigh shr 63

    if lhsSign == rhsSign:
      return fromBits(lhsSign shl 63, 0'u64)

    return fromBits(0'u64, 0'u64)

  if lhsZero:
    return fromBits(
      effectiveRhsHigh,
      rhsBits.low,
    )

  if rhsZero:
    return lhs

  let
    lhsParts =
      float128DecodeFiniteBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsParts =
      float128DecodeFiniteBits(
        effectiveRhsHigh,
        rhsBits.low,
      )

  if lhsParts.sign == rhsParts.sign:
    var
      larger = lhsParts
      smaller = rhsParts

    if float128MagnitudeLess(larger, smaller):
      swap(larger, smaller)

    let
      exponentDifference =
        larger.exponent - smaller.exponent
      largerExtended =
        larger.significand shl 3
      smallerExtended =
        float128ShiftRightJam256(
          smaller.significand shl 3,
          exponentDifference,
        )

    var
      sum = largerExtended + smallerExtended
      exponent = larger.exponent

    let highest = float128HighestBit256(sum)

    if highest > 115:
      let shift = highest - 115
      sum =
        float128ShiftRightJam256(
          sum,
          shift,
        )
      exponent += shift

    return float128PackRounded(
      larger.sign,
      exponent,
      sum,
    )

  var
    larger = lhsParts
    smaller = rhsParts

  if float128MagnitudeLess(larger, smaller):
    swap(larger, smaller)

  let
    exponentDifference =
      larger.exponent - smaller.exponent
    largerExtended =
      larger.significand shl 3
    smallerExtended =
      float128ShiftRightJam256(
        smaller.significand shl 3,
        exponentDifference,
      )
    zero = default(UInt256)

  var difference =
    largerExtended - smallerExtended

  if difference == zero:
    return fromBits(0'u64, 0'u64)

  var exponent = larger.exponent
  let highest = float128HighestBit256(difference)

  if highest < 115:
    let shift = 115 - highest
    difference = difference shl shift
    exponent -= shift

  float128PackRounded(
    larger.sign,
    exponent,
    difference,
  )

func `-`*(value: Float128): Float128 =
  let bits = toBits(value)

  fromBits(
    bits.high xor 0x8000_0000_0000_0000'u64,
    bits.low,
  )

func `+`*(lhs, rhs: Float128): Float128 =
  float128AddSub(lhs, rhs, false)

func `-`*(lhs, rhs: Float128): Float128 =
  float128AddSub(lhs, rhs, true)

# ----------------------------------------------------------------------
# IEEE 754 binary128 multiplication
# ----------------------------------------------------------------------

func `*`*(lhs, rhs: Float128): Float128 =
  let
    lhsBits = toBits(lhs)
    rhsBits = toBits(rhs)

  if float128IsNaNBits(lhsBits.high, lhsBits.low):
    return float128QuietNaNBits(
      lhsBits.high,
      lhsBits.low,
    )

  if float128IsNaNBits(rhsBits.high, rhsBits.low):
    return float128QuietNaNBits(
      rhsBits.high,
      rhsBits.low,
    )

  let
    negative =
      (
        (lhsBits.high xor rhsBits.high) and
        0x8000_0000_0000_0000'u64
      ) != 0'u64
    signBits =
      if negative:
        0x8000_0000_0000_0000'u64
      else:
        0'u64
    lhsInfinity =
      float128IsInfinityBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsInfinity =
      float128IsInfinityBits(
        rhsBits.high,
        rhsBits.low,
      )
    lhsZero =
      float128IsZeroBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsZero =
      float128IsZeroBits(
        rhsBits.high,
        rhsBits.low,
      )

  if (lhsInfinity and rhsZero) or
      (rhsInfinity and lhsZero):
    return float128CanonicalQuietNaN()

  if lhsInfinity or rhsInfinity:
    return fromBits(
      signBits or 0x7FFF_0000_0000_0000'u64,
      0'u64,
    )

  if lhsZero or rhsZero:
    return fromBits(signBits, 0'u64)

  let
    lhsParts =
      float128DecodeFiniteBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsParts =
      float128DecodeFiniteBits(
        rhsBits.high,
        rhsBits.low,
      )
    product =
      lhsParts.significand *
      rhsParts.significand
    highest =
      float128HighestBit256(product)
    normalizationShift =
      highest - 115
    extended =
      float128ShiftRightJam256(
        product,
        normalizationShift,
      )
    exponent =
      lhsParts.exponent +
      rhsParts.exponent +
      highest -
      224

  float128PackRounded(
    negative,
    exponent,
    extended,
  )
# ----------------------------------------------------------------------
# IEEE 754 binary128 division candidate
# ----------------------------------------------------------------------

func `/`*(lhs, rhs: Float128): Float128 =
  let
    lhsBits = toBits(lhs)
    rhsBits = toBits(rhs)

  if float128IsNaNBits(lhsBits.high, lhsBits.low):
    return float128QuietNaNBits(
      lhsBits.high,
      lhsBits.low,
    )

  if float128IsNaNBits(rhsBits.high, rhsBits.low):
    return float128QuietNaNBits(
      rhsBits.high,
      rhsBits.low,
    )

  let
    negative =
      (
        (lhsBits.high xor rhsBits.high) and
        0x8000_0000_0000_0000'u64
      ) != 0'u64
    signBits =
      if negative:
        0x8000_0000_0000_0000'u64
      else:
        0'u64
    lhsInfinity =
      float128IsInfinityBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsInfinity =
      float128IsInfinityBits(
        rhsBits.high,
        rhsBits.low,
      )
    lhsZero =
      float128IsZeroBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsZero =
      float128IsZeroBits(
        rhsBits.high,
        rhsBits.low,
      )

  if (lhsInfinity and rhsInfinity) or
      (lhsZero and rhsZero):
    return float128CanonicalQuietNaN()

  if lhsInfinity:
    return fromBits(
      signBits or 0x7FFF_0000_0000_0000'u64,
      0'u64,
    )

  if rhsInfinity:
    return fromBits(signBits, 0'u64)

  if rhsZero:
    return fromBits(
      signBits or 0x7FFF_0000_0000_0000'u64,
      0'u64,
    )

  if lhsZero:
    return fromBits(signBits, 0'u64)

  let
    lhsParts =
      float128DecodeFiniteBits(
        lhsBits.high,
        lhsBits.low,
      )
    rhsParts =
      float128DecodeFiniteBits(
        rhsBits.high,
        rhsBits.low,
      )
    one = float128UInt256One()

  var
    exponent =
      lhsParts.exponent -
      rhsParts.exponent
    numerator: UInt256

  if lhsParts.significand >= rhsParts.significand:
    numerator =
      lhsParts.significand shl 115
  else:
    numerator =
      lhsParts.significand shl 116
    dec exponent

  var quotient =
    numerator div rhsParts.significand

  let remainder =
    numerator mod rhsParts.significand

  if remainder != default(UInt256):
    quotient = quotient or one

  float128PackRounded(
    negative,
    exponent,
    quotient,
  )

# ----------------------------------------------------------------------
# IEEE 754 binary128 numeric comparisons
# ----------------------------------------------------------------------

func float128MagnitudeLessBits(
    lhsHigh, lhsLow, rhsHigh, rhsLow: uint64;
): bool {.inline.} =
  let
    lhsMagnitudeHigh =
      lhsHigh and 0x7FFF_FFFF_FFFF_FFFF'u64
    rhsMagnitudeHigh =
      rhsHigh and 0x7FFF_FFFF_FFFF_FFFF'u64

  if lhsMagnitudeHigh != rhsMagnitudeHigh:
    return lhsMagnitudeHigh < rhsMagnitudeHigh

  lhsLow < rhsLow

func `==`*(lhs, rhs: Float128): bool =
  let
    lhsBits = toBits(lhs)
    rhsBits = toBits(rhs)

  if float128IsNaNBits(lhsBits.high, lhsBits.low) or
      float128IsNaNBits(rhsBits.high, rhsBits.low):
    return false

  if float128IsZeroBits(lhsBits.high, lhsBits.low) and
      float128IsZeroBits(rhsBits.high, rhsBits.low):
    return true

  lhsBits.high == rhsBits.high and
    lhsBits.low == rhsBits.low

func `<`*(lhs, rhs: Float128): bool =
  let
    lhsBits = toBits(lhs)
    rhsBits = toBits(rhs)

  if float128IsNaNBits(lhsBits.high, lhsBits.low) or
      float128IsNaNBits(rhsBits.high, rhsBits.low):
    return false

  if float128IsZeroBits(lhsBits.high, lhsBits.low) and
      float128IsZeroBits(rhsBits.high, rhsBits.low):
    return false

  let
    lhsNegative =
      (lhsBits.high shr 63) != 0'u64
    rhsNegative =
      (rhsBits.high shr 63) != 0'u64

  if lhsNegative != rhsNegative:
    return lhsNegative

  if lhsNegative:
    return float128MagnitudeLessBits(
      rhsBits.high,
      rhsBits.low,
      lhsBits.high,
      lhsBits.low,
    )

  float128MagnitudeLessBits(
    lhsBits.high,
    lhsBits.low,
    rhsBits.high,
    rhsBits.low,
  )

func `<=`*(lhs, rhs: Float128): bool =
  (lhs < rhs) or (lhs == rhs)
# ----------------------------------------------------------------------
# IEEE 754 binary128 square root candidate
# ----------------------------------------------------------------------

func float128IntegerSqrt256(
    value: UInt256;
): tuple[root, remainder: UInt256] =
  let zero = default(UInt256)

  if value == zero:
    return (zero, zero)

  let
    one = float128UInt256One()
    bitLength =
      float128HighestBit256(value) + 1

  var current =
    one shl ((bitLength + 1) div 2)

  while true:
    let next =
      (current + value div current) shr 1

    if next >= current:
      return (
        current,
        value - current * current,
      )

    current = next

func sqrt*(value: Float128): Float128 =
  let bits = toBits(value)

  if float128IsNaNBits(bits.high, bits.low):
    return float128QuietNaNBits(
      bits.high,
      bits.low,
    )

  if float128IsZeroBits(bits.high, bits.low):
    return value

  if (bits.high shr 63) != 0'u64:
    return float128CanonicalQuietNaN()

  if float128IsInfinityBits(bits.high, bits.low):
    return value

  let parts =
    float128DecodeFiniteBits(
      bits.high,
      bits.low,
    )

  var
    exponent = parts.exponent
    significand = parts.significand

  if (exponent and 1) != 0:
    significand = significand shl 1
    dec exponent

  let
    radicand = significand shl 118
    integerResult =
      float128IntegerSqrt256(radicand)
    one = float128UInt256One()

  var extendedRoot = integerResult.root

  if integerResult.remainder != default(UInt256):
    extendedRoot = extendedRoot or one

  float128PackRounded(
    false,
    exponent div 2,
    extendedRoot,
  )

# ----------------------------------------------------------------------
# IEEE 754 binary128 fused multiply-add
# ----------------------------------------------------------------------

func float128ScaleInteger(
    value: UInt256;
    rightShift: int;
): UInt256 {.inline.} =
  if rightShift > 0:
    return float128ShiftRightJam256(
      value,
      rightShift,
    )

  if rightShift < 0:
    return value shl (-rightShift)

  value

func float128PackExactInteger(
    negative: bool;
    magnitude: UInt256;
    binaryExponent: int;
): Float128 =
  let zero = default(UInt256)

  if magnitude == zero:
    return fromBits(0'u64, 0'u64)

  let
    highest = float128HighestBit256(magnitude)
    normalizationShift = highest - 115
    extended =
      float128ScaleInteger(
        magnitude,
        normalizationShift,
      )
    exponent =
      highest + binaryExponent

  float128PackRounded(
    negative,
    exponent,
    extended,
  )

func fusedMultiplyAdd*(
    a, b, c: Float128;
): Float128 =
  ## Computes a*b+c with one final roundTiesToEven operation.
  let
    aBits = toBits(a)
    bBits = toBits(b)
    cBits = toBits(c)

  if float128IsNaNBits(aBits.high, aBits.low):
    return float128QuietNaNBits(
      aBits.high,
      aBits.low,
    )

  if float128IsNaNBits(bBits.high, bBits.low):
    return float128QuietNaNBits(
      bBits.high,
      bBits.low,
    )

  if float128IsNaNBits(cBits.high, cBits.low):
    return float128QuietNaNBits(
      cBits.high,
      cBits.low,
    )

  let
    aInfinity =
      float128IsInfinityBits(
        aBits.high,
        aBits.low,
      )
    bInfinity =
      float128IsInfinityBits(
        bBits.high,
        bBits.low,
      )
    cInfinity =
      float128IsInfinityBits(
        cBits.high,
        cBits.low,
      )
    aZero =
      float128IsZeroBits(
        aBits.high,
        aBits.low,
      )
    bZero =
      float128IsZeroBits(
        bBits.high,
        bBits.low,
      )
    cZero =
      float128IsZeroBits(
        cBits.high,
        cBits.low,
      )
    productNegative =
      (
        (aBits.high xor bBits.high) and
        0x8000_0000_0000_0000'u64
      ) != 0'u64
    productSignBits =
      if productNegative:
        0x8000_0000_0000_0000'u64
      else:
        0'u64

  if (aInfinity and bZero) or
      (bInfinity and aZero):
    return float128CanonicalQuietNaN()

  if aInfinity or bInfinity:
    if cInfinity:
      let cNegative =
        (cBits.high shr 63) != 0'u64

      if cNegative != productNegative:
        return float128CanonicalQuietNaN()

    return fromBits(
      productSignBits or
        0x7FFF_0000_0000_0000'u64,
      0'u64,
    )

  if cInfinity:
    return c

  if aZero or bZero:
    let productZero =
      fromBits(productSignBits, 0'u64)

    return productZero + c

  if cZero:
    return a * b

  let
    aParts =
      float128DecodeFiniteBits(
        aBits.high,
        aBits.low,
      )
    bParts =
      float128DecodeFiniteBits(
        bBits.high,
        bBits.low,
      )
    cParts =
      float128DecodeFiniteBits(
        cBits.high,
        cBits.low,
      )
    productMagnitude =
      aParts.significand *
      bParts.significand
    productBaseExponent =
      aParts.exponent +
      bParts.exponent -
      224
    cBaseExponent =
      cParts.exponent - 112
    productHighest =
      float128HighestBit256(productMagnitude)
    productTopExponent =
      productBaseExponent + productHighest
    cTopExponent =
      cParts.exponent
    targetTopExponent =
      max(
        productTopExponent,
        cTopExponent,
      )
    commonBaseExponent =
      targetTopExponent - 254
    productAligned =
      float128ScaleInteger(
        productMagnitude,
        commonBaseExponent -
          productBaseExponent,
      )
    cAligned =
      float128ScaleInteger(
        cParts.significand,
        commonBaseExponent -
          cBaseExponent,
      )
    zero = default(UInt256)

  var
    resultNegative: bool
    resultMagnitude: UInt256

  if productNegative == cParts.sign:
    resultNegative = productNegative
    resultMagnitude =
      productAligned + cAligned
  elif productAligned > cAligned:
    resultNegative = productNegative
    resultMagnitude =
      productAligned - cAligned
  elif cAligned > productAligned:
    resultNegative = cParts.sign
    resultMagnitude =
      cAligned - productAligned
  else:
    return fromBits(0'u64, 0'u64)

  if resultMagnitude == zero:
    return fromBits(0'u64, 0'u64)

  float128PackExactInteger(
    resultNegative,
    resultMagnitude,
    commonBaseExponent,
  )
# ----------------------------------------------------------------------
# Exact raw-bit hexadecimal text foundation
# ----------------------------------------------------------------------

func float128HexDigit(value: uint64): char {.inline.} =
  if value < 10'u64:
    char(ord('0') + int(value))
  else:
    char(ord('A') + int(value - 10'u64))

func float128HexNibble(value: char): int {.inline.} =
  case value
  of '0'..'9':
    ord(value) - ord('0')
  of 'A'..'F':
    ord(value) - ord('A') + 10
  of 'a'..'f':
    ord(value) - ord('a') + 10
  else:
    -1

func toHexString*(value: Float128): string =
  ## Returns the exact raw binary128 encoding as 0xHHHH...LLLL.
  let bits = toBits(value)

  result = newString(34)
  result[0] = '0'
  result[1] = 'x'

  for index in 0 ..< 16:
    let shift = (15 - index) * 4

    result[2 + index] =
      float128HexDigit(
        (bits.high shr shift) and 0xF'u64
      )

    result[18 + index] =
      float128HexDigit(
        (bits.low shr shift) and 0xF'u64
      )

proc tryParseHexFloat128*(
    text: string;
    destination: var Float128;
): bool =
  ## Parses the exact raw binary128 form emitted by toHexString.
  destination = fromBits(0'u64, 0'u64)

  if text.len != 34:
    return false

  if text[0] != '0' or
      (text[1] != 'x' and text[1] != 'X'):
    return false

  var
    high = 0'u64
    low = 0'u64

  for index in 0 ..< 16:
    let nibble = float128HexNibble(text[2 + index])

    if nibble < 0:
      return false

    high =
      (high shl 4) or uint64(nibble)

  for index in 0 ..< 16:
    let nibble = float128HexNibble(text[18 + index])

    if nibble < 0:
      return false

    low =
      (low shl 4) or uint64(nibble)

  destination = fromBits(high, low)
  true

# ----------------------------------------------------------------------
# Correctly rounded decimal text parsing
# ----------------------------------------------------------------------

const
  float128DecimalMaximumInputBytes = 10_000
  float128DecimalMaximumExponentDigits = 9
  float128DecimalMaximumAbsoluteExponent = 100_000

type
  Float128DecimalBigUInt = object
    limbs: seq[uint32]

func float128DecimalIsZero(
    value: Float128DecimalBigUInt;
): bool {.inline.} =
  value.limbs.len == 0

proc float128DecimalNormalize(
    value: var Float128DecimalBigUInt;
) =
  while value.limbs.len > 0 and
      value.limbs[^1] == 0'u32:
    value.limbs.setLen(value.limbs.len - 1)

proc float128DecimalAddSmall(
    value: var Float128DecimalBigUInt;
    addend: uint32;
) =
  if addend == 0'u32:
    return

  if value.limbs.len == 0:
    value.limbs = @[addend]
    return

  var
    index = 0
    carry = uint64(addend)

  while carry != 0'u64:
    if index == value.limbs.len:
      value.limbs.add(0'u32)

    let total =
      uint64(value.limbs[index]) + carry

    value.limbs[index] =
      uint32(total and 0xFFFF_FFFF'u64)
    carry = total shr 32
    inc index

proc float128DecimalMultiplySmall(
    value: var Float128DecimalBigUInt;
    factor: uint32;
) =
  if value.float128DecimalIsZero or factor == 1'u32:
    return

  if factor == 0'u32:
    value.limbs.setLen(0)
    return

  var carry = 0'u64

  for index in 0 ..< value.limbs.len:
    let product =
      uint64(value.limbs[index]) *
        uint64(factor) +
      carry

    value.limbs[index] =
      uint32(product and 0xFFFF_FFFF'u64)
    carry = product shr 32

  if carry != 0'u64:
    value.limbs.add(uint32(carry))

proc float128DecimalMultiplyPowerOfFive(
    value: var Float128DecimalBigUInt;
    exponent: int;
) =
  for _ in 0 ..< exponent:
    value.float128DecimalMultiplySmall(5'u32)

func float128DecimalPowerOfFive(
    exponent: int;
): Float128DecimalBigUInt =
  result.limbs = @[1'u32]
  result.float128DecimalMultiplyPowerOfFive(exponent)

func float128DecimalFromDigits(
    digits: string;
    first, pastLast: int;
): Float128DecimalBigUInt =
  for index in first ..< pastLast:
    result.float128DecimalMultiplySmall(10'u32)
    result.float128DecimalAddSmall(
      uint32(ord(digits[index]) - ord('0'))
    )

  result.float128DecimalNormalize()

func float128DecimalCompare(
    lhs, rhs: Float128DecimalBigUInt;
): int =
  if lhs.limbs.len != rhs.limbs.len:
    if lhs.limbs.len < rhs.limbs.len:
      return -1

    return 1

  if lhs.limbs.len == 0:
    return 0

  for index in countdown(lhs.limbs.len - 1, 0):
    if lhs.limbs[index] < rhs.limbs[index]:
      return -1

    if lhs.limbs[index] > rhs.limbs[index]:
      return 1

  0

func float128DecimalLimbBitLength(
    value: uint32;
): int =
  var remaining = value

  while remaining != 0'u32:
    inc result
    remaining = remaining shr 1

func float128DecimalBitLength(
    value: Float128DecimalBigUInt;
): int =
  if value.float128DecimalIsZero:
    return 0

  (value.limbs.len - 1) * 32 +
    float128DecimalLimbBitLength(value.limbs[^1])

func float128DecimalShiftLeft(
    value: Float128DecimalBigUInt;
    distance: int;
): Float128DecimalBigUInt =
  if value.float128DecimalIsZero:
    return

  if distance == 0:
    return value

  let
    limbShift = distance div 32
    bitShift = distance mod 32

  result.limbs = newSeq[uint32](
    value.limbs.len + limbShift + 1
  )

  var carry = 0'u64

  for index in 0 ..< value.limbs.len:
    let combined =
      (uint64(value.limbs[index]) shl bitShift) or
      carry

    result.limbs[index + limbShift] =
      uint32(combined and 0xFFFF_FFFF'u64)
    carry = combined shr 32

  if carry != 0'u64:
    result.limbs[value.limbs.len + limbShift] =
      uint32(carry)

  result.float128DecimalNormalize()

proc float128DecimalShiftLeftOne(
    value: var Float128DecimalBigUInt;
) =
  if value.float128DecimalIsZero:
    return

  var carry = 0'u64

  for index in 0 ..< value.limbs.len:
    let combined =
      (uint64(value.limbs[index]) shl 1) or carry

    value.limbs[index] =
      uint32(combined and 0xFFFF_FFFF'u64)
    carry = combined shr 32

  if carry != 0'u64:
    value.limbs.add(uint32(carry))

proc float128DecimalSubtractAssign(
    value: var Float128DecimalBigUInt;
    subtrahend: Float128DecimalBigUInt;
) =
  doAssert float128DecimalCompare(value, subtrahend) >= 0

  var borrow = 0'u64

  for index in 0 ..< value.limbs.len:
    let
      lhs = uint64(value.limbs[index])
      rhs =
        (
          if index < subtrahend.limbs.len:
            uint64(subtrahend.limbs[index])
          else:
            0'u64
        ) + borrow

    if lhs >= rhs:
      value.limbs[index] = uint32(lhs - rhs)
      borrow = 0'u64
    else:
      value.limbs[index] =
        uint32((1'u64 shl 32) + lhs - rhs)
      borrow = 1'u64

  doAssert borrow == 0'u64
  value.float128DecimalNormalize()

proc float128DecimalSetExtendedBit(
    value: var UInt256;
    position: int;
) =
  value =
    value or
    (float128UInt256One() shl position)

func float128DecimalNormalizedRatio(
    numerator, denominator: Float128DecimalBigUInt;
): tuple[
    exponent: int,
    extended: UInt256,
    remainderNonzero: bool,
] =
  doAssert not numerator.float128DecimalIsZero
  doAssert not denominator.float128DecimalIsZero

  var exponent =
    numerator.float128DecimalBitLength -
    denominator.float128DecimalBitLength

  if exponent >= 0:
    let scaledDenominator =
      denominator.float128DecimalShiftLeft(exponent)

    if float128DecimalCompare(
      numerator,
      scaledDenominator,
    ) < 0:
      dec exponent
  else:
    let scaledNumerator =
      numerator.float128DecimalShiftLeft(-exponent)

    if float128DecimalCompare(
      scaledNumerator,
      denominator,
    ) < 0:
      dec exponent

  var
    normalizedDenominator: Float128DecimalBigUInt
    remainder: Float128DecimalBigUInt

  if exponent >= 0:
    normalizedDenominator =
      denominator.float128DecimalShiftLeft(exponent)
    remainder = numerator
    remainder.float128DecimalSubtractAssign(
      normalizedDenominator
    )
  else:
    remainder =
      numerator.float128DecimalShiftLeft(-exponent)
    normalizedDenominator = denominator
    remainder.float128DecimalSubtractAssign(
      normalizedDenominator
    )

  result.exponent = exponent
  result.extended.float128DecimalSetExtendedBit(115)

  for position in countdown(114, 1):
    remainder.float128DecimalShiftLeftOne()

    if float128DecimalCompare(
      remainder,
      normalizedDenominator,
    ) >= 0:
      remainder.float128DecimalSubtractAssign(
        normalizedDenominator
      )
      result.extended.float128DecimalSetExtendedBit(
        position
      )

  remainder.float128DecimalShiftLeftOne()

  if float128DecimalCompare(
    remainder,
    normalizedDenominator,
  ) >= 0:
    remainder.float128DecimalSubtractAssign(
      normalizedDenominator
    )
    result.extended.float128DecimalSetExtendedBit(0)

  result.remainderNonzero =
    not remainder.float128DecimalIsZero

  if result.remainderNonzero:
    result.extended.float128DecimalSetExtendedBit(0)

func float128DecimalAsciiLower(
    value: char;
): char {.inline.} =
  if value >= 'A' and value <= 'Z':
    char(ord(value) + ord('a') - ord('A'))
  else:
    value

func float128DecimalEqualsIgnoreCase(
    text: string;
    first: int;
    expected: string;
): bool =
  if text.len - first != expected.len:
    return false

  for index in 0 ..< expected.len:
    if float128DecimalAsciiLower(
      text[first + index]
    ) != expected[index]:
      return false

  true

proc tryParseFloat128*(
    text: string;
    destination: var Float128;
): bool =
  ## Parses an ASCII decimal binary128 value using roundTiesToEven.
  ##
  ## Accepted finite forms are digits, digits., digits.fraction,
  ## .fraction, and an optional e/E exponent. Optional leading signs
  ## and the case-insensitive specials inf, infinity, and nan are
  ## accepted. Whitespace and digit separators are rejected.
  destination = fromBits(0'u64, 0'u64)

  if text.len == 0 or
      text.len > float128DecimalMaximumInputBytes:
    return false

  var
    index = 0
    negative = false

  if text[index] == '+' or text[index] == '-':
    negative = text[index] == '-'
    inc index

    if index == text.len:
      return false

  let signBits =
    if negative:
      0x8000_0000_0000_0000'u64
    else:
      0'u64

  if float128DecimalEqualsIgnoreCase(
    text,
    index,
    "inf",
  ) or float128DecimalEqualsIgnoreCase(
    text,
    index,
    "infinity",
  ):
    destination = fromBits(
      signBits or 0x7FFF_0000_0000_0000'u64,
      0'u64,
    )
    return true

  if float128DecimalEqualsIgnoreCase(
    text,
    index,
    "nan",
  ):
    destination = fromBits(
      signBits or 0x7FFF_8000_0000_0000'u64,
      0'u64,
    )
    return true

  var
    digits = newStringOfCap(text.len)
    fractionalDigitCount = 0
    sawDigit = false
    sawPoint = false

  while index < text.len and
      text[index] != 'e' and
      text[index] != 'E':
    let character = text[index]

    if character >= '0' and character <= '9':
      sawDigit = true
      digits.add(character)

      if sawPoint:
        inc fractionalDigitCount
    elif character == '.' and not sawPoint:
      sawPoint = true
    else:
      return false

    inc index

  if not sawDigit:
    return false

  var explicitExponent = 0

  if index < text.len:
    inc index

    if index == text.len:
      return false

    var exponentNegative = false

    if text[index] == '+' or text[index] == '-':
      exponentNegative = text[index] == '-'
      inc index

      if index == text.len:
        return false

    var exponentDigitCount = 0

    while index < text.len:
      let character = text[index]

      if character < '0' or character > '9':
        return false

      inc exponentDigitCount

      if exponentDigitCount >
          float128DecimalMaximumExponentDigits:
        return false

      explicitExponent =
        explicitExponent * 10 +
        ord(character) -
        ord('0')

      if explicitExponent >
          float128DecimalMaximumAbsoluteExponent:
        return false

      inc index

    if exponentDigitCount == 0:
      return false

    if exponentNegative:
      explicitExponent = -explicitExponent

  var firstNonzero = -1

  for digitIndex in 0 ..< digits.len:
    if digits[digitIndex] != '0':
      firstNonzero = digitIndex
      break

  if firstNonzero < 0:
    destination = fromBits(signBits, 0'u64)
    return true

  var trailingZeroCount = 0
  var trailingIndex = digits.len - 1

  while trailingIndex >= firstNonzero and
      digits[trailingIndex] == '0':
    inc trailingZeroCount
    dec trailingIndex

  let
    significantPastLast =
      digits.len - trailingZeroCount
    significantDigitCount =
      significantPastLast - firstNonzero
    decimalExponent =
      explicitExponent -
      fractionalDigitCount +
      trailingZeroCount
    decimalOrder =
      significantDigitCount -
      1 +
      decimalExponent

  if decimalOrder > 4932:
    destination = fromBits(
      signBits or 0x7FFF_0000_0000_0000'u64,
      0'u64,
    )
    return true

  if decimalOrder < -4966:
    destination = fromBits(signBits, 0'u64)
    return true

  var
    numerator =
      float128DecimalFromDigits(
        digits,
        firstNonzero,
        significantPastLast,
      )
    denominator: Float128DecimalBigUInt
    binaryExponent = decimalExponent

  if decimalExponent >= 0:
    numerator.float128DecimalMultiplyPowerOfFive(
      decimalExponent
    )
    denominator.limbs = @[1'u32]
  else:
    denominator =
      float128DecimalPowerOfFive(-decimalExponent)

  let extracted =
    float128DecimalNormalizedRatio(
      numerator,
      denominator,
    )

  destination =
    float128PackRounded(
      negative,
      extracted.exponent + binaryExponent,
      extracted.extended,
    )

  true

proc parseFloat128*(text: string): Float128 =
  ## Parses an ASCII decimal binary128 value or raises ValueError.
  if not tryParseFloat128(text, result):
    raise newException(
      ValueError,
      "invalid Float128 decimal text",
    )
# ----------------------------------------------------------------------
# 36-significant-digit scientific decimal formatting
# ----------------------------------------------------------------------

func float128DecimalClone(
    value: Float128DecimalBigUInt;
): Float128DecimalBigUInt =
  result.limbs = newSeq[uint32](value.limbs.len)

  for index in 0 ..< value.limbs.len:
    result.limbs[index] = value.limbs[index]

func float128DecimalFromUInt256(
    value: UInt256;
): Float128DecimalBigUInt =
  for index in 0 ..< 8:
    result.limbs.add(
      uint32(
        toUInt(value shr (index * 32)) and
        0xFFFF_FFFF'u64
      )
    )

  result.float128DecimalNormalize()

func float128DecimalMultiplyBig(
    lhs, rhs: Float128DecimalBigUInt;
): Float128DecimalBigUInt =
  if lhs.float128DecimalIsZero or
      rhs.float128DecimalIsZero:
    return

  result.limbs = newSeq[uint32](
    lhs.limbs.len + rhs.limbs.len + 1
  )

  for lhsIndex in 0 ..< lhs.limbs.len:
    var carry = 0'u64

    for rhsIndex in 0 ..< rhs.limbs.len:
      let
        position = lhsIndex + rhsIndex
        total =
          uint64(result.limbs[position]) +
          uint64(lhs.limbs[lhsIndex]) *
            uint64(rhs.limbs[rhsIndex]) +
          carry

      result.limbs[position] =
        uint32(total and 0xFFFF_FFFF'u64)
      carry = total shr 32

    var position = lhsIndex + rhs.limbs.len

    while carry != 0'u64:
      let total =
        uint64(result.limbs[position]) + carry

      result.limbs[position] =
        uint32(total and 0xFFFF_FFFF'u64)
      carry = total shr 32
      inc position

  result.float128DecimalNormalize()

func float128DecimalPowerOfTenFast(
    exponent: int;
): Float128DecimalBigUInt =
  doAssert exponent >= 0

  result.limbs = @[1'u32]

  if exponent == 0:
    return

  var
    remaining = exponent
    base: Float128DecimalBigUInt

  base.limbs = @[10'u32]

  while remaining != 0:
    if (remaining and 1) != 0:
      result =
        float128DecimalMultiplyBig(result, base)

    remaining = remaining shr 1

    if remaining != 0:
      base =
        float128DecimalMultiplyBig(base, base)

func float128DecimalCompareRatioPowerOfTen(
    numerator, denominator: Float128DecimalBigUInt;
    decimalExponent: int;
): int =
  let power =
    float128DecimalPowerOfTenFast(
      abs(decimalExponent)
    )

  if decimalExponent >= 0:
    let scaledDenominator =
      float128DecimalMultiplyBig(
        denominator,
        power,
      )

    return float128DecimalCompare(
      numerator,
      scaledDenominator,
    )

  let scaledNumerator =
    float128DecimalMultiplyBig(
      numerator,
      power,
    )

  float128DecimalCompare(
    scaledNumerator,
    denominator,
  )

func float128DecimalFloorLog10Estimate(
    binaryExponent: int;
): int =
  let product = binaryExponent * 78_913

  if product >= 0:
    product div 262_144
  else:
    -((-product + 262_143) div 262_144)

proc float128DecimalIncrementDigits(
    digits: var string;
    decimalExponent: var int;
) =
  var index = digits.len - 1

  while index >= 0 and digits[index] == '9':
    digits[index] = '0'
    dec index

  if index >= 0:
    digits[index] =
      char(ord(digits[index]) + 1)
  else:
    digits[0] = '1'

    for position in 1 ..< digits.len:
      digits[position] = '0'

    inc decimalExponent

func toScientificString*(
    value: Float128;
): string =
  ## Returns 36 significant decimal digits in scientific notation.
  ##
  ## Every finite output round-trips through tryParseFloat128.
  let bits = toBits(value)
  let negative = (bits.high shr 63) != 0'u64

  if float128IsNaNBits(bits.high, bits.low):
    if negative:
      return "-nan"

    return "nan"

  if float128IsInfinityBits(bits.high, bits.low):
    if negative:
      return "-inf"

    return "inf"

  if float128IsZeroBits(bits.high, bits.low):
    if negative:
      return "-0"

    return "0"

  let
    parts =
      float128DecodeFiniteBits(
        bits.high,
        bits.low,
      )
    binaryExponent = parts.exponent - 112

  var
    numerator =
      float128DecimalFromUInt256(
        parts.significand
      )
    denominator: Float128DecimalBigUInt

  denominator.limbs = @[1'u32]

  if binaryExponent >= 0:
    numerator =
      numerator.float128DecimalShiftLeft(
        binaryExponent
      )
  else:
    denominator =
      denominator.float128DecimalShiftLeft(
        -binaryExponent
      )

  var decimalExponent =
    float128DecimalFloorLog10Estimate(
      parts.exponent
    )

  while float128DecimalCompareRatioPowerOfTen(
    numerator,
    denominator,
    decimalExponent,
  ) < 0:
    dec decimalExponent

  while float128DecimalCompareRatioPowerOfTen(
    numerator,
    denominator,
    decimalExponent + 1,
  ) >= 0:
    inc decimalExponent

  var
    scaledNumerator: Float128DecimalBigUInt
    scaledDenominator: Float128DecimalBigUInt

  if decimalExponent >= 0:
    scaledNumerator =
      numerator.float128DecimalClone()

    scaledDenominator =
      float128DecimalMultiplyBig(
        denominator,
        float128DecimalPowerOfTenFast(
          decimalExponent
        ),
      )
  else:
    scaledNumerator =
      float128DecimalMultiplyBig(
        numerator,
        float128DecimalPowerOfTenFast(
          -decimalExponent
        ),
      )

    scaledDenominator =
      denominator.float128DecimalClone()

  var
    remainder =
      scaledNumerator.float128DecimalClone()
    digits = newString(36)

  for position in 0 ..< 36:
    var digit = 0

    while float128DecimalCompare(
      remainder,
      scaledDenominator,
    ) >= 0:
      remainder.float128DecimalSubtractAssign(
        scaledDenominator
      )
      inc digit

    doAssert digit >= 0 and digit <= 9
    digits[position] = char(ord('0') + digit)

    if position != 35:
      remainder.float128DecimalMultiplySmall(10'u32)

  var doubledRemainder =
    remainder.float128DecimalClone()

  doubledRemainder.float128DecimalShiftLeftOne()

  let roundingComparison =
    float128DecimalCompare(
      doubledRemainder,
      scaledDenominator,
    )

  if roundingComparison > 0 or
      (
        roundingComparison == 0 and
        ((ord(digits[^1]) - ord('0')) and 1) != 0
      ):
    digits.float128DecimalIncrementDigits(
      decimalExponent
    )

  result = newStringOfCap(44)

  if negative:
    result.add('-')

  result.add(digits[0])
  result.add('.')
  result.add(digits[1 .. ^1])
  result.add('e')

  if decimalExponent >= 0:
    result.add('+')

  result.add($decimalExponent)

# IEEE-style remainder operations for Float128
const
  float128RemainderSignMask =
    0x8000_0000_0000_0000'u64
  float128RemainderExponentMask =
    0x7fff'u16
  float128RemainderFractionHighMask =
    0x0000_ffff_ffff_ffff'u64
  float128RemainderQuietNaNMask =
    0x0000_8000_0000_0000'u64
  float128RemainderExponentBias =
    16383
  float128RemainderMinimumNormalExponent =
    -16382
  float128RemainderMinimumSubnormalExponent =
    -16494

type
  Float128RemainderDecoded = object
    significand: UInt256
    exponent: int

func float128RemainderWordAt(
    value: UInt256;
    index: int;
): uint64 {.inline.} =
  case index
  of 0:
    word64(value, 0)
  of 1:
    word64(value, 1)
  of 2:
    word64(value, 2)
  of 3:
    word64(value, 3)
  else:
    0'u64

func float128RemainderBitLength64(
    value: uint64;
): int {.inline.} =
  for bitIndex in countdown(63, 0):
    if (
      (
        value shr bitIndex
      ) and 1'u64
    ) != 0'u64:
      return bitIndex + 1

  0

func float128RemainderTrailingZeroCount64(
    value: uint64;
): int {.inline.} =
  for bitIndex in 0 .. 63:
    if (
      (
        value shr bitIndex
      ) and 1'u64
    ) != 0'u64:
      return bitIndex

  64

func float128RemainderBitLength(
    value: UInt256;
): int {.inline.} =
  for wordIndex in countdown(3, 0):
    let currentWord =
      float128RemainderWordAt(
        value,
        wordIndex,
      )

    if currentWord != 0'u64:
      return (
        wordIndex * 64 +
        float128RemainderBitLength64(
          currentWord,
        )
      )

  0

func float128RemainderTrailingZeroCount(
    value: UInt256;
): int {.inline.} =
  for wordIndex in 0 .. 3:
    let currentWord =
      float128RemainderWordAt(
        value,
        wordIndex,
      )

    if currentWord != 0'u64:
      return (
        wordIndex * 64 +
        float128RemainderTrailingZeroCount64(
          currentWord,
        )
      )

  0

func float128RemainderCompareScaled(
    aMagnitude: UInt256;
    aExponent: int;
    bMagnitude: UInt256;
    bExponent: int;
): int =
  let
    aBits =
      float128RemainderBitLength(
        aMagnitude,
      )
    bBits =
      float128RemainderBitLength(
        bMagnitude,
      )

  if aBits == 0:
    if bBits == 0:
      return 0

    return -1

  if bBits == 0:
    return 1

  let
    aTop =
      aExponent + aBits
    bTop =
      bExponent + bBits

  if aTop < bTop:
    return -1

  if aTop > bTop:
    return 1

  if aExponent >= bExponent:
    cmp(
      `shl`(
        aMagnitude,
        aExponent - bExponent
      ),
      bMagnitude,
    )
  else:
    cmp(
      aMagnitude,
      `shl`(
        bMagnitude,
        bExponent - aExponent
      ),
    )

func float128RemainderSubtractScaled(
    aMagnitude: UInt256;
    aExponent: int;
    bMagnitude: UInt256;
    bExponent: int;
): tuple[
    magnitude: UInt256,
    exponent: int,
] =
  let commonExponent =
    if aExponent < bExponent:
      aExponent
    else:
      bExponent

  let
    aAligned =
      `shl`(
        aMagnitude,
        aExponent - commonExponent
      )
    bAligned =
      `shl`(
        bMagnitude,
        bExponent - commonExponent
      )

  doAssert aAligned >= bAligned

  (
    magnitude:
      aAligned - bAligned,
    exponent:
      commonExponent,
  )

func float128RemainderReduceMod(
    value: UInt256;
    modulus: UInt256;
): UInt256 =
  doAssert not isZero(modulus)

  if value < modulus:
    return value

  var
    remainder =
      value
    shift =
      float128RemainderBitLength(
        value,
      ) -
      float128RemainderBitLength(
        modulus,
      )
    shiftedModulus =
      modulus shl shift

  while true:
    if shiftedModulus <= remainder:
      remainder =
        remainder - shiftedModulus

    if shift == 0:
      break

    shiftedModulus =
      shiftedModulus shr 1

    dec shift

  remainder

func float128RemainderPowerOfTwoMod(
    value: UInt256;
    shift: int;
    modulus: UInt256;
): UInt256 =
  var
    resultValue =
      float128RemainderReduceMod(
        value,
        modulus,
      )
    base =
      float128RemainderReduceMod(
        toUInt256(2'u64),
        modulus,
      )
    exponent =
      shift

  while exponent > 0:
    if (
      exponent and 1
    ) != 0:
      resultValue =
        float128RemainderReduceMod(
          resultValue * base,
          modulus,
        )

    exponent =
      exponent shr 1

    if exponent > 0:
      base =
        float128RemainderReduceMod(
          base * base,
          modulus,
        )

  resultValue

func float128RemainderDecodeMagnitude(
    value: Float128;
): Float128RemainderDecoded {.inline.} =
  let
    bits =
      toBits(value)
    exponentField =
      int(
        biasedExponent(value)
      )
    fraction =
      fromUInt64Words(
        0'u64,
        0'u64,
        bits.high and
          float128RemainderFractionHighMask,
        bits.low,
      )

  if exponentField == 0:
    Float128RemainderDecoded(
      significand:
        fraction,
      exponent:
        float128RemainderMinimumSubnormalExponent,
    )
  else:
    Float128RemainderDecoded(
      significand:
        fraction +
        fromUInt64Words(
          0'u64,
          0'u64,
          0x0001_0000_0000_0000'u64,
          0'u64,
        ),
      exponent:
        exponentField -
        float128RemainderExponentBias -
        112,
    )

func float128RemainderEncodeExactMagnitude(
    originalMagnitude: UInt256;
    originalExponent: int;
    negative: bool;
): Float128 =
  if isZero(originalMagnitude):
    return fromBits(
      (
        if negative:
          float128RemainderSignMask
        else:
          0'u64
      ),
      0'u64,
    )

  let trailingZeroCount =
    float128RemainderTrailingZeroCount(
      originalMagnitude,
    )

  let
    magnitude =
      originalMagnitude shr
        trailingZeroCount
    exponent =
      originalExponent +
      trailingZeroCount
    bitLength =
      float128RemainderBitLength(
        magnitude,
      )
    topExponent =
      exponent +
      bitLength -
      1

  doAssert bitLength <= 113

  let signBits =
    if negative:
      float128RemainderSignMask
    else:
      0'u64

  if topExponent >=
      float128RemainderMinimumNormalExponent:
    let
      significand =
        `shl`(
          magnitude,
          113 - bitLength
        )
      exponentField =
        topExponent +
        float128RemainderExponentBias
      fractionHigh =
        word64(
          significand,
          1,
        ) and
        float128RemainderFractionHighMask
      fractionLow =
        word64(
          significand,
          0,
        )

    doAssert exponentField > 0
    doAssert exponentField < 0x7fff

    return fromBits(
      signBits or
      (
        `shl`(
          uint64(exponentField),
          48,
        )
      ) or
      fractionHigh,
      fractionLow,
    )

  let subnormalShift =
    exponent -
    float128RemainderMinimumSubnormalExponent

  doAssert subnormalShift >= 0

  let fraction =
    magnitude shl subnormalShift

  doAssert word64(fraction, 3) == 0'u64
  doAssert word64(fraction, 2) == 0'u64
  doAssert (
    `shr`(
      word64(fraction, 1),
      48,
    )
  ) == 0'u64

  fromBits(
    signBits or
    (
      word64(
        fraction,
        1,
      ) and
      float128RemainderFractionHighMask
    ),
    word64(
      fraction,
      0,
    ),
  )

func float128RemainderQuietNaN(
    value: Float128;
): Float128 {.inline.} =
  let bits =
    toBits(value)

  fromBits(
    bits.high or
      float128RemainderQuietNaNMask,
    bits.low,
  )

func float128RemainderPreferredNaN(
    x,
    y: Float128;
): Float128 {.inline.} =
  if isNaN(x):
    float128RemainderQuietNaN(x)
  else:
    float128RemainderQuietNaN(y)

func float128RemainderOperation(
    x,
    y: Float128;
    remainderMode: bool;
): Float128 =
  if isNaN(x) or
      isNaN(y):
    return float128RemainderPreferredNaN(
        x,
        y,
      )

  if isInfinite(x) or
      isZero(y):
    return canonicalQuietNaNFloat128

  if isInfinite(y):
    return x

  if isZero(x):
    return x

  let
    xDecoded =
      float128RemainderDecodeMagnitude(
        x,
      )
    yDecoded =
      float128RemainderDecodeMagnitude(
        y,
      )
    xNegative =
      signBit(x)
    magnitudeComparison =
      float128RemainderCompareScaled(
        xDecoded.significand,
        xDecoded.exponent,
        yDecoded.significand,
        yDecoded.exponent,
      )

  if magnitudeComparison < 0:
    if not remainderMode:
      return x

    let halfComparison =
      float128RemainderCompareScaled(
        xDecoded.significand shl 1,
        xDecoded.exponent,
        yDecoded.significand,
        yDecoded.exponent,
      )

    if halfComparison < 0:
      return x

    if halfComparison == 0:
      return x

    let difference =
      float128RemainderSubtractScaled(
        yDecoded.significand,
        yDecoded.exponent,
        xDecoded.significand,
        xDecoded.exponent,
      )

    return float128RemainderEncodeExactMagnitude(
        difference.magnitude,
        difference.exponent,
        not xNegative,
      )

  doAssert xDecoded.exponent >=
    yDecoded.exponent

  let
    alignmentShift =
      xDecoded.exponent -
      yDecoded.exponent
    doubledDivisor =
      yDecoded.significand shl 1
    reduced =
      float128RemainderPowerOfTwoMod(
        xDecoded.significand,
        alignmentShift,
        doubledDivisor,
      )
    quotientIsOdd =
      reduced >=
        yDecoded.significand
    floorRemainder =
      if quotientIsOdd:
        reduced -
        yDecoded.significand
      else:
        reduced

  if not remainderMode:
    return float128RemainderEncodeExactMagnitude(
        floorRemainder,
        yDecoded.exponent,
        xNegative,
      )

  let doubledRemainder =
    floorRemainder shl 1

  if doubledRemainder <
      yDecoded.significand:
    return float128RemainderEncodeExactMagnitude(
        floorRemainder,
        yDecoded.exponent,
        xNegative,
      )

  if doubledRemainder >
      yDecoded.significand:
    return float128RemainderEncodeExactMagnitude(
        yDecoded.significand -
        floorRemainder,
        yDecoded.exponent,
        not xNegative,
      )

  if not quotientIsOdd:
    float128RemainderEncodeExactMagnitude(
        floorRemainder,
        yDecoded.exponent,
        xNegative,
      )
  else:
    float128RemainderEncodeExactMagnitude(
        yDecoded.significand -
        floorRemainder,
        yDecoded.exponent,
        not xNegative,
      )

func remainder*(x, y: Float128): Float128 =
  float128RemainderOperation(x, y, true)

func fmod*(x, y: Float128): Float128 =
  float128RemainderOperation(x, y, false)

# ----------------------------------------------------------------------
# Shortest round-trip decimal formatting for Float128
# ----------------------------------------------------------------------

type
  Float128ShortestRatio = object
    numerator: Float128DecimalBigUInt
    denominator: Float128DecimalBigUInt

  Float128ShortestPrepared = object
    numerator: Float128DecimalBigUInt
    denominator: Float128DecimalBigUInt
    lowerNumerator: Float128DecimalBigUInt
    upperNumerator: Float128DecimalBigUInt
    boundaryDenominator: Float128DecimalBigUInt
    decimalExponent: int
    midpointInclusive: bool

  Float128ShortestCandidate = object
    digits: string
    decimalPower: int
    significantDigits: int
    coefficientOdd: bool

proc float128ShortestOne(): Float128DecimalBigUInt =
  result.limbs = @[1'u32]

proc float128ShortestClone(
    value: Float128DecimalBigUInt
): Float128DecimalBigUInt =
  result =
    float128DecimalClone(value)



proc float128ShortestFromUInt256(
    value: UInt256
): Float128DecimalBigUInt =
  result =
    float128DecimalFromUInt256(value)



proc float128ShortestShiftLeft(
    value: Float128DecimalBigUInt;
    distance: int
): Float128DecimalBigUInt =
  result =
    value.float128DecimalShiftLeft(
      distance,
    )



proc float128ShortestMultiplyBig(
    lhs,
    rhs: Float128DecimalBigUInt
): Float128DecimalBigUInt =
  result =
    float128DecimalMultiplyBig(
      lhs,
      rhs,
    )



proc float128ShortestPowerOfTen(
    exponent: int
): Float128DecimalBigUInt =
  result =
    float128DecimalPowerOfTenFast(
      exponent,
    )



proc float128ShortestAddBig(
    lhs,
    rhs: Float128DecimalBigUInt
): Float128DecimalBigUInt =
  result =
    lhs.float128ShortestClone(
    )

  var
    index = 0
    carry = 0'u64

  while index < rhs.limbs.len or
      carry != 0'u64:
    if index == result.limbs.len:
      result.limbs.add(0'u32)

    let
      rhsWord =
        if index < rhs.limbs.len:
          uint64(rhs.limbs[index])
        else:
          0'u64

      total =
        uint64(result.limbs[index]) +
        rhsWord +
        carry

    result.limbs[index] =
      uint32(
        total and
        0xFFFF_FFFF'u64
      )

    carry = total shr 32
    inc index

  result.float128DecimalNormalize()


proc float128ShortestDyadicRatio(
    significand: UInt256;
    binaryExponent: int
): Float128ShortestRatio =
  result.numerator =
    significand.float128ShortestFromUInt256(
    )

  result.denominator =
    float128ShortestOne()

  if binaryExponent >= 0:
    result.numerator =
      result.numerator.float128ShortestShiftLeft(
        binaryExponent,
      )
  else:
    result.denominator =
      result.denominator.float128ShortestShiftLeft(
        -binaryExponent,
      )

proc float128ShortestAlignedInteger(
    significand: UInt256;
    binaryExponent,
    commonBinaryExponent: int
): Float128DecimalBigUInt =
  result =
    significand.float128ShortestFromUInt256(
    )

  let shift =
    binaryExponent -
    commonBinaryExponent

  doAssert shift >= 0

  if shift != 0:
    result =
      result.float128ShortestShiftLeft(
        shift,
      )

proc float128ShortestPrepare(
    value: Float128
): Float128ShortestPrepared =
  let
    rawBits = toBits(value)

    magnitude =
      fromBits(
        rawBits.high and
          0x7FFF_FFFF_FFFF_FFFF'u64,
        rawBits.low,
      )

    magnitudeBits =
      toBits(magnitude)

    targetParts =
      float128DecodeFiniteBits(
        magnitudeBits.high,
        magnitudeBits.low,
      )

    targetBinaryExponent =
      targetParts.exponent - 112

  var targetRatio =
    float128ShortestDyadicRatio(
      targetParts.significand,
      targetBinaryExponent,
    )

  var decimalExponent =
    float128DecimalFloorLog10Estimate(
      targetParts.exponent,
    )

  while float128DecimalCompareRatioPowerOfTen(
    targetRatio.numerator,
    targetRatio.denominator,
    decimalExponent,
  ) < 0:
    dec decimalExponent

  while float128DecimalCompareRatioPowerOfTen(
    targetRatio.numerator,
    targetRatio.denominator,
    decimalExponent + 1,
  ) >= 0:
    inc decimalExponent

  let decimalScale =
    float128ShortestPowerOfTen(
      abs(decimalExponent),
    )

  if decimalExponent >= 0:
    result.numerator =
      targetRatio.numerator

    result.denominator =
      float128ShortestMultiplyBig(
        targetRatio.denominator,
        decimalScale,
      )
  else:
    result.numerator =
      float128ShortestMultiplyBig(
        targetRatio.numerator,
        decimalScale,
      )

    result.denominator =
      targetRatio.denominator

  let previousValue =
    nextDown(magnitude)

  var
    previousSignificand =
      default(UInt256)

    previousBinaryExponent =
      targetBinaryExponent

  if not isZero(previousValue):
    let
      previousBits =
        toBits(previousValue)

      previousParts =
        float128DecodeFiniteBits(
          previousBits.high,
          previousBits.low,
        )

    previousSignificand =
      previousParts.significand

    previousBinaryExponent =
      previousParts.exponent - 112

  var
    nextSignificand: UInt256
    nextBinaryExponent: int

  let maximumFinite =
    magnitudeBits.high ==
      0x7FFE_FFFF_FFFF_FFFF'u64 and
    magnitudeBits.low ==
      high(uint64)

  if maximumFinite:
    nextSignificand =
      float128UInt256One() shl 112

    nextBinaryExponent =
      16384 - 112
  else:
    let
      nextValue =
        nextUp(magnitude)

      nextBits =
        toBits(nextValue)

      nextParts =
        float128DecodeFiniteBits(
          nextBits.high,
          nextBits.low,
        )

    nextSignificand =
      nextParts.significand

    nextBinaryExponent =
      nextParts.exponent - 112

  var commonBinaryExponent =
    min(
      targetBinaryExponent,
      nextBinaryExponent,
    )

  if previousSignificand !=
      default(UInt256):
    commonBinaryExponent =
      min(
        commonBinaryExponent,
        previousBinaryExponent,
      )

  let
    previousAligned =
      float128ShortestAlignedInteger(
        previousSignificand,
        previousBinaryExponent,
        commonBinaryExponent,
      )

    targetAligned =
      float128ShortestAlignedInteger(
        targetParts.significand,
        targetBinaryExponent,
        commonBinaryExponent,
      )

    nextAligned =
      float128ShortestAlignedInteger(
        nextSignificand,
        nextBinaryExponent,
        commonBinaryExponent,
      )

  var
    lowerNumerator =
      float128ShortestAddBig(
        previousAligned,
        targetAligned,
      )

    upperNumerator =
      float128ShortestAddBig(
        targetAligned,
        nextAligned,
      )

    boundaryDenominator =
      float128ShortestOne()

  let boundaryBinaryExponent =
    commonBinaryExponent - 1

  if boundaryBinaryExponent >= 0:
    lowerNumerator =
      lowerNumerator.float128ShortestShiftLeft(
        boundaryBinaryExponent,
      )

    upperNumerator =
      upperNumerator.float128ShortestShiftLeft(
        boundaryBinaryExponent,
      )
  else:
    boundaryDenominator =
      boundaryDenominator.float128ShortestShiftLeft(
        -boundaryBinaryExponent,
      )

  if decimalExponent >= 0:
    boundaryDenominator =
      float128ShortestMultiplyBig(
        boundaryDenominator,
        decimalScale,
      )
  else:
    lowerNumerator =
      float128ShortestMultiplyBig(
        lowerNumerator,
        decimalScale,
      )

    upperNumerator =
      float128ShortestMultiplyBig(
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
      magnitudeBits.low and
      1'u64
    ) == 0'u64






proc float128ShortestNormalizedCandidate(
    rawDigits: string;
    candidateExponent: int
): Float128ShortestCandidate =
  result.digits = rawDigits

  result.decimalPower =
    candidateExponent -
    rawDigits.len +
    1

  while result.digits.len > 1 and
      result.digits[^1] == '0':
    result.digits.setLen(
      result.digits.len - 1,
    )

    inc result.decimalPower

  result.significantDigits =
    result.digits.len

  result.coefficientOdd =
    (
      (
        ord(result.digits[^1]) -
        ord('0')
      ) and 1
    ) != 0

proc float128ShortestRender(
    candidate: Float128ShortestCandidate
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
    scientificExponent < digits.len
  ):
    let pointPosition =
      digits.len +
      candidate.decimalPower

    if pointPosition <= 0:
      result = "0."

      for _ in 0 ..< -pointPosition:
        result.add('0')

      result.add(digits)
      return

    if pointPosition >= digits.len:
      result = digits

      for _ in 0 ..< (
        pointPosition -
        digits.len
      ):
        result.add('0')

      return

    result.add(
      digits[0 ..< pointPosition]
    )

    result.add('.')

    result.add(
      digits[
        pointPosition ..
        digits.high
      ]
    )

    return

  result.add(digits[0])

  if digits.len > 1:
    result.add('.')
    result.add(
      digits[1 .. digits.high]
    )

  result.add('e')
  result.add($scientificExponent)

func float128ShortestFormat(
    value: Float128
): string =
  let bits =
    toBits(value)

  let negative =
    (
      bits.high shr 63
    ) != 0'u64

  if float128IsNaNBits(
      bits.high,
      bits.low,
  ):
    result =
      if negative:
        "-nan"
      else:
        "nan"

    return

  if float128IsInfinityBits(
      bits.high,
      bits.low,
  ):
    result =
      if negative:
        "-inf"
      else:
        "inf"

    return

  if float128IsZeroBits(
      bits.high,
      bits.low,
  ):
    result =
      if negative:
        "-0"
      else:
        "0"

    return

  let prepared =
    float128ShortestPrepare(
      value,
    )

  var
    remainder =
      prepared.numerator.float128ShortestClone(
      )

    floorCoefficient:
      Float128DecimalBigUInt

    decimalGridPower =
      float128ShortestOne()

    digits = ""

  for digitStep in 1 .. 36:
    var digit = 0

    while float128DecimalCompare(
      remainder,
      prepared.denominator,
    ) >= 0:
      remainder.float128DecimalSubtractAssign(
        prepared.denominator,
      )

      inc digit

    doAssert digit >= 0 and digit <= 9

    floorCoefficient.float128DecimalMultiplySmall(
      10'u32,
    )

    floorCoefficient.float128DecimalAddSmall(
      uint32(digit),
    )


    digits.add(
      char(
        ord('0') +
        digit
      )
    )

    let
      lowerRight =
        float128ShortestMultiplyBig(
          prepared.lowerNumerator,
          decimalGridPower,
        )

      upperRight =
        float128ShortestMultiplyBig(
          prepared.upperNumerator,
          decimalGridPower,
        )

      floorLeft =
        float128ShortestMultiplyBig(
          floorCoefficient,
          prepared.boundaryDenominator,
        )

    var ceilCoefficient =
      floorCoefficient.float128ShortestClone(
      )

    ceilCoefficient.float128DecimalAddSmall(
      1'u32,
    )


    let ceilLeft =
      float128ShortestMultiplyBig(
        ceilCoefficient,
        prepared.boundaryDenominator,
      )

    let
      floorLowerComparison =
        float128DecimalCompare(
          floorLeft,
          lowerRight,
        )

      floorUpperComparison =
        float128DecimalCompare(
          floorLeft,
          upperRight,
        )

      ceilLowerComparison =
        float128DecimalCompare(
          ceilLeft,
          lowerRight,
        )

      ceilUpperComparison =
        float128DecimalCompare(
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
        Float128ShortestCandidate

      ceilCandidate:
        Float128ShortestCandidate

    if floorValid:
      floorCandidate =
        float128ShortestNormalizedCandidate(
          digits,
          prepared.decimalExponent,
        )

    if ceilValid:
      var
        ceilDigits = digits
        ceilExponent =
          prepared.decimalExponent

      ceilDigits.float128DecimalIncrementDigits(
        ceilExponent,
      )

      ceilCandidate =
        float128ShortestNormalizedCandidate(
          ceilDigits,
          ceilExponent,
        )


    if floorValid or ceilValid:
      var selected:
        Float128ShortestCandidate

      if floorValid and not ceilValid:
        selected = floorCandidate

      elif ceilValid and not floorValid:
        selected = ceilCandidate

      elif floorCandidate.significantDigits <
          ceilCandidate.significantDigits:
        selected = floorCandidate

      elif ceilCandidate.significantDigits <
          floorCandidate.significantDigits:
        selected = ceilCandidate

      else:
        var doubledRemainder =
          remainder.float128ShortestClone(
          )

        doubledRemainder.float128DecimalShiftLeftOne()


        let distanceComparison =
          float128DecimalCompare(
            doubledRemainder,
            prepared.denominator,
          )

        if distanceComparison < 0:
          selected = floorCandidate

        elif distanceComparison > 0:
          selected = ceilCandidate

        elif floorCandidate.coefficientOdd !=
            ceilCandidate.coefficientOdd:
          if floorCandidate.coefficientOdd:
            selected = ceilCandidate
          else:
            selected = floorCandidate

        else:
          selected = floorCandidate


      result =
        float128ShortestRender(
          selected,
        )

      if negative:
        result =
          "-" &
          result

      return

    remainder.float128DecimalMultiplySmall(
      10'u32,
    )


    decimalGridPower.float128DecimalMultiplySmall(
      10'u32,
    )


  raise newException(
    AssertionDefect,
    "Float128 shortest formatting exceeded 36 digits",
  )

func toShortestString*(value: Float128): string =
  float128ShortestFormat(value)
