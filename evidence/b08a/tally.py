#!/usr/bin/env python3
"""Read the B8a manifest (and the shape classifications, when they exist) and report E-020's
registered quantities. DECIDES NOTHING — it computes and prints; every exclusion and every
verdict is written into experiments/E-020-decomposition-depth-BE005.md with its reason.

  ./evidence/b08a/tally.py evidence/b08a/batch-20260925T091510Z/manifest.tsv \
      [evidence/b08a/shape/classifications.tsv]

fisher2 is lifted verbatim from evidence/p04a/e005/analyse-e005.py so that a p-value here and
a p-value there are the same arithmetic.
"""
import csv
import sys
from math import comb
from statistics import median
from collections import defaultdict


def fisher2(a, b, c, d):
    n, r1, r2, c1 = a + b + c + d, a + b, c + d, a + c
    def pr(x):
        return comb(r1, x) * comb(r2, c1 - x) / comb(n, c1)
    lo, hi, p0 = max(0, c1 - r2), min(r1, c1), pr(a)
    return sum(pr(x) for x in range(lo, hi + 1) if pr(x) <= p0 + 1e-12)


def spread(vals):
    if not vals:
        return "n=0"
    return f"median {median(vals):.6g}  range {min(vals):.6g}-{max(vals):.6g}  n={len(vals)}"


# F13, registered in E-020 §"The F13 decision": control 07 is the only truncated run.
F13 = "ed58787c-6529-42ce-a677-065d86945bc2"
# The RUNNER's own failureClass marks TWO controls F13, not one. ed58787c is a correct label;
# 4abf7f01 is not (12 changed files, 41 model calls, 230 s - the control medians exactly). Both
# are reported as a third population so the reader can see what baseline-report.py's own rule costs.
RUNNER_F13 = {"ed58787c-6529-42ce-a677-065d86945bc2", "4abf7f01-cd54-4c77-962c-8bd4f8752466"}

man = sys.argv[1] if len(sys.argv) > 1 else "evidence/b08a/batch-20260925T091510Z/manifest.tsv"
shapefile = sys.argv[2] if len(sys.argv) > 2 else None

with open(man, encoding="utf-8") as fh:
    rows = [r for r in csv.DictReader((l for l in fh if not l.startswith("#")), delimiter="\t")]

shape = {}
if shapefile:
    try:
        with open(shapefile, encoding="utf-8") as fh:
            for r in csv.DictReader((l for l in fh if not l.startswith("#")), delimiter="\t"):
                shape[r["run_id"]] = r["adjudicated"]
    except FileNotFoundError:
        pass

arms = defaultdict(list)
for r in rows:
    arms[r["arm"]].append(r)

print(f"manifest: {man}   runs: {len(rows)}   arms: "
      + ", ".join(f"{a}={len(v)}" for a, v in sorted(arms.items())))
print()

for label, drop in (("WITH control 07 (the truncated run) - THE REGISTERED POPULATION", set()),
                    ("WITHOUT control 07 (the F13 decision)", {F13}),
                    ("WITHOUT BOTH runner-labelled F13 controls - what baseline-report.py does", RUNNER_F13)):
    print(f"=== {label} ===")
    tbl = {}
    for arm in ("treated", "control"):
        rs = [r for r in arms[arm] if r["run_id"] not in drop]
        passed = sum(1 for r in rs if r["evaluator_exit"] == "0")
        tbl[arm] = (passed, len(rs) - passed)
        print(f"  {arm:8s} evaluator pass {passed} of {len(rs)}")
    (a, b), (c, d) = tbl["treated"], tbl["control"]
    print(f"  P2 evaluator pass rate: Fisher two-sided p = {fisher2(a, b, c, d):.4f}"
          f"   (table [[{a},{b}],[{c},{d}]])")

    if shape:
        stbl = {}
        for arm in ("treated", "control"):
            rs = [r for r in arms[arm] if r["run_id"] not in drop]
            right = sum(1 for r in rs if shape.get(r["run_id"]) == "RIGHT")
            na = sum(1 for r in rs if shape.get(r["run_id"]) == "NO-ATTEMPT")
            stbl[arm] = (right, len(rs) - right)
            print(f"  {arm:8s} shape RIGHT {right} of {len(rs)}"
                  f"   (NO-ATTEMPT {na}, in the denominator only, per RULE.md)")
        (a, b), (c, d) = stbl["treated"], stbl["control"]
        print(f"  P3 shape classification: Fisher two-sided p = {fisher2(a, b, c, d):.4f}"
              f"   (table [[{a},{b}],[{c},{d}]])")
    print()

print("=== reported rows — median and range, never a mean alone (§4 step 8) ===")
for arm in ("treated", "control"):
    rs = arms[arm]
    keep = [r for r in rs if r["run_id"] != F13]
    print(f"  {arm}:")
    print(f"    cost        all        {spread([float(r['cost']) for r in rs])}")
    print(f"    cost        minus f13  {spread([float(r['cost']) for r in keep])}")
    print(f"    duration_s  minus f13  {spread([int(r['duration_ms']) // 1000 for r in keep])}")
    print(f"    modelCalls  all        {spread([int(r['model_calls']) for r in rs])}")
    print(f"    modelCalls  minus f13  {spread([int(r['model_calls']) for r in keep])}")
    print(f"    changed     all        {spread([int(r['changed']) for r in rs])}")
print()

print("=== P4 — delegation count in {3,5}, one-arm, treated only ===")
for r in arms["treated"]:
    s, t = r["deleg_stream"], r["deleg_telemetry"]
    flag = "IN {3,5}" if s in ("3", "5") else "*** OUTSIDE {3,5} ***"
    agree = "agree" if s == t else f"*** SOURCES DISAGREE stream={s} telemetry={t} ***"
    print(f"  {r['seq']} {r['run_id'][:8]}  stream={s:>3}  telemetry={t:>3}  {flag}  {agree}")
ds = [r["deleg_stream"] for r in arms["treated"]]
print(f"  in {{3,5}}: {sum(1 for x in ds if x in ('3', '5'))} of {len(ds)}"
      f"   outside: {sum(1 for x in ds if x not in ('3', '5'))}")
print()

print("=== delivery conditions, every treated run (row 0a check) ===")
bad = [r for r in arms["treated"]
       if not (r["cond_a"] == "ok" and r["cond_b"] == "ok" and r["cond_c"] == "ok"
               and r["cond_d"].startswith("ok"))]
print(f"  treated runs failing any of the four: {len(bad)}  -> row 0a fires on {len(bad)}")
print("  control runs with all three hashes null: "
      f"{sum(1 for r in arms['control'] if r['agent_hash'] == r['instr_hash'] == r['skills_hash'] == 'null')}"
      f" of {len(arms['control'])}")
mods = {r["model"] for r in rows}
print(f"  runtime.model over all {len(rows)} runs: {mods}")


print()
print("=== the rubric sheets, codex, gate-passing runs only (Decision D) ===")
try:
    with open("evidence/b08a/sheets-codex.tsv", encoding="utf-8") as fh:
        sheets = [r for r in csv.DictReader((l for l in fh if not l.startswith("#")), delimiter="\t")]
except FileNotFoundError:
    sheets = []
if sheets:
    cats = ("architecture_consistency", "maintainability", "test_quality")
    for arm in ("treated", "control"):
        rs = [r for r in sheets if r["arm"] == arm]
        print(f"  {arm} (n={len(rs)}):")
        for c in cats:
            vals = [int(r[c]) for r in rs if r[c] != "null"]
            nulls = sum(1 for r in rs if r[c] == "null")
            print(f"    {c:26s} {spread(vals)}   nulls={nulls}   values={[int(r[c]) for r in rs]}")
        print(f"    {'change_focus':26s} UNMEASURED - author decision 2026-09-25 item 1, "
              f"reported not computed: {[r['change_focus'] for r in rs]}")
    t = [int(r["architecture_consistency"]) for r in sheets if r["arm"] == "treated"]
    c = [int(r["architecture_consistency"]) for r in sheets if r["arm"] == "control"]
    print(f"  P1 registered outcome: treated median {median(t):g} (n={len(t)}) "
          f"vs control median {median(c):g} (n={len(c)}); P1 predicted 2 vs 0")
    print(f"  rubric shas all 945817b8c509: "
          f"{all(r['rubric_sha'] == '945817b8c509' for r in sheets)}")

