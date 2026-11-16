import std/[algorithm, hashes, random, sequtils, sets, strutils, unittest]
import atcoder/extra/other/compress
import atcoder/extra/algorithm/coordinate_compression

type
  Counted = object
    value: int
  OrderedOnly = object
    value: int
  LessOnly = distinct int

var hashCalls, lessCalls: int
proc hash(x: Counted): Hash =
  inc hashCalls
  hash(x.value)
proc `==`(a, b: Counted): bool = a.value == b.value
proc `<`(a, b: Counted): bool =
  inc lessCalls
  a.value < b.value
proc `$`(x: Counted): string = $x.value
proc hash(x: OrderedOnly): Hash {.error: "hash is intentionally unavailable".}
proc `==`(a, b: OrderedOnly): bool = a.value == b.value
proc `<`(a, b: OrderedOnly): bool = a.value < b.value
proc `$`(x: OrderedOnly): string {.error: "string conversion is intentionally unavailable".}
proc `<`(a, b: LessOnly): bool = int(a) < int(b)
proc `==`(a, b: LessOnly): bool {.error: "equality is intentionally unavailable".}

proc oracle(a: openArray[int]): seq[int] =
  for x in a:
    if x notin result: result.add x
  result.sort()

suite "Compress public and complexity contracts":
  test "legacy seq representation, pools, named arguments and mutation":
    static:
      doAssert typeof(initCompress[int]()) is seq[int]
      doAssert CoordinateCompression[int] isnot seq[int]
    check initCompress[int]().len == 0
    check initCompress[int](newSeq[int]()).len == 0
    let input = @[9, -2, 9, 1]
    var c = initCompress[int](input, @[5, -2], newSeq[int]())
    check input == @[9, -2, 9, 1]
    check c == @[-2, 1, 5, 9]
    check c.id(a = 5) == 2
    check c{9} == 3
    check c.val(i = 0) == -2
    c.add -10
    c[1] = 9
    var alias = c
    c.build()
    check c == @[-10, -2, 5, 9]
    check alias == @[-2, 9, 5, 9, -10]
    var visited: seq[int]
    for x in c: visited.add x
    check visited == c
    alias.build()
    check alias == c

  test "canonical object, open arrays and public values":
    let input = [9, -2, 9, 1]
    var cc = initCoordinateCompression(a = input)
    check cc.values == @[-2, 1, 9]
    check input == [9, -2, 9, 1]
    check cc.len == 3
    check not cc.empty
    check cc.compress(input) == @[2, 0, 2, 1]
    check cc.restore(@[2, 0, 1]) == @[9, -2, 1]
    cc.values.add 20
    check cc.indexOf(20) == 3
    check cc.decode(3) == 20
    check initCoordinateCompression(newSeq[int]()).empty

  test "missing keys, assertion modes and bounds defects remain distinct":
    let c = initCompress[int](@[1, 3, 5])
    let cc = initCoordinateCompression([1, 3, 5])
    check cc.indexOf(2) == -1
    check not cc.contains(2)
    when compileOption("assertions"):
      var caught = false
      try:
        discard c.id(2)
      except AssertionDefect as e:
        caught = true
        doAssert "Error: No such value: 2" in e.msg
      doAssert caught
    else:
      doAssert c.id(2) == -1
    expect AssertionDefect: discard cc.encode(2)
    expect AssertionDefect: discard cc.decode(-1)
    expect AssertionDefect: discard cc.decode(3)
    expect IndexDefect: discard c.val(-1)
    expect IndexDefect: discard c.val(3)

  test "legacy std binarySearch selection and canonical first occurrence":
    let duplicateValues = @[7, 7, 7, 7]
    let cc = CoordinateCompression[int](values: duplicateValues)
    check duplicateValues.id(7) == binarySearch(duplicateValues, 7)
    check cc.indexOf(7) == 0
    check cc.lowerBoundIndex(7) == 0
    check cc.upperBoundIndex(7) == 4

  test "type constraints: hash-free construction and less-only bounds":
    let cc = initCoordinateCompression([OrderedOnly(value: 3),
      OrderedOnly(value: 1), OrderedOnly(value: 3)])
    doAssert cc.len == 2
    doAssert cc.values[0].value == 1
    doAssert cc.encode(OrderedOnly(value: 3)) == 1
    static:
      doAssert not compiles(initCompress[OrderedOnly](@[OrderedOnly(value: 1)]))
      doAssert not compiles(initCoordinateCompression([LessOnly(1)]))
    let less = CoordinateCompression[LessOnly](values: @[LessOnly(1), LessOnly(3)])
    doAssert less.lowerBoundIndex(LessOnly(2)) == 1
    doAssert less.upperBoundIndex(LessOnly(3)) == 2

  test "integer extremes and strings":
    let extremes = @[high(int), low(int), 0, high(int), low(int)]
    let c = initCompress[int](extremes)
    let cc = initCoordinateCompression(extremes)
    check c == @[low(int), 0, high(int)]
    check cc.values == c
    for x in c:
      check c.val(c.id(x)) == x
      check cc.decode(cc.encode(x)) == x
    let text = @["", "aa", "a", "é", "\0", "a"]
    check initCompress[string](text) == initCoordinateCompression(text).values

  test "deterministic random differential and all query APIs":
    var rng = initRand(20261116)
    for trial in 0 ..< 300:
      let n = rng.rand(200)
      var input = newSeq[int](n)
      for x in input.mitems: x = rng.rand(-50 .. 50)
      let expected = oracle(input)
      let split = rng.rand(n)
      let c = initCompress[int](input[0 ..< split], input[split ..< n])
      let cc = initCoordinateCompression(input)
      doAssert c == expected and cc.values == expected
      doAssert cc.restore(cc.compress(input)) == input
      for x in -55 .. 55:
        var lower, upper: int
        for value in expected:
          if value < x: inc lower
          if value <= x: inc upper
        let index = expected.find(x)
        doAssert cc.lowerBoundIndex(x) == lower
        doAssert cc.upperBoundIndex(x) == upper
        doAssert cc.indexOf(x) == index
        doAssert cc.contains(x) == (index >= 0)
        if index >= 0:
          doAssert c.id(x) == index and cc.encode(x) == index

  test "legacy sorts u keys, preserves linear hash work, canonical needs no hash":
    const n = 100_000
    const u = 16
    let input = newSeqWith(n, Counted(value: 0))
    var values = input
    for i in 0 ..< n: values[i].value = i mod u
    hashCalls = 0
    lessCalls = 0
    let c = initCompress[Counted](values)
    doAssert c.len == u
    doAssert hashCalls >= n and hashCalls <= 4 * n
    # A sort of all n interleaved keys would greatly exceed this u-sized bound.
    doAssert lessCalls <= 4096
    hashCalls = 0
    lessCalls = 0
    let cc = initCoordinateCompression(values)
    doAssert cc.len == u
    doAssert hashCalls == 0
    doAssert lessCalls <= 64 * n * 17

  test "large high-duplicate and distinct pools":
    block:
      var input = newSeq[int](500_000)
      for i in 0 ..< input.len: input[i] = i mod 32
      let c = initCompress[int](input)
      let cc = initCoordinateCompression(input)
      doAssert c.len == 32 and cc.values == c
    block:
      var input = newSeq[int](250_000)
      for i in 0 ..< input.len: input[i] = input.len - 1 - i
      let c = initCompress[int](input)
      let cc = initCoordinateCompression(input)
      doAssert c.len == input.len and cc.values == c
      for i in 0 ..< input.len: doAssert c[i] == i

echo "COMPRESS_PUBLIC_AND_COMPLEXITY_CONTRACT_OK"
