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
#  13  --resume names a batch this driver may not join (no manifest, a different registered
#      population, or a different n) — a resume that joined the wrong batch would pool two
#      populations under one tag, which is the one thing a manifest exists to prevent
#
# Usage: evidence/b09/run-b9-batch.sh [--resume <TAG>] [N] [BE-003|BE-004 ...]   (N defaults to 10)
#
# *** WHY --resume EXISTS, AND IT IS NOT A CONVENIENCE. *** This driver's runs are children of the
# shell that launches it, and this project launches it from a claude session that the §0 phase-
# boundary rule REQUIRES to end. Batch 20260926T151319Z was killed that way at 17:45:01Z with four
# pairs' worth of runs recorded and a fifth run complete but unrowed; batch 20260926T133740Z died
# three minutes in on the `rv` defect. Without resume the only ways forward are to re-run runs that
# already happened — duplicate evidence that cannot be deleted (§6) — or to pool two batch tags by
# hand. --resume re-enters the SAME manifest, skips every (task,seq,arm) cell already recorded in
# it, and SEEDS the per-task cost so author decision 13's ceiling still bounds the whole batch and
# not just the tail. The launcher must also detach the driver from the session's process group
# (`setsid`-equivalent), or the next boundary kills it again; that is the launcher's job, not this
# script's, and it is recorded in this stop's workbook.
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

RESUME_TAG="${B9_RESUME_TAG:-}"
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --resume) RESUME_TAG="${2:-}"; shift 2 || true ;;
    *) echo "run-b9-batch: unknown flag $1 (only --resume <TAG>)" >&2; exit 2 ;;
  esac
done
[[ -n "$RESUME_TAG" && ! "$RESUME_TAG" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] && {
  echo "run-b9-batch: --resume wants a batch TAG like 20260926T151319Z, got '$RESUME_TAG'" >&2; exit 13; }

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
# *** THE COLUMNS ARE FOUND BY NAME, AND THE FIRST VERSION OF THIS FUNCTION READ THEM BY POSITION.
# *** It hard-coded `$13` for cost. Two columns (`router_mentions`, `router_denied`) were then added
# to the preflight manifest ahead of it, so `$13` became `router_denied`, whose value is the string
# `no` — which awk sums as 0 while counting two rows. The ceiling came out as **$0.0000**, it did NOT
# refuse, and a $0 ceiling fires on the first pair. A control that answers confidently with the wrong
# number is worse than one that refuses, and author decision 13 item (iv) is precisely about the
# ceiling being computed rather than carried.
# THE FIXTURE SET MISSED IT because `mkmanifest` writes its own header with cost at column 13 — a
# fixture testing a copy of the format instead of the format. Case L below now shifts the columns on
# purpose, and case M puts a non-numeric value in the cost column.
pair_cost() {  # pair_cost <task>
  local task="$1" c
  [[ -r "$PREFLIGHT_MANIFEST" ]] || { echo unreadable; return; }
  c="$(awk -F'\t' -v t="$task" '
        # The header is the row whose first field is literally `task`. Everything after it is data.
        !hdr && $1=="task" {
          for (i=1;i<=NF;i++) { if ($i=="arm") a=i; else if ($i=="cost") c=i }
          hdr=1; next
        }
        hdr && $1==t && (a && c) && ($a=="treated" || $a=="control") {
          v=$c
          # A cost must be a number. `null`, an empty field, or a string that happens to sit in the
          # column is NOT zero — it is unreadable, and saying so is the whole point of this function.
          if (v ~ /^[0-9]+(\.[0-9]+)?$/) { s+=v; n++ } else { bad++ }
        }
        END {
          if (!hdr || !a || !c) { print "unreadable"; exit }
          if (bad>0 || n!=2)    { print "unreadable"; exit }
          printf "%.4f", s
        }' "$PREFLIGHT_MANIFEST")"
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

# --- RESUME VALIDATION, BEFORE THE ENDPOINTS AND BEFORE THE LOCK IS TAKEN. --------------------
# These three refusals need no network and no run, so the fixture set can prove them. A resume is
# only safe if the batch it joins is the SAME REGISTERED POPULATION — same corpus, same agent file,
# same two CLAUDE.md shas, same n. Joining a differently-registered batch would put two populations
# under one tag and no later reader could separate them.
if [[ -n "$RESUME_TAG" ]]; then TAG="$RESUME_TAG"; else TAG="$(date -u +%Y%m%dT%H%M%SZ)"; fi
EVID="${B9_EVID_ROOT:-$LAB/evidence/b09}/batch-$TAG"   # B9_EVID_ROOT is the fixture set's only
MANIFEST="$EVID/manifest.tsv"                          # hook; the overlays stay real under $LAB.
if [[ -n "$RESUME_TAG" ]]; then
  [[ -f "$MANIFEST" ]] || { echo "ABORT: --resume $TAG names no manifest at $MANIFEST (exit 13)" >&2; exit 13; }
  for pat in "$EXPECT_KNOWLEDGE_HASH" "$EXPECT_AGENT_HASH" "$EXPECT_INSTR_T" "$EXPECT_INSTR_C"; do
    /usr/bin/grep -qF "$pat" "$MANIFEST" || {
      echo "ABORT: $MANIFEST does not register $pat — this is not the same population (exit 13)" >&2; exit 13; }
  done
  mn="$(sed -n 's/^# B9 REGISTERED BATCH [0-9TZ]* *n=\([0-9]*\) .*/\1/p' "$MANIFEST" | head -1)"
  [[ -n "$mn" ]] || { echo "ABORT: $MANIFEST has no 'n=' in its header line (exit 13)" >&2; exit 13; }
  [[ "$mn" == "$N" ]] || {
    echo "ABORT: $MANIFEST registers n=$mn and this invocation says n=$N. A resume may not change" >&2
    echo "  the registered population size; pass the same N or start a new batch. (exit 13)" >&2; exit 13; }
  echo "resume: $MANIFEST validated — same corpus, same agent file, same two CLAUDE.md shas, n=$mn"
  if [[ -n "${B9_RESUME_VALIDATE_ONLY:-}" ]]; then echo "resume-validate-only: NOTHING was run"; exit 0; fi
fi

ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT
KEEPDIR="$LAB/evidence.local/b09-worktrees"
SMALLDIR="$LAB/evidence/b09/worktrees"
mkdir -p "$EVID/init-schema" "$KEEPDIR" "$SMALLDIR"   # TAG, EVID and MANIFEST are set above, with
                                                      # the resume validation that needs them.
LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }
EVENTS_BEFORE="$(events_bytes)"

# --- RESUME: JOIN THE SAME MANIFEST, OR REFUSE. ----------------------------------------------
# The three refusals below are the whole point. A resume is only safe if the batch it joins is the
# SAME REGISTERED POPULATION: same corpus, same agent file, same two CLAUDE.md shas, same n. A
# resume that joined a differently-registered batch would put two populations under one tag, and no
# later reader could separate them — the same defect as a control reporting over a scope smaller
# than it claims, applied to a population instead of a check.
declare -A SEEN=() TASK_COST_SEED=()
H_SEED=0; DEN_SEED=0; NULLC_SEED=0
RESUMED_ROWS=0
if [[ -n "$RESUME_TAG" ]]; then
  # Read EVERY seeded value BY COLUMN NAME. The b09 preflight reader was hard-coded to $13 for cost
  # once already, two columns were inserted ahead of it, and the ceiling silently read $0.0000.
  while IFS=$'\t' read -r k a b; do
    case "$k" in
      CELL)  SEEN["$a"]=1; RESUMED_ROWS=$((RESUMED_ROWS+1)) ;;
      COST)  TASK_COST_SEED["$a"]="$b" ;;
      H)     H_SEED="$a" ;;
      DEN)   DEN_SEED="$a" ;;
      NULLC) NULLC_SEED="$a" ;;
    esac
  done < <(awk -F'\t' '
      !hdr && $1=="task" { for (i=1;i<=NF;i++) col[$i]=i; hdr=1; next }
      hdr && $1 ~ /^BE-/ {
        print "CELL\t" $1 "/" $(col["seq"]) "/" $(col["arm"]) "\t";
        c = $(col["cost"]);
        if (c ~ /^[0-9]+(\.[0-9]+)?$/) { cost[$1] += c } else { nullc++ }
        if ($(col["arm"]) == "treated") {
          if ($(col["log_lines"]) + 0 >= 1) h++;
          if ($(col["router_denied"]) == "yes") den++;
        }
      }
      END { for (t in cost) printf "COST\t%s\t%.4f\n", t, cost[t];
            printf "H\t%d\t\n", h+0; printf "DEN\t%d\t\n", den+0; printf "NULLC\t%d\t\n", nullc+0 }
    ' "$MANIFEST")
  echo "resume: joining $MANIFEST — $RESUMED_ROWS rows already recorded"
  for t in "${TASKS[@]}"; do
    printf 'resume: %s already spent $%s of its ceiling\n' "$t" "${TASK_COST_SEED[$t]:-0}"
  done
  if [[ -n "${B9_RESUME_PLAN_ONLY:-}" ]]; then
    echo "resume-plan:"
    for t in "${TASKS[@]}"; do
      for ((i=1;i<=N;i++)); do
        s2="$(printf '%02d' "$i")"
        for a in treated control; do
          if [[ -n "${SEEN["$t/$s2/$a"]:-}" ]]; then echo "  SKIP $t $s2 $a"; else echo "  RUN  $t $s2 $a"; fi
        done
      done
    done
    echo "resume-plan: nothing was run"; exit 0
  fi
  {
    printf '# RESUMED %s by run-b9-batch.sh --resume: %s rows already recorded, %s cells skipped\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$RESUMED_ROWS" "$RESUMED_ROWS"
    printf '# seeded into the ceiling:'
    for t in "${TASKS[@]}"; do printf ' %s=$%s' "$t" "${TASK_COST_SEED[$t]:-0}"; done
    printf '\n# claude %s at resume; the rows below this line were run after it\n' "$LAUNCH_CLAUDE"
  } >> "$MANIFEST"
fi
if [[ -z "$RESUME_TAG" ]]; then
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
  printf 'task\tseq\tarm\trun_id\trc\teval\tf13\tedits\truntime_ver\tmodel\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\tlog_hits\tfirst_status\trouter_mentions\trouter_denied\tcorpus_match\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"
fi

api() { curl -s -m 20 "$API/api/runs/$1" 2>/dev/null; }
declare -A TASK_COST=()
for t in "${TASKS[@]}"; do TASK_COST["$t"]="${TASK_COST_SEED[$t]:-0}"; done
H_COUNT="${H_SEED:-0}"
DENIED_TREATED="${DEN_SEED:-0}"
NULL_COST="${NULLC_SEED:-0}"

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
  # *** rv AND rm WERE DECLARED AND NEVER ASSIGNED, AND set -u KILLED THE BATCH AT THE PRINTF —
  # AFTER THE FIRST RUN HAD ALREADY COST $0.140948. *** The columns were carried over from the b08
  # driver and the two jq reads were not. Run 6d728d76-5b1d-4b56-8e1f-154ea27ae82b is on record in
  # the API with no manifest row; it is documented as an orphan in this stop's evidence and is
  # excluded-and-replaced under E-022's registered infrastructure rule. ShellCheck cannot see this
  # (they are declared locals) and the guard fixture set cannot either (it never enters one()), so
  # the sidecar below exists to make the NEXT omission of this class cost a row rather than a batch.
  rv="$(printf '%s' "$rec"   | jq -r '.runtime.version // "null"')"
  rm="$(printf '%s' "$rec"   | jq -r '.runtime.model // "null"')"
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
  # *** AN ABSENT LOG HAS TWO CAUSES AND CONFLATING THEM NEARLY TURNED A HARNESS REFUSAL INTO A
  # NULL RESULT. *** The 2026-09-26T12:48Z preflight: BE-003 treated fbdebf75 CALLED the router at
  # its first opportunity and the call landed in `permission_denials` (the runner allowed only mvn
  # Bash commands); BE-004 treated 5a16fd3e never mentioned it. Same ABSENT, opposite meanings, and
  # the decision rule's VOID row is only about the second. `router_denied=yes` on any treated run
  # means the population is measuring the harness, not the instruction.
  local rmentions rdenied
  # -o PIPED TO wc -l, NOT grep -c, AND NO `|| echo 0`. Two defects in the first version of this
  # line, both of which the b08 driver already records: `grep -c` counts LINES WITH A MATCH, so two
  # router calls on one stream-json line count once; and `grep -c ... || echo 0` prints grep's own
  # "0" AND the fallback "0", putting a NEWLINE inside a manifest field. Hand-checked against the
  # 12:48Z logs: BE-003 treated 2 calls / denied yes, the other three 0 / no.
  # *** THE RUNNER'S OWN ECHO IS NOT AN ATTEMPT. *** obs#90 added `echo "  claude args: ..."`, and
  # the flag list contains Bash(.ai/knowledge/router.sh:*) — so every row of the 13:17Z preflight
  # read `router_mentions=1` with no agent involvement at all. A detector that counts its own
  # harness is the same defect as a control reporting over a scope smaller than it claims, three
  # versions in a row on one line. The `claude args:` line is excluded here BY NAME.
  rmentions="$(/usr/bin/grep -av 'claude args:' "$log" 2>/dev/null | /usr/bin/grep -ao 'router\.sh' | /usr/bin/wc -l | tr -d ' ')"
  rmentions="${rmentions:-0}"
  # NAMED `mentions`, NOT `calls`, AND THE DIFFERENCE IS NOT PEDANTRY: one tool call appears in the
  # stream-json more than once — the `tool_use` input, the cwd-prefixed form the harness records,
  # and the `permission_denials` entry if it was refused. On fbdebf75 that is 3 for ONE call. The
  # column is a presence indicator, and the thing that decides anything is `router_denied` beside
  # it and the log's own line count.
  rdenied=no
  /usr/bin/grep -ao 'permission_denials":\[[^]]\{0,240\}' "$log" 2>/dev/null | /usr/bin/grep -q 'router\.sh' && rdenied=yes
  if [[ "$arm" == treated && "$rdenied" == yes ]]; then
    echo "  !! THE HARNESS DENIED THE ROUTER ON A TREATED RUN. Every treated run of this batch is" >&2
    echo "  !! measuring a permission, not a treatment. STOP, fix the permission, re-run the" >&2
    echo "  !! preflight. Do NOT report this as the decision rule's VOID row." >&2
    DENIED_TREATED=$((${DENIED_TREATED:-0}+1))
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

  # THE SIDECAR, WRITTEN BEFORE THE ROW. A run id and a worktree path are the two things that cannot
  # be recovered if this function dies between the run and the manifest: the money is spent, the
  # evidence is on disk under a name nothing records, and the only safe reading afterwards is "a run
  # happened and we do not know which". Two lines, written first, so a crash costs a row and not a
  # run.
  printf '%s\t%s\t%s\t%s\t%s\n' "$task" "$seq" "$arm" "${rid:-NONE}" "${wt:-NONE}" >> "$EVID/run-ids.tsv"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$seq" "$arm" "${rid:-NONE}" "$rc" "$ev" "$f13" "$edits" "$rv" "$rm" "$kn" "$ih" "$ah" \
    "$lstate" "$lines" "$hits" "$first" "$rmentions" "$rdenied" "$cmatch" "$mc" "$tc" "$cost" "$dur" \
    "$chg" "$it" "${wt:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev edits=$edits kn=$kn log=$lstate(${lines}L/${hits}hit first=$first) rmentions=$rmentions denied=$rdenied corpus=$cmatch calls=$mc cost=$cost"

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
    printf 'treated runs whose ROUTER CALL THE HARNESS DENIED: %s — any of these and the batch is\n' "${DENIED_TREATED:-0}"
    printf '  measuring a permission rather than a treatment, and is NOT the VOID row\n'
    printf 'events.jsonl bytes before %s, after %s\n' "$EVENTS_BEFORE" "$(events_bytes)"
  } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit "$code"
}

# A CELL ALREADY IN THIS BATCH'S MANIFEST IS NEVER RE-RUN. §0: "never re-run a benchmark run you
# cannot prove failed to start, because a duplicate run is evidence you then cannot delete."
cell() {  # cell <task> <arm> <seq>
  if [[ -n "${SEEN["$1/$3/$2"]:-}" ]]; then
    echo "  resume: SKIP $1 $3 $2 — already recorded in this batch's manifest"; return 0
  fi
  one "$1" "$2" "$3"
}

for idx in "${!CEIL_TASK[@]}"; do
  t="${CEIL_TASK[$idx]}"; cl="${CEIL_VAL[$idx]}"
  for ((i=1;i<=N;i++)); do
    s2="$(printf '%02d' "$i")"
    cell "$t" treated "$s2"
    cell "$t" control "$s2"
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
