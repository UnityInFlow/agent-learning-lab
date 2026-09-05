#!/usr/bin/env bash
# E-006 DELIBERATE FAILURE, arm G: the shipped v1.0 overlay with its `tools:` line deleted.
#
#   ./evidence/b04/run-e006-armG.sh          # 5 arm-G + 5 concurrent plain control, interleaved
#   PAIRS=1 ./evidence/b04/run-e006-armG.sh  # one pair, smoke
#
# WHAT THIS IS. §4 step 9. `build/README.md#b4` names exactly one trap - "if `tools:` is
# omitted, Copilot custom agents get all tools" - and arm G is that trap, executed. The
# overlay is byte-identical to agent-v1.0 with line 5 removed and nothing else; `--agent` is
# still passed, so run-agent.sh's overlay guard ADMITS the run and what breaks is the
# BOUNDARY rather than the guard. Predictions F1-F5 are committed at 2e39e58, BEFORE this
# script was written, and are not editable after it runs.
#
# NOT AN ARM OF THE REGISTERED COMPARISON. Its own experiment key. No median, range, quartile
# or Fisher test in E-006 includes it and no verdict is computed from it.
#
# THE CONCURRENT CONTROL WAS ADDED AFTER THE PREDICTION COMMIT AND CHANGES NO PREDICTION.
# F2 predicts arm G's median toolCalls against batch 2's already-recorded numbers, which are
# fixed and cannot move. Batch 2 ran 09:50-10:36Z and arm G runs after 17:16Z on the same
# machine and the same day, so a "toolCalls fell" reading has an alternative explanation -
# the machine got quieter - that a same-window plain control removes and a between-block
# comparison cannot. Five control runs cost about $0.75 and delete an alternative
# explanation; that trade is worth taking and is disclosed rather than folded in silently.
# `Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-05, after 2e39e58 and before the
# first arm-G run.`
#
# EXIT 9 does NOT stop this batch, and that is the one deliberate difference from
# run-e006.sh. Exit 9 is row 0a - "the delivered schema is not the declared one" - which
# voids a registered batch. Arm G DECLARES NO SCHEMA, so check-init-schema.sh returns
# verdict=recorded-only and exit 0 by its own contract (runner/lib/check-init-schema.sh:101),
# and F3 predicts exactly that. If a 9 appears anyway it is a finding about the runner, not a
# reason to stop, so it is recorded and the batch continues.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

if command -v caffeinate >/dev/null 2>&1 && [[ "${E006_CAFFEINATED:-0}" != "1" ]]; then
  echo "run-e006-armG: re-executing under caffeinate -i so the batch cannot span an idle sleep"
  E006_CAFFEINATED=1 exec caffeinate -i "$0" "$@"
fi
[[ "${E006_CAFFEINATED:-0}" == "1" ]] \
  || echo "run-e006-armG: WARNING - caffeinate unavailable, an idle sleep can contaminate durations" >&2

LAB="$(pwd)"
OBS="$(cd "$LAB/../agent-observatory" && pwd)" || exit 1

PAIRS="${PAIRS:-5}"
EXPERIMENT_KEY="${EXPERIMENT_KEY:-EXP-B4-DELIBERATE-NOTOOLS}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b04/armG-$STAMP"
ISD="$LAB/evidence/b04/init-schema"
mkdir -p "$EVID" "$ISD" || exit 1
MANIFEST="$EVID/manifest.tsv"

# --- the registered variables, asserted before the first run ---------------
# Identical to run-e006.sh except the overlay hash, which is the ONE thing arm G moves.
OVERLAY_DIR="$LAB/build/customizations/agent-v1.0-notools-DELIBERATE-FAILURE"
OVERLAY_FILE="$OVERLAY_DIR/.claude/agents/backend-feature-implementer.md"
EXPECT_OVERLAY_HASH="eb2a63fa5a675f23cedb79f5f005a4ed"
SHIPPED_OVERLAY="$LAB/build/customizations/agent-v1.0/.claude/agents/backend-feature-implementer.md"
EXPECT_BENCH_SHA="0448643"
EXPECT_MODEL="claude-haiku-4-5-20251001"
EXPECT_CLAUDE="${EXPECT_CLAUDE:-2.1.261}"

fail() { echo "run-e006-armG: $*" >&2; exit 1; }

got_hash="$(shasum -a 256 "$OVERLAY_FILE" | cut -c1-32)"
[[ "$got_hash" == "$EXPECT_OVERLAY_HASH" ]] \
  || fail "arm-G overlay hash is $got_hash, registered $EXPECT_OVERLAY_HASH."

# THE DELIBERATE FAILURE IS ONE LINE AND THIS PROVES IT IS ONE LINE. A deliberate failure
# that quietly changed two things would be a second experiment wearing the first one's name.
# `diff` must report exactly `5d4` and the deleted `tools:` line - three lines of output,
# nothing else.
diff_out="$(diff "$SHIPPED_OVERLAY" "$OVERLAY_FILE")"
expected_diff="5d4
< tools: Read, Edit, Write, Bash"
[[ "$diff_out" == "$expected_diff" ]] \
  || fail "arm G differs from the shipped overlay by more than the tools: line. Got:
$diff_out"

grep -qE '^tools:' "$OVERLAY_FILE" \
  && fail "arm-G overlay still declares a tools: line - the failure was not applied."

got_bench="$(git -C "$LAB/../agent-observatory-benchmarks" rev-parse --short HEAD)"
[[ "$got_bench" == "$EXPECT_BENCH_SHA" ]] \
  || fail "benchmarks HEAD is $got_bench, registered $EXPECT_BENCH_SHA - the task moved."
got_claude="$(claude --version 2>/dev/null | awk '{print $1}')"
[[ "$got_claude" == "$EXPECT_CLAUDE" ]] \
  || fail "claude is $got_claude, registered $EXPECT_CLAUDE."

# THE PREDICTION MUST PRECEDE THE FIRST RUN, and this checks it rather than asserting it.
PRED_COMMIT="${PRED_COMMIT:-2e39e58}"
pred_at="$(git -C "$LAB" log --format=%cI -1 "$PRED_COMMIT" 2>/dev/null)" \
  || fail "prediction commit $PRED_COMMIT is not in this repository."
[[ -n "$pred_at" ]] || fail "prediction commit $PRED_COMMIT has no timestamp."
pred_epoch="$(date -j -f '%Y-%m-%dT%H:%M:%S%z' "${pred_at/Z/+0000}" +%s 2>/dev/null)" \
  || pred_epoch=""
now_epoch="$(date +%s)"
if [[ -n "$pred_epoch" && "$now_epoch" -le "$pred_epoch" ]]; then
  fail "the clock says the first run would start at or before the prediction commit."
fi
echo "run-e006-armG: prediction $PRED_COMMIT committed $pred_at; first run starts after it"

ARM_COMMON=(
  RUNTIME=claude
  BENCHMARK=BE-003
  "EXPERIMENT=$EXPERIMENT_KEY"
  "MODEL=$EXPECT_MODEL"
  ISOLATE_USER_SETTINGS=1
  KEEP=1
)
ARM_G=(
  "CUSTOMIZATION=../agent-learning-lab/build/customizations/agent-v1.0-notools-DELIBERATE-FAILURE"
  AGENT=backend-feature-implementer
  VARIANT=agent-v1.0-notools
)
ARM_CONTROL=(
  VARIANT=baseline-armG-window
)

{
  echo "# E-006 arm G (deliberate failure) $STAMP"
  echo "# overlay $EXPECT_OVERLAY_HASH (shipped $(shasum -a 256 "$SHIPPED_OVERLAY" | cut -c1-32))"
  echo "# benchmarks $got_bench · claude $got_claude · model $EXPECT_MODEL"
  echo "# prediction commit $PRED_COMMIT at $pred_at"
  echo "# common:   ${ARM_COMMON[*]}"
  echo "# arm G adds:  ${ARM_G[*]}"
  echo "# control adds: ${ARM_CONTROL[*]}"
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
  one_run armG "$s" "${ARM_G[@]}"
  rc=$?
  [[ $rc -eq 9 ]] && echo "!! armG $s returned 9 - RECORDED as a finding about the runner, batch continues (see header)."
  one_run control "$s" "${ARM_CONTROL[@]}"
done

echo "batch end   (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$EVID/window.txt"
echo ""
echo "manifest: $MANIFEST"
column -t -s "$(printf '\t')" "$MANIFEST" 2>/dev/null || cat "$MANIFEST"
