when not declared ATCODER_SEGTREE_HPP:
  const ATCODER_SEGTREE_HPP* = 1
  import atcoder/internal_bit
  import std/sequtils, std/algorithm
  import atcoder/rangeutils

  #{.push inline.}
  type SegTree*[S; p:static[tuple]] = object
    len*, size*, log*:int
    d: seq[S]

  template calc_op*[ST:SegTree](self:ST or typedesc[ST], a, b:ST.S):auto =
    ST.p.op(a, b)
  template calc_e*[ST:SegTree](self:ST or typedesc[ST]):auto =
    ST.p.e()
  proc update[ST:SegTree](self: var ST, k:int) =
    self.d[k] = ST.calc_op(self.d[2 * k], self.d[2 * k + 1])

  proc init*[ST:SegTree](self: var ST, v:seq[ST.S]) =
    let
      n = v.len
      log = ceil_pow2(n)
      size = 1 shl log
    (self.len, self.size, self.log) = (n, size, log)
    if self.d.len < 2 * size:
      self.d = newSeqWith(2 * size, ST.calc_e())
    else:
      self.d.fill(0, 2 * size - 1, ST.calc_e())
    for i in 0..<n: self.d[size + i] = v[i]
    for i in countdown(size - 1, 1): self.update(i)
  proc init*[ST:SegTree](self: var ST, n:int) =
    self.init(newSeqWith(n, ST.calc_e()))
  proc init*[ST:SegTree](self: typedesc[ST], v:seq[ST.S]):auto =
    result = ST()
    result.init(v)
  proc init*[ST:SegTree](self: typedesc[ST], n:int):auto =
    self.init(newSeqWith(n, ST.calc_e()))
  template SegTreeType*[S](op0, e0:untyped):typedesc[SegTree] =
    proc op1(l, r:S):S {.gensym inline.} = op0(l, r)
    proc e1():S {.gensym inline.} = e0()
    SegTree[S, (op:op1, e:e1)]
  template getType*(ST:typedesc[SegTree], S:typedesc, op, e:untyped):typedesc[SegTree] =
    SegTreeType[S](op, e)

  template initSegTree*[S](v:seq[S] or int, op, e:untyped):auto =
    SegTreeType[S](op, e).init(v)

  proc set*[ST:SegTree](self:var ST, p:IndexType, x:ST.S) =
    var p = self^^p
    assert p in 0..<self.len
    p += self.size
    self.d[p] = x
    for i in 1..self.log: self.update(p shr i)

  proc get*[ST:SegTree](self:ST, p:IndexType):ST.S =
    let p = self^^p
    assert p in 0..<self.len
    return self.d[p + self.size]

  proc prod*[ST:SegTree](self:ST, p:RangeType):ST.S =
    var (l, r) = self.halfOpenEndpoints(p)
    assert 0 <= l and l <= r and r <= self.len
    var
      sml, smr = ST.calc_e()
    l += self.size; r += self.size
    while l < r:
      if (l and 1) != 0: sml = ST.calc_op(sml, self.d[l]);l.inc
      if (r and 1) != 0: r.dec;smr = ST.calc_op(self.d[r], smr)
      l = l shr 1
      r = r shr 1
    return ST.calc_op(sml, smr)
  proc `[]`*[ST:SegTree](self:ST, p:IndexType):auto = self.get(p)
  proc `[]`*[ST:SegTree](self:ST, p:RangeType):auto = self.prod(p)
  proc `[]=`*[ST:SegTree](self:var ST, p:IndexType, x:ST.S) = self.set(p, x)

  proc all_prod*[ST:SegTree](self:ST):ST.S = self.d[1]

#  proc max_right*[ST:SegTree, f:static[proc(s:ST.S):bool]](self:ST, l:int):auto = self.max_right(l, f)
  proc max_right*[ST:SegTree](self:ST, l:IndexType, f:proc(s:ST.S):bool):int =
    var l = self^^l
    assert l in 0..self.len
    assert f(ST.calc_e())
    if l == self.len: return self.len
    l += self.size
    var sm = ST.calc_e()
    while true:
      while l mod 2 == 0: l = l shr 1
      let nextSmOuter = ST.calc_op(sm, self.d[l])
      if not f(nextSmOuter):
        while l < self.size:
          l = (2 * l)
          let nextSmInner = ST.calc_op(sm, self.d[l])
          if f(nextSmInner):
            sm = nextSmInner
            l.inc
        return l - self.size
      sm = nextSmOuter
      l.inc
      if not ((l and -l) != l): break
    return self.len

#  proc min_left*[ST:SegTree, f:static[proc(s:ST.S):bool]](self:ST, r:int):auto = self.min_left(r, f)
  proc min_left*[ST:SegTree](self:ST, r:IndexType, f:proc(s:ST.S):bool):int =
    var r = self^^r
    assert r in 0..self.len
    assert f(ST.calc_e())
    if r == 0: return 0
    r += self.size
    var sm = ST.calc_e()
    while true:
      r.dec
      while r > 1 and (r mod 2 != 0): r = r shr 1
      let nextSmOuter = ST.calc_op(self.d[r], sm)
      if not f(nextSmOuter):
        while r < self.size:
          r = (2 * r + 1)
          let nextSmInner = ST.calc_op(self.d[r], sm)
          if f(nextSmInner):
            sm = nextSmInner
            r.dec
        return r + 1 - self.size
      sm = nextSmOuter
      if not ((r and -r) != r): break
    return 0
  #{.pop.}
