#!/usr/bin/env bash
# What did the model actually produce? One exit code per outcome, per output contract,
# because "nothing" was five different things wearing one word.
#
#   ./tools/classify-model-output.sh score      findings/opencode/score-known-good-<stamp>.yaml
#   ./tools/classify-model-output.sh critic     <raw line-level output>
#   ./tools/classify-model-output.sh acceptance <raw acceptance output>
#
# WHY THIS EXISTS. E-001 asks whether a rubric can decide anything, and its most informative
# possible result is the scorer failing to produce a sheet — which has already happened: a
# seven-category rubric whose anchors cited things the scorer could not see made it "emit an
# empty body. Not a bad score. Nothing." The guard this replaces called that
# `FATAL ... produced nothing usable` and exited 1, the same code it used for opencode
# crashing, and the experiment's Exclusions then told the reader to re-run it as
# infrastructure. The harness discarded the phenomenon under test and labelled it a broken
# script. `lab-acceptance` rejected the record on exactly this, blocking, 2026-08-27.
#
# THREE CONTRACTS, ONE SET OF CODES. The three agents in .opencode/agent/ have different
# output contracts but the same failure modes, and opencode-review.sh had no equivalent of
# this check at all — a line-level pass that returned nothing would have written a header,
# built an empty recurrence table and exited 0.
#
#   score       lab-scorer     `scorer: lab-scorer` + `categories:`  (or `error:`)
#   critic      lab-critic     at least one `**Verdict:**` line
#   acceptance  lab-acceptance `acceptance:` + a `verdict:` line
#
# Two of these codes mean the run is infrastructure and must be discarded; three mean the
# model did something, and the run is evidence.
#
#   0  contract        the contract was met. For `score` that includes a sheet whose every
#                      cell is `score: null` — nulls are the contract working, not an
#                      absence of output. Use it.
#   1  usage/read error
#   2  off-contract    the model said something that is not the contract — a refusal, prose,
#                      a truncated answer. EVIDENCE, not infrastructure: it is what this
#                      model did when handed this input. Record it, do not silently re-run.
#   3  empty           nothing at all. Ambiguous between an empty turn (infra) and wholesale
#                      undecidability (the finding), and the file cannot tell you which.
#                      Re-run ONCE on the same input; a repeat is a finding.
#   4  fallback        opencode did not load the agent and silently used the default one.
#                      Infrastructure. Discard — a default-agent answer looks exactly like a
#                      real one and would poison every comparison.
#   5  declared-error  the agent's own contract for an input it cannot use. A statement about
#                      the INPUT, so a finding, and an unambiguous one. `score` only.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

[ $# -eq 2 ] || { echo "usage: $0 <score|critic|acceptance> <file>" >&2; exit 1; }

contract="$1"
f="$2"

case "$contract" in
  score|critic|acceptance) ;;
  *) echo "unknown contract: $contract (expected score, critic or acceptance)" >&2; exit 1 ;;
esac
[ -r "$f" ] || { echo "cannot read: $f" >&2; exit 1; }

# Checked against the whole file, header included, and checked FIRST: a fallback run can
# emit something that parses as the contract, and that is the dangerous one.
if grep -q "Falling back to default agent" "$f"; then
  echo "fallback"
  exit 4
fi

# The body is everything after a provenance header's `---`, when there is one. Test for the
# separator rather than for a non-empty result: a header followed by nothing is the `empty`
# class, and falling back to the whole file there would hide it behind its own header.
if grep -q '^---$' "$f"; then
  body="$(awk 'seen { print } /^---$/ && !seen { seen = 1 }' "$f")"
else
  body="$(cat "$f")"
fi

if [ -z "${body//[[:space:]]/}" ]; then
  echo "empty"
  exit 3
fi

has() { printf '%s\n' "$body" | grep -qE "$1"; }

case "$contract" in
  score)
    if has '^scorer: lab-scorer'; then
      if has '^categories:'; then echo "contract"; exit 0; fi
      if has '^error:';      then echo "declared-error"; exit 5; fi
    fi
    ;;
  critic)
    # One section with a verdict is the minimum a line-level pass can be. Fewer sections
    # than the artifact has is under-reporting, which is a finding about the critic and not
    # something this classifier can see.
    if has '^\*\*Verdict:\*\*'; then echo "contract"; exit 0; fi
    ;;
  acceptance)
    if has '^[[:space:]]*acceptance:' && has '^[[:space:]]*verdict:'; then
      echo "contract"; exit 0
    fi
    ;;
esac

echo "off-contract"
exit 2
