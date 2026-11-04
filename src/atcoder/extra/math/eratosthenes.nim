when not declared ATCODER_EXTRA_MATH_ERATOSTHENES_HPP:
  const ATCODER_EXTRA_MATH_ERATOSTHENES_HPP* = 1
  import atcoder/extra/math/divisor
  type Eratosthenes* = object
    n*:int
    pdiv*, prime*:seq[int32]
    index:seq[int]
  proc propagate(self:var Eratosthenes, i:int) =
    let p = self.prime[i]
    while self.index[i] < self.n:
      self.pdiv[self.index[i]] = p
      self.index[i] += p
  proc expand(self:var Eratosthenes, n = -1) =
    if n != -1 and n < self.n: return
    let n = if n == -1: self.n * 2 else: max(self.n * 2, n)
    self.pdiv.setLen(n)
    let old_n = self.n
    self.n = n
    for i in old_n ..< self.n: self.pdiv[i] = i.int32
    for i,p in self.prime:
      if p * p > self.n: break
      self.propagate(i)
    for p in old_n ..< self.n:
      if self.pdiv[p] == p:
        self.prime.add(p.int32)
        self.index.add(p * p)
        self.propagate(self.prime.len - 1)
    self.n = n
  proc initEratosthenes*(n = 10000):Eratosthenes =
    result = Eratosthenes(n: 2, pdiv: @[0'i32,0'i32])
    result.expand(n)
  proc isPrime*(self:var Eratosthenes, n:int): bool =
    self.expand(n + 1)
    return n != 0 and n != 1 and self.pdiv[n] == n
  proc primeDivisor*(self:var Eratosthenes, n:int):int =
    self.expand(n + 1)
    return self.pdiv[n]
  proc factor*(self:var Eratosthenes, n:int): seq[(int,int)] =
    result = newSeq[(int,int)]()
    var n = n
    while n > 1:
      let p = self.primeDivisor(n)
      var e = 0
      while n mod p == 0: e.inc;n = n div p
      result.add (p, e)
  proc getPrime*(self:var Eratosthenes, i:int):int =
    while i >= self.prime.len: self.expand()
    return self.prime[i]
  proc `[]`*(self:var Eratosthenes, i:int):int = self.getPrime(i)
  proc divisor*(self: var Eratosthenes, n:int):seq[int] =
    var f = self.factor(n)
    return f.divisor()
  iterator enumPrime*(self:var Eratosthenes, P = int.high):int =
    if P >= 2:
      yield 2
      var p = 3
      while true:
        if p > P: break
        if self.isPrime(p): yield p
        p += 2
