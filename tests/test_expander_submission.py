"""Focused tool tests. Synthetic Git history is not evidence of public release."""
import base64
from contextlib import redirect_stdout
import hashlib
import importlib.util
import io
import json
import lzma
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]

def load(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

ex = load("nacl_expander_test", ROOT / "expander.py")
wrapper = load("nacl_wrapper_test", ROOT / "run_expander.py")

class SubmissionTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="nacl paths ")
        self.root = Path(self.tmp.name)
        self.lib = self.root / "library 空白"
        self.lib.mkdir()
        self.src = self.root / "solution file.nim"
        self.out = self.root / "combined.nim"
        for tool in ["expander.py", "run_expander.py"]:
            shutil.copyfile(ROOT / tool, self.lib / tool)
        self.write("src/atcoder/answer.nim", "proc answer*(): int = 42\n")
        self.src.write_text("import atcoder/answer\necho answer()\n", encoding="utf-8")
        self.git("init", "-q")
        self.git("-c", "user.email=test@example.invalid", "-c", "user.name=fixture", "add", ".")
        self.git("-c", "user.email=test@example.invalid", "-c", "user.name=fixture", "commit", "-qm", "fixture")
        self.sha = self.git("rev-parse", "HEAD").strip()

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, name, text):
        p = self.lib / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(text.encode("utf-8"))

    def git(self, *args):
        p = subprocess.run(["git", "--no-optional-locks", "-c", "commit.gpgSign=false",
                            "-c", "core.hooksPath=.git/nacl-no-hooks",
                            "-c", "core.autocrlf=false", "-C", str(self.lib), *args],
                           capture_output=True, text=True, check=True)
        return p.stdout

    def run_expand(self, mode="bundle", extra=(), expected=0):
        p = subprocess.run([sys.executable, str(self.lib/"expander.py"), str(self.src),
                            "--lib", str(self.lib), "--source-ref", self.sha,
                            "--mode", mode, "--output", str(self.out), *extra],
                           capture_output=True, text=True, timeout=30)
        self.assertEqual(p.returncode, expected, p.stderr)
        return p

    def payload(self):
        text = self.out.read_text(encoding="utf-8")
        data = re.search(r'let naclRequest = \$\(%\* \{"data": "([A-Za-z0-9+/=]+)"', text).group(1)
        with tarfile.open(fileobj=io.BytesIO(base64.b64decode(data)), mode="r:xz") as t:
            return {x.name: t.extractfile(x).read() for x in t.getmembers()}

    def test_plain_has_source_and_readable_answer(self):
        self.run_expand("plain")
        text=self.out.read_text()
        self.assertIn("/tree/"+self.sha, text)
        self.assertIn("proc answer*", text)
        self.assertIn("echo answer()", text)
        self.assertNotIn("staticExec", text)

    def test_bundle_uses_exact_public_bytes_not_main(self):
        self.run_expand()
        files=self.payload()
        self.assertEqual(files, {"atcoder/answer.nim": (self.lib/"src/atcoder/answer.nim").read_bytes()})
        self.assertIn("echo answer()", self.out.read_text())
        self.assertIn("/blob/"+self.sha+"/expander.py", self.out.read_text())

    def test_bundle_is_deterministic(self):
        self.run_expand(); a=self.out.read_bytes()
        self.run_expand(); self.assertEqual(self.out.read_bytes(),a)

    def test_embed_exact_source_is_visible(self):
        self.run_expand("embed")
        text=self.out.read_text()
        payload=re.search(r'<=== "([A-Za-z0-9+/=]+)"',text).group(1)
        original=lzma.decompress(base64.b64decode(payload)).decode()
        block=text.split("# BEGIN ORIGINAL SOURCE exact embed input atcoder/answer.nim; FINAL_NEWLINE=YES\n")[1].split("# END ORIGINAL SOURCE")[0]
        self.assertEqual("".join(line[2:]+"\n" for line in block.splitlines()),original)

    def test_dirty_source_is_rejected_preserving_output(self):
        self.out.write_text("previous")
        self.write("src/atcoder/answer.nim", "proc answer*(): int = 43\n")
        p=self.run_expand(expected=1)
        self.assertIn("SOURCE_REF_MISMATCH",p.stderr)
        self.assertEqual(self.out.read_text(),"previous")

    def test_inactive_import_still_requires_matching_source(self):
        self.src.write_text("when false:\n  import atcoder/answer\necho 42\n")
        self.write("src/atcoder/answer.nim", "proc answer*(): int = 43\n")
        for mode in ("plain", "embed", "bundle"):
            with self.subTest(mode=mode):
                self.out.write_text("previous")
                p = self.run_expand(mode, expected=1)
                self.assertIn("SOURCE_REF_MISMATCH", p.stderr)
                self.assertEqual(self.out.read_text(), "previous")

    def test_embed_records_all_conditional_dependency_variants(self):
        self.write("src/atcoder/unit.nim", "const value* = 42\n")
        self.write("src/atcoder/answer.nim", "import atcoder/unit\nproc answer*(): int = value\n")
        self.src.write_text("when true:\n  import atcoder/unit\n  import atcoder/answer\n"
                            "when true:\n  import atcoder/answer\necho answer()\n")
        self.git("add", ".")
        self.git("-c", "user.name=f", "-c", "user.email=f@invalid", "commit", "-qm", "branches")
        self.sha = self.git("rev-parse", "HEAD").strip()
        self.run_expand("embed")
        text = self.out.read_text()
        self.assertIn("exact embed input atcoder/answer.nim [variant 2]", text)
        for payload in re.findall(r'<=== "([A-Za-z0-9+/=]+)"', text):
            decoded = lzma.decompress(base64.b64decode(payload)).decode()
            # Every emitted compressed input must have a readable exact copy.
            readable = "".join("# " + line + "\n" for line in decoded.splitlines())
            self.assertIn(readable, text)

    def test_clean_new_commit_cannot_claim_old_source(self):
        self.write("src/atcoder/answer.nim", "proc answer*(): int = 43\n")
        self.git("add", ".")
        self.git("-c", "user.name=f", "-c", "user.email=f@invalid", "commit", "-qm", "unpublished")
        p=self.run_expand(expected=1)
        self.assertIn("SOURCE_REF_MISMATCH",p.stderr)

    def test_crlf_checkout_emits_git_bytes(self):
        path=self.lib/"src/atcoder/answer.nim"
        original=path.read_bytes()
        path.write_bytes(original.replace(b"\n",b"\r\n"))
        self.run_expand()
        self.assertEqual(self.payload()["atcoder/answer.nim"],original)

    def test_unpublished_bootstrap_requires_preview(self):
        with (self.lib/"expander.py").open("a") as f: f.write("\n# local change\n")
        p=self.run_expand(expected=1)
        self.assertIn("EXPANDER_REF_MISMATCH",p.stderr)
        self.run_expand(extra=("--preview",))
        self.assertIn("PREVIEW ONLY",self.out.read_text())

    def test_legacy_aliases(self):
        self.run_expand(extra=("--compress","--directory"))
        self.assertEqual(len(self.payload()),1)

    def test_empty_bundle_is_not_bootstrapped(self):
        self.src.write_text("echo 42\n")
        self.run_expand()
        self.assertNotIn("gorgeEx", self.out.read_text())

    def test_mylib_comments_cannot_be_escaped(self):
        self.src.write_text("include mylib/foo\necho x\n")
        (self.root/"mylib").mkdir()
        raw='const x = "]# unsafe? #["\n'
        (self.root/"mylib/foo.nim").write_bytes(raw.encode("utf-8"))
        self.run_expand()
        self.assertIn('# const x = "]# unsafe? #["',self.out.read_text())
        self.assertEqual(self.payload()["mylib/foo.nim"].decode(),raw)

    def test_output_cannot_overwrite_main(self):
        old=self.src.read_bytes()
        p=self.run_expand("plain",extra=("--output",str(self.src)),expected=1)
        self.assertIn("overwrite",p.stderr)
        self.assertEqual(self.src.read_bytes(),old)

    def test_traversal_rejected(self):
        self.src.write_text("include atcoder/../../escape\n")
        p=self.run_expand("plain",expected=1)
        self.assertIn("escapes",p.stderr)

    def test_aliased_source_remains_auditable(self):
        self.write("src/atcoder/extra/inner.nim", "const inner* = 7\n")
        self.write("src/atcoder/answer.nim", "import lib/inner\nproc answer*(): int = inner\n")
        self.git("add", ".")
        self.git("-c","user.name=f","-c","user.email=f@invalid","commit","-qm","alias")
        self.sha=self.git("rev-parse","HEAD").strip()
        self.run_expand()
        self.assertIn(b"import atcoder/extra/inner",self.payload()["atcoder/answer.nim"])
        self.assertIn("exact transformed bundle member",self.out.read_text())

    def test_wrapper_failure_never_copies_stale_output(self):
        self.out.write_text("old")
        with patch.object(wrapper.subprocess,"run",return_value=subprocess.CompletedProcess([],23)) as run, patch.object(wrapper,"clipboard_command") as copy:
            rc=wrapper.main([str(self.src),"--lib",str(self.lib),"--output",str(self.out)])
            self.assertEqual(rc,23)
            copy.assert_not_called()
            self.assertNotIn("shell",run.call_args.kwargs)
        self.assertEqual(self.out.read_text(),"old")

    def test_wrapper_retains_output(self):
        p=subprocess.run([sys.executable,str(self.lib/"run_expander.py"),str(self.src),
                          "--lib",str(self.lib),"--source-ref",self.sha,"--no-clipboard",
                          "--output",str(self.out)],capture_output=True,text=True)
        self.assertEqual(p.returncode,0,p.stderr)
        self.assertTrue(self.out.exists())

    def test_clipboard_platform_routes(self):
        with patch.object(wrapper.shutil,"which",side_effect=lambda x:x), patch.dict(os.environ,{"WAYLAND_DISPLAY":"test"}):
            self.assertEqual(wrapper.clipboard_command("Darwin"),["pbcopy"])
            self.assertEqual(wrapper.clipboard_command("Linux"),["wl-copy"])
            self.assertIn("Set-Clipboard",wrapper.clipboard_command("Windows")[-1])

    def test_restore_preserves_flags_and_detects_error(self):
        # Execute the actual generated helper with a synthetic compiler, not Nim.
        self.run_expand()
        data=re.search(r'let naclRequest = \$\(%\* \{"data": "([A-Za-z0-9+/=]+)"',self.out.read_text()).group(1)
        fake=self.root/"fake compiler.py"
        fake.write_text('import sys,json,pathlib\nargs=sys.argv[1:]\np=pathlib.Path(next(a[7:] for a in args if a.startswith("--path:")))\nassert (p/"atcoder/answer.nim").read_text()=="proc answer*(): int = 42\\n"\nassert "--checks:on" in args and "-d:MY_FLAG" in args\nassert "-d:danger" not in args\nprint("FAKE_ACCEPTED")\nsys.exit(17)\n')
        # The Python executable acts as compiler; its source must precede options.
        import shlex
        request=dict(data=data,source=str(self.src),compiler=sys.executable,
                     command=(subprocess.list2cmdline if os.name == "nt" else shlex.join)(
                         [str(fake),"--checks:on","-d:MY_FLAG",str(self.src)]),keep=False)
        r=subprocess.run([sys.executable,"-c",ex.BUNDLE_RESTORE],input=json.dumps(request),capture_output=True,text=True)
        self.assertEqual(r.returncode,17,r.stderr)
        self.assertIn("FAKE_ACCEPTED",r.stdout)

    def test_restore_rejects_unsafe_member(self):
        buf=io.BytesIO()
        with tarfile.open(fileobj=buf,mode="w") as t:
            m=tarfile.TarInfo("../escape");m.size=1;t.addfile(m,io.BytesIO(b"x"))
        data=base64.b64encode(lzma.compress(buf.getvalue())).decode()
        request=dict(data=data,source=str(self.src),compiler=sys.executable,command='"'+str(self.src)+'"',keep=False)
        r=subprocess.run([sys.executable,"-c",ex.BUNDLE_RESTORE],input=json.dumps(request),capture_output=True,text=True)
        self.assertNotEqual(r.returncode,0)
        self.assertIn("invalid bundle member",r.stderr)

    def test_compression_levels_decode_identically(self):
        self.run_expand(extra=("--compression-level","1")); first=self.payload()
        self.run_expand(extra=("--compression-level","6")); self.assertEqual(self.payload(),first)

if __name__ == "__main__":
    unittest.main(verbosity=2)
