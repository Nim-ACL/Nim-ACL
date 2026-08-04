import std/[os, strutils]

import atcoder/extra/numeric/internal/limbs
import atcoder/extra/numeric/internal/wide_div

func parseHex64(
    text: string,
): uint64 =
  doAssert text.len == 16

  for character in text:
    let digit =
      case character
      of '0' .. '9':
        ord(character) - ord('0')
      of 'a' .. 'f':
        ord(character) - ord('a') + 10
      of 'A' .. 'F':
        ord(character) - ord('A') + 10
      else:
        raise newException(
          ValueError,
          "invalid hexadecimal digit",
        )

    result =
      (result shl 4) or uint64(digit)

func toHex64(
    value: uint64,
): string =
  const digits =
    "0123456789abcdef"

  result = newString(16)

  var current = value

  for index in countdown(15, 0):
    result[index] =
      digits[int(current and 15'u64)]

    current = current shr 4

proc checkCase(
    numerator: UInt512Limbs,
    denominator: UInt256Limbs,
    expectedQuotient: UInt512Limbs,
    expectedRemainder: UInt256Limbs,
) =
  let actual =
    divRemWide8x4(
      numerator,
      denominator,
    )

  doAssert actual.quotient ==
    expectedQuotient

  doAssert actual.remainder ==
    expectedRemainder

proc runLocalContract() =
  block zeroDividedByOne:
    var
      numerator: UInt512Limbs
      denominator: UInt256Limbs
      quotient: UInt512Limbs
      remainder: UInt256Limbs

    denominator[0] = 1'u64

    checkCase(
      numerator,
      denominator,
      quotient,
      remainder,
    )

  block oneDividedByOne:
    var
      numerator: UInt512Limbs
      denominator: UInt256Limbs
      quotient: UInt512Limbs
      remainder: UInt256Limbs

    numerator[0] = 1'u64
    denominator[0] = 1'u64
    quotient[0] = 1'u64

    checkCase(
      numerator,
      denominator,
      quotient,
      remainder,
    )

  block tenDividedByThree:
    var
      numerator: UInt512Limbs
      denominator: UInt256Limbs
      quotient: UInt512Limbs
      remainder: UInt256Limbs

    numerator[0] = 10'u64
    denominator[0] = 3'u64
    quotient[0] = 3'u64
    remainder[0] = 1'u64

    checkCase(
      numerator,
      denominator,
      quotient,
      remainder,
    )

  block twoPower256Boundary:
    var
      numerator: UInt512Limbs
      denominator: UInt256Limbs
      quotient: UInt512Limbs
      remainder: UInt256Limbs

    numerator[4] = 1'u64

    for index in 0 ..< 4:
      denominator[index] =
        high(uint64)

    quotient[0] = 1'u64
    remainder[0] = 1'u64

    checkCase(
      numerator,
      denominator,
      quotient,
      remainder,
    )

  block maximumExactDivision:
    var
      numerator: UInt512Limbs
      denominator: UInt256Limbs
      quotient: UInt512Limbs
      remainder: UInt256Limbs

    for index in 0 ..< 8:
      numerator[index] =
        high(uint64)

    for index in 0 ..< 4:
      denominator[index] =
        high(uint64)

    quotient[0] = 1'u64
    quotient[4] = 1'u64

    checkCase(
      numerator,
      denominator,
      quotient,
      remainder,
    )

  echo "NACL_UINT512_WIDE_DIVISION_PACKET_C_CONTRACT_OK"

proc runOracleMode() =
  var line: string

  while stdin.readLine(line):
    if line.len == 0:
      continue

    let fields =
      line.splitWhitespace()

    doAssert fields.len == 12

    var
      numerator: UInt512Limbs
      denominator: UInt256Limbs

    for index in 0 ..< 8:
      numerator[index] =
        parseHex64(fields[index])

    for index in 0 ..< 4:
      denominator[index] =
        parseHex64(fields[index + 8])

    let actual =
      divRemWide8x4(
        numerator,
        denominator,
      )

    var output =
      newSeq[string](12)

    for index in 0 ..< 8:
      output[index] =
        toHex64(
          actual.quotient[index]
        )

    for index in 0 ..< 4:
      output[index + 8] =
        toHex64(
          actual.remainder[index]
        )

    stdout.write(
      output.join(" ")
    )
    stdout.write("\n")

if paramCount() == 1 and
   paramStr(1) == "--oracle":
  runOracleMode()
else:
  runLocalContract()
