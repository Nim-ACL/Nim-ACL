import atcoder/extra/structure/dense_range_fenwicktree_2d
import atcoder/extra/structure/sparse_range_fenwicktree_2d

var dense = initDenseRangeFenwickTree2D[int64](4, 5)
var sparse = initSparseRangeFenwickTree2D[int64](4, 5)
dense.add(1, 4, 2, 5, 7)
sparse.add(1, 4, 2, 5, 7)
dense.add(0, 2, 0, 3, -2)
sparse.add(0, 2, 0, 3, -2)
for r0 in 0 .. 4:
  for r1 in r0 .. 4:
    for c0 in 0 .. 5:
      for c1 in c0 .. 5:
        var expected = 0'i64
        for r in r0 ..< r1:
          for c in c0 ..< c1:
            if r >= 1 and c >= 2: expected += 7
            if r < 2 and c < 3: expected -= 2
        doAssert dense.sum(r0, r1, c0, c1) == expected
        doAssert sparse.sum(r0, r1, c0, c1) == expected
echo "dense/sparse coexistence OK"
