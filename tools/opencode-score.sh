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

# Absolute, so the path survives regardless of where opencode resolves attachments from.
RUBRIC_ABS="$(cd "$(dirname "$RUBRIC")" && pwd)/$(basename "$RUBRIC")"

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

# Attach every source file under the target. Keeps the scorer tool-free and makes the
# evidence set explicit rather than whatever the model chose to go looking for.
impl=()
while IFS= read -r f; do impl+=(-f "$f"); done < <(find "$TARGET" -type f \
  \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)

if [ ${#impl[@]} -eq 0 ]; then
  echo "no source files found under $TARGET" >&2
  exit 1
fi

echo "scoring $slug with $MODEL — $(( ${#impl[@]} / 2 )) source file(s) ..." >&2

# The prompt must precede -f: opencode's -f is a yargs array flag and will otherwise
# swallow the message as a filename.
# NO --dir. It repoints opencode's project root at the target, so `.opencode/agent/` is
# looked up inside the implementation under test, lab-scorer is not found, and opencode
# SILENTLY FALLS BACK to the default `build` agent — full tool access, none of the output
# contract — and still exits 0. The agent definition is Layer 3: it constrained nothing, and
# nothing told us it had been ignored. The guard below is the Layer 2 version of that wish.
#
# Source files are attached instead, so the scorer needs no filesystem tools at all.
opencode run --agent lab-scorer -m "$MODEL" \
  "Score the attached implementation against the attached rubric ($(basename "$RUBRIC")).
   The attachments are the COMPLETE evidence set — every source file under test is already
   attached. Do not look for other files; there are none, and you have no tools. Cite
   attachment filename:line as evidence. Emit score: null with reason: ambiguous for any
   category whose anchors do not let you separate two scores. YAML only — no preamble,
   nothing after the YAML." \
  -f "$RUBRIC_ABS" "${impl[@]}" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' >> "$out"

# PIPESTATUS[0], not $? — $? is sed's status, and sed always succeeds.
rc=${PIPESTATUS[0]}

# A missing agent is a WARNING to opencode and exit 0. Treat it as fatal: a score produced
# by the default agent looks exactly like a real one and would poison every comparison.
if grep -q "Falling back to default agent" "$out"; then
  echo "FATAL: lab-scorer was not loaded; opencode fell back to the default agent." >&2
  echo "The scores in $out are NOT contract-compliant. Discard them." >&2
  exit 1
fi

if [ $rc -ne 0 ]; then
  echo "opencode exited $rc — see $out" >&2
  exit 1
fi

# opencode exits 0 even when the model produced no scores — a rejected tool call, a refusal,
# an empty turn. Without this the script reports success and hands back a file containing an
# error message, which is exactly the shape of failure the agent-fallback guard above exists
# to stop. Require the contract's own markers before calling it a score.
if ! grep -q "^scorer: lab-scorer" "$out" || ! grep -q "^categories:" "$out"; then
  echo "FATAL: no contract-compliant YAML in the output — the scorer produced nothing usable." >&2
  echo "See $out for what it did instead." >&2
  exit 1
fi

echo "$out"
