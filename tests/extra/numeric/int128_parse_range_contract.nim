import atcoder/extra/numeric/int128

template expectValueError(
    expression: untyped,
) =
  block:
    var observed =
      false

    try:
      discard expression
    except ValueError:
      observed =
        true

    doAssert observed

const
  UInt128Maximum =
    "340282366920938463463374607431768211455"

  UInt128MaximumPlusOne =
    "340282366920938463463374607431768211456"

  Int128Maximum =
    "170141183460469231731687303715884105727"

  Int128MaximumPlusOne =
    "170141183460469231731687303715884105728"

  Int128Minimum =
    "-170141183460469231731687303715884105728"

  Int128MinimumMinusOne =
    "-170141183460469231731687303715884105729"

doAssert $parseUInt128("0") == "0"
doAssert $parseUInt128("+0") == "0"
doAssert $parseUInt128("000001") == "1"

doAssert $parseUInt128(
  UInt128Maximum
) == UInt128Maximum

doAssert $parseUInt128(
  "+" & UInt128Maximum
) == UInt128Maximum

expectValueError(
  parseUInt128(
    UInt128MaximumPlusOne
  )
)

expectValueError(
  parseUInt128(
    UInt128MaximumPlusOne & "0"
  )
)

expectValueError(
  parseUInt128("")
)

expectValueError(
  parseUInt128("+")
)

expectValueError(
  parseUInt128("-1")
)

expectValueError(
  parseUInt128("1x")
)

expectValueError(
  parseUInt128(" 1")
)

doAssert $parseInt128("0") == "0"
doAssert $parseInt128("+0") == "0"
doAssert $parseInt128("-0") == "0"
doAssert $parseInt128("000001") == "1"
doAssert $parseInt128("-000001") == "-1"

doAssert $parseInt128(
  Int128Maximum
) == Int128Maximum

doAssert $parseInt128(
  "+" & Int128Maximum
) == Int128Maximum

doAssert $parseInt128(
  Int128Minimum
) == Int128Minimum

expectValueError(
  parseInt128(
    Int128MaximumPlusOne
  )
)

expectValueError(
  parseInt128(
    "+" & Int128MaximumPlusOne
  )
)

expectValueError(
  parseInt128(
    Int128MinimumMinusOne
  )
)

expectValueError(
  parseInt128(
    Int128MaximumPlusOne & "0"
  )
)

expectValueError(
  parseInt128(
    Int128MinimumMinusOne & "0"
  )
)

expectValueError(
  parseInt128("")
)

expectValueError(
  parseInt128("+")
)

expectValueError(
  parseInt128("-")
)

expectValueError(
  parseInt128("1x")
)

expectValueError(
  parseInt128("--1")
)

let minimum =
  parseInt128(
    Int128Minimum
  )

doAssert (
  minimum div toInt128(-1'i64)
) == minimum

echo "INT128_PARSE_RANGE_CONTRACT_OK"
