#!/usr/bin/env bash
#
# run-b7-batch — §4 step 6 for stop 15. THE REGISTERED BATCH: n = 10 per arm per task,
# interleaved treated/control so a drift in the machine or the service hits both arms alike.
#
# IT IS THE SAME one() AS THE PREFLIGHT, DELIBERATELY. The preflight proved that function
# reads back agentHash, init.tools, the policy log, the edit count and the EVALUATOR's exit
# code correctly, on eight runs across two tasks. A batch script with its own copy of that
# logic would be an unproven instrument sitting between the runs and the result.
#
# The preflight this inherits answered, before ~$7 was spent:
#
#   does the treatment reach the model, and does it stay away from the control?
#
# WHAT IS ASSERTED PER RUN, and why each one is here rather than assumed:
#
#   .ai/policy-events.jsonl PRESENT on treated, ABSENT on control
#       This is the delivery proof and there is no alternative. run-agent.sh:625-629 records
#       instructionsHash, skillsHash and agentHash and NO settings or hook hash, and
#       GET /api/runs/{id} carries no `environment` object, so hookExecutions is not in the
#       API record either. The hook appends on ALLOW as well as DENY, so the file exists if
#       and only if the hook executed. Its ABSENCE on the control is the half this project
#       has been wrong about before -- the B4 overlay force-add, and `tools:` delivered as
#       [Read, Bash] when the file named four.
#
#   agentHash IDENTICAL on both arms
#       The two overlays carry a byte-identical agent file on purpose. If the hashes differ,
#       the phase treatment moved and the arms differ by more than one variable.
#
#   init.tools read back from the run's own init record (author decision 8)
#       Because a `tools:` line is a claim about a file until the delivered schema says so.
#
#   modelCalls non-null
#       A run that recorded no model calls measured the harness.
#
# MANIFEST-AS-PROGRESS-RECORD: every run appends before the next starts, so a session that
# dies mid-preflight leaves a record of what already ran. NEVER re-run an id that is in a
# manifest -- a duplicate benchmark run is evidence that cannot be deleted.
#
# MANIFEST-AS-PROGRESS-RECORD and a PID LOCK. Every run appends before the next starts. If
# this dies mid-batch, the manifest says exactly which ids exist -- READ IT BEFORE DECIDING
# ANYTHING IS DEAD, and never re-run an id that is in it: a duplicate benchmark run is
# evidence that cannot be deleted.
#
# Usage: evidence/b07/run-b7-batch.sh [N] [BE-003|BE-004 ...]     (N defaults to 10)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1
OVERLAY_T="$LAB/build/customizations/verify-v1.0"
OVERLAY_C="$LAB/build/customizations/phases-v1.0"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
EXPECT_AGENT_HASH="sha256:b3450564b6f32d6193e8580db766210e"

N=10
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then N="$1"; shift; fi
TASKS=("$@"); [[ ${#TASKS[@]} -eq 0 ]] && TASKS=(BE-003 BE-004)
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
EVID="$LAB/evidence/b07/batch-$TAG"

LOCK="$LAB/evidence/b07/.batch.lock"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "run-b7-batch: a batch is already running (pid $(cat "$LOCK")). Read its manifest" >&2
  echo "  before deciding anything is dead. Refusing to start a second one." >&2
  exit 8
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT
mkdir -p "$EVID/init-schema"
MANIFEST="$EVID/manifest.tsv"

LAUNCH_CLAUDE="$(claude --version 2>/dev/null | awk '{print $1}')"
{
  printf '# B7 REGISTERED BATCH %s  n=%s per arm per task, interleaved (author decision 9)\n' "$TAG" "$N"
  printf '# treated overlay %s\n'  "$(shasum -a 256 "$OVERLAY_T/.ai/hooks/policy-gate.sh" | cut -d" " -f1)"
  printf '# expected agentHash on BOTH arms: %s\n' "$EXPECT_AGENT_HASH"
  printf '# claude %s at launch, model %s\n' "$LAUNCH_CLAUDE" "$MODEL"
  printf '# prediction commit ea7b1d2 at 2026-09-10T09:51:08Z, BEFORE any run here\n'
  printf 'task\tseq\tarm\trun_id\tmake_rc\tevaluator_exit\tf13\tedits\tworktree\tagent_hash\tsettings_tracked\tpolicy_log\tpolicy_lines\tmodel_calls\tinit_tools\n'
} > "$MANIFEST"

api() { curl -s -m 10 "http://127.0.0.1:18081/api/runs/$1" 2>/dev/null; }

one() {  # one <task> <arm>
  local task="$1" arm="$2" seq="$3" key log rc rid wt ah pl pn mc it
  key="EXP-B7-POLICY-$(echo "$task" | tr -d '-')"   # BE-003 -> EXP-B7-POLICY-BE003. THE REGISTERED KEY.
  log="$EVID/${task}-${seq}-${arm}.log"
  echo ""; echo "======== $task $seq $arm  key=$key ========"
  # THESE ARE MAKE COMMAND-LINE VARIABLES, NOT ENVIRONMENT VARIABLES, and the difference is
  # not cosmetic. The observatory Makefile does `-include infra/.env`, so a variable exported
  # into the environment loses to the Makefile's own assignment -- while a command-line
  # variable always wins. Passed as env, API_PORT=18081 was ignored and all four runs died
  # with "Observatory API not reachable at http://localhost:8081" before any agent started.
  # No run was consumed and the four refusals stay in the first manifest.
  local -a mk=(RUNTIME=claude "BENCHMARK=$task" "EXPERIMENT=$key" "MODEL=$MODEL"
               ISOLATE_USER_SETTINGS=1 KEEP=1 API_PORT=18081
               OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200
               "INIT_SCHEMA_DIR=$EVID/init-schema")
  if [[ "$arm" == treated ]]; then
    mk+=("CUSTOMIZATION=$OVERLAY_T" "AGENT=$AGENT_NAME" VARIANT=verify-v1.0)
  else
    mk+=("CUSTOMIZATION=$OVERLAY_C" "AGENT=$AGENT_NAME" VARIANT=phases-v1.0)
  fi
  ( cd "$OBS" && make run-benchmark "${mk[@]}" ) > "$log" 2>&1
  rc=$?
  rid="$(grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  # ONE API READ, not four. Four separate curls can straddle a write and disagree with
  # each other, which is a race in the instrument rather than a fact about the run.
  local rec; rec="$(api "${rid:-x}")"
  ah="$(printf '%s' "$rec" | jq -r '.customization.agentHash // "null"')"
  mc="$(printf '%s' "$rec" | jq -r '.behavior.modelCalls // "null"')"
  # THE EVALUATOR'S EXIT CODE, NOT MAKE'S. `rc` above is GNU make's status, which is 2 for
  # ANY failed recipe -- so a manifest column called `exit` that holds it says "2" whether
  # the evaluator returned 10, 12 or 21. Every batch manifest in this repo has that shape,
  # which is why a census over them shows only 0 and 2 and says nothing about violations.
  # The evaluator's own verdict is in the run record and it is what belongs here.
  local ev; ev="$(printf '%s' "$rec" | jq -r '.evaluation.exitCode // "null"')"
  # F13: an api_error run measured the network, not the variant. The runner already says so
  # in its own output; recording it here means the manifest can be read without the logs.
  local f13=no; grep -aq '"terminal_reason":"api_error"' "$log" && f13=yes
  # HOW MANY EDITS WERE EVEN ATTEMPTED. Without this the delivery assertion has a hole: a run
  # that dies before its first Edit produces NO policy-events.jsonl for a reason that has
  # nothing to do with whether the hook was installed, and "ABSENT" would read as a failed
  # treatment. It is INCONCLUSIVE, and only a number can tell the two apart.
  # -oE piped to wc -l, NOT -c. `grep -c` counts LINES CONTAINING a match, so two Edit calls
  # on one line count once. They are on separate lines in stream-json today and the two agree
  # today; a counter that is only right because of the current line-wrapping is a counter that
  # will be wrong quietly. Verified against a real B5 log with the REAL /usr/bin/grep -- the
  # `grep` in an interactive shell here is a ugrep wrapper function that a #!/bin/bash script
  # does not inherit, so testing the wrapper would have proved nothing about this line.
  local edits; edits="$(/usr/bin/grep -aoE '"name":"(Edit|Write|NotebookEdit)"' "$log" 2>/dev/null | /usr/bin/wc -l | tr -d ' ')"
  edits="${edits:-0}"
  # DELIVERY vs EXECUTION, separated. The settings file being TRACKED IN THE SETUP COMMIT is
  # delivery; the event log is execution. A run with zero edits can prove the first and
  # cannot prove the second, and conflating them is how an arm gets called void for the
  # wrong reason.
  local tracked=no
  [[ -n "$wt" ]] && git -C "$wt" ls-files --error-unmatch .claude/settings.json >/dev/null 2>&1 && tracked=yes
  # THE LOG LIVES BESIDE THE WORKTREE, NOT INSIDE IT, since 2026-09-10 -- inside, the
  # evaluator's scope guard counted it as an unrelated production file and failed two
  # otherwise-correct runs at exit 21 (2077432c, 88b861f3). Derived from the worktree path
  # itself rather than from THIS process's $TMPDIR, so it is right even if the runner's
  # environment differs from the harness's.
  local plog=""; [[ -n "$wt" ]] && plog="$(dirname "$wt")/policy-events-$(basename "$wt").jsonl"
  pl="ABSENT"; pn=0
  if [[ -n "$plog" && -f "$plog" ]]; then
    pl="PRESENT"; pn="$(/usr/bin/grep -c . "$plog" 2>/dev/null | tr -d ' ')"
    # The worktree is kept but the log is not in it, so copy the log into the evidence dir
    # or the run's only delivery proof lives in a temp directory nobody archives.
    cp "$plog" "$EVID/${task}-${seq}-${arm}-policy-events.jsonl" 2>/dev/null || true
  elif [[ "$edits" -eq 0 ]]; then
    pl="INCONCLUSIVE-0-edits"
  fi
  # check-init-schema.sh writes a THREE-LINE TEXT report, not JSON:
  #   init-schema: delivered n=4 ["Read","Edit","Write","Bash"]
  #   init-schema: declared  n=4 [...]
  #   init-schema: verdict=match
  # Parsing it as JSON returns nothing and reads as "UNREAD" -- which is what the first
  # version of this line did. The delivered list AND the verdict are both recorded, because
  # stop 9 measured `Read, Grep, Glob, Bash` being DELIVERED as ["Read","Bash"] on 10 of 10
  # runs: the declared list is a claim about a file and only the delivered one is evidence.
  it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$task" "$seq" "$arm" "${rid:-NONE}" "$rc" "$ev" "$f13" "$edits" "${wt:-NONE}" "$ah" "$tracked" "$pl" "$pn" "$mc" "$it" >> "$MANIFEST"
  echo "  -> ${rid:-NO RUN ID} make_rc=$rc evaluator=$ev f13=$f13 edits=$edits settings_tracked=$tracked policy_log=$pl($pn) modelCalls=$mc"
  local cv; cv="$(claude --version 2>/dev/null | awk '{print $1}')"
  [[ "$cv" == "$LAUNCH_CLAUDE" ]] || { echo "ABORT: claude moved mid-preflight: $LAUNCH_CLAUDE -> $cv" >&2; exit 9; }
}

# INTERLEAVED, and it is not cosmetic. E-006 and E-007 both ran arm-blocked batches and both
# had to argue afterwards that nothing on the machine drifted between the blocks. Alternating
# means any drift -- a slower network, a warmer cache, a service update -- lands on both arms.
for t in "${TASKS[@]}"; do
  for ((i=1;i<=N;i++)); do
    s2="$(printf '%02d' "$i")"
    one "$t" treated "$s2"
    one "$t" control "$s2"
  done
done

echo ""; echo "manifest: $MANIFEST"; echo "BATCH DONE"
