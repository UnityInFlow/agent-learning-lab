#!/usr/bin/env bash
# THE PORTABILITY CENSUS FOR SPINE STOP 21 (B10) — predictions 1 and 2 of E-024 / E-025.
#
#   ./evidence/b10/census-port.sh          # prints the census, spends nothing
#
# WHY THIS IS A SCRIPT AND NOT A TABLE IN THE WORKBOOK. Prediction 1 is a file count and
# prediction 2 is a claim about CONTROLS. A file count can be read off `find`; a claim that a
# control does not survive a port cannot — it is either proved by something that executes and
# refuses, or it is one person's reading of a runner. §5's layer column is about the PROOF, so
# each row below is an actual invocation of the real `run-agent.sh` and its actual exit code.
#
# NOTHING HERE COSTS MONEY. Every probe passes `--check-customization`, which installs the
# overlay, computes the hashes, prints them and exits BEFORE the model is called
# (run-agent.sh:670-686). The refusals are earlier still. Five probes, zero model calls.
#
# THE ONE RESULT THAT IS NOT A CONFIRMATION IS PROBE 5, and it is the point of the whole file:
# `.claude/settings.json` — which is how B7's measured Layer-2 policy gate and B8's repair
# limit are wired — crosses onto codex with exit 0, TRACKED, and no hash of any kind naming it.
# The named-agent boundary is lost LOUDLY (probes 3 and 4 refuse). The policy gate is lost
# SILENTLY. Both are lost; only one of them tells a future reader so.
#
# Exit 0 every probe behaved as registered · 1 a probe's exit code did not match
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="$(cd ../agent-observatory && pwd)" || exit 1
FIX="$LAB/evidence/b10/census-fixtures"
PORT="$LAB/build/customizations/agent-v1.2-knowledge-codex"
CLAUDE_OVERLAY="$LAB/build/customizations/agent-v1.2-knowledge"

export API="${B10_API:-http://127.0.0.1:8081}"
export WEB="http://localhost:5174"
export TEMPO_URL="http://localhost:3200"
export OTLP_HTTP_ENDPOINT="${B10_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B10_OTLP_GRPC:-http://localhost:4317}"

FAIL=0
probe() {  # probe <label> <expected_exit> <expect_grep> [extra run-agent args...]
  local label="$1" want="$2" needle="$3"; shift 3
  local out rc
  out="$(mktemp)"
  ( cd "$OBS" && runner/run-agent.sh --runtime codex --benchmark BE-003 \
      --experiment EXP-B10-CENSUS --model gpt-5.6-sol --isolate-user-settings \
      --check-customization "$@" ) > "$out" 2>&1
  rc=$?
  printf '%-34s exit %s (registered %s)  ' "$label" "$rc" "$want"
  if [[ "$rc" != "$want" ]]; then printf 'MISMATCH\n'; FAIL=1
  elif ! grep -q "$needle" "$out"; then printf 'exit matched but the reason did not: %s absent\n' "$needle"; FAIL=1
  else printf 'as registered\n'; fi
  sed -n '/^  customization hashes:/p;/^  tracked overlay files/p;/^run-agent: /,$p' "$out" | sed 's/^/      /'
  rm -f "$out"
}

echo "=== 1. THE FILE COUNT (prediction 1: 8 of 11 port unchanged) ==="
printf 'source overlay agent-v1.2-knowledge: %s files\n' "$(find "$CLAUDE_OVERLAY" -type f | wc -l | tr -d ' ')"
printf 'ported overlay agent-v1.2-knowledge-codex: %s files\n' "$(find "$PORT" -type f | wc -l | tr -d ' ')"
echo "byte-identity of the .ai tree (empty output = identical):"
diff -r "$CLAUDE_OVERLAY/.ai" "$PORT/.ai" | sed 's/^/      /'
echo "CLAUDE.md vs AGENTS.md (empty = same bytes, different name = a RENAME, not an unchanged port):"
diff "$CLAUDE_OVERLAY/CLAUDE.md" "$PORT/AGENTS.md" | sed 's/^/      /'
echo "files in the source that are NOT in the port:"
( cd "$CLAUDE_OVERLAY" && find . -type f | sed 's|^\./||' | LC_ALL=C sort ) > /tmp/b10-src.$$
( cd "$PORT" && find . -type f | sed 's|^\./||' | LC_ALL=C sort ) > /tmp/b10-dst.$$
comm -23 /tmp/b10-src.$$ /tmp/b10-dst.$$ | sed 's/^/      /'
rm -f /tmp/b10-src.$$ /tmp/b10-dst.$$

echo
echo "=== 2. THE CONTROLS (prediction 2: 0 of 2 survive) — five executed probes ==="
probe "1 the 9-file port on codex" 0 'customization checks passed' \
  --customization "$PORT" --variant agent-v1.2-knowledge-codex
probe "2 the 11-file claude overlay" 1 "does not read" \
  --customization "$CLAUDE_OVERLAY" --variant agent-v1.2-knowledge
probe "3 --agent on codex" 1 'is not forwarded to runtime' \
  --agent backend-feature-phases --customization "$PORT" --variant port
probe "4 port + .claude/agents/" 1 'does not read' \
  --customization "$FIX/port-plus-claude-agents" --variant port-plus-claude-agents
probe "5 port + .claude/settings.json" 0 'customization checks passed' \
  --customization "$FIX/port-plus-claude-settings" --variant port-plus-claude-settings

echo
if [[ "$FAIL" == 0 ]]; then echo "census: every probe behaved as registered"; else echo "census: A PROBE DID NOT BEHAVE AS REGISTERED — read the rows above"; fi
exit "$FAIL"
