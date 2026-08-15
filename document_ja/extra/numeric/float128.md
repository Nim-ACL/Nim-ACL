# `float128`

`atcoder/extra/numeric/float128` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Portable IEEE 754 binary128 bit representation.
Phase F0 intentionally provides only:
- raw bit construction and decomposition
- sign, exponent and fraction extraction
- value classification
- signed zero, infinity and NaN construction
Arithmetic and numeric conversions are intentionally deferred.

## インポート

```nim
import atcoder/extra/numeric/float128
```

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `const` | `Float128ExponentBits` | 15 |
| `const` | `Float128FractionBits` | 16 |
| `const` | `Float128PrecisionBits` | 17 |
| `const` | `Float128ExponentBias` | 18 |
| `type` | `Float128` | 28 |
| `type` | `Float128Class` | 33 |
| `const` | `positiveZeroFloat128` | 42 |
| `const` | `negativeZeroFloat128` | 45 |
| `const` | `positiveInfinityFloat128` | 48 |
| `const` | `negativeInfinityFloat128` | 51 |
| `const` | `canonicalQuietNaNFloat128` | 54 |
| `const` | `canonicalSignalingNaNFloat128` | 57 |
| `func` | `fromBits` | 60 |
| `func` | `toBits` | 64 |
| `func` | `sameBits` | 68 |
| `func` | `signBit` | 72 |
| `func` | `biasedExponent` | 75 |
| `func` | `fractionHighBits` | 78 |
| `func` | `fractionLowBits` | 81 |
| `func` | `isZero` | 87 |
| `func` | `isSubnormal` | 90 |
| `func` | `isNormal` | 93 |
| `func` | `isInfinite` | 97 |
| `func` | `isNaN` | 101 |
| `func` | `isQuietNaN` | 105 |
| `func` | `isSignalingNaN` | 109 |
| `func` | `isFinite` | 113 |
| `func` | `classify` | 116 |
| `func` | `withSign` | 133 |
| `func` | `negateSign` | 141 |
| `func` | `nextUp` | 175 |
| `func` | `nextDown` | 204 |
| `func` | `copySign` | 233 |
| `func` | `totalOrder` | 258 |
| `func` | `nextAfter` | 333 |
| `func` | `totalOrderMag` | 361 |
| `func` | `minimum` | 369 |
| `func` | `maximum` | 399 |
| `func` | `minimumNumber` | 429 |
| `func` | `maximumNumber` | 450 |
| `func` | `minimumMagnitude` | 471 |
| `func` | `maximumMagnitude` | 501 |
| `func` | `minimumMagnitudeNumber` | 531 |
| `func` | `maximumMagnitudeNumber` | 552 |
| `func` | `zeroFloat128` | 573 |
| `func` | `infinityFloat128` | 579 |
| `func` | `toFloat128` | 731 |
| `proc` | `tryToUInt128` | 1018 |
| `proc` | `tryToInt128` | 1045 |
| `proc` | `tryToUInt256` | 1081 |
| `proc` | `tryToInt256` | 1108 |
| `func` | `toFloat32` | 1390 |
| `func` | `toFloat64` | 1411 |
| `func` | ``-`` | 1805 |
| `func` | ``+`` | 1813 |
| `func` | ``*`` | 1823 |
| `func` | ``/`` | 1923 |
| `func` | ``==`` | 2054 |
| `func` | ``<`` | 2070 |
| `func` | ``<=`` | 2107 |
| `func` | `sqrt` | 2141 |
| `func` | `fusedMultiplyAdd` | 2236 |
| `func` | `toHexString` | 2435 |
| `proc` | `tryParseHexFloat128` | 2456 |
| `proc` | `tryParseFloat128` | 2839 |
| `proc` | `parseFloat128` | 3051 |
| `func` | `toScientificString` | 3213 |
| `func` | `remainder` | 3962 |
| `func` | `fmod` | 3965 |
| `func` | `toShortestString` | 4768 |

## 検証

関連する tracked test / contract:

- `tests/extra/numeric/float128_add_sub_contract.nim`
- `tests/extra/numeric/float128_bits_contract.nim`
- `tests/extra/numeric/float128_comparison_contract.nim`
- `tests/extra/numeric/float128_decimal_parser_contract.nim`
- `tests/extra/numeric/float128_division_contract.nim`
- `tests/extra/numeric/float128_downconversion_contract.nim`
- `tests/extra/numeric/float128_float_conversion_contract.nim`
- `tests/extra/numeric/float128_fma_contract.nim`
- `tests/extra/numeric/float128_hex_text_contract.nim`
- `tests/extra/numeric/float128_ieee_extra_contract.nim`
- `tests/extra/numeric/float128_ieee_packet_two_a_contract.nim`
- `tests/extra/numeric/float128_ieee_packet_two_b_contract.nim`
- `tests/extra/numeric/float128_integer_conversion_contract.nim`
- `tests/extra/numeric/float128_multiplication_contract.nim`
- `tests/extra/numeric/float128_scientific_formatter_contract.nim`
- `tests/extra/numeric/float128_shortest_contract.nim`
- `tests/extra/numeric/float128_sqrt_contract.nim`
- `tests/extra/numeric/float128_to_integer_conversion_contract.nim`
- `tests/extra/numeric/float256_float128_interop_contract.nim`

## ソース

- `src/atcoder/extra/numeric/float128.nim`
