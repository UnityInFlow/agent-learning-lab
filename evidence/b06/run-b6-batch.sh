#!/usr/bin/env bash
# B6 — one specialist skill. The interleaved batch driver for BOTH tasks.
#
#   BENCHMARK=BE-003 EXPERIMENT_KEY=EXP-B6-SKILL-BE003 ./evidence/b06/run-b6-batch.sh
#   BENCHMARK=BE-004 EXPERIMENT_KEY=EXP-B6-SKILL-BE004 ./evidence/b06/run-b6-batch.sh
#   B6_GUARDS_ONLY=1 ... — every guard runs, nothing is spent.
#
# Descended from evidence/b05/run-b5-batch.sh — same lock, same pair loop, same manifest-as-
# progress-record, same "a duplicate benchmark run is evidence you cannot delete". What is
# DIFFERENT, and why each difference exists:
#
#   a. BOTH ARMS CARRY AN AGENT OVERLAY. B5 compared an agent against a plain baseline, so it
#      guarded agentHash non-null on treated and null on control. Here the agent is the CARRIER
#      and is IDENTICAL ON BOTH ARMS (51ffaedf9a3edbfe); the single variable is the skill
#      directory, read back as customization.skillsHash — non-null treated, NULL control. A
#      control whose agentHash differs from the treated arm's is a failed batch, not a control.
#
#   b. THE CARRIER IS NOT phases-v1.0 AND THAT IS DISCLOSED, NOT HIDDEN. phases-v1.0 declares
#      `tools: Read, Edit, Write, Bash` — no `Skill` — and its measured init read-back is n=4.
#      A skill cannot be selected by an agent that has no Skill tool, so on phases-v1.0 the
#      treatment CANNOT BE DELIVERED at all (evidence/b06/preflight/, run fbe8c643). §6 forbids
#      editing a measured version, so phases-v1.0 IS NOT EDITED: the carrier is a new overlay
#      differing from it by ONE LINE and installed on BOTH ARMS.
#
#   c. ACTIVATION IS AN OUTCOME, NOT A GUARD. Delivery is `skillsHash` — the file arrived.
#      Selection is the activation record — the model chose it. A treated run with a delivered
#      skill and zero activations is a REAL DATUM about selection, not a broken run, so it is
#      RECORDED AND THE BATCH CONTINUES. The arm-level "installed and never selected" void
#      condition is evaluated at §4 step 8, over the arm, never per run.
#
#   d. NEITHER ARM MAY DELEGATE. Both arms' tools: line declares no `Task`, so a delegation on
#      EITHER arm is the E-005 failure mode (the runtime handing the model an undeclared tool)
#      and aborts. B5's asymmetry existed only because its control was a plain baseline.
#
#   e. EVERY EXPECTATION IS OVERRIDABLE BY ENV so each guard can be SHOWN TO REJECT before the
#      batch spends anything; evidence/b06/verify-b6-batch-guards.sh drives exactly that.
#
# Exit 0 batch complete · 4 another batch holds the lock · 8 treatment undelivered, control
#        contaminated, or an arm delegated · 9 the runner reported an undelivered declared tool
#        set · 1 a guard refused before any run was made.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

if command -v caffeinate >/dev/null 2>&1 && [[ "${B6_CAFFEINATED:-0}" != "1" ]]; then
  echo "run-b6-batch: re-executing under caffeinate -i so the batch cannot span an idle sleep"
  B6_CAFFEINATED=1 exec caffeinate -i "$0" "$@"
fi
[[ "${B6_CAFFEINATED:-0}" == "1" ]] \
  || echo "run-b6-batch: WARNING - caffeinate unavailable, an idle sleep can contaminate durations" >&2

LAB="$(pwd)"
OBS="$(cd "$LAB/../agent-observatory" && pwd)" || exit 1
BENCH_REPO="$LAB/../agent-observatory-benchmarks"

BENCHMARK="${BENCHMARK:?set BENCHMARK=BE-003 or BE-004}"
EXPERIMENT_KEY="${EXPERIMENT_KEY:?set EXPERIMENT_KEY}"
PAIRS="${PAIRS:-10}"
START="${START:-1}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
CELL="$LAB/evidence/b06"
EVID="$CELL/batch-$BENCHMARK-$STAMP"
LOCK="${B6_LOCK:-$CELL/.batch.lock}"
API_PORT="${B6_API_PORT:-18081}"

TREATED_DIR="${B6_TREATED_DIR:-$LAB/build/customizations/phases-v1.0-skillcarrier}"
CONTROL_DIR="${B6_CONTROL_DIR:-$LAB/build/customizations/phases-v1.0-skillcarrier-control}"
AGENT_REL=".claude/agents/backend-feature-phases.md"
SKILL_REL=".claude/skills/testing-and-verification/SKILL.md"
EXPECT_AGENT_SHA="${B6_EXPECT_AGENT_SHA:-51ffaedf9a3edbfe5fd85009f70f84c5}"     # first 32 hex
EXPECT_SKILL_SHA="${B6_EXPECT_SKILL_SHA:-7bea904863fb79a544ee2068cb2f0f43}"     # the FILE on disk
# The runner's `customization.skillsHash` is NOT the sha of SKILL.md. It hashes the skills
# SUBTREE, and it is a different number: 61445ead… against the file's 7bea9048…. The first
# batch was aborted at pair 01 by a guard that asserted the file sha against the read-back —
# a guard registered against the wrong quantity, which is the same class of defect as a
# control reporting success over a scope smaller than it claims, and it cost one run
# (4452e08a, excluded by name in E-012 before any scoring).
#
# THE LESSON, RECORDED WHERE IT HAPPENED: verify-b6-batch-guards.sh drives the driver with
# B6_GUARDS_ONLY=1, so it can only ever exercise guards that fire BEFORE the first run. A
# per-run read-back guard is structurally invisible to that fixture set. The proof for this
# one is therefore the probe manifests, where the same value appears on six independent runs
# (evidence/b06/probe-v1.1, probe-carrier, selection-rate).
EXPECT_SKILLS_HASH="${B6_EXPECT_SKILLS_HASH:-61445ead85042e340435613314920ef8}"  # the READ-BACK
EXPECT_MODEL="${B6_EXPECT_MODEL:-claude-haiku-4-5-20251001}"

case "$BENCHMARK" in
  BE-003) TASK_DIR="tasks/BE-003-confirm-shipment"
          EXPECT_TREE="${B6_EXPECT_TREE:-eeb15a753adc94e92bc3f74c50e1b02fc3b53030}"
          PRED_COMMIT="${PRED_COMMIT:-133de65}" ;;
  BE-004) TASK_DIR="tasks/BE-004-cancel-order"
          EXPECT_TREE="${B6_EXPECT_TREE:-4ff79f7b157b2ae344036ebec60e1841b0ab9762}"
          PRED_COMMIT="${PRED_COMMIT:-133de65}" ;;
  *) echo "run-b6-batch: BENCHMARK must be BE-003 or BE-004, got $BENCHMARK" >&2; exit 1 ;;
esac

fail() { echo "run-b6-batch: $*" >&2; exit 1; }

acquire_lock() {
  if ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null; then LOCK_HELD=1; return 0; fi
  local holder; holder="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$holder" ]] && kill -0 "$holder" 2>/dev/null; then
    echo "run-b6-batch: REFUSING TO START. A batch is already running under pid $holder." >&2
    echo "run-b6-batch: lock $LOCK. Read its manifest before deciding anything is dead:" >&2
    echo "run-b6-batch: a duplicate benchmark run is evidence you then cannot delete." >&2
    exit 4
  fi
  echo "run-b6-batch: stale lock from pid ${holder:-unknown} (no such process) — clearing it" >&2
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
for d in "$TREATED_DIR" "$CONTROL_DIR"; do
  [[ -d "$d" ]] || fail "overlay directory missing: $d"
  [[ -f "$d/$AGENT_REL" ]] || fail "$d does not carry $AGENT_REL"
done
# The control-carries-a-skill case is checked FIRST, above the file counts, so its refusal names
# the actual defect rather than a file count that is only its symptom.
[[ -f "$CONTROL_DIR/$SKILL_REL" ]] && fail "the control overlay carries a skill; it is not a control."
tn="$(find "$TREATED_DIR" -type f | wc -l | tr -d ' ')"
cn="$(find "$CONTROL_DIR" -type f | wc -l | tr -d ' ')"
[[ "$tn" == "2" ]] || fail "treated overlay holds $tn files; it is exactly the agent and the skill."
[[ "$cn" == "1" ]] || fail "control overlay holds $cn files; it is exactly the agent."
[[ -f "$TREATED_DIR/$SKILL_REL" ]] || fail "treated overlay's second file is not $SKILL_REL"

ta="$(shasum -a 256 "$TREATED_DIR/$AGENT_REL" | cut -c1-32)"
ca="$(shasum -a 256 "$CONTROL_DIR/$AGENT_REL" | cut -c1-32)"
[[ "$ta" == "$ca" ]] \
  || fail "the two arms' agent files differ ($ta vs $ca); the skill would not be the only variable."
[[ "$ta" == "$EXPECT_AGENT_SHA" ]] \
  || fail "carrier agent is $ta, registered $EXPECT_AGENT_SHA - the carrier moved."
ts="$(shasum -a 256 "$TREATED_DIR/$SKILL_REL" | cut -c1-32)"
[[ "$ts" == "$EXPECT_SKILL_SHA" ]] \
  || fail "skill is $ts, registered $EXPECT_SKILL_SHA - the treatment moved."
grep -q '^tools:.*\bSkill\b' "$TREATED_DIR/$AGENT_REL" \
  || fail "the carrier's tools: line does not declare Skill; the skill could never be selected."

got_tree="$(git -C "$BENCH_REPO" rev-parse "HEAD:$TASK_DIR" 2>/dev/null)"
[[ "$got_tree" == "$EXPECT_TREE" ]] \
  || fail "$BENCHMARK tree is ${got_tree:-absent}, registered $EXPECT_TREE - the task moved."
got_bench="$(git -C "$BENCH_REPO" rev-parse HEAD)"

LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
[[ -n "$LAUNCH_CLAUDE" ]] || fail "cannot read the claude version; the runtime is unidentified."

pred_at="$(git -C "$LAB" log --format=%cI -1 "$PRED_COMMIT" 2>/dev/null)" \
  || fail "prediction commit $PRED_COMMIT is not in this repository."
[[ -n "$pred_at" ]] || fail "prediction commit $PRED_COMMIT has no timestamp."
echo "run-b6-batch: prediction $PRED_COMMIT committed $pred_at; first run starts after it"

api_n="$(curl -s -m 10 "http://127.0.0.1:${API_PORT}/api/runs" | jq 'length' 2>/dev/null)"
[[ "$api_n" =~ ^[0-9]+$ ]] \
  || fail "the API at 127.0.0.1:$API_PORT did not return a run list; refusing to spend a batch on a dead endpoint."
echo "run-b6-batch: API 127.0.0.1:$API_PORT holds $api_n run(s) before this batch"

busy="$(LC_ALL=C pgrep -fl 'bin/opencode|run-agent.sh' 2>/dev/null | grep -v "$$" || true)"
[[ -z "$busy" ]] || echo "run-b6-batch: WARNING - other work is live; durations may be contaminated:
$busy" >&2

if [[ "${B6_GUARDS_ONLY:-0}" == "1" ]]; then
  echo "run-b6-batch: GUARDS ONLY — every guard passed, nothing was run."
  exit 0
fi

ARM_COMMON=(
  RUNTIME=claude
  "BENCHMARK=$BENCHMARK"
  "EXPERIMENT=$EXPERIMENT_KEY"
  "MODEL=$EXPECT_MODEL"
  ISOLATE_USER_SETTINGS=1
  KEEP=1
  ENABLE_SKILLS=1
  AGENT=backend-feature-phases
  "API_PORT=$API_PORT"
  "OTLP_HTTP_PORT=${B6_OTLP_HTTP_PORT:-14318}"
  "OTLP_GRPC_PORT=${B6_OTLP_GRPC_PORT:-14317}"
  "TEMPO_PORT=${B6_TEMPO_PORT:-13200}"
  "INIT_SCHEMA_DIR=$EVID/init-schema"
)
ARM_T=( "CUSTOMIZATION=$TREATED_DIR" VARIANT=skill-v1.1-carrier )
ARM_C=( "CUSTOMIZATION=$CONTROL_DIR" VARIANT=carrier-control )

EVENTS="$OBS/infra/telemetry-out/events.jsonl"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }

mkdir -p "$EVID/init-schema" || fail "cannot create $EVID"
{
  echo "# B6 $BENCHMARK $STAMP  key=$EXPERIMENT_KEY pairs=$PAIRS start=$START"
  echo "# carrier agent $ta ON BOTH ARMS · skill file $ts on TREATED ONLY"
  echo "# treated runs must read back skillsHash sha256:$EXPECT_SKILLS_HASH (the skills SUBTREE hash, not the file's)"
  echo "# carrier = phases-v1.0's agent + Skill in tools:, one line; phases-v1.0 itself untouched"
  echo "# $BENCHMARK tree $EXPECT_TREE at benchmarks $got_bench"
  echo "# claude $LAUNCH_CLAUDE at launch, asserted constant per run · model $EXPECT_MODEL"
  echo "# prediction commit $PRED_COMMIT at $pred_at"
  echo "# common:      ${ARM_COMMON[*]}"
  echo "# treated adds:${ARM_T[*]}"
  echo "# control adds:${ARM_C[*]}"
  printf 'seq\tarm\trun_id\texit\tworktree\tagent_hash\tskill_hash\tinstr_hash\tskill_stream\tdeleg_stream\tclaude\n'
} > "$MANIFEST"

{ echo "batch start (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "events.jsonl bytes at start: $(events_bytes)"; } | tee "$EVID/window.txt"

read_back() {
  local rid="$1" out
  for _ in 1 2 3; do
    out="$(curl -s -m 10 "http://127.0.0.1:${API_PORT}/api/runs/${rid}" 2>/dev/null \
           | jq -r 'if .customization then ((.customization.agentHash // "null")+" "+(.customization.skillsHash // "null")+" "+(.customization.instructionsHash // "null")) else empty end' 2>/dev/null)"
    [[ -n "$out" ]] && { echo "$out"; return 0; }
    sleep 3
  done
  echo "UNREAD UNREAD UNREAD"
}

LAST_RC=0; LAST_AGENT=""; LAST_SKILL=""; LAST_INSTR=""; LAST_DELEG=0; LAST_SKACT=0
one_run() {
  local arm="$1" seq="$2"; shift 2
  local log="$EVID/${seq}-${arm}.log"
  echo ""; echo "======== $BENCHMARK $seq $arm ========"
  ( cd "$OBS" && make run-benchmark "${ARM_COMMON[@]}" "$@" ) > "$log" 2>&1
  local rc=$? rid wt deleg skact cv trip a s i
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  deleg="$(grep -acE '"(name|tool_name)":"(Task|Agent)"' "$log" 2>/dev/null)"; deleg="${deleg:-0}"
  skact="$(grep -acE '"(name|tool_name)":"Skill"' "$log" 2>/dev/null)"; skact="${skact:-0}"
  trip="UNREAD UNREAD UNREAD"; [[ -n "$rid" ]] && trip="$(read_back "$rid")"
  # `a s i` MUST be local (declared above). They were not on the first attempt, and `s` is the
  # caller`s loop label: the read clobbered it, so every control run was passed the skills hash
  # as its seq, every control log was written to the SAME filename, and each control log
  # overwrote the last. Two runs and two batch directories were spent finding that.
  read -r a s i <<<"$trip"
  cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:-NONE}" "$rc" "${wt:-NONE}" "$a" "$s" "$i" "$skact" "$deleg" "${cv:-UNREAD}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} exit=$rc agent=$a skill=$s instr=$i skillCalls=$skact deleg=$deleg claude=$cv"
  LAST_RC=$rc; LAST_AGENT="$a"; LAST_SKILL="$s"; LAST_INSTR="$i"; LAST_DELEG="$deleg"; LAST_SKACT="$skact"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] \
    || abort_batch "claude moved mid-batch: $LAUNCH_CLAUDE at launch, $cv at $seq $arm."
  return $rc
}

abort_batch() {
  echo "!! $*" >&2
  echo "!! The batch STOPS here. It is redesigned, not resumed." >&2
  { echo "batch aborted (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "events.jsonl bytes at abort: $(events_bytes)"; } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit 8
}

check_common() {
  local arm="$1" seq="$2"
  [[ "$LAST_AGENT" == "sha256:$EXPECT_AGENT_SHA" || "$LAST_AGENT" == "UNREAD" ]] \
    || abort_batch "$arm $seq read back agentHash=$LAST_AGENT, registered sha256:$EXPECT_AGENT_SHA: the carrier did not arrive."
  [[ "$LAST_INSTR" == "null" || "$LAST_INSTR" == "UNREAD" ]] \
    || abort_batch "$arm $seq read back instructionsHash=$LAST_INSTR: an unregistered instruction file arrived."
  [[ "$LAST_DELEG" == "0" ]] \
    || abort_batch "$arm $seq shows $LAST_DELEG delegation event(s); its tools: line declares no Task."
}

for i in $(seq "$START" $((START + PAIRS - 1))); do
  s="$(printf '%02d' "$i")"

  one_run treated "$s" "${ARM_T[@]}"
  [[ $LAST_RC -eq 9 ]] && { echo "!! treated $s returned 9 — delivered tool schema is not the declared one." >&2; exit 9; }
  check_common treated "$s"
  [[ "$LAST_SKILL" == "sha256:$EXPECT_SKILLS_HASH" || "$LAST_SKILL" == "UNREAD" ]] \
    || abort_batch "treated $s read back skillsHash=$LAST_SKILL, registered sha256:$EXPECT_SKILLS_HASH: the skill did not arrive."
  # RECORDED, NOT FATAL, AND WRITTEN EVEN WHEN ZERO. Selection is an outcome; see note (c).
  echo "treated $s skill invocations in stream: $LAST_SKACT" >> "$EVID/skill-selection.txt"

  one_run control "$s" "${ARM_C[@]}"
  check_common control "$s"
  [[ "$LAST_SKILL" == "null" || "$LAST_SKILL" == "UNREAD" ]] \
    || abort_batch "control $s read back skillsHash=$LAST_SKILL: a control received the skill."
  [[ "$LAST_SKACT" == "0" ]] \
    || abort_batch "control $s invoked Skill $LAST_SKACT time(s) with no skill installed."
done

{ echo "batch end   (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "events.jsonl bytes at end: $(events_bytes)"; } | tee -a "$EVID/window.txt"
echo ""; echo "manifest: $MANIFEST"
column -t -s "$(printf '\t')" "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
