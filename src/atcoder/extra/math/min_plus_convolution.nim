# Min-plus convolution where the first input is convex.
#
# The convexity precondition is checked by the current public facade.
# Both inputs are preserved and a newly allocated sequence is returned.

proc isConvex(
    values: openArray[int64],
): bool =
  if values.len <= 2:
    return true

  var previousDifference =
    values[1] -
    values[0]

  for index in 2 ..< values.len:
    let difference =
      values[index] -
      values[index - 1]

    if difference <
        previousDifference:
      return false

    previousDifference =
      difference

  true


proc solveRows(
    convex,
    arbitrary: openArray[int64],
    answer: var seq[int64],
    leftRow,
    rightRow,
    optionLeft,
    optionRight: int,
) =
  if leftRow > rightRow:
    return

  let middle =
    (leftRow + rightRow) div 2

  let minimumOption =
    max(
      optionLeft,
      max(
        0,
        middle - (convex.len - 1),
      ),
    )

  let maximumOption =
    min(
      optionRight,
      min(
        arbitrary.high,
        middle,
      ),
    )

  doAssert minimumOption <=
    maximumOption

  var bestOption =
    minimumOption

  var bestValue =
    convex[
      middle - minimumOption
    ] +
    arbitrary[minimumOption]

  for option in minimumOption + 1 ..
      maximumOption:
    let candidate =
      convex[middle - option] +
      arbitrary[option]

    if candidate < bestValue:
      bestValue =
        candidate

      bestOption =
        option

  answer[middle] =
    bestValue

  solveRows(
    convex,
    arbitrary,
    answer,
    leftRow,
    middle - 1,
    optionLeft,
    bestOption,
  )

  solveRows(
    convex,
    arbitrary,
    answer,
    middle + 1,
    rightRow,
    bestOption,
    optionRight,
  )


## Computes the min-plus convolution when the first sequence is
## discrete convex.
##
## If `n = convex.len` and `m = arbitrary.len`, the running time is
## `O(m * log(n + m) + n + m)`.
##
## All adjacent differences used by the convexity check and all candidate
## sums evaluated by the algorithm must be representable as `int64`.
proc minPlusConvolutionConvexArbitrary*(
    convex,
    arbitrary: openArray[int64],
): seq[int64] =
  if convex.len == 0 or
      arbitrary.len == 0:
    return newSeq[int64]()

  if not isConvex(convex):
    raise newException(
      ValueError,
      "the first sequence must be convex",
    )

  result =
    newSeq[int64](
      convex.len +
      arbitrary.len -
      1
    )

  solveRows(
    convex,
    arbitrary,
    result,
    0,
    result.high,
    0,
    arbitrary.high,
  )


## Computes the min-plus convolution when the second sequence is
## discrete convex.
##
## If `n = arbitrary.len` and `m = convex.len`, the running time is
## `O(n * log(n + m) + n + m)`.
##
## All adjacent differences used by the convexity check and all candidate
## sums evaluated by the algorithm must be representable as `int64`.
proc minPlusConvolutionArbitraryConvex*(
    arbitrary,
    convex: openArray[int64],
): seq[int64] =
  minPlusConvolutionConvexArbitrary(
    convex,
    arbitrary,
  )


## Computes the min-plus convolution of two arbitrary sequences.
##
## If `n = left.len` and `m = right.len`, the running time is `O(n * m)`.
##
## Every candidate sum evaluated by the algorithm must be representable
## as `int64`.
proc minPlusConvolution*(
    left,
    right: openArray[int64],
): seq[int64] =
  if left.len == 0 or
      right.len == 0:
    return newSeq[int64]()

  result =
    newSeq[int64](
      left.len +
      right.len -
      1
    )

  for outputIndex in 0 ..< result.len:
    let minimumLeftIndex =
      max(
        0,
        outputIndex -
        right.high,
      )

    let maximumLeftIndex =
      min(
        left.high,
        outputIndex,
      )

    var bestValue =
      left[minimumLeftIndex] +
      right[
        outputIndex -
        minimumLeftIndex
      ]

    var leftIndex =
      minimumLeftIndex +
      1

    while leftIndex <=
        maximumLeftIndex:
      let candidate =
        left[leftIndex] +
        right[
          outputIndex -
          leftIndex
        ]

      if candidate < bestValue:
        bestValue =
          candidate

      leftIndex.inc

    result[outputIndex] =
      bestValue
