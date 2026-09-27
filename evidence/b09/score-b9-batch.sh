#!/usr/bin/env bash
# Score every run of B9 batch 20260926T151319Z with the REGISTERED scorer (codex), one run
# at a time, appending a row BEFORE it starts the next call so the file is a progress record
# and a resumed invocation never re-scores a run it already scored.
#
# ./evidence/b09/score-b9-batch.sh            from agent-learning-lab/
#
# Registered rubrics, asserted here rather than trusted: BE-003 -> backend-quality.yaml at
# 396e1799eb2b, BE-004 -> backend-quality-be004.yaml at 6252778b8472. A sha that has moved is
# a registered variable that moved mid-experiment (§6) and this script refuses to run.
#
# Exit 0 every run scored · 2 a rubric sha moved · 3 the batch manifest is unreadable.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3

BATCH=evidence/b09/batch-20260926T151319Z
IDS="$BATCH/run-ids.tsv"
OUT="$BATCH/codex-sheets.tsv"
[ -r "$IDS" ] || { echo "cannot read $IDS" >&2; exit 3; }

R3=benchmark/rubrics/backend-quality.yaml
R4=benchmark/rubrics/backend-quality-be004.yaml
[ "$(shasum -a 256 "$R3" | cut -c1-12)" = "396e1799eb2b" ] || { echo "BE-003 rubric sha MOVED" >&2; exit 2; }
[ "$(shasum -a 256 "$R4" | cut -c1-12)" = "6252778b8472" ] || { echo "BE-004 rubric sha MOVED" >&2; exit 2; }

# Newest file in findings/codex/ by mtime, NUL-safe, without parsing `ls`.
newest_sheet() {
  find findings/codex -maxdepth 1 -type f -print0 2>/dev/null \
    | xargs -0 stat -f '%m %N' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-
}

[ -s "$OUT" ] || printf 'task\tseq\tarm\trun_id\tscore_exit\tsheet\n' > "$OUT"

while IFS=$'\t' read -r task seq arm rid _wt; do
  grep -q "	$rid	" "$OUT" && { echo "skip already scored $rid"; continue; }
  case "$task" in
    BE-003) rubric="$R3" ;;
    BE-004) rubric="$R4" ;;
    *) echo "unknown task $task" >&2; continue ;;
  esac
  before=$(newest_sheet)
  echo "=== $task $seq $arm $rid"
  ./tools/codex-score.sh "$rubric" --run-id "$rid" >/dev/null 2>&1
  rc=$?
  after=$(newest_sheet)
  sheet="none"
  [ "$after" != "$before" ] && sheet="$after"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$task" "$seq" "$arm" "$rid" "$rc" "$sheet" >> "$OUT"
done < "$IDS"

echo "=== scoring finished, $(($(wc -l < "$OUT") - 1)) rows in $OUT"
