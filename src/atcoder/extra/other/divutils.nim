when not declared ATCODER_DIVUTILS_HPP:
  const ATCODER_DIVUTILS_HPP* = 1
  import std/math except ceilDiv
  proc ceilDiv*[T:SomeInteger](a, b:T):T =
    ## Ceiling division, including negative operands, without intermediate overflow.
    assert b != 0
    when T is SomeSignedInt:
      if a == low(T) and b == -1:
        raise newException(OverflowDefect, "ceilDiv result is out of range")
    result = a div b
    let r = a mod b
    when T is SomeUnsignedInt:
      if r != 0: inc result
    else:
      if (r > 0 and b > 0) or (r < 0 and b < 0): inc result
  proc ceilMod*[T:SomeInteger](a, b:T):T =
    ## Remainder paired with ceilDiv; its sign is opposite to the divisor.
    ## For unsigned types only zero is representable; otherwise raises RangeDefect.
    assert b != 0
    when T is SomeSignedInt:
      # Avoid the unrepresentable quotient of low(T) / -1, even for mod.
      if b == -1: return 0
    result = a mod b
    when T is SomeUnsignedInt:
      if result != 0:
        raise newException(RangeDefect, "ceilMod result is negative for unsigned type")
    else:
      if (result > 0 and b > 0) or (result < 0 and b < 0):
        result -= b
  template `/.`*[T:SomeInteger](a, b:T):T = floorDiv(a, b)
  template `/^`*[T:SomeInteger](a, b:T):T = ceilDiv(a, b)
  template `%.`*[T:SomeInteger](a, b:T):T = floorMod(a, b)
  template `%^`*[T:SomeInteger](a, b:T):T = ceilMod(a, b)
