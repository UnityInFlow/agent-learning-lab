#!/usr/bin/env bash
# Prove that run-b5-batch.sh's guards REFUSE, one case each, WITHOUT spending a benchmark run.
#
# Why this exists: "a control that has never been shown to reject anything is indistinguishable
# from one that rejects nothing" (workspace CLAUDE.md, and the reason every tools/verify-*.sh in
# this repository exists). run-e009.sh — this driver's parent — shipped with no such fixture set,
# so its guards were ShellCheck-clean and never once observed refusing.
#
# B5_GUARDS_ONLY=1 makes the driver run every guard and exit 0 without invoking make. Each case
# below perturbs exactly one registered value through the driver's own override variables and
# asserts the exit code AND that the refusal names the right thing.
#
# Exit 0 all cases behaved · 1 at least one guard did not refuse, or refused for the wrong reason.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

DRIVER="evidence/b05/run-b5-batch.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

# The lock lives in evidence/b05/ and a real batch may hold it. Every case takes its own.
run_case() {
  local name="$1" want_rc="$2" want_text="$3"; shift 3
  local out rc
  # "$@" comes LAST on purpose: `env` lets a later assignment win, so a case that overrides
  # B5_LOCK must be applied after the default or the default would silently clobber it.
  out="$(env B5_LOCK="$TMP/lock.$RANDOM" B5_GUARDS_ONLY=1 B5_CAFFEINATED=1 "$@" \
         "$DRIVER" 2>&1)"; rc=$?
  if [[ "$rc" == "$want_rc" ]] && grep -qF "$want_text" <<<"$out"; then
    echo "  ok   — $name (exit $rc)"; pass=$((pass+1))
  else
    echo "  FAIL — $name: wanted exit $want_rc naming '$want_text', got exit $rc"
    echo "         $(head -3 <<<"$out" | tr '\n' ' ')"
    fail=$((fail+1))
  fi
}

echo "verify-b5-batch-guards: driving $DRIVER with B5_GUARDS_ONLY=1"

# A. the happy path — every guard passes and NOTHING is run.
run_case "A: the registered configuration passes all guards and runs nothing" 0 \
  "GUARDS ONLY" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS

run_case "A2: the same on BE-004" 0 \
  "GUARDS ONLY" BENCHMARK=BE-004 EXPERIMENT_KEY=EXP-VERIFY-GUARDS

# B. an unknown benchmark is refused rather than defaulted.
run_case "B: an unknown BENCHMARK is refused, not defaulted" 1 \
  "must be BE-003 or BE-004" BENCHMARK=BE-999 EXPERIMENT_KEY=EXP-VERIFY-GUARDS

# C. the treatment moved — the overlay's sha is not the registered one.
run_case "C: a changed overlay sha stops the batch and names both shas" 1 \
  "the treatment moved" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B5_EXPECT_OVERLAY_SHA=0000000000000000000000000000000000000000000000000000000000000000

# D. the overlay is not one file — a second file is how a single-agent overlay becomes a split.
mkdir -p "$TMP/two/.claude/agents"
cp build/customizations/phases-v1.0/.claude/agents/backend-feature-phases.md "$TMP/two/.claude/agents/"
echo "second" > "$TMP/two/.claude/agents/intruder.md"
run_case "D: a second file in the overlay is refused and counted" 1 \
  "phases-v1.0 is exactly one agent definition" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  "B5_OVERLAY_DIR=$TMP/two"

# E. the overlay's one file is not the agent definition the runner will look for.
mkdir -p "$TMP/wrongname/.claude/agents"
echo "x" > "$TMP/wrongname/.claude/agents/not-the-one.md"
run_case "E: the one file having the wrong path is refused" 1 \
  "is not .claude/agents/backend-feature-phases.md" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  "B5_OVERLAY_DIR=$TMP/wrongname"

# F. the benchmark task tree moved under the batch.
run_case "F: a moved task tree stops the batch and names the task" 1 \
  "the task moved" BENCHMARK=BE-004 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B5_EXPECT_TREE=0000000000000000000000000000000000000000

# G. the prediction commit does not exist — prediction-before-run cannot be checked, so nothing runs.
run_case "G: an unknown prediction commit is refused" 1 \
  "is not in this repository" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  PRED_COMMIT=deadbee

# H. the API is a dead port. THIS is the one that would otherwise cost a whole batch: 8081 on
#    this host accepts a connection and answers nothing.
run_case "H: a dead API port is refused before any run is spent" 1 \
  "refusing to spend a batch on a dead endpoint" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B5_API_PORT=8081

# I. a live batch holds the lock — a duplicate run is evidence you cannot delete.
printf '%s' "$$" > "$TMP/held.lock"
run_case "I: a lock held by a LIVE pid refuses with exit 4" 4 \
  "A batch is already running under pid" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS \
  B5_LOCK="$TMP/held.lock"

# J. a lock left by a DEAD pid is cleared rather than blocking forever.
echo "999999" > "$TMP/stale.lock"
run_case "J: a stale lock from a dead pid is cleared and the guards proceed" 0 \
  "stale lock" BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-VERIFY-GUARDS B5_LOCK="$TMP/stale.lock"

echo ""
echo "verify-b5-batch-guards: $pass passed, $fail failed, of $((pass+fail)) registered cases"
[[ "$fail" == "0" ]] || exit 1
