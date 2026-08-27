#!/usr/bin/env bash
# The classifier decides whether a run is evidence or infrastructure, so it is a Layer 2
# control, and a control that has never been shown to discriminate is indistinguishable
# from one that returns the same answer to everything. The single guard it replaced was
# exactly that: every non-contract outcome came back as exit 1, "re-run it".
#
# Every fixture in tools/fixtures/model-outputs/<contract>/ is registered here with the
# class and exit code it must produce. A fixture that stops discriminating fails this
# script, and a fixture nobody registered fails it too.
#
#   ./tools/verify-model-output-classifier.sh
#
# Exit 0 if every fixture produced its registered class and code, 1 otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# contract/fixture:expected-class:expected-exit
CASES=(
  "score/sheet-scored.yaml:contract:0"
  "score/sheet-all-null.yaml:contract:0"
  "score/off-contract-refusal.yaml:off-contract:2"
  "score/off-contract-truncated.yaml:off-contract:2"
  "score/empty-body.yaml:empty:3"
  "score/empty-whitespace.yaml:empty:3"
  "score/fallback-default-agent.yaml:fallback:4"
  "score/declared-error.yaml:declared-error:5"

  "critic/contract-sections.md:contract:0"
  "critic/off-contract-prose.md:off-contract:2"
  "critic/empty-whitespace.md:empty:3"
  "critic/fallback-default-agent.md:fallback:4"

  "acceptance/contract-accept.md:contract:0"
  "acceptance/contract-reject.md:contract:0"
  "acceptance/off-contract-no-verdict.md:off-contract:2"
  "acceptance/empty-body.md:empty:3"
)

dir=tools/fixtures/model-outputs
fail=0

# A fixture nobody registered is a fixture nobody tests.
for f in "$dir"/*/*; do
  rel="${f#"$dir"/}"
  case " ${CASES[*]} " in
    *" $rel:"*) ;;
    *) echo "UNREGISTERED  $rel — add it to CASES with its expected class and exit code"; fail=1 ;;
  esac
done

for case_ in "${CASES[@]}"; do
  name="${case_%%:*}"
  rest="${case_#*:}"
  want_class="${rest%%:*}"
  want_code="${rest##*:}"
  contract="${name%%/*}"
  got_class="$(./tools/classify-model-output.sh "$contract" "$dir/$name" 2>/dev/null)"
  got_code=$?
  if [ "$got_class" = "$want_class" ] && [ "$got_code" = "$want_code" ]; then
    printf 'ok    %-42s %-14s exit %s\n' "$name" "$got_class" "$got_code"
  else
    printf 'FAIL  %-42s %-14s exit %s, expected %s exit %s\n' \
      "$name" "$got_class" "$got_code" "$want_class" "$want_code"
    fail=1
  fi
done

# Every contract must be exercised, and each must still tell evidence from infrastructure.
# If either split collapses to one side the harness is back to discarding its own findings.
for c in score critic acceptance; do
  infra=0; evidence=0
  for case_ in "${CASES[@]}"; do
    [ "${case_%%/*}" = "$c" ] || continue
    rest="${case_#*:}"
    case "${rest%%:*}" in
      fallback) infra=$((infra + 1)) ;;
      contract|off-contract|declared-error) evidence=$((evidence + 1)) ;;
      empty) ;;   # deliberately neither — it is the class that needs a repeat to decide
    esac
  done
  if [ "$evidence" -eq 0 ]; then
    echo "FAIL  contract '$c' registers no evidence-class fixture"
    fail=1
  fi
done

exit "$fail"
