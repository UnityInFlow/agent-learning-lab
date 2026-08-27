#!/usr/bin/env bash
# The classifier decides whether a run is evidence or infrastructure, so it is a Layer 2
# control, and a control that has never been shown to discriminate is indistinguishable
# from one that returns the same answer to everything. The old single guard it replaces
# was exactly that: every non-sheet outcome came back as exit 1, "re-run it".
#
# Every fixture in tools/fixtures/score-outputs/ is registered here with the class and exit
# code it must produce. A fixture that stops discriminating fails this script.
#
#   ./tools/verify-score-output-classifier.sh
#
# Exit 0 if every fixture produced its registered class and code, 1 otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# fixture:expected-class:expected-exit
CASES=(
  "sheet-scored.yaml:sheet:0"
  "sheet-all-null.yaml:sheet:0"
  "off-contract-refusal.yaml:off-contract:2"
  "off-contract-truncated.yaml:off-contract:2"
  "empty-body.yaml:empty:3"
  "empty-whitespace.yaml:empty:3"
  "fallback-default-agent.yaml:fallback:4"
  "declared-error.yaml:declared-error:5"
)

dir=tools/fixtures/score-outputs
fail=0

# A fixture nobody registered is a fixture nobody tests.
for f in "$dir"/*.yaml; do
  base="$(basename "$f")"
  case " ${CASES[*]} " in
    *" $base:"*) ;;
    *) echo "UNREGISTERED  $base — add it to CASES with its expected class and exit code"; fail=1 ;;
  esac
done

for case_ in "${CASES[@]}"; do
  name="${case_%%:*}"
  rest="${case_#*:}"
  want_class="${rest%%:*}"
  want_code="${rest##*:}"
  got_class="$(./tools/classify-score-output.sh "$dir/$name" 2>/dev/null)"
  got_code=$?
  if [ "$got_class" = "$want_class" ] && [ "$got_code" = "$want_code" ]; then
    printf 'ok    %-32s %-14s exit %s\n' "$name" "$got_class" "$got_code"
  else
    printf 'FAIL  %-32s %-14s exit %s, expected %s exit %s\n' \
      "$name" "$got_class" "$got_code" "$want_class" "$want_code"
    fail=1
  fi
done

# Two classes are infrastructure and three are evidence. If that split ever collapses to one
# side, the harness is back to discarding its own findings and this script must say so.
infra=0
evidence=0
for case_ in "${CASES[@]}"; do
  rest="${case_#*:}"
  case "${rest%%:*}" in
    fallback) infra=$((infra + 1)) ;;
    sheet|off-contract|declared-error) evidence=$((evidence + 1)) ;;
    empty) ;;   # deliberately neither — it is the class that needs a repeat to decide
  esac
done
if [ "$infra" -eq 0 ] || [ "$evidence" -eq 0 ]; then
  echo "FAIL  the evidence/infrastructure split has collapsed — $infra infra, $evidence evidence"
  fail=1
fi

exit "$fail"
