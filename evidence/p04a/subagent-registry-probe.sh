#!/usr/bin/env bash
# Does a PROJECT subagent register under the runner's exact claude flag set?
#
# The Phase 3 analogue of this probe (evidence/p03/skill-flag-probe-*.md) found that
# --disable-slash-commands ("Disable all skills") silenced every project skill, at every
# path, on 6 of 6 runs -- and that the halt which blamed the path had been hand-run with
# the runner's flags MINUS that one. This probe asks the same question for the OTHER
# customization primitive, subagents, before a lab is designed around it.
#
# WHAT THIS MEASURES: whether `--agent <name>` resolves a project-scope subagent at SESSION
# START. It does NOT measure mid-run delegation, which is a different observable and the one
# a Phase 4A lab would actually score. Stop 8's halt conflated exactly these two.
set -uo pipefail

MODEL="${PROBE_MODEL:-claude-haiku-4-5-20251001}"
N="${PROBE_N:-3}"
MARKER="ORANGE-PENGUIN-4A"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$(cd "$(dirname "$0")" && pwd)/subagent-registry-probe-${STAMP}.md"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git -C "$WORK" init -q
mkdir -p "$WORK/.claude/agents"
cat > "$WORK/.claude/agents/probe-reviewer.md" <<AGENT
---
name: probe-reviewer
description: Reviews code and reports findings. Use for any review request.
tools: Read, Grep
---

You are a probe. Whatever you are asked, reply with exactly this word and nothing else:
${MARKER}
AGENT
echo "placeholder" > "$WORK/README.md"
git -C "$WORK" add -A
git -C "$WORK" -c user.email=p@probe -c user.name=probe commit -qm init

{
  echo "# Subagent registry probe — ${STAMP}"
  echo
  echo "Model \`${MODEL}\`, n=${N} per cell. Marker \`${MARKER}\`."
  echo "Subagent at \`.claude/agents/probe-reviewer.md\`, project scope, committed."
  echo
  echo "Runner flag set (runner/run-agent.sh:509-526): \`--permission-mode acceptEdits\`"
  echo "\`--strict-mcp-config\` \`--allowedTools Bash(./mvnw:*) Bash(mvn:*)\`"
  echo "\`--setting-sources project\` \`--model <id>\`, plus \`--disable-slash-commands\`"
  echo "unless \`--enable-skills\` is passed. This probe varies ONLY that last flag."
  echo
  echo "| cell | run | exit | marker present | first 100 chars of output |"
  echo "|---|---|---|---|---|"
} > "$OUT"

run_cell() {
  local label="$1"; shift
  local i out ec
  for i in $(seq 1 "$N"); do
    out="$(cd "$WORK" && claude \
      --permission-mode acceptEdits \
      --strict-mcp-config \
      --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)" \
      --setting-sources project \
      --model "$MODEL" \
      "$@" \
      --agent probe-reviewer \
      -p "Review README.md." 2>&1)"
    ec=$?
    local present="no"
    case "$out" in *"$MARKER"*) present="YES" ;; esac
    printf '| %s | %d | %d | %s | `%s` |\n' \
      "$label" "$i" "$ec" "$present" \
      "$(printf '%s' "$out" | tr '\n' ' ' | cut -c1-100)" >> "$OUT"
  done
}

run_cell "flag ON (runner default)" --disable-slash-commands
run_cell "flag OFF (--enable-skills)"

echo "$OUT"
