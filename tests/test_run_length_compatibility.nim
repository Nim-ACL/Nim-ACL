import std/[random, sequtils, unittest]
import atcoder/extra/algorithm/run_length_encoding
import atcoder/extra/string/run_length_compress

proc naive[T](values: openArray[T]): seq[tuple[c: T, n: int]] =
  var first = 0
  while first < values.len:
    var last = first + 1
    while last < values.len and values[last] == values[first]: inc last
    result.add (c: values[first], n: last - first)
    first = last

static:
  doAssert encode(s = "aabb") == @[(c: 'a', n: 2), (c: 'b', n: 2)]
  doAssert runLengthEncode("").len == 0

suite "run-length compatibility":
  test "empty, single run, byte strings and named tuple fields":
    for s in ["", "a", "aaaaa", "abab", "\0\0\xFF\xFFa", "日本語日本語"]:
      let old: seq[tuple[c: char, n: int]] = encode(s = s)
      check old == naive[char](s)
      check decode(a = old) == s
      let current = runLengthEncode(s)
      check runLengthDecodeString(current) == s
      check old.len == current.len
      for i in 0 ..< old.len:
        check old[i].c == current[i].value
        check old[i].n == current[i].count

  test "generic values and existing decoder semantics":
    let values = @[(1, 2), (1, 2), (3, 4)]
    check encode(values) == naive(values)
    check decode(encode(values)) == values
    check encode(newSeq[int]()).len == 0
    check decode(@[(c: 2, n: 0), (c: 3, n: 2)]) == @[3, 3]
    # The legacy API repeats each string internally, then adds one element.
    check decode(@[(c: "ab", n: 2)]) == @["abab"]
    check decode(@[(c: "ab", n: 0)]) == @[""]
    expect RangeDefect:
      discard decode(@[(c: 'a', n: -1)])
    expect RangeDefect:
      discard decode(@[(c: 1, n: -1)])

  test "random differential and round trips":
    var rng = initRand(20261116)
    for trial in 0 ..< 2000:
      var values: seq[int]
      var text = ""
      for i in 0 ..< rng.rand(0 .. 100):
        let value = rng.rand(0 .. 4)
        values.add value
        text.add char(value)
      let original = values
      let old = encode(values)
      let current = runLengthEncode(values)
      check old == naive(values)
      check encode(text) == naive[char](text)
      check decode(old) == values
      check decode(encode(text)) == text
      check runLengthDecode(current) == values
      check values == original
      for i in 0 ..< old.len:
        check old[i].c == current[i].value
        check old[i].n == current[i].count
