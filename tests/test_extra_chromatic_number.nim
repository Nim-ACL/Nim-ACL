import std/[sequtils, random]
import atcoder/extra/graph/chromatic_number

proc brute(g: seq[seq[bool]]): int =
  if g.len == 0: return 0
  var colors = newSeq[int](g.len)
  proc color(v, k: int): bool =
    if v == g.len: return true
    for c in 1 .. k:
      var valid = true
      for u in 0 ..< v:
        if g[v][u] and colors[u] == c: valid = false
      if valid:
        colors[v] = c
        if color(v + 1, k): return true
    false
  for k in 1 .. g.len:
    if color(0, k): return k

for n in 0 .. 5:
  let edges = n * (n - 1) div 2
  for mask in 0 ..< (1 shl edges):
    var g = newSeqWith(n, newSeq[bool](n))
    var bit = 0
    for u in 0 ..< n:
      for v in u + 1 ..< n:
        g[u][v] = (mask and (1 shl bit)) != 0
        g[v][u] = g[u][v]
        bit.inc
    doAssert chromatic_number(g) == brute(g), "n=" & $n & " mask=" & $mask
var rng = initRand(208)
for sample in 0 ..< 100:
  var g = newSeqWith(7, newSeq[bool](7))
  for u in 0 ..< 7:
    for v in u + 1 ..< 7:
      g[u][v] = rand(rng, 1) == 1
      g[v][u] = g[u][v]
  doAssert chromatic_number(g) == brute(g)
echo "chromatic exhaustive/random OK"
