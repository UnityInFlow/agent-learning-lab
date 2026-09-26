#!/usr/bin/env bash
# verify-retrieval-trace-probe.sh — prove every registered exit code of
# retrieval-trace-probe.sh fires, on a fixture written to force it.
#
# §4 step 4: "a control that has never been shown to reject anything is
# indistinguishable from one that rejects nothing." The probe's whole claim is a
# NEGATIVE — that nothing in the telemetry names a file a run read — and a scanner
# that scans nothing returns exactly that. Cases 2-5, 7 and 11 are the ones that
# matter: they prove the detector FIRES, at both sensitivities, in an attribute, in
# a body, in resource attributes, in another tool's event, and in a run record.
#
# Exit 0 when every case returns its registered code; 1 otherwise.
set -uo pipefail

cd "$(dirname "$0")" || exit 2
PROBE=./retrieval-trace-probe.sh
FIX=./fixtures
pass=0
fail=0

check() {
  local want=$1 desc=$2
  shift 2
  local got
  "$@" >/dev/null 2>&1
  got=$?
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %-34s exit %s  %s\n' "$desc" "$got" "$*"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-34s want %s got %s  %s\n' "$desc" "$want" "$got" "$*"
    fail=$((fail + 1))
  fi
}

# --- the detector must FIRE. These are the positive controls. ---
check 3 "path in a Read attribute"        "$PROBE" telemetry "$FIX/t-path-attr.jsonl"
check 3 "path in a log record body"       "$PROBE" telemetry "$FIX/t-path-body.jsonl"
check 3 "path in resource attributes"     "$PROBE" telemetry "$FIX/t-path-resource.jsonl"
check 3 "bare filename, LOOSE only"       "$PROBE" telemetry "$FIX/t-bare-filename.jsonl"
check 3 "path in a non-Read event"        "$PROBE" telemetry "$FIX/t-path-in-bash-event.jsonl"
check 3 "paths in result.changedFiles"    "$PROBE" records   "$FIX/r-changed-files.json"

# --- the detector must stay SILENT only over a non-empty population ---
check 0 "Read events, no file named"      "$PROBE" telemetry "$FIX/t-no-path.jsonl"
check 0 "a record naming no file"         "$PROBE" records   "$FIX/r-no-paths.json"

# --- an empty population must NOT read as a clean negative ---
check 4 "zero Read events"                "$PROBE" telemetry "$FIX/t-no-read-events.jsonl"
check 4 "zero run records"                "$PROBE" records   "$FIX/r-empty.json"

# --- unparsable input must NOT read as a clean negative either ---
check 5 "telemetry, not JSON"             "$PROBE" telemetry "$FIX/t-malformed.jsonl"
check 5 "telemetry, empty file"           "$PROBE" telemetry "$FIX/t-empty.jsonl"
check 5 "telemetry, blank lines only"     "$PROBE" telemetry "$FIX/t-blank-lines.jsonl"
check 5 "records, not JSON"               "$PROBE" records   "$FIX/r-malformed.json"

# --- usage errors ---
check 2 "no arguments"                    "$PROBE"
check 2 "mode with no file"               "$PROBE" telemetry
check 2 "unknown mode"                    "$PROBE" corpus "$FIX/t-no-path.jsonl"
check 2 "input file does not exist"       "$PROBE" telemetry "$FIX/does-not-exist.jsonl"
check 2 "records mode, two inputs"        "$PROBE" records "$FIX/r-no-paths.json" "$FIX/r-empty.json"

# --- multi-file telemetry: a hit in the SECOND file must still fire ---
check 3 "hit in the second input only"    "$PROBE" telemetry "$FIX/t-no-path.jsonl" "$FIX/t-path-body.jsonl"

printf '\n%s: %d passed, %d failed\n' "${0##*/}" "$pass" "$fail"
[[ "$fail" -eq 0 ]]
