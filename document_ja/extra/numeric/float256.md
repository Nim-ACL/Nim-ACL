# `float256`

`atcoder/extra/numeric/float256` の公開 API リファレンスです。
このページの API 一覧は、現在の source の export 宣言から構成しています。

## ソース上の概要

Project-local binary256-style raw representation.
This module provides:
- exact raw-bit construction and decomposition
- sign, exponent and fraction extraction
- encoding classification
- signed zero, infinity and NaN constants
- sign manipulation
- total ordering and adjacent-value operations
Native float32 / float64, Float128 and fixed-width integer conversion is available.
Parsing and formatting are available.

## インポート

```nim
import atcoder/extra/numeric/float256
```

## 公開 API

| 種別 | シンボル | source line |
|---|---|---:|
| `const` | `Float256ExponentBits` | 22 |
| `const` | `Float256FractionBits` | 23 |
| `const` | `Float256PrecisionBits` | 24 |
| `const` | `Float256ExponentBias` | 25 |
| `type` | `Float256` | 43 |
| `type` | `Float256Class` | 50 |
| `const` | `positiveZeroFloat256` | 59 |
| `const` | `negativeZeroFloat256` | 67 |
| `const` | `positiveInfinityFloat256` | 75 |
| `const` | `negativeInfinityFloat256` | 83 |
| `const` | `canonicalQuietNaNFloat256` | 91 |
| `const` | `canonicalSignalingNaNFloat256` | 99 |
| `func` | `fromBits` | 107 |
| `func` | `toBits` | 120 |
| `func` | `sameBits` | 135 |
| `func` | `signBit` | 144 |
| `func` | `biasedExponent` | 152 |
| `func` | `fractionHighBits` | 162 |
| `func` | `fractionWord2Bits` | 168 |
| `func` | `fractionWord1Bits` | 173 |
| `func` | `fractionLowBits` | 178 |
| `func` | `isZero` | 191 |
| `func` | `isSubnormal` | 197 |
| `func` | `isNormal` | 203 |
| `func` | `isInfinite` | 212 |
| `func` | `isNaN` | 219 |
| `func` | `isQuietNaN` | 226 |
| `func` | `isSignalingNaN` | 235 |
| `func` | `isFinite` | 244 |
| `func` | `classify` | 250 |
| `func` | `withSign` | 271 |
| `func` | `negateSign` | 291 |
| `func` | `nextUp` | 366 |
| `func` | `nextDown` | 389 |
| `func` | `copySign` | 412 |
| `func` | `totalOrder` | 449 |
| `func` | `nextAfter` | 531 |
| `func` | `totalOrderMag` | 556 |
| `func` | `zeroFloat256` | 565 |
| `func` | `infinityFloat256` | 573 |
| `func` | `toFloat256` | 805 |
| `proc` | `tryToUInt128` | 1053 |
| `proc` | `tryToInt128` | 1084 |
| `proc` | `tryToUInt256` | 1125 |
| `proc` | `tryToInt256` | 1156 |
| `func` | `toFloat32` | 1815 |
| `func` | `toFloat64` | 1838 |
| `func` | `toFloat128` | 2139 |
| `func` | ``-`` | 2897 |
| `func` | ``+`` | 2902 |
| `func` | ``*`` | 3064 |
| `func` | ``/`` | 3198 |
| `proc` | `tryParseHexFloat256` | 3244 |
| `proc` | `tryParseFloat256` | 3811 |
| `proc` | `parseFloat256` | 4109 |
| `func` | `toHexString` | 4135 |
| `func` | `toScientificString` | 4390 |
| `func` | `toShortestString` | 5425 |

## 検証

関連する tracked test / contract:

- `tests/extra/numeric/float256_add_sub_contract.nim`
- `tests/extra/numeric/float256_binary_float_interop_contract.nim`
- `tests/extra/numeric/float256_core_layout_contract.nim`
- `tests/extra/numeric/float256_division_contract.nim`
- `tests/extra/numeric/float256_float128_interop_contract.nim`
- `tests/extra/numeric/float256_formatting_contract.nim`
- `tests/extra/numeric/float256_integer_conversion_contract.nim`
- `tests/extra/numeric/float256_multiplication_contract.nim`
- `tests/extra/numeric/float256_parsing_contract.nim`

## ソース

- `src/atcoder/extra/numeric/float256.nim`
