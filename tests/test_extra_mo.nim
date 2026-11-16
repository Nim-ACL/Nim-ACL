discard """
  cmd: "nim cpp -r $file"
"""

import std/unittest
import std/tables
import std/algorithm
import std/sequtils
import atcoder/extra/algorithm/mo

test "Mo distinct values":
  let a = @[1, 2, 1, 3, 2]

  var mo = initMo(a.len)

  discard mo.addQuery(0, 3)
  discard mo.addQuery(1, 5)
  discard mo.addQuery(2, 4)
  discard mo.addQuery(0, 5)

  var
    frequency = initTable[int, int]()
    distinctCount = 0
    answer = newSeq[int](mo.len)

  proc add(index: int) =
    let x = a[index]
    let old = frequency.getOrDefault(x, 0)

    if old == 0:
      distinctCount.inc

    frequency[x] = old + 1

  proc remove(index: int) =
    let x = a[index]
    let old = frequency[x]

    if old == 1:
      frequency.del(x)
      distinctCount.dec
    else:
      frequency[x] = old - 1

  proc save(queryId: int) =
    answer[queryId] = distinctCount

  mo.run(add, remove, save)

  check answer == @[2, 3, 2, 3]

test "Mo asymmetric callbacks for range sum":
  let a = @[5, 1, 4, 2, 3]

  var mo = initMo(a.len, blockSize = 2)

  discard mo.addQuery(0, 5)
  discard mo.addQuery(1, 4)
  discard mo.addQuery(2, 3)
  discard mo.addQuery(0, 0)

  var
    sum = 0
    answer = newSeq[int](mo.len)

  proc addLeft(index: int) =
    sum += a[index]

  proc addRight(index: int) =
    sum += a[index]

  proc removeLeft(index: int) =
    sum -= a[index]

  proc removeRight(index: int) =
    sum -= a[index]

  proc save(queryId: int) =
    answer[queryId] = sum

  mo.run(addLeft, addRight, removeLeft, removeRight, save)

  check answer == @[15, 7, 4, 0]

test "Mo ordering preserves query ids":
  var mo = initMo(100)

  for i in 0 ..< 20:
    discard mo.addQuery(i, 100 - i)

  let ordered = mo.orderedQueries()

  var ids: seq[int] = @[]

  for query in ordered:
    ids.add query.id
    check 0 <= query.l
    check query.l <= query.r
    check query.r <= 100

  ids.sort()

  check ids == toSeq(0 ..< 20)

test "Mo constructor remains usable as a procedure value":
  let constructor: proc(n, blockSize: int): Mo = initMo
  let queries: Mo = constructor(0, 0)
  check queries.len == 0

test "Mo public object construction remains supported":
  let queries = Mo(n: 3, blockSize: 1,
    queries: @[MoQuery(l: 0, r: 3, id: 0)])
  var total = 0
  proc add(i: int) = total += i + 1
  proc remove(i: int) = total -= i + 1
  proc save(id: int) = check id == 0 and total == 6
  queries.run(add, remove, save)
