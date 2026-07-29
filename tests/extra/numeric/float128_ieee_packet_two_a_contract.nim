import atcoder/extra/numeric/float128

var packetTwoCheckCount =
  0

let packetTwoPosZero =
  fromBits(0x0000000000000000'u64, 0x0000000000000000'u64)

let packetTwoNegZero =
  fromBits(0x8000000000000000'u64, 0x0000000000000000'u64)

let packetTwoPosOne =
  fromBits(0x3fff000000000000'u64, 0x0000000000000000'u64)

let packetTwoNegOne =
  fromBits(0xbfff000000000000'u64, 0x0000000000000000'u64)

let packetTwoPosTwo =
  fromBits(0x4000000000000000'u64, 0x0000000000000000'u64)

let packetTwoNegTwo =
  fromBits(0xc000000000000000'u64, 0x0000000000000000'u64)

let packetTwoPosMaxFinite =
  fromBits(0x7ffeffffffffffff'u64, 0xffffffffffffffff'u64)

let packetTwoNegMaxFinite =
  fromBits(0xfffeffffffffffff'u64, 0xffffffffffffffff'u64)

let packetTwoPosInf =
  fromBits(0x7fff000000000000'u64, 0x0000000000000000'u64)

let packetTwoNegInf =
  fromBits(0xffff000000000000'u64, 0x0000000000000000'u64)

let packetTwoPosSNaN1 =
  fromBits(0x7fff000000000000'u64, 0x0000000000000001'u64)

let packetTwoPosQNaN1 =
  fromBits(0x7fff800000000000'u64, 0x0000000000000001'u64)

let packetTwoPosQNaN2 =
  fromBits(0x7fff800000000000'u64, 0x0000000000000002'u64)

let packetTwoNegSNaN1 =
  fromBits(0xffff000000000000'u64, 0x0000000000000001'u64)

let packetTwoNegQNaN1 =
  fromBits(0xffff800000000000'u64, 0x0000000000000001'u64)

doAssert sameBits(
  nextAfter(packetTwoPosZero, packetTwoNegZero),
  fromBits(0x8000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoNegZero, packetTwoPosZero),
  fromBits(0x0000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoPosOne, packetTwoPosTwo),
  fromBits(0x3fff000000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoPosOne, packetTwoNegTwo),
  fromBits(0x3ffeffffffffffff'u64, 0xffffffffffffffff'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoPosInf, packetTwoNegInf),
  fromBits(0x7ffeffffffffffff'u64, 0xffffffffffffffff'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoNegInf, packetTwoPosInf),
  fromBits(0xfffeffffffffffff'u64, 0xffffffffffffffff'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoPosSNaN1, packetTwoPosOne),
  fromBits(0x7fff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoPosOne, packetTwoNegSNaN1),
  fromBits(0xffff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  nextAfter(packetTwoPosQNaN2, packetTwoPosSNaN1),
  fromBits(0x7fff800000000000'u64, 0x0000000000000002'u64),
)
inc packetTwoCheckCount

doAssert (
  totalOrderMag(packetTwoNegZero, packetTwoPosZero)
) == true
inc packetTwoCheckCount

doAssert (
  totalOrderMag(packetTwoPosZero, packetTwoNegZero)
) == true
inc packetTwoCheckCount

doAssert (
  totalOrderMag(packetTwoNegOne, packetTwoPosOne)
) == true
inc packetTwoCheckCount

doAssert (
  totalOrderMag(packetTwoPosOne, packetTwoNegOne)
) == true
inc packetTwoCheckCount

doAssert (
  totalOrderMag(packetTwoPosSNaN1, packetTwoPosQNaN1)
) == true
inc packetTwoCheckCount

doAssert (
  totalOrderMag(packetTwoPosQNaN1, packetTwoPosSNaN1)
) == false
inc packetTwoCheckCount

doAssert sameBits(
  minimum(packetTwoPosZero, packetTwoNegZero),
  fromBits(0x8000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximum(packetTwoPosZero, packetTwoNegZero),
  fromBits(0x0000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimum(packetTwoNegTwo, packetTwoPosOne),
  fromBits(0xc000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximum(packetTwoNegTwo, packetTwoPosOne),
  fromBits(0x3fff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimum(packetTwoPosSNaN1, packetTwoPosOne),
  fromBits(0x7fff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximum(packetTwoPosOne, packetTwoNegSNaN1),
  fromBits(0xffff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimum(packetTwoPosQNaN2, packetTwoPosSNaN1),
  fromBits(0x7fff800000000000'u64, 0x0000000000000002'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximum(packetTwoPosQNaN2, packetTwoPosSNaN1),
  fromBits(0x7fff800000000000'u64, 0x0000000000000002'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumNumber(packetTwoPosSNaN1, packetTwoPosOne),
  fromBits(0x3fff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumNumber(packetTwoPosOne, packetTwoPosQNaN1),
  fromBits(0x3fff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumNumber(packetTwoPosSNaN1, packetTwoPosQNaN2),
  fromBits(0x7fff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumNumber(packetTwoNegSNaN1, packetTwoPosQNaN2),
  fromBits(0xffff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumMagnitude(packetTwoPosOne, packetTwoNegOne),
  fromBits(0xbfff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumMagnitude(packetTwoPosOne, packetTwoNegOne),
  fromBits(0x3fff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumMagnitude(packetTwoNegTwo, packetTwoPosOne),
  fromBits(0x3fff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumMagnitude(packetTwoNegTwo, packetTwoPosOne),
  fromBits(0xc000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumMagnitude(packetTwoPosSNaN1, packetTwoPosOne),
  fromBits(0x7fff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumMagnitude(packetTwoPosOne, packetTwoNegSNaN1),
  fromBits(0xffff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumMagnitudeNumber(packetTwoPosSNaN1, packetTwoNegTwo),
  fromBits(0xc000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumMagnitudeNumber(packetTwoPosTwo, packetTwoPosQNaN1),
  fromBits(0x4000000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumMagnitudeNumber(packetTwoPosSNaN1, packetTwoPosQNaN2),
  fromBits(0x7fff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumMagnitudeNumber(packetTwoNegSNaN1, packetTwoPosQNaN2),
  fromBits(0xffff800000000000'u64, 0x0000000000000001'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimum(packetTwoNegInf, packetTwoPosInf),
  fromBits(0xffff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximum(packetTwoNegInf, packetTwoPosInf),
  fromBits(0x7fff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  minimumMagnitude(packetTwoNegInf, packetTwoPosMaxFinite),
  fromBits(0x7ffeffffffffffff'u64, 0xffffffffffffffff'u64),
)
inc packetTwoCheckCount

doAssert sameBits(
  maximumMagnitude(packetTwoNegInf, packetTwoPosMaxFinite),
  fromBits(0xffff000000000000'u64, 0x0000000000000000'u64),
)
inc packetTwoCheckCount

doAssert packetTwoCheckCount == 41

echo "FLOAT128_IEEE_PACKET_TWO_A_CONTRACT_OK\t10\t41"
