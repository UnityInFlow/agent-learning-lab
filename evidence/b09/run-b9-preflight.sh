#!/usr/bin/env bash
#
# run-b9-preflight — §4 step 5 for spine stop 20 (B9). ONE RUN PER ARM PER TASK: four runs, each
# under its own task's registered experiment key, with the `init.tools` read-back author decision 8
# requires. No batch starts until this passes.
#
# THE THREE CONDITIONS, from E-022/E-023's `Preflight assertion` row, with (ii) as amended:
#   (i)   knowledgeHash is SET on the treated run and NULL on the control — read back from the run
#         record, never inferred from the flag that was passed.
#   (ii)  the router's log exists with >= 1 LINE for the treated run and is ABSENT for the control.
#         *** THE LOG IS OUTSIDE THE WORKTREE. *** It was registered as `.agent/knowledge-log.jsonl`
#         inside it; both evaluators would then have scored every treated run exit 21 for an AC7
#         scope violation caused by the treatment's own bookkeeping, exactly as B7's preflight pair
#         2077432c / 88b861f3 were (E-016:227-237). Amendment 1 in both experiment files carries the
#         whole reasoning. The path is ${TMPDIR}/knowledge-log-observatory-run-<runId>.jsonl.
#   (iii) the corpus files in the treated kept worktree hash to the overlay's values.
#
# *** IF (ii) FAILS ON THE TREATED ARM THE BATCH DOES NOT START (exit 2). *** That is not caution,
# it is the registered VOID row of the decision rule: an L3 instruction nobody acted on tested
# nothing, and the batch would spend $8 measuring a file the agent never opened. B6's stop-13 and
# B8's stop-17 preflights both stopped a batch on this class of check.
#
# EXIT CODES
#   0  every condition held on every arm — the batch may start
#   2  condition (ii) failed on a treated arm — the instruction was not acted on
#   3  condition (i) or (iii) failed — the treatment was not delivered as registered
#   6  a guard refused before any run (overlay shas, control purity)
#   7  an endpoint is dead
#   8  a preflight or batch is already running (pid lock)
#
# Usage: evidence/b09/run-b9-preflight.sh [BE-003|BE-004 ...]
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

OVERLAY_T="${B9_OVERLAY_T:-$LAB/build/customizations/agent-v1.2-knowledge}"
OVERLAY_C="${B9_OVERLAY_C:-$LAB/build/customizations/agent-v1.1}"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
# REGISTERED, and hand re-derived rather than copied out of the verifier's output:
#   find .ai/knowledge -type f | LC_ALL=C sort, then (path, sha256) pairs digested, cut -c1-32.
EXPECT_KNOWLEDGE_HASH="${B9_EXPECT_KNOWLEDGE_HASH:-sha256:0770219ae7f4281a80071d78dadea285}"
EXPECT_AGENT_HASH="${B9_EXPECT_AGENT_HASH:-sha256:b3450564b6f32d6193e8580db766210e}"
EXPECT_INSTR_T="${B9_EXPECT_INSTR_T:-sha256:ebf489800a60a156986f98ea4f127848}"
EXPECT_INSTR_C="${B9_EXPECT_INSTR_C:-sha256:a94237242e8c1308fb1d434a06a03463}"

# THE ENDPOINTS, PROVED BELOW AND NOT GUESSED. 18081/14318 belonged to a colima tunnel that is
# refused today; 8081/4318 is the live stack (627 runs), confirmed by `make smoke` this session.
export API="${B9_API:-http://127.0.0.1:8081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="${B9_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B9_OTLP_GRPC:-http://localhost:4317}"
EVENTS="$OBS/infra/telemetry-out/events.jsonl"

TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b09/preflight-$TAG"
KEEPDIR="$LAB/evidence.local/b09-worktrees"
SMALLDIR="$LAB/evidence/b09/worktrees"

# ONE LOCK FOR THE PREFLIGHT AND THE BATCH, deliberately: a preflight run and a batch run of the
# same arms at the same time would interleave two populations in one API.
LOCK="${B9_LOCK:-$LAB/evidence/b09/.batch.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b9-preflight: a preflight or batch is already running (pid $(cat "$LOCK")). Read its" >&2
  echo "  manifest before deciding anything is dead. Refusing to start a second one." >&2
  exit 8
fi

# --- THE GUARDS. One variable moves; everything else is v1.1 byte for byte. -----------------
ta="$(shasum -a 256 "$OVERLAY_T/.claude/agents/$AGENT_NAME.md" | cut -d' ' -f1)"
ca="$(shasum -a 256 "$OVERLAY_C/.claude/agents/$AGENT_NAME.md" | cut -d' ' -f1)"
[[ "$ta" == "$ca" ]] || { echo "ABORT: the arms' agent files DIFFER — more than one variable moves" >&2; exit 6; }
[[ "sha256:${ta:0:32}" == "$EXPECT_AGENT_HASH" ]] \
  || { echo "ABORT: agent file is not the registered one: sha256:${ta:0:32} != $EXPECT_AGENT_HASH" >&2; exit 6; }
for f in .claude/settings.json .ai/policies/protected-paths.yaml .ai/hooks/policy-gate.sh \
         .ai/hooks/repair-limit.sh .ai/hooks/repair-record.sh; do
  t="$(shasum -a 256 "$OVERLAY_T/$f" | cut -d' ' -f1)"; c="$(shasum -a 256 "$OVERLAY_C/$f" | cut -d' ' -f1)"
  [[ "$t" == "$c" ]] || { echo "ABORT: $f differs between the arms — more than one variable moves" >&2; exit 6; }
done
ti="$(shasum -a 256 "$OVERLAY_T/CLAUDE.md" | cut -c1-32)"
ci="$(shasum -a 256 "$OVERLAY_C/CLAUDE.md" | cut -c1-32)"
[[ "sha256:$ti" == "$EXPECT_INSTR_T" ]] || { echo "ABORT: treated CLAUDE.md is not the registered one: sha256:$ti" >&2; exit 6; }
[[ "sha256:$ci" == "$EXPECT_INSTR_C" ]] || { echo "ABORT: control CLAUDE.md is not v1.1's: sha256:$ci" >&2; exit 6; }
# THE CONTROL MUST CARRY NO CORPUS, asserted on the filesystem before the record is read.
[[ -e "$OVERLAY_C/.ai/knowledge" ]] && { echo "ABORT: the CONTROL overlay has .ai/knowledge — the treatment is in both arms" >&2; exit 6; }
kh="$( (cd "$OVERLAY_T" && find .ai/knowledge -type f | LC_ALL=C sort | while IFS= read -r f; do
          printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done) | shasum -a 256 | cut -c1-32)"
[[ "sha256:$kh" == "$EXPECT_KNOWLEDGE_HASH" ]] \
  || { echo "ABORT: the corpus is not the registered one: sha256:$kh != $EXPECT_KNOWLEDGE_HASH" >&2; exit 6; }
# THE CORPUS MUST NAME NO TASK WORD (registered content constraint; the leak check greps object
# path NAMES only, run-agent.sh:259-262, so nothing else enforces this).
if (cd "$OVERLAY_T/.ai/knowledge" && grep -ril 'confirm\|cancel\|shipment\|order' . | grep -q .); then
  echo "ABORT: the corpus names a task word — the outcome would be partly derived from the task" >&2; exit 6
fi
# AND IT MUST BE THE SAME BYTES FOR BOTH TASKS, which is only meaningful as an assertion because
# it is the same directory: stated so a future reader does not look for two corpora.
echo "guards: one variable moves. agent/settings/policy/hooks identical; CLAUDE.md differs by the"
echo "        router clause only; corpus sha256:$kh present on treated and absent on control."

if [[ -n "${B9_GUARDS_ONLY:-}" ]]; then echo "guards-only: every guard passed and NOTHING was run"; exit 0; fi

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
  printf '# B9 PREFLIGHT %s — one run per arm per task, four runs, §4 step 5\n' "$TAG"
  printf '# treated %s (knowledgeHash %s) / control %s\n' "$OVERLAY_T" "$EXPECT_KNOWLEDGE_HASH" "$OVERLAY_C"
  printf '# claude %s at launch, model %s\n' "$LAUNCH_CLAUDE" "$MODEL"
  printf '# API %s  OTLP %s / %s  events.jsonl %s bytes at launch\n' \
    "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT" "$EVENTS_BEFORE"
  printf '# prediction commit ef2c6c0, BEFORE any run here\n'
  printf 'task\tarm\trun_id\trc\teval\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\tlog_hits\trouter_mentions\trouter_denied\tcorpus_match\tcost\tmodel_calls\ttool_calls\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 20 "$API/api/runs/$1" 2>/dev/null; }
COST_TOTAL=0; FAIL_II=0; FAIL_I_III=0

one() {  # one <task> <arm>
  local task="$1" arm="$2" key log rc rid wt rec
  key="EXP-B9-ROUTER-$(echo "$task" | tr -d '-')"   # BE-003 -> EXP-B9-ROUTER-BE003. REGISTERED.
  log="$EVID/${task}-${arm}.log"
  echo ""; echo "======== PREFLIGHT $task $arm  key=$key  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime claude --benchmark "$task" --experiment "$key" --model "$MODEL"
                 --agent "$AGENT_NAME" --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then args+=(--customization "$OVERLAY_T" --variant agent-v1.2-knowledge)
  else                             args+=(--customization "$OVERLAY_C" --variant agent-v1.1); fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(api "${rid:-x}")"
  local kn ih ah cost mc tc dur chg ev
  kn="$(printf '%s' "$rec"   | jq -r '.customization.knowledgeHash // "null"')"
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"

  # ===== CONDITION (ii): the router's log, OUTSIDE the worktree, one file per run.
  local lf="" lstate="ABSENT" lines=0 hits=0
  [[ -n "$wt" ]] && lf="${TMPDIR:-/tmp}/knowledge-log-$(basename "$wt").jsonl"
  if [[ -n "$lf" && -f "$lf" ]]; then
    lstate="PRESENT"
    lines="$(grep -c . "$lf" 2>/dev/null || echo 0)"
    hits="$(grep -c '"status":"hit"' "$lf" 2>/dev/null || echo 0)"
  fi
  # ===== WAS THE ROUTER ATTEMPTED, AND WAS THE ATTEMPT REFUSED? *** AN ABSENT LOG HAS TWO
  # CAUSES AND CONFLATING THEM NEARLY TURNED A HARNESS REFUSAL INTO A NULL RESULT. *** On the
  # 2026-09-26T12:48Z preflight, BE-003 treated fbdebf75 CALLED the router at its first
  # opportunity and the call was in `permission_denials`, because the runner allowed only mvn
  # Bash commands; BE-004 treated 5a16fd3e never mentioned it at all. Same ABSENT, opposite
  # meanings. `router_mentions` counts the attempts in the run log; `router_denied` is yes when a
  # denial entry names the router. An EMPTY denial array on a run that made the call is the
  # thing that proves the permission took effect — a flag echoed into a log proves only that it
  # was passed.
  local rmentions rdenied
  # -o PIPED TO wc -l, NOT grep -c, AND NO `|| echo 0`. Two defects in the first version of this
  # line, both of which the b08 driver already records: `grep -c` counts LINES WITH A MATCH, so two
  # router calls on one stream-json line count once; and `grep -c ... || echo 0` prints grep's own
  # "0" AND the fallback "0", putting a NEWLINE inside a manifest field. Hand-checked against the
  # 12:48Z logs: BE-003 treated 2 calls / denied yes, the other three 0 / no.
  # *** THE RUNNER'S OWN ECHO IS NOT AN ATTEMPT. *** obs#90 added `echo "  claude args: ..."`, and
  # the flag list contains Bash(.ai/knowledge/router.sh:*) — so every row of the 13:17Z preflight
  # read `router_mentions=1` with no agent involvement at all. A detector that counts its own
  # harness is the same defect as a control reporting over a scope smaller than it claims, three
  # versions in a row on one line. The `claude args:` line is excluded here BY NAME.
  rmentions="$(/usr/bin/grep -av 'claude args:' "$log" 2>/dev/null | /usr/bin/grep -ao 'router\.sh' | /usr/bin/wc -l | tr -d ' ')"
  rmentions="${rmentions:-0}"
  # NAMED `mentions`, NOT `calls`, AND THE DIFFERENCE IS NOT PEDANTRY: one tool call appears in the
  # stream-json more than once — the `tool_use` input, the cwd-prefixed form the harness records,
  # and the `permission_denials` entry if it was refused. On fbdebf75 that is 3 for ONE call. The
  # column is a presence indicator, and the thing that decides anything is `router_denied` beside
  # it and the log's own line count.
  rdenied=no
  /usr/bin/grep -ao 'permission_denials":\[[^]]\{0,240\}' "$log" 2>/dev/null | /usr/bin/grep -q 'router\.sh' && rdenied=yes

  # ===== CONDITION (iii): the corpus in the kept worktree hashes to the overlay's value.
  local cmatch="n/a"
  if [[ -n "$wt" && -d "$wt/.ai/knowledge" ]]; then
    local wkh
    wkh="$( (cd "$wt" && find .ai/knowledge -type f | LC_ALL=C sort | while IFS= read -r f; do
              printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done) | shasum -a 256 | cut -c1-32)"
    [[ "sha256:$wkh" == "$EXPECT_KNOWLEDGE_HASH" ]] && cmatch="MATCH" || cmatch="DIFFER:sha256:$wkh"
  elif [[ "$arm" == control ]]; then
    [[ -e "$wt/.ai/knowledge" ]] && cmatch="LEAK-INTO-CONTROL" || cmatch="ABSENT-as-registered"
  fi
  local it; it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$arm" "${rid:-NONE}" "$rc" "$ev" "$kn" "$ih" "$ah" "$lstate" "$lines" "$hits" \
    "$rmentions" "$rdenied" "$cmatch" "$cost" "$mc" "$tc" "$dur" "$chg" "$it" "${wt:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev knowledgeHash=$kn log=$lstate(${lines} lines, ${hits} hits) router_mentions=$rmentions denied=$rdenied corpus=$cmatch cost=$cost"

  # ===== THE EVIDENCE COPY, THE DAY THE RUN IS MADE. The reaper empties a kept worktree in
  # about three days and LEAVES THE DIRECTORY STANDING, so a copy made later is a copy of nothing.
  if [[ -n "$rid" ]]; then
    mkdir -p "$SMALLDIR/$rid"
    printf '%s' "$rec" > "$SMALLDIR/$rid/run-record.json"
    if [[ -n "$lf" && -f "$lf" ]]; then cp "$lf" "$SMALLDIR/$rid/knowledge-log.jsonl"
    else printf 'condition: knowledge log ABSENT at %s\n' "$lf" > "$SMALLDIR/$rid/knowledge-log-absent.txt"; fi
    [[ -n "$it" && -f "$EVID/init-schema/init-schema-${rid}.txt" ]] \
      && cp "$EVID/init-schema/init-schema-${rid}.txt" "$SMALLDIR/$rid/init-schema.txt"
    if [[ -n "$wt" && -d "$wt" ]]; then
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null \
        && echo "     worktree copied -> evidence.local/b09-worktrees/$rid ($(du -sh "$KEEPDIR/$rid" 2>/dev/null | cut -f1))"
    fi
  fi
  [[ "$cost" == "null" ]] || COST_TOTAL="$(awk -v a="$COST_TOTAL" -v b="$cost" 'BEGIN{printf "%.4f", a+b}')"

  # ===== THE VERDICTS, per arm, evaluated here rather than read off the manifest afterwards.
  if [[ "$arm" == treated ]]; then
    [[ "$kn" == "$EXPECT_KNOWLEDGE_HASH" ]] || { echo "  !! (i) FAILED: treated knowledgeHash is $kn" >&2; FAIL_I_III=$((FAIL_I_III+1)); }
    [[ "$cmatch" == "MATCH" ]]              || { echo "  !! (iii) FAILED: corpus in the worktree is $cmatch" >&2; FAIL_I_III=$((FAIL_I_III+1)); }
    if [[ "$lstate" != "PRESENT" || "$lines" -lt 1 ]]; then
      if [[ "$rdenied" == yes ]]; then
        echo "  !! (ii) FAILED **BY REFUSAL**: the agent CALLED the router ($rmentions attempt(s)) and the" >&2
        echo "  !!      harness DENIED it. This is NOT the VOID row and must never be reported as one —" >&2
        echo "  !!      the instruction was acted on. Fix the permission, then re-run this preflight." >&2
      else
        echo "  !! (ii) FAILED: the router was NOT ATTEMPTED on a treated run ($rmentions mentions in the" >&2
        echo "  !!      log, no denial naming it). THE BATCH MUST NOT START." >&2
      fi
      FAIL_II=$((FAIL_II+1))
    fi
  else
    [[ "$kn" == "null" ]] || { echo "  !! (i) FAILED: control knowledgeHash is $kn, not null" >&2; FAIL_I_III=$((FAIL_I_III+1)); }
    [[ "$lstate" == "ABSENT" ]] || { echo "  !! (ii) FAILED: the control wrote a router log" >&2; FAIL_I_III=$((FAIL_I_III+1)); }
  fi
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-preflight: $LAUNCH_CLAUDE -> $cv" >&2; exit 9; }
}

for t in "${TASKS[@]}"; do one "$t" treated; one "$t" control; done

{
  printf 'preflight %s ended (UTC): %s\n' "$TAG" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'cost over the runs that reported one: $%s\n' "$COST_TOTAL"
  printf 'PAIR COST PER TASK is what author decision 13 multiplies by 11 — see window.txt reader\n'
  printf 'events.jsonl bytes before %s, after %s\n' "$EVENTS_BEFORE" "$(events_bytes)"
  printf 'condition (ii) failures on treated arms: %s\n' "$FAIL_II"
  printf 'condition (i)/(iii) failures: %s\n' "$FAIL_I_III"
} | tee "$EVID/window.txt"
echo "manifest: $MANIFEST"
[[ "$FAIL_II" -gt 0 ]] && exit 2
[[ "$FAIL_I_III" -gt 0 ]] && exit 3
echo "PREFLIGHT PASSED — the batch may start."
exit 0
