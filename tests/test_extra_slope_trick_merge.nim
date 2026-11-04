import atcoder/extra/structure/slope_trick

proc absSum(centers: openArray[int], shiftBy, constant, x: int): int =
  result = constant
  for center in centers:
    result += abs(x - (center + shiftBy))

proc makeAbsSum(centers: openArray[int], shiftBy, constant: int): SlopeTrick[int] =
  result = initSlopeTrick[int]()
  for center in centers:
    result.add_abs(center)
  result.shift(shiftBy)
  result.add_all(constant)

proc mergedState(a, b: openArray[int], shiftA, shiftB, constantA, constantB: int): SlopeTrick[int] =
  result = makeAbsSum(a, shiftA, constantA)
  var other = makeAbsSum(b, shiftB, constantB)
  result.merge(other)

proc checkMerge(a, b: openArray[int], shiftA, shiftB, constantA, constantB: int) =
  let merged = mergedState(a, b, shiftA, shiftB, constantA, constantB)
  doAssert merged.len == 2 * (a.len + b.len)
  let summary = merged.query()
  var expectedMin = int.high
  var expectedLeft, expectedRight: int

  # All shifted centers in these fixtures lie strictly inside this interval.
  # Rebuild before each get: get destroys its own heaps; no copy/alias contract
  # is needed to compare the represented function at several points.
  for x in -12 .. 12:
    let expected = absSum(a, shiftA, constantA, x) + absSum(b, shiftB, constantB, x)
    var sample = mergedState(a, b, shiftA, shiftB, constantA, constantB)
    doAssert sample.get(x) == expected
    if expected < expectedMin:
      expectedMin = expected
      expectedLeft = x
      expectedRight = x
    elif expected == expectedMin:
      expectedRight = x

  doAssert summary.min_f == expectedMin
  doAssert summary.lx == expectedLeft
  doAssert summary.rx == expectedRight

# A larger donor takes the swap branch; a smaller donor takes the other branch.
# Different shifts and nonzero (also negative) constants exercise both offsets
# and min_f while the oracle remains a direct sum of absolute values.
checkMerge([-2], [-3, 1, 4], 3, -2, 5, -4)
checkMerge([-4, 0, 3], [2], -1, 3, -7, 2)
checkMerge([-2, 5], [1, 3], 2, -1, 4, 6)
checkMerge([], [1, 4], 1, 2, 6, -1)
checkMerge([-2, 5], [], -2, 7, -3, 4)
echo "OK"
