#!/usr/bin/env bash
# Prove what render-spine-status.py does on the fixtures in tools/fixtures/spine-status/, and
# nothing wider:
#   - running, blocked and done each print exactly three lines on stdout and nothing else: line 1
#     is byte-equal to the status line written below for the fixture (word, ` — `, live comment,
#     nothing after), line 2 is blank, and line 3 is byte-equal to
#     *Generated from `<file>` at <token>.* where <token> is `uncommitted` or a 7-40 character
#     lowercase hex sha. Prefix, token and the closing `.*` are each checked, so a provenance
#     line that drops the sha, or carries anything before or after it, fails;
#   - the blocked fixture's superseded history (`position 8`, the value the hand-written line was
#     once stuck on) never reaches the output;
#   - a second `#` inside the live comment does not cut it: the text after it is on the status
#     line, because that line is compared whole;
#   - a missing file, a file with no status: line, `paused`, `RUNNING` and `running,` are each
#     refused with exit exactly 1, zero bytes on stdout (counted as bytes, so a lone newline is
#     not empty), and a stderr that carries no `Traceback` and does carry the phrase the renderer
#     emits for that case. Other invalid inputs are not tested here, so this proves nothing about
#     them, and nothing here reads the renderer's source.
# The renderer is overridable through RENDER_SPINE_STATUS. When it is UNSET, this script then
# re-runs ITSELF once per `*.py` under tools/fixtures/spine-status/mutants/, with that file as
# the renderer, and fails unless every one of them fails the cases above; an empty mutants
# directory fails too. The sweep decides this script's exit code here, in this file — it is not
# a claim about a mutant loop living in some step elsewhere. A run with RENDER_SPINE_STATUS set
# is a leaf: it skips the sweep, so there is no recursion.
# No sha is asserted for the renderer itself: CI checks out shallow.
set -uo pipefail
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
cd "$(dirname "$0")/.." || exit 1
F=tools/fixtures/spine-status
SWEEP="${RENDER_SPINE_STATUS:-}"          # set ⇒ this is a leaf run, no mutant sweep
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
  local name="$1" file="$2" want="$3" absent="${4:-}" n lines l1 l2 l3 pfx rest token
  run "$file"
  if [ "$rc" -ne 0 ]; then bad "$name" "exit $rc, stderr: $err"; return; fi
  n="$(grep -c -e '^\*\*Status: ' "$TMP/out")"
  if [ "$n" -ne 1 ]; then bad "$name" "$n **Status: lines, expected exactly 1"; return; fi
  # Nothing else on stdout: exactly the status line, a blank line and the provenance line. awk
  # counts an unterminated last line too, so a renderer that drops the final newline is not
  # silently short by one.
  lines="$(awk 'END {print NR}' "$TMP/out")"
  if [ "$lines" -ne 3 ]; then
    bad "$name" "$lines lines on stdout, expected 3 (status, blank, provenance)"; return
  fi
  l1="$(sed -n 1p "$TMP/out")"; l2="$(sed -n 2p "$TMP/out")"; l3="$(sed -n 3p "$TMP/out")"
  # Line 1 whole, so a suffix or a changed word fails. With exactly one **Status: line in the
  # output and that line being line 1, this is the whole status-line contract — checking the
  # grep-extracted line as well would assert the same bytes twice.
  if [ "$l1" != "$want" ]; then bad "$name" "line 1 is '$l1', expected '$want'"; return; fi
  if [ -n "$l2" ]; then bad "$name" "line 2 is '$l2', expected blank"; return; fi
  # Line 3 whole as well, by peeling the literal prefix and the literal closing `.*` off and
  # requiring what is left to be a provenance token. A prefix-only match would accept
  # `… at .*` with no sha, and `UNEXPECTED … at abc1234.* EXTRA` with noise on both sides.
  pfx="*Generated from \`$file\` at "
  rest="${l3#"$pfx"}"
  if [ "$rest" = "$l3" ]; then
    bad "$name" "line 3 is '$l3', expected it to start '$pfx'"; return
  fi
  token="${rest%".*"}"
  if [ "$token" = "$rest" ]; then
    bad "$name" "line 3 is '$l3', expected it to end '.*'"; return
  fi
  if ! [[ "$token" =~ ^([0-9a-f]{7,40}|uncommitted)$ ]]; then
    bad "$name" "line 3 provenance token is '$token', expected a short sha or 'uncommitted'"
    return
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

# The mutant sweep. Only the default run does it; a run driven with RENDER_SPINE_STATUS is the
# leaf the sweep itself spawned, and stops here.
if [ -z "$SWEEP" ]; then
  mutants=("$F"/mutants/*.py)
  if [ ! -e "${mutants[0]}" ]; then
    bad "mutant sweep" "no *.py under $F/mutants/ — nothing proves the cases above can fail"
  else
    for m in "${mutants[@]}"; do
      if RENDER_SPINE_STATUS="$m" bash "$SELF" >/dev/null 2>&1; then
        bad "mutant $(basename "$m") is killed" "it passed the cases above"
      else
        ok "mutant $(basename "$m") is killed"
      fi
    done
  fi
fi

echo ""
echo "verify-render-spine-status: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
