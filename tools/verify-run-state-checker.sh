#!/usr/bin/env bash
#
# verify-run-state-checker — the fixture set for tools/check-run-state.sh.
#
# A validator never shown to reject anything is indistinguishable from one that accepts
# everything, and this project has shipped three of those (tools/skill-activation.sh, three
# rounds of "everything not bundled is MINE"; the runner's contamination guard, "every skill
# is THEIRS"). Both are allowlists with fixture sets now. This is that fixture set, written
# in the same commit as the checker rather than after it.
#
# The KNOWN-GOOD case is produced by RUNNING THE REAL HOOK, not by hand-writing what the
# schema is believed to look like — a fixture written from the schema proves the schema
# agrees with itself.
#
# Usage: tools/verify-run-state-checker.sh
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
CHECK="$PWD/tools/check-run-state.sh"
LIMIT="$PWD/build/customizations/agent-v1.1/.ai/hooks/repair-limit.sh"
[[ -x "$CHECK" ]] || { echo "check-run-state.sh not executable" >&2; exit 30; }
[[ -x "$LIMIT" ]] || { echo "repair-limit.sh not executable" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-62s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-62s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
export CLAUDE_PROJECT_DIR="$SANDBOX/observatory-run-fixture"; mkdir -p "$CLAUDE_PROJECT_DIR"
GOOD="$SANDBOX/known-good.json"

# --- known-good, produced by the real hook ---------------------------------------------------
AGENT_RUN_STATE_FILE="$GOOD" bash -c \
  'printf "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"./mvnw test\"}}" | "$0"' \
  "$LIMIT" >/dev/null 2>&1

expect() {  # expect <label> <want-exit> <file>
  local label="$1" want="$2" f="$3" got
  "$CHECK" "$f" >/dev/null 2>&1; got=$?
  [[ "$got" == "$want" ]] && ok "$label" "exit $got" || bad "$label" "exit $want" "exit $got"
}

# mutate <jq-program> -> path to a mutated copy of known-good
mutate() { local out="$SANDBOX/m$RANDOM$RANDOM.json"; jq "$1" "$GOOD" > "$out"; echo "$out"; }

echo "verify-run-state-checker: fixture set for tools/check-run-state.sh"
echo
echo "ACCEPTS a file the real hook wrote:"
expect "known-good, written by repair-limit.sh itself"              0 "$GOOD"

echo
echo "REFUSES a file that is not a run-state at all:"
printf 'not json'                > "$SANDBOX/notjson.json";  expect "not JSON"                      1 "$SANDBOX/notjson.json"
printf '{}'                      > "$SANDBOX/empty.json";    expect "an empty object"               1 "$SANDBOX/empty.json"
printf '[]'                      > "$SANDBOX/arr.json";      expect "a JSON array"                  1 "$SANDBOX/arr.json"
printf '{"schemaVersion":"b8-v1.1"}' > "$SANDBOX/thin.json"; expect "the version field and nothing else" 1 "$SANDBOX/thin.json"

echo
echo "REFUSES each required field removed one at a time:"
for f in schemaVersion worktree startedAt updatedAt phase totalRepairAttempts \
         repairAttemptsByFingerprint affectedFiles blocks hookExecutions limits handoff; do
  expect "missing .$f" 1 "$(mutate "del(.$f)")"
done

echo
echo "REFUSES a field of the wrong type — a schema that only checks presence is not a schema:"
expect "totalRepairAttempts as a string"   1 "$(mutate '.totalRepairAttempts = "3"')"
expect "affectedFiles as an object"        1 "$(mutate '.affectedFiles = {}')"
expect "repairAttemptsByFingerprint as an array" 1 "$(mutate '.repairAttemptsByFingerprint = []')"
expect "limits missing its per-failure key" 1 "$(mutate 'del(.limits.maxRepairAttemptsPerFailure)')"

echo
echo "REFUSES a file whose invariants say the limit did NOT hold — the point of the checker:"
expect "a fingerprint above maxRepairAttemptsPerFailure" 1 "$(mutate '.repairAttemptsByFingerprint["deadbeef00000000"] = 4')"
expect "totalRepairAttempts above maxTotalRepairAttempts" 1 "$(mutate '.totalRepairAttempts = 8')"
expect "a negative total"                                1 "$(mutate '.totalRepairAttempts = -1')"
expect "a cleared fingerprint left at 0 instead of deleted" 1 "$(mutate '.repairAttemptsByFingerprint["deadbeef00000000"] = 0')"
expect "a block with no reason"                          1 "$(mutate '.blocks = [{"fingerprint":"x","reason":""}]')"
expect "a hookExecution with an unknown decision"        1 "$(mutate '.hookExecutions = [{"hook":"h","decision":"maybe"}]')"

echo
echo "AUTHOR DECISION 11 ITEM 7 — the handoff block is required, and required to say it is reserved:"
expect "handoff present with all four fields"            0 "$GOOD"
for f in fromAgent toAgent delivered remaining; do
  expect "handoff missing .$f" 1 "$(mutate "del(.handoff.$f)")"
done
expect "handoff whose reserved note does not name B8a"   1 "$(mutate '.handoff.reserved = "tbd"')"
# NEGATIVE CONTROL. The fields are RESERVED, so null is the correct value at this version and
# a checker that demanded values would be demanding that B8a already exist.
expect "NEGATIVE CONTROL: all four handoff fields null is VALID" 0 "$(mutate '.handoff.fromAgent=null | .handoff.toAgent=null | .handoff.delivered=null | .handoff.remaining=null')"
# NEGATIVE CONTROL. And a populated handoff must also pass, or B8a could not use the field it
# was given.
expect "NEGATIVE CONTROL: a populated handoff is VALID too" 0 "$(mutate '.handoff.fromAgent="orchestrator" | .handoff.toAgent="implementer" | .handoff.delivered="schema" | .handoff.remaining="tests"')"

echo
echo "NEGATIVE CONTROLS — legitimate shapes that must NOT be refused:"
expect "a run with no repairs at all (the expected batch shape)" 0 "$(mutate '.repairAttemptsByFingerprint = {} | .totalRepairAttempts = 0')"
expect "a run sitting exactly ON both limits"                    0 "$(mutate '.repairAttemptsByFingerprint = {"aaaaaaaaaaaaaaaa":3} | .totalRepairAttempts = 7')"
expect "a run that recorded blocks"                              0 "$(mutate '.blocks = [{"ts":"t","fingerprint":"f","command":"c","reason":"fingerprint-limit: attempt 4 exceeds 3"}]')"
expect "a run that recorded an error execution (fail-open)"      0 "$(mutate '.hookExecutions += [{"hook":"repair-limit","ts":"t","decision":"error","reason":"no-command"}]')"

echo
echo "THE THREE §4a ROUND-1 FINDINGS — each fixture is the failure scenario the critic named,"
echo "and each one PASSED this checker before 2026-09-16:"
expect "decision \"allo\" — a PREFIX of a valid enum value"          1 "$(mutate '.hookExecutions[0].decision = "allo"')"
expect "decision \"low b\" — a SUBSTRING spanning two values"        1 "$(mutate '.hookExecutions[0].decision = "low b"')"
expect "decision \"\" — the empty string is inside every string"     1 "$(mutate '.hookExecutions[0].decision = ""')"
expect "decision \"allowed\" — a SUPERSTRING of a valid value"       1 "$(mutate '.hookExecutions[0].decision = "allowed"')"
expect "a file that raises its OWN ceiling to 1000 and sits at 900"  1 "$(mutate '.limits.maxTotalRepairAttempts = 1000 | .totalRepairAttempts = 900')"
expect "a file that raises its own per-failure ceiling to 99"        1 "$(mutate '.limits.maxRepairAttemptsPerFailure = 99 | .repairAttemptsByFingerprint = {"aaaaaaaaaaaaaaaa":50}')"
expect "a file that LOWERS its own ceilings below the registered 3/7" 1 "$(mutate '.limits = {"maxRepairAttemptsPerFailure":1,"maxTotalRepairAttempts":2}')"
expect "totalRepairAttempts = 2.5 — a count that is not whole"       1 "$(mutate '.totalRepairAttempts = 2.5')"
expect "a fingerprint counter of 1.5"                               1 "$(mutate '.repairAttemptsByFingerprint = {"aaaaaaaaaaaaaaaa":1.5}')"
expect "a limit declared as 3.5"                                    1 "$(mutate '.limits.maxRepairAttemptsPerFailure = 3.5')"

echo
echo "AND THE NEGATIVE CONTROLS FOR THOSE THREE — the strengthened checks must still accept:"
expect "every valid decision value, one execution each"             0 "$(mutate '.hookExecutions = [{"hook":"repair-limit","ts":"t","decision":"allow"},{"hook":"repair-limit","ts":"t","decision":"block","reason":"r"},{"hook":"repair-record","ts":"t","decision":"success"},{"hook":"repair-limit","ts":"t","decision":"error","reason":"r"}]')"
expect "the registered limits stated explicitly as 3 and 7"         0 "$(mutate '.limits = {"maxRepairAttemptsPerFailure":3,"maxTotalRepairAttempts":7}')"
expect "whole-number counts at the boundary (0 and 7)"              0 "$(mutate '.totalRepairAttempts = 7 | .repairAttemptsByFingerprint = {}')"

echo
echo "USAGE errors are exit 30, distinct from INVALID — so a broken call is not read as a bad file:"
"$CHECK" >/dev/null 2>&1; G=$?; [[ "$G" == 30 ]] && ok "no argument" "exit 30" || bad "no argument" "exit 30" "exit $G"
"$CHECK" "$SANDBOX/nope.json" >/dev/null 2>&1; G=$?; [[ "$G" == 30 ]] && ok "unreadable path" "exit 30" || bad "unreadable path" "exit 30" "exit $G"

echo
echo "  $PASS of $N cases pass"
rm -rf "$SANDBOX"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
