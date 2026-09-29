#!/usr/bin/env bash
# verify-quotes.sh — prove that every sentence a workbook quotes is still in the page it
# cites, or say which is not. The pages and the quotes come from a MANIFEST, so one proved
# instrument serves every phase instead of one hardcoded copy per phase.
#
# WHY THIS IS A TOOL AND NOT A SECOND COPY. Stop 23 (Phase 8) wrote
# `evidence/p08/verify-quotes.sh` with its pages and quotes compiled in, and the §4a review
# found FIVE defects in it, all of one shape: a failure to fetch or parse, reported as
# documentation drift. Copying that file per phase copies the shape and re-earns the defects
# one phase at a time. This file is the same machinery with the phase-specific data lifted
# into a manifest; every one of stop 23's five fixes is carried here and cited at the line it
# protects, and `tools/verify-quote-checker.sh` re-proves each of them against THIS file
# rather than trusting that the copy was faithful.
#
# Stop 23's script is deliberately NOT modified: it produced a measured result and §6 keeps
# measured artefacts as they were. Instead, this tool is run against a manifest transcribed
# from it (`evidence/p08/quotes-p08.tsv`) and must reproduce its live numbers exactly. A
# generalisation that changes a measured number is a defect in the generalisation.
#
#   ./tools/verify-quotes.sh --manifest evidence/p09/quotes-p09.tsv
#   ./tools/verify-quotes.sh --manifest <file> --list     # print the quote table, fetch nothing
#
# MANIFEST FORMAT — tab-separated, '#' comments and blank lines ignored:
#   page <TAB> <key> <TAB> <url>          declares a page and names it
#   quote <TAB> <key> <TAB> <sentence>    a sentence that must appear on that page
#
# Exit codes — registered, and `tools/verify-quote-checker.sh` proves each one:
#   0  every quote in the manifest was found in its page
#   2  at least one quote was not found (the interesting failure; not an error)
#   3  a page could not be fetched, read, or converted to text (nothing was proved either way)
#   4  bad usage, or a manifest that cannot be trusted to mean what it says
#
# REGISTERED LIMITATION, inherited from stop 23 and unchanged. `strip` removes <script> and
# <style> and then all tags, so the searched text includes page CHROME — navigation, footers,
# accessibility-only elements. A sentence deleted from the body but surviving in chrome would
# still report FOUND. The claim this script supports is therefore exactly: "the quoted
# sentence still appears somewhere on the cited page", which is the claim a workbook makes,
# since a quotation cites a page and not a region. Raised by the §4a codex review 2026-09-27
# and DISPUTED rather than fixed: body extraction needs a per-site selector that breaks on the
# next redesign, and these quotes are full sentences, which chrome does not carry.
#
# It is L2 over the quoting and says nothing whatever about the agent under test.
set -uo pipefail

MANIFEST=""
LIST=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --manifest) [ "$#" -ge 2 ] || { echo "--manifest needs a path" >&2; exit 4; }
                MANIFEST="$2"; shift 2 ;;
    --list)     LIST=1; shift ;;
    *)          echo "usage: $0 --manifest <file> [--list]" >&2; exit 4 ;;
  esac
done
[ -n "$MANIFEST" ] || { echo "usage: $0 --manifest <file> [--list]" >&2; exit 4; }
[ -r "$MANIFEST" ] || { echo "MANIFEST NOT READABLE $MANIFEST" >&2; exit 4; }

# Resolve the manifest BEFORE the cd, so a path relative to the caller's directory still
# means what the caller meant. The cd itself is the house rule: without `|| exit` a failed cd
# leaves the script running wherever the caller happened to be.
MANIFEST=$(cd "$(dirname "$MANIFEST")" && pwd)/$(basename "$MANIFEST") || exit 4
cd "$(dirname "$0")/.." || exit 4

CACHE="${QUOTE_CACHE_DIR:-}"          # set to re-check against already-fetched pages
FIXTURE="${QUOTE_FIXTURE_FILE:-}"     # set by verify-quote-checker.sh to a single local page
SLUG=$(basename "$MANIFEST"); SLUG=${SLUG%.tsv}

# ---- parse the manifest ------------------------------------------------------------------
# Every rejection below is exit 4 — a manifest that cannot be trusted is a MISCONFIGURED
# VERIFIER, and this project's house failure mode is a misconfiguration that reports as a
# finding. None of these may ever come out as exit 2.
PAGE_KEYS=" "
declare -a PAGES=()
QUOTES=""
lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno+1))
  case "$line" in ''|'#'*) continue ;; esac
  kind=${line%%	*}; rest=${line#*	}
  key=${rest%%	*}; val=${rest#*	}
  if [ "$rest" = "$line" ] || [ "$val" = "$rest" ] || [ -z "$key" ] || [ -z "$val" ]; then
    printf 'MALFORMED MANIFEST LINE %s: expected <kind>TAB<key>TAB<value>\\n' "$lineno" >&2
    exit 4
  fi
  # ---- §4a round-1 defects (1) and (2), codex + deepseek-v4-pro panel, 2026-09-29 ---------
  # The key had NO GRAMMAR. Two consequences, both silent:
  #   (1) a key containing `../` makes every `cp`/`curl` below write to "$TMP/$key.html",
  #       i.e. OUTSIDE the mktemp directory, so the EXIT trap does not remove it — the
  #       verifier writes into the repository and leaves the file behind.
  #   (2) a key containing `|` breaks the `key=${entry%%|*}` split at the fetch loop, so the
  #       url silently becomes the wrong string and the page fetched is not the page declared.
  # Both are exit 4 for the reason the block above gives: a manifest that cannot be trusted is
  # a MISCONFIGURED VERIFIER, and it must never be reported as a drift result.
  case "$key" in
    *[!A-Za-z0-9_-]*|'')
      printf 'ILLEGAL KEY %s at manifest line %s: keys are [A-Za-z0-9_-]+ — not a drift result\n' \
        "'$key'" "$lineno" >&2
      exit 4 ;;
  esac
  # §4a round-1 defect (3): the two parse sites disagreed about a TAB inside the value. Line
  # ~80 keeps every tab after the first; the matcher's `IFS=$'\t' read` does not. A quote
  # carrying a tab was therefore silently DIFFERENT in the two places, so it is refused here
  # rather than truncated somewhere else.
  case "$val" in
    *"$(printf '\t')"*)
      printf 'TAB INSIDE VALUE at manifest line %s: a quote may not contain a tab — not a drift result\n' \
        "$lineno" >&2
      exit 4 ;;
  esac

  case "$kind" in
    page)
      case "$PAGE_KEYS" in
        *" $key "*) echo "DUPLICATE PAGE KEY '$key' at manifest line $lineno" >&2; exit 4 ;;
      esac
      PAGE_KEYS="$PAGE_KEYS$key "
      PAGES+=("$key|$val")
      ;;
    quote)
      QUOTES="$QUOTES$key	$val
" ;;
    *) echo "UNKNOWN MANIFEST KIND '$kind' at line $lineno (expected 'page' or 'quote')" >&2
       exit 4 ;;
  esac
done < "$MANIFEST"

# A checker with nothing to check must not exit 0. Stop 23's five defects were all "I failed
# to look, reported as it is not there"; this is the same shape inverted — "I looked at
# nothing, reported as everything verified" — and an empty or all-comment manifest produces
# it. It is exit 4 and not exit 0.
[ "${#PAGES[@]}" -gt 0 ] || { echo "MANIFEST DECLARES NO PAGES $MANIFEST" >&2; exit 4; }
[ -n "$QUOTES" ] || { echo "MANIFEST DECLARES NO QUOTES $MANIFEST" >&2; exit 4; }

# Every quote's page key must name a DECLARED page. A typo used to read a file that does not
# exist, with stderr discarded by `2>/dev/null`, and print ABSENT — so an invalid verifier
# configuration was indistinguishable from real documentation drift. (Stop 23 defect (c),
# §4a codex review 2026-09-27.) Bash 3.2 ships on this machine, so this is a string
# membership test and not an associative array.
while IFS=$'\t' read -r key _q; do
  [ -z "${key:-}" ] && continue
  case "$PAGE_KEYS" in
    *" $key "*) : ;;
    *) echo "UNDECLARED PAGE KEY '$key' in manifest quotes — not a drift result" >&2; exit 4 ;;
  esac
done <<< "$QUOTES"

# ...and the SYMMETRIC check, which was missing. §4a round-4 BLOCKING finding, codex +
# deepseek-v4-pro panel, 2026-09-29: the validator above only asked "does every quote name a
# declared page". Nothing asked "is every declared page quoted". An ORPHAN page — a see-also or
# context url nobody quotes — was fetched anyway, and if its url were dead the WHOLE manifest
# died at exit 3 with nothing reported: the quotes that would have verified lost behind an exit
# code whose documented meaning is "nothing was proved either way", indistinguishable from a
# fetch failure on the page that actually carried the drift signal.
#
# IT IS A SKIP, NOT A REFUSAL, and that choice is not a softening. The first run of the refusing
# version REFUSED evidence/p08/quotes-p08.tsv — which declares page key `home` and quotes it
# nowhere. That manifest is transcribed MECHANICALLY from stop 23's script and is the parity
# proof; editing it would break the property that makes the parity mean anything, and refusing it
# would destroy a reproducible measurement over a page that contributes NOTHING to any result.
# An orphan page can only ever hurt — it cannot add a quote, and it can abort a run — so the fix
# is to not fetch it and to say so. The exit code stays driven by the quotes. Fixtures AA and AB.
SKIPPED_PAGES=""
KEPT_PAGES=()
for entry in "${PAGES[@]}"; do
  pkey=${entry%%|*}
  qref=0
  while IFS=$'\t' read -r key _q; do
    [ -z "${key:-}" ] && continue
    [ "$key" = "$pkey" ] && { qref=1; break; }
  done <<< "$QUOTES"
  if [ "$qref" = 1 ]; then
    KEPT_PAGES+=("$entry")
  else
    echo "ORPHAN PAGE KEY '$pkey' declared but quoted by nothing - SKIPPED, not fetched" >&2
    SKIPPED_PAGES="$SKIPPED_PAGES$pkey "
  fi
done
PAGES=("${KEPT_PAGES[@]}")
# Every page was an orphan: nothing would be fetched and every quote would then fail on a missing
# file. That is the "I looked at nothing" shape again and it is exit 4, not a page of absences.
[ "${#PAGES[@]}" -gt 0 ] || { echo "EVERY DECLARED PAGE IS AN ORPHAN $MANIFEST" >&2; exit 4; }

if [ "$LIST" = 1 ]; then printf '%s' "$QUOTES"; exit 0; fi

# §4a round-4 line-level finding (4), deepseek-v4-pro: a failure to make a local scratch
# directory exited 3, the code that means "a page could not be read" — although no page had been
# touched. It is an environment failure, not a fetch failure, and it now says so on stderr. The
# code stays 3 rather than moving, because this file's exit taxonomy is quoted in the stop-24
# workbook's validation table and in 47 fixture cases: renaming a registered code at the close of
# the stop that registered it is the one thing §6 forbids outright. The message is the fix that
# was available.
TMP=$(mktemp -d) || { echo "CANNOT CREATE SCRATCH DIRECTORY — an environment failure, not a page fetch failure" >&2; exit 3; }
trap 'rm -rf "$TMP"' EXIT

# §4a round-3 blocking finding (2), codex + deepseek-v4-pro panel, 2026-09-29: these two
# substitutions were case-sensitive, so a `<SCRIPT>` block SURVIVED the strip and a sentence
# that exists only inside uppercase script content reported FOUND. The registered limitation
# in this file's own header says "strip removes <script> and <style>" — which was true of
# lowercase only. That is the house failure mode exactly: A CONTROL REPORTING OVER A SCOPE
# SMALLER THAN IT CLAIMS. `re.I` added; fixture W proves it on an uppercase block.
strip() { # html on stdin -> one long line of text on stdout
  python3 -c '
import sys,re,html
t=sys.stdin.read()
t=re.sub(r"<script.*?</script>","",t,flags=re.S|re.I)
t=re.sub(r"<style.*?</style>","",t,flags=re.S|re.I)
sys.stdout.write(re.sub(r"\s+"," ",html.unescape(re.sub(r"<[^>]+>"," ",t))))'
}

# Bash 3.2 ships on this machine as /bin/bash and REJECTS `declare -A`. The first version of
# this block used one and passed every check here only because `env bash` resolves to a 5.x
# Homebrew build — green in my environment, broken on the platform this file's own header
# names four lines above. Found by the §4a codex + deepseek-v4-pro panel, 2026-09-29. It is a
# newline-delimited string with a tab separator, the same membership idiom used above, and the
# ORDER IS THE MANIFEST'S rather than a hash's — which also fixes the non-deterministic
# `sources=` ordering the same finding named.
PAGE_SOURCES=""
for entry in "${PAGES[@]}"; do
  key=${entry%%|*}; url=${entry#*|}
  SOURCE="unknown"
  # §4a round-3 blocking finding (1), codex + deepseek-v4-pro panel, 2026-09-29: the cache
  # filename was "$SLUG-$key.html" — manifest basename plus page key, and NOT the declared URL.
  # Two manifests sharing a basename and a key but declaring DIFFERENT urls collided: the second
  # read the first's page and reported `sources=<key>=cached` for a url it never fetched, with
  # nothing in the output naming the url. A wrong cache HIT is silent; a cache MISS is not,
  # because it falls through to a live fetch and says so. The url is therefore part of the name.
  # A cache written under the old name is not found, and that is warned about rather than used.
  urlhash=$(printf '%s' "$url" | shasum -a 256 | cut -c1-12)
  if [ -n "$CACHE" ] && [ ! -f "$CACHE/$SLUG-$key-$urlhash.html" ] && [ -f "$CACHE/$SLUG-$key.html" ]; then
    echo "PRE-URL-HASH CACHE NAME for key '$key' at $CACHE/$SLUG-$key.html - IGNORED, fetching live; re-populate it as $SLUG-$key-$urlhash.html" >&2
  fi
  if [ -n "$FIXTURE" ]; then
    # A fixture that cannot be read proves nothing about a quote, so it is exit 3 — the same
    # code as a failed fetch — and never a page full of absences.
    [ -r "$FIXTURE" ] || { echo "FIXTURE NOT READABLE $FIXTURE" >&2; exit 3; }
    [ -s "$FIXTURE" ] || { echo "FIXTURE EMPTY $FIXTURE" >&2; exit 3; }
    cp "$FIXTURE" "$TMP/$key.html"; SOURCE="fixture"
  elif [ -n "$CACHE" ] && [ -f "$CACHE/$SLUG-$key-$urlhash.html" ]; then
    # Stop 23 defect (b): identical empty content was classified two different ways depending
    # only on where it came from — an empty live response or fixture exited 3, an empty CACHED
    # page reached the matcher and exited 2. Same input, two verdicts.
    [ -s "$CACHE/$SLUG-$key-$urlhash.html" ] || { echo "EMPTY CACHED PAGE $key $CACHE/$SLUG-$key-$urlhash.html" >&2; exit 3; }
    cp "$CACHE/$SLUG-$key-$urlhash.html" "$TMP/$key.html"; SOURCE="cached"
  else
    # Stop 23 defect (a): `--fail` is load-bearing. Without it a 404 that serves a non-empty
    # HTML error page exits 0, the strip step produces real text, every quote for that page
    # reports ABSENT and the script exits 2 — CLAIMING DOCUMENTATION DRIFT FOR A PAGE IT NEVER
    # READ. That is this project's house failure mode (a control reporting over a scope smaller
    # than it claims) and it could have produced a false headline.
    curl -fsS -m 40 -L "$url" -o "$TMP/$key.html" || { echo "FETCH FAILED $key $url" >&2; exit 3; }
    [ -s "$TMP/$key.html" ] || { echo "EMPTY PAGE $key $url" >&2; exit 3; }
    SOURCE="live"
  fi
  # Stop 23 defect (d), the one its §4a ACCEPTANCE GATE blocked on (minimax-m3, REJECT,
  # 2026-09-28): the strip step is a python3 wrapper and it CAN fail — a crashing or missing
  # interpreter, or a page carrying a non-UTF-8 byte (UnicodeDecodeError). `set -uo pipefail`
  # does not catch it because `-e` is absent, so an EMPTY .txt reached the matcher and every
  # quote on the page printed ABSENT at exit 2 — AN INTERNAL PROCESSING FAILURE REPORTED AS
  # DOCUMENTATION DRIFT.
  if ! strip < "$TMP/$key.html" > "$TMP/$key.txt"; then
    echo "STRIP FAILED $key (html -> text extraction)" >&2; exit 3
  fi
  [ -s "$TMP/$key.txt" ] || { echo "STRIP PRODUCED NO TEXT $key" >&2; exit 3; }
  PAGE_SOURCES="$PAGE_SOURCES$key\t$SOURCE\n"
done
PAGE_SOURCES=$(printf '%b' "$PAGE_SOURCES")

source_of() { # key -> the source recorded for it
  printf '%s\n' "$PAGE_SOURCES" | while IFS=$'\t' read -r k v; do
    [ "$k" = "$1" ] && { printf '%s' "$v"; return 0; }
  done
}

# §4a round-3 line-level finding (4), deepseek-v4-pro: `strip()` collapses every whitespace run
# in the PAGE to one space, and the matcher then searched the quote RAW. A quote carrying a
# double space, a tab or a trailing run therefore could never match text that was present —
# a FALSE ABSENT, which is the direction that INFLATES a staleness headline rather than hiding
# one. Neither quotes-p09.tsv nor quotes-p08.tsv carries such a run (checked by `awk` before
# this fix, and the two manifests re-run after it return the same cells), so it did not bite on
# any measurement on file; it is fixed because the next manifest is not checked by that fact.
# The collapse here is the SAME collapse `strip()` applies, deliberately: no trimming, no
# case folding, nothing the page side does not also do. Fixture Z proves it.
found=0; missing=0
while IFS=$'\t' read -r key quote; do
  [ -z "${key:-}" ] && continue
  quote=$(printf '%s' "$quote" | tr -s '[:space:]' ' ')
  if grep -qF -- "$quote" "$TMP/$key.txt"; then   # no 2>/dev/null: every key is validated above
    printf 'FOUND   [%s:%s] %s\n' "$key" "$(source_of "$key")" "$quote"; found=$((found+1))
  else
    printf 'ABSENT  [%s:%s] %s\n' "$key" "$(source_of "$key")" "$quote"; missing=$((missing+1))
  fi
done <<< "$QUOTES"

# §4a round-1 defect (4): a CACHED page produced a byte-identical result line and exit code to
# a LIVE fetch, so nothing in the output said whether the network had been touched. That is the
# stop-23 defect class one level up — not "a failure reported as a result", but "a result whose
# PROVENANCE is unreportable". Every line now carries its source, and so does the summary.
SOURCES=""
while IFS=$'\t' read -r k v; do
  [ -n "${k:-}" ] && SOURCES="$SOURCES$k=$v "
done <<EOF_SRC
$PAGE_SOURCES
EOF_SRC
# The skipped set goes in the SUMMARY LINE and not only on stderr: stderr is discarded by every
# caller that redirects, and a page silently not fetched is exactly the kind of narrowed scope
# this stop spent its whole review budget on.
if [ -n "$SKIPPED_PAGES" ]; then
  printf '\nmanifest=%s found=%d absent=%d sources=%s skipped-orphan-pages=%s\n' "$SLUG" "$found" "$missing" "${SOURCES% }" "${SKIPPED_PAGES% }"
else
  printf '\nmanifest=%s found=%d absent=%d sources=%s\n' "$SLUG" "$found" "$missing" "${SOURCES% }"
fi
[ "$missing" -eq 0 ] && exit 0
exit 2
