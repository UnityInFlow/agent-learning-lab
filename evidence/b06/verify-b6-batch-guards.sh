#!/usr/bin/env bash
# Prove that run-b6-batch.sh's guards REFUSE, one case each, WITHOUT spending a benchmark run.
#
# Same reason as evidence/b05/verify-b5-batch-guards.sh: "a control that has never been shown to
# reject anything is indistinguishable from one that rejects nothing". B6_GUARDS_ONLY=1 makes the
# driver run every guard and exit 0 without invoking make. Each case below perturbs exactly one
# registered value through the driver's own override variables and asserts the exit code AND that
# the refusal names the right thing.
#
# The cases that matter most here are C and D: this stop's whole design rests on the two arms
# carrying the SAME agent and differing ONLY by the skill directory, and on the carrier actually
# declaring `Skill`. A driver that would run a batch with those broken is a driver that would
# produce a confident number about the wrong comparison.
#
# Exit 0 all cases behaved · 1 at least one guard did not refuse, or refused for the wrong reason.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

DRIVER="evidence/b06/run-b6-batch.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

run_case() {
  local name="$1" want_rc="$2" want_text="$3"; shift 3
  local out rc
  out="$(env B6_LOCK="$TMP/lock.$RANDOM" B6_GUARDS_ONLY=1 B6_CAFFEINATED=1 "$@" \
         "$DRIVER" 2>&1)"; rc=$?
  if [[ "$rc" == "$want_rc" ]] && grep -qF "$want_text" <<<"$out"; then
    echo "  ok   — $name (exit $rc)"; pass=$((pass+1))
  else
    echo "  FAIL — $name: wanted exit $want_rc naming '$want_text', got exit $rc"
    echo "         $(head -3 <<<"$out" | tr '\n' ' ')"
    fail=$((fail+1))
  fi
}

echo "verify-b6-batch-guards: driving $DRIVER with B6_GUARDS_ONLY=1"

# A. the happy path — every guard passes and NOTHING is run.
run_case "A: the registered configuration passes all guards and runs nothing" 0 \
  "GUARDS ONLY" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS
run_case "A2: the same on BE-004" 0 \
  "GUARDS ONLY" BENCHMARK=BE-004 EXPERIMENT_KEY=EXP-VERIFY-GUARDS

# B. the task must be the registered one.
run_case "B: a moved benchmark tree is refused" 1 \
  "the task moved" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B6_EXPECT_TREE=deadbeef
run_case "B2: an unknown benchmark is refused" 1 \
  "must be BE-003 or BE-004" BENCHMARK=BE-999 EXPERIMENT_KEY=EXP-VERIFY-GUARDS

# C. THE TWO ARMS MUST SHARE AN AGENT. This is the guard the whole stop rests on: if the control
#    carries a different agent, the skill is no longer the only variable and the batch measures
#    two things at once. Pointing the control at phases-v1.0 (the pre-carrier agent) is exactly
#    the mistake a hurried session would make, so that is the fixture.
run_case "C: a control whose agent differs from the treated arm's is refused" 1 \
  "the skill would not be the only variable" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B6_CONTROL_DIR="$PWD/build/customizations/phases-v1.0"
run_case "C2: a moved carrier agent is refused" 1 \
  "the carrier moved" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B6_EXPECT_AGENT_SHA=deadbeef

# D. THE CARRIER MUST DECLARE Skill, and the treatment must be the registered file.
#    Without the first, every treated run would be a second control and the batch would produce a
#    clean, confident null — which is the exact failure the §4 step 5 preflight caught by hand.
run_case "D: a carrier that does not declare Skill is refused" 1 \
  "could never be selected" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B6_TREATED_DIR="$PWD/evidence/b06/fixtures/carrier-no-skill-tool" \
  B6_CONTROL_DIR="$PWD/evidence/b06/fixtures/carrier-no-skill-tool-control" \
  B6_EXPECT_AGENT_SHA=b3450564b6f32d6193e8580db766210e
run_case "D2: a moved skill file is refused" 1 \
  "the treatment moved" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B6_EXPECT_SKILL_SHA=deadbeef

# E. THE CONTROL MUST NOT CARRY A SKILL, and the treated arm must carry exactly one.
run_case "E: a control that carries the skill is refused" 1 \
  "it is not a control" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B6_CONTROL_DIR="$PWD/build/customizations/phases-v1.0-skillcarrier"
run_case "E2: a treated overlay with no skill is refused" 1 \
  "treated overlay holds 1 files" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B6_TREATED_DIR="$PWD/build/customizations/phases-v1.0-skillcarrier-control"

# F. missing overlays, and the dead-endpoint guard.
run_case "F: a missing overlay directory is refused" 1 \
  "overlay directory missing" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B6_TREATED_DIR="$TMP/nope"
run_case "F2: a dead API port is refused before anything is spent" 1 \
  "refusing to spend a batch on a dead endpoint" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B6_API_PORT=1

# G. the lock.
LOCKED="$TMP/held.lock"; echo $$ > "$LOCKED"
run_case "G: a lock held by a LIVE pid refuses a second batch" 4 \
  "REFUSING TO START" \
  BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B6_LOCK="$LOCKED"

echo ""
echo "verify-b6-batch-guards: $pass passed, $fail failed"
[[ "$fail" == "0" ]] || exit 1
