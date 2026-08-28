#!/usr/bin/env bash
# Does a scorer's sheet carry EXACTLY the rubric's categories — no more, no fewer, no others?
#
#   ./tools/check-sheet-categories.sh <rubric.yaml> <sheet.yaml>
#
# WHY THIS EXISTS. `classify-model-output.sh score` asks whether a `categories:` key is
# present. It cannot ask what is under it, because it does not know which rubric produced
# the sheet. So until 2026-08-28 a scorer could return three of the rubric's four categories
# and every check in the pipeline passed: the JSON schema said `minItems: 1` with no
# `maxItems` and `name` as a free string, the classifier saw `categories:` and said
# `contract`, and the sheet was written to findings/ looking complete.
#
# A MISSING CELL IS NOT A NULL CELL. `null` is a measurement — the scorer read the anchor and
# could not decide. A category that never appears is an absence, and nothing downstream can
# tell them apart once the sheet is on disk. E-001's dependent variable is the null RATE, a
# ratio whose denominator is the cell count, so a silently 3-cell sheet does not add noise to
# the result: it changes what was measured while reporting the same units.
#
# Exit 0 the sets match · 1 usage, unreadable, or a parse that produced nothing — fail
# closed, never assume a match · 2 the sets differ, which is off-contract output.
set -uo pipefail

[ $# -eq 2 ] || { echo "usage: $0 <rubric.yaml> <sheet.yaml>" >&2; exit 1; }
RUBRIC="$1"; SHEET="$2"
[ -r "$RUBRIC" ] || { echo "cannot read rubric: $RUBRIC" >&2; exit 1; }
[ -r "$SHEET" ]  || { echo "cannot read sheet: $SHEET" >&2; exit 1; }

# Both files declare a category the same way — `  - name: x` at one indent — and the sheet is
# rendered by this repo, so the shape is ours on both sides. Quotes are stripped because the
# sheet writer quotes and the rubric does not.
names() { sed -n 's/^  - name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$1" | sed 's/[[:space:]]*$//' | sort; }

want="$(names "$RUBRIC")"
got="$(names "$SHEET")"

# Fail closed. An empty parse on either side means the shape moved, and a comparison of two
# empty lists would report a match — the loudest possible way to be wrong.
[ -n "$want" ] || { echo "FATAL: parsed no categories from the rubric $RUBRIC." >&2
                    echo "Refusing to report a match against nothing." >&2; exit 1; }
[ -n "$got" ]  || { echo "FATAL: parsed no categories from the sheet $SHEET." >&2
                    echo "Refusing to report a match against nothing." >&2; exit 1; }

if [ "$want" = "$got" ]; then
  echo "ok: $(echo "$want" | wc -l | tr -d ' ') categories, exactly the rubric's"
  exit 0
fi

missing="$(comm -23 <(echo "$want") <(echo "$got"))"
extra="$(comm -13 <(echo "$want") <(echo "$got"))"
echo "CATEGORY SET MISMATCH between $SHEET and $RUBRIC" >&2
[ -n "$missing" ] && { echo "  absent from the sheet (NOT the same as scored null):" >&2
                       echo "$missing" | sed 's/^/    /' >&2; }
[ -n "$extra" ]   && { echo "  present in the sheet but not in the rubric:" >&2
                       echo "$extra" | sed 's/^/    /' >&2; }
exit 2
