# M192 isolated candidate regression.
# Completion: dynamic isPrime matches trial division on 0 .. 128.
# This covers 0, 1, 2 and expansion of an initially small sieve.
# Negative inputs are outside this regression's contract.

import atcoder/extra/math/eratosthenes

proc trialDivisionPrime(n: int): bool =
  if n < 2:
    return false
  var d = 2
  while d <= n div d:
    if n mod d == 0:
      return false
    inc d
  return true

var sieve = initEratosthenes(4)
var checked = 0
for n in 0 .. 128:
  let
    expected = trialDivisionPrime(n)
    actual = sieve.isPrime(n)
  doAssert actual == expected,
    "dynamic isPrime(" & $n & "): actual=" & $actual &
    ", expected=" & $expected
  inc checked

doAssert checked == 129
echo "M192_MATH_DYNAMIC_SIEVE_REGRESSION_PASS cases=", checked
