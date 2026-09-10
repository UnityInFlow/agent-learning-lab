#!/usr/bin/env bash
# B6 §4 step 5, second attempt — the DESCRIPTION revision, probed before any batch.
#
# WHY TWO PROBES AND NOT ONE. The first preflight found 0 activations on the treated arm and
# concluded, from a skill-only probe that also read 0, that the agent's tool list "is not the
# cause". That is too strong: the treated arm's `init` read-back is n=4 [Read,Edit,Write,Bash]
# with NO `Skill` tool, which is a SUFFICIENT blocker on its own. The skill-only probe shows a
# SECOND, independent blocker. Both are present in the registered treatment, so the two probes
# below separate them:
#
#   A  skill alone, no agent, full 29-tool pool -> `Skill` IS available. Tests the DESCRIPTION.
#   B  agent + skill, the registered treated arm -> `Skill` is NOT available. Tests whether the
#      tool list is decisive even with a description that names the task's domain.
#
# Only the description changed between v1.0 and v1.1; the 675-word body is byte-identical
# (`diff` over the file minus line 3 is clean) and the agent file is unchanged at b3450564b6f32d61.
set -uo pipefail
LAB="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab"
cd "$LAB" || exit 1
OBS="$LAB/../agent-observatory"
EVID="$LAB/evidence/b06/probe-v1.1"
mkdir -p "$EVID/init-schema"
M="$EVID/manifest.tsv"
printf '# B6 probe v1.1  skill sha 7bea904863fb79a544ee2068cb2f0f43  agent b3450564b6f32d61 (unchanged)\n' > "$M"
printf 'probe\ttask\tkey\trun_id\texit\tagent_hash\tskill_hash\tmodel_calls\n' >> "$M"

probe () {
  local name=$1 task=$2 key=$3 overlay=$4 variant=$5 agent=$6
  local log="$EVID/${name}.log"
  echo "======== $name ($task) ========"
  local -a agentarg=()
  [ -n "$agent" ] && agentarg=(AGENT="$agent")
  ( cd "$OBS" && make run-benchmark RUNTIME=claude BENCHMARK="$task" \
      EXPERIMENT="$key" MODEL=claude-haiku-4-5-20251001 \
      ISOLATE_USER_SETTINGS=1 KEEP=1 ENABLE_SKILLS=1 \
      API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200 \
      INIT_SCHEMA_DIR="$EVID/init-schema" \
      CUSTOMIZATION="$overlay" "${agentarg[@]}" VARIANT="$variant" ) > "$log" 2>&1
  local rc=$? rid ah sh mc
  rid=$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')
  if [ -n "$rid" ]; then
    read -r ah sh mc < <(curl -s --max-time 15 "http://127.0.0.1:18081/api/runs/$rid" | python3 -c "
import json,sys
d=json.load(sys.stdin)
c=d.get('customization',{}) or {}
b=d.get('behavior',{}) or {}
print(c.get('agentHash'), c.get('skillsHash'), b.get('modelCalls'))
" 2>/dev/null)
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$task" "$key" "${rid:-NONE}" "$rc" "${ah:-NONE}" "${sh:-NONE}" "${mc:-NONE}" >> "$M"
  echo "  -> ${rid:-NORUN} exit=$rc agentHash=$ah skillsHash=$sh modelCalls=$mc"
}

probe A-skill-only BE-003 EXP-B6-SKILL-DELIVERY-PROBE-V11 \
  "$LAB/evidence/b06/probe-skill-only-v1.1" probe-skill-only-v1.1 ""
probe B-agent-skill BE-003 EXP-B6-SKILL-BE003-PREFLIGHT-V11 \
  "$LAB/build/customizations/skill-v1.1-testing" skill-v1.1-testing backend-feature-phases
echo "PROBE V1.1 DONE"
