#!/usr/bin/env python3
"""M196 Ubuntu 24.04 / Nim 2.2.4 exploratory expander performance comparison.

Requires a single-purpose GitHub Actions branch containing exactly this worker
and the corresponding workflow on top of pinned, locally validated Nim-ACL.
No modifications to canonical source, remote master, or tags. Results are
reference measurements on a shared GitHub-hosted runner, not AtCoder speed claims.
"""
from __future__ import annotations

import hashlib
import json
import os
import platform
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARENT = 'aee1b2bf7aed40a9149f987c6e2d44923da0f3cc'
PARENT_TREE = 'd46de5ff928e88c028c9c49e79c6c94eba0af89c'
CI_FILES = {'.github/workflows/nacl-m196-ubuntu-perf.yml', 'tools/m196_ubuntu_perf.py'}
MODES = ('plain','embed','bundle')
COMPILER_REPEATS = 2
RUNTIME_REPEATS = 7

# Stable workloads and stdin (input supplied at runtime, not compiler-folded).
# Both use only modules that previously passed the M195 portability gate.
WORKLOADS = {
    'dsu_fenwick': '''import std/strutils
import atcoder/[dsu,fenwicktree]
let steps = parseInt(stdin.readLine())
const n = 8192
var uf = initDSU(n)
var ft = initFenwickTree[int](n)
var seed = 123456789'u32
var checksum: int64 = 0
for i in 0..<steps:
  seed = seed xor (seed shl 13)
  seed = seed xor (seed shr 17)
  seed = seed xor (seed shl 5)
  let p = int(seed and 8191'u32)
  ft.add(p, 1)
  if (i and 31) == 0:
    discard uf.merge(p, (p + (i and 255)) and 8191)
  if (i and 127) == 0:
    checksum += int64(ft.sum(0..<p))
echo checksum, ":", uf.size(0), ":", ft.sum(0..<n)
''',
    'header_array': '''include atcoder/extra/header/chaemon_header
import std/strutils
let steps = parseInt(stdin.readLine())
const n = 16384
var arr = newSeq[int](n)
var seed = 7654321'u32
var checksum: int64 = 0
for i in 0..<steps:
  seed = seed xor (seed shl 13)
  seed = seed xor (seed shr 17)
  seed = seed xor (seed shl 5)
  let pos = int(seed and 16383'u32)
  let other = (pos + 1) and 16383
  arr[pos] = (arr[pos] + arr[other] + int(seed and 255'u32)) mod 1000000007
  if (i and 1023) == 0:
    checksum += int64(arr[pos])
echo checksum, ":", arr[0], ":", seed
''',
}
INPUTS = {'dsu_fenwick': '2500000\n', 'header_array': '5000000\n'}


def sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def cmd(args: list[str], cwd: Path, timeout: int, stdin: str | None=None):
    started = time.perf_counter()
    try:
        p = subprocess.run(args,cwd=cwd,input=stdin,text=True,
                           encoding='utf-8',errors='replace',capture_output=True,
                           timeout=timeout, env={**os.environ,'PYTHONDONTWRITEBYTECODE':'1'})
        return (p.returncode, p.stdout, p.stderr, round(time.perf_counter()-started,6))
    except subprocess.TimeoutExpired as exc:
        msg = f'Run exceeded {timeout} seconds: '+repr(args[:3])
        raise RuntimeError(msg) from exc


def must_run(args,cwd,timeout=120,stdin=None):
    rc,out,err,sec = cmd(args,cwd,timeout,stdin)
    if rc:
        raise RuntimeError('COMMAND_FAILED '+str(rc)+' '+repr(args[:4])+':\n'+(out+'\n'+err)[-2800:])
    return out,err,sec


def identity_check():
    head,_,_ = must_run(['git','rev-parse','HEAD'],ROOT)
    parent,_,_ = must_run(['git','rev-parse','HEAD^'],ROOT)
    tree,_,_ = must_run(['git','rev-parse','HEAD^^{tree}'],ROOT)
    changed,_,_ = must_run(['git','diff','--no-renames','--name-only','HEAD^','HEAD'],ROOT)
    actual = set(changed.splitlines())
    if parent.strip()!=PARENT or tree.strip()!=PARENT_TREE or actual!=CI_FILES:
        raise RuntimeError('CI_BRANCH_LINEAGE_OR_FILES_MISMATCH')
    state,_,_=must_run(['git','status','--porcelain=v1','--untracked-files=all'],ROOT)
    if state.strip():
        raise RuntimeError('CI_CHECKOUT_ALREADY_DIRTY')
    return head.strip()


def environment():
    if platform.system()!='Linux':
        raise RuntimeError('EXPECTED_LINUX_HOST')
    try:
        osrel=Path('/etc/os-release').read_text(errors='replace')
    except OSError:
        osrel=''
    if 'ID=ubuntu' not in osrel:
        raise RuntimeError('EXPECTED_UBUNTU_HOST')
    version,_,_ = must_run(['nim','--version'],ROOT)
    if 'Nim Compiler Version 2.2.4' not in version:
        raise RuntimeError('EXPECTED_NIM_2_2_4')
    gcc,_,_ = must_run(['g++','--version'],ROOT)
    model='UNKNOWN'
    try:
        for line in Path('/proc/cpuinfo').read_text().splitlines():
            if line.startswith('model name'):
                model=line.split(':',1)[-1].strip();break
    except OSError:pass
    return {'os':platform.platform(),'cpu':model, 'logical_cpus':os.cpu_count(),
            'nim':version.splitlines()[0], 'gpp':gcc.splitlines()[0],
            'runner_image':os.getenv('ImageOS',''), 'runner_name_is_shared':True,
            'nim_flags':'cpp -d:release --opt:speed --mm:orc',
            'perf_conclusion':'EXPLORATORY_HOSTED_RUNNER_NOT_ATCODER_CPU'}


def main():
    head=identity_check()
    env=environment()
    output=ROOT/'m196-ubuntu-perf-report'
    if output.exists():raise RuntimeError('REPORT_DIR_ALREADY_EXISTS')
    output.mkdir()
    summary={'status':'BLOCKED','ci_commit':head,'environment':env,
             'methodology':{'compile_repeats':COMPILER_REPEATS,'runtime_repeats':RUNTIME_REPEATS,
                            'modes':MODES,'workloads':list(WORKLOADS),
                            'shared_runner':True, 'performance_claim_allowed':False,
                            'workload_same_source_per_mode':True,
                            'compile_cache':'FRESH_PER_MODE_AND_TRIAL',
                            'no_danger_or_checks_off':True},
             'workloads':{}, 'bench_results':[], 'error':None}
    work=Path(tempfile.mkdtemp(prefix='nacl-m196-'))
    try:
        for key,source in WORKLOADS.items():
            (work/key).mkdir()
            src=work/key/'main.nim';src.write_text(source,encoding='utf-8')
            expanded={}
            for mode in MODES:
                dest=work/key/('combined_'+mode+'.nim')
                _,_,generation=must_run([sys.executable,str(ROOT/'expander.py'),str(src),
                     '--lib',str(ROOT),'--source-ref',head,'--mode',mode,'--preview',
                     '--output',str(dest)],work/key,240)
                content=dest.read_bytes()
                if b'# Library source:' not in content or head.encode() not in content:
                    raise RuntimeError('EXPANDER_PROVENANCE_MISSING_'+mode)
                expanded[mode]={'path':str(dest),'sha256':sha(content),'size':len(content),
                                'generation_seconds':generation}
            summary['workloads'][key]={'source_sha256':sha(src.read_bytes()),
                'input':INPUTS[key].strip(),'expanded':expanded}
            gold=None
            for mode in MODES:
                timings=[];runs=[]
                for trial in range(COMPILER_REPEATS):
                    exe=work/key/('exe_'+mode+'_'+str(trial))
                    args=['nim','cpp','-d:release','--opt:speed','--mm:orc',
                          '--multimethods:on','--warning[SmallLshouldNotBeUsed]:off',
                          '--maxLoopIterationsVM:10000000000000',
                          '--maxCallDepthVM:10000000000000',
                          '--hints:off','--verbosity:0',
                          '--nimcache:'+str(work/key/('nimcache_'+mode+'_'+str(trial))),
                          '--out:'+str(exe),expanded[mode]['path']]
                    _,_,compile_seconds=must_run(args,work/key,480)
                    timings.append(compile_seconds)
                    # output correctness is checked on *each* compiled binary.
                    stdout,_,_ = must_run([str(exe)],work/key,60,INPUTS[key])
                    if gold is None:gold=stdout
                    if stdout!=gold:
                        raise RuntimeError('OUTPUT_MISMATCH_'+key+'_'+mode)
                    if trial==0:
                        # Warm once; measure repeated wall time on the same binary.
                        _,_,_=must_run([str(exe)],work/key,60,INPUTS[key])
                        for i in range(RUNTIME_REPEATS):
                            got,_,secs=must_run([str(exe)],work/key,60,INPUTS[key])
                            if got!=gold:raise RuntimeError('OUTPUT_CHANGED_DURING_BENCH')
                            runs.append(secs)
                summary['bench_results'].append({'workload':key,'mode':mode,
                   'compile_seconds':timings,'runtime_seconds':runs,
                   'compile_median':statistics.median(timings),
                   'runtime_median':statistics.median(runs),
                   'output_sha256':sha(gold.encode('utf-8'))})
                print('M196_CASE='+key+'/'+mode+' COMPILE_MEDIAN_S='+
                      str(round(statistics.median(timings),3))+' RUNTIME_MEDIAN_S='+
                      str(round(statistics.median(runs),4)),flush=True)
        summary['status']='PASS'
        print('M196_PERF_DATA_CAPTURE=PASS',flush=True)
    except BaseException as exc:
        summary['error']=type(exc).__name__+': '+str(exc)
        print('M196_ERROR='+summary['error'],flush=True)
    finally:
        # All benchmark source, expanded files, and selected outputs for audit.
        for key in WORKLOADS:
            p=work/key/'main.nim'
            if p.is_file():
                d=output/'sources';d.mkdir(exist_ok=True)
                (d/(key+'.nim')).write_bytes(p.read_bytes())
        (output/'SUMMARY.json').write_text(json.dumps(summary,ensure_ascii=False,sort_keys=True,indent=2)+'\n')
        shutil.rmtree(work,ignore_errors=True)
        print('===== NACL M196 RESULT START =====',flush=True)
        print('STATUS: '+summary['status'],flush=True)
        print('COMPLETED_CASES: '+str(len(summary['bench_results']))+'/6',flush=True)
        print('RUNTIME_PERFORMANCE_CLAIM: EXPLORATORY_ONLY',flush=True)
        print('===== NACL M196 RESULT END =====',flush=True)
    return 0 if summary['status']=='PASS' else 1


if __name__ == '__main__':
    sys.exit(main())
