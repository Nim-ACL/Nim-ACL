when not declared ATCODER_EXTRA_NUMERIC_INT128_HPP:
  const ATCODER_EXTRA_NUMERIC_INT128_HPP* = 1

  import std/[algorithm, hashes]

  type
    UInt128* = object
      loWord: uint64
      hiWord: uint64

    Int128* = object
      loWord: uint64
      hiWord: uint64

  func rawUInt128(loWord, hiWord: uint64): UInt128 {.inline.} =
    UInt128(
      loWord: loWord,
      hiWord: hiWord,
    )

  func rawInt128(loWord, hiWord: uint64): Int128 {.inline.} =
    Int128(
      loWord: loWord,
      hiWord: hiWord,
    )

  func fromUInt64Words*(
      highWord,
      lowWord: uint64,
  ): UInt128 {.inline.} =
    rawUInt128(
      lowWord,
      highWord,
    )

  func fromInt128Bits*(
      highWord,
      lowWord: uint64,
  ): Int128 {.inline.} =
    rawInt128(
      lowWord,
      highWord,
    )

  func low64*(x: UInt128): uint64 {.inline.} =
    x.loWord

  func high64*(x: UInt128): uint64 {.inline.} =
    x.hiWord

  func low64*(x: Int128): uint64 {.inline.} =
    x.loWord

  func high64*(x: Int128): uint64 {.inline.} =
    x.hiWord

  func asUInt128(x: Int128): UInt128 {.inline.} =
    rawUInt128(
      x.loWord,
      x.hiWord,
    )

  func asInt128(x: UInt128): Int128 {.inline.} =
    rawInt128(
      x.loWord,
      x.hiWord,
    )

  func isZero(x: UInt128): bool {.inline.} =
    x.loWord == 0'u64 and
      x.hiWord == 0'u64

  func isZero(x: Int128): bool {.inline.} =
    x.loWord == 0'u64 and
      x.hiWord == 0'u64

  func isNegative(x: Int128): bool {.inline.} =
    (x.hiWord shr 63) != 0'u64

  converter toUInt128*[T: SomeInteger](
      x: T,
  ): UInt128 {.inline.} =
    when T is SomeUnsignedInt:
      rawUInt128(
        uint64(x),
        0'u64,
      )
    else:
      let signedValue = int64(x)

      if signedValue < 0'i64:
        rawUInt128(
          cast[uint64](signedValue),
          high(uint64),
        )
      else:
        rawUInt128(
          uint64(signedValue),
          0'u64,
        )

  converter toInt128*[T: SomeInteger](
      x: T,
  ): Int128 {.inline.} =
    when T is SomeUnsignedInt:
      rawInt128(
        uint64(x),
        0'u64,
      )
    else:
      let signedValue = int64(x)

      if signedValue < 0'i64:
        rawInt128(
          cast[uint64](signedValue),
          high(uint64),
        )
      else:
        rawInt128(
          uint64(signedValue),
          0'u64,
        )

  converter toUInt128*(
      x: Int128,
  ): UInt128 {.inline.} =
    asUInt128(x)

  converter toInt128*(
      x: UInt128,
  ): Int128 {.inline.} =
    asInt128(x)

  func `==`*(
      a,
      b: UInt128,
  ): bool {.inline.} =
    a.loWord == b.loWord and
      a.hiWord == b.hiWord

  func `==`*(
      a,
      b: Int128,
  ): bool {.inline.} =
    a.loWord == b.loWord and
      a.hiWord == b.hiWord

  func `<`*(
      a,
      b: UInt128,
  ): bool {.inline.} =
    a.hiWord < b.hiWord or
      (
        a.hiWord == b.hiWord and
        a.loWord < b.loWord
      )

  func `<`*(
      a,
      b: Int128,
  ): bool {.inline.} =
    let aNegative = isNegative(a)
    let bNegative = isNegative(b)

    if aNegative != bNegative:
      aNegative
    elif a.hiWord != b.hiWord:
      a.hiWord < b.hiWord
    else:
      a.loWord < b.loWord

  func `<=`*[T: UInt128 or Int128](
      a,
      b: T,
  ): bool {.inline.} =
    a < b or
      a == b

  func `>`*[T: UInt128 or Int128](
      a,
      b: T,
  ): bool {.inline.} =
    b < a

  func `>=`*[T: UInt128 or Int128](
      a,
      b: T,
  ): bool {.inline.} =
    b <= a

  func cmp*[T: UInt128 or Int128](
      a,
      b: T,
  ): int {.inline.} =
    if a < b:
      -1
    elif a == b:
      0
    else:
      1

  func `and`*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    rawUInt128(
      a.loWord and b.loWord,
      a.hiWord and b.hiWord,
    )

  func `or`*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    rawUInt128(
      a.loWord or b.loWord,
      a.hiWord or b.hiWord,
    )

  func `xor`*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    rawUInt128(
      a.loWord xor b.loWord,
      a.hiWord xor b.hiWord,
    )

  func `not`*(
      a: UInt128,
  ): UInt128 {.inline.} =
    rawUInt128(
      not a.loWord,
      not a.hiWord,
    )

  func `and`*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    asInt128(
      asUInt128(a) and asUInt128(b)
    )

  func `or`*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    asInt128(
      asUInt128(a) or asUInt128(b)
    )

  func `xor`*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    asInt128(
      asUInt128(a) xor asUInt128(b)
    )

  func `not`*(
      a: Int128,
  ): Int128 {.inline.} =
    asInt128(
      not asUInt128(a)
    )

  func `+`*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    let lowResult =
      a.loWord + b.loWord

    let carry =
      if lowResult < a.loWord:
        1'u64
      else:
        0'u64

    rawUInt128(
      lowResult,
      a.hiWord + b.hiWord + carry,
    )

  func `-`*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    let borrow =
      if a.loWord < b.loWord:
        1'u64
      else:
        0'u64

    rawUInt128(
      a.loWord - b.loWord,
      a.hiWord - b.hiWord - borrow,
    )

  func `+`*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    asInt128(
      asUInt128(a) + asUInt128(b)
    )

  func `-`*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    asInt128(
      asUInt128(a) - asUInt128(b)
    )

  func `-`*(
      x: Int128,
  ): Int128 {.inline.} =
    asInt128(
      toUInt128(0'u64) - asUInt128(x)
    )

  func shlUInt128(
      x: UInt128,
      shift: int,
  ): UInt128 {.inline.} =
    if shift <= 0:
      x
    elif shift >= 128:
      toUInt128(0'u64)
    elif shift >= 64:
      rawUInt128(
        0'u64,
        x.loWord shl (shift - 64),
      )
    else:
      rawUInt128(
        x.loWord shl shift,
        (x.hiWord shl shift) or
          (x.loWord shr (64 - shift)),
      )

  func shrUInt128(
      x: UInt128,
      shift: int,
  ): UInt128 {.inline.} =
    if shift <= 0:
      x
    elif shift >= 128:
      toUInt128(0'u64)
    elif shift >= 64:
      rawUInt128(
        x.hiWord shr (shift - 64),
        0'u64,
      )
    else:
      rawUInt128(
        (x.loWord shr shift) or
          (x.hiWord shl (64 - shift)),
        x.hiWord shr shift,
      )

  func arithmeticShiftRight64(
      word: uint64,
      shift: int,
  ): uint64 {.inline.} =
    let negative =
      (word shr 63) != 0'u64

    if shift <= 0:
      word
    elif shift >= 64:
      if negative:
        high(uint64)
      else:
        0'u64
    elif negative:
      (word shr shift) or
        (high(uint64) shl (64 - shift))
    else:
      word shr shift

  func `shl`*(
      x: UInt128,
      shift: int,
  ): UInt128 {.inline.} =
    shlUInt128(
      x,
      shift,
    )

  func `shr`*(
      x: UInt128,
      shift: int,
  ): UInt128 {.inline.} =
    shrUInt128(
      x,
      shift,
    )

  func `shl`*(
      x: Int128,
      shift: int,
  ): Int128 {.inline.} =
    asInt128(
      shlUInt128(
        asUInt128(x),
        shift,
      )
    )

  func `shr`*(
      x: Int128,
      shift: int,
  ): Int128 {.inline.} =
    if shift <= 0:
      x
    elif shift >= 128:
      if isNegative(x):
        rawInt128(
          high(uint64),
          high(uint64),
        )
      else:
        toInt128(0'i64)
    elif shift >= 64:
      let fill =
        if isNegative(x):
          high(uint64)
        else:
          0'u64

      rawInt128(
        arithmeticShiftRight64(
          x.hiWord,
          shift - 64,
        ),
        fill,
      )
    else:
      rawInt128(
        (x.loWord shr shift) or
          (x.hiWord shl (64 - shift)),
        arithmeticShiftRight64(
          x.hiWord,
          shift,
        ),
      )

  func mul64Wide(
      a,
      b: uint64,
  ): tuple[
      lowWord,
      highWord: uint64,
  ] {.inline.} =
    const mask32 =
      0xffff_ffff'u64

    let aLow =
      a and mask32
    let aHigh =
      a shr 32
    let bLow =
      b and mask32
    let bHigh =
      b shr 32

    let lowProduct =
      aLow * bLow

    var middle =
      aHigh * bLow +
        (lowProduct shr 32)

    let middleLow =
      middle and mask32
    let middleHigh =
      middle shr 32

    middle =
      aLow * bHigh +
        middleLow

    result.lowWord =
      (middle shl 32) or
        (lowProduct and mask32)

    result.highWord =
      aHigh * bHigh +
        middleHigh +
        (middle shr 32)

  func `*`*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    let lowProduct =
      mul64Wide(
        a.loWord,
        b.loWord,
      )

    let highWord =
      lowProduct.highWord +
        (a.loWord * b.hiWord) +
        (a.hiWord * b.loWord)

    rawUInt128(
      lowProduct.lowWord,
      highWord,
    )

  func `*`*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    asInt128(
      asUInt128(a) * asUInt128(b)
    )

  func bitAt(
      x: UInt128,
      bitIndex: int,
  ): bool {.inline.} =
    if bitIndex < 64:
      (
        (
          x.loWord shr bitIndex
        ) and 1'u64
      ) != 0'u64
    else:
      (
        (
          x.hiWord shr (bitIndex - 64)
        ) and 1'u64
      ) != 0'u64

  proc setBit(
      x: var UInt128,
      bitIndex: int,
  ) {.inline.} =
    if bitIndex < 64:
      x.loWord =
        x.loWord or
          (1'u64 shl bitIndex)
    else:
      x.hiWord =
        x.hiWord or
          (1'u64 shl (bitIndex - 64))

  proc unsignedDivMod(
      numerator,
      denominator: UInt128,
  ): tuple[
      quotient,
      remainder: UInt128,
  ] =
    if isZero(denominator):
      raise newException(
        DivByZeroDefect,
        "UInt128 division by zero",
      )

    var quotient =
      toUInt128(0'u64)

    var remainder =
      toUInt128(0'u64)

    for bitIndex in countdown(127, 0):
      let overflowBit =
        remainder.hiWord shr 63

      remainder =
        remainder shl 1

      if bitAt(
          numerator,
          bitIndex,
      ):
        remainder.loWord =
          remainder.loWord or 1'u64

      if overflowBit != 0'u64 or
          remainder >= denominator:
        remainder =
          remainder - denominator

        setBit(
          quotient,
          bitIndex,
        )

    result =
      (
        quotient,
        remainder,
      )

  proc `div`*(
      a,
      b: UInt128,
  ): UInt128 =
    unsignedDivMod(
      a,
      b,
    ).quotient

  proc `mod`*(
      a,
      b: UInt128,
  ): UInt128 =
    unsignedDivMod(
      a,
      b,
    ).remainder

  func magnitude(
      x: Int128,
  ): UInt128 {.inline.} =
    if isNegative(x):
      toUInt128(0'u64) -
        asUInt128(x)
    else:
      asUInt128(x)

  proc `div`*(
      a,
      b: Int128,
  ): Int128 =
    if isZero(b):
      raise newException(
        DivByZeroDefect,
        "Int128 division by zero",
      )

    let quotientMagnitude =
      magnitude(a) div magnitude(b)

    let quotient =
      asInt128(quotientMagnitude)

    if isNegative(a) xor isNegative(b):
      -quotient
    else:
      quotient

  proc `mod`*(
      a,
      b: Int128,
  ): Int128 =
    if isZero(b):
      raise newException(
        DivByZeroDefect,
        "Int128 modulo by zero",
      )

    let remainder =
      asInt128(
        magnitude(a) mod magnitude(b)
      )

    if isNegative(a):
      -remainder
    else:
      remainder

  proc floorDiv*(
      a,
      b: Int128,
  ): Int128 =
    var quotient =
      a div b

    let remainder =
      a mod b

    if not isZero(remainder) and
        (
          isNegative(a) xor
          isNegative(b)
        ):
      quotient =
        quotient - toInt128(1'i64)

    quotient

  proc floorMod*(
      a,
      b: Int128,
  ): Int128 =
    var remainder =
      a mod b

    if not isZero(remainder) and
        (
          isNegative(a) xor
          isNegative(b)
        ):
      remainder =
        remainder + b

    remainder

  func abs*(
      x: Int128,
  ): Int128 {.inline.} =
    if isNegative(x):
      -x
    else:
      x

  func toInt*(
      x: Int128,
  ): int {.inline.} =
    int(
      cast[int64](x.loWord)
    )

  func toInt*(
      x: UInt128,
  ): int {.inline.} =
    int(
      cast[int64](x.loWord)
    )

  func toInt32*(
      x: Int128,
  ): int32 {.inline.} =
    cast[int32](
      uint32(x.loWord)
    )

  func toUInt*(
      x: Int128,
  ): uint {.inline.} =
    uint(x.loWord)

  func toUInt*(
      x: UInt128,
  ): uint {.inline.} =
    uint(x.loWord)

  func hash*(
      x: UInt128,
  ): Hash =
    hash(x.loWord) !&
      hash(x.hiWord)

  func hash*(
      x: Int128,
  ): Hash =
    hash(x.loWord) !&
      hash(x.hiWord)

  proc uint128ToDecimal(
      value: UInt128,
  ): string =
    if isZero(value):
      return "0"

    let ten =
      toUInt128(10'u64)

    var current =
      value

    var reversedDigits =
      ""

    while not isZero(current):
      let division =
        unsignedDivMod(
          current,
          ten,
        )

      reversedDigits.add(
        char(
          ord('0') +
            int(division.remainder.loWord)
        )
      )

      current =
        division.quotient

    reversedDigits.reverse()
    reversedDigits

  proc `$`*(
      value: UInt128,
  ): string =
    uint128ToDecimal(value)

  proc `$`*(
      value: Int128,
  ): string =
    if isNegative(value):
      "-" &
        uint128ToDecimal(
          magnitude(value)
        )
    else:
      uint128ToDecimal(
        asUInt128(value)
      )

  proc parseUInt128*(
      text: string,
  ): UInt128 =
    if text.len == 0:
      raise newException(
        ValueError,
        "empty UInt128 string",
      )

    var index =
      0

    if text[0] == '+':
      index =
        1

    if index >= text.len:
      raise newException(
        ValueError,
        "missing UInt128 digits",
      )

    let ten =
      toUInt128(10'u64)

    let maximum =
      rawUInt128(
        high(uint64),
        high(uint64),
      )

    let maximumDivision =
      unsignedDivMod(
        maximum,
        ten,
      )

    var value =
      toUInt128(0'u64)

    while index < text.len:
      let character =
        text[index]

      if character < '0' or
          character > '9':
        raise newException(
          ValueError,
          "invalid UInt128 digit",
        )

      let digit =
        toUInt128(
          uint64(
            ord(character) -
              ord('0')
          )
        )

      if value >
          maximumDivision.quotient or
          (
            value ==
              maximumDivision.quotient and
            digit >
              maximumDivision.remainder
          ):
        raise newException(
          ValueError,
          "UInt128 overflow",
        )

      value =
        value * ten +
          digit

      inc index

    value
  proc parseInt128*(
      text: string,
  ): Int128 =
    if text.len == 0:
      raise newException(
        ValueError,
        "empty Int128 string",
      )

    var index =
      0

    var negative =
      false

    if text[0] == '-':
      negative =
        true

      inc index
    elif text[0] == '+':
      inc index

    if index >= text.len:
      raise newException(
        ValueError,
        "missing Int128 digits",
      )

    let ten =
      toUInt128(10'u64)

    let limit =
      if negative:
        rawUInt128(
          0'u64,
          1'u64 shl 63,
        )
      else:
        rawUInt128(
          high(uint64),
          high(uint64) shr 1,
        )

    let limitDivision =
      unsignedDivMod(
        limit,
        ten,
      )

    var magnitudeValue =
      toUInt128(0'u64)

    while index < text.len:
      let character =
        text[index]

      if character < '0' or
          character > '9':
        raise newException(
          ValueError,
          "invalid Int128 digit",
        )

      let digit =
        toUInt128(
          uint64(
            ord(character) -
              ord('0')
          )
        )

      if magnitudeValue >
          limitDivision.quotient or
          (
            magnitudeValue ==
              limitDivision.quotient and
            digit >
              limitDivision.remainder
          ):
        raise newException(
          ValueError,
          "Int128 overflow",
        )

      magnitudeValue =
        magnitudeValue * ten +
          digit

      inc index

    if negative:
      -asInt128(
        magnitudeValue
      )
    else:
      asInt128(
        magnitudeValue
      )
  proc pow*(
      base,
      exponent,
      modulus: Int128,
  ): Int128 =
    if isZero(modulus):
      raise newException(
        DivByZeroDefect,
        "Int128 modular power with zero modulus",
      )

    if isNegative(exponent):
      raise newException(
        ValueError,
        "negative Int128 exponent",
      )

    var result =
      toInt128(1'i64) mod modulus

    var currentBase =
      base mod modulus

    var currentExponent =
      exponent

    while currentExponent > toInt128(0'i64):
      if (
          asUInt128(currentExponent).loWord and
          1'u64
      ) != 0'u64:
        result =
          (result * currentBase) mod modulus

      currentExponent =
        currentExponent shr 1

      if currentExponent > toInt128(0'i64):
        currentBase =
          (currentBase * currentBase) mod modulus

    result

  proc `^`*(
      base,
      exponent: Int128,
  ): Int128 =
    if isNegative(exponent):
      raise newException(
        ValueError,
        "negative Int128 exponent",
      )

    var result =
      toInt128(1'i64)

    var currentBase =
      base

    var currentExponent =
      exponent

    while currentExponent > toInt128(0'i64):
      if (
          asUInt128(currentExponent).loWord and
          1'u64
      ) != 0'u64:
        result =
          result * currentBase

      currentExponent =
        currentExponent shr 1

      if currentExponent > toInt128(0'i64):
        currentBase =
          currentBase * currentBase

    result

  proc inc*(
      value: var UInt128,
  ) {.inline.} =
    value =
      value + toUInt128(1'u64)

  proc dec*(
      value: var UInt128,
  ) {.inline.} =
    value =
      value - toUInt128(1'u64)

  proc inc*(
      value: var Int128,
  ) {.inline.} =
    value =
      value + toInt128(1'i64)

  proc dec*(
      value: var Int128,
  ) {.inline.} =
    value =
      value - toInt128(1'i64)

  proc `+=`*[T: UInt128 or Int128](
      value: var T,
      other: T,
  ) {.inline.} =
    value =
      value + other

  proc `-=`*[T: UInt128 or Int128](
      value: var T,
      other: T,
  ) {.inline.} =
    value =
      value - other

  proc `*=`*[T: UInt128 or Int128](
      value: var T,
      other: T,
  ) {.inline.} =
    value =
      value * other

  func maxUInt128Value(): UInt128 {.inline.} =
    rawUInt128(
      high(uint64),
      high(uint64),
    )

  func maxInt128Value(): Int128 {.inline.} =
    rawInt128(
      high(uint64),
      high(uint64) shr 1,
    )

  func minInt128Value(): Int128 {.inline.} =
    rawInt128(
      0'u64,
      1'u64 shl 63,
    )

  func positiveInt128MagnitudeLimit(): UInt128 {.inline.} =
    rawUInt128(
      high(uint64),
      high(uint64) shr 1,
    )

  func negativeInt128MagnitudeLimit(): UInt128 {.inline.} =
    rawUInt128(
      0'u64,
      1'u64 shl 63,
    )

  proc wrappingAdd*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    a + b

  proc wrappingSub*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    a - b

  proc wrappingMul*(
      a,
      b: UInt128,
  ): UInt128 {.inline.} =
    a * b

  proc wrappingAdd*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    a + b

  proc wrappingSub*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    a - b

  proc wrappingMul*(
      a,
      b: Int128,
  ): Int128 {.inline.} =
    a * b

  proc overflowingAdd*(
      a,
      b: UInt128,
  ): tuple[
      value: UInt128,
      overflow: bool,
  ] {.inline.} =
    let value =
      a + b

    (
      value,
      value < a,
    )

  proc overflowingSub*(
      a,
      b: UInt128,
  ): tuple[
      value: UInt128,
      overflow: bool,
  ] {.inline.} =
    (
      a - b,
      a < b,
    )

  proc overflowingMul*(
      a,
      b: UInt128,
  ): tuple[
      value: UInt128,
      overflow: bool,
  ] =
    let value =
      a * b

    let overflow =
      not isZero(b) and
      a > maxUInt128Value() div b

    (
      value,
      overflow,
    )

  proc overflowingAdd*(
      a,
      b: Int128,
  ): tuple[
      value: Int128,
      overflow: bool,
  ] {.inline.} =
    let value =
      a + b

    let aNegative =
      isNegative(a)

    let overflow =
      aNegative == isNegative(b) and
      isNegative(value) != aNegative

    (
      value,
      overflow,
    )

  proc overflowingSub*(
      a,
      b: Int128,
  ): tuple[
      value: Int128,
      overflow: bool,
  ] {.inline.} =
    let value =
      a - b

    let aNegative =
      isNegative(a)

    let overflow =
      aNegative != isNegative(b) and
      isNegative(value) != aNegative

    (
      value,
      overflow,
    )

  proc overflowingMul*(
      a,
      b: Int128,
  ): tuple[
      value: Int128,
      overflow: bool,
  ] =
    let value =
      a * b

    if isZero(a) or
        isZero(b):
      return (
        value,
        false,
      )

    let negativeResult =
      isNegative(a) xor
      isNegative(b)

    let limit =
      if negativeResult:
        negativeInt128MagnitudeLimit()
      else:
        positiveInt128MagnitudeLimit()

    let overflow =
      magnitude(a) >
        limit div magnitude(b)

    (
      value,
      overflow,
    )

  proc saturatingAdd*(
      a,
      b: UInt128,
  ): UInt128 =
    let calculation =
      overflowingAdd(
        a,
        b,
      )

    if calculation.overflow:
      maxUInt128Value()
    else:
      calculation.value

  proc saturatingSub*(
      a,
      b: UInt128,
  ): UInt128 =
    let calculation =
      overflowingSub(
        a,
        b,
      )

    if calculation.overflow:
      toUInt128(0'u64)
    else:
      calculation.value

  proc saturatingMul*(
      a,
      b: UInt128,
  ): UInt128 =
    let calculation =
      overflowingMul(
        a,
        b,
      )

    if calculation.overflow:
      maxUInt128Value()
    else:
      calculation.value

  proc saturatingAdd*(
      a,
      b: Int128,
  ): Int128 =
    let calculation =
      overflowingAdd(
        a,
        b,
      )

    if calculation.overflow:
      if isNegative(a):
        minInt128Value()
      else:
        maxInt128Value()
    else:
      calculation.value

  proc saturatingSub*(
      a,
      b: Int128,
  ): Int128 =
    let calculation =
      overflowingSub(
        a,
        b,
      )

    if calculation.overflow:
      if isNegative(a):
        minInt128Value()
      else:
        maxInt128Value()
    else:
      calculation.value

  proc saturatingMul*(
      a,
      b: Int128,
  ): Int128 =
    let calculation =
      overflowingMul(
        a,
        b,
      )

    if calculation.overflow:
      if isNegative(a) xor
          isNegative(b):
        minInt128Value()
      else:
        maxInt128Value()
    else:
      calculation.value

  func countLeadingZeroBits64(
      x: uint64,
  ): int =
    if x == 0'u64:
      return 64

    var mask =
      1'u64 shl 63

    while (x and mask) == 0'u64:
      inc result
      mask =
        mask shr 1

  func countTrailingZeroBits64(
      x: uint64,
  ): int =
    if x == 0'u64:
      return 64

    var mask =
      1'u64

    while (x and mask) == 0'u64:
      inc result
      mask =
        mask shl 1

  func popcount64(
      x: uint64,
  ): int =
    var value =
      x

    while value != 0'u64:
      value =
        value and
        (value - 1'u64)

      inc result

  func countLeadingZeroBits*(
      x: UInt128,
  ): int =
    if x.hiWord != 0'u64:
      countLeadingZeroBits64(
        x.hiWord,
      )
    else:
      64 +
        countLeadingZeroBits64(
          x.loWord,
        )

  func countTrailingZeroBits*(
      x: UInt128,
  ): int =
    if x.loWord != 0'u64:
      countTrailingZeroBits64(
        x.loWord,
      )
    else:
      64 +
        countTrailingZeroBits64(
          x.hiWord,
        )

  func popcount*(
      x: UInt128,
  ): int =
    popcount64(x.loWord) +
      popcount64(x.hiWord)

  func countLeadingZeroBits*(
      x: Int128,
  ): int =
    countLeadingZeroBits(
      asUInt128(x)
    )

  func countTrailingZeroBits*(
      x: Int128,
  ): int =
    countTrailingZeroBits(
      asUInt128(x)
    )

  func popcount*(
      x: Int128,
  ): int =
    popcount(
      asUInt128(x)
    )

  func normalizedRotation(
      distance: int,
  ): int =
    result =
      distance mod 128

    if result < 0:
      result +=
        128

  func rotateLeft*(
      x: UInt128,
      distance: int,
  ): UInt128 =
    let shift =
      normalizedRotation(distance)

    if shift == 0:
      x
    else:
      (x shl shift) or
        (x shr (128 - shift))

  func rotateRight*(
      x: UInt128,
      distance: int,
  ): UInt128 =
    let shift =
      normalizedRotation(distance)

    if shift == 0:
      x
    else:
      (x shr shift) or
        (x shl (128 - shift))

  func rotateLeft*(
      x: Int128,
      distance: int,
  ): Int128 =
    asInt128(
      rotateLeft(
        asUInt128(x),
        distance,
      )
    )

  func rotateRight*(
      x: Int128,
      distance: int,
  ): Int128 =
    asInt128(
      rotateRight(
        asUInt128(x),
        distance,
      )
    )
