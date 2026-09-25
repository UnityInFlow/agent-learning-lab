#!/usr/bin/env bash
# Stop 18 / Lab 6.5 — the print-mode MCP hole. Driver for E-021.
#
# Registered outcome, per run: does `mcp__stop18probe__` appear in the run's OWN
# system/init stream-json record. Never inferred from the flag being on the
# command line — E-005 measured `Read, Grep, Glob, Bash` delivered as
# ["Read","Bash"] on 10 of 10 runs, and the delivered set is the only truth.
#
# Arms (E-021 "Independent variable"):
#   P  positive control  runner flags + --strict-mcp-config + --mcp-config <probe>
#   A  hole arm          runner flags MINUS --strict-mcp-config
#   B  harness as-is     runner flags exactly as run-agent.sh runs them
#   X  contingency (A')  arm A minus --setting-sources project
#
# Exit codes — every one of them provoked by a fixture in
# verify-mcp-hole-probe-guards.sh, because a control that has never been shown
# to reject anything is indistinguishable from one that rejects nothing.
#   0  batch completed at its registered n
#   2  claude binary missing, or its version is not the registered one
#   3  probe server fixture missing, or it fails its standalone handshake
#   4  the runner's claude flag block has changed since E-021 copied it
#   5  the work directory is inside one of the three tracked repositories
#   6  another probe holds the lock
#   7  an unknown arm was requested
#   8  the budget ceiling was reached; the population that occurred is reported
#   1  an unexpected internal failure (mkdir of the evidence or work directory).
#      Added to this list at §4 step 13a from
#      findings/opencode/review-run-mcp-hole-probe-20260925T191443Z.md (blocking, 2/2), which
#      found `die 1` in use and absent from the header. It never fired.
#
# KNOWN SCOPE LIMITS, recorded rather than fixed, because this file produced a measured batch
# and editing it after the fact would mean the committed driver is not the one that ran.
# All four are from the §4a review of 2026-09-25; none changes a recorded value.
#
#   (a) GUARD 3 CHECKS PRESENCE, NOT ABSENCE. It asserts six flag lines are still in
#       run-agent.sh. It would NOT notice the runner ADDING a seventh, so arm B could drift
#       from the real plain-run launch without the guard firing. Closed for THIS stop by hand:
#       the runner's block at :774-792 adds exactly `--model` (which this driver passes) and
#       `--agent` (added only when AGENT_NAME is set, i.e. never on a plain run, which is what
#       arm B mirrors). A hash of the block would be the fix; it is not applied here.
#   (b) THE APPROVAL DETECTOR HAS NEVER BEEN SHOWN TO FIRE. It greps four strings that do not
#       appear in this stream format on any of the 26 runs, and under --permission-mode
#       acceptEdits a `can_use_tool` would be an auto-approval rather than a prompt anyway. It
#       is NOT what proves E-021's prediction 4; `result.permission_denials == []` and the
#       servers reaching `connected` with their tools delivered are. E-021's Failure analysis
#       says this at length. The column is kept because deleting a column changes a file that
#       produced measured runs.
#   (c) MULTIPLE init RECORDS WOULD SPLIT A TSV ROW. `jq -c` emits one line per matching
#       record, so two init records would embed a newline in one logical row. Checked across
#       all 26 init files: every one holds EXACTLY ONE record, so it did not occur.
#   (d) WHY THIS RECONSTRUCTS THE RUNNER'S FLAGS INSTEAD OF CALLING run-agent.sh. The runner
#       needs a benchmark id, a git worktree, an experiment key and an observatory it can post
#       a run record to. This lab needs none of them and must run in a throwaway directory
#       outside every tracked tree — and `customization.mcpHash` is null by construction, so
#       there is no field in a run record that could have carried this measurement anyway.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
WORKSPACE="$(cd "$HERE/../../.." && pwd)" || exit 1

CLAUDE_BIN="${PROBE_CLAUDE_BIN:-claude}"
EXPECT_VERSION="${PROBE_EXPECT_VERSION:-2.1.282}"
RUNNER="${PROBE_RUNNER:-$WORKSPACE/agent-observatory/runner/run-agent.sh}"
FIXTURE_DIR="${PROBE_FIXTURE_DIR:-$HERE}"
MODEL="${PROBE_MODEL:-claude-haiku-4-5-20251001}"
BUDGET="${PROBE_BUDGET:-0.50}"
DRY_RUN="${PROBE_DRY_RUN:-0}"
ARMS="${PROBE_ARMS:-P,A,B}"
N="${PROBE_N:-5}"
LOCK="${PROBE_LOCK:-/tmp/stop18-mcp-probe.lock}"

TS="$(date -u +%Y%m%dT%H%M%SZ)"
WORKDIR="${PROBE_WORKDIR:-/tmp/stop18-mcp-probe-$TS}"
EVID="${PROBE_EVIDENCE:-$HERE/mcp-hole-probe-$TS}"

# The nine-word prompt, identical in every arm. The init record is emitted
# before the model does any work, so the answer is irrelevant and the cost is
# dominated by session start-up.
PROMPT='Reply with the single word READY and nothing else.'

say() { printf '%s\n' "$*"; }
die() { printf 'probe: %s\n' "$2" >&2; exit "$1"; }

# --- guard 1: the claude binary and its version -----------------------------
command -v "$CLAUDE_BIN" >/dev/null 2>&1 \
  || die 2 "claude binary not found: $CLAUDE_BIN"
GOT_VERSION="$("$CLAUDE_BIN" --version 2>/dev/null | awk '{print $1}')"
[[ "$GOT_VERSION" == "$EXPECT_VERSION" ]] \
  || die 2 "claude version is '$GOT_VERSION', registered is '$EXPECT_VERSION'"

# --- guard 2: the probe server exists and answers the handshake -------------
SERVER_FIXTURE="$FIXTURE_DIR/probe_server.py.fixture"
MCPJSON_FIXTURE="$FIXTURE_DIR/mcp.json.fixture"
[[ -f "$SERVER_FIXTURE" ]] || die 3 "probe server fixture missing: $SERVER_FIXTURE"
[[ -f "$MCPJSON_FIXTURE" ]] || die 3 "mcp.json fixture missing: $MCPJSON_FIXTURE"
HANDSHAKE="$(printf '%s\n%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"guard","version":"1"}}}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
  | python3 "$SERVER_FIXTURE" 2>/dev/null)"
case "$HANDSHAKE" in
  *'"name": "probe_marker"'*|*'"name":"probe_marker"'*) : ;;
  *) die 3 "probe server did not answer tools/list with probe_marker" ;;
esac

# --- guard 3: the runner's flag block is still the one E-021 copied ---------
[[ -f "$RUNNER" ]] || die 4 "runner not found: $RUNNER"
while IFS= read -r want; do
  [[ -n "$want" ]] || continue
  grep -qF -- "$want" "$RUNNER" \
    || die 4 "runner flag block changed; missing line: $want"
done <<'FLAGS'
--permission-mode acceptEdits
--strict-mcp-config
--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
CLAUDE_ARGS+=(--disable-slash-commands)
CLAUDE_ARGS+=(--setting-sources project)
--output-format stream-json --verbose
FLAGS

# --- guard 4: no .mcp.json is ever written inside a tracked tree ------------
for repo in agent-learning-lab agent-observatory agent-observatory-benchmarks; do
  case "$WORKDIR/" in
    "$WORKSPACE/$repo/"*) die 5 "work directory is inside the tracked repo $repo: $WORKDIR" ;;
  esac
done

# --- guard 5: one probe at a time -------------------------------------------
if ! mkdir "$LOCK" 2>/dev/null; then
  die 6 "another probe holds the lock: $LOCK"
fi
# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rmdir "$LOCK" 2>/dev/null || true; }
trap cleanup EXIT

# --- guard 6: every requested arm is one we defined -------------------------
IFS=',' read -r -a ARM_LIST <<< "$ARMS"
for arm in "${ARM_LIST[@]}"; do
  case "$arm" in
    P|A|B|X) : ;;
    *) die 7 "unknown arm: $arm (known: P, A, B, X)" ;;
  esac
done

mkdir -p "$EVID" "$WORKDIR" || die 1 "cannot create evidence or work directory"
SERVER="$WORKDIR/probe_server.py"
cp "$SERVER_FIXTURE" "$SERVER"
sed "s|__PROBE_SERVER_PATH__|$SERVER|" "$MCPJSON_FIXTURE" > "$WORKDIR/mcp-config.json"
printf '%s\n' "$PROMPT" > "$EVID/PROMPT.txt"

{
  say "probe run  : $TS"
  say "claude     : $("$CLAUDE_BIN" --version 2>&1)"
  say "model      : $MODEL"
  say "runner     : $RUNNER"
  say "runner sha : $(cd "$(dirname "$RUNNER")" && git rev-parse HEAD 2>/dev/null | cut -c1-12)"
  say "workdir    : $WORKDIR"
  say "arms       : $ARMS   n=$N   budget=\$$BUDGET   dry_run=$DRY_RUN"
  say "sha256 probe_server.py.fixture : $(shasum -a 256 "$SERVER_FIXTURE" | awk '{print $1}')"
  say "sha256 mcp.json.fixture        : $(shasum -a 256 "$MCPJSON_FIXTURE" | awk '{print $1}')"
  say "sha256 mcp-config.json (subst) : $(shasum -a 256 "$WORKDIR/mcp-config.json" | awk '{print $1}')"
} > "$EVID/HASHES.txt"

printf 'arm\ti\trun_dir\tstarted_at\tfinished_at\ttool_present\tserver_present\tserver_status\tapproval_event\tcost_usd\tnote\n' \
  > "$EVID/RESULT.tsv"

SPENT=0
CEILING_HIT=0

run_one() {
  local arm="$1" i="$2"
  local rd="$WORKDIR/run-$arm-$i"
  mkdir -p "$rd"
  # The project-scope .mcp.json, in the run's own cwd. Identical bytes in every
  # arm: the one variable is the flag, never the file.
  cp "$WORKDIR/mcp-config.json" "$rd/.mcp.json"

  local args=(--permission-mode acceptEdits
              --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
              --disable-slash-commands)
  case "$arm" in
    P) args+=(--setting-sources project --strict-mcp-config --mcp-config "$WORKDIR/mcp-config.json") ;;
    A) args+=(--setting-sources project) ;;
    B) args+=(--setting-sources project --strict-mcp-config) ;;
    X) : ;;  # A' — the ONE arm that drops --setting-sources project
  esac
  args+=(--model "$MODEL" --output-format stream-json --verbose -p "$PROMPT")

  printf '%s\n' "${args[@]}" > "$EVID/argv-$arm-$i.txt"

  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$arm" "$i" "$rd" "dry" "dry" "dry" "dry" "dry" "dry" "0" "dry-run" >> "$EVID/RESULT.tsv"
    return 0
  fi

  local started finished stream
  stream="$EVID/stream-$arm-$i.jsonl"
  started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  ( cd "$rd" || exit 1; "$CLAUDE_BIN" "${args[@]}" ) > "$stream" 2>"$EVID/stderr-$arm-$i.txt"
  finished="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  local init tool_present server_present server_status approval cost note
  init="$EVID/init-$arm-$i.json"
  jq -c 'select(.type=="system" and .subtype=="init") | {tools:.tools, mcp_servers:.mcp_servers}' \
    < "$stream" > "$init" 2>/dev/null || true

  if [[ ! -s "$init" ]]; then
    note="no-init"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$arm" "$i" "$rd" "$started" "$finished" "na" "na" "na" "na" "0" "$note" >> "$EVID/RESULT.tsv"
    return 0
  fi

  if grep -q 'mcp__stop18probe__' "$init"; then tool_present=yes; else tool_present=no; fi
  server_present="$(jq -r '[.mcp_servers[]?.name] | index("stop18probe") | if . == null then "no" else "yes" end' < "$init")"
  server_status="$(jq -r '[.mcp_servers[]? | select(.name=="stop18probe") | .status] | .[0] // "none"' < "$init")"

  # Prediction 4: no approval/permission event anywhere in the stream.
  if grep -qE '"(can_use_tool|permission_request|permission_denial)"|approve this MCP|Do you want to (use|allow)' "$stream"; then
    approval=yes
  else
    approval=no
  fi

  cost="$(jq -r 'select(.type=="result") | .total_cost_usd // empty' < "$stream" | tail -1)"
  [[ -n "$cost" ]] || cost=0

  # F13 (rate limit) is decided STRUCTURALLY, never by a substring. The first
  # version of this line grepped for `rate.?limit` and flagged the preflight
  # run, whose stream carries a routine `rate_limit_event` with
  # `"status":"allowed"` — an event that says the run was NOT limited. A
  # detector that fires on every run is as useless as one that fires on none,
  # and it would have moved runs into Exclusions that belong in the population.
  # Corrected before the batch, with no run in flight (§4 step 4); the
  # preflight's own RESULT.tsv is NOT rewritten (§4 step 12) — see
  # preflight-*/NOTE-f13-false-positive.md.
  note=ok
  if jq -e 'select(.type=="rate_limit_event") | select(.rate_limit_info.status != "allowed")' \
       < "$stream" >/dev/null 2>&1; then
    note="f13-candidate"
  elif jq -e 'select(.type=="result") | select(.is_error == true)' \
       < "$stream" >/dev/null 2>&1; then
    note="result-is-error"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$arm" "$i" "$rd" "$started" "$finished" "$tool_present" "$server_present" \
    "$server_status" "$approval" "$cost" "$note" >> "$EVID/RESULT.tsv"

  SPENT="$(python3 -c "print(round($SPENT + $cost, 6))")"
}

for arm in "${ARM_LIST[@]}"; do
  reps="$N"
  [[ "$arm" == "P" ]] && reps=1
  for ((i = 1; i <= reps; i++)); do
    # Evaluated in dry run too, so the ceiling has a fixture that provokes it
    # without spending: SPENT stays 0 there and only PROBE_BUDGET=0 fires it.
    if python3 -c "import sys; sys.exit(0 if $SPENT >= $BUDGET else 1)"; then
      CEILING_HIT=1
      say "probe: budget ceiling \$$BUDGET reached at \$$SPENT — stopping, reporting the population that occurred"
      break 2
    fi
    run_one "$arm" "$i"
    say "probe: $arm/$i done, spent \$$SPENT"
  done
done

{
  say "spent_usd: $SPENT"
  say "ceiling_usd: $BUDGET"
  say "ceiling_hit: $CEILING_HIT"
  say "claude_after: $("$CLAUDE_BIN" --version 2>&1)"
} >> "$EVID/HASHES.txt"

say "probe: evidence in $EVID"
[[ "$CEILING_HIT" == "1" ]] && exit 8
exit 0
