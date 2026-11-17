import std/unittest
import atcoder/modint
import atcoder/extra/math/ntt
import atcoder/extra/math/multipoint_evaluation_backup

useStaticModInt(backupSecondField, 167772161)

proc valueByPowers[T](coefficients: seq[T], x: T): T =
  result = T.init(0)
  var power = T.init(1)
  for coefficient in coefficients:
    result += coefficient * power
    power *= x

proc checkValues[T](coefficients, points: seq[T]) =
  let savedCoefficients = coefficients
  let savedPoints = points
  let values = multipointEvaluation(coefficients, points)
  doAssert values.len == points.len
  for i, x in points:
    doAssert values[i] == valueByPowers(coefficients, x)
  doAssert coefficients == savedCoefficients and points == savedPoints

proc singletonCases[T]() =
  let originalFailure = @[T.init(1), T.init(14), T.init(27), T.init(40), T.init(53)]
  doAssert multipointEvaluation(originalFailure, @[T.init(0)]) == @[T.init(1)]
  for length in [0, 1, 2, 3, 5, 16, 65, 257]:
    var coefficients = newSeq[T](length)
    for i in 0 ..< length: coefficients[i] = T.init(i * 13 + 1)
    for x in [0, 1, -1, 2, 37]:
      checkValues(coefficients, @[T.init(x)])

proc boundaryAndRandomCases[T]() =
  var state = 20261117'u64
  proc next(limit: int): int =
    state = state xor (state shl 7)
    state = state xor (state shr 9)
    state = state xor (state shl 8)
    int(state mod uint64(limit))
  for n in [0, 1, 2, 3, 7, 8, 9, 63, 64, 65, 129]:
    for length in [0, 1, 2, 5, n, n + 9]:
      var points = newSeq[T](n)
      var coefficients = newSeq[T](length)
      for i in 0 ..< n: points[i] = T.init((i * 7) mod 37)
      for i in 0 ..< length: coefficients[i] = T.init(i * 13 + 1)
      checkValues(coefficients, points)
  for trial in 0 ..< 300:
    let n = next(18)
    var points = newSeq[T](n)
    var coefficients = newSeq[T](next(50))
    for i in 0 ..< n: points[i] = T.init(next(23) - 11)
    for i in 0 ..< coefficients.len: coefficients[i] = T.init(next(200000) - 100000)
    checkValues(coefficients, points)
  checkValues(@[T.init(0), T.init(0), T.init(0)], @[T.init(0), T.init(0)])
  checkValues(@[T.init(3), T.init(2), T.init(0), T.init(0)], @[T.init(1), T.init(1)])

suite "backup multipoint evaluation":
  test "singleton root over 998244353":
    singletonCases[modint998244353]()
  test "singleton root over another supported NTT field":
    singletonCases[backupSecondField]()
  test "zero one two points and random power-sum oracle":
    boundaryAndRandomCases[modint998244353]()
    boundaryAndRandomCases[backupSecondField]()
