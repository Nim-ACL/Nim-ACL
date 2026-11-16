when not declared ATCODER_EXTRA_ALGORITHM_INTERNAL_MO_CORE_HPP:
  const ATCODER_EXTRA_ALGORITHM_INTERNAL_MO_CORE_HPP* = 1

  import std/algorithm
  import std/math

  type
    MoQuery* = object
      l*, r*, id*: int

    MoState*[legacyApi: static[bool]] = object
      n*: int
      queries*: seq[MoQuery]
      blockSize*: int
      when legacyApi:
        requiredQueryCount: int

  proc initMoState*[legacyApi: static[bool]](
    n: int, blockSize = 0, requiredQueryCount = -1
  ): MoState[legacyApi] =
    ## Creates a Mo's algorithm query container.
    doAssert n >= 0
    doAssert blockSize >= 0

    result.n = n
    when legacyApi:
      result.requiredQueryCount = requiredQueryCount
    result.queries = @[]

    if blockSize > 0:
      result.blockSize = blockSize
    else:
      result.blockSize = max(1, int(sqrt(float(max(1, n)))))

  proc len*[legacyApi](mo: MoState[legacyApi]): int {.inline.} =
    ## Returns the number of registered queries.
    mo.queries.len

  proc addQuery*[legacyApi](mo: var MoState[legacyApi], l, r: int): int =
    ## Adds the half-open query `[l, r)` and returns its query id.
    doAssert 0 <= l and l <= r and r <= mo.n

    result = mo.queries.len
    mo.queries.add MoQuery(l: l, r: r, id: result)

  proc orderedQueries*[legacyApi](mo: MoState[legacyApi]): seq[MoQuery] =
    ## Returns queries in Mo order.
    result = mo.queries

    let blockSize = mo.blockSize
    const reverseFirstBlock = legacyApi

    result.sort(proc(a, b: MoQuery): int =
      let
        blockA = a.l div blockSize
        blockB = b.l div blockSize

      if blockA != blockB:
        return cmp(blockA, blockB)

      if ((blockA and 1) == 0) != reverseFirstBlock:
        cmp(a.r, b.r)
      else:
        cmp(b.r, a.r)
    )

  proc runMoQueries*[legacyApi: static[bool]; AL, AR, DL, DR, Answer](
    mo: MoState[legacyApi],
    addLeft: AL,
    addRight: AR,
    removeLeft: DL,
    removeRight: DR,
    answer: Answer
  ) =
    ## Runs registered range queries in Mo order.
    when legacyApi:
      assert mo.queries.len == mo.requiredQueryCount
    var
      currentL = 0
      currentR = 0

    for query in mo.orderedQueries():
      while currentL > query.l:
        currentL.dec
        addLeft(currentL)

      while currentR < query.r:
        addRight(currentR)
        currentR.inc

      while currentL < query.l:
        removeLeft(currentL)
        currentL.inc

      while currentR > query.r:
        currentR.dec
        removeRight(currentR)

      answer(query.id)
