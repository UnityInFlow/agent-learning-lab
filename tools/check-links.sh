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

UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36'

files=("${@:-SOURCES.md CURRICULUM.md}")
# shellcheck disable=SC2128
[ $# -eq 0 ] && files=(SOURCES.md CURRICULUM.md)

# Strip markdown punctuation that can cling to a URL: backticks, brackets, quotes,
# and trailing sentence punctuation. A trailing backtick produced a false 404 once.
urls=$(grep -ohE 'https?://[^ )>,"`]+' "${files[@]}" | sed 's/[.,;:]*$//' | sort -u)
total=$(echo "$urls" | wc -l | tr -d ' ')
echo "Checking $total unique URLs in ${files[*]}"
echo

fail=0 moved=0 blocked=0 ok=0 unver=0

while read -r u; do
  [ -z "$u" ] && continue
  # The lab's own repos used to be private, and a private repo 404s to an unauthenticated
  # curl, so they were skipped outright. All three went public and the skip stayed: on
  # 2026-08-28 two URLs were reported PRIVATE and counted as neither ok nor broken while
  # both answered 200. A check that does not run is not a pass. So check them like anything
  # else, and let a 404 -- the shape a private repo actually returns -- be what reports
  # PRIVATE, instead of the hostname deciding the answer in advance.
  own_repo=0
  case "$u" in
    https://github.com/UnityInFlow/*) own_repo=1 ;;
  esac
  # Local service endpoints are not sources and must not fail a cohort check. They were
  # counted as broken=2 on 2026-08-10 and would have exited 1 for no reason: 4317 is gRPC,
  # so an HTTP GET cannot succeed, and 4318/v1/traces answers 405 because it is POST-only —
  # that 405 is the collector working, reported as a failure.
  case "$u" in
    http://localhost:*|http://127.0.0.1:*|http://0.0.0.0:*)
      printf '🏠 LOCAL   %s  (service endpoint, not a source)\n' "$u"; continue ;;
  esac
  # A bare "Mozilla/5.0" is not a browser, and two hosts treat it as one more bot: on
  # 2026-08-28 anthropic.com and code.claude.com dropped the connection rather than
  # answering, curl reported 000, and this script counted two live pages as broken and
  # exited 1. Same defect class as the 405 above -- the checker failing, dressed up as the
  # source failing. Both answer 200 to the full UA below.
  code=000 final=-
  for _attempt in 1 2; do
    read -r code final < <(curl -sSL -o /dev/null \
        -w '%{http_code} %{url_effective}' \
        --max-time 25 -A "$UA" "$u" 2>/dev/null || echo "000 -")
    [ "$code" != "000" ] && break
  done

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
    000)
      # No HTTP response at all after two tries. That is a transport failure -- a timeout,
      # a reset, a bot filter that drops instead of answering -- and it is NOT evidence
      # that the page is gone. Calling it broken states something the check never
      # established, so it gets its own bucket: not ok, not broken, resolved by a human.
      # Same reasoning as the 403 above, which is the polite form of the same behaviour.
      printf '⚠️  UNVERIFIED %s  (no HTTP response in 2 tries -- transport failure, not a 404)\n' "$u"
      unver=$((unver + 1))
      ;;
    404)
      if [ "$own_repo" = 1 ]; then
        printf '🔑 PRIVATE %s  (404 unauthenticated — private again, or renamed)\n' "$u"
      else
        printf '❌ %s     %s\n' "$code" "$u"
        fail=$((fail + 1))
      fi
      ;;
    *)
      printf '❌ %s     %s\n' "$code" "$u"
      fail=$((fail + 1))
      ;;
  esac
done <<< "$urls"

echo
echo "ok=$ok moved=$moved blocked=$blocked unverified=$unver broken=$fail"

if [ "$unver" -gt $((total / 2)) ]; then
  echo
  echo "More than half the URLs returned nothing at all. That is this machine's network,"
  echo "not link rot -- do not record a drift finding from this run."
fi

if [ "$moved" -gt 0 ]; then
  echo
  echo "A redirect is not automatically harmless. If a page was *renamed*, the model"
  echo "behind it usually changed too — read it fresh rather than trusting notes written"
  echo "against the old title, and update SOURCES.md."
fi

[ "$fail" -eq 0 ]
