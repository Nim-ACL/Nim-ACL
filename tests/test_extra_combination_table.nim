# M192 isolated candidate regression.
# Completion: 110 inputs per type match an independent falling product.
# The composite static modulus checks that P needs no division or inverse.

import atcoder/modint
import atcoder/extra/math/combination_table

useStaticModInt(m192Mod12, 12)

proc directPermutation(n, r: int): int =
  if r < 0 or r > n:
    return 0
  result = 1
  for i in 0 ..< r:
    result *= n - i

var checked = 0
for n in 0 .. 10:
  for r in -2 .. (n + 2):
    let expected = directPermutation(n, r)

    let actualInt = int.P(n, r)
    doAssert actualInt == expected,
      "int.P(" & $n & ", " & $r & "): actual=" & $actualInt &
      ", expected=" & $expected
    inc checked

    let actualPrime = modint998244353.P(n, r)
    doAssert actualPrime == modint998244353(expected),
      "modint998244353.P(" & $n & ", " & $r & "): actual=" &
      $actualPrime & ", expected=" & $(expected mod 998244353)
    inc checked

    let actualComposite = m192Mod12.P(n, r)
    doAssert actualComposite == m192Mod12(expected),
      "m192Mod12.P(" & $n & ", " & $r & "): actual=" &
      $actualComposite & ", expected=" & $(expected mod 12)
    inc checked

doAssert checked == 330
echo "M192_MATH_P_REGRESSION_PASS cases=", checked
