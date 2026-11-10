#!/usr/bin/env python3
"""Run the matching expander safely; never delete the generated source."""
import argparse
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys


def clipboard_command(system):
    if system == "Darwin":
        return ["pbcopy"] if shutil.which("pbcopy") else None
    if system == "Windows":
        powershell = shutil.which("powershell") or shutil.which("pwsh")
        if powershell:
            return [powershell, "-NoProfile", "-NonInteractive", "-Command",
                    "[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false); "
                    "Set-Clipboard -Value ([Console]::In.ReadToEnd())"]
        return None
    if system == "Linux":
        for exe, args in [("wl-copy", []), ("xsel", ["--clipboard", "--input"]),
                          ("xclip", ["-selection", "clipboard"])]:
            if exe == "wl-copy" and not os.environ.get("WAYLAND_DISPLAY"):
                continue
            if shutil.which(exe):
                return [exe] + args
    return None


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source")
    parser.add_argument("--lib")
    parser.add_argument("--output")
    parser.add_argument("--no-clipboard", action="store_true")
    opts, extra = parser.parse_known_args(argv)
    source = Path(opts.source).expanduser().resolve()
    suffix = source.suffix.lower()
    if suffix not in {".nim", ".cpp"}:
        parser.error("source extension must be .nim or .cpp")
    output = Path(opts.output or ("combined" + suffix)).resolve()
    if output == source:
        parser.error("output must not overwrite source")
    if suffix == ".nim":
        tool = Path(__file__).resolve().with_name("expander.py")
        root = Path(opts.lib).expanduser().resolve() if opts.lib else tool.parent
        command = [sys.executable, str(tool), str(source), "--lib", str(root),
                   "--output", str(output)] + extra
    else:
        root = Path(opts.lib).expanduser().resolve() if opts.lib else Path.home() / "git/ac-library"
        command = [sys.executable, str(root / "expander.py"), str(source),
                   "--lib", str(root), "--output", str(output)] + extra
    # A failed expansion never copies stale output or returns success.
    completed = subprocess.run(command, check=False)
    if completed.returncode:
        return completed.returncode
    if not output.is_file():
        raise RuntimeError("expander reported success without its output file")
    if not opts.no_clipboard:
        command = clipboard_command(platform.system())
        if command is None:
            print("Clipboard unavailable; generated file retained: " + str(output), file=sys.stderr)
        else:
            copied = subprocess.run(command, input=output.read_bytes(), check=False)
            if copied.returncode:
                print("Clipboard failed; generated file retained: " + str(output), file=sys.stderr)
                return copied.returncode
    print("OUTPUT=" + str(output))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
