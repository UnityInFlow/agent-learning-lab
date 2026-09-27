#!/usr/bin/env bash
#
# probe-router-permission — why the B9 preflight's condition (ii) failed, and which of two fixes
# actually works. A stop-8-style flag probe: cheap, model-level, and it answers a question no
# amount of reading the code can close.
#
# WHAT THE PREFLIGHT FOUND. On BE-003 treated run fbdebf75-03e2-4b3a-ab49-cb44af946f35 the agent
# DID call the router, on its own initiative, at its first opportunity:
#     .ai/knowledge/router.sh "state transition validation error codes" 2>&1
# and that call appears in the run's `permission_denials` array. The repair-limit hook recorded
# NINE allows and ZERO blocks, so the treatment's own hooks did not refuse it. What refused it is
# the runner's own allowlist: run-agent.sh:798-800 passes
#     --permission-mode acceptEdits --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
# and in `claude -p` there is no human to approve anything else. So EVERY Bash command that is not
# mvn is denied, the router can never execute, and the batch would have recorded H = 0 and reported
# `VOID — an L3 instruction nobody acted on` about an agent that acted on it immediately.
#
# THE TWO CANDIDATE FIXES, and the probe exists because they are not equivalent:
#   (A) a `permissions.allow` entry in the OVERLAY's .claude/settings.json — the treatment carrying
#       its own precondition, loaded because the runner passes --setting-sources project;
#   (B) a new entry in the RUNNER's --allowedTools — a change to a harness variable held constant
#       since B2, inherited by every later stop.
# (A) is preferable if it works at all. Whether a project-scope permission rule is UNIONED with
# --allowedTools is a property of the runtime, not of this repository, and stop 9 is the reason it
# gets probed rather than assumed: a four-name `tools:` list was delivered as two on 10 of 10 runs.
#
# THE ARMS, three claude -p runs of nine words of work each, with the runner's exact claude flags:
#   1 BASELINE   overlay settings as shipped              -> expect DENIED, no log line
#   2 OVERLAY    settings + permissions.allow for the router -> (A) works iff this executes
#   3 CLI        settings as shipped + --allowedTools entry   -> (B) works iff this executes
#
# Usage: evidence/b09/probe-router-permission.sh
# Exit:  0 the probe ran; read RESULT.md. Non-zero only on a setup failure.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OVL="$LAB/build/customizations/agent-v1.2-knowledge"
MODEL="claude-haiku-4-5-20251001"
TAG="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$LAB/evidence/b09/router-permission-probe-$TAG"
mkdir -p "$OUT"
PROMPT='Run the command .ai/knowledge/router.sh "status enum branch" and then print, on one line, either the two paths it printed or the exact error you got. Do nothing else.'

arena() {  # arena <name> [extra settings json fragment]
  local d="$OUT/$1"; mkdir -p "$d"
  cp -R "$OVL"/. "$d"/
  ( cd "$d" && git init -q && git add -A -f >/dev/null 2>&1 \
      && git -c user.email=probe@local -c user.name=probe commit -qm setup >/dev/null 2>&1 )
  echo "$d"
}

run_arm() {  # run_arm <name> <arena> [extra claude args...]
  local name="$1" d="$2"; shift 2
  local log="$OUT/$name.log"
  ( cd "$d" && KNOWLEDGE_EVENT_LOG="$OUT/$name-knowledge.jsonl" \
      claude -p "$PROMPT" --output-format json --model "$MODEL" \
        --permission-mode acceptEdits --strict-mcp-config --disable-slash-commands \
        --setting-sources project --agent backend-feature-phases \
        --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)" "$@" ) > "$log" 2>&1
  local rc=$? denied executed lines
  denied="$(/usr/bin/grep -aoc 'permission_denials":\[{' "$log" 2>/dev/null || echo 0)"
  executed=no; [[ -s "$OUT/$name-knowledge.jsonl" ]] && executed=yes
  lines="$(grep -c . "$OUT/$name-knowledge.jsonl" 2>/dev/null || echo 0)"
  printf '%s\trc=%s\tdenial_array_nonempty=%s\trouter_log=%s\tlines=%s\n' \
    "$name" "$rc" "$denied" "$executed" "$lines" | tee -a "$OUT/RESULT.tsv"
}

echo "probe: three arms, nine words of work each, $OUT"
printf 'arm\trc\tdenial_array_nonempty\trouter_log\tlines\n' > "$OUT/RESULT.tsv"

A1="$(arena baseline)"
run_arm baseline "$A1"

A2="$(arena overlay-permission)"
python3 - "$A2/.claude/settings.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d["permissions"] = {"allow": ["Bash(.ai/knowledge/router.sh:*)"]}
json.dump(d, open(p, "w"), indent=2)
print("overlay settings patched with permissions.allow")
PY
( cd "$A2" && git add -A -f >/dev/null 2>&1 && git -c user.email=probe@local -c user.name=probe commit -qm perm >/dev/null 2>&1 )
run_arm overlay-permission "$A2"

A3="$(arena cli-allowlist)"
run_arm cli-allowlist "$A3" --allowedTools "Bash(.ai/knowledge/router.sh:*)"

echo ""; cat "$OUT/RESULT.tsv"
echo "probe output: $OUT"
