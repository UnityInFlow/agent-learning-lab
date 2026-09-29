#!/usr/bin/env bash
#
# verify-retrieval-budget — the fixture set for B11's first executing control,
# build/customizations/agent-v1.2-efficiency/.ai/hooks/retrieval-budget.sh.
#
# IT EXISTS BECAUSE THE BATCH CANNOT ANSWER THE GATE CLAUSE, and this is the third stop in a row
# where that has been true. `build/README.md#b11` asks for fewer unnecessary tool calls; the
# batch measures whether a refusal HAPPENED, never whether a refusal WORKS. If the model happens
# to stay inside five searches on all ten treated runs, the hook logs ten allows and refuses
# nothing, and a control never shown to reject anything is indistinguishable from one that
# rejects nothing. THIS is the evidence that it refuses.
#
# Cases marked NEGATIVE CONTROL are the ones a naive implementation gets wrong — and two of them
# are the ones that would quietly break a benchmark run rather than quietly weaken a control:
# a hook that keeps enforcing "before design" limits after the first edit, and a hook that blocks
# instead of failing open when its own policy file is unreadable.
#
# It exercises THE REGISTERED FILE, never a copy.
#
# Usage: tools/verify-retrieval-budget.sh      (exit 0 = every case behaved as specified)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
OVERLAY="$PWD/build/customizations/agent-v1.2-efficiency"
HOOK="$OVERLAY/.ai/hooks/retrieval-budget.sh"
POLICY="$OVERLAY/.ai/policies/retrieval-budget.yaml"
[[ -x "$HOOK" ]]   || { echo "retrieval-budget.sh not found or not executable: $HOOK" >&2; exit 30; }
[[ -r "$POLICY" ]] || { echo "the policy file is missing: $POLICY" >&2; exit 30; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-62s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-62s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
export CLAUDE_PROJECT_DIR="$SANDBOX/observatory-run-fixture"
mkdir -p "$CLAUDE_PROJECT_DIR"
export AGENT_BUDGET_LOG="$SANDBOX/budget-log.jsonl"
export AGENT_BUDGET_STATE="$SANDBOX/budget-state.json"
export AGENT_BUDGET_POLICY="$POLICY"
reset() { rm -f "$AGENT_BUDGET_LOG" "$AGENT_BUDGET_STATE"; }

call() {  # call <tool> <json tool_input> ; prints nothing, returns the hook's exit code
  printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":%s}' "$1" "$2" \
    | "$HOOK" >/dev/null 2>&1
}
call_stderr() {  # same, but prints the hook's stderr
  { printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":%s}' "$1" "$2" \
      | "$HOOK" >/dev/null; } 2>&1
}
readjson() { jq -Rn --arg p "$1" '{file_path:$p}'; }
loglines() { [[ -f "$AGENT_BUDGET_LOG" ]] && grep -c . "$AGENT_BUDGET_LOG" || echo 0; }
lastdec()  { [[ -f "$AGENT_BUDGET_LOG" ]] && tail -1 "$AGENT_BUDGET_LOG" | jq -r '.decision' || echo NOFILE; }

echo "verify-retrieval-budget: the five searches, the fifteen files, the log rule, and failing open"

# --- 1. the search limit: five allowed, the sixth refused ------------------------------------
reset
sr=0
for i in 1 2 3 4 5; do call Grep "{\"pattern\":\"p$i\"}" || sr=1; done
[[ "$sr" == 0 ]] && ok "searches 1-5 in the design phase" "exit 0 each" || bad "searches 1-5 in the design phase" "exit 0 each" "a non-zero"
call Grep '{"pattern":"p6"}'; rc=$?
[[ "$rc" == 2 ]] && ok "the 6th search before any edit" "exit 2" || bad "the 6th search before any edit" "exit 2" "$rc"
msg="$(call_stderr Grep '{"pattern":"p7"}')"
grep -q 'retrieval budget' <<<"$msg" && ok "the refusal names the budget on stderr" "named" || bad "the refusal names the budget" "the phrase 'retrieval budget'" "$(head -c 60 <<<"$msg")"
grep -q 'Do not route around this' <<<"$msg" && ok "the refusal forbids the obvious workaround" "present" || bad "the refusal forbids the workaround" "the sentence" "absent"

# --- 2. NEGATIVE CONTROL: the search limit STOPS at the first edit ---------------------------
call Edit '{"file_path":"/tmp/x.kt"}'; rc=$?
[[ "$rc" == 0 ]] && ok "an Edit is never refused by THIS hook" "exit 0" || bad "an Edit through this hook" "exit 0" "$rc"
call Grep '{"pattern":"p8"}'; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a search AFTER the first edit" "exit 0" || bad "a search after the first edit" "exit 0 — the limit is 'before design'" "$rc"
ph="$(jq -r '.phase' "$AGENT_BUDGET_STATE")"
[[ "$ph" == implementation ]] && ok "the Edit moved the phase" "implementation" || bad "phase after an Edit" "implementation" "$ph"

# --- 3. the distinct-file limit: fifteen allowed, the sixteenth refused ----------------------
reset
fr=0
for i in $(seq 1 15); do call Read "$(readjson "/tmp/f$i.kt")" || fr=1; done
[[ "$fr" == 0 ]] && ok "15 distinct files in the design phase" "exit 0 each" || bad "15 distinct files" "exit 0 each" "a non-zero"
call Read "$(readjson /tmp/f16.kt)"; rc=$?
[[ "$rc" == 2 ]] && ok "the 16th DISTINCT file before any edit" "exit 2" || bad "the 16th distinct file" "exit 2" "$rc"

# --- 4. NEGATIVE CONTROL: re-reading a file already opened is not a new file -----------------
call Read "$(readjson /tmp/f3.kt)"; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: re-read of an already-opened file at the cap" "exit 0" || bad "re-read at the cap" "exit 0 — the cap counts DISTINCT files" "$rc"
nf="$(jq -r '.filesRead | length' "$AGENT_BUDGET_STATE")"
[[ "$nf" == 15 ]] && ok "the re-read did not grow the distinct-file set" "15" || bad "distinct files after a re-read" "15" "$nf"

# --- 5. the log rule, in both phases, and its one exemption ---------------------------------
reset
call Read "$(readjson /tmp/build.log)"; rc=$?
[[ "$rc" == 2 ]] && ok "an unbounded Read of a .log file" "exit 2" || bad "unbounded .log read" "exit 2" "$rc"
call Read "$(readjson /tmp/events.jsonl)"; rc=$?
[[ "$rc" == 2 ]] && ok "an unbounded Read of a .jsonl file" "exit 2" || bad "unbounded .jsonl read" "exit 2" "$rc"
call Read "$(readjson /tmp/target/surefire-reports/TEST-x.txt)"; rc=$?
[[ "$rc" == 2 ]] && ok "an unbounded Read under surefire-reports/" "exit 2" || bad "unbounded surefire read" "exit 2" "$rc"
call Read '{"file_path":"/tmp/build.log","limit":120}'; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a BOUNDED read of the same .log" "exit 0" || bad "bounded .log read" "exit 0 — a limit is the whole point" "$rc"
call Edit '{"file_path":"/tmp/x.kt"}' >/dev/null 2>&1
call Read "$(readjson /tmp/other.log)"; rc=$?
[[ "$rc" == 2 ]] && ok "NEGATIVE CONTROL: the log rule survives the phase change" "exit 2" || bad "log rule after the first edit" "exit 2 — it is not a 'before design' limit" "$rc"

# --- 6. the log is written on EVERY call, allow and block alike ------------------------------
reset
call Grep '{"pattern":"a"}' ; a="$(loglines)"; d1="$(lastdec)"
[[ "$a" == 1 && "$d1" == allow ]] && ok "an ALLOW writes its own log line" "1 line, allow" || bad "log after one allow" "1 line and decision=allow" "$a/$d1"
for i in 2 3 4 5 6; do call Grep "{\"pattern\":\"a$i\"}"; done
b="$(loglines)"; d2="$(lastdec)"
[[ "$b" == 6 && "$d2" == block ]] && ok "a BLOCK writes its own log line too" "6 lines, block" || bad "log after the refusal" "6 lines and decision=block" "$b/$d2"
if jq -e . "$AGENT_BUDGET_LOG" >/dev/null 2>&1 || ! grep -qv '^{' "$AGENT_BUDGET_LOG"; then
  ok "every log line parses as JSON" "parses"
else bad "log line JSON" "each line an object" "a line that is not"; fi
tgt="$(grep '"decision":"block"' "$AGENT_BUDGET_LOG" | tail -1 | jq -r '.target')"
[[ "$tgt" == a6 ]] && ok "the log records the TARGET the telemetry deletes" "a6" || bad "target on a blocked search" "a6" "$tgt"

# --- 7. NEGATIVE CONTROL: an unreadable policy file FAILS OPEN ------------------------------
# A hook that cannot read its own limits and blocks anyway would fail a benchmark run for an
# infrastructure fault, and the run would be scored as the model's failure. Fail open, and say so.
reset
AGENT_BUDGET_POLICY="$SANDBOX/not-a-file.yaml" call Grep '{"pattern":"z"}'; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: unreadable policy" "exit 0, fails OPEN" || bad "unreadable policy" "exit 0" "$rc"
AGENT_BUDGET_POLICY="$SANDBOX/not-a-file.yaml" call Grep '{"pattern":"z2"}' >/dev/null 2>&1
d="$(grep -c '"decision":"error"' "$AGENT_BUDGET_LOG")"
[[ "$d" -ge 1 ]] && ok "the fail-open is RECORDED, not silent" "$d error line(s)" || bad "fail-open record" "at least one decision=error" "$d"

# --- 8. a policy whose value is not an integer is treated as unreadable ----------------------
reset
sed 's/    value: 5/    value: five/' "$POLICY" > "$SANDBOX/bad.yaml"
AGENT_BUDGET_POLICY="$SANDBOX/bad.yaml" call Grep '{"pattern":"q"}'; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a non-integer limit" "exit 0, fails OPEN" || bad "non-integer limit" "exit 0" "$rc"

# --- 9. a tool the hook is not registered for is passed through -----------------------------
reset
call WebFetch '{"url":"https://example.com"}'; rc=$?
[[ "$rc" == 0 ]] && ok "an unbudgeted tool" "exit 0" || bad "an unbudgeted tool" "exit 0" "$rc"

rm -rf "$SANDBOX"
echo ""
printf 'verify-retrieval-budget: %s passed, %s failed, %s total.\n' "$PASS" "$FAIL" "$N"
[[ "$FAIL" == 0 ]] || exit 1
echo "verify-retrieval-budget: all $N cases behaved as specified."
