#!/usr/bin/env python3
"""Focused consolidation and API checks against local working-tree sources.

Run each stage with both installed compilers:
  python3 tools/verify_module_consolidation.py --phase mo
Override discovery with repeated --nim /path/to/nim arguments.

Expansion uses the same internal functions as the expander unit tests. Output
is temporary and explicitly marked local-only: unpublished source cannot pass
the submission CLI's source/ref check, even with --preview. This script does
not change that check or create commits. Both import orders are separate input
files, avoiding the resolver's pre-existing conditional-import limitation.
"""

import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
MODES = ("direct", "plain", "embed", "bundle")
# (source, reverse top-level library imports, test expanded modes)
CASES = {
    "p0": [
        ("tests/test_extra_chromatic_number.nim", False, True),
        ("tests/test_extra_legacy_header.nim", False, True),
        ("tests/test_extra_range_fenwick_2d_coexistence.nim", False, True),
        ("tests/test_extra_range_fenwick_2d_coexistence.nim", True, True),
        ("tests/extra/structure/dense_range_fenwicktree_2d_contract.nim", False, False),
        ("tests/extra/structure/sparse_range_fenwicktree_2d_contract.nim", False, False),
    ],
    "mo": [
        ("tests/test_extra_mo.nim", False, True),
        ("tests/test_extra_mo_legacy.nim", False, True),
        ("tests/test_extra_mo_compatibility.nim", False, True),
        ("tests/test_extra_mo_compatibility.nim", True, True),
    ],
    "kmp": [
        ("tests/test_extra_kmp.nim", False, True),
        ("tests/test_extra_kmp_random.nim", False, True),
        ("tests/test_extra_kmp_compatibility.nim", False, True),
        ("tests/test_extra_kmp_compatibility.nim", True, True),
    ],
    "monoid": [
        ("tests/test_commutative_monoid_public_contract.nim", False, True),
        # This legacy fixture has conditional imports. Embed expansion of
        # conditional imports has a pre-existing indentation limitation;
        # the public-contract fixture covers all four modes instead.
        ("tests/test_extra_monoid.nim", False, False),
        ("tests/extra/monoid/commutative_group_contract.nim", False, True),
    ],
}


def protected_state():
    """Read only: preserve the user's monoid edits and the entire index diff."""
    index = subprocess.run(
        ["git", "--no-optional-locks", "diff", "--cached", "--binary"],
        cwd=ROOT, check=True, capture_output=True,
    ).stdout
    return (ROOT / "src/atcoder/extra/monoid/monoid.nim").read_bytes(), index


def expand(expander, source, destination, mode):
    expander.SOURCE_BYTES.clear()
    expander.BUNDLE_BYTES.clear()
    expander.EMBED_TEXTS.clear()
    lines = expander.read_source(
        str(source), "", set(), ROOT / "src", ROOT, None, mode, 0,
    )
    bootstrap = ""
    if mode == "embed" and expander.EMBED_TEXTS:
        bootstrap = expander.embed_bootstrap()
    elif mode == "bundle" and expander.BUNDLE_BYTES:
        bootstrap = expander.bundle_bootstrap(None, False)
    destination.write_text(
        "# LOCAL REGRESSION TEST ONLY: unpublished sources; DO NOT SUBMIT.\n"
        + bootstrap + "\n".join(lines) + "\n", encoding="utf-8",
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase", choices=["all", *CASES], default="all")
    parser.add_argument("--nim", action="append", type=Path)
    parser.add_argument("--mm", choices=["refc", "orc"])
    parser.add_argument("--mode", action="append", choices=MODES)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    compilers = args.nim or [
        Path.home() / f".choosenim/toolchains/nim-{v}/bin/nim"
        for v in ("2.2.10", "2.2.4")
    ]
    for nim in compilers:
        if not nim.is_file():
            parser.error(f"compiler not found: {nim}; specify --nim")
    phases = list(CASES) if args.phase == "all" else [args.phase]
    if "monoid" in phases:
        print("NOTE: legacy test_extra_monoid uses direct mode; its conditional "
              "imports hit the existing embed indentation limitation.", flush=True)
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location("nacl_expander", ROOT / "expander.py")
    expander = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(expander)
    before = protected_state()
    results = []
    try:
        with tempfile.TemporaryDirectory(prefix="nacl-consolidation-") as directory:
            temp = Path(directory)
            fixtures = []
            for phase in phases:
                for number, (name, reverse, expanded) in enumerate(CASES[phase]):
                    text = (ROOT / name).read_text(encoding="utf-8")
                    if reverse:
                        imports = [line for line in text.splitlines()
                                   if line.startswith("import atcoder/extra/")]
                        assert len(imports) == 2, (name, imports)
                        # Replace by line number rather than rewrite identifiers.
                        lines = text.splitlines()
                        a, b = (lines.index(line) for line in imports)
                        lines[a], lines[b] = lines[b], lines[a]
                        text = "\n".join(lines) + "\n"
                    source = temp / f"{phase}_{number}_direct.nim"
                    source.write_text(text, encoding="utf-8")
                    modes = args.mode or MODES
                    for mode in modes:
                        if not expanded and mode != "direct":
                            continue
                        target = source
                        if mode != "direct":
                            target = temp / f"{phase}_{number}_{mode}.nim"
                            expand(expander, source, target, mode)
                        fixtures.append((phase, name, reverse, mode, target))
            for compiler_number, nim in enumerate(compilers):
                version = subprocess.run(
                    [str(nim), "--version"], check=True, capture_output=True, text=True,
                ).stdout.splitlines()[0]
                for number, (phase, name, reverse, mode, source) in enumerate(fixtures):
                    stem = f"case_{compiler_number}_{number}"
                    command = [
                        str(nim), "cpp", "-r", "--hints:off", "--warnings:off",
                        f"--path:{ROOT / 'src'}", f"--nimcache:{temp / (stem + '_cache')}",
                        f"--out:{temp / stem}",
                    ]
                    if args.mm:
                        command.append(f"--mm:{args.mm}")
                    run = subprocess.run(
                        [*command, str(source)], cwd=temp,
                        capture_output=True, text=True, timeout=180,
                    )
                    results.append(dict(phase=phase, version=version, source=name,
                                        reverse=reverse, mode=mode, exit=run.returncode))
                    status = "PASS" if run.returncode == 0 else "FAIL"
                    print(f"{status}: {version}; {name}; reverse={reverse}; {mode}", flush=True)
                    if run.returncode:
                        print((run.stdout + run.stderr)[-8000:], flush=True)
    finally:
        assert protected_state() == before, "protected monoid/index state changed"
    failures = sum(row["exit"] != 0 for row in results)
    if args.report:
        args.report.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    print(f"RESULT: {len(results) - failures} PASS; {failures} FAIL")
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
