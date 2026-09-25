#!/usr/bin/env bash
# Fixture set for run-mcp-hole-probe.sh — §4 step 4: "a control that has never
# been shown to reject anything is indistinguishable from one that rejects
# nothing." Every exit code the driver can return is provoked here by a real
# invocation. No case spends money: the happy path runs with PROBE_DRY_RUN=1.
#
# Exit 0 when every case returns its registered code; 1 otherwise.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DRIVER="$HERE/run-mcp-hole-probe.sh"
TMP="$(mktemp -d)" || exit 1
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0
CASES=0

# Never pipe the driver: a pipe would report the pipe's exit code, which is how
# a failing verifier gets reported as passing (§0a, this session).
check() {
  local name="$1" want="$2"; shift 2
  local got
  CASES=$((CASES + 1))
  env "$@" "$DRIVER" > "$TMP/out.$CASES" 2>&1
  got=$?
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %-44s exit %s\n' "$name" "$got"
    PASS=$((PASS + 1))
  else
    printf 'FAIL  %-44s want %s got %s\n' "$name" "$want" "$got"
    printf '      %s\n' "$(tail -2 "$TMP/out.$CASES" | tr '\n' ' ')"
    FAIL=$((FAIL + 1))
  fi
}

# Fixture A — a good fixture directory, copied so a case can corrupt one file.
GOOD="$TMP/good"; mkdir -p "$GOOD"
cp "$HERE/probe_server.py.fixture" "$GOOD/"
cp "$HERE/mcp.json.fixture" "$GOOD/"

# Fixture B — server present but mute: answers no tools/list.
MUTE="$TMP/mute"; mkdir -p "$MUTE"
printf 'import sys\nfor _ in sys.stdin: pass\n' > "$MUTE/probe_server.py.fixture"
cp "$HERE/mcp.json.fixture" "$MUTE/"

# Fixture C — mcp.json missing, server fine.
NOJSON="$TMP/nojson"; mkdir -p "$NOJSON"
cp "$HERE/probe_server.py.fixture" "$NOJSON/"

# Fixture D — empty fixture directory.
EMPTY="$TMP/empty"; mkdir -p "$EMPTY"

# Fixture E — a runner whose flag block has changed (--strict-mcp-config gone).
BADRUNNER="$TMP/bad-run-agent.sh"
{
  printf '      --permission-mode acceptEdits\n'
  printf '      --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"\n'
  printf '    CLAUDE_ARGS+=(--disable-slash-commands)\n'
  printf '    CLAUDE_ARGS+=(--setting-sources project)\n'
  printf '          --output-format stream-json --verbose \\\n'
} > "$BADRUNNER"

# Fixture F — a fake claude of the wrong version, on PATH.
FAKEBIN="$TMP/bin"; mkdir -p "$FAKEBIN"
printf '#!/bin/sh\necho "9.9.9 (Fake Claude)"\n' > "$FAKEBIN/claude-wrong"
chmod +x "$FAKEBIN/claude-wrong"

BASE=(PROBE_DRY_RUN=1 "PROBE_FIXTURE_DIR=$GOOD" "PROBE_WORKDIR=$TMP/wd"
      "PROBE_EVIDENCE=$TMP/ev" "PROBE_LOCK=$TMP/lock")

echo "verify-mcp-hole-probe-guards: 11 cases"
echo

check "A happy path, dry run"                0 "${BASE[@]}"
check "B claude binary missing"              2 "${BASE[@]}" PROBE_CLAUDE_BIN=/nonexistent/claude
check "C claude version not the registered"  2 "${BASE[@]}" PROBE_EXPECT_VERSION=9.9.9
check "D wrong-version claude on PATH"       2 "${BASE[@]}" "PROBE_CLAUDE_BIN=$FAKEBIN/claude-wrong"
check "E probe server fixture missing"       3 "${BASE[@]}" "PROBE_FIXTURE_DIR=$EMPTY"
check "F mcp.json fixture missing"           3 "${BASE[@]}" "PROBE_FIXTURE_DIR=$NOJSON"
check "G probe server answers no tools/list" 3 "${BASE[@]}" "PROBE_FIXTURE_DIR=$MUTE"
check "H runner flag block changed"          4 "${BASE[@]}" "PROBE_RUNNER=$BADRUNNER"
check "I workdir inside a tracked repo"      5 "${BASE[@]}" \
      "PROBE_WORKDIR=$(cd "$HERE/../.." && pwd)/evidence/p06a/would-be-tracked"
check "K unknown arm"                        7 "${BASE[@]}" PROBE_ARMS=P,A,Z
check "L budget ceiling reached"             8 "${BASE[@]}" PROBE_BUDGET=0

# J — the lock. Pre-created by hand so the driver meets a held lock, and the
# driver must NOT remove a lock it did not take.
mkdir -p "$TMP/held"
check "J another probe holds the lock"       6 "${BASE[@]}" "PROBE_LOCK=$TMP/held"
if [[ -d "$TMP/held" ]]; then
  printf 'ok    %-44s lock not stolen\n' "J' held lock survives the refusal"
  PASS=$((PASS + 1))
else
  printf 'FAIL  %-44s the driver removed a lock it did not take\n' "J' held lock survives"
  FAIL=$((FAIL + 1))
fi
CASES=$((CASES + 1))

echo
printf '%s of %s cases pass\n' "$PASS" "$CASES"
[[ "$FAIL" == 0 ]] || exit 1
exit 0
