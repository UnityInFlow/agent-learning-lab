#!/usr/bin/env bash
# Author decision 8 (2026-09-04): before any B step registers an agent overlay with a `tools:`
# key, the DELIVERED schema is read from the run's `system`/`init` record and diffed against the
# file, per arm, and recorded in the experiment BEFORE the prediction commit. A difference is
# row 0a — VOID before the batch, redesign.
#
# Why this exists: on Claude Code 2.1.260 a subagent list containing Bash was delivered WITHOUT
# Grep and Glob. `Read, Grep, Glob, Bash` arrived as `[Read, Bash]` on 10 of 10 arm-F runs of
# E-005. A `tools:` file is not the treatment until its init record says so.
#
# The flag set below is run-agent.sh's claude arm VERBATIM (--permission-mode acceptEdits,
# --strict-mcp-config, --allowedTools, --disable-slash-commands, --setting-sources project,
# --model) plus --agent, which is what B4 adds. Copying it by hand is the weak point; the flags
# are listed in one array here so a reader can diff them against the runner.
set -euo pipefail
cd "$(dirname "$0")" || exit 1
HERE="$(pwd)"
OUT="${1:-$HERE/init-schema-probe-$(date -u +%Y%m%dT%H%M%SZ)}"
REPS="${REPS:-3}"
MODEL="claude-haiku-4-5-20251001"
mkdir -p "$OUT"

CLAUDE_FLAGS=(
  --permission-mode acceptEdits
  --strict-mcp-config
  --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
  --disable-slash-commands
  --setting-sources project
  --model "$MODEL"
)

# The candidate allowlists B4's design intends to use, plus the no-key control.
declare -a ARM_NAME=(candidate nobash control)
declare -a ARM_TOOLS=("Read, Grep, Glob, Edit, Write, Bash" "Read, Grep, Glob, Edit, Write" "")

for i in "${!ARM_NAME[@]}"; do
  arm="${ARM_NAME[$i]}"; tools="${ARM_TOOLS[$i]}"
  for r in $(seq 1 "$REPS"); do
    W="$OUT/wt-$arm-$r"
    mkdir -p "$W/.claude/agents"
    {
      echo "---"
      echo "name: backend-feature-implementer"
      echo "description: Implements one focused backend feature or bug fix in an existing Kotlin or Java Spring Boot repository, with tests, and verifies it before finishing."
      echo "model: $MODEL"
      [ -n "$tools" ] && echo "tools: $tools"
      echo "---"
      echo
      echo "Probe body. Not the shipped overlay."
    } > "$W/.claude/agents/backend-feature-implementer.md"
    ( cd "$W" && claude "${CLAUDE_FLAGS[@]}" \
        --agent backend-feature-implementer \
        --output-format stream-json --verbose \
        -p "Reply with the single word ok." ) \
      > "$OUT/$arm-$r.jsonl" 2>"$OUT/$arm-$r.err" \
      || echo "probe: $arm-$r exited non-zero — recorded anyway" >&2
  done
done

echo "== delivered init.tools, per arm =="
python3 - "$OUT" <<'PY'
import json,sys,glob,os,collections
out=sys.argv[1]
for f in sorted(glob.glob(os.path.join(out,'*.jsonl'))):
    arm=os.path.basename(f)[:-6]
    tools=None
    with open(f) as fh:
        for line in fh:
            try: d=json.loads(line)
            except Exception: continue
            if d.get('subtype')=='init':
                tools=d.get('tools'); break
    print(f"{arm:14s} n_tools={len(tools) if tools else 'NO INIT RECORD'}  {json.dumps(tools)}")
PY
