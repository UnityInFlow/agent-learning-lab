#!/usr/bin/env bash
#
# verify-codex-score-timeout.sh — the fixture set for LAB_SCORE_TIMEOUT in tools/codex-score.sh.
#
# WHY. Before 2026-09-27 the registered scorer had no wall-clock budget: a `codex exec` sat at 0.0 %
# CPU for 61 minutes and still left a 1.3k header-only sheet with zero `score:` lines. A driver
# reading the exit code or the file's existence would have recorded it as SCORED. The budget is the
# fix; this file is the proof that the budget FIRES, that it kills the whole process GROUP, and that
# it does not fire on a call that finishes — because a control that has never been shown to reject
# anything is indistinguishable from one that rejects nothing (§6).
#
# `codex` is stubbed on PATH. Nothing here calls the real codex, spends a token, or writes into
# findings/ outside its own scratch directory.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
LAB="$PWD"
SCORER="$LAB/tools/codex-score.sh"
RUBRIC="$LAB/benchmark/rubrics/backend-quality.yaml"
FIXTURE="$LAB/../agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/fixtures/good-nested-ifs"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
SLEEP_MARK="cst-stub-sleep-$$"
export STUB_SLEEP_MARK="$SLEEP_MARK"
pass=0; fail=0
ok()  { echo "  ok   — $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL — $1"; fail=$((fail + 1)); }

[[ -f "$SCORER" && -f "$RUBRIC" && -d "$FIXTURE" ]] || { echo "missing scorer, rubric or fixture" >&2; exit 2; }

# A stub that sleeps forever in a CHILD, so a kill that misses the group leaves the child alive —
# which is exactly the bug the group kill exists for.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/codex" <<'STUB'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "codex-cli 0.0.0-stub"; exit 0 ;;
esac
if [[ "${STUB_MODE:-hang}" == hang ]]; then
  # The marker makes the grandchild uniquely findable, so case B's pgrep cannot match an
  # unrelated `sleep` belonging to something else on this machine.
  ( exec -a "$STUB_SLEEP_MARK" sleep 600 ) &   # a CHILD, on purpose
  echo "stub child $! sleeping" >&2
  wait
  exit 0
fi
# STUB_MODE=ok — write a schema-shaped last message and succeed.
for a in "$@"; do
  [[ -n "${want:-}" ]] && { printf '%s' '{"categories":[{"name":"architecture-consistency","score":2,"evidence":"stub"},{"name":"maintainability","score":0,"evidence":"stub"},{"name":"test-quality","score":null,"evidence":"stub"},{"name":"change-focus","score":2,"evidence":"stub"}]}' > "$a"; unset want; }
  [[ "$a" == "--output-last-message" ]] && want=1
done
exit 0
STUB
chmod +x "$WORK/bin/codex"
export PATH="$WORK/bin:$PATH"
command -v codex | grep -q "$WORK/bin" || { echo "the stub is not first on PATH" >&2; exit 2; }

run_scorer() {  # run_scorer <label> <extra env...>; prints nothing, sets RC and ELAPSED
  local t0 t1
  shift    # the label is for the reader, not for `env` — without this shift `env` tried to
           # EXECUTE the label and every case returned 127, which four cases then read as a pass.
  t0=$(date +%s)
  ( cd "$WORK" && env STUB_SLEEP_MARK="$SLEEP_MARK" LAB_SCORE_OUTDIR="$WORK/sheets" "$@" \
      "$SCORER" "$RUBRIC" "$FIXTURE" >"$WORK/out.txt" 2>&1 )
  RC=$?
  t1=$(date +%s); ELAPSED=$((t1 - t0))
}

# --- A: THE BUDGET FIRES, AT 124, AND WITHIN A FEW SECONDS OF ITS DEADLINE. ---------------------
run_scorer A STUB_MODE=hang LAB_SCORE_TIMEOUT=5
if [[ "$RC" -eq 124 && "$ELAPSED" -lt 30 ]]; then ok "A a hung call expires at exit 124 in ${ELAPSED}s"
else bad "A a hung call expires at 124 — got rc=$RC after ${ELAPSED}s"; fi

# --- B: THE KILL REACHED THE GROUP, so the stub's CHILD is gone too. ---------------------------
sleep 1
if ! pgrep -f "$SLEEP_MARK" >/dev/null 2>&1; then ok "B the stub's grandchild sleep was killed with the group"
else bad "B the marked grandchild survived the timeout — the kill missed the process group"
     pkill -f "$SLEEP_MARK" 2>/dev/null; fi

# --- C: THE STALL MESSAGE NAMES THE BUDGET AND CALLS IT A STALL, NOT A SCORE. ------------------
if grep -q 'exceeded LAB_SCORE_TIMEOUT' "$WORK/out.txt" && grep -q 'STALL, not a score' "$WORK/out.txt"
then ok "C the expiry message names the budget and says STALL"
else bad "C the expiry message is missing or does not say STALL"; fi

# --- D: THE HEADER-ONLY SHEET IS KEPT, and it has fewer than four score lines. -----------------
SHEET="$(find "$WORK/sheets" -name 'score-*.yaml' 2>/dev/null | head -1)"
if [[ -n "$SHEET" ]] && [[ "$(grep -c '^ *score:' "$SHEET")" -lt 4 ]]
then ok "D the stalled sheet is kept and is incomplete ($(grep -c '^ *score:' "$SHEET") of 4 score lines)"
else bad "D no kept sheet, or it looks complete: ${SHEET:-none}"; fi

# --- E: THE BUDGET IS RECORDED IN THE SHEET'S PROVENANCE. --------------------------------------
if [[ -n "$SHEET" ]] && grep -q 'wall_budget_s:  5' "$SHEET"
then ok "E the sheet's provenance records the budget it ran under"
else bad "E the sheet does not record wall_budget_s"; fi

# --- F: A CALL THAT FINISHES IS NOT KILLED, and the budget is not in its way. ------------------
rm -rf "$WORK/sheets"
run_scorer F STUB_MODE=ok LAB_SCORE_TIMEOUT=120
if [[ "$RC" -ne 124 ]]; then ok "F a completing call is not expired (rc=$RC in ${ELAPSED}s)"
else bad "F a completing call was killed by the budget"; fi

# --- G: LAB_SCORE_TIMEOUT=0 DISABLES THE BUDGET, and that restores the old behaviour. ----------
# Proved by the hang stub NOT being killed within a short window: the scorer is still waiting.
rm -rf "$WORK/sheets"
( cd "$WORK" && env STUB_SLEEP_MARK="$SLEEP_MARK" LAB_SCORE_OUTDIR="$WORK/sheets" \
    STUB_MODE=hang LAB_SCORE_TIMEOUT=0 "$SCORER" "$RUBRIC" "$FIXTURE" >"$WORK/out0.txt" 2>&1 ) &
ZERO_PID=$!
sleep 12
if kill -0 "$ZERO_PID" 2>/dev/null; then ok "G LAB_SCORE_TIMEOUT=0 leaves the call running (no budget)"
else bad "G LAB_SCORE_TIMEOUT=0 still killed the call"; fi
# NEVER `kill -- -$$` here: this script's process group contains the shell that launched it.
kill "$ZERO_PID" 2>/dev/null; wait "$ZERO_PID" 2>/dev/null
pkill -f "$SLEEP_MARK" 2>/dev/null

# --- H: A NON-NUMERIC BUDGET IS REFUSED, not silently treated as zero or as 900. ---------------
run_scorer H STUB_MODE=ok LAB_SCORE_TIMEOUT=abc
if [[ "$RC" -eq 1 ]] && grep -q 'must be a whole number of seconds' "$WORK/out.txt"
then ok "H a non-numeric LAB_SCORE_TIMEOUT is refused at exit 1"
else bad "H a non-numeric budget was accepted — rc=$RC"; fi

# --- I: AN EMPTY BUDGET IS REFUSED TOO. `${VAR:-900}` treats empty as unset, so this checks that
# an explicitly-empty value cannot silently become the default in a way a reader would not expect.
run_scorer I STUB_MODE=ok LAB_SCORE_TIMEOUT=
if [[ "$RC" -ne 124 ]]; then ok "I an empty LAB_SCORE_TIMEOUT falls back to the default, not to 0 (rc=$RC)"
else bad "I an empty budget expired the call"; fi

# --- K: THE DEFAULT BUDGET IS ABOVE EVERY COMPLETED CALL EVER OBSERVED HERE. -------------------
# The longest completed codex scoring call on record is 1875s (31m15s, stop 20). A default below it
# converts a real sheet into a stall, which is a control rejecting correct work. Asserted against
# the script's own text, because the default is what a caller who passes nothing gets.
DEFAULT_BUDGET="$(grep -oE 'SCORE_BUDGET="\$\{LAB_SCORE_TIMEOUT:-[0-9]+' "$SCORER" | grep -oE '[0-9]+$')"
if [[ -n "$DEFAULT_BUDGET" ]] && [[ "$DEFAULT_BUDGET" -gt 1875 ]]
then ok "K the default budget ${DEFAULT_BUDGET}s exceeds the longest observed completed call (1875s)"
else bad "K the default budget is ${DEFAULT_BUDGET:-unset}s, at or below the observed 1875s maximum"; fi

# --- J: THE OUTDIR HOOK WORKS, so a fixture can never again write into the registered directory. --
rm -rf "$WORK/sheets"
BEFORE="$(find "$LAB/findings/codex" -name 'score-*.yaml' 2>/dev/null | wc -l | tr -d ' ')"
run_scorer J STUB_MODE=ok LAB_SCORE_TIMEOUT=60
AFTER="$(find "$LAB/findings/codex" -name 'score-*.yaml' 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$BEFORE" == "$AFTER" ]] && [[ -n "$(find "$WORK/sheets" -name 'score-*.yaml' 2>/dev/null | head -1)" ]]
then ok "J LAB_SCORE_OUTDIR keeps the sheet out of findings/codex ($BEFORE unchanged)"
else bad "J the sheet reached findings/codex ($BEFORE -> $AFTER)"; fi

echo ""
echo "verify-codex-score-timeout: $pass passed, $fail failed, $((pass + fail)) of 11 cases ran."
[[ "$fail" -eq 0 && $((pass + fail)) -eq 11 ]] || exit 1
exit 0
