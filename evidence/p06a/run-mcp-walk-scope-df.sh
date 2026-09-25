#!/usr/bin/env bash
# Stop 18 / Lab 6.5 — §4 step 9 extension. Arms D2 and D3.
#
# Arm D refuted DF1/DF2 at 5 of 5: a .mcp.json ONE directory above an empty cwd
# loads under `claude -p`. How far above decides whether this project's own runs
# are exposed, because every benchmark run happens in a git worktree nested
# under directories the operator controls.
#
#   D2  .mcp.json at the top, cwd THREE plain directories below, no git anywhere
#   D3  .mcp.json at the top, cwd TWO levels below and itself a `git init` repo
#
# DF3/DF4 registered in E-021 BEFORE this file existed: both predict PRESENT on
# 5 of 5. DF4 is written to be wrong in the direction that would be good news.
#
# Exit codes, every one provoked by verify-mcp-walk-scope-df.sh:
#   0  the arm completed at its registered n
#   2  claude binary missing, or its version is not the registered one
#   3  probe fixtures missing, or the server fails its standalone handshake
#   5  the work directory is inside one of the three tracked repositories
#   6  another probe holds the lock
#   7  an unknown arm was requested
#   9  a .mcp.json exists at or below the cwd — the arm would measure nothing
#  11  arm D3's cwd is not a git repository — the arm would measure nothing
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
WORKSPACE="$(cd "$HERE/../../.." && pwd)" || exit 1

CLAUDE_BIN="${PROBE_CLAUDE_BIN:-claude}"
EXPECT_VERSION="${PROBE_EXPECT_VERSION:-2.1.282}"
FIXTURE_DIR="${PROBE_FIXTURE_DIR:-$HERE}"
MODEL="${PROBE_MODEL:-claude-haiku-4-5-20251001}"
DRY_RUN="${PROBE_DRY_RUN:-0}"
N="${PROBE_N:-5}"
ARM="${PROBE_ARM:-D2}"
LOCK="${PROBE_LOCK:-/tmp/stop18-mcp-probe.lock}"
SKIP_SETUP="${PROBE_SKIP_SETUP:-0}"

TS="$(date -u +%Y%m%dT%H%M%SZ)"
WORKDIR="${PROBE_WORKDIR:-/tmp/stop18-mcp-walk-$ARM-$TS}"
EVID="${PROBE_EVIDENCE:-$HERE/walk-scope-$ARM-$TS}"
PROMPT='Reply with the single word READY and nothing else.'

die() { printf 'walk-probe: %s\n' "$2" >&2; exit "$1"; }

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

case "$ARM" in D2|D3) : ;; *) die 7 "unknown arm: $ARM (known: D2, D3)" ;; esac

for repo in agent-learning-lab agent-observatory agent-observatory-benchmarks; do
  case "$WORKDIR/" in
    "$WORKSPACE/$repo/"*) die 5 "work directory is inside the tracked repo $repo: $WORKDIR" ;;
  esac
done

if ! mkdir "$LOCK" 2>/dev/null; then die 6 "another probe holds the lock: $LOCK"; fi
# shellcheck disable=SC2329  # invoked indirectly by the EXIT trap below
cleanup() { rmdir "$LOCK" 2>/dev/null || true; }
trap cleanup EXIT

TOP="$WORKDIR/top"
if [[ "$ARM" == "D2" ]]; then
  CWD="$TOP/a/b/c"                 # three plain directories below the file
else
  CWD="$TOP/a/repo"                # two levels below, and a git repository
fi

mkdir -p "$CWD" "$EVID" || die 1 "cannot create directories"
if [[ "$SKIP_SETUP" != "1" ]]; then
  cp "$SERVER_FIXTURE" "$WORKDIR/probe_server.py"
  sed "s|__PROBE_SERVER_PATH__|$WORKDIR/probe_server.py|" "$MCPJSON_FIXTURE" > "$TOP/.mcp.json"
  if [[ "$ARM" == "D3" ]]; then
    ( cd "$CWD" && git init -q && git config user.email p@p && git config user.name p \
      && : > README.md && git add README.md && git commit -qm init ) >/dev/null 2>&1
  fi
fi

# The guards that make the arm mean something: no .mcp.json at or below the cwd,
# and for D3 the cwd really is a git repository.
DIR="$CWD"
while [[ "$DIR" != "$TOP" && "$DIR" != "/" ]]; do
  [[ -e "$DIR/.mcp.json" ]] && die 9 "a .mcp.json exists at or below the cwd: $DIR/.mcp.json"
  DIR="$(dirname "$DIR")"
done
if [[ "$ARM" == "D3" ]]; then
  [[ -d "$CWD/.git" ]] || die 11 "arm D3's cwd is not a git repository: $CWD"
fi

printf '%s\n' "$PROMPT" > "$EVID/PROMPT.txt"
{
  printf 'arm        : %s\n' "$ARM"
  printf 'claude     : %s\n' "$("$CLAUDE_BIN" --version 2>&1)"
  printf 'file at    : %s\n' "$TOP/.mcp.json"
  printf 'cwd        : %s\n' "$CWD"
  printf 'levels up  : %s\n' "$(python3 -c "
import os,sys
print(len(os.path.relpath(sys.argv[1], sys.argv[2]).split(os.sep)))" "$CWD" "$TOP")"
  printf 'cwd is git : %s\n' "$([[ -d "$CWD/.git" ]] && echo yes || echo no)"
  printf 'sha256 top/.mcp.json : %s\n' "$(shasum -a 256 "$TOP/.mcp.json" 2>/dev/null | awk '{print $1}')"
} > "$EVID/HASHES.txt"

printf 'arm\ti\tcwd\tlevels_up\tcwd_is_git\ttool_present\tserver_present\tmcp_tool_count\tpermission_denials\tcost_usd\tnote\n' \
  > "$EVID/RESULT.tsv"

LEVELS="$(python3 -c "
import os,sys
print(len(os.path.relpath(sys.argv[1], sys.argv[2]).split(os.sep)))" "$CWD" "$TOP")"
IS_GIT="$([[ -d "$CWD/.git" ]] && echo yes || echo no)"
SPENT=0

for ((i = 1; i <= N; i++)); do
  args=(--permission-mode acceptEdits
        --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
        --disable-slash-commands
        --setting-sources project
        --model "$MODEL"
        --output-format stream-json --verbose
        -p "$PROMPT")
  printf '%s\n' "${args[@]}" > "$EVID/argv-$ARM-$i.txt"

  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\t%s\t%s\t%s\t%s\tdry\tdry\tdry\tdry\t0\tdry-run\n' \
      "$ARM" "$i" "$CWD" "$LEVELS" "$IS_GIT" >> "$EVID/RESULT.tsv"
    continue
  fi

  stream="$EVID/stream-$ARM-$i.jsonl"
  ( cd "$CWD" || exit 1; "$CLAUDE_BIN" "${args[@]}" ) > "$stream" 2>"$EVID/stderr-$ARM-$i.txt"

  init="$EVID/init-$ARM-$i.json"
  jq -c 'select(.type=="system" and .subtype=="init") | {cwd:.cwd, tools:.tools, mcp_servers:.mcp_servers}' \
    < "$stream" > "$init" 2>/dev/null || true
  if [[ ! -s "$init" ]]; then
    printf '%s\t%s\t%s\t%s\t%s\tna\tna\tna\tna\t0\tno-init\n' \
      "$ARM" "$i" "$CWD" "$LEVELS" "$IS_GIT" >> "$EVID/RESULT.tsv"
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
       < "$stream" >/dev/null 2>&1; then note="f13-candidate"; fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$ARM" "$i" "$CWD" "$LEVELS" "$IS_GIT" "$tool_present" "$server_present" \
    "$mcp_count" "$denials" "$cost" "$note" >> "$EVID/RESULT.tsv"
  SPENT="$(python3 -c "print(round($SPENT + $cost, 6))")"
  printf 'walk-probe: %s/%s done, spent $%s\n' "$ARM" "$i" "$SPENT"
done

printf 'spent_usd: %s\n' "$SPENT" >> "$EVID/HASHES.txt"
printf 'walk-probe: evidence in %s\n' "$EVID"
exit 0
