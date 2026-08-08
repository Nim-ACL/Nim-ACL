when not declared ATCODER_EXTRA_STRUCTURE_OFFLINE_RECTANGLE_ADD_RECTANGLE_SUM_HPP:
  const ATCODER_EXTRA_STRUCTURE_OFFLINE_RECTANGLE_ADD_RECTANGLE_SUM_HPP* = 1

  import atcoder/extra/monoid/monoid
  import atcoder/extra/structure/offline_point_add_rectangle_sum

  type
    OfflineRectangleAddRectangleSumEventKind =
      enum
        rectangleAddEvent,
        rectangleQueryEvent

    OfflineRectangleAddRectangleSumEvent[
        CG: CommutativeGroup
    ] =
      object
        xLeft, xRight, yLower, yUpper:
          int
        case kind:
          OfflineRectangleAddRectangleSumEventKind
        of rectangleAddEvent:
          weight:
            CG.value_type
        of rectangleQueryEvent:
          queryIndex:
            int

    OfflineRectangleAddRectangleSum*[
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
            OfflineRectangleAddRectangleSumEvent[
              CG
            ]
          ]
        queryCountValue:
          int

    OfflineRectangleAddRectangleSumCoefficient[
        CG: CommutativeGroup
    ] =
      object
        c00:
          CG.value_type
        c10:
          CG.value_type
        c01:
          CG.value_type
        c11:
          CG.value_type

    OfflineRectangleAddRectangleSumCoefficientOps[
        CG: CommutativeGroup
    ] =
      object

    OfflineRectangleAddRectangleSumCoefficientPoint[
        CG: CommutativeGroup
    ] =
      tuple[
        x:
          int,
        y:
          int,
        weight:
          OfflineRectangleAddRectangleSumCoefficient[
            CG
          ]
      ]

    OfflineRectangleAddRectangleSumQueryPlan =
      object
        xLeft, xRight, yLower, yUpper:
          int
        rightUpperQuery:
          int
        leftUpperQuery:
          int
        rightLowerQuery:
          int
        leftLowerQuery:
          int

  proc zero[
      CG: CommutativeGroup
  ](
      _:
        typedesc[
          OfflineRectangleAddRectangleSumCoefficientOps[
            CG
          ]
        ]
  ): OfflineRectangleAddRectangleSumCoefficient[
      CG
  ] =
    result.c00 =
      CG.e()
    result.c10 =
      CG.e()
    result.c01 =
      CG.e()
    result.c11 =
      CG.e()

  proc add[
      CG: CommutativeGroup
  ](
      _:
        typedesc[
          OfflineRectangleAddRectangleSumCoefficientOps[
            CG
          ]
        ],
      a,
      b:
        OfflineRectangleAddRectangleSumCoefficient[
          CG
        ]
  ): OfflineRectangleAddRectangleSumCoefficient[
      CG
  ] =
    result.c00 =
      CG.op(
        a.c00,
        b.c00,
      )
    result.c10 =
      CG.op(
        a.c10,
        b.c10,
      )
    result.c01 =
      CG.op(
        a.c01,
        b.c01,
      )
    result.c11 =
      CG.op(
        a.c11,
        b.c11,
      )

  proc sub[
      CG: CommutativeGroup
  ](
      _:
        typedesc[
          OfflineRectangleAddRectangleSumCoefficientOps[
            CG
          ]
        ],
      a,
      b:
        OfflineRectangleAddRectangleSumCoefficient[
          CG
        ]
  ): OfflineRectangleAddRectangleSumCoefficient[
      CG
  ] =
    result.c00 =
      CG.op(
        a.c00,
        CG.inv(
          b.c00
        ),
      )
    result.c10 =
      CG.op(
        a.c10,
        CG.inv(
          b.c10
        ),
      )
    result.c01 =
      CG.op(
        a.c01,
        CG.inv(
          b.c01
        ),
      )
    result.c11 =
      CG.op(
        a.c11,
        CG.inv(
          b.c11
        ),
      )

  proc coordinateRank(
      x:
        int
  ): uint {.inline.} =
    let half =
      uint(
        high(
          int
        )
      ) + 1'u

    if x < 0:
      result =
        uint(
          x - low(
            int
          )
        )
    else:
      result =
        half + uint(
          x
        )

  proc naturalScale[
      CG: CommutativeGroup
  ](
      value:
        CG.value_type,
      count:
        uint,
      _:
        typedesc[
          CG
        ]
  ): CG.value_type =
    result =
      CG.e()

    var base =
      value

    var remaining =
      count

    while remaining != 0'u:
      if (
        remaining and 1'u
      ) != 0'u:
        result =
          CG.op(
            result,
            base,
          )

      remaining =
        remaining shr 1

      if remaining != 0'u:
        base =
          CG.op(
            base,
            base,
          )

  proc coefficientAt[
      CG: CommutativeGroup
  ](
      x,
      y:
        int,
      value:
        CG.value_type,
      _:
        typedesc[
          CG
        ]
  ): OfflineRectangleAddRectangleSumCoefficient[
      CG
  ] =
    let xRank =
      coordinateRank(
        x
      )

    let yRank =
      coordinateRank(
        y
      )

    result.c00 =
      value

    result.c10 =
      naturalScale[
        CG
      ](
        value,
        xRank,
        CG,
      )

    result.c01 =
      naturalScale[
        CG
      ](
        value,
        yRank,
        CG,
      )

    result.c11 =
      naturalScale[
        CG
      ](
        result.c01,
        xRank,
        CG,
      )

  proc addRectangleCorners[
      CG: CommutativeGroup
  ](
      pointSolver:
        var OfflinePointAddRectangleSum[
          OfflineRectangleAddRectangleSumCoefficient[
            CG
          ],
          OfflineRectangleAddRectangleSumCoefficientOps[
            CG
          ]
        ],
      xLeft, xRight, yLower, yUpper:
        int,
      weight:
        CG.value_type,
      _:
        typedesc[
          CG
        ]
  ) =
    if xLeft == xRight or
        yLower == yUpper:
      return

    let inverseWeight =
      CG.inv(
        weight
      )

    pointSolver.addPoint(
      xLeft,
      yLower,
      coefficientAt[
        CG
      ](
        xLeft,
        yLower,
        weight,
        CG,
      ),
    )

    pointSolver.addPoint(
      xLeft,
      yUpper,
      coefficientAt[
        CG
      ](
        xLeft,
        yUpper,
        inverseWeight,
        CG,
      ),
    )

    pointSolver.addPoint(
      xRight,
      yLower,
      coefficientAt[
        CG
      ](
        xRight,
        yLower,
        inverseWeight,
        CG,
      ),
    )

    pointSolver.addPoint(
      xRight,
      yUpper,
      coefficientAt[
        CG
      ](
        xRight,
        yUpper,
        weight,
        CG,
      ),
    )

  proc prefixValue[
      CG: CommutativeGroup
  ](
      coefficients:
        OfflineRectangleAddRectangleSumCoefficient[
          CG
        ],
      xEnd,
      yEnd:
        int,
      _:
        typedesc[
          CG
        ]
  ): CG.value_type =
    let xRank =
      coordinateRank(
        xEnd
      )

    let yRank =
      coordinateRank(
        yEnd
      )

    let scaled00 =
      naturalScale[
        CG
      ](
        naturalScale[
          CG
        ](
          coefficients.c00,
          yRank,
          CG,
        ),
        xRank,
        CG,
      )

    let scaled10 =
      naturalScale[
        CG
      ](
        coefficients.c10,
        yRank,
        CG,
      )

    let scaled01 =
      naturalScale[
        CG
      ](
        coefficients.c01,
        xRank,
        CG,
      )

    result =
      CG.op(
        scaled00,
        CG.inv(
          scaled10
        ),
      )

    result =
      CG.op(
        result,
        CG.inv(
          scaled01
        ),
      )

    result =
      CG.op(
        result,
        coefficients.c11,
      )

  proc initOfflineRectangleAddRectangleSum*[
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
  ): OfflineRectangleAddRectangleSum[
      CG
  ] =
    ## Constructs an offline rectangle-add and rectangle-sum
    ## event solver over integer lattice unit cells.
    ##
    ## A half-open rectangle [xLeft, xRight) x
    ## [yLower, yUpper) denotes unit cells with integer
    ## coordinates xLeft <= x < xRight and
    ## yLower <= y < yUpper.
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
        var OfflineRectangleAddRectangleSum[
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
      OfflineRectangleAddRectangleSumEvent[
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

  proc addRectangleQuery*[
      CG: CommutativeGroup
  ](
      solver:
        var OfflineRectangleAddRectangleSum[
          CG
        ],
      xLeft, xRight, yLower, yUpper:
        int
  ): int =
    doAssert xLeft <= xRight
    doAssert yLower <= yUpper

    result =
      solver.queryCountValue

    solver.queryCountValue.inc

    solver.events.add(
      OfflineRectangleAddRectangleSumEvent[
        CG
      ](
        kind:
          rectangleQueryEvent,
        xLeft:
          xLeft,
        xRight:
          xRight,
        yLower:
          yLower,
        yUpper:
          yUpper,
        queryIndex:
          result,
      )
    )

  proc queryCount*[
      CG: CommutativeGroup
  ](
      solver:
        OfflineRectangleAddRectangleSum[
          CG
        ]
  ): int {.inline.} =
    solver.queryCountValue

  proc solve*[
      CG: CommutativeGroup
  ](
      solver:
        OfflineRectangleAddRectangleSum[
          CG
        ]
  ): seq[
      CG.value_type
  ] =
    bind zero, add, sub

    ## Returns rectangle-sum answers in query-registration order.
    ##
    ## Each query observes the initial rectangles and only
    ## rectangle-add events registered before that query.
    ##
    ## solve is repeatable and does not mutate the event stream.
    var initialPoints =
      newSeq[
        OfflineRectangleAddRectangleSumCoefficientPoint[
          CG
        ]
      ]()

    var pointSolver =
      initOfflinePointAddRectangleSum[
        OfflineRectangleAddRectangleSumCoefficient[
          CG
        ],
        OfflineRectangleAddRectangleSumCoefficientOps[
          CG
        ]
      ](
        initialPoints,
        OfflineRectangleAddRectangleSumCoefficientOps[
          CG
        ],
      )

    for rectangle in
        solver.initialRectangles:
      addRectangleCorners[
        CG
      ](
        pointSolver,
        rectangle.xLeft,
        rectangle.xRight,
        rectangle.yLower,
        rectangle.yUpper,
        rectangle.weight,
        CG,
      )

    var queryPlans =
      newSeq[
        OfflineRectangleAddRectangleSumQueryPlan
      ](
        solver.queryCountValue
      )

    for event in solver.events:
      case event.kind
      of rectangleAddEvent:
        addRectangleCorners[
          CG
        ](
          pointSolver,
          event.xLeft,
          event.xRight,
          event.yLower,
          event.yUpper,
          event.weight,
          CG,
        )

      of rectangleQueryEvent:
        let rightUpperQuery =
          pointSolver.addRectangleQuery(
            low(
              int
            ),
            event.xRight,
            low(
              int
            ),
            event.yUpper,
          )

        let leftUpperQuery =
          pointSolver.addRectangleQuery(
            low(
              int
            ),
            event.xLeft,
            low(
              int
            ),
            event.yUpper,
          )

        let rightLowerQuery =
          pointSolver.addRectangleQuery(
            low(
              int
            ),
            event.xRight,
            low(
              int
            ),
            event.yLower,
          )

        let leftLowerQuery =
          pointSolver.addRectangleQuery(
            low(
              int
            ),
            event.xLeft,
            low(
              int
            ),
            event.yLower,
          )

        queryPlans[
          event.queryIndex
        ] =
          OfflineRectangleAddRectangleSumQueryPlan(
            xLeft:
              event.xLeft,
            xRight:
              event.xRight,
            yLower:
              event.yLower,
            yUpper:
              event.yUpper,
            rightUpperQuery:
              rightUpperQuery,
            leftUpperQuery:
              leftUpperQuery,
            rightLowerQuery:
              rightLowerQuery,
            leftLowerQuery:
              leftLowerQuery,
          )

    let coefficientAnswers =
      pointSolver.solve()

    result =
      newSeq[
        CG.value_type
      ](
        solver.queryCountValue
      )

    for index in 0 ..<
        queryPlans.len:
      let plan =
        queryPlans[
          index
        ]

      let rightUpper =
        prefixValue[
          CG
        ](
          coefficientAnswers[
            plan.rightUpperQuery
          ],
          plan.xRight,
          plan.yUpper,
          CG,
        )

      let leftUpper =
        prefixValue[
          CG
        ](
          coefficientAnswers[
            plan.leftUpperQuery
          ],
          plan.xLeft,
          plan.yUpper,
          CG,
        )

      let rightLower =
        prefixValue[
          CG
        ](
          coefficientAnswers[
            plan.rightLowerQuery
          ],
          plan.xRight,
          plan.yLower,
          CG,
        )

      let leftLower =
        prefixValue[
          CG
        ](
          coefficientAnswers[
            plan.leftLowerQuery
          ],
          plan.xLeft,
          plan.yLower,
          CG,
        )

      let upperStrip =
        CG.op(
          rightUpper,
          CG.inv(
            leftUpper
          ),
        )

      let lowerStrip =
        CG.op(
          rightLower,
          CG.inv(
            leftLower
          ),
        )

      result[
        index
      ] =
        CG.op(
          upperStrip,
          CG.inv(
            lowerStrip
          ),
        )
