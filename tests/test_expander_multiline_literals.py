"""Real Nim regressions for literal bytes, macro parsing and import resolution."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from test_expander_conditional_imports import compilers, expand


ROOT = Path(__file__).resolve().parents[1]


class MultilineLiterals(unittest.TestCase):
    def check_program(self, directory, source, library, local):
        outputs = {"direct": source}
        for mode in ("plain", "embed", "bundle"):
            target = directory / (source.stem + "_" + mode + ".nim")
            expand(source, target, library, local, mode)
            outputs[mode] = target
        rows = []
        for number, compiler in enumerate(compilers()):
            reference = None
            for mode, target in outputs.items():
                with self.subTest(source=source.name, compiler=str(compiler), mode=mode):
                    stem = source.stem + "_" + mode + "_" + str(number)
                    binary = directory / (stem + "_run")
                    cmd = [str(compiler), "cpp", "-d:release", "--hints:off", "--warnings:off",
                           "--passC:-w", "--mm:" + os.environ.get("NACL_EXPANDER_MM", "orc"),
                           "--nimcache:" + str(directory / (stem + "_cache")), "--out:" + str(binary)]
                    if mode == "direct":
                        cmd += ["--path:" + str(library), "--path:" + str(local)]
                    built = subprocess.run([*cmd, str(target)], cwd=directory,
                                           capture_output=True, text=True, timeout=180)
                    self.assertEqual(built.returncode, 0, built.stdout + built.stderr)
                    ran = subprocess.run([str(binary)], cwd=directory, capture_output=True, text=True, timeout=30)
                    self.assertEqual(ran.returncode, 0, ran.stdout + ran.stderr)
                    if mode == "direct":
                        reference = ran.stdout
                    self.assertEqual(ran.stdout, reference)
                    rows.append(dict(source=source.name, compiler=str(compiler), mode=mode,
                                     mm=os.environ.get("NACL_EXPANDER_MM", "orc"), stdout=ran.stdout))
        self.assertEqual(len(rows), 4 * len(compilers()))
        return rows

    def test_literals_and_comment_contents_survive_nested_inlining(self):
        if not compilers():
            self.skipTest("Nim not installed")
        with tempfile.TemporaryDirectory(prefix="nacl literals ") as folder:
            tmp = Path(folder)
            library = tmp / "library"
            (library / "atcoder").mkdir(parents=True)
            (tmp / "mylib").mkdir()
            # Both the synthetic import-once guard and a guarded parent's import
            # site add indentation. Text that resembles source must stay text.
            (library / "atcoder/text.nim").write_text('''const literalText* = """
import atcoder/not_a_module
  when false:
    export text
  indentation and trailing spaces  
"""
const quoted* = """ends with a quote""""
const rawText* = r"a""b\\"
const escaped* = "\\\"\\\"\\\""
const quoteChar* = '"'
const integer* = 7'u64
#[
import atcoder/not_a_comment_module
  #[ nested comment with """ ]#
]#
##[
import atcoder/not_a_doc_module
##[ nested documentation ]##
]##
''')
            (library / "atcoder/bridge.nim").write_text('''when not declared(NACL_LITERAL_BRIDGE):
  const NACL_LITERAL_BRIDGE* = true
  import atcoder/text
  export text
''')
            (tmp / "mylib/fragment.nim").write_text('''let localText = """first
include mylib/not_a_file
  last
"""
doAssert localText == "first\\ninclude mylib/not_a_file\\n  last\\n"
''')
            source = tmp / "literal_program.nim"
            source.write_text('''import std/json
when true:
  import atcoder/bridge
import atcoder/text
block:
  include mylib/fragment
doAssert escaped == "\\\"\\\"\\\"" and quoteChar == '"' and integer == 7
doAssert quoted == "ends with a quote\\\""
doAssert rawText == "a\\\"b\\\\"
echo $(%literalText)
echo $(%quoted)
echo $(%rawText)
''')
            self.check_program(tmp, source, library, tmp)

    def test_original_fps_macro_and_interpolation(self):
        if not compilers():
            self.skipTest("Nim not installed")
        with tempfile.TemporaryDirectory(prefix="nacl fps literals ") as folder:
            tmp = Path(folder)
            source = tmp / "fps_program.nim"
            source.write_text('''import atcoder/modint
import atcoder/extra/math/polynomial_interpolation
import atcoder/extra/math/multipoint_evaluation
type mint = modint998244353
for n in [0, 1, 3, 65, 257]:
  var xs, f = newSeq[mint](n)
  for i in 0 ..< n:
    xs[i] = mint.init(i * 7 + 5)
    f[i] = mint.init(i * 19 + 2)
  let ys = multipointEvaluation(f, xs)
  doAssert polynomialInterpolation(xs, ys) == f
  for i in 0 ..< n:
    var value = mint.init(0)
    for j in countdown(f.len - 1, 0): value = value * xs[i] + f[j]
    doAssert ys[i] == value
echo "FPS_LITERAL_MACRO=PASS"
''')
            rows = self.check_program(tmp, source, ROOT / "src", tmp)
            if os.environ.get("NACL_EXPANDER_LITERAL_REPORT"):
                Path(os.environ["NACL_EXPANDER_LITERAL_REPORT"]).write_text(json.dumps(rows, indent=2) + "\n")


if __name__ == "__main__":
    unittest.main(verbosity=2)
