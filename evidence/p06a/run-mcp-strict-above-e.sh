#!/usr/bin/env bash
# Stop 18 / Lab 6.5 — §4 step 13a. ARM E only.
#
# THE COMBINATION NO OTHER ARM RAN. Arms D, D2 and D3 put the .mcp.json ABOVE
# the cwd with --strict-mcp-config OFF, and arm B tested the flag against a file
# IN the cwd. Nothing tested the flag ON against a file ABOVE. The §4a review
# found that the Decision section calls the flag L2 on that unmeasured
# combination, so this arm measures it instead of softening the sentence.
#
#   cwd    : empty, no .mcp.json
#   parent : holds the .mcp.json
#   flags  : run-agent.sh's plain-run set UNMODIFIED, --strict-mcp-config ON
#
# DF5, registered in E-021 BEFORE this file existed: ABSENT on 5 of 5. A
# refutation would mean the flag filters the cwd's .mcp.json and not an
# ancestor's, which would make this stop's registered Decision wrong.
#
# A SEPARATE driver again: run-mcp-parent-dir-df.sh produced a measured arm and
# is not edited to grow one.
#
# Exit codes, every one provoked by verify-mcp-strict-above-e.sh:
#   0  arm E completed at its registered n
#   1  an unexpected internal failure (mkdir)
#   2  claude binary missing, or its version is not the registered one
#   3  probe fixtures missing, or the server fails its standalone handshake
#   5  the work directory is inside one of the three tracked repositories
#   6  another probe holds the lock
#   9  the child directory is NOT clean of .mcp.json — the arm would measure nothing
#  10  the parent directory has NO .mcp.json — the arm would measure nothing
#  12  --strict-mcp-config is absent from the constructed argv — THE ARM'S WHOLE POINT
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
WORKSPACE="$(cd "$HERE/../../.." && pwd)" || exit 1

CLAUDE_BIN="${PROBE_CLAUDE_BIN:-claude}"
EXPECT_VERSION="${PROBE_EXPECT_VERSION:-2.1.282}"
FIXTURE_DIR="${PROBE_FIXTURE_DIR:-$HERE}"
MODEL="${PROBE_MODEL:-claude-haiku-4-5-20251001}"
DRY_RUN="${PROBE_DRY_RUN:-0}"
N="${PROBE_N:-5}"
LOCK="${PROBE_LOCK:-/tmp/stop18-mcp-probe.lock}"
SKIP_SETUP="${PROBE_SKIP_SETUP:-0}"
OMIT_STRICT="${PROBE_OMIT_STRICT:-0}"   # fixture-only, to provoke guard 12

TS="$(date -u +%Y%m%dT%H%M%SZ)"
WORKDIR="${PROBE_WORKDIR:-/tmp/stop18-mcp-strict-above-$TS}"
EVID="${PROBE_EVIDENCE:-$HERE/arm-e-$TS}"
PROMPT='Reply with the single word READY and nothing else.'

die() { printf 'arm-e: %s\n' "$2" >&2; exit "$1"; }

command -v "$CLAUDE_BIN" >/dev/null 2>&1 || die 2 "claude binary not found: $CLAUDE_BIN"
GOT_VERSION="$("$CLAUDE_BIN" --version 2>/dev/null | awk '{print $1}')"
[[ "$GOT_VERSION" == "$EXPECT_VERSION" ]] \
  || die 2 "claude version is '$GOT_VERSION', registered is '$EXPECT_VERSION'"

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

for repo in agent-learning-lab agent-observatory agent-observatory-benchmarks; do
  case "$WORKDIR/" in
    "$WORKSPACE/$repo/"*) die 5 "work directory is inside the tracked repo $repo: $WORKDIR" ;;
  esac
done

if ! mkdir "$LOCK" 2>/dev/null; then die 6 "another probe holds the lock: $LOCK"; fi
# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rmdir "$LOCK" 2>/dev/null || true; }
trap cleanup EXIT

PARENT="$WORKDIR/parent"
CHILD="$PARENT/child"
mkdir -p "$CHILD" "$EVID" || die 1 "cannot create directories"
if [[ "$SKIP_SETUP" != "1" ]]; then
  cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"
  sed "s|__PROBE_SERVER_PATH__|$WORKDIR/probe_server.py|" "$MCPJSON_FIXTURE" > "$PARENT/.mcp.json"
  # The post-cp existence check the §4a review asked arm D's driver for.
  [[ -s "$WORKDIR/probe_server.py" ]] || die 3 "probe server did not survive the copy"
fi

[[ -e "$CHILD/.mcp.json" ]] && die 9 "child directory is NOT clean: $CHILD/.mcp.json exists"
[[ -f "$PARENT/.mcp.json" ]] || die 10 "parent directory has NO .mcp.json: $PARENT"

# run-agent.sh's plain-run claude set, UNMODIFIED. --strict-mcp-config is the
# whole arm, so its presence is asserted rather than assumed.
args=(--permission-mode acceptEdits
      --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
      --disable-slash-commands
      --setting-sources project)
[[ "$OMIT_STRICT" == "1" ]] || args+=(--strict-mcp-config)
args+=(--model "$MODEL" --output-format stream-json --verbose -p "$PROMPT")

printf '%s\n' "${args[@]}" | grep -qx -- '--strict-mcp-config' \
  || die 12 "--strict-mcp-config is absent from the argv; this arm would measure arm D"

printf '%s\n' "$PROMPT" > "$EVID/PROMPT.txt"
{
  printf 'arm        : E\n'
  printf 'claude     : %s\n' "$("$CLAUDE_BIN" --version 2>&1)"
  printf 'model      : %s\n' "$MODEL"
  printf 'file at    : %s   (one level ABOVE the cwd)\n' "$PARENT/.mcp.json"
  printf 'cwd        : %s   (empty)\n' "$CHILD"
  printf 'strict flag: PRESENT — asserted by guard 12, not assumed\n'
  printf 'sha256 parent/.mcp.json : %s\n' "$(shasum -a 256 "$PARENT/.mcp.json" | awk '{print $1}')"
} > "$EVID/HASHES.txt"

printf 'arm\ti\tcwd\tstarted_at\tfinished_at\ttool_present\tserver_present\tmcp_tool_count\tpermission_denials\tcost_usd\tnote\n' \
  > "$EVID/RESULT.tsv"
printf '%s\n' "${args[@]}" > "$EVID/argv-E.txt"

SPENT=0
for ((i = 1; i <= N; i++)); do
  if [[ "$DRY_RUN" == "1" ]]; then
    printf 'E\t%s\t%s\tdry\tdry\tdry\tdry\tdry\tdry\t0\tdry-run\n' "$i" "$CHILD" >> "$EVID/RESULT.tsv"
    continue
  fi
  stream="$EVID/stream-E-$i.jsonl"
  started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  ( cd "$CHILD" || exit 1; "$CLAUDE_BIN" "${args[@]}" ) > "$stream" 2>"$EVID/stderr-E-$i.txt"
  finished="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  init="$EVID/init-E-$i.json"
  jq -c 'select(.type=="system" and .subtype=="init") | {cwd:.cwd, tools:.tools, mcp_servers:.mcp_servers}' \
    < "$stream" > "$init" 2>/dev/null || true
  if [[ ! -s "$init" ]]; then
    printf 'E\t%s\t%s\t%s\t%s\tna\tna\tna\tna\t0\tno-init\n' "$i" "$CHILD" "$started" "$finished" >> "$EVID/RESULT.tsv"
    continue
  fi

  if grep -q 'mcp__stop18probe__' "$init"; then tool_present=yes; else tool_present=no; fi
  server_present="$(jq -r '[.mcp_servers[]?.name] | index("stop18probe") | if . == null then "no" else "yes" end' < "$init")"
  mcp_count="$(jq -r '[.tools[]? | select(startswith("mcp__"))] | length' < "$init")"
  # has() first, so an ABSENT key is distinguishable from an empty array — the
  # §4a review's non-blocking finding on arm D's driver, fixed here rather than
  # retrofitted into a file whose runs are already on disk.
  if [[ "$(jq -r 'select(.type=="result") | has("permission_denials")' < "$stream" | tail -1)" == "true" ]]; then
    denials="$(jq -r 'select(.type=="result") | .permission_denials | length' < "$stream" | tail -1)"
  else
    denials="absent"
  fi
  cost="$(jq -r 'select(.type=="result") | .total_cost_usd // empty' < "$stream" | tail -1)"
  [[ -n "$cost" ]] || cost=0
  note=ok
  if jq -e 'select(.type=="rate_limit_event") | select(.rate_limit_info.status != "allowed")' \
       < "$stream" >/dev/null 2>&1; then note="f13-candidate"; fi

  printf 'E\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$i" "$CHILD" "$started" "$finished" "$tool_present" "$server_present" \
    "$mcp_count" "$denials" "$cost" "$note" >> "$EVID/RESULT.tsv"
  SPENT="$(python3 -c "print(round($SPENT + $cost, 6))")"
  printf 'arm-e: E/%s done, spent $%s\n' "$i" "$SPENT"
done

printf 'spent_usd: %s\n' "$SPENT" >> "$EVID/HASHES.txt"
printf 'arm-e: evidence in %s\n' "$EVID"
exit 0
