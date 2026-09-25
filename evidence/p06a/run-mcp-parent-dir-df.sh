#!/usr/bin/env bash
# Stop 18 / Lab 6.5 — §4 step 9, the deliberate failure. ARM D only.
#
# Arm A proved a project-scope .mcp.json IN THE RUN'S OWN CWD loads under
# `claude -p` without the documented approval prompt. Arm D asks the question
# that decides how wide that hole is for THIS project, whose every benchmark run
# happens in a worktree nested inside a tree the operator controls: does the
# loader walk UPWARD?
#
#   cwd    : empty, no .mcp.json
#   parent : holds the .mcp.json
#   flags  : arm A's, exactly
#
# Registered in E-021 "Deliberate failure" BEFORE this file existed:
# DF1/DF2 predict the probe tool and the server ABSENT on 5 of 5.
#
# A SEPARATE driver on purpose. run-mcp-hole-probe.sh produced a measured batch
# and is not edited to grow an arm — the same reasoning the B8a batch recorded
# when it re-derived its F13 column post-hoc rather than patching a driver whose
# runs were already on disk.
#
# Exit codes, every one provoked by a fixture in verify-mcp-parent-dir-df.sh:
#   0  arm D completed at its registered n
#   2  claude binary missing, or its version is not the registered one
#   3  probe server fixture missing, or it fails its standalone handshake
#   5  the work directory is inside one of the three tracked repositories
#   6  another probe holds the lock
#   9  the child directory is NOT empty of .mcp.json — the arm would measure nothing
#  10  the parent directory has NO .mcp.json — the arm would measure nothing
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

TS="$(date -u +%Y%m%dT%H%M%SZ)"
WORKDIR="${PROBE_WORKDIR:-/tmp/stop18-mcp-df-$TS}"
EVID="${PROBE_EVIDENCE:-$HERE/deliberate-failure-$TS}"
PROMPT='Reply with the single word READY and nothing else.'

say() { printf '%s\n' "$*"; }
die() { printf 'df-probe: %s\n' "$2" >&2; exit "$1"; }

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

if ! mkdir "$LOCK" 2>/dev/null; then
  die 6 "another probe holds the lock: $LOCK"
fi
# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rmdir "$LOCK" 2>/dev/null || true; }
trap cleanup EXIT

PARENT="$WORKDIR/parent"
CHILD="$PARENT/child"
if [[ "$SKIP_SETUP" != "1" ]]; then
  mkdir -p "$CHILD" "$EVID" || die 1 "cannot create directories"
  cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"
  # THE .mcp.json GOES IN THE PARENT. That is the entire arm.
  sed "s|__PROBE_SERVER_PATH__|$WORKDIR/probe_server.py|" "$MCPJSON_FIXTURE" > "$PARENT/.mcp.json"
else
  mkdir -p "$CHILD" "$EVID" || die 1 "cannot create directories"
fi

# --- the two guards that make this arm mean something ----------------------
# Without them a null is indistinguishable from a probe that was never planted,
# which is the same failure shape arm P exists to close for arms A and B.
[[ -e "$CHILD/.mcp.json" ]] && die 9 "child directory is NOT clean: $CHILD/.mcp.json exists"
[[ -f "$PARENT/.mcp.json" ]] || die 10 "parent directory has NO .mcp.json: $PARENT"

printf '%s\n' "$PROMPT" > "$EVID/PROMPT.txt"
{
  say "df run     : $TS"
  say "claude     : $("$CLAUDE_BIN" --version 2>&1)"
  say "model      : $MODEL"
  say "parent     : $PARENT   (holds .mcp.json)"
  say "child/cwd  : $CHILD    (empty)"
  say "sha256 parent/.mcp.json : $(shasum -a 256 "$PARENT/.mcp.json" | awk '{print $1}')"
} > "$EVID/HASHES.txt"

printf 'arm\ti\tcwd\tstarted_at\tfinished_at\ttool_present\tserver_present\tmcp_tool_count\tpermission_denials\tcost_usd\tnote\n' \
  > "$EVID/RESULT.tsv"

SPENT=0
for ((i = 1; i <= N; i++)); do
  # Arm A's flag set, exactly: no --strict-mcp-config.
  args=(--permission-mode acceptEdits
        --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
        --disable-slash-commands
        --setting-sources project
        --model "$MODEL"
        --output-format stream-json --verbose
        -p "$PROMPT")
  printf '%s\n' "${args[@]}" > "$EVID/argv-D-$i.txt"

  if [[ "$DRY_RUN" == "1" ]]; then
    printf 'D\t%s\t%s\tdry\tdry\tdry\tdry\tdry\tdry\t0\tdry-run\n' "$i" "$CHILD" >> "$EVID/RESULT.tsv"
    continue
  fi

  stream="$EVID/stream-D-$i.jsonl"
  started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  ( cd "$CHILD" || exit 1; "$CLAUDE_BIN" "${args[@]}" ) > "$stream" 2>"$EVID/stderr-D-$i.txt"
  finished="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  init="$EVID/init-D-$i.json"
  jq -c 'select(.type=="system" and .subtype=="init") | {cwd:.cwd, tools:.tools, mcp_servers:.mcp_servers}' \
    < "$stream" > "$init" 2>/dev/null || true

  if [[ ! -s "$init" ]]; then
    printf 'D\t%s\t%s\t%s\t%s\tna\tna\tna\tna\t0\tno-init\n' "$i" "$CHILD" "$started" "$finished" >> "$EVID/RESULT.tsv"
    continue
  fi

  if grep -q 'mcp__stop18probe__' "$init"; then tool_present=yes; else tool_present=no; fi
  server_present="$(jq -r '[.mcp_servers[]?.name] | index("stop18probe") | if . == null then "no" else "yes" end' < "$init")"
  mcp_count="$(jq -r '[.tools[]? | select(startswith("mcp__"))] | length' < "$init")"
  denials="$(jq -r 'select(.type=="result") | .permission_denials | length' < "$stream" | tail -1)"
  [[ -n "$denials" ]] || denials=na
  cost="$(jq -r 'select(.type=="result") | .total_cost_usd // empty' < "$stream" | tail -1)"
  [[ -n "$cost" ]] || cost=0

  note=ok
  if jq -e 'select(.type=="rate_limit_event") | select(.rate_limit_info.status != "allowed")' \
       < "$stream" >/dev/null 2>&1; then
    note="f13-candidate"
  fi

  printf 'D\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$i" "$CHILD" "$started" "$finished" "$tool_present" "$server_present" \
    "$mcp_count" "$denials" "$cost" "$note" >> "$EVID/RESULT.tsv"

  SPENT="$(python3 -c "print(round($SPENT + $cost, 6))")"
  say "df-probe: D/$i done, spent \$$SPENT"
done

say "spent_usd: $SPENT" >> "$EVID/HASHES.txt"
say "df-probe: evidence in $EVID"
exit 0
