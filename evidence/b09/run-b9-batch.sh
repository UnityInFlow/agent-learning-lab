#!/usr/bin/env bash
#
# run-b9-batch — §4 step 6 for spine stop 20 (B9). THE REGISTERED BATCH: n = 10 per arm per task,
# interleaved treated/control so any drift in the machine or the service lands on both arms.
#
# WHAT IS DIFFERENT FROM evidence/b08/run-b8-batch.sh and evidence/b08a/run-b8a-batch.sh:
#
#   1. *** THE COST CEILING IS COMPUTED, NOT CARRIED, AND THERE IS ONE PER TASK. ***
#      Author decision 13 (2026-09-26): a B-step's ceiling is 11 x THE MEASURED PREFLIGHT-PAIR
#      COST, PER TASK. Stop 17a's flat $9.70 was 25 x a PLAIN-run median, its preflight pair then
#      measured $1.2222 — 1.57x two plain runs, because a treated arm costs more than the arm the
#      median came from — so $9.70 funded 7.9 pairs, the batch stopped at n = 8 on exit 11 and
#      E-020's `8 of 10` threshold could not be evaluated as written. Decision 13 item (iv):
#      *the ceiling only stays L2 if the driver computes it; a multiplication living in prose is
#      L3 again.* So this script READS the preflight manifest, sums the treated + control cost of
#      that task's pair, multiplies by 11, and refuses to start at all if the pair cost is not
#      readable (exit 12). It carries no dollar figure of its own.
#
#   2. THE DELIVERY PROOF IS THE ROUTER'S OWN LOG, plus knowledgeHash, plus the corpus sha in the
#      kept worktree. The log is OUTSIDE the worktree at
#      ${TMPDIR}/knowledge-log-observatory-run-<runId>.jsonl — Amendment 1 in E-022/E-023: written
#      inside it, both evaluators would score every treated run exit 21 for an AC7 scope violation
#      caused by the treatment's own bookkeeping, as B7's preflight pair already was.
#
#   3. `H` IS COUNTED PER RUN AS THE BATCH GOES, because it is the decision rule's first
#      partition (E-022 row 0, E-023 row 1: H <= 2 means VOID at any M). It is REPORTED and does
#      NOT stop the batch: no early-stop on H was registered before the run, and inventing one
#      here would change the population the rule is evaluated over.
#
# WHAT IS THE SAME, DELIBERATELY, because every one of them was paid for: the manifest as a
# progress record (every run appends before the next starts, so a session that dies mid-batch
# leaves a record of what ran — NEVER re-run an id that is in a manifest), the pid lock shared
# with the preflight, one API read per run, the evaluator's own exit code rather than make's, the
# init read-back (author decision 8), the claude-version drift abort, and the evidence copy made
# the day the run is made because the reaper empties a kept worktree in about three days and
# leaves the directory standing.
#
# EXIT CODES
#   0  the batch completed n per arm per task
#   6  a guard refused before any run
#   7  an endpoint is dead
#   8  a preflight or batch is already running (pid lock)
#   9  the claude CLI moved mid-batch
#  11  a task's computed cost ceiling was reached before n per arm — the population that occurred
#      is reported, as E-016 did at n = 7
#  12  the preflight pair cost could not be read, so the ceiling cannot be computed (decision 13)
#
# Usage: evidence/b09/run-b9-batch.sh [N] [BE-003|BE-004 ...]      (N defaults to 10)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

OVERLAY_T="${B9_OVERLAY_T:-$LAB/build/customizations/agent-v1.2-knowledge}"
OVERLAY_C="${B9_OVERLAY_C:-$LAB/build/customizations/agent-v1.1}"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
EXPECT_KNOWLEDGE_HASH="${B9_EXPECT_KNOWLEDGE_HASH:-sha256:0770219ae7f4281a80071d78dadea285}"
EXPECT_AGENT_HASH="${B9_EXPECT_AGENT_HASH:-sha256:b3450564b6f32d6193e8580db766210e}"
EXPECT_INSTR_T="${B9_EXPECT_INSTR_T:-sha256:ebf489800a60a156986f98ea4f127848}"
EXPECT_INSTR_C="${B9_EXPECT_INSTR_C:-sha256:a94237242e8c1308fb1d434a06a03463}"
CEILING_MULTIPLIER="${B9_CEILING_MULTIPLIER:-11}"   # author decision 13. Not a knob.

export API="${B9_API:-http://127.0.0.1:8081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="${B9_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B9_OTLP_GRPC:-http://localhost:4317}"
EVENTS="$OBS/infra/telemetry-out/events.jsonl"

N=10
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then N="$1"; shift; fi
TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)

# --- AUTHOR DECISION 13: THE CEILING, COMPUTED HERE. ----------------------------------------
# pair_cost <task> — the treated + control cost of that task's preflight pair, read from the
# NEWEST preflight manifest. Prints the sum, or `unreadable`.
PREFLIGHT_MANIFEST="${B9_PREFLIGHT_MANIFEST:-}"
if [[ -z "$PREFLIGHT_MANIFEST" ]]; then
  PREFLIGHT_MANIFEST="$(find "$LAB/evidence/b09" -name manifest.tsv -path '*preflight-*' 2>/dev/null \
                        | LC_ALL=C sort | tail -1)"
fi
pair_cost() {  # pair_cost <task>
  local task="$1" c
  [[ -r "$PREFLIGHT_MANIFEST" ]] || { echo unreadable; return; }
  c="$(awk -F'\t' -v t="$task" '
        $1==t && ($2=="treated" || $2=="control") && $13!="null" && $13!="" { s+=$13; n++ }
        END { if (n==2) printf "%.4f", s; else print "unreadable" }' "$PREFLIGHT_MANIFEST")"
  [[ -n "$c" ]] && echo "$c" || echo unreadable
}
ceiling_for() {  # ceiling_for <task>
  local p; p="$(pair_cost "$1")"
  [[ "$p" == unreadable ]] && { echo unreadable; return; }
  awk -v p="$p" -v m="$CEILING_MULTIPLIER" 'BEGIN{printf "%.4f", p*m}'
}
# The one comparison the loop uses, defined once so the fixture set can prove the SAME expression
# fires that the batch runs. A fixture that re-implemented it would test a copy of the control.
ceiling_reached() { awk -v t="$1" -v c="$2" 'BEGIN{exit !(t>=c)}'; }

if [[ -n "${B9_STOPRULE_ONLY:-}" ]]; then
  if ceiling_reached "${B9_TEST_COST:-0}" "${B9_TEST_CEILING:-0}"; then
    echo "stop-rule: CEILING \$${B9_TEST_CEILING:-0} REACHED at \$${B9_TEST_COST:-0} (exit 11)"; exit 11
  fi
  echo "stop-rule: the ceiling does not fire at cost=\$${B9_TEST_COST:-0} ceiling=\$${B9_TEST_CEILING:-0}"; exit 0
fi

LOCK="${B9_LOCK:-$LAB/evidence/b09/.batch.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b9-batch: a preflight or batch is already running (pid $(cat "$LOCK")). Read its" >&2
  echo "  manifest before deciding anything is dead. Refusing to start a second one." >&2
  exit 8
fi

# --- THE GUARDS, identical to the preflight's: one variable moves. ---------------------------
ta="$(shasum -a 256 "$OVERLAY_T/.claude/agents/$AGENT_NAME.md" | cut -d' ' -f1)"
ca="$(shasum -a 256 "$OVERLAY_C/.claude/agents/$AGENT_NAME.md" | cut -d' ' -f1)"
[[ "$ta" == "$ca" ]] || { echo "ABORT: the arms' agent files DIFFER — more than one variable moves" >&2; exit 6; }
[[ "sha256:${ta:0:32}" == "$EXPECT_AGENT_HASH" ]] || { echo "ABORT: agent file is not the registered one" >&2; exit 6; }
for f in .claude/settings.json .ai/policies/protected-paths.yaml .ai/hooks/policy-gate.sh \
         .ai/hooks/repair-limit.sh .ai/hooks/repair-record.sh; do
  t="$(shasum -a 256 "$OVERLAY_T/$f" | cut -d' ' -f1)"; c="$(shasum -a 256 "$OVERLAY_C/$f" | cut -d' ' -f1)"
  [[ "$t" == "$c" ]] || { echo "ABORT: $f differs between the arms" >&2; exit 6; }
done
ti="$(shasum -a 256 "$OVERLAY_T/CLAUDE.md" | cut -c1-32)"
ci="$(shasum -a 256 "$OVERLAY_C/CLAUDE.md" | cut -c1-32)"
[[ "sha256:$ti" == "$EXPECT_INSTR_T" ]] || { echo "ABORT: treated CLAUDE.md is not the registered one" >&2; exit 6; }
[[ "sha256:$ci" == "$EXPECT_INSTR_C" ]] || { echo "ABORT: control CLAUDE.md is not v1.1's" >&2; exit 6; }
[[ -e "$OVERLAY_C/.ai/knowledge" ]] && { echo "ABORT: the CONTROL overlay has .ai/knowledge" >&2; exit 6; }
kh="$( (cd "$OVERLAY_T" && find .ai/knowledge -type f | LC_ALL=C sort | while IFS= read -r f; do
          printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done) | shasum -a 256 | cut -c1-32)"
[[ "sha256:$kh" == "$EXPECT_KNOWLEDGE_HASH" ]] || { echo "ABORT: the corpus is not the registered one: sha256:$kh" >&2; exit 6; }
if (cd "$OVERLAY_T/.ai/knowledge" && grep -ril 'confirm\|cancel\|shipment\|order' . | grep -q .); then
  echo "ABORT: the corpus names a task word" >&2; exit 6
fi

# THE CEILINGS, COMPUTED BEFORE ANYTHING RUNS AND REFUSED IF NOT COMPUTABLE.
declare -a CEIL_TASK=() CEIL_VAL=() PAIR_VAL=()
for t in "${TASKS[@]}"; do
  pc="$(pair_cost "$t")"; cl="$(ceiling_for "$t")"
  if [[ "$cl" == unreadable ]]; then
    echo "ABORT: the preflight pair cost for $t is not readable from ${PREFLIGHT_MANIFEST:-<none found>}." >&2
    echo "  Author decision 13 makes the ceiling 11 x that pair. A ceiling this script cannot" >&2
    echo "  compute is a number in prose, which is Layer 3, which is not a control. Exit 12." >&2
    exit 12
  fi
  CEIL_TASK+=("$t"); CEIL_VAL+=("$cl"); PAIR_VAL+=("$pc")
  printf 'ceiling %s: pair $%s x %s = $%s   (author decision 13, computed from %s)\n' \
    "$t" "$pc" "$CEILING_MULTIPLIER" "$cl" "$PREFLIGHT_MANIFEST"
done

if [[ -n "${B9_GUARDS_ONLY:-}" ]]; then echo "guards-only: every guard passed and NOTHING was run"; exit 0; fi

ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b09/batch-$TAG"
KEEPDIR="$LAB/evidence.local/b09-worktrees"
SMALLDIR="$LAB/evidence/b09/worktrees"
mkdir -p "$EVID/init-schema" "$KEEPDIR" "$SMALLDIR"
MANIFEST="$EVID/manifest.tsv"
LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }
EVENTS_BEFORE="$(events_bytes)"
{
  printf '# B9 REGISTERED BATCH %s  n=%s per arm per task, interleaved (author decision 9)\n' "$TAG" "$N"
  printf '# treated %s / control %s\n' "$OVERLAY_T" "$OVERLAY_C"
  printf '# expected knowledgeHash treated %s / control null\n' "$EXPECT_KNOWLEDGE_HASH"
  printf '# expected agentHash BOTH arms %s; instructionsHash treated %s / control %s\n' \
    "$EXPECT_AGENT_HASH" "$EXPECT_INSTR_T" "$EXPECT_INSTR_C"
  for i in "${!CEIL_TASK[@]}"; do
    printf '# COMPUTED ceiling %s: pair $%s x %s = $%s (author decision 13, from %s)\n' \
      "${CEIL_TASK[$i]}" "${PAIR_VAL[$i]}" "$CEILING_MULTIPLIER" "${CEIL_VAL[$i]}" "$PREFLIGHT_MANIFEST"
  done
  printf '# claude %s at launch, model %s, benchmarks %s\n' "$LAUNCH_CLAUDE" "$MODEL" \
    "$(git -C ../agent-observatory-benchmarks rev-parse --short HEAD 2>/dev/null)"
  printf '# API %s  OTLP %s / %s  events.jsonl %s bytes at launch\n' \
    "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT" "$EVENTS_BEFORE"
  printf '# prediction commit ef2c6c0 at 2026-09-26, BEFORE any run here\n'
  printf 'task\tseq\tarm\trun_id\trc\teval\tf13\tedits\truntime_ver\tmodel\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\tlog_hits\tfirst_status\tcorpus_match\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 20 "$API/api/runs/$1" 2>/dev/null; }
declare -A TASK_COST=()
H_COUNT=0

one() {  # one <task> <arm> <seq>
  local task="$1" arm="$2" seq="$3" key log rc rid wt rec
  key="EXP-B9-ROUTER-$(echo "$task" | tr -d '-')"
  log="$EVID/${task}-${seq}-${arm}.log"
  echo ""; echo "======== $task $seq $arm  key=$key  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime claude --benchmark "$task" --experiment "$key" --model "$MODEL"
                 --agent "$AGENT_NAME" --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then args+=(--customization "$OVERLAY_T" --variant agent-v1.2-knowledge)
  else                             args+=(--customization "$OVERLAY_C" --variant agent-v1.1); fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  local kn ih ah mc tc cost dur chg ev rv rm
  kn="$(printf '%s' "$rec"   | jq -r '.customization.knowledgeHash // "null"')"
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"
  local f13=no; /usr/bin/grep -aq '"terminal_reason":"api_error"' "$log" && f13=yes
  local edits; edits="$(/usr/bin/grep -aoE '"name":"(Edit|Write|NotebookEdit)"' "$log" 2>/dev/null | /usr/bin/wc -l | tr -d ' ')"
  edits="${edits:-0}"

  # ===== THE DELIVERY PROOF: the router's own log, outside the worktree.
  local lf="" lstate="ABSENT" lines=0 hits=0 first="n/a"
  [[ -n "$wt" ]] && lf="${TMPDIR:-/tmp}/knowledge-log-$(basename "$wt").jsonl"
  if [[ -n "$lf" && -f "$lf" ]]; then
    lstate="PRESENT"
    lines="$(grep -c . "$lf" 2>/dev/null || echo 0)"
    hits="$(grep -c '"status":"hit"' "$lf" 2>/dev/null || echo 0)"
    first="$(head -1 "$lf" | jq -r '.status // "unparsed"' 2>/dev/null || echo unparsed)"
    [[ "$arm" == treated && "$lines" -ge 1 ]] && H_COUNT=$((H_COUNT+1))
  fi
  local cmatch="n/a"
  if [[ -n "$wt" && -d "$wt/.ai/knowledge" ]]; then
    local wkh
    wkh="$( (cd "$wt" && find .ai/knowledge -type f | LC_ALL=C sort | while IFS= read -r f; do
              printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done) | shasum -a 256 | cut -c1-32)"
    [[ "sha256:$wkh" == "$EXPECT_KNOWLEDGE_HASH" ]] && cmatch="MATCH" || cmatch="DIFFER:sha256:$wkh"
  elif [[ "$arm" == control ]]; then
    cmatch="ABSENT-as-registered"
  fi
  local it; it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$seq" "$arm" "${rid:-NONE}" "$rc" "$ev" "$f13" "$edits" "$rv" "$rm" "$kn" "$ih" "$ah" \
    "$lstate" "$lines" "$hits" "$first" "$cmatch" "$mc" "$tc" "$cost" "$dur" "$chg" "$it" "${wt:-NONE}" \
    >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev edits=$edits kn=$kn log=$lstate(${lines}L/${hits}hit first=$first) corpus=$cmatch calls=$mc cost=$cost"

  if [[ -n "$rid" ]]; then
    mkdir -p "$SMALLDIR/$rid"
    printf '%s' "$rec" > "$SMALLDIR/$rid/run-record.json"
    if [[ -n "$lf" && -f "$lf" ]]; then cp "$lf" "$SMALLDIR/$rid/knowledge-log.jsonl"
    else printf 'condition: knowledge log ABSENT at %s\n' "$lf" > "$SMALLDIR/$rid/knowledge-log-absent.txt"; fi
    [[ -f "$EVID/init-schema/init-schema-${rid}.txt" ]] && cp "$EVID/init-schema/init-schema-${rid}.txt" "$SMALLDIR/$rid/init-schema.txt"
    local plog; [[ -n "$wt" ]] && plog="${TMPDIR:-/tmp}/policy-events-$(basename "$wt").jsonl"
    [[ -n "${plog:-}" && -f "$plog" ]] && cp "$plog" "$SMALLDIR/$rid/policy-events.jsonl"
    local sf; [[ -n "$wt" ]] && sf="${TMPDIR:-/tmp}/run-state-$(basename "$wt").json"
    [[ -n "${sf:-}" && -f "$sf" ]] && cp "$sf" "$SMALLDIR/$rid/run-state.json"
    if [[ -n "$wt" && -d "$wt" ]]; then
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null \
        && echo "     worktree copied -> evidence.local/b09-worktrees/$rid ($(du -sh "$KEEPDIR/$rid" 2>/dev/null | cut -f1))"
    fi
  fi
  if [[ "$cost" != "null" && -n "$cost" ]]; then
    TASK_COST["$task"]="$(awk -v a="${TASK_COST[$task]:-0}" -v b="$cost" 'BEGIN{printf "%.4f", a+b}')"
  else
    NULL_COST=$((${NULL_COST:-0}+1))
  fi
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-batch: $LAUNCH_CLAUDE -> $cv" >&2; finish 9; }
}

finish() {
  local code="$1" i
  { printf 'batch %s ended (UTC): %s  exit %s\n' "$TAG" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$code"
    for i in "${!CEIL_TASK[@]}"; do
      printf 'task %s: spent $%s of a COMPUTED ceiling $%s (pair $%s x %s)\n' \
        "${CEIL_TASK[$i]}" "${TASK_COST[${CEIL_TASK[$i]}]:-0}" "${CEIL_VAL[$i]}" "${PAIR_VAL[$i]}" "$CEILING_MULTIPLIER"
    done
    printf 'runs whose estimatedCost read null: %s — with any of these every total is a LOWER BOUND\n' "${NULL_COST:-0}"
    printf 'treated runs with a non-empty router log (H, the decision rules first partition): %s\n' "$H_COUNT"
    printf 'events.jsonl bytes before %s, after %s\n' "$EVENTS_BEFORE" "$(events_bytes)"
  } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit "$code"
}

for idx in "${!CEIL_TASK[@]}"; do
  t="${CEIL_TASK[$idx]}"; cl="${CEIL_VAL[$idx]}"
  for ((i=1;i<=N;i++)); do
    s2="$(printf '%02d' "$i")"
    one "$t" treated "$s2"
    one "$t" control "$s2"
    # Checked AFTER the pair so the arms stay balanced: stopping between a control and its treated
    # partner would leave an unpaired run in a batch whose whole design is interleaving.
    if ceiling_reached "${TASK_COST[$t]:-0}" "$cl"; then
      echo ""; echo "!! $t's COMPUTED CEILING \$$cl REACHED at \$${TASK_COST[$t]:-0} after pair $s2." >&2
      echo "!! This task stops here and the population that occurred is reported. Other tasks continue." >&2
      CEILING_FIRED="${CEILING_FIRED:-}${CEILING_FIRED:+,}$t"
      break
    fi
  done
done

echo ""; echo "BATCH DONE $(date -u +%Y-%m-%dT%H:%M:%SZ)"
[[ -n "${CEILING_FIRED:-}" ]] && { echo "ceilings fired for: $CEILING_FIRED" >&2; finish 11; }
finish 0
