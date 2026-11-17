# verification-helper: PROBLEM https://judge.yosupo.jp/problem/point_add_rectangle_sum

import std/strutils
import atcoder/extra/monoid/monoid
import atcoder/extra/structure/compressed_fenwicktree_2d

proc addInt64(
    a,
    b: int64
): int64 =
  a + b

proc zeroInt64(): int64 =
  0'i64

proc negateInt64(
    value: int64
): int64 =
  -value

type
  AdditiveGroup =
    CommutativeGroupOf(
      int64,
      addInt64,
      zeroInt64,
      negateInt64,
    )

  InitialPoint =
    object
      x, y: int

      weight: int64

  Query =
    object
      kind: int

      xLeft, yLeft, xRight, yRight: int

      weight: int64

let tokens =
  stdin.readAll.splitWhitespace()

var tokenIndex =
  0

proc nextToken(): string =
  result =
    tokens[tokenIndex]

  inc tokenIndex

proc nextInt(): int =
  parseInt(
    nextToken()
  )

proc nextInt64(): int64 =
  parseBiggestInt(
    nextToken()
  )

let n =
  nextInt()

let q =
  nextInt()

var initialPoints:
  seq[InitialPoint]

var builder =
  initCompressedFenwickTree2DBuilder()

for _ in 0 ..< n:
  let point =
    InitialPoint(
      x:
        nextInt(),
      y:
        nextInt(),
      weight:
        nextInt64(),
    )

  initialPoints.add(
    point
  )

  builder.addPoint(
    point.x,
    point.y,
  )

var queries:
  seq[Query]

for _ in 0 ..< q:
  let kind =
    nextInt()

  if kind == 0:
    let query =
      Query(
        kind:
          kind,
        xLeft:
          nextInt(),
        yLeft:
          nextInt(),
        weight:
          nextInt64(),
      )

    queries.add(
      query
    )

    builder.addPoint(
      query.xLeft,
      query.yLeft,
    )
  else:
    queries.add(
      Query(
        kind:
          kind,
        xLeft:
          nextInt(),
        yLeft:
          nextInt(),
        xRight:
          nextInt(),
        yRight:
          nextInt(),
      )
    )

var tree =
  builder.build(
    AdditiveGroup
  )

for point in initialPoints:
  tree.add(
    point.x,
    point.y,
    point.weight,
  )

for query in queries:
  if query.kind == 0:
    tree.add(
      query.xLeft,
      query.yLeft,
      query.weight,
    )
  else:
    echo tree.sum(
      query.xLeft,
      query.xRight,
      query.yLeft,
      query.yRight,
    )
