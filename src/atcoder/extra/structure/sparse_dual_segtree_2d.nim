when not declared ATCODER_EXTRA_STRUCTURE_SPARSE_DUAL_SEGTREE_2D_HPP:
  const ATCODER_EXTRA_STRUCTURE_SPARSE_DUAL_SEGTREE_2D_HPP* = 1

  import atcoder/extra/monoid/monoid
  import atcoder/extra/structure/internal/sparse_segment_tree_core

  ## Sparse online rectangle-apply / point-get structure over a huge
  ## fixed `(height, width)` grid.
  ##
  ## Update values form a commutative monoid.  Commutativity is required
  ## because a point query combines tags from the Cartesian product of
  ## outer and inner root-to-leaf paths.
  ##
  ## Temporary candidate: exact public API is not frozen.

  type
    SparseDualSegTree2DRowPayload[S] = object
      columnTree:
        SparseIntervalArena[S]

    SparseDualSegTree2D*[
        CM: CommutativeMonoid
    ] = object
      heightValue:
        int

      widthValue:
        int

      rowTree:
        SparseIntervalArena[
          SparseDualSegTree2DRowPayload[
            CM.value_type
          ]
        ]


  proc initRowPayload[S](
      width: int
  ): SparseDualSegTree2DRowPayload[S] {.inline.} =
    result.columnTree =
      initSparseIntervalArena[S](
        width
      )


  proc innerApplyNode[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseIntervalArena[
          CM.value_type
        ],
      node,
      lo,
      hi,
      queryLeft,
      queryRight: int,
      value:
        CM.value_type
  ) =
    if (
      queryRight <= lo or
      hi <= queryLeft
    ):
      return

    if (
      queryLeft <= lo and
      hi <= queryRight
    ):
      let old =
        readPayload(
          tree,
          node,
        )

      setPayload(
        tree,
        node,
        CM.op(
          old,
          value,
        ),
      )

      return

    let mid =
      sparseIntervalMidpoint(
        lo,
        hi,
      )

    if queryLeft < mid:
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

      innerApplyNode[CM](
        tree,
        child,
        lo,
        mid,
        queryLeft,
        queryRight,
        value,
      )

    if mid < queryRight:
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

      innerApplyNode[CM](
        tree,
        child,
        mid,
        hi,
        queryLeft,
        queryRight,
        value,
      )


  proc innerApply[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseIntervalArena[
          CM.value_type
        ],
      queryLeft,
      queryRight: int,
      value:
        CM.value_type
  ) =
    if queryLeft == queryRight:
      return

    let root =
      ensureRoot(
        tree,
        CM.e(),
      )

    innerApplyNode[CM](
      tree,
      root,
      0,
      domainSize(tree),
      queryLeft,
      queryRight,
      value,
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
    var node =
      rootIndex(
        tree
      )

    if node == -1:
      return CM.e()

    var
      lo =
        0

      hi =
        domainSize(tree)

    result =
      CM.e()

    while node != -1:
      result =
        CM.op(
          result,
          readPayload(
            tree,
            node,
          ),
        )

      if hi - lo == 1:
        break

      let mid =
        sparseIntervalMidpoint(
          lo,
          hi,
        )

      if point < mid:
        node =
          readLeftChild(
            tree,
            node,
          )

        hi =
          mid

      else:
        node =
          readRightChild(
            tree,
            node,
          )

        lo =
          mid


  proc outerApplyNode[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseDualSegTree2D[CM],
      node,
      lo,
      hi,
      rowLeft,
      rowRight,
      colLeft,
      colRight: int,
      value:
        CM.value_type
  ) =
    if (
      rowRight <= lo or
      hi <= rowLeft
    ):
      return

    if (
      rowLeft <= lo and
      hi <= rowRight
    ):
      var payload =
        readPayload(
          tree.rowTree,
          node,
        )

      innerApply[CM](
        payload.columnTree,
        colLeft,
        colRight,
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

    if rowLeft < mid:
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

      outerApplyNode[CM](
        tree,
        child,
        lo,
        mid,
        rowLeft,
        rowRight,
        colLeft,
        colRight,
        value,
      )

    if mid < rowRight:
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

      outerApplyNode[CM](
        tree,
        child,
        mid,
        hi,
        rowLeft,
        rowRight,
        colLeft,
        colRight,
        value,
      )


  proc initSparseDualSegTree2D*[
      CM: CommutativeMonoid
  ](
      height,
      width: int,
      _: typedesc[CM]
  ): SparseDualSegTree2D[CM] =
    if height < 0 or width < 0:
      raise newException(
        ValueError,
        "SparseDualSegTree2D dimensions must be nonnegative",
      )

    result.heightValue =
      height

    result.widthValue =
      width

    result.rowTree =
      initSparseIntervalArena[
        SparseDualSegTree2DRowPayload[
          CM.value_type
        ]
      ](
        height
      )


  proc height*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseDualSegTree2D[CM]
  ): int {.inline.} =
    tree.heightValue


  proc width*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseDualSegTree2D[CM]
  ): int {.inline.} =
    tree.widthValue


  proc checkPoint[
      CM: CommutativeMonoid
  ](
      tree:
        SparseDualSegTree2D[CM],
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
        "SparseDualSegTree2D point outside fixed grid",
      )


  proc checkRectangle[
      CM: CommutativeMonoid
  ](
      tree:
        SparseDualSegTree2D[CM],
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
        "SparseDualSegTree2D rectangle outside fixed grid",
      )


  proc apply*[
      CM: CommutativeMonoid
  ](
      tree:
        var SparseDualSegTree2D[CM],
      rowLeft,
      rowRight,
      colLeft,
      colRight: int,
      value:
        CM.value_type
  ) =
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
      return

    let root =
      ensureRoot(
        tree.rowTree,
        initRowPayload[
          CM.value_type
        ](
          tree.widthValue
        ),
      )

    outerApplyNode[CM](
      tree,
      root,
      0,
      tree.heightValue,
      rowLeft,
      rowRight,
      colLeft,
      colRight,
      value,
    )


  proc get*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseDualSegTree2D[CM],
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

    result =
      CM.e()

    while node != -1:
      let payload =
        readPayload(
          tree.rowTree,
          node,
        )

      result =
        CM.op(
          result,
          innerGet[CM](
            payload.columnTree,
            col,
          ),
        )

      if hi - lo == 1:
        break

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


  proc `[]`*[
      CM: CommutativeMonoid
  ](
      tree:
        SparseDualSegTree2D[CM],
      row,
      col: int
  ): CM.value_type {.inline.} =
    tree.get(
      row,
      col,
    )


  when defined(
    naclSparseDualSegTree2DContract
  ):
    proc debugOuterNodeCount*[
        CM: CommutativeMonoid
    ](
        tree:
          SparseDualSegTree2D[CM]
    ): int =
      nodeCount(
        tree.rowTree
      )


    proc debugTotalInnerNodeCount*[
        CM: CommutativeMonoid
    ](
        tree:
          SparseDualSegTree2D[CM]
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
