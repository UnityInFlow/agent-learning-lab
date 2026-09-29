#!/usr/bin/env python3
"""Re-derive every number Lab 10.0 asserts, from the sources, and reject a mismatch.

Why this exists: the §4a round objected, at 2/2 recurrence across both rounds, that the
validation table rates runtime-written evidence L1 or L2 while NOTHING EXECUTES to reject a
false claim in the table. That objection is correct — a span in Tempo cannot be hand-written,
but a sentence about it can. This script is the thing that executes. It reads the expectations
from EXPECT below and the facts from the evidence files, and exits non-zero on any mismatch.

Exit codes:  0 = every expectation matched.  2 = at least one mismatch.  3 = a source is missing.

Negative control: run with --selftest. It corrupts one expectation in memory and asserts the
script exits 2, because a checker that has never been shown to reject anything is
indistinguishable from one that rejects nothing.
"""
import json, os, re, sys, collections

HERE = os.path.dirname(os.path.abspath(__file__))
LAB = os.path.abspath(os.path.join(HERE, "..", ".."))
EVENTS = os.path.join(LAB, "..", "agent-observatory", "infra", "telemetry-out", "events.jsonl")

EXPECT = {
    # per-run span counts asserted in the checkbox-2 table
    "e488ed2e": {"file": "trace-e488ed2e-blocked-on-user.json",
                 "tool": 14, "blocked": 14, "execution": 14, "interaction": 1, "llm": 15,
                 "decision": {"unknown": 14}, "source": {"unknown": 14}, "unexecuted": 0},
    "606ab03e": {"file": "trace-606ab03e-replication.json",
                 "tool": 15, "blocked": 15, "execution": 13, "interaction": 1, "llm": 12,
                 "decision": {"unknown": 13, "reject": 2}, "source": {"unknown": 15},
                 "unexecuted": 2},
    # the checkbox-3 claims
    "scrub": {"survivor_marker": "resource-level-P10SCRUBPROBE20260929T180630Z",
              "deleted_markers": ["record-level-P10SCRUBPROBE20260929T180630Z",
                                  "record-level-prompt-P10SCRUBPROBE20260929T180630Z",
                                  "record-level-toolargs-P10SCRUBPROBE20260929T180630Z"]},
}


def spans(path):
    with open(path) as fh:
        d = json.load(fh)
    for b in d.get("batches", d.get("resourceSpans", [])):
        for ss in b.get("scopeSpans", b.get("instrumentationLibrarySpans", [])):
            for s in ss.get("spans", []):
                yield s, {a["key"]: list(a["value"].values())[0]
                          for a in s.get("attributes", [])}


def check_run(tag, exp, fail):
    path = os.path.join(HERE, exp["file"])
    if not os.path.exists(path):
        print(f"MISSING  {path}")
        sys.exit(3)
    names = collections.Counter()
    dec, src = collections.Counter(), collections.Counter()
    tools, execs = set(), set()
    for s, at in spans(path):
        names[s["name"]] += 1
        if s["name"] == "claude_code.tool":
            tools.add(at.get("tool_use_id"))
        if s["name"] == "claude_code.tool.execution":
            execs.add(at.get("tool_use_id"))
        if s["name"] == "claude_code.tool.blocked_on_user":
            dec[at.get("decision")] += 1
            src[at.get("source")] += 1
    got = {"tool": names["claude_code.tool"],
           "blocked": names["claude_code.tool.blocked_on_user"],
           "execution": names["claude_code.tool.execution"],
           "interaction": names["claude_code.interaction"],
           "llm": names["claude_code.llm_request"],
           "decision": dict(dec), "source": dict(src),
           "unexecuted": len(tools - execs)}
    for k in ("tool", "blocked", "execution", "interaction", "llm",
              "decision", "source", "unexecuted"):
        if got[k] != exp[k]:
            fail.append(f"{tag}.{k}: workbook says {exp[k]!r}, sources give {got[k]!r}")
    # the 1:1 claim, checked as a claim and not re-stated
    if got["tool"] != got["blocked"]:
        fail.append(f"{tag}: the 1:1 claim fails — {got['tool']} tool vs {got['blocked']} blocked")


def check_scrub(exp, fail):
    path = os.path.join(HERE, "scrub-probe-surviving-record.json")
    if not os.path.exists(path) or not os.path.exists(EVENTS):
        print(f"MISSING  {path} or {EVENTS}")
        sys.exit(3)
    blob = open(path).read()
    if exp["survivor_marker"] not in blob:
        fail.append("scrub: the resource-level survivor is absent from the saved record")
    for m in exp["deleted_markers"]:
        if m in blob:
            fail.append(f"scrub: {m} was claimed deleted but is present in the record")
    live = open(EVENTS, errors="replace").read()
    for m in exp["deleted_markers"]:
        if m in live:
            fail.append(f"scrub: {m} was claimed deleted but is live in events.jsonl")
    # the zero, with the probe's own planted address excluded
    hits = sum(1 for ln in live.splitlines()
               if "user.email" in ln and "P10SCRUBPROBE" not in ln)
    if hits != 0:
        fail.append(f"scrub: the checkbox-3 zero fails — {hits} non-probe user.email line(s)")


def main():
    selftest = "--selftest" in sys.argv
    exp = json.loads(json.dumps(EXPECT))
    if selftest:
        exp["e488ed2e"]["tool"] = 999            # a number the sources cannot produce
    fail = []
    check_run("e488ed2e", exp["e488ed2e"], fail)
    check_run("606ab03e", exp["606ab03e"], fail)
    check_scrub(exp["scrub"], fail)
    if fail:
        for f in fail:
            print("MISMATCH " + f)
        print(f"\n{len(fail)} mismatch(es). The workbook and the sources disagree.")
        if selftest:
            print("SELFTEST: the checker rejected a corrupted expectation. This is the "
                  "negative control and exit 2 is correct.")
        sys.exit(2)
    if selftest:
        print("SELFTEST FAILED: the checker ACCEPTED a corrupted expectation.")
        sys.exit(2)
    print("ok: every number Lab 10.0 asserts was re-derived from the evidence files "
          "and matched. 2 runs, 29 blocked_on_user spans, 4 planted placements.")


if __name__ == "__main__":
    main()
