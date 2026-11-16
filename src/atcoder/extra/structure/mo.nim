when not declared ATCODER_MO_HPP:
  const ATCODER_MO_HPP* = 1

  import std/math
  import atcoder/extra/algorithm/internal/mo_core
  when not declared(Mo):
    type Mo* = MoState[true]

  proc initMo*(N, Q: int): MoState[true] =
    ## Legacy constructor: the second argument is the expected query count.
    doAssert N >= 0 and Q >= 0
    let width = max(1, int(float(N) /
      max(1.0, sqrt(float(Q) * 2.0 / 3.0))))
    initMoState[true](N, width, requiredQueryCount = Q)

  proc insert*(self: var MoState[true], l, r: int) =
    discard self.addQuery(l, r)

  proc initMo*(N: int, l, r: seq[int]): MoState[true] =
    doAssert l.len == r.len
    result = initMo(N = N, Q = l.len)
    for i in 0 ..< l.len:
      result.insert(l[i], r[i])

  proc run*[AL, AR, DL, DR, REM](
    self: MoState[true],
    add_left: AL,
    add_right: AR,
    delete_left: DL,
    delete_right: DR,
    rem: REM
  ) =
    self.runMoQueries(add_left, add_right, delete_left, delete_right, rem)
