#!/usr/bin/env bash
#
# repair-record — the SUCCESS ORACLE. A recorder, never a control.
#
# Registered as a PostToolUse hook on `Bash` by ../../.claude/settings.json. It clears the
# consecutive-attempt counter for the fingerprint of the command that just ran, and it ALWAYS
# EXITS 0.
#
# IT IS NOT AN ENFORCER AND IT IS NOT A FAILURE RECORDER, and neither is a style choice:
#
#   * It cannot enforce. phases/05a-guardrails/README.md:58-60 — "PostToolUse merely shows
#     stderr because the tool already ran". An exit 2 here changes nothing that happened.
#   * It cannot see a failure. Probed 2026-09-15 before this file was written: PostToolUse on
#     `Bash` fired for 6 of 6 successful commands and 0 of 6 failing ones, two-sided Fisher
#     p = 0.0022. Evidence: evidence/b08/hook-event-probe-20260915T153209Z/README.md.
#
# THOSE TWO FACTS ARE WHAT MAKES IT USEFUL. `tool_response` carries no exit code — its keys
# are {stdout, stderr, interrupted, isImage, noOutputExpected} — but the EVENT'S PRESENCE is
# the signal the payload lacks: if this hook fired for a command, that command succeeded. It
# is the only success signal a hook has in this runtime.
#
# WITHOUT IT THE LIMIT WOULD BE WRONG RATHER THAN MERELY BLIND. A fingerprint's counter could
# only ever rise, so a run that legitimately ran `./mvnw test` four times — passing every time
# — would be blocked on the fourth. The build spec's constant is
# MAX_REPAIR_ATTEMPTS_PER_FAILURE, and *per failure* is exactly what this reset buys. That is
# why B8 ships two hooks on two events rather than one: recording a success and refusing a
# repeat are only observable at different moments.
#
# EXIT CODE: 0, always, on every path including its own internal failures.
set -uo pipefail

STATE="${AGENT_RUN_STATE_FILE:-${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}/run-state-$(basename "${CLAUDE_PROJECT_DIR:-unknown}").json}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# Byte-identical to repair-limit.sh's. A second, drifting copy of the rule is a rule that can
# disagree with the one it claims to mirror; verify-repair-limit.sh asserts the two agree.
fingerprint() {
  printf '%s' "$1" \
    | tr '\n' ' ' \
    | sed -e 's/[[:space:]][[:space:]]*/ /g' -e 's/^ //' -e 's/ $//' \
    | shasum -a 256 | cut -c1-16
}

IN="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
[[ -f "$STATE" ]] || exit 0    # no state file means repair-limit.sh never ran; nothing to clear

CMD="$(printf '%s' "$IN" | jq -r '.tool_input.command // ""' 2>/dev/null)"
[[ -n "$CMD" ]] || exit 0
FP="$(fingerprint "$CMD")"
[[ -n "$FP" ]] || exit 0

tmp="${STATE}.tmp.$$"
# The fingerprint is DELETED rather than set to 0, so that "present in the map" means "has
# failed at least once since its last success" and a reader cannot confuse a cleared entry
# with a first attempt. totalRepairAttempts is NOT decremented: it is the run's cumulative
# repair budget and a success does not refund it.
jq --arg ts "$(now)" --arg fp "$FP" --arg cmd "$CMD" \
   '.updatedAt=$ts
    | .repairAttemptsByFingerprint = (.repairAttemptsByFingerprint | del(.[$fp]))
    | .hookExecutions += [{"hook":"repair-record","ts":$ts,"decision":"success","fingerprint":$fp,"reason":"postToolUse-fired-therefore-exit-0"}]' \
   "$STATE" > "$tmp" 2>/dev/null && mv "$tmp" "$STATE"
exit 0
