#!/usr/bin/env bash
set -u
cd /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab || exit 1
export LAB_OBSERVATORY_API="http://127.0.0.1:18081"

TSV=/private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7b1fe12c-2f28-4ea3-b216-a29ba38b5ac3/scratchpad/remaining.tsv
RESULTS=/private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7b1fe12c-2f28-4ea3-b216-a29ba38b5ac3/scratchpad/results.tsv
LOGDIR=/private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7b1fe12c-2f28-4ea3-b216-a29ba38b5ac3/scratchpad/logs
mkdir -p "$LOGDIR"
rm -f "$LOGDIR/STOP_REASON"

n=1
while IFS=$'\t' read -r task arm run_id; do
  n=$((n+1))
  if [ "$task" = "BE-003" ]; then
    rubric=benchmark/rubrics/backend-quality.yaml
  elif [ "$task" = "BE-004" ]; then
    rubric=benchmark/rubrics/backend-quality-be004.yaml
  else
    echo -e "${task}\t${arm}\t${run_id}\tBADTASK\t\tunknown-rubric" >> "$RESULTS"
    continue
  fi

  logf="$LOGDIR/${n}-${run_id}.log"
  echo "=== [$n/36] $task $arm $run_id rubric=$rubric ===" | tee -a "$LOGDIR/driver.log"

  ./tools/codex-score.sh "$rubric" --run-id "$run_id" > "$logf" 2>&1
  rc=$?

  sheet=""
  if [ $rc -eq 0 ]; then
    sheet=$(tail -1 "$logf")
  fi

  if grep -qiE '\busage limit\b|\bquota exceeded\b|insufficient_quota|\brate limit exceeded\b|\btoo many requests\b|\bHTTP 429\b|\b429 error\b' "$logf"; then
    echo "QUOTA_HIT run_id=$run_id rc=$rc" | tee -a "$LOGDIR/driver.log"
    echo -e "${task}\t${arm}\t${run_id}\t${rc}\t${sheet}\tQUOTA_HIT" >> "$RESULTS"
    echo "STOPPED_AT_QUOTA:$run_id" > "$LOGDIR/STOP_REASON"
    exit 0
  fi

  echo -e "${task}\t${arm}\t${run_id}\t${rc}\t${sheet}\t" >> "$RESULTS"
  echo "  rc=$rc sheet=$sheet" | tee -a "$LOGDIR/driver.log"
done < "$TSV"

echo "ALL_DONE" > "$LOGDIR/STOP_REASON"
