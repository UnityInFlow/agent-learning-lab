#!/usr/bin/env bash
# Independent second scoring of an implementation against a rubric.
#
# This is the instrument for Lab B1.1 — "does the same task, scored twice, produce the
# same score?" You cannot answer that alone; scoring your own work twice measures your
# consistency, not the rubric's. This runs a different model family against the same
# rubric so the gap between the two sheets is real evidence.
#
#   ./tools/opencode-score.sh benchmark/rubrics/backend-quality.yaml \
#       ../agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/fixtures/known-good
#
#   LAB_REVIEW_MODEL=opencode-go/glm-5.3 ./tools/opencode-score.sh rubric.yaml <dir>
#
# Writes findings/opencode/score-<fixture>-<timestamp>.yaml with a provenance header.
#
# Score the fixture YOURSELF FIRST, and do not read this output until you have. Reading it
# first is how you get agreement that means nothing.
#
# Every run is a fresh session — never --continue. A scorer that remembers its last sheet
# is not an independent second scorer.
# Exit 1 on bad arguments or an opencode failure.

set -uo pipefail
cd "$(dirname "$0")/.."

MODEL="${LAB_REVIEW_MODEL:-ollama-cloud/deepseek-v4-pro}"
OUTDIR="findings/opencode"

if [ $# -ne 2 ]; then
  echo "usage: $0 <rubric.yaml> <implementation-dir>" >&2
  exit 1
fi

RUBRIC="$1"
TARGET="$2"

[ -r "$RUBRIC" ] || { echo "cannot read rubric: $RUBRIC" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }

mkdir -p "$OUTDIR"
stamp=$(date -u +%Y%m%dT%H%M%SZ)
slug=$(basename "$TARGET")
out="$OUTDIR/score-$slug-$stamp.yaml"

{
  echo "# provenance — this block is data, not decoration."
  echo "# An unpinned scorer model is an unregistered variable. That is the Phase 0A lesson."
  echo "provenance:"
  echo "  scorer:        lab-scorer"
  echo "  model:         $MODEL"
  echo "  opencode:      $(opencode --version 2>/dev/null | tail -1)"
  echo "  agent_sha:     $(shasum -a 256 .opencode/agent/lab-scorer.md | cut -c1-12)"
  echo "  rubric_path:   $RUBRIC"
  echo "  rubric_sha:    $(shasum -a 256 "$RUBRIC" | cut -c1-12)"
  echo "  target:        $TARGET"
  echo "  scored_utc:    $stamp"
  echo "  session:       fresh    # never --continue; independence requires no memory"
  echo "---"
} > "$out"

echo "scoring $slug with $MODEL ..." >&2

# The prompt must precede -f: opencode's -f is a yargs array flag and will otherwise
# swallow the message as a filename.
opencode run --agent lab-scorer -m "$MODEL" --dir "$TARGET" \
  "Score the implementation in the working directory against the attached rubric.
   Read the source before scoring; cite path:line as evidence. Emit score: null with
   reason: ambiguous for any category whose anchors do not let you separate two scores.
   YAML only — no preamble, nothing after the YAML." \
  -f "$RUBRIC" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' >> "$out"

# PIPESTATUS[0], not $? — $? is sed's status, and sed always succeeds.
rc=${PIPESTATUS[0]}
if [ $rc -ne 0 ]; then
  echo "opencode exited $rc — see $out" >&2
  exit 1
fi

echo "$out"
