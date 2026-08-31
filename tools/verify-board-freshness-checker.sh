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

s_no_markers()  { printf 'state\n' > HANDOFF.md; git add -A; git commit -qm one; }

s_current()     { printf 'state\n' > HANDOFF.md; git add -A; git commit -qm one
                  local sha; sha="$(git log -1 --format=%h -- HANDOFF.md)"
                  printf 'state\n<!-- board: https://x/a built-from: %s -->\n' "$sha" > HANDOFF.md; }

s_stale()       { printf 'state\n' > HANDOFF.md; git add -A; git commit -qm one
                  local old; old="$(git log -1 --format=%h -- HANDOFF.md)"
                  printf 'state\nMATERIALLY DIFFERENT PROSE\n' > HANDOFF.md
                  git add -A; git commit -qm two
                  printf 'state\nMATERIALLY DIFFERENT PROSE\n<!-- board: https://x/a built-from: %s -->\n' "$old" > HANDOFF.md; }

# The self-invalidation clause: writing the marker moves the file, and that alone must NOT
# count as stale. One substantive line in the same diff and it must.
s_marker_only() { printf 'state\n' > HANDOFF.md; git add -A; git commit -qm one
                  local sha; sha="$(git log -1 --format=%h -- HANDOFF.md)"
                  printf 'state\n<!-- board: https://x/a built-from: %s -->\n' "$sha" > HANDOFF.md
                  git add -A; git commit -qm marker; }

s_marker_plus() { printf 'state\n' > HANDOFF.md; git add -A; git commit -qm one
                  local sha; sha="$(git log -1 --format=%h -- HANDOFF.md)"
                  printf 'state\nNEW SUBSTANTIVE LINE\n<!-- board: https://x/a built-from: %s -->\n' "$sha" > HANDOFF.md
                  git add -A; git commit -qm both; }

s_no_sha()      { printf 'state\n<!-- board: https://x/a -->\n' > HANDOFF.md; git add -A; git commit -qm one; }
s_no_url()      { printf 'state\n<!-- board: built-from: abc1234 -->\n' > HANDOFF.md; git add -A; git commit -qm one; }

# THE CASE THAT ALREADY FOOLED THIS AUTHOR ONCE. An untracked file takes the early exit, and
# a positive control written against one passes while proving nothing.
s_untracked()   { printf 'state\n<!-- board: https://x/a built-from: 0000000 -->\n' > HANDOFF.md; }

s_missing()     { :; }

echo "check-board-freshness.sh — registered cases"
run_case "no markers declared"                     0 s_no_markers
run_case "marker at the current sha"               0 s_current
run_case "marker behind a substantive change"      1 s_stale
run_case "marker-only diff is not staleness"       0 s_marker_only
run_case "marker plus a substantive line IS stale" 1 s_marker_plus
run_case "marker missing built-from"               2 s_no_sha
run_case "marker missing url"                      2 s_no_url
run_case "untracked file — the early-exit path"    0 s_untracked
run_case "file absent entirely"                    2 s_missing

echo
if [ "$fail" -gt 0 ]; then
  echo "$fail of $((pass+fail)) cases did NOT produce their registered exit code." >&2
  exit 1
fi
echo "all $pass cases produced their registered exit code."
