# M192 isolated candidate regression.
# Completion: all 12 representable values return correctly with overflow
# checks enabled. No OverflowDefect is caught or accepted.
# The first 8 cases include all inputs from the M190/M191 witness.
# Requires a 64-bit int target and --overflowChecks:on.

import atcoder/extra/math/convert_base

static:
  doAssert sizeof(int) == 8,
    "This regression requires a 64-bit int target"
  doAssert compileOption("overflowChecks"),
    "Compile this regression with --overflowChecks:on"

var checked = 0

doAssert toInt(@[5, 4, 3, 2, 1], 10) == 12345
inc checked
doAssert toInt(@[1, 0, 1, 1], 2) == 13
inc checked

var decimalDigits = newSeq[int](19)
decimalDigits[18] = 1
doAssert toInt(decimalDigits, 10) == 1_000_000_000_000_000_000
inc checked

doAssert toInt(newSeq[int](19), 10) == 0
inc checked
doAssert toInt(toSeq(0, 10, 19), 10) == 0
inc checked

var binaryDigits = newSeq[int](63)
for i in 0 ..< binaryDigits.len:
  binaryDigits[i] = 1
doAssert toInt(binaryDigits, 2) == int.high
inc checked

doAssert toInt(toSeq(int.high, 10), 10) == int.high
inc checked
doAssert toInt(toSeq(1, 10, 20), 10) == 1
inc checked

# Preserve empty input, zero and default-base single-digit behavior.
doAssert toInt(newSeq[int]()) == 0
inc checked
doAssert toInt(newSeq[int](), 2) == 0
inc checked
doAssert toInt(@[0]) == 0
inc checked
doAssert toInt(@[7]) == 7
inc checked

doAssert checked == 12
echo "M192_MATH_CONVERT_BASE_REGRESSION_PASS cases=", checked
