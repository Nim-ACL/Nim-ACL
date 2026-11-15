#!/usr/bin/env python3
"""Nim-ACL M195: focused portability checks on a disposable CI branch.

Runs under GitHub-hosted native Ubuntu/Windows; does not modify source or tags.
All generated files go to RUNNER_TEMP and a report folder in the checkout.
This is a correctness/compatibility gate, not a speedup benchmark.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_PARENT = 'aee1b2bf7aed40a9149f987c6e2d44923da0f3cc'
EXPECTED_TREE = 'd46de5ff928e88c028c9c49e79c6c94eba0af89c'
EXPECTED_NIM = os.environ.get('M195_NIM_VERSION', '2.2.4')
ALLOWED_DELTA = {
    '.github/workflows/nacl-m195-portability.yml',
    'tools/m195_portability_gate.py',
}
CASES = [
    'tests/test_extra_bellman_ford_path.nim',
    'tests/test_extra_combination_table.nim',
    'tests/test_extra_convert_base.nim',
    'tests/test_extra_eratosthenes.nim',
    'tests/test_extra_rolling_hash_append.nim',
    'tests/test_extra_slope_trick_merge.nim',
    'tests/test_extra_static_eratosthenes.nim',
]
CORE = '''import atcoder/[dsu, fenwicktree]
when not defined(M193Flag):
  {.error: "caller flag lost".}
static:
  doAssert not defined(danger)
  doAssert compileOption("overflowChecks")
var d = initDSU(5)
d.merge(0, 1)
d.merge(1, 2)
var bit = initFenwickTree[int](5)
bit.add(0, 7)
bit.add(3, 5)
doAssert d.size(1) == 3
doAssert bit.sum(0..<4) == 12
echo "M193_SMOKE_OK"
'''
HEADER = '''include atcoder/extra/header/chaemon_header
when not defined(M193Flag):
  {.error: "caller flag lost".}
static:
  doAssert not defined(danger)
  doAssert compileOption("overflowChecks")
let values = @[3, 1, 4]
var total = 0
for value in values: total += value
doAssert total == 8
echo "M193_SMOKE_OK"
'''


def capture(argv: list[str], cwd: Path, limit: int = 45) -> str:
    r = subprocess.run(argv, cwd=cwd, capture_output=True, text=True,
                       errors='replace', timeout=limit)
    if r.returncode:
        raise RuntimeError(f'COMMAND_FAILED: {argv[:3]}: {r.stderr[-1400:]}')
    return r.stdout.strip()


def git_guard() -> dict[str, str]:
    head = capture(['git', 'rev-parse', 'HEAD'], ROOT)
    parent = capture(['git', 'rev-parse', 'HEAD^'], ROOT)
    tree = capture(['git', 'rev-parse', 'HEAD^{tree}'], ROOT)
    parent_tree = capture(['git', 'rev-parse', 'HEAD^^{tree}'], ROOT)
    name_status = capture(['git','diff','--no-renames','--name-only','HEAD^','HEAD'], ROOT)
    changed = set(name_status.splitlines()) if name_status else set()
    if parent != EXPECTED_PARENT or parent_tree != EXPECTED_TREE:
        raise RuntimeError('PARENT_COMMIT_OR_TREE_MISMATCH')
    if changed != ALLOWED_DELTA:
        raise RuntimeError('UNEXPECTED_CI_BRANCH_FILE_CHANGES: '+repr(sorted(changed)))
    # On Actions checkout, src and tools should match the parent's source bytes.
    if not (ROOT/'src/atcoder/dsu.nim').is_file():
        raise RuntimeError('NIM_ACL_SOURCE_MISSING')
    return {'head':head,'parent':parent,'tree':tree,'parent_tree':parent_tree}


def native_compiler_preflight() -> dict[str, str]:
    if sys.platform == 'win32' and shutil.which('g++') is None:
        for d in [r'C:\msys64\ucrt64\bin',r'C:\msys64\mingw64\bin',
                  r'C:\ProgramData\chocolatey\bin']:
            if Path(d, 'g++.exe').is_file():
                os.environ['PATH'] = d + os.pathsep + os.environ.get('PATH','')
                break
    nim=shutil.which('nim')
    if nim is None:
        raise RuntimeError('NIM_COMPILER_NOT_ON_PATH')
    stdout=capture([nim,'--version'], ROOT)
    if 'Nim Compiler Version '+EXPECTED_NIM not in stdout:
        raise RuntimeError('NIM_VERSION_MISMATCH: '+stdout.splitlines()[0])
    gpp=shutil.which('g++')
    if gpp is None:
        raise RuntimeError('NATIVE_CPLUSPLUS_COMPILER_NOT_FOUND')
    version=capture([gpp,'--version'], ROOT).splitlines()[0]
    return {'nim':nim,'nim_version':EXPECTED_NIM,'gxx':gpp,'gxx_version':version}


def run_case(name: str, argv: list[str], cwd: Path, logdir: Path,
             timeout: int=180, expected_stdout: str | None=None) -> dict:
    """Never use shell=True (native Windows compatibility)."""
    print('CHECK_START='+name,flush=True)
    start=time.monotonic()
    timed_out=False
    try:
        p=subprocess.run(argv,cwd=cwd,capture_output=True,timeout=timeout,
                         text=True,errors='replace',env=os.environ.copy())
        rc=p.returncode
        stdout=p.stdout or ''
        stderr=p.stderr or ''
    except subprocess.TimeoutExpired as exc:
        timed_out=True
        rc=124
        stdout=(exc.stdout or b'').decode('utf-8','replace') if isinstance(exc.stdout,bytes) else (exc.stdout or '')
        stderr=(exc.stderr or b'').decode('utf-8','replace') if isinstance(exc.stderr,bytes) else (exc.stderr or '')
    except OSError as exc:
        rc=125;stdout='';stderr=str(exc)
    elapsed=round(time.monotonic()-start,3)
    logdir.mkdir(parents=True,exist_ok=True)
    log=(logdir/(name+'.log'))
    log.write_text('COMMAND '+repr(argv)+'\nSTDOUT\n'+stdout+'\nSTDERR\n'+stderr+'\n',encoding='utf-8')
    good=rc==0 and not timed_out
    if expected_stdout is not None:
        good=good and stdout.strip()==expected_stdout
    rec={'name':name,'status':'PASS' if good else 'FAIL','return_code':rc,
         'timeout':timed_out,'elapsed_seconds':elapsed,'log':str(log.relative_to(ROOT)),
         'expected_stdout':expected_stdout}
    print('CHECK_'+name+'='+rec['status'],flush=True)
    if not good:
        print('DIAGNOSTIC_START='+name,flush=True)
        print((stdout+'\n'+stderr)[-3000:],flush=True)
        print('DIAGNOSTIC_END='+name,flush=True)
    return rec


def main() -> int:
    parser=argparse.ArgumentParser()
    parser.add_argument('--report',default='m195-ci-report')
    ns=parser.parse_args()
    report=(ROOT/ns.report).resolve()
    if ROOT not in report.parents or report.exists():
        raise RuntimeError('INVALID_OR_EXISTING_REPORT_DIRECTORY')
    report.mkdir(parents=True)
    logdir=report/'logs';logdir.mkdir()
    tempbase=Path(os.getenv('RUNNER_TEMP', tempfile.gettempdir())).resolve()
    work=Path(tempfile.mkdtemp(prefix='nacl-m195-',dir=tempbase))
    rows=[];identity={};toolchain={}
    status='BLOCKED'
    try:
        identity=git_guard()
        toolchain=native_compiler_preflight()
        print('M195_OS='+platform.platform(),flush=True)
        print('M195_NIM='+toolchain['nim_version'],flush=True)
        if sys.platform != 'win32' and platform.system() != 'Linux':
            raise RuntimeError('UNEXPECTED_RUNNER_OS')
        # Existing 25 Python checks, run separately with logs.
        for short,rel in [('python20','tests/test_expander_submission.py'),
                          ('python5','tests/test_expander_flattened_exports.py')]:
            rows.append(run_case(short,[sys.executable,rel],ROOT,logdir,240))
        rows.append(run_case('nimble_check',['nimble','check'],ROOT,logdir,90))
        nim=toolchain['nim']
        for rel in CASES:
            stem=Path(rel).stem
            name='api_'+stem
            cache=work/('cache_'+stem)
            target=work/(stem+('.exe' if sys.platform=='win32' else ''))
            cmd=[nim,'cpp','-d:release','--opt:speed','--mm:orc',
                 '--checks:on','--overflowChecks:on','--hints:off',
                 '--nimcache:'+str(cache),'--out:'+str(target),'-r',rel]
            rows.append(run_case(name,cmd,ROOT,logdir,240))
        for key,src in [('core',CORE),('header',HEADER)]:
            for mode in ('plain','embed','bundle'):
                stem=key+'_'+mode
                pdir=work/stem;pdir.mkdir(parents=True)
                input_file=pdir/'source with spaces.nim'
                input_file.write_text(src,encoding='utf-8')
                output=pdir/'combined.nim'
                cmd=[sys.executable,str(ROOT/'expander.py'),str(input_file),
                     '--lib',str(ROOT),'--source-ref',identity['head'],
                     '--mode',mode,'--preview','--output',str(output)]
                generation=run_case('expand_'+stem,cmd,pdir,logdir,90)
                rows.append(generation)
                if generation['status']!='PASS':
                    continue
                text=output.read_text(encoding='utf-8',errors='replace')
                if not ('# Library source:' in text and identity['head'] in text):
                    raise RuntimeError('EXPANDED_SOURCE_PROVENANCE_MISSING: '+stem)
                if mode!='plain' and 'PREVIEW ONLY' not in text:
                    raise RuntimeError('EXPANDED_SOURCE_PREVIEW_LABEL_MISSING: '+stem)
                exe=pdir/('program.exe' if sys.platform=='win32' else 'program')
                cmd=[nim,'cpp','-d:release','--opt:speed','--mm:orc',
                     '--multimethods:on','--warning[SmallLshouldNotBeUsed]:off',
                     '--hints:off','--maxLoopIterationsVM:10000000000000',
                     '--maxCallDepthVM:10000000000000','--checks:on','--overflowChecks:on',
                     '-d:M193Flag','--nimcache:'+str(pdir/'nimcache'),
                     '--out:'+str(exe),str(output)]
                compilation=run_case('compile_'+stem,cmd,pdir,logdir,240)
                rows.append(compilation)
                if compilation['status']!='PASS':continue
                rows.append(run_case('run_'+stem,[str(exe)],pdir,logdir,30,
                                     'M193_SMOKE_OK'))
        status='PASS' if len(rows)==3+len(CASES)+18 and all(
            r['status']=='PASS' for r in rows) else 'BLOCKED'
    except Exception as exc:
        print('M195_ERROR='+type(exc).__name__+': '+str(exc),flush=True)
        (report/'ERROR.txt').write_text(type(exc).__name__+': '+str(exc)+'\n',encoding='utf-8')
    finally:
        summary={'status':status,'identity':identity,'toolchain':toolchain,
                 'os':platform.platform(),'python':sys.version,'checks':rows,
                 'completed_checks':len(rows),'passed_checks':sum(r['status']=='PASS' for r in rows),
                 'performance_benchmark':'NOT_RUN',
                 'remote_source_or_release_mutation':'NONE',
                 'source_lineage':'M192_PLUS_M193_EXACT_PARENT_COMMIT'}
        (report/'SUMMARY.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n',encoding='utf-8')
        print('\n===== NACL M195 CI RESULT START =====',flush=True)
        print('STATUS: '+status,flush=True)
        print('HOST_OS: '+platform.system(),flush=True)
        print('EXPECTED_NIM: '+EXPECTED_NIM,flush=True)
        print('CHECKS_COMPLETED: '+str(len(rows)),flush=True)
        print('CHECKS_PASSED: '+str(summary['passed_checks']),flush=True)
        print('PERFORMANCE_BENCHMARK: NOT_RUN',flush=True)
        print('===== NACL M195 CI RESULT END =====',flush=True)
    # Preserve results for upload; remove only ephemeral compiler products.
    shutil.rmtree(work,ignore_errors=True)
    return 0 if status=='PASS' else 1

if __name__=='__main__':
    sys.exit(main())
