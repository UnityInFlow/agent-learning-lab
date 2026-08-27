#!/usr/bin/env bash
# The validator is a Layer 2 control, so it is code, and code that has never been shown to
# reject anything is indistinguishable from code that rejects nothing. `--dir` silently
# selecting a default agent and exiting 0 is the same class of failure, one directory over.
#
# Every fixture in tools/fixtures/run-records/ is registered here with the exit code it
# must produce. A fixture that stops discriminating fails this script.
#
#   ./tools/verify-run-record-validator.sh
#
# Exit 0 if every fixture produced its registered code, 1 otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# fixture:expected-exit — 0 valid, 2 invalid
CASES=(
  "valid-level-a.yaml:0"
  "valid-level-c.yaml:0"
  "valid-mixed.yaml:0"
  "bad-bare-scalar.yaml:2"
  "bad-zero-for-unknown.yaml:2"
  "bad-value-without-source.yaml:2"
  "bad-provider-estimated.yaml:2"
  "bad-null-with-source.yaml:2"
  "bad-unknown-source.yaml:2"
  "bad-missing-telemetry-complete.yaml:2"
  "bad-missing-block.yaml:2"
)

dir=tools/fixtures/run-records
fail=0

# A fixture nobody registered is a fixture nobody tests.
for f in "$dir"/*.yaml; do
  base="$(basename "$f")"
  case " ${CASES[*]} " in
    *" $base:"*) ;;
    *) echo "UNREGISTERED  $base — add it to CASES with its expected exit code"; fail=1 ;;
  esac
done

for case_ in "${CASES[@]}"; do
  name="${case_%%:*}"
  want="${case_##*:}"
  ./tools/validate-run-record.sh "$dir/$name" >/dev/null 2>&1
  got=$?
  if [ "$got" = "$want" ]; then
    printf 'ok    %-38s exit %s\n' "$name" "$got"
  else
    printf 'FAIL  %-38s exit %s, expected %s\n' "$name" "$got" "$want"
    fail=1
  fi
done

# And the artifact the whole thing exists to protect.
./tools/validate-run-record.sh templates/run-record.yaml >/dev/null 2>&1
got=$?
if [ "$got" = 0 ]; then
  printf 'ok    %-38s exit 0\n' "templates/run-record.yaml"
else
  printf 'FAIL  %-38s exit %s, expected 0\n' "templates/run-record.yaml" "$got"
  fail=1
fi

exit "$fail"
