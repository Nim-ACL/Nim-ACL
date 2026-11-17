when not declared ATCODER_EXTRA_MATH_MULTIPOINT_EVALUATION_BACKUP_HPP:
  const ATCODER_EXTRA_MATH_MULTIPOINT_EVALUATION_BACKUP_HPP* = 1
  import atcoder/extra/math/ntt
  import atcoder/extra/math/formal_power_series
  import std/bitops, std/sequtils, std/algorithm
  import atcoder/extra/other/reference
  proc multipointEvaluation*[mint](f: FormalPowerSeries[mint], xs: seq[mint]): seq[mint] =
    type fps = FormalPowerSeries[mint]
    let s = xs.len
    #let N = 1 << (32 - __builtin_clz((int)xs.size() - 1));
    let N = 1 shl (32 - countLeadingZeroBits(int32(xs.len - 1))) # TODO
    if f.len == 0 or xs.len == 0:
      return newSeqWith(s, mint.init(0))
    var buf = newSeq[FormalPowerSeries[mint]](2 * N)
    for i in 0 ..< N:
      var n = mint.init(if i < s: -xs[i] else: mint.init(0))
      buf[i + N] = initFormalPowerSeries[mint](@[n + 1, n - 1])
    for i in countdown(N - 1, 1):
      g =& buf[(i shl 1) or 0]
      h =& buf[(i shl 1) or 1]
      var
        n = g.len
        m = n shl 1
      buf[i] = newSeqOfCap[mint](m)
      buf[i].resize(n);
      for j in 0 ..< n:
        buf[i][j] = g[j] * h[j] - mint.init(1)
      if i != 1:
        buf[i] = buf[i].fft_doubling()
        for j in 0 ..< m:
          buf[i][j] += (if j < n: mint.init(1) else: -mint.init(1))
  
    let fs = f.len
    var root = buf[1]
    root = root.ifft(mint)
    # A singleton leaf already contains its leading one; only internal roots
    # store that coefficient implicitly after pointwise multiplication.
    if N > 1:
      root.add(mint.init(1))
    root.reverse
    root = root.inv(fs).rev() * f
    #root.erase(begin(root), begin(root) + fs - 1);
    root = root[fs - 1 .. ^1]
    root.resize(N, mint.init(0))
  
    var ans = newSeq[mint](s)
  
    proc calc(i, l, r: int, g:fps) =
      if i >= N:
        ans[i - N] = g[0]
        return
      let
        glen = g.len
        m = (l + r) shr 1
      var
        g = g.fft()
        tmp = buf[i * 2 + 1]
      for j in 0 ..< gLen: tmp[j] *= g[j]
      tmp = tmp.ifft(mint)
      calc(i * 2 + 0, l, m, tmp[(gLen shr 1) ..< tmp.len])
      if m >= s: return
      tmp = buf[i * 2 + 0];
      for j in 0 ..< gLen: tmp[j] *= g[j]
      tmp = tmp.ifft(mint)
      calc(i * 2 + 1, m, r, tmp[(gLen shr 1) ..< tmp.len])
    calc(1, 0, N, root)
    return ans
