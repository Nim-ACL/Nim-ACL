# M192 isolated candidate regression.
# Completion: static isPrime matches trial division on 0 .. 128.
# This covers 0, 1, 2 and the last valid array index.
# Negative inputs are outside this regression's contract.

import atcoder/extra/math/static_eratosthenes

proc trialDivisionPrime(n: int): bool =
  if n < 2:
    return false
  var d = 2
  while d <= n div d:
    if n mod d == 0:
      return false
    inc d
  return true

var sieve = initEratosthenes(128)
var checked = 0
for n in 0 .. 128:
  let
    expected = trialDivisionPrime(n)
    actual = sieve.isPrime(n)
  doAssert actual == expected,
    "static isPrime(" & $n & "): actual=" & $actual &
    ", expected=" & $expected
  inc checked

doAssert checked == 129
echo "M192_MATH_STATIC_SIEVE_REGRESSION_PASS cases=", checked
