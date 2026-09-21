#!/usr/bin/env bash
# Prove what render-spine-status.py does on the fixtures in tools/fixtures/spine-status/, and
# nothing wider:
#   - running, blocked and done each print exactly three lines on stdout and nothing else: line 1
#     starts `**Status: ` and is byte-equal to the one written below for the fixture (word, ` — `,
#     live comment, nothing after), line 2 is blank, line 3 is the provenance line for that file;
#   - the blocked fixture's superseded history (`position 8`, the value the hand-written line was
#     once stuck on) never reaches the output;
#   - a second `#` inside the live comment does not cut it: the text after it is on the status
#     line, because that line is compared whole;
#   - a missing file, a file with no status: line, `paused`, `RUNNING` and `running,` are each
#     refused with exit exactly 1, zero bytes on stdout (counted as bytes, so a lone newline is
#     not empty), and a stderr that carries no `Traceback` and does carry the phrase the renderer
#     emits for that case. Other invalid inputs are not tested here, so this proves nothing about
#     them, and nothing here reads the renderer's source.
# The renderer is overridable through RENDER_SPINE_STATUS; each of the seven mutants under
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

run() { # run <file>; sets rc, out, err. out/err are for messages only — the assertions that
        # care about exact bytes read $TMP/out and $TMP/err directly.
  python3 "$RENDER" "$1" >"$TMP/out" 2>"$TMP/err"; rc=$?
  out="$(cat "$TMP/out")"; err="$(cat "$TMP/err")"
}

renders() { # renders <name> <file> <expected-status-line> [absent-phrase]
  local name="$1" file="$2" want="$3" absent="${4:-}" status n lines l1 l2 l3
  run "$file"
  if [ "$rc" -ne 0 ]; then bad "$name" "exit $rc, stderr: $err"; return; fi
  n="$(grep -c -e '^\*\*Status: ' "$TMP/out")"
  if [ "$n" -ne 1 ]; then bad "$name" "$n **Status: lines, expected exactly 1"; return; fi
  status="$(grep -e '^\*\*Status: ' "$TMP/out")"
  if [ "$status" != "$want" ]; then bad "$name" "status line is '$status', expected '$want'"; return; fi
  # Nothing else on stdout: exactly the status line, a blank line and the provenance line. awk
  # counts an unterminated last line too, so a renderer that drops the final newline is not
  # silently short by one.
  lines="$(awk 'END {print NR}' "$TMP/out")"
  if [ "$lines" -ne 3 ]; then
    bad "$name" "$lines lines on stdout, expected 3 (status, blank, provenance)"; return
  fi
  l1="$(sed -n 1p "$TMP/out")"; l2="$(sed -n 2p "$TMP/out")"; l3="$(sed -n 3p "$TMP/out")"
  if [ "$l1" != "$want" ]; then bad "$name" "line 1 is '$l1', expected the status line"; return; fi
  if [ -n "$l2" ]; then bad "$name" "line 2 is '$l2', expected blank"; return; fi
  if ! grep -qF -e "Generated from \`$file\` at " <<<"$l3"; then
    bad "$name" "line 3 is '$l3', expected the provenance line"; return
  fi
  if [ -n "$absent" ] && grep -qF -e "$absent" <<<"$out"; then
    bad "$name" "superseded text '$absent' leaked into the output"; return
  fi
  ok "$name"
}

refuses() { # refuses <name> <file> <expected-stderr-phrase>
  local name="$1" file="$2" phrase="$3" bytes
  run "$file"
  if [ "$rc" -ne 1 ]; then bad "$name" "exit $rc, expected 1"; return; fi
  # Bytes, not "$(cat)": command substitution strips trailing newlines, so a lone newline on
  # stdout would read as empty.
  bytes="$(wc -c <"$TMP/out")"
  if [ "$bytes" -ne 0 ]; then bad "$name" "$bytes bytes on stdout, expected 0"; return; fi
  if grep -qF -e 'Traceback' "$TMP/err"; then
    bad "$name" "stderr is a traceback, not a refusal message"; return
  fi
  if ! grep -qF -e "$phrase" "$TMP/err"; then
    bad "$name" "stderr does not contain '$phrase': $err"; return
  fi
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
refuses "a file with no top-level status: line is refused"  "$F/no-status.md" \
  "has no 'status:' line"
refuses "status: paused is refused"                         "$F/paused.md" \
  "has status 'paused'"
refuses "status: RUNNING is refused"                        "$F/uppercase.md" \
  "has status 'RUNNING'"
refuses "status: running, is refused"                       "$F/trailing-comma.md" \
  "has status 'running,'"
refuses "a missing file is refused"                         "$F/does-not-exist.md" \
  "cannot read $F/does-not-exist.md"

echo ""
echo "verify-render-spine-status: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
