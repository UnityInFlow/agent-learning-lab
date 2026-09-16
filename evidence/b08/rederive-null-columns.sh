#!/usr/bin/env bash
#
# rederive-null-columns — recover the two columns run-b8-batch.sh recorded as null, from the
# run records it already saved, WITHOUT re-running anything.
#
# THE DEFECT: the driver read `.durationMs` and `.changedFiles` at the top level of the run
# record. They are not there. The record carries `.efficiency.durationMs` and
# `.result.changedFiles` (an ARRAY of paths, so a count is `length`, not the value). Every row
# of the batch manifest therefore reads `null` in those two columns.
#
# WHY THIS IS A RE-DERIVATION AND NOT A REPAIR: no run is touched, no manifest row is edited,
# and nothing is overwritten (§4 step 12, §6). The driver saved the API's own run record to
# evidence/b08/worktrees/<run id>/run-record.json the moment each run ended, so the values were
# never lost — only mis-addressed on their way into one TSV column. The output is a NEW file
# beside the manifest; the manifest keeps its nulls, and the two files together are the honest
# record of what the instrument did and what the runs did.
#
# It is also the same failure mode this project keeps meeting and the state file names in as
# many words: `.behavior.modelCalls` not `.overhead.*`, `.efficiency.estimatedCost` not
# top-level. A wrong jq path reads null and looks exactly like a missing measurement.
#
# Usage: evidence/b08/rederive-null-columns.sh [output.tsv]
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

OUT="${1:-evidence/b08/rederived-columns.tsv}"
n=0; missing=0
printf 'run_id\tduration_ms\tchanged_files\tadded_lines\tdeleted_lines\tproduction_files\tunrelated_files\n' > "$OUT"
for d in evidence/b08/worktrees/*/; do
  rid="$(basename "$d")"
  rec="$d/run-record.json"
  [[ -r "$rec" ]] || { echo "no run record for $rid" >&2; missing=$((missing+1)); continue; }
  jq -er --arg rid "$rid" '
    [$rid,
     (.efficiency.durationMs // "null"|tostring),
     (if .result.changedFiles then (.result.changedFiles|length|tostring) else "null" end),
     (.result.addedLines // "null"|tostring),
     (.result.deletedLines // "null"|tostring),
     (.evaluation.productionFilesChanged // "null"|tostring),
     (.evaluation.unrelatedFilesChanged // "null"|tostring)] | @tsv' "$rec" >> "$OUT" 2>/dev/null \
    || { echo "unparseable run record for $rid" >&2; missing=$((missing+1)); continue; }
  n=$((n+1))
done
echo "rederive-null-columns: $n records read, $missing unreadable -> $OUT"
[[ "$missing" -eq 0 ]] || exit 1
