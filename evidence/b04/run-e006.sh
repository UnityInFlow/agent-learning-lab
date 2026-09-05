#!/usr/bin/env bash
# E-006, the B4 batch: 10 treatment + 10 control on BE-003, INTERLEAVED.
#
#   ./evidence/b04/run-e006.sh            # the full batch
#   PAIRS=1 ./evidence/b04/run-e006.sh    # one pair, for a smoke check
#
# INTERLEAVED, NOT ARM-AT-A-TIME. Ten treatment runs followed by ten control runs measures
# the treatment plus whatever else moved between the two blocks — a machine that got busier,
# a runtime that auto-updated, an API that degraded. Alternating puts that drift on both
# arms equally. It is also why the control is run TODAY rather than read out of B3's stored
# runs: "vs B3" means vs the condition B3 left behind, and B3 closed REJECT with
# instructions-v0.1 removed and not replaced, so that condition is the plain baseline.
#
# ONE FLAG ARRAY, BOTH ARMS. blocked_on_author item C: flags are not on the run record, so
# "the same flags were passed to every arm" is L3 — a sentence, not a control. It is still
# L3 here. What this file adds is that the sentence is now DIFFABLE: both arms are launched
# from ARM_COMMON below, and the only difference between them is the two lines under
# `treatment`. A reader can check the claim by reading twenty lines instead of trusting a
# summary. That is weaker than a record and stronger than a claim, and it is the same
# arrangement stop 9's run-e005.sh used.
#
# EXIT 9 STOPS THE BATCH. run-agent.sh exits 9 when the tool schema the runtime delivered is
# not the one the overlay declares — decision-rule row 0a, the treatment did not arrive.
# Continuing past it would spend the remaining runs on an arm that is secretly a baseline
# and then report the batch at full n. Every other non-zero exit is a run outcome (the
# evaluator's verdict) and is recorded, never swallowed: an arm that fails the gate more
# often IS a result.
#
# WHAT THIS SCRIPT DOES NOT DECIDE. It runs and records. Scoring, the gate, the medians and
# the verdict are §4 steps 7-11 and are not automated here, deliberately: a driver that also
# scored would let a batch be re-run until the number looked right.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

# KEEP THE MACHINE AWAKE FOR THE WHOLE BATCH. Batch 1 (08:33:11Z-09:08:29Z, 2026-09-05) ran
# across THREE idle sleeps - 08:41:58Z, 08:55:03Z and 09:04:11Z - and two of its five
# gate-passing runs span one. PROMPT §4 step 6 says do not run across a machine sleep, and
# E-006 exclusion 2 then costs those runs their duration, which is a registered outcome. A
# sentence telling the operator to disable sleep is L3; this is the L2 version, and it covers
# the batch rather than the session that launched it.
if command -v caffeinate >/dev/null 2>&1 && [[ "${E006_CAFFEINATED:-0}" != "1" ]]; then
  echo "run-e006: re-executing under caffeinate -i so the batch cannot span an idle sleep"
  E006_CAFFEINATED=1 exec caffeinate -i "$0" "$@"
fi
[[ "${E006_CAFFEINATED:-0}" == "1" ]] \
  || echo "run-e006: WARNING - caffeinate is unavailable, so an idle sleep can still contaminate durations" >&2

LAB="$(pwd)"
OBS="$(cd "$LAB/../agent-observatory" && pwd)"

PAIRS="${PAIRS:-10}"
EXPERIMENT_KEY="${EXPERIMENT_KEY:-EXP-B4-AGENT-BOUNDARY}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b04/batch-$STAMP"
ISD="$LAB/evidence/b04/init-schema"
mkdir -p "$EVID" "$ISD" || exit 1
MANIFEST="$EVID/manifest.tsv"

# --- the registered variables, asserted before the first run, not after ----
# Every one of these is a controlled variable in E-006. Checking them here means a drift is
# a refusal to start rather than a footnote discovered during analysis.
OVERLAY_DIR="$LAB/build/customizations/agent-v1.0"
OVERLAY_FILE="$OVERLAY_DIR/.claude/agents/backend-feature-implementer.md"
EXPECT_OVERLAY_HASH="59c2b5db71f4c01e22a51589a1febdf9"
EXPECT_BENCH_SHA="0448643"
EXPECT_MODEL="claude-haiku-4-5-20251001"
EXPECT_CLAUDE="${EXPECT_CLAUDE:-2.1.261}"   # batch 2. Batch 1 ran wholly on 2.1.260 and was aborted;
                                           # the bump is E-006's fifth disclosed harness move, schema re-probed
                                           # on run fee79c79 before batch 2 (verdict=match).

fail() { echo "run-e006: $*" >&2; exit 1; }

got_hash="$(shasum -a 256 "$OVERLAY_FILE" | cut -c1-32)"
[[ "$got_hash" == "$EXPECT_OVERLAY_HASH" ]] \
  || fail "overlay hash is $got_hash, registered $EXPECT_OVERLAY_HASH. A measured version is
    never edited; a change is a new version. Register one rather than moving this line."
got_bench="$(git -C "$LAB/../agent-observatory-benchmarks" rev-parse --short HEAD)"
[[ "$got_bench" == "$EXPECT_BENCH_SHA" ]] \
  || fail "benchmarks HEAD is $got_bench, registered $EXPECT_BENCH_SHA — the task moved."
got_claude="$(claude --version 2>/dev/null | awk '{print $1}')"
[[ "$got_claude" == "$EXPECT_CLAUDE" ]] \
  || fail "claude is $got_claude, registered $EXPECT_CLAUDE. A runtime move mid-batch voids
    the batch (E-006 controlled variables). Disclose it and start a new one."

# --- the flags, once, for both arms ---------------------------------------
ARM_COMMON=(
  RUNTIME=claude
  BENCHMARK=BE-003
  "EXPERIMENT=$EXPERIMENT_KEY"
  "MODEL=$EXPECT_MODEL"
  ISOLATE_USER_SETTINGS=1
  KEEP=1
)
ARM_TREATMENT=(
  "CUSTOMIZATION=../agent-learning-lab/build/customizations/agent-v1.0"
  AGENT=backend-feature-implementer
  VARIANT=agent-v1.0
)
ARM_CONTROL=(
  VARIANT=baseline
)

{
  echo "# E-006 batch $STAMP"
  echo "# overlay $EXPECT_OVERLAY_HASH · benchmarks $got_bench · claude $got_claude · model $EXPECT_MODEL"
  echo "# common: ${ARM_COMMON[*]}"
  echo "# treatment adds: ${ARM_TREATMENT[*]}"
  echo "# control adds:   ${ARM_CONTROL[*]}"
  printf 'seq\tarm\trun_id\texit\tworktree\tinit_schema_verdict\n'
} > "$MANIFEST"

echo "batch start (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee "$EVID/window.txt"

one_run() {
  local arm="$1" seq="$2"; shift 2
  local log="$EVID/${seq}-${arm}.log"
  echo ""
  echo "======== $seq $arm ========"
  ( cd "$OBS" && INIT_SCHEMA_DIR="$ISD" make run-benchmark "${ARM_COMMON[@]}" "$@" ) \
    > "$log" 2>&1
  local rc=$?
  # The run id and worktree are read back OUT OF THE LOG the runner wrote, not remembered.
  local rid wt verdict
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  verdict="$(grep -ao 'verdict=[a-z-]*' "$log" | head -1)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:-NONE}" "$rc" "${wt:-NONE}" "${verdict:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} exit=$rc ${verdict:-no-schema-verdict}"
  return $rc
}

for i in $(seq 1 "$PAIRS"); do
  s="$(printf '%02d' "$i")"
  one_run treatment "$s" "${ARM_TREATMENT[@]}"
  rc=$?
  if [[ $rc -eq 9 ]]; then
    echo "!! treatment $s returned 9 — row 0a, the delivered schema is not the declared one."
    echo "   Stopping the batch. The runs already recorded stay; do not score them."
    break
  fi
  one_run control "$s" "${ARM_CONTROL[@]}"
done

echo "batch end   (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$EVID/window.txt"
# E-006 exclusion 2 excludes a sleeping run's DURATION, not the run. The window above is what
# `pmset -g log | grep -E "Sleep|Wake"` is checked against afterwards; recording it here
# means the check can be made later by someone who was not present.
echo ""
echo "manifest: $MANIFEST"
column -t -s "$(printf '\t')" "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
