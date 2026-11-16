## Compile identical sources/flags against both checkouts via --path.
## Args: empty|equal|duplicates|shuffled|sorted|reverse|strings|lookup.
## cpuTime excludes input/oracle preparation; every constructed result is checked.
import std/[algorithm, os, sequtils, sets, strutils, times]
import atcoder/extra/other/compress

proc fingerprint(a: openArray[int]): uint64 =
  result = 14695981039346656037'u64
  for x in a: result = (result xor cast[uint64](x)) * 1099511628211'u64

proc fingerprint(a: openArray[string]): uint64 =
  result = 14695981039346656037'u64
  for x in a:
    for ch in x: result = (result xor uint64(ord(ch))) * 1099511628211'u64

proc uniqueOracle[T](a: openArray[T]): seq[T] =
  let ordered = sorted(a)
  for x in ordered:
    if result.len == 0 or result[^1] != x: result.add x

proc next(state: var uint64): int =
  state = state xor (state shl 13)
  state = state xor (state shr 7)
  state = state xor (state shl 17)
  int(state and 0x7FFFFFFF'u64)

proc construct[T](input: seq[T], repetitions: int): tuple[seconds: float64, checksum: uint64] =
  let expected = fingerprint(uniqueOracle(input))
  GC_fullCollect()
  let started = cpuTime()
  for i in 0 ..< repetitions:
    let c = initCompress[T](input)
    let actual = fingerprint(c)
    doAssert actual == expected
    result.checksum = result.checksum xor (actual + uint64(i))
  result.seconds = cpuTime() - started

let scenario = paramStr(1)
var seconds: float64
var checksum: uint64
if scenario == "strings":
  var input = newSeq[string](20_000)
  for i in 0 ..< input.len: input[i] = "key-" & align($(i * 7919 mod 5000), 4, '0')
  (seconds, checksum) = construct(input, 40)
elif scenario == "lookup":
  var input = newSeq[int](65_536)
  for i in 0 ..< input.len: input[i] = i
  let c = initCompress[int](input)
  doAssert c == input
  var queries = newSeq[int](1_000_000)
  var state = 20261116'u64
  var expected: uint64
  for x in queries.mitems:
    x = state.next mod input.len
    expected += uint64(x)
  GC_fullCollect()
  let started = cpuTime()
  for x in queries: checksum += uint64(c.id(x))
  seconds = cpuTime() - started
  doAssert checksum == expected
else:
  doAssert scenario in ["empty", "equal", "duplicates", "shuffled", "sorted", "reverse"]
  let size = if scenario == "empty": 0 elif scenario == "shuffled": 65_536 else: 100_000
  let repetitions = if scenario == "empty": 3_000_000
                    elif scenario in ["equal", "duplicates"]: 100
                    elif scenario == "shuffled": 50 else: 30
  var input = newSeq[int](size)
  for i in 0 ..< size:
    input[i] = if scenario == "equal": 7
               elif scenario == "duplicates": i mod 16
               elif scenario == "reverse": size - 1 - i else: i
  if scenario == "shuffled":
    var state = 20261116'u64
    for i in countdown(size - 1, 1): swap(input[i], input[state.next mod (i + 1)])
  (seconds, checksum) = construct(input, repetitions)
echo "case=", scenario, " cpu=", seconds, " checksum=", checksum, " valid=true"
