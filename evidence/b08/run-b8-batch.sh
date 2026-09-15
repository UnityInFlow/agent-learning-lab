#!/usr/bin/env bash
#
# run-b8-batch — §4 step 6 for stop 17. THE REGISTERED BATCH: n = 10 per arm per task,
# interleaved treated/control so a drift in the machine or the service hits both arms alike.
#
# WHAT IS DIFFERENT FROM run-b7-batch.sh, and why each difference is here:
#
#   1. IT CALLS runner/run-agent.sh DIRECTLY instead of `make run-benchmark`.
#      The Makefile defaults OTLP_HTTP_PORT/OTLP_GRPC_PORT to 4318/4317 (Makefile:24-25),
#      and on THIS machine those two ports are LEAKED limactl listeners with nothing behind
#      them: POST http://localhost:4318/v1/traces answers 000. The live collector is on
#      14318/14317 through the colima tunnel, and the API on 127.0.0.1:18081 — not :8081,
#      which answers 000 and belongs to a second, empty stack. A run that reaches the wrong
#      collector records null modelCalls and null cost, which looks exactly like a run that
#      made no model calls. Calling the runner directly means the three endpoints are stated
#      here, in one place, and cannot be re-defaulted by an -include of a file this script
#      cannot even read (infra/.env is unreadable to this user).
#
#   2. THE DELIVERY PROOF IS THE RUN-STATE FILE, not a policy log.
#      Both overlays carry .ai/hooks/policy-gate.sh, so a policy event proves nothing about
#      B8's treatment. What only the treated overlay has is the PreToolUse/Bash +
#      PostToolUse/Bash pair, and `repair-limit.sh` writes
#      ${TMPDIR}/run-state-observatory-run-<runId>.json on the FIRST Bash call whatever its
#      outcome. So: PRESENT on treated, ABSENT on control, per E-018/E-019 P1 — and P1 is a
#      gate on the whole experiment (decision rule row 0: two failures VOID the batch).
#      The file is written OUTSIDE the worktree on purpose; B7 scored two correct runs exit 21
#      because a guardrail's own log inside the worktree counted as an unrelated file.
#
#   3. IT COPIES EACH RUN'S EVIDENCE OFF $TMPDIR THE MOMENT THE RUN ENDS.
#      The reaper on this machine empties a kept worktree's files in about three days and
#      LEAVES THE DIRECTORY STANDING, so `ls -d` passes on a hollowed one. The author
#      decision 11 census returned NO READING AT ALL because all 54 kept BE-004 worktrees
#      had already been emptied when it opened them. A copy made later is a copy of nothing.
#
#   4. instructionsHash IS ASSERTED PER RUN, both directions.
#      Treated must equal the registered sha of agent-v1.1/CLAUDE.md; control must be null,
#      because verify-v1.0 carries no CLAUDE.md at all. The B4 overlay force-add and stop 9's
#      `Read, Grep, Glob, Bash` delivered as ["Read","Bash"] are why a hash is read back
#      rather than a flag trusted.
#
# WHAT IS THE SAME, DELIBERATELY: the manifest-as-progress-record, the pid lock, the single
# API read per run, the evaluator's own exit code rather than make's, the init read-back
# (author decision 8), and the claude-version drift abort. Every one of those was paid for.
#
# MANIFEST-AS-PROGRESS-RECORD: every run appends before the next starts, so a session that
# dies mid-batch leaves a record of what already ran. NEVER re-run an id that is in a
# manifest — a duplicate benchmark run is evidence that cannot be deleted.
#
# Usage: evidence/b08/run-b8-batch.sh [N] [BE-003|BE-004 ...]     (N defaults to 10)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1
# The B8_OVERLAY_* overrides, like B8_API/B8_OTLP, exist ONLY so the guard fixture set can
# point a guard at a deliberately-broken COPY of an overlay and prove it refuses. The
# registered overlays are the defaults and a batch that wanted others would be a different
# experiment.
OVERLAY_T="${B8_OVERLAY_T:-$LAB/build/customizations/agent-v1.1}"
OVERLAY_C="${B8_OVERLAY_C:-$LAB/build/customizations/verify-v1.0}"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
EXPECT_AGENT_HASH="sha256:b3450564b6f32d6193e8580db766210e"
EXPECT_INSTR_HASH="sha256:a94237242e8c1308fb1d434a06a03463"

# THE THREE ENDPOINTS, PROVED BEFORE THE BATCH AND NOT GUESSED (see header note 1).
# The B8_* overrides exist ONLY so verify-b8-batch-guards.sh can point a guard at a dead port
# and prove it refuses. They are not a configuration knob: the registered values are the
# defaults, and a batch that wanted different endpoints would be a different experiment.
export API="${B8_API:-http://127.0.0.1:18081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:13200"
export OTLP_HTTP_ENDPOINT="${B8_OTLP:-http://localhost:14318}"
export OTLP_GRPC_ENDPOINT="http://localhost:14317"

N=10
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then N="$1"; shift; fi
TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b08/batch-$TAG"
KEEPDIR="$LAB/evidence.local/b08-worktrees"
SMALLDIR="$LAB/evidence/b08/worktrees"

LOCK="${B8_LOCK:-$LAB/evidence/b08/.batch.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b8-batch: a batch is already running (pid $(cat "$LOCK")). Read its manifest" >&2
  echo "  before deciding anything is dead. Refusing to start a second one." >&2
  exit 8
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT
mkdir -p "$EVID/init-schema" "$KEEPDIR" "$SMALLDIR"
MANIFEST="$EVID/manifest.tsv"

# PRE-FLIGHT THE ENDPOINTS ONCE. A batch that starts against a dead API burns the first run
# to find out; the runner refuses before the agent starts, but the refusal costs a slot in
# the manifest and reads like a failed run.
ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

# THE ONE-VARIABLE GUARDS. This stop's whole comparison rests on the two arms carrying a
# BYTE-IDENTICAL agent file and differing ONLY by agent-v1.1's CLAUDE.md and its two Bash
# hooks. A batch that ran with either of those broken would produce a confident number about
# the wrong comparison — which is what stop 9 found when a four-name `tools:` list was
# delivered as two. Checked here, on the files, before any money is spent.
ta="$(shasum -a 256 "$OVERLAY_T/.claude/agents/$AGENT_NAME.md" | cut -c1-32)"
ca="$(shasum -a 256 "$OVERLAY_C/.claude/agents/$AGENT_NAME.md" | cut -c1-32)"
[[ "$ta" == "$ca" ]] || { echo "ABORT: the arms' agent files DIFFER ($ta vs $ca) — more than one variable moves" >&2; exit 6; }
[[ "sha256:$ta" == "$EXPECT_AGENT_HASH" ]] || { echo "ABORT: agent file is not the registered one: sha256:$ta != $EXPECT_AGENT_HASH" >&2; exit 6; }
ti="$(shasum -a 256 "$OVERLAY_T/CLAUDE.md" | cut -c1-32)"
[[ "sha256:$ti" == "$EXPECT_INSTR_HASH" ]] || { echo "ABORT: treated CLAUDE.md is not the registered one: sha256:$ti != $EXPECT_INSTR_HASH" >&2; exit 6; }
[[ -e "$OVERLAY_C/CLAUDE.md" ]] && { echo "ABORT: the CONTROL overlay has a CLAUDE.md — instructionsHash cannot be null" >&2; exit 6; }
for h in repair-limit.sh repair-record.sh; do
  [[ -x "$OVERLAY_T/.ai/hooks/$h" ]] || { echo "ABORT: treated overlay is missing an executable .ai/hooks/$h" >&2; exit 6; }
  [[ -e "$OVERLAY_C/.ai/hooks/$h" ]] && { echo "ABORT: the CONTROL overlay carries .ai/hooks/$h — the treatment is in both arms" >&2; exit 6; }
done

# GUARDS-ONLY MODE exists so the guards above can be PROVEN to refuse without spending a
# benchmark run. verify-b8-batch-guards.sh is the fixture set; nothing else sets this.
if [[ -n "${B8_GUARDS_ONLY:-}" ]]; then
  echo "guards-only: every guard passed and NOTHING was run"; exit 0
fi

LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
{
  printf '# B8 REGISTERED BATCH %s  n=%s per arm per task, interleaved (author decision 9)\n' "$TAG" "$N"
  printf '# treated overlay %s (agent-v1.1), control %s (verify-v1.0)\n' \
    "$(shasum -a 256 "$OVERLAY_T/CLAUDE.md" | cut -d" " -f1)" "none-no-CLAUDE.md"
  printf '# expected agentHash on BOTH arms: %s\n' "$EXPECT_AGENT_HASH"
  printf '# expected instructionsHash treated %s / control null\n' "$EXPECT_INSTR_HASH"
  printf '# claude %s at launch, model %s\n' "$LAUNCH_CLAUDE" "$MODEL"
  printf '# API %s  OTLP %s / %s\n' "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT"
  printf '# prediction commit 5d7bfe0 at 2026-09-15T14:31:03Z, BEFORE any run here\n'
  printf 'task\tseq\tarm\trun_id\trc\tevaluator_exit\tf13\tedits\truntime_ver\tmodel\tagent_hash\tinstr_hash\tstate_file\tstate_valid\ttotal_repairs\tblocks\tpre_allows\tpost_succ\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 15 "$API/api/runs/$1" 2>/dev/null; }

one() {  # one <task> <arm> <seq>
  local task="$1" arm="$2" seq="$3" key log rc rid wt rec
  key="EXP-B8-RUNSTATE-$(echo "$task" | tr -d '-')"   # BE-003 -> EXP-B8-RUNSTATE-BE003. REGISTERED.
  log="$EVID/${task}-${seq}-${arm}.log"
  echo ""; echo "======== $task $seq $arm  key=$key  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime claude --benchmark "$task" --experiment "$key" --model "$MODEL"
                 --agent "$AGENT_NAME" --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then
    args+=(--customization "$OVERLAY_T" --variant agent-v1.1)
  else
    args+=(--customization "$OVERLAY_C" --variant verify-v1.0)
  fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  # ONE API READ, not ten. Ten separate curls can straddle a write and disagree with each
  # other, which is a race in the instrument rather than a fact about the run.
  rec="$(api "${rid:-x}")"
  local ah ih mc tc cost dur chg ev rv rm
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r '.changedFiles // "null"')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"
  rv="$(printf '%s' "$rec"   | jq -r '.runtime.version // "null"')"
  rm="$(printf '%s' "$rec"   | jq -r '.runtime.model // "null"')"
  # F13: an api_error run measured the network, not the variant.
  local f13=no; /usr/bin/grep -aq '"terminal_reason":"api_error"' "$log" && f13=yes
  # HOW MANY EDITS WERE EVEN ATTEMPTED — so an absent artefact can be told apart from an
  # absent treatment. -oE piped to wc -l, NOT grep -c: two calls on one line count once.
  local edits; edits="$(/usr/bin/grep -aoE '"name":"(Edit|Write|NotebookEdit)"' "$log" 2>/dev/null | /usr/bin/wc -l | tr -d ' ')"
  edits="${edits:-0}"
  # ===== P1, BOTH HALVES. The run-state file is B8's only per-run delivery proof.
  local sf="" sfstate="ABSENT" svalid="n/a" tr_=0 blocks=0 pre=0 post=0
  [[ -n "$wt" ]] && sf="${TMPDIR:-/tmp}/run-state-$(basename "$wt").json"
  if [[ -n "$sf" && -f "$sf" ]]; then
    sfstate="PRESENT"
    "$LAB/tools/check-run-state.sh" "$sf" >"$EVID/${task}-${seq}-${arm}-check-run-state.txt" 2>&1
    svalid="$?"
    tr_="$(jq -r '.totalRepairAttempts // 0' "$sf" 2>/dev/null)"
    blocks="$(jq -r '[.hookExecutions[]? | select(.decision=="block")] | length' "$sf" 2>/dev/null)"
    pre="$(jq -r '[.hookExecutions[]? | select(.hook=="repair-limit")] | length' "$sf" 2>/dev/null)"
    post="$(jq -r '[.hookExecutions[]? | select(.hook=="repair-record")] | length' "$sf" 2>/dev/null)"
  elif [[ "$edits" -eq 0 ]]; then
    sfstate="INCONCLUSIVE-0-edits"
  fi
  # THE INIT READ-BACK (author decision 8): a `tools:` line is a claim about a file until the
  # delivered schema says so. Three-line TEXT report, not JSON — parsing it as JSON reads as
  # UNREAD, which is what the first version of this line in run-b7-batch.sh did.
  local it; it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$seq" "$arm" "${rid:-NONE}" "$rc" "$ev" "$f13" "$edits" "$rv" "$rm" "$ah" "$ih" \
    "$sfstate" "$svalid" "$tr_" "$blocks" "$pre" "$post" "$mc" "$tc" "$cost" "$dur" "$chg" \
    "$it" "${wt:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev f13=$f13 edits=$edits state=$sfstate(valid=$svalid) repairs=$tr_ blocks=$blocks hooks=$pre/$post calls=$mc cost=$cost instr=$ih"
  # ===== THE EVIDENCE COPY, THE DAY THE RUN IS MADE (header note 3).
  if [[ -n "$rid" ]]; then
    mkdir -p "$SMALLDIR/$rid"
    printf '%s' "$rec" > "$SMALLDIR/$rid/run-record.json"
    [[ -n "$sf" && -f "$sf" ]] && cp "$sf" "$SMALLDIR/$rid/run-state.json"
    [[ -n "$sf" && ! -f "$sf" ]] && { printf 'condition: run-state file ABSENT at %s\n' "$sf" > "$SMALLDIR/$rid/condition-absent.txt"; stat "$sf" >> "$SMALLDIR/$rid/condition-absent.txt" 2>&1; }
    local isf; isf="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
    [[ -n "$isf" ]] && cp "$isf" "$SMALLDIR/$rid/init-schema.txt"
    local plog; [[ -n "$wt" ]] && plog="${TMPDIR:-/tmp}/policy-events-$(basename "$wt").jsonl"
    [[ -n "${plog:-}" && -f "$plog" ]] && cp "$plog" "$SMALLDIR/$rid/policy-events.jsonl"
    if [[ -n "$wt" && -d "$wt" ]]; then
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null && echo "     worktree copied -> evidence.local/b08-worktrees/$rid ($(du -sh "$KEEPDIR/$rid" 2>/dev/null | cut -f1))"
    fi
  fi
  # A CLI THAT MOVES MID-BATCH IS A CHANGED REGISTERED VARIABLE. Abort, do not continue.
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-batch: $LAUNCH_CLAUDE -> $cv" >&2; exit 9; }
}

# INTERLEAVED, and it is not cosmetic. E-006 and E-007 both ran arm-blocked batches and both
# had to argue afterwards that nothing on the machine drifted between the blocks. Alternating
# means any drift — a slower network, a warmer cache, a service update — lands on both arms.
for t in "${TASKS[@]}"; do
  for ((i=1;i<=N;i++)); do
    s2="$(printf '%02d' "$i")"
    one "$t" treated "$s2"
    one "$t" control "$s2"
  done
done

echo ""; echo "manifest: $MANIFEST"; echo "BATCH DONE $(date -u +%Y-%m-%dT%H:%M:%SZ)"
