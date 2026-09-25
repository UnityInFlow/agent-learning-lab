#!/usr/bin/env bash
#
# run-b8a-preflight — §4 step 5 for spine stop 17a. TWO RUNS, one per arm, EACH UNDER ITS OWN
# PROBE KEY so that neither can ever land in the registered population.
#
# This is not a small batch. It is the run that decides whether the step opens at all:
# decision 11 item 11 names "a preflight that cannot show all four delivery conditions" as one
# of three registered early-end conditions. It also carries three things the batch cannot:
#   - author decision 8's init read-back for all THREE specialists, which is where a `tools:`
#     line stops being a claim about a file. E-005 and run-agent.sh:975-979: `Bash` in a
#     subagent allowlist REMOVES `Grep` and `Glob`, 19 of 19, no exception. The verifier's
#     registered `Read, Grep, Glob, Bash` is EXPECTED to arrive as ["Read","Bash"], and when it
#     does the LABEL drops from L2 to L3 in the workbook. The tools: line is not edited.
#   - whether infra/telemetry-out/events.jsonl grows at all. It has not since 2026-09-17, and an
#     open OTLP port is not proof an export lands (stop 11's rule). Delivery condition (d) is
#     telemetry-sourced, so this is load-bearing.
#   - the second half of the §0a isolation row, owed and discharged here rather than by a
#     separate paid run: the control's three hashes null and 0 hook executions.
#
# Exit 0 always: this script MEASURES, it does not judge. The four conditions are evaluated and
# printed per run; whether the step opens is decided by a human reading RESULT.md, not by an
# exit code, because "the preflight could not show all four" is a finding to write up rather
# than a failure to retry.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

OVERLAY_T="$LAB/build/customizations/b8a-pipeline-v1.0"
AGENT_NAME="orchestrator"
TASK="BE-005"
KEY="EXP-B8A-PREFLIGHT"
MODEL="claude-haiku-4-5-20251001"
EXPECT_AGENT_HASH="sha256:1f27323694e579ec11dbca026bfbb326"
SPECIALISTS=(planner implementer verifier)

export API="http://127.0.0.1:8081"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="http://localhost:4318"
export OTLP_GRPC_ENDPOINT="http://localhost:4317"
EVENTS="$OBS/infra/telemetry-out/events.jsonl"

TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b08a/preflight-$TAG"
KEEPDIR="$LAB/evidence.local/b08a-worktrees"
mkdir -p "$EVID/init-schema" "$KEEPDIR"
REPORT="$EVID/OBSERVED.md"

events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }
EB0="$(events_bytes)"
api() { curl -s -m 15 "$API/api/runs/$1" 2>/dev/null; }

{
  echo "# B8a preflight pair — observed, $TAG"
  echo
  echo "Probe key \`$KEY\` — NOT the batch key. Model \`$MODEL\`. Task \`$TASK\`."
  echo "API \`$API\`, OTLP \`$OTLP_HTTP_ENDPOINT\` / \`$OTLP_GRPC_ENDPOINT\`."
  echo "\`events.jsonl\` **$EB0 bytes** before the pair."
  echo
} > "$REPORT"

one() {  # one <arm>
  local arm="$1" log rc rid wt rec
  log="$EVID/${arm}.log"
  echo ""; echo "======== PREFLIGHT $arm  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime claude --benchmark "$TASK" --experiment "$KEY" --model "$MODEL"
                 --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then
    args+=(--customization "$OVERLAY_T" --agent "$AGENT_NAME" --variant b8a-pipeline-v1.0)
  else
    args+=(--variant baseline)
  fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  [[ -n "$rid" ]] && printf '%s' "$rec" > "$EVID/run-record-$arm.json"

  local ah ih sh_ mc tc cost dur chg ev rv rm hooks
  ah="$(printf '%s' "$rec"  | jq -r '.customization.agentHash // "null"')"
  ih="$(printf '%s' "$rec"  | jq -r '.customization.instructionsHash // "null"')"
  sh_="$(printf '%s' "$rec" | jq -r '.customization.skillsHash // "null"')"
  mc="$(printf '%s' "$rec"  | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"  | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec" | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec" | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"  | jq -r '.evaluation.exitCode // "null"')"
  rv="$(printf '%s' "$rec"  | jq -r '.runtime.version // "null"')"
  rm="$(printf '%s' "$rec"  | jq -r '.runtime.model // "null"')"
  # The §0a isolation row's second half: hook executions on an --isolate-user-settings run.
  hooks="$(printf '%s' "$rec" | jq -r '[.. | objects | select(has("hookExecutions")) | .hookExecutions[]?] | length' 2>/dev/null)"
  hooks="${hooks:-unread}"

  local ds dt
  ds="$(/usr/bin/grep -acE '"(name|tool_name)":"(Task|Agent)"' "$log" 2>/dev/null)"; ds="${ds:-0}"
  dt=0
  if [[ -n "$rid" && -f "$EVENTS" ]]; then
    dt="$(/usr/bin/grep -a "$rid" "$EVENTS" 2>/dev/null | /usr/bin/grep -acE '"(name|tool_name)":"(Task|Agent)"')"; dt="${dt:-0}"
  fi

  local itfile; itfile="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"

  {
    echo "## arm \`$arm\` — run \`${rid:-NONE}\`"
    echo
    echo "| | |"
    echo "|---|---|"
    echo "| runner exit | \`$rc\` |"
    echo "| evaluator exitCode | \`$ev\` |"
    echo "| runtime.model | \`$rm\` |"
    echo "| runtime.version | \`$rv\` |"
    echo "| agentHash | \`$ah\` |"
    echo "| instructionsHash | \`$ih\` |"
    echo "| skillsHash | \`$sh_\` |"
    echo "| hookExecutions in record | \`$hooks\` |"
    echo "| modelCalls / toolCalls | \`$mc\` / \`$tc\` |"
    echo "| estimatedCost / durationMs | \`$cost\` / \`$dur\` |"
    echo "| changedFiles | \`$chg\` |"
    echo "| delegations, agent stream | \`$ds\` |"
    echo "| delegations, telemetry | \`$dt\` |"
    echo "| kept worktree | \`${wt:-NONE}\` |"
    echo
  } >> "$REPORT"

  if [[ "$arm" == treated ]]; then
    {
    echo "### The four delivery conditions (decision 11 item 9)"
    echo
    # (a) git ls-files in the kept worktree — tracked, not merely present.
    echo '```'
    echo "(a) git ls-files --error-unmatch, inside the kept worktree:"
    for f in orchestrator planner implementer verifier; do
      if [[ -n "$wt" && -d "$wt" ]] && ( cd "$wt" && git ls-files --error-unmatch ".claude/agents/$f.md" ) >/dev/null 2>&1; then
        echo "    TRACKED   .claude/agents/$f.md"
      else
        echo "    NOT TRACKED  .claude/agents/$f.md"
      fi
    done
    echo "(b) agentHash $ah  vs registered $EXPECT_AGENT_HASH"
    if [[ -n "$itfile" && -r "$itfile" ]]; then
      echo "(c) init read-back file: $(basename "$itfile")"
      sed 's/^/    /' "$itfile"
    else
      echo "(c) init read-back: NO FILE"
    fi
    echo "(d) specialists named, telemetry then stream:"
    local hay=""
    [[ -n "$rid" && -f "$EVENTS" ]] && hay="$(/usr/bin/grep -a "$rid" "$EVENTS" 2>/dev/null)"
    for s in "${SPECIALISTS[@]}"; do
      local int ins
      int=0; [[ -n "$hay" ]] && printf '%s' "$hay" | /usr/bin/grep -q "$s" && int=1
      ins=0; /usr/bin/grep -q "$s" "$log" 2>/dev/null && ins=1
      echo "    $s  telemetry=$int  stream=$ins"
    done
    echo '```'
    echo
    # EVERY init read-back file this run produced — one per agent, which is the point.
    echo "### Every init read-back this run wrote (author decision 8, all three specialists)"
    echo
    echo '```'
    find "$EVID/init-schema" -type f 2>/dev/null | sort | while read -r f; do
      echo "--- $(basename "$f")"; sed 's/^/    /' "$f"
    done
    echo '```'
    echo
    } >> "$REPORT"
  fi

  # THE EVIDENCE COPY, THE SAME DAY. The reaper empties a kept worktree in about three days and
  # leaves the directory standing; all 54 BE-004 worktrees were hollow when the census opened them.
  if [[ -n "$rid" && -n "$wt" && -d "$wt" ]]; then
    rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
    cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null \
      && echo "  worktree copied -> evidence.local/b08a-worktrees/$rid ($(du -sh "$KEEPDIR/$rid" 2>/dev/null | cut -f1))"
  fi
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev model=$rm deleg=$ds/$dt agentHash=$ah cost=$cost"
}

one control
one treated

{
  echo "## events.jsonl"
  echo
  echo "| | bytes |"
  echo "|---|---|"
  echo "| before the pair | \`$EB0\` |"
  echo "| after the pair | \`$(events_bytes)\` |"
  echo
  echo "An open OTLP port is not proof an export lands (stop 11). If these two numbers are equal,"
  echo "delivery condition (d) has no telemetry source and is answered from the agent stream with"
  echo "that substitution named in the workbook."
} >> "$REPORT"

echo ""; echo "PREFLIGHT DONE $(date -u +%Y-%m-%dT%H:%M:%SZ)"; echo "report: $REPORT"
