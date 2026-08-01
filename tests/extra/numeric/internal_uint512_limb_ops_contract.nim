import atcoder/extra/numeric/internal/limbs

const
  GeneratedCaseCount =
    4096

  SyntheticValueCount =
    12

  SplitMixSeed =
    0x00000f2565124096'u64

  ExpectedGeneratorFinalState =
    0x36964e151f31c096'u64

  ExpectedGeneratorChecksum =
    0x47966ef44a609c2e'u64

  BoundaryAmounts = [
    -1,
    0,
    1,
    2,
    3,
    63,
    64,
    65,
    127,
    128,
    129,
    235,
    236,
    237,
    255,
    256,
    257,
    447,
    448,
    511,
    512,
    513,
    514,
    515,
  ]

# REFERENCE_MODEL_BEGIN

func referenceGetBit(
    value: UInt512Limbs;
    index: int,
): int =
  if index < 0 or index >= 512:
    return 0

  let limbIndex =
    index shr 6

  let bitIndex =
    index and 63

  if (
    value[limbIndex] and
    (1'u64 shl bitIndex)
  ) != 0'u64:
    1
  else:
    0

proc referenceSetBit(
    value: var UInt512Limbs;
    index: int;
    bit: int,
) =
  if bit == 0:
    return

  if index < 0 or index >= 512:
    return

  let limbIndex =
    index shr 6

  let bitIndex =
    index and 63

  value[limbIndex] =
    value[limbIndex] or
    (1'u64 shl bitIndex)

proc referenceCompare8(
    a,
    b: UInt512Limbs,
): int =
  for bitIndex in countdown(511, 0):
    let aBit =
      referenceGetBit(
        a,
        bitIndex,
      )

    let bBit =
      referenceGetBit(
        b,
        bitIndex,
      )

    if aBit < bBit:
      return -1

    if aBit > bBit:
      return 1

  0

proc referenceAdd8(
    a,
    b: UInt512Limbs,
): tuple[
    value: UInt512Limbs,
    carry: bool,
] =
  var carry = 0

  for bitIndex in 0 ..< 512:
    let total =
      referenceGetBit(
        a,
        bitIndex,
      ) +
      referenceGetBit(
        b,
        bitIndex,
      ) +
      carry

    referenceSetBit(
      result.value,
      bitIndex,
      total and 1,
    )

    carry =
      total shr 1

  result.carry =
    carry != 0

proc referenceSub8(
    a,
    b: UInt512Limbs,
): tuple[
    value: UInt512Limbs,
    borrow: bool,
] =
  var borrow = 0

  for bitIndex in 0 ..< 512:
    var difference =
      referenceGetBit(
        a,
        bitIndex,
      ) -
      referenceGetBit(
        b,
        bitIndex,
      ) -
      borrow

    if difference < 0:
      difference += 2
      borrow = 1
    else:
      borrow = 0

    referenceSetBit(
      result.value,
      bitIndex,
      difference,
    )

  result.borrow =
    borrow != 0

proc referenceShiftLeft8(
    value: UInt512Limbs;
    amount: int,
): UInt512Limbs =
  if amount <= 0:
    return value

  if amount >= 512:
    return

  for sourceBit in 0 ..< 512:
    if referenceGetBit(
      value,
      sourceBit,
    ) == 0:
      continue

    let destinationBit =
      sourceBit + amount

    if destinationBit < 512:
      referenceSetBit(
        result,
        destinationBit,
        1,
      )

proc referenceShiftRight8(
    value: UInt512Limbs;
    amount: int,
): UInt512Limbs =
  if amount <= 0:
    return value

  if amount >= 512:
    return

  for sourceBit in 0 ..< 512:
    if referenceGetBit(
      value,
      sourceBit,
    ) == 0:
      continue

    let destinationBit =
      sourceBit - amount

    if destinationBit >= 0:
      referenceSetBit(
        result,
        destinationBit,
        1,
      )

proc referenceGuardRoundSticky8(
    value: UInt512Limbs;
    discardedBitCount: int,
): tuple[
    guard: bool,
    roundBit: bool,
    sticky: bool,
] =
  if discardedBitCount <= 0:
    return

  result.guard =
    referenceGetBit(
      value,
      discardedBitCount - 1,
    ) != 0

  if discardedBitCount < 2:
    return

  result.roundBit =
    referenceGetBit(
      value,
      discardedBitCount - 2,
    ) != 0

  let stickyLimit =
    min(
      discardedBitCount - 2,
      512,
    )

  for bitIndex in 0 ..< stickyLimit:
    if referenceGetBit(
      value,
      bitIndex,
    ) != 0:
      result.sticky = true
      return

# REFERENCE_MODEL_END

proc splitMix64(
    state: var uint64,
): uint64 =
  state =
    state +
    0x9e3779b97f4a7c15'u64

  var value = state

  value =
    (
      value xor
      (value shr 30)
    ) *
    0xbf58476d1ce4e5b9'u64

  value =
    (
      value xor
      (value shr 27)
    ) *
    0x94d049bb133111eb'u64

  value xor
  (value shr 31)

proc makeRandomWide(
    state: var uint64,
): UInt512Limbs =
  for index in 0 ..< 8:
    result[index] =
      splitMix64(state)

proc makeSyntheticValues():
    array[
      SyntheticValueCount,
      UInt512Limbs,
    ] =
  result[0] =
    default(UInt512Limbs)

  result[1][0] =
    1'u64

  for index in 0 ..< 8:
    result[2][index] =
      high(uint64)

  result[3][0] =
    1'u64

  result[4][0] =
    1'u64 shl 63

  result[5][1] =
    1'u64

  result[6][3] =
    1'u64 shl 63

  result[7][4] =
    1'u64

  result[8][7] =
    1'u64 shl 62

  result[9][7] =
    1'u64 shl 63

  for index in 0 ..< 8:
    result[10][index] =
      0xaaaaaaaaaaaaaaaa'u64

    result[11][index] =
      0x5555555555555555'u64

doAssert sizeof(UInt512Limbs) == 64

let syntheticValues =
  makeSyntheticValues()

doAssert syntheticValues.len ==
  SyntheticValueCount

doAssert syntheticValues[1] ==
  syntheticValues[3]

var
  syntheticBoundaryCheckCount = 0
  syntheticPairCheckCount = 0

for value in syntheticValues:
  for amount in BoundaryAmounts:
    doAssert shiftLeft8(
      value,
      amount,
    ) == referenceShiftLeft8(
      value,
      amount,
    )

    doAssert shiftRight8(
      value,
      amount,
    ) == referenceShiftRight8(
      value,
      amount,
    )

    let actualGrs =
      guardRoundSticky8(
        value,
        amount,
      )

    let expectedGrs =
      referenceGuardRoundSticky8(
        value,
        amount,
      )

    doAssert actualGrs.guard ==
      expectedGrs.guard

    doAssert actualGrs.roundBit ==
      expectedGrs.roundBit

    doAssert actualGrs.sticky ==
      expectedGrs.sticky

    inc syntheticBoundaryCheckCount

for a in syntheticValues:
  for b in syntheticValues:
    doAssert compare8(
      a,
      b,
    ) == referenceCompare8(
      a,
      b,
    )

    let actualAdd =
      add8(
        a,
        b,
      )

    let expectedAdd =
      referenceAdd8(
        a,
        b,
      )

    doAssert actualAdd.value ==
      expectedAdd.value

    doAssert actualAdd.carry ==
      expectedAdd.carry

    let actualSub =
      sub8(
        a,
        b,
      )

    let expectedSub =
      referenceSub8(
        a,
        b,
      )

    doAssert actualSub.value ==
      expectedSub.value

    doAssert actualSub.borrow ==
      expectedSub.borrow

    inc syntheticPairCheckCount

let topBitOnly =
  syntheticValues[9]

let synthetic513 =
  guardRoundSticky8(
    topBitOnly,
    513,
  )

doAssert not synthetic513.guard
doAssert synthetic513.roundBit
doAssert not synthetic513.sticky

let synthetic514 =
  guardRoundSticky8(
    topBitOnly,
    514,
  )

doAssert not synthetic514.guard
doAssert not synthetic514.roundBit
doAssert synthetic514.sticky

var
  generatorState =
    SplitMixSeed

  generatorChecksum =
    0'u64

  generatedCaseCount =
    0

for caseIndex in 0 ..< GeneratedCaseCount:
  let a =
    makeRandomWide(
      generatorState
    )

  let b =
    makeRandomWide(
      generatorState
    )

  let c =
    makeRandomWide(
      generatorState
    )

  for limb in a:
    generatorChecksum =
      generatorChecksum xor limb

  for limb in b:
    generatorChecksum =
      generatorChecksum xor limb

  for limb in c:
    generatorChecksum =
      generatorChecksum xor limb

  doAssert compare8(
    a,
    b,
  ) == referenceCompare8(
    a,
    b,
  )

  let actualAdd =
    add8(
      a,
      b,
    )

  let expectedAdd =
    referenceAdd8(
      a,
      b,
    )

  doAssert actualAdd.value ==
    expectedAdd.value

  doAssert actualAdd.carry ==
    expectedAdd.carry

  let actualSub =
    sub8(
      a,
      b,
    )

  let expectedSub =
    referenceSub8(
      a,
      b,
    )

  doAssert actualSub.value ==
    expectedSub.value

  doAssert actualSub.borrow ==
    expectedSub.borrow

  let shiftAmount =
    BoundaryAmounts[
      caseIndex mod
      BoundaryAmounts.len
    ]

  doAssert shiftLeft8(
    c,
    shiftAmount,
  ) == referenceShiftLeft8(
    c,
    shiftAmount,
  )

  doAssert shiftRight8(
    c,
    shiftAmount,
  ) == referenceShiftRight8(
    c,
    shiftAmount,
  )

  let grsAmount =
    BoundaryAmounts[
      (
        caseIndex * 7 +
        3
      ) mod
      BoundaryAmounts.len
    ]

  let actualGrs =
    guardRoundSticky8(
      c,
      grsAmount,
    )

  let expectedGrs =
    referenceGuardRoundSticky8(
      c,
      grsAmount,
    )

  doAssert actualGrs.guard ==
    expectedGrs.guard

  doAssert actualGrs.roundBit ==
    expectedGrs.roundBit

  doAssert actualGrs.sticky ==
    expectedGrs.sticky

  inc generatedCaseCount

doAssert generatedCaseCount ==
  GeneratedCaseCount

doAssert syntheticBoundaryCheckCount ==
  SyntheticValueCount *
  BoundaryAmounts.len

doAssert syntheticPairCheckCount ==
  SyntheticValueCount *
  SyntheticValueCount

doAssert generatorState ==
  ExpectedGeneratorFinalState

doAssert generatorChecksum ==
  ExpectedGeneratorChecksum

echo "F256_STAGE_A_COMPACT_CONTRACT_OK",
  "\t", generatedCaseCount,
  "\t", syntheticBoundaryCheckCount,
  "\t", syntheticPairCheckCount,
  "\t", BoundaryAmounts.len,
  "\t", syntheticValues.len,
  "\t", sizeof(UInt512Limbs)
