#!/usr/bin/env bash
#
# verify-policy-gate — the fixture set for B7's ONE executing control,
# build/customizations/verify-v1.0/.ai/hooks/policy-gate.sh.
#
# It exercises THE REGISTERED FILE, never a copy, because a fixture set that tests a copy
# proves something about the copy. Four things have to hold and only the first is obvious:
#
#   1. it DENIES what the policy names, at exit 2
#   2. it ALLOWS what the policy does not name -- a guardrail that denies legitimate work
#      has a false-positive rate, which is the gate clause B7 is measured on
#   3. it LOGS BOTH, because the log is this treatment's only per-run delivery proof
#      (run-agent.sh records no settings or hook hash, and the API record carries no
#      environment object), and a hook that logs only denials is indistinguishable from a
#      hook that never ran
#   4. it FAILS OPEN LOUDLY. Every exit code except 2 means "the action proceeds"
#      (Claude Code hooks reference, extracted in phases/05a-guardrails/). So the honest
#      requirement is not "never fail" but "when it fails, say so in the log", or a run
#      whose gate silently died is indistinguishable afterwards from a run whose gate
#      allowed everything on purpose.
#
# Cases marked NEGATIVE CONTROL are ones a NAIVE implementation gets wrong -- a substring
# matcher would deny `DockerfileParser.kt` and `pom.xml.md`. They are here because
# tools/naive-phase-checker.py earned its place at stop 12 the same way.
#
# Usage: tools/verify-policy-gate.sh
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
OVERLAY="$PWD/build/customizations/verify-v1.0"
GATE="$OVERLAY/.ai/hooks/policy-gate.sh"
[[ -x "$GATE" ]] || { echo "policy-gate.sh not found or not executable: $GATE" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-52s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-52s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
mkdir -p "$SANDBOX/.ai"
cp -R "$OVERLAY/.ai/policies" "$SANDBOX/.ai/"
cp -R "$OVERLAY/.ai/hooks"    "$SANDBOX/.ai/"
export CLAUDE_PROJECT_DIR="$SANDBOX"
# The gate writes OUTSIDE the worktree since 2026-09-10 (see the header of policy-gate.sh:
# its log inside the repo was scored as an unrelated production file and failed two
# otherwise-correct preflight runs at exit 21). POLICY_EVENT_LOG pins it for the fixtures,
# and the DEFAULT path is asserted separately below so this override cannot hide a
# regression in the default.
LOG="$SANDBOX/policy-events.jsonl"
export POLICY_EVENT_LOG="$LOG"

call() {  # call <tool> <path> -> exit code, and appends to LOG
  printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$SANDBOX/$2" | "$GATE" >/dev/null 2>&1
}

expect() {  # expect <label> <want-exit> <want-decision> <tool> <relpath>
  local label="$1" want="$2" wantdec="$3" tool="$4" path="$5" got dec
  call "$tool" "$path"; got=$?
  dec="$(tail -1 "$LOG" 2>/dev/null | jq -r '.decision' 2>/dev/null)"
  if [[ "$got" == "$want" && "$dec" == "$wantdec" ]]; then
    ok "$label" "exit $got, logged $dec"
  else
    bad "$label" "exit $want/$wantdec" "exit $got/${dec:-<nothing logged>}"
  fi
}

echo "verify-policy-gate: fixture set for build/customizations/verify-v1.0/.ai/hooks/policy-gate.sh"
echo
echo "DENY — the paths protected-paths.yaml names (exit 2, logged deny):"
expect "pom.xml at the repository root"            2 deny Edit  "pom.xml"
expect "pom.xml nested in the service"             2 deny Edit  "sample-service/pom.xml"
expect "build.gradle.kts"                          2 deny Write "app/build.gradle.kts"
expect "settings.gradle"                           2 deny Edit  "settings.gradle"
expect "gradle.properties"                         2 deny Edit  "gradle.properties"
expect "a lockfile"                                2 deny Write "yarn.lock"
expect "package-lock.json"                         2 deny Write "package-lock.json"
expect "a CI workflow"                             2 deny Edit  ".github/workflows/ci.yml"
expect "anything under .github/"                   2 deny Write ".github/dependabot.yml"
expect "a Dockerfile"                              2 deny Write "Dockerfile"
expect "a nested Dockerfile"                       2 deny Write "service/Dockerfile"
expect "docker-compose.yml"                        2 deny Edit  "docker-compose.yml"
expect "docker-compose.override.yaml"              2 deny Edit  "docker-compose.override.yaml"
expect "infra/"                                    2 deny Write "infra/main.tf"
expect "deploy/"                                   2 deny Write "deploy/values.yaml"
expect "charts/"                                   2 deny Write "charts/app/Chart.yaml"
expect "k8s/"                                      2 deny Write "k8s/deployment.yaml"
expect ".env"                                      2 deny Write ".env"
expect ".env.local"                                2 deny Write ".env.local"
expect "NotebookEdit is covered too"               2 deny NotebookEdit "pom.xml"

echo
echo "ALLOW — everything the policy does not name (exit 0, logged allow):"
expect "the feature's own production package"      0 allow Edit  "sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentService.kt"
expect "the shared api package"                    0 allow Edit  "sample-service/src/main/kotlin/com/unityinflow/sample/api/ApiError.kt"
expect "a new test file"                           0 allow Write "sample-service/src/test/kotlin/com/unityinflow/sample/shipment/ConfirmTest.kt"
expect "a resource yml inside src/"                0 allow Edit  "sample-service/src/main/resources/application.yml"
expect "a README"                                  0 allow Write "README.md"

echo
echo "ALLOW — NEGATIVE CONTROLS, where a substring matcher would over-deny:"
expect "DockerfileParser.kt is source, not a Dockerfile" 0 allow Write "sample-service/src/main/kotlin/com/unityinflow/sample/shipment/DockerfileParser.kt"
expect "pom.xml.md is a document, not a build file"      0 allow Write "docs/pom.xml.md"
expect "a path merely CONTAINING .github as text"        0 allow Write "sample-service/src/main/kotlin/GithubClient.kt"
expect "locked.kt is not a lockfile"                     0 allow Write "sample-service/src/main/kotlin/locked.kt"
expect "infrastructure.md is not infra/"                 0 allow Write "docs/infrastructure.md"

echo
echo "FAIL OPEN, LOUDLY — every exit code but 2 means the action proceeds:"
got=$(printf '{"tool_name":"Edit","tool_input":{}}' | "$GATE" >/dev/null 2>&1; echo $?)
dec="$(tail -1 "$LOG" | jq -r '.decision')"; rsn="$(tail -1 "$LOG" | jq -r '.reason')"
if [[ "$got" == 0 && "$dec" == error && "$rsn" == *no-path* ]]; then
  ok "no path in tool_input: proceeds AND is logged as error" "exit 0, $rsn"
else bad "no path in tool_input" "exit 0/error/no-path" "exit $got/$dec/$rsn"; fi

MOVED="$SANDBOX/.ai/policies/protected-paths.yaml"
mv "$MOVED" "$MOVED.hidden"
got=$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s/pom.xml"}}' "$SANDBOX" | "$GATE" >/dev/null 2>&1; echo $?)
dec="$(tail -1 "$LOG" | jq -r '.decision')"; rsn="$(tail -1 "$LOG" | jq -r '.reason')"
mv "$MOVED.hidden" "$MOVED"
if [[ "$got" == 0 && "$dec" == error && "$rsn" == *policy-file-unreadable* ]]; then
  ok "policy file unreadable: a DENY path is ALLOWED, and logged" "exit 0, $rsn"
else bad "policy file unreadable" "exit 0/error/policy-file-unreadable" "exit $got/$dec/$rsn"; fi

echo
echo "THE DELIVERY PROOF — the log exists because the hook ran, on allow as well as deny:"
TOTAL="$(grep -c . "$LOG")"; ALLOWS="$(jq -r 'select(.decision=="allow")|.decision' "$LOG" | grep -c . || true)"
DENIES="$(jq -r 'select(.decision=="deny")|.decision' "$LOG" | grep -c . || true)"
ERRORS="$(jq -r 'select(.decision=="error")|.decision' "$LOG" | grep -c . || true)"
if [[ "$TOTAL" -eq $((ALLOWS+DENIES+ERRORS)) && "$ALLOWS" -gt 0 && "$DENIES" -gt 0 && "$ERRORS" -gt 0 ]]; then
  ok "every call logged exactly once, all three decisions present" "$TOTAL = $ALLOWS allow + $DENIES deny + $ERRORS error"
else
  bad "every call logged exactly once" "total == allow+deny+error, all three > 0" "$TOTAL vs $ALLOWS/$DENIES/$ERRORS"
fi
if jq -e 'select(.policy != "protected-paths")' "$LOG" >/dev/null 2>&1; then
  bad "every entry names its policy" "protected-paths on all" "an entry did not"
else ok "every entry names its policy" "protected-paths"; fi

echo
echo "THE LOG'S DEFAULT LOCATION — outside the worktree, because inside it fails the evaluator:"
DEFDIR="$(mktemp -d)"; mkdir -p "$DEFDIR/observatory-run-deadbeef/.ai"
cp -R "$OVERLAY/.ai/policies" "$DEFDIR/observatory-run-deadbeef/.ai/"
( unset POLICY_EVENT_LOG
  TMPDIR="$DEFDIR" CLAUDE_PROJECT_DIR="$DEFDIR/observatory-run-deadbeef" \
    bash -c 'printf "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"x.kt\"}}" | "$0"' "$GATE" >/dev/null 2>&1 )
if [[ -f "$DEFDIR/policy-events-observatory-run-deadbeef.jsonl" ]]; then
  ok "default log is \$TMPDIR/policy-events-<worktree>.jsonl" "outside the worktree"
else bad "default log location" "\$TMPDIR/policy-events-observatory-run-deadbeef.jsonl" "not written there"; fi
if [[ -e "$DEFDIR/observatory-run-deadbeef/.ai/policy-events.jsonl" ]]; then
  bad "nothing is written INSIDE the worktree" "no such file" "the gate wrote into the repo under test"
else ok "nothing is written INSIDE the worktree" "confirmed absent"; fi
rm -rf "$DEFDIR"

echo
echo "  $PASS of $N cases pass"
rm -rf "$SANDBOX"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
