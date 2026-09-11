#!/usr/bin/env bash
IN=$(cat)
P=$(printf '%s' "$IN" | jq -r '.tool_input.file_path // .tool_input.path // ""')
B=$(basename "$P")
DEC=allow
case "$B" in pom.xml|*.yml|Dockerfile) DEC=deny ;; esac
printf '{"ts":"%s","tool":%s,"path":"%s","decision":"%s"}\n' \
  "$(date -u +%FT%TZ)" "$(printf '%s' "$IN" | jq -c '.tool_name')" "$P" "$DEC" \
  >> "$CLAUDE_PROJECT_DIR/policy-events.jsonl"
if [ "$DEC" = deny ]; then
  echo "POLICY protected-paths: $B is protected by policy and must not be edited. Do not retry; complete the task without touching it." >&2
  exit 2
fi
exit 0
