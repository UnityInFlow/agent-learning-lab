#!/usr/bin/env python3
"""Median and range per arm per task, over the REGISTERED B9 population ONLY.

    ./evidence/b09/report-b9-registered.py            from agent-learning-lab/

WHY THIS EXISTS RATHER THAN `make baseline-report`. `run-b9-preflight.sh:134` runs the
preflight pair under the SAME experiment key as the batch, with the comment `REGISTERED`.
So every API-side aggregate over `EXP-B9-ROUTER-BE003` sees 25 runs and over
`EXP-B9-ROUTER-BE004` sees 24, where the registered population is 20 each: eight preflight
runs and one recorded orphan (`6d728d76`, evidence/b09/batch-20260926T133740Z/ORPHAN.md)
share the key. `make baseline-report` POOLS them silently and prints a median that is not
this experiment's. `analyze-experiment.py` REFUSES, exit 2, naming 12 and 13 measuring runs
against an expected 10 — which is the instrument doing its job.

This reads the 40 archived run records BY RUN ID off run-ids.tsv, so no run outside the
registered batch can enter a number, and every value is re-derivable from the repository
without the API.

Median and full range, never a mean alone — B2's exit gate, and the reason is in
agent-observatory/runner/baseline-report.py's header.
"""
import json, statistics, pathlib, sys

BATCH = pathlib.Path("evidence/b09/batch-20260926T151319Z")
ids = BATCH / "run-ids.tsv"
if not ids.is_file():
    sys.exit("cannot read %s" % ids)

METRICS = [
    ("estimated cost", lambda r: r.get("efficiency", {}).get("estimatedCost")),
    ("total tokens",   lambda r: r.get("efficiency", {}).get("reportedTotalTokens")),
    ("model calls",    lambda r: r.get("behavior", {}).get("modelCalls")),
    ("tool calls",     lambda r: r.get("behavior", {}).get("toolCalls")),
    ("perm denials",   lambda r: r.get("behavior", {}).get("permissionDenials")),
    ("duration (s)",   lambda r: (r.get("efficiency", {}).get("durationMs") or 0) / 1000.0),
]

rows = []
for line in ids.read_text().splitlines():
    task, seq, arm, rid, _wt = line.split("\t")
    doc = json.loads((BATCH / "run-records" / f"{rid}.json").read_text())
    rows.append((task, arm, rid, doc))

print("B9 registered population — 40 runs, read by run id from the archived records.")
print("Preflight and orphan runs share the experiment key and are NOT in this report.\n")

for task in ("BE-003", "BE-004"):
    print("=" * 72)
    print(task)
    for arm in ("agent-v1.2-knowledge", "agent-v1.1"):
        sub = [d for t, a, _i, d in rows
               if t == task and d.get("variant") == arm]
        label = "treated" if arm.endswith("knowledge") else "control"
        passed = sum(1 for d in sub if d.get("evaluation", {}).get("exitCode") == 0)
        print(f"\n  {label:8} variant={arm}  n={len(sub)}  evaluator-passing {passed}/{len(sub)}")
        print(f"  {'metric':<16} {'n':>3} {'min':>12} {'median':>12} {'max':>12}")
        print(f"  {'-'*16} {'-'*3} {'-'*12} {'-'*12} {'-'*12}")
        for name, get in METRICS:
            xs = sorted(x for x in (get(d) for d in sub) if x is not None)
            if not xs:
                continue
            print(f"  {name:<16} {len(xs):>3} {xs[0]:>12.4f} "
                  f"{statistics.median(xs):>12.4f} {xs[-1]:>12.4f}")

    t = sorted(d["efficiency"]["estimatedCost"] for _t, _a, _i, d in rows
               if _t == task and d.get("variant", "").endswith("knowledge"))
    c = sorted(d["efficiency"]["estimatedCost"] for _t, _a, _i, d in rows
               if _t == task and d.get("variant") == "agent-v1.1")
    mt, mc = statistics.median(t), statistics.median(c)
    print(f"\n  cost median treated {mt:.6f} vs control {mc:.6f} = {(mt/mc-1)*100:+.2f} %")
print()
print("DURATION CARRIES A KNOWN CONTAMINANT AND IS NOT A RESULT: run c49eec44 records")
print("5420 s against a batch median near 117 s, because the batch spanned a rate window.")
print("§4 step 6: exclude duration, keep the run.")
