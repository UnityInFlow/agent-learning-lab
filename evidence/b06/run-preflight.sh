#!/usr/bin/env bash
# B6 §4 step 5 — the preflight pair, one run per arm per task, under keys of their own so a
# probe never joins an n. Asserts the ONE thing that decides whether this stop can run at all:
# a RECORDED skill activation on the treated arm and none on the control.
#
# ENABLE_SKILLS=1 GOES ON BOTH ARMS. The runner dies if a skill overlay is installed without it
# ("the arm would silently be a second baseline"), and its own message says to pass it on every
# arm INCLUDING THE CONTROL so the switch is not itself a difference between arms.
set -uo pipefail
cd "/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab" || exit 1
OBS="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/../agent-observatory"
EVID="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/evidence/b06/preflight"
M="$EVID/manifest.tsv"
printf '# B6 preflight  overlay skill sha 0876025fa451af5f1f2970da67a02f0d  agent b3450564b6f32d61\n' > "$M"
printf 'task\tarm\trun_id\texit\tagent_hash\tskill_activations\tmodel_calls\n' >> "$M"

probe () {
  local task=$1 arm=$2 key=$3 overlay=$4 variant=$5
  local log="$EVID/${task}-${arm}.log"
  echo "======== $task $arm ========"
  ( cd "$OBS" && make run-benchmark RUNTIME=claude BENCHMARK=$task \
      EXPERIMENT=$key MODEL=claude-haiku-4-5-20251001 \
      ISOLATE_USER_SETTINGS=1 KEEP=1 ENABLE_SKILLS=1 \
      API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200 \
      INIT_SCHEMA_DIR="$EVID/init-schema" \
      CUSTOMIZATION="$overlay" AGENT=backend-feature-phases VARIANT=$variant ) > "$log" 2>&1
  local rc=$? rid ah acts mc
  rid=$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')
  if [ -n "$rid" ]; then
    read ah acts mc < <(curl -s --max-time 15 "http://127.0.0.1:18081/api/runs/$rid" | python3 -c "
import json,sys
d=json.load(sys.stdin)
c=d.get('customization',{}) or {}
b=d.get('behavior',{}) or {}
acts=b.get('skillActivations')
if acts is None:
    s=json.dumps(d).lower(); acts='SEE_RECORD' if 'skill' in s else 0
print(c.get('agentHash'), acts, b.get('modelCalls'))
" 2>/dev/null)
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$task" "$arm" "${rid:-NONE}" "$rc" "${ah:-NONE}" "${acts:-NONE}" "${mc:-NONE}" >> "$M"
  echo "  -> ${rid:-NORUN} exit=$rc agentHash=$ah skillActivations=$acts modelCalls=$mc"
}

probe BE-003 treated EXP-B6-SKILL-BE003-PREFLIGHT "/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/build/customizations/skill-v1.0-testing" skill-v1.0-testing
probe BE-003 control EXP-B6-SKILL-BE003-PREFLIGHT "/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/build/customizations/phases-v1.0"        phases-v1.0
echo "PREFLIGHT BE-003 DONE"
