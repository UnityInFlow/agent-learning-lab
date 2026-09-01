#!/usr/bin/env bash
#
# Does the published board still describe the HANDOFF it claims to?
#
# WHY THIS EXISTS
#
# HANDOFF.md cites an artifact URL as "the readable view of this file". A view is a COPY, and
# a copy goes stale the moment the source moves. On 2026-08-30 the source moved eleven times
# in one session and the board went on saying B1 was blocked on seventeen blind cells that
# had by then been superseded outright.
#
# The guard in place at the time was a sentence in HANDOFF.md saying the file is the source of
# truth and the artifact is only a view. That is Layer 3 — words a reader chooses to follow —
# and it failed exactly the way L3 fails: nobody disbelieved the link, because nothing said
# the link was old.
#
# This script is the L2 version. It does not keep the board correct; nothing can do that
# except republishing it. It makes the board's staleness IMPOSSIBLE TO MISS, by failing.
#
# WHAT IT COMPARES
#
# HANDOFF.md records, beside each board link, the commit that the board was built from:
#
#     <!-- board: https://claude.ai/code/artifact/<id> built-from: <sha> -->
#
# The check asks whether HANDOFF.md has moved since that sha. Same question the blind sheet
# asks with `rubric_sha`, and for the same reason: an artifact that does not record what it
# was made from is a claim with no provenance.
#
# THE HONEST COST, so nobody discovers it as a surprise
#
# This fires on ANY commit touching HANDOFF.md, a typo included, and will sometimes demand a
# republish that changes nothing a reader would notice. That is deliberate. The alternative —
# hashing only the "material" sections — needs a definition of material, and a definition of
# material is a judgement that quietly stops being applied. A check that occasionally asks for
# a pointless republish still tells the truth; one that decides for itself which changes count
# eventually does not.
#
# Exit codes: 0 every board current (or none declared) · 1 at least one stale · 2 malformed
#
# Usage:  ./tools/check-board-freshness.sh [handoff-file]

set -uo pipefail

HANDOFF="${1:-HANDOFF.md}"

if [ ! -r "$HANDOFF" ]; then
  echo "check-board-freshness: cannot read $HANDOFF" >&2
  exit 2
fi

# Ask git for the file's own last commit rather than HEAD. HEAD moves for every commit in the
# repo; this must move only when the board's source actually changed, or the check cries wolf
# on every unrelated commit and gets ignored — which is how a control stops being a control.
current="$(git log -1 --format=%h -- "$HANDOFF" 2>/dev/null || true)"
if [ -z "$current" ]; then
  echo "check-board-freshness: $HANDOFF has no commit history yet — nothing to compare" >&2
  exit 0
fi

declared=0
stale=0

while IFS= read -r line; do
  # The url must LOOK like a url. Matching any non-space run after "board:" accepted
  # `<!-- board: built-from: abc1234 -->` as a board whose url was the literal string
  # "built-from:", which then failed as merely STALE rather than as MALFORMED — a wrong
  # diagnosis that would send someone republishing a board that does not exist. Found by
  # verify-board-freshness-checker.sh, which is the entire argument for having it.
  url="$(printf '%s' "$line" | sed -n 's|.*board: *\(https\{0,1\}://[^ ]*\).*|\1|p')"
  sha="$(printf '%s' "$line" | sed -n 's/.*built-from: *\([0-9a-f][0-9a-f]*\).*/\1/p')"

  if [ -z "$url" ] || [ -z "$sha" ]; then
    echo "MALFORMED board marker, needs 'board: <url> built-from: <sha>':" >&2
    echo "  $line" >&2
    exit 2
  fi

  declared=$((declared + 1))

  # Compare on the shorter of the two, so a marker written with a full sha and a `git log`
  # printing a short one still match. Never the reverse: a truncated comparison that passes
  # by accident is the failure mode this whole file exists to prevent elsewhere.
  n=${#sha}; [ ${#current} -lt "$n" ] && n=${#current}

  # SELF-INVALIDATION, and why this clause is not a loophole.
  #
  # Writing the marker edits HANDOFF.md, which moves the file's sha, which makes the marker
  # the check just wrote immediately stale. Left alone, the check would fail permanently and
  # be switched off within a week — the ordinary fate of a control that cries wolf.
  #
  # So: if everything that changed since the recorded sha is marker lines themselves, the
  # board still describes the prose accurately and this passes. The clause is narrow on
  # purpose. It asks whether the diff touches ONLY lines containing a board marker; one
  # substantive line in the same diff and the whole thing is stale again.
  fresh=0
  if [ "${sha:0:$n}" = "${current:0:$n}" ]; then
    fresh=1
  elif git cat-file -e "${sha}^{commit}" 2>/dev/null; then
    substantive="$(git diff "$sha" -- "$HANDOFF" 2>/dev/null \
                   | grep -E '^[+-]' | grep -Ev '^(\+\+\+|---)' \
                   | grep -vc 'board:' || true)"
    [ "${substantive:-1}" -eq 0 ] && fresh=1
  fi

  if [ "$fresh" -eq 1 ]; then
    echo "  current   $url  (built from $sha)"
  else
    echo "  STALE     $url" >&2
    echo "            built from $sha, but $HANDOFF is now at $current" >&2
    echo "            republish the board from the current file, then update its built-from marker" >&2
    stale=$((stale + 1))
  fi
done < <(grep -o '<!-- *board:[^>]*-->' "$HANDOFF" 2>/dev/null || true)

if [ "$declared" -eq 0 ]; then
  echo "check-board-freshness: no board markers in $HANDOFF — nothing claimed, nothing to check"
  exit 0
fi

if [ "$stale" -gt 0 ]; then
  echo "" >&2
  echo "$stale of $declared board(s) describe an older $HANDOFF than the one on disk." >&2
  echo "A board is a COPY. This check does not keep it correct; it stops it lying quietly." >&2
  exit 1
fi

echo "check-board-freshness: $declared board(s) current at $current"
exit 0
