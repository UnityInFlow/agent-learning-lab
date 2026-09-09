#!/usr/bin/env bash
# B6 §4 step 5, third and last preflight — the CARRIER pair.
#
# WHY A CARRIER EXISTS AT ALL. Probe A (run ba8b4b98) proved the v1.1 description IS selected:
# `Skill` was in the delivered 30-tool pool and skill-activation.sh recorded
# `activations_by_source: projectSettings=1`, status `measured`. Probe B is the registered
# treated arm, whose agent is delivered n=4 ["Read","Edit","Write","Bash"] — no `Skill` — so a
# skill can never be selected there no matter what its description says.
#
# `phases-v1.0` is a MEASURED version and §6 forbids editing it. It is not edited. The carrier
# is a NEW overlay that differs from it by ONE LINE (`tools:` gains `Skill`) and it is installed
# on BOTH ARMS, so the single variable of E-012/E-013 is still the skill directory and nothing
# else. Treated and control agent files are byte-identical (51ffaedf9a3edbfe on both).
#
# The carrier is an experiment fixture, NOT a product version: v1.0 remains what B5 measured and
# what B7 will close against.
set -uo pipefail
LAB="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab"
cd "$LAB" || exit 1
OBS="$LAB/../agent-observatory"
EVID="$LAB/evidence/b06/probe-carrier"
mkdir -p "$EVID/init-schema"
M="$EVID/manifest.tsv"
printf '# B6 carrier probe  skill sha 7bea904863fb79a544ee2068cb2f0f43  carrier agent 51ffaedf9a3edbfe (phases-v1.0 + Skill, both arms)\n' > "$M"
printf 'arm\ttask\tkey\trun_id\texit\tagent_hash\tskill_hash\tmodel_calls\n' >> "$M"

probe () {
  local arm=$1 task=$2 key=$3 overlay=$4 variant=$5
  local log="$EVID/${task}-${arm}.log"
  echo "======== $task $arm ========"
  ( cd "$OBS" && make run-benchmark RUNTIME=claude BENCHMARK="$task" \
      EXPERIMENT="$key" MODEL=claude-haiku-4-5-20251001 \
      ISOLATE_USER_SETTINGS=1 KEEP=1 ENABLE_SKILLS=1 \
      API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200 \
      INIT_SCHEMA_DIR="$EVID/init-schema" \
      CUSTOMIZATION="$overlay" AGENT=backend-feature-phases VARIANT="$variant" ) > "$log" 2>&1
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
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$arm" "$task" "$key" "${rid:-NONE}" "$rc" "${ah:-NONE}" "${sh:-NONE}" "${mc:-NONE}" >> "$M"
  echo "  -> ${rid:-NORUN} exit=$rc agentHash=$ah skillsHash=$sh modelCalls=$mc"
}

probe treated BE-003 EXP-B6-CARRIER-BE003-PREFLIGHT \
  "$LAB/build/customizations/phases-v1.0-skillcarrier" phases-v1.0-skillcarrier
probe control BE-003 EXP-B6-CARRIER-BE003-PREFLIGHT \
  "$LAB/build/customizations/phases-v1.0-skillcarrier-control" phases-v1.0-skillcarrier-control
probe treated BE-004 EXP-B6-CARRIER-BE004-PREFLIGHT \
  "$LAB/build/customizations/phases-v1.0-skillcarrier" phases-v1.0-skillcarrier
probe control BE-004 EXP-B6-CARRIER-BE004-PREFLIGHT \
  "$LAB/build/customizations/phases-v1.0-skillcarrier-control" phases-v1.0-skillcarrier-control
echo "CARRIER PROBE DONE"
