"""Compile/run lexical-scope regressions with real Nim compilers.

NACL_EXPANDER_NIM selects one compiler (used by quick_verify). Otherwise the
installed 2.2.10 and 2.2.4 compilers are used, falling back to PATH's Nim.
Runtime if/block scopes use include: Nim forbids import in those scopes.
"""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("conditional_expander", ROOT / "expander.py")
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)

# (name, source, compiler defines). Each transformed binary is compared with
# the actual unexpanded program, including module initialization side effects.
CASES = [
    ("nested_when", """when true:
  when true:
    import atcoder/unit
    doAssert answer() == 42
echo "OK"
""", ()),
    ("opposite_branches", """when defined(First):
  import atcoder/unit
elif defined(Second):
  import atcoder/unit
else:
  import atcoder/unit
doAssert answer() == 42
echo "OK"
""", ()),
    ("opposite_branches", None, ("First",)),
    ("opposite_branches", None, ("Second",)),
    ("independent_conditions", """when defined(First):
  import atcoder/unit
when defined(Second):
  import atcoder/unit
doAssert answer() == 42
echo "OK"
""", ("Second",)),
    ("independent_conditions", None, ("First", "Second")),
    ("conditional_then_unconditional", """when defined(First):
  import atcoder/unit
import atcoder/unit
doAssert answer() == 42
echo "OK"
""", ()),
    ("conditional_then_unconditional", None, ("First",)),
    ("deduplicated_block", """import atcoder/unit
when true:
  import atcoder/unit
doAssert answer() == 42
echo "OK"
""", ()),
    ("mixed_external", """when true:
  import std/strutils, atcoder/unit
doAssert " 42 ".strip() == $answer()
echo "OK"
""", ()),
    ("transitive_conditions", """when defined(First):
  import atcoder/bridge
when defined(Second):
  import atcoder/bridge
doAssert bridgeAnswer() == 42
echo "OK"
""", ("Second",)),
    ("transitive_conditions", None, ("First", "Second")),
    ("dependency_variants", """when defined(First):
  import atcoder/unit
  import atcoder/bridge
when defined(Second):
  import atcoder/bridge
doAssert bridgeAnswer() == 42
echo "OK"
""", ("Second",)),
    ("dependency_variants", None, ("First", "Second")),
    ("library_conditions", """import atcoder/conditional
import atcoder/unit
doAssert conditionalAnswer() == answer()
echo "OK"
""", ()),
    ("library_conditions", None, ("First",)),
    ("nested_if_block_include", """var visits = 0
when true:
  block:
    if true:
      include mylib/tick
      block:
        include mylib/local
        doAssert localValue == 7
block:
  include mylib/local
  doAssert localValue == 7
doAssert visits == 1
echo "OK"
""", ()),
    ("include_conditions", """var visits = 0
when false:
  include mylib/tick
when true:
  include mylib/tick
if false:
  include mylib/tick
else:
  include mylib/tick
doAssert visits == 2
echo "OK"
""", ()),
]


def compilers():
    selected = os.environ.get("NACL_EXPANDER_NIM")
    if selected:
        return [Path(selected)]
    result = [Path.home() / f".choosenim/toolchains/nim-{v}/bin/nim"
              for v in ("2.2.10", "2.2.4")]
    result = [p for p in result if p.is_file()]
    if not result and shutil.which("nim"):
        result = [Path(shutil.which("nim"))]
    return result


def expand(source, output, library, local, mode):
    ex.SOURCE_BYTES.clear()
    ex.BUNDLE_BYTES.clear()
    ex.EMBED_TEXTS.clear()
    lines = ex.read_source(str(source), "", set(), library, local, None, mode, 0)
    bootstrap = ""
    if mode == "embed" and ex.EMBED_TEXTS:
        bootstrap = ex.embed_bootstrap()
    elif mode == "bundle" and ex.BUNDLE_BYTES:
        bootstrap = ex.bundle_bootstrap(None, False)
    output.write_text("# LOCAL REGRESSION FIXTURE; NOT A SUBMISSION.\n" + bootstrap
                      + "\n".join(lines) + "\n", encoding="utf-8")


class ConditionalImports(unittest.TestCase):
    def test_compile_run_matrix(self):
        installed = compilers()
        if not installed:
            self.skipTest("Nim not installed")
        rows = []
        with tempfile.TemporaryDirectory(prefix="nacl conditional ") as directory:
            tmp = Path(directory)
            library = tmp / "library"
            local = tmp / "local"
            (library / "atcoder").mkdir(parents=True)
            (local / "mylib").mkdir(parents=True)
            (library / "atcoder/unit.nim").write_text(
                'proc answer*(): int = 42\necho "UNIT_INIT"\n')
            (library / "atcoder/bridge.nim").write_text("""when not declared(NACL_BRIDGE):
  const NACL_BRIDGE* = true
  import atcoder/unit
  export unit
  proc bridgeAnswer*(): int = answer()
""")
            (library / "atcoder/conditional.nim").write_text("""when not declared NACL_CONDITIONAL:
  const NACL_CONDITIONAL* = true
  when defined(First):
    import atcoder/unit
  else:
    import atcoder/unit
  proc conditionalAnswer*(): int = answer()
""")
            (local / "mylib/tick.nim").write_text("inc visits\n")
            (local / "mylib/local.nim").write_text("const localValue = 7\n")
            sources = {}
            for number, (name, text, defines) in enumerate(CASES):
                if text is not None:
                    sources[name] = text
                source = tmp / f"case_{number}.nim"
                source.write_text(sources[name], encoding="utf-8")
                outputs = {"direct": source}
                for mode in ("plain", "embed", "bundle"):
                    target = tmp / f"case_{number}_{mode}.nim"
                    expand(source, target, library, local, mode)
                    outputs[mode] = target
                    if mode == "bundle":
                        for name, content in ex.BUNDLE_BYTES.items():
                            self.assertEqual(content, ex.SOURCE_BYTES[name])
                for ci, compiler in enumerate(installed):
                    reference = None
                    for mode, target in outputs.items():
                        with self.subTest(case=name, defines=defines, compiler=str(compiler), mode=mode):
                            stem = f"run_{number}_{ci}_{mode}"
                            binary = tmp / stem
                            command = [str(compiler), "cpp", "--hints:off", "--colors:off",
                                       "--nimcache:" + str(tmp / (stem + "_cache")),
                                       "--out:" + str(binary)]
                            command += ["-d:" + flag for flag in defines]
                            if mode == "direct":
                                command += ["--path:" + str(library), "--path:" + str(local)]
                            built = subprocess.run([*command, str(target)], cwd=tmp,
                                                   capture_output=True, text=True, timeout=180)
                            self.assertEqual(built.returncode, 0, built.stdout + built.stderr)
                            ran = subprocess.run([str(binary)], cwd=tmp, capture_output=True,
                                                 text=True, timeout=30)
                            self.assertEqual(ran.returncode, 0, ran.stdout + ran.stderr)
                            if mode == "direct":
                                reference = ran.stdout
                            self.assertEqual(ran.stdout, reference)
                            rows.append(dict(case=name, defines=defines, compiler=str(compiler),
                                             mode=mode, exit=ran.returncode))
        self.assertEqual(len(rows), len(CASES) * 4 * len(installed))
        if os.environ.get("NACL_EXPANDER_REPORT"):
            Path(os.environ["NACL_EXPANDER_REPORT"]).write_text(json.dumps(rows, indent=2) + "\n")
        print(f"EXPANDER_CONDITIONAL_MATRIX_OK compilers={len(installed)} runs={len(rows)}", flush=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
