when not declared ATCODER_EXTRA_STRUCTURE_OFFLINE_RECTANGLE_ADD_POINT_GET_HPP:
  const ATCODER_EXTRA_STRUCTURE_OFFLINE_RECTANGLE_ADD_POINT_GET_HPP* = 1

  import atcoder/extra/monoid/monoid
  import atcoder/extra/structure/compressed_dual_fenwicktree_2d

  type
    OfflineRectangleAddPointGetEventKind =
      enum
        rectangleAddEvent,
        pointQueryEvent

    OfflineRectangleAddPointGetEvent[
        CG: CommutativeGroup
    ] =
      object
        case kind:
          OfflineRectangleAddPointGetEventKind
        of rectangleAddEvent:
          xLeft, xRight, yLower, yUpper:
            int
          weight:
            CG.value_type
        of pointQueryEvent:
          x, y:
            int
          queryIndex:
            int

    OfflineRectangleAddPointGet*[
        CG: CommutativeGroup
    ] =
      object
        initialRectangles:
          seq[
            tuple[
              xLeft, xRight, yLower, yUpper:
                int,
              weight:
                CG.value_type
            ]
          ]
        events:
          seq[
            OfflineRectangleAddPointGetEvent[
              CG
            ]
          ]
        queryCountValue:
          int

  proc initOfflineRectangleAddPointGet*[
      CG: CommutativeGroup
  ](
      initialRectangles:
        seq[
          tuple[
            xLeft, xRight, yLower, yUpper:
              int,
            weight:
              CG.value_type
          ]
        ],
      _:
        typedesc[
          CG
        ]
  ): OfflineRectangleAddPointGet[
      CG
  ] =
    ## Constructs an offline rectangle-add and point-get
    ## event solver.
    ##
    ## Initial rectangles are active before the first
    ## registered event.
    result.initialRectangles =
      newSeq[
        tuple[
          xLeft, xRight, yLower, yUpper:
            int,
          weight:
            CG.value_type
        ]
      ](
        initialRectangles.len
      )

    for index in 0 ..<
        initialRectangles.len:
      let rectangle =
        initialRectangles[
          index
        ]

      doAssert rectangle.xLeft <=
        rectangle.xRight
      doAssert rectangle.yLower <=
        rectangle.yUpper

      result.initialRectangles[
        index
      ] =
        rectangle

  proc addRectangle*[
      CG: CommutativeGroup
  ](
      solver:
        var OfflineRectangleAddPointGet[
          CG
        ],
      xLeft, xRight, yLower, yUpper:
        int,
      weight:
        CG.value_type
  ) =
    doAssert xLeft <= xRight
    doAssert yLower <= yUpper

    solver.events.add(
      OfflineRectangleAddPointGetEvent[
        CG
      ](
        kind:
          rectangleAddEvent,
        xLeft:
          xLeft,
        xRight:
          xRight,
        yLower:
          yLower,
        yUpper:
          yUpper,
        weight:
          weight,
      )
    )

  proc addPointQuery*[
      CG: CommutativeGroup
  ](
      solver:
        var OfflineRectangleAddPointGet[
          CG
        ],
      x, y:
        int
  ): int =
    result =
      solver.queryCountValue

    solver.queryCountValue.inc
    solver.events.add(
      OfflineRectangleAddPointGetEvent[
        CG
      ](
        kind:
          pointQueryEvent,
        x:
          x,
        y:
          y,
        queryIndex:
          result,
      )
    )

  proc queryCount*[
      CG: CommutativeGroup
  ](
      solver:
        OfflineRectangleAddPointGet[
          CG
        ]
  ): int {.inline.} =
    solver.queryCountValue

  proc solve*[
      CG: CommutativeGroup
  ](
      solver:
        OfflineRectangleAddPointGet[
          CG
        ]
  ): seq[
      CG.value_type
  ] =
    ## Returns answers in point-query registration order.
    ##
    ## Each query observes the initial rectangles and only
    ## rectangle-add events registered before that query.
    ##
    ## solve is repeatable and does not mutate the event
    ## stream.
    var builder =
      initCompressedDualFenwickTree2DBuilder()

    for rectangle in
        solver.initialRectangles:
      builder.registerRectangle(
        rectangle.xLeft,
        rectangle.xRight,
        rectangle.yLower,
        rectangle.yUpper,
      )

    for event in solver.events:
      if event.kind ==
          rectangleAddEvent:
        builder.registerRectangle(
          event.xLeft,
          event.xRight,
          event.yLower,
          event.yUpper,
        )

    var tree =
      builder.build(
        CG
      )

    for rectangle in
        solver.initialRectangles:
      tree.add(
        rectangle.xLeft,
        rectangle.xRight,
        rectangle.yLower,
        rectangle.yUpper,
        rectangle.weight,
      )

    result =
      newSeq[
        CG.value_type
      ](
        solver.queryCountValue
      )

    for event in solver.events:
      case event.kind
      of rectangleAddEvent:
        tree.add(
          event.xLeft,
          event.xRight,
          event.yLower,
          event.yUpper,
          event.weight,
        )
      of pointQueryEvent:
        result[
          event.queryIndex
        ] =
          tree.get(
            event.x,
            event.y,
          )
