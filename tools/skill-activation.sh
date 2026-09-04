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
#   4  the run is present and the stream around it is DAMAGED — the counts are a LOWER BOUND
#   2  the telemetry file could not be parsed as one JSON object per line at all
#   1  usage error
#
# Presence is decided by ANY log record carrying this observatory.run.id, not by a skill event.
# A run that emitted 4000 records and no skill event is a real zero. A run that emitted nothing
# has not been measured. Reporting the second as zero would silently turn an instrument failure
# into evidence for the control arm — which is the direction that flatters the hypothesis.
#
# AND THERE IS A THIRD STATE, WHICH ROUND 3 OF THE §4a GATE FOUND MISSING. Between "present"
# and "absent" sits "present, and part of the stream is unreadable". Until 2026-09-04 an
# unparseable line was skipped with `continue` and a run whose records were partly corrupt
# reported `measured` with a clean-looking zero — the same number a genuinely clean run
# reports, and again in the direction that flatters the hypothesis, because the activation
# that would refute a null is exactly what a dropped line takes away.
#
# So damage is counted and reported, and it changes the status and the exit code. A count
# from a damaged stream is a LOWER BOUND, never a zero. Two kinds are counted separately:
#   malformed_lines   JSON lines in the file that do not parse. They cannot be attributed to
#                     a run, so ANY of them makes every run's count a lower bound — one of
#                     them could have been this run's activation.
#   damaged_records   records that DO carry this run id but whose attributes cannot be read.
# Note what is NOT damage: an activation carrying no `skill.source`. That parses fine and is
# a measurement of an absent attribute; it has its own bucket and its own warning.
#
# THIS SCRIPT DOES NOT DECIDE WHICH ACTIVATION WAS YOURS. It reports a count per
# `skill.source` and stops. That is a correction, and it took the §4a gate three rounds to
# force it, because the first three versions all had the same shape:
#
#   round 1  everything not "bundled"            -> counted as the installed skill
#   round 2  everything not "bundled"/empty      -> counted as the installed skill
#   round 3  everything not "bundled"/"plugin"   -> counted as the installed skill
#
# Each fix named one more scope and kept the same unsound move: an open "everything else is
# mine" bucket. A user-scope skill, an enterprise skill, or a source this runtime has not
# shipped yet all land in it, and every one of them lands on the CONTROL arm too — the arm
# that installed nothing. That is not a bug to patch a fourth time; the category was wrong.
#
# So: no bucket is labelled "installed". `activations_by_source` is the measurement. The
# experiment reading it must FIRST pin what `skill.source` a project skill emits — no
# project-scope skill has ever been recorded on this instrument — and then count that value
# by name. Until it does, there is no number here that means "my skill loaded".

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: skill-activation.sh <events.jsonl> <observatory-run-id>

Exit codes:
  0  run present in telemetry; counts are a measurement
  3  run absent from telemetry; counts are UNKNOWN, not zero
  4  run present but the stream is damaged; counts are a LOWER BOUND, not zero
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
malformed_lines = 0
damaged_records = 0
bundled = 0
plugin = 0
unknown_source = 0
other = 0
by_source = collections.Counter()
names = collections.Counter()
triggers = collections.Counter()

class DamagedRecord(Exception):
    pass

def attrs(node):
    # Defensive on purpose. A record whose attribute list is truncated used to raise here
    # and abort the whole script with a traceback, which reads as "the tool is broken"
    # rather than "this run's telemetry is". Now it is counted as damage on the run it
    # belongs to, and the rest of the stream is still read.
    out = {}
    for a in node.get("attributes", []) or []:
        try:
            out[a["key"]] = list(a["value"].values())[0]
        except (KeyError, TypeError, AttributeError, IndexError):
            raise DamagedRecord
    return out

with open(events) as fh:
    for line in fh:
        line = line.strip()
        if not line:
            continue
        try:
            doc = json.loads(line)
        except json.JSONDecodeError:
            malformed_lines += 1
            continue
        parsed_any = True
        for rl in doc.get("resourceLogs", []):
            try:
                res = attrs(rl.get("resource", {}))
            except DamagedRecord:
                # §4a round 1, found at 2/2 recurrence: this call sat OUTSIDE the try below,
                # so a malformed RESOURCE attribute raised uncaught and the script exited 1
                # with a traceback — making the exit-4 path it documents unreachable from
                # here. The resource carries observatory.run.id for every record beneath it,
                # so when it is unreadable none of them can be attributed. Count them all.
                damaged_records += sum(
                    len(sl.get("logRecords", []) or [])
                    for sl in (rl.get("scopeLogs", []) or [])
                ) or 1
                continue
            for sl in rl.get("scopeLogs", []):
                for lr in sl.get("logRecords", []):
                    try:
                        at = attrs(lr)
                    except DamagedRecord:
                        # Unreadable attributes mean the run id is unreadable too, so this
                        # cannot be attributed. Counted against every run for the same
                        # reason a malformed line is: it might have been this one's.
                        damaged_records += 1
                        continue
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
                    names[str(at.get("skill.name"))] += 1
                    triggers[str(at.get("invocation_trigger"))] += 1
                    # EVERY scope this experiment did not install is counted apart from the
                    # one it did. Two §4a rounds were needed to get this right, and both
                    # failures had the same shape: a value that is not "bundled" falling
                    # through to the installed-skill counter, inventing evidence for the
                    # treatment arm out of an attribute that means something else.
                    #
                    #   round 1: a MISSING skill.source counted as the installed skill
                    #   round 2: a PLUGIN skill counted as the installed skill — and plugin is
                    #            the only non-bundled source ever observed on this instrument,
                    #            so a plugin firing on the CONTROL arm would have recorded an
                    #            activation in the arm that installed nothing
                    #
                    # The counter is therefore an allowlist by exclusion, and everything it
                    # excludes is reported on its own line rather than dropped.
                    # NO "everything else is mine" bucket. See the header.
                    by_source[str(src)] += 1
                    if src == "bundled":
                        bundled += 1
                    elif src == "plugin":
                        plugin += 1
                    elif src is None or src == "":
                        unknown_source += 1
                    else:
                        other += 1

if not parsed_any:
    print("skill-activation: no parseable JSON lines in telemetry", file=sys.stderr)
    sys.exit(2)

def fmt(counter):
    return ",".join(f"{k}={v}" for k, v in sorted(counter.items())) or "-"

damaged = malformed_lines + damaged_records
if not present:
    status = "UNKNOWN-run-absent-from-telemetry"
elif damaged:
    status = "PARTIAL-telemetry-damaged"
else:
    status = "measured"
if present and unknown_source:
    print(f"skill-activation: {unknown_source} activation(s) carry no skill.source and are "
          "counted in NO scope — inspect them before using this run", file=sys.stderr)
print(f"run: {run_id}")
print(f"status: {status}")
print(f"bundled_activations: {bundled if present else 'null'}")
print(f"plugin_activations: {plugin if present else 'null'}")
print(f"unknown_source_activations: {unknown_source if present else 'null'}")
print(f"other_source_activations: {other if present else 'null'}")
print(f"activations_by_source: {fmt(by_source)}")
print(f"skill_names: {fmt(names)}")
print(f"invocation_triggers: {fmt(triggers)}")
print(f"malformed_lines: {malformed_lines}")
print(f"damaged_records: {damaged_records}")

if not present:
    sys.exit(3)
if damaged:
    print(f"skill-activation: {malformed_lines} unparseable line(s) and {damaged_records} "
          "unreadable record(s) in this stream. Every count above is a LOWER BOUND, not a "
          "zero — a dropped line could have carried this run's activation.", file=sys.stderr)
    sys.exit(4)
sys.exit(0)
PY
