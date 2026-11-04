when not declared ATCODER_EXTRA_STRING_ROLLING_HASH_HPP:
  const ATCODER_EXTRA_STRING_ROLLING_HASH_HPP* = 1
  import std/sequtils, std/strformat
  import atcoder/rangeutils

  
  template MASK*(n:static[int]):auto = (1'u shl n.uint) - 1

  const MOD = (1'u shl 61) - 1

  type RH_Base* = distinct uint
  
  #type RH* = RH_Base[(1'u shl 61) - 1, base]
  
  #converter toRH*(t:SomeInteger or char):RH = RH(h:t.uint)
  
  proc multRaw*[RH: RH_Base](a, b:RH):RH =
    let
      au = a.uint shr 31
      ad = a.uint and MASK(31)
      bu = b.uint shr 31
      bd = b.uint and MASK(31)
      mid = ad * bu + au * bd
      midu = mid shr 30
      midd = mid and MASK(30)
    RH_Base(au * bu * 2 + midu + (midd shl 31) + ad * bd)
  
  proc calcMod*[RH: RH_Base](x:RH):RH =
    let
      xu = x.uint shr 61
      xd = x.uint and MASK(61)
    result = RH_base(xu + xd)
    if result.uint >= MOD: result.uint -= MOD
  
  proc `*=`*[RH: RH_Base](a: var RH, b:RH) =  a = calcMod(multRaw(a, b))
  proc `*`*[RH: RH_Base](a, b:RH):RH = result = a;result *= b
  proc `==`*[RH: RH_Base](a, b:RH):bool = a.uint == b.uint
  proc `+=`*[RH: RH_Base](a:var RH, b:RH) =
    a.uint += b.uint
    if a.uint >= MOD: a.uint -= MOD
  proc `+`*[RH: RH_Base](a, b:RH):RH = result = a;result += b
  proc `-=`*[RH: RH_Base](a:var RH, b:RH) =
    a.uint += MOD - b.uint
    if a.uint >= MOD: a.uint -= MOD
  proc `-`*[RH: RH_Base](a, b:RH):RH = result = a;result -= b
  proc `$`*[RH: RH_Base](a: RH):string =
    let a = a.uint
    return &"{a:016x}"

 
  import hashes
  proc hash*[RH: RH_Base](a:RH):Hash = a.h.hash
  
  #const base* = 1000000007'u
  
  # baseを動的に決められるようにする
  

  type RollingHash*[base: static[uint]] = object
    len*: int
    hashed*: seq[RHBase]

  proc getPower(n:int, base: static[uint]):RH_Base =
    var a {.global.}: seq[RH_Base]
    once:
      a = newSeqOfCap[RH_Base](32)
      a.add(RH_Base(1'u))
    while a.len < n + 1:
      a.add(a[^1] * RH_Base(base))
    return a[n]
  
  proc initRollingHash*(s:string, base: static[uint] = 1000000007'u):auto =
    var
      sz = s.len
      hashed = newSeqWith(sz + 1, RH_Base(0))
    for i in 0..<sz:
      hashed[i + 1] = calcMod(multRaw(hashed[i], RH_Base(base)) + RHBase(uint(s[i])))
  #    if hashed[i + 1] >= MOD: hashed[i + 1] -= MOD
    return RollingHash[base](hashed: hashed, len: sz)

  type PartialRollingHash*[base: static[uint]] = object
    h*: RH_Base
    len*: int

  proc `==`*(a, b: PartialRollingHash): bool =
    a.len == b.len and a.h == b.h
  
  proc `[]`*(self: RollingHash; s:RangeType):PartialRollingHash[RollingHash.base] =
    let (l, r) = self.halfOpenEndpoints(s)
    result.h = calcMod(self.hashed[r] + RHBase(MOD shl 2) - multRaw(self.hashed[l], getPower(r - l, RollingHash.base)))
    result.len = r - l
  
  proc `&`*[T: PartialRollingHash](h1, h2: T):T =
    const base = T.base
    let h2len = h2.len
    result.h = calcMod(multRaw(h1.h, getPower(h2len, base)) + h2.h)
    result.len = h1.len + h2.len

  # &演算子はRH_Baseではないところに
  proc `&=`*(a:var PartialRollingHash, c:SomeInteger or char) =
    const base = PartialRollingHash.base
    a.h = multRaw(a.h, RH_Base(base))
    a.h += RHBase(uint(c))
    a.h = a.h.calcMod()
    a.len.inc
  proc `&`*(a:PartialRollingHash, c:SomeInteger or char):PartialRollingHash = result = a;result &= c
  proc `&`*(c:SomeInteger or char, a:PartialRollingHash):PartialRollingHash =
    result.h = RHBase(c) * getPower(a.len, a.base) + a.h
    result.len = a.len + 1
  proc `&`*(a:PartialRollingHash, c:string):PartialRollingHash = a & initRollingHash(c)[0 .. ^1]
  proc `&`*(c:string, a:PartialRollingHash):PartialRollingHash = initRollingHash(c)[0 .. ^1] & a

  proc LCP*(self, b:RollingHash; p1, p2:RangeType):int =
    let
      (l1, r1) = self.halfOpenEndpoints(p1)
      (l2, r2) = b.halfOpenEndpoints(p2)
    var
      low = -1
      high = min(r1 - l1, r2 - l2) + 1
    while high - low > 1:
      let mid = (low + high) div 2
      if self[l1 ..< l1 + mid] == b[l2 ..< l2 + mid]: low = mid
      else: high = mid
    return low
