#!/usr/bin/env bash
# B6 §4 step 9, COMPLETING the registration rather than substituting for it.
#
# WHAT THE §4a REVIEW CAUGHT, AND IT WAS RIGHT. E-012/E-013 registered the deliberate failure at
# `n = 3` with TWO clauses -- activation falls to 0, AND `test-quality` stays at the control's
# level -- and named the configuration as "a skill delivered inside an agent overlay". The step-9
# amendment ran ONE run, in the SKILL-ALONE configuration, and checked activation only. That
# change was not disclosed. The acceptance gate rejected the file for it (recurrence 2/2).
#
# This restores the registration: THREE runs, on the CARRIER -- which is the agent overlay the
# batch actually used, and the only agent overlay in which a skill can be selected at all -- with
# the misdescribed skill, scored for `test-quality` afterwards so the second clause is answered
# too. The skill-alone run 81899960 is KEPT and reported as the extra evidence it is.
set -uo pipefail
LAB="/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab"
cd "$LAB" || exit 1
OBS="$LAB/../agent-observatory"
EVID="$LAB/evidence/b06/deliberate-failure-carrier"
if [[ -f "$EVID/manifest.tsv" && "${B6_DF_FORCE:-0}" != "1" ]]; then
  echo "run-deliberate-failure-carrier: REFUSING, $EVID/manifest.tsv already exists:" >&2
  sed 's/^/  /' "$EVID/manifest.tsv" >&2
  exit 4
fi
mkdir -p "$EVID/init-schema"
OVL="$EVID/overlay"
rm -rf "$OVL"; mkdir -p "$OVL/.claude/agents" "$OVL/.claude/skills/testing-and-verification"
cp "$LAB/build/customizations/phases-v1.0-skillcarrier/.claude/agents/backend-feature-phases.md" "$OVL/.claude/agents/"
cp "$LAB/build/customizations/skill-v1.1-misdescribed/.claude/skills/testing-and-verification/SKILL.md" \
   "$OVL/.claude/skills/testing-and-verification/SKILL.md"
M="$EVID/manifest.tsv"
{ printf '# B6 deliberate failure on the CARRIER  misdescribed skill fabfc481c4929524786e5a6332c8647a\n'
  printf '# carrier agent 51ffaedf9a3edbfe5fd85009f70f84c5, identical to the batch`s treated arm\n'
  printf 'seq\trun_id\texit\tagent_hash\tskill_hash\tskill_stream\tworktree\n'; } > "$M"
for i in 1 2 3; do
  s="$(printf '%02d' "$i")"
  log="$EVID/$s.log"
  echo "======== deliberate failure $s ========"
  ( cd "$OBS" && make run-benchmark RUNTIME=claude BENCHMARK=BE-003 \
      EXPERIMENT=EXP-B6-DELIBERATE-FAILURE-CARRIER MODEL=claude-haiku-4-5-20251001 \
      ISOLATE_USER_SETTINGS=1 KEEP=1 ENABLE_SKILLS=1 \
      API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200 \
      INIT_SCHEMA_DIR="$EVID/init-schema" \
      CUSTOMIZATION="$OVL" AGENT=backend-feature-phases VARIANT=skill-v1.1-misdescribed-carrier ) > "$log" 2>&1
  rc=$?
  rid=$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')
  wt=$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)
  sk=$(grep -acE '"(name|tool_name)":"Skill"' "$log" 2>/dev/null); sk="${sk:-0}"
  ah=""; sh=""
  if [ -n "$rid" ]; then
    read -r ah sh < <(curl -s --max-time 15 "http://127.0.0.1:18081/api/runs/$rid" | python3 -c "
import json,sys
d=json.load(sys.stdin); c=d.get('customization',{}) or {}
print(c.get('agentHash'), c.get('skillsHash'))
" 2>/dev/null)
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$s" "${rid:-NONE}" "$rc" "${ah:-NONE}" "${sh:-NONE}" "$sk" "${wt:-NONE}" >> "$M"
  echo "  -> ${rid:-NORUN} exit=$rc skillCalls=$sk agent=$ah skill=$sh"
done
echo "DELIBERATE FAILURE CARRIER DONE"
cat "$M"
