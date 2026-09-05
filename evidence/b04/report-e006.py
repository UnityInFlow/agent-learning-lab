#!/usr/bin/env python3
"""E-006 §4 step 8 — median and range per arm, never a mean alone.

    ./evidence/b04/report-e006.py

WHY THIS EXISTS INSTEAD OF `make baseline-report`. `runner/baseline-report.py` selects runs by
`experimentKey` and reports ONE arm per key. `EXP-B4-AGENT-BOUNDARY` holds **40** runs — the
aborted batch 1 (runtime `2.1.260`, 5 gate-passing + 15 F13) and batch 2 (`2.1.261`, 20 of 20)
— across two variants. Run unfiltered it would average an aborted batch into a real one and
call two arms one. That is a wrong number that looks right, so it is not run that way.

The separation is the one recorded in `TRACK-B-STATE.md` and confirmed by validator pass 12:
runtime version is disjoint between batches and the time windows do not overlap. This filters
on the version and splits on `variant`.

NO MEAN IS PRINTED ANYWHERE. Median, range and quartiles only, per §4 step 8. Quartiles are
medians of the lower and upper halves (the same convention the validator used, stated so the
two are comparable).

Only runs that passed every gate are compared, per the observatory's standing rule: a run that
failed a gate is unsuccessful even when it used fewer tokens.
"""
import json
import urllib.request

API = "http://localhost:8081"
KEY = "EXP-B4-AGENT-BOUNDARY"
BATCH2_VERSION = "2.1.261"


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
    lower, upper = s[: n // 2], s[(n + 1) // 2:]
    return median(lower), median(upper)


def fmt(x, unit=""):
    if x is None:
        return "-"
    if isinstance(x, float):
        return f"{x:.4g}{unit}" if abs(x) < 1 else f"{x:.4g}{unit}"
    return f"{x}{unit}"


def main():
    runs = [r for r in fetch(f"{API}/api/runs")
            if r.get("experimentKey") == KEY
            and BATCH2_VERSION in (r.get("runtime") or {}).get("version", "")]

    arms = {}
    for r in runs:
        arms.setdefault(r["variant"], []).append(r)

    print(f"E-006 batch 2 — {KEY}, runtime {BATCH2_VERSION} only")
    print(f"selected {len(runs)} runs of the {len(fetch(f'{API}/api/runs'))} in the API; "
          f"batch 1 (2.1.260) is EXCLUDED as aborted\n")

    # Every gate first. Nothing below is computed on a run that failed one.
    for arm in sorted(arms):
        rs = arms[arm]
        passed = [r for r in rs if (r.get("evaluation") or {}).get("exitCode") == 0]
        print(f"  {arm:12s} n={len(rs)}  gate-passing={len(passed)}  "
              f"acceptance 7/7 on {sum(1 for r in passed if (r['evaluation']['acceptanceCriteriaPassed']) == 7)}")
    print()

    metrics = [
        ("behavior.toolCalls", lambda r: r["behavior"]["toolCalls"], ""),
        ("behavior.modelCalls", lambda r: r["behavior"]["modelCalls"], ""),
        ("efficiency.estimatedCost", lambda r: r["efficiency"]["estimatedCost"], ""),
        ("efficiency.durationMs", lambda r: r["efficiency"]["durationMs"] / 1000.0, "s"),
        ("result.addedLines", lambda r: r["result"]["addedLines"], ""),
        ("result.changedFiles", lambda r: len(r["result"]["changedFiles"]), ""),
    ]

    print(f"  {'metric':26s} {'arm':12s} {'n':>3s} {'min':>9s} {'Q1':>9s} {'median':>9s} {'Q3':>9s} {'max':>9s}")
    for name, get, unit in metrics:
        for arm in sorted(arms):
            passed = [r for r in arms[arm] if (r.get("evaluation") or {}).get("exitCode") == 0]
            vals = [get(r) for r in passed]
            q1, q3 = quartiles(vals)
            print(f"  {name:26s} {arm:12s} {len(vals):3d} "
                  f"{fmt(min(vals), unit):>9s} {fmt(q1, unit):>9s} {fmt(median(vals), unit):>9s} "
                  f"{fmt(q3, unit):>9s} {fmt(max(vals), unit):>9s}")
        print()

    # The one derived outcome P6 registered, computed from the run record rather than a sheet.
    print("  wrote a test file (P6, registered before the batch):")
    for arm in sorted(arms):
        passed = [r for r in arms[arm] if (r.get("evaluation") or {}).get("exitCode") == 0]
        wrote = sum(1 for r in passed
                    if any("src/test" in f for f in r["result"]["changedFiles"]))
        print(f"    {arm:12s} {wrote} of {len(passed)}")
    print()
    print("  No mean is reported. A difference read off two medians is not a result;")
    print("  the decision rule in E-006 is what answers the gate, at step 11.")


if __name__ == "__main__":
    main()
