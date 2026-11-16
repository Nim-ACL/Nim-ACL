# Contributing to Nim-ACL

This repository keeps compatibility with existing Nim-ACL / ACL-style APIs while adding small convenience facades, tests, and documentation.

## Local verification policy

Before pushing changes that touch library code, tests, or documentation, run:

~~~bash
bash tools/quick_verify.sh
~~~

For a review that must preserve existing uncommitted and staged changes, use:

~~~bash
NACL_VERIFY_WORKTREE=1 bash tools/quick_verify.sh
~~~

This opt-in mode checks generated documentation against its starting content
and checks file contents, executable bits, and staged changes at the end. Regenerate and
review documentation first; newly generated differences still fail validation.
It never resets documentation, including when `CI=true`. The default clean-tree
verification policy is unchanged.

The script runs the main smoke tests for:

- core ACL modules
- extra FPS facade
- monoid helpers
- graph template / graph algorithm helpers
- universal segtree
- generated documentation consistency

It writes the full log to:

~~~text
/tmp/nacl_quick_verify.log
~~~

and prints a short final result block:

~~~text
===== NACL RESULT START =====
STATUS: OK
...
===== NACL RESULT END =====
~~~

When sharing logs in issue comments or review threads, prefer sharing only this final `NACL RESULT` block unless the status is `NG`.

## Documentation policy

Documentation is generated from `document_ja/**/*.md` and `document_en/**/*.md`.

To regenerate docs, publish to `gh-pages`, and run a short live-page sanity check, run:

~~~bash
bash tools/publish_docs.sh
~~~

The script writes the full log to:

~~~text
/tmp/nacl_publish_docs.log
~~~

and prints a short final `NACL RESULT` block.

## CI policy

The `quick-verify` GitHub Actions workflow should call:

~~~bash
bash tools/quick_verify.sh
~~~

This keeps CI behavior aligned with the local smoke test.

In CI, `tools/quick_verify.sh` treats generated documentation diffs as non-strict by default. This avoids Linux/macOS documentation rendering drift from failing unrelated code checks. Documentation publication remains the responsibility of `tools/publish_docs.sh`. Set `NACL_STRICT_DOCS=1` to make CI fail on generated documentation diffs.

When adding a new facade or user-facing helper, prefer the following sequence:

1. Add or update implementation.
2. Add targeted tests.
3. Add or update Japanese documentation.
4. Run `bash tools/quick_verify.sh`.
5. Commit and push.
6. Run `bash tools/publish_docs.sh` when documentation changed.

## Generated binaries

Local Nim test runs may generate executable files next to test files and may also create `.nim_runtime/` or `nimcache/`. Verification scripts remove the known generated test artifacts automatically. Do not commit generated binaries or generated runtime directories.

## Warning policy

Nim/C++ backend warnings such as generated-array-bound warnings may appear during local test builds. Treat them as warnings unless the test command fails. A successful run must still end with `STATUS: OK` in the `NACL RESULT` block.

## Documentation policy for advanced algorithms

For advanced or less common algorithms, documentation should be usable as both
an API reference and a short learning note.

Prefer the following structure:

1. Overview: what problem the algorithm solves.
2. Use cases: common contest patterns and representative problems.
3. Idea: the core invariant or greedy/DP/graph principle.
4. API reference: import, types, constructors, operations.
5. Nim-friendly usage: operators, iterators, templates, or macros when helpful.
6. Complexity and pitfalls.
7. Related resources and libraries.

Do not copy implementations from other languages into the documentation.
When other public competitive-programming libraries are useful references, link
to them instead.

## Nim documentation syntax highlighting

Generated documentation uses Nim's official
`packages/docutils/highlite` tokenizer.

Use a normal Nim fence for API definitions and short fragments:

~~~markdown
~~~nim
proc prod(tree: SqrtTree, l, r: int): T
~~~
~~~

Substantial usage examples should display line numbers. Place this marker
immediately before the Nim code block:

~~~markdown
<!-- nim-line-numbers -->
~~~nim
import atcoder/extra/structure/sqrt_tree

proc add(a, b: int): int = a + b

let tree = initSqrtTree(@[1, 2, 3], 0, add)
doAssert tree.prod(0, 3) == 6
~~~
~~~

The marker utility automatically adds the marker to substantial Nim blocks
under headings such as `使用例`, `実行例`, `Example`, and `Usage`:

~~~bash
python3 tools/mark_complete_nim_examples.py
~~~

To suppress automatic line numbering in an example section, place:

~~~html
<!-- nim-no-line-numbers -->
~~~

Line numbers are rendered with CSS counters and are not part of the copied
source text. Syntax highlighting and line numbers do not depend on a CDN or
browser-side JavaScript.

## Documentation link policy

Entries under `関連資料`, `Related resources`, `References`, and similar
sections should use concrete links rather than plain resource names.

- Internal Nim-ACL documentation uses relative links and opens in the same tab.
- External HTTP/HTTPS links open in a new tab.
- Generated external links include `target="_blank" rel="noopener"`.
- `noreferrer` is not added by default, so ordinary referral information is
  preserved.
- Prefer official documentation, original papers, official problem pages,
  and primary project repositories.
- Do not reproduce substantial external text, figures, or source code merely
  to avoid linking to the original source.

Run the related-resource linker and audit with:

~~~bash
python3 tools/link_related_resources.py
python3 tools/link_related_resources.py --audit-only
python3 tools/postprocess_document_links.py
python3 tools/audit_generated_document_html.py
~~~

## Nim compiler compatibility policy

Required CI and verification profiles are:

- `latest`: Nim `2.2.10`
- `atcoder`: Nim `2.2.4`

Both profiles run `tools/quick_verify.sh`.
The manual `oj-verify` workflow also runs both profiles independently.

AtCoder additionally provides Nim `1.6.20`.
It is recorded as `atcoder_legacy` in
`tools/nim_version_policy.json`, but it is not currently a required
per-push compatibility target.

To run the local suite after selecting a compiler with a version
manager:

~~~bash
bash tools/run_nim_compatibility.sh latest
bash tools/run_nim_compatibility.sh atcoder
~~~

When either the current stable Nim release or the AtCoder judge
environment changes, update the policy file and both workflow
matrices in the same commit. The quick verification suite audits
their consistency.
