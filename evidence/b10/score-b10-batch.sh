#!/usr/bin/env bash
# Score every run of B10 batch 20260927T125809Z with the REGISTERED scorer (codex), one run
# at a time, appending a row only for a COMPLETE sheet so the file is a progress record and a
# resumed invocation never re-scores a run it already scored, and never records a stall as a
# score.
#
#   ./evidence/b10/score-b10-batch.sh                    from agent-learning-lab/
#   LAB_SCORE_TIMEOUT=900 ./evidence/b10/score-b10-batch.sh
#
# Registered rubrics, ASSERTED here rather than trusted: BE-003 -> backend-quality.yaml at
# 396e1799eb2b, BE-004 -> backend-quality-be004.yaml at 6252778b8472. A sha that has moved is
# a registered variable moving mid-experiment (§6) and this script refuses to run at all.
#
# WHY THE BUDGET LIVES HERE AND NOT IN codex-score.sh. The registered scorer has no timeout of
# its own (`grep -n timeout tools/codex-score.sh` returns nothing) and a `codex exec` under it
# has twice sat at 0.0 % CPU for around an hour and STILL WRITTEN A SHEET. codex-score.sh is
# the instrument that produces this experiment's numbers, so the budget is added around it and
# not inside it. macOS has no `timeout`, so the watchdog kills the process GROUP; a plain
# `kill $pid` leaves the `codex exec` child alive, which is how the first stall outlived its
# parent. This driver is the stop-20 driver (evidence/b09/score-b9-batch.sh) with the manifest
# reader changed, and that provenance is the reason its guards are already known to fire.
#
# A STALL IS NOT A SCORE, AND THE TEST IS THE SHEET, NOT THE EXIT CODE. A completed sheet
# carries exactly one `score:` line per rubric category — four. Both registered rubrics have
# four categories, so the same test serves both tasks. Stall artefacts are KEPT, never deleted
# (§6), and are marked by the `stall`/`timeout` rc in the progress file with sheet `none`, so a
# later invocation retries them rather than reading them as zeros.
#
# Exit 0 every run scored · 2 a rubric sha moved · 3 the batch manifest is unreadable or is
# not the registered 20 rows · 8 another scoring driver holds the lock.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3

BATCH=evidence/b10/batch-20260927T125809Z
MANIFEST="$BATCH/manifest.tsv"
OUT="$BATCH/codex-sheets.tsv"
LOCK=evidence/b10/.score.lock
BUDGET="${LAB_SCORE_TIMEOUT:-900}"

[ -r "$MANIFEST" ] || { echo "cannot read $MANIFEST" >&2; exit 3; }

R3=benchmark/rubrics/backend-quality.yaml
R4=benchmark/rubrics/backend-quality-be004.yaml
[ "$(shasum -a 256 "$R3" | cut -c1-12)" = "396e1799eb2b" ] || { echo "BE-003 rubric sha MOVED" >&2; exit 2; }
[ "$(shasum -a 256 "$R4" | cut -c1-12)" = "6252778b8472" ] || { echo "BE-004 rubric sha MOVED" >&2; exit 2; }

# The registered population is 20 runs. A manifest that is not 20 data rows is either a
# resumed batch that never finished or the wrong file, and scoring it would produce a
# population nobody registered.
rows=$(awk -F'\t' '!/^#/ && $1 != "task" && NF >= 4 {n++} END {print n+0}' "$MANIFEST")
[ "$rows" -eq 20 ] || { echo "manifest has $rows data rows, registered population is 20" >&2; exit 3; }

# One scoring driver at a time. Two codex calls on one quota is how a sheet gets attributed to
# the wrong run id.
if [ -e "$LOCK" ] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "another scoring driver holds $LOCK (pid $(cat "$LOCK"))" >&2; exit 8
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

# Newest file in findings/codex/ by mtime, NUL-safe, without parsing `ls`.
newest_sheet() {
  find findings/codex -maxdepth 1 -type f -print0 2>/dev/null \
    | xargs -0 stat -f '%m %N' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-
}

# A completed sheet carries one `score:` line per rubric category. Four, or it is a stall.
sheet_complete() { [ "$(grep -c '^ *score:' "$1" 2>/dev/null)" -eq 4 ]; }

# Run a command under a wall-clock budget, killing the whole process GROUP on expiry.
# Writes the command's exit status to <rcfile>; the caller reads it. 124 means expired.
run_limited() {   # <seconds> <rcfile> -- <command...>
  local secs="$1" rcfile="$2"; shift 3
  set -m
  ( "$@" ) & local pid=$!
  ( sleep "$secs"; kill -TERM -"$pid" 2>/dev/null; sleep 5; kill -KILL -"$pid" 2>/dev/null ) & local dog=$!
  wait "$pid"; local rc=$?
  kill "$dog" 2>/dev/null; wait "$dog" 2>/dev/null
  set +m
  [ "$rc" -ge 128 ] && rc=124
  echo "$rc" > "$rcfile"
}

[ -s "$OUT" ] || printf 'task\tseq\tarm\trun_id\tscore_exit\tsheet\n' > "$OUT"
RCF=$(mktemp)
trap 'rm -f "$RCF" "$LOCK"' EXIT

awk -F'\t' '!/^#/ && $1 != "task" && NF >= 4 {print $1"\t"$2"\t"$3"\t"$4}' "$MANIFEST" \
| while IFS=$'\t' read -r task seq arm rid; do
  grep -q "	$rid	" "$OUT" && { echo "skip already scored $rid"; continue; }
  case "$task" in
    BE-003) rubric="$R3" ;;
    BE-004) rubric="$R4" ;;
    *) echo "unknown task $task" >&2; continue ;;
  esac

  rc=0; sheet="none"
  for attempt in 1 2; do
    before=$(newest_sheet)
    echo "=== $task $seq $arm $rid attempt $attempt ($(date -u +%H:%M:%SZ))"
    run_limited "$BUDGET" "$RCF" -- ./tools/codex-score.sh "$rubric" --run-id "$rid"
    rc=$(cat "$RCF")
    after=$(newest_sheet)
    if [ "$after" != "$before" ] && sheet_complete "$after"; then
      sheet="$after"; break
    fi
    sheet="none"
    [ "$rc" -eq 0 ] && rc=stall
    [ "$rc" = "124" ] && rc=timeout
    echo "    attempt $attempt did not produce a complete sheet (rc=$rc)"
  done

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$task" "$seq" "$arm" "$rid" "$rc" "$sheet" >> "$OUT"
done

echo "=== scoring finished, $(($(wc -l < "$OUT") - 1)) rows in $OUT"
