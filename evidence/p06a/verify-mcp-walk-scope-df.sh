#!/usr/bin/env bash
# Fixture set for run-mcp-walk-scope-df.sh. Every exit code provoked by a real
# invocation; the happy paths run dry so no case spends money.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DRIVER="$HERE/run-mcp-walk-scope-df.sh"
TMP="$(mktemp -d)" || exit 1
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0; CASES=0

# Never pipe the driver — a pipe reports the pipe's exit code.
check() {
  local name="$1" want="$2"; shift 2
  local got
  CASES=$((CASES + 1))
  env "$@" "$DRIVER" > "$TMP/out.$CASES" 2>&1
  got=$?
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %-46s exit %s\n' "$name" "$got"; PASS=$((PASS + 1))
  else
    printf 'FAIL  %-46s want %s got %s\n' "$name" "$want" "$got"
    printf '      %s\n' "$(tail -2 "$TMP/out.$CASES" | tr '\n' ' ')"; FAIL=$((FAIL + 1))
  fi
}

GOOD="$TMP/good"; mkdir -p "$GOOD"
cp "$HERE/probe_server.py.fixture" "$GOOD/"; cp "$HERE/mcp.json.fixture" "$GOOD/"
MUTE="$TMP/mute"; mkdir -p "$MUTE"
printf 'import sys\nfor _ in sys.stdin: pass\n' > "$MUTE/probe_server.py.fixture"
cp "$HERE/mcp.json.fixture" "$MUTE/"
EMPTY="$TMP/empty"; mkdir -p "$EMPTY"
FAKEBIN="$TMP/bin"; mkdir -p "$FAKEBIN"
printf '#!/bin/sh\necho "9.9.9 (Fake Claude)"\n' > "$FAKEBIN/claude-wrong"
chmod +x "$FAKEBIN/claude-wrong"

# Guard-9 fixture: a stray .mcp.json planted AT the cwd, setup skipped.
STRAY="$TMP/stray"; mkdir -p "$STRAY/top/a/b/c"
cp "$HERE/mcp.json.fixture" "$STRAY/top/a/b/c/.mcp.json"
# Guard-11 fixture: arm D3 with setup skipped, so the cwd is not a git repo.
NOGIT="$TMP/nogit"; mkdir -p "$NOGIT/top/a/repo"

BASE=(PROBE_DRY_RUN=1 "PROBE_FIXTURE_DIR=$GOOD" "PROBE_EVIDENCE=$TMP/ev"
      "PROBE_LOCK=$TMP/lock" PROBE_N=1)

echo "verify-mcp-walk-scope-df: 10 cases"
echo
check "A happy path D2, dry run"                0 "${BASE[@]}" PROBE_ARM=D2 "PROBE_WORKDIR=$TMP/w1"
check "B happy path D3, dry run"                0 "${BASE[@]}" PROBE_ARM=D3 "PROBE_WORKDIR=$TMP/w2"
check "C claude binary missing"                 2 "${BASE[@]}" "PROBE_WORKDIR=$TMP/w3" PROBE_CLAUDE_BIN=/nonexistent/claude
check "D wrong-version claude on PATH"          2 "${BASE[@]}" "PROBE_WORKDIR=$TMP/w4" "PROBE_CLAUDE_BIN=$FAKEBIN/claude-wrong"
check "E probe fixtures missing"                3 "${BASE[@]}" "PROBE_WORKDIR=$TMP/w5" "PROBE_FIXTURE_DIR=$EMPTY"
check "F probe server answers no tools/list"    3 "${BASE[@]}" "PROBE_WORKDIR=$TMP/w6" "PROBE_FIXTURE_DIR=$MUTE"
check "G unknown arm"                           7 "${BASE[@]}" PROBE_ARM=D9 "PROBE_WORKDIR=$TMP/w7"
check "H workdir inside a tracked repo"         5 "${BASE[@]}" PROBE_ARM=D2 \
      "PROBE_WORKDIR=$(cd "$HERE/../.." && pwd)/evidence/p06a/would-be-tracked"
check "I stray .mcp.json at the cwd"            9 "${BASE[@]}" PROBE_ARM=D2 PROBE_SKIP_SETUP=1 "PROBE_WORKDIR=$STRAY"
check "J arm D3 cwd is not a git repo"         11 "${BASE[@]}" PROBE_ARM=D3 PROBE_SKIP_SETUP=1 "PROBE_WORKDIR=$NOGIT"

echo
printf '%s of %s cases pass\n' "$PASS" "$CASES"
[[ "$FAIL" == 0 ]] || exit 1
exit 0
