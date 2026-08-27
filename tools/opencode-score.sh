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
#
# Exit codes carry the distinction between a broken run and an informative one, because
# collapsing them is how an experiment discards its own finding:
#
#   0  a sheet — score it. Every cell `null` still counts as a sheet
#   1  bad arguments, or opencode itself failed — infrastructure, discard
#   2  off contract — the scorer said something else. Evidence; read it
#   3  empty — nothing produced. Re-run once; a repeat is a finding
#   4  the default agent answered instead of lab-scorer — infrastructure, discard
#   5  the scorer declared the rubric unusable — a finding about the rubric
#
# tools/classify-model-output.sh owns that decision and documents each code.

set -uo pipefail
# `|| exit` matters here: without it a failed cd runs the review from the caller's
# directory, resolving artifact paths against the wrong tree and stamping the wrong shas.
cd "$(dirname "$0")/.." || exit 1

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

# THE GATE FILTER. This rubric scores only submissions that already cleared every gate —
# every "the gates own that" in its header depends on it, and the business case calls it the
# single most important rule. Until 2026-08-27 nothing enforced it: this script would score
# `known-bad-*` and hand back a number in the rubric's units that meant something else
# entirely. `lab-acceptance` rejected the rubric on that, blocking, and the rubric had
# already named the missing control on itself: "The L2 version is the scorer refusing a
# target that is not a registered gate-passing run_case; it does not exist."
#
# It exists now, and it reads the registry rather than keeping a second copy of it. The
# source of truth is `QUALITY_VARIANTS` in the benchmark's own `verify-evaluator.sh`, which
# CI already runs to prove every one of them still exits 0. A copy here would drift silently;
# reading theirs makes drift a hard failure instead.
#
# FAILS CLOSED. An unreachable registry stops the run. A scorer that falls back to "score it
# anyway" when it cannot find the rules is the same control as no control.
REGISTRY="${LAB_SCORE_REGISTRY:-$(cd "$TARGET/../.." 2>/dev/null && pwd)/verify-evaluator.sh}"
if [ ! -r "$REGISTRY" ]; then
  echo "cannot read the gate-passing registry: $REGISTRY" >&2
  echo "Set LAB_SCORE_REGISTRY to the benchmark's verify-evaluator.sh. Refusing to score" >&2
  echo "without it — a number computed on an unregistered target is a different" >&2
  echo "measurement wearing this rubric's units." >&2
  exit 1
fi

allowed="known-good $(sed -n 's/^QUALITY_VARIANTS=(\(.*\))$/\1/p' "$REGISTRY")"
case " $allowed " in
  *" $(basename "$TARGET") "*) ;;
  *)
    echo "FATAL: $(basename "$TARGET") is not a registered gate-passing variant." >&2
    echo "Registered: $allowed" >&2
    echo "This rubric only scores submissions that cleared every gate. A score on a" >&2
    echo "gate-failing submission is not a weaker result — it is a different measurement" >&2
    echo "wearing this one's units, and comparing the two is the mistake the business case" >&2
    echo "calls its single most important rule. Registry: $REGISTRY" >&2
    exit 1 ;;
esac

# THE BASELINE. E-001 Decision B, 2026-08-27: `change-focus` asks whether methods the ticket
# did not name were restyled, which is a statement about a change, and one tree is not a
# change. The baseline makes the anchor citable at path:line in both trees.
#
# It was decided, written into the experiment record and the worksheet as though the script
# already did it, and the script did not. Two documents asserted an attachment set the
# instrument never assembled — the failure the worksheet warns about six lines earlier in its
# own text: "Not built. Do not describe it as if it were."
#
# ASYMMETRY, ON THE RECORD RATHER THAN HIDDEN. `known-good` is the baseline, so when it is
# the target there is nothing to compare it against and it is scored on its own files alone.
# Its cells are therefore NOT drawn from the same evidence set as the other five fixtures'.
# The provenance header records which case a run was, so the asymmetry is provable per run
# instead of remembered.
BASELINE="${LAB_SCORE_BASELINE:-$(dirname "$TARGET")/known-good}"
baseline_state="attached"
if [ "$(cd "$TARGET" && pwd)" = "$(cd "$BASELINE" 2>/dev/null && pwd || echo /nonexistent)" ]; then
  BASELINE=""
  baseline_state="none — the target IS the baseline; its cells see one tree, the others see two"
elif [ ! -d "$BASELINE" ]; then
  echo "baseline not found: $BASELINE" >&2
  echo "E-001 Decision B requires it. Set LAB_SCORE_BASELINE, or fix the path — scoring" >&2
  echo "without it silently produces a different measurement from the registered one." >&2
  exit 1
fi

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
  echo "  baseline:      ${BASELINE:-null}"
  echo "  baseline_state: $baseline_state"
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

base=()
if [ -n "$BASELINE" ]; then
  while IFS= read -r f; do base+=(-f "$f"); done < <(find "$BASELINE" -type f \
    \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)
  if [ ${#base[@]} -eq 0 ]; then
    echo "no source files found under the baseline $BASELINE" >&2
    exit 1
  fi
fi

echo "scoring $slug with $MODEL — $(( ${#impl[@]} / 2 )) source file(s), \
$(( ${#base[@]} / 2 )) baseline file(s) ..." >&2

# The prompt must precede -f: opencode's -f is a yargs array flag and will otherwise
# swallow the message as a filename.
# NO --dir. It repoints opencode's project root at the target, so `.opencode/agent/` is
# looked up inside the implementation under test, lab-scorer is not found, and opencode
# SILENTLY FALLS BACK to the default `build` agent — full tool access, none of the output
# contract — and still exits 0. The agent definition is Layer 3: it constrained nothing, and
# nothing told us it had been ignored. The guard below is the Layer 2 version of that wish.
#
# Source files are attached instead, so the scorer needs no filesystem tools at all.
# Naming which tree is which is a strong hint, and a registered cost of Decision B: the
# scorer is told where the reference is, so `architecture-consistency` and `maintainability`
# may become spot-the-difference. That is why prediction 3 exists. Not naming them is worse
# — the scorer would have two trees and no way to tell the work from the reference.
if [ -n "$BASELINE" ]; then
  baseline_note="Files under $BASELINE are the BASELINE submission — the reference the work
   under test is read against, NOT the work itself. Files under $TARGET are the work under
   test. Score only the work under test."
else
  baseline_note="There is no baseline in this run: the target IS the reference submission.
   Any category whose anchors require comparing against a baseline is undecidable here —
   emit score: null with reason: ambiguous rather than scoring it against itself."
fi

opencode run --agent lab-scorer -m "$MODEL" \
  "Score the attached implementation against the attached rubric ($(basename "$RUBRIC")).
   $baseline_note
   The attachments are the COMPLETE evidence set — every source file is already attached.
   Do not look for other files; there are none, and you have no tools. Cite attachment
   filename:line as evidence. Emit score: null with reason: ambiguous for any category
   whose anchors do not let you separate two scores. YAML only — no preamble, nothing
   after the YAML." \
  -f "$RUBRIC_ABS" "${impl[@]}" "${base[@]+"${base[@]}"}" 2>&1 | sed $'s/\x1b\\[[0-9;]*m//g' >> "$out"

# PIPESTATUS[0], not $? — $? is sed's status, and sed always succeeds.
rc=${PIPESTATUS[0]}

# opencode exiting non-zero is the one unambiguous infrastructure failure: the process
# itself did not complete, so there is nothing to classify.
if [ $rc -ne 0 ]; then
  echo "opencode exited $rc — infrastructure, discard and re-run. See $out" >&2
  exit 1
fi

# Everything else is a question about what the SCORER did, and that question has more than
# one answer. It used to have one: any output that was not a sheet exited 1 alongside a
# crash, and E-001's Exclusions then told the reader to re-run it as infrastructure —
# discarding the wholesale-null outcome that is the experiment's most informative result.
# The classifier is where that distinction now executes; its header documents each code.
class="$(./tools/classify-model-output.sh score "$out")"
cls=$?

case $cls in
  0) ;;   # a sheet — including one whose every cell is null. That is a result, not an absence.
  4) echo "FATAL [$class]: lab-scorer was not loaded; opencode fell back to the default agent." >&2
     echo "The scores in $out are NOT contract-compliant. Infrastructure — discard." >&2
     exit 4 ;;
  3) echo "EMPTY [$class]: the scorer produced nothing after the provenance header." >&2
     echo "Ambiguous: an empty turn, or the rubric being wholesale undecidable. The file" >&2
     echo "cannot tell you which. Re-run ONCE on the same rubric and fixture; a repeat is a" >&2
     echo "finding and must be recorded, not discarded. See $out" >&2
     exit 3 ;;
  5) echo "DECLARED ERROR [$class]: the scorer reports the rubric is unusable. This is a finding" >&2
     echo "about the rubric, not infrastructure — record it. See $out" >&2
     exit 5 ;;
  *) echo "OFF CONTRACT [$class]: the scorer produced output that is not the sheet — a refusal," >&2
     echo "prose, or a truncated sheet. This is what it did with this rubric, so it is" >&2
     echo "evidence. Read it before re-running. See $out" >&2
     exit 2 ;;
esac

echo "$out"
