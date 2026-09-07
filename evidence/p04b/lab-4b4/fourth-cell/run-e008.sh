#!/usr/bin/env bash
# E-008 — E-007's fourth cell: the worker's prose as CLAUDE.md, with NO split.
#
#   ./evidence/p04b/lab-4b4/fourth-cell/run-e008.sh          # 10 arm-F + 10 concurrent control, interleaved
#   PAIRS=1 ./evidence/p04b/lab-4b4/fourth-cell/run-e008.sh  # one pair, smoke
#   PAIRS=1 EXPERIMENT_KEY=EXP-4B-FOURTH-CELL-PREFLIGHT \
#     ./evidence/p04b/lab-4b4/fourth-cell/run-e008.sh        # the read-back pair, its own key
#
# WHAT THIS IS. Author decision 10.1's arm: a plain baseline PLUS the body of
# `build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md`, delivered as an
# overlay CLAUDE.md (`build/customizations/implementer-prose-4b4/`), proved per run by
# `customization.instructionsHash` as E-003 proved its file. NO orchestrator, NO `.claude/agents/`,
# NO `--agent`. Arm C is the plain baseline. Predictions are in
# experiments/E-008-fourth-cell-prose-without-split.md, committed BEFORE this script ran anything.
#
# WHY A SCRIPT. Same reason as run-e007-p2.sh, whose pair loop and lockfile this copies: the
# manifest row per run IS the progress record, and the lock is the thing that EXECUTES to answer
# "is a batch running?". What changed is the guard set. The P2 driver guarded an agent overlay
# (tools: lines, two file hashes); this one guards a single instruction file:
#   1. the overlay holds EXACTLY one file, and it is CLAUDE.md — a `.claude/agents/` that crept in
#      would turn this cell back into a split wearing the fourth cell's name;
#   2. that file is BYTE-IDENTICAL to lines 7- of the P1 implementer.md — the cell is "the same
#      words", and a diff is what proves sameness, not a sentence;
#   3. its hash is the registered one — so a consistent edit of BOTH files (which the diff cannot
#      see) still stops the batch;
#   4. the BE-003 task TREE is the one E-007 ran on. benchmarks HEAD moved (benchmarks#29 merged
#      BE-004), so a commit guard would pin a sha that is no longer main's; the tree hash of
#      tasks/BE-003-confirm-shipment is the registered variable, and it is asserted as such.
#
# DELIVERY IS READ BACK PER RUN from the API and written to the manifest: a treatment run whose
# instructionsHash is not the registered one, or a control whose hash is non-null, or ANY
# delegation event on any run, is decision-rule row 0a (VOID) — and the batch STOPS there, exit 8,
# because spending nineteen more runs on a void arm is the thing run-e007-p2.sh refused to do too.
set -uo pipefail
cd "$(dirname "$0")/../../../.." || exit 1

if command -v caffeinate >/dev/null 2>&1 && [[ "${E008_CAFFEINATED:-0}" != "1" ]]; then
  echo "run-e008: re-executing under caffeinate -i so the batch cannot span an idle sleep"
  E008_CAFFEINATED=1 exec caffeinate -i "$0" "$@"
fi
[[ "${E008_CAFFEINATED:-0}" == "1" ]] \
  || echo "run-e008: WARNING - caffeinate unavailable, an idle sleep can contaminate durations" >&2

LAB="$(pwd)"
OBS="$(cd "$LAB/../agent-observatory" && pwd)" || exit 1

PAIRS="${PAIRS:-5}"
# START numbers the first pair of THIS invocation. E-008 registers n = 10 PER ARM, and the
# first invocation ran the default 5 pairs (copied from run-e007-p2.sh, whose registered n WAS
# 5 per arm) - an instrument fault of the author of this script, disclosed in E-008. The second
# half runs with START=6 PAIRS=5 so its rows read 06-10 and the two manifests concatenate.
START="${START:-1}"
EXPERIMENT_KEY="${EXPERIMENT_KEY:-EXP-4B-FOURTH-CELL}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
CELL="$LAB/evidence/p04b/lab-4b4/fourth-cell"
EVID="$CELL/batch-$STAMP"
LOCK="${E008_LOCK:-$CELL/.batch.lock}"
API_PORT="${E008_API_PORT:-18081}"

fail() { echo "run-e008: $*" >&2; exit 1; }

# --- the lock, before anything is created ----------------------------------
acquire_lock() {
  if ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null; then
    LOCK_HELD=1
    return 0
  fi
  local holder
  holder="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$holder" ]] && kill -0 "$holder" 2>/dev/null; then
    echo "run-e008: REFUSING TO START. A batch is already running under pid $holder." >&2
    echo "run-e008: lock $LOCK. Read its manifest before deciding anything is dead:" >&2
    echo "run-e008: a duplicate benchmark run is evidence you then cannot delete." >&2
    exit 4
  fi
  echo "run-e008: stale lock from pid ${holder:-unknown} (no such process) — clearing it" >&2
  rm -f "$LOCK" || fail "cannot clear stale lock $LOCK"
  ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null \
    || fail "cannot take lock $LOCK after clearing a stale one"
  LOCK_HELD=1
}
LOCK_HELD=0
release_lock() { [[ "$LOCK_HELD" == "1" ]] && rm -f "$LOCK"; }
trap release_lock EXIT INT TERM

acquire_lock
MANIFEST="$EVID/manifest.tsv"
# No mkdir here, on purpose: a refused invocation must leave no batch-<STAMP>/ behind.

# --- the registered variables, asserted before the first run ---------------
OVERLAY_DIR="$LAB/build/customizations/implementer-prose-4b4"
OVERLAY_FILE="$OVERLAY_DIR/CLAUDE.md"
SOURCE_FILE="$LAB/build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md"
EXPECT_HASH16="51f16eeb1618cd21"
EXPECT_INSTRUCTIONS_HASH="sha256:51f16eeb1618cd212405818c5165dcba"   # the runner keeps 32 hex chars
EXPECT_BE003_TREE="eeb15a753adc94e92bc3f74c50e1b02fc3b53030"
EXPECT_MODEL="claude-haiku-4-5-20251001"
EXPECT_CLAUDE="${EXPECT_CLAUDE:-2.1.263}"
PRED_COMMIT="${PRED_COMMIT:-b952e8c}"

# 1. exactly one file, and it is CLAUDE.md. Counted, not assumed: a second file is how a
#    "no split" cell becomes a split.
[[ -d "$OVERLAY_DIR" ]] || fail "overlay directory missing: $OVERLAY_DIR"
nfiles="$(find "$OVERLAY_DIR" -type f | wc -l | tr -d ' ')"
[[ "$nfiles" == "1" ]] \
  || fail "overlay holds $nfiles files; the fourth cell is exactly one file (CLAUDE.md) and NO .claude/agents/."
[[ -f "$OVERLAY_FILE" ]] \
  || fail "overlay's one file is not CLAUDE.md; the claude runtime reads CLAUDE.md and nothing else here."

# 2. byte-identical to the implementer body. THIS is what "the same words" means.
[[ -f "$SOURCE_FILE" ]] || fail "source of the prose is missing: $SOURCE_FILE"
if ! diff -q <(tail -n +7 "$SOURCE_FILE") "$OVERLAY_FILE" >/dev/null; then
  fail "CLAUDE.md is NOT byte-identical to implementer.md lines 7-; the cell is not 'the same words'."
fi

# 3. the registered hash — catches a consistent edit of both files, which the diff cannot see.
got="$(shasum -a 256 "$OVERLAY_FILE" | cut -c1-16)"
[[ "$got" == "$EXPECT_HASH16" ]] \
  || fail "CLAUDE.md is $got, registered $EXPECT_HASH16 - the treatment moved."

# 4. the BE-003 task tree, not the benchmarks commit.
got_tree="$(git -C "$LAB/../agent-observatory-benchmarks" rev-parse HEAD:tasks/BE-003-confirm-shipment 2>/dev/null)"
[[ "$got_tree" == "$EXPECT_BE003_TREE" ]] \
  || fail "BE-003 tree is ${got_tree:-absent}, registered $EXPECT_BE003_TREE - the task moved."
got_bench="$(git -C "$LAB/../agent-observatory-benchmarks" rev-parse --short HEAD)"

got_claude="$(claude --version 2>/dev/null | awk '{print $1}')"
[[ "$got_claude" == "$EXPECT_CLAUDE" ]] \
  || fail "claude is $got_claude, registered $EXPECT_CLAUDE - the runtime moved under the batch."

# THE PREDICTION MUST PRECEDE THE FIRST RUN, checked rather than asserted.
pred_at="$(git -C "$LAB" log --format=%cI -1 "$PRED_COMMIT" 2>/dev/null)" \
  || fail "prediction commit $PRED_COMMIT is not in this repository."
[[ -n "$pred_at" ]] || fail "prediction commit $PRED_COMMIT has no timestamp."
pred_epoch="$(date -j -f '%Y-%m-%dT%H:%M:%S%z' "${pred_at/Z/+0000}" +%s 2>/dev/null)" || pred_epoch=""
now_epoch="$(date +%s)"
if [[ -n "$pred_epoch" && "$now_epoch" -le "$pred_epoch" ]]; then
  fail "the clock says the first run would start at or before the prediction commit."
fi
echo "run-e008: prediction $PRED_COMMIT committed $pred_at; first run starts after it"

busy="$(LC_ALL=C pgrep -fl 'bin/opencode|run-agent.sh' 2>/dev/null | grep -v "$$" || true)"
[[ -z "$busy" ]] || echo "run-e008: WARNING - other work is live; durations may be contaminated:
$busy" >&2

ARM_COMMON=(
  RUNTIME=claude
  BENCHMARK=BE-003
  "EXPERIMENT=$EXPERIMENT_KEY"
  "MODEL=$EXPECT_MODEL"
  ISOLATE_USER_SETTINGS=1
  KEEP=1
  # colima tunnels, as run-e007-p2.sh: the host port-forwards are dead, the stack is healthy.
  # OTLP_GRPC_PORT is passed too (stop 11's telemetry rule): check events.jsonl grows.
  "API_PORT=$API_PORT"
  "OTLP_HTTP_PORT=${E008_OTLP_HTTP_PORT:-14318}"
  "OTLP_GRPC_PORT=${E008_OTLP_GRPC_PORT:-14317}"
  "TEMPO_PORT=${E008_TEMPO_PORT:-13200}"
)
ARM_F=(
  "CUSTOMIZATION=../agent-learning-lab/build/customizations/implementer-prose-4b4"
  VARIANT=implementer-prose-4b4
)
ARM_CONTROL=(
  VARIANT=baseline-e008-window
)

EVENTS="$OBS/infra/telemetry-out/events.jsonl"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }

mkdir -p "$EVID" || fail "cannot create $EVID"

{
  echo "# E-008 fourth cell $STAMP  key=$EXPERIMENT_KEY pairs=$PAIRS start=$START"
  echo "# overlay CLAUDE.md $EXPECT_HASH16 (runner form $EXPECT_INSTRUCTIONS_HASH) = implementer.md lines 7-, verbatim"
  echo "# BE-003 tree $EXPECT_BE003_TREE at benchmarks $got_bench · claude $got_claude · model $EXPECT_MODEL"
  echo "# prediction commit $PRED_COMMIT at $pred_at"
  echo "# common:       ${ARM_COMMON[*]}"
  echo "# arm F adds:   ${ARM_F[*]}"
  echo "# control adds: ${ARM_CONTROL[*]}"
  printf 'seq\tarm\trun_id\texit\tworktree\tinstructions_hash\tdelegations\n'
} > "$MANIFEST"

{
  echo "batch start (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "events.jsonl bytes at start: $(events_bytes)"
} | tee "$EVID/window.txt"

read_back_hash() {
  # The run record's customization.instructionsHash, from the API, with three tries. "UNREAD"
  # is recorded when the API does not answer; it is NOT a pass and the step-7 verdict re-reads
  # every hash from the API before any sheet is opened.
  local rid="$1" out
  for _ in 1 2 3; do
    out="$(curl -s -m 10 "http://127.0.0.1:${API_PORT}/api/runs/${rid}" 2>/dev/null \
           | jq -r 'if .customization then (.customization.instructionsHash // "null") else empty end' 2>/dev/null)"
    [[ -n "$out" ]] && { echo "$out"; return 0; }
    sleep 3
  done
  echo "UNREAD"
}

one_run() {
  local arm="$1" seq="$2"; shift 2
  local log="$EVID/${seq}-${arm}.log"
  echo ""
  echo "======== $seq $arm ========"
  ( cd "$OBS" && make run-benchmark "${ARM_COMMON[@]}" "$@" ) > "$log" 2>&1
  local rc=$?
  local rid wt ihash deleg
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  deleg="$(grep -acE '"(name|tool_name)":"(Task|Agent)"' "$log" 2>/dev/null)"
  deleg="${deleg:-0}"
  ihash="NONE"
  [[ -n "$rid" ]] && ihash="$(read_back_hash "$rid")"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:-NONE}" "$rc" "${wt:-NONE}" "$ihash" "$deleg" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} exit=$rc instructionsHash=$ihash deleg~$deleg"
  LAST_RC=$rc; LAST_HASH="$ihash"; LAST_DELEG="$deleg"
  return $rc
}

abort_batch() {
  echo "!! $*" >&2
  echo "!! The batch STOPS here (decision-rule row 0a). It is redesigned, not resumed." >&2
  { echo "batch aborted (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"; echo "events.jsonl bytes at abort: $(events_bytes)"; } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit 8
}

LAST_RC=0; LAST_HASH=""; LAST_DELEG=0
for i in $(seq "$START" $((START + PAIRS - 1))); do
  s="$(printf '%02d' "$i")"
  one_run F "$s" "${ARM_F[@]}"
  if [[ $LAST_RC -eq 9 ]]; then
    echo "!! arm F $s returned 9 — the runner reported an undelivered DECLARED set, and this arm declares none." >&2
    { echo "batch aborted (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } | tee -a "$EVID/window.txt"
    echo "manifest: $MANIFEST"; exit 9
  fi
  [[ "$LAST_HASH" == "$EXPECT_INSTRUCTIONS_HASH" || "$LAST_HASH" == "UNREAD" ]] \
    || abort_batch "arm F $s read back instructionsHash=$LAST_HASH, registered $EXPECT_INSTRUCTIONS_HASH: the treatment did not arrive."
  [[ "$LAST_DELEG" == "0" ]] \
    || abort_batch "arm F $s shows $LAST_DELEG delegation event(s) in its stream: this cell is NO split."
  one_run control "$s" "${ARM_CONTROL[@]}"
  [[ "$LAST_HASH" == "null" || "$LAST_HASH" == "UNREAD" || "$LAST_HASH" == "NONE" ]] \
    || abort_batch "control $s read back instructionsHash=$LAST_HASH: a control received an instruction file."
  [[ "$LAST_DELEG" == "0" ]] \
    || abort_batch "control $s shows $LAST_DELEG delegation event(s) in its stream."
done

{
  echo "batch end   (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "events.jsonl bytes at end: $(events_bytes)"
} | tee -a "$EVID/window.txt"
echo ""
echo "manifest: $MANIFEST"
column -t -s "$(printf '\t')" "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
