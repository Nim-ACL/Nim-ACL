when not declared ATCODER_COMPRESS_HPP:
  const ATCODER_COMPRESS_HPP* = 1

  import std/[algorithm, sets]

  type Compress[T] = seq[T]

  proc build*[T](v:var Compress[T]) =
    # Materialize before replacing v: a self-assignment can destroy it
    # before the HashSet conversion reads its elements under ORC.
    let unique = toHashSet(v)
    var built = newSeqOfCap[T](unique.len)
    for x in sets.items(unique): built.add x
    built.sort()
    swap(v, built)
  proc initCompress*[T](a:varargs[seq[T]]):Compress[T] =
    if a.len == 0:return
    for p in a:
      for x in p: result.add(x)
    result.build
  proc id*[T](c:Compress[T], a:T):int =
    result = c.binarySearch(a)
    assert result != -1, "Error: No such value: " & $a
  proc `{}`*[T](c:Compress[T], a:T):int = c.id(a)
  proc val*[T](c:Compress[T], i:int):T = c[i]
