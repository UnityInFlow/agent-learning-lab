#!/usr/bin/env bash
# Adversarial review of a lab artifact by a second, non-Claude model.
#
# The point is independence. Claude wrote nothing here and neither did you — the reviewer
# is a different model family (opencode-go / ollama-cloud are the authenticated providers),
# so its disagreement is not correlated with the author's blind spots.
#
#   ./tools/opencode-review.sh benchmark/rubrics/backend-quality.yaml
#   ./tools/opencode-review.sh rubric.yaml ../agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/task.md
#   LAB_REVIEW_MODEL=opencode-go/glm-5.3 ./tools/opencode-review.sh rubric.yaml
#
# Writes findings/opencode/review-<artifact>-<timestamp>.md with a provenance header.
#
# The reviewer model is a registered variable. Changing it mid-experiment invalidates
# every comparison that spans the change — the header exists so you can prove you did not.
# Exit 1 if opencode fails or no artifact was given.

set -uo pipefail
cd "$(dirname "$0")/.."

MODEL="${LAB_REVIEW_MODEL:-ollama-cloud/deepseek-v4-pro}"
OUTDIR="findings/opencode"

if [ $# -eq 0 ]; then
  echo "usage: $0 <artifact> [more-artifacts...]" >&2
  exit 1
fi

for f in "$@"; do
  [ -r "$f" ] || { echo "cannot read: $f" >&2; exit 1; }
done

mkdir -p "$OUTDIR"
stamp=$(date -u +%Y%m%dT%H%M%SZ)
slug=$(basename "$1" | sed 's/\.[^.]*$//')
out="$OUTDIR/review-$slug-$stamp.md"

attach=()
for f in "$@"; do attach+=(-f "$f"); done

{
  echo "# opencode review — $slug"
  echo
  echo '```yaml'
  echo "reviewer:        lab-critic"
  echo "model:           $MODEL          # registered variable — do not change mid-experiment"
  echo "opencode:        $(opencode --version 2>/dev/null | tail -1)"
  echo "agent_sha:       $(shasum -a 256 .opencode/agent/lab-critic.md | cut -c1-12)"
  echo "reviewed_utc:    $stamp"
  echo "artifacts:"
  for f in "$@"; do
    echo "  - path: $f"
    echo "    sha:  $(shasum -a 256 "$f" | cut -c1-12)"
  done
  echo "lab_head:        $(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
  echo "lab_dirty:       $([ -n "$(git status --porcelain 2>/dev/null)" ] && echo true || echo false)"
  echo '```'
  echo
} > "$out"

echo "reviewing $# artifact(s) with $MODEL ..." >&2

# The prompt must precede -f: opencode's -f is a yargs array flag and will otherwise
# swallow the message as a filename.
opencode run --agent lab-critic -m "$MODEL" \
  "Review the attached artifact(s) against your output contract. Work through every
   section in the artifact's own order. Remember: a finding needs a concrete failure
   scenario, 'no finding' is a valid verdict, and you must not supply replacement text." \
  "${attach[@]}" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' >> "$out"

# PIPESTATUS[0], not $? — $? is sed's status, and sed always succeeds.
rc=${PIPESTATUS[0]}
if [ $rc -ne 0 ]; then
  echo "opencode exited $rc — see $out" >&2
  exit 1
fi

echo "$out"
