discard """
  cmd: "nim cpp -r $file"
"""

import std/unittest
import atcoder/extra/string/minimum_rotation

test "minimum string rotation":
  check minimumRotationIndex("bbaaccaadd") == 2
  check minimumRotation("bbaaccaadd") == "aaccaaddbb"

  check minimumRotationIndex("caba") == 1
  check minimumRotation("caba") == "abac"

test "equal characters choose zero":
  check minimumRotationIndex("aaaa") == 0
  check maximumRotationIndex("aaaa") == 0

test "maximum rotation":
  check maximumRotationIndex("abac") == 3
  check maximumRotation("abac") == "caba"

test "generic sequence":
  let a = @[3, 1, 2, 1]

  check minimumRotationIndex(a) == 1
  check minimumRotation(a) == @[1, 2, 1, 3]
  check maximumRotation(a) == @[3, 1, 2, 1]

test "empty sequence":
  check minimumRotationIndex("") == 0
  check minimumRotation("") == ""
  check minimumRotation(newSeq[int]()) == newSeq[int]()
