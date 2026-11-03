import atcoder/header
import atcoder/lazysegtree
import atcoder/modint
import sugar

type mint = modint998244353

type S = tuple[a:mint, size:int]
type F = tuple[a:mint, b:mint]

let op = (l:S, r:S) => (l.a + r.a, l.size + r.size)
let e = () => (mint(0), 0)
let mapping = (l:F, r:S) => (r.a * l.a + r.size * l.b, r.size)
let composition = (l:F, r:F) => (r.a * l.a, r.b * l.a + l.b)
let id = () => (mint(1), mint(0))

let n, q = nextInt()
var a = newSeq[S](n)

for i in 0..<n:
  let x = nextInt()
  a[i] = (mint.init(x), 1)

var seg = initLazySegTree[S, F](a, op, e, mapping, composition, id)

for i in 0..<q:
  let t = nextInt()
  if t == 0:
    let l, r, c, d = nextInt()
    seg.apply(l..<r, (c.mint, d.mint));
  else:
    let l, r = nextInt()
    echo seg.prod(l..<r).a.val()
