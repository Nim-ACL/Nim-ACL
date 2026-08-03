import atcoder/extra/numeric/float256

type
  RefBits =
    array[4, uint64]

  RefWide =
    array[8, uint64]

  RefFiniteParts =
    object
      sign: bool
      exponent: int
      significand: RefWide

const
  GeneratedPairCount =
    4096

  ExpectedPublicSymbolCount =
    43

  SplitMixSeed =
    0x0000_a256_add0_4096'u64

  ExpectedGeneratorFinalState =
    0xbcdd61fbebdac096'u64

  ExpectedGeneratorChecksum =
    0x3ff0ce0eca56cedd'u64

  BaseEncodings:
    array[24, RefBits] = [
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x8000000000000000'u64,
    ],
    [
      0x0000000000000001'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
    ],
    [
      0x0000000000000001'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x8000000000000000'u64,
    ],
    [
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0x00000fffffffffff'u64,
    ],
    [
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0x80000fffffffffff'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000100000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x8000100000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x3ffff00000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0xbffff00000000000'u64,
    ],
    [
      0x0000000000000001'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x3ffff00000000000'u64,
    ],
    [
      0x0000000000000001'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0xbffff00000000000'u64,
    ],
    [
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0x3fffefffffffffff'u64,
    ],
    [
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xbfffefffffffffff'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x3ff1200000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0xbff1200000000000'u64,
    ],
    [
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0x7fffefffffffffff'u64,
    ],
    [
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffffffffffffff'u64,
      0xffffefffffffffff'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x7ffff00000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0xfffff00000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x7ffff80000000000'u64,
    ],
    [
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0xfffff80000000000'u64,
    ],
    [
      0x0000000000000001'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0x7ffff00000000000'u64,
    ],
    [
      0x0000000000000001'u64,
      0x0000000000000000'u64,
      0x0000000000000000'u64,
      0xfffff00000000000'u64,
    ],
  ]

# REFERENCE_MODEL_BEGIN

func refExponent(
    value: RefBits,
): int =
  int(
    (
      value[3] shr 44
    ) and
    0x0007_ffff'u64
  )

func refSign(
    value: RefBits,
): bool =
  (
    value[3] and
    0x8000_0000_0000_0000'u64
  ) != 0'u64

func refFractionZero(
    value: RefBits,
): bool =
  (
    value[3] and
    0x0000_0fff_ffff_ffff'u64
  ) == 0'u64 and
    value[2] == 0'u64 and
    value[1] == 0'u64 and
    value[0] == 0'u64

func refIsZero(
    value: RefBits,
): bool =
  refExponent(value) == 0 and
    refFractionZero(value)

func refIsInfinity(
    value: RefBits,
): bool =
  refExponent(value) == 0x7ffff and
    refFractionZero(value)

func refIsNaN(
    value: RefBits,
): bool =
  refExponent(value) == 0x7ffff and
    not refFractionZero(value)

func refNegate(
    value: RefBits,
): RefBits =
  result =
    value

  result[3] =
    result[3] xor
    0x8000_0000_0000_0000'u64

func refQuietNaN(
    value: RefBits,
): RefBits =
  result =
    value

  result[3] =
    result[3] or
    0x0000_0800_0000_0000'u64

func refWideZero(
    value: RefWide,
): bool =
  for word in value:
    if word != 0'u64:
      return false

  true

func refWideCompare(
    a,
    b: RefWide,
): int =
  for index in countdown(7, 0):
    if a[index] < b[index]:
      return -1

    if a[index] > b[index]:
      return 1

  0

func refWideAdd(
    a,
    b: RefWide,
): tuple[
    value: RefWide,
    carry: bool,
] =
  var carry =
    0'u64

  for index in 0 ..< 8:
    let
      first =
        a[index] +
        b[index]

      firstCarry =
        first <
        a[index]

      second =
        first +
        carry

      secondCarry =
        second <
        first

    result.value[index] =
      second

    if firstCarry or
        secondCarry:
      carry =
        1'u64
    else:
      carry =
        0'u64

  result.carry =
    carry != 0'u64

func refWideSub(
    a,
    b: RefWide,
): tuple[
    value: RefWide,
    borrow: bool,
] =
  var borrow =
    0'u64

  for index in 0 ..< 8:
    let
      first =
        a[index] -
        b[index]

      firstBorrow =
        a[index] <
        b[index]

      second =
        first -
        borrow

      secondBorrow =
        first <
        borrow

    result.value[index] =
      second

    if firstBorrow or
        secondBorrow:
      borrow =
        1'u64
    else:
      borrow =
        0'u64

  result.borrow =
    borrow != 0'u64

func refWideGetBit(
    value: RefWide;
    index: int,
): bool =
  if index < 0 or
      index >= 512:
    return false

  let
    wordIndex =
      index shr 6

    bitIndex =
      index and 63

  (
    value[wordIndex] and
    (1'u64 shl bitIndex)
  ) != 0'u64

proc refWideSetBit(
    value: var RefWide;
    index: int,
) =
  if index < 0 or
      index >= 512:
    return

  let
    wordIndex =
      index shr 6

    bitIndex =
      index and 63

  value[wordIndex] =
    value[wordIndex] or
    (1'u64 shl bitIndex)

func refWideShiftLeft(
    value: RefWide;
    amount: int,
): RefWide =
  if amount <= 0:
    return value

  if amount >= 512:
    return

  for sourceIndex in 0 ..< (512 - amount):
    if refWideGetBit(
      value,
      sourceIndex,
    ):
      refWideSetBit(
        result,
        sourceIndex +
          amount,
      )

func refWideShiftRightJam(
    value: RefWide;
    amount: int,
): RefWide =
  if refWideZero(value):
    return

  if amount <= 0:
    return value

  if amount >= 512:
    result[0] =
      1'u64
    return

  for sourceIndex in amount ..< 512:
    if refWideGetBit(
      value,
      sourceIndex,
    ):
      refWideSetBit(
        result,
        sourceIndex -
          amount,
      )

  for discardedIndex in 0 ..< amount:
    if refWideGetBit(
      value,
      discardedIndex,
    ):
      result[0] =
        result[0] or
        1'u64
      break

func refWideHighest(
    value: RefWide,
): int =
  for index in countdown(511, 0):
    if refWideGetBit(
      value,
      index,
    ):
      return index

  -1

func refPack(
    negative: bool;
    exponentField: int;
    fraction: RefWide,
): RefBits =
  result[0] =
    fraction[0]

  result[1] =
    fraction[1]

  result[2] =
    fraction[2]

  result[3] =
    (
      if negative:
        0x8000_0000_0000_0000'u64
      else:
        0'u64
    ) or
    (
      uint64(exponentField) shl 44
    ) or
    (
      fraction[3] and
      0x0000_0fff_ffff_ffff'u64
    )

func refFiniteParts(
    value: RefBits,
): RefFiniteParts =
  result.sign =
    refSign(value)

  let exponentField =
    refExponent(value)

  result.significand[0] =
    value[0]

  result.significand[1] =
    value[1]

  result.significand[2] =
    value[2]

  result.significand[3] =
    value[3] and
    0x0000_0fff_ffff_ffff'u64

  if exponentField == 0:
    let
      highest =
        refWideHighest(
          result.significand
        )

      shift =
        236 -
        highest

    result.significand =
      refWideShiftLeft(
        result.significand,
        shift,
      )

    result.exponent =
      -262142 -
      shift
  else:
    refWideSetBit(
      result.significand,
      236,
    )

    result.exponent =
      exponentField -
      262143

func refRoundPack(
    negative: bool;
    sourceExponent: int;
    sourceExtended: RefWide,
): RefBits =
  var one =
    default(RefWide)

  refWideSetBit(
    one,
    0,
  )

  let
    hiddenBit =
      refWideShiftLeft(
        one,
        236,
      )

    carryBit =
      refWideShiftLeft(
        one,
        237,
      )

  if refWideZero(
      sourceExtended
  ):
    return refPack(
      negative,
      0,
      default(RefWide),
    )

  var
    exponent =
      sourceExponent

    extended =
      sourceExtended

  if exponent < -262142:
    extended =
      refWideShiftRightJam(
        extended,
        -262142 -
          exponent,
      )

    exponent =
      -262142

  # Preserve the retained least-significant bit.
  # Only the three GRS bits are removed before using the
  # existing shift-right-jam helper as a pure right shift.
  var retainedSource =
    extended

  retainedSource[0] =
    retainedSource[0] and
    not 7'u64

  var retained =
    refWideShiftRightJam(
      retainedSource,
      3,
    )

  let
    guard =
      refWideGetBit(
        extended,
        2,
      )

    roundBit =
      refWideGetBit(
        extended,
        1,
      )

    sticky =
      refWideGetBit(
        extended,
        0,
      )

  if guard and
      (
        roundBit or
        sticky or
        ((retained[0] and 1'u64) != 0'u64)
      ):
    let incremented =
      refWideAdd(
        retained,
        one,
      )

    doAssert not incremented.carry

    retained =
      incremented.value

  if refWideCompare(
      retained,
      carryBit,
  ) >= 0:
    retained =
      refWideShiftRightJam(
        retained,
        1,
      )

    retained[0] =
      retained[0] and
      not 1'u64

    inc exponent

  if exponent > 262143:
    return refPack(
      negative,
      0x7ffff,
      default(RefWide),
    )

  if refWideZero(retained):
    return refPack(
      negative,
      0,
      default(RefWide),
    )

  if exponent == -262142 and
      refWideCompare(
        retained,
        hiddenBit,
      ) < 0:
    return refPack(
      negative,
      0,
      retained,
    )

  let fraction =
    refWideSub(
      retained,
      hiddenBit,
    )

  doAssert not fraction.borrow

  refPack(
    negative,
    exponent +
      262143,
    fraction.value,
  )

func refAddSubFinite(
    lhs,
    rhs: RefFiniteParts,
): RefBits =
  var
    larger =
      lhs

    smaller =
      rhs

  if larger.exponent < smaller.exponent or
      (
        larger.exponent == smaller.exponent and
        refWideCompare(
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
      refWideShiftLeft(
        larger.significand,
        3,
      )

    smallerExtended =
      refWideShiftRightJam(
        refWideShiftLeft(
          smaller.significand,
          3,
        ),
        exponentDifference,
      )

  if larger.sign == smaller.sign:
    let added =
      refWideAdd(
        largerExtended,
        smallerExtended,
      )

    doAssert not added.carry

    var
      sum =
        added.value

      exponent =
        larger.exponent

    let highest =
      refWideHighest(sum)

    if highest > 239:
      let shift =
        highest -
        239

      sum =
        refWideShiftRightJam(
          sum,
          shift,
        )

      exponent +=
        shift

    return refRoundPack(
      larger.sign,
      exponent,
      sum,
    )

  let subtracted =
    refWideSub(
      largerExtended,
      smallerExtended,
    )

  doAssert not subtracted.borrow

  var difference =
    subtracted.value

  if refWideZero(difference):
    return BaseEncodings[0]

  var exponent =
    larger.exponent

  let highest =
    refWideHighest(
      difference
    )

  if highest < 239:
    let shift =
      239 -
      highest

    difference =
      refWideShiftLeft(
        difference,
        shift,
      )

    exponent -=
      shift

  refRoundPack(
    larger.sign,
    exponent,
    difference,
  )

func refAddSub(
    lhs,
    rhs: RefBits;
    subtract: bool,
): RefBits =
  if refIsNaN(lhs):
    return refQuietNaN(lhs)

  if refIsNaN(rhs):
    return refQuietNaN(rhs)

  let effectiveRhs =
    if subtract:
      refNegate(rhs)
    else:
      rhs

  let
    lhsInfinity =
      refIsInfinity(lhs)

    rhsInfinity =
      refIsInfinity(effectiveRhs)

  if lhsInfinity and
      rhsInfinity:
    if refSign(lhs) !=
        refSign(effectiveRhs):
      return BaseEncodings[20]

    return lhs

  if lhsInfinity:
    return lhs

  if rhsInfinity:
    return effectiveRhs

  let
    lhsZero =
      refIsZero(lhs)

    rhsZero =
      refIsZero(effectiveRhs)

  if lhsZero and
      rhsZero:
    if refSign(lhs) ==
        refSign(effectiveRhs):
      return
        if refSign(lhs):
          BaseEncodings[1]
        else:
          BaseEncodings[0]

    return BaseEncodings[0]

  if lhsZero:
    return effectiveRhs

  if rhsZero:
    return lhs

  refAddSubFinite(
    refFiniteParts(lhs),
    refFiniteParts(effectiveRhs),
  )

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

  value xor
    (value shr 31)

proc randomRef(
    state: var uint64,
): RefBits =
  for index in 0 ..< 4:
    result[index] =
      splitMix64(state)

proc checkUnary(
    bits: RefBits,
) =
  let value =
    candidateFromRef(bits)

  doAssert candidateToRef(
    -value
  ) == refNegate(bits)

proc checkPair(
    xBits,
    yBits: RefBits,
) =
  let
    x =
      candidateFromRef(xBits)

    y =
      candidateFromRef(yBits)

  doAssert candidateToRef(
    x + y
  ) == refAddSub(
    xBits,
    yBits,
    false,
  )

  doAssert candidateToRef(
    x - y
  ) == refAddSub(
    xBits,
    yBits,
    true,
  )

doAssert sizeof(Float256) == 32

block:
  let
    minimumSubnormal =
      BaseEncodings[2]

    minimumNormal =
      BaseEncodings[6]

    expectedExactSum: RefBits = [
      0x0000_0000_0000_0001'u64,
      0x0000_0000_0000_0000'u64,
      0x0000_0000_0000_0000'u64,
      0x0000_1000_0000_0000'u64,
    ]

  doAssert refAddSub(
    minimumSubnormal,
    minimumNormal,
    false,
  ) == expectedExactSum

  doAssert candidateToRef(
    candidateFromRef(minimumSubnormal) +
    candidateFromRef(minimumNormal)
  ) == expectedExactSum

var
  baseEncodingCount =
    0

  orderedPairCount =
    0

  generatedPairCount =
    0

  operationEvaluationCount =
    0

for bits in BaseEncodings:
  checkUnary(bits)

  inc baseEncodingCount

for xBits in BaseEncodings:
  for yBits in BaseEncodings:
    checkPair(
      xBits,
      yBits,
    )

    inc orderedPairCount

    operationEvaluationCount +=
      2

var
  generatorState =
    SplitMixSeed

  generatorChecksum =
    0'u64

for _ in 0 ..< GeneratedPairCount:
  let
    xBits =
      randomRef(
        generatorState
      )

    yBits =
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

  checkUnary(xBits)

  checkPair(
    xBits,
    yBits,
  )

  inc generatedPairCount

  operationEvaluationCount +=
    2

doAssert baseEncodingCount == 24

doAssert orderedPairCount == 576

doAssert generatedPairCount ==
  GeneratedPairCount

doAssert operationEvaluationCount ==
  9344

doAssert generatorState ==
  ExpectedGeneratorFinalState

doAssert generatorChecksum ==
  ExpectedGeneratorChecksum

doAssert ExpectedPublicSymbolCount ==
  43

echo "F256_ADD_SUB_PACKET_A_CONTRACT_OK",
  "\t", baseEncodingCount,
  "\t", orderedPairCount,
  "\t", generatedPairCount,
  "\t", operationEvaluationCount,
  "\t", ExpectedPublicSymbolCount,
  "\t", sizeof(Float256)
