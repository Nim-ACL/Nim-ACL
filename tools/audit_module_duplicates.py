#!/usr/bin/env python3
"""Inventory tracked Nim modules and lexical duplication signals.

This is a triage aid, not a Nim parser or proof that a module can be removed.
Public imports, tuple fields, callback contracts and algorithmic complexity
still need a compatibility review before replacing any implementation.
"""

import argparse
from collections import Counter, defaultdict
import hashlib
import itertools
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def git_paths(*args):
    # -z is essential: Git otherwise quotes the Japanese facade filenames.
    return [name.decode("utf-8") for name in subprocess.check_output(
        ["git", "--no-optional-locks", *args], cwd=ROOT,
    ).split(b"\0") if name]


def normalized_lines(text):
    return [re.sub(r"\s+", " ", line.strip())
            for line in text.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
            and not re.match(r"\s*(when not declared|const ATCODER_|import |export )", line)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--baseline", default="9571f218")
    args = parser.parse_args()
    names = sorted(name for name in git_paths("ls-files", "-z", "--", "src/atcoder")
                   if name.endswith(".nim"))
    baseline = sorted(name for name in git_paths(
        "ls-tree", "-r", "--name-only", "-z", args.baseline, "--", "src/atcoder",
    ) if name.endswith(".nim"))
    readers = {name: (ROOT / name).read_text(encoding="utf-8", errors="replace")
               for name in git_paths("ls-files", "-z", "--", "src", "test", "tests")
               if name.endswith(".nim") and (ROOT / name).is_file()}
    exact = defaultdict(list)
    blocks = defaultdict(set)
    modules = []
    for name in names:
        data = (ROOT / name).read_bytes()
        text = data.decode("utf-8")
        digest = hashlib.sha256(data).hexdigest()
        exact[digest].append(name)
        lines = normalized_lines(text)
        for i in range(len(lines) - 11):
            blocks["\n".join(lines[i:i + 12])].add(name)
        module = name.removeprefix("src/").removesuffix(".nim")
        modules.append({
            "path": name, "sha256": digest, "lines": len(text.splitlines()),
            "legacy_name": bool(re.search(r"(?:^old_|_old$|_backup$)", Path(name).stem)),
            "lexical_public_routines": re.findall(
                r"^\s*(?:proc|func|iterator|template|macro)\s+([^\s\[(]+)\*", text, re.M),
            "lexical_referrers": sorted(other for other, content in readers.items()
                                         if other != name and module in content),
        })
    pairs = Counter()
    for paths in blocks.values():
        for a, b in itertools.combinations(sorted(paths), 2):
            pairs[a, b] += 1
    review = json.loads((ROOT / "tools/module_consolidation_review.json").read_text())
    classification = review.get("classification_review")
    if classification:
        entries = classification["groups"]
        assert len(entries) == len(review["groups"])
        assert [entry["group"] for entry in entries] == list(range(1, len(entries) + 1))
        for entry, group in zip(entries, review["groups"]):
            assert entry["anchor_module"] == group["modules"][0]
        counts = Counter(entry["primary_classification"] for entry in entries)
        assert dict(counts) == classification["counts"]
        assert counts["independent_implementation"] == sum(
            classification["independent_subgroups"].values())
    for group in review["groups"]:
        for module in group["modules"]:
            assert module in names, f"review points to a missing module: {module}"
    for candidate in review["new_algorithm_candidates"]:
        pattern = re.compile(candidate["search_pattern"], re.I)
        candidate["lexical_matches"] = [name for name in names
                                         if pattern.search(readers[name]) or pattern.search(name)]
    report = {
        "head": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT,
                                         text=True).strip(),
        "baseline": args.baseline, "baseline_count": len(baseline),
        "current_count": len(names), "added_since_baseline": sorted(set(names) - set(baseline)),
        "removed_since_baseline": sorted(set(baseline) - set(names)),
        "scope": "tracked src/atcoder/**/*.nim; lexical signals are not semantic equivalence",
        "exact_duplicate_groups": [paths for paths in exact.values() if len(paths) > 1],
        "shared_12_line_windows": [dict(modules=list(pair), windows=count)
                                   for pair, count in pairs.most_common(30)],
        "modules": modules, "review": review,
    }
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(f"MODULES: {len(baseline)} -> {len(names)}")
    print(f"EXACT_DUPLICATE_GROUPS: {len(report['exact_duplicate_groups'])}")
    print(f"LEGACY_NAMED_MODULES: {sum(m['legacy_name'] for m in modules)}")
    print(f"REVIEW_GROUPS: {len(review['groups'])}")
    print(f"REPORT: {args.output}")


if __name__ == "__main__":
    main()
