#!/usr/bin/env bash
#
# run-b7-preflight — §4 step 5 for stop 15. ONE PAIR PER TASK, under its OWN key, entering
# no `n` and no comparison. Its whole job is to answer, before ~$7 of batch is spent:
#
#   does the treatment reach the model, and does it stay away from the control?
#
# WHAT IS ASSERTED PER RUN, and why each one is here rather than assumed:
#
#   .ai/policy-events.jsonl PRESENT on treated, ABSENT on control
#       This is the delivery proof and there is no alternative. run-agent.sh:625-629 records
#       instructionsHash, skillsHash and agentHash and NO settings or hook hash, and
#       GET /api/runs/{id} carries no `environment` object, so hookExecutions is not in the
#       API record either. The hook appends on ALLOW as well as DENY, so the file exists if
#       and only if the hook executed. Its ABSENCE on the control is the half this project
#       has been wrong about before -- the B4 overlay force-add, and `tools:` delivered as
#       [Read, Bash] when the file named four.
#
#   agentHash IDENTICAL on both arms
#       The two overlays carry a byte-identical agent file on purpose. If the hashes differ,
#       the phase treatment moved and the arms differ by more than one variable.
#
#   init.tools read back from the run's own init record (author decision 8)
#       Because a `tools:` line is a claim about a file until the delivered schema says so.
#
#   modelCalls non-null
#       A run that recorded no model calls measured the harness.
#
# MANIFEST-AS-PROGRESS-RECORD: every run appends before the next starts, so a session that
# dies mid-preflight leaves a record of what already ran. NEVER re-run an id that is in a
# manifest -- a duplicate benchmark run is evidence that cannot be deleted.
#
# Usage: evidence/b07/run-b7-preflight.sh [BE-003|BE-004 ...]
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1
OVERLAY_T="$LAB/build/customizations/verify-v1.0"
OVERLAY_C="$LAB/build/customizations/phases-v1.0"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
EXPECT_AGENT_HASH="sha256:b3450564b6f32d6193e8580db766210e"

TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b07/preflight-$TAG"
mkdir -p "$EVID/init-schema"
MANIFEST="$EVID/manifest.tsv"

LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
{
  printf '# B7 PREFLIGHT PAIR %s  (author decisions 8 and 9)\n' "$TAG"
  printf '# treated overlay %s\n'  "$(shasum -a 256 "$OVERLAY_T/.ai/hooks/policy-gate.sh" | cut -d" " -f1)"
  printf '# expected agentHash on BOTH arms: %s\n' "$EXPECT_AGENT_HASH"
  printf '# claude %s at launch, model %s\n' "$LAUNCH_CLAUDE" "$MODEL"
  printf '# prediction commit ea7b1d2 at 2026-09-10T09:51:08Z, BEFORE any run here\n'
  printf 'task\tarm\trun_id\trc\tworktree\tagent_hash\tpolicy_log\tpolicy_lines\tmodel_calls\tinit_tools\n'
} > "$MANIFEST"

api() { curl -s -m 10 "http://127.0.0.1:18081/api/runs/$1" 2>/dev/null; }

one() {  # one <task> <arm>
  local task="$1" arm="$2" key log rc rid wt ah pl pn mc it
  key="EXP-B7-POLICY-$(echo "$task" | tr -d '-')-PREFLIGHT"   # BE-003 -> EXP-B7-POLICY-BE003-PREFLIGHT
  log="$EVID/${task}-${arm}.log"
  echo ""; echo "======== $task $arm  key=$key ========"
  local -a env=(RUNTIME=claude "BENCHMARK=$task" "EXPERIMENT=$key" "MODEL=$MODEL"
                ISOLATE_USER_SETTINGS=1 KEEP=1 API_PORT=18081
                OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200
                "INIT_SCHEMA_DIR=$EVID/init-schema")
  if [[ "$arm" == treated ]]; then
    env+=("CUSTOMIZATION=$OVERLAY_T" "AGENT=$AGENT_NAME" VARIANT=verify-v1.0)
  else
    env+=("CUSTOMIZATION=$OVERLAY_C" "AGENT=$AGENT_NAME" VARIANT=phases-v1.0)
  fi
  ( cd "$OBS" && env "${env[@]}" make run-benchmark ) > "$log" 2>&1
  rc=$?
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  ah="$(api "${rid:-x}" | jq -r '.customization.agentHash // "null"')"
  mc="$(api "${rid:-x}" | jq -r '.behavior.modelCalls // "null"')"
  pl="ABSENT"; pn=0
  if [[ -n "$wt" && -f "$wt/.ai/policy-events.jsonl" ]]; then
    pl="PRESENT"; pn="$(grep -c . "$wt/.ai/policy-events.jsonl" 2>/dev/null || echo 0)"
  fi
  # check-init-schema.sh writes a THREE-LINE TEXT report, not JSON:
  #   init-schema: delivered n=4 ["Read","Edit","Write","Bash"]
  #   init-schema: declared  n=4 [...]
  #   init-schema: verdict=match
  # Parsing it as JSON returns nothing and reads as "UNREAD" -- which is what the first
  # version of this line did. The delivered list AND the verdict are both recorded, because
  # stop 9 measured `Read, Grep, Glob, Bash` being DELIVERED as ["Read","Bash"] on 10 of 10
  # runs: the declared list is a claim about a file and only the delivered one is evidence.
  it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$arm" "${rid:-NONE}" "$rc" "${wt:-NONE}" "$ah" "$pl" "$pn" "$mc" "$it" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc agentHash=$ah policy_log=$pl($pn lines) modelCalls=$mc"
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-preflight: $LAUNCH_CLAUDE -> $cv" >&2; exit 9; }
}

for t in "${TASKS[@]}"; do one "$t" treated; one "$t" control; done

echo ""; echo "manifest: $MANIFEST"; echo "PREFLIGHT DONE"
