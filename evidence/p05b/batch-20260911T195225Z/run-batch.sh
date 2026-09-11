#!/usr/bin/env bash
# Stop 16, §4 step 6 — E-017's registered batch, interleaved.
#
# 10 control + 5 arm D + 5 arm H, in the order C D C H repeated five times, so no arm is
# clustered in time. Serial on purpose: B7's first batch died because five concurrent runs
# starved `./mvnw test` of CPU (load average 202) and six runs had to be excluded by name.
#
# EVERY RUN IS APPENDED TO manifest.tsv BEFORE ITS EXIT CODE IS KNOWN, so a batch interrupted
# mid-run leaves a file saying what was in flight. Never relaunch from a guess; read this file.
#
# The endpoints are the COLIMA TUNNELS. infra/.env says API_PORT=8081, and plain 8081 on this
# machine answers for a second, empty stack — a control reporting over a scope smaller than it
# claims, wearing a port number.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OBS=/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-observatory
LAB=/Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab
EXP="EXP-5B5-PERMISSION-BLOCK-BE003"
MODEL=claude-haiku-4-5-20251001
MANIFEST="$HERE/manifest.tsv"
[[ -f "$MANIFEST" ]] || printf 'idx\tarm\tvariant\tstarted\trun_id\texit\tworktree\n' > "$MANIFEST"

# The CLI version at the start of the batch. B7's batch ended when claude moved 2.1.267 ->
# 2.1.268 mid-run; mixing two runtimes inside one comparison is an unregistered variable.
BASE_VERSION="$(claude --version 2>/dev/null | head -1)"
echo "batch base runtime: $BASE_VERSION" | tee -a "$HERE/batch.log"

one() { # one <idx> <arm> <variant> [customization-dir]
  local idx="$1" arm="$2" variant="$3" cust="${4:-}"
  local now; now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local v; v="$(claude --version 2>/dev/null | head -1)"
  if [[ "$v" != "$BASE_VERSION" ]]; then
    echo "ABORT: claude moved mid-batch: $BASE_VERSION -> $v" | tee -a "$HERE/batch.log"
    exit 9
  fi
  printf '%s\t%s\t%s\t%s\tPENDING\t-\t-\n' "$idx" "$arm" "$variant" "$now" >> "$MANIFEST"
  local log="$HERE/run-${idx}-${arm}.log"
  ( cd "$OBS" && OTLP_HTTP_ENDPOINT=http://127.0.0.1:14318 \
      OTLP_GRPC_ENDPOINT=http://127.0.0.1:14317 \
      ./runner/run-agent.sh --runtime claude --benchmark BE-003 \
        --variant "$variant" --experiment "$EXP" \
        --api http://127.0.0.1:18081 --web http://127.0.0.1:15174 \
        ${cust:+--customization "$cust"} \
        --model "$MODEL" --isolate-user-settings --keep ) > "$log" 2>&1
  local rc=$?
  local rid wt
  rid="$(LC_ALL=C grep -ao 'api/runs/[0-9a-f-]\{36\}' "$log" | head -1 | sed 's|api/runs/||')"
  wt="$(LC_ALL=C grep -ao 'worktree kept at .*' "$log" | head -1 | sed 's|worktree kept at ||')"
  # Replace the PENDING row for this idx rather than appending a second one.
  awk -F'\t' -v i="$idx" -v r="${rid:-NONE}" -v e="$rc" -v w="${wt:-NONE}" 'BEGIN{OFS="\t"}
    $1==i && $5=="PENDING" {$5=r; $6=e; $7=w} {print}' "$MANIFEST" > "$MANIFEST.tmp" \
    && mv "$MANIFEST.tmp" "$MANIFEST"
  echo "$(date -u +%H:%M:%SZ) idx=$idx arm=$arm exit=$rc run=${rid:-NONE}" | tee -a "$HERE/batch.log"
}

i=0
for _cycle in 1 2 3 4 5; do
  i=$((i+1)); one "$i" control plain
  i=$((i+1)); one "$i" D blocked-deny-5b5 "$LAB/build/customizations/permission-block-deny-5b5"
  i=$((i+1)); one "$i" control plain
  i=$((i+1)); one "$i" H blocked-hook-5b5 "$LAB/build/customizations/permission-block-hook-5b5"
done
echo "BATCH COMPLETE $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$HERE/batch.log"
