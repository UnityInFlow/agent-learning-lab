#!/usr/bin/env bash
#
# run-gate-b2 — author decision 11 step 4, SECOND PASS on ticket A' (amendment clause). FIVE plain-baseline runs of BE-005 under a probe key.
# The rule, threshold and parameters are in RULE.md beside this file, committed before the
# first run. N IS NOT A PARAMETER: decision 11 says five and "never a bigger n", so there is
# no way to ask this script for six.
#
# Shape as evidence/b08/run-b8-batch.sh, minus the two-arm guards (there is one arm and no
# overlay): calls runner/run-agent.sh directly with the three tunnel endpoints stated here;
# manifest-as-progress-record; pid lock; one API read per run; claude-version drift abort;
# and the evidence copy the moment the run ends, because the $TMPDIR reaper hollows a kept
# worktree in about three days and the census read nothing for exactly that reason.
#
# What is new here: the FULL DIFF of every run is saved as runs/<id>/diff.patch, staged
# against the worktree's root commit exactly as the runner computes changedFiles (step 9:
# `git add -A` then `diff --cached <root>`), so new files the agent created are in it. Gate B
# is decided from that file, by a reader, never from the exit code. The `shape` column of
# the manifest is written as PENDING and is filled by hand after CLASSIFICATION.md exists.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1
BENCH="$(cd ../agent-observatory-benchmarks && pwd)" || exit 1
HERE="$LAB/evidence/gate-b2-decision-11"

N=5
TASK="BE-005"
KEY="EXP-B8A-GATEB2-BE005-PROBE"
MODEL="claude-haiku-4-5-20251001"
EXPECT_BENCH_SHA="fac772d216c0c63f7947b489a162debb5cb58251"   # benchmarks main after PR #31 (ticket A') merged 2026-09-17; filled by Claude Opus 5 before the first run

export API="http://127.0.0.1:18081"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:13200"
export OTLP_HTTP_ENDPOINT="http://localhost:14318"
export OTLP_GRPC_ENDPOINT="http://localhost:14317"

KEEPDIR="$LAB/evidence.local/gate-b2-worktrees"
RUNS="$HERE/runs"
MANIFEST="$HERE/manifest.tsv"
LOGDIR="$HERE/logs"

LOCK="$HERE/.batch.lock"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-gate-b: a batch is already running (pid $(cat "$LOCK")). Refusing to start a second." >&2
  exit 8
fi
echo $$ > "$LOCK"; trap 'rm -f "$LOCK"' EXIT

# A manifest that already holds rows means runs exist. NEVER re-run: a duplicate benchmark
# run is evidence that cannot be deleted, and six rows is the bigger n the rule forbids.
if [[ -f "$MANIFEST" ]] && [[ "$(grep -cv '^#' "$MANIFEST")" -gt 1 ]]; then
  echo "run-gate-b: $MANIFEST already has rows. Gate B has run; read it, do not re-run it." >&2
  exit 5
fi

# THE TICKET IS THE MERGED ONE. Not the branch, not a dirty tree.
bs="$(git -C "$BENCH" rev-parse HEAD)"
[[ "$bs" == "$EXPECT_BENCH_SHA" ]] || { echo "ABORT: benchmarks HEAD is $bs, not $EXPECT_BENCH_SHA (main after #30)" >&2; exit 6; }
[[ -z "$(git -C "$BENCH" status --porcelain)" ]] || { echo "ABORT: benchmarks tree is dirty" >&2; exit 6; }
[[ -d "$BENCH/tasks/BE-005-partial-fulfilment" ]] || { echo "ABORT: tasks/BE-005-partial-fulfilment missing" >&2; exit 6; }

# THE ENDPOINTS, PROVED NOT GUESSED.
ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

# NO RUN UNDER THIS KEY MAY EXIST YET. Five is five.
have="$(curl -s -m 15 "$API/api/runs?limit=1000" | jq -r --arg k "$KEY" '[.[] | select(.experimentKey==$k)] | length')"
[[ "$have" == "0" ]] || { echo "ABORT: $have run(s) already recorded under $KEY. Gate B is not re-run." >&2; exit 5; }

mkdir -p "$RUNS" "$LOGDIR" "$KEEPDIR"
LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
{
  printf '# GATE B (author decision 11 step 4)  started %s  n=%s  task %s  key %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$N" "$TASK" "$KEY"
  printf '# benchmarks main %s  claude %s  model %s\n' "$bs" "$LAUNCH_CLAUDE" "$MODEL"
  printf '# API %s  OTLP %s / %s\n' "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT"
  printf '# shape column: PENDING until runs/<id>/CLASSIFICATION.md is written and author-confirmed; then WRONG | RIGHT | NO-ATTEMPT\n'
  printf 'seq\trun_id\trc\tevaluator_exit\tf13\tedits\truntime_ver\tmodel\tinstr_hash\tagent_hash\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tworktree\tshape\n'
} > "$MANIFEST"

api() { curl -s -m 15 "$API/api/runs/$1" 2>/dev/null; }

for ((i=1;i<=N;i++)); do
  seq="$(printf '%02d' "$i")"
  log="$LOGDIR/${TASK}-${seq}.log"
  echo ""; echo "======== $TASK $seq  key=$KEY  $(date -u +%H:%M:%SZ) ========"
  ( cd "$OBS" && runner/run-agent.sh --runtime claude --benchmark "$TASK" --experiment "$KEY" \
      --model "$MODEL" --variant baseline --isolate-user-settings --keep ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"
  rv="$(printf '%s' "$rec"   | jq -r '.runtime.version // "null"')"
  rm_="$(printf '%s' "$rec"  | jq -r '.runtime.model // "null"')"
  f13=no; /usr/bin/grep -aq '"terminal_reason":"api_error"' "$log" && f13=yes
  edits="$(/usr/bin/grep -aoE '"name":"(Edit|Write|NotebookEdit)"' "$log" 2>/dev/null | /usr/bin/wc -l | tr -d ' ')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "${rid:-NONE}" "$rc" "$ev" "$f13" "${edits:-0}" "$rv" "$rm_" "$ih" "$ah" \
    "$mc" "$tc" "$cost" "$dur" "$chg" "${wt:-NONE}" "PENDING" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev f13=$f13 edits=${edits:-0} changed=$chg calls=$mc cost=$cost dur=$dur"
  # THE EVIDENCE COPY, NOW. The diff is the thing Gate B reads.
  if [[ -n "$rid" ]]; then
    d="$RUNS/$rid"; mkdir -p "$d"
    printf '%s' "$rec" > "$d/run-record.json"
    if [[ -n "$wt" && -d "$wt" ]]; then
      root="$(git -C "$wt" rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
      git -C "$wt" add -A >/dev/null 2>&1 || true
      git -C "$wt" diff --cached "$root" > "$d/diff.patch" 2>/dev/null
      git -C "$wt" diff --cached --stat "$root" > "$d/diff.stat" 2>/dev/null
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      rsync -a --exclude 'target/' "$wt/" "$KEEPDIR/$rid/" 2>/dev/null \
        && echo "     worktree copied -> evidence.local/gate-b-worktrees/$rid; diff.patch $(wc -l < "$d/diff.patch" | tr -d ' ') lines"
    else
      printf 'condition: worktree ABSENT at %s\n' "${wt:-<none in log>}" > "$d/condition-absent.txt"
    fi
  fi
  cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-batch: $LAUNCH_CLAUDE -> $cv" >&2; exit 9; }
done

echo ""; echo "manifest: $MANIFEST"; echo "GATE B RUNS DONE $(date -u +%Y-%m-%dT%H:%M:%SZ) — now read the five diffs"
