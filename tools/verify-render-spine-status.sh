#!/usr/bin/env bash
# Prove render-spine-status.py renders the three status words and refuses everything else.
#
# The renderer replaces a paragraph that went stale three times by hand. A renderer that has
# never been shown to refuse, or to drop the superseded history, would only move the staleness:
# the blocked fixture's history names `position 8`, the value the hand-written line was once
# stuck on, and it must never reach the output. No sha is asserted: CI checks out shallow.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
F=tools/fixtures/spine-status
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

ok()  { echo "  ok   — $1"; pass=$((pass+1)); }
bad() { echo "  FAIL — $1: $2"; fail=$((fail+1)); }

run() { # run <file>; sets rc, out, err
  python3 tools/render-spine-status.py "$1" >"$TMP/out" 2>"$TMP/err"; rc=$?
  out="$(cat "$TMP/out")"; err="$(cat "$TMP/err")"
}

renders() { # renders <name> <file> <word> [absent-phrase]
  local name="$1" file="$2" word="$3" absent="${4:-}"
  run "$file"
  if [ "$rc" -ne 0 ]; then bad "$name" "exit $rc, stderr: $err"; return; fi
  if ! grep -qF -e "**Status: $word**" <<<"$out"; then bad "$name" "no status word '$word'"; return; fi
  if ! grep -qF -e "Generated from \`$file\` at " <<<"$out"; then bad "$name" "no provenance line"; return; fi
  if [ -n "$absent" ] && grep -qF -e "$absent" <<<"$out"; then
    bad "$name" "superseded text '$absent' leaked into the output"; return
  fi
  ok "$name"
}

refuses() { # refuses <name> <file>
  local name="$1" file="$2"
  run "$file"
  if [ "$rc" -eq 0 ]; then bad "$name" "exit 0"; return; fi
  if [ -n "$out" ]; then bad "$name" "printed on stdout: $out"; return; fi
  if [ -z "$err" ]; then bad "$name" "no message on stderr"; return; fi
  ok "$name"
}

renders "running renders"                                   "$F/running.md" "running"
renders "blocked renders without its superseded history"    "$F/blocked.md" "blocked" "position 8"
renders "done renders"                                      "$F/done.md"    "done"
refuses "a file with no top-level status: line is refused"  "$F/no-status.md"
refuses "status: paused is refused"                         "$F/paused.md"
refuses "a missing file is refused"                         "$F/does-not-exist.md"

echo ""
echo "verify-render-spine-status: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
