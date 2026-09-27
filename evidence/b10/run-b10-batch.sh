#!/usr/bin/env bash
# THE REGISTERED B10 BATCH — spine stop 21, E-024 (BE-003) and E-025 (BE-004).
#
#   ./evidence/b10/run-b10-batch.sh [N] [TASK ...]      # default N=5, tasks BE-003 BE-004
#   ./evidence/b10/run-b10-batch.sh --resume 20260927T120000Z
#
# One codex arm pair per task, interleaved control-then-treated, n=5 per arm per task = 20 runs.
# The treated arm carries build/customizations/agent-v1.2-knowledge-codex (nine files). The
# control carries NO overlay at all, which is what E-024's control assertion registers: all five
# customization.*Hash null, READ BACK from the record rather than inferred from the absent flag.
#
# WHAT THIS DRIVER REFUSES, AND WHY EACH REFUSAL EXISTS RATHER THAN BEING A COMMENT:
#
#   exit 5  the overlay's digests are not the registered ones. Registered BEFORE the batch as
#           EXACT VALUES, not as "non-null" — a delivery proof that only asserts non-null passes
#           when the wrong overlay is installed. Checked from the directory on disk, once, before
#           run one, because §4 step 4 forbids editing a tool while a run of it is in flight and
#           the same logic forbids discovering a bad overlay at run twelve.
#   exit 6  the 20-run ceiling. THERE IS NO DOLLAR CEILING AND THAT IS NOT AN OMISSION:
#           estimatedCost is null on 8 of 8 codex runs ever recorded, so a dollar ceiling cannot
#           fire on this arm (E-024 `## Runs`). Stop 20 learned the harder version of this — its
#           ceiling accumulated from a null field and stayed $0, so a stop rule that reads a
#           field the run does not populate is not a control. Runs and wall-clock are fields this
#           driver populates itself.
#   exit 7  the 4-hour wall-clock ceiling, from the stored codex durations on BE-003 (median 115 s).
#   exit 8  a second batch. A pid lock, because a duplicate run is evidence that cannot be deleted.
#   exit 13 a --resume TAG that is not a batch tag.
#
# AND WHAT IT DOES *NOT* REFUSE, DELIBERATELY: a treated run whose hashes come back null. That is
# E-024's row 0a — a VOID verdict computed from the count, not a crash — so the run is RECORDED
# with its nulls and the driver keeps going. The count is printed at the end. A driver that died
# there would convert a measurable delivery failure into a missing measurement.
#
# THE MANIFEST IS THE PROGRESS RECORD. A row is appended for a cell as soon as it finishes, and
# `--resume` skips every (task, seq, arm) already in it. So a resumed launch NEVER re-runs a
# recorded cell — §0's one outright prohibition.
#
# B10_RUNNER exists so the fixture set can stub the runner. A verify-*.sh that invokes the real
# run-agent.sh can start a paid run, which is a defect in the fixture: case O of
# verify-b9-df-guards.sh did exactly that and was killed after 110 s.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="${B10_OBS:-$(cd ../agent-observatory && pwd)}" || exit 1

OVERLAY_T="${B10_OVERLAY_T:-$LAB/build/customizations/agent-v1.2-knowledge-codex}"
MODEL="${B10_MODEL:-gpt-5.6-sol}"
RUNTIME="${B10_RUNTIME:-codex}"
EXPECT_INSTR_T="${B10_EXPECT_INSTR_T:-sha256:ebf489800a60a156986f98ea4f127848}"
EXPECT_KNOWLEDGE_T="${B10_EXPECT_KNOWLEDGE_T:-sha256:0770219ae7f4281a80071d78dadea285}"
MAX_RUNS="${B10_MAX_RUNS:-20}"
MAX_SECONDS="${B10_MAX_SECONDS:-14400}"
RUNNER="${B10_RUNNER:-runner/run-agent.sh}"

# EXPORTED, AND WITH THE SCHEME ON THE GRPC ENDPOINT. run-agent.sh reads API from its own
# environment and defaults to localhost:8080, which is taken on this machine. And a scheme-less
# OTLP_GRPC_ENDPOINT makes the otlp preflight print `answered 200` while every estimatedCost,
# modelCalls and toolCalls comes back NULL — curl normalises a bare host:port and the exporter
# does not. Copied from evidence/b09/run-b9-batch.sh:80-84 rather than retyped.
export API="${B10_API:-http://127.0.0.1:8081}"
export WEB="${B10_WEB:-http://localhost:5174}"
export TEMPO_URL="${B10_TEMPO:-http://localhost:3200}"
export OTLP_HTTP_ENDPOINT="${B10_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B10_OTLP_GRPC:-http://localhost:4317}"

RESUME_TAG="${B10_RESUME_TAG:-}"
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --resume) RESUME_TAG="${2:-}"; shift 2 || true ;;
    *) echo "run-b10-batch: unknown flag $1 (only --resume <TAG>)" >&2; exit 2 ;;
  esac
done
if [[ -n "$RESUME_TAG" && ! "$RESUME_TAG" =~ ^[0-9]{8}T[0-9]{6}Z$ ]]; then
  echo "run-b10-batch: --resume wants a batch TAG like 20260927T120000Z, got '$RESUME_TAG'" >&2
  exit 13
fi

N="${B10_N:-5}"
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then N="$1"; shift; fi
TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)

# --- the pid lock ---------------------------------------------------------------------------
LOCK="$LAB/evidence/b10/.batch.lock"
if [[ -e "$LOCK" ]]; then
  other="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$other" ]] && kill -0 "$other" 2>/dev/null; then
    echo "run-b10-batch: a batch is already running as pid $other ($LOCK). Refusing." >&2
    exit 8
  fi
  echo "run-b10-batch: stale lock for pid ${other:-?}, taking it over" >&2
fi
echo "$$" > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

# --- exit 5: the overlay is the registered one, checked before run one ----------------------
# Computed the way the runner computes them (run-agent.sh:572-576 and :653-668), so a mismatch
# here is a mismatch there. The port's mode bits are checked too: stop 20's deliberate failure
# shipped an unexecutable router.sh, both hashes were IDENTICAL to the measured overlay, and the
# registered driver did not refuse it. A digest over (path, content) is blind to a mode bit.
instr_digest() { printf 'sha256:%s' "$(shasum -a 256 "$1/AGENTS.md" | cut -c1-32)"; }
knowledge_digest() {
  ( cd "$1" && find .ai/knowledge -type f 2>/dev/null | LC_ALL=C sort \
    | while IFS= read -r f; do printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done ) \
    | shasum -a 256 | cut -c1-32 | sed 's/^/sha256:/'
}
GOT_INSTR="$(instr_digest "$OVERLAY_T")"
GOT_KNOW="$(knowledge_digest "$OVERLAY_T")"
if [[ "$GOT_INSTR" != "$EXPECT_INSTR_T" || "$GOT_KNOW" != "$EXPECT_KNOWLEDGE_T" ]]; then
  echo "run-b10-batch: the treated overlay is not the registered one. Refusing to start." >&2
  echo "  instructionsHash want $EXPECT_INSTR_T got $GOT_INSTR" >&2
  echo "  knowledgeHash    want $EXPECT_KNOWLEDGE_T got $GOT_KNOW" >&2
  exit 5
fi
NOEXEC="$(find "$OVERLAY_T" -type f -name '*.sh' ! -perm -u+x | wc -l | tr -d ' ')"
if [[ "$NOEXEC" != 0 ]]; then
  echo "run-b10-batch: $NOEXEC shell file(s) in the overlay are not executable, and NO HASH" >&2
  echo "  WOULD HAVE SEEN THAT — stop 20's deliberate failure is the precedent. Refusing." >&2
  exit 5
fi

TAG="${RESUME_TAG:-$(date -u +%Y%m%dT%H%M%SZ)}"
# B10_EVID_ROOT exists so the fixture set writes its stub batches into a temp directory instead
# of littering evidence/b10 with manifests full of stub uuids. Sixteen of those appeared on the
# first run of verify-b10-batch-guards.sh, and a directory that looks like a recorded batch but
# is a fixture artefact is exactly the kind of thing a later reader cites by mistake.
EVID="${B10_EVID_ROOT:-$LAB/evidence/b10}/batch-$TAG"
mkdir -p "$EVID"
MANIFEST="$EVID/manifest.tsv"
STARTED_AT="$(date +%s)"

if [[ ! -s "$MANIFEST" ]]; then
{
  printf '# B10 REGISTERED BATCH %s  n=%s per arm per task, interleaved control-then-treated\n' "$TAG" "$N"
  printf '# runtime %s  model %s  treated overlay %s  control NO OVERLAY\n' "$RUNTIME" "$MODEL" "$OVERLAY_T"
  printf '# expected treated instructionsHash %s / knowledgeHash %s; control ALL FIVE null\n' \
    "$EXPECT_INSTR_T" "$EXPECT_KNOWLEDGE_T"
  printf '# ceiling %s runs and %s s of wall-clock. NO DOLLAR CEILING: estimatedCost is null on\n' "$MAX_RUNS" "$MAX_SECONDS"
  printf '#   8 of 8 codex runs ever recorded, so a dollar ceiling cannot fire on this arm.\n'
  printf '# codex %s at launch, benchmarks %s\n' \
    "$(codex --version 2>/dev/null | head -1)" "$(git -C ../agent-observatory-benchmarks rev-parse --short HEAD 2>/dev/null)"
  printf '# prediction commits 05aaf3e (E-024, E-025) at 2026-09-27, BEFORE any run here\n'
  printf 'task\tseq\tarm\trun_id\trc\teval\truntime_ver\tmodel\tinstr_hash\tknowledge_hash\tskills_hash\tagent_hash\tagents_hash\tdelivery\trouter_log\trouter_lines\tcorpus_contact\tmodel_calls\ttool_calls\tcost\ttokens\tduration_ms\tchanged\tworktree\n'
} > "$MANIFEST"
fi

api() { curl -s -m 20 "$API/api/runs/$1" 2>/dev/null; }
done_cell() {  # done_cell <task> <seq> <arm>
  awk -F'\t' -v t="$1" -v s="$2" -v a="$3" '$1==t && $2==s && $3==a {found=1} END {exit !found}' "$MANIFEST"
}

# SEEDED FROM THE MANIFEST, not from zero. A --resume that restarted the count would make the
# 20-run ceiling a per-invocation ceiling, i.e. no ceiling at all across three resumes. Stop 20's
# ceiling failed for the mirror-image reason: it accumulated from a field the run left null.
RUNS="$(awk -F'\t' '$1 ~ /^BE-/ {n++} END {print n+0}' "$MANIFEST")"
VOID="$(awk -F'\t' '$1 ~ /^BE-/ && $14=="VOID-0a" {n++} END {print n+0}' "$MANIFEST")"
H_COUNT="$(awk -F'\t' '$1 ~ /^BE-/ && $17=="router" {n++} END {print n+0}' "$MANIFEST")"
echo "run-b10-batch: manifest already holds $RUNS run(s); ceiling is $MAX_RUNS"
mkdir -p "$EVID/router-logs"

one() {  # one <task> <arm> <seq>
  local task="$1" arm="$2" seq="$3" key log rc rid wt rec
  key="EXP-B10-RUNTIME-PORT-$(echo "$task" | tr -d '-')"
  log="$EVID/${task}-${seq}-${arm}.log"
  if done_cell "$task" "$seq" "$arm"; then
    echo "  $task $seq $arm already in the manifest — SKIPPED, never re-run"
    return 0
  fi
  local elapsed=$(( $(date +%s) - STARTED_AT ))
  if (( RUNS >= MAX_RUNS )); then
    echo "run-b10-batch: the $MAX_RUNS-run ceiling is reached. Stopping, and the population that" >&2
    echo "  occurred is what E-024 row 0b says to report." >&2
    exit 6
  fi
  if (( elapsed >= MAX_SECONDS )); then
    echo "run-b10-batch: the ${MAX_SECONDS}s wall-clock ceiling is reached at ${elapsed}s. Stopping." >&2
    exit 7
  fi
  echo ""; echo "======== $task $seq $arm  key=$key  $(date -u +%H:%M:%SZ)  elapsed ${elapsed}s ========"
  local -a args=(--runtime "$RUNTIME" --benchmark "$task" --experiment "$key" --model "$MODEL"
                 --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then
    args+=(--customization "$OVERLAY_T" --variant agent-v1.2-knowledge-codex)
  else
    args+=(--variant plain)
  fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" "$RUNNER" "${args[@]}" ) > "$log" 2>&1
  rc=$?
  RUNS=$((RUNS+1))
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  local ih kh sh ah gh ver mc tc cost tok dur chg ev
  ih="$(printf '%s' "$rec"  | jq -r '.customization.instructionsHash // "null"')"
  kh="$(printf '%s' "$rec"  | jq -r '.customization.knowledgeHash // "null"')"
  sh="$(printf '%s' "$rec"  | jq -r '.customization.skillsHash // "null"')"
  ah="$(printf '%s' "$rec"  | jq -r '.customization.agentHash // "null"')"
  gh="$(printf '%s' "$rec"  | jq -r '.customization.agentsHash // "null"')"
  ver="$(printf '%s' "$rec" | jq -r '.runtime.version // "null"')"
  mc="$(printf '%s' "$rec"  | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"  | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec"| jq -r '.efficiency.estimatedCost // "null"')"
  tok="$(printf '%s' "$rec" | jq -r '.efficiency.reportedTotalTokens // "null"')"
  dur="$(printf '%s' "$rec" | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec" | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"  | jq -r '.evaluation.exitCode // "null"')"

  # --- the delivery verdict, per run, from the RECORD and not from the flag ----------------
  # Row 0a of both decision rules. A treated run missing either hash, or a control carrying ANY
  # hash, is VOID BEFORE SCORING. Recorded, counted, not fatal.
  local delivery="ok"
  if [[ "$arm" == treated ]]; then
    [[ "$ih" == "$EXPECT_INSTR_T" && "$kh" == "$EXPECT_KNOWLEDGE_T" ]] || delivery="VOID-0a"
  else
    [[ "$ih" == null && "$kh" == null && "$sh" == null && "$ah" == null && "$gh" == null ]] || delivery="VOID-0a"
  fi
  [[ "$delivery" == "VOID-0a" ]] && VOID=$((VOID+1))

  # --- corpus contact, defined exactly as stop 20 defined it -------------------------------
  # H is "the router's log is non-empty". Stop 20's census found that H therefore counts ROUTER
  # INVOCATIONS and not corpus consultations — one run read index.yaml by hand and never ran the
  # router. Both numbers are recorded here so the same gap is visible without a second census.
  # THE LOG IS NOT IN THE WORKTREE. router.sh:51 writes it to
  # $TMPDIR/knowledge-log-<basename of the worktree>.jsonl, deliberately — inside the repository
  # under test it would have landed in the agent's own diff and the evaluator counts changed
  # files. AND $TMPDIR IS REAPED BY macOS IN ABOUT THREE DAYS, so it is COPIED into the evidence
  # directory here, at the end of the run that wrote it, rather than read days later.
  local rlog="none" rlines=0 contact="no" src
  src="${TMPDIR:-/tmp}/knowledge-log-observatory-run-${rid:-none}.jsonl"
  if [[ -s "$src" ]]; then
    rlog="$EVID/router-logs/$(basename "$src")"
    cp "$src" "$rlog"
    rlines="$(wc -l < "$rlog" | tr -d ' ')"
    contact="router"
    H_COUNT=$((H_COUNT+1))
  elif /usr/bin/grep -aqE '\.ai/knowledge|index\.yaml|kotlin-exhaustive-when' "$log"; then
    # Corpus contact WITHOUT a router invocation. Stop 20 found exactly one of these and it is
    # the reason H is a floor and not a point estimate: H counts router calls, and a run that
    # read index.yaml by hand consulted the corpus without ever appearing in H.
    contact="by-hand"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$seq" "$arm" "${rid:-none}" "$rc" "$ev" "$ver" "$MODEL" "$ih" "$kh" "$sh" "$ah" "$gh" \
    "$delivery" "${rlog:-none}" "$rlines" "$contact" "$mc" "$tc" "$cost" "$tok" "$dur" "$chg" "${wt:-none}" \
    >> "$MANIFEST"
  echo "  rc=$rc eval=$ev delivery=$delivery instr=$ih knowledge=$kh contact=$contact tokens=$tok"
}

for ((i=1;i<=N;i++)); do
  seq="$(printf '%02d' "$i")"
  for task in "${TASKS[@]}"; do
    one "$task" control "$seq"
    one "$task" treated "$seq"
  done
done

echo ""
echo "======== batch $TAG finished: $RUNS runs, $VOID void on delivery, H=$H_COUNT ========"
echo "manifest $MANIFEST"
