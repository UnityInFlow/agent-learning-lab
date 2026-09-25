#!/usr/bin/env bash
#
# Prove that run-b8a-batch.sh's guards and stop rules REFUSE, one case each, WITHOUT spending a
# benchmark run. A control that has never been shown to reject anything is indistinguishable
# from one that rejects nothing, and this project has paid for that three times.
#
# HOW: run-b8a-batch.sh runs every file-and-endpoint guard and exits 0 under B8A_GUARDS_ONLY=1,
# and evaluates its two stop rules and nothing else under B8A_STOPRULE_ONLY=1. Each case below
# perturbs EXACTLY ONE registered value and asserts BOTH the exit code AND that the refusal
# names the right thing -- an exit code alone would pass on a script that refused for an
# unrelated reason.
#
# WHAT THIS CANNOT PROVE, said plainly rather than left for a reader to discover: exit 9, the
# claude-version drift abort, needs the CLI to move between two real runs and has no fixture
# here. evidence/b08/verify-b8-batch-guards.sh has the same gap for the same reason.
#
# THE STOP RULES ARE PROVED THROUGH THE SCRIPT'S OWN FUNCTIONS. ceiling_reached() and
# row0a_ends_step() are defined once and called both by the batch loop and by stop-rule-only
# mode, so cases L-P exercise the expression the batch actually runs. A fixture that
# re-implemented the comparison would be testing a copy of the control.
#
# Exit 0 all cases behaved · 1 at least one guard did not refuse, or refused for the wrong reason.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b08a/run-b8a-batch.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

run_case() {  # run_case <name> <want_rc> <want_text> [VAR=value ...]
  local name="$1" want_rc="$2" want_text="$3"; shift 3
  local out rc
  out="$(env "$@" "$DRIVER" 2>&1)"; rc=$?
  if [[ "$rc" -eq "$want_rc" ]] && grep -qF "$want_text" <<<"$out"; then
    echo "  ok   — $name (exit $rc)"; pass=$((pass+1))
  else
    echo "  FAIL — $name: wanted exit $want_rc naming '$want_text', got exit $rc"
    tail -4 <<<"${out//$'\n'/$'\n'}"
    fail=$((fail+1))
  fi
}

# A clean copy of the registered overlay that cases may break one field of at a time.
copy_overlay() {  # copy_overlay <name> -> prints the path
  local d="$TMP/$1"; rm -rf "$d"; mkdir -p "$d"
  cp -R "$LAB/build/customizations/b8a-pipeline-v1.0/." "$d/"
  echo "$d"
}

echo "verify-b8a-batch-guards: proving every reachable exit code"

# --- A. THE HAPPY PATH. If this ever fails, every refusal below proves nothing, because a
# script that refuses everything would pass all of them.
run_case "A: the registered configuration passes every guard and runs nothing" 0 \
  "guards-only: every guard passed and NOTHING was run" \
  B8A_GUARDS_ONLY=1

# --- B, C. exit 7 — the endpoints, probed and never inherited.
run_case "B: a dead API port is refused, naming the code it answered" 7 \
  "ABORT: API" \
  B8A_GUARDS_ONLY=1 B8A_API=http://127.0.0.1:59999
run_case "C: a dead OTLP endpoint is refused" 7 \
  "ABORT: OTLP" \
  B8A_GUARDS_ONLY=1 B8A_OTLP=http://localhost:59998

# --- D–J. exit 6 — the one-variable guards on the overlay itself.
d="$(copy_overlay missing-specialist)"; rm -f "$d/.claude/agents/planner.md"
run_case "D: a missing SPECIALIST is refused — the three files no hash sees" 6 \
  "missing .claude/agents/planner.md" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d"

d="$(copy_overlay drifted-orchestrator)"; printf '\nan extra line\n' >> "$d/.claude/agents/orchestrator.md"
run_case "E: an orchestrator that drifted from its registered sha is refused" 6 \
  "is not the registered file" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d"

d="$(copy_overlay no-task)"
sed -i '' 's/^tools: Read, Grep, Glob, Task$/tools: Read, Grep, Glob/' "$d/.claude/agents/orchestrator.md"
run_case "F: an orchestrator whose tools: has no Task is refused — the deliberate failure's own shape" 6 \
  "does not contain Task" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d" \
  B8A_EXPECT_AGENT_HASH="sha256:$(shasum -a 256 "$d/.claude/agents/orchestrator.md" | cut -c1-32)"

d="$(copy_overlay stray-claudemd)"; echo "a rule" > "$d/CLAUDE.md"
run_case "G: an overlay carrying a CLAUDE.md is refused — instructionsHash would not be null" 6 \
  "carries CLAUDE.md" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d"

d="$(copy_overlay stray-skill)"; mkdir -p "$d/.claude/skills/x"; echo "---" > "$d/.claude/skills/x/SKILL.md"
run_case "H: an overlay carrying a SKILL.md is refused — Q7 declined a skill" 6 \
  "carries a SKILL.md" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d"

d="$(copy_overlay stray-hooks)"; mkdir -p "$d/.ai/hooks"; echo "#!/bin/sh" > "$d/.ai/hooks/x.sh"
run_case "I: an overlay carrying a hooks directory is refused — a second executed control" 6 \
  "carries a hooks directory" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d"

d="$(copy_overlay pinned-model)"
sed -i '' 's/^tools: Read, Grep, Glob$/tools: Read, Grep, Glob\nmodel: claude-opus-4-6/' "$d/.claude/agents/planner.md"
run_case "J: an agent file that pins model: is refused — a fifth variable" 6 \
  "sets model:" \
  B8A_GUARDS_ONLY=1 B8A_OVERLAY_T="$d"

# --- K. exit 8 — the pid lock, and a stale lock that must NOT block.
live_lock="$TMP/live.lock"; echo $$ > "$live_lock"
run_case "K: a live lock refuses a second batch" 8 \
  "Refusing to start a second one" \
  B8A_GUARDS_ONLY=1 B8A_LOCK="$live_lock"
stale_lock="$TMP/stale.lock"; echo 999999 > "$stale_lock"
run_case "K2: a stale lock (dead pid) does NOT block a batch" 0 \
  "guards-only: every guard passed" \
  B8A_GUARDS_ONLY=1 B8A_LOCK="$stale_lock"

# --- L–P. exits 10 and 11 — the two stop rules, through the batch's own functions.
run_case "L: row 0a on 2 treated runs ends the step" 10 \
  "ROW 0a on 2 treated runs" \
  B8A_STOPRULE_ONLY=1 B8A_TEST_ROW0A=2
run_case "M: row 0a on 1 treated run does NOT end the step" 0 \
  "neither rule fires" \
  B8A_STOPRULE_ONLY=1 B8A_TEST_ROW0A=1
run_case "N: the \$9.70 ceiling fires AT the ceiling, not only above it" 11 \
  "COST CEILING" \
  B8A_STOPRULE_ONLY=1 B8A_TEST_COST=9.70
run_case "O: one cent under the ceiling does NOT stop the batch" 0 \
  "neither rule fires" \
  B8A_STOPRULE_ONLY=1 B8A_TEST_COST=9.69
run_case "P: row 0a is evaluated BEFORE the ceiling — a broken arm is not reported as a budget stop" 10 \
  "ROW 0a" \
  B8A_STOPRULE_ONLY=1 B8A_TEST_ROW0A=2 B8A_TEST_COST=99.00

echo ""
echo "verify-b8a-batch-guards: $pass passed, $fail failed."
[[ "$fail" -eq 0 ]] || exit 1
echo "verify-b8a-batch-guards: all $pass cases behaved as specified."
