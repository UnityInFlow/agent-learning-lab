#!/usr/bin/env bash
# What did the scorer actually produce? One exit code per outcome, because "no scores" was
# five different things wearing one word.
#
# E-001 asks whether a rubric can decide anything. Its most informative possible result is
# the scorer failing to produce a sheet — that already happened once, on file: a
# seven-category rubric whose anchors cited things the scorer could not see made it "emit an
# empty body. Not a bad score. Nothing." The old guard in opencode-score.sh called that
# `FATAL ... produced nothing usable` and exited 1, the same code it used for opencode
# crashing, and the experiment's Exclusions then told the reader to re-run it as
# infrastructure. The harness threw away the phenomenon under test and labelled it a broken
# script. `lab-acceptance` rejected the record on exactly this, blocking, 2026-08-27.
#
# The split below is the Layer 2 version of that distinction. Two of these codes mean the
# run is infrastructure and must be discarded; three of them mean the rubric did something,
# and the run is evidence.
#
#   ./tools/classify-score-output.sh findings/opencode/score-known-good-<stamp>.yaml
#
# Prints the class name and exits:
#
#   0  sheet           `scorer: lab-scorer` + `categories:`. A sheet whose every cell is
#                      `score: null` IS a sheet — nulls are the contract working, not an
#                      absence of output. Score it.
#   1  usage/read error
#   2  off-contract    the scorer said something that is not the contract — a refusal, prose,
#                      a truncated sheet. EVIDENCE, not infrastructure: it is what this
#                      scorer did when handed this rubric. Record it, do not silently re-run.
#   3  empty           nothing after the provenance header at all. Ambiguous between an empty
#                      turn (infra) and wholesale undecidability (the finding), and the file
#                      cannot tell you which. Re-run ONCE; if the same rubric and fixture
#                      produce it again, it is a finding and not infrastructure.
#   4  fallback        opencode did not load lab-scorer and silently used the default agent.
#                      Infrastructure. Discard — a default-agent score looks exactly like a
#                      real one and would poison every comparison.
#   5  declared-error  `scorer: lab-scorer` + `error:` — the scorer's own contract for a
#                      rubric that is unreadable or has no categories. A statement about the
#                      RUBRIC, so it is a finding, and an unambiguous one.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

[ $# -eq 1 ] || { echo "usage: $0 <score-output.yaml>" >&2; exit 1; }

f="$1"
[ -r "$f" ] || { echo "cannot read: $f" >&2; exit 1; }

# Checked against the whole file, header included, and checked FIRST: a fallback run can
# emit something that parses as a sheet, and that sheet is the dangerous one.
if grep -q "Falling back to default agent" "$f"; then
  echo "fallback"
  exit 4
fi

# The body is everything after the provenance header's `---`. Test for the separator
# rather than for a non-empty result: a header followed by nothing is the `empty` class,
# and falling back to the whole file there would hide it behind its own provenance block.
if grep -q '^---$' "$f"; then
  body="$(awk 'seen { print } /^---$/ && !seen { seen = 1 }' "$f")"
else
  body="$(cat "$f")"
fi

if [ -z "${body//[[:space:]]/}" ]; then
  echo "empty"
  exit 3
fi

if printf '%s\n' "$body" | grep -q '^scorer: lab-scorer'; then
  if printf '%s\n' "$body" | grep -q '^categories:'; then
    echo "sheet"
    exit 0
  fi
  if printf '%s\n' "$body" | grep -q '^error:'; then
    echo "declared-error"
    exit 5
  fi
fi

echo "off-contract"
exit 2
