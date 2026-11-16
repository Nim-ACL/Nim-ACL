#!/usr/bin/env python3

import re
import argparse
import subprocess
import tempfile
import os
import platform
import base64
import hashlib
import io
import json
import lzma
import tarfile
from urllib.parse import urlparse
from pathlib import Path
from logging import Logger, basicConfig, getLogger

logger = getLogger(__name__)
system_name = platform.system()

# Module bytes are captured once and reused for provenance and archive creation.
# Reset per invocation: never reuse stale data between independent expansions.
SOURCE_BYTES = {}
BUNDLE_BYTES = {}
EMBED_TEXTS = {}
COMPRESSION_LEVEL = 6

ATCODER_INCLUDE = re.compile(r'\s*(include|import)\s*([a-zA-Z0-9_,./\s"\[\]]*)')
# Plain/embed inlining removes module namespaces. `export module_name` then
# has no imported module symbol to export; the public declarations are already
# in the same generated source. Do not touch exports of external modules.
FLATTENED_EXPORT = re.compile(
    r"^(\s*)export\s+([A-Za-z_][A-Za-z_0-9]*(?:\s*,\s*[A-Za-z_][A-Za-z_0-9]*)*)(\s*(?:#.*)?)$"
)
WHEN_STATEMENT = re.compile(r'^\s*when\s+.*:')

INDENT_WIDTH = 2

# ----------------------------
# utility
# ----------------------------

def indent_level(line):
    for i, c in enumerate(line):
        if c != " ":
            return i
    return len(line)


def split_import_items(s):
    items = []
    cur = []
    depth = 0

    for c in s:
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1

        if c == "," and depth == 0:
            items.append("".join(cur).strip())
            cur = []
            continue

        cur.append(c)

    if cur:
        items.append("".join(cur).strip())

    return items


def expand_bracket_import(item):

    m = re.match(r"^(.*?)/\[(.*)\]$", item)

    if not m:
        return [item]

    prefix = m.group(1)
    inner = m.group(2)

    parts = [x.strip() for x in inner.split(",")]

    return [f"{prefix}/{p}" for p in parts]


def strip_relative_prefix(name):

    name = name.strip().strip('"')

    # Nim's `./foo/bar` and `foo/bar` refer to the same module here.
    # Do not use lstrip("./"): it would also mangle paths like `../foo`.
    while name.startswith("./"):
        name = name[2:]

    return name


def is_internal_module(name):

    name = strip_relative_prefix(name)

    return (
        name.startswith("atcoder/")
        or name.startswith("lib/")
        or name.startswith("mylib/")
    )


def normalize_internal_path(name):

    name = strip_relative_prefix(name)

    if name.startswith("lib/"):
        name = name.replace("lib/", "atcoder/extra/", 1)

    if not name.endswith(".nim"):
        name += ".nim"

    return name


def module_import_path(relpath):

    relpath = strip_relative_prefix(relpath)

    if relpath.endswith(".nim"):
        relpath = relpath[:-4]

    return relpath


# ----------------------------
# file read
# ----------------------------

def read_module_text(path, lib_root, local_root):
    if path not in SOURCE_BYTES:
        p = Path(path)
        if p.is_absolute():
            target = p
        else:
            root = local_root if path.startswith("mylib/") else lib_root
            target = (root / path).resolve()
            try:
                target.relative_to(root.resolve())
            except ValueError as exc:
                raise ValueError(f"module escapes its root: {path}") from exc
        raw = target.read_bytes()
        raw.decode("utf-8")  # Reject undecodable data, rather than alter it.
        SOURCE_BYTES[path] = raw
    return SOURCE_BYTES[path].decode("utf-8")


def write_bundle_module(relpath, lines, bundle_tmp):
    # Preserve original bytes wherever no lib/ alias needed rewriting.
    raw = SOURCE_BYTES[relpath]
    original_lines = raw.decode("utf-8").splitlines()
    BUNDLE_BYTES[relpath] = (raw if original_lines == lines else
                             ("\n".join(lines) + "\n").encode("utf-8"))


# ----------------------------
# recursive resolver
# ----------------------------

def read_source(path, prefix, defined, lib_root, local_root,
                bundle_tmp, mode, depth):

    if path in defined:
        logger.info(f"already included {path}, skip")
        return []

    defined.add(path)

    # Track only imports expanded from this module. A global set would
    # incorrectly remove exports of unrelated, still-imported modules.
    inlined_imported_modules = set()
    source = read_module_text(path, lib_root, local_root).splitlines()

    result = []

    i = 0
    while i < len(source):

        line = source[i]
        spaces = indent_level(line)

        if WHEN_STATEMENT.match(line):
            result.append(line)
            i += 1
            continue

        if mode != "bundle":
            exported = FLATTENED_EXPORT.fullmatch(line)
            if exported:
                names = [part.strip() for part in exported.group(2).split(",")]
                retained = [name for name in names
                            if name not in inlined_imported_modules]
                if len(retained) != len(names):
                    # A completely inlined import no longer has a module alias
                    # in a single-file submission. Keep the parent Nim block
                    # syntactically nonempty, and preserve other exports.
                    result.append((exported.group(1) + "export " + ", ".join(retained)
                                   + exported.group(3)) if retained else
                                  (exported.group(1) + "discard"))
                    i += 1
                    continue

        matched = ATCODER_INCLUDE.match(line)

        if not matched:
            result.append(line)
            i += 1
            continue

        keyword = matched.group(1)
        tail = matched.group(2)

        items = []

        for it in split_import_items(tail):
            items.extend(expand_bracket_import(it))

        if mode == "bundle":
            rewritten_items = []
            changed = False
            for item in items:
                item = item.strip('"')
                if is_internal_module(item):
                    fname = normalize_internal_path(item)
                    read_source(fname, "", defined, lib_root, local_root,
                                bundle_tmp, mode, depth + 1)
                    if strip_relative_prefix(item).startswith("lib/"):
                        item = module_import_path(fname)
                        changed = True
                rewritten_items.append(item)
            result.append((" " * spaces + keyword + " " + ", ".join(rewritten_items))
                          if changed else line)
            i += 1
            continue

        for item in items:

            item = item.strip('"')

            if is_internal_module(item):

                fname = normalize_internal_path(item)
                if mode != "bundle":
                    inlined_imported_modules.add(Path(fname).stem)

                if mode == "bundle":

                    read_source(
                        fname, "", defined,
                        lib_root, local_root, bundle_tmp,
                        mode, depth + 1
                    )

                    result.append(" " * spaces + f"{keyword} {module_import_path(fname)}")

                else:


                    
                    expanded = read_source(
                        fname, " " * spaces, defined,
                        lib_root, local_root, bundle_tmp,
                        mode, depth + 1
                    )

                    if mode == "embed" and depth == 0:

                        text = "\n".join(expanded) + "\n"
                        EMBED_TEXTS[fname] = text
                        compressed = lzma.compress(text.encode("utf-8"), preset=COMPRESSION_LEVEL)
                        
                        b64 = base64.b64encode(compressed).decode()

                        result.append(
                            prefix + f'ImportExpand "{fname}" <=== "{b64}"'
                        )

                    else:
                        result.extend((" " * spaces) + ln for ln in expanded)

            else:
                result.append(" " * spaces + f"{keyword} {item}")

        i += 1

    if depth > 0 and mode != "bundle":
        # The caller adds the import site's indentation to every returned line.
        # A second prefix here over-indents unguarded modules' trailing discard.
        result.append("discard")

    if mode == "bundle" and depth > 0:
        write_bundle_module(path, result, bundle_tmp)

    return result


# ----------------------------
# bundle bootstrap
# ----------------------------

# This Python program is included as readable source in the generated bootstrap.
# Large data goes through stdin, not command-line arguments (Windows limit).
BUNDLE_RESTORE = r'''import base64, ctypes, io, json, os, pathlib, shlex, shutil, subprocess, sys, tarfile, tempfile
p = json.load(sys.stdin)
if os.name == "nt":
    from ctypes import wintypes
    split = ctypes.windll.shell32.CommandLineToArgvW
    split.argtypes = [wintypes.LPCWSTR, ctypes.POINTER(ctypes.c_int)]
    split.restype = ctypes.POINTER(wintypes.LPWSTR)
    count = ctypes.c_int()
    ptr = split("nim " + p["command"], ctypes.byref(count))
    if not ptr:
        raise RuntimeError("cannot parse compiler arguments")
    try:
        args = [ptr[i] for i in range(1, count.value)]
    finally:
        ctypes.windll.kernel32.LocalFree.argtypes = [ctypes.c_void_p]
        ctypes.windll.kernel32.LocalFree(ctypes.cast(ptr, ctypes.c_void_p))
else:
    args = shlex.split(p["command"])
source = pathlib.Path(p["source"]).resolve()
positions = [i for i, arg in enumerate(args) if not arg.startswith("-") and pathlib.Path(arg).resolve() == source]
if len(positions) != 1:
    raise RuntimeError("expected one source argument in compiler command")
work = pathlib.Path(tempfile.mkdtemp(prefix="nim_acl_bundle_"))
try:
    with tarfile.open(fileobj=io.BytesIO(base64.b64decode(p["data"], validate=True)), mode="r:xz") as archive:
        seen = set()
        for member in archive.getmembers():
            name = pathlib.PurePosixPath(member.name)
            if (not member.isfile() or name.is_absolute() or ".." in name.parts or "\\" in member.name or ":" in member.name or member.name in seen):
                raise RuntimeError("invalid bundle member")
            seen.add(member.name)
            dest = work.joinpath(*name.parts)
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(archive.extractfile(member).read())
    # Inject after the user's options, before the source: this path wins over
    # installed/older libraries. All original codegen flags and output stay intact.
    pos = positions[0]
    args[pos:pos] = ["-d:NaclBundleSecond", "--path:" + str(work)]
    result = subprocess.run([p["compiler"]] + args)
    code = result.returncode
finally:
    if p["keep"]:
        print("NIM_ACL_BUNDLE_DIR=" + str(work), file=sys.stderr)
    else:
        shutil.rmtree(work)
sys.exit(code)
'''


def nim_literal(value):
    # UTF-8 remains UTF-8; ASCII quoting is compatible with Nim string literals.
    return json.dumps(value, ensure_ascii=False)


def python_launcher(program):
    # A one-line launcher works with Windows cmd.exe. The readable program is
    # also included, unmodified, as comments in the submitted source.
    return "exec(" + repr(program) + ")"


def comment_source(label, text):
    # Line comments cannot be terminated by a source containing ]# or #[.
    # Removing the '# ' prefix reproduces all source bytes except a documented
    # optional final newline. Never modify source text to escape comment tokens.
    ending = "YES" if text.endswith("\n") else "NO"
    return (f"# BEGIN ORIGINAL SOURCE {label}; FINAL_NEWLINE={ending}\n" +
            "".join("# " + line + "\n" for line in text.split("\n")[:-1]) +
            ("# " + text.split("\n")[-1] + "\n" if not text.endswith("\n") else "") +
            f"# END ORIGINAL SOURCE {label}\n")


def make_bundle():
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w", format=tarfile.PAX_FORMAT) as archive:
        for name, raw in sorted(BUNDLE_BYTES.items()):
            info = tarfile.TarInfo(name)
            info.size = len(raw)
            info.mode = 0o644
            info.mtime = 0
            archive.addfile(info, io.BytesIO(raw))
    return base64.b64encode(lzma.compress(buf.getvalue(), preset=COMPRESSION_LEVEL)).decode("ascii")


def bundle_bootstrap(bundle_tmp, keep_tmp):
    payload = make_bundle()
    # No runtime decoder is linked into the solution. Restore runs at compile time.
    return comment_source("bundle bootstrap helper (Python)", BUNDLE_RESTORE) + f'''when not defined(NaclBundleSecond):
  import std/[os, compilesettings, json]
  static:
    let naclPython = getEnv("NACL_PYTHON", (when defined(windows): "python" else: "python3"))
    let naclRequest = $(%* {{"data": {nim_literal(payload)},
      "source": querySetting(SingleValueSetting.projectFull),
      "compiler": getCurrentCompilerExe(),
      "command": querySetting(SingleValueSetting.commandLine),
      "keep": {str(keep_tmp).lower()}}})
    let (naclOutput, naclExit) = gorgeEx(quoteShell(naclPython) & " -c " &
      quoteShell({nim_literal(python_launcher(BUNDLE_RESTORE))}), naclRequest)
    if naclOutput.len > 0: echo naclOutput
    quit(naclExit)
'''


EMBED_DECODE = "import base64,lzma,sys;sys.stdout.buffer.write(lzma.decompress(base64.b64decode(sys.stdin.buffer.read(),validate=True)))"


def embed_bootstrap():
    return f'''import std/[macros, os]
macro ImportExpand(s: untyped): untyped =
  let naclPython = getEnv("NACL_PYTHON", (when defined(windows): "python" else: "python3"))
  let (text, code) = gorgeEx(quoteShell(naclPython) & " -c " &
    quoteShell({nim_literal(EMBED_DECODE)}), $s[2])
  if code != 0: error("Nim-ACL decompression failed: " & text)
  result = parseStmt(text)
'''


def git_bytes(root, *args, input_bytes=None):
    result = subprocess.run(["git", "--no-optional-locks", "-C", str(root), *args],
                            input=input_bytes, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, check=False)
    if result.returncode:
        raise ValueError(result.stderr.decode("utf-8", "replace").strip())
    return result.stdout


def provenance(lib_root, ref, repo_url, mode, tool_ref, preview):
    library = {name: raw for name, raw in SOURCE_BYTES.items() if name.startswith("atcoder/")}
    local = {name: raw for name, raw in SOURCE_BYTES.items() if name.startswith("mylib/")}
    header = "# Generated by Nim-ACL expander; solution body remains readable.\n"
    if library:
        root = lib_root.parent
        commit = git_bytes(root, "rev-parse", "--verify", ref + "^{commit}").decode("ascii").strip()
        if not re.fullmatch(r"[0-9a-f]{40}", commit):
            raise ValueError("source ref must resolve to a full SHA-1 commit")
        parsed = urlparse(repo_url)
        if (parsed.scheme != "https" or parsed.netloc != "github.com" or
                not re.fullmatch(r"/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/?", parsed.path) or
                parsed.query or parsed.fragment):
            raise ValueError("--source-repo must be an HTTPS GitHub repository URL")
        # One Git batch for all modules. Compare bytes, not just a working-tree
        # status: a clean unpublished local commit must not be cited as v0.5.1.
        names = sorted(library)
        specs = "".join(commit + ":src/" + name + "\n" for name in names).encode("utf-8")
        stream = io.BytesIO(git_bytes(root, "cat-file", "--batch", input_bytes=specs))
        for name in names:
            fields = stream.readline().rstrip(b"\n").split()
            if len(fields) != 3 or fields[1] != b"blob":
                raise ValueError("source not present in cited commit: " + name)
            expected = stream.read(int(fields[2]))
            if stream.read(1) != b"\n":
                raise ValueError("invalid Git batch response")
            actual = library[name]
            if expected != actual:
                if expected.replace(b"\r\n", b"\n") != actual.replace(b"\r\n", b"\n"):
                    raise ValueError("SOURCE_REF_MISMATCH: " + name +
                                     "; publish/cite the matching version before contest use")
                # Windows CRLF checkout: emit the cited Git bytes, not a new
                # unpublished code version. Do not accept any other difference.
                if BUNDLE_BYTES.get(name) == actual:
                    BUNDLE_BYTES[name] = expected
                SOURCE_BYTES[name] = expected
        header += ("# Library source: " + repo_url.rstrip("/") + "/tree/" + commit + "\n" +
                   "# Source checked against local Git; CRLF-only checkout normalization allowed.\n" +
                   "# Public availability / publication before contest: NOT VERIFIED.\n")
    if (mode == "bundle" and BUNDLE_BYTES) or (mode == "embed" and EMBED_TEXTS):
        # The bootstrap is submitted code too, not just a local packaging tool.
        # Do not cite an old public library for a new unpublished bootstrap.
        if preview:
            header += "# PREVIEW ONLY: EXPANDER BOOTSTRAP PUBLICATION NOT VERIFIED; DO NOT SUBMIT.\n"
        else:
            tool_commit = git_bytes(lib_root.parent, "rev-parse", "--verify",
                                    (tool_ref or ref) + "^{commit}").decode("ascii").strip()
            tool_bytes = git_bytes(lib_root.parent, "show", tool_commit + ":expander.py")
            if tool_bytes.replace(b"\r\n", b"\n") != Path(__file__).read_bytes().replace(b"\r\n", b"\n"):
                raise ValueError("EXPANDER_REF_MISMATCH: generated bootstrap also needs a matching public source; "
                                 "use --preview only for local testing")
            header += ("# Expander/bootstrap source: " + repo_url.rstrip("/") + "/blob/" +
                       tool_commit + "/expander.py\n")
    for name, raw in sorted(local.items()):
        if mode != "plain":
            header += comment_source(name, raw.decode("utf-8"))
    if local:
        header += "# Local/mylib AI-assisted code still requires separate prior publication.\n"
    if mode == "bundle":
        for name, raw in sorted(BUNDLE_BYTES.items()):
            if raw != SOURCE_BYTES[name]:
                header += comment_source("exact transformed bundle member " + name, raw.decode("utf-8"))
    elif mode == "embed":
        # Flattened source is not byte-identical to any single repository file.
        # Include exact pre-compression input, even though it increases code size.
        for name, text in EMBED_TEXTS.items():
            header += comment_source("exact embed input " + name, text)
    return header + "# End provenance.\n\n"


# ----------------------------
# main
# ----------------------------

def main():

    parser = argparse.ArgumentParser()

    parser.add_argument("source")
    parser.add_argument("--mode", choices=["plain", "embed", "bundle"], default="bundle")
    parser.add_argument("--lib")
    parser.add_argument("--mylib")
    parser.add_argument("--keep-bundle-tmp", action="store_true")
    parser.add_argument("--output", default="combined.nim")
    parser.add_argument("--source-ref", default="origin/master",
                        help="local Git ref whose exact bytes are cited; publication time is not certified")
    parser.add_argument("--tool-source-ref", help="public ref containing this expander (defaults to --source-ref)")
    parser.add_argument("--preview", action="store_true", help="local tests only; allow an unpublished bootstrap")
    parser.add_argument("--source-repo", default="https://github.com/Nim-ACL/Nim-ACL")
    parser.add_argument("--compression-level", type=int, choices=range(10), default=6)
    parser.add_argument("--compress", action="store_true", help="legacy alias for --mode embed")
    parser.add_argument("--directory", action="store_true", help="legacy alias for --mode bundle")

    opts = parser.parse_args()
    if opts.directory:
        opts.mode = "bundle"
    elif opts.compress:
        opts.mode = "embed"
    global COMPRESSION_LEVEL
    COMPRESSION_LEVEL = opts.compression_level
    SOURCE_BYTES.clear()
    BUNDLE_BYTES.clear()
    EMBED_TEXTS.clear()

    basicConfig(level="INFO")

    src = Path(opts.source)
    if src.suffix == "":
        src = src.with_suffix(".nim")

    main_file = src.resolve()
    
    if not main_file.exists():
        raise FileNotFoundError(f"source file not found: {main_file}")
    if not main_file.is_file():
        raise ValueError(f"source is not a file: {main_file}")
    if main_file.suffix != ".nim":
        raise ValueError(f"source must be a .nim file: {main_file}")

    local_root = Path(opts.mylib).expanduser().resolve() if opts.mylib else main_file.parent

    if opts.lib:
        lib_root = Path(opts.lib).expanduser().resolve() / "src"
    else:
        lib_root = Path("~/git/Nim-ACL/src").expanduser()

    bundle_tmp = None  # Archives are assembled in memory; no leaked temp tree.

    expanded = read_source(
        str(main_file), "", set(),
        lib_root, local_root, bundle_tmp,
        opts.mode, 0
    )

    header = provenance(lib_root, opts.source_ref, opts.source_repo, opts.mode, opts.tool_source_ref, opts.preview)
    outputPrefix = embed_bootstrap() if opts.mode == "embed" and EMBED_TEXTS else ""
    if opts.mode == "bundle" and BUNDLE_BYTES:
        outputPrefix = bundle_bootstrap(bundle_tmp, opts.keep_bundle_tmp)
    output = header + outputPrefix + "\n".join(expanded) + "\n"

    target = Path(opts.output).resolve()
    inputs = {Path(n).resolve() if Path(n).is_absolute() else
              ((local_root if n.startswith("mylib/") else lib_root) / n).resolve()
              for n in SOURCE_BYTES}
    if target in inputs:
        raise ValueError("output must not overwrite an input source")
    target.parent.mkdir(parents=True, exist_ok=True)
    # Replace only after successful expansion and provenance checks. On failure,
    # the wrapper won't copy an old combined.nim to the clipboard.
    with tempfile.NamedTemporaryFile(dir=target.parent, delete=False) as tmp:
        temp_path = Path(tmp.name)
        tmp.write(output.encode("utf-8"))
    try:
        os.replace(temp_path, target)
    finally:
        temp_path.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
