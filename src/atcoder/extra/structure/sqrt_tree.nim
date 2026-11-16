when not declared ATCODER_EXTRA_STRUCTURE_SQRT_TREE_HPP:
  const ATCODER_EXTRA_STRUCTURE_SQRT_TREE_HPP* = 1

  import std/math

  const SqrtTreeLeafThreshold* = 4

  type
    SqrtTreeNode[T] = ref object
      l, r: int
      blockSize: int

      prefix: seq[T]
      suffix: seq[T]
      between: seq[seq[T]]

      children: seq[SqrtTreeNode[T]]

    SqrtTree*[T] = object
      data*: seq[T]
      identity*: T
      op*: proc(a, b: T): T {.closure.}
      root: SqrtTreeNode[T]

  proc ceilSqrt(n: int): int =
    doAssert n > 0

    result = max(1, int(ceil(sqrt(float(n)))))

    while result * result < n:
      result.inc

    while result > 1 and
        (result - 1) * (result - 1) >= n:
      result.dec

  proc buildNode[T](
    data: seq[T],
    op: proc(a, b: T): T {.closure.},
    l, r: int
  ): SqrtTreeNode[T] =
    result = SqrtTreeNode[T](
      l: l,
      r: r,
      blockSize: 0,
      prefix: @[],
      suffix: @[],
      between: @[],
      children: @[],
    )

    let length = r - l

    if length <= SqrtTreeLeafThreshold:
      return

    result.blockSize = max(2, ceilSqrt(length))

    let blockCount =
      (length + result.blockSize - 1) div result.blockSize

    result.prefix = newSeq[T](length)
    result.suffix = newSeq[T](length)
    result.children = newSeq[SqrtTreeNode[T]](blockCount)

    var blockProduct = newSeq[T](blockCount)

    for blockIndex in 0 ..< blockCount:
      let
        blockL = l + blockIndex * result.blockSize
        blockR = min(r, blockL + result.blockSize)

      result.children[blockIndex] =
        buildNode(data, op, blockL, blockR)

      result.prefix[blockL - l] = data[blockL]

      for i in blockL + 1 ..< blockR:
        result.prefix[i - l] =
          op(result.prefix[i - l - 1], data[i])

      result.suffix[blockR - 1 - l] = data[blockR - 1]

      if blockR - 2 >= blockL:
        for i in countdown(blockR - 2, blockL):
          result.suffix[i - l] =
            op(data[i], result.suffix[i + 1 - l])

      blockProduct[blockIndex] =
        result.prefix[blockR - 1 - l]

    result.between = newSeq[seq[T]](blockCount)

    for leftBlock in 0 ..< blockCount:
      result.between[leftBlock] = newSeq[T](blockCount)
      result.between[leftBlock][leftBlock] =
        blockProduct[leftBlock]

      for rightBlock in leftBlock + 1 ..< blockCount:
        result.between[leftBlock][rightBlock] =
          op(
            result.between[leftBlock][rightBlock - 1],
            blockProduct[rightBlock],
          )

  proc initSqrtTree*[T](
    data: openArray[T],
    identity: T,
    op: proc(a, b: T): T {.closure.}
  ): SqrtTree[T] =
    ## Builds a recursive square-root decomposition for static range products.
    ##
    ## Preprocessing and memory are `O(n log log n)`.
    ## Queries take `O(log log n)` in this clear recursive implementation.
    result.data = @data
    result.identity = identity
    result.op = op

    if result.data.len > 0:
      result.root =
        buildNode(result.data, op, 0, result.data.len)

  proc len*[T](
    tree: SqrtTree[T]
  ): int {.inline.} =
    tree.data.len

  proc queryNode[T](
    tree: SqrtTree[T],
    node: SqrtTreeNode[T],
    queryL, queryR: int
  ): T =
    let length = node.r - node.l

    if length <= SqrtTreeLeafThreshold:
      var value = tree.data[queryL]

      for i in queryL + 1 ..< queryR:
        value = tree.op(value, tree.data[i])

      return value

    let
      leftBlock =
        (queryL - node.l) div node.blockSize
      rightBlock =
        (queryR - 1 - node.l) div node.blockSize

    if leftBlock == rightBlock:
      return tree.queryNode(
        node.children[leftBlock],
        queryL,
        queryR,
      )

    var value =
      node.suffix[queryL - node.l]

    if leftBlock + 1 <= rightBlock - 1:
      value = tree.op(
        value,
        node.between[leftBlock + 1][rightBlock - 1],
      )

    value = tree.op(
      value,
      node.prefix[queryR - 1 - node.l],
    )

    value

  proc prod*[T](
    tree: SqrtTree[T],
    l, r: int
  ): T =
    ## Returns the product over the non-empty half-open interval `[l, r)`.
    doAssert 0 <= l and l < r and r <= tree.len
    doAssert not tree.root.isNil

    tree.queryNode(tree.root, l, r)

  proc `[]`*[T](
    tree: SqrtTree[T],
    range: tuple[l, r: int]
  ): T =
    ## Sugar for `prod(range.l, range.r)`.
    tree.prod(range.l, range.r)

  proc allProd*[T](
    tree: SqrtTree[T]
  ): T =
    ## Returns the aggregate of the whole array.
    if tree.len == 0:
      tree.identity
    else:
      tree.prod(0, tree.len)
