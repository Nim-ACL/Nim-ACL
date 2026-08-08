import std/[algorithm, tables]

import atcoder/extra/monoid/monoid


type
  CompressedDualSegTree2DBuilder*[
      S;
      FM: CommutativeMonoid;
      Mapper
  ] =
    object
      points:
        seq[
          tuple[
            x:
              int,
            y:
              int,
            value:
              S
          ]
        ]


  CompressedDualSegTree2D*[
      S;
      FM: CommutativeMonoid;
      Mapper
  ] =
    object
      xs:
        seq[int]

      xSize:
        int

      ys:
        seq[
          seq[int]
        ]

      ySize:
        seq[int]

      tags:
        seq[
          seq[
            FM.value_type
          ]
        ]

      pointValues:
        Table[
          tuple[
            x:
              int,
            y:
              int
          ],
          S
        ]


proc lowerBoundInt(
    values:
      openArray[int],
    key:
      int
): int =
  var
    left =
      0

    right =
      values.len

  while left < right:
    let middle =
      (left + right) shr 1

    if values[
      middle
    ] < key:
      left =
        middle + 1
    else:
      right =
        middle

  left


proc sortUnique(
    values:
      var seq[int]
) =
  values.sort()

  var uniqueValues:
    seq[int]

  for value in values:
    if uniqueValues.len == 0 or uniqueValues[^1] != value:
      uniqueValues.add(
        value
      )

  values =
    uniqueValues


proc initCompressedDualSegTree2DBuilder*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    _:
      typedesc[S],
    _:
      typedesc[FM],
    _:
      typedesc[Mapper]
): CompressedDualSegTree2DBuilder[
    S,
    FM,
    Mapper
] =
  discard


proc addPoint*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    builder:
      var CompressedDualSegTree2DBuilder[
        S,
        FM,
        Mapper
      ],
    x,
    y:
      int,
    value:
      S
) =
  builder.points.add(
    (
      x:
        x,
      y:
        y,
      value:
        value,
    )
  )


proc build*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    builder:
      CompressedDualSegTree2DBuilder[
        S,
        FM,
        Mapper
      ]
): CompressedDualSegTree2D[
    S,
    FM,
    Mapper
] =
  result.pointValues =
    initTable[
      tuple[
        x:
          int,
        y:
          int
      ],
      S
    ]()

  for point in builder.points:
    let key =
      (
        x:
          point.x,
        y:
          point.y,
      )

    if result.pointValues.hasKey(
      key
    ):
      raise newException(
        ValueError,
        "duplicate registered coordinate",
      )

    result.pointValues[
      key
    ] =
      point.value

    result.xs.add(
      point.x
    )

  result.xs.sortUnique()

  result.xSize =
    1

  while result.xSize < result.xs.len:
    result.xSize =
      result.xSize shl 1

  result.ys =
    newSeq[
      seq[int]
    ](
      2 * result.xSize
    )

  result.ySize =
    newSeq[int](
      2 * result.xSize
    )

  result.tags =
    newSeq[
      seq[
        FM.value_type
      ]
    ](
      2 * result.xSize
    )

  for point in builder.points:
    let xRank =
      result.xs.lowerBoundInt(
        point.x
      )

    var xNode =
      result.xSize + xRank

    while xNode > 0:
      result.ys[
        xNode
      ].add(
        point.y
      )

      xNode =
        xNode shr 1

  for xNode in 1 ..< 2 * result.xSize:
    result.ys[
      xNode
    ].sortUnique()

    var size =
      1

    while size < result.ys[
      xNode
    ].len:
      size =
        size shl 1

    result.ySize[
      xNode
    ] =
      size

    result.tags[
      xNode
    ] =
      newSeq[
        FM.value_type
      ](
        2 * size
      )

    for index in 0 ..< result.tags[
      xNode
    ].len:
      result.tags[
        xNode
      ][
        index
      ] =
        FM.e()


proc pointCount*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    tree:
      CompressedDualSegTree2D[
        S,
        FM,
        Mapper
      ]
): int =
  tree.pointValues.len


proc containsPoint*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    tree:
      CompressedDualSegTree2D[
        S,
        FM,
        Mapper
      ],
    x,
    y:
      int
): bool =
  tree.pointValues.hasKey(
    (
      x:
        x,
      y:
        y,
    )
  )


proc applyY[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    tree:
      var CompressedDualSegTree2D[
        S,
        FM,
        Mapper
      ],
    xNode,
    yBegin,
    yEnd:
      int,
    action:
      FM.value_type
) =
  var
    left =
      yBegin + tree.ySize[
          xNode
        ]

    right =
      yEnd + tree.ySize[
          xNode
        ]

  while left < right:
    if (
      left and 1
    ) != 0:
      tree.tags[
        xNode
      ][
        left
      ] =
        FM.op(
          tree.tags[
            xNode
          ][
            left
          ],
          action,
        )

      inc left

    if (
      right and 1
    ) != 0:
      dec right

      tree.tags[
        xNode
      ][
        right
      ] =
        FM.op(
          tree.tags[
            xNode
          ][
            right
          ],
          action,
        )

    left =
      left shr 1

    right =
      right shr 1


proc apply*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    tree:
      var CompressedDualSegTree2D[
        S,
        FM,
        Mapper
      ],
    xLeft,
    xRight,
    yLower,
    yUpper:
      int,
    action:
      FM.value_type
) =
  doAssert xLeft <= xRight
  doAssert yLower <= yUpper

  if xLeft == xRight or yLower == yUpper:
    return

  var
    left =
      tree.xs.lowerBoundInt(
        xLeft
      ) + tree.xSize

    right =
      tree.xs.lowerBoundInt(
        xRight
      ) + tree.xSize

  while left < right:
    if (
      left and 1
    ) != 0:
      let
        yBegin =
          tree.ys[
            left
          ].lowerBoundInt(
            yLower
          )

        yEnd =
          tree.ys[
            left
          ].lowerBoundInt(
            yUpper
          )

      tree.applyY(
        left,
        yBegin,
        yEnd,
        action,
      )

      inc left

    if (
      right and 1
    ) != 0:
      dec right

      let
        yBegin =
          tree.ys[
            right
          ].lowerBoundInt(
            yLower
          )

        yEnd =
          tree.ys[
            right
          ].lowerBoundInt(
            yUpper
          )

      tree.applyY(
        right,
        yBegin,
        yEnd,
        action,
      )

    left =
      left shr 1

    right =
      right shr 1


proc get*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    tree:
      CompressedDualSegTree2D[
        S,
        FM,
        Mapper
      ],
    x,
    y:
      int
): S =
  mixin mapping

  let key =
    (
      x:
        x,
      y:
        y,
    )

  if not tree.pointValues.hasKey(
    key
  ):
    raise newException(
      ValueError,
      "point is not registered",
    )

  let xRank =
    tree.xs.lowerBoundInt(
      x
    )

  var
    xNode =
      tree.xSize + xRank

    accumulatedAction =
      FM.e()

  while xNode > 0:
    let yRank =
      tree.ys[
        xNode
      ].lowerBoundInt(
        y
      )

    doAssert yRank < tree.ys[
      xNode
    ].len

    doAssert tree.ys[
      xNode
    ][
      yRank
    ] == y

    var yNode =
      tree.ySize[
        xNode
      ] + yRank

    while yNode > 0:
      accumulatedAction =
        FM.op(
          accumulatedAction,
          tree.tags[
            xNode
          ][
            yNode
          ],
        )

      yNode =
        yNode shr 1

    xNode =
      xNode shr 1

  mapping(
    Mapper,
    accumulatedAction,
    tree.pointValues[
      key
    ],
  )


proc `[]`*[
    S;
    FM: CommutativeMonoid;
    Mapper
](
    tree:
      CompressedDualSegTree2D[
        S,
        FM,
        Mapper
      ],
    x,
    y:
      int
): S =
  tree.get(
    x,
    y,
  )
