# M193R1: expander submission-source candidate

This is a candidate, not an installed or released change. M192's 16-file fixes
and local commit are separate and are not modified by this packet.

## Scope

- `expander.py`: source/ref verification, readable provenance, deterministic
  in-process tar/xz creation, portable Python-assisted compile-time restoration.
- `run_expander.py`: argument-array invocation, proper error propagation,
  clipboard routing, persistent generated source.
- `tests/test_expander_submission.py`: 20 focused host tests.
- This document.

## Existing modes and aliases

`--mode plain`, `--mode embed`, `--mode bundle` remain available; bundle remains
the default. `--compress` maps to embed and `--compress --directory` maps to
bundle (the received version did not actually accept these legacy switches).
`--output` defaults to `combined.nim`. The wrapper keeps that file, including on
clipboard failure; it never copies output after a failed expansion.

Bundle keeps the problem solution readable and packs only referenced modules.
Unmodified library modules are packed byte-for-byte. Legacy `lib/` aliases that
require rewriting have their exact transformed source included as line comments.
Local `mylib/` files are also included as original-source comments. Embed mode
inlines modules before compression, so its exact flattened pre-compression input
is included as comments; it may therefore be larger than plain mode. Prefer
bundle for size and module boundaries. Comments do not establish prepublication
of AI-assisted local code.

## Public source references

`--source-ref` defaults to the *local* `origin/master` ref. All referenced
Nim-ACL module bytes are compared with that Git commit in one cat-file batch.
A clean but newer local commit is NOT equivalent to the public release.
An actual source mismatch is an error, not a warning. Windows CRLF-only checkout
changes are accepted and the cited Git bytes are used in the bundle.

The generated compiler bootstrap is submitted code too. Its expander source
must match `--tool-source-ref` (defaults to `--source-ref`). A newer local tool
must not cite v0.5.1 for its newly added bootstrap. `--preview` allows local tests
with an unpublished tool but clearly marks the output DO NOT SUBMIT. It does
not skip the library-content check.

These checks establish content correspondence, not public visibility or time.
The user must ensure the repository/commit (including the bootstrap) was
publicly accessible before the relevant contest. A local Git date is not proof.
`--source-repo` defaults to https://github.com/Nim-ACL/Nim-ACL; use the matching
public GitHub repository for a fork. It is the user's responsibility to verify
license conditions and separately cite any AI-assisted mylib content.

Official references checked on 2026-11-05:
- https://atcoder.jp/posts/algorithm_rules_20261014_ja
- https://info.atcoder.jp/entry/llm-rules-ja
- https://img.atcoder.jp/file/language-update/2025-10/language-list.html

## Portability and compiler flags

Generation requires Python >=3.8 with lzma and Git. No host tar/base64/rm tools
are required. Compressed output requires Python on the *compiler host* too:
`python3` by default on Unix, `python` on Windows; `NACL_PYTHON` overrides it.
The Python helper receives payload through stdin rather than a huge command
line. Generated helpers are readable, and restoration happens at compile time.
There is no runtime decompression.

Bundle still uses a second Nim compile (not a new optimization). It now uses the
actual outer compiler and forwards its command line, adding only a recursion
guard and the isolated module path. It does not force `-d:danger`, `--checks:off`,
or output `a.out`; the caller's flags/output must be preserved. This change
needs actual Nim smoke tests. Linux/Windows shell argument handling is covered
at the Python level only where explicitly reported; Windows ctypes argument
parsing and PowerShell clipboard use require a native Windows run.

The line-oriented import resolver is NOT a full Nim parser. Exotic
multiline/macro-generated import expressions remain outside the new guarantee.
Do not interpret smoke-test success as a proof for every possible Nim program.

Conditional one-line imports retain their original indentation in plain and
embed output. Separate lexical scopes have separate deduplication state; Nim,
not Python, selects `when` branches. Unguarded imported modules receive a
private generated import-once guard. Distinct flattened embed inputs for the
same module are all retained in the readable provenance comments.

Nim forbids ordinary `import` inside runtime `if` and `block` scopes; regression
tests use valid private `include` fragments there. The resolver still verifies
all referenced library bytes, including imports in inactive conditions.

## Performance evidence boundaries

This work reduces external packing/decoding commands and makes packing
reproducible. No solution runtime speedup is claimed. Compression level is an
explicit option (0..9; default 6). The primary acceptance environment is Ubuntu
with Nim 2.2.4 and the official cpp/release/speed flags. macOS and native Windows
are compatibility targets, not substitutions for that runtime benchmark.

The assistant-host tests run on Debian Linux x86_64, not Ubuntu. No Nim compiler
was available there. The supplied run-clipboard packet runs the same 20 Python
tests and eight small real Nim compile/run cases on the user's Mac: two fixture
programs across three modes with 2.2.4, plus bundle with 2.2.10. This is a
candidate checkpoint, not an automatic source install, commit, push or release.

## Local preview example (not a contest submission)

```
python3 /path/to/candidate/expander.py main.nim --lib ~/git/Nim-ACL \
  --mode bundle --source-ref v0.5.1 --preview
nim cpp -d:release --opt:speed --checks:on combined.nim
```

After the tool and library version have been validated and publicly released,
use the matching public refs and remove `--preview`. Do not publish a submission
with a source URL that merely happens to exist but does not match its code.

The Python tests create/commit only disposable synthetic Git fixtures; signing
and hooks are disabled for those fixtures, never for the canonical repository.
The packet reports those fixture Git writes separately from canonical writes.
