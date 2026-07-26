# Changelog

All notable changes to Nim-ACL will be documented in this file.

The format follows Keep a Changelog, and versions use Semantic Versioning.

## [0.3.0] - 2026-07-26

This release completes the v0.3.0 two-dimensional data-structure roadmap and standardizes array-like 2D APIs on `(height, width)` dimensions, `(row, col)` indices, and half-open rectangles.

### Highlights

- Completed and closed the v0.3.0 2D roadmap with 14 source modules and 13 self-contained contract programs.
- Froze a 155-record 2D public API inventory.
- Qualified all 14 modules on Nim 2.2.10 and Nim 2.2.4 with both refc and ORC.
- Qualified all 13 contracts on Nim 2.2.10 and Nim 2.2.4 with cross-version output agreement.

### Added

- add DenseRangeFenwickTree2D.
- add CompressedDualFenwickTree2D.
- add DenseSegTree2D.
- add DenseSparseTable2D.
- add DenseDisjointSparseTable2D.
- add DenseDualSegTree2D.
- add StaticRectangleSum.
- add OfflinePointAddRectangleSum.
- add the initial FFT2D contract.

### Changed

- standardize array-like dense 2D Fenwick APIs on row-column order.
- standardize cumulative-sum 2D APIs on row-column order.
- extend the compressed FenwickTree2D contract.
- extend the cumulative-sum 2D contract.
- extend the dual cumulative-sum 2D contract.
- extend the FFT2D contract.

### Compatibility

- restore `src/atcoder/extra/structure/segtree_2d_backup.nim` byte-for-byte from its historical Git blob.
- retain coordinate-plane `(x, y)` conventions for compressed point structures where appropriate.

### Release qualification

- 14 module imports passed 56/56 lanes across Nim 2.2.10, Nim 2.2.4, refc, and ORC.
- 13 contract programs passed 26/26 lanes with 13/13 cross-version output matches.
- `nimble check` and `git fsck --full --no-dangling` passed.
- The frozen 2D public API inventory has SHA256 `e6a7cd0df1e6979eed82dc7594b7f31fa0b532a927ebda7ce2792b87be38206b`.

## [0.2.0] - 2026-07-18

This is the repository's first SemVer-tagged release. The package previously declared version `0.1.0` without a corresponding Git tag.

### Highlights

- Fixed-width numeric support: UInt128, Int128, UInt256, Int256, Float128.
- Data structures: PersistentSegTree, BinaryTrie, XorBasis, RollbackDSU.
- String algorithms: KMP, Manacher.
- Formal power series facade and constructor improvements.
- Float128 decimal parsing and fixed 36-digit scientific formatting.

### Added

- add Float128 scientific formatting.
- add Float128 decimal parsing.
- add Float128 hexadecimal text conversion.
- add Float128 fused multiply-add.
- add Float128 square root.
- add Float128 comparisons.
- add Float128 division.
- add Float128 multiplication.
- add Float128 addition and subtraction.
- add Float128 downconversions.
- add checked Float128 integer conversions.
- add Float128 float conversions.
- add Float128 integer conversions.
- add Float128 bit representation and classification.
- add portable UInt256 and Int256.
- add portable UInt128 and Int128.
- add DP optimization and curate algorithm docs.
- add experimental Japanese API facades.

### Fixed

- avoid capturing openArray in monotone minima.
- import algorithm in Kruskal.
- correct FastSet hierarchy and searches.
- restore Aho-Corasick compatibility with Nim 2.2.

### Release qualification

- The release candidate is validated with Nim 2.2.10 and Nim 2.2.4.
- Self-contained contract programs are compiled and executed on both versions.
- A public API manifest is frozen to provide a baseline for future compatibility audits.

### Deferred

- The Float128 shortest round-trip formatter is not public in this release. Its semantics were validated, but the parser-based prototype was deferred because its measured performance was unsuitable for a public formatter.
- Float256 and the broader 2D data-structure roadmap remain future work.

