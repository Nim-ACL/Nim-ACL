when not declared ATCODER_SLOPE_TRICK_HPP:
  const ATCODER_SLOPE_TRICK_HPP* = 1
#  const T INF[T] = numeric_limits< T >::max() / 3;
  import heapqueue

  type SlopeTrick*[T] = object
    min_f, inf:T
    L, R:HeapQueue[T]
    add_left, add_right: T
#    priority_queue< T, vector< T >, less<> > L;
#    priority_queue< T, vector< T >, greater<> > R;

  proc initSlopeTrick*[T]():SlopeTrick[T] =
    return SlopeTrick[T](min_f: 0, inf:T.high div 3, add_left: 0, add_right: 0)

  proc push_R*[T](self: var SlopeTrick[T], a:T) =
    self.R.push(a - self.add_right)
 
  proc top_R*[T](self:SlopeTrick[T]):T =
    if self.R.len == 0: return self.inf
    else: return self.R[0] + self.add_right
 
  proc pop_R*[T](self:var SlopeTrick[T]):T =
    var val = self.top_R()
    if self.R.len > 0: discard self.R.pop()
    return val

  proc push_L*[T](self:var SlopeTrick[T], a:T) =
    self.L.push(-(a - self.add_left))
 
  proc top_L*[T](self: SlopeTrick[T]):T =
    if self.L.len == 0: return -self.inf
    else: return -self.L[0] + self.add_left
 
  proc pop_L*[T](self:var SlopeTrick[T]):T =
    var val = self.top_L()
    if self.L.len > 0: discard self.L.pop()
    return val
 
  proc len*[T](self:SlopeTrick[T]):int =
    return self.L.len + self.R.len
 
#public:
#  SlopeTrick() : min_f(0), add_left(0), add_right(0) {}
 
  type Query*[T] = object
    lx*, rx*, min_f*:T

  # return min f(x)
  proc query*[T](self:SlopeTrick[T]):Query[T] =
    return Query[T](lx:self.top_L(), rx:self.top_R(), min_f:self.min_f)

  # f(x) += a
  proc add_all*[T](self:var SlopeTrick[T], a:T) =
    self.min_f += a

  # add \_
  # f(x) += max(a - x, 0)
  proc add_a_minus_x*[T](self: var SlopeTrick[T], a:T) =
    self.min_f += max(T(0), a - self.top_R())
    self.push_R(a)
    self.push_L(self.pop_R())

  # add _/
  # f(x) += max(x - a, 0)
  proc add_x_minus_a*[T](self: var SlopeTrick[T], a:T) =
    self.min_f += max(T(0), self.top_L() - a)
    self.push_L(a)
    self.push_R(self.pop_L())

  # add \/
  # f(x) += abs(x - a)
  proc add_abs*[T](self: var SlopeTrick[T], a:T) =
    self.add_a_minus_x(a)
    self.add_x_minus_a(a)

  # \/ -> \_
  # f_{new} (x) = min f(y) (y <= x)
  proc clear_right*[T](self: var SlopeTrick[T]) =
    while self.R.len > 0: discard self.R.pop()
 
  # \/ -> _/
  # f_{new} (x) = min f(y) (y >= x)
  proc clear_left*[T](self: var SlopeTrick[T]) =
    while self.L.len > 0: discard self.L.pop()
 
  # \/ -> \_/
  # f_{new} (x) = min f(y) (x-b <= y <= x-a)
  proc shift*[T](self: var SlopeTrick[T], a, b:T) =
    assert a <= b
    self.add_left += a
    self.add_right += b
 
  # \/. -> .\/
  # f_{new} (x) = f(x - a)
  proc shift*[T](self: var SlopeTrick[T], a:T) =
    self.shift(a, a)
 
  # L, R を破壊する
  proc get*[T](self: var SlopeTrick[T], x:T):T =
    result = self.min_f
    while self.L.len > 0:
      result += max(T(0), self.pop_L() - x)
    while self.R.len > 0:
      result += max(T(0), x - self.pop_R())
 
  proc merge*[T](self, st: var SlopeTrick[T]) =
    if st.len > self.len:
      swap st.L, self.L
      swap st.R, self.R
      swap st.add_left, self.add_left
      swap st.add_right, self.add_right
      swap st.min_f, self.min_f
    while st.R.len > 0:
      self.add_x_minus_a(st.pop_R())
    while st.L.len > 0:
      self.add_a_minus_x(st.pop_L())
    self.min_f += st.min_f
