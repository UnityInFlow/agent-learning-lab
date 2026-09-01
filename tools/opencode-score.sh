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
#   ./tools/opencode-score.sh benchmark/rubrics/backend-quality.yaml --run-id <run-id>
#
#   LAB_REVIEW_MODEL=opencode-go/glm-5.3 ./tools/opencode-score.sh rubric.yaml <dir>
#
# PATH B — added 2026-09-01, and it closes a gap this repo's CLAUDE.md named on itself:
# "opencode-score.sh has NO run path — Decision C makes codex the scorer, so B2 does not
# need one, and a cross-harness check on B2 is therefore not currently possible."
#
# It is possible now. DECISION C IS UNTOUCHED: codex remains B2's registered scorer and
# produces the experiment's numbers. This is the second reader, which is exactly what B1
# had and B2 did not — and the distance between two harnesses' sheets is the only thing
# that can tell a rubric defect from a model quirk.
#
# It also removes a single point of failure that FAILED. On 2026-09-01 codex hit its usage
# limit mid-session; with codex the only run-scoring path, B2 was unscoreable for three
# hours. Two paths is not redundancy for its own sake — see the harness table in CLAUDE.md.
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

# Path B takes --run-id, NEVER a directory plus a "this passed" flag. A flag is a promise
# by the caller, which is Layer 3 wearing Layer 2's clothes, and `--dir X --run-id Y` lets
# the two disagree. Resolving the directory FROM the id makes the mismatch unrepresentable.
# Same shape as codex-score.sh, deliberately: two scorers that admit targets by different
# rules are not scoring the same population.
MODE=fixture
RUN_ID=""
OBS_API="${LAB_OBSERVATORY_API:-http://localhost:8081}"

if [ $# -eq 3 ] && [ "$2" = "--run-id" ]; then
  MODE=run; RUBRIC="$1"; RUN_ID="$3"; TARGET=""
elif [ $# -eq 2 ]; then
  RUBRIC="$1"; TARGET="$2"
else
  echo "usage: $0 <rubric.yaml> <implementation-dir>" >&2
  echo "       $0 <rubric.yaml> --run-id <observatory-run-id>" >&2
  exit 1
fi

[ -r "$RUBRIC" ] || { echo "cannot read rubric: $RUBRIC" >&2; exit 1; }

if [ "$MODE" = run ]; then
  # The runner names the worktree after the run id, so the directory is derived rather than
  # supplied and cannot disagree with the record fetched below.
  TARGET="${TMPDIR:-/tmp}/observatory-run-${RUN_ID}"
  [ -d "$TARGET" ] || {
    echo "no worktree at $TARGET" >&2
    echo "run-agent.sh deletes the worktree at step 12 unless it was given --keep." >&2
    echo "A run scored from a deleted worktree is not something this can reconstruct." >&2
    exit 1; }
  [ -d "$TARGET/.git" ] || {
    echo "$TARGET is not a git worktree; cannot derive what changed" >&2; exit 1; }
fi

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
#
# PATH B uses a different proof of the SAME invariant, and that difference is the whole of
# Decision D: a run has no fixture name to look up, so the proof is the evaluator's own
# recorded verdict. The invariant does not move — only gate-passing submissions get scored.
# An unevaluated run is refused, because "no verdict" is not "passed".
EVAL_EXIT=""
if [ "$MODE" = run ]; then
  rundoc="$(mktemp)"
  curl -fsS "${OBS_API}/api/runs/${RUN_ID}" -o "$rundoc" 2>/dev/null || {
    rm -f "$rundoc"
    echo "cannot read run ${RUN_ID} from ${OBS_API}" >&2
    echo "Set LAB_OBSERVATORY_API if the API is elsewhere. Refusing to score a run whose" >&2
    echo "gate result cannot be established." >&2; exit 1; }
  # Fetching and deciding are split so the decision stays testable without a live API —
  # verify-run-gate-checker.sh proves the gate on 13 cases and never touches the network.
  # Reported against the RUN, not the temp file it landed in: a refusal naming
  # /tmp/tmp.0k9HO4 tells the reader nothing about which run was refused.
  gate_out="$(./tools/check-run-gate.sh "$rundoc" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "$gate_out" | sed "s|$rundoc|run ${RUN_ID} at ${OBS_API}|g" >&2
    rm -f "$rundoc"; exit "$rc"
  fi
  EVAL_EXIT="$(jq -r '(.evaluation // .).exitCode' "$rundoc" 2>/dev/null)"
  rm -f "$rundoc"
fi

REGISTRY="${LAB_SCORE_REGISTRY:-$(cd "$TARGET/../.." 2>/dev/null && pwd)/verify-evaluator.sh}"
if [ "$MODE" = fixture ] && [ ! -r "$REGISTRY" ]; then
  echo "cannot read the gate-passing registry: $REGISTRY" >&2
  echo "Set LAB_SCORE_REGISTRY to the benchmark's verify-evaluator.sh. Refusing to score" >&2
  echo "without it — a number computed on an unregistered target is a different" >&2
  echo "measurement wearing this rubric's units." >&2
  exit 1
fi

if [ "$MODE" = fixture ]; then
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
fi

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
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if [ "$MODE" = run ]; then
  # DECISION D. A B1 fixture is "the files that DIFFER from a clean baseline, in full" — the
  # benchmarks repo's own definition. A run's diff is the same object, so B2 attaches the
  # files the agent changed, in full, against those same files as they were BEFORE the agent
  # ran. Same rule as B1 applied to a run, so B1 and B2 sheets stay comparable by
  # construction rather than by a caveat someone has to remember.
  #
  # NOT the whole worktree, and the reason is not tidiness. sample-service already ships
  # ShipmentControllerTest.kt, so attaching all 25 files would put a test file among the
  # attachments on EVERY run — and `test-quality`'s precondition ("no file under src/test/
  # among the attachments -> null") could then never fire. Decision A would be silently
  # disabled between B1 and B2 while the sheet kept reporting the same units.
  BASELINE="$tmp/baseline"
  baseline_state="pre-agent HEAD of the changed files (Decision D); new files have no baseline side"
else
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
fi

mkdir -p "$OUTDIR"
stamp=$(date -u +%Y%m%dT%H%M%SZ)
slug=$(basename "$TARGET")
out="$OUTDIR/score-$slug-$stamp.yaml"


# Attach every source file under the target. Keeps the scorer tool-free and makes the
# evidence set explicit rather than whatever the model chose to go looking for.
impl=()
base=()

if [ "$MODE" = run ]; then
  # Tracked modifications plus new untracked files. run-agent.sh builds the agent's repo with
  # git archive + git init and asserts a single commit, so HEAD is unambiguously the
  # pre-agent state and "changed" needs no further definition.
  changed=$( { git -C "$TARGET" diff --name-only HEAD;
               git -C "$TARGET" ls-files --others --exclude-standard; } 2>/dev/null \
             | grep -E '\.(kt|java|xml|ya?ml)$' | sort -u )
  [ -n "$changed" ] || {
    echo "the agent changed no source file in $TARGET" >&2
    echo "There is no submission to score. That is a result about the run, and the" >&2
    echo "evaluator will have recorded it — it is not a scoring failure." >&2; exit 1; }
  mkdir -p "$BASELINE"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    impl+=(-f "$TARGET/$rel")
    # A file the agent CREATED has no pre-agent side. Absent from the baseline set is the
    # honest representation of that; inventing an empty file would read as "it existed and
    # was blank", which is a different claim.
    if git -C "$TARGET" cat-file -e "HEAD:$rel" 2>/dev/null; then
      dst="$BASELINE/$rel"; mkdir -p "$(dirname "$dst")"
      git -C "$TARGET" show "HEAD:$rel" > "$dst" 2>/dev/null && base+=(-f "$dst")
    fi
  done <<< "$changed"
  # Every changed file is new, so there is nothing to read a change against. Say so in the
  # provenance rather than leaving a directory that exists and is empty.
  [ ${#base[@]} -gt 0 ] || {
    BASELINE=""
    baseline_state="none — every changed file is NEW; no pre-agent side exists to compare"; }
else
  while IFS= read -r f; do impl+=(-f "$f"); done < <(find "$TARGET" -type f \
    \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)

  if [ ${#impl[@]} -eq 0 ]; then
    echo "no source files found under $TARGET" >&2
    exit 1
  fi

  if [ -n "$BASELINE" ]; then
    while IFS= read -r f; do base+=(-f "$f"); done < <(find "$BASELINE" -type f \
      \( -name '*.kt' -o -name '*.java' -o -name '*.xml' -o -name '*.yaml' -o -name '*.yml' \) | sort)
    if [ ${#base[@]} -eq 0 ]; then
      echo "no source files found under the baseline $BASELINE" >&2
      exit 1
    fi
  fi
fi

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
  echo "  mode:          $MODE"
  if [ "$MODE" = run ]; then
    echo "  run_id:        $RUN_ID"
    echo "  evaluator_exit: ${EVAL_EXIT:-null}"
    echo "  observatory:   ${OBS_API}/api/runs/${RUN_ID}"
  fi
  echo "  baseline:      ${BASELINE:-null}"
  echo "  baseline_state: $baseline_state"
  echo "  scored_utc:    $stamp"
  echo "  attachments:   $(( ${#impl[@]} / 2 )) file(s) under test, $(( ${#base[@]} / 2 )) with a baseline side"
  echo "  session:       fresh    # never --continue; independence requires no memory"
  echo "---"
} > "$out"

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
if [ "$MODE" = run ] && [ -n "$BASELINE" ]; then
  baseline_note="Files under $BASELINE are the PRE-AGENT versions of the files the agent
   changed — the state of the repository before it ran, and the reference a change is read
   against. Files under $TARGET are the work under test. Score only the work under test.
   Only changed files are attached, by design; a file you cannot see was not touched."
elif [ "$MODE" = run ]; then
  baseline_note="The agent CREATED every file attached; none existed before it ran, so there
   is no earlier version to read a change against. Any category whose anchors require
   comparing against a baseline is undecidable here — emit score: null with
   reason: ambiguous rather than inventing one."
elif [ -n "$BASELINE" ]; then
  baseline_note="Files under $BASELINE are the BASELINE submission — the reference the work
   under test is read against, NOT the work itself. Files under $TARGET are the work under
   test. Score only the work under test."
else
  baseline_note="There is no baseline in this run: the target IS the reference submission.
   Any category whose anchors require comparing against a baseline is undecidable here —
   emit score: null with reason: ambiguous rather than scoring it against itself."
fi


# BOUNDED. `opencode run` fails to return on a fraction of non-interactive calls,
# independent of model and project, and never times out on its own. Unbounded, a stall here
# hangs the scorer forever and leaves a process holding the API call — three such processes
# survived twelve to fourteen days on this machine before being found by hand.
#
# macOS ships no timeout(1) and none is installed here, hence the poll. The child is killed
# with its PROCESS GROUP: killing the wrapper alone leaves opencode itself running. Same
# mechanism as tools/opencode-review.sh, which has had it since 2026-08-27.
SCORE_TIMEOUT="${LAB_SCORE_TIMEOUT:-900}"

run_limited() {   # <seconds> <rcfile> -- <command...>
  local secs="$1" rcfile="$2"; shift 3
  set -m
  ( "$@"; echo "${PIPESTATUS[0]:-$?}" > "$rcfile" ) &
  local pid=$! waited=0
  set +m
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$secs" ]; then
      kill -TERM "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null
      sleep 3
      kill -KILL "-$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null
      return 124
    fi
    sleep 2; waited=$((waited + 2))
  done
  wait "$pid" 2>/dev/null
  return 0
}

# Built in the parent: the prompt interpolates $baseline_note and the rubric basename, which
# would not expand inside the single-quoted bash -c body.
score_prompt="Score the attached implementation against the attached rubric ($(basename "$RUBRIC")).
   $baseline_note
   The attachments are the COMPLETE evidence set — every source file is already attached.
   Do not look for other files; there are none, and you have no tools. Cite attachment
   filename:line as evidence. Emit score: null with reason: ambiguous for any category
   whose anchors do not let you separate two scores. YAML only — no preamble, nothing
   after the YAML."

# ASSEMBLE AND STOP, the same escape hatch codex-score.sh has and for the same reason: B2
# needs to inspect the exact evidence set before committing runs to it, and "read the script
# and imagine the attachments" is how an attachment-set mistake survives to the batch. This
# is what answered RUNBOOK §0.5 without spending a run. Not a gate bypass — every check above
# has already run, it produces no sheet, and it exits 3.
if [ -n "${LAB_SCORE_DRY_RUN:-}" ]; then
  {
    echo "# DRY RUN — the prompt and the exact attachment set. Nothing was scored."
    echo "# mode=$MODE target=$TARGET"
    echo
    echo "$score_prompt"
    echo
    echo "## Attachments, in the order opencode receives them"
    echo
    echo "rubric (-f): $RUBRIC_ABS"
    for f in "${impl[@]}" ${base[@]+"${base[@]}"}; do
      [ "$f" = "-f" ] && continue
      echo "  $f"
    done
  } > "${LAB_SCORE_DRY_RUN}" 2>/dev/null \
    || { echo "cannot write ${LAB_SCORE_DRY_RUN}" >&2; exit 1; }
  echo "DRY RUN — nothing scored. $(( ${#impl[@]} / 2 )) file(s) under test, \
$(( ${#base[@]} / 2 )) baseline. Written to ${LAB_SCORE_DRY_RUN}" >&2
  rm -f "$out"
  exit 3
fi

score_rcfile="$(mktemp -t lab-score-rc)"
run_limited "$SCORE_TIMEOUT" "$score_rcfile" -- bash -c '
  opencode run --agent lab-scorer -m "$1" "$2" \
    -f "$3" "${@:5}" 2>&1 | sed $'"'"'s/\x1b\\[[0-9;]*m//g'"'"' >> "$4"
  exit "${PIPESTATUS[0]}"
' _ "$MODEL" "$score_prompt" "$RUBRIC_ABS" "$out" "${impl[@]}" "${base[@]+"${base[@]}"}"
limit_rc=$?

# A STALL IS NOT AN EMPTY RESULT. Unhandled, a killed run leaves a header-only file that
# classify-model-output.sh reads as code 3 (EMPTY) — and EMPTY is a finding about the
# RUBRIC being wholesale undecidable, which is E-001's most informative outcome. Reporting
# a harness hang as that outcome would manufacture the experiment's headline result.
if [ "$limit_rc" = 124 ]; then
  rm -f "$score_rcfile"
  echo "STALLED after ${SCORE_TIMEOUT}s — opencode never returned and was killed with its" >&2
  echo "process group. This is INFRASTRUCTURE, not a finding: discard and re-run. It is NOT" >&2
  echo "an empty result and must not be recorded as one. See $out" >&2
  exit 1
fi

rc="$(cat "$score_rcfile" 2>/dev/null || echo 1)"
rm -f "$score_rcfile"

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

# classify-model-output.sh asks whether a `categories:` key is present. It cannot ask what is
# under it, because it is not given the rubric. So a sheet carrying three of the rubric's
# four categories classified as `contract` and was written to findings/ looking complete.
# A missing cell is not a null cell: `null` is a measurement, an absence is not, and E-001's
# dependent variable is a ratio whose denominator is the cell count.
if ! ./tools/check-sheet-categories.sh "$RUBRIC" "$out" >/dev/null; then
  ./tools/check-sheet-categories.sh "$RUBRIC" "$out" >&2
  echo "OFF CONTRACT: the sheet's category set is not the rubric's. Read it before" >&2
  echo "re-running — this is what the scorer did with this rubric. See $out" >&2
  exit 2
fi

echo "$out"
