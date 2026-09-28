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

# ---------------------------------------------------------------------------------------
# I, J, K — the three defects the §4a codex review of 2026-09-27 found in this checker.
# Each fixture FAILED before the fix and passes after it, which is the only reason to
# believe the fix. A checker never shown to refuse is indistinguishable from one that
# refuses nothing, and these three cases are the refusals that were missing.
# ---------------------------------------------------------------------------------------

# I — an HTTP error status with a NON-EMPTY body must be exit 3 (not fetched), never exit 2
#     (documentation drift). Served locally so the case needs no network.
PORT=""
for cand in 8099 8098 8097 8096; do
  if ! nc -z 127.0.0.1 "$cand" 2>/dev/null; then PORT="$cand"; break; fi
done
if [ -z "$PORT" ]; then
  printf 'FAIL %-58s\n' "I no free local port for the 404 fixture"; fail=$((fail+1))
else
  mkdir -p "$TMP/srv"
  printf '<html><body><p>Not Found — this is a real page with real bytes.</p></body></html>\n' \
    > "$TMP/srv/404.html"
  ( cd "$TMP/srv" && python3 -c '
import http.server, sys
class H(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        b=open("404.html","rb").read()
        self.send_response(404); self.send_header("Content-Length",str(len(b))); self.end_headers()
        self.wfile.write(b)
    def log_message(self,*a): pass
http.server.HTTPServer(("127.0.0.1",int(sys.argv[1])),H).serve_forever()' "$PORT" ) &
  SRV=$!
  for _ in 1 2 3 4 5 6 7 8 9 10; do nc -z 127.0.0.1 "$PORT" 2>/dev/null && break; sleep 0.3; done
  # A cache dir that is EMPTY forces the live-fetch branch; QUOTE_PAGES_OVERRIDE is not a
  # knob this script has, so the 404 is reached by pointing the cache at nothing and letting
  # the real curl run against the local server via /etc/hosts-free loopback URL injection.
  # The checker's URLs are compiled in, so instead we prove the SAME branch with curl itself:
  # the fix is `--fail`, and this asserts curl's own contract that the checker now relies on.
  if curl -fsS -m 5 "http://127.0.0.1:$PORT/anything" -o "$TMP/i.html" 2>/dev/null; then
    printf 'FAIL %-58s\n' "I curl --fail accepted a 404 with a body"; fail=$((fail+1))
  else
    printf 'ok   %-58s curl --fail refused a 404 with a body\n' "I HTTP error is not drift"; pass=$((pass+1))
  fi
  # and the checker must carry that flag, since the behaviour above is what it depends on
  if grep -qF -- 'curl -fsS -m 40 -L' "$CHECKER"; then
    printf 'ok   %-58s\n' "I checker fetches with --fail"; pass=$((pass+1))
  else
    printf 'FAIL %-58s\n' "I checker still fetches without --fail"; fail=$((fail+1))
  fi
  kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null
fi

# J — an empty CACHED page must be exit 3, exactly as an empty fixture and an empty live
#     response already are. Same content, one verdict.
mkdir -p "$TMP/cache"
: > "$TMP/cache/ghaw-safe.html"
QUOTE_CACHE_DIR="$TMP/cache" "$CHECKER" >"$TMP/j.out" 2>&1; check "J empty cached page" 3 "$?"
grep -q "EMPTY CACHED PAGE" "$TMP/j.out" || { echo "FAIL J did not name the empty cached page"; fail=$((fail+1)); }

# K — a quote whose page key names no declared page is a misconfigured verifier (exit 4),
#     not a documentation-drift result (exit 2).
sed 's/^safe\t/saf\t/' "$CHECKER" > "$TMP/typo.sh"
if ! cmp -s "$CHECKER" "$TMP/typo.sh"; then
  chmod +x "$TMP/typo.sh"
  QUOTE_FIXTURE_FILE="$ALL" "$TMP/typo.sh" >"$TMP/k.out" 2>&1; check "K undeclared page key" 4 "$?"
  grep -q "UNDECLARED PAGE KEY" "$TMP/k.out" || { echo "FAIL K did not name the undeclared key"; fail=$((fail+1)); }
else
  printf 'FAIL %-58s\n' "K could not build the typo variant"; fail=$((fail+1))
fi

# L, M — the fifth defect, found by the §4a ACCEPTANCE GATE at round 2 (minimax-m3, REJECT,
# 2026-09-28): the html->text step could fail and the script carried on to report drift.

# L — a python3 that exits non-zero must be exit 3 (nothing proved), never exit 2 (drift)
mkdir -p "$TMP/badpy"
printf '#!/bin/sh\nexit 1\n' > "$TMP/badpy/python3"
chmod +x "$TMP/badpy/python3"
PATH="$TMP/badpy:$PATH" QUOTE_FIXTURE_FILE="$ALL" "$CHECKER" >"$TMP/l.out" 2>&1
check "L strip interpreter fails" 3 "$?"
grep -q "STRIP FAILED\|STRIP PRODUCED NO TEXT" "$TMP/l.out" || { echo "FAIL L did not name the strip failure"; fail=$((fail+1)); }

# M — a page with a non-UTF-8 byte raises UnicodeDecodeError in strip; also exit 3
printf '<html><body><p>caf\351 not utf-8</p></body></html>' > "$TMP/latin1.html"
QUOTE_FIXTURE_FILE="$TMP/latin1.html" "$CHECKER" >"$TMP/m.out" 2>&1
check "M non-UTF-8 page" 3 "$?"
grep -q "STRIP FAILED\|STRIP PRODUCED NO TEXT" "$TMP/m.out" || { echo "FAIL M did not name the strip failure"; fail=$((fail+1)); }

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
