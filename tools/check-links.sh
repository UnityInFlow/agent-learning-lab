#!/usr/bin/env bash
# Re-verify every source link in SOURCES.md and CURRICULUM.md.
#
# Run before each cohort. Vendor agent docs move often — during the 2026-08-09 check,
# 7 of 43 links redirected, including the entire Codex documentation host.
#
#   ./tools/check-links.sh            # check everything
#   ./tools/check-links.sh SOURCES.md # check one file
#
# Exit 1 if anything 404s or errors. Redirects and 403s are reported, not fatal:
# openai.com returns 403 to non-browser user agents but the pages are live.

set -uo pipefail
# `|| exit` is not defensive noise: without it a failed cd leaves the script running in the
# caller's directory, where the SOURCES.md it checks is whatever happened to be there.
cd "$(dirname "$0")/.." || exit 1

files=("${@:-SOURCES.md CURRICULUM.md}")
# shellcheck disable=SC2128
[ $# -eq 0 ] && files=(SOURCES.md CURRICULUM.md)

# Strip markdown punctuation that can cling to a URL: backticks, brackets, quotes,
# and trailing sentence punctuation. A trailing backtick produced a false 404 once.
urls=$(grep -ohE 'https?://[^ )>,"`]+' "${files[@]}" | sed 's/[.,;:]*$//' | sort -u)
total=$(echo "$urls" | wc -l | tr -d ' ')
echo "Checking $total unique URLs in ${files[*]}"
echo

fail=0 moved=0 blocked=0 ok=0

while read -r u; do
  [ -z "$u" ] && continue
  # Private repos 404 to an unauthenticated curl. Not broken — unreachable to this checker.
  case "$u" in
    https://github.com/UnityInFlow/*) printf '🔑 PRIVATE %s\n' "$u"; continue ;;
  esac
  # Local service endpoints are not sources and must not fail a cohort check. They were
  # counted as broken=2 on 2026-08-10 and would have exited 1 for no reason: 4317 is gRPC,
  # so an HTTP GET cannot succeed, and 4318/v1/traces answers 405 because it is POST-only —
  # that 405 is the collector working, reported as a failure.
  case "$u" in
    http://localhost:*|http://127.0.0.1:*|http://0.0.0.0:*)
      printf '🏠 LOCAL   %s  (service endpoint, not a source)\n' "$u"; continue ;;
  esac
  read -r code final < <(curl -sSL -o /dev/null \
      -w '%{http_code} %{url_effective}' \
      --max-time 25 -A 'Mozilla/5.0' "$u" 2>/dev/null || echo "000 -")

  case "$code" in
    200|30*)
      if [ "$final" != "$u" ]; then
        printf '↪️  MOVED   %s\n           → %s\n' "$u" "$final"
        moved=$((moved + 1))
      else
        ok=$((ok + 1))
      fi
      ;;
    403)
      printf '🔒 BLOCKED %s  (403 to curl — verify in a browser)\n' "$u"
      blocked=$((blocked + 1))
      ;;
    *)
      printf '❌ %s     %s\n' "$code" "$u"
      fail=$((fail + 1))
      ;;
  esac
done <<< "$urls"

echo
echo "ok=$ok moved=$moved blocked=$blocked broken=$fail"

if [ "$moved" -gt 0 ]; then
  echo
  echo "A redirect is not automatically harmless. If a page was *renamed*, the model"
  echo "behind it usually changed too — read it fresh rather than trusting notes written"
  echo "against the old title, and update SOURCES.md."
fi

[ "$fail" -eq 0 ]
