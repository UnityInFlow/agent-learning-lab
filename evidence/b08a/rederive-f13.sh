#!/usr/bin/env bash
# rederive-f13 — the f13 column run-b8a-batch.sh does not have.
#
# F13 is the runner's own category for "timeout/rate limit" (run-agent.sh:1101, :1360) and it
# is an EXCLUSION: such a run measured the network, not the variant. evidence/b08/run-b8-batch.sh
# carried an f13 column; the B8a driver was written without one, and §4 step 4 forbids editing a
# tool while a run of it is in flight, so it is re-derived here from the logs the batch already
# wrote — the same route evidence/b08/rederive-null-columns.sh took for a wrong jq path.
#
# NOTHING IS EXCLUDED BY THIS SCRIPT. It counts and reports; the exclusion is a decision written
# into the experiment file with its reason, as §4 step 6 requires ("if a run's duration looks
# contaminated, say so and exclude duration, not the run").
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
D="${1:?usage: rederive-f13.sh <batch dir>}"
printf 'seq\tarm\trun_id\thttp_529\tapi_error\trate_limit\tdur_s\tmodel_calls\tchanged\n'
for f in "$D"/BE-005-*-*.log; do
  b="$(basename "$f" .log)"; seq="${b#BE-005-}"; arm="${seq#*-}"; seq="${seq%%-*}"
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$f" | head -1 | awk '{print $2}')"
  n529="$(/usr/bin/grep -ac '529' "$f" 2>/dev/null)"
  nerr="$(/usr/bin/grep -ac 'api_error' "$f" 2>/dev/null)"
  nrl="$(/usr/bin/grep -aci 'rate_limit' "$f" 2>/dev/null)"
  # BSD grep has no -P, so the manifest lookup is awk on field 3. The first version used
  # `grep -P "\t<rid>\t"`, which matched nothing on macOS and printed `?` in three columns —
  # a lookup that fails silently reads exactly like a missing measurement.
  row="$(awk -F'\t' -v r="$rid" '$3==r{print; exit}' "$D/manifest.tsv" 2>/dev/null)"
  dur="$(printf '%s' "$row" | cut -f22)"; mc="$(printf '%s' "$row" | cut -f19)"; chg="$(printf '%s' "$row" | cut -f23)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:0:8}" "${n529:-0}" "${nerr:-0}" "${nrl:-0}" "$(( ${dur:-0} / 1000 ))" "${mc:-?}" "${chg:-?}"
done
