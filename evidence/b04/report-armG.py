#!/usr/bin/env python3
"""E-006 arm G (§4 step 9, the deliberate failure) — median, range and quartiles per arm.

    ./evidence/b04/report-armG.py

SEPARATE FROM report-e006.py ON PURPOSE. That script is the evidence step 8 closed on and is
not edited to serve a later step; §6 forbids editing an instrument whose output is already a
result. This one differs from it in exactly three constants — the experiment key, the two
variant names, and the batch-2 reference column it prints beside them — and is otherwise the
same arithmetic, so the two arms' numbers stay comparable by construction rather than by
assertion.

WHAT IT PRINTS AND WHY. Arm G's own medians, and beside each the batch-2 numbers F2 was
registered against, so a reader does not have to hold two tables in their head to see whether
the prediction landed. THE BATCH-2 COLUMN IS RE-READ FROM THE API HERE, not typed in from the
step-8 report: a hand-copied reference number is a claim, and this project has already been
bitten by one.

NO MEAN ANYWHERE. Median, range and quartiles only, and only over runs that passed every gate.
"""
import json
import sys
import urllib.request

API = "http://localhost:8081"
ARMG_KEY = "EXP-B4-DELIBERATE-NOTOOLS"
BATCH2_KEY = "EXP-B4-AGENT-BOUNDARY"
BATCH2_VERSION = "2.1.261"      # batch 1 (2.1.260) was aborted and is excluded, as at step 8


def fetch(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)


def median(xs):
    s = sorted(xs)
    n = len(s)
    if n == 0:
        return None
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def quartiles(xs):
    s = sorted(xs)
    n = len(s)
    if n < 4:
        return None, None
    return median(s[: n // 2]), median(s[(n + 1) // 2:])


def fmt(x, unit=""):
    if x is None:
        return "-"
    return f"{x:.4g}{unit}" if isinstance(x, float) else f"{x}{unit}"


def passing(rs):
    return [r for r in rs if (r.get("evaluation") or {}).get("exitCode") == 0]


METRICS = [
    ("behavior.toolCalls", lambda r: r["behavior"]["toolCalls"], ""),
    ("behavior.modelCalls", lambda r: r["behavior"]["modelCalls"], ""),
    ("efficiency.estimatedCost", lambda r: r["efficiency"]["estimatedCost"], ""),
    ("efficiency.durationMs", lambda r: r["efficiency"]["durationMs"] / 1000.0, "s"),
    ("result.addedLines", lambda r: r["result"]["addedLines"], ""),
    ("result.changedFiles", lambda r: len(r["result"]["changedFiles"]), ""),
]


def main():
    allruns = fetch(f"{API}/api/runs")
    armg = [r for r in allruns if r.get("experimentKey") == ARMG_KEY]
    batch2 = [r for r in allruns
              if r.get("experimentKey") == BATCH2_KEY
              and BATCH2_VERSION in (r.get("runtime") or {}).get("version", "")]

    if not armg:
        print(f"no runs under {ARMG_KEY} — the batch has not started or did not persist")
        return 1

    arms = {}
    for r in armg:
        arms.setdefault(r["variant"], []).append(r)
    for r in batch2:
        arms.setdefault(f"[ref] {r['variant']}", []).append(r)

    print(f"E-006 arm G — {ARMG_KEY}, with batch-2 ({BATCH2_KEY}, {BATCH2_VERSION}) as the "
          f"reference F2 was registered against")
    print(f"{len(armg)} arm-G runs and {len(batch2)} batch-2 runs, "
          f"of {len(allruns)} in the API\n")

    versions = sorted({(r.get("runtime") or {}).get("version", "?") for r in armg})
    models = sorted({(r.get("runtime") or {}).get("model", "?") for r in armg})
    print(f"  arm-G runtime version(s): {versions}   model(s): {models}")
    print("  (a second version here would mean the runtime moved mid-batch — a voiding event)\n")

    for arm in sorted(arms):
        rs = arms[arm]
        ok = passing(rs)
        sevens = sum(1 for r in ok
                     if (r["evaluation"] or {}).get("acceptanceCriteriaPassed") == 7)
        print(f"  {arm:26s} n={len(rs):3d}  gate-passing={len(ok):3d}  acceptance 7/7 on {sevens}")
    print()

    hdr = f"  {'metric':26s} {'arm':26s} {'n':>3s} {'min':>9s} {'Q1':>9s} {'median':>9s} {'Q3':>9s} {'max':>9s}"
    print(hdr)
    for name, get, unit in METRICS:
        for arm in sorted(arms):
            ok = passing(arms[arm])
            vals = [get(r) for r in ok]
            if not vals:
                continue
            q1, q3 = quartiles(vals)
            print(f"  {name:26s} {arm:26s} {len(vals):3d} "
                  f"{fmt(min(vals), unit):>9s} {fmt(q1, unit):>9s} {fmt(median(vals), unit):>9s} "
                  f"{fmt(q3, unit):>9s} {fmt(max(vals), unit):>9s}")
        print()

    print("  wrote a test file:")
    for arm in sorted(arms):
        ok = passing(arms[arm])
        if not ok:
            continue
        wrote = sum(1 for r in ok if any("src/test" in f for f in r["result"]["changedFiles"]))
        print(f"    {arm:26s} {wrote} of {len(ok)}")
    print()

    print("  F2's registered thresholds, applied to arm G's median toolCalls:")
    g = passing(arms.get("agent-v1.0-notools", []))
    if g:
        m = median([r["behavior"]["toolCalls"] for r in g])
        band = ("<= 22  -> F2 HOLDS: B4's only MDE-clearing effect was the runtime's "
                "tool-list rewrite, not the boundary prose") if m <= 22 else (
               ">= 25  -> F2 REFUTED: the rise is the prose" if m >= 25 else
               "23-24  -> registered IN ADVANCE as ambiguous; reported as neither")
        print(f"    median = {m}  ->  {band}")
    print()
    print("  No mean is reported. Arm G is a DELIBERATE FAILURE and enters no verdict:")
    print("  no median, range, quartile or Fisher test in E-006's registered comparison")
    print("  includes it. n = 5, so nothing here is stated as a property.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
