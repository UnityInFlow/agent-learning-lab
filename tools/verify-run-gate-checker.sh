#!/usr/bin/env bash
# Proves check-run-gate.sh still refuses. A gate that stopped refusing is indistinguishable
# from one that is working, which is the whole reason this file exists.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
CHECK=./tools/check-run-gate.sh
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
fail=0

run_case() {
  local name="$1" want="$2" doc="$3"
  "$CHECK" "$doc" >/dev/null 2>&1
  local got=$?
  if [ "$got" = "$want" ]; then printf 'ok    %-48s exit %s\n' "$name" "$got"
  else printf 'FAIL  %-48s exit %s, expected %s\n' "$name" "$got" "$want"; fail=1; fi
}

w() { printf '%s' "$2" > "$WORK/$1"; echo "$WORK/$1"; }

# The run document shape the API returns
run_case "run doc, passed, exit 0"            0 "$(w pass.json '{"id":"r1","evaluation":{"passed":true,"exitCode":0,"correctness":{"taskAttempted":true}}}')"
# The bare evaluation shape the runner writes
run_case "bare evaluation, passed, exit 0"    0 "$(w bare.json '{"passed":true,"exitCode":0}')"

run_case "evaluator failed (exit 12)"         2 "$(w f12.json '{"evaluation":{"passed":false,"exitCode":12,"failureClass":"functional"}}')"
run_case "wrong envelope (exit 13)"           2 "$(w f13.json '{"evaluation":{"passed":false,"exitCode":13}}')"
run_case "passed true but exitCode nonzero"   2 "$(w mix.json '{"evaluation":{"passed":true,"exitCode":30}}')"

# The one 0A.3 exists to teach: blocked is not wrong, and neither is a submission.
run_case "task NOT attempted"                 2 "$(w noatt.json '{"evaluation":{"passed":true,"exitCode":0,"correctness":{"taskAttempted":false}}}')"

# Fail closed. Absence of a verdict must never read as a verdict.
run_case "run with no evaluation at all"      1 "$(w noeval.json '{"id":"r9","status":"COMPLETED"}')"
run_case "evaluation present but no passed"   1 "$(w nopass.json '{"evaluation":{"exitCode":0}}')"
run_case "evaluation present but no exitCode" 1 "$(w noexit.json '{"evaluation":{"passed":true}}')"
run_case "empty object"                       1 "$(w empty.json '{}')"
run_case "not JSON at all"                    1 "$(w bad.json 'this is not json')"
run_case "file does not exist"                1 "$WORK/absent.json"

"$CHECK" >/dev/null 2>&1; [ $? = 1 ] \
  && printf 'ok    %-48s exit 1\n' "no argument" \
  || { printf 'FAIL  no argument\n'; fail=1; }

echo
if [ "$fail" = 0 ]; then echo "verify-run-gate-checker: all 13 cases behaved as specified."
else echo "verify-run-gate-checker: FAILURES above."; fi
exit "$fail"
