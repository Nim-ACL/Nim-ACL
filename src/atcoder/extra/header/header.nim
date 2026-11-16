when not declared ATCODER_EXTRA_HEADER_HEADER_HPP:
  const ATCODER_EXTRA_HEADER_HEADER_HPP* = 1

  {.hints:off warnings:off assertions:on optimization:speed.}
  when declared(DO_CHECK):
    when DO_CHECK:
      static: echo "check is on"
      {.checks:on.}
    else:
      static: echo "check is off"
      {.checks:off.}
  else:
    static: echo "check is on"
    {.checks:on.}

  import std/algorithm as algorithm_lib
  import std/sequtils as sequtils_lib
  import std/macros as macros_lib
  import std/math as math_lib except ceilDiv
  import std/sets as sets_lib
  import std/tables as tables_lib
  import std/strutils as strutils_lib
  import std/strformat as strformat_lib
  import std/options as options_lib
  import std/bitops as bitops_lib
  import std/streams as streams_lib


  import atcoder/extra/forward_compatibility/internal_sugar
#  import std/sugar
  import atcoder/extra/other/reader
  import atcoder/extra/other/cfor
  import atcoder/extra/other/assignment_operator
  import atcoder/extra/other/inf
  import atcoder/extra/other/warlus_operator
  import atcoder/extra/other/seq_array_utils
  include atcoder/extra/other/debug
  import atcoder/extra/other/solve_proc

  when declared USE_DEFAULT_TABLE:
    when USE_DEFAULT_TABLE:
      proc `[]`[A, B](self: var Table[A, B], key: A): var B =
        discard self.hasKeyOrPut(key, B.default)
        tables_lib.`[]`(self, key)

  # converter toBool[T:ref object](x:T):bool = x != nil
  # converter toBool[T](x:T):bool = x != T(0)
  # misc
  proc `<`[T](a, b:seq[T]):bool =
    for i in 0 ..< min(a.len, b.len):
      if a[i] < b[i]: return true
      elif a[i] > b[i]: return false
    if a.len < b.len: return true
    else: return false

  proc ceilDiv*[T:SomeInteger](a, b:T):T =
    assert b != 0
    if b < 0: return ceilDiv(-a, -b)
    result = a.floorDiv(b)
    if a mod b != 0: result.inc

  template `/^`*[T:SomeInteger](a, b:T):T = ceilDiv(a, b)
