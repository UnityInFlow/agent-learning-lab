#!/usr/bin/env bash
# B6 §4 step 9 — the deliberate failure. ONE run, registered in E-012/E-013 at commit 4d3d166
# BEFORE this script existed. Same 675-word body, E-004's measured-at-0-of-5 CSS description,
# in the skill-alone configuration — the only one in which this skill has been recorded
# activating, so a 0 here is a 0 against a control that has been shown to say yes.
set -uo pipefail
LAB="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab"
cd "$LAB" || exit 1
OBS="$LAB/../agent-observatory"
EVID="$LAB/evidence/b06/deliberate-failure"
mkdir -p "$EVID/init-schema"
OVL="$EVID/overlay"
rm -rf "$OVL"; mkdir -p "$OVL/.claude/skills/testing-and-verification"
cp "$LAB/build/customizations/skill-v1.1-misdescribed/.claude/skills/testing-and-verification/SKILL.md" \
   "$OVL/.claude/skills/testing-and-verification/SKILL.md"
log="$EVID/run.log"
( cd "$OBS" && make run-benchmark RUNTIME=claude BENCHMARK=BE-003 \
    EXPERIMENT=EXP-B6-DELIBERATE-FAILURE MODEL=claude-haiku-4-5-20251001 \
    ISOLATE_USER_SETTINGS=1 KEEP=1 ENABLE_SKILLS=1 \
    API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200 \
    INIT_SCHEMA_DIR="$EVID/init-schema" \
    CUSTOMIZATION="$OVL" VARIANT=skill-v1.1-misdescribed ) > "$log" 2>&1
rc=$?
rid=$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')
sk="$(grep -acE '"(name|tool_name)":"Skill"' "$log" 2>/dev/null)"
{ echo "run_id: ${rid:-NONE}"
  echo "exit: $rc"
  echo "skill_stream: ${sk:-0}"
  echo "skill sha: fabfc481c4929524786e5a6332c8647a (misdescribed; body identical to 7bea9048…)"
} > "$EVID/manifest.txt"
cat "$EVID/manifest.txt"
echo "DELIBERATE FAILURE DONE"
