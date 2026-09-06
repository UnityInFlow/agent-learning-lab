#!/usr/bin/env python3
"""Does the TRANSCRIPT measure of delegation reproduce the TELEMETRY one?

F1 was registered against the observatory telemetry ("same query as O1"). The P2 batch exported
no telemetry (see E-007 § "An instrument fault of my own making"), so F1 is read from the
transcript instead. THAT SUBSTITUTION IS ONLY LEGAL IF IT IS PROVED, and this is the proof:
run the transcript measure over the MAIN batch's twenty runs, where telemetry DOES exist, and
require agreement run for run.

Exit 0 they agree on every run · 1 they do not · 2 a source is missing.
"""
import json, sys, os, collections

LAB = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", ".."))
BATCH = os.path.join(LAB, "evidence/p04b/lab-4b4/batch-20260906T080905Z")
TEL = os.path.abspath(os.path.join(LAB, "..", "agent-observatory/infra/telemetry-out/events.jsonl"))
DELEGATE = {"Task", "Agent"}


def transcript_count(path):
    """Delegations in the session's OWN stream (parent_tool_use_id is null)."""
    n, saw = 0, False
    for line in open(path, errors="ignore"):
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            o = json.loads(line)
        except Exception:
            continue
        if o.get("type") != "assistant":
            continue
        if "parent_tool_use_id" in o:
            saw = True
        if o.get("parent_tool_use_id") is not None:
            continue
        for b in o.get("message", {}).get("content", []) or []:
            if isinstance(b, dict) and b.get("type") == "tool_use" and b.get("name") in DELEGATE:
                n += 1
    if not saw:
        sys.exit("crossvalidate: no parent_tool_use_id in %s" % path)
    return n


def main():
    mani = os.path.join(BATCH, "manifest.tsv")
    for p in (mani, TEL):
        if not os.path.exists(p):
            sys.exit("crossvalidate: missing %s" % p)

    rows = []
    for l in open(mani):
        if l.startswith("#"):
            continue
        p = l.rstrip("\n").split("\t")
        if len(p) > 6 and len(p[2]) == 36:
            rows.append((p[0], p[1], p[2]))
    if len(rows) != 20:
        sys.exit("crossvalidate: expected 20 runs in the manifest, found %d" % len(rows))

    ids = {rid for _, _, rid in rows}
    tel = collections.Counter()
    for line in open(TEL, errors="ignore"):
        if '"Task"' not in line and '"Agent"' not in line:
            continue
        try:
            o = json.loads(line)
        except Exception:
            continue
        for rl in o.get("resourceLogs", []):
            for sl in rl.get("scopeLogs", []):
                for lr in sl.get("logRecords", []):
                    a = {x["key"]: list(x["value"].values())[0] for x in lr.get("attributes", [])}
                    if (a.get("observatory.run.id") in ids
                            and a.get("event.name") == "tool_result"
                            and a.get("tool_name") in DELEGATE):
                        tel[a["observatory.run.id"]] += 1

    print("%-4s %-8s %-9s %-10s %-10s %s" % ("seq", "arm", "run", "telemetry", "transcript", ""))
    bad = 0
    for seq, arm, rid in rows:
        log = os.path.join(BATCH, "%s-%s.log" % (seq, "O" if arm == "O" else "control"))
        t, x = tel.get(rid, 0), transcript_count(log)
        ok = "agree" if t == x else "*** DISAGREE ***"
        if t != x:
            bad += 1
        print("%-4s %-8s %-9s %-10s %-10s %s" % (seq, arm, rid[:8], t, x, ok))

    print()
    if bad:
        print("crossvalidate: %d of 20 runs DISAGREE — the transcript may NOT stand in for "
              "telemetry, and F1 is UNMEASURED." % bad)
        return 1
    print("crossvalidate: telemetry and transcript agree on 20 of 20 runs, count for count. "
          "The transcript measure is a valid stand-in for F1.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
