import std/algorithm

import atcoder/extra/structure/wavelet_matrix


const
  StaticWaveletMatrix2DRankBits =
    sizeof(int) * 8 - 1


type
  StaticWaveletMatrix2D* =
    object
      xs:
        seq[int]
      ys:
        CompressedWaveletMatrix[
          int,
          StaticWaveletMatrix2DRankBits
        ]


proc compareStaticWaveletMatrix2DPoint(
    first,
    second:
      tuple[
        x:
          int,
        y:
          int
      ]
): int =
  if first.x < second.x:
    return -1

  if second.x < first.x:
    return 1

  if first.y < second.y:
    return -1

  if second.y < first.y:
    return 1

  0


proc initStaticWaveletMatrix2D*(
    points:
      openArray[
        tuple[
          x:
            int,
          y:
            int
        ]
      ]
): StaticWaveletMatrix2D =
  ## Builds a static multiset of two-dimensional integer points.
  ##
  ## Duplicate points are retained as distinct records.

  var sortedPoints =
    newSeq[
      tuple[
        x:
          int,
        y:
          int
      ]
    ](
      points.len
    )

  for index in 0 ..< points.len:
    sortedPoints[index] =
      points[index]

  sortedPoints.sort(
    compareStaticWaveletMatrix2DPoint
  )

  result.xs =
    newSeq[int](
      sortedPoints.len
    )

  var yValues =
    newSeq[int](
      sortedPoints.len
    )

  for index in 0 ..< sortedPoints.len:
    result.xs[index] =
      sortedPoints[index].x

    yValues[index] =
      sortedPoints[index].y

  result.ys =
    initCompressedWaveletMatrix(
      yValues,
      StaticWaveletMatrix2DRankBits,
    )


proc pointCount*(
    structure:
      StaticWaveletMatrix2D
): int =
  ## Returns the number of stored point records.

  structure.xs.len


proc xInterval(
    structure:
      StaticWaveletMatrix2D,
    xBegin,
    xEnd:
      int
): tuple[
    left,
    right:
      int
] =
  doAssert xBegin <= xEnd

  (
    lowerBound(
      structure.xs,
      xBegin,
    ),
    lowerBound(
      structure.xs,
      xEnd,
    ),
  )


proc rangeFreq*(
    structure:
      StaticWaveletMatrix2D,
    xBegin,
    xEnd,
    yBegin,
    yEnd:
      int
): int =
  ## Counts point multiplicity in
  ## [xBegin, xEnd) x [yBegin, yEnd).

  doAssert yBegin <= yEnd

  let (
    left,
    right,
  ) =
    structure.xInterval(
      xBegin,
      xEnd,
    )

  structure.ys.range_freq(
    left ..< right,
    yBegin,
    yEnd,
  )


proc kthSmallest*(
    structure:
      StaticWaveletMatrix2D,
    xBegin,
    xEnd,
    k:
      int
): int =
  ## Returns the zero-based k-th smallest y coordinate among
  ## points whose x coordinate lies in [xBegin, xEnd).

  let (
    left,
    right,
  ) =
    structure.xInterval(
      xBegin,
      xEnd,
    )

  doAssert 0 <= k
  doAssert k < right - left

  structure.ys.kth_smallest(
    left ..< right,
    k,
  )


proc kthLargest*(
    structure:
      StaticWaveletMatrix2D,
    xBegin,
    xEnd,
    k:
      int
): int =
  ## Returns the zero-based k-th largest y coordinate among
  ## points whose x coordinate lies in [xBegin, xEnd).

  let (
    left,
    right,
  ) =
    structure.xInterval(
      xBegin,
      xEnd,
    )

  doAssert 0 <= k
  doAssert k < right - left

  structure.ys.kth_largest(
    left ..< right,
    k,
  )
