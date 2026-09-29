#!/usr/bin/env bash
# verify-quote-checker.sh — prove tools/verify-quotes.sh returns each of its registered exit
# codes, and prove it REFUSES the five failure shapes the §4a review found in stop 23's
# hardcoded ancestor plus one new shape this generalisation introduced.
#
# WHY THE REFUSALS MATTER MORE THAN THE HAPPY PATH. Stop 23's fixture set passed 10 of 10
# while the script under it carried five defects, because NO FIXTURE MADE THE SCRIPT FAIL AT
# ITS OWN MACHINERY. Every defect had one shape: a failure to fetch or parse, reported as
# documentation drift — a control whose failure is indistinguishable from, and louder than,
# the finding it was built to make. Cases I-M below are those five shapes. Cases N-P are the
# shape the manifest ADDED: a manifest that declares nothing would make the checker report
# "everything verified" at exit 0 after looking at nothing, which is the same defect inverted.
#
# Cases R-U were added the same day from this file's OWN §4a review (codex +
# deepseek-v4-pro panel): they exercise refusals that did not exist before that review, so a
# suite passing without them is a suite that never touched the fix.
#
# PLATFORM SEMANTICS THIS SUITE DEPENDS ON, measured rather than assumed. The same review
# claimed cases K, L and M fail on macOS because BSD `sed` treats `\t` literally and BSD
# `grep` lacks `\|` in a BRE. Both were checked byte-exactly on this machine and both claims
# are false here — evidence/p09/dispute-bsd-sed-grep-20260929T1213Z.txt has the `od -c` output
# and grep's own negative control. The finding was still worth answering with an observation
# rather than an argument, because its failure mode would have been the house one: three cases
# GREEN while testing nothing, which 29/29 alone would not have caught.
#
# Written 2026-09-29 by Opus 5 (claude-opus-5), autonomously, at spine stop 24.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# A missing dependency must not look like a test failure, and must never look like a PASS.
# Named in the same §4a review: this suite silently relies on four external commands.
for dep in python3 nc sed grep; do
  command -v "$dep" >/dev/null 2>&1 || {
    printf 'verify-quote-checker: MISSING DEPENDENCY %s — cannot run the suite, and a suite\n' "$dep" >&2
    printf '  that cannot run is not a suite that passed. Exit 2, distinct from a case failure (1).\n' >&2
    exit 2
  }
done

CHECKER="./tools/verify-quotes.sh"
TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

check() { # name expected_exit actual_exit
  if [ "$2" = "$3" ]; then printf 'ok   %-56s exit %s\n' "$1" "$3"; pass=$((pass+1))
  else printf 'FAIL %-56s expected %s, got %s\n' "$1" "$2" "$3"; fail=$((fail+1)); fi
}
names() { # name file pattern
  if grep -q "$3" "$2"; then printf 'ok   %-56s named it\n' "$1"; pass=$((pass+1))
  else printf 'FAIL %-56s did not name %s\n' "$1" "$3"; fail=$((fail+1)); fi
}

# A local page carrying exactly the two sentences the good manifest quotes.
PAGE="$TMP/page.html"
printf '<html><head><style>x{}</style></head><body><p>The first sentence is here.</p>\n<p>And the\nsecond sentence   is here.</p></body></html>\n' > "$PAGE"

GOOD="$TMP/good.tsv"
printf 'page\tp1\thttps://example.invalid/never-fetched\n' > "$GOOD"
printf 'quote\tp1\tThe first sentence is here.\n' >> "$GOOD"
printf 'quote\tp1\tAnd the second sentence is here.\n' >> "$GOOD"

# A — every quote present. Also proves whitespace collapsing: the manifest's single-spaced
#     sentence matches the page's newline-and-triple-space version.
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$GOOD" >"$TMP/a.out" 2>&1
check "A all quotes found" 0 "$?"

# B — one quote absent is exit 2. This is the only code that means documentation drift.
BAD="$TMP/bad.tsv"
cp "$GOOD" "$BAD"
printf 'quote\tp1\tA sentence that was never on the page.\n' >> "$BAD"
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$BAD" >"$TMP/b.out" 2>&1
check "B one quote absent" 2 "$?"
names "B" "$TMP/b.out" "^ABSENT"

# C, D — a fixture that proves nothing about a quote is exit 3, never a page of absences.
QUOTE_FIXTURE_FILE="$TMP/does-not-exist.html" "$CHECKER" --manifest "$GOOD" >"$TMP/c.out" 2>&1
check "C fixture not readable" 3 "$?"
: > "$TMP/empty.html"
QUOTE_FIXTURE_FILE="$TMP/empty.html" "$CHECKER" --manifest "$GOOD" >"$TMP/d.out" 2>&1
check "D fixture empty" 3 "$?"

# E, F, G, H — usage and manifest trust. All exit 4; none may come out as 2.
"$CHECKER" >"$TMP/e.out" 2>&1;                          check "E no --manifest" 4 "$?"
"$CHECKER" --manifest "$TMP/nope.tsv" >"$TMP/f.out" 2>&1; check "F manifest not readable" 4 "$?"
printf 'page\tonlytwofields\n' > "$TMP/malformed.tsv"
"$CHECKER" --manifest "$TMP/malformed.tsv" >"$TMP/g.out" 2>&1
check "G malformed manifest line" 4 "$?"
names "G" "$TMP/g.out" "MALFORMED MANIFEST LINE"
printf 'pge\tp1\thttps://example.invalid/x\n' > "$TMP/kind.tsv"
"$CHECKER" --manifest "$TMP/kind.tsv" >"$TMP/h.out" 2>&1
check "H unknown manifest kind" 4 "$?"
names "H" "$TMP/h.out" "UNKNOWN MANIFEST KIND"

# ---------------------------------------------------------------------------------------
# I-M — the five shapes the §4a review found in stop 23's ancestor. Each one used to be
# reported as documentation drift (exit 2). Each must now be exit 3 or 4.
# ---------------------------------------------------------------------------------------

# I — an HTTP error status with a NON-EMPTY body must be exit 3 (not fetched), never exit 2.
#     STRICTLY STRONGER THAN STOP 23'S CASE I: because the URL comes from a manifest, the
#     CHECKER ITSELF is driven against the 404 here. Stop 23 could only assert curl's own
#     contract and grep its source for the flag, since its URLs were compiled in.
PORT=""
for cand in 8099 8098 8097 8096; do
  if ! nc -z 127.0.0.1 "$cand" 2>/dev/null; then PORT="$cand"; break; fi
done
if [ -z "$PORT" ]; then
  printf 'FAIL %-56s\n' "I no free local port for the 404 fixture"; fail=$((fail+1))
else
  mkdir -p "$TMP/srv"
  printf '<html><body><p>Not Found - a real page with real bytes.</p></body></html>\n' > "$TMP/srv/404.html"
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
  printf 'page\tp1\thttp://127.0.0.1:%s/anything\n' "$PORT" > "$TMP/http404.tsv"
  printf 'quote\tp1\tThe first sentence is here.\n' >> "$TMP/http404.tsv"
  "$CHECKER" --manifest "$TMP/http404.tsv" >"$TMP/i.out" 2>&1
  check "I HTTP 404 with a body is not drift" 3 "$?"
  names "I" "$TMP/i.out" "FETCH FAILED"
  kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null
fi

# J — an empty CACHED page must be exit 3, exactly as an empty fixture already is. Same
#     content, one verdict. The cache filename is <manifest-slug>-<key>-<url-sha-12>.html
#     since the §4a round-3 fix; before it, the url was not in the name at all (case X).
mkdir -p "$TMP/cache"
GOOD_URL="https://example.invalid/never-fetched"
GOOD_HASH=$(printf '%s' "$GOOD_URL" | shasum -a 256 | cut -c1-12)
: > "$TMP/cache/good-p1-$GOOD_HASH.html"
QUOTE_CACHE_DIR="$TMP/cache" "$CHECKER" --manifest "$GOOD" >"$TMP/j.out" 2>&1
check "J empty cached page" 3 "$?"
names "J" "$TMP/j.out" "EMPTY CACHED PAGE"
rm -f "$TMP/cache/good-p1-$GOOD_HASH.html"

# K — a quote whose page key names no declared page is a misconfigured verifier (exit 4),
#     not a documentation-drift result (exit 2).
sed 's/^quote\tp1\t/quote\tp2\t/' "$GOOD" > "$TMP/typo.tsv"
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$TMP/typo.tsv" >"$TMP/k.out" 2>&1
check "K undeclared page key" 4 "$?"
names "K" "$TMP/k.out" "UNDECLARED PAGE KEY"

# L — a python3 that exits non-zero must be exit 3 (nothing proved), never exit 2 (drift).
#     This is the defect stop 23's §4a ACCEPTANCE GATE blocked on: one broken interpreter
#     declared its entire extract fabricated, at exit 2, in the format of a real finding.
mkdir -p "$TMP/badpy"
printf '#!/bin/sh\nexit 1\n' > "$TMP/badpy/python3"
chmod +x "$TMP/badpy/python3"
PATH="$TMP/badpy:$PATH" QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$GOOD" >"$TMP/l.out" 2>&1
check "L strip interpreter fails" 3 "$?"
names "L" "$TMP/l.out" "STRIP FAILED\|STRIP PRODUCED NO TEXT"

# M — a page with a non-UTF-8 byte raises UnicodeDecodeError in strip; also exit 3.
printf '<html><body><p>caf\351 not utf-8</p></body></html>' > "$TMP/latin1.html"
QUOTE_FIXTURE_FILE="$TMP/latin1.html" "$CHECKER" --manifest "$GOOD" >"$TMP/m.out" 2>&1
check "M non-UTF-8 page" 3 "$?"
names "M" "$TMP/m.out" "STRIP FAILED\|STRIP PRODUCED NO TEXT"

# ---------------------------------------------------------------------------------------
# N-P — the shape the MANIFEST added. Stop 23's ancestor could not have these, because its
# data was compiled in. A manifest that declares nothing would look at nothing and report
# `found=0 absent=0`, exit 0 — "every quote verified" when none exist.
# ---------------------------------------------------------------------------------------
printf '# only a comment\n\n' > "$TMP/nopages.tsv"
"$CHECKER" --manifest "$TMP/nopages.tsv" >"$TMP/n.out" 2>&1
check "N manifest declares no pages" 4 "$?"
names "N" "$TMP/n.out" "DECLARES NO PAGES"

printf 'page\tp1\thttps://example.invalid/x\n' > "$TMP/noquotes.tsv"
"$CHECKER" --manifest "$TMP/noquotes.tsv" >"$TMP/o.out" 2>&1
check "O manifest declares no quotes" 4 "$?"
names "O" "$TMP/o.out" "DECLARES NO QUOTES"

printf 'page\tp1\thttps://example.invalid/x\npage\tp1\thttps://example.invalid/y\nquote\tp1\tz\n' \
  > "$TMP/dup.tsv"
"$CHECKER" --manifest "$TMP/dup.tsv" >"$TMP/p.out" 2>&1
check "P duplicate page key" 4 "$?"
names "P" "$TMP/p.out" "DUPLICATE PAGE KEY"

# Q — --list prints the quote table and fetches nothing. Proved by pointing it at a manifest
#     whose URL cannot resolve: a --list that fetched would exit 3.
"$CHECKER" --manifest "$GOOD" --list >"$TMP/q.out" 2>&1
check "Q --list fetches nothing" 0 "$?"
if [ "$(wc -l < "$TMP/q.out")" -eq 2 ]; then
  printf 'ok   %-56s printed 2 quote lines\n' "Q list contents"; pass=$((pass+1))
else
  printf 'FAIL %-56s expected 2 quote lines\n' "Q list contents"; fail=$((fail+1))
fi

# ---- cases R-U: the four defects the §4a codex + deepseek-v4-pro panel found, 2026-09-29 ----
# Each is proved against the PRE-FIX script the way stop 23 proved its five: the behaviour
# being tested is a REFUSAL that did not exist before, so a suite that passes without these
# cases is a suite that never exercised the fix.

# R — a page key containing `../` escapes the mktemp directory. Before the fix, every cp/curl
#     wrote to "$TMP/../x.html", i.e. OUTSIDE the directory the EXIT trap removes: the verifier
#     wrote into the tree and left the file behind. Now exit 4, before any fetch.
printf 'page\t../escape\thttps://example.invalid/x\nquote\t../escape\tz\n' > "$TMP/trav.tsv"
"$CHECKER" --manifest "$TMP/trav.tsv" >"$TMP/r.out" 2>&1
check "R page key escapes the temp dir" 4 "$?"
names "R" "$TMP/r.out" "ILLEGAL KEY"

# S — a page key containing `|` silently broke the `key=${entry%%|*}` split at the fetch loop,
#     so the url became the wrong string and the page fetched was NOT the page declared. The
#     old script could not notice; a wrong page reports its quotes ABSENT and exits 2, which is
#     indistinguishable from real drift.
printf 'page\tp|x\thttps://example.invalid/x\nquote\tp|x\tz\n' > "$TMP/pipe.tsv"
"$CHECKER" --manifest "$TMP/pipe.tsv" >"$TMP/s.out" 2>&1
check "S page key contains the split delimiter" 4 "$?"
names "S" "$TMP/s.out" "ILLEGAL KEY"

# T — a TAB inside a quote value was kept by the manifest parser and dropped by the matcher's
#     `IFS=$'\t' read`, so the sentence searched for was not the sentence declared. Refused
#     rather than truncated.
printf 'page\tp1\thttps://example.invalid/x\nquote\tp1\ta\tb\n' > "$TMP/tabval.tsv"
"$CHECKER" --manifest "$TMP/tabval.tsv" >"$TMP/t.out" 2>&1
check "T tab inside a quote value" 4 "$?"
names "T" "$TMP/t.out" "TAB INSIDE VALUE"

# U — the SOURCE of every page is now reportable. Before the fix a cached page produced a
#     byte-identical result line and exit code to a live fetch, so nothing in the output said
#     whether the network had been touched. Driven here through the FIXTURE path, whose source
#     must read `fixture` and never `live`.
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$GOOD" >"$TMP/u.out" 2>&1
check "U source of each page is reported" 0 "$?"
names "U" "$TMP/u.out" "sources=p1=fixture"

# V — the checker runs under Bash 3.2, which is what /bin/bash IS on this machine. The first
#     version of the page-source feature used `declare -A`, a Bash 4 builtin, and passed every
#     check here only because `env bash` resolves to a 5.x Homebrew build: GREEN IN THIS
#     ENVIRONMENT, BROKEN ON THE PLATFORM THE SCRIPT'S OWN HEADER NAMES. Found by the §4a
#     codex + deepseek-v4-pro panel, 2026-09-29. No fixture could have caught it, because
#     every fixture ran under the same wrong interpreter — so this case pins the interpreter
#     instead of the behaviour.
if [ -x /bin/bash ]; then
  QUOTE_FIXTURE_FILE="$PAGE" /bin/bash "$CHECKER" --manifest "$GOOD" >"$TMP/v.out" 2>&1
  check "V runs under /bin/bash (3.2 on macOS)" 0 "$?"
  names "V" "$TMP/v.out" "sources=p1=fixture"
else
  printf 'ok   %-56s skipped: no /bin/bash\n' "V bash 3.2"; pass=$((pass+1))
fi

# W — the strip must remove an UPPERCASE <SCRIPT> block. Until the §4a round-3 fix the two
#     substitutions were case-sensitive, so a sentence living only inside `<SCRIPT>` reported
#     FOUND and exit 0 while the file's own registered limitation told the reader script
#     content had been removed. A CONTROL REPORTING OVER A SCOPE SMALLER THAN IT CLAIMS, which
#     is this project's named failure mode. The page's visible body must NOT contain the
#     sentence, or the case proves nothing.
UPPER="$TMP/upper.html"
printf '<html><head><SCRIPT>const e = "Only inside uppercase script.";</SCRIPT></head><body><p>Visible text that is not the quote.</p></body></html>\n' > "$UPPER"
UPPER_TSV="$TMP/upper.tsv"
printf 'page\tp1\thttps://example.invalid/never-fetched\n' > "$UPPER_TSV"
printf 'quote\tp1\tOnly inside uppercase script.\n' >> "$UPPER_TSV"
QUOTE_FIXTURE_FILE="$UPPER" "$CHECKER" --manifest "$UPPER_TSV" >"$TMP/w.out" 2>&1
check "W uppercase <SCRIPT> is stripped" 2 "$?"
names "W" "$TMP/w.out" "ABSENT"

# X — a cache file under the PRE-URL-HASH name must NOT be used. Two manifests sharing a
#     basename and a key but declaring different urls used to collide silently, the second
#     reporting `cached` for a page it never fetched. Now the old name is warned about and
#     ignored, which drops through to a live fetch of example.invalid — so exit 3, a loud
#     failure, rather than exit 0 over the wrong page. A cache MISS is safe; a wrong cache
#     HIT is not, and that asymmetry is the whole design of the fix.
printf '<html><body><p>The first sentence is here.</p><p>And the second sentence is here.</p></body></html>\n' > "$TMP/cache/good-p1.html"
QUOTE_CACHE_DIR="$TMP/cache" "$CHECKER" --manifest "$GOOD" >"$TMP/x.out" 2>&1
check "X pre-url-hash cache name is ignored" 3 "$?"
names "X" "$TMP/x.out" "PRE-URL-HASH CACHE NAME"
rm -f "$TMP/cache/good-p1.html"

# Y — the negative control for X. The SAME bytes under the url-hashed name ARE used, so the
#     fix refuses one name and accepts the other rather than refusing every cache. Without
#     this case X would pass just as well against a checker whose cache never works at all.
printf '<html><body><p>The first sentence is here.</p><p>And the second sentence is here.</p></body></html>\n' > "$TMP/cache/good-p1-$GOOD_HASH.html"
QUOTE_CACHE_DIR="$TMP/cache" "$CHECKER" --manifest "$GOOD" >"$TMP/y.out" 2>&1
check "Y url-hashed cache name IS used" 0 "$?"
names "Y" "$TMP/y.out" "sources=p1=cached"
rm -f "$TMP/cache/good-p1-$GOOD_HASH.html"

# Z — the quote is collapsed with the SAME rule as the page. `strip()` folds every whitespace
#     run in the page to one space; the matcher used to search the quote raw, so a quote
#     carrying a double space could never match text that was PRESENT — a false ABSENT, the
#     direction that INFLATES a staleness count. Neither manifest on disk carries such a run,
#     so nothing measured moved; this case is why the next manifest does not have to be lucky.
DBL="$TMP/double.tsv"
printf 'page\tp1\thttps://example.invalid/never-fetched\n' > "$DBL"
printf 'quote\tp1\tThe first  sentence is here.\n' >> "$DBL"
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$DBL" >"$TMP/z.out" 2>&1
check "Z double-spaced quote matches collapsed page" 0 "$?"
names "Z" "$TMP/z.out" "FOUND"

# AA — a DECLARED page that no quote names is a manifest defect (exit 4), caught before any
#      network call. §4a round-4 blocking finding: without it, an orphan see-also page with a
#      dead url killed the whole manifest at exit 3 — "nothing was proved either way" — and the
#      quotes that WOULD have verified were lost behind an exit code indistinguishable from a
#      fetch failure on the page that carried the drift signal. The url here is deliberately the
#      unreachable example.invalid, so the case proves the orphan is never fetched: if it were,
#      curl would fail and this would exit 3 instead of 0. The skip is also required to appear
#      in the SUMMARY line, not only on stderr, because stderr is discarded by every caller that
#      redirects and a page silently not fetched is a narrowed scope nobody can see.
ORPHAN="$TMP/orphan.tsv"
printf 'page\tp1\thttps://example.invalid/never-fetched\n'  > "$ORPHAN"
printf 'page\tp2\thttps://example.invalid/also-never\n'    >> "$ORPHAN"
printf 'quote\tp1\tThe first sentence is here.\n'          >> "$ORPHAN"
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$ORPHAN" >"$TMP/aa.out" 2>&1
check "AA orphan declared page is SKIPPED, not fatal" 0 "$?"
names "AA" "$TMP/aa.out" "ORPHAN PAGE KEY"
names "AA summary names the skip" "$TMP/aa.out" "skipped-orphan-pages=p2"

# AB — the negative control for AA. The SAME two pages, both quoted, must NOT be refused: the
#      check must reject an unquoted page and accept a quoted one, or it is just a rule that
#      forbids two pages. Without AB, AA passes equally against a checker that skips or refuses
#      every extra page — and quotes-p08.tsv has seven.
#
#      AND THE REFUSING VERSION OF THIS CHECK WAS WRITTEN FIRST AND REFUSED REAL EVIDENCE ON ITS
#      FIRST RUN: evidence/p08/quotes-p08.tsv declares page key `home` and quotes it nowhere, so
#      an exit-4 refusal destroyed the stop-23 parity measurement over a page that contributes
#      nothing to any result. That is why this is a skip. The orphan was stop 23's, carried
#      faithfully by a mechanical transcription, and the manifest is NOT edited.
BOTH="$TMP/both.tsv"
{
  printf 'page\tp1\thttps://example.invalid/never-fetched\n'
  printf 'page\tp2\thttps://example.invalid/also-never\n'
  printf 'quote\tp1\tThe first sentence is here.\n'
  printf 'quote\tp2\tAnd the second sentence is here.\n'
} > "$BOTH"
QUOTE_FIXTURE_FILE="$PAGE" "$CHECKER" --manifest "$BOTH" >"$TMP/ab.out" 2>&1
check "AB both pages quoted is accepted" 0 "$?"
names "AB" "$TMP/ab.out" "sources=p1=fixture"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
