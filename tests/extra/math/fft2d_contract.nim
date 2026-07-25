import atcoder/modint
import atcoder/extra/math/formal_power_series
import atcoder/extra/math/ntt
import atcoder/extra/math/fft2d

type mint = modint998244353

proc makeMatrix(
    rows: seq[seq[int]],
): seq[FormalPowerSeries[mint]] =
  result = newSeq[FormalPowerSeries[mint]](rows.len)

  for i in 0 ..< rows.len:
    result[i] = initFormalPowerSeries[mint](rows[i])

proc assertSame(
    actual,
    expected: seq[FormalPowerSeries[mint]],
) =
  doAssert actual.len == expected.len

  for i in 0 ..< expected.len:
    doAssert actual[i].len == expected[i].len

    for j in 0 ..< expected[i].len:
      doAssert actual[i][j] == expected[i][j]

proc assertValues(
    actual: seq[FormalPowerSeries[mint]],
    expected: seq[seq[int]],
) =
  doAssert actual.len == expected.len

  for i in 0 ..< expected.len:
    doAssert actual[i].len == expected[i].len

    for j in 0 ..< expected[i].len:
      doAssert actual[i][j] == mint(expected[i][j])

block emptyInputs:
  let emptyMatrix =
    newSeq[FormalPowerSeries[mint]](0)

  doAssert multiply2d_naive(
    emptyMatrix,
    emptyMatrix,
  ).len == 0

  doAssert multiply2d_partially_naive(
    emptyMatrix,
    emptyMatrix,
  ).len == 0

  doAssert multiply2d(
    emptyMatrix,
    emptyMatrix,
  ).len == 0

  var emptyRowMatrix =
    newSeq[FormalPowerSeries[mint]](1)

  emptyRowMatrix[0] =
    initFormalPowerSeries[mint](0)

  doAssert multiply2d(
    emptyRowMatrix,
    emptyRowMatrix,
  ).len == 0

block exactSmallConvolution:
  let a = makeMatrix(@[
    @[1, 2],
    @[3, 4],
  ])

  let b = makeMatrix(@[
    @[5, 6],
    @[7, 8],
  ])

  let expected = makeMatrix(@[
    @[5, 16, 12],
    @[22, 60, 40],
    @[21, 52, 32],
  ])

  assertSame(
    multiply2d_naive(a, b),
    expected,
  )

  assertSame(
    multiply2d_partially_naive(a, b),
    expected,
  )

  assertSame(
    multiply2d(a, b),
    expected,
  )

block transformRoundTrip:
  let expected = @[
    @[1, 2, 3, 4],
    @[0, 0, 0, 0],
    @[5, 6, 7, 8],
    @[9, 10, 11, 12],
  ]

  var values = makeMatrix(expected)

  fft2d(values)
  ifft2d(values)

  assertValues(values, expected)

block deterministicEquivalence:
  var aRows = newSeq[seq[int]](7)
  var bRows = newSeq[seq[int]](7)

  for i in 0 ..< 7:
    aRows[i] = newSeq[int](7)
    bRows[i] = newSeq[int](7)

    for j in 0 ..< 7:
      aRows[i][j] =
        ((i * 7 + j) mod 11) - 5

      bRows[i][j] =
        ((i * 5 + j * 3) mod 13) - 6

  let a = makeMatrix(aRows)
  let b = makeMatrix(bRows)
  let expected = multiply2d_naive(a, b)

  assertSame(
    multiply2d_partially_naive(a, b),
    expected,
  )

  assertSame(
    multiply2d(a, b),
    expected,
  )

echo "FFT2D_CONTRACT_OK"


# NIM_ACL_FFT2D_FOCUSED_EXTENSION_START

import atcoder/modint
import atcoder/extra/math/formal_power_series
import atcoder/extra/math/ntt

type
  FFT2DExtMint =
    modint998244353

proc fft2dExtMakeMatrix(
    rows:
      seq[
        seq[
          int
        ]
      ]
): seq[
    FormalPowerSeries[
      FFT2DExtMint
    ]
] =
  result =
    newSeq[
      FormalPowerSeries[
        FFT2DExtMint
      ]
    ](
      rows.len
    )

  for row in 0 ..< rows.len:
    result[row] =
      initFormalPowerSeries[
        FFT2DExtMint
      ](
        rows[row]
      )

proc fft2dExtZeroMatrix(
    height,
    width:
      int
): seq[
    FormalPowerSeries[
      FFT2DExtMint
    ]
] =
  result =
    newSeq[
      FormalPowerSeries[
        FFT2DExtMint
      ]
    ](
      height
    )

  for row in 0 ..< height:
    result[row] =
      initFormalPowerSeries[
        FFT2DExtMint
      ](
        width
      )

proc fft2dExtCloneMatrix(
    source:
      seq[
        FormalPowerSeries[
          FFT2DExtMint
        ]
      ]
): seq[
    FormalPowerSeries[
      FFT2DExtMint
    ]
] =
  result =
    newSeq[
      FormalPowerSeries[
        FFT2DExtMint
      ]
    ](
      source.len
    )

  for row in 0 ..< source.len:
    result[row] =
      initFormalPowerSeries[
        FFT2DExtMint
      ](
        source[row].len
      )

    for col in 0 ..< source[row].len:
      result[row][col] =
        source[row][col]

proc fft2dExtAssertSame(
    actual,
    expected:
      seq[
        FormalPowerSeries[
          FFT2DExtMint
        ]
      ]
) =
  doAssert actual.len ==
    expected.len

  for row in 0 ..< expected.len:
    doAssert actual[row].len ==
      expected[row].len

    for col in 0 ..< expected[row].len:
      doAssert actual[row][col] ==
        expected[row][col]

proc fft2dExtAssertValues(
    actual:
      seq[
        FormalPowerSeries[
          FFT2DExtMint
        ]
      ],
    expected:
      seq[
        seq[
          int
        ]
      ]
) =
  doAssert actual.len ==
    expected.len

  for row in 0 ..< expected.len:
    doAssert actual[row].len ==
      expected[row].len

    for col in 0 ..< expected[row].len:
      doAssert actual[row][col] ==
        FFT2DExtMint(
          expected[row][col]
        )

proc fft2dExtNextState(
    state:
      var uint64
): uint64 =
  state =
    state * 6364136223846793005'u64 +
    1442695040888963407'u64

  state

proc fft2dExtNextInt(
    state:
      var uint64,
    bound:
      int
): int =
  doAssert bound > 0

  int(state.fft2dExtNextState mod uint64(bound))

proc fft2dExtDeterministicMatrix(
    height,
    width,
    seed:
      int
): seq[
    FormalPowerSeries[
      FFT2DExtMint
    ]
] =
  result =
    fft2dExtZeroMatrix(
      height,
      width,
    )

  for row in 0 ..< height:
    for col in 0 ..< width:
      if (
        row * 13 +
        col * 17 +
        seed
      ) mod 19 < 3:
        result[row][col] =
          FFT2DExtMint(
            (
              row * 7 +
              col * 5 +
              seed
            ) mod 23 - 11
          )

block fft2dExtTransformRoundTrip:
  for dimensions in @[
    (height: 1, width: 1),
    (height: 1, width: 8),
    (height: 8, width: 1),
    (height: 2, width: 4),
    (height: 4, width: 2),
    (height: 4, width: 8),
    (height: 8, width: 4),
    (height: 8, width: 8),
  ]:
    var expected =
      newSeq[
        seq[
          int
        ]
      ](
        dimensions.height
      )

    for row in 0 ..< dimensions.height:
      expected[row] =
        newSeq[int](
          dimensions.width
        )

      for col in 0 ..< dimensions.width:
        expected[row][col] =
          (
            row * 17 +
            col * 11 +
            row * col * 3
          ) mod 29 - 14

    var transformed =
      fft2dExtMakeMatrix(
        expected
      )

    fft2d(
      transformed
    )

    ifft2d(
      transformed
    )

    fft2dExtAssertValues(
      transformed,
      expected,
    )

  var zeroWidth =
    fft2dExtZeroMatrix(
      4,
      0,
    )

  fft2d(
    zeroWidth
  )

  ifft2d(
    zeroWidth
  )

  doAssert zeroWidth.len == 4

  for row in zeroWidth:
    doAssert row.len == 0

block fft2dExtRandomConvolutionDifferential:
  var state =
    20260725'u64

  var caseCount =
    0

  for caseIndex in 0 ..< 96:
    let
      heightA =
        state.fft2dExtNextInt(8) + 1
      widthA =
        state.fft2dExtNextInt(8) + 1
      heightB =
        state.fft2dExtNextInt(8) + 1
      widthB =
        state.fft2dExtNextInt(8) + 1

    var rowsA =
      newSeq[
        seq[
          int
        ]
      ](
        heightA
      )

    var rowsB =
      newSeq[
        seq[
          int
        ]
      ](
        heightB
      )

    for row in 0 ..< heightA:
      rowsA[row] =
        newSeq[int](
          widthA
        )

      for col in 0 ..< widthA:
        rowsA[row][col] =
          state.fft2dExtNextInt(21) - 10

    for row in 0 ..< heightB:
      rowsB[row] =
        newSeq[int](
          widthB
        )

      for col in 0 ..< widthB:
        rowsB[row][col] =
          state.fft2dExtNextInt(21) - 10

    let
      matrixA =
        fft2dExtMakeMatrix(
          rowsA
        )
      matrixB =
        fft2dExtMakeMatrix(
          rowsB
        )
      expected =
        multiply2d_naive(
          matrixA,
          matrixB,
        )
      partiallyNaive =
        multiply2d_partially_naive(
          matrixA,
          matrixB,
        )
      adaptive =
        multiply2d(
          matrixA,
          matrixB,
        )

    fft2dExtAssertSame(
      partiallyNaive,
      expected,
    )

    fft2dExtAssertSame(
      adaptive,
      expected,
    )

    caseCount.inc

    discard caseIndex

  doAssert caseCount == 96

block fft2dExtAlgorithmBranches:
  for branchCase in @[
    (
      heightA: 2,
      widthA: 2,
      heightB: 3,
      widthB: 3,
      seed: 1,
      checkPartial: true,
    ),
    (
      heightA: 7,
      widthA: 8,
      heightB: 7,
      widthB: 8,
      seed: 2,
      checkPartial: true,
    ),
    (
      heightA: 2,
      widthA: 40,
      heightB: 2,
      widthB: 40,
      seed: 3,
      checkPartial: true,
    ),
    (
      heightA: 41,
      widthA: 3,
      heightB: 41,
      widthB: 3,
      seed: 4,
      checkPartial: false,
    ),
    (
      heightA: 3,
      widthA: 41,
      heightB: 3,
      widthB: 41,
      seed: 5,
      checkPartial: true,
    ),
    (
      heightA: 41,
      widthA: 41,
      heightB: 41,
      widthB: 41,
      seed: 6,
      checkPartial: false,
    ),
  ]:
    let
      matrixA =
        fft2dExtDeterministicMatrix(
          branchCase.heightA,
          branchCase.widthA,
          branchCase.seed,
        )
      matrixB =
        fft2dExtDeterministicMatrix(
          branchCase.heightB,
          branchCase.widthB,
          branchCase.seed + 31,
        )
      expected =
        multiply2d_naive(
          matrixA,
          matrixB,
        )
      adaptive =
        multiply2d(
          matrixA,
          matrixB,
        )

    fft2dExtAssertSame(
      adaptive,
      expected,
    )

    if branchCase.checkPartial:
      let partiallyNaive =
        multiply2d_partially_naive(
          matrixA,
          matrixB,
        )

      fft2dExtAssertSame(
        partiallyNaive,
        expected,
      )

block fft2dExtInputImmutabilityAndCommutativity:
  let
    matrixA =
      fft2dExtDeterministicMatrix(
        9,
        9,
        7,
      )
    matrixB =
      fft2dExtDeterministicMatrix(
        8,
        7,
        8,
      )
    originalA =
      fft2dExtCloneMatrix(
        matrixA
      )
    originalB =
      fft2dExtCloneMatrix(
        matrixB
      )

  let first =
    multiply2d(
      matrixA,
      matrixB,
    )

  fft2dExtAssertSame(
    matrixA,
    originalA,
  )

  fft2dExtAssertSame(
    matrixB,
    originalB,
  )

  discard multiply2d_partially_naive(
    matrixA,
    matrixB,
  )

  fft2dExtAssertSame(
    matrixA,
    originalA,
  )

  fft2dExtAssertSame(
    matrixB,
    originalB,
  )

  let second =
    multiply2d(
      matrixB,
      matrixA,
    )

  fft2dExtAssertSame(
    first,
    second,
  )

block fft2dExtRejectionAndEmpty:
  let emptyMatrix =
    newSeq[
      FormalPowerSeries[
        FFT2DExtMint
      ]
    ]()

  doAssert multiply2d_naive(
    emptyMatrix,
    emptyMatrix,
  ).len == 0

  doAssert multiply2d_partially_naive(
    emptyMatrix,
    emptyMatrix,
  ).len == 0

  doAssert multiply2d(
    emptyMatrix,
    emptyMatrix,
  ).len == 0

  var emptyTransform =
    newSeq[
      FormalPowerSeries[
        FFT2DExtMint
      ]
    ]()

  doAssertRaises(
    IndexDefect
  ):
    fft2d(
      emptyTransform
    )

  var invalidHeight =
    fft2dExtZeroMatrix(
      3,
      4,
    )

  doAssertRaises(
    AssertionDefect
  ):
    fft2d(
      invalidHeight
    )

  var invalidWidth =
    fft2dExtZeroMatrix(
      4,
      3,
    )

  doAssertRaises(
    AssertionDefect
  ):
    fft2d(
      invalidWidth
    )

  let
    ragged =
      fft2dExtMakeMatrix(
        @[
          @[1, 2, 3],
          @[4, 5],
        ]
      )
    valid =
      fft2dExtMakeMatrix(
        @[
          @[1],
        ]
      )

  doAssertRaises(
    AssertionDefect
  ):
    discard multiply2d_naive(
      ragged,
      valid,
    )

  doAssertRaises(
    AssertionDefect
  ):
    discard multiply2d_partially_naive(
      ragged,
      valid,
    )

  doAssertRaises(
    AssertionDefect
  ):
    discard multiply2d(
      ragged,
      valid,
    )

echo "FFT2D_EXTENDED_CONTRACT_OK"

# NIM_ACL_FFT2D_FOCUSED_EXTENSION_END
