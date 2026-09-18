#!/usr/bin/env bash
# Prove what render-spine-status.py does on the fixtures in tools/fixtures/spine-status/, and
# nothing wider:
#   - running, blocked and done each render exactly one line starting `**Status: `, that line is
#     byte-equal to the one written below for the fixture (word, ` — `, live comment, nothing
#     after), and a provenance line;
#   - the blocked fixture's superseded history (`position 8`, the value the hand-written line was
#     once stuck on) never reaches the output;
#   - a second `#` inside the live comment does not cut it: the text after it is on the status
#     line, because that line is compared whole;
#   - a missing file, a file with no status: line, `paused`, `RUNNING` and `running,` are each
#     refused with exit 1, empty stdout and a message on stderr. Other invalid inputs are not
#     tested here, so this proves nothing about them.
# The renderer is overridable through RENDER_SPINE_STATUS; each mutant under
# tools/fixtures/spine-status/mutants/ must make this script fail (the step's Check runs them).
# No sha is asserted: CI checks out shallow.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
F=tools/fixtures/spine-status
RENDER="${RENDER_SPINE_STATUS:-tools/render-spine-status.py}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

ok()  { echo "  ok   — $1"; pass=$((pass+1)); }
bad() { echo "  FAIL — $1: $2"; fail=$((fail+1)); }

run() { # run <file>; sets rc, out, err
  python3 "$RENDER" "$1" >"$TMP/out" 2>"$TMP/err"; rc=$?
  out="$(cat "$TMP/out")"; err="$(cat "$TMP/err")"
}

renders() { # renders <name> <file> <expected-status-line> [absent-phrase]
  local name="$1" file="$2" want="$3" absent="${4:-}" status n
  run "$file"
  if [ "$rc" -ne 0 ]; then bad "$name" "exit $rc, stderr: $err"; return; fi
  status="$(grep -e '^\*\*Status: ' <<<"$out")"
  n="$(grep -c -e '^\*\*Status: ' <<<"$out")"
  if [ "$n" -ne 1 ]; then bad "$name" "$n **Status: lines, expected exactly 1"; return; fi
  if [ "$status" != "$want" ]; then bad "$name" "status line is '$status', expected '$want'"; return; fi
  if ! grep -qF -e "Generated from \`$file\` at " <<<"$out"; then bad "$name" "no provenance line"; return; fi
  if [ -n "$absent" ] && grep -qF -e "$absent" <<<"$out"; then
    bad "$name" "superseded text '$absent' leaked into the output"; return
  fi
  ok "$name"
}

refuses() { # refuses <name> <file>
  local name="$1" file="$2"
  run "$file"
  if [ "$rc" -ne 1 ]; then bad "$name" "exit $rc, expected 1"; return; fi
  if [ -n "$out" ]; then bad "$name" "printed on stdout: $out"; return; fi
  if [ -z "$err" ]; then bad "$name" "no message on stderr"; return; fi
  ok "$name"
}

renders "running renders"                                   "$F/running.md" \
  "**Status: running** — position 12 (B5 — workflow phases) OPEN at §4 step 3"
renders "blocked renders without its superseded history"    "$F/blocked.md" \
  "**Status: blocked** — §7 HALT at position 17a: BE-005 needs an author decision." "position 8"
renders "done renders"                                      "$F/done.md" \
  "**Status: done** — all twenty-eight positions closed"
renders "a second # in the live comment is kept"            "$F/second-hash.md" \
  "**Status: running** — position 12 OPEN at §4 step 3 # live note after the second hash" "position 8"
refuses "a file with no top-level status: line is refused"  "$F/no-status.md"
refuses "status: paused is refused"                         "$F/paused.md"
refuses "status: RUNNING is refused"                        "$F/uppercase.md"
refuses "status: running, is refused"                       "$F/trailing-comma.md"
refuses "a missing file is refused"                         "$F/does-not-exist.md"

echo ""
echo "verify-render-spine-status: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
