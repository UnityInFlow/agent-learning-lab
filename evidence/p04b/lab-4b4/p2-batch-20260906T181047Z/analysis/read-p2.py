#!/usr/bin/env python3
"""Read the P2 deliberate-failure batch: F1, F2, F3, F4, from the sources each was registered against.

  ./read-p2.py <p2-batch-dir>

WHY THIS EXISTS RATHER THAN A grep. F2 asks whether the ORCHESTRATOR wrote code, and in P2 the
worker writes code on every successful run — so a bare count of Write/Edit events answers a
different question from the one registered. The separator is `parent_tool_use_id`: it is null on
the orchestrator's own messages and set to the delegating tool_use id on everything the subagent
did. This script asserts that the field is present before it counts, so a runtime that stopped
emitting it fails loudly instead of returning a clean-looking zero.

F1  delegation      >=1 tool_use named Task or Agent in the orchestrator's OWN stream
F2  self-implement  >=1 Write/Edit/MultiEdit/NotebookEdit in the orchestrator's OWN stream
F3  evaluator       exit code from the manifest
F4  delivered pool  n and verdict from the run's init-schema record
"""
import json, sys, os, collections

WRITE = {"Write", "Edit", "MultiEdit", "NotebookEdit"}
DELEGATE = {"Task", "Agent"}


def read_log(path):
    own, sub = collections.Counter(), collections.Counter()
    inits, denied, saw_parent = [], [], False
    for line in open(path, errors="ignore"):
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            o = json.loads(line)
        except Exception:
            continue
        if o.get("type") == "system" and o.get("subtype") == "init":
            inits.append(len(o.get("tools", [])))
        if o.get("type") == "system" and o.get("subtype") == "permission_denied":
            denied.append(o.get("tool_name"))
        if o.get("type") != "assistant":
            continue
        if "parent_tool_use_id" in o:
            saw_parent = True
        parent = o.get("parent_tool_use_id")
        for b in o.get("message", {}).get("content", []) or []:
            if isinstance(b, dict) and b.get("type") == "tool_use":
                (own if parent is None else sub)[b.get("name")] += 1
    return own, sub, inits, denied, saw_parent


def main():
    d = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    mani = os.path.join(d, "manifest.tsv")
    rows = []
    for l in open(mani):
        if l.startswith("#"):
            continue
        p = l.rstrip("\n").split("\t")
        if len(p) > 6 and len(p[2]) == 36:
            rows.append(p)
    if not rows:
        sys.exit("read-p2: no runs in %s" % mani)

    print("%-4s %-8s %-9s %-5s %-22s %-6s %-6s %s" %
          ("seq", "arm", "run", "eval", "delivered", "F1del", "F2own", "orchestrator's own stream"))
    tally = collections.Counter()
    for seq, arm, rid, rc, wt, verdict, _deleg in rows:
        log = os.path.join(d, "%s-%s.log" % (seq, "O" if arm == "O" else "control"))
        own, sub, inits, denied, saw = read_log(log)
        if not saw:
            sys.exit("read-p2: no parent_tool_use_id field in %s — the separator F2 depends on is "
                     "gone; this script must not report a zero." % log)
        f1 = sum(own[n] for n in DELEGATE)
        f2 = sum(own[n] for n in WRITE)
        tally[(arm, "F1>=1" if f1 else "F1=0")] += 1
        tally[(arm, "F2>=1" if f2 else "F2=0")] += 1
        tally[(arm, "eval0" if rc == "0" else "evalNZ")] += 1
        print("%-4s %-8s %-9s %-5s %-22s %-6s %-6s %s" %
              (seq, arm, rid[:8], rc, "n=%s" % (inits[0] if inits else "?"),
               f1, f2, dict(own)))
    print()
    print("TALLY:", dict(tally))
    print("NOTE: the worker's own calls are excluded by construction; F2 counts ONLY messages "
          "whose parent_tool_use_id is null.")


if __name__ == "__main__":
    main()
