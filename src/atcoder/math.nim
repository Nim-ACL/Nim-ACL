when not declared ATCODER_MATH_HPP:
  const ATCODER_MATH_HPP* = 1

  import atcoder/internal_math
  import std/math as math_lib_of_math

  proc pow_mod*(x,n,m:int):int =
    assert 0 <= n and 1 <= m
    if m == 1: return 0
    let bt = initBarrett(m.uint)
    var
      r = 1.uint
      y = x.floorMod(m).uint
      n = n
    while n != 0:
      if (n and 1) != 0: r = bt.mul(r, y)
      y = bt.mul(y, y)
      n = n shr 1
    return r.int
  
  proc inv_mod*(x, m:int):int =
    assert 1 <= m
    let z = inv_gcd(x, m)
    assert z[0] == 1
    return z[1]
  
  # (rem, mod)
  proc crt*(r, m:openArray[int]):(int,int) =
    assert r.len == m.len
    let n = r.len
    if n == 0: return (0, 1)
    assert 1 <= m[0]
    # Contracts: 0 <= r0 < m0
    var
      r0 = floorMod(r[0], m[0])
      m0 = m[0]
    for i in 1..<n:
      assert 1 <= m[i]
      var
        r1 = floorMod(r[i], m[i])
        m1 = m[i]
      if m0 < m1:
        swap(r0, r1)
        swap(m0, m1)
      if m0 mod m1 == 0:
        if r0 mod m1 != r1: return (0, 0)
        continue
      #  assume: m0 > m1, lcm(m0, m1) >= 2 * max(m0, m1)
  
      #  (r0, m0), (r1, m1) -> (r2, m2 = lcm(m0, m1));
      #  r2 % m0 = r0
      #  r2 % m1 = r1
      #  -> (r0 + x*m0) % m1 = r1
      #  -> x*u0*g % (u1*g) = (r1 - r0) (u0*g = m0, u1*g = m1)
      #  -> x = (r1 - r0) / g * inv(u0) (mod u1)
  
      #  im = inv(u0) (mod u1) (0 <= im < u1)
      let
        (g, im) = inv_gcd(m0, m1)
        u1 = m1 div g
      # |r1 - r0| < (m0 + m1) <= lcm(m0, m1)
      if ((r1 - r0) mod g) != 0: return (0, 0)
  
      # u1 * u1 <= m1 * m1 / g / g <= m0 * m1 / g = lcm(m0, m1)
      let x = (r1 - r0) div g mod u1 * im mod u1
  
      # |r0| + |m0 * x|
      # < m0 + m0 * (u1 - 1)
      # = m0 + m0 * m1 / g - m0
      # = lcm(m0, m1)
      r0 += x * m0
      m0 *= u1  # -> lcm(m0, m1)
      if r0 < 0: r0 += m0
    return (r0, m0)

  proc floor_sum*(n, m, a, b:int):int =
    assert n in 0..<(1 shl 32)
    assert m in 1..<(1 shl 32)
    var (a, b) = (a, b)
    var ans = 0.uint
    if a < 0:
      var a2:uint = floorMod(a, m).uint
      ans -= n.uint * (n - 1).uint div 2 * ((a2 - a.uint) div m.uint)
      a = a2.int
    if b < 0:
      var b2:uint = floorMod(b, m).uint
      ans -= n.uint * ((b2 - b.uint) div m.uint)
      b = b2.int
    return cast[int](ans + floor_sum_unsigned(n.uint, m.uint, a.uint, b.uint))
