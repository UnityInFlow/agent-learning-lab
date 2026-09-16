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
# `type == "number"` admits 2.5, and these three fields are COUNTS. Integrality is checked
# separately from type so the message says which of the two is wrong. §4a round 1, 1/2.
if jq -e '(.totalRepairAttempts // 0) | (floor != .)' "$FILE" >/dev/null 2>&1; then
  problem ".totalRepairAttempts: must be a whole number, found $(jq -r '.totalRepairAttempts' "$FILE")"
fi
if jq -e '[.repairAttemptsByFingerprint[] | select((type == "number") and (floor != .))] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".repairAttemptsByFingerprint: every value must be a WHOLE number"
fi
if jq -e '[.limits[] | select((type == "number") and (floor != .))] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".limits: every limit must be a WHOLE number"
fi
if jq -e '[.repairAttemptsByFingerprint[] | select((type != "number") or (. < 1))] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".repairAttemptsByFingerprint: every value must be a number >= 1 (a cleared fingerprint is DELETED, not set to 0)"
fi
# THE CEILINGS ARE THE REGISTERED CONSTANTS, NOT THE ONES THE FILE DECLARES ABOUT ITSELF.
# Until §4a round 1 both checks below read `.limits.* // 3` and `.limits.* // 7`, so a file
# declaring `maxTotalRepairAttempts: 1000` with `totalRepairAttempts: 900` passed the very check
# meant to catch it — the file was grading its own homework. The registered values are 3 and 7
# (build/README.md#b8, and MAX_PER / MAX_TOTAL in repair-limit.sh), so they are written here and
# the file's own `.limits` block is now CHECKED AGAINST them rather than trusted as the source.
# Found by §4a round 1, codex + deepseek, 1/2 recurrence — and 1/2 is a detection threshold, not
# a truth value.
REG_PER=3
REG_TOTAL=7
if jq -e --argjson m "$REG_PER" '.limits.maxRepairAttemptsPerFailure != $m' "$FILE" >/dev/null 2>&1; then
  problem ".limits.maxRepairAttemptsPerFailure: expected the registered $REG_PER, found $(jq -r '.limits.maxRepairAttemptsPerFailure' "$FILE")"
fi
if jq -e --argjson m "$REG_TOTAL" '.limits.maxTotalRepairAttempts != $m' "$FILE" >/dev/null 2>&1; then
  problem ".limits.maxTotalRepairAttempts: expected the registered $REG_TOTAL, found $(jq -r '.limits.maxTotalRepairAttempts' "$FILE")"
fi
# A fingerprint may never sit above the REGISTERED limit: the hook refuses the call that would
# do it, so a file that shows one above it is a file whose limit did not hold.
if jq -e --argjson m "$REG_PER" '[.repairAttemptsByFingerprint[] | select(. > $m)] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".repairAttemptsByFingerprint: a value exceeds the registered $REG_PER — the limit did not hold"
fi
if jq -e --argjson m "$REG_TOTAL" '(.totalRepairAttempts // 0) > $m' "$FILE" >/dev/null 2>&1; then
  problem ".totalRepairAttempts: exceeds the registered $REG_TOTAL — the total limit did not hold"
fi
# Every recorded block must name a reason, or a blocked run cannot be explained afterwards.
if jq -e '[.blocks[] | select((.reason // "") == "" or (.fingerprint // "") == "")] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".blocks: every entry needs a non-empty .reason and .fingerprint"
fi
# EXACT membership, not containment. `inside("allow block success error")` was a SUBSTRING test:
# jq's `inside` on a string asks whether the left operand is contained in the right, so "allo",
# "low b" and "" all passed the enum. Found by §4a round 1, codex + deepseek, 2/2 recurrence.
# An enum check that accepts a prefix of a valid value is a control reporting success over a
# scope smaller than it claims — the house failure mode, in one jq builtin.
if jq -e '[.hookExecutions[] | select((.decision // "") as $d | ["allow","block","success","error"] | index($d) == null)] | length > 0' "$FILE" >/dev/null 2>&1; then
  problem ".hookExecutions: .decision must be EXACTLY one of allow | block | success | error"
fi

if [[ "$PROBLEMS" -eq 0 ]]; then
  echo "check-run-state: $FILE is valid against schema b8-v1.1"
  exit 0
fi
echo "check-run-state: $PROBLEMS problem(s) in $FILE" >&2
exit 1
