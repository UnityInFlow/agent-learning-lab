#!/usr/bin/env python3
"""E-008 per-arm report from the API (the registered report tool baseline-report.py is
single-arm and pools both arms under one key — E-007 §4 step 8 recorded that), plus P6's
delegation count from the observatory telemetry file.

    ./per-arm.py <manifest.tsv> [events.jsonl]
"""
import sys, json, re, statistics as st, urllib.request
API = 'http://127.0.0.1:18081'
manifest = sys.argv[1]; events = sys.argv[2] if len(sys.argv) > 2 else None
runs = []
for line in open(manifest):
    if line.startswith('#'): continue
    p = line.rstrip('\n').split('\t')
    if p[0] == 'seq': continue
    runs.append((p[0], p[1], p[2]))
assert len(runs) == 10, f'{len(runs)} rows'
recs = {}
for seq, arm, rid in runs:
    with urllib.request.urlopen(f'{API}/api/runs/{rid}', timeout=15) as r:
        recs[rid] = json.load(r)
def q(vals):
    v = sorted(vals); n = len(v)
    med = st.median(v)
    q1 = st.median(v[:n//2]); q3 = st.median(v[(n+1)//2:])
    return med, q1, q3, v[0], v[-1]
metrics = {
  'estimatedCost': lambda d: d['efficiency']['estimatedCost'],
  'durationS': lambda d: d['efficiency']['durationMs']/1000,
  'modelCalls': lambda d: d['behavior']['modelCalls'],
  'toolCalls': lambda d: d['behavior']['toolCalls'],
  'inOutTokens': lambda d: d['efficiency']['inputTokens'] + d['efficiency']['outputTokens'],
  'cachedTokens': lambda d: d['efficiency']['cachedTokens'],
  'addedLines': lambda d: d['result']['addedLines'],
  'changedFiles': lambda d: len(d['result']['changedFiles']),
}
print(f'E-008 per-arm, n = 5 pairs, from {API}\n')
print(f"{'seq':4}{'arm':9}{'run':10}{'model':28}{'ver':8}{'instrHash':38}{'eval':5}" + ''.join(f'{m:>13}' for m in metrics))
for seq, arm, rid in runs:
    d = recs[rid]
    ih = (d.get('customization') or {}).get('instructionsHash') or 'null'
    ev = d['evaluation'].get('exitCode') if isinstance(d.get('evaluation'), dict) else d.get('evaluation')
    print(f"{seq:4}{arm:9}{rid[:8]:10}{d['runtime']['model']:28}{d['runtime']['version'].split()[0]:8}{ih:38}{str(ev):5}" + ''.join(f'{metrics[m](d):>13.4g}' for m in metrics))
print('\nPER ARM: median (q1–q3, range)')
for m, f in metrics.items():
    out = f'  {m:14}'
    for arm in ('F', 'control'):
        vals = [f(recs[rid]) for _, a, rid in runs if a == arm]
        med, q1, q3, lo, hi = q(vals)
        out += f'   {arm:8} {med:>9.4g} ({q1:.4g}–{q3:.4g}, {lo:.4g}–{hi:.4g})'
    fv = st.median([f(recs[rid]) for _, a, rid in runs if a == 'F']); cv = st.median([f(recs[rid]) for _, a, rid in runs if a == 'control'])
    out += f'   delta {(fv-cv)/cv*100:+.1f} %' if cv else ''
    print(out)
if events:
    print(f'\nP6 — delegation events per run from {events} (lines carrying the run id; tool_name/name in {{Task, Agent}})')
    pat = re.compile(r'"(tool_name|name)"\s*:\s*"(Task|Agent)"')
    tot = {rid: 0 for _, _, rid in runs}; deleg = {rid: 0 for _, _, rid in runs}
    with open(events, errors='replace') as fh:
        for line in fh:
            for rid in tot:
                if rid in line:
                    tot[rid] += 1
                    if pat.search(line): deleg[rid] += 1
    for seq, arm, rid in runs:
        print(f'  {seq} {arm:8} {rid[:8]}  events {tot[rid]:5}  delegation {deleg[rid]}')
