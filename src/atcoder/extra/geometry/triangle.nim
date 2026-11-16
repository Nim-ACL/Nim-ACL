when not declared ATCODER_TRIANGLE_HPP:
  const ATCODER_TRIANGLE_HPP* = 1
  import atcoder/extra/geometry/geometry_template

  proc centroid*[Real](a,b,c:Point[Real]):Point[Real] =
    result = a + b + c
    result = result / Real(3)
  
  proc incircle*[Real](a,b,c:Point[Real]):Circle[Real] =
    let
      (x, y, z) = (abs(b - c), abs(c - a), abs(a - b))
      p = (a * x + b * y + c * z)/(x + y + z)
    return initCircle(p, initLine(a, b).distance(p))
  proc incenter*[Real](a, b, c:Point[Real]):Point[Real] =
    incircle(a, b, c).p
  
  proc excircle*[Real](a,b,c:Point[Real]):array[3, Circle[Real]] =
    let
      (x, y, z) = (abs(b - c), abs(c - a), abs(a - b))
      pa = (- a * x + b * y + c * z)/(- x + y + z)
      pb = (a * x - b * y + c * z)/(x - y + z)
      pc = (a * x + b * y - c * z)/(x + y - z)
    return [initCircle(pa, initLine(b, c).distance(pa)), 
            initCircle(pb, initLine(c, a).distance(pb)), 
            initCircle(pc, initLine(a, b).distance(pc))]
  proc excenter*[Real](a, b, c:Point[Real]):array[3, Point[Real]] =
    let c = excircle(a, b, c)
    return [c[0].p, c[1].p, c[2].p]
  proc circumcircle*[Real](a,b,c:Point[Real]):Circle[Real] =
    initCircle(a, b, c)
  proc circumcenter*[Real](a,b,c:Point[Real]):Point[Real] =
    initCircle(a, b, c).p
  proc orthocenter*[Real](a,b,c:Point[Real]):Point[Real] =
    return crossPoint(
             initLine(a, a.projection(initLine(b, c))), 
             initLine(b, b.projection(initLine(a, c))))
