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
# HANDOFF.md records, beside each board link, a digest of the prose the board was built from,
# and the commit it was built from as provenance for a human:
#
#     <!-- board: https://claude.ai/code/artifact/<id> built-from: <sha> prose: <digest> -->
#
# The check asks whether the prose still hashes to `prose:`. Same question the blind sheet
# asks with `rubric_sha`, and for the same reason: an artifact that does not record what it
# was made from is a claim with no provenance. `built-from:` is printed and never branched on.
#
# It compared a COMMIT until 2026-09-01. Squash merges destroy the commit a marker names, so
# that basis turned main red after every handoff update, on boards that were correct. The long
# comment further down records what that cost and why no ordering avoids it.
#
# THE HONEST COST, so nobody discovers it as a surprise
#
# This fires on ANY change to HANDOFF.md's prose, a typo included, and will sometimes demand a
# republish that changes nothing a reader would notice. That is deliberate, and moving to a
# digest did not soften it. The alternative — hashing only the "material" sections — needs a
# definition of material, and a definition of material is a judgement that quietly stops being
# applied. A check that occasionally asks for a pointless republish still tells the truth; one
# that decides for itself which changes count eventually does not.
#
# The ONE exclusion is the marker lines themselves, and it is not a judgement about what
# matters: it is what makes writing the marker possible at all. Hashing them would mean the
# act of recording the digest changed the digest.
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

# WHAT THIS COMPARES, AND WHY IT IS NO LONGER A COMMIT SHA.
#
# Until 2026-09-01 the marker named the commit the board was built from, and the check asked
# whether HANDOFF.md had moved since it. That basis has a defect that cannot be patched: the
# marker can only ever name a commit on the BRANCH, and squash-merging destroys that commit.
# It happened twice in one session -- 4f71a45 from PR #43, then bb7e316 from PR #46 -- and the
# second time it turned main red on a board that was byte-for-byte correct.
#
# There is no ordering that avoids it. Put the marker in the same PR as the prose and the sha
# it names is squashed away. Put it in a later PR and the PR carrying the prose is itself red.
# So the check would have failed after every handoff update forever, which is precisely the
# "control that cries wolf" this file warns about two comments below -- and it would have been
# switched off, correctly, as noise.
#
# The basis is now a digest of the PROSE, with marker lines excluded. That makes three
# problems disappear rather than get handled:
#
#   squash merges      irrelevant -- no commit is consulted
#   self-invalidation  impossible -- writing a marker cannot change a digest that excludes
#                      marker lines, so the narrow "marker-only diff" clause is gone
#   unresolvable sha   cannot arise, so the UNVERIFIABLE outcome added earlier today is gone
#                      with it. It was the right message for the old basis and the old basis
#                      is what was wrong
#
# `built-from:` is KEPT and is now purely provenance for a human: which commit someone built
# the board from. Nothing branches on it. `prose:` is what is checked.

digest_of() {
  # Marker lines are excluded so that writing or relabelling a marker cannot move the digest.
  if command -v sha256sum >/dev/null 2>&1; then
    sed '/board:/d' "$1" | sha256sum | cut -c1-12
  else
    sed '/board:/d' "$1" | shasum -a 256 | cut -c1-12
  fi
}

current="$(digest_of "$HANDOFF")"
if [ -z "$current" ]; then
  echo "check-board-freshness: cannot digest $HANDOFF" >&2
  exit 2
fi

declared=0
stale=0

while IFS= read -r line; do
  # The url must LOOK like a url. Matching any non-space run after "board:" accepted
  # `<!-- board: built-from: abc1234 -->` as a board whose url was the literal string
  # "built-from:", which then failed as merely STALE rather than as MALFORMED -- a wrong
  # diagnosis that would send someone republishing a board that does not exist. Found by
  # verify-board-freshness-checker.sh, which is the entire argument for having it.
  url="$(printf '%s' "$line" | sed -n 's|.*board: *\(https\{0,1\}://[^ ]*\).*|\1|p')"
  prose="$(printf '%s' "$line" | sed -n 's/.*prose: *\([0-9a-f][0-9a-f]*\).*/\1/p')"
  sha="$(printf '%s' "$line" | sed -n 's/.*built-from: *\([0-9a-f][0-9a-f]*\).*/\1/p')"

  if [ -z "$url" ] || [ -z "$prose" ]; then
    echo "MALFORMED board marker, needs 'board: <url> prose: <digest>':" >&2
    echo "  $line" >&2
    exit 2
  fi

  declared=$((declared + 1))

  # Compare on the shorter of the two, so a marker written with a longer digest still matches.
  # Never the reverse: a truncated comparison that passes by accident is the failure mode this
  # whole file exists to prevent elsewhere.
  n=${#prose}; [ ${#current} -lt "$n" ] && n=${#current}

  if [ "${prose:0:$n}" = "${current:0:$n}" ]; then
    echo "  current   $url  (prose $prose${sha:+, built from $sha})"
  else
    echo "  STALE     $url" >&2
    echo "            marker says prose $prose, but $HANDOFF hashes to $current" >&2
    echo "            the prose actually changed. Republish the board from the current file," >&2
    echo "            then set its prose: marker to $current" >&2
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
