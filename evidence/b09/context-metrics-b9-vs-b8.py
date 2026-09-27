#!/usr/bin/env python3
"""context-metrics-b9-vs-b8.py — B9's exit-gate clause "context metrics compared against B8".

READ-ONLY. Reads the ARCHIVED run records by run id out of a batch manifest, never the API, so the
numbers do not move under a reader. Extract fact 3 of this stop's workbook is the constraint:
there is no "context metric" in this instrument, only five token counters, so this script reports
exactly those five and names the absence rather than inventing a composite.

Usage: context-metrics-b9-vs-b8.py <manifest.tsv> <records-dir>
Exit 0 with the table; 2 on a missing file; 3 when no record carries a token counter.
"""
import json, pathlib, statistics, sys

if len(sys.argv) != 3:
    sys.stderr.write(__doc__ + "\n"); sys.exit(2)
man, recdir = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
if not man.is_file() or not recdir.is_dir():
    sys.stderr.write(f"missing: {man} or {recdir}\n"); sys.exit(2)

# THE FIVE COUNTERS, BY THEIR REAL NAMES, read off `.efficiency | keys` of an archived record and
# not from the schema doc: cachedTokens (not cacheReadTokens) and reportedTotalTokens (not
# totalTokens). The first version of this list used the doc's names and printed two rows of dashes,
# which reads as "the instrument does not carry them" when the instrument does. A field name
# guessed from prose is the same defect as a control reporting over a scope smaller than it claims.
FIELDS = ["inputTokens", "outputTokens", "cachedTokens", "cacheCreationTokens", "reportedTotalTokens"]
rows, hdr = [], None
for line in man.read_text().splitlines():
    if line.startswith("#"):
        continue
    f = line.split("\t")
    if hdr is None:
        hdr = {n: i for i, n in enumerate(f)}
        continue
    if not f[0].startswith("BE-"):
        continue
    rows.append(f)

buckets, seen_any = {}, False
for f in rows:
    rid = f[hdr["run_id"]]
    p = recdir / f"{rid}.json"
    if not p.is_file():
        continue
    rec = json.loads(p.read_text())
    eff = rec.get("efficiency") or {}
    key = (f[hdr["task"]], f[hdr["arm"]])
    b = buckets.setdefault(key, {k: [] for k in FIELDS})
    for k in FIELDS:
        v = eff.get(k)
        if isinstance(v, (int, float)):
            b[k].append(v); seen_any = True

if not seen_any:
    sys.stderr.write("no record carries a token counter — nothing to compare\n"); sys.exit(3)

def med(xs): return statistics.median(xs) if xs else None
print("B9 context metrics — the five token counters, by task and arm, from the ARCHIVED records.")
print("There is no single 'context metric' in this instrument (workbook extract fact 3); these five")
print("counters are the whole of what the exit-gate clause can be answered with.\n")
for task in sorted({k[0] for k in buckets}):
    print(f"{task}")
    print(f"  {'counter':<22}{'treated median':>16}{'control median':>16}{'delta':>12}{'n_t/n_c':>10}")
    for k in FIELDS:
        t = buckets.get((task, "treated"), {}).get(k, [])
        c = buckets.get((task, "control"), {}).get(k, [])
        mt, mc = med(t), med(c)
        if mt is None or mc is None:
            print(f"  {k:<22}{'-':>16}{'-':>16}{'-':>12}{len(t)}/{len(c):>4}"); continue
        d = "n/a" if mc == 0 else f"{(mt - mc) / mc * 100:+.2f} %"
        print(f"  {k:<22}{mt:>16.0f}{mc:>16.0f}{d:>12}{len(t):>6}/{len(c)}")
    print()
sys.exit(0)
