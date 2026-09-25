#!/usr/bin/env bash
#
# run-b8a-batch — §4 step 6 for spine stop 17a (B8a, decomposition depth).
# n = 10 per arm, ONE task (BE-005, author decision 11 item 5), interleaved control/treated.
#
# WHAT IS DIFFERENT FROM evidence/b08/run-b8-batch.sh, and why each difference is here:
#
#   1. THE COST CEILING IS READ BY THIS SCRIPT AND STOPS IT. EXIT 11.
#      Decision 11 item 11 registers $9.70 = 25 x $0.388 (Gate B''s median plain-run cost on
#      ticket A', evidence/gate-b2-decision-11/RESULT.md:38). The workbook's layer table row 11
#      says a number in a workbook is L3 and becomes L2 "if the batch driver reads it and stops".
#      This is that. The sum is over `efficiency.estimatedCost` of every run this batch made,
#      BOTH arms, read from the run record and not from a log line. A run whose cost reads null
#      contributes 0 and is COUNTED SEPARATELY in `null_cost`, because a ceiling that silently
#      treats an unmeasured cost as free is a control reporting over a scope smaller than it
#      claims -- and if any cost is null the ceiling is reported as A LOWER BOUND, not a total.
#
#   2. THE CONTROL INSTALLS NOTHING. No --customization, no --agent, --variant baseline.
#      That is Gate B''s own invocation (evidence/gate-b2-decision-11/run-gate-b2.sh:91) and it
#      is what makes B8a's control batch ALSO BE-005's baseline (decision 11 item 5). So the
#      control-side guard is the ABSENCE of an overlay, asserted from the run record's three
#      null hashes, not from the flag not being passed.
#
#   3. THE FOUR DELIVERY CONDITIONS ARE EVALUATED PER RUN, HERE, BEFORE ANY SCORING.
#      Decision 11 item 9 names them and says none of them is a hash:
#        (a) the setup commit's tree lists every overlay file -- `git ls-files` in the kept
#            worktree, NOT the file being present;
#        (b) customization.agentHash equals the orchestrator file's registered sha;
#        (c) the `init` read-back shows `Task` in the orchestrator's delivered tool set;
#        (d) telemetry shows at least one delegation event naming each of the three specialists.
#      A treated run missing any is ROW 0a, void before scoring. TWO OR MORE ENDS THE STEP -- the
#      script stops with EXIT 10 rather than spending the rest of the budget on a broken arm.
#
#   4. agentHash COVERS ONE FILE OF FOUR AND THIS SCRIPT SAYS SO IN THE MANIFEST HEADER.
#      run-agent.sh:609-611 hashes `.claude/agents/<AGENT_NAME>.md` alone. Condition (a) exists
#      precisely because three of the four files are files no hash sees.
#
#   5. DELEGATIONS ARE COUNTED TWICE, FROM TWO SOURCES, AND BOTH GO IN THE MANIFEST.
#      `deleg_stream` from the agent's own output stream in the log, `deleg_telemetry` from
#      infra/telemetry-out/events.jsonl filtered to the run id. Q8 fixes the expected value at
#      3 or 5 and NOTHING ELSE; 4 or 6+ is a finding. events.jsonl has not grown since
#      2026-09-17 on this machine, so the telemetry column may be 0 for a reason that is about
#      the collector and not about the run -- which is why the stream count is carried beside it
#      and why `window.txt` records the file's size before and after the batch.
#
# WHAT IS THE SAME, DELIBERATELY: the pid lock, the manifest-as-progress-record, the one API
# read per run, the same-day evidence copy off $TMPDIR (the reaper emptied all 54 BE-004
# worktrees and voided the decision 11 census), the init read-back, and the claude-version
# drift abort. Every one of those was paid for.
#
# NEVER re-run an id that is already in a manifest. A duplicate benchmark run is evidence that
# cannot be deleted.
#
# Exit codes, every one proved by evidence/b08a/verify-b8a-batch-guards.sh:
#   0  the batch ran to n per arm
#   6  a one-variable guard refused (overlay wrong, control overlay present, sha not registered)
#   7  an endpoint is dead (API or OTLP)
#   8  a batch is already running (pid lock)
#   9  the claude CLI moved mid-batch
#   10 row 0a on 2 or more treated runs -- the step ends early (decision 11 item 11)
#   11 the $9.70 cost ceiling was reached before n per arm -- the population that occurred is
#      reported, as E-016 did at n = 7 (decision rule row 0b)
#
# Usage: evidence/b08a/run-b8a-batch.sh [N]        (N defaults to 10)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

# The B8A_* overrides exist ONLY so verify-b8a-batch-guards.sh can point a guard at a
# deliberately-broken COPY and prove it refuses. The registered values are the defaults; a batch
# that wanted others would be a different experiment.
OVERLAY_T="${B8A_OVERLAY_T:-$LAB/build/customizations/b8a-pipeline-v1.0}"
AGENT_NAME="orchestrator"
TASK="${B8A_TASK:-BE-005}"
KEY="${B8A_KEY:-EXP-B8A-DECOMP-BE005}"
MODEL="claude-haiku-4-5-20251001"
EXPECT_AGENT_HASH="${B8A_EXPECT_AGENT_HASH:-sha256:1f27323694e579ec11dbca026bfbb326}"
CEILING="${B8A_CEILING:-9.70}"
SPECIALISTS=(planner implementer verifier)

export API="${B8A_API:-http://127.0.0.1:8081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="${B8A_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B8A_OTLP_GRPC:-http://localhost:4317}"
EVENTS="$OBS/infra/telemetry-out/events.jsonl"

N=10
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then N="$1"; shift; fi
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b08a/batch-$TAG"
KEEPDIR="$LAB/evidence.local/b08a-worktrees"
SMALLDIR="$LAB/evidence/b08a/worktrees"
MANIFEST="$EVID/manifest.tsv"

LOCK="${B8A_LOCK:-$LAB/evidence/b08a/.batch.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b8a-batch: a batch is already running (pid $(cat "$LOCK")). Read its manifest" >&2
  echo "  before deciding anything is dead. Refusing to start a second one." >&2
  exit 8
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

# --- THE ONE-VARIABLE GUARDS, on the files, before any money is spent. ------------------
# All four overlay files must exist: three of them are invisible to agentHash, so a missing
# specialist would produce a run that looks perfectly delivered by every hash this harness has.
for f in orchestrator planner implementer verifier; do
  [[ -f "$OVERLAY_T/.claude/agents/$f.md" ]] \
    || { echo "ABORT: treated overlay is missing .claude/agents/$f.md" >&2; exit 6; }
done
ta="$(shasum -a 256 "$OVERLAY_T/.claude/agents/$AGENT_NAME.md" | cut -c1-32)"
[[ "sha256:$ta" == "$EXPECT_AGENT_HASH" ]] \
  || { echo "ABORT: orchestrator is not the registered file: sha256:$ta != $EXPECT_AGENT_HASH" >&2; exit 6; }
# The orchestrator must be able to delegate, or the treated arm is a second baseline that every
# check passes. This is the guard the DELIBERATE FAILURE is built to trip (Q5).
grep -qE '^tools:.*\bTask\b' "$OVERLAY_T/.claude/agents/$AGENT_NAME.md" \
  || { echo "ABORT: the orchestrator's tools: line does not contain Task -- nothing can be delegated" >&2; exit 6; }
# The treatment must be the agents and nothing else: no CLAUDE.md, no SKILL.md, no hooks, or the
# arms differ by more than the registered configuration.
for stray in CLAUDE.md AGENTS.md; do
  [[ -e "$OVERLAY_T/$stray" ]] \
    && { echo "ABORT: treated overlay carries $stray -- instructionsHash would not be null and the arms differ by more than the agents" >&2; exit 6; }
done
if find "$OVERLAY_T" -type f -name 'SKILL.md' 2>/dev/null | grep -q .; then
  echo "ABORT: treated overlay carries a SKILL.md -- Q7 declined a skill and skillsHash would not be null" >&2; exit 6
fi
if find "$OVERLAY_T" -type d -name 'hooks' 2>/dev/null | grep -q .; then
  echo "ABORT: treated overlay carries a hooks directory -- that is a second executed control" >&2; exit 6
fi
# No agent file may pin a model: CLAUDE_CODE_SUBAGENT_MODEL sits above a subagent's own model
# field (SOURCES.md row 220), so an explicit model there is a fifth variable.
if grep -lE '^model:' "$OVERLAY_T"/.claude/agents/*.md 2>/dev/null | grep -q .; then
  echo "ABORT: an agent file sets model: -- the model is chosen by --model and nowhere else" >&2; exit 6
fi

# --- THE ENDPOINTS, PROBED ONCE. Never inherited: on this machine 18081 was the only live -----
# route in September and is now the dead one, and an open OTLP port is not proof an export lands.
ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP $OTLP_HTTP_ENDPOINT answered $oc, not 200" >&2; exit 7; }

# GUARDS-ONLY MODE exists so every guard above can be PROVEN to refuse without spending a run.
# Nothing but verify-b8a-batch-guards.sh sets it. It exits BEFORE any directory is created, so a
# fixture run leaves no dated batch- directory that a stranger would read as a batch of nothing.
if [[ -n "${B8A_GUARDS_ONLY:-}" ]]; then
  echo "guards-only: every guard passed and NOTHING was run"; exit 0
fi

# --- THE TWO STOP RULES, DEFINED ONCE. ------------------------------------------------
# The loop below calls exactly these two functions, and so does STOP-RULE-ONLY MODE. That is
# what makes the $9.70 ceiling an L2 control rather than a number in a workbook: the fixture set
# proves the SAME expression fires that the batch runs. A fixture that re-implemented the
# comparison would be testing a copy of the control, which is this project's house failure mode.
ceiling_reached()   { awk -v t="$1" -v c="$CEILING" 'BEGIN{exit !(t>=c)}'; }
row0a_ends_step()   { [[ "$1" -ge 2 ]]; }

# STOP-RULE-ONLY MODE: evaluate the two rules against values the caller supplies, with no run and
# no money. Nothing but verify-b8a-batch-guards.sh sets these.
if [[ -n "${B8A_STOPRULE_ONLY:-}" ]]; then
  if row0a_ends_step "${B8A_TEST_ROW0A:-0}"; then
    echo "stop-rule: ROW 0a on ${B8A_TEST_ROW0A:-0} treated runs — the step ends (exit 10)"; exit 10
  fi
  if ceiling_reached "${B8A_TEST_COST:-0}"; then
    echo "stop-rule: COST CEILING \$$CEILING REACHED at \$${B8A_TEST_COST:-0} (exit 11)"; exit 11
  fi
  echo "stop-rule: neither rule fires at row0a=${B8A_TEST_ROW0A:-0} cost=\$${B8A_TEST_COST:-0}"; exit 0
fi

mkdir -p "$EVID/init-schema" "$KEEPDIR" "$SMALLDIR"
LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
events_bytes() { [[ -f "$EVENTS" ]] && wc -c < "$EVENTS" | tr -d ' ' || echo 0; }
EVENTS_BEFORE="$(events_bytes)"

{
  printf '# B8a REGISTERED BATCH %s  n=%s per arm, ONE task %s, interleaved\n' "$TAG" "$N" "$TASK"
  printf '# treated overlay %s dispatched --agent %s; CONTROL INSTALLS NOTHING\n' "$OVERLAY_T" "$AGENT_NAME"
  printf '# agentHash covers ONE file of FOUR; conditions (a),(c),(d) carry the other three\n'
  printf '# expected agentHash treated %s / control null\n' "$EXPECT_AGENT_HASH"
  printf '# cost ceiling $%s enforced by this script (exit 11); row 0a x2 ends the step (exit 10)\n' "$CEILING"
  printf '# claude %s at launch, model %s\n' "$LAUNCH_CLAUDE" "$MODEL"
  printf '# API %s  OTLP %s / %s  events.jsonl %s bytes at launch\n' \
    "$API" "$OTLP_HTTP_ENDPOINT" "$OTLP_GRPC_ENDPOINT" "$EVENTS_BEFORE"
  printf '# prediction commit a3acac7 at 2026-09-25T07:04:59Z, BEFORE any run here\n'
  printf 'seq\tarm\trun_id\trc\tevaluator_exit\truntime_ver\tmodel\tagent_hash\tinstr_hash\tskills_hash\tcond_a\tcond_b\tcond_c\tcond_d\trow0a\tdeleg_stream\tdeleg_q8\tdeleg_telemetry\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

api() { curl -s -m 15 "$API/api/runs/$1" 2>/dev/null; }

COST_TOTAL=0
NULL_COST=0
ROW0A=0

one() {  # one <arm> <seq>
  local arm="$1" seq="$2" log rc rid wt rec
  log="$EVID/${TASK}-${seq}-${arm}.log"
  echo ""; echo "======== $TASK $seq $arm  key=$KEY  $(date -u +%H:%M:%SZ) ========"
  local -a args=(--runtime claude --benchmark "$TASK" --experiment "$KEY" --model "$MODEL"
                 --isolate-user-settings --keep)
  if [[ "$arm" == treated ]]; then
    args+=(--customization "$OVERLAY_T" --agent "$AGENT_NAME" --variant b8a-pipeline-v1.0)
  else
    args+=(--variant baseline)
  fi
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" runner/run-agent.sh "${args[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  # ONE API read, not ten: ten curls can straddle a write and disagree with each other, which is
  # a race in the instrument rather than a fact about the run.
  rec="$(api "${rid:-x}")"
  local ah ih sh_ mc tc cost dur chg ev rv rm
  ah="$(printf '%s' "$rec"   | jq -r '.customization.agentHash // "null"')"
  ih="$(printf '%s' "$rec"   | jq -r '.customization.instructionsHash // "null"')"
  sh_="$(printf '%s' "$rec"  | jq -r '.customization.skillsHash // "null"')"
  mc="$(printf '%s' "$rec"   | jq -r '.behavior.modelCalls // "null"')"
  tc="$(printf '%s' "$rec"   | jq -r '.behavior.toolCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec"  | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec"  | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec"   | jq -r '.evaluation.exitCode // "null"')"
  rv="$(printf '%s' "$rec"   | jq -r '.runtime.version // "null"')"
  rm="$(printf '%s' "$rec"   | jq -r '.runtime.model // "null"')"

  # --- DELEGATIONS, TWO SOURCES, NEITHER STANDING IN FOR THE OTHER ---------------------
  # *** THE WIRE TOOL NAME IS `Agent`, NOT `Task`. *** The frontmatter says `tools: ... Task`,
  # `init.tools` reads back `Task`, and the model then emits `"name":"Agent"`. Measured at §4
  # step 5: `"name":"Task"` appears ZERO times in a treated transcript with six real delegations.
  # AND A LINE COUNT IS NOT A CALL COUNT: the old pattern returned 19 for a run that made 6
  # delegations, because a streaming transcript repeats each call across several events. Count
  # DISTINCT tool_use ids.
  local ds dt
  ds="$(/usr/bin/grep -aoE '"type":"tool_use","id":"toolu_[A-Za-z0-9]+","name":"Agent"' "$log" 2>/dev/null | sort -u | wc -l | tr -d ' ')"
  ds="${ds:-0}"
  # Telemetry DOES carry the delegations (tool_name=Agent) even though it carries no
  # subagent_type; it emits a pre/post pair per call, so this column is about twice ds.
  dt=0
  if [[ -n "$rid" && -f "$EVENTS" ]]; then
    dt="$(/usr/bin/grep -a "$rid" "$EVENTS" 2>/dev/null | /usr/bin/grep -ac '"stringValue":"Agent"')"
    dt="${dt:-0}"
  fi
  # Q8 fixes the expected count at 3 (no bounce) or 5 (one bounce) and says 4 or 6+ IS A FINDING.
  # It is RECORDED, NOT VOIDED: decision 11 item 9 lists four delivery conditions and the count
  # is not one of them, so a run with six delegations is a result about the orchestrator's
  # discipline rather than a failed delivery. The §4 step 5 preflight made SIX -- four of them to
  # the planner - so this column is expected to be a finding on most runs.
  local dclass="finding-$ds"
  { [[ "$ds" == "3" ]] || [[ "$ds" == "5" ]]; } && dclass="q8-ok-$ds"

  # --- THE FOUR DELIVERY CONDITIONS (decision 11 item 9). Treated arm only; on the control
  # they are recorded `n/a` because the control declares no overlay to deliver. ----------
  local ca=na cb=na cc=na cd=na r0a=no
  local it itfile
  itfile="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$itfile" && -r "$itfile" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$itfile" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$itfile" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi

  if [[ "$arm" == treated ]]; then
    # (a) the setup commit's TREE lists every overlay file. `git ls-files` in the kept worktree,
    #     not `test -f`: a file present but untracked never reached the setup commit.
    ca=fail
    if [[ -n "$wt" && -d "$wt" ]]; then
      local tracked=0
      for f in orchestrator planner implementer verifier; do
        ( cd "$wt" && git ls-files --error-unmatch ".claude/agents/$f.md" ) >/dev/null 2>&1 && tracked=$((tracked+1))
      done
      [[ "$tracked" -eq 4 ]] && ca=ok || ca="fail-$tracked-of-4"
    fi
    # (b) agentHash equals the orchestrator's registered sha.
    [[ "$ah" == "$EXPECT_AGENT_HASH" ]] && cb=ok || cb=fail
    # (c) the init read-back shows Task in the delivered set. This is the condition the
    #     deliberate failure attacks, and the one E-005 showed the runtime can rewrite away.
    if [[ -n "$itfile" && -r "$itfile" ]]; then
      /usr/bin/grep -q '"Task"' "$itfile" && cc=ok || cc=fail
    else cc=fail-nofile; fi
    # (d) EACH OF THE THREE SPECIALISTS IS NAMED IN AT LEAST ONE DELEGATION.
    #
    # *** THE SOURCE IS THE AGENT STREAM AND IT IS NOT A FALLBACK. Measured at §4 step 5 on run
    # a390a301: events.jsonl DOES carry this run (70 lines, +807 kB across the pair) and DOES
    # carry `tool_name: "Agent"` twelve times -- but it carries NO `subagent_type` attribute at
    # all, so the three NAMES are not in telemetry and no query over it can find them. Decision
    # 11 item 9(d) asks for a telemetry source; the telemetry schema does not have the field.
    # Reading the names from the stream is therefore not a weaker substitute, it is the only
    # place the fact exists -- and it is recorded as a SOURCE SUBSTITUTION in the workbook and
    # in author_notes rather than taken silently. ***
    #
    # The first version of this block grepped events.jsonl for the run id, found 70 matching
    # lines, and therefore NEVER fell back -- then failed to find the names and would have
    # returned fail-0-of-3 on every treated run, voiding the batch at pair 2 on a wrong query.
    # That is the same failure the B8 driver's header records for `.behavior.*`: a wrong path
    # reads empty and looks exactly like a missing measurement.
    local named=0
    for s in "${SPECIALISTS[@]}"; do
      /usr/bin/grep -aq "\"subagent_type\":\"$s\"" "$log" && named=$((named+1))
    done
    [[ "$named" -eq 3 ]] && cd="ok-stream-3of3" || cd="fail-$named-of-3-stream"
    case "$ca$cb$cc$cd" in *fail*) r0a=yes; ROW0A=$((ROW0A+1));; esac
  else
    # THE CONTROL'S ASSERTION IS STRUCTURAL: three null hashes read from its own run record.
    # "No flag was passed" is a fact about my command line; three nulls are an observation
    # about the session.
    if [[ "$ah" == "null" && "$ih" == "null" && "$sh_" == "null" ]]; then ca=ok-null-triple
    else ca="FAIL-control-carries-$ah/$ih/$sh_"; fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq" "$arm" "${rid:-NONE}" "$rc" "$ev" "$rv" "$rm" "$ah" "$ih" "$sh_" \
    "$ca" "$cb" "$cc" "$cd" "$r0a" "$ds" "$dclass" "$dt" "$mc" "$tc" "$cost" "$dur" "$chg" \
    "$it" "${wt:-NONE}" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} rc=$rc eval=$ev model=$rm deleg=$ds($dclass)/$dt cond=$ca,$cb,$cc,$cd row0a=$r0a cost=$cost"

  # --- THE EVIDENCE COPY, THE DAY THE RUN IS MADE. --------------------------------------
  # The reaper on this machine empties a kept worktree in about three days and LEAVES THE
  # DIRECTORY STANDING, so `ls -d` passes on a hollowed one. All 54 kept BE-004 worktrees were
  # already empty when the decision 11 census opened them, and the census returned no reading.
  if [[ -n "$rid" ]]; then
    mkdir -p "$SMALLDIR/$rid"
    printf '%s' "$rec" > "$SMALLDIR/$rid/run-record.json"
    [[ -n "$itfile" ]] && cp "$itfile" "$SMALLDIR/$rid/init-schema.txt"
    if [[ -n "$wt" && -d "$wt" ]]; then
      rm -rf "${KEEPDIR:?}/${rid:?}" 2>/dev/null
      cp -R "$wt" "$KEEPDIR/$rid" 2>/dev/null \
        && echo "     worktree copied -> evidence.local/b08a-worktrees/$rid ($(du -sh "$KEEPDIR/$rid" 2>/dev/null | cut -f1))"
    fi
  fi

  # --- THE COST CEILING, ACCUMULATED FROM THE RECORD (header note 1). -------------------
  if [[ "$cost" == "null" || -z "$cost" ]]; then
    NULL_COST=$((NULL_COST+1))
  else
    COST_TOTAL="$(awk -v a="$COST_TOTAL" -v b="$cost" 'BEGIN{printf "%.4f", a+b}')"
  fi

  # A CLI THAT MOVES MID-BATCH IS A CHANGED REGISTERED VARIABLE.
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ -z "$cv" || "$cv" == "$LAUNCH_CLAUDE" ]] \
    || { echo "ABORT: claude moved mid-batch: $LAUNCH_CLAUDE -> $cv" >&2; finish 9; }
}

finish() {  # finish <exit code>
  local code="$1"
  { printf 'batch %s ended (UTC): %s  exit %s\n' "$TAG" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$code"
    printf 'cost total read from run records: $%s over the runs that reported one\n' "$COST_TOTAL"
    printf 'runs whose estimatedCost read null: %s -- with any of these the total above is a LOWER BOUND\n' "$NULL_COST"
    printf 'ceiling: $%s\n' "$CEILING"
    printf 'treated runs classed row 0a: %s\n' "$ROW0A"
    printf 'events.jsonl bytes before %s, after %s\n' "$EVENTS_BEFORE" "$(events_bytes)"
  } | tee -a "$EVID/window.txt"
  echo "manifest: $MANIFEST"
  exit "$code"
}

# INTERLEAVED, and it is not cosmetic: E-006 and E-007 both ran arm-blocked batches and both had
# to argue afterwards that nothing on the machine drifted between the blocks.
for ((i=1;i<=N;i++)); do
  s2="$(printf '%02d' "$i")"
  one control  "$s2"
  one treated  "$s2"
  # Checked AFTER the pair so the arms stay balanced: stopping between a control and its treated
  # partner would leave an unpaired run in a batch whose whole design is interleaving.
  if row0a_ends_step "$ROW0A"; then
    echo ""; echo "!! ROW 0a ON $ROW0A TREATED RUNS. The step ends here (decision 11 item 11)." >&2
    echo "!! The delivery proof failed; this is not a null result and must not be reported as one." >&2
    finish 10
  fi
  if ceiling_reached "$COST_TOTAL"; then
    echo ""; echo "!! COST CEILING \$$CEILING REACHED at \$$COST_TOTAL after pair $s2." >&2
    echo "!! The batch stops and the population that occurred is reported (decision rule row 0b)." >&2
    finish 11
  fi
done

echo ""; echo "BATCH DONE $(date -u +%Y-%m-%dT%H:%M:%SZ)"
finish 0
