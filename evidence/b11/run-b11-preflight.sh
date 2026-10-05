#!/usr/bin/env bash
#
# run-b11-preflight — §4 step 5 for spine stop 26 (B11, v1.2). ONE RUN PER ARM PER TASK: four
# runs, each under its own task's key WITH THE `-PF` SUFFIX, with the `init.tools` read-back
# author decision 8 requires. No batch starts until this passes.
#
# Adapted from evidence/b09/run-b9-preflight.sh. Everything structural is kept verbatim because
# every piece of it was paid for: the shared pid lock, the sidecar written before the manifest
# row, the evidence copy made the day the run is made (the reaper empties a kept worktree in
# about three days and LEAVES THE DIRECTORY STANDING), the claude-version drift abort, and the
# `-PF` key suffix — which exists because stop 20's preflight runs landed in the BATCH's
# registered key and `make baseline-report` pooled 25 runs into a population of 20 without
# saying so.
#
# THE FOUR CONDITIONS, from E-026/E-027's `Preflight assertion` and `Control assertion` rows:
#   (i)   instructionsHash equals the REGISTERED v1.2 sha on the treated run and v1.1's on the
#         control — read back from the run record, never inferred from the flag that was passed.
#   (ii)  AT LEAST ONE of the three L2 hooks left a log line on the treated run, and NONE of the
#         three logs exists for the control. This is the VOID row of both decision rules: a hook
#         nobody's tool call reached tested nothing.
#   (iii) `git ls-files` in the treated kept worktree lists EVERY overlay file by name. Author
#         decision 11 item 9's rule for a multi-file overlay, and it is the only delivery proof
#         there is for the hooks: *** customization.hooksHash HAS BEEN null ON EVERY RUN THIS
#         PROJECT HAS EVER RECORDED *** (stop 16 author note), so a hook file is proved present
#         by the setup commit's tree and by its own log, never by a hash.
#   (iv)  the control's worktree contains NONE of the four new hook files.
#
# *** WHY THE LOGS ARE OUTSIDE THE WORKTREE, AND WHY THAT IS NOT A CONVENIENCE. *** They were
# registered as `.agent/budget-log.jsonl` and friends. Written INSIDE the worktree, both
# evaluators score every treated run exit 21 for a scope violation caused by the treatment's own
# bookkeeping — which is exactly what happened to B7's preflight pair 2077432c / 88b861f3, both
# of which SOLVED their tasks (E-016:227-237), and again to B9 (E-022 Amendment 1). The
# evaluator's ignore pattern is a REGISTERED VARIABLE and moving it is a §7 halt. So the
# documented path stays `.agent/*.jsonl` and the file lives beside B8's run-state under $TMPDIR
# with the worktree in its name.
#
# EXIT CODES
#   0  every condition held on every arm — the batch may start
#   2  condition (ii) failed on a treated arm — no hook was reached, the batch must not start
#   3  condition (i), (iii) or (iv) failed — the treatment was not delivered as registered
#   6  a guard refused before any run (overlay shas, control purity)
#   7  an endpoint is dead
#   8  a preflight or batch is already running (pid lock)
#   9  the claude CLI moved mid-preflight
#
# Usage: evidence/b11/run-b11-preflight.sh [BE-003|BE-004 ...]
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

OVERLAY_T="${B11_OVERLAY_T:-$LAB/build/customizations/agent-v1.2-efficiency}"
OVERLAY_C="${B11_OVERLAY_C:-$LAB/build/customizations/agent-v1.1}"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
# REGISTERED at §4 step 4, hand-derived with `shasum -a 256 <file> | cut -c1-32`, which is what
# run-agent.sh:572-576 computes.
EXPECT_AGENT_HASH="${B11_EXPECT_AGENT_HASH:-sha256:b3450564b6f32d6193e8580db766210e}"
EXPECT_INSTR_T="${B11_EXPECT_INSTR_T:-sha256:1cb0ea105099353da3e8048b1a923687}"
EXPECT_INSTR_C="${B11_EXPECT_INSTR_C:-sha256:a94237242e8c1308fb1d434a06a03463}"

# The five files v1.2 ADDS to v1.1, and the ones both arms must share byte for byte. Named here
# once so the guards, condition (iii) and condition (iv) all read the same list — a fixture that
# checked a second copy of the list would be testing the copy.
NEW_FILES=(.ai/hooks/retrieval-budget.sh .ai/hooks/summary-cache.sh
           .ai/hooks/summary-cache-record.sh .ai/hooks/command-dedup.sh
           .ai/policies/retrieval-budget.yaml .ai/efficiency/classify-task.sh
           .ai/efficiency/verification-profiles.yaml .ai/core/context-policy.md)
SHARED_FILES=(.ai/policies/protected-paths.yaml .ai/hooks/policy-gate.sh
              .ai/hooks/repair-limit.sh .ai/hooks/repair-record.sh)

export API="${B11_API:-http://127.0.0.1:8081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="${B11_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B11_OTLP_GRPC:-http://localhost:4317}"
EVENTS="$OBS/infra/telemetry-out/events.jsonl"

TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="${B11_EVID_ROOT:-$LAB/evidence/b11}/preflight-$TAG"
KEEPDIR="$LAB/evidence.local/b11-worktrees"
SMALLDIR="$LAB/evidence/b11/worktrees"

# ONE LOCK FOR THE PREFLIGHT AND THE BATCH, deliberately: a preflight run and a batch run of the
# same arms at the same time would interleave two populations in one API.
LOCK="${B11_LOCK:-$LAB/evidence/b11/.batch.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b11-preflight: a preflight or batch is already running (pid $(cat "$LOCK")). Read its" >&2
  echo "  manifest before deciding anything is dead. Refusing to start a second one." >&2
  exit 8
fi

# --- THE GUARDS. One variable moves: the VERSION. Everything v1.1 had is v1.1's bytes. -------
ta="$(shasum -a 256 "$OVERLAY_T/.claude/agents/$AGENT_NAME.md" | cut -d' ' -f1)"
ca="$(shasum -a 256 "$OVERLAY_C/.claude/agents/$AGENT_NAME.md" | cut -d' ' -f1)"
[[ "$ta" == "$ca" ]] || { echo "ABORT: the arms' agent files DIFFER — more than one variable moves" >&2; exit 6; }
[[ "sha256:${ta:0:32}" == "$EXPECT_AGENT_HASH" ]] \
  || { echo "ABORT: agent file is not the registered one: sha256:${ta:0:32} != $EXPECT_AGENT_HASH" >&2; exit 6; }
for f in "${SHARED_FILES[@]}"; do
  t="$(shasum -a 256 "$OVERLAY_T/$f" | cut -d' ' -f1)"; c="$(shasum -a 256 "$OVERLAY_C/$f" | cut -d' ' -f1)"
  [[ "$t" == "$c" ]] || { echo "ABORT: $f differs between the arms — v1.1's files must be v1.1's bytes" >&2; exit 6; }
done
# *** settings.json IS NOT IN SHARED_FILES, AND THAT IS THE POINT OF THIS VERSION. *** v1.2
# registers four more hooks, so the file MUST differ; asserting it identical (as the b09 guard
# did, where the router was prose) would refuse the treatment. What is asserted instead is that
# the control's settings.json is still v1.1's and that it names none of the new hooks.
cs="$(shasum -a 256 "$OVERLAY_C/.claude/settings.json" | cut -d' ' -f1)"
[[ "$cs" == "$(shasum -a 256 "$LAB/build/customizations/agent-v1.1/.claude/settings.json" | cut -d' ' -f1)" ]] \
  || { echo "ABORT: the control's settings.json is not v1.1's" >&2; exit 6; }
for f in "${NEW_FILES[@]}"; do
  [[ -e "$OVERLAY_T/$f" ]] || { echo "ABORT: the TREATED overlay is missing $f" >&2; exit 6; }
  [[ -e "$OVERLAY_C/$f" ]] && { echo "ABORT: the CONTROL overlay has $f — the treatment is in both arms" >&2; exit 6; }
done
for h in retrieval-budget summary-cache summary-cache-record command-dedup; do
  grep -q "$h.sh" "$OVERLAY_T/.claude/settings.json" \
    || { echo "ABORT: treated settings.json does not register $h.sh — the file would be dead weight" >&2; exit 6; }
  grep -q "$h.sh" "$OVERLAY_C/.claude/settings.json" \
    && { echo "ABORT: CONTROL settings.json registers $h.sh" >&2; exit 6; }
done
ti="$(shasum -a 256 "$OVERLAY_T/CLAUDE.md" | cut -c1-32)"
ci="$(shasum -a 256 "$OVERLAY_C/CLAUDE.md" | cut -c1-32)"
[[ "sha256:$ti" == "$EXPECT_INSTR_T" ]] || { echo "ABORT: treated CLAUDE.md is not the registered one: sha256:$ti" >&2; exit 6; }
[[ "sha256:$ci" == "$EXPECT_INSTR_C" ]] || { echo "ABORT: control CLAUDE.md is not v1.1's: sha256:$ci" >&2; exit 6; }
# THE THREE FIXTURE SETS MUST PASS BEFORE A RUN IS PAID FOR. A hook whose refusal has never been
# demonstrated is indistinguishable from one that refuses nothing, and finding that out after a
# $6 batch is the expensive order to find it out in.
# B11_FIXTURE_DIR exists for evidence/b11/verify-b11-*-guards.sh and for nothing else: a gate
# that refuses when a fixture set fails must itself be shown to refuse, and the only way to do
# that without breaking a registered hook is to point this at a stub that exits non-zero.
FIXTURE_DIR="${B11_FIXTURE_DIR:-$LAB/tools}"
if [[ -z "${B11_SKIP_FIXTURES:-}" ]]; then
  for v in verify-retrieval-budget verify-summary-cache verify-command-dedup; do
    ( cd "$LAB" && "$FIXTURE_DIR/$v.sh" >/dev/null 2>&1 ) \
      || { echo "ABORT: $FIXTURE_DIR/$v.sh does not pass — read its output before any run" >&2; exit 6; }
  done
  echo "guards: the three hook fixture sets pass (24 + 19 + 22 cases)"
fi
echo "guards: one variable moves — the version. agent file and v1.1's four hook/policy files are"
echo "        byte-identical; CLAUDE.md differs by the v1.2 section; the ${#NEW_FILES[@]} new files are on"
echo "        treated and absent from control; settings.json registers four hooks on treated, none on control."

if [[ -n "${B11_PRINT_KEYS:-}" ]]; then
  for t in BE-003 BE-004; do
    printf 'preflight key %s -> EXP-B11-EFFICIENCY-%s%s\n' "$t" "$(echo "$t" | tr -d '-')" "${B11_PREFLIGHT_KEY_SUFFIX:--PF}"
  done
  echo "print-keys: nothing was run"; exit 0
fi
if [[ -n "${B11_GUARDS_ONLY:-}" ]]; then echo "guards-only: every guard passed and NOTHING was run"; exit 0; fi

ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT
mkdir -p "$EVID/init-schema" "$KEEPDIR" "$SMALLDIR"
MANIFEST="$EVID/manifest.tsv"
LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }
EVENTS_BEFORE="$(events_bytes)"
{
  printf '# B11 PREFLIGHT %s — one run per arm per task, four runs, §4 step 5\n' "$TAG"
  printf '# treated %s / control %s\n' "$OVERLAY_T" "$OVERLAY_C"
  printf '# expected instructionsHash treated %s / control %s; agentHash BOTH %s\n' \
    "$EXPECT_INSTR_T" "$EXPECT_INSTR_C" "$EXPECT_AGENT_HASH"
  printf '# claude %s at launch, model %s, benchmarks %s\n' "$LAUNCH_CLAUDE" "$MODEL" \
    "$(git -C ../agent-observatory-benchmarks rev-parse --short HEAD 2>/dev/null)"
  printf '# API %s  OTLP %s / %s  events.jsonl %s bytes at launch\n' \
    "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT" "$EVENTS_BEFORE"
  printf '# prediction commit 2552b75 at 2026-09-29T19:30:40Z, BEFORE any run here\n'
  printf '# the cost column is what author decision 13 multiplies by 11, PER TASK, in run-b11-batch.sh\n'
  printf 'task\tarm\trun_id\trc\teval\tinstr_hash\tagent_hash\tagents_hash\thooks_hash\tbudget_lines\tcache_lines\tdedup_lines\tclassify\toverlay_files\th_fired\tcost\tmodel_calls\ttool_calls\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 20 "$API/api/runs/$1" 2>/dev/null; }
COST_TOTAL=0; FAIL_II=0; FAIL_OTHER=0

# log_lines <worktree> <prefix> — the line count of one hook's log, or 0 when it is absent.
# The three logs are named for the worktree, exactly as B8's run-state and B9's router log are.
log_lines() {
  local wt="$1" pre="$2" f
  [[ -n "$wt" ]] || { echo 0; return; }
  f="${TMPDIR:-/tmp}/${pre}-$(basename "$wt").jsonl"
  [[ -f "$f" ]] && grep -c . "$f" 2>/dev/null || echo 0
}
log_path() { printf '%s/%s-%s.jsonl' "${TMPDIR:-/tmp}" "$2" "$(basename "$1")"; }

one() {  # one <task> <arm>
  local task="$1" arm="$2" key log rc rid wt rec
  key="EXP-B11-EFFICIENCY-$(echo "$task" | tr -d '-')${B11_PREFLIGHT_KEY_SUFFIX:--PF}"
  log="$EVID/${task}-${arm}.log"
  echo ""; echo "======== PREFLIGHT $task $arm  key=$key  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime claude --benchmark "$task" --experiment "$key" --model "$MODEL"
                 --agent "$AGENT_NAME" --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then args+=(--customization "$OVERLAY_T" --variant agent-v1.2-efficiency)
  else                             args+=(--customization "$OVERLAY_C" --variant agent-v1.1); fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  local ih ah gh hh cost mc tc dur chg ev
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  gh="$(printf '%s' "$rec"   | jq -r '.customization.agentsHash // "null"')"
  hh="$(printf '%s' "$rec"   | jq -r '.customization.hooksHash // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"

  # ===== CONDITION (ii): the three L2 hooks' own logs, one per mechanism, NEVER POOLED.
  # B9's Amendment 5 is the reason a single `H` is not computed here: a pooled H counted
  # invocations of one thing and was read as consultation of another.
  local bl cl dl cls hfired
  bl="$(log_lines "$wt" budget-log)"; cl="$(log_lines "$wt" cache-log)"; dl="$(log_lines "$wt" dedup-log)"
  cls=ABSENT
  [[ -n "$wt" && -f "${TMPDIR:-/tmp}/task-classification-$(basename "$wt").yaml" ]] && cls=PRESENT
  hfired=0
  for n in "$bl" "$cl" "$dl"; do [[ "$n" -ge 1 ]] && hfired=$((hfired+1)); done

  # ===== CONDITION (iii)/(iv): the overlay files in the kept worktree, by `git ls-files`.
  # NOT by `-e`: a file present but not in the setup commit's tree is a file the run's own
  # bookkeeping could have created. Author decision 11 item 9's (a).
  local ofiles="n/a" missing=""
  if [[ -n "$wt" && -d "$wt" ]]; then
    local tracked; tracked="$(git -C "$wt" ls-files 2>/dev/null)"
    if [[ "$arm" == treated ]]; then
      local have=0
      for f in "${NEW_FILES[@]}"; do
        if grep -qxF "$f" <<<"$tracked"; then have=$((have+1)); else missing="${missing}${missing:+,}$f"; fi
      done
      ofiles="$have/${#NEW_FILES[@]}"
      [[ -n "$missing" ]] && ofiles="$ofiles MISSING:$missing"
    else
      local leaked=0
      for f in "${NEW_FILES[@]}"; do grep -qxF "$f" <<<"$tracked" && leaked=$((leaked+1)); done
      [[ "$leaked" == 0 ]] && ofiles="ABSENT-as-registered" || ofiles="LEAK-INTO-CONTROL:$leaked"
    fi
  fi

  local it; it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi

  # The sidecar, written before the row: a crash between the run and the manifest must cost a
  # row, never a run id and a worktree path nothing records.
  printf '%s\t%s\t%s\t%s\t%s\n' "$task" "$arm" "${rid:-NONE}" "${wt:-NONE}" "$(date -u +%H:%M:%SZ)" >> "$EVID/run-ids.tsv"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$arm" "${rid:-NONE}" "$rc" "$ev" "$ih" "$ah" "$gh" "$hh" "$bl" "$cl" "$dl" "$cls" \
    "$ofiles" "$hfired" "$cost" "$mc" "$tc" "$dur" "$chg" "$it" "${wt:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev instr=$ih hooksHash=$hh budget=${bl}L cache=${cl}L dedup=${dl}L classify=$cls overlay=$ofiles cost=$cost"

  # ===== THE EVIDENCE COPY, THE DAY THE RUN IS MADE.
  if [[ -n "$rid" ]]; then
    mkdir -p "$SMALLDIR/$rid"
    printf '%s' "$rec" > "$SMALLDIR/$rid/run-record.json"
    for pre in budget-log cache-log dedup-log; do
      local f; f="$(log_path "${wt:-none}" "$pre")"
      if [[ -n "$wt" && -f "$f" ]]; then cp "$f" "$SMALLDIR/$rid/$pre.jsonl"
      else printf 'condition: %s ABSENT at %s\n' "$pre" "$f" > "$SMALLDIR/$rid/$pre-absent.txt"; fi
    done
    if [[ -n "$wt" && -f "${TMPDIR:-/tmp}/task-classification-$(basename "$wt").yaml" ]]; then
      cp "${TMPDIR:-/tmp}/task-classification-$(basename "$wt").yaml" "$SMALLDIR/$rid/task-classification.yaml"
    fi
    local sf; [[ -n "$wt" ]] && sf="${TMPDIR:-/tmp}/run-state-$(basename "$wt").json"
    [[ -n "${sf:-}" && -f "$sf" ]] && cp "$sf" "$SMALLDIR/$rid/run-state.json"
    [[ -f "$EVID/init-schema/init-schema-${rid}.txt" ]] && cp "$EVID/init-schema/init-schema-${rid}.txt" "$SMALLDIR/$rid/init-schema.txt"
    if [[ -n "$wt" && -d "$wt" ]]; then
      git -C "$wt" ls-files > "$SMALLDIR/$rid/git-ls-files.txt" 2>/dev/null
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null \
        && echo "     worktree copied -> evidence.local/b11-worktrees/$rid ($(du -sh "$KEEPDIR/$rid" 2>/dev/null | cut -f1))"
    fi
  fi
  [[ "$cost" == "null" ]] || COST_TOTAL="$(awk -v a="$COST_TOTAL" -v b="$cost" 'BEGIN{printf "%.4f", a+b}')"

  # ===== THE VERDICTS, per arm, evaluated here rather than read off the manifest afterwards.
  if [[ "$arm" == treated ]]; then
    [[ "$ih" == "$EXPECT_INSTR_T" ]] || { echo "  !! (i) FAILED: treated instructionsHash is $ih, not $EXPECT_INSTR_T" >&2; FAIL_OTHER=$((FAIL_OTHER+1)); }
    [[ "$ah" == "$EXPECT_AGENT_HASH" ]] || { echo "  !! (i) FAILED: treated agentHash is $ah" >&2; FAIL_OTHER=$((FAIL_OTHER+1)); }
    [[ "$ofiles" == "${#NEW_FILES[@]}/${#NEW_FILES[@]}" ]] \
      || { echo "  !! (iii) FAILED: the setup commit's tree lists $ofiles of the overlay's new files" >&2; FAIL_OTHER=$((FAIL_OTHER+1)); }
    if [[ "$hfired" -lt 1 ]]; then
      echo "  !! (ii) FAILED: NOT ONE of the three L2 hooks left a log line on a treated run." >&2
      echo "  !!      budget=${bl} cache=${cl} dedup=${dl}. Either the hooks were not delivered, or the" >&2
      echo "  !!      runtime did not run them, or their log path is wrong. THE BATCH MUST NOT START —" >&2
      echo "  !!      this is the VOID row, and at stop 13 exactly this check saved a batch." >&2
      FAIL_II=$((FAIL_II+1))
    fi
  else
    [[ "$ih" == "$EXPECT_INSTR_C" ]] || { echo "  !! (i) FAILED: control instructionsHash is $ih, not v1.1's" >&2; FAIL_OTHER=$((FAIL_OTHER+1)); }
    [[ "$ofiles" == "ABSENT-as-registered" ]] || { echo "  !! (iv) FAILED: the control's tree shows $ofiles" >&2; FAIL_OTHER=$((FAIL_OTHER+1)); }
    if [[ "$bl" != 0 || "$cl" != 0 || "$dl" != 0 ]]; then
      echo "  !! (iv) FAILED: the CONTROL wrote a hook log (budget=$bl cache=$cl dedup=$dl)" >&2
      FAIL_OTHER=$((FAIL_OTHER+1))
    fi
  fi
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-preflight: $LAUNCH_CLAUDE -> $cv" >&2; exit 9; }
}

for t in "${TASKS[@]}"; do one "$t" treated; one "$t" control; done

{
  printf 'preflight %s ended (UTC): %s\n' "$TAG" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'cost over the runs that reported one: $%s\n' "$COST_TOTAL"
  printf 'THE PAIR COST PER TASK is what author decision 13 multiplies by 11; run-b11-batch.sh\n'
  printf '  reads it from this manifest BY COLUMN NAME and refuses to start if it cannot (exit 12)\n'
  printf 'events.jsonl bytes before %s, after %s\n' "$EVENTS_BEFORE" "$(events_bytes)"
  printf 'condition (ii) failures on treated arms: %s\n' "$FAIL_II"
  printf 'condition (i)/(iii)/(iv) failures: %s\n' "$FAIL_OTHER"
} | tee "$EVID/window.txt"
echo "manifest: $MANIFEST"
[[ "$FAIL_II" -gt 0 ]] && exit 2
[[ "$FAIL_OTHER" -gt 0 ]] && exit 3
echo "PREFLIGHT PASSED — the batch may start."
exit 0
