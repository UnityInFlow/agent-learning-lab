#!/usr/bin/env bash
# verify-retrieval-trace-probe.sh — prove every exit code retrieval-trace-probe.sh
# REGISTERS actually fires, on a fixture written to force it, and prove the two detector
# sensitivities are distinguishable from each other rather than merely both present.
#
# §4 step 4: "a control that has never been shown to reject anything is indistinguishable
# from one that rejects nothing." The probe's whole claim is a NEGATIVE — that nothing in
# the telemetry names a file a run read — and a scanner that scans nothing returns exactly
# that.
#
# WHICH CASES CARRY WHICH CLAIM (named, not numbered — an earlier version of this header
# cited "Cases 2-5, 7 and 11" against a script that has no numbered cases, which the §4a
# review called materially false, and it was):
#
#   THE DETECTOR FIRES, and where:  "path in a Read attribute", "path in a log record
#       body", "path in resource attributes", "bare filename, LOOSE only", "path in a
#       non-Read event", "paths in result.changedFiles"
#   THE TWO SENSITIVITIES ARE DISTINGUISHABLE:  "STRICT stays silent where LOOSE fires"
#       and "STRICT fires on a separator path" assert the PRINTED strict/loose counts, not
#       just the exit code. Without them a probe whose STRICT regex had collapsed into
#       LOOSE would pass this entire suite.
#   A HIT IS ATTRIBUTED TO A READ OR NOT:  "a hit ON a Read event is read-scoped" and
#       "a hit on a non-Read event is NOT read-scoped" assert the printed read_scoped line.
#   THE PARSER MATCHES THE REAL SCHEMA:  "a real telemetry excerpt is recognised" runs
#       against three unmodified lines captured from the live events.jsonl. No synthetic
#       fixture can catch a wrong schema assumption, because I wrote both the fixture and
#       the parser from the same belief.
#   A SCHEMA CHANGE IS NOT AN EMPTY POPULATION:  "attributes under a different key"
#   AN EMPTY POPULATION IS NOT A CLEAN NEGATIVE:  "zero Read events", "zero run records"
#   UNPARSABLE IS NOT A CLEAN NEGATIVE EITHER:  the four "not JSON" / "empty" cases
#   PRECEDENCE IS REGISTERED, NOT ACCIDENTAL:  "malformed input beside a real hit" pins
#       detection above partial parse failure, so two implementations cannot both pass.
#
# OUT OF SCOPE, stated so the title cannot be read as more: this script asserts exit codes
# and the specific printed counters named above. It does NOT assert that the probe reports
# the RIGHT path — only that it reports a hit where one exists and none where it does not.
#
# Exit 0 when every case returns its registered code AND the declared code set is fully
# exercised; 1 otherwise.
set -uo pipefail

cd "$(dirname "$0")" || exit 2
PROBE=./retrieval-trace-probe.sh
FIX=./fixtures
pass=0
fail=0
exercised=""

check() {
  local want=$1 desc=$2
  shift 2
  local got
  "$@" >/dev/null 2>&1
  got=$?
  exercised="$exercised $want"
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %-40s exit %s\n' "$desc" "$got"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-40s want %s got %s  %s\n' "$desc" "$want" "$got" "$*"
    fail=$((fail + 1))
  fi
}

# assert a printed line matches a regex — the counters, not only the exit code
check_out() {
  local desc=$1 pattern=$2
  shift 2
  local out
  out=$("$@" 2>&1)
  if grep -Eq -- "$pattern" <<<"$out"; then
    printf 'ok    %-40s output matches /%s/\n' "$desc" "$pattern"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-40s output does NOT match /%s/\n' "$desc" "$pattern"
    printf '      got: %s\n' "$(grep -E '^(hits|read_scoped):' <<<"$out" | tr '\n' ' ')"
    fail=$((fail + 1))
  fi
}

# --- the detector must FIRE. These are the positive controls. ---
check 3 "path in a Read attribute"          "$PROBE" telemetry "$FIX/t-path-attr.jsonl"
check 3 "path in a log record body"         "$PROBE" telemetry "$FIX/t-path-body.jsonl"
check 3 "path in resource attributes"       "$PROBE" telemetry "$FIX/t-path-resource.jsonl"
check 3 "bare filename, LOOSE only"         "$PROBE" telemetry "$FIX/t-bare-filename.jsonl"
check 3 "path in a non-Read event"          "$PROBE" telemetry "$FIX/t-path-in-bash-event.jsonl"
check 3 "paths in result.changedFiles"      "$PROBE" records   "$FIX/r-changed-files.json"

# --- the two sensitivities must be DISTINGUISHABLE, not merely both reachable ---
check_out "STRICT stays silent where LOOSE fires" 'hits: strict=0 loose_only=1' \
  "$PROBE" telemetry "$FIX/t-bare-filename.jsonl"
check_out "STRICT fires on a separator path"      'hits: strict=1 loose_only=0' \
  "$PROBE" telemetry "$FIX/t-path-body.jsonl"

# --- a hit must be attributable to a Read, or explicitly not ---
check_out "a hit ON a Read event is read-scoped"  'read_scoped: strict=1 loose_only=0' \
  "$PROBE" telemetry "$FIX/t-path-attr.jsonl"
check_out "a hit on a non-Read event is NOT read-scoped" 'read_scoped: strict=0 loose_only=0' \
  "$PROBE" telemetry "$FIX/t-path-in-bash-event.jsonl"

# --- the parser must match the REAL schema, not only the one I invented ---
check 0 "a real telemetry excerpt is recognised" "$PROBE" telemetry "$FIX/t-real-sample.jsonl"
check_out "the real excerpt yields real Read events" 'read_events=[1-9]' \
  "$PROBE" telemetry "$FIX/t-real-sample.jsonl"

# --- a moved schema must NOT read as an empty population ---
check 6 "attributes under a different key"   "$PROBE" telemetry "$FIX/t-schema-moved.jsonl"

# --- the detector must stay SILENT only over a non-empty population ---
check 0 "Read events, no file named"        "$PROBE" telemetry "$FIX/t-no-path.jsonl"
check 0 "a record naming no file"           "$PROBE" records   "$FIX/r-no-paths.json"

# --- an empty population must NOT read as a clean negative ---
check 4 "zero Read events"                  "$PROBE" telemetry "$FIX/t-no-read-events.jsonl"
check 4 "zero run records"                  "$PROBE" records   "$FIX/r-empty.json"

# --- unparsable input must NOT read as a clean negative either ---
check 5 "telemetry, not JSON"               "$PROBE" telemetry "$FIX/t-malformed.jsonl"
check 5 "telemetry, empty file"             "$PROBE" telemetry "$FIX/t-empty.jsonl"
check 5 "telemetry, blank lines only"       "$PROBE" telemetry "$FIX/t-blank-lines.jsonl"
check 5 "records, not JSON"                 "$PROBE" records   "$FIX/r-malformed.json"

# --- PRECEDENCE: a partially unparsable input is not 5 ---
check 3 "malformed input beside a real hit" \
  "$PROBE" telemetry "$FIX/t-malformed.jsonl" "$FIX/t-path-body.jsonl"
check 3 "hit in the second input only"      \
  "$PROBE" telemetry "$FIX/t-no-path.jsonl" "$FIX/t-path-body.jsonl"

# --- usage errors ---
check 2 "no arguments"                      "$PROBE"
check 2 "mode with no file"                 "$PROBE" telemetry
check 2 "unknown mode"                      "$PROBE" corpus "$FIX/t-no-path.jsonl"
check 2 "input file does not exist"         "$PROBE" telemetry "$FIX/does-not-exist.jsonl"
check 2 "records mode, two inputs"          "$PROBE" records "$FIX/r-no-paths.json" "$FIX/r-empty.json"

# --- and the claim in this script's own title, made executable ---
# "every registered exit code" is meaningless unless the registered SET is read from the
# probe rather than from memory. A code added to the probe without a case here now FAILS.
declared=$(grep -m1 '^# REGISTERED-EXIT-CODES:' "$PROBE" \
  | sed 's/^# REGISTERED-EXIT-CODES://' | tr -s ' ' '\n' | grep -E '^[0-9]+$' | sort -u | tr '\n' ' ')
covered=$(tr -s ' ' '\n' <<<"$exercised" | grep -E '^[0-9]+$' | sort -u | tr '\n' ' ')
printf '\nregistered exit codes declared by the probe: %s\n' "$declared"
printf 'exit codes exercised by this script:        %s\n' "$covered"
if [[ -z "$declared" ]]; then
  printf 'FAIL  the probe declares no REGISTERED-EXIT-CODES line to check against\n'
  fail=$((fail + 1))
elif [[ "$declared" == "$covered" ]]; then
  printf 'ok    every declared exit code is exercised, and no undeclared code is\n'
  pass=$((pass + 1))
else
  printf 'FAIL  declared and exercised sets differ — a code is unproved or undeclared\n'
  fail=$((fail + 1))
fi

printf '\n%s: %d passed, %d failed\n' "${0##*/}" "$pass" "$fail"
[[ "$fail" -eq 0 ]]
