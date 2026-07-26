when not declared ATCODER_EXTRA_STRUCTURE_SEGTREE_2D_BACKUP_HPP:
  const ATCODER_EXTRA_STRUCTURE_SEGTREE_2D_BACKUP_HPP* = 1
  import atcoder/segtree
  type SegTree2D*[S; SegTree] = object
    N2: int
    xs: seq[S]
    ys: seq[seq[S]]
    segt: seq[SegTree]

  proc initSegTree2D*[S](v: seq[tuple[x, y:int]], op: static[proc(a, b:S):S], e: static[proc():S]):auto =
    type st = SegTreeType[S](op, e)
    result = SegTree2D[S, st]()
    for i in 0 ..< v.len: result.xs.add v[i].x
    result.xs.sort
    result.xs = result.xs.deduplicate(true)
    var N2 = 1
    while N2 < result.xs.len: N2 *= 2

    result.ys.setLen(N2 * 2)
    result.segt.setLen(N2 * 2)
    result.N2 = N2

    var result_p = result.addr
    proc setYs(i, xi, y, l, r:int) =
      result_p[].ys[i].add y
      if r - l > 1:
        let m = (l + r) shr 1
        if xi in l ..< m:
          setYs(i * 2 + 1, xi, y, l, m)
        else:
          setYs(i * 2 + 2, xi, y, m, r)

    for (x, y) in v:
      let xi = result.xs.lowerBound(x)
      setYs(0, xi, y, 0, N2)
    for i in 0 ..< result.ys.len:
      result.ys[i].sort
      result.ys[i] = result.ys[i].deduplicate(true)
      result.segt[i].init(result.ys[i].len)

  proc add*[ST:SegTree2D](self:var ST, i, xi, y: int, v:ST.S, l, r:int) =
    let yi = self.ys[i].lowerBound(y)
    doAssert self.ys[i][yi] == y
    if r - l > 1:
      let m = (l + r) shr 1
      if xi in l ..< m:
        self.add(i * 2 + 1, xi, y, v, l, m)
      else:
        self.add(i * 2 + 2, xi, y, v, m, r)
    self.segt[i][yi] = self.SegTree.calc_op(self.segt[i][yi], v)
  proc get*[ST:SegTree2D](self:ST, i, xi, y: int, l, r:int):ST.S =
    if r - l > 1:
      let m = (l + r) shr 1
      if xi in l ..< m:
        return self.get(i * 2 + 1, xi, y, l, m)
      else:
        return self.get(i * 2 + 2, xi, y, m, r)
    else:
      let yi = self.ys[i].lowerBound(y)
      doAssert self.ys[i][yi] == y
      return self.segt[i][yi]

  proc prod*[ST:SegTree2D](self: ST, i, xil, xir, yl, yr, l, r:int):int =
    if xir <= l or r <= xil: return self.SegTree.calc_e()
    elif xil <= l and r <= xir:
      let
        yil = self.ys[i].lowerBound(yl)
        yir = self.ys[i].lowerBound(yr)
      return self.segt[i][yil ..< yir]
    else:
      let m = (l + r) shr 1
      return self.SegTree.calc_op(self.prod(i * 2 + 1, xil, xir, yl, yr, l, m), self.prod(i * 2 + 2, xil, xir, yl, yr, m, r))

  proc add*[ST:SegTree2D](self: var ST, x, y:int, v:ST.S) =
    let xi = self.xs.lowerBound(x)
    doAssert self.xs[xi] == x
    self.add(0, xi, y, v, 0, self.N2)
  #proc `[]=`*[ST:SegTree2D](self: var ST, x, y:int, v:ST.S) = self.add(x, y, v)
  proc get*[ST:SegTree2D](self: var ST, x, y:int):ST.S =
    let xi = self.xs.lowerBound(x)
    doAssert self.xs[xi] == x
    return self.get(0, xi, y, 0, self.N2)
  proc `[]`*[ST:SegTree2D](self: var ST, x, y:int):ST.S = self.get(x, y)

  proc prod*[ST:SegTree2D](self: var ST, xp, yp: Slice[int] or int):ST.S =
    when xp is int:
      let xp = xp .. xp
    when yp is int:
      let yp = yp .. yp
    let
      xl = xp.a
      xr = xp.b + 1
      yl = yp.a
      yr = yp.b + 1
      xil = self.xs.lowerBound(xl)
      xir = self.xs.lowerBound(xr)
    self.prod(0, xil, xir, yl, yr, 0, self.N2)
  proc `[]`*[ST:SegTree2D](self: var ST, xp, yp: Slice[int] or int):ST.S = self.prod(xp, yp)
