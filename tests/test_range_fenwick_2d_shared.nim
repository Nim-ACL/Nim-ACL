import std/[random, sequtils, unittest]
import atcoder/modint
import atcoder/extra/structure/dense_range_fenwicktree_2d
import atcoder/extra/structure/sparse_range_fenwicktree_2d

type
  Scalar = distinct int64
  Update = tuple[r0, r1, c0, c1: int, delta: int64]

proc `+`(a, b: Scalar): Scalar = Scalar(int64(a) + int64(b))
proc `-`(a, b: Scalar): Scalar = Scalar(int64(a) - int64(b))
proc `-`(a: Scalar): Scalar = Scalar(-int64(a))
proc `*`(a, b: Scalar): Scalar = Scalar(int64(a) * int64(b))
proc `==`(a, b: Scalar): bool = int64(a) == int64(b)

proc rectangle(rng: var Rand, h, w: int): Update =
  let (a, b, c, d) = (rng.rand(h), rng.rand(h), rng.rand(w), rng.rand(w))
  (min(a, b), max(a, b), min(c, d), max(c, d), int64(rng.rand(-3 .. 3)))

proc oracle(updates: seq[Update], query: Update): int64 =
  for u in updates:
    let rows = max(0, min(u.r1, query.r1) - max(u.r0, query.r0))
    let cols = max(0, min(u.c1, query.c1) - max(u.c0, query.c0))
    result += int64(rows) * int64(cols) * u.delta

proc largeCheck[Tree](tree: var Tree, h, w: int) =
  mixin add, sum, get
  var rng = initRand(20261116)
  var updates: seq[Update]
  for i in 0 ..< 128:
    let u = rng.rectangle(h, w)
    updates.add u
    tree.add(u.r0, u.r1, u.c0, u.c1, u.delta)
  for i in 0 ..< 256:
    let q = rng.rectangle(h, w)
    doAssert tree.sum(q.r0, q.r1, q.c0, q.c1) == oracle(updates, q)
  doAssert tree.sum(0, h, 0, w) == oracle(updates, (0, h, 0, w, 0'i64))
  doAssert tree.get(h - 1, w - 1) ==
    oracle(updates, (h - 1, h, w - 1, w, 0'i64))

suite "Range Fenwick 2D shared operations":
  test "distinct public types, named arguments, zero dimensions and empty updates":
    static:
      doAssert DenseRangeFenwickTree2D[int64] isnot SparseRangeFenwickTree2D[int64]
    for h in 0 .. 3:
      for w in 0 .. 3:
        var d = initDenseRangeFenwickTree2D[int64](height = h, width = w)
        var s = initSparseRangeFenwickTree2D[int64](height = h, width = w)
        d.add(rowBegin = h, rowEnd = h, colBegin = 0, colEnd = w, delta = low(int64))
        s.add(rowBegin = h, rowEnd = h, colBegin = 0, colEnd = w, delta = low(int64))
        d.add(0, h, w, w, low(int64))
        s.add(0, h, w, w, low(int64))
        check d.sum(rowBegin = 0, rowEnd = h, colBegin = 0, colEnd = w) == 0
        check s.sum(rowBegin = 0, rowEnd = h, colBegin = 0, colEnd = w) == 0
        if h > 0 and w > 0:
          d.add(0, h, 0, w, 7)
          s.add(0, h, 0, w, 7)
          check d.get(row = h - 1, col = w - 1) == 7
          check s.get(row = h - 1, col = w - 1) == 7

  test "invalid inputs retain assertion behavior":
    expect AssertionDefect: discard initDenseRangeFenwickTree2D[int64](-1, 2)
    expect AssertionDefect: discard initSparseRangeFenwickTree2D[int64](2, -1)
    var d = initDenseRangeFenwickTree2D[int64](3, 4)
    var s = initSparseRangeFenwickTree2D[int64](3, 4)
    expect AssertionDefect: d.add(-1, 2, 0, 4, 1)
    expect AssertionDefect: s.add(-1, 2, 0, 4, 1)
    expect AssertionDefect: discard d.sum(2, 1, 0, 4)
    expect AssertionDefect: discard s.sum(2, 1, 0, 4)
    expect AssertionDefect: discard d.get(3, 0)
    expect AssertionDefect: discard s.get(0, 4)
    check d.sum(0, 3, 0, 4) == 0
    check s.sum(0, 3, 0, 4) == 0

  test "generic scalar and floating-point contracts":
    var d = initDenseRangeFenwickTree2D[Scalar](3, 4)
    var s = initSparseRangeFenwickTree2D[Scalar](3, 4)
    d.add(0, 3, 0, 4, Scalar(5)); s.add(0, 3, 0, 4, Scalar(5))
    d.add(1, 3, 2, 4, Scalar(-2)); s.add(1, 3, 2, 4, Scalar(-2))
    doAssert d.sum(0, 3, 0, 4) == Scalar(52)
    doAssert s.sum(0, 3, 0, 4) == Scalar(52)
    doAssert d.get(2, 3) == Scalar(3)
    doAssert s.get(2, 3) == Scalar(3)
    var fd = initDenseRangeFenwickTree2D[float64](3, 4)
    var fs = initSparseRangeFenwickTree2D[float64](3, 4)
    fd.add(0, 3, 0, 4, 0.5); fs.add(0, 3, 0, 4, 0.5)
    fd.add(1, 3, 2, 4, -0.25); fs.add(1, 3, 2, 4, -0.25)
    check fd.sum(0, 3, 0, 4) == 5.0
    check fs.sum(0, 3, 0, 4) == 5.0

  test "deterministic random differential against a naive grid":
    var rng = initRand(1162026)
    for trial in 0 ..< 300:
      let (h, w) = (rng.rand(12), rng.rand(13))
      var d = initDenseRangeFenwickTree2D[int64](h, w)
      var s = initSparseRangeFenwickTree2D[int64](h, w)
      var grid = newSeqWith(h, newSeq[int64](w))
      for operation in 0 ..< 200:
        let q = rng.rectangle(h, w)
        if operation mod 3 != 0:
          d.add(q.r0, q.r1, q.c0, q.c1, q.delta)
          s.add(q.r0, q.r1, q.c0, q.c1, q.delta)
          for r in q.r0 ..< q.r1:
            for c in q.c0 ..< q.c1: grid[r][c] += q.delta
        else:
          var expected = 0'i64
          for r in q.r0 ..< q.r1:
            for c in q.c0 ..< q.c1: expected += grid[r][c]
          doAssert d.sum(q.r0, q.r1, q.c0, q.c1) == expected
          doAssert s.sum(q.r0, q.r1, q.c0, q.c1) == expected

  test "large dense grid and huge sparse domain":
    block:
      var d = initDenseRangeFenwickTree2D[int64](1024, 1536)
      d.largeCheck(1024, 1536)
    block:
      var s = initSparseRangeFenwickTree2D[int64](10_000_007, 10_000_009)
      s.largeCheck(10_000_007, 10_000_009)

  test "sparse index advancement near high(int), with modular coefficients":
    type Mint = modint998244353
    let n = high(int)
    var s = initSparseRangeFenwickTree2D[Mint](n, n)
    s.add(n - 3, n, n - 4, n, Mint(5))
    check s.sum(0, n, 0, n) == Mint(60)
    check s.get(n - 1, n - 1) == Mint(5)
    s.add(n - 1, n, n - 1, n, Mint(-2))
    check s.sum(n - 3, n, n - 4, n) == Mint(58)
    check s.get(n - 1, n - 1) == Mint(3)

echo "RANGE_FENWICK_2D_SHARED_CONTRACT_OK"
