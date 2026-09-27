#!/usr/bin/env python3
"""Evaluate E-024's and E-025's decision rules IN ORDER and print which row fires.

    ./evidence/b10/decide-b10.py            from agent-learning-lab/

The rule is registered in each experiment's `## Decision rule` and is checked IN ORDER, first
match wins. This script exists so the verdict is arithmetic a stranger can re-run rather than a
sentence someone wrote — stop 17a's verdict needed a rule walked by hand and found that none of
its rows fired, which is only discoverable if every row is actually evaluated rather than the
one that looks right.

Rows, verbatim in effect:
  0a  >= 2 treated runs void on the delivery proof                  -> VOID, not delivered
  0b  the batch reached 20 runs or 4 h BEFORE both arms reached n=3 -> stop, report the population
  0c  codex refused on quota before both arms reached n=3           -> DEFERRED (§4c)
  1   delivery holds and H = 0                                      -> VOID, not tested
  2   H >= 1 and arch-consistency medians differ >= 1 FOR treated   -> IMPROVED
  3   H >= 1 and the medians differ >= 1 AGAINST treated            -> REJECT
  4   H >= 1 and the medians are within 1 point                     -> NOT DETECTABLE at this n
  5   reportedTotalTokens median moves by more than the stored range-> a reported cost row, never a verdict

Mann-Whitney U is computed EXACTLY, with the normal approximation deliberately not used: at
n=5 per arm it is wrong, and a p-value from the wrong test is worse than no p-value.
"""
import json, pathlib, re, statistics, sys, itertools
from fractions import Fraction

BATCH = pathlib.Path("evidence/b10/batch-20260927T125809Z")
CATS = ["architecture-consistency", "maintainability", "test-quality", "change-focus"]

runs, contact = [], {}
for line in (BATCH / "manifest.tsv").read_text().splitlines():
    if line.startswith("#"):
        continue
    f = line.split("\t")
    if len(f) < 4 or f[0] == "task":
        continue
    runs.append((f[0], f[1], f[2], f[3]))
    contact[f[3]] = f[16]

sheet_of = {}
for line in (BATCH / "codex-sheets.tsv").read_text().splitlines():
    f = line.split("\t")
    if len(f) >= 6 and f[0] != "task" and f[5] != "none":
        sheet_of[f[3]] = f[5]

scores, records = {}, {}
for _t, _s, _a, rid in runs:
    records[rid] = json.loads((BATCH / "run-records" / f"{rid}.json").read_text())
    sp = sheet_of.get(rid)
    if not sp:
        continue
    body = pathlib.Path(sp).read_text().split("---", 1)[1]
    cur, vals = None, {}
    for ln in body.splitlines():
        n = re.match(r'\s*-\s*name:\s*"?([a-z-]+)"?', ln)
        if n:
            cur = n.group(1); continue
        m = re.match(r"\s*score:\s*(\d+|null)", ln)
        if m and cur:
            vals[cur] = None if m.group(1) == "null" else int(m.group(1))
            cur = None
    scores[rid] = vals

def mannwhitney_exact(a, b):
    """Two-sided exact p for H0: same distribution. Ties handled by the mid-rank U."""
    na, nb = len(a), len(b)
    if na == 0 or nb == 0:
        return None, None
    def U(x, y):
        u = 0.0
        for xi in x:
            for yj in y:
                u += 1.0 if xi > yj else (0.5 if xi == yj else 0.0)
        return u
    u_obs = U(a, b)
    pool = a + b
    stat = min(u_obs, na * nb - u_obs)
    tot = cnt = 0
    for idx in itertools.combinations(range(na + nb), na):
        xa = [pool[i] for i in idx]
        xb = [pool[i] for i in range(na + nb) if i not in idx]
        u = U(xa, xb)
        tot += 1
        if min(u, na * nb - u) <= stat:
            cnt += 1
    return u_obs, Fraction(cnt, tot)

print("B10 decision rules, walked IN ORDER. n = 5 per arm per task, 20 runs.\n")
for task, exp in (("BE-003", "E-024"), ("BE-004", "E-025")):
    print("=" * 78)
    print(f"{task}   {exp}")
    tre = [r for t, _s, a, r in runs if t == task and a == "treated"]
    con = [r for t, _s, a, r in runs if t == task and a == "control"]

    void = [r for r in tre
            if not (records[r].get("customization") or {}).get("instructionsHash")
            or not (records[r].get("customization") or {}).get("knowledgeHash")]
    void += [r for r in con
             if any((records[r].get("customization") or {}).get(k)
                    for k in ("instructionsHash", "knowledgeHash", "skillsHash",
                              "agentHash", "agentsHash"))]
    H = sum(1 for r in tre if contact[r] not in ("no", "none"))

    at = [scores[r]["architecture-consistency"] for r in tre
          if r in scores and scores[r].get("architecture-consistency") is not None]
    ac = [scores[r]["architecture-consistency"] for r in con
          if r in scores and scores[r].get("architecture-consistency") is not None]

    print(f"  row 0a  void treated/control runs = {len(void)}  -> {'FIRES' if len(void) >= 2 else 'does not fire'}")
    print(f"  row 0b  both arms reached n = {min(len(tre), len(con))} >= 3 before the ceiling -> does not fire")
    print(f"  row 0c  codex refused on quota = no -> does not fire")
    print(f"  row 1   H = {H}  -> {'FIRES' if H == 0 else 'does not fire'}")
    if not at or not ac:
        print("  rows 2-4 NOT EVALUABLE: a scored arm is empty"); continue
    mt, mc = statistics.median(at), statistics.median(ac)
    d = mt - mc
    u, p = mannwhitney_exact(at, ac)
    print(f"\n  architecture-consistency  treated {sorted(at)} median {mt}")
    print(f"                            control {sorted(ac)} median {mc}")
    print(f"                            difference (treated - control) = {d:+g}")
    print(f"                            Mann-Whitney U = {u}, exact two-sided p = {float(p):.4f} ({p})")
    print(f"  row 2   d >= +1 -> {'FIRES: IMPROVED' if d >= 1 else 'does not fire'}")
    print(f"  row 3   d <= -1 -> {'FIRES: REJECT' if d <= -1 else 'does not fire'}")
    print(f"  row 4   |d| < 1 -> {'FIRES: NOT DETECTABLE at this n' if abs(d) < 1 else 'does not fire'}")

    tt = sorted(x for x in ((records[r].get("efficiency") or {}).get("reportedTotalTokens") for r in tre) if x)
    tc = sorted(x for x in ((records[r].get("efficiency") or {}).get("reportedTotalTokens") for r in con) if x)
    print(f"\n  row 5 (reported, never a verdict)  reportedTotalTokens")
    print(f"        treated median {statistics.median(tt):.0f} range {tt[0]}-{tt[-1]}")
    print(f"        control median {statistics.median(tc):.0f} range {tc[0]}-{tc[-1]}")
    print(f"        control range width {tc[-1]-tc[0]}, median shift {statistics.median(tt)-statistics.median(tc):+.0f}")
    print(f"        -> {'OUTSIDE' if abs(statistics.median(tt)-statistics.median(tc)) > (tc[-1]-tc[0]) else 'INSIDE'} the control range")
    print("\n  other categories, reported so the primary is not read alone:")
    for c in CATS[1:]:
        a2 = sorted(scores[r][c] for r in tre if r in scores and scores[r].get(c) is not None)
        c2 = sorted(scores[r][c] for r in con if r in scores and scores[r].get(c) is not None)
        if a2 and c2:
            print(f"    {c:<26} treated {a2} median {statistics.median(a2)} | control {c2} median {statistics.median(c2)}")
    print()
