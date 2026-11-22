# Mo's Algorithm

`Mo` reorders offline static range queries to minimize endpoint movement.

It is useful when adding or removing one array element from the current range is inexpensive.

## Import and API

~~~nim
import atcoder/extra/algorithm/mo

proc initMo(n: int, blockSize = 0): Mo
proc addQuery(mo: var Mo, l, r: int): int
proc orderedQueries(mo: Mo): seq[MoQuery]
proc run(mo: Mo, add, remove, answer)
~~~

All ranges are half-open `[l, r)`.

## Complexity

Typically:

```text
O(q log q + (q B + n^2 / B) * add/remove cost)
B = block size (default: max(1, floor(sqrt(n))))
```

Storage is `O(q)`, including the ordered query copy.

## Legacy API

`atcoder/extra/structure/mo` delegates to the same internal core. Its
`initMo(N, Q)` uses the query count as the second argument; the modern API
uses the block size. When importing both, use `initMo(N = n, Q = q)` or
`initMo(n, blockSize = b)` to distinguish them.

## Related resources

- [cp-algorithms: Mo's Algorithm](https://cp-algorithms.com/data_structures/sqrt_decomposition.html#mos-algorithm)
- [ei1333 Library: Mo](https://ei1333.github.io/library/other/mo.hpp.html)
- [Nyaan Library: Mo](https://nyaannyaan.github.io/library/misc/mo.hpp.html)
