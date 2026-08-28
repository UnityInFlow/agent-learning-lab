#!/usr/bin/env bash
# Proves check-sheet-categories.sh still discriminates. Without this it is a script someone
# believes in; with it, a version that stopped rejecting anything fails CI.
#
# Fixtures are generated in-script rather than committed, because every one of them is three
# lines of YAML whose whole content is the property under test. A fixture file would hide
# that behind a path.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
CHECK=./tools/check-sheet-categories.sh
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
fail=0

rubric() { printf 'categories:\n'; for n in "$@"; do printf '  - name: %s\n' "$n"; done; }
sheet()  { printf 'scorer: lab-scorer\ncategories:\n'; for n in "$@"; do printf '  - name: "%s"\n    score: 1\n' "$n"; done; }

FOUR=(architecture-consistency maintainability test-quality change-focus)

run_case() {
  local name="$1" want="$2" r="$3" s="$4"
  "$CHECK" "$r" "$s" >/dev/null 2>&1
  local got=$?
  if [ "$got" = "$want" ]; then printf 'ok    %-46s exit %s\n' "$name" "$got"
  else printf 'FAIL  %-46s exit %s, expected %s\n' "$name" "$got" "$want"; fail=1; fi
}

rubric "${FOUR[@]}" > "$WORK/r4.yaml"

sheet "${FOUR[@]}" > "$WORK/exact.yaml"
run_case "the rubric's four, exactly"                0 "$WORK/r4.yaml" "$WORK/exact.yaml"

sheet change-focus test-quality maintainability architecture-consistency > "$WORK/order.yaml"
run_case "same four in a different order"            0 "$WORK/r4.yaml" "$WORK/order.yaml"

# THE CASE THIS EXISTS FOR. Three of four, every one of them a real category, every value
# well formed. The JSON schema admitted it, the classifier called it `contract`.
sheet architecture-consistency maintainability test-quality > "$WORK/missing.yaml"
run_case "one category absent — not the same as null" 2 "$WORK/r4.yaml" "$WORK/missing.yaml"

sheet "${FOUR[@]}" security > "$WORK/extra.yaml"
run_case "a category the rubric does not have"       2 "$WORK/r4.yaml" "$WORK/extra.yaml"

sheet architecture-consistency maintainability test-quality change_focus > "$WORK/renamed.yaml"
run_case "a category misspelled"                     2 "$WORK/r4.yaml" "$WORK/renamed.yaml"

# Fail closed. A parse that yields nothing must never compare empty to empty and pass.
# THE PANEL'S COUNTEREXAMPLE, 2026-08-28. A category absent from `categories:` but present
# in any other list at the same indent used to be counted as present, so the sheet that had
# genuinely lost a category reported an exact match.
{ printf 'scorer: lab-scorer\ncategories:\n  - name: "architecture-consistency"\n    score: 1\n'
  printf '  - name: "maintainability"\n    score: 1\n  - name: "test-quality"\n    score: 1\n'
  printf 'other:\n  - name: "change-focus"\n'; } > "$WORK/elsewhere.yaml"
run_case "a category filed under another key"   2 "$WORK/r4.yaml" "$WORK/elsewhere.yaml"

# And the rubric side of the same hole: column-0 comments between categories must not
# truncate the block.
{ printf 'categories:\n  - name: architecture-consistency\n'
  printf '# a column-zero comment, as the real rubric has\n'
  printf '  - name: maintainability\n  - name: test-quality\n  - name: change-focus\n'; } > "$WORK/rcomment.yaml"
run_case "rubric with column-0 comments inside"  0 "$WORK/rcomment.yaml" "$WORK/exact.yaml"

printf 'version: 2\ntask: x\n' > "$WORK/norubric.yaml"
run_case "rubric declares no categories"             1 "$WORK/norubric.yaml" "$WORK/exact.yaml"

printf 'scorer: lab-scorer\ncategories:\n' > "$WORK/emptysheet.yaml"
run_case "sheet declares no categories"              1 "$WORK/r4.yaml" "$WORK/emptysheet.yaml"

run_case "sheet does not exist"                      1 "$WORK/r4.yaml" "$WORK/nope.yaml"

"$CHECK" "$WORK/r4.yaml" >/dev/null 2>&1
[ $? = 1 ] && printf 'ok    %-46s exit 1\n' "one argument" || { printf 'FAIL  one argument\n'; fail=1; }

echo
if [ "$fail" = 0 ]; then echo "verify-sheet-category-checker: all 11 cases behaved as specified."
else echo "verify-sheet-category-checker: FAILURES above."; fi
exit "$fail"
