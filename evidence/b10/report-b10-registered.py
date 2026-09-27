#!/usr/bin/env python3
"""Median and range per arm per task over the REGISTERED B10 population ONLY — 20 runs.

    ./evidence/b10/report-b10-registered.py          from agent-learning-lab/

WHY THIS EXISTS RATHER THAN `make baseline-report`. Two reasons, and only the second is the
stop-20 one.

  1. The registered PRIMARY outcome of E-024 and E-025 is a RUBRIC cell — `architecture-
     consistency` on the codex scorer — and `make baseline-report` does not read rubric
     sheets at all. It reports the observatory's own efficiency and behaviour fields. So for
     this stop it cannot produce the number the decision rule turns on, whatever else it
     does correctly.
  2. Preflight pooling. At stop 20 `run-b9-preflight.sh:134` ran the preflight pair under the
     SAME experiment key as the batch, so every API-side aggregate silently included it.
     THAT IS NOT THE CASE HERE — run-b10-preflight.sh uses EXP-B10-PREFLIGHT-BE003/-BE004,
     its own keys — and this script ASSERTS that rather than trusting it: it refuses if any
     archived record in the batch carries a preflight key. A pooled number here would be a
     NEW bug, not the stop-20 one, so the assertion is cheap and worth having.

Everything is read BY RUN ID off manifest.tsv, from the archived records in run-records/ and
the committed sheets named in codex-sheets.tsv. No API call, no experiment-key query: a run
outside the registered batch cannot enter a number, and every value is re-derivable from the
repository alone.

Median and full range, never a mean alone — B2's exit gate.

Exit 0 report written · 2 a preflight key is pooled into the batch · 3 an input is missing.
"""
import json, pathlib, statistics, sys, re

BATCH = pathlib.Path("evidence/b10/batch-20260927T125809Z")
MANIFEST = BATCH / "manifest.tsv"
SHEETS = BATCH / "codex-sheets.tsv"
REG_RUBRIC = {"BE-003": "396e1799eb2b", "BE-004": "6252778b8472"}
CATS = ["architecture-consistency", "maintainability", "test-quality", "change-focus"]
WEIGHTS = {"architecture-consistency": 35, "maintainability": 25,
           "test-quality": 25, "change-focus": 15}

for p in (MANIFEST, SHEETS):
    if not p.is_file():
        sys.exit(3)

runs = []          # (task, seq, arm, rid)
contact = {}       # rid -> corpus_contact
for line in MANIFEST.read_text().splitlines():
    if line.startswith("#"):
        continue
    f = line.split("\t")
    if len(f) < 4 or f[0] == "task":
        continue
    runs.append((f[0], f[1], f[2], f[3]))
    contact[f[3]] = f[16] if len(f) > 16 else "?"
if len(runs) != 20:
    sys.exit("manifest has %d data rows, registered population is 20" % len(runs))

sheet_of = {}
for line in SHEETS.read_text().splitlines():
    f = line.split("\t")
    if len(f) < 6 or f[0] == "task":
        continue
    if f[5] != "none":
        sheet_of[f[3]] = f[5]

records, scores = {}, {}
for task, seq, arm, rid in runs:
    rp = BATCH / "run-records" / f"{rid}.json"
    if not rp.is_file():
        sys.exit("missing archived record %s" % rp)
    d = json.loads(rp.read_text())
    key = d.get("experimentKey") or ""
    if "PREFLIGHT" in key.upper():
        print("REFUSING: %s carries preflight key %s" % (rid, key), file=sys.stderr)
        sys.exit(2)
    records[rid] = d

    sp = sheet_of.get(rid)
    if sp and pathlib.Path(sp).is_file():
        txt = pathlib.Path(sp).read_text()
        m = re.search(r"rubric_sha:\s*(\S+)", txt)
        got = m.group(1) if m else "?"
        if got != REG_RUBRIC[task]:
            sys.exit("sheet %s was scored against rubric %s, registered is %s"
                     % (sp, got, REG_RUBRIC[task]))
        body = txt.split("---", 1)[1]
        cur, vals = None, {}
        for ln in body.splitlines():
            n = re.match(r'\s*-\s*name:\s*"?([a-z-]+)"?', ln)
            if n:
                cur = n.group(1); continue
            s = re.match(r"\s*score:\s*(\d+|null)", ln)
            if s and cur:
                vals[cur] = None if s.group(1) == "null" else int(s.group(1))
                cur = None
        scores[rid] = vals

def mmm(xs):
    xs = sorted(x for x in xs if x is not None)
    if not xs:
        return "  -    n=0"
    return "%8.2f %8.2f %8.2f   n=%d" % (xs[0], statistics.median(xs), xs[-1], len(xs))

print("B10 registered population — 20 runs, read by run id from the archived records and the")
print("committed codex sheets. The preflight has its own experiment key and is asserted absent.")
print("Scorer: codex, the REGISTERED scorer (Decision C). The second reader is DEFERRED —")
print("ollama-cloud has been on its weekly limit for five consecutive sessions.\n")

for task in ("BE-003", "BE-004"):
    print("=" * 78)
    print("%s   rubric %s" % (task, REG_RUBRIC[task]))
    for arm in ("control", "treated"):
        sub = [r for t, _s, a, r in runs if t == task and a == arm]
        ev = sum(1 for r in sub if (records[r].get("evaluation") or {}).get("exitCode") == 0)
        sc = sum(1 for r in sub if r in scores)
        h = sum(1 for r in sub if contact.get(r) not in ("no", "none", "?"))
        print("\n  %-8s n=%d  evaluator-passing %d/%d  scored %d/%d  corpus contact %d/%d"
              % (arm, len(sub), ev, len(sub), sc, len(sub), h, len(sub)))
        print("  %-26s %8s %8s %8s" % ("metric", "min", "median", "max"))
        print("  " + "-" * 26 + " " + "-" * 8 + " " + "-" * 8 + " " + "-" * 8)
        for c in CATS:
            print("  %-26s %s" % (c, mmm([scores.get(r, {}).get(c) for r in sub])))
        tot = []
        for r in sub:
            v = scores.get(r)
            if v and all(v.get(c) is not None for c in CATS):
                tot.append(sum(v[c] * WEIGHTS[c] for c in CATS) / 2.0)
        print("  %-26s %s" % ("weighted total (0-100)", mmm(tot)))
        for label, get in (
            ("reportedTotalTokens", lambda d: (d.get("efficiency") or {}).get("reportedTotalTokens")),
            ("durationMs", lambda d: (d.get("efficiency") or {}).get("durationMs")),
            ("estimatedCost", lambda d: (d.get("efficiency") or {}).get("estimatedCost")),
            ("modelCalls", lambda d: (d.get("behavior") or {}).get("modelCalls")),
            ("toolCalls", lambda d: (d.get("behavior") or {}).get("toolCalls")),
            # changedFiles is a LIST of paths in this schema, not a count. The first cut of
            # this script passed the list straight into the median and crashed, which is the
            # cheap version of the failure where a list's truthiness gets read as a number.
            ("changedFiles (count)", lambda d: (lambda v: len(v) if isinstance(v, list) else v)((d.get("result") or {}).get("changedFiles"))),
            ("addedLines", lambda d: (d.get("result") or {}).get("addedLines")),
            ("deletedLines", lambda d: (d.get("result") or {}).get("deletedLines")),
            ("permissionDenials", lambda d: (d.get("behavior") or {}).get("permissionDenials")),
            ("retries", lambda d: (d.get("behavior") or {}).get("retries")),
        ):
            print("  %-26s %s" % (label, mmm([get(records[r]) for r in sub])))
    print()

print("=" * 78)
print("PER-RUN architecture-consistency — the registered primary outcome, every value shown")
print("so a stranger can re-derive the median rather than take it.\n")
for task in ("BE-003", "BE-004"):
    for arm in ("control", "treated"):
        vs = [(s, scores.get(r, {}).get("architecture-consistency"))
              for t, s, a, r in runs if t == task and a == arm]
        print("  %-7s %-8s %s" % (task, arm, "  ".join("%s=%s" % (s, v) for s, v in vs)))
