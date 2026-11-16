when not declared ATCODER_CHROMATIC_NUMBER_HPP:
  const ATCODER_CHROMATIC_NUMBER_HPP* = 1
  import sequtils, bitops, math
  
  proc chromatic_number*(g:seq[seq[bool]]):int =
    let N = g.len
    var es = newSeq[int](N)
    for i in 0..<N:
      for j in 0..<N:
        if g[i][j]: es[i] = es[i] or (1 shl j)
    result = N
    for d in [7, 11, 21]:
      let MOD = 10^9 + d
      var
        ind = newSeq[int](2^N)
        aux = newSeqWith(2^N, 1)
      ind[0] = 1
      for S in 1 ..< 2^N:
        let u = countTrailingZeroBits(S)
        ind[S] = ind[S xor (1 shl u)] + ind[(S xor (1 shl u)) and not es[u]]
      for i in 1 ..< result:
        var all = 0
        for j in 0 ..< 2^N:
          let S = j xor (j shr 1)
          aux[S] = (aux[S] * ind[S]) mod MOD
          all += (if (j and 1) != 0: aux[S] else: MOD - aux[S])
        if all mod MOD != 0: result = i
