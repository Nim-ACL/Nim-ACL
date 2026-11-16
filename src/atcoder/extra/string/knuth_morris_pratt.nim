when not declared ATCODER_KNUTH_MORRIS_PRATT_HPP:
  const ATCODER_KNUTH_MORRIS_PRATT_HPP* = 1

  import atcoder/extra/string/kmp

  proc KnuthMorrisPratt*(t, p: string): seq[int] =
    ## Legacy argument order: text, pattern. Overlapping matches are included.
    ## Preserve the old empty-text result, including the empty/empty case.
    if t.len == 0:
      return @[]
    initKMP(p).findAll(t)
