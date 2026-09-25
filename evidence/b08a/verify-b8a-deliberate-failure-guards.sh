#!/usr/bin/env bash
#
# verify-b8a-deliberate-failure-guards — the fixture set for run-b8a-deliberate-failure.sh.
#
# §4 step 4: "a control that has never been shown to reject anything is indistinguishable from
# one that rejects nothing". Every guard below is pointed at a deliberately-broken COPY of the
# overlay and must return its registered exit code. NO RUN IS MADE AND NO MONEY IS SPENT — every
# case runs in DF_GUARDS_ONLY or DF_CEILING_ONLY mode, both of which exit before run-agent.sh.
#
# Case D is the one that matters most: it points the driver at the REGISTERED treatment overlay
# (whose orchestrator CAN delegate) and requires a refusal. Without it, a mistyped path would run
# the registered treatment under the probe key and its delegations would read as a refutation of
# the deliberate failure — the single worst error available at this step.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b08a/run-b8a-deliberate-failure.sh"
GOOD="$LAB/build/customizations/b8a-pipeline-v1.0-notask"
REGISTERED="$LAB/build/customizations/b8a-pipeline-v1.0"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

# run <name> <expected exit> <env assignments...> -- runs the driver in a guards-only mode
run() {
  local name="$1" want="$2"; shift 2
  local got out
  out="$(env "$@" DF_LOCK="$TMP/lock-$RANDOM" "$DRIVER" 2>&1)"; got=$?
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %-44s exit %s\n' "$name" "$got"; PASS=$((PASS+1))
  else
    printf 'FAIL  %-44s exit %s, wanted %s\n' "$name" "$got" "$want"
    printf '      %s\n' "$(printf '%s' "$out" | tail -1)"; FAIL=$((FAIL+1))
  fi
}

copy() { local d="$TMP/$1"; mkdir -p "$d/.claude/agents"; cp "$GOOD"/.claude/agents/*.md "$d/.claude/agents/"; echo "$d"; }

A="$GOOD"
B="$(copy missing-specialist)";  rm "$B/.claude/agents/verifier.md"
C="$(copy wrong-hash)";          printf '\nextra line\n' >> "$C/.claude/agents/orchestrator.md"
E="$(copy specialist-edited)";   printf '\nextra line\n' >> "$E/.claude/agents/planner.md"
F="$(copy carries-claudemd)";    printf 'x\n' > "$F/CLAUDE.md"
G="$(copy carries-skill)";       mkdir -p "$G/.claude/skills/s"; printf 'x\n' > "$G/.claude/skills/s/SKILL.md"
H="$(copy pins-model)";          printf 'model: claude-opus-4-6\n' >> "$H/.claude/agents/verifier.md"

echo "verify-b8a-deliberate-failure-guards: guards-only and ceiling-only; NO RUN IS MADE"
echo
run "A happy path (the registered broken overlay)" 0 DF_GUARDS_ONLY=1 DF_OVERLAY="$A"
run "B a specialist file is missing"               6 DF_GUARDS_ONLY=1 DF_OVERLAY="$B"
run "C the orchestrator is not the registered file" 6 DF_GUARDS_ONLY=1 DF_OVERLAY="$C"
run "D the orchestrator CAN delegate (registered)" 6 DF_GUARDS_ONLY=1 DF_OVERLAY="$REGISTERED" \
    DF_EXPECT_AGENT_HASH="sha256:1f27323694e579ec11dbca026bfbb326"
run "E a specialist differs from the measured one" 6 DF_GUARDS_ONLY=1 DF_OVERLAY="$E"
run "F the overlay carries a CLAUDE.md"            6 DF_GUARDS_ONLY=1 DF_OVERLAY="$F"
run "G the overlay carries a SKILL.md"             6 DF_GUARDS_ONLY=1 DF_OVERLAY="$G"
run "H an agent file pins a model"                 6 DF_GUARDS_ONLY=1 DF_OVERLAY="$H"
run "I the API does not answer"                    7 DF_GUARDS_ONLY=1 DF_OVERLAY="$A" DF_API="http://127.0.0.1:1"
run "K the ceiling fires at exactly 4.00"         11 DF_CEILING_ONLY=1 DF_OVERLAY="$A" DF_TEST_COST=4.00
run "L the ceiling does not fire at 3.99"          0 DF_CEILING_ONLY=1 DF_OVERLAY="$A" DF_TEST_COST=3.99

# J — the lock. Held by a live process, so it must be tested against a real pid.
LK="$TMP/held.lock"; sleep 60 & held=$!; echo "$held" > "$LK"
out="$(env DF_GUARDS_ONLY=1 DF_OVERLAY="$A" DF_LOCK="$LK" "$DRIVER" 2>&1)"; got=$?
kill "$held" 2>/dev/null; wait "$held" 2>/dev/null
if [[ "$got" == 8 ]]; then printf 'ok    %-44s exit 8\n' "J another instance holds the lock"; PASS=$((PASS+1))
else printf 'FAIL  %-44s exit %s, wanted 8\n' "J another instance holds the lock" "$got"; FAIL=$((FAIL+1)); fi

echo
echo "verify-b8a-deliberate-failure-guards: $PASS passed, $FAIL failed."
[[ "$FAIL" -eq 0 ]] || exit 1
