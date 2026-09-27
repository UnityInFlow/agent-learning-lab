#!/usr/bin/env bash
# Score every run of B9 batch 20260926T151319Z with the REGISTERED scorer (codex), one run
# at a time, appending a row BEFORE it starts the next call so the file is a progress record
# and a resumed invocation never re-scores a run it already scored.
#
#   ./evidence/b09/score-b9-batch.sh            from agent-learning-lab/
#   LAB_SCORE_TIMEOUT=420 ./evidence/b09/score-b9-batch.sh
#
# Registered rubrics, asserted here rather than trusted: BE-003 -> backend-quality.yaml at
# 396e1799eb2b, BE-004 -> backend-quality-be004.yaml at 6252778b8472. A sha that has moved is
# a registered variable that moved mid-experiment (§6) and this script refuses to run.
#
# THE STALL BUDGET, AND WHY IT IS HERE RATHER THAN IN codex-score.sh. On 2026-09-27 a
# `codex exec` under codex-score.sh sat at 0.0 % CPU for sixty-one minutes on run
# 4bf8abf5 and never returned — the opencode stall mode (§6), on the codex route, where no
# budget existed at all: `grep -n timeout tools/codex-score.sh` returns nothing. The budget
# lives in this driver and not in the registered scorer because codex-score.sh is the
# instrument that produces the experiment's numbers and this run is not the place to change
# it. macOS has no `timeout`/`gtimeout`, so the watchdog is a background killer on the
# process GROUP; a plain `kill $pid` leaves the `codex exec` child alive, which is how the
# first stall survived its parent.
#
# A STALL IS NOT A SCORE, AND THE TEST IS THE SHEET, NOT THE EXIT CODE. The stalled call
# still left a 1.3k sheet on disk carrying its provenance header and zero `score:` lines,
# where a completed sheet has exactly four. So completeness is checked by counting them.
# Stall artefacts are kept, never deleted (§6), and labelled by the `stall` rc in this file.
#
# Exit 0 every run scored · 2 a rubric sha moved · 3 the batch manifest is unreadable.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3

BATCH=evidence/b09/batch-20260926T151319Z
IDS="$BATCH/run-ids.tsv"
OUT="$BATCH/codex-sheets.tsv"
BUDGET="${LAB_SCORE_TIMEOUT:-420}"
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
trap 'rm -f "$RCF"' EXIT

while IFS=$'\t' read -r task seq arm rid _wt; do
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
done < "$IDS"

echo "=== scoring finished, $(($(wc -l < "$OUT") - 1)) rows in $OUT"
