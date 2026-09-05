#!/usr/bin/env bash
# Round 2 of the init-schema probe: is the drop specific to Bash's presence, and does a list
# that already matches the delivered set survive verbatim?
set -euo pipefail
cd "$(dirname "$0")" || exit 1
OUT="$(pwd)/probe2-20260905"; REPS="${REPS:-3}"; MODEL="claude-haiku-4-5-20251001"
mkdir -p "$OUT"
CLAUDE_FLAGS=(
  --permission-mode acceptEdits --strict-mcp-config
  --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
  --disable-slash-commands --setting-sources project --model "$MODEL"
)
declare -a ARM_NAME=(verbatim greponly globonly)
declare -a ARM_TOOLS=("Read, Edit, Write, Bash" "Read, Grep, Edit, Write, Bash" "Read, Glob, Edit, Write, Bash")
for i in "${!ARM_NAME[@]}"; do
  arm="${ARM_NAME[$i]}"; tools="${ARM_TOOLS[$i]}"
  for r in $(seq 1 "$REPS"); do
    W="$OUT/wt-$arm-$r"; mkdir -p "$W/.claude/agents"
    { echo "---"; echo "name: backend-feature-implementer"
      echo "description: Implements one focused backend feature or bug fix in an existing Kotlin or Java Spring Boot repository, with tests, and verifies it before finishing."
      echo "model: $MODEL"; echo "tools: $tools"; echo "---"; echo; echo "Probe body. Not the shipped overlay."
    } > "$W/.claude/agents/backend-feature-implementer.md"
    ( cd "$W" && claude "${CLAUDE_FLAGS[@]}" --agent backend-feature-implementer \
        --output-format stream-json --verbose -p "Reply with the single word ok." ) \
      > "$OUT/$arm-$r.jsonl" 2>"$OUT/$arm-$r.err" || echo "probe2: $arm-$r non-zero" >&2
  done
done
python3 - "$OUT" <<'PY'
import json,sys,glob,os
for f in sorted(glob.glob(os.path.join(sys.argv[1],'*.jsonl'))):
    t=None
    for line in open(f):
        try: d=json.loads(line)
        except Exception: continue
        if d.get('subtype')=='init': t=d.get('tools'); break
    print(f"{os.path.basename(f)[:-6]:14s} n={len(t) if t else 'NONE'}  {json.dumps(t)}")
PY
