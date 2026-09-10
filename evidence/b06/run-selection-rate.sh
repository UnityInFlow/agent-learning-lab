#!/usr/bin/env bash
# B6 §4 step 5 — the SELECTION-RATE probe, and the reason it exists instead of a batch.
#
# The carrier delivers the Skill tool: `init-schema: delivered n=5 [...,"Skill"] verdict=match`.
# So the skill is DELIVERABLE and SELECTABLE there, which is what the carrier was built for. But
# the first carrier run recorded ZERO activations, while the same skill with the same description
# and no agent at all recorded ONE. Both are n=1.
#
# A 40-run batch on an arm that selects the skill rarely measures nothing and says so confidently
# — E-012's P1 void condition. This probe costs ten runs and settles the rate first:
#
#   CARRIER  agent + Skill in tools: + the skill   -> does the agent's own six-phase prose
#                                                     displace skill selection?
#   ALONE    the skill, no agent, full 30-tool pool -> the rate when nothing competes with it
#
# Neither key ever joins an n; both are probe keys. Nothing here is a treatment comparison —
# the two configurations differ by the whole agent, not by one variable.
#
# Usage: N=5 ./evidence/b06/run-selection-rate.sh
set -uo pipefail
LAB="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab"
cd "$LAB" || exit 1
OBS="$LAB/../agent-observatory"
EVID="$LAB/evidence/b06/selection-rate"
N="${N:-5}"
mkdir -p "$EVID/init-schema"
M="$EVID/manifest.tsv"
if [[ ! -f "$M" ]]; then
  printf '# B6 selection rate  skill sha 7bea904863fb79a544ee2068cb2f0f43 (v1.1, domain description)\n' > "$M"
  printf '# carrier agent 51ffaedf9a3edbfe5fd85009f70f84c5 = phases-v1.0 + Skill in tools:\n' >> "$M"
  printf 'config\tseq\trun_id\texit\tagent_hash\tskill_hash\tskill_stream\tmodel_calls\n' >> "$M"
fi

one () {
  local cfg=$1 seq=$2 overlay=$3 variant=$4 agent=$5
  local log="$EVID/${cfg}-${seq}.log"
  local -a agentarg=()
  [ -n "$agent" ] && agentarg=(AGENT="$agent")
  echo "======== $cfg $seq ========"
  ( cd "$OBS" && make run-benchmark RUNTIME=claude BENCHMARK=BE-003 \
      EXPERIMENT="EXP-B6-SELECTION-RATE-$cfg" MODEL=claude-haiku-4-5-20251001 \
      ISOLATE_USER_SETTINGS=1 KEEP=1 ENABLE_SKILLS=1 \
      API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200 \
      INIT_SCHEMA_DIR="$EVID/init-schema" \
      CUSTOMIZATION="$overlay" "${agentarg[@]}" VARIANT="$variant" ) > "$log" 2>&1
  local rc=$? rid ah sh mc sk
  rid=$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')
  sk="$(grep -acE '"(name|tool_name)":"Skill"' "$log" 2>/dev/null)"; sk="${sk:-0}"
  if [ -n "$rid" ]; then
    read -r ah sh mc < <(curl -s --max-time 15 "http://127.0.0.1:18081/api/runs/$rid" | python3 -c "
import json,sys
d=json.load(sys.stdin)
c=d.get('customization',{}) or {}
b=d.get('behavior',{}) or {}
print(c.get('agentHash'), c.get('skillsHash'), b.get('modelCalls'))
" 2>/dev/null)
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$cfg" "$seq" "${rid:-NONE}" "$rc" "${ah:-NONE}" "${sh:-NONE}" "$sk" "${mc:-NONE}" >> "$M"
  echo "  -> ${rid:-NORUN} exit=$rc skillCalls=$sk agent=$ah skill=$sh"
}

for i in $(seq 1 "$N"); do
  s="$(printf '%02d' "$i")"
  one carrier "$s" "$LAB/build/customizations/phases-v1.0-skillcarrier" phases-v1.0-skillcarrier backend-feature-phases
  one alone   "$s" "$LAB/evidence/b06/probe-skill-only-v1.1"            probe-skill-only-v1.1    ""
done
echo "SELECTION RATE DONE"
column -t -s "$(printf '\t')" "$M" 2>/dev/null || cat "$M"
