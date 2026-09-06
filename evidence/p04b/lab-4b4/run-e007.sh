#!/usr/bin/env bash
# E-007 / Lab 4B.4 — orchestration overhead on a task too small to split.
#
#   ./evidence/p04b/lab-4b4/run-e007.sh            # 10 arm-O + 10 concurrent control, interleaved
#   PAIRS=1 ./evidence/p04b/lab-4b4/run-e007.sh    # one pair, smoke
#   PAIRS=1 EXPERIMENT_KEY=EXP-4B-ORCH-PREFLIGHT \
#     ./evidence/p04b/lab-4b4/run-e007.sh          # §4 step 5 preflight pair, its own key
#
# WHAT THIS IS. §4 step 6 of spine stop 11. Arm O installs
# `build/customizations/orchestration-4b4-P1` and starts the session AS the `orchestrator`
# agent, which can read but not write and must delegate to `implementer` via `Task`. Arm C is
# the plain baseline. Predictions O1–O7 are committed at c21781b, BEFORE this script existed,
# and are not editable after it runs.
#
# WHY A SCRIPT AND NOT `make run-benchmark` TWENTY TIMES. The manifest row per run IS the
# progress record. Stop 10 learned that the expensive way: a session declared a live batch dead
# because it checked for a process instead of reading the manifest, and wrote a recovery plan
# that would have duplicated five benchmark runs — evidence you then cannot delete.
#
# THE LOCKFILE IS THE FIX STOP 10 OWED, and it is the whole reason "is this batch running?" is
# now answered by something that executes. It holds this script's PID; a second invocation
# refuses while the first is alive, and a stale lock (the holder is gone) is reported and
# cleared rather than silently reused. `pgrep` cannot do this job on this machine: bare pgrep
# fails with an illegal-byte-sequence error and prints nothing, which reads exactly like "no
# batch running", and even LC_ALL=C pgrep matches poller shells that are not the batch.
#
# EXIT 9 FROM THE RUNNER STOPS THIS BATCH, deliberately, and that is the opposite of
# run-e006-armG.sh's choice. Arm G declared no schema, so a 9 there would have been a finding
# about the runner. Arm O DOES declare one, so a 9 here is decision-rule row 0a — the treatment
# did not arrive — and continuing would spend nineteen more runs on an arm that is already void.
# A permutation of the declared list is NOT a 9 any more; see the 2026-09-06 amendment in
# experiments/E-007-orchestration-overhead.md and runner/lib/schema-verdict-policy.sh.
set -uo pipefail
cd "$(dirname "$0")/../../.." || exit 1

if command -v caffeinate >/dev/null 2>&1 && [[ "${E007_CAFFEINATED:-0}" != "1" ]]; then
  echo "run-e007: re-executing under caffeinate -i so the batch cannot span an idle sleep"
  E007_CAFFEINATED=1 exec caffeinate -i "$0" "$@"
fi
[[ "${E007_CAFFEINATED:-0}" == "1" ]] \
  || echo "run-e007: WARNING - caffeinate unavailable, an idle sleep can contaminate durations" >&2

LAB="$(pwd)"
OBS="$(cd "$LAB/../agent-observatory" && pwd)" || exit 1

PAIRS="${PAIRS:-10}"
EXPERIMENT_KEY="${EXPERIMENT_KEY:-EXP-4B-ORCH-OVERHEAD}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/p04b/lab-4b4/batch-$STAMP"
ISD="$LAB/evidence/p04b/lab-4b4/init-schema"
LOCK="${E007_LOCK:-$LAB/evidence/p04b/lab-4b4/.batch.lock}"

fail() { echo "run-e007: $*" >&2; exit 1; }

# --- the lock, before anything is created ----------------------------------
# `noclobber` makes the create-or-fail atomic: two shells racing here cannot both win.
acquire_lock() {
  if ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null; then
    LOCK_HELD=1
    return 0
  fi
  local holder
  holder="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$holder" ]] && kill -0 "$holder" 2>/dev/null; then
    echo "run-e007: REFUSING TO START. A batch is already running under pid $holder." >&2
    echo "run-e007: lock $LOCK. Read its manifest before deciding anything is dead:" >&2
    echo "run-e007: a duplicate benchmark run is evidence you then cannot delete." >&2
    exit 4
  fi
  echo "run-e007: stale lock from pid ${holder:-unknown} (no such process) — clearing it" >&2
  rm -f "$LOCK" || fail "cannot clear stale lock $LOCK"
  ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null \
    || fail "cannot take lock $LOCK after clearing a stale one"
  LOCK_HELD=1
}
LOCK_HELD=0
release_lock() { [[ "$LOCK_HELD" == "1" ]] && rm -f "$LOCK"; }
trap release_lock EXIT INT TERM

acquire_lock
mkdir -p "$EVID" "$ISD" || fail "cannot create $EVID"
MANIFEST="$EVID/manifest.tsv"

# --- the registered variables, asserted before the first run ---------------
OVERLAY_DIR="$LAB/build/customizations/orchestration-4b4-P1"
ORCH_FILE="$OVERLAY_DIR/.claude/agents/orchestrator.md"
IMPL_FILE="$OVERLAY_DIR/.claude/agents/implementer.md"
EXPECT_ORCH_HASH="4f2af4ba7f740c33"
EXPECT_IMPL_HASH="6096f5ea35383112"
EXPECT_BENCH_SHA="0448643"
EXPECT_MODEL="claude-haiku-4-5-20251001"
# 2.1.263, NOT the 2.1.261 § Controlled variables names. The binary was repointed at 04:38Z on
# 2026-09-06, before both the probe and the prediction commit; disclosed in E-007's amendment.
# Asserted rather than accepted, so a SECOND bump mid-batch stops the batch instead of splitting
# it in half unnoticed — which is exactly what happened to E-006's two batches under one key.
EXPECT_CLAUDE="${EXPECT_CLAUDE:-2.1.263}"
PRED_COMMIT="${PRED_COMMIT:-c21781b}"

# THE `tools:` ASSERTIONS COME BEFORE THE HASH ASSERTIONS, and the order is the point rather
# than a detail. A hash guard pins the whole file, so while it holds these two greps can never
# fire — an unreachable guard is one nothing can ever prove rejects, which is the shape this
# project keeps paying for. Put first, they are reachable, and `verify-run-e007.sh` drives both.
# What they catch is the specific mistake worth catching: the arm's one L2 element is this line,
# and P2 — the step-9 deliberate failure — is this same file WITHOUT it. A batch that ran P2
# under the treatment's key and hash constant would be the deliberate failure wearing the
# treatment's name.
grep -qE '^tools:[[:space:]]*Read, Grep, Glob, Task[[:space:]]*$' "$ORCH_FILE" \
  || fail "orchestrator.md does not declare the registered tools: line."
grep -qE '^tools:' "$IMPL_FILE" \
  && fail "implementer.md declares a tools: line; it is registered as inheriting the pool."

got="$(shasum -a 256 "$ORCH_FILE" | cut -c1-16)"
[[ "$got" == "$EXPECT_ORCH_HASH" ]] \
  || fail "orchestrator.md is $got, registered $EXPECT_ORCH_HASH - the treatment moved."
got="$(shasum -a 256 "$IMPL_FILE" | cut -c1-16)"
[[ "$got" == "$EXPECT_IMPL_HASH" ]] \
  || fail "implementer.md is $got, registered $EXPECT_IMPL_HASH - the treatment moved."

got_bench="$(git -C "$LAB/../agent-observatory-benchmarks" rev-parse --short HEAD)"
[[ "$got_bench" == "$EXPECT_BENCH_SHA" ]] \
  || fail "benchmarks HEAD is $got_bench, registered $EXPECT_BENCH_SHA - the task moved."
got_claude="$(claude --version 2>/dev/null | awk '{print $1}')"
[[ "$got_claude" == "$EXPECT_CLAUDE" ]] \
  || fail "claude is $got_claude, registered $EXPECT_CLAUDE - the runtime moved under the batch."

# THE PREDICTION MUST PRECEDE THE FIRST RUN, and this checks it rather than asserting it.
pred_at="$(git -C "$LAB" log --format=%cI -1 "$PRED_COMMIT" 2>/dev/null)" \
  || fail "prediction commit $PRED_COMMIT is not in this repository."
[[ -n "$pred_at" ]] || fail "prediction commit $PRED_COMMIT has no timestamp."
pred_epoch="$(date -j -f '%Y-%m-%dT%H:%M:%S%z' "${pred_at/Z/+0000}" +%s 2>/dev/null)" || pred_epoch=""
now_epoch="$(date +%s)"
if [[ -n "$pred_epoch" && "$now_epoch" -le "$pred_epoch" ]]; then
  fail "the clock says the first run would start at or before the prediction commit."
fi
echo "run-e007: prediction $PRED_COMMIT committed $pred_at; first run starts after it"

# Nothing else of this lab's may be running: durations are an outcome here (O3), and the
# 17:34Z preflight of stop 10 contaminated four arm-G runs by ignoring exactly this.
busy="$(LC_ALL=C pgrep -fl 'bin/opencode|run-agent.sh' 2>/dev/null | grep -v "$$" || true)"
[[ -z "$busy" ]] || echo "run-e007: WARNING - other work is live; durations may be contaminated:
$busy" >&2

ARM_COMMON=(
  RUNTIME=claude
  BENCHMARK=BE-003
  "EXPERIMENT=$EXPERIMENT_KEY"
  "MODEL=$EXPECT_MODEL"
  ISOLATE_USER_SETTINGS=1
  KEEP=1
)
ARM_O=(
  "CUSTOMIZATION=../agent-learning-lab/build/customizations/orchestration-4b4-P1"
  AGENT=orchestrator
  VARIANT=orchestration-4b4-P1
)
ARM_CONTROL=(
  VARIANT=baseline-e007-window
)

{
  echo "# E-007 Lab 4B.4 $STAMP  key=$EXPERIMENT_KEY pairs=$PAIRS"
  echo "# orchestrator $EXPECT_ORCH_HASH · implementer $EXPECT_IMPL_HASH"
  echo "# benchmarks $got_bench · claude $got_claude · model $EXPECT_MODEL"
  echo "# prediction commit $PRED_COMMIT at $pred_at"
  echo "# common:       ${ARM_COMMON[*]}"
  echo "# arm O adds:   ${ARM_O[*]}"
  echo "# control adds: ${ARM_CONTROL[*]}"
  printf 'seq\tarm\trun_id\texit\tworktree\tinit_schema_verdict\tdelegations\n'
} > "$MANIFEST"

echo "batch start (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee "$EVID/window.txt"

one_run() {
  local arm="$1" seq="$2"; shift 2
  local log="$EVID/${seq}-${arm}.log"
  echo ""
  echo "======== $seq $arm ========"
  ( cd "$OBS" && INIT_SCHEMA_DIR="$ISD" make run-benchmark "${ARM_COMMON[@]}" "$@" ) \
    > "$log" 2>&1
  local rc=$?
  local rid wt verdict deleg
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  verdict="$(grep -ao 'verdict=[a-z-]*' "$log" | head -1)"
  # O1's raw count, from the runner's own log, as a cheap in-flight check. The REGISTERED
  # number is the observatory telemetry at §4 step 7; this column exists so a batch that is
  # delegating zero times is visible at pair 01 instead of at pair 10.
  deleg="$(grep -acE '"(name|tool_name)":"(Task|Agent)"' "$log" 2>/dev/null || echo 0)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:-NONE}" "$rc" "${wt:-NONE}" "${verdict:-NONE}" "$deleg" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} exit=$rc ${verdict:-no-schema-verdict} deleg~$deleg"
  return $rc
}

for i in $(seq 1 "$PAIRS"); do
  s="$(printf '%02d' "$i")"
  one_run O "$s" "${ARM_O[@]}"
  rc=$?
  if [[ $rc -eq 9 ]]; then
    echo "!! arm O $s returned 9 — DECISION-RULE ROW 0a. The declared set was not delivered." >&2
    echo "!! The batch STOPS here. It is redesigned, not resumed: see the manifest for what ran." >&2
    echo "batch aborted (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$EVID/window.txt"
    echo "manifest: $MANIFEST"
    exit 9
  fi
  one_run control "$s" "${ARM_CONTROL[@]}"
done

echo "batch end   (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$EVID/window.txt"
echo ""
echo "manifest: $MANIFEST"
column -t -s "$(printf '\t')" "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
