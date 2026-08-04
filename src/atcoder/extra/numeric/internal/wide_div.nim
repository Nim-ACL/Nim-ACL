import atcoder/extra/numeric/internal/limbs

proc divideMod4*(
    numerator,
    denominator: UInt256Limbs,
): tuple[
    quotient: UInt256Limbs,
    remainder: UInt256Limbs,
] =
  if isZero4(denominator):
    raise newException(
      DivByZeroDefect,
      "division by zero",
    )

  for bitIndex in countdown(255, 0):
    result.remainder =
      shiftLeftOne4(
        result.remainder
      )

    if getBit4(
      numerator,
      range[0 .. 255](bitIndex),
    ):
      result.remainder[0] =
        result.remainder[0] or
        1'u64

    if compare4(
      result.remainder,
      denominator,
    ) >= 0:
      result.remainder =
        sub4(
          result.remainder,
          denominator,
        ).value

      setBit4(
        result.quotient,
        range[0 .. 255](bitIndex),
      )

when not declared ATCODER_EXTRA_NUMERIC_INTERNAL_WIDE_DIV_8X4:
  const ATCODER_EXTRA_NUMERIC_INTERNAL_WIDE_DIV_8X4 = 1

  func compare8ForWideDivision(
      left: UInt512Limbs,
      right: UInt512Limbs,
  ): int {.inline.} =
    for index in countdown(7, 0):
      if left[index] < right[index]:
        return -1
      if left[index] > right[index]:
        return 1

    0

  func shiftLeftOne8ForWideDivision(
      value: UInt512Limbs,
  ): UInt512Limbs {.inline.} =
    var carry = 0'u64

    for index in 0 ..< 8:
      let nextCarry =
        value[index] shr 63

      result[index] =
        (value[index] shl 1) or carry

      carry = nextCarry

  func subtract8ForWideDivision(
      left: UInt512Limbs,
      right: UInt512Limbs,
  ): UInt512Limbs {.inline.} =
    var borrow = 0'u64

    for index in 0 ..< 8:
      let
        withoutBorrow =
          left[index] - right[index]

        firstBorrow =
          if left[index] < right[index]:
            1'u64
          else:
            0'u64

        value =
          withoutBorrow - borrow

        secondBorrow =
          if withoutBorrow < borrow:
            1'u64
          else:
            0'u64

      result[index] = value
      borrow = firstBorrow or secondBorrow

  func isZero4ForWideDivision(
      value: UInt256Limbs,
  ): bool {.inline.} =
    for index in 0 ..< 4:
      if value[index] != 0'u64:
        return false

    true

  func widen4ForWideDivision(
      value: UInt256Limbs,
  ): UInt512Limbs {.inline.} =
    for index in 0 ..< 4:
      result[index] = value[index]

  func divRemWide8x4*(
      numerator: UInt512Limbs,
      denominator: UInt256Limbs,
  ): tuple[
      quotient: UInt512Limbs,
      remainder: UInt256Limbs,
  ] =
    ## Divides an unsigned 512-bit numerator by an unsigned
    ## 256-bit denominator.
    ##
    ## The algorithm performs exactly 512 restoring-division
    ## iterations. The denominator must be nonzero.
    doAssert not isZero4ForWideDivision(
      denominator
    )

    let denominatorWide =
      widen4ForWideDivision(
        denominator
      )

    var
      quotient: UInt512Limbs
      remainderWide: UInt512Limbs

    for bitIndex in countdown(511, 0):
      remainderWide =
        shiftLeftOne8ForWideDivision(
          remainderWide
        )

      let
        wordIndex = bitIndex shr 6
        bitOffset = bitIndex and 63

      if (
        (
          numerator[wordIndex] shr bitOffset
        ) and 1'u64
      ) != 0'u64:
        remainderWide[0] =
          remainderWide[0] or 1'u64

      if compare8ForWideDivision(
        remainderWide,
        denominatorWide,
      ) >= 0:
        remainderWide =
          subtract8ForWideDivision(
            remainderWide,
            denominatorWide,
          )

        quotient[wordIndex] =
          quotient[wordIndex] or
          (1'u64 shl bitOffset)

    for index in 4 ..< 8:
      doAssert remainderWide[index] == 0'u64

    result.quotient = quotient

    for index in 0 ..< 4:
      result.remainder[index] =
        remainderWide[index]
