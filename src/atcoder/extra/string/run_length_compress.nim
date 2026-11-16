when not declared ATCODER_RUN_LENGTH_COMPRESS_HPP:
  const ATCODER_RUN_LENGTH_COMPRESS_HPP* = 1
  import strutils
  import atcoder/extra/algorithm/run_length_encoding

  proc encode*(s:string):seq[tuple[c:char, n:int]] =
    for run in runLengthEncode(s):
      result.add (c: run.value, n: run.count)

  proc decode*(a:seq[tuple[c:char, n:int]]):string =
    for (c, n) in a:
      result.add c.repeat(n)

  proc encode*[T](s:seq[T]):seq[tuple[c:T, n:int]] =
    for run in runLengthEncode(s):
      result.add (c: run.value, n: run.count)

  # Keep the legacy repeat overloads: for string elements they concatenate
  # each run into one element, unlike runLengthDecode's element repetition.
  proc decode*[T](a:seq[tuple[c:T, n:int]]):seq[T] =
    for (c, n) in a:
      result.add c.repeat(n)
