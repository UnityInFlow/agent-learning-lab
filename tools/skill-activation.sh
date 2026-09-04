#!/usr/bin/env bash
# skill-activation.sh — count project-scope skill activations for one observatory run.
#
# WHY THIS EXISTS, AND WHY IT REFUSES.
#
# E-004's primary outcome is "did the installed skill load on this run". The obvious way to
# answer it is to grep the telemetry for `claude_code.skill_activated` and report the count.
# That is wrong in one specific way this project has already paid for: **a run with no
# telemetry and a run with no activation produce the same number.** Zero.
#
# A missing cell is not a null cell. So this script separates them by exit code:
#
#   0  the run IS present in the telemetry stream, and the counts below are a measurement
#   3  the run is ABSENT from telemetry entirely — the counts are UNKNOWN, not zero
#   2  the telemetry file could not be parsed as one JSON object per line
#   1  usage error
#
# Presence is decided by ANY log record carrying this observatory.run.id, not by a skill event.
# A run that emitted 4000 records and no skill event is a real zero. A run that emitted nothing
# has not been measured. Reporting the second as zero would silently turn an instrument failure
# into evidence for the control arm — which is the direction that flatters the hypothesis.
#
# Bundled skills are counted separately and NEVER in the project-scope figure. Claude Code ships
# its own skills and may load one on any arm, including the control; counting those would put
# activations in the arm that installed nothing.

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: skill-activation.sh <events.jsonl> <observatory-run-id>

Exit codes:
  0  run present in telemetry; counts are a measurement
  3  run absent from telemetry; counts are UNKNOWN, not zero
  2  telemetry file unparseable
  1  usage error
EOF
  exit 1
}

[[ $# -eq 2 ]] || usage
EVENTS="$1"
RUN_ID="$2"
[[ -n "$RUN_ID" ]] || usage
[[ -f "$EVENTS" ]] || { echo "skill-activation: no such telemetry file: $EVENTS" >&2; exit 1; }

EVENTS="$EVENTS" RUN_ID="$RUN_ID" python3 <<'PY'
import json, os, sys, collections

events = os.environ["EVENTS"]
run_id = os.environ["RUN_ID"]

present = False
parsed_any = False
proj = 0
bundled = 0
unknown_source = 0
names = collections.Counter()
triggers = collections.Counter()
sources = collections.Counter()

def attrs(node):
    return {a["key"]: list(a["value"].values())[0] for a in node.get("attributes", [])}

with open(events) as fh:
    for line in fh:
        line = line.strip()
        if not line:
            continue
        try:
            doc = json.loads(line)
        except json.JSONDecodeError:
            continue
        parsed_any = True
        for rl in doc.get("resourceLogs", []):
            res = attrs(rl.get("resource", {}))
            for sl in rl.get("scopeLogs", []):
                for lr in sl.get("logRecords", []):
                    at = attrs(lr)
                    rid = at.get("observatory.run.id") or res.get("observatory.run.id")
                    if rid != run_id:
                        continue
                    # ANY record proves the run reached the collector.
                    present = True
                    body = lr.get("body", {})
                    body = body.get("stringValue") if isinstance(body, dict) else body
                    if body != "claude_code.skill_activated":
                        continue
                    src = at.get("skill.source")
                    sources[str(src)] += 1
                    names[str(at.get("skill.name"))] += 1
                    triggers[str(at.get("invocation_trigger"))] += 1
                    # An event with no skill.source is NOT project scope. The first version
                    # of this script sent everything that was not "bundled" to the project
                    # counter, so a source-less event would have been counted as the installed
                    # skill loading — inventing evidence for the treatment arm out of a missing
                    # attribute. Caught by the §4a gate, 2026-09-04, before any batch.
                    if src == "bundled":
                        bundled += 1
                    elif src is None or src == "":
                        unknown_source += 1
                    else:
                        proj += 1

if not parsed_any:
    print("skill-activation: no parseable JSON lines in telemetry", file=sys.stderr)
    sys.exit(2)

def fmt(counter):
    return ",".join(f"{k}={v}" for k, v in sorted(counter.items())) or "-"

status = "measured" if present else "UNKNOWN-run-absent-from-telemetry"
if present and unknown_source:
    print(f"skill-activation: {unknown_source} activation(s) carry no skill.source and are "
          "counted in NEITHER scope — inspect them before using this run", file=sys.stderr)
print(f"run: {run_id}")
print(f"status: {status}")
print(f"project_scope_activations: {proj if present else 'null'}")
print(f"bundled_activations: {bundled if present else 'null'}")
print(f"unknown_source_activations: {unknown_source if present else 'null'}")
print(f"skill_names: {fmt(names)}")
print(f"skill_sources: {fmt(sources)}")
print(f"invocation_triggers: {fmt(triggers)}")

sys.exit(0 if present else 3)
PY
