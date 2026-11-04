when not declared ATCODER_EXTRA_MATH_COMBINATION_TABLE_HPP:
  const ATCODER_EXTRA_MATH_COMBINATION_TABLE_HPP* = 1
  import atcoder/element_concepts

  type Combination*[T:RingElem] = object
    cmb_a: seq[seq[T]]
    fact_a: seq[T]

  type CombinationC* = concept x
    x is typedesc[RingElem] or x is var Combination

  proc getAddr(T:typedesc[RingElem]):auto {.discardable.} =
    var cmb_a{.global.}:Combination[T]
    once:
      cmb_a = Combination[T]()
    return cmb_a.addr

  template zero*(T:typedesc[RingElem]):T = T(0)
  template zero*[T:RingElem](cmb:Combination[T]):T = T(0)
  
  template fact*(T:CombinationC, k:int):auto =
    var p = T.getAddr
    while p[].fact_a.len <= k:
      if p[].fact_a.len == 0:
        p[].fact_a.add(T(1))
      else:
        let n = p[].fact_a.len
        p[].fact_a.add(p[].fact_a[^1] * n)
    p[].fact_a[k]

  template resetCombination*(T:typedesc[RingElem] or var Combination) =
    var p = T.getAddr()
    p[].fact_a.setLen(0)
    p[].cmb_a.setLen(0)

  template C_impl*(C:CombinationC, n, r:int):auto =
    when C is Combination:
      type T = C.T
    else:
      type T = C
    if r < 0 or n < r: C.zero()
    else:
      var p = getAddr(C)
      while p[].cmb_a.len <= n:
        if p[].cmb_a.len == 0:
          p[].cmb_a.add(@[T(1)])
        else:
          let k = p[].cmb_a.len
          var v = newSeq[T](k + 1)
          v[0] = T(1)
          for i in 1..k - 1:
            v[i] = p[].cmb_a[^1][i - 1] + p[].cmb_a[^1][i]
          v[k] = T(1)
          p[].cmb_a.add(v)
      p[].cmb_a[n][r]
  template C*(T:CombinationC, n,r:int):auto =
    if n >= 0:
      T.C_impl(n, r)
    else:
      let N = -n
      var a = T.C_impl(N + r - 1, N - 1)
      if r mod 2 != 0: a *= -1
      a
  template H*(T:CombinationC, n,r:int):auto =
    if n < 0 or r < 0: T.zero()
    elif r == 0: T.zero() + 1
    else: T.C(n + r - 1, r)

  template P*(T:CombinationC, n,r:int):auto =
    if r < 0 or n < r: T.zero()
    else:
      T.C(n, r) * T.fact(r)
