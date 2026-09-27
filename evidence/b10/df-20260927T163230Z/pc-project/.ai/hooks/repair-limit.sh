#!/usr/bin/env bash
#
# repair-limit — B8's ONE executing control, and the recorder that feeds it.
#
# Registered as a PreToolUse hook on `Bash` by ../../.claude/settings.json. Reads the tool
# call on stdin as JSON, fingerprints the command, increments that fingerprint's consecutive
# attempt counter and the run total in the run-state file, and BLOCKS — stderr plus exit 2 —
# when this call would exceed MAX_REPAIR_ATTEMPTS_PER_FAILURE (3) for the fingerprint or
# MAX_TOTAL_REPAIR_ATTEMPTS (7) for the run. Those two constants are the build spec's, at
# businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md:103-104.
#
# WHY THIS IS PreToolUse AND NOT PostToolUse, twice over, both measured rather than assumed:
#
#   1. PostToolUse exit 2 DOES NOT ENFORCE. phases/05a-guardrails/README.md:58-60 —
#      "PostToolUse merely shows stderr because the tool already ran". A limit built there is
#      L3 wearing L2's clothes.
#   2. PostToolUse on `Bash` NEVER FIRES FOR A FAILING COMMAND AT ALL. Probed 2026-09-15
#      before this file was written: 6 of 6 successes fired it, 0 of 6 failures did, two-sided
#      Fisher p = 0.0022, and `tool_response` carries no exit code either — its keys are
#      {stdout, stderr, interrupted, isImage, noOutputExpected}. Evidence and payloads:
#      evidence/b08/hook-event-probe-20260915T153209Z/README.md.
#      So a PostToolUse recorder of FAILING commands would have reported 0 on every run of
#      both arms, and that zero would have read as "the model does not fail this task".
#
# HENCE THE COUNTER DOES NOT COUNT FAILURES. It cannot: no event carries one. It counts
# REPEAT ATTEMPTS AT THE SAME FINGERPRINT, and repair-record.sh (PostToolUse) clears a
# fingerprint when it succeeds. That is a rule over facts the record already holds, needing no
# exit code and no vocabulary — the same shape as Track A's BLOCKED rule.
#
# THE STATE FILE IS WRITTEN OUTSIDE THE WORKTREE, and that is not a detail. B7's preflight
# pair 2077432c and 88b861f3 SOLVED their tasks and were scored exit 21, "unrelated production
# files changed", where the single unrelated file was the guardrail's own log
# (experiments/E-016-verification-policies-BE004.md:227-237). The evaluator's ignore pattern is
# a REGISTERED VARIABLE, so teaching it to ignore .agent/ is not available and is not
# attempted. `.agent/run-state.json` stays the documented production path and is what the
# schema is named for; here the same file lives under $TMPDIR with the run in its own name.
#
# THE FILE IS WRITTEN ON EVERY CALL, ALLOW OR BLOCK, and that is B7's rule inherited: a hook
# that writes only on the interesting path is indistinguishable from a hook that never ran.
# It is also the ONLY per-run delivery proof available — run-agent.sh:625-629 computes
# instructionsHash, skillsHash and agentHash and no hook hash at all.
#
# EXIT CODES:
#   0   allow — the tool call proceeds
#   2   BLOCK — the tool call does not happen and stderr is fed back to the model
#   any other   NON-BLOCKING ERROR; THE CALL PROCEEDS. So every internal failure below is
#               fail-OPEN and is recorded as its own decision, so that a run whose limiter
#               silently died is afterwards distinguishable from one that allowed everything.
set -uo pipefail

MAX_PER_FINGERPRINT=3
MAX_TOTAL=7

STATE="${AGENT_RUN_STATE_FILE:-${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}/run-state-$(basename "${CLAUDE_PROJECT_DIR:-unknown}").json}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# A fingerprint is the command text with volatile parts flattened, so that `./mvnw test` run
# three times is one fingerprint and `echo 1`/`echo 2` are two. Deliberately NOT a semantic
# classifier: phrase-matching an error string is the trap this stop is named after, and it
# failed four times in the observatory (quota->F03, permission block->F05, dropped
# connection->F03, session limit->F03). This matches on what was RUN, not on what came back.
fingerprint() {
  printf '%s' "$1" \
    | tr '\n' ' ' \
    | sed -e 's/[[:space:]][[:space:]]*/ /g' -e 's/^ //' -e 's/ $//' \
    | shasum -a 256 | cut -c1-16
}

# Bootstrap: the schema, written whole on first touch so that a reader never meets a partial
# file. `handoff` is AUTHOR DECISION 11 ITEM 7 and is RESERVED FOR B8a — nothing at this stop
# executes on it, which makes it L3 (data), not a control. It is written unconditionally
# because item 7 is the only item in that decision with a deadline, and this is the deadline.
init_state() {
  cat > "$STATE" <<JSON
{
  "schemaVersion": "b8-v1.1",
  "runStatePath": ".agent/run-state.json",
  "worktree": "${CLAUDE_PROJECT_DIR:-unknown}",
  "startedAt": "$(now)",
  "updatedAt": "$(now)",
  "phase": "unknown",
  "goal": null,
  "affectedFiles": [],
  "lastAttempt": null,
  "repairAttemptsByFingerprint": {},
  "totalRepairAttempts": 0,
  "blocks": [],
  "limits": { "maxRepairAttemptsPerFailure": $MAX_PER_FINGERPRINT, "maxTotalRepairAttempts": $MAX_TOTAL },
  "handoff": {
    "reserved": "B8a — author decision 11 item 7. Nothing at stop 17 reads or writes these fields; they are L3 data awaiting a consumer.",
    "fromAgent": null,
    "toAgent": null,
    "delivered": null,
    "remaining": null
  },
  "hookExecutions": []
}
JSON
}

fail_open() {  # fail_open <reason>
  # Record into the state file if we can; if we cannot, there is nowhere else to go and the
  # call still proceeds, because exit != 0,2 is non-blocking and pretending otherwise would
  # be a lie about the layer.
  if [[ -w "$STATE" ]] && command -v jq >/dev/null 2>&1; then
    tmp="${STATE}.tmp.$$"
    jq --arg ts "$(now)" --arg r "$1" \
       '.updatedAt=$ts | .hookExecutions += [{"hook":"repair-limit","ts":$ts,"decision":"error","reason":$r}]' \
       "$STATE" > "$tmp" 2>/dev/null && mv "$tmp" "$STATE"
  fi
  exit 0
}

IN="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0   # nowhere to record it; fail open, silently and honestly
[[ -f "$STATE" ]] || init_state
[[ -f "$STATE" ]] || exit 0

CMD="$(printf '%s' "$IN" | jq -r '.tool_input.command // ""' 2>/dev/null)"
[[ -n "$CMD" ]] || fail_open "no-command-in-tool-input"

FP="$(fingerprint "$CMD")"
[[ -n "$FP" ]] || fail_open "fingerprint-failed"

PRIOR="$(jq -r --arg fp "$FP" '.repairAttemptsByFingerprint[$fp] // 0' "$STATE" 2>/dev/null)"
TOTAL="$(jq -r '.totalRepairAttempts // 0' "$STATE" 2>/dev/null)"
[[ "$PRIOR" =~ ^[0-9]+$ ]] || fail_open "unreadable-fingerprint-counter"
[[ "$TOTAL" =~ ^[0-9]+$ ]] || fail_open "unreadable-total-counter"

# PRIOR is the number of attempts ALREADY made at this fingerprint since its last success.
# This call would be attempt PRIOR+1. A repeat is any attempt after the first, so this call
# adds to the repair total exactly when PRIOR >= 1.
ATTEMPT=$(( PRIOR + 1 ))
NEW_TOTAL="$TOTAL"; [[ "$PRIOR" -ge 1 ]] && NEW_TOTAL=$(( TOTAL + 1 ))

DECISION=allow; REASON="attempt-${ATTEMPT}-of-${MAX_PER_FINGERPRINT}"
if [[ "$ATTEMPT" -gt "$MAX_PER_FINGERPRINT" ]]; then
  DECISION=block; REASON="fingerprint-limit: attempt ${ATTEMPT} exceeds ${MAX_PER_FINGERPRINT}"
elif [[ "$NEW_TOTAL" -gt "$MAX_TOTAL" ]]; then
  DECISION=block; REASON="total-limit: repair attempt ${NEW_TOTAL} exceeds ${MAX_TOTAL}"
fi

tmp="${STATE}.tmp.$$"
if [[ "$DECISION" == block ]]; then
  # A blocked call did not run, so it does not increment the counters it was refused by.
  # Incrementing here would let one refusal push the total past the ceiling on its own and
  # make the next refusal unattributable.
  jq --arg ts "$(now)" --arg fp "$FP" --arg cmd "$CMD" --arg r "$REASON" \
     '.updatedAt=$ts
      | .blocks += [{"ts":$ts,"fingerprint":$fp,"command":$cmd,"reason":$r}]
      | .hookExecutions += [{"hook":"repair-limit","ts":$ts,"decision":"block","fingerprint":$fp,"reason":$r}]' \
     "$STATE" > "$tmp" 2>/dev/null && mv "$tmp" "$STATE"
  cat >&2 <<MSG
BLOCKED by the repair limit: ${REASON}.

This exact command has already been attempted ${PRIOR} time(s) since it last succeeded, and
the run's repair budget is ${MAX_PER_FINGERPRINT} attempts per failing command and ${MAX_TOTAL}
in total. Re-running it unchanged is refused.

Do one of these instead: change the command, fix the underlying cause, or stop and report what
is blocking you and what you have already tried. Do not retry this command as it stands.
MSG
  exit 2
fi

jq --arg ts "$(now)" --arg fp "$FP" --arg cmd "$CMD" --arg r "$REASON" \
   --argjson attempt "$ATTEMPT" --argjson total "$NEW_TOTAL" \
   '.updatedAt=$ts
    | .repairAttemptsByFingerprint[$fp] = $attempt
    | .totalRepairAttempts = $total
    | .lastAttempt = {"ts":$ts,"fingerprint":$fp,"command":$cmd,"attempt":$attempt}
    | .hookExecutions += [{"hook":"repair-limit","ts":$ts,"decision":"allow","fingerprint":$fp,"reason":$r}]' \
   "$STATE" > "$tmp" 2>/dev/null && mv "$tmp" "$STATE"
exit 0
