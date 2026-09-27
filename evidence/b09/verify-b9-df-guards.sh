#!/usr/bin/env bash
#
# verify-b9-df-guards.sh — the fixture set for run-b9-deliberate-failure.sh.
#
# "A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing" (§6). The driver's whole job is to refuse the MEASURED overlay, because the
# registered batch driver has been shown NOT to (clause 1). Case A is that refusal and it is the
# reason this file exists.
#
# Every case stops before any run: --guards-only, --plan-only, or a guard that aborts. NOTHING here
# spends a dollar or touches the API.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
DRIVER="evidence/b09/run-b9-deliberate-failure.sh"
MEASURED="$PWD/build/customizations/agent-v1.2-knowledge"
BROKEN="$PWD/build/customizations/agent-v1.2-knowledge-noexec"
SCRATCH="$(mktemp -d)"; trap 'rm -rf "$SCRATCH"' EXIT
PASS=0; FAIL=0

run_case() {  # run_case <label> <expected-exit> <expect-substring-or-EMPTY> -- <env assignments...> -- <args...>
  local label="$1" want="$2" needle="$3"; shift 3
  [[ "$1" == "--" ]] && shift
  local -a envs=() args=()
  while [[ $# -gt 0 && "$1" != "--" ]]; do envs+=("$1"); shift; done
  [[ $# -gt 0 ]] && shift
  args=("$@")
  local out rc
  out="$(env "${envs[@]}" "$DRIVER" "${args[@]}" 2>&1)"; rc=$?
  local ok=1
  [[ "$rc" == "$want" ]] || ok=0
  [[ -z "$needle" ]] || printf '%s' "$out" | grep -q "$needle" || ok=0
  if [[ "$ok" == 1 ]]; then PASS=$((PASS+1)); printf 'PASS  %-58s exit %s\n' "$label" "$rc"
  else FAIL=$((FAIL+1)); printf 'FAIL  %-58s exit %s (wanted %s, needle "%s")\n' "$label" "$rc" "$want" "$needle"
       printf '%s\n' "$out" | sed 's/^/        /' | head -6
  fi
}

# --- A: THE INVERTED GUARD. The measured overlay must be refused. -----------------------------
run_case "A measured overlay (router IS executable) -> refused" 6 "IS EXECUTABLE" \
  -- "B9DF_OVERLAY=$MEASURED" -- --guards-only

# --- B: the break itself passes every guard. ---------------------------------------------------
run_case "B the break passes guards-only" 0 "guards-only: every guard passed" \
  -- "B9DF_OVERLAY=$BROKEN" -- --guards-only

# --- C: a byte changed in the corpus is NOT the break. -----------------------------------------
cp -R "$BROKEN" "$SCRATCH/corpus-moved"
printf '\n# one added comment line\n' >> "$SCRATCH/corpus-moved/.ai/knowledge/index.yaml"
run_case "C corpus sha moved -> refused" 6 "not the registered" \
  -- "B9DF_OVERLAY=$SCRATCH/corpus-moved" -- --guards-only

# --- D: a changed CLAUDE.md is a second variable. ----------------------------------------------
cp -R "$BROKEN" "$SCRATCH/instr-moved"
printf '\nAnd one more sentence.\n' >> "$SCRATCH/instr-moved/CLAUDE.md"
run_case "D CLAUDE.md sha moved -> refused" 6 "not the registered treated" \
  -- "B9DF_OVERLAY=$SCRATCH/instr-moved" -- --guards-only

# --- E: a changed agent file is a third. -------------------------------------------------------
cp -R "$BROKEN" "$SCRATCH/agent-moved"
printf '\n' >> "$SCRATCH/agent-moved/.claude/agents/backend-feature-phases.md"
run_case "E agent file sha moved -> refused" 6 "not the registered sha256" \
  -- "B9DF_OVERLAY=$SCRATCH/agent-moved" -- --guards-only

# --- F: a missing overlay, and a missing router inside one. ------------------------------------
run_case "F overlay directory absent -> exit 1" 1 "no overlay at" \
  -- "B9DF_OVERLAY=$SCRATCH/does-not-exist" -- --guards-only
cp -R "$BROKEN" "$SCRATCH/no-router"; rm -f "$SCRATCH/no-router/.ai/knowledge/router.sh"
run_case "G router file absent -> exit 1" 1 "no router at" \
  -- "B9DF_OVERLAY=$SCRATCH/no-router" -- --guards-only

# --- H: an unknown flag is refused rather than ignored. ----------------------------------------
run_case "H unknown flag -> exit 2" 2 "unknown flag" \
  -- "B9DF_OVERLAY=$BROKEN" -- --n 5

# --- I: an uncomputable ceiling refuses rather than defaulting to zero. ------------------------
# The registered driver's ceiling bug was exactly this: a non-numeric cost summed to 0 and a $0
# ceiling fires on the first pair. Here a non-numeric median must ABORT, not become 0.
run_case "I ceiling from a non-numeric median -> exit 12" 12 "not computable" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_TREATED_MEDIAN=null" -- --guards-only

run_case "N n that is not a positive integer -> exit 12" 12 "not a positive integer" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_N=0" -- --guards-only

# --- J: a held lock refuses a second batch. ----------------------------------------------------
# The guards run BEFORE the lock check, so --guards-only cannot reach it; --plan-only can.
echo $$ > "$SCRATCH/held.lock"
run_case "J a live pid lock -> exit 8" 8 "held by pid" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_LOCK=$SCRATCH/held.lock" -- --plan-only
# A STALE lock (a pid that is gone) must NOT refuse — a crashed batch must be resumable.
echo 99999999 > "$SCRATCH/stale.lock"
run_case "K a stale pid lock -> NOT refused" 0 "plan-only: nothing was run" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_LOCK=$SCRATCH/stale.lock" -- --plan-only

# --- L: a bad API endpoint is exit 7, and it is reached only after the guards pass. ------------
run_case "L API not answering 200 -> exit 7" 7 "not 200" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_LOCK=$SCRATCH/free.lock" "API=http://127.0.0.1:59999" --

# --- M: --plan-only on the real break runs nothing and says so. --------------------------------
run_case "M plan-only on the break -> exit 0, nothing run" 0 "plan-only: nothing was run" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_LOCK=$SCRATCH/free2.lock" -- --plan-only

# --- O: a run that produces no run id must ABORT at exit 14, not fill n with nulls. ------------
# Driven through B9DF_RUNNER, a stub that prints what the real runner printed when it could not
# reach the API. *** THE FIRST VERSION OF THIS CASE STUBBED THE API INSTEAD AND SO INVOKED THE REAL
# run-agent.sh *** — a fixture that can start a paid agent run. It was killed after 110s; no
# worktree, no knowledge log, no API record, nothing spent. A real launch of the class this case
# tests is on disk at evidence/b09/deliberate-failure/batch-20260927T085830Z: five rows of
# `none/1/null/null` written in two seconds under the message `done: 5 runs`.
cat > "$SCRATCH/runner-stub.sh" <<'STUB'
#!/usr/bin/env bash
echo "  stripped terminal CLI shims from PATH — the agent runs the real binary"
echo "run-agent: Observatory API not reachable at http://localhost:8080; run 'make up' first"
exit 1
STUB
chmod +x "$SCRATCH/runner-stub.sh"
run_case "O runner produces no run id -> exit 14, row kept" 14 "produced no run id" \
  -- "B9DF_OVERLAY=$BROKEN" "B9DF_LOCK=$SCRATCH/free3.lock" "B9DF_EVID_ROOT=$SCRATCH/evid" \
     "B9DF_N=2" "B9DF_RUNNER=$SCRATCH/runner-stub.sh" --
# The kept row is the point: ONE row, not two, and it names the failure.
ABORTED_ROW=0; ROWS=0
for m in "$SCRATCH/evid"/batch-*/manifest.tsv; do
  [[ -f "$m" ]] || continue
  grep -q 'ABORTED at seq 01' "$m" && ABORTED_ROW=1
  ROWS=$(( ROWS + $(grep -c '^0[0-9]' "$m") ))
done
if [[ "$ABORTED_ROW" == 1 && "$ROWS" == 1 ]]; then
  PASS=$((PASS+1)); printf 'PASS  %-58s %s\n' "P one row kept, ABORTED recorded, n NOT filled" "ok"
else
  FAIL=$((FAIL+1)); printf 'FAIL  %-58s %s\n' "P one row kept, ABORTED recorded, n NOT filled" "aborted=$ABORTED_ROW rows=$ROWS"
fi

echo ""
echo "$PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] && { echo "all $((PASS)) cases behaved as specified"; exit 0; }
exit 1
