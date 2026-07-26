import std/unittest

import atcoder/extra/math/min_plus_convolution


proc naiveMinPlusConvolution(
    left,
    right: openArray[int64],
): seq[int64] =
  if left.len == 0 or right.len == 0:
    return @[]

  result =
    newSeq[int64](
      left.len + right.len - 1
    )

  for index in 0 ..< result.len:
    var
      initialized = false
      best: int64

    for leftIndex in 0 ..< left.len:
      let rightIndex =
        index - leftIndex

      if rightIndex < 0 or
         rightIndex >= right.len:
        continue

      let candidate =
        left[leftIndex] +
        right[rightIndex]

      if not initialized or
         candidate < best:
        initialized = true
        best = candidate

    doAssert initialized
    result[index] = best


proc nextRandom(
    state: var uint64,
): uint64 =
  state =
    state xor (
      state shl 7
    )

  state =
    state xor (
      state shr 9
    )

  state =
    state xor (
      state shl 8
    )

  state


proc randomInt(
    state: var uint64,
    low,
    high: int64,
): int64 =
  doAssert low <= high

  low +
    int64(
      nextRandom(state) mod
      uint64(high - low + 1)
    )


proc randomConvexSequence(
    state: var uint64,
    length: int,
): seq[int64] =
  if length == 0:
    return @[]

  result =
    newSeq[int64](length)

  result[0] =
    randomInt(
      state,
      -20,
      20,
    )

  var slope =
    randomInt(
      state,
      -8,
      8,
    )

  for index in 1 ..< length:
    slope +=
      randomInt(
        state,
        0,
        4,
      )

    result[index] =
      result[index - 1] +
      slope


proc randomSequence(
    state: var uint64,
    length: int,
): seq[int64] =
  result =
    newSeq[int64](length)

  for value in result.mitems:
    value =
      randomInt(
        state,
        -30,
        30,
      )


suite "Min-plus convolution convex-arbitrary":
  test "known case":
    let
      convex =
        @[0'i64, 1, 3]

      arbitrary =
        @[5'i64, 2]

    check minPlusConvolutionConvexArbitrary(
      convex,
      arbitrary,
    ) == @[5'i64, 2, 3, 5]

  test "empty input":
    let
      empty: seq[int64] = @[]
      values = @[1'i64, 2]

    check minPlusConvolutionConvexArbitrary(
      empty,
      values,
    ).len == 0

    check minPlusConvolutionConvexArbitrary(
      values,
      empty,
    ).len == 0

  test "input preservation":
    let
      convex =
        @[2'i64, 1, 1, 2, 4]

      arbitrary =
        @[7'i64, -1, 3]

      convexBefore = convex
      arbitraryBefore = arbitrary

    discard minPlusConvolutionConvexArbitrary(
      convex,
      arbitrary,
    )

    check convex == convexBefore
    check arbitrary == arbitraryBefore

  test "invalid convex input":
    expect ValueError:
      discard minPlusConvolutionConvexArbitrary(
        @[0'i64, 2, 1],
        @[0'i64],
      )

  test "random differential":
    var state =
      0x6A09E667F3BCC909'u64

    for convexLength in 0 .. 14:
      for arbitraryLength in 0 .. 14:
        for repetition in 0 ..< 12:
          discard repetition

          let
            convex =
              randomConvexSequence(
                state,
                convexLength,
              )

            arbitrary =
              randomSequence(
                state,
                arbitraryLength,
              )

            expected =
              naiveMinPlusConvolution(
                convex,
                arbitrary,
              )

            actual =
              minPlusConvolutionConvexArbitrary(
                convex,
                arbitrary,
              )

          check actual == expected


suite "Min-plus convolution complete public family":
  test "arbitrary-convex known case and validation":
    let
      arbitrary =
        @[5'i64, 2]
      convex =
        @[0'i64, 1, 3]

    check minPlusConvolutionArbitraryConvex(
      arbitrary,
      convex,
    ) == @[5'i64, 2, 3, 5]

    expect ValueError:
      discard minPlusConvolutionArbitraryConvex(
        @[0'i64],
        @[0'i64, 2, 1],
      )

  test "general known case and empty inputs":
    let
      left =
        @[3'i64, -1, 4]
      right =
        @[2'i64, 5]
      empty: seq[int64] =
        @[]

    check minPlusConvolution(
      left,
      right,
    ) == @[5'i64, 1, 4, 9]

    check minPlusConvolution(
      empty,
      right,
    ).len == 0

    check minPlusConvolution(
      left,
      empty,
    ).len == 0

  test "additional API input preservation":
    let
      arbitrary =
        @[7'i64, -1, 3]
      convex =
        @[2'i64, 1, 1, 2, 4]
      other =
        @[-4'i64, 6, 0]

      arbitraryBefore =
        arbitrary
      convexBefore =
        convex
      otherBefore =
        other

    discard minPlusConvolutionArbitraryConvex(
      arbitrary,
      convex,
    )

    discard minPlusConvolution(
      arbitrary,
      other,
    )

    check arbitrary == arbitraryBefore
    check convex == convexBefore
    check other == otherBefore

  test "representable int64 boundaries":
    let
      nearHigh =
        @[high(int64) - 10]
      positive =
        @[5'i64]

    check minPlusConvolution(
      nearHigh,
      positive,
    ) == @[high(int64) - 5]

    let
      nearLowConvex =
        @[
          low(int64) + 10,
          low(int64) + 12,
          low(int64) + 15,
        ]

    check minPlusConvolutionConvexArbitrary(
      nearLowConvex,
      positive,
    ) == naiveMinPlusConvolution(
      nearLowConvex,
      positive,
    )

    check minPlusConvolutionArbitraryConvex(
      positive,
      nearLowConvex,
    ) == naiveMinPlusConvolution(
      positive,
      nearLowConvex,
    )

  test "additional APIs randomized differential":
    var state =
      0xBB67AE8584CAA73B'u64

    for leftLength in 0 .. 12:
      for rightLength in 0 .. 12:
        for repetition in 0 ..< 10:
          discard repetition

          let
            arbitraryLeft =
              randomSequence(
                state,
                leftLength,
              )

            arbitraryRight =
              randomSequence(
                state,
                rightLength,
              )

            convexRight =
              randomConvexSequence(
                state,
                rightLength,
              )

          check minPlusConvolution(
            arbitraryLeft,
            arbitraryRight,
          ) == naiveMinPlusConvolution(
            arbitraryLeft,
            arbitraryRight,
          )

          check minPlusConvolutionArbitraryConvex(
            arbitraryLeft,
            convexRight,
          ) == naiveMinPlusConvolution(
            arbitraryLeft,
            convexRight,
          )
