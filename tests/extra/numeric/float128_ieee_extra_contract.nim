import atcoder/extra/numeric/float128

type
  Bits =
    tuple[
      high,
      low: uint64
    ]

  CopyCase =
    tuple[
      magnitude,
      signSource: Bits
    ]

const
  signMask =
    0x8000_0000_0000_0000'u64

  exponentMaskHigh =
    0x7FFF_0000_0000_0000'u64

  fractionMaskHigh =
    0x0000_FFFF_FFFF_FFFF'u64

  positiveZeroBits: Bits =
    (
      high: 0x0000_0000_0000_0000'u64,
      low: 0x0000_0000_0000_0000'u64,
    )

  negativeZeroBits: Bits =
    (
      high: 0x8000_0000_0000_0000'u64,
      low: 0x0000_0000_0000_0000'u64,
    )

  positiveInfinityBits: Bits =
    (
      high: 0x7FFF_0000_0000_0000'u64,
      low: 0x0000_0000_0000_0000'u64,
    )

  negativeInfinityBits: Bits =
    (
      high: 0xFFFF_0000_0000_0000'u64,
      low: 0x0000_0000_0000_0000'u64,
    )

  positiveMinSubnormalBits: Bits =
    (
      high: 0x0000_0000_0000_0000'u64,
      low: 0x0000_0000_0000_0001'u64,
    )

  negativeMinSubnormalBits: Bits =
    (
      high: 0x8000_0000_0000_0000'u64,
      low: 0x0000_0000_0000_0001'u64,
    )

func asFloat(
    value: Bits;
): Float128 {.inline.} =
  fromBits(
    value.high,
    value.low,
  )

func bitsOf(
    value: Float128;
): Bits {.inline.} =
  toBits(value)

func same(
    a,
    b: Bits;
): bool {.inline.} =
  a.high == b.high and
    a.low == b.low

func isNaNBits(
    value: Bits;
): bool {.inline.} =
  (value.high and exponentMaskHigh) ==
      exponentMaskHigh and
    (
      (
        value.high and
        fractionMaskHigh
      ) != 0'u64 or
      value.low != 0'u64
    )

func isZeroBits(
    value: Bits;
): bool {.inline.} =
  (
    value.high and
    not signMask
  ) == 0'u64 and
    value.low == 0'u64

func incrementBits(
    value: Bits;
): Bits {.inline.} =
  if value.low == high(uint64):
    (
      high: value.high + 1'u64,
      low: 0'u64,
    )
  else:
    (
      high: value.high,
      low: value.low + 1'u64,
    )

func decrementBits(
    value: Bits;
): Bits {.inline.} =
  if value.low == 0'u64:
    (
      high: value.high - 1'u64,
      low: high(uint64),
    )
  else:
    (
      high: value.high,
      low: value.low - 1'u64,
    )

func expectedNextUp(
    value: Bits;
): Bits {.inline.} =
  if isNaNBits(value) or
      same(
        value,
        positiveInfinityBits,
      ):
    return value

  if isZeroBits(value):
    return positiveMinSubnormalBits

  if (
    value.high and
    signMask
  ) != 0'u64:
    decrementBits(value)
  else:
    incrementBits(value)

func expectedNextDown(
    value: Bits;
): Bits {.inline.} =
  if isNaNBits(value) or
      same(
        value,
        negativeInfinityBits,
      ):
    return value

  if isZeroBits(value):
    return negativeMinSubnormalBits

  if (
    value.high and
    signMask
  ) != 0'u64:
    incrementBits(value)
  else:
    decrementBits(value)

func expectedCopySign(
    magnitude,
    signSource: Bits;
): Bits {.inline.} =
  (
    high:
      (
        magnitude.high and
        not signMask
      ) or
      (
        signSource.high and
        signMask
      ),
    low:
      magnitude.low,
  )

func totalOrderKey(
    value: Bits;
): Bits {.inline.} =
  if (
    value.high and
    signMask
  ) != 0'u64:
    (
      high: not value.high,
      low: not value.low,
    )
  else:
    (
      high: value.high xor signMask,
      low: value.low,
    )

func keyLessOrEqual(
    a,
    b: Bits;
): bool {.inline.} =
  a.high < b.high or
    (
      a.high == b.high and
      a.low <= b.low
    )

func expectedTotalOrder(
    a,
    b: Bits;
): bool {.inline.} =
  keyLessOrEqual(
    totalOrderKey(a),
    totalOrderKey(b),
  )

proc assertBits(
    actual: Float128;
    expected: Bits;
) =
  let actualBits =
    bitsOf(actual)

  doAssert same(
    actualBits,
    expected,
  )

const
  unaryInputs:
    array[20, Bits] = [
      (
        high: 0x0000_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x8000_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x0000_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0001'u64,
      ),
      (
        high: 0x8000_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0001'u64,
      ),
      (
        high: 0x0000_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0x8000_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0x0001_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x8001_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x3FFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0xBFFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x7FFE_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0xFFFE_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0x7FFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0xFFFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x7FFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0001'u64,
      ),
      (
        high: 0xFFFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0001'u64,
      ),
      (
        high: 0x7FFF_8000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0xFFFF_8000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x7FFF_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0xFFFF_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
    ]

  copyCases:
    array[12, CopyCase] = [
      (
        magnitude: (
          high: 0x3FFF_0000_0000_0000'u64,
          low: 0'u64,
        ),
        signSource: negativeZeroBits,
      ),
      (
        magnitude: (
          high: 0xBFFF_0000_0000_0000'u64,
          low: 0'u64,
        ),
        signSource: positiveZeroBits,
      ),
      (
        magnitude: positiveZeroBits,
        signSource: negativeInfinityBits,
      ),
      (
        magnitude: negativeZeroBits,
        signSource: positiveInfinityBits,
      ),
      (
        magnitude: (
          high: 0x7FFF_FFFF_FFFF_FFFF'u64,
          low: 0xFFFF_FFFF_FFFF_FFFF'u64,
        ),
        signSource: (
          high: 0xBFFF_0000_0000_0000'u64,
          low: 0'u64,
        ),
      ),
      (
        magnitude: (
          high: 0xFFFF_FFFF_FFFF_FFFF'u64,
          low: 0xFFFF_FFFF_FFFF_FFFF'u64,
        ),
        signSource: (
          high: 0x3FFF_0000_0000_0000'u64,
          low: 0'u64,
        ),
      ),
      (
        magnitude: (
          high: 0x7FFF_0000_0000_0000'u64,
          low: 1'u64,
        ),
        signSource: (
          high: 0xFFFF_8000_0000_0000'u64,
          low: 0'u64,
        ),
      ),
      (
        magnitude: (
          high: 0xFFFF_7FFF_FFFF_FFFF'u64,
          low: 0xFFFF_FFFF_FFFF_FFFF'u64,
        ),
        signSource: (
          high: 0x7FFF_8000_0000_0000'u64,
          low: 0'u64,
        ),
      ),
      (
        magnitude: (
          high: 0x7FFE_FFFF_FFFF_FFFF'u64,
          low: 0xFFFF_FFFF_FFFF_FFFF'u64,
        ),
        signSource: (
          high: 0xFFFF_0000_0000_0000'u64,
          low: 1'u64,
        ),
      ),
      (
        magnitude: (
          high: 0xFFFE_FFFF_FFFF_FFFF'u64,
          low: 0xFFFF_FFFF_FFFF_FFFF'u64,
        ),
        signSource: (
          high: 0x7FFF_0000_0000_0000'u64,
          low: 1'u64,
        ),
      ),
      (
        magnitude: (
          high: 0x1234_5678_9ABC_DEF0'u64,
          low: 0x0123_4567_89AB_CDEF'u64,
        ),
        signSource: (
          high: 0xBFFF_0000_0000_0000'u64,
          low: 0'u64,
        ),
      ),
      (
        magnitude: (
          high: 0xFEDC_BA98_7654_3210'u64,
          low: 0xFEDC_BA98_7654_3210'u64,
        ),
        signSource: (
          high: 0x3FFF_0000_0000_0000'u64,
          low: 0'u64,
        ),
      ),
    ]

  totalOrderChain:
    array[18, Bits] = [
      (
        high: 0xFFFF_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0xFFFF_8000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0xFFFF_7FFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0xFFFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0001'u64,
      ),
      negativeInfinityBits,
      (
        high: 0xFFFE_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0xBFFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      negativeMinSubnormalBits,
      negativeZeroBits,
      positiveZeroBits,
      positiveMinSubnormalBits,
      (
        high: 0x3FFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x7FFE_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      positiveInfinityBits,
      (
        high: 0x7FFF_0000_0000_0000'u64,
        low: 0x0000_0000_0000_0001'u64,
      ),
      (
        high: 0x7FFF_7FFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
      (
        high: 0x7FFF_8000_0000_0000'u64,
        low: 0x0000_0000_0000_0000'u64,
      ),
      (
        high: 0x7FFF_FFFF_FFFF_FFFF'u64,
        low: 0xFFFF_FFFF_FFFF_FFFF'u64,
      ),
    ]

var unaryVectorCount =
  0

for input in unaryInputs:
  assertBits(
    nextUp(asFloat(input)),
    expectedNextUp(input),
  )

  inc unaryVectorCount

  assertBits(
    nextDown(asFloat(input)),
    expectedNextDown(input),
  )

  inc unaryVectorCount

doAssert unaryVectorCount == 40

var copySignVectorCount =
  0

for testCase in copyCases:
  assertBits(
    copySign(
      asFloat(testCase.magnitude),
      asFloat(testCase.signSource),
    ),
    expectedCopySign(
      testCase.magnitude,
      testCase.signSource,
    ),
  )

  inc copySignVectorCount

doAssert copySignVectorCount == 12

for index in 0 ..< totalOrderChain.len:
  let value =
    asFloat(
      totalOrderChain[index]
    )

  doAssert totalOrder(
    value,
    value,
  )

  if index + 1 < totalOrderChain.len:
    let nextValue =
      asFloat(
        totalOrderChain[index + 1]
      )

    doAssert totalOrder(
      value,
      nextValue,
    )

    doAssert not totalOrder(
      nextValue,
      value,
    )

var totalOrderPairCount =
  0

for leftIndex in 0 ..< totalOrderChain.len:
  for rightIndex in 0 ..< totalOrderChain.len:
    let
      left =
        totalOrderChain[leftIndex]
      right =
        totalOrderChain[rightIndex]

    doAssert totalOrder(
      asFloat(left),
      asFloat(right),
    ) == (
      leftIndex <= rightIndex
    )

    doAssert totalOrder(
      asFloat(left),
      asFloat(right),
    ) == expectedTotalOrder(
      left,
      right,
    )

    inc totalOrderPairCount

doAssert totalOrderPairCount == 324

type
  TinyRng =
    object
      state:
        uint64

proc nextU64(
    rng: var TinyRng;
): uint64 =
  rng.state =
    rng.state *
      6364136223846793005'u64 +
      1442695040888963407'u64

  rng.state

proc nextBits(
    rng: var TinyRng;
): Bits =
  (
    high: rng.nextU64(),
    low: rng.nextU64(),
  )

var rng =
  TinyRng(
    state:
      0x4E49_4D41_434C_5031'u64,
  )

const randomCaseCount = 32768

for _ in 0 ..< randomCaseCount:
  let
    xBits =
      rng.nextBits()
    yBits =
      rng.nextBits()
    zBits =
      rng.nextBits()

    x =
      asFloat(xBits)
    y =
      asFloat(yBits)
    z =
      asFloat(zBits)

  assertBits(
    nextUp(x),
    expectedNextUp(xBits),
  )

  assertBits(
    nextDown(x),
    expectedNextDown(xBits),
  )

  assertBits(
    copySign(x, y),
    expectedCopySign(
      xBits,
      yBits,
    ),
  )

  doAssert totalOrder(x, y) ==
    expectedTotalOrder(
      xBits,
      yBits,
    )

  doAssert totalOrder(x, y) or
    totalOrder(y, x)

  if totalOrder(x, y) and
      totalOrder(y, x):
    doAssert sameBits(x, y)

  if totalOrder(x, y) and
      totalOrder(y, z):
    doAssert totalOrder(x, z)

echo "FLOAT128_IEEE_EXTRA_CONTRACT_OK\t4\t40\t12\t18\t324\t32768"
