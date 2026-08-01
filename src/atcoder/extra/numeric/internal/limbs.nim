type
  UInt256Limbs* = array[4, uint64]
  UInt512Limbs* = array[8, uint64]

func isZero4*(
    value: UInt256Limbs,
): bool =
  for limb in value:
    if limb != 0'u64:
      return false

  true

func compare4*(
    a,
    b: UInt256Limbs,
): int =
  for index in countdown(3, 0):
    if a[index] < b[index]:
      return -1

    if a[index] > b[index]:
      return 1

  0

func add4*(
    a,
    b: UInt256Limbs,
): tuple[
    value: UInt256Limbs,
    carry: bool,
] =
  var carryWord =
    0'u64

  for index in 0 ..< 4:
    let first =
      a[index] + b[index]

    let firstCarry =
      first < a[index]

    let second =
      first + carryWord

    let secondCarry =
      second < first

    result.value[index] =
      second

    if firstCarry or secondCarry:
      carryWord =
        1'u64
    else:
      carryWord =
        0'u64

  result.carry =
    carryWord != 0'u64

func sub4*(
    a,
    b: UInt256Limbs,
): tuple[
    value: UInt256Limbs,
    borrow: bool,
] =
  var borrowWord =
    0'u64

  for index in 0 ..< 4:
    let first =
      a[index] - b[index]

    let firstBorrow =
      a[index] < b[index]

    let second =
      first - borrowWord

    let secondBorrow =
      first < borrowWord

    result.value[index] =
      second

    if firstBorrow or secondBorrow:
      borrowWord =
        1'u64
    else:
      borrowWord =
        0'u64

  result.borrow =
    borrowWord != 0'u64

func shiftLeftOne4*(
    value: UInt256Limbs,
): UInt256Limbs =
  var carry =
    0'u64

  for index in 0 ..< 4:
    let nextCarry =
      value[index] shr 63

    result[index] =
      (value[index] shl 1) or carry

    carry =
      nextCarry

func shiftRightOne4*(
    value: UInt256Limbs,
): UInt256Limbs =
  var carry =
    0'u64

  for index in countdown(3, 0):
    let nextCarry =
      value[index] and 1'u64

    result[index] =
      (value[index] shr 1) or
      (carry shl 63)

    carry =
      nextCarry

func getBit4*(
    value: UInt256Limbs,
    index: range[0 .. 255],
): bool =
  let limbIndex =
    int(index) shr 6

  let bitIndex =
    int(index) and 63

  (
    value[limbIndex] and
    (1'u64 shl bitIndex)
  ) != 0'u64

proc setBit4*(
    value: var UInt256Limbs,
    index: range[0 .. 255],
) =
  let limbIndex =
    int(index) shr 6

  let bitIndex =
    int(index) and 63

  value[limbIndex] =
    value[limbIndex] or
    (1'u64 shl bitIndex)

func compare8*(
    a,
    b: UInt512Limbs,
): int =
  for index in countdown(7, 0):
    if a[index] < b[index]:
      return -1

    if a[index] > b[index]:
      return 1

  0

func add8*(
    a,
    b: UInt512Limbs,
): tuple[
    value: UInt512Limbs,
    carry: bool,
] =
  var carryWord =
    0'u64

  for index in 0 ..< 8:
    let first =
      a[index] + b[index]

    let firstCarry =
      first < a[index]

    let second =
      first + carryWord

    let secondCarry =
      second < first

    result.value[index] =
      second

    if firstCarry or secondCarry:
      carryWord =
        1'u64
    else:
      carryWord =
        0'u64

  result.carry =
    carryWord != 0'u64

func sub8*(
    a,
    b: UInt512Limbs,
): tuple[
    value: UInt512Limbs,
    borrow: bool,
] =
  var borrowWord =
    0'u64

  for index in 0 ..< 8:
    let first =
      a[index] - b[index]

    let firstBorrow =
      a[index] < b[index]

    let second =
      first - borrowWord

    let secondBorrow =
      first < borrowWord

    result.value[index] =
      second

    if firstBorrow or secondBorrow:
      borrowWord =
        1'u64
    else:
      borrowWord =
        0'u64

  result.borrow =
    borrowWord != 0'u64

func shiftLeft8*(
    value: UInt512Limbs;
    amount: int,
): UInt512Limbs =
  if amount <= 0:
    return value

  if amount >= 512:
    return default(UInt512Limbs)

  let wordShift =
    amount shr 6

  let bitShift =
    amount and 63

  for destinationIndex in countdown(7, 0):
    let sourceIndex =
      destinationIndex - wordShift

    if sourceIndex < 0:
      continue

    result[destinationIndex] =
      value[sourceIndex] shl bitShift

    if bitShift != 0 and
        sourceIndex > 0:
      result[destinationIndex] =
        result[destinationIndex] or
        (
          value[sourceIndex - 1] shr
          (64 - bitShift)
        )

func shiftRight8*(
    value: UInt512Limbs;
    amount: int,
): UInt512Limbs =
  if amount <= 0:
    return value

  if amount >= 512:
    return default(UInt512Limbs)

  let wordShift =
    amount shr 6

  let bitShift =
    amount and 63

  for destinationIndex in 0 ..< 8:
    let sourceIndex =
      destinationIndex + wordShift

    if sourceIndex >= 8:
      continue

    result[destinationIndex] =
      value[sourceIndex] shr bitShift

    if bitShift != 0 and
        sourceIndex + 1 < 8:
      result[destinationIndex] =
        result[destinationIndex] or
        (
          value[sourceIndex + 1] shl
          (64 - bitShift)
        )

func getBit8(
    value: UInt512Limbs;
    index: int,
): bool =
  if index < 0 or index >= 512:
    return false

  let limbIndex =
    index shr 6

  let bitIndex =
    index and 63

  (
    value[limbIndex] and
    (1'u64 shl bitIndex)
  ) != 0'u64

func anyLowBits8(
    value: UInt512Limbs;
    bitCount: int,
): bool =
  if bitCount <= 0:
    return false

  if bitCount >= 512:
    for limb in value:
      if limb != 0'u64:
        return true

    return false

  let fullLimbs =
    bitCount shr 6

  let partialBits =
    bitCount and 63

  for index in 0 ..< fullLimbs:
    if value[index] != 0'u64:
      return true

  if partialBits != 0:
    let mask =
      (1'u64 shl partialBits) -
      1'u64

    if (
      value[fullLimbs] and
      mask
    ) != 0'u64:
      return true

  false

func guardRoundSticky8*(
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
    getBit8(
      value,
      discardedBitCount - 1,
    )

  if discardedBitCount >= 2:
    result.roundBit =
      getBit8(
        value,
        discardedBitCount - 2,
      )

    result.sticky =
      anyLowBits8(
        value,
        discardedBitCount - 2,
      )
