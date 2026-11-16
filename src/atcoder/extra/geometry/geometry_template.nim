when not declared ATCODER_GEOMETRY_TEMPLATE_HPP:
  const ATCODER_GEOMETRY_TEMPLATE_HPP* = 1
  import atcoder/extra/other/static_var
  import atcoder/extra/other/floatutils
  #import complex
  import atcoder/extra/other/internal_complex
  export internal_complex
  import std/math, std/macros
  
  type Point*[Real] = Complex[Real]
  
  #proc initPoint(re:float, im:float):Point = Point(re:re, im:im)
  #proc initPoint*[Real](re, im:Real):Point[Real] = Point[Real](re:re.Real, im:im.Real)
  proc initPoint*[Real](re, im:Real):Point[Real] = Point[Real](re:Real(re), im:Real(im))
  proc initPoint*[Real; S: not Real, T](re:S, im:T):Point[Real] = Point[Real](re:Real(re), im:Real(im))
  proc initPoint*[Real; T: not Real](re:Real, im:T):Point[Real] = Point[Real](re:Real(re), im:Real(im))
  #converter toPoint*[Real](p:(Real, Real)):Point[Real] = initPoint(p[0], p[1])
  #proc nextPoint():Point = return initPoint(nextFloat(), nextFloat())
  
  proc `*`*[Real](p:Point[Real], d:Real):Point[Real] =
    return Point[Real](re:p.re * d, im:p.im * d)
  
  proc toString*[Real](p:Point[Real]):string = $(p.re) & " " & $(p.im)
  
  # rotate point p counterclockwise by theta rad
  proc rotate*[Real](theta:Real, p:Point):Point =
    return initPoint[Real](cos(theta) * p.re - sin(theta) * p.im, sin(theta) * p.re + cos(theta) * p.im)
  
  proc radianToDegree*[Real](r:Real):Real = r * 180.Real / Real$.pi
  proc degreeToRadian*[Real](d:Real):Real = d * Real$.pi / 180.Real
  
  # smaller angle of the a-b-c
  proc getAngle*[Real](a,b,c:Point[Real]):Real =
    let
      v = b - a
      w = c - b
    var
      alpha = arctan2(v.im, v.re)
      beta = arctan2(w.im, w.re)
    if alpha > beta: swap(alpha, beta)
    let theta = beta - alpha
    return min(theta, 2.Real * Real$.pi - theta)
 
  # comparison functions {{{
  #proc eq(a,b:Real):bool = return abs(b - a) < EPS
  proc `=~`*[Real](a,b:Point[Real]):bool =
    return a.re =~ b.re and a.im =~ b.im
  
  proc `<~`*[Real](a,b:Point[Real]):bool =
    if a.re !=~ b.re: return a.re <~ b.re
    elif a.im !=~ b.im: return a.im <~ b.im
    return false
  proc `>~`*[Real](a,b:Point[Real]):bool = b <~ a
#  proc `<`*[Real](a,b:Point[Real]):bool = return a <~ b
  
  proc `<=~`*[Real](a,b:Point[Real]):bool =
    if a.re !=~ b.re: return a.re <~ b.re
    elif a.im !=~ b.im: return a.im <~ b.im
    return true
  proc `>=~`*[Real](a,b:Point[Real]):bool = b <=~ a
#  proc `<=`*[Real](a,b:Point[Real]):bool = return a <=~ b
  # }}}
  
  # Line and Segment {{{
  type Line*[Real] = object
    a*, b*:Point[Real]
  
  #type Segment[Real] {.borrow: `.`.} = distinct Line[Real]
  type Segment*[Real] = distinct Line[Real]
  proc a*[Real](self:Segment[Real]):Point[Real] = Line[Real](self).a
  proc b*[Real](self:Segment[Real]):Point[Real] = Line[Real](self).b
  
  proc initLine*[Real](a,b:Point[Real]):Line[Real] = Line[Real](a:a, b:b)
  proc initLine*[Real](A, B, C:Real):Line[Real] = # Ax + By = C
    # A, Bが両方0であってはならない
    var a, b: Point[Real]
    if A =~ 0.Real: a = initPoint[Real](0.Real, C / B); b = initPoint[Real](1.Real, C / B)
    elif B =~ 0.Real: a = initPoint[Real](C / A, 0.Real); b = initPoint[Real](C / A, 1.Real)
    elif C =~ 0.Real: a = initPoint[Real](0.Real, 0.Real); b = initPoint[Real](B, -A)
    else: a = initPoint[Real](0.Real, C / B); b = initPoint[Real](C / A, 0.Real)
    return initLine(a, b)
  proc `--`*[Real](a, b:Point[Real]):Line[Real] = initLine(a, b)
  
  proc `$`*[Real](p:Line[Real]):string =
    return "Line[" & p.a.toString & " to " & p.b.toString & "]"
  #proc nextLine():Line = initLine(nextPoint(), nextPoint())
  
  proc initSegment*[Real](a, b:Point[Real]):Segment[Real] = Segment[Real](Line[Real](a:a, b:b))
  proc `!!`*[Real](a, b:Point[Real]):Segment[Real] =
    initSegment[Real](a, b)
  #proc nextSegment():Segment = initSegment(nextPoint(), nextPoint())
  # }}}
  
  # Circle {{{
  type Circle*[Real] = object
    p*:Point[Real]
    r*:Real
  
  proc initCircle*[Real](p:Point[Real], r:Real):Circle[Real] = Circle[Real](p:p, r:r)
  proc initCircle*[Real](a, b, c: Point[Real]):Circle[Real] =
    let
      x = Real(1)/(b - a).conjugate
      y = Real(1)/(c - a).conjugate
      p = (y - x)/(x.conjugate * y - x * y.conjugate) + a
    return initCircle(p, abs(p-a))

  # }}}
  

  template swappableProcImpl(name, a, type_a, b, type_b, body:untyped) =
    proc name*[Real](a:type_a, b:type_b):auto =
      body
    proc name*[Real](b:type_b, a:type_a):auto =
      body

  macro swappableProc(a, body:untyped):untyped =
    result = newStmtList().add(newCall(ident("swappableProcImpl"), a[0], a[1][0], a[1][1], a[2][0], a[2][1], body))

  proc cross*[Real](a,b:Point[Real]):Real = a.re * b.im - a.im * b.re
  proc dot*[Real](a,b:Point[Real]):Real = a.re * b.re + a.im * b.im
  
  proc norm*[Real](a:Point[Real]):Real = dot(a,a)
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_C
  type CCWState* = enum
    ONLINE_FRONT = -2
    CLOCKWISE = -1
    ON_SEGMENT = 0
    COUNTER_CLOCKWISE = +1
    ONLINE_BACK = +2

  proc ccw*[Real](a, b, c: Point[Real]):CCWState =
    var
      b = b - a
      c = c - a
    if cross(b, c) >~ 0.Real: return CCWState.COUNTER_CLOCKWISE # "COUNTER_CLOCKWISE"
    if cross(b, c) <~ -0.Real: return CCWState.CLOCKWISE # "CLOCKWISE"
    if dot(b, c) <~ 0.Real: return CCWState.ONLINE_BACK # "ONLINE_BACK" c-a-b
    if norm(b) <~ norm(c): return CCWState.ONLINE_FRONT # "ONLINE_FRONT" a-b-c
    return CCWState.ON_SEGMENT # "ON_SEGMENT" a-c-b
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_A
  proc parallel*[Real](a,b:Line[Real]):bool = cross(a.b - a.a, b.b - b.a) =~ 0.Real
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_A
  proc orthogonal*[Real](a,b:Line[Real]):bool = dot(a.a - a.b, b.a - b.b) =~ 0.Real
  
  # projection reflection {{{
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_A
  swappableProc projection(p:Point[Real], l:Line[Real]):
    let t = dot(p - l.a, l.a - l.b) / norm(l.a - l.b)
    return Point[Real](l.a + (l.a - l.b) * complex(t))
  swappableProc projection(p:Point[Real], l:Segment[Real]):
    projection(p, Line[Real](l))
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_1_B
  swappableProc reflection(p: Point[Real], l: Line[Real]):
    return Point[Real](p + (p.projection(l) - p) * complex(2.Real))
  swappableProc reflection(p: Point[Real], l: Segment[Real]):
    reflection(p, Line[Real](l))

  # }}}
  
  # intersect function {{{
  proc intersect*[Real](l, m: Line[Real]):bool =
    cross(l.b - l.a, m.b - m.a) >~ 0 or cross(l.b - l.a, m.b - l.a) <~ 0

  swappableProc intersect(l: Line[Real], p: Point[Real]):
    cross(l.a-l.b, p-l.b) =~ 0 or cross(l.b-l.a, p-l.a) =~ 0

  swappableProc intersect(s: Segment[Real], p: Point[Real]):
    let dotp = dot(s.a-s.b, p-s.b)
    intersect(Line[Real](s), p) and (0 <=~ dotp) and (dotp <=~ norm(s.a-s.b))
  
  swappableProc intersect(l: Line[Real], s: Segment[Real]):
    cross(l.b - l.a, s.a - l.a) * cross(l.b - l.a, s.b - l.a) <~ 0.Real
  
  swappableProc intersect(c: Circle[Real], l: Line[Real]):
    abs(c.p - c.p.projection(l)) <=~ c.r
  
  swappableProc intersect(c: Circle[Real], p: Point[Real]): abs(abs(p - c.p) - c.r) =~ 0.Real
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_B
  proc intersect*[Real](s, t: Segment[Real]):bool =
    return ccw(s.a, s.b, t.a).int * ccw(s.a, s.b, t.b).int <= 0 and ccw(t.a, t.b, s.a).int * ccw(t.a, t.b, s.b).int <= 0
  
  swappableProc intersect(c: Circle[Real], l: Segment[Real]):
    let ll = Line[Real](l)
    if norm(c.p.projection(l) - c.p) - c.r * c.r >~ 0.Real: return 0
    let
      d1 = abs(c.p - ll.a)
      d2 = abs(c.p - ll.b)
    if d1 <=~ c.r and d2 <=~ c.r: return 0
    if d1 <~ c.r and d2 >~ c.r or d1 >~ c.r and d2 <~ c.r: return 1
    let h:Point[Real] = c.p.projection(l)
    if dot(ll.a - h, ll.b - h) <~ 0.Real: return 2
    return 0
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_A
  # number of common tangent
  proc intersect*[Real](c1, c2: Circle[Real]):int =
    var (c1, c2) = (c1, c2)
    if c1.r <~ c2.r: swap(c1, c2)
    let d = abs(c1.p - c2.p)
    if c1.r + c2.r <~ d: return 4
    elif c1.r + c2.r =~ d: return 3
    elif c1.r - c2.r <~ d: return 2
    elif c1.r - c2.r =~ d: return 1
    else: return 0
  # }}}
  
  # distance function {{{
  proc distance*[Real](a, b:Point[Real]):Real = abs(a - b)
  swappableProc distance(l: Line[Real], p: Point[Real]): abs(p - p.projection(l))
  proc distance*[Real](l, m: Line[Real]):Real = 
    if intersect(l, m): 0.Real else: distance(l, m.a)
  
  swappableProc distance(s: Segment[Real], p: Point[Real]):
    let r = p.projection(s)
    let d = dot(r-s.a, s.b-s.a)
    if d >= 0 and d <= abs(s.b-s.a)^2: return abs(r - p)
    return min(abs(s.a - p), abs(s.b - p))
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_D
  proc distance*[Real](a, b:Segment[Real]):Real =
    if intersect(a, b): return Real(0)
    return min(min(distance(a, b.a), distance(a, b.b)), min(distance(b, a.a), distance(b, a.b)))
  swappableProc distance(l: Line[Real], s: Segment[Real]):
    if intersect(l, s): return Real(0)
    return min(distance(l, s.a), distance(l, s.b));
  # }}}
  
  # crosspoint function {{{
  proc crosspoint*[Real](l, m:Line[Real]):Point[Real] =
    let
      A = cross(l.b - l.a, m.b - m.a)
      B = cross(l.b - l.a, l.b - m.a)
    if abs(A) =~ 0.Real and abs(B) =~ 0.Real: return m.a
    return m.a + (m.b - m.a) * complex(B) / A

  swappableProc crosspoint(l: Line[Real], s: Segment[Real]):
    return crosspoint[Real](l, Line[Real](s))
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_2_C
  proc crosspoint*[Real](l, m:Segment[Real]):Point[Real] =
    return crosspoint(Line[Real](l), Line[Real](m))
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_D
  swappableProc crosspoint(c: Circle[Real], l: Line[Real]):
    let pr = c.p.projection(l)
    let e = (l.b - l.a) / abs(l.b - l.a)
    if distance(l, c.p) =~ c.r: return (pr, pr)
    let base = sqrt(c.r * c.r - norm(pr - c.p))
    return (pr - e * complex(base), pr + e * complex(base))
  
  swappableProc crosspoint(c: Circle[Real], l: Segment[Real]):
    let
      aa = cast[Line[Real]](l)
    if intersect(c, l) == 2: return crosspoint(c, aa)
    result = crosspoint(c, aa)
    let l = Line[Real](l)
    if dot(l.a - result[0], l.b - result[0]) < 0: result[1] = result[0]
    else: result[0] = result[1]
  
  # http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=CGL_7_E
  proc crosspoint*[Real](c1, c2: Circle[Real]):(Point[Real],Point[Real]) =
    let
      d = abs(c1.p - c2.p)
      a = arccos((c1.r * c1.r + d * d - c2.r * c2.r) / (2 * c1.r * d))
      t = arctan2(c2.p.im - c1.p.im, c2.p.re - c1.p.re)
    return (c1.p + initPoint[Real](cos(t + a) * c1.r, sin(t + a) * c1.r),
            c1.p + initPoint[Real](cos(t - a) * c1.r, sin(t - a) * c1.r))
  # }}}
