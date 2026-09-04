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
# EVERY scope this experiment did not install is counted apart from the one it did:
# `bundled` (Claude Code ships its own), `plugin` (the operator may have some), and events with
# no `skill.source` at all. Only what is left is reported as `installed_scope_activations`.
# Anything looser puts activations in the arm that installed nothing — the control — which is
# the direction that manufactures a result. `plugin` is the ONLY non-bundled source ever
# observed on this instrument, so lumping it in with the installed skill was not hypothetical.
#
# NOTE: the value `skill.source` carries for a project skill is UNKNOWN — none has ever been
# recorded here. The preflight must pin it before a batch is read, or `installed_scope` is a
# category with nothing proven to be in it.

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
installed = 0     # the skill THIS experiment installed: source is neither bundled nor plugin
bundled = 0
plugin = 0
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
                    if src == "bundled":
                        bundled += 1
                    elif src == "plugin":
                        plugin += 1
                    elif src is None or src == "":
                        unknown_source += 1
                    else:
                        installed += 1

if not parsed_any:
    print("skill-activation: no parseable JSON lines in telemetry", file=sys.stderr)
    sys.exit(2)

def fmt(counter):
    return ",".join(f"{k}={v}" for k, v in sorted(counter.items())) or "-"

status = "measured" if present else "UNKNOWN-run-absent-from-telemetry"
if present and unknown_source:
    print(f"skill-activation: {unknown_source} activation(s) carry no skill.source and are "
          "counted in NO scope — inspect them before using this run", file=sys.stderr)
print(f"run: {run_id}")
print(f"status: {status}")
print(f"installed_scope_activations: {installed if present else 'null'}")
print(f"bundled_activations: {bundled if present else 'null'}")
print(f"plugin_activations: {plugin if present else 'null'}")
print(f"unknown_source_activations: {unknown_source if present else 'null'}")
print(f"skill_names: {fmt(names)}")
print(f"skill_sources: {fmt(sources)}")
print(f"invocation_triggers: {fmt(triggers)}")

sys.exit(0 if present else 3)
PY
