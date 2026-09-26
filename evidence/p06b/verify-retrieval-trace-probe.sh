#!/usr/bin/env bash
# verify-retrieval-trace-probe.sh — prove every exit code retrieval-trace-probe.sh
# REGISTERS actually fires, on a fixture written to force it; prove the two detector
# sensitivities are distinguishable from each other rather than merely both present; and
# assert printed counters by EXACT FULL-LINE match, never by substring.
#
# §4 step 4: "a control that has never been shown to reject anything is indistinguishable
# from one that rejects nothing." The probe's whole claim is a NEGATIVE — that nothing in
# the telemetry names a file a run read — and a scanner that scans nothing returns exactly
# that.
#
# WHY EXACT MATCHING, in this script's own history: round 2 of the §4a review found that
# every counter assertion here was an unanchored `grep -E` substring, so the pattern for
# `loose_only=1` also accepted `loose_only=10`, and `read_events=[1-9]` accepted
# `read_events=199`. Five assertions that looked like measurements were prefix tests. They
# are now `grep -Fxq` whole-line comparisons (check_line) or exact field extraction
# (check_field), and the failure output prints what it actually got.
#
# WHICH CASES CARRY WHICH CLAIM (named, not numbered — an earlier header cited "Cases 2-5,
# 7 and 11" against a script that has no numbered cases, which round 1 called materially
# false, and it was):
#
#   THE DETECTOR FIRES, and where:  "path in a Read attribute", "path in a log record
#       body", "path in resource attributes", "bare filename, LOOSE only", "path in a
#       non-Read event", "paths in result.changedFiles"
#   THE THREE SENSITIVITIES ARE DISTINGUISHABLE:  "STRICT stays silent where LOOSE fires",
#       "STRICT fires on a separator path" and "a root-relative path matches STRICT" assert
#       the whole printed `hits:` line. Without them a probe whose STRICT regex had
#       collapsed into LOOSE would pass.
#   AN EXTENSIONLESS TARGET CANNOT HIDE:  "an extensionless path fires PATHY only" — a Read
#       of `/repo/README` scores zero under STRICT and LOOSE, which §4a round 3 found would
#       have made the null narrower than the header claimed. PATHY closes it, and this case
#       is what proves PATHY is wired in rather than merely defined.
#   A HIT IS LOCATED WITHIN A READ EVENT, AT TWO SCOPES:  "a path in a Read ATTRIBUTE is
#       attributed", "a path in a Read BODY is any-scoped but not attributed", and "a hit
#       on a non-Read event is neither". The probe LOCATES; it does not claim the hit IS
#       the file read, and no case here asserts that it does.
#   THE PARSER MATCHES THE REAL SCHEMA:  "a real telemetry excerpt is recognised" runs
#       against three unmodified lines captured from the live events.jsonl. Its job is to
#       prove the PARSER reads the real shape — `read_events` non-zero — and NOT to prove
#       path extraction: real telemetry contains no paths, which is the lab's whole result.
#   THE FLAT-ATTRIBUTE BRANCH IS EXERCISED:  "attribute values as flat strings". The probe
#       accepts both the nested OTLP shape and a flat one; round 2 noted the flat branch
#       had no fixture, so a regression there would have been invisible.
#   A SCHEMA CHANGE IS NEVER AN EMPTY POPULATION:  "attributes under a different key",
#       "resourceLogs renamed", "the run array moved" — all three previously returned a
#       misleading exit 4.
#   AN EMPTY POPULATION IS NOT A CLEAN NEGATIVE:  "zero Read events", "zero run records"
#   MALFORMED INPUT IS NOT A CLEAN NEGATIVE, AND NEVER A CRASH:  the "not JSON" / "empty"
#       cases, plus "a valid JSON line that is not an object" — which used to raise an
#       uncaught AttributeError and exit 1, a code the probe does not register.
#   PRECEDENCE IS REGISTERED, NOT ACCIDENTAL, IN BOTH ORDERS:  "malformed first, hit
#       second" and "hit first, malformed second" both pin detection above partial parse
#       failure, so the result cannot depend on argument order.
#
# OUT OF SCOPE, stated so the title cannot be read as more: this script asserts exit codes
# and the specific printed counter lines named above. It does NOT assert that a reported
# path is the file that was actually read — the probe does not claim that either.
#
# Exit 0 when every case returns its registered code, every asserted line matches exactly,
# and the probe's DECLARED exit-code set equals the set these cases exercise; 1 otherwise.
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
    printf 'ok    %-46s exit %s\n' "$desc" "$got"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-46s want %s got %s  %s\n' "$desc" "$want" "$got" "$*"
    fail=$((fail + 1))
  fi
}

# EXACT whole-line assertion. grep -Fx: fixed string, full line. No substring, no prefix.
check_line() {
  local desc=$1 expect=$2
  shift 2
  local out
  out=$("$@" 2>&1)
  if grep -Fxq -- "$expect" <<<"$out"; then
    printf 'ok    %-46s line == %q\n' "$desc" "$expect"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-46s no line equals %q\n' "$desc" "$expect"
    printf '      counter lines were: %s\n' \
      "$(grep -E '^(hits|pathy|read_scoped_any|read_scoped_attr|read_scoped_pathy|population):' \
          <<<"$out" | tr '\n' '|')"
    fail=$((fail + 1))
  fi
}

# EXACT field assertion: pull `key=value` out of the output and compare the value.
check_field() {
  local desc=$1 key=$2 expect=$3
  shift 3
  local out got
  out=$("$@" 2>&1)
  got=$(sed -n "s/.*[[:space:]]${key}=\([^[:space:]]*\).*/\1/p" <<<"$out" | head -1)
  if [[ "$got" == "$expect" ]]; then
    printf 'ok    %-46s %s == %s\n' "$desc" "$key" "$got"
    pass=$((pass + 1))
  else
    printf 'FAIL  %-46s %s: want %q got %q\n' "$desc" "$key" "$expect" "$got"
    fail=$((fail + 1))
  fi
}

# --- the detector must FIRE. These are the positive controls. ---
check 3 "path in a Read attribute"            "$PROBE" telemetry "$FIX/t-path-attr.jsonl"
check 3 "path in a log record body"           "$PROBE" telemetry "$FIX/t-path-body.jsonl"
check 3 "path in resource attributes"         "$PROBE" telemetry "$FIX/t-path-resource.jsonl"
check 3 "bare filename, LOOSE only"           "$PROBE" telemetry "$FIX/t-bare-filename.jsonl"
check 3 "path in a non-Read event"            "$PROBE" telemetry "$FIX/t-path-in-bash-event.jsonl"
check 3 "paths in result.changedFiles"        "$PROBE" records   "$FIX/r-changed-files.json"

# --- an extensionless target must not be invisible (§4a round 3) ---
check 3 "an extensionless path is seen at all"  "$PROBE" telemetry "$FIX/t-extensionless-path.jsonl"
check_line "and it fires PATHY only"           "hits: strict=0 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-extensionless-path.jsonl"
check_line "with exactly one PATHY hit"        "pathy: total=1 distinct_keys=1" \
  "$PROBE" telemetry "$FIX/t-extensionless-path.jsonl"

# --- a root-relative single-component path must match STRICT, as the header says ---
check_line "a root-relative path matches STRICT" "hits: strict=1 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-root-relative-path.jsonl"

# --- a None inside the attributes array must not CRASH (it used to exit 1) ---
check 0 "a null inside the attributes array"   "$PROBE" telemetry "$FIX/t-null-attribute.jsonl"
check_field "and the Read event is still seen" read_events 1 \
  "$PROBE" telemetry "$FIX/t-null-attribute.jsonl"

# --- an EMPTY list under the first known key must not hide runs under the second ---
check 0 "empty first key, runs under the second" "$PROBE" records "$FIX/r-empty-first-key.json"
check_field "and that run is counted"          records 1 \
  "$PROBE" records "$FIX/r-empty-first-key.json"

# --- the two sensitivities must be DISTINGUISHABLE, by exact line ---
check_line "STRICT stays silent where LOOSE fires" "hits: strict=0 loose_only=1" \
  "$PROBE" telemetry "$FIX/t-bare-filename.jsonl"
check_line "STRICT fires on a separator path"      "hits: strict=1 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-path-body.jsonl"

# --- a hit must be LOCATED within a Read event, at both scopes, by exact line ---
check_line "a path in a Read ATTRIBUTE is attributed" \
  "read_scoped_attr: strict=1 loose_only=0" "$PROBE" telemetry "$FIX/t-path-attr.jsonl"
check_line "a path in a Read BODY is any-scoped only" \
  "read_scoped_attr: strict=0 loose_only=0" "$PROBE" telemetry "$FIX/t-path-body.jsonl"
check_line "a path in a Read BODY is any-scoped" \
  "read_scoped_any: strict=1 loose_only=0" "$PROBE" telemetry "$FIX/t-path-body.jsonl"
check_line "a hit on a non-Read event is neither" \
  "read_scoped_any: strict=0 loose_only=0" "$PROBE" telemetry "$FIX/t-path-in-bash-event.jsonl"

# --- the parser must match the REAL schema, not only the one its author invented ---
check 0 "a real telemetry excerpt is recognised" "$PROBE" telemetry "$FIX/t-real-sample.jsonl"
check_field "the real excerpt yields 3 Read events" read_events 3 \
  "$PROBE" telemetry "$FIX/t-real-sample.jsonl"
check_line "and names no file, as the result says" "hits: strict=0 loose_only=0" \
  "$PROBE" telemetry "$FIX/t-real-sample.jsonl"

# --- the flat-attribute branch must be exercised, not merely present ---
check 0 "attribute values as flat strings"    "$PROBE" telemetry "$FIX/t-flat-attrs.jsonl"
check_field "the flat branch yields a Read event" read_events 1 \
  "$PROBE" telemetry "$FIX/t-flat-attrs.jsonl"

# --- a moved schema must NEVER read as an empty population. Three shapes. ---
check 6 "attributes under a different key"    "$PROBE" telemetry "$FIX/t-schema-moved.jsonl"
check 6 "resourceLogs renamed"                "$PROBE" telemetry "$FIX/t-no-log-records.jsonl"
check 6 "the run array moved"                 "$PROBE" records   "$FIX/r-array-moved.json"

# --- the detector must stay SILENT only over a non-empty population ---
check 0 "Read events, no file named"          "$PROBE" telemetry "$FIX/t-no-path.jsonl"
check 0 "a record naming no file"             "$PROBE" records   "$FIX/r-no-paths.json"

# --- an empty population must NOT read as a clean negative ---
check 4 "zero Read events"                    "$PROBE" telemetry "$FIX/t-no-read-events.jsonl"
check 4 "zero run records"                    "$PROBE" records   "$FIX/r-empty.json"

# --- unparsable input must NOT read as a clean negative, and must NEVER crash ---
check 5 "telemetry, not JSON"                 "$PROBE" telemetry "$FIX/t-malformed.jsonl"
check 5 "telemetry, empty file"               "$PROBE" telemetry "$FIX/t-empty.jsonl"
check 5 "telemetry, blank lines only"         "$PROBE" telemetry "$FIX/t-blank-lines.jsonl"
check 5 "a valid JSON line that is not object" "$PROBE" telemetry "$FIX/t-nonobject-line.jsonl"
check 5 "records, not JSON"                   "$PROBE" records   "$FIX/r-malformed.json"

# --- PRECEDENCE: a partially unparsable input is not 5, in EITHER argument order ---
check 3 "malformed first, hit second" \
  "$PROBE" telemetry "$FIX/t-malformed.jsonl" "$FIX/t-path-body.jsonl"
check 3 "hit first, malformed second" \
  "$PROBE" telemetry "$FIX/t-path-body.jsonl" "$FIX/t-malformed.jsonl"
check 3 "hit in the second input only" \
  "$PROBE" telemetry "$FIX/t-no-path.jsonl" "$FIX/t-path-body.jsonl"

# --- usage errors ---
check 2 "no arguments"                        "$PROBE"
check 2 "mode with no file"                   "$PROBE" telemetry
check 2 "unknown mode"                        "$PROBE" corpus "$FIX/t-no-path.jsonl"
check 2 "input file does not exist"           "$PROBE" telemetry "$FIX/does-not-exist.jsonl"
check 2 "records mode, two inputs"            "$PROBE" records "$FIX/r-no-paths.json" "$FIX/r-empty.json"

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
