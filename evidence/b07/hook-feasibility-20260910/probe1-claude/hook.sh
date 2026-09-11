#!/usr/bin/env bash
IN=$(cat)
echo "{\"ts\":\"$(date -u +%FT%TZ)\",\"event\":\"PreToolUse\",\"raw\":$(printf '%s' "$IN" | head -c 400 | jq -Rs .)}" >> "$CLAUDE_PROJECT_DIR/policy-events.jsonl"
exit 0
