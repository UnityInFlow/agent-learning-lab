#!/usr/bin/env bash
#
# verify-repair-limit — the fixture set for B8's ONE executing control,
# build/customizations/agent-v1.1/.ai/hooks/repair-limit.sh, and for the success oracle that
# feeds it, .ai/hooks/repair-record.sh.
#
# IT EXISTS BECAUSE THE BATCH CANNOT ANSWER THE GATE CLAUSE. `build/README.md#b8` asks for
# "limits technically enforced", and the limit will not fire during either arm of Lab B8.1:
# BE-004 has never failed the evaluator on claude-haiku-4-5-20251001 (9 of 9 before stop 12,
# 10 of 10 in every arm at B5 and B6, 7 of 7 in both arms at B7 — author decision 11's own
# count) and BE-003 passes nearly always. A counter that reads 0 on 20 runs is not evidence
# that a limit works. THIS is that evidence: it executes, and it must refuse.
#
# A control never shown to reject anything is indistinguishable from one that rejects nothing.
#
# It exercises THE REGISTERED FILES, never copies. Cases marked NEGATIVE CONTROL are ones a
# naive implementation gets wrong.
#
# Usage: tools/verify-repair-limit.sh
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
OVERLAY="$PWD/build/customizations/agent-v1.1"
LIMIT="$OVERLAY/.ai/hooks/repair-limit.sh"
RECORD="$OVERLAY/.ai/hooks/repair-record.sh"
[[ -x "$LIMIT"  ]] || { echo "repair-limit.sh not found or not executable: $LIMIT" >&2; exit 30; }
[[ -x "$RECORD" ]] || { echo "repair-record.sh not found or not executable: $RECORD" >&2; exit 30; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-58s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-58s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
export CLAUDE_PROJECT_DIR="$SANDBOX/observatory-run-fixture"
mkdir -p "$CLAUDE_PROJECT_DIR"
STATE="$SANDBOX/run-state.json"
export AGENT_RUN_STATE_FILE="$STATE"
reset_state() { rm -f "$STATE"; }

pre()  { printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')" | "$LIMIT" >/dev/null 2>&1; }
post() { printf '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":%s},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":false}}' "$(jq -Rn --arg c "$1" '$c')" | "$RECORD" >/dev/null 2>&1; }
# stdout discarded, stderr captured — braces rather than `2>&1 >/dev/null` so the order is
# unambiguous to a reader and to shellcheck (SC2069).
pre_stderr() { { printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')" | "$LIMIT" >/dev/null; } 2>&1; }

expect_exit() {  # expect_exit <label> <want> <cmd>
  local label="$1" want="$2" cmd="$3" got
  pre "$cmd"; got=$?
  [[ "$got" == "$want" ]] && ok "$label" "exit $got" || bad "$label" "exit $want" "exit $got"
}

echo "verify-repair-limit: fixture set for build/customizations/agent-v1.1/.ai/hooks/"
echo
echo "THE PER-FINGERPRINT LIMIT — at most 3 attempts at the same failing command (exit 2 on the 4th):"
reset_state
expect_exit "1st attempt at ./mvnw test"                       0 "./mvnw test"
expect_exit "2nd attempt, identical"                           0 "./mvnw test"
expect_exit "3rd attempt, identical — still allowed, 3 is the limit" 0 "./mvnw test"
expect_exit "4th attempt, identical — REFUSED"                 2 "./mvnw test"
expect_exit "5th attempt, still refused rather than re-allowed" 2 "./mvnw test"

echo
echo "THE REFUSAL SAYS WHY, because stderr is the only thing the model is handed:"
MSG="$(pre_stderr './mvnw test')"
if printf '%s' "$MSG" | grep -q 'BLOCKED by the repair limit'; then ok "stderr names the limit" "message present"
else bad "stderr names the limit" "a BLOCKED message" "${MSG:0:40}"; fi
if printf '%s' "$MSG" | grep -qi 'do not retry'; then ok "stderr tells the model what to do instead" "instruction present"
else bad "stderr tells the model what to do instead" "an instruction" "absent"; fi

echo
echo "A BLOCKED CALL DOES NOT INCREMENT THE COUNTERS IT WAS REFUSED BY:"
# NEGATIVE CONTROL. A naive implementation increments first and tests second, so each refusal
# pushes the total up and the *total* limit then fires on refusals rather than on work.
BEFORE_T="$(jq -r '.totalRepairAttempts' "$STATE")"
BEFORE_F="$(jq -r '.repairAttemptsByFingerprint | to_entries[0].value' "$STATE")"
pre './mvnw test' >/dev/null 2>&1
AFTER_T="$(jq -r '.totalRepairAttempts' "$STATE")"
AFTER_F="$(jq -r '.repairAttemptsByFingerprint | to_entries[0].value' "$STATE")"
[[ "$BEFORE_T" == "$AFTER_T" ]] && ok "NEGATIVE CONTROL: a refusal leaves the total alone" "stayed at $AFTER_T" \
  || bad "NEGATIVE CONTROL: a refusal leaves the total alone" "$BEFORE_T" "$AFTER_T"
[[ "$BEFORE_F" == "$AFTER_F" ]] && ok "NEGATIVE CONTROL: a refusal leaves the fingerprint alone" "stayed at $AFTER_F" \
  || bad "NEGATIVE CONTROL: a refusal leaves the fingerprint alone" "$BEFORE_F" "$AFTER_F"

echo
echo "A SUCCESS CLEARS ITS OWN FINGERPRINT — the reset that makes the limit 'per failure':"
reset_state
pre './mvnw test'; pre './mvnw test'; pre './mvnw test'
post './mvnw test'                      # PostToolUse fires => that attempt succeeded
if [[ "$(jq -r '.repairAttemptsByFingerprint | length' "$STATE")" == "0" ]]; then
  ok "the fingerprint is cleared by a success" "map is empty"
else bad "the fingerprint is cleared by a success" "an empty map" "$(jq -c '.repairAttemptsByFingerprint' "$STATE")"; fi
expect_exit "a 4th attempt AFTER a success is allowed, not blocked"  0 "./mvnw test"
expect_exit "and the count restarts: the next two are allowed too"   0 "./mvnw test"
expect_exit "…and the third"                                         0 "./mvnw test"
expect_exit "the 4th since the success is refused again"             2 "./mvnw test"

echo
echo "A SUCCESS DOES NOT REFUND THE RUN'S TOTAL BUDGET:"
# NEGATIVE CONTROL. Decrementing the total on success would let a run alternate fail/succeed
# forever and never reach the 7-attempt ceiling the build spec sets.
T_NOW="$(jq -r '.totalRepairAttempts' "$STATE")"
[[ "$T_NOW" -ge 4 ]] && ok "NEGATIVE CONTROL: total is cumulative across successes" "total = $T_NOW" \
  || bad "NEGATIVE CONTROL: total is cumulative across successes" ">= 4" "$T_NOW"

echo
echo "THE RUN-TOTAL LIMIT — at most 7 repeat attempts across ALL commands (exit 2 on the 8th):"
# Each distinct command's FIRST attempt is not a repeat and does not count; the second
# onwards does. Four commands x two attempts each = 4 repeats; a fifth pair takes it to 5…
reset_state
for c in a b c d e f g h; do pre "echo $c" >/dev/null 2>&1; done   # 8 firsts => 0 repeats
T="$(jq -r '.totalRepairAttempts' "$STATE")"
[[ "$T" == "0" ]] && ok "NEGATIVE CONTROL: 8 distinct first attempts are 0 repairs" "total = 0" \
  || bad "NEGATIVE CONTROL: 8 distinct first attempts are 0 repairs" "0" "$T"
for c in a b c d e f g; do pre "echo $c" >/dev/null 2>&1; done     # 7 repeats => at the ceiling
T="$(jq -r '.totalRepairAttempts' "$STATE")"
[[ "$T" == "7" ]] && ok "seven repeats are reached and allowed" "total = 7" \
  || bad "seven repeats are reached and allowed" "7" "$T"
expect_exit "the 8th repeat — REFUSED on the total, not the fingerprint" 2 "echo h"
R="$(jq -r '.blocks[-1].reason' "$STATE")"
printf '%s' "$R" | grep -q 'total-limit' && ok "and the refusal names the TOTAL limit" "$R" \
  || bad "the refusal names the TOTAL limit" "total-limit: …" "$R"

echo
echo "THE FINGERPRINT IS OVER THE COMMAND, NOT OVER ITS OUTPUT OR ITS WHITESPACE:"
reset_state
pre './mvnw   test'   >/dev/null 2>&1
pre './mvnw test'     >/dev/null 2>&1
if [[ "$(jq -r '.repairAttemptsByFingerprint | length' "$STATE")" == "1" ]]; then
  ok "runs of whitespace collapse to one fingerprint" "1 entry"
else bad "runs of whitespace collapse to one fingerprint" "1 entry" "$(jq -r '.repairAttemptsByFingerprint | length' "$STATE")"; fi
reset_state
pre 'echo one' >/dev/null 2>&1
pre 'echo two' >/dev/null 2>&1
if [[ "$(jq -r '.repairAttemptsByFingerprint | length' "$STATE")" == "2" ]]; then
  ok "NEGATIVE CONTROL: different commands are different fingerprints" "2 entries"
else bad "NEGATIVE CONTROL: different commands are different fingerprints" "2 entries" "$(jq -r '.repairAttemptsByFingerprint | length' "$STATE")"; fi

echo
echo "THE TWO HOOKS AGREE ON THE FINGERPRINT — a drifting second copy is a rule that can disagree:"
# NEGATIVE CONTROL. If repair-record's fingerprint differed by one byte it would clear
# nothing, the limit would never reset, and the failure would look like a working limit.
reset_state
pre 'ls -la /tmp' >/dev/null 2>&1
post 'ls -la /tmp'
if [[ "$(jq -r '.repairAttemptsByFingerprint | length' "$STATE")" == "0" ]]; then
  ok "NEGATIVE CONTROL: repair-record clears what repair-limit wrote" "same fingerprint"
else bad "NEGATIVE CONTROL: repair-record clears what repair-limit wrote" "cleared" "not cleared — the two fingerprints disagree"; fi

echo
echo "IT RECORDS ON ALLOW AS WELL AS ON BLOCK — B7's rule, inherited:"
# A hook that writes only on the interesting path is indistinguishable from one that never ran,
# and this file is the treatment's ONLY per-run delivery proof: run-agent.sh:625-629 computes
# instructionsHash, skillsHash and agentHash and no hook hash at all.
reset_state
pre 'echo delivered' >/dev/null 2>&1
A="$(jq -r '[.hookExecutions[] | select(.decision=="allow")] | length' "$STATE")"
[[ "$A" == "1" ]] && ok "an allowed call is recorded" "1 allow execution" || bad "an allowed call is recorded" "1" "$A"
for _ in 1 2 3; do pre 'echo delivered' >/dev/null 2>&1; done
B="$(jq -r '[.hookExecutions[] | select(.decision=="block")] | length' "$STATE")"
[[ "$B" -ge 1 ]] && ok "a blocked call is recorded too" "$B block executions" || bad "a blocked call is recorded too" ">=1" "$B"

echo
echo "COUNTERS SURVIVE AN INTERRUPTION — the gate clause, answered on disk:"
# The state lives in a file, not in a hook's own process, which is the distinction Phase 5B
# draws between L2 and "L3 wearing L2's clothes". Each invocation above was a separate
# process; this asserts the value is readable after them all and after a simulated kill.
reset_state
pre './mvnw verify' >/dev/null 2>&1
pre './mvnw verify' >/dev/null 2>&1
SURVIVED="$(jq -r '.repairAttemptsByFingerprint | to_entries[0].value' "$STATE")"
[[ "$SURVIVED" == "2" ]] && ok "the counter is on disk, not in a process" "reads 2 from a cold file" \
  || bad "the counter is on disk, not in a process" "2" "$SURVIVED"

echo
echo "IT FAILS OPEN, AND SAYS SO — every exit code except 2 means the call proceeds:"
reset_state
GOT=$(printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{}}' | "$LIMIT" >/dev/null 2>&1; echo $?)
[[ "$GOT" == "0" ]] && ok "a tool_input with no command fails open" "exit 0" || bad "a tool_input with no command fails open" "exit 0" "exit $GOT"
E="$(jq -r '[.hookExecutions[] | select(.decision=="error")] | length' "$STATE")"
[[ "$E" -ge 1 ]] && ok "…and the fail-open is RECORDED, not silent" "$E error execution(s)" \
  || bad "the fail-open is recorded" ">=1 error execution" "$E"
GOT=$(printf 'not json at all' | "$LIMIT" >/dev/null 2>&1; echo $?)
[[ "$GOT" == "0" ]] && ok "malformed stdin fails open" "exit 0" || bad "malformed stdin fails open" "exit 0" "exit $GOT"

echo
echo "IT WRITES OUTSIDE THE WORKTREE — B7 paid two otherwise-correct preflight runs for this:"
DEFDIR="$(mktemp -d)"; mkdir -p "$DEFDIR/observatory-run-deadbeef"
( unset AGENT_RUN_STATE_FILE
  TMPDIR="$DEFDIR" CLAUDE_PROJECT_DIR="$DEFDIR/observatory-run-deadbeef" \
    bash -c 'printf "{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"echo x\"}}" | "$0"' "$LIMIT" >/dev/null 2>&1 )
if [[ -f "$DEFDIR/run-state-observatory-run-deadbeef.json" ]]; then
  ok "default path is \$TMPDIR/run-state-<worktree>.json" "outside the worktree"
else bad "default state location" "\$TMPDIR/run-state-observatory-run-deadbeef.json" "not written there"; fi
if find "$DEFDIR/observatory-run-deadbeef" -type f | grep -q .; then
  bad "nothing is written INSIDE the worktree" "no files" "the hook wrote into the repo under test"
else ok "nothing is written INSIDE the worktree" "confirmed empty"; fi
rm -rf "$DEFDIR"

echo
echo "  $PASS of $N cases pass"
rm -rf "$SANDBOX"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
