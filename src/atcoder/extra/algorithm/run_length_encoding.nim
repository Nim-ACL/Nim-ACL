when not declared ATCODER_EXTRA_ALGORITHM_RUN_LENGTH_ENCODING_HPP:
  const ATCODER_EXTRA_ALGORITHM_RUN_LENGTH_ENCODING_HPP* = 1

  type
    Run*[T] = tuple[value: T, count: int]

  proc runLengthEncode*[T](
    a: openArray[T]
  ): seq[Run[T]] =
    ## Groups consecutive equal values.
    for x in a:
      if result.len == 0 or result[^1].value != x:
        result.add (value: x, count: 1)
      else:
        result[^1].count.inc

  proc runLengthEncode*(
    s: string
  ): seq[Run[char]] =
    ## String overload.
    runLengthEncode[char](s)

  proc rle*[T](
    a: openArray[T]
  ): seq[Run[T]] =
    ## Short alias of `runLengthEncode`.
    runLengthEncode(a)

  proc rle*(
    s: string
  ): seq[Run[char]] =
    ## String alias.
    runLengthEncode(s)

  proc runLengthDecode*[T](
    runs: openArray[Run[T]]
  ): seq[T] =
    ## Restores the original sequence.
    var total = 0

    for run in runs:
      doAssert run.count >= 0
      total += run.count

    result = newSeqOfCap[T](total)

    for run in runs:
      for _ in 0 ..< run.count:
        result.add run.value

  proc runLengthDecodeString*(
    runs: openArray[Run[char]]
  ): string =
    ## Restores a string.
    var total = 0

    for run in runs:
      doAssert run.count >= 0
      total += run.count

    result = newStringOfCap(total)

    for run in runs:
      for _ in 0 ..< run.count:
        result.add run.value

  proc compressedLength*[T](
    runs: openArray[Run[T]]
  ): int =
    ## Returns the number of runs.
    runs.len

  proc originalLength*[T](
    runs: openArray[Run[T]]
  ): int =
    ## Returns the decoded length.
    for run in runs:
      doAssert run.count >= 0
      result += run.count
