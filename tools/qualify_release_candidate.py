#!/usr/bin/env python3
"""Qualify an exact local RC checkout; never publish or reuse historical gates.

CI sets NACL_RC_SHA, NACL_RC_NIM, NACL_RC_OS and NACL_RC_REPORT.
Linux runs full quick_verify as well as the portable gates. Windows runs the
portable gates natively; its report explicitly records that scope difference.
macOS execution is a local rehearsal and cannot qualify a hosted CI row.
"""
from pathlib import Path
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CASES = [
    "tests/test_int128_mixed_comparisons.nim", "tests/test_extra_bflow.nim",
    "tests/test_scc.nim", "tests/test_extra_divutils.nim",
    "tests/test_extra_lowlink.nim", "tests/test_extra_multipoint_evaluation_backup.nim",
    "tests/test_extra_chromatic_number.nim", "tests/test_compress_legacy_standalone.nim",
    "tests/test_rolling_hash_public_contract.nim",
    "tests/test_implicit_treap_resources.nim",
    "tests/test_implicit_treap_allocating_sink.nim",
]
SMOKE = '''import atcoder/[dsu, fenwicktree, modint]
import atcoder/extra/graph/undirected_decomposition
import atcoder/extra/math/polynomial_interpolation
import atcoder/extra/numeric/int128
import atcoder/extra/graph/bflow
var uf = initDSU(3)
uf.merge(0, 1)
doAssert uf.same(0, 1)
var bit = initFenwickTree[int](3)
bit.add(0, 7)
doAssert bit.sum(0 ..< 2) == 7
var g = initUndirectedGraph(3)
let a = g.addEdge(0, 1)
let b = g.addEdge(1, 2)
let raw = g.lowLinkUndirected()
doAssert raw.ord.len == 3 and raw.low.len == 3
doAssert raw.articulation == @[1] and raw.bridges == @[b, a]
doAssert raw.edgeComponents.len == 0 and raw.vertexComponents.len == 0
doAssert raw.componentOfEdge.len == 0
let full = g.lowLinkUndirected(buildComponents = true)
doAssert full == g.biconnectedComponents()
doAssert full.bridges == @[a, b]
type mint = modint998244353
doAssert polynomialInterpolation(@[mint.init(0), mint.init(1), mint.init(2)],
  @[mint.init(3), mint.init(10), mint.init(27)]) == @[mint.init(3), mint.init(2), mint.init(5)]
let signedZero = toInt128(0)
doAssert signedZero >= -1 and -1 <= signedZero
var numericFlow = initBFlow[int, Int128](2)
numericFlow.add_supply(0, 2)
numericFlow.add_demand(1, 2)
numericFlow.add_edge(0, 1, 0, 3, toInt128(0))
let numericResult = numericFlow.solve()
doAssert numericResult[0] and numericResult[1] == toInt128(0)
doAssert numericFlow.f == @[2]
echo "RC_INSTALLED_PACKAGE_OK"
'''

def git(*args):
    return subprocess.check_output(["git", "--no-optional-locks", *args], cwd=ROOT)

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def source_hashes():
    names = git("ls-files", "-z").decode().split("\0")
    return {name: digest(ROOT / name) for name in names if name}

def main():
    report = Path(os.environ["NACL_RC_REPORT"]).resolve()
    report.mkdir(parents=True, exist_ok=True)
    rows = []
    summary = {"status": "FAIL", "checks": rows, "os": platform.platform(), "python": sys.version,
               "hosted_rows_qualified": False, "full_oj_verification": "NOT_RUN_BY_THIS_GATE",
               "publication": "NONE", "performance_benchmarks": "NOT_RUN"}
    before = None
    env = os.environ.copy()
    env.update(PYTHONDONTWRITEBYTECODE="1", NACL_PYTHON=sys.executable)

    def run(name, command, cwd=ROOT, timeout=600):
        print("CHECK_START=" + name, flush=True)
        try:
            r = subprocess.run([str(x) for x in command], cwd=cwd, env=env,
                               capture_output=True, text=True, errors="replace", timeout=timeout)
            output = r.stdout + r.stderr
            rc = r.returncode
        except subprocess.TimeoutExpired as error:
            output = str(error)
            rc = 124
        (report / (name + ".log")).write_text(output, encoding="utf-8")
        rows.append({"name": name, "returncode": rc, "command": [str(x) for x in command],
                     "cwd": str(cwd), "status": "PASS" if rc == 0 else "FAIL"})
        print("CHECK_" + name + "=" + rows[-1]["status"], flush=True)
        if rc:
            raise RuntimeError("REQUIRED_CHECK_FAILED: " + name)
        return output

    try:
        sha = os.environ["NACL_RC_SHA"]
        version = os.environ["NACL_RC_NIM"]
        expected_os = os.environ["NACL_RC_OS"]
        actual_os = {"Linux": "Linux", "Windows": "Windows", "Darwin": "macOS"}.get(platform.system())
        if not re.fullmatch(r"[0-9a-f]{40}", sha) or version not in ("2.2.4", "2.2.10"):
            raise RuntimeError("INVALID_CANDIDATE_IDENTITY")
        if git("rev-parse", "HEAD").decode().strip() != sha:
            raise RuntimeError("CHECKOUT_SHA_MISMATCH")
        if expected_os != actual_os or actual_os not in ("Linux", "Windows", "macOS"):
            raise RuntimeError("RUNNER_OS_MISMATCH")
        if git("status", "--porcelain", "--untracked-files=all").strip():
            raise RuntimeError("CHECKOUT_NOT_CLEAN")
        before = source_hashes()
        (report / "source-hashes.json").write_text(json.dumps(before, indent=2) + "\n")
        summary.update(sha=sha, expected_nim=version, expected_os=expected_os,
                       scope="full quick_verify + portable" if actual_os == "Linux" else "portable",
                       windows_full_quick_verify="NOT_RUN_BASH_SCOPE" if actual_os == "Windows" else "NOT_APPLICABLE")
        nim = shutil.which("nim")
        nimble = shutil.which("nimble")
        if not nim or not nimble or not shutil.which("g++"):
            raise RuntimeError("NATIVE_TOOLCHAIN_MISSING")
        version_output = run("nim_version", [nim, "--version"])
        if not re.search(r"Nim Compiler Version " + re.escape(version) + r"\s", version_output):
            raise RuntimeError("NIM_VERSION_MISMATCH")
        run("cxx_version", ["g++", "--version"])
        run("git_version", ["git", "--version"])
        import lzma  # compressed Expander modes require this in the active Python
        assert lzma.decompress(lzma.compress(b"rc")) == b"rc"
        metadata = (ROOT / "atcoder.nimble").read_text()
        if not re.search(r'version\s*=\s*"0\.5\.3"', metadata) or 'requires "nim >= 2.2.4"' not in metadata:
            raise RuntimeError("RC_METADATA_MISMATCH")
        env.update(NACL_EXPANDER_NIM=nim, NACL_EXPANDER_MM="orc")
        for audit in ("audit_ci_workflows", "audit_nim_version_matrix"):
            run(audit, [sys.executable, "tools/" + audit + ".py"])
        if actual_os == "Linux":
            profile = "latest" if version == "2.2.10" else "atcoder"
            env["NACL_QUICK_VERIFY_LOG"] = str(report / "full-quick-verify.log")
            run("full_quick_verify", ["bash", "tools/run_nim_compatibility.sh", profile], timeout=5400)
        run("expander_python", [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_expander*.py", "-v"], timeout=1800)
        run("consolidation", [sys.executable, "tools/verify_module_consolidation.py", "--phase", "all", "--nim", nim,
                              "--mm", "orc", "--report", report / "consolidation.json"], timeout=3600)
        with tempfile.TemporaryDirectory(prefix="nacl RC spaces ") as temp:
            work = Path(temp)
            for mm in ("refc", "orc"):
                for number, case in enumerate(CASES):
                    run("regression_" + mm + "_" + str(number), [nim, "cpp", "-r", "--hints:off", "--warnings:off",
                        "--checks:on", "--overflowChecks:on", "--mm:" + mm, "--nimcache:" + str(work / ("cache_" + mm + str(number))),
                        "--out:" + str(work / ("test_" + mm + str(number) + (".exe" if actual_os == "Windows" else ""))), case])
            nimble_dir = work / "nimble"
            nimble_dir.mkdir()
            cached_list = Path.home() / ".nimble/packages_official.json"
            if cached_list.is_file():
                shutil.copy2(cached_list, nimble_dir / "packages_official.json")
            else:
                run("nimble_refresh", [nimble, "--nimbleDir:" + str(nimble_dir), "refresh"], timeout=300)
            run("nimble_version", [nimble, "--nimbleDir:" + str(nimble_dir), "--version"])
            help_text = run("nimble_help", [nimble, "--nimbleDir:" + str(nimble_dir), "--help"])
            common = [nimble, "--nim:" + nim, "--nimbleDir:" + str(nimble_dir), "--offline"]
            if "--useSystemNim" in help_text:
                common.append("--useSystemNim")
            run("nimble_check", [*common, "check"])
            dump = json.loads(run("nimble_dump", [*common, "dump", "--json"]))
            if dump["version"] != "0.5.3" or Path(dump["nimDir"]).resolve() != Path(nim).resolve().parent:
                raise RuntimeError("NIMBLE_COMPILER_OR_VERSION_MISMATCH")
            run("nimble_install", [*common, "install", "-y"])
            packages = list(nimble_dir.glob("pkgs2/atcoder-0.5.3-*")) + list(nimble_dir.glob("pkgs/atcoder-0.5.3"))
            if len(packages) != 1:
                raise RuntimeError("INSTALLED_PACKAGE_NOT_FOUND")
            package = packages[0]
            installed_hashes = {}
            for source in (ROOT / "src").rglob("*.nim"):
                relative = source.relative_to(ROOT / "src")
                if relative.parts[0] == "verify":
                    continue
                destination = package / relative
                if not destination.is_file() or digest(source) != digest(destination):
                    raise RuntimeError("INSTALLED_SOURCE_MISMATCH: " + str(relative))
                installed_hashes[str(relative)] = digest(destination)
            (report / "installed-source-hashes.json").write_text(json.dumps(installed_hashes, indent=2) + "\n")
            if actual_os == "Linux" and not ((package / "lib").is_symlink() and (package / "lib").resolve() == (package / "atcoder/extra").resolve()):
                raise RuntimeError("LINUX_INSTALL_ALIAS_MISSING")
            smoke = work / "installed_smoke.nim"
            smoke.write_text(SMOKE)
            for mm in ("refc", "orc"):
                run("installed_" + mm, [nim, "cpp", "-r", "--hints:off", "--warnings:off", "--noNimblePath",
                    "--path:" + str(package), "--mm:" + mm, "--nimcache:" + str(work / ("installed_" + mm)),
                    "--out:" + str(work / ("installed_" + mm + (".exe" if actual_os == "Windows" else ".bin"))), smoke], cwd=work)
        for tool in ("generate_document", "postprocess_document_html", "postprocess_document_links", "audit_generated_document_html"):
            run(tool, [sys.executable, "tools/" + tool + ".py"])
        summary["status"] = "LOCAL_PASS" if actual_os == "macOS" else "PASS"
        summary["hosted_rows_qualified"] = actual_os in ("Linux", "Windows") and os.environ.get("GITHUB_ACTIONS") == "true"
    except Exception as error:
        summary["error"] = type(error).__name__ + ": " + str(error)
        print(summary["error"], flush=True)
    finally:
        if before is not None and (source_hashes() != before or git("diff", "--cached", "--binary")):
            summary.update(status="FAIL", source_unchanged=False, error="SOURCE_OR_INDEX_CHANGED")
        else:
            summary["source_unchanged"] = before is not None
        summary["passed_checks"] = sum(row["status"] == "PASS" for row in rows)
        summary["completed_checks"] = len(rows)
        summary["unperformed_after_failure"] = summary["status"] == "FAIL"
        (report / "SUMMARY.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
        print("RC_GATE_STATUS=" + summary["status"], flush=True)
    return 0 if summary["status"] in ("PASS", "LOCAL_PASS") else 1

if __name__ == "__main__":
    sys.exit(main())
