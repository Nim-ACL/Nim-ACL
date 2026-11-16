# Deliberately import no header or std helpers: this must be self-contained.
import atcoder/extra/other/compress

var c = initCompress[int](@[5, 1, 5], @[3, 1])
doAssert c is seq[int]
doAssert c == @[1, 3, 5]
doAssert c.id(3) == 1
doAssert c{5} == 2
doAssert c.val(0) == 1
c.add -2
c.build()
doAssert c == @[-2, 1, 3, 5]
doAssert initCompress[int]().len == 0
doAssert initCompress[string](@["b", "a", "b"]) == @["a", "b"]
when compileOption("assertions"):
  var caught = false
  try:
    discard c.id(100)
  except AssertionDefect:
    caught = true
  doAssert caught
else:
  doAssert c.id(100) == -1
echo "COMPRESS_LEGACY_STANDALONE_OK"
