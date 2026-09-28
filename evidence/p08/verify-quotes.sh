#!/usr/bin/env bash
# verify-quotes.sh — prove that every sentence phases/08-agentic-workflows/README.md quotes
# is still in the page it cites, or say which is not.
#
# Stop 23 (Phase 8, gh-aw) wrote an extract out of seven documentation pages. A quote is a
# claim about a document, and this project's rule is that a claim needs something that
# executes behind it. `check-links.sh` proves a URL resolves; nothing here proved a quotation
# still appears in the resolved page — and the August 2026 extract of this same phase carried
# a bold display quote that had since disappeared. This script is that missing check, scoped
# to one phase.
#
# Exit codes — registered, and the fixture set below proves each one:
#   0  every quote in QUOTES was found in its page
#   2  at least one quote was not found (the interesting failure; not an error)
#   3  a page could not be fetched (nothing was proved either way)
#   4  bad usage
#
# REGISTERED LIMITATION, not a defect to discover later. `strip` removes <script> and <style>
# and then all tags, so the searched text includes page CHROME — navigation, footers,
# accessibility-only elements. A sentence deleted from the body but surviving in chrome would
# still report FOUND. The claim this script supports is therefore exactly: "the quoted
# sentence still appears somewhere on the cited page", which is the claim the workbook makes,
# since a quotation cites a page and not a region. Raised by the §4a codex review,
# 2026-09-27, and DISPUTED rather than fixed: body extraction needs a per-site selector that
# breaks on the next redesign, and these quotes are full sentences, which chrome does not
# carry. The limitation is written here so no reader infers a stronger claim.
#
# It is L2 over the quoting and says nothing whatever about the agent under test.
set -uo pipefail

CACHE="${QUOTE_CACHE_DIR:-}"          # set to re-check against already-fetched pages
FIXTURE="${QUOTE_FIXTURE_FILE:-}"     # set by verify-quote-checker.sh to a single local page

usage() { echo "usage: $0 [--list]" >&2; exit 4; }
[ "$#" -gt 1 ] && usage
[ "${1:-}" = "--list" ] && LIST=1 || LIST=0
[ "$#" -eq 1 ] && [ "$LIST" = 0 ] && usage

declare -a PAGES=(
  "home|https://github.github.com/gh-aw/"
  "creating|https://github.github.com/gh-aw/setup/creating-workflows/"
  "safe|https://github.github.com/gh-aw/reference/safe-outputs/"
  "perms|https://github.github.com/gh-aw/reference/permissions/"
  "exp|https://github.github.com/gh-aw/experimental/experiments/"
  "threat|https://github.github.com/gh-aw/reference/threat-detection/"
  "trig|https://github.github.com/gh-aw/reference/triggers/"
)

# page-key <TAB> the sentence, exactly as the workbook quotes it
QUOTES=$(cat <<'Q'
safe	Safe outputs enforce security through separation
safe	least privilege, defense against prompt injection, auditability, and controlled limits per operation
safe	all without giving the agentic portion of the workflow any write permissions
safe	The agent never receives write tokens directly
safe	create-issue is automatically enabled with conservative defaults
safe	Every write operation is skipped
safe	Merge pull requests after policy gates pass (max: 1, experimental)
safe	Trigger other workflows with inputs (max: 3, same-repo only)
safe	Create Copilot coding agent sessions (max: 1)
perms	GitHub Agentic Workflows uses read-only permissions by default for security, with write operations handled through safe outputs
perms	id-token: read is not a valid permission and will be rejected at compile time
creating	A GitHub Agentic Workflows source is a Markdown file in
creating	The gh aw compile command turns this source into the .lock.yml GitHub Actions workflow
creating	Add, commit and push the workflow file and its lock file to your repository
threat	analyze agent output and code changes for potential security issues before they are applied
threat	Threat detection is automatically enabled when safe outputs are configured
threat	the workflow stops and safe outputs are not applied. This fail-safe approach prevents potentially malicious content from being processed
threat	By default, threat detection uses the same AI engine as your main workflow to analyze output for security threats
threat	a static, rule-based protection layer
threat	Hard-block: the safe output fails with an error message
trig	roles is an allowlist, not a privilege threshold
trig	will reject actors with admin or maintainer roles because admin !== write
trig	Pull request workflows block forks by default for security
trig	Automatically disable workflow triggering after a deadline to control costs
exp	A/B Experiments is an experimental feature
exp	Statistical significance alone does not override minimum_effect
exp	Only usable observations count toward min_samples
exp	Over time, this keeps usage roughly balanced across variants
exp	It does not promote a variant, edit the workflow, or change traffic
Q
)

if [ "$LIST" = 1 ]; then printf '%s\n' "$QUOTES"; exit 0; fi

TMP=$(mktemp -d) || exit 3
trap 'rm -rf "$TMP"' EXIT

strip() { # html on stdin -> one long line of text on stdout
  python3 -c '
import sys,re,html
t=sys.stdin.read()
t=re.sub(r"<script.*?</script>","",t,flags=re.S)
t=re.sub(r"<style.*?</style>","",t,flags=re.S)
sys.stdout.write(re.sub(r"\s+"," ",html.unescape(re.sub(r"<[^>]+>"," ",t))))'
}

for entry in "${PAGES[@]}"; do
  key=${entry%%|*}; url=${entry#*|}
  if [ -n "$FIXTURE" ]; then
    # A fixture that cannot be read proves nothing about a quote, so it is exit 3 —
    # the same code as a failed fetch — and never a page full of absences.
    [ -r "$FIXTURE" ] || { echo "FIXTURE NOT READABLE $FIXTURE" >&2; exit 3; }
    [ -s "$FIXTURE" ] || { echo "FIXTURE EMPTY $FIXTURE" >&2; exit 3; }
    cp "$FIXTURE" "$TMP/$key.html"
  elif [ -n "$CACHE" ] && [ -f "$CACHE/ghaw-$key.html" ]; then
    # Identical empty content used to be classified two different ways depending only on
    # where it came from: an empty live response or fixture exits 3, an empty CACHED page
    # reached the matcher and exited 2. Same input, two verdicts. Found by the §4a codex
    # review, 2026-09-27; fixture J proves the fix.
    [ -s "$CACHE/ghaw-$key.html" ] || { echo "EMPTY CACHED PAGE $key $CACHE/ghaw-$key.html" >&2; exit 3; }
    cp "$CACHE/ghaw-$key.html" "$TMP/$key.html"
  else
    # `--fail` is load-bearing and was missing. Without it a 404 that serves a non-empty
    # HTML error page exits 0, the strip step produces real text, every quote for that
    # page reports ABSENT and the script exits 2 — CLAIMING DOCUMENTATION DRIFT FOR A PAGE
    # IT NEVER READ. That is this project's house failure mode (a control reporting over a
    # scope smaller than it claims) and it could have produced a false headline.
    # Found by the §4a codex review, 2026-09-27; fixture I proves the fix.
    curl -fsS -m 40 -L "$url" -o "$TMP/$key.html" || { echo "FETCH FAILED $key $url" >&2; exit 3; }
    [ -s "$TMP/$key.html" ] || { echo "EMPTY PAGE $key $url" >&2; exit 3; }
  fi
  strip < "$TMP/$key.html" > "$TMP/$key.txt"
done

# Every quote's page key must name a DECLARED page. A typo used to read a file that does not
# exist, with stderr discarded by `2>/dev/null`, and print ABSENT — so an invalid verifier
# configuration was indistinguishable from real documentation drift. Bash 3.2 ships on this
# machine, so this is a string membership test and not an associative array.
# Found by the §4a codex review, 2026-09-27; fixture K proves the fix.
PAGE_KEYS=" "
for entry in "${PAGES[@]}"; do PAGE_KEYS="$PAGE_KEYS${entry%%|*} "; done
while IFS=$'\t' read -r key _q; do
  [ -z "${key:-}" ] && continue
  case "$PAGE_KEYS" in
    *" $key "*) : ;;
    *) echo "UNDECLARED PAGE KEY '$key' in QUOTES — not a drift result" >&2; exit 4 ;;
  esac
done <<< "$QUOTES"

found=0; missing=0
while IFS=$'\t' read -r key quote; do
  [ -z "${key:-}" ] && continue
  if grep -qF -- "$quote" "$TMP/$key.txt"; then   # no 2>/dev/null: every key is validated above
    printf 'FOUND   [%s] %s\n' "$key" "$quote"; found=$((found+1))
  else
    printf 'ABSENT  [%s] %s\n' "$key" "$quote"; missing=$((missing+1))
  fi
done <<< "$QUOTES"

printf '\nfound=%d absent=%d\n' "$found" "$missing"
[ "$missing" -eq 0 ] && exit 0
exit 2
