when not declared ATCODER_EXTRA_STRUCTURE_SPARSE_SEGTREE_2D_HPP:
  const ATCODER_EXTRA_STRUCTURE_SPARSE_SEGTREE_2D_HPP* = 1

  import atcoder/extra/monoid/monoid
  import atcoder/extra/structure/internal/sparse_segment_tree_core

  type
    SparseSegTree2DRowPayload[S] = object
      columnTree:
        SparseIntervalArena[S]

    SparseSegTree2D*[
        CM: CommutativeMonoid
    ] = object
      heightValue:
        int

      widthValue:
        int

      rowTree:
        SparseIntervalArena[
          SparseSegTree2DRowPayload[
            CM.value_type
          ]
        ]


  proc initRowPayload[S](
      width: int
  ): SparseSegTree2DRowPayload[S] {.inline.} =
    result.columnTree =
      initSparseIntervalArena[S](
        width
      )


  proc innerSetNode[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseIntervalArena[
          CM.value_type
        ],
      node,
      lo,
      hi,
      point: int,
      value:
        CM.value_type
  ): CM.value_type =
    if hi - lo == 1:
      setPayload(
        tree,
        node,
        value,
      )

      return value

    let mid =
      sparseIntervalMidpoint(
        lo,
        hi,
      )

    var
      leftValue:
        CM.value_type

      rightValue:
        CM.value_type

    if point < mid:
      var child =
        readLeftChild(
          tree,
          node,
        )

      if child == -1:
        child =
          ensureLeftChild(
            tree,
            node,
            CM.e(),
          )

      leftValue =
        innerSetNode[CM](
          tree,
          child,
          lo,
          mid,
          point,
          value,
        )

      let right =
        readRightChild(
          tree,
          node,
        )

      if right == -1:
        rightValue =
          CM.e()
      else:
        rightValue =
          readPayload(
            tree,
            right,
          )

    else:
      var child =
        readRightChild(
          tree,
          node,
        )

      if child == -1:
        child =
          ensureRightChild(
            tree,
            node,
            CM.e(),
          )

      rightValue =
        innerSetNode[CM](
          tree,
          child,
          mid,
          hi,
          point,
          value,
        )

      let left =
        readLeftChild(
          tree,
          node,
        )

      if left == -1:
        leftValue =
          CM.e()
      else:
        leftValue =
          readPayload(
            tree,
            left,
          )

    result =
      CM.op(
        leftValue,
        rightValue,
      )

    setPayload(
      tree,
      node,
      result,
    )


  proc innerSet[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseIntervalArena[
          CM.value_type
        ],
      point: int,
      value:
        CM.value_type
  ) =
    let root =
      ensureRoot(
        tree,
        CM.e(),
      )

    discard innerSetNode[CM](
      tree,
      root,
      0,
      domainSize(tree),
      point,
      value,
    )


  proc innerGetNode[
      CM: CommutativeMonoid
  ](
      tree:
        SparseIntervalArena[
          CM.value_type
        ],
      node,
      lo,
      hi,
      point: int
  ): CM.value_type =
    if node == -1:
      return CM.e()

    if hi - lo == 1:
      return readPayload(
        tree,
        node,
      )

    let mid =
      sparseIntervalMidpoint(
        lo,
        hi,
      )

    if point < mid:
      result =
        innerGetNode[CM](
          tree,
          readLeftChild(
            tree,
            node,
          ),
          lo,
          mid,
          point,
        )

    else:
      result =
        innerGetNode[CM](
          tree,
          readRightChild(
            tree,
            node,
          ),
          mid,
          hi,
          point,
        )


  proc innerGet[
      CM: CommutativeMonoid
  ](
      tree:
        SparseIntervalArena[
          CM.value_type
        ],
      point: int
  ): CM.value_type =
    let root =
      rootIndex(tree)

    if root == -1:
      return CM.e()

    innerGetNode[CM](
      tree,
      root,
      0,
      domainSize(tree),
      point,
    )


  proc innerProdNode[
      CM: CommutativeMonoid
  ](
      tree:
        SparseIntervalArena[
          CM.value_type
        ],
      node,
      lo,
      hi,
      queryLeft,
      queryRight: int
  ): CM.value_type =
    if (
      node == -1 or
      queryRight <= lo or
      hi <= queryLeft
    ):
      return CM.e()

    if (
      queryLeft <= lo and
      hi <= queryRight
    ):
      return readPayload(
        tree,
        node,
      )

    let mid =
      sparseIntervalMidpoint(
        lo,
        hi,
      )

    let leftValue =
      innerProdNode[CM](
        tree,
        readLeftChild(
          tree,
          node,
        ),
        lo,
        mid,
        queryLeft,
        queryRight,
      )

    let rightValue =
      innerProdNode[CM](
        tree,
        readRightChild(
          tree,
          node,
        ),
        mid,
        hi,
        queryLeft,
        queryRight,
      )

    CM.op(
      leftValue,
      rightValue,
    )


  proc innerProd[
      CM: CommutativeMonoid
  ](
      tree:
        SparseIntervalArena[
          CM.value_type
        ],
      queryLeft,
      queryRight: int
  ): CM.value_type =
    if queryLeft == queryRight:
      return CM.e()

    let root =
      rootIndex(tree)

    if root == -1:
      return CM.e()

    innerProdNode[CM](
      tree,
      root,
      0,
      domainSize(tree),
      queryLeft,
      queryRight,
    )


  proc outerSetNode[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseSegTree2D[CM],
      node,
      lo,
      hi,
      row,
      col: int,
      value:
        CM.value_type
  ) =
    var payload =
      readPayload(
        tree.rowTree,
        node,
      )

    if hi - lo == 1:
      innerSet[CM](
        payload.columnTree,
        col,
        value,
      )

      setPayload(
        tree.rowTree,
        node,
        payload,
      )

      return

    let mid =
      sparseIntervalMidpoint(
        lo,
        hi,
      )

    if row < mid:
      var child =
        readLeftChild(
          tree.rowTree,
          node,
        )

      if child == -1:
        child =
          ensureLeftChild(
            tree.rowTree,
            node,
            initRowPayload[
              CM.value_type
            ](
              tree.widthValue
            ),
          )

      outerSetNode[CM](
        tree,
        child,
        lo,
        mid,
        row,
        col,
        value,
      )

    else:
      var child =
        readRightChild(
          tree.rowTree,
          node,
        )

      if child == -1:
        child =
          ensureRightChild(
            tree.rowTree,
            node,
            initRowPayload[
              CM.value_type
            ](
              tree.widthValue
            ),
          )

      outerSetNode[CM](
        tree,
        child,
        mid,
        hi,
        row,
        col,
        value,
      )

    var
      leftValue =
        CM.e()

      rightValue =
        CM.e()

    let left =
      readLeftChild(
        tree.rowTree,
        node,
      )

    if left != -1:
      let leftPayload =
        readPayload(
          tree.rowTree,
          left,
        )

      leftValue =
        innerGet[CM](
          leftPayload.columnTree,
          col,
        )

    let right =
      readRightChild(
        tree.rowTree,
        node,
      )

    if right != -1:
      let rightPayload =
        readPayload(
          tree.rowTree,
          right,
        )

      rightValue =
        innerGet[CM](
          rightPayload.columnTree,
          col,
        )

    innerSet[CM](
      payload.columnTree,
      col,
      CM.op(
        leftValue,
        rightValue,
      ),
    )

    setPayload(
      tree.rowTree,
      node,
      payload,
    )


  proc outerProdNode[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM],
      node,
      lo,
      hi,
      rowLeft,
      rowRight,
      colLeft,
      colRight: int
  ): CM.value_type =
    if (
      node == -1 or
      rowRight <= lo or
      hi <= rowLeft
    ):
      return CM.e()

    if (
      rowLeft <= lo and
      hi <= rowRight
    ):
      let payload =
        readPayload(
          tree.rowTree,
          node,
        )

      return innerProd[CM](
        payload.columnTree,
        colLeft,
        colRight,
      )

    let mid =
      sparseIntervalMidpoint(
        lo,
        hi,
      )

    let leftValue =
      outerProdNode[CM](
        tree,
        readLeftChild(
          tree.rowTree,
          node,
        ),
        lo,
        mid,
        rowLeft,
        rowRight,
        colLeft,
        colRight,
      )

    let rightValue =
      outerProdNode[CM](
        tree,
        readRightChild(
          tree.rowTree,
          node,
        ),
        mid,
        hi,
        rowLeft,
        rowRight,
        colLeft,
        colRight,
      )

    CM.op(
      leftValue,
      rightValue,
    )


  proc initSparseSegTree2D*[
      CM: CommutativeMonoid
  ](
      height,
      width: int,
      _: typedesc[CM]
  ): SparseSegTree2D[CM] =
    if height < 0 or width < 0:
      raise newException(
        ValueError,
        "SparseSegTree2D dimensions must be nonnegative",
      )

    result.heightValue =
      height

    result.widthValue =
      width

    result.rowTree =
      initSparseIntervalArena[
        SparseSegTree2DRowPayload[
          CM.value_type
        ]
      ](
        height
      )


  proc height*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM]
  ): int {.inline.} =
    tree.heightValue


  proc width*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM]
  ): int {.inline.} =
    tree.widthValue


  proc checkPoint[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM],
      row,
      col: int
  ) {.inline.} =
    if not (
      0 <= row and
      row < tree.heightValue and
      0 <= col and
      col < tree.widthValue
    ):
      raise newException(
        IndexDefect,
        "SparseSegTree2D point outside fixed grid",
      )


  proc checkRectangle[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM],
      rowLeft,
      rowRight,
      colLeft,
      colRight: int
  ) {.inline.} =
    if not (
      0 <= rowLeft and
      rowLeft <= rowRight and
      rowRight <= tree.heightValue and
      0 <= colLeft and
      colLeft <= colRight and
      colRight <= tree.widthValue
    ):
      raise newException(
        IndexDefect,
        "SparseSegTree2D rectangle outside fixed grid",
      )


  proc set*[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseSegTree2D[CM],
      row,
      col: int,
      value:
        CM.value_type
  ) =
    tree.checkPoint(
      row,
      col,
    )

    let root =
      ensureRoot(
        tree.rowTree,
        initRowPayload[
          CM.value_type
        ](
          tree.widthValue
        ),
      )

    outerSetNode[CM](
      tree,
      root,
      0,
      tree.heightValue,
      row,
      col,
      value,
    )


  proc get*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM],
      row,
      col: int
  ): CM.value_type =
    tree.checkPoint(
      row,
      col,
    )

    var node =
      rootIndex(
        tree.rowTree
      )

    if node == -1:
      return CM.e()

    var
      lo =
        0

      hi =
        tree.heightValue

    while hi - lo > 1:
      let mid =
        sparseIntervalMidpoint(
          lo,
          hi,
        )

      if row < mid:
        node =
          readLeftChild(
            tree.rowTree,
            node,
          )

        hi =
          mid

      else:
        node =
          readRightChild(
            tree.rowTree,
            node,
          )

        lo =
          mid

      if node == -1:
        return CM.e()

    let payload =
      readPayload(
        tree.rowTree,
        node,
      )

    innerGet[CM](
      payload.columnTree,
      col,
    )


  proc prod*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM],
      rowLeft,
      rowRight,
      colLeft,
      colRight: int
  ): CM.value_type =
    tree.checkRectangle(
      rowLeft,
      rowRight,
      colLeft,
      colRight,
    )

    if (
      rowLeft == rowRight or
      colLeft == colRight
    ):
      return CM.e()

    let root =
      rootIndex(
        tree.rowTree
      )

    if root == -1:
      return CM.e()

    outerProdNode[CM](
      tree,
      root,
      0,
      tree.heightValue,
      rowLeft,
      rowRight,
      colLeft,
      colRight,
    )


  proc allProd*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM]
  ): CM.value_type =
    tree.prod(
      0,
      tree.heightValue,
      0,
      tree.widthValue,
    )


  proc `[]`*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseSegTree2D[CM],
      row,
      col: int
  ): CM.value_type {.inline.} =
    tree.get(
      row,
      col,
    )


  proc `[]=`*[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseSegTree2D[CM],
      row,
      col: int,
      value:
        CM.value_type
  ) {.inline.} =
    tree.set(
      row,
      col,
      value,
    )


  when defined(
    naclSparseSegTree2DContract
  ):
    proc debugOuterNodeCount*[
        CM: CommutativeMonoid
    ](
        tree:
          SparseSegTree2D[CM]
    ): int =
      nodeCount(
        tree.rowTree
      )


    proc debugTotalInnerNodeCount*[
        CM: CommutativeMonoid
    ](
        tree:
          SparseSegTree2D[CM]
    ): int =
      let count =
        nodeCount(
          tree.rowTree
        )

      for node in 0 ..< count:
        let payload =
          readPayload(
            tree.rowTree,
            node,
          )

        result +=
          nodeCount(
            payload.columnTree
          )
