#!/usr/bin/env bash
# verify-quote-checker.sh — fixture set for verify-quotes.sh.
#
# A checker that has never been shown to REFUSE anything is indistinguishable from one that
# refuses nothing. That sentence has cost this project a voided experiment, so every registered
# exit code of verify-quotes.sh gets a fixture here, including the ones nobody wants to see.
#
# Cases:
#   A  every quote present in the fixture page            -> exit 0
#   B  one quote removed from the fixture page            -> exit 2
#   C  fixture file does not exist                        -> exit 3
#   D  fixture file exists and is empty                   -> exit 3
#   E  two arguments                                      -> exit 4
#   F  one argument that is not --list                    -> exit 4
#   G  --list prints one line per quote and exits 0       -> exit 0, line count matches
#   H  case A again with the quote text as a literal, to prove the match is substring-exact
#      and not a regex (a quote containing `!==` and `(max: 1, experimental)` must match
#      literally; grep -F is what makes that true)        -> exit 0
set -uo pipefail

cd "$(dirname "$0")" || exit 1
CHECKER=./verify-quotes.sh
[ -x "$CHECKER" ] || { echo "missing $CHECKER"; exit 1; }

TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
check() { # name expected_exit actual_exit
  if [ "$2" = "$3" ]; then printf 'ok   %-58s exit %s\n' "$1" "$3"; pass=$((pass+1))
  else printf 'FAIL %-58s expected %s, got %s\n' "$1" "$2" "$3"; fail=$((fail+1)); fi
}

# Build a page that contains every quote the checker looks for. Each quote goes on its own
# line inside a <p>, so the strip step has real markup to remove.
ALL="$TMP/all.html"
{
  echo '<html><head><title>fixture</title><style>x{}</style><script>var a=1;</script></head><body>'
  "$CHECKER" --list | while IFS=$'\t' read -r _key quote; do
    [ -z "${quote:-}" ] && continue
    printf '<p>%s</p>\n' "$quote"
  done
  echo '</body></html>'
} > "$ALL"

QUOTE_COUNT=$("$CHECKER" --list | grep -c .)

# A — all present
QUOTE_FIXTURE_FILE="$ALL" "$CHECKER" >"$TMP/a.out" 2>&1; check "A all quotes present" 0 "$?"
grep -q "absent=0" "$TMP/a.out" || { echo "FAIL A did not report absent=0"; fail=$((fail+1)); }

# B — remove exactly one quote
ONE=$("$CHECKER" --list | sed -n '1p' | cut -f2)
grep -vF -- "$ONE" "$ALL" > "$TMP/minus.html"
QUOTE_FIXTURE_FILE="$TMP/minus.html" "$CHECKER" >"$TMP/b.out" 2>&1; check "B one quote removed" 2 "$?"
grep -q "absent=1" "$TMP/b.out" || { echo "FAIL B did not report absent=1"; fail=$((fail+1)); }

# C — fixture missing
QUOTE_FIXTURE_FILE="$TMP/does-not-exist.html" "$CHECKER" >/dev/null 2>&1; check "C fixture missing" 3 "$?"

# D — fixture empty
: > "$TMP/empty.html"
QUOTE_FIXTURE_FILE="$TMP/empty.html" "$CHECKER" >/dev/null 2>&1; check "D fixture empty" 3 "$?"

# E — two arguments
"$CHECKER" --list extra >/dev/null 2>&1; check "E two arguments" 4 "$?"

# F — one bad argument
"$CHECKER" --wat >/dev/null 2>&1; check "F unknown argument" 4 "$?"

# G — --list
"$CHECKER" --list >"$TMP/g.out" 2>&1; check "G --list exits 0" 0 "$?"
g=$(grep -c . "$TMP/g.out")
if [ "$g" = "$QUOTE_COUNT" ] && [ "$g" -gt 0 ]; then
  printf 'ok   %-58s %s quotes\n' "G --list line count" "$g"; pass=$((pass+1))
else
  printf 'FAIL %-58s got %s want %s\n' "G --list line count" "$g" "$QUOTE_COUNT"; fail=$((fail+1))
fi

# H — literal matching, not regex: a quote with !== and (max: 1, experimental) in it
LIT='will reject actors with admin or maintainer roles because admin !== write'
if "$CHECKER" --list | grep -qF -- "$LIT"; then
  printf 'ok   %-58s\n' "H literal quote is in the registered set"; pass=$((pass+1))
else
  printf 'FAIL %-58s\n' "H literal quote missing from registered set"; fail=$((fail+1))
fi
# and prove a regex-special quote still matches through the real code path
printf '<html><body><p>%s</p></body></html>\n' "$LIT" > "$TMP/lit.html"
QUOTE_FIXTURE_FILE="$TMP/lit.html" "$CHECKER" >"$TMP/h.out" 2>&1
if grep -qF "FOUND   [trig] $LIT" "$TMP/h.out"; then
  printf 'ok   %-58s\n' "H regex-special quote matched literally"; pass=$((pass+1))
else
  printf 'FAIL %-58s\n' "H regex-special quote not matched"; fail=$((fail+1))
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
