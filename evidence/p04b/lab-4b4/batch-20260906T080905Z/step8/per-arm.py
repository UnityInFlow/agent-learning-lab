#!/usr/bin/env python3
"""Per-arm median and range for E-007, re-derivable by a stranger.

    ./per-arm.py <dir-of-run-documents>

The directory holds one JSON per run, exactly as `GET /api/runs/{id}` returns it, for the
twenty runs of EXP-4B-ORCH-OVERHEAD. Fetch them with:

    for id in $(awk -F'\t' 'NR>3{print $3}' ../manifest.tsv); do
      curl -s "$LAB_OBSERVATORY_API/api/runs/$id" > "$id.json"
    done

`make baseline-report` is single-arm and pools both arms, which is not the comparison this
experiment asks for. Median and range only; never a mean alone (§4 step 8).
"""
import json, glob, os, sys, statistics as st

rows = []
for f in glob.glob(os.path.join(sys.argv[1], '*.json')):
    r = json.load(open(f))
    if r.get('experimentKey') != 'EXP-4B-ORCH-OVERHEAD':
        continue
    e, b = r['efficiency'], r['behavior']
    rows.append(dict(
        arm='O' if r['variant'] == 'orchestration-4b4-P1' else 'C',
        dur=e['durationMs'] / 1000.0, cost=e['estimatedCost'],
        tok=e['inputTokens'] + e['outputTokens'], cache=e['cachedTokens'],
        tools=b['toolCalls'], models=b['modelCalls'], fails=b['toolFailures']))

assert len(rows) == 20, f"expected 20 runs, found {len(rows)}"
hdr = f"{'metric':14} {'arm':4} {'n':>2} {'min':>10} {'median':>10} {'max':>10}   {'O-C median':>11}"
print(hdr); print('-' * len(hdr))
for key, label, fmt in [('dur', 'duration (s)', '{:.0f}'), ('cost', 'cost ($)', '{:.4f}'),
                        ('tok', 'in+out tokens', '{:.0f}'), ('cache', 'cached tokens', '{:.0f}'),
                        ('tools', 'tool calls', '{:.0f}'), ('models', 'model calls', '{:.0f}')]:
    meds = {}
    for arm in ('O', 'C'):
        v = sorted(r[key] for r in rows if r['arm'] == arm)
        meds[arm] = st.median(v)
        print(f"{label:14} {arm:4} {len(v):>2} {fmt.format(min(v)):>10} "
              f"{fmt.format(st.median(v)):>10} {fmt.format(max(v)):>10}")
    d = meds['O'] - meds['C']
    print(f"{'':14} {'':4} {'':>2} {'':>10} {'':>10} {'':>10}   {fmt.format(d):>11}"
          f"  ({100 * d / meds['C']:+.1f}%)")
    print()
print("tool failures observed, both arms:", sorted(set(r['fails'] for r in rows)))
