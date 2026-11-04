when not declared ATCODER_STATIC_ERATOSTHENES_HPP:
  const ATCODER_STATIC_ERATOSTHENES_HPP* = 1
  import atcoder/extra/math/divisor
  type Eratosthenes*[n:static[int]] = object
    pdiv*: array[n + 1, int32]
  proc init*(self: var Eratosthenes) =
    let n = self.n
    for i in 1 .. n:
      self.pdiv[i] = i.int32
    for i in 2 .. n:
      if self.pdiv[i] == i:
        var m = i * i
        while m <= n:
          self.pdiv[m] = i.int32
          m += i
  proc initEratosthenes*(n:static[int]):Eratosthenes[n] =
    result.init()
  proc isPrime*(self:Eratosthenes, n:int): bool =
    return n != 0 and n != 1 and self.pdiv[n] == n
  proc primeDivisor*(self:Eratosthenes, n:int):int =
    return self.pdiv[n]
  proc factor*(self:var Eratosthenes, n:int): seq[(int,int)] =
    result = newSeq[(int,int)]()
    var n = n
    while n > 1:
      let p = self.primeDivisor(n)
      var e = 0
      while n mod p == 0: e.inc;n = n div p
      result.add (p, e)
  #proc getPrime*(self:var Eratosthenes, i:int):int =
  #  while i >= self.prime.len: self.expand()
  #  return self.prime[i]
  #proc `[]`*(self:var Eratosthenes, i:int):int = self.getPrime(i)
  proc divisor*(self: var Eratosthenes, n:int):seq[int] =
    var f = self.factor(n)
    return f.divisor()

