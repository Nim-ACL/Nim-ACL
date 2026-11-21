# Implicit Treap

Maintains a dynamic sequence with an implicit Treap whose balancing priorities
are randomized.

It supports insertion and erasure by position, element access and replacement,
range reversal, and range products.

## General form

~~~nim
proc op(
    left,
    right: S,
): S =
  ...

proc e(): S =
  ...

type
  Treap =
    ImplicitTreapType[S](
      op,
      e,
    )

var tree =
  Treap.init(
    values,
  )
~~~

An empty tree can be initialized as follows.

~~~nim
var tree =
  Treap.init()
~~~

## Parameters and types

- `S`: element and aggregate type
- `op(left, right)`: Monoid operation
- `e()`: Monoid identity
- `values`: initial sequence
- `seed`: 64-bit seed used to generate node priorities

`op` must be associative, and `e()` must be both a left and right identity.
Commutativity is not required.

The default seed is `DefaultImplicitTreapSeed`. It is fixed, so the same
operation sequence creates a reproducible tree. The seed affects only the tree
shape and running time; it does not affect returned values or correctness.

When an initial sequence is supplied, node storage is preallocated for its
length. Storage belonging to erased nodes is reused by later insertions.

## Preconditions

Let `n = tree.len`.

- `insert(position, value)`: `0 <= position <= n`
- `erase(position)`, `get(position)`, `set(position, value)`, and
  `tree[position]`: `0 <= position < n`
- `reverse(left, right)` and `prod(left, right)`:
  `0 <= left <= right <= n`

A violation raises `ValueError`.

## Return values and side effects

- `tree.len`: current length
- `tree.insert(position, value)`: inserts immediately before `position`
- `tree.erase(position)`: erases and returns one value
- `tree.get(position)`, `tree[position]`: returns one value
- `tree.set(position, value)`, `tree[position] = value`: replaces one value
- `tree.reverse(left, right)`: reverses the half-open range `[left, right)`
- `tree.prod(left, right)`: returns the product of `[left, right)`
- `tree.allProd()`: returns the product of the entire sequence
- `tree.toSeq()`: returns the current sequence as `seq[S]`

`prod` on an empty range returns `e()`.

Every subtree stores both its forward and backward aggregate. Therefore range
reversal works for noncommutative Monoids without an extra callback for
reversing an aggregate.

## Example

~~~nim
import atcoder/extra/structure/implicit_treap

proc op(
    left,
    right: int,
): int =
  left + right

proc e(): int =
  0

type
  SumTreap =
    ImplicitTreapType[int](
      op,
      e,
    )

var tree =
  SumTreap.init(
    @[1, 2, 3, 4]
  )

tree.insert(
  2,
  10,
)

doAssert tree.toSeq() ==
  @[1, 2, 10, 3, 4]

tree.reverse(
  1,
  4,
)

doAssert tree.toSeq() ==
  @[1, 3, 10, 2, 4]

doAssert tree.prod(
  1,
  4,
) == 15
~~~

## Related APIs

- `SplayTree`: dynamic sequences based on a self-adjusting tree, including
  Lazy Action variants and Link-Cut Tree infrastructure
- `PersistentSegTree`: persistent versions of a segment tree
- `LazySegTree`: range updates and products on a fixed-length sequence

This Implicit Treap is an owning container. Internal nodes and the root are not
exposed; split and merge are implementation details.

The first public version supports reversal and Monoid products, but does not
include Lazy Actions.

## Complexity and implementation

Let `n` be the current length.

Expected complexity:

- `insert`, `erase`, `get`, `set`: `O(log n)`
- `reverse`, `prod`: `O(log n)`
- `allProd`, `len`: `O(1)`
- `toSeq`: `O(n)`
- construction from `n` initial values: `O(n log n)`

The worst case is `O(n)` when the randomized tree becomes highly unbalanced.

Memory usage is `O(h)`, where `h` is the retained node slot count defined below.
Erased node slots are reused through a free list.

## Value lifetimes

The pool retains erased slots and their values until reuse, reinitialization,
overwrite, or destruction. Let `h` be the number of retained slots, including
erased ones. Value assignment copies the pool independently. Reinitialization
and overwriting a destination release its old element and aggregate values.
With custom lifetime hooks, pool destruction and reinitialization take `O(h)`,
and value assignment takes `O(h_destination + h_source)`, plus the hooks' costs.
Nim 2.2.4/2.2.10 refc may also visit such slots during a move.

For nontrivially copyable node values under refc, cleanup directly invokes the
element destructors and clears the sequence reference using Nim's `wasMoved`.
It does not assign default nodes: a user sink hook can allocate resources even
for an empty value. GC write barriers are preserved when trees are held in
managed containers. Trivially copyable values and orc retain their existing
storage path.

Value hooks must follow Nim's ownership rules. This cleanup does not replace
compiler lifetime handling for `toSeq()` results or user-owned sequences.
