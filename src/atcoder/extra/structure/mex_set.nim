when not declared ATCODER_EXTRA_STRUCTURE_MEX_SET_HPP:
  const ATCODER_EXTRA_STRUCTURE_MEX_SET_HPP* = 1

  import atcoder/extra/structure/fast_set

  type
    MexSet* = object
      limit*: int
      counts*: seq[int]
      missing*: FastSet
      storedCount: int

  proc initMexSet*(limit: int): MexSet =
    ## Creates a multiset that can report mex values up to `limit + 1`.
    ##
    ## Values outside `[0, limit]` do not affect the mex.
    doAssert limit >= 0

    result.limit = limit
    result.counts = newSeq[int](limit + 1)
    result.missing = initFastSet(limit + 2)
    result.storedCount = 0

    for x in 0 .. limit + 1:
      result.missing.incl(x)

  proc insert*(s: var MexSet, x: int): bool

  proc initMexSet*(
    limit: int,
    values: openArray[int]
  ): MexSet =
    ## Creates a MexSet containing `values`.
    result = initMexSet(limit)

    for x in values:
      discard result.insert(x)

  proc len*(s: MexSet): int {.inline.} =
    ## Returns the total multiplicity of relevant values.
    s.storedCount

  proc empty*(s: MexSet): bool {.inline.} =
    s.storedCount == 0

  proc count*(s: MexSet, x: int): int {.inline.} =
    ## Returns the multiplicity of `x`.
    if x < 0 or x > s.limit:
      0
    else:
      s.counts[x]

  proc contains*(s: MexSet, x: int): bool {.inline.} =
    s.count(x) > 0

  proc insert*(s: var MexSet, x: int): bool =
    ## Inserts one copy of `x`.
    ##
    ## Returns `true` iff `x` changed from absent to present.
    if x < 0 or x > s.limit:
      return false

    result = s.counts[x] == 0

    if result:
      discard s.missing.erase(x)

    s.counts[x].inc
    s.storedCount.inc

  proc incl*(s: var MexSet, x: int) =
    ## Set-like alias of `insert`.
    discard s.insert(x)

  proc erase*(s: var MexSet, x: int): bool =
    ## Erases one copy of `x`.
    ##
    ## Returns `false` when no copy existed.
    if x < 0 or x > s.limit or s.counts[x] == 0:
      return false

    s.counts[x].dec
    s.storedCount.dec

    if s.counts[x] == 0:
      discard s.missing.insert(x)

    true

  proc excl*(s: var MexSet, x: int) =
    ## Set-like alias of `erase`.
    discard s.erase(x)

  proc mex*(s: MexSet): int {.inline.} =
    ## Returns the minimum non-negative absent integer.
    ##
    ## The result is in `[0, limit + 1]`.
    result = s.missing.minValue()

    doAssert result >= 0

  proc clear*(s: var MexSet) =
    ## Removes all relevant values.
    let limit = s.limit
    s = initMexSet(limit)
