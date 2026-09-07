#!/usr/bin/env bash
# Does the set of admitted sheets cover the owed run ids exactly, one each?
# check-sheet-categories.sh admits by SHAPE; this admits by IDENTITY. Both are needed:
# 34 well-formed sheets could still be two sheets for one run and none for another.
# Registered by validator round 3 of 2026-09-07, finding 1.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
IDS_FILE="${1:-evidence/second-reader/owed-run-ids.txt}"
PROBE="e8d881b9-5fb2-406e-947a-d32e107e157a"
rc=0; n_ok=0; n_bad=0
while read -r id; do
  [ -z "$id" ] && continue
  admitted=0
  for f in findings/opencode/score-observatory-run-"$id"-20260907T*.yaml; do
    [ -e "$f" ] || continue
    if ./tools/check-sheet-categories.sh benchmark/rubrics/backend-quality.yaml "$f" >/dev/null 2>&1; then
      admitted=$((admitted+1))
    fi
  done
  if [ "$admitted" -eq 1 ]; then
    n_ok=$((n_ok+1))
  else
    n_bad=$((n_bad+1)); rc=1
    echo "FAIL ${id:0:8} — $admitted admitted sheets from 2026-09-07, expected exactly 1"
  fi
done < <(printf '%s\n%s\n' "$PROBE" "$(cat "$IDS_FILE")")
echo "verify-sheet-coverage: $n_ok run id(s) with exactly one admitted sheet, $n_bad without"
exit $rc
