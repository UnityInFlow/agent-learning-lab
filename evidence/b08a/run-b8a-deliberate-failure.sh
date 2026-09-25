#!/usr/bin/env bash
#
# run-b8a-deliberate-failure — §4 step 9 for spine stop 17a (B8a, decomposition depth).
#
# THE SAME FOUR OVERLAY FILES WITH `Task` REMOVED FROM THE ORCHESTRATOR'S `tools:` LINE.
# Registered in E-020 `## Deliberate failure` BEFORE this script existed. Single arm, its own
# probe key, excluded by name from both registered arms.
#
# WHY THIS IS A SEPARATE SCRIPT AND NOT A FLAG ON run-b8a-batch.sh:
#   run-b8a-batch.sh:118-120 REFUSES an orchestrator whose `tools:` line has no Task, with
#   exit 6. That guard is a registered instrument of the batch that produced the 16 runs and
#   IS NOT EDITED after the fact. It was pointed at this overlay before a dollar was spent and
#   it refused — evidence/b08a/deliberate-failure-*/guard-refusal.txt. So the deliberate
#   failure had to be run around it, deliberately, by a driver that says so.
#
# THE GUARD IS INVERTED HERE. This driver refuses an overlay that DOES contain Task (exit 6),
# because the one thing that would silently destroy this step is running the REGISTERED
# treatment under the probe key and reading its delegations as a refutation.
#
# EXIT CODES
#   0  every run completed and the manifest is written
#   6  a one-variable guard refused (wrong overlay, missing file, Task present, model pinned)
#   7  an endpoint did not answer
#   8  another instance holds the lock
#   9  the claude CLI moved mid-batch
#  11  the cost ceiling was reached before N runs — the population that occurred is reported
#
# Usage: evidence/b08a/run-b8a-deliberate-failure.sh [N]     (N defaults to 5)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

OVERLAY="${DF_OVERLAY:-$LAB/build/customizations/b8a-pipeline-v1.0-notask}"
AGENT_NAME="orchestrator"
TASK="${DF_TASK:-BE-005}"
KEY="${DF_KEY:-EXP-B8A-DF-NOTASK}"
MODEL="claude-haiku-4-5-20251001"
EXPECT_AGENT_HASH="${DF_EXPECT_AGENT_HASH:-sha256:c0c5aab3e7d469ded7227b8f57280004}"
# $4.00 = 5 x $0.80, above the registered treated arm's median run cost of $0.7149
# (evidence/b08a/REPORT.md). A no-Task run opens no subagent context and should cost LESS, so
# this ceiling is expected not to bind; it exists so a runaway cannot spend the step's budget.
CEILING="${DF_CEILING:-4.00}"
SPECIALISTS=(planner implementer verifier)

export API="${DF_API:-http://127.0.0.1:8081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="${DF_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${DF_OTLP_GRPC:-http://localhost:4317}"
EVENTS="$OBS/infra/telemetry-out/events.jsonl"

N=5
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then N="$1"; shift; fi
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b08a/deliberate-failure-$TAG"
KEEPDIR="$LAB/evidence.local/b08a-worktrees"
SMALLDIR="$LAB/evidence/b08a/worktrees"
MANIFEST="$EVID/manifest.tsv"

LOCK="${DF_LOCK:-$LAB/evidence/b08a/.df.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b8a-deliberate-failure: already running (pid $(cat "$LOCK")). Refusing a second one." >&2
  exit 8
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

# --- THE ONE-VARIABLE GUARDS, INVERTED WHERE THIS ARM INVERTS THE TREATMENT ------------
for f in orchestrator planner implementer verifier; do
  [[ -f "$OVERLAY/.claude/agents/$f.md" ]] \
    || { echo "ABORT: overlay is missing .claude/agents/$f.md" >&2; exit 6; }
done
ta="$(shasum -a 256 "$OVERLAY/.claude/agents/$AGENT_NAME.md" | cut -c1-32)"
[[ "sha256:$ta" == "$EXPECT_AGENT_HASH" ]] \
  || { echo "ABORT: orchestrator is not the registered broken file: sha256:$ta != $EXPECT_AGENT_HASH" >&2; exit 6; }
# *** INVERTED. *** Running the registered treatment under this probe key would read as a
# refutation of the deliberate failure and would be one of the worst errors available here.
if grep -qE '^tools:.*\bTask\b' "$OVERLAY/.claude/agents/$AGENT_NAME.md"; then
  echo "ABORT: this orchestrator CAN delegate — that is the registered treatment, not the deliberate failure" >&2; exit 6
fi
# The three specialists must be byte-identical to the measured ones: one variable moves.
for f in planner implementer verifier; do
  a="$(shasum -a 256 "$LAB/build/customizations/b8a-pipeline-v1.0/.claude/agents/$f.md" | cut -c1-32)"
  b="$(shasum -a 256 "$OVERLAY/.claude/agents/$f.md" | cut -c1-32)"
  [[ "$a" == "$b" ]] || { echo "ABORT: $f.md differs from the measured overlay ($a != $b) — more than one variable moved" >&2; exit 6; }
done
for stray in CLAUDE.md AGENTS.md; do
  [[ -e "$OVERLAY/$stray" ]] \
    && { echo "ABORT: overlay carries $stray — instructionsHash would not be null" >&2; exit 6; }
done
if find "$OVERLAY" -type f -name 'SKILL.md' 2>/dev/null | grep -q .; then
  echo "ABORT: overlay carries a SKILL.md — skillsHash would not be null" >&2; exit 6
fi
if grep -lE '^model:' "$OVERLAY"/.claude/agents/*.md 2>/dev/null | grep -q .; then
  echo "ABORT: an agent file sets model: — the model is chosen by --model and nowhere else" >&2; exit 6
fi

ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

# GUARDS-ONLY MODE: prove every guard refuses without spending a run.
if [[ -n "${DF_GUARDS_ONLY:-}" ]]; then
  echo "guards-only: every guard passed and NOTHING was run"; exit 0
fi
# CEILING-ONLY MODE: prove the SAME expression the batch uses fires at a supplied total.
ceiling_reached() { awk -v t="$1" -v c="$CEILING" 'BEGIN{exit !(t>=c)}'; }
if [[ -n "${DF_CEILING_ONLY:-}" ]]; then
  if ceiling_reached "${DF_TEST_COST:-0}"; then
    echo "stop-rule: COST CEILING \$$CEILING REACHED at \$${DF_TEST_COST:-0} (exit 11)"; exit 11
  fi
  echo "stop-rule: ceiling does not fire at \$${DF_TEST_COST:-0}"; exit 0
fi

mkdir -p "$EVID/init-schema" "$KEEPDIR" "$SMALLDIR"
LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }
EVENTS_BEFORE="$(events_bytes)"

{
  printf '# B8a DELIBERATE FAILURE %s  n=%s, ONE arm, task %s, key %s\n' "$TAG" "$N" "$TASK" "$KEY"
  printf '# overlay %s — orchestrator tools: has NO Task; planner/implementer/verifier byte-identical to v1.0\n' "$OVERLAY"
  printf '# expected agentHash %s (the BROKEN orchestrator, not the registered one)\n' "$EXPECT_AGENT_HASH"
  printf '# registered batch driver REFUSED this overlay at exit 6 before any run — guard-refusal.txt\n'
  printf '# ceiling %s USD (5 x 0.80, above the treated median 0.7149); exit 11 if reached\n' "$CEILING"
  printf '# claude %s at launch, model %s\n' "$LAUNCH_CLAUDE" "$MODEL"
  printf '# API %s  OTLP %s / %s  events.jsonl %s bytes at launch\n' \
    "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT" "$EVENTS_BEFORE"
  printf 'seq\trun_id\trc\tevaluator_exit\truntime_ver\tmodel\tagent_hash\tinstr_hash\tskills_hash\tcond_a\tcond_b\tcond_c\tcond_d\trow0a\tdeleg_stream\tdeleg_telemetry\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 15 "$API/api/runs/$1" 2>/dev/null; }
COST_TOTAL=0
NULL_COST=0
ROW0A=0

finish() {
  local code="$1"
  { printf 'deliberate failure %s ended (UTC): %s  exit %s\n' "$TAG" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$code"
    printf 'cost total read from run records: $%s\n' "$COST_TOTAL"
    printf 'runs whose estimatedCost read null: %s — with any of these the total is a LOWER BOUND\n' "$NULL_COST"
    printf 'ceiling: $%s\n' "$CEILING"
    printf 'runs classed row 0a: %s of %s\n' "$ROW0A" "$N"
    printf 'events.jsonl bytes before %s, after %s\n' "$EVENTS_BEFORE" "$(events_bytes)"
  } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit "$code"
}

one() {  # one <seq>
  local seq="$1" log rc rid wt rec
  log="$EVID/${TASK}-${seq}-notask.log"
  echo ""; echo "======== $TASK $seq notask  key=$KEY  $(date -u +%H:%M:%SZ) ========"
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh \
      --runtime claude --benchmark "$TASK" --experiment "$KEY" --model "$MODEL" \
      --isolate-user-settings --keep \
      --customization "$OVERLAY" --agent "$AGENT_NAME" --variant b8a-pipeline-v1.0-notask ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  local ah ih sh_ mc tc cost dur chg ev rv rm
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  sh_="$(printf '%s' "$rec"  | jq -r '.customization.skillsHash // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"
  rv="$(printf '%s' "$rec"   | jq -r '.runtime.version // "null"')"
  rm="$(printf '%s' "$rec"   | jq -r '.runtime.model // "null"')"

  # Delegations, two sources, same expressions the registered batch used. The wire tool name is
  # `Agent`, not `Task`, and DISTINCT tool_use ids are counted, not lines.
  local ds dt
  ds="$(/usr/bin/grep -aoE '"type":"tool_use","id":"toolu_[A-Za-z0-9]+","name":"Agent"' "$log" 2>/dev/null | sort -u | wc -l | tr -d ' ')"
  ds="${ds:-0}"
  dt=0
  if [[ -n "$rid" && -f "$EVENTS" ]]; then
    dt="$(/usr/bin/grep -a "$rid" "$EVENTS" 2>/dev/null | /usr/bin/grep -ac '"stringValue":"Agent"')"
    dt="${dt:-0}"
  fi

  local ca=fail cb=fail cc=fail cd=fail r0a=no it itfile
  itfile="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$itfile" && -r "$itfile" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$itfile" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$itfile" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi

  if [[ -n "$wt" && -d "$wt" ]]; then
    local tracked=0
    for f in orchestrator planner implementer verifier; do
      ( cd "$wt" && git ls-files --error-unmatch ".claude/agents/$f.md" ) >/dev/null 2>&1 && tracked=$((tracked+1))
    done
    [[ "$tracked" -eq 4 ]] && ca=ok || ca="fail-$tracked-of-4"
  fi
  [[ "$ah" == "$EXPECT_AGENT_HASH" ]] && cb=ok || cb=fail
  if [[ -n "$itfile" && -r "$itfile" ]]; then
    /usr/bin/grep -q '"Task"' "$itfile" && cc=ok || cc=fail
  else cc=fail-nofile; fi
  local named=0
  for s in "${SPECIALISTS[@]}"; do
    /usr/bin/grep -aq "\"subagent_type\":\"$s\"" "$log" && named=$((named+1))
  done
  [[ "$named" -eq 3 ]] && cd="ok-stream-3of3" || cd="fail-$named-of-3-stream"
  case "$ca$cb$cc$cd" in *fail*) r0a=yes; ROW0A=$((ROW0A+1));; esac

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "${rid:-NONE}" "$rc" "$ev" "$rv" "$rm" "$ah" "$ih" "$sh_" \
    "$ca" "$cb" "$cc" "$cd" "$r0a" "$ds" "$dt" "$mc" "$tc" "$cost" "$dur" "$chg" \
    "$it" "${wt:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev model=$rm deleg=$ds/$dt cond=$ca,$cb,$cc,$cd row0a=$r0a cost=$cost"

  if [[ -n "$rid" ]]; then
    mkdir -p "$SMALLDIR/$rid"
    printf '%s' "$rec" > "$SMALLDIR/$rid/run-record.json"
    [[ -n "$itfile" ]] && cp "$itfile" "$SMALLDIR/$rid/init-schema.txt"
    if [[ -n "$wt" && -d "$wt" ]]; then
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null \
        && echo "     worktree copied -> evidence.local/b08a-worktrees/$rid"
    fi
  fi

  if [[ "$cost" == "null" || -z "$cost" ]]; then
    NULL_COST=$((NULL_COST+1))
  else
    COST_TOTAL="$(awk -v a="$COST_TOTAL" -v b="$cost" 'BEGIN{printf "%.4f", a+b}')"
  fi

  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] \
    || { echo "ABORT: claude moved mid-batch: $LAUNCH_CLAUDE -> $cv" >&2; finish 9; }
}

for i in $(seq 1 "$N"); do
  s="$(printf '%02d' "$i")"
  one "$s"
  if ceiling_reached "$COST_TOTAL"; then
    echo ""; echo "COST CEILING \$$CEILING REACHED at \$$COST_TOTAL after run $s — stopping at n=$i"
    finish 11
  fi
done
finish 0
