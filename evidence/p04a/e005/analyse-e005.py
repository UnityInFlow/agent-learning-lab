#!/usr/bin/env python3
"""Read batch-results.csv and report E-005's registered quantities. Decides nothing."""
import csv, sys
from math import comb
from collections import defaultdict

def fisher2(a, b, c, d):
    n, r1, r2, c1 = a+b+c+d, a+b, c+d, a+c
    pr = lambda x: comb(r1, x)*comb(r2, c1-x)/comb(n, c1)
    lo, hi, p0 = max(0, c1-r2), min(r1, c1), pr(a)
    return sum(pr(x) for x in range(lo, hi+1) if pr(x) <= p0+1e-12)

EXCLUDED = {("control", "7")}   # registered: harness killed before the outcome row was written

rows = list(csv.DictReader(open(sys.argv[1] if len(sys.argv) > 1 else "batch-results.csv")))
arms = defaultdict(list)
for r in rows:
    if (r["arm"], r["run"]) in EXCLUDED:
        continue
    arms[r["arm"]].append(r)

print(f"{'arm':13s} {'n':>3} {'W (tracked)':>12} {'any change':>11} {'write calls':>12} {'bash':>5} {'read':>5} {'exit!=0':>8}")
W = {}
for arm in ("control", "toollist", "description"):
    rs = arms.get(arm, [])
    if not rs:
        continue
    n = len(rs)
    w = sum(int(r["tracked_changed"]) for r in rs)
    a = sum(int(r["any_change"]) for r in rs)
    wc = sum(int(r["write_tool_calls"] or 0) for r in rs)
    bc = sum(int(r["bash_calls"] or 0) for r in rs)
    rc = sum(int(r["read_calls"] or 0) for r in rs)
    bad = sum(1 for r in rs if r["agent_exit"] != "0")
    W[arm] = (w, n)
    print(f"{arm:13s} {n:3d} {w:>7d}/{n:<4d} {a:>7d}/{n:<3d} {wc:12d} {bc:5d} {rc:5d} {bad:8d}")

if len(W) == 3:
    (wt, nt), (wd, nd), (wc_, nc) = W["toollist"], W["description"], W["control"]
    print()
    print(f"T vs C : {wt}/{nt} vs {wc_}/{nc}  Fisher two-sided p = {fisher2(wt, nt-wt, wc_, nc-wc_):.5f}")
    print(f"D vs C : {wd}/{nd} vs {wc_}/{nc}  Fisher two-sided p = {fisher2(wd, nd-wd, wc_, nc-wc_):.5f}")
    print(f"T vs D : {wt}/{nt} vs {wd}/{nd}  Fisher two-sided p = {fisher2(wt, nt-wt, wd, nd-wd):.5f}  [DERIVED, not a one-factor contrast]")
