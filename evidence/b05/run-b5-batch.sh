#!/usr/bin/env bash
# B5 — workflow phases v1.0. The interleaved batch driver for BOTH tasks.
#
#   BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-B5-PHASES-BE003 ./evidence/b05/run-b5-batch.sh
#   BENCHMARK=BE-004 EXPERIMENT_KEY=EXP-B5-PHASES-BE004 ./evidence/b05/run-b5-batch.sh
#   PAIRS=1 ... ./evidence/b05/run-b5-batch.sh     # smoke — SPENDS TWO REAL RUNS UNDER THE KEY
#
# Descended from evidence/p04b/lab-4b4/fourth-cell/run-e009.sh — same lock, same pair loop, same
# manifest-as-progress-record, same "a duplicate benchmark run is evidence you cannot delete".
# What is DIFFERENT, and why each difference exists:
#
#   a. THE TREATMENT IS AN AGENT OVERLAY, NOT AN INSTRUCTION FILE. E-009 guarded
#      `customization.instructionsHash`; this guards `customization.agentHash` and expects
#      `instructionsHash` to be NULL ON BOTH ARMS. A treated run whose instructionsHash is
#      non-null is as wrong as one whose agentHash is null — it would mean a CLAUDE.md arrived
#      that this experiment never registered.
#
#   b. THE DELEGATION RULE IS INVERTED RELATIVE TO E-009, FOR A MEASURED REASON. E-009's arm F
#      declared no tool list, so a treated delegation meant the split had crept in. HERE the
#      treated arm's `tools:` line is `Read, Edit, Write, Bash` — it has NO `Task` — so a treated
#      delegation would mean the runtime handed the model a tool the overlay does not declare,
#      which is exactly the E-005 failure mode and is decision-rule row 0a. A CONTROL delegation
#      is RECORDED AND THE BATCH CONTINUES: the control is delivered 29 tools including `Task`,
#      so delegating is something a plain baseline may legitimately do. That asymmetry is threat 7
#      in E-010 and E-011 and this script is its executable half — THE CONTROL COUNT IS WRITTEN TO
#      THE MANIFEST ON EVERY RUN, INCLUDING WHEN IT IS ZERO. A confound only mentioned when it
#      fires is a confound nobody checked.
#
#   c. THE CLAUDE VERSION IS PINNED AT LAUNCH TO WHATEVER IT IS, AND ASSERTED CONSTANT AFTERWARDS,
#      instead of being compared to a hardcoded string. E-010 and E-011 register no claude version
#      — their comparison is a concurrent control, so within-batch constancy is the property that
#      matters and a hardcoded 2.1.263 would now abort a legitimate batch (the runtime is 2.1.266).
#      The launch value goes in the manifest header so a reader can see it moved since E-009.
#
#   d. EVERY EXPECTATION IS OVERRIDABLE BY ENV, so each guard can be SHOWN TO REJECT before the
#      batch spends anything. A control that has never been shown to reject anything is
#      indistinguishable from one that rejects nothing; evidence/b05/verify-b5-batch-guards.sh
#      drives exactly that and its output is filed beside this script.
#
# Exit 0 batch complete · 4 another batch holds the lock · 8 decision-rule row 0a, treatment
#        undelivered or a treated run delegated · 9 the runner reported an undelivered declared
#        tool set · 1 a guard refused before any run was made.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

if command -v caffeinate >/dev/null 2>&1 && [[ "${B5_CAFFEINATED:-0}" != "1" ]]; then
  echo "run-b5-batch: re-executing under caffeinate -i so the batch cannot span an idle sleep"
  B5_CAFFEINATED=1 exec caffeinate -i "$0" "$@"
fi
[[ "${B5_CAFFEINATED:-0}" == "1" ]] \
  || echo "run-b5-batch: WARNING - caffeinate unavailable, an idle sleep can contaminate durations" >&2

LAB="$(pwd)"
OBS="$(cd "$LAB/../agent-observatory" && pwd)" || exit 1
BENCH_REPO="$LAB/../agent-observatory-benchmarks"

BENCHMARK="${BENCHMARK:?set BENCHMARK=BE-003 or BE-004}"
EXPERIMENT_KEY="${EXPERIMENT_KEY:?set EXPERIMENT_KEY}"
PAIRS="${PAIRS:-10}"
START="${START:-1}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
CELL="$LAB/evidence/b05"
EVID="$CELL/batch-$BENCHMARK-$STAMP"
LOCK="${B5_LOCK:-$CELL/.batch.lock}"
API_PORT="${B5_API_PORT:-18081}"

# The registered variables. Overridable ONLY so the guards can be proved to refuse; the
# defaults are the registered values and a real batch never passes these.
OVERLAY_DIR="${B5_OVERLAY_DIR:-$LAB/build/customizations/phases-v1.0}"
OVERLAY_FILE="$OVERLAY_DIR/.claude/agents/backend-feature-phases.md"
EXPECT_OVERLAY_SHA="${B5_EXPECT_OVERLAY_SHA:-b3450564b6f32d6193e8580db766210e35c1bfaa90589a705b3e9236fdb18a41}"
EXPECT_AGENT_HASH="${B5_EXPECT_AGENT_HASH:-sha256:b3450564b6f32d6193e8580db766210e}"  # the runner keeps 32 hex
EXPECT_MODEL="${B5_EXPECT_MODEL:-claude-haiku-4-5-20251001}"

case "$BENCHMARK" in
  BE-003) TASK_DIR="tasks/BE-003-confirm-shipment"
          EXPECT_TREE="${B5_EXPECT_TREE:-eeb15a753adc94e92bc3f74c50e1b02fc3b53030}"
          PRED_COMMIT="${PRED_COMMIT:-5777b07}" ;;
  BE-004) TASK_DIR="tasks/BE-004-cancel-order"
          EXPECT_TREE="${B5_EXPECT_TREE:-4ff79f7b157b2ae344036ebec60e1841b0ab9762}"
          PRED_COMMIT="${PRED_COMMIT:-ccd5c0c}" ;;
  *) echo "run-b5-batch: BENCHMARK must be BE-003 or BE-004, got $BENCHMARK" >&2; exit 1 ;;
esac

fail() { echo "run-b5-batch: $*" >&2; exit 1; }

acquire_lock() {
  if ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null; then LOCK_HELD=1; return 0; fi
  local holder; holder="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$holder" ]] && kill -0 "$holder" 2>/dev/null; then
    echo "run-b5-batch: REFUSING TO START. A batch is already running under pid $holder." >&2
    echo "run-b5-batch: lock $LOCK. Read its manifest before deciding anything is dead:" >&2
    echo "run-b5-batch: a duplicate benchmark run is evidence you then cannot delete." >&2
    exit 4
  fi
  echo "run-b5-batch: stale lock from pid ${holder:-unknown} (no such process) — clearing it" >&2
  rm -f "$LOCK" || fail "cannot clear stale lock $LOCK"
  ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null || fail "cannot take lock $LOCK"
  LOCK_HELD=1
}
LOCK_HELD=0
release_lock() { [[ "$LOCK_HELD" == "1" ]] && rm -f "$LOCK"; }
trap release_lock EXIT INT TERM

acquire_lock
MANIFEST="$EVID/manifest.tsv"

# --- guards, all before the first run and none of them a promise ------------
[[ -d "$OVERLAY_DIR" ]] || fail "overlay directory missing: $OVERLAY_DIR"
nfiles="$(find "$OVERLAY_DIR" -type f | wc -l | tr -d ' ')"
[[ "$nfiles" == "1" ]] \
  || fail "overlay holds $nfiles files; phases-v1.0 is exactly one agent definition."
[[ -f "$OVERLAY_FILE" ]] \
  || fail "overlay's one file is not .claude/agents/backend-feature-phases.md"

got_sha="$(shasum -a 256 "$OVERLAY_FILE" | awk '{print $1}')"
[[ "$got_sha" == "$EXPECT_OVERLAY_SHA" ]] \
  || fail "overlay is $got_sha, registered $EXPECT_OVERLAY_SHA - the treatment moved."

# The overlay must DECLARE a tools: line. The declared-vs-delivered COMPARISON itself is the
# runner's (exit 9) and lib/check-init-schema.sh's, whose per-run output lands in $EVID/init-schema/;
# keeping a second copy of the expected list here would be a second source that can drift.
grep -q '^tools:' "$OVERLAY_FILE" \
  || fail "overlay declares no tools: line; author decision 8's read-back has nothing to assert."

got_tree="$(git -C "$BENCH_REPO" rev-parse "HEAD:$TASK_DIR" 2>/dev/null)"
[[ "$got_tree" == "$EXPECT_TREE" ]] \
  || fail "$BENCHMARK tree is ${got_tree:-absent}, registered $EXPECT_TREE - the task moved."
got_bench="$(git -C "$BENCH_REPO" rev-parse HEAD)"

LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
[[ -n "$LAUNCH_CLAUDE" ]] || fail "cannot read the claude version; the runtime is unidentified."

pred_at="$(git -C "$LAB" log --format=%cI -1 "$PRED_COMMIT" 2>/dev/null)" \
  || fail "prediction commit $PRED_COMMIT is not in this repository."
[[ -n "$pred_at" ]] || fail "prediction commit $PRED_COMMIT has no timestamp."
pred_epoch="$(date -j -f '%Y-%m-%dT%H:%M:%S%z' "${pred_at/Z/+0000}" +%s 2>/dev/null)" || pred_epoch=""
now_epoch="$(date +%s)"
if [[ -n "$pred_epoch" && "$now_epoch" -le "$pred_epoch" ]]; then
  fail "the clock says the first run would start at or before the prediction commit."
fi
echo "run-b5-batch: prediction $PRED_COMMIT committed $pred_at; first run starts after it"

# The API must be the LIVE one. 8081 on this host is a leaked forward that accepts a
# connection and answers nothing — an unchecked port is how a whole batch posts into a void.
api_n="$(curl -s -m 10 "http://127.0.0.1:${API_PORT}/api/runs" | jq 'length' 2>/dev/null)"
[[ "$api_n" =~ ^[0-9]+$ ]] \
  || fail "the API at 127.0.0.1:$API_PORT did not return a run list; refusing to spend a batch on a dead endpoint."
echo "run-b5-batch: API 127.0.0.1:$API_PORT holds $api_n run(s) before this batch"

busy="$(LC_ALL=C pgrep -fl 'bin/opencode|run-agent.sh' 2>/dev/null | grep -v "$$" || true)"
[[ -z "$busy" ]] || echo "run-b5-batch: WARNING - other work is live; durations may be contaminated:
$busy" >&2

if [[ "${B5_GUARDS_ONLY:-0}" == "1" ]]; then
  echo "run-b5-batch: GUARDS ONLY — every guard passed, nothing was run."
  exit 0
fi

ARM_COMMON=(
  RUNTIME=claude
  "BENCHMARK=$BENCHMARK"
  "EXPERIMENT=$EXPERIMENT_KEY"
  "MODEL=$EXPECT_MODEL"
  ISOLATE_USER_SETTINGS=1
  KEEP=1
  "API_PORT=$API_PORT"
  "OTLP_HTTP_PORT=${B5_OTLP_HTTP_PORT:-14318}"
  "OTLP_GRPC_PORT=${B5_OTLP_GRPC_PORT:-14317}"
  "TEMPO_PORT=${B5_TEMPO_PORT:-13200}"
  "INIT_SCHEMA_DIR=$EVID/init-schema"
)
ARM_T=( "CUSTOMIZATION=$OVERLAY_DIR" AGENT=backend-feature-phases VARIANT=phases-v1.0 )
ARM_C=( VARIANT=baseline )

EVENTS="$OBS/infra/telemetry-out/events.jsonl"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }

mkdir -p "$EVID/init-schema" || fail "cannot create $EVID"

{
  echo "# B5 $BENCHMARK $STAMP  key=$EXPERIMENT_KEY pairs=$PAIRS start=$START"
  echo "# overlay $EXPECT_OVERLAY_SHA (runner form $EXPECT_AGENT_HASH), one file, declares tools:"
  echo "# $BENCHMARK tree $EXPECT_TREE at benchmarks $got_bench"
  echo "# claude $LAUNCH_CLAUDE at launch, asserted constant per run · model $EXPECT_MODEL"
  echo "# prediction commit $PRED_COMMIT at $pred_at"
  echo "# common:      ${ARM_COMMON[*]}"
  echo "# treated adds:${ARM_T[*]}"
  echo "# control adds:${ARM_C[*]}"
  printf 'seq\tarm\trun_id\texit\tworktree\tagent_hash\tinstr_hash\tdeleg_stream\tdeleg_telemetry\tclaude\n'
} > "$MANIFEST"

{ echo "batch start (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "events.jsonl bytes at start: $(events_bytes)"; } | tee "$EVID/window.txt"

read_back() {
  # customization.{agentHash,instructionsHash} from the API, three tries. "UNREAD" is NOT a
  # pass; §4 step 7 re-reads every hash from the API before any sheet is opened.
  local rid="$1" out
  for _ in 1 2 3; do
    out="$(curl -s -m 10 "http://127.0.0.1:${API_PORT}/api/runs/${rid}" 2>/dev/null \
           | jq -r 'if .customization then ((.customization.agentHash // "null")+" "+(.customization.instructionsHash // "null")) else empty end' 2>/dev/null)"
    [[ -n "$out" ]] && { echo "$out"; return 0; }
    sleep 3
  done
  echo "UNREAD UNREAD"
}

LAST_RC=0; LAST_AGENT=""; LAST_INSTR=""; LAST_DELEG=0
one_run() {
  local arm="$1" seq="$2"; shift 2
  local log="$EVID/${seq}-${arm}.log"
  echo ""; echo "======== $BENCHMARK $seq $arm ========"
  ( cd "$OBS" && make run-benchmark "${ARM_COMMON[@]}" "$@" ) > "$log" 2>&1
  local rc=$? rid wt deleg tdeleg pair cv
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  deleg="$(grep -acE '"(name|tool_name)":"(Task|Agent)"' "$log" 2>/dev/null)"; deleg="${deleg:-0}"
  tdeleg=0
  if [[ -n "$rid" && -f "$EVENTS" ]]; then
    tdeleg="$(grep -a "$rid" "$EVENTS" 2>/dev/null | grep -acE '"(name|tool_name)":"(Task|Agent)"')"
    tdeleg="${tdeleg:-0}"
  fi
  pair="null null"; [[ -n "$rid" ]] && pair="$(read_back "$rid")"
  cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:-NONE}" "$rc" "${wt:-NONE}" "${pair% *}" "${pair#* }" "$deleg" "$tdeleg" "${cv:-UNREAD}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} exit=$rc agentHash=${pair% *} instrHash=${pair#* } deleg stream=$deleg telemetry=$tdeleg claude=$cv"
  LAST_RC=$rc; LAST_AGENT="${pair% *}"; LAST_INSTR="${pair#* }"; LAST_DELEG="$deleg"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] \
    || abort_batch "claude moved mid-batch: $LAUNCH_CLAUDE at launch, $cv at $seq $arm."
  return $rc
}

abort_batch() {
  echo "!! $*" >&2
  echo "!! The batch STOPS here (decision-rule row 0a). It is redesigned, not resumed." >&2
  { echo "batch aborted (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "events.jsonl bytes at abort: $(events_bytes)"; } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit 8
}

for i in $(seq "$START" $((START + PAIRS - 1))); do
  s="$(printf '%02d' "$i")"

  one_run treated "$s" "${ARM_T[@]}"
  if [[ $LAST_RC -eq 9 ]]; then
    echo "!! treated $s returned 9 — the delivered tool schema is not the declared one." >&2
    { echo "batch aborted (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"; } | tee -a "$EVID/window.txt"
    echo "manifest: $MANIFEST"; exit 9
  fi
  [[ "$LAST_AGENT" == "$EXPECT_AGENT_HASH" || "$LAST_AGENT" == "UNREAD" ]] \
    || abort_batch "treated $s read back agentHash=$LAST_AGENT, registered $EXPECT_AGENT_HASH: the treatment did not arrive."
  [[ "$LAST_INSTR" == "null" || "$LAST_INSTR" == "UNREAD" ]] \
    || abort_batch "treated $s read back instructionsHash=$LAST_INSTR: an unregistered instruction file arrived."
  [[ "$LAST_DELEG" == "0" ]] \
    || abort_batch "treated $s shows $LAST_DELEG delegation event(s); its tools: line declares no Task."

  one_run control "$s" "${ARM_C[@]}"
  [[ "$LAST_AGENT" == "null" || "$LAST_AGENT" == "UNREAD" ]] \
    || abort_batch "control $s read back agentHash=$LAST_AGENT: a control received the overlay."
  [[ "$LAST_INSTR" == "null" || "$LAST_INSTR" == "UNREAD" ]] \
    || abort_batch "control $s read back instructionsHash=$LAST_INSTR: a control received an instruction file."
  # RECORDED, NOT FATAL, AND WRITTEN EVEN WHEN ZERO — threat 7's executable half.
  echo "control $s delegation: stream=$LAST_DELEG telemetry-derived column in manifest" >> "$EVID/control-delegations.txt"
  [[ "$LAST_DELEG" == "0" ]] \
    && echo "run-b5-batch: control $s did not delegate (0)" \
    || echo "run-b5-batch: NOTE - control $s delegated ($LAST_DELEG stream event(s)). Recorded, batch continues." >&2
done

{ echo "batch end   (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "events.jsonl bytes at end: $(events_bytes)"; } | tee -a "$EVID/window.txt"
echo ""; echo "manifest: $MANIFEST"
column -t -s "$(printf '\t')" "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
