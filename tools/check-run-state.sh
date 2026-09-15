#!/usr/bin/env bash
#
# check-run-state — validates a B8 run-state file against the registered schema and REFUSES a
# malformed one.
#
# WHY IT EXISTS, and it is not a formality. The run-state file itself is L3: it is data, and
# any process can put anything in a JSON file, so having a field is not a control. The
# workspace CLAUDE.md names that exact substitution — "adding `required:` to a template,
# documenting a unit, defining an enum in a comment — none of these run". THIS RUNS. It is
# what makes the schema row checkable rather than asserted, and it is the difference between
# "B8 defines a run-state schema" and "B8 has a run-state schema that something enforces".
#
# EXIT CODES:
#   0   valid against the registered schema
#   1   INVALID — every problem found is printed, not just the first
#   30  usage / unreadable input
#
# Usage: tools/check-run-state.sh <path-to-run-state.json>
set -uo pipefail

FILE="${1:-}"
[[ -n "$FILE" ]] || { echo "usage: check-run-state.sh <run-state.json>" >&2; exit 30; }
[[ -r "$FILE" ]] || { echo "check-run-state: cannot read $FILE" >&2; exit 30; }
command -v jq >/dev/null 2>&1 || { echo "check-run-state: jq is required" >&2; exit 30; }
jq -e . "$FILE" >/dev/null 2>&1 || { echo "check-run-state: $FILE is not valid JSON" >&2; exit 1; }

PROBLEMS=0
problem() { PROBLEMS=$((PROBLEMS+1)); printf '  INVALID  %s\n' "$1"; }

want_type() {  # want_type <jq-path> <expected type>
  local path="$1" want="$2" got
  got="$(jq -r "try ($path | type) catch \"missing\"" "$FILE" 2>/dev/null)"
  [[ -z "$got" ]] && got=missing
  [[ "$got" == "$want" ]] || problem "$path: expected $want, found $got"
}

# --- required scalars ---------------------------------------------------------------------
want_type '.schemaVersion'              string
want_type '.worktree'                   string
want_type '.startedAt'                  string
want_type '.updatedAt'                  string
want_type '.phase'                      string
want_type '.totalRepairAttempts'        number
want_type '.repairAttemptsByFingerprint' object
want_type '.affectedFiles'              array
want_type '.blocks'                     array
want_type '.hookExecutions'             array
want_type '.limits'                     object
want_type '.limits.maxRepairAttemptsPerFailure' number
want_type '.limits.maxTotalRepairAttempts'      number

# --- the handoff block — author decision 11 item 7 ------------------------------------------
# Written UNCONDITIONALLY and MARKED RESERVED. This checker asserts it is PRESENT and has its
# four fields; it deliberately does NOT assert they are non-null, because at this version
# nothing writes them and a checker that demanded values would be demanding that B8a exist.
want_type '.handoff' object
for f in fromAgent toAgent delivered remaining; do
  jq -e "has(\"handoff\") and (.handoff | has(\"$f\"))" "$FILE" >/dev/null 2>&1 \
    || problem ".handoff.$f: missing (author decision 11 item 7 requires the field, reserved)"
done
jq -e '(.handoff.reserved // "") | test("B8a")' "$FILE" >/dev/null 2>&1 \
  || problem '.handoff.reserved: must say the block is reserved for B8a, so a later reader cannot mistake data for a control'

# --- the invariants the hooks are supposed to maintain ---------------------------------------
# These are what separate a file that LOOKS like a run-state from one a run actually produced.
if jq -e '.schemaVersion != "b8-v1.1"' "$FILE" >/dev/null 2>&1; then
  problem ".schemaVersion: expected \"b8-v1.1\", found $(jq -r '.schemaVersion' "$FILE")"
fi
if jq -e '.totalRepairAttempts < 0' "$FILE" >/dev/null 2>&1; then
  problem ".totalRepairAttempts: negative"
fi
if jq -e '[.repairAttemptsByFingerprint[] | select((type != "number") or (. < 1))] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".repairAttemptsByFingerprint: every value must be a number >= 1 (a cleared fingerprint is DELETED, not set to 0)"
fi
# A fingerprint may never sit above its own limit: the hook refuses the call that would do it.
if jq -e '(.limits.maxRepairAttemptsPerFailure // 3) as $m | [.repairAttemptsByFingerprint[] | select(. > $m)] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".repairAttemptsByFingerprint: a value exceeds maxRepairAttemptsPerFailure — the limit did not hold"
fi
if jq -e '(.limits.maxTotalRepairAttempts // 7) as $m | (.totalRepairAttempts // 0) > $m' "$FILE" >/dev/null 2>&1; then
  problem ".totalRepairAttempts: exceeds maxTotalRepairAttempts — the total limit did not hold"
fi
# Every recorded block must name a reason, or a blocked run cannot be explained afterwards.
if jq -e '[.blocks[] | select((.reason // "") == "" or (.fingerprint // "") == "")] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".blocks: every entry needs a non-empty .reason and .fingerprint"
fi
if jq -e '[.hookExecutions[] | select((.decision // "") | inside("allow block success error") | not)] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".hookExecutions: .decision must be one of allow | block | success | error"
fi

if [[ "$PROBLEMS" -eq 0 ]]; then
  echo "check-run-state: $FILE is valid against schema b8-v1.1"
  exit 0
fi
echo "check-run-state: $PROBLEMS problem(s) in $FILE" >&2
exit 1
