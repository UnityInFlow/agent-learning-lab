#!/usr/bin/env bash
#
# run-b9-deliberate-failure.sh — §4 step 9 of spine stop 20. ONE arm, ONE task, n = 5.
#
# THE BREAK: `.ai/knowledge/router.sh` without its executable bit, in a copy of the measured
# overlay whose every byte is identical (`diff -r` returns nothing). The CLAUDE.md clause still
# names the command. The instruction is intact and the thing it names cannot execute.
#
# WHY IT NEEDS ITS OWN DRIVER, AND IT IS THE OPPOSITE REASON TO STOP 17a's. There, the registered
# batch driver REFUSED the broken overlay at exit 6, so the deliberate failure could not enter the
# registered population by accident and needed a separate runner to happen at all. Here the
# registered driver ACCEPTS it — `B9_GUARDS_ONLY=1 B9_OVERLAY_T=<broken>` exits 0, identical output
# to the measured overlay (evidence/b09/deliberate-failure/clause1-*.txt), because both
# `run-b9-batch.sh:181` and `run-agent.sh:knowledge_hash()` digest (path, content) pairs and a mode
# bit is neither. So the separation has to be built here, and it is built as an INVERTED GUARD:
# this script REFUSES an overlay whose router IS executable (exit 6). It cannot run the measured
# arm, which is the only guarantee available once the registered guard is known not to help.
#
# EXIT CODES. Every one is proved by evidence/b09/verify-b9-df-guards.sh:
#   0   ok — the batch ran to n, or a --guards-only / --plan-only probe passed
#   1   cd failed, or the overlay directory is missing
#   2   unknown flag
#   6   GUARD REFUSAL: the router is executable (this is the measured overlay, not the break);
#       or the corpus sha is not the registered one; or CLAUDE.md is not the registered treated one
#   7   the API or the OTLP endpoint did not answer 200
#   8   a pid lock is held — another batch is running
#   11  the cost ceiling was reached; the population that occurred is reported, not extended
#   12  the ceiling could not be computed from the registered median, or n is not a positive integer
#   14  a run produced NO run id — the runner never started. The row is kept and the batch STOPS
#       rather than filling n with null rows, which the first launch of this script did
#
# THE MANIFEST APPENDS BEFORE THE NEXT RUN STARTS, so it is a progress record: an id in it has
# already run and must never be re-run (§0). Resume by reading it, not by guessing.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1

OVERLAY="${B9DF_OVERLAY:-$LAB/build/customizations/agent-v1.2-knowledge-noexec}"
AGENT_NAME="backend-feature-phases"
MODEL="claude-haiku-4-5-20251001"
TASK="BE-003"
KEY="EXP-B9-DF-NOEXEC"
N="${B9DF_N:-5}"
EXPECT_KNOWLEDGE_HASH="${B9DF_EXPECT_KNOWLEDGE_HASH:-sha256:0770219ae7f4281a80071d78dadea285}"
EXPECT_INSTR="${B9DF_EXPECT_INSTR:-sha256:ebf489800a60a156986f98ea4f127848}"
EXPECT_AGENT_HASH="${B9DF_EXPECT_AGENT_HASH:-sha256:b3450564b6f32d6193e8580db766210e}"
# The ceiling is COMPUTED from the registered treated median, never carried as prose (author
# decision 13's shape, applied to a 5-run probe): 5 x $0.133958 rounded up, plus margin.
TREATED_MEDIAN="${B9DF_TREATED_MEDIAN:-0.133958}"
# *** VALIDATE THE INPUT, NOT THE PRODUCT, AND THE FIXTURE SET IS WHY THIS LINE IS HERE. ***
# The first version of this block multiplied first and then checked the result against
# `^[0-9]+\.[0-9]+$`. awk reads a non-numeric median as 0, so `null` produced a ceiling of
# `0.0000`, which MATCHES that pattern and fires on the first run. That is the identical defect
# run-b9-batch.sh's `pair_cost()` comment already documents — written by someone who had just read
# that comment — and case I of verify-b9-df-guards.sh is what caught it. A number the script cannot
# compute must abort, never default to zero.
[[ "$TREATED_MEDIAN" =~ ^[0-9]+(\.[0-9]+)?$ ]] || {
  echo "ABORT: median '$TREATED_MEDIAN' is not a number, so the ceiling is not computable." >&2
  echo "  A ceiling that defaults to 0 fires on the first run and reads as a stop rule. (exit 12)" >&2
  exit 12; }
[[ "$N" =~ ^[1-9][0-9]*$ ]] || { echo "ABORT: n '$N' is not a positive integer (exit 12)" >&2; exit 12; }
CEILING="$(awk -v m="$TREATED_MEDIAN" -v n="$N" 'BEGIN{printf "%.4f", m*n*1.5}')"
if [[ ! "$CEILING" =~ ^[0-9]+\.[0-9]+$ ]] || ! awk -v c="$CEILING" 'BEGIN{exit !(c>0)}'; then
  echo "ABORT: computed ceiling '$CEILING' is not a positive number (exit 12)" >&2; exit 12
fi

# *** EXPORTED, NOT ASSIGNED, AND THE FIRST LAUNCH PAID FOR IT. *** run-agent.sh:31 reads
# `API="${API:-http://localhost:8080}"` from its OWN environment. This block originally assigned
# without `export`, so the driver's curl probe checked 8081 and answered 200 while every run of the
# batch went to 8080 and died with `Observatory API not reachable`. The registered driver exports
# all five (run-b9-batch.sh:80-84); this one now does too. Launch 20260927T085830Z is kept on disk
# as the record of the failure — five rows, rc=1, cost null, no run id, no money spent.
export API="${API:-http://127.0.0.1:8081}"
export WEB="${WEB:-http://localhost:5174}"
export TEMPO_URL="${TEMPO_URL:-http://localhost:3200}"
export OTLP_HTTP_ENDPOINT="${OTLP_HTTP_ENDPOINT:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${OTLP_GRPC_ENDPOINT:-localhost:4317}"
GUARDS_ONLY="" ; PLAN_ONLY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --guards-only) GUARDS_ONLY=1; shift ;;
    --plan-only)   PLAN_ONLY=1; shift ;;
    *) echo "run-b9-deliberate-failure: unknown flag $1 (only --guards-only, --plan-only)" >&2; exit 2 ;;
  esac
done

[[ -d "$OVERLAY" ]] || { echo "ABORT: no overlay at $OVERLAY (exit 1)" >&2; exit 1; }
ROUTER="$OVERLAY/.ai/knowledge/router.sh"
[[ -f "$ROUTER" ]] || { echo "ABORT: no router at $ROUTER (exit 1)" >&2; exit 1; }

# --- THE INVERTED GUARD. This is the whole reason the file exists. -----------------------------
if [[ -x "$ROUTER" ]]; then
  echo "ABORT: $ROUTER IS EXECUTABLE. This driver runs the DELIBERATE FAILURE, and an" >&2
  echo "  executable router is the MEASURED overlay. Running it here would put a registered-arm" >&2
  echo "  run under the probe key $KEY. Refusing. (exit 6)" >&2
  exit 6
fi
kh="$( (cd "$OVERLAY" && find .ai/knowledge -type f | LC_ALL=C sort | while IFS= read -r f; do
          printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done) | shasum -a 256 | cut -c1-32)"
[[ "sha256:$kh" == "$EXPECT_KNOWLEDGE_HASH" ]] || {
  echo "ABORT: corpus is sha256:$kh, not the registered $EXPECT_KNOWLEDGE_HASH. The break is a" >&2
  echo "  MODE BIT and must not change a byte. (exit 6)" >&2; exit 6; }
ih="sha256:$(shasum -a 256 "$OVERLAY/CLAUDE.md" | cut -c1-32)"
[[ "$ih" == "$EXPECT_INSTR" ]] || { echo "ABORT: CLAUDE.md is $ih, not the registered treated $EXPECT_INSTR (exit 6)" >&2; exit 6; }
ah="sha256:$(shasum -a 256 "$OVERLAY/.claude/agents/$AGENT_NAME.md" | cut -c1-32)"
[[ "$ah" == "$EXPECT_AGENT_HASH" ]] || { echo "ABORT: agent file is $ah, not the registered $EXPECT_AGENT_HASH (exit 6)" >&2; exit 6; }
echo "guards: router NOT executable (the break), corpus $EXPECT_KNOWLEDGE_HASH, CLAUDE.md $EXPECT_INSTR, agent $EXPECT_AGENT_HASH"
echo "ceiling: \$$CEILING = $N x \$$TREATED_MEDIAN x 1.5"
[[ -n "$GUARDS_ONLY" ]] && { echo "guards-only: every guard passed and NOTHING was run"; exit 0; }

LOCK="${B9DF_LOCK:-$LAB/evidence/b09/.df.lock}"
if [[ -e "$LOCK" ]] && kill -0 "$(cat "$LOCK" 2>/dev/null)" 2>/dev/null; then
  echo "ABORT: $LOCK held by pid $(cat "$LOCK") (exit 8)" >&2; exit 8
fi
ac="$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$API/api/runs?limit=1")"
[[ "$ac" == "200" ]] || { echo "ABORT: API $API answered $ac, not 200 (exit 7)" >&2; exit 7; }
oc="$(curl -s -o /dev/null -w '%{http_code}' -m 10 -X POST -H 'Content-Type: application/json' \
      -d '{"resourceSpans":[]}' "$OTLP_HTTP_ENDPOINT/v1/traces")"
[[ "$oc" == "200" ]] || { echo "ABORT: OTLP answered $oc, not 200 (exit 7)" >&2; exit 7; }

TAG="${B9DF_TAG:-$(date -u +%Y%m%dT%H%M%SZ)}"
EVID="${B9DF_EVID_ROOT:-$LAB/evidence/b09/deliberate-failure}/batch-$TAG"
MANIFEST="$EVID/manifest.tsv"
mkdir -p "$EVID/init-schema"
if [[ -n "$PLAN_ONLY" ]]; then
  echo "plan: $N runs of $TASK under key $KEY, overlay $OVERLAY, ceiling \$$CEILING"
  echo "plan-only: nothing was run"; exit 0
fi
echo $$ > "$LOCK"; trap 'rm -f "$LOCK"' EXIT
{
  printf '# B9 DELIBERATE FAILURE %s  n=%s  task=%s  key=%s\n' "$TAG" "$N" "$TASK" "$KEY"
  printf '# overlay %s (router NOT executable; every byte identical to agent-v1.2-knowledge)\n' "$OVERLAY"
  printf '# expected knowledgeHash %s  instructionsHash %s  agentHash %s\n' \
    "$EXPECT_KNOWLEDGE_HASH" "$EXPECT_INSTR" "$EXPECT_AGENT_HASH"
  printf '# ceiling $%s  claude %s  model %s  benchmarks %s\n' "$CEILING" \
    "$(claude --version 2>/dev/null | awk '{print $1}')" "$MODEL" \
    "$(git -C ../agent-observatory-benchmarks rev-parse --short HEAD 2>/dev/null)"
  printf '# prediction commit fd5dcae at 2026-09-27, BEFORE any run here\n'
  printf 'seq\trun_id\trc\teval\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\trouter_exec\trouter_mentions\trouter_denied\tmodel_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree\n'
} > "$MANIFEST"

SPENT=0
for ((i=1;i<=N;i++)); do
  seq2="$(printf '%02d' "$i")"
  if awk -v c="$SPENT" -v k="$CEILING" 'BEGIN{exit !(c>=k)}'; then
    printf '# STOPPED at seq %s: ceiling $%s reached at $%s (exit 11)\n' "$seq2" "$CEILING" "$SPENT" >> "$MANIFEST"
    echo "stop-rule: ceiling \$$CEILING reached at \$$SPENT after $((i-1)) runs (exit 11)" >&2
    exit 11
  fi
  log="$EVID/$TASK-$seq2.log"
  echo ""; echo "======== $TASK $seq2  key=$KEY  $(date -u +%H:%M:%SZ) ========"
  # *** B9DF_RUNNER IS THE FIXTURE SET'S ONLY HOOK, and it exists because the first version of
  # case O stubbed the API instead and thereby invoked the REAL runner — which creates a worktree
  # and launches a real agent. It ran for 110 seconds before it was killed; no worktree, no
  # knowledge log and no API record were created, so nothing was spent and no unregistered run
  # exists (checked by `find` on $TMPDIR and by the API's newest run id). A fixture that can start
  # a paid run is a defect in the fixture, not a risk to accept. The overlays and the API stay real
  # under the default, exactly as B9_EVID_ROOT does for run-b9-batch.sh. ***
  ( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" "${B9DF_RUNNER:-runner/run-agent.sh}" \
      --runtime claude --benchmark "$TASK" --experiment "$KEY" --model "$MODEL" \
      --agent "$AGENT_NAME" --isolate-user-settings --keep \
      --customization "$OVERLAY" --variant agent-v1.2-knowledge-noexec ) > "$log" 2>&1
  rc=$?
  rid="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$log" | head -1 | awk '{print $2}')"
  wt="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$log" | head -1)"
  rec="$(curl -s -m 20 "$API/api/runs/${rid:-x}" 2>/dev/null)"
  kn="$(printf '%s' "$rec" | jq -r '.customization.knowledgeHash // "null"')"
  ihr="$(printf '%s' "$rec" | jq -r '.customization.instructionsHash // "null"')"
  ahr="$(printf '%s' "$rec" | jq -r '.customization.agentHash // "null"')"
  mc="$(printf '%s' "$rec" | jq -r '.behavior.modelCalls // "null"')"
  cost="$(printf '%s' "$rec" | jq -r '.efficiency.estimatedCost // "null"')"
  dur="$(printf '%s' "$rec" | jq -r '.efficiency.durationMs // "null"')"
  chg="$(printf '%s' "$rec" | jq -r 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
  ev="$(printf '%s' "$rec" | jq -r '.evaluation.exitCode // "null"')"
  # The delivery proof, outside the worktree, exactly as the registered driver reads it.
  lstate="ABSENT"; lines=0; lf=""
  [[ -n "$wt" ]] && lf="${TMPDIR:-/tmp}/knowledge-log-$(basename "$wt").jsonl"
  if [[ -n "$lf" && -f "$lf" ]]; then lstate="PRESENT"; lines="$(grep -c . "$lf" 2>/dev/null || echo 0)"; fi
  # `router_exec` is the census detector: a tool_use envelope, which the harness never emits.
  # `router_mentions` is the registered driver's looser column, kept beside it so the two can be
  # compared on the same runs — that comparison is registered clause 6.
  rx="$(/usr/bin/grep -ao '"name":"Bash","input":{"command":"[^"]*router\.sh' "$log" 2>/dev/null | /usr/bin/wc -l | tr -d ' ')"
  rmn="$(/usr/bin/grep -av 'claude args:' "$log" 2>/dev/null | /usr/bin/grep -ao 'router\.sh' | /usr/bin/wc -l | tr -d ' ')"
  rdn=no
  /usr/bin/grep -ao 'permission_denials":\[[^]]\{0,240\}' "$log" 2>/dev/null | /usr/bin/grep -q 'router\.sh' && rdn=yes
  it="$(find "$EVID/init-schema" -name "*${rid}*" 2>/dev/null | head -1)"
  if [[ -n "$it" && -r "$it" ]]; then
    it="$(sed -n 's/^init-schema: delivered //p' "$it" | head -1)/$(sed -n 's/^init-schema: verdict=//p' "$it" | head -1)"
    [[ "$it" == "/" ]] && it="UNPARSED"
  else it="NOFILE"; fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$seq2" "${rid:-none}" "$rc" "$ev" "$kn" "$ihr" "$ahr" "$lstate" "${lines:-0}" "${rx:-0}" \
    "${rmn:-0}" "$rdn" "$mc" "$cost" "$dur" "$chg" "$it" "${wt:-none}" >> "$MANIFEST"
  [[ "$cost" =~ ^[0-9]+(\.[0-9]+)?$ ]] && SPENT="$(awk -v a="$SPENT" -v b="$cost" 'BEGIN{printf "%.6f", a+b}')"
  echo "  recorded: eval=$ev log=$lstate/$lines router_exec=$rx mentions=$rmn cost=$cost  spent=\$$SPENT"
  # *** A RUN THAT PRODUCED NO RUN ID IS NOT A RUN, AND THE BATCH MUST NOT WALK PAST IT. ***
  # The first launch of this script recorded five rows of `none/1/null/null` in two seconds and
  # printed `done: 5 runs`. That is the house failure mode exactly — a control reporting success
  # over a scope smaller than it claims — and nothing downstream would have caught it, because
  # `n = 5` rows existed. The row is KEPT (§6: never delete evidence) and the batch stops here.
  if [[ -z "$rid" || "$rid" == none ]]; then
    printf '# ABORTED at seq %s: the runner produced NO run id. See %s (exit 14)\n' "$seq2" "$log" >> "$MANIFEST"
    echo "ABORT: seq $seq2 produced no run id — the runner did not start a run." >&2
    echo "  Last two lines of $log:" >&2; tail -2 "$log" >&2
    echo "  The row is recorded and the batch stops rather than filling n with nulls. (exit 14)" >&2
    exit 14
  fi
done
printf '# COMPLETE %s  n=%s  spent $%s of $%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$N" "$SPENT" "$CEILING" >> "$MANIFEST"
echo ""; echo "done: $N runs, spent \$$SPENT of \$$CEILING, manifest $MANIFEST"
exit 0
