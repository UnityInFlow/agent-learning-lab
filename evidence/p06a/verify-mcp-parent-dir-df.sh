#!/usr/bin/env bash
# Fixture set for run-mcp-parent-dir-df.sh. Every exit code provoked by a real
# invocation; the happy path runs dry so no case spends money.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DRIVER="$HERE/run-mcp-parent-dir-df.sh"
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
    printf '      %s\n' "$(tail -2 "$TMP/out.$CASES" | tr '\n' ' ')"
    FAIL=$((FAIL + 1))
  fi
}

GOOD="$TMP/good"; mkdir -p "$GOOD"
cp "$HERE/probe_server.py.fixture" "$GOOD/"
cp "$HERE/mcp.json.fixture" "$GOOD/"

MUTE="$TMP/mute"; mkdir -p "$MUTE"
printf 'import sys\nfor _ in sys.stdin: pass\n' > "$MUTE/probe_server.py.fixture"
cp "$HERE/mcp.json.fixture" "$MUTE/"

EMPTY="$TMP/empty"; mkdir -p "$EMPTY"

FAKEBIN="$TMP/bin"; mkdir -p "$FAKEBIN"
printf '#!/bin/sh\necho "9.9.9 (Fake Claude)"\n' > "$FAKEBIN/claude-wrong"
chmod +x "$FAKEBIN/claude-wrong"

# Case F's fixture: setup skipped and the .mcp.json planted in the CHILD
# instead of the parent — the mistake guard 9 and guard 10 exist to catch.
DIRTY="$TMP/dirty"; mkdir -p "$DIRTY/parent/child"
cp "$HERE/mcp.json.fixture" "$DIRTY/parent/child/.mcp.json"
cp "$HERE/mcp.json.fixture" "$DIRTY/parent/.mcp.json"

# Case G's fixture: setup skipped and NOTHING planted anywhere.
BARE="$TMP/bare"; mkdir -p "$BARE/parent/child"

BASE=(PROBE_DRY_RUN=1 "PROBE_FIXTURE_DIR=$GOOD" "PROBE_WORKDIR=$TMP/wd"
      "PROBE_EVIDENCE=$TMP/ev" "PROBE_LOCK=$TMP/lock" PROBE_N=1)

echo "verify-mcp-parent-dir-df: 9 cases"
echo
check "A happy path, dry run"                  0 "${BASE[@]}"
check "B claude binary missing"                2 "${BASE[@]}" PROBE_CLAUDE_BIN=/nonexistent/claude
check "C wrong-version claude on PATH"         2 "${BASE[@]}" "PROBE_CLAUDE_BIN=$FAKEBIN/claude-wrong"
check "D probe fixtures missing"               3 "${BASE[@]}" "PROBE_FIXTURE_DIR=$EMPTY"
check "E probe server answers no tools/list"   3 "${BASE[@]}" "PROBE_FIXTURE_DIR=$MUTE"
check "F workdir inside a tracked repo"        5 "${BASE[@]}" \
      "PROBE_WORKDIR=$(cd "$HERE/../.." && pwd)/evidence/p06a/would-be-tracked"
check "G child dir not clean of .mcp.json"     9 "${BASE[@]}" PROBE_SKIP_SETUP=1 "PROBE_WORKDIR=$DIRTY"
check "H parent dir has no .mcp.json"         10 "${BASE[@]}" PROBE_SKIP_SETUP=1 "PROBE_WORKDIR=$BARE"

mkdir -p "$TMP/held"
check "I another probe holds the lock"         6 "${BASE[@]}" "PROBE_LOCK=$TMP/held"

echo
printf '%s of %s cases pass\n' "$PASS" "$CASES"
[[ "$FAIL" == 0 ]] || exit 1
exit 0
