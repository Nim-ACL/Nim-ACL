import atcoder/extra/monoid/monoid
import atcoder/extra/structure/compressed_fenwicktree_2d

type
  CompressedRangeFenwickTree2D*[
      CG: CommutativeGroup
  ] = object
    s00:
      CompressedFenwickTree2D[CG]

    s10:
      CompressedFenwickTree2D[CG]

    s01:
      CompressedFenwickTree2D[CG]

    s11:
      CompressedFenwickTree2D[CG]


proc scaleByInt[
    CG: CommutativeGroup
](
    value:
      CG.value_type,
    scalar:
      int
): CG.value_type =
  var
    baseValue =
      value

    magnitude:
      uint

  if scalar < 0:
    baseValue =
      CG.inv(
        baseValue
      )

    magnitude =
      uint(
        -(scalar + 1)
      ) + 1'u
  else:
    magnitude =
      uint(
        scalar
      )

  result =
    CG.e()

  var current =
    baseValue

  while magnitude != 0'u:
    if (
      magnitude and 1'u
    ) != 0'u:
      result =
        CG.op(
          result,
          current
        )

    magnitude =
      magnitude shr 1

    if magnitude != 0'u:
      current =
        CG.op(
          current,
          current
        )


proc initCompressedRangeFenwickTree2D*[
    CG: CommutativeGroup
](
    points:
      openArray[
        CompressedFenwickPoint2D
      ],
    _:
      typedesc[CG]
): CompressedRangeFenwickTree2D[CG] =
  result.s00 =
    initCompressedFenwickTree2D(
      points,
      CG
    )

  result.s10 =
    initCompressedFenwickTree2D(
      points,
      CG
    )

  result.s01 =
    initCompressedFenwickTree2D(
      points,
      CG
    )

  result.s11 =
    initCompressedFenwickTree2D(
      points,
      CG
    )


proc addCorner[
    CG: CommutativeGroup
](
    tree:
      var CompressedRangeFenwickTree2D[CG],
    x,
    y:
      int,
    delta:
      CG.value_type
) =
  tree.s00.add(
    x,
    y,
    delta
  )

  tree.s10.add(
    x,
    y,
    scaleByInt[CG](
      delta,
      x
    )
  )

  tree.s01.add(
    x,
    y,
    scaleByInt[CG](
      delta,
      y
    )
  )

  tree.s11.add(
    x,
    y,
    scaleByInt[CG](
      scaleByInt[CG](
        delta,
        x
      ),
      y
    )
  )


proc add*[
    CG: CommutativeGroup
](
    tree:
      var CompressedRangeFenwickTree2D[CG],
    xLeft,
    xRight,
    yLower,
    yUpper:
      int,
    delta:
      CG.value_type
) =
  doAssert xLeft <= xRight
  doAssert yLower <= yUpper

  if xLeft == xRight or
     yLower == yUpper:
    return

  let inverseDelta =
    CG.inv(
      delta
    )

  tree.addCorner(
    xLeft,
    yLower,
    delta
  )

  tree.addCorner(
    xRight,
    yLower,
    inverseDelta
  )

  tree.addCorner(
    xLeft,
    yUpper,
    inverseDelta
  )

  tree.addCorner(
    xRight,
    yUpper,
    delta
  )


proc prefixSum[
    CG: CommutativeGroup
](
    tree:
      CompressedRangeFenwickTree2D[CG],
    x,
    y:
      int
): CG.value_type =
  let
    q00 =
      tree.s00.prefixSum(
        x,
        y
      )

    q10 =
      tree.s10.prefixSum(
        x,
        y
      )

    q01 =
      tree.s01.prefixSum(
        x,
        y
      )

    q11 =
      tree.s11.prefixSum(
        x,
        y
      )

    term00 =
      scaleByInt[CG](
        scaleByInt[CG](
          q00,
          x
        ),
        y
      )

    term10 =
      scaleByInt[CG](
        q10,
        y
      )

    term01 =
      scaleByInt[CG](
        q01,
        x
      )

  result =
    CG.op(
      CG.op(
        term00,
        CG.inv(
          term10
        )
      ),
      CG.op(
        CG.inv(
          term01
        ),
        q11
      )
    )


proc sum*[
    CG: CommutativeGroup
](
    tree:
      CompressedRangeFenwickTree2D[CG],
    xLeft,
    xRight,
    yLower,
    yUpper:
      int
): CG.value_type =
  doAssert xLeft <= xRight
  doAssert yLower <= yUpper

  if xLeft == xRight or
     yLower == yUpper:
    return CG.e()

  result =
    CG.op(
      CG.op(
        tree.prefixSum(
          xRight,
          yUpper
        ),
        CG.inv(
          tree.prefixSum(
            xLeft,
            yUpper
          )
        )
      ),
      CG.op(
        CG.inv(
          tree.prefixSum(
            xRight,
            yLower
          )
        ),
        tree.prefixSum(
          xLeft,
          yLower
        )
      )
    )


proc get*[
    CG: CommutativeGroup
](
    tree:
      CompressedRangeFenwickTree2D[CG],
    x,
    y:
      int
): CG.value_type =
  doAssert x < high(
    int
  )

  doAssert y < high(
    int
  )

  tree.sum(
    x,
    x + 1,
    y,
    y + 1
  )
