#!/usr/bin/env python3
"""Did this run actually work in phases, or did it narrate them?

    ./tools/check-phase-contract.py <transcript.jsonl> [--json]

WHY THIS EXISTS. B5's gate is "phase markers observable in the transcript, no code written
before DESIGN, overhead measured not assumed". Two of those three are checkable by something
that executes, and the third is the runner's. Nothing here reads a summary the agent wrote
about itself: every check walks the kept stream-json transcript in ARRIVAL ORDER, so a marker
and a tool call can be compared by position rather than by claim.

That distinction is the whole point. An agent asked to work in phases can emit all six markers
in its closing message after having edited the repository in its second turn, and a checker
that greps the final text would pass it. This project has already published the general form of
that mistake three times (an instruction file under a name nothing reads, a skill under a flag
that disables skills, an agent overlay with no --agent): copied, committed, hashed, and none of
it the treatment. A narrated phase is the same shape wearing B5's clothes.

WHAT EACH CHECK IS WORTH, stated so the caller does not round it up:

  1 markers      L2 over the artifact. Proves the six markers appear, once each, in the
                 registered order. Does NOT prove the work under a marker belongs to it.
  2 code order   L2, and the strongest one here. The first mutating tool_use must arrive
                 AFTER the DESIGN marker. Position in the stream, not self-report.
  3 placeholders L2. Template tokens surviving into output mean the model echoed the phase
                 template instead of instantiating it. Borrowed from the feature-pipeline
                 bundle's score.py, which calls it the template-echo detector.
  4 completion   L2 over the artifact. DONE must carry the four completion fields. Whether
                 they are TRUE is the evaluator's question, and this cannot answer it.
  5 no split     L2. Any event carrying parent_tool_use_id, or any Task/Agent tool_use, means
                 this run delegated. On a phases-without-split arm that is a confound, and it
                 is reported whatever the arm, because "the control did not delegate" is a
                 claim this project has already had to retract once.

                 CORRECTED 2026-09-07, before this branch was pushed. Attribution:
                 findings/track-b-validation-2026-09-07-2.md (pass 18, claude-fable-5-1) §3.4.
                 ~~The facts block reported a single `delegations` count.~~ It reported a SUM
                 of two different things and called it one. On E-008 control run 9043f824 the
                 sum is 37 — one `Agent` call with subagent_type Explore, plus 36 events
                 carrying its parent_tool_use_id — while the batch manifest records 1. A
                 reader comparing 37 with 1 concludes the two instruments disagree; they agree
                 exactly, about different units. Now reported as `delegating_calls` (1) and
                 `delegated_events` (36) with no sum offered.

                 The 9043f824 finding itself stands and is the reason this check exists: the
                 observatory's own telemetry counter read 0 delegations on that run. Pass 18
                 ran this checker over all 38 kept fourth-cell streams — 37 events on that one
                 run, 0 on every other, matching the counter everywhere it was not blind.

Exit 0 every check passed · 2 a check failed · 3 the input is unusable as a transcript.
A failed check is a finding about the run. An unusable input is a finding about the harness,
and the two must never share an exit code — collapsing them is how an experiment discards its
own strongest signal.
"""
import argparse
import json
import re
import sys

PHASES = ["ANALYSIS", "DESIGN", "IMPLEMENTATION", "VERIFICATION", "REVIEW", "DONE"]
MARKER = re.compile(r"<<PHASE:([A-Z]+)>>")

# Tools that change the repository. Bash is deliberately NOT here: `bash -c "grep ..."` is a
# read and `bash -c "cat > x"` is a write, and this checker cannot tell them apart without
# parsing a shell. Naming Bash as mutating would fail every run that searched the repo before
# designing, which is the behaviour the phase order is meant to ENCOURAGE. The narrower rule
# under-detects and says so; a wider one would be wrong in the expensive direction.
MUTATING = {"Edit", "Write", "MultiEdit", "NotebookEdit", "str_replace_editor"}
DELEGATING = {"Task", "Agent"}

# Shell fragments that WRITE. Reported as a fact beside the verdict, never folded into it —
# see the note under check 2. A shape here is not proof: `grep x src > /tmp/out` matches and
# changes nothing in the repository, and this cannot tell the two apart without resolving the
# target path. Over-reporting a fact is cheap; over-refusing a run is not.
WRITE_SHAPES = [
    r">>?\s*\S", r"\btee\b", r"\bsed\b[^|;]*-i", r"\bgit\s+apply\b", r"\bpatch\b",
    r"\bmv\b", r"\bcp\b", r"\btouch\b", r"\bmkdir\b", r"\brm\b",
]

# Tokens from the phase template. Finding one verbatim means the template was echoed.
PLACEHOLDERS = [
    r"\{Entity\}", r"\{entity\}", r"\{Feature\}", r"\{feature\}", r"\{field\}",
    r"\{Type\}", r"\{TICKET\}", r"\{ticket\}", r"\{file\}", r"\{command\}",
    r"one line per file", r"<one sentence>", r"<restate", r"TODO: fill",
]

# DONE's completion contract. Absent fields are the "premature completion" failure mode the
# 4B extract names, in the only form a script can see.
COMPLETION_FIELDS = ["Requirement", "Changed", "Tests", "Verification"]


def load_stream(path):
    """Return events in arrival order as (kind, name, text). Raises ValueError if unusable."""
    events, assistant_seen = [], 0
    try:
        fh = open(path, encoding="utf-8")
    except OSError as exc:
        raise ValueError("cannot open %s: %s" % (path, exc))
    with fh:
        for lineno, line in enumerate(fh, 1):
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                raise ValueError("line %d is not JSON — this is not a stream-json transcript"
                                 % lineno)
            if not isinstance(obj, dict):
                continue
            if obj.get("parent_tool_use_id"):
                events.append(("delegated_event", obj.get("type", "?"), ""))
            if obj.get("type") != "assistant":
                continue
            assistant_seen += 1
            content = (obj.get("message") or {}).get("content") or []
            if isinstance(content, str):
                content = [{"type": "text", "text": content}]
            for block in content:
                if not isinstance(block, dict):
                    continue
                if block.get("type") == "text":
                    events.append(("text", "", block.get("text") or ""))
                elif block.get("type") == "tool_use":
                    # The command is carried too, not just the name: `input` is where the
                    # shell lives, and dropping it is what made check 2's under-detection
                    # invisible (pass 18 §3.1).
                    inp = block.get("input") or {}
                    cmd = inp.get("command") if isinstance(inp, dict) else ""
                    events.append(("tool_use", block.get("name") or "?", cmd or ""))
    if assistant_seen == 0:
        raise ValueError("no assistant events — an empty or truncated transcript is not a "
                         "run that worked without phases")
    return events


def check(events):
    findings, marker_at, first_mut = [], {}, None
    # Two counters, never summed — see check 5 in the module docstring.
    delegating_calls, delegated_events, delegation_kinds = 0, 0, set()
    bash_writes = []
    dup = []
    order = []

    for idx, (kind, name, text) in enumerate(events):
        if kind == "text":
            for m in MARKER.finditer(text):
                phase = m.group(1)
                if phase in marker_at:
                    dup.append(phase)
                else:
                    marker_at[phase] = idx
                order.append(phase)
        elif kind == "tool_use":
            if name == "Bash" and text and any(re.search(w, text) for w in WRITE_SHAPES):
                bash_writes.append(idx)
            if name in MUTATING and first_mut is None:
                first_mut = (idx, name)
            if name in DELEGATING:
                delegating_calls += 1
                delegation_kinds.add(name)
        elif kind == "delegated_event":
            delegated_events += 1
            delegation_kinds.add("parent_tool_use_id")

    # 1 — markers
    missing = [p for p in PHASES if p not in marker_at]
    if missing:
        findings.append(("markers", "missing phase marker(s): " + ", ".join(missing)))
    if dup:
        findings.append(("markers", "phase marker emitted more than once: " + ", ".join(sorted(set(dup)))))
    present = [p for p in order if p in PHASES]
    expected_order = [p for p in PHASES if p in marker_at]
    seen_first = []
    for p in present:
        if p not in seen_first:
            seen_first.append(p)
    if not missing and not dup and seen_first != expected_order:
        findings.append(("markers", "phases out of registered order: got %s, expected %s"
                         % (" -> ".join(seen_first), " -> ".join(expected_order))))

    # 2 — no code before DESIGN
    if "DESIGN" in marker_at:
        if first_mut is None:
            if bash_writes:
                # CORRECTED 2026-09-07 (pass 18 §3.1): the old message said "nothing was
                # implemented" on a run that wrote two files through Bash. A refusal is still
                # right — check 2 has no Edit/Write to order — but the reason has to be true.
                findings.append(("code-order",
                                 "no Edit/Write in the whole run, but %d Bash call(s) carry a "
                                 "write shape (first at position %d, DESIGN at %d) — this run "
                                 "may well have implemented something, through a tool this "
                                 "check cannot order. Not scorable as a phased run."
                                 % (len(bash_writes), bash_writes[0], marker_at["DESIGN"])))
            else:
                findings.append(("code-order", "no mutating tool call in the whole run — nothing "
                                               "was implemented, so the order proves nothing"))
        elif first_mut[0] < marker_at["DESIGN"]:
            findings.append(("code-order", "first %s at stream position %d, DESIGN marker at "
                                           "%d — code was written before DESIGN"
                             % (first_mut[1], first_mut[0], marker_at["DESIGN"])))
    else:
        findings.append(("code-order", "no DESIGN marker, so the ordering check cannot run"))

    # 3 — template echo
    body = "\n".join(t for k, _, t in events if k == "text")
    leaked = sorted({p for p in PLACEHOLDERS if re.search(p, body)})
    if leaked:
        findings.append(("placeholders", "template token(s) survived into output: " + ", ".join(leaked)))

    # 4 — completion contract, read from the DONE phase onward
    if "DONE" in marker_at:
        tail = "\n".join(t for i, (k, _, t) in enumerate(events)
                         if k == "text" and i >= marker_at["DONE"])
        absent = [f for f in COMPLETION_FIELDS if not re.search(r"^\s*%s\b" % f, tail, re.M)]
        if absent:
            findings.append(("completion", "DONE is missing contract field(s): " + ", ".join(absent)))

    return findings, {
        "markers_found": len(marker_at),
        "markers_expected": len(PHASES),
        "first_mutating_tool": first_mut[1] if first_mut else None,
        "first_mutating_position": first_mut[0] if first_mut else None,
        "design_marker_position": marker_at.get("DESIGN"),
        "bash_write_shape_calls": len(bash_writes),
        "bash_write_shape_before_design": (
            len([i for i in bash_writes if i < marker_at["DESIGN"]])
            if "DESIGN" in marker_at else None),
        "delegating_calls": delegating_calls,
        "delegated_events": delegated_events,
        "delegation_kinds": sorted(delegation_kinds),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("transcript")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    args = ap.parse_args()

    try:
        events = load_stream(args.transcript)
    except ValueError as exc:
        if args.json:
            print(json.dumps({"status": "UNUSABLE", "reason": str(exc)}, indent=2))
        else:
            print("check-phase-contract: UNUSABLE INPUT — %s" % exc, file=sys.stderr)
        return 3

    findings, facts = check(events)
    status = "PASS" if not findings else "FAIL"

    if args.json:
        print(json.dumps({"status": status,
                          "findings": [{"check": c, "detail": d} for c, d in findings],
                          "facts": facts}, indent=2))
    else:
        print("check-phase-contract: %s" % status)
        print("  markers %d of %d · first mutating tool %s at %s · DESIGN at %s · "
              "delegating calls %d, delegated events %d"
              % (facts["markers_found"], facts["markers_expected"],
                 facts["first_mutating_tool"], facts["first_mutating_position"],
                 facts["design_marker_position"],
                 facts["delegating_calls"], facts["delegated_events"]))
        bwd = facts["bash_write_shape_before_design"]
        if bwd:
            print("  NOTE: %d Bash call(s) carrying a write shape ran BEFORE the DESIGN marker "
                  "(%d in the run). Check 2 does not read these — see WRITE_SHAPES. A run whose "
                  "real work went through Bash before DESIGN and then touched one file after it "
                  "passes this check; that is the known residual hole, reported rather than "
                  "scored." % (bwd, facts["bash_write_shape_calls"]))
        if facts["delegating_calls"] or facts["delegated_events"]:
            print("  NOTE: this run delegated — %d call(s), %d event(s) from them (%s). On a "
                  "no-split arm that is a confound, not a detail."
                  % (facts["delegating_calls"], facts["delegated_events"],
                     ", ".join(facts["delegation_kinds"])))
        for c, d in findings:
            print("  FAIL [%s] %s" % (c, d))
    return 0 if status == "PASS" else 2


if __name__ == "__main__":
    sys.exit(main())
