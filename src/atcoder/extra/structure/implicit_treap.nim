when not declared ATCODER_EXTRA_STRUCTURE_IMPLICIT_TREAP_HPP:
  import std/typetraits

  const
    ATCODER_EXTRA_STRUCTURE_IMPLICIT_TREAP_HPP* = 1

    DefaultImplicitTreapSeed* =
      0x243f_6a88_85a3_08d3'u64


  type
    ImplicitTreapNode[S] = object
      left: int
      right: int
      priority: uint64
      size: int
      value: S
      forwardAggregate: S
      backwardAggregate: S
      reversePending: bool

    # Keep seq's refc write barriers when a tree is moved into a GC container.
    ImplicitTreapStorage[S] = distinct seq[ImplicitTreapNode[S]]

    ImplicitTreap*[
        S;
        p: static[tuple]
    ] = object
      root: int
      when defined(gcRefc) and not supportsCopyMem(ImplicitTreapNode[S]):
        ownedNodes: ImplicitTreapStorage[S]
      else:
        nodes: seq[ImplicitTreapNode[S]]
      freeList: seq[int]
      randomState: uint64

  template data[S](storage: ImplicitTreapStorage[S]): untyped =
    seq[ImplicitTreapNode[S]](storage)

  proc clear[S](storage: var ImplicitTreapStorage[S]) =
    # refc seq replacement does not destroy the old elements. Destroy them
    # directly: assigning a default node can invoke allocating user sink hooks.
    `=destroy`(storage.data)
    wasMoved(storage.data)

  proc `=destroy`[S](storage: var ImplicitTreapStorage[S]) =
    storage.clear()

  proc `=copy`[S](dest: var ImplicitTreapStorage[S],
      source: ImplicitTreapStorage[S]) =
    if addr(dest) == unsafeAddr(source): return
    if dest.data.len > 0 and source.data.len > 0 and
        addr(dest.data[0]) == unsafeAddr(source.data[0]): return
    dest.clear()
    dest.data = newSeq[ImplicitTreapNode[S]](source.data.len)
    for i in 0..<source.data.len:
      dest.data[i] = source.data[i]

  proc `=sink`[S](dest: var ImplicitTreapStorage[S],
      source: ImplicitTreapStorage[S]) =
    dest.clear()
    # Borrow the consumed source without copying or destroying its payloads.
    # Moving the underlying seq retains Nim's element and GC handling.
    var consumed {.cursor.} = source
    dest.data = move(consumed.data)

  template nodes[IT: ImplicitTreap](tree: IT): untyped =
    tree.ownedNodes.data


  template calcOp[
      IT: ImplicitTreap
  ](
      self: IT or typedesc[IT],
      left,
      right: IT.S,
  ): auto =
    IT.p.op(
      left,
      right,
    )


  template calcE[
      IT: ImplicitTreap
  ](
      self: IT or typedesc[IT],
  ): auto =
    IT.p.e()


  template ImplicitTreapType*[S](
      op0,
      e0: untyped,
  ): typedesc[ImplicitTreap] =
    proc op1(
        left,
        right: S,
    ): S {.gensym, inline.} =
      op0(
        left,
        right,
      )

    proc e1(): S {.gensym, inline.} =
      e0()

    ImplicitTreap[
      S,
      (
        op: op1,
        e: e1,
      ),
    ]


  proc nodeSize[
      IT: ImplicitTreap
  ](
      tree: IT,
      node: int,
  ): int {.inline.} =
    if node < 0:
      0
    else:
      tree.nodes[node].size


  proc nodeForward[
      IT: ImplicitTreap
  ](
      tree: IT,
      node: int,
  ): IT.S {.inline.} =
    if node < 0:
      tree.calcE()
    else:
      tree.nodes[node].forwardAggregate


  proc nodeBackward[
      IT: ImplicitTreap
  ](
      tree: IT,
      node: int,
  ): IT.S {.inline.} =
    if node < 0:
      tree.calcE()
    else:
      tree.nodes[node].backwardAggregate


  proc nextPriority[
      IT: ImplicitTreap
  ](
      tree: var IT,
  ): uint64 {.inline.} =
    tree.randomState +=
      0x9e37_79b9_7f4a_7c15'u64

    var value =
      tree.randomState

    value =
      (
        value xor (value shr 30)
      ) * 0xbf58_476d_1ce4_e5b9'u64

    value =
      (
        value xor (value shr 27)
      ) * 0x94d0_49bb_1331_11eb'u64

    value xor (value shr 31)


  proc pull[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node: int,
  ) =
    if node < 0:
      return

    let
      left =
        tree.nodes[node].left

      right =
        tree.nodes[node].right

      value =
        tree.nodes[node].value

    tree.nodes[node].size =
      1 +
      tree.nodeSize(left) +
      tree.nodeSize(right)

    tree.nodes[node].forwardAggregate =
      tree.calcOp(
        tree.calcOp(
          tree.nodeForward(left),
          value,
        ),
        tree.nodeForward(right),
      )

    tree.nodes[node].backwardAggregate =
      tree.calcOp(
        tree.calcOp(
          tree.nodeBackward(right),
          value,
        ),
        tree.nodeBackward(left),
      )


  proc applyReverse[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node: int,
  ) =
    if node < 0:
      return

    swap(
      tree.nodes[node].left,
      tree.nodes[node].right,
    )

    swap(
      tree.nodes[node].forwardAggregate,
      tree.nodes[node].backwardAggregate,
    )

    tree.nodes[node].reversePending =
      not tree.nodes[node].reversePending


  proc push[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node: int,
  ) =
    if node < 0:
      return

    if not tree.nodes[node].reversePending:
      return

    let
      left =
        tree.nodes[node].left

      right =
        tree.nodes[node].right

    tree.applyReverse(left)
    tree.applyReverse(right)

    tree.nodes[node].reversePending =
      false


  proc allocateNode[
      IT: ImplicitTreap
  ](
      tree: var IT,
      value: IT.S,
  ): int =
    let node =
      ImplicitTreapNode[IT.S](
        left: -1,
        right: -1,
        priority: tree.nextPriority(),
        size: 1,
        value: value,
        forwardAggregate: value,
        backwardAggregate: value,
        reversePending: false,
      )

    if tree.freeList.len > 0:
      result =
        tree.freeList.pop()

      tree.nodes[result] =
        node
    else:
      result =
        tree.nodes.len

      tree.nodes.add(node)


  proc releaseNode[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node: int,
  ) =
    if node >= 0:
      tree.freeList.add(node)


  proc splitNode[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node,
      leftSize: int,
  ): (int, int) =
    if node < 0:
      return (-1, -1)

    tree.push(node)

    let
      currentLeft =
        tree.nodes[node].left

      currentLeftSize =
        tree.nodeSize(currentLeft)

    if leftSize <= currentLeftSize:
      let parts =
        tree.splitNode(
          currentLeft,
          leftSize,
        )

      tree.nodes[node].left =
        parts[1]

      tree.pull(node)

      result =
        (
          parts[0],
          node,
        )
    else:
      let
        currentRight =
          tree.nodes[node].right

        parts =
          tree.splitNode(
            currentRight,
            leftSize - currentLeftSize - 1,
          )

      tree.nodes[node].right =
        parts[0]

      tree.pull(node)

      result =
        (
          node,
          parts[1],
        )


  proc mergeNode[
      IT: ImplicitTreap
  ](
      tree: var IT,
      leftRoot,
      rightRoot: int,
  ): int =
    if leftRoot < 0:
      return rightRoot

    if rightRoot < 0:
      return leftRoot

    if tree.nodes[leftRoot].priority >
        tree.nodes[rightRoot].priority:
      tree.push(leftRoot)

      tree.nodes[leftRoot].right =
        tree.mergeNode(
          tree.nodes[leftRoot].right,
          rightRoot,
        )

      tree.pull(leftRoot)

      result =
        leftRoot
    else:
      tree.push(rightRoot)

      tree.nodes[rightRoot].left =
        tree.mergeNode(
          leftRoot,
          tree.nodes[rightRoot].left,
        )

      tree.pull(rightRoot)

      result =
        rightRoot


  proc init*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      seed: uint64 =
        DefaultImplicitTreapSeed,
  ) =
    tree.root = -1
    when defined(gcRefc) and not supportsCopyMem(ImplicitTreapNode[IT.S]):
      tree.ownedNodes.clear()
    else:
      tree.nodes = @[]
    tree.freeList = @[]
    tree.randomState = seed


  proc init*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      values: openArray[IT.S],
      seed: uint64 =
        DefaultImplicitTreapSeed,
  ) =
    tree.init(seed)

    tree.nodes =
      newSeqOfCap[
        ImplicitTreapNode[IT.S]
      ](
        values.len
      )

    for value in values:
      let node =
        tree.allocateNode(value)

      tree.root =
        tree.mergeNode(
          tree.root,
          node,
        )


  proc init*[
      IT: ImplicitTreap
  ](
      treeType: typedesc[IT],
      seed: uint64 =
        DefaultImplicitTreapSeed,
  ): IT =
    result.init(seed)


  proc init*[
      IT: ImplicitTreap
  ](
      treeType: typedesc[IT],
      values: openArray[IT.S],
      seed: uint64 =
        DefaultImplicitTreapSeed,
  ): IT =
    result.init(
      values,
      seed,
    )


  proc len*[
      IT: ImplicitTreap
  ](
      tree: IT,
  ): int {.inline.} =
    tree.nodeSize(tree.root)


  proc checkInsertPosition[
      IT: ImplicitTreap
  ](
      tree: IT,
      position: int,
  ) =
    if position < 0 or position > tree.len:
      raise newException(
        ValueError,
        "insert position is out of range",
      )


  proc checkPosition[
      IT: ImplicitTreap
  ](
      tree: IT,
      position: int,
  ) =
    if position < 0 or position >= tree.len:
      raise newException(
        ValueError,
        "position is out of range",
      )


  proc checkRange[
      IT: ImplicitTreap
  ](
      tree: IT,
      left,
      right: int,
  ) =
    if left < 0 or left > right or right > tree.len:
      raise newException(
        ValueError,
        "range is out of bounds",
      )


  proc insert*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      position: int,
      value: IT.S,
  ) =
    tree.checkInsertPosition(position)

    let parts =
      tree.splitNode(
        tree.root,
        position,
      )

    let middle =
      tree.allocateNode(value)

    tree.root =
      tree.mergeNode(
        tree.mergeNode(
          parts[0],
          middle,
        ),
        parts[1],
      )


  proc erase*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      position: int,
  ): IT.S =
    tree.checkPosition(position)

    let outer =
      tree.splitNode(
        tree.root,
        position,
      )

    let inner =
      tree.splitNode(
        outer[1],
        1,
      )

    let removed =
      inner[0]

    if removed < 0 or tree.nodeSize(removed) != 1:
      raise newException(
        AssertionDefect,
        "internal erase split failed",
      )

    result =
      tree.nodes[removed].value

    tree.root =
      tree.mergeNode(
        outer[0],
        inner[1],
      )

    tree.releaseNode(removed)


  proc getNodeValue[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node,
      position: int,
  ): IT.S =
    tree.push(node)

    let leftSize =
      tree.nodeSize(
        tree.nodes[node].left
      )

    if position < leftSize:
      result =
        tree.getNodeValue(
          tree.nodes[node].left,
          position,
        )
    elif position == leftSize:
      result =
        tree.nodes[node].value
    else:
      result =
        tree.getNodeValue(
          tree.nodes[node].right,
          position - leftSize - 1,
        )


  proc get*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      position: int,
  ): IT.S =
    tree.checkPosition(position)

    tree.getNodeValue(
      tree.root,
      position,
    )


  proc setNodeValue[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node,
      position: int,
      value: IT.S,
  ) =
    tree.push(node)

    let leftSize =
      tree.nodeSize(
        tree.nodes[node].left
      )

    if position < leftSize:
      tree.setNodeValue(
        tree.nodes[node].left,
        position,
        value,
      )
    elif position == leftSize:
      tree.nodes[node].value =
        value
    else:
      tree.setNodeValue(
        tree.nodes[node].right,
        position - leftSize - 1,
        value,
      )

    tree.pull(node)


  proc set*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      position: int,
      value: IT.S,
  ) =
    tree.checkPosition(position)

    tree.setNodeValue(
      tree.root,
      position,
      value,
    )


  proc reverse*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      left,
      right: int,
  ) =
    tree.checkRange(
      left,
      right,
    )

    if left == right:
      return

    let outer =
      tree.splitNode(
        tree.root,
        right,
      )

    let inner =
      tree.splitNode(
        outer[0],
        left,
      )

    tree.applyReverse(
      inner[1]
    )

    tree.root =
      tree.mergeNode(
        tree.mergeNode(
          inner[0],
          inner[1],
        ),
        outer[1],
      )


  proc prod*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      left,
      right: int,
  ): IT.S =
    tree.checkRange(
      left,
      right,
    )

    if left == right:
      return tree.calcE()

    let outer =
      tree.splitNode(
        tree.root,
        right,
      )

    let inner =
      tree.splitNode(
        outer[0],
        left,
      )

    result =
      tree.nodeForward(
        inner[1]
      )

    tree.root =
      tree.mergeNode(
        tree.mergeNode(
          inner[0],
          inner[1],
        ),
        outer[1],
      )


  proc allProd*[
      IT: ImplicitTreap
  ](
      tree: IT,
  ): IT.S =
    tree.nodeForward(
      tree.root
    )


  proc appendToSequence[
      IT: ImplicitTreap
  ](
      tree: var IT,
      node: int,
      output: var seq[IT.S],
  ) =
    if node < 0:
      return

    tree.push(node)

    tree.appendToSequence(
      tree.nodes[node].left,
      output,
    )

    output.add(
      tree.nodes[node].value
    )

    tree.appendToSequence(
      tree.nodes[node].right,
      output,
    )


  proc toSeq*[
      IT: ImplicitTreap
  ](
      tree: var IT,
  ): seq[IT.S] =
    result =
      newSeqOfCap[IT.S](
        tree.len
      )

    tree.appendToSequence(
      tree.root,
      result,
    )


  proc `[]`*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      position: int,
  ): IT.S {.inline.} =
    tree.get(position)


  proc `[]=`*[
      IT: ImplicitTreap
  ](
      tree: var IT,
      position: int,
      value: IT.S,
  ) {.inline.} =
    tree.set(
      position,
      value,
    )
