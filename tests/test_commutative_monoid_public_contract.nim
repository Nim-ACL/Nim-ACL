import atcoder/extra/monoid/monoid

# The public Monoid contract requires value_type, op and e, not a parameter E.
type CustomSum = object
template value_type(_: typedesc[CustomSum]): typedesc = int
proc op(_: typedesc[CustomSum], a, b: int): int = a + b
proc e(_: typedesc[CustomSum]): int = 0
proc inv(_: typedesc[CustomSum], a: int): int = -a

# Even when E exists, it need not be the public value type.
type Descriptor[E] = object
template value_type(_: typedesc[Descriptor[string]]): typedesc = int
proc op(_: typedesc[Descriptor[string]], a, b: int): int = a + b
proc e(_: typedesc[Descriptor[string]]): int = 0

proc add(a, b: int): int = a + b
proc zero(): int = 0
proc neg(a: int): int = -a

type
  Generated = CommutativeMonoidOf(int, add, zero)
  Custom = CommutativeMonoidType(CustomSum)
  DifferentE = CommutativeMonoidType(Descriptor[string])
  Nested = CommutativeMonoidType(CommutativeMonoidType(Generated))
  CustomGroup = CommutativeGroupType(CustomSum)
  NestedGroup = CommutativeGroupType(CommutativeGroupOf(int, add, zero, neg))

proc sum[M: Monoid](_: typedesc[M], values: openArray[M.value_type]): M.value_type =
  result = M.e()
  for value in values:
    result = M.op(result, value)

template verify(M: typedesc) =
  static:
    doAssert M is Monoid
    doAssert M is CommutativeMonoid
    doAssert M.value_type is int
  doAssert M.e() == 0
  doAssert M.op(3, 4) == 7
  doAssert sum(M, [1, 2, 3]) == 6

verify(Generated)
verify(Custom)
verify(DifferentE)
verify(Nested)
verify(CustomGroup)
verify(NestedGroup)

static:
  doAssert CustomGroup is CommutativeGroup
  doAssert NestedGroup is CommutativeGroup
doAssert CustomGroup.inv(7) == -7
doAssert NestedGroup.inv(7) == -7

proc shift(f, x: int): int = f + x
type Action = ActedMonoidType(Custom, Nested, shift)
doAssert Action.S is int
doAssert Action.F is int
doAssert Action.op(3, 4) == 7
doAssert Action.mapping(2, 3) == 5

echo "COMMUTATIVE_MONOID_PUBLIC_CONTRACT_OK"
