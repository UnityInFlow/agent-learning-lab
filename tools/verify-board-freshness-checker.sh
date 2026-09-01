#!/usr/bin/env bash
#
# Does check-board-freshness.sh still reject what it is supposed to reject?
#
# The reason this file exists is on the record: `check-sheet-categories.sh` was built to catch
# silent category loss and LOST CATEGORIES — it scanned by indent rather than by block — and
# it shipped with ShellCheck clean, a green CI job and nine passing fixtures. None of those
# can answer "does this gate admit something it should not". Only a fixture built to be
# rejected can.
#
# Each case below builds a throwaway git repo, because the check reads `git log` for the
# file's own history. A fixture that is not tracked exercises a different code path — the
# early "no commit history" exit — and that path was ALREADY the reason a first attempt at
# testing this silently passed. Case 7 pins it deliberately so it can never pass by accident
# again.
#
# Exit 0 = every case produced its registered code.

set -uo pipefail

CHECK="$(cd "$(dirname "$0")" && pwd)/check-board-freshness.sh"
[ -x "$CHECK" ] || { echo "not executable: $CHECK" >&2; exit 2; }

pass=0; fail=0

# <name> <expected-exit> <setup-fn>
run_case() {
  local name="$1" want="$2" setup="$3"
  local dir; dir="$(mktemp -d)"
  (
    cd "$dir" || exit 99
    git init -q .; git config user.email t@t; git config user.name t
    "$setup"
  )
  local got=0
  ( cd "$dir" && "$CHECK" HANDOFF.md >/dev/null 2>&1 ) || got=$?
  if [ "$got" = "$want" ]; then
    printf '  ok    %-46s exit %s\n' "$name" "$got"; pass=$((pass+1))
  else
    printf '  FAIL  %-46s exit %s, wanted %s\n' "$name" "$got" "$want" >&2; fail=$((fail+1))
  fi
  rm -rf "$dir"
}

# The digest the checker will compute for the CURRENT HANDOFF.md, so a case can write a marker
# that genuinely matches instead of hard-coding a hash that drifts the moment a case's prose is
# edited. Mirrors digest_of() in the checker: marker lines excluded.
dg() {
  if command -v sha256sum >/dev/null 2>&1; then
    sed '/board:/d' HANDOFF.md | sha256sum | cut -c1-12
  else
    sed '/board:/d' HANDOFF.md | shasum -a 256 | cut -c1-12
  fi
}

s_no_markers()  { printf 'state\n' > HANDOFF.md; git add -A; git commit -qm one; }

s_current()     { printf 'state\n' > HANDOFF.md
                  printf 'state\n<!-- board: https://x/a prose: %s -->\n' "$(dg)" > HANDOFF.md; }

s_stale()       { printf 'state\n' > HANDOFF.md
                  local old; old="$(dg)"
                  printf 'state\nMATERIALLY DIFFERENT PROSE\n<!-- board: https://x/a prose: %s -->\n' "$old" > HANDOFF.md; }

# Writing the marker must NOT count as stale. Under the commit basis this needed a narrow
# "the diff is marker lines only" clause; under the digest basis it is structural, because the
# digest excludes marker lines. The case stays: the property is what matters, not the mechanism.
s_marker_only() { printf 'state\n' > HANDOFF.md
                  printf 'state\n<!-- board: https://x/a prose: %s -->\n' "$(dg)" > HANDOFF.md
                  git add -A; git commit -qm marker; }

s_marker_plus() { printf 'state\n' > HANDOFF.md
                  local sha; sha="$(dg)"
                  printf 'state\nNEW SUBSTANTIVE LINE\n<!-- board: https://x/a prose: %s -->\n' "$sha" > HANDOFF.md
                  git add -A; git commit -qm both; }

s_no_sha()      { printf 'state\n<!-- board: https://x/a -->\n' > HANDOFF.md; git add -A; git commit -qm one; }
s_no_url()      { printf 'state\n<!-- board: prose: abc123456789 -->\n' > HANDOFF.md; git add -A; git commit -qm one; }

# built-from: is provenance now, not a control input. A marker carrying only prose: is VALID,
# and the check must not reject it -- otherwise the field quietly becomes required again.
s_prose_only()  { printf 'state\n' > HANDOFF.md
                  printf 'state\n<!-- board: https://x/a prose: %s -->\n' "$(dg)" > HANDOFF.md; }

# THE CASE THAT ALREADY FOOLED THIS AUTHOR ONCE. Under the commit basis an untracked file took
# an early exit and passed, so a positive control written against one proved nothing. The digest
# basis consults no git at all, so tracking is now irrelevant and a wrong marker on an untracked
# file FAILS like any other. The expected code moves 0 -> 1, and that is the improvement.
s_untracked()   { printf 'state\n<!-- board: https://x/a prose: 000000000000 -->\n' > HANDOFF.md; }

s_missing()     { :; }

# WHAT A SQUASH MERGE LEAVES BEHIND, and why there is no longer a case for it. Under the commit
# basis this file registered an UNVERIFIABLE outcome for a marker whose sha no longer resolved.
# The digest basis consults no commit, so the condition cannot arise and the outcome is gone.
# An orphaned sha in built-from: is now simply provenance pointing at a squashed commit, which
# is true and harmless. Kept as a comment because the failure is worth remembering: it turned
# main red twice in one session on boards that were byte-for-byte correct.

echo "check-board-freshness.sh — registered cases"
run_case "no markers declared"                     0 s_no_markers
run_case "marker at the current digest"            0 s_current
run_case "marker behind a substantive change"      1 s_stale
run_case "writing the marker is not staleness"     0 s_marker_only
run_case "marker plus a substantive line IS stale" 1 s_marker_plus
run_case "marker missing prose"                    2 s_no_sha
run_case "marker missing url"                      2 s_no_url
run_case "untracked file is checked like any other" 1 s_untracked
run_case "prose: alone is a valid marker"          0 s_prose_only
run_case "file absent entirely"                    2 s_missing

echo
if [ "$fail" -gt 0 ]; then
  echo "$fail of $((pass+fail)) cases did NOT produce their registered exit code." >&2
  exit 1
fi
echo "all $pass cases produced their registered exit code."
