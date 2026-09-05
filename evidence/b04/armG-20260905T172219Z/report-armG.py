#!/usr/bin/env python3
"""Arm G (deliberate failure, `tools:` line deleted) — the numbers E-006 §F reads.

WHY THIS EXISTS AND NOT `make baseline-report`. baseline-report.py selects by
experimentKey alone and reports ONE arm per key. EXP-B4-DELIBERATE-NOTOOLS holds
two variants — the arm and its concurrent plain control — so the Makefile target
would average them together and call two arms one. Same reason report-e006.py
exists for batch 2.

MEDIAN, RANGE AND QUARTILES ONLY. No mean anywhere: prompt section 4 step 8.
n = 5 per arm, so nothing here is a property; it is true of these five runs.

Re-derive:  python3 report-armG.py     (reads records/*.json, fetched from
            GET /api/runs/<id> and committed beside this file)
"""
import json, glob, os, statistics as st

HERE = os.path.dirname(os.path.abspath(__file__))
ARM, CTL = 'agent-v1.0-notools', 'baseline-armG-window'

def quartile(xs, p):
    xs = sorted(xs); n = len(xs); i = (n - 1) * p
    lo = int(i); hi = min(lo + 1, n - 1)
    return xs[lo] + (xs[hi] - xs[lo]) * (i - lo)

rows = []
for f in sorted(glob.glob(os.path.join(HERE, 'records', '*.json'))):
    d = json.load(open(f))
    ev, res, beh, eff = d['evaluation'], d['result'], d['behavior'], d['efficiency']
    rows.append(dict(id=d['runId'][:8], variant=d['variant'],
                     runtime=d['runtime']['version'], model=d['runtime']['model'],
                     toolCalls=beh['toolCalls'], modelCalls=beh['modelCalls'],
                     estimatedCost=eff['estimatedCost'], durationS=eff['durationMs'] / 1000,
                     addedLines=res['addedLines'], changedFiles=len(res['changedFiles']),
                     acc=ev['acceptanceCriteriaPassed'], accTotal=ev['acceptanceCriteriaTotal'],
                     passed=ev['passed'], exitCode=ev['exitCode']))

# A registered variable that moved would void the comparison. Assert, do not assume.
assert {r['runtime'] for r in rows} == {'2.1.261 (Claude Code)'}, 'runtime moved'
assert {r['model'] for r in rows} == {'claude-haiku-4-5-20251001'}, 'model moved'
assert all(r['exitCode'] == 0 for r in rows), 'a run did not pass the evaluator'

for variant in (ARM, CTL):
    g = [r for r in rows if r['variant'] == variant]
    print(f'--- {variant}   n={len(g)}')
    for m in ('toolCalls', 'modelCalls', 'estimatedCost', 'durationS', 'addedLines', 'changedFiles'):
        xs = [r[m] for r in g]
        print(f'    {m:14s} median={st.median(xs):9.3f}  range={min(xs)}–{max(xs)}'
              f'  Q1={quartile(xs,.25):.3f} Q3={quartile(xs,.75):.3f}  {sorted(xs)}')
    print(f'    acceptance {g[0]["accTotal"]}/{g[0]["accTotal"]} on '
          f'{sum(1 for r in g if r["acc"] == r["accTotal"])} of {len(g)}; '
          f'changedFiles==3 on {sum(1 for r in g if r["changedFiles"] == 3)} of {len(g)}, '
          f'>=4 on {sum(1 for r in g if r["changedFiles"] >= 4)}')

arm = st.median([r['toolCalls'] for r in rows if r['variant'] == ARM])
ctl = st.median([r['toolCalls'] for r in rows if r['variant'] == CTL])
band = ('<=22 -> harness' if arm <= 22 else
        '>=25 -> prose'   if arm >= 25 else
        '23-24 -> NEITHER, registered as neither before the run')
print(f'\nF2 band (registered before the run): armG median toolCalls = {arm:g}  ->  {band}')
print(f'Unregistered co-variate: delta vs its own concurrent control = {arm - ctl:+g} '
      f'(armG {arm:g} - control {ctl:g}). Not a registered outcome; not a result.')
