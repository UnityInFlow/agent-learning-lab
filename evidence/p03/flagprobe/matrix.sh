#!/usr/bin/env bash
# 4 cells x 3 reps. Detector: a `Skill` tool_use in the stream-json, NOT a text marker —
# the agent can read SKILL.md off disk, which is why the marker test was contaminated.
set -u
SP="$(cd "$(dirname "$0")" && pwd)"
cd "$SP" || exit 1
P="I need to change the shipment confirmation logic in this Kotlin Spring backend. Read sub/ShipmentController.kt first, then tell me what conventions apply."
detect() { python3 -c '
import json,sys
skill=read=marker=0
for ln in open(sys.argv[1]):
    try: d=json.loads(ln)
    except: continue
    if d.get("type")=="assistant":
        for c in d.get("message",{}).get("content",[]):
            if c.get("type")=="tool_use":
                if c.get("name")=="Skill": skill+=1
                if c.get("name") in ("Read","Grep","Glob") and "SKILL.md" in json.dumps(c.get("input","")): read+=1
            if c.get("type")=="text" and "BODY-MARKER-7F31" in c.get("text",""): marker=1
print(f"skill_tool={skill} read_skillmd={read} text_marker={marker}")' "$1"; }
cell() { # $1 label  $2 extraflag
  for i in 1 2 3; do
    f="$SP/sj-$1-$i.jsonl"
    # shellcheck disable=SC2086
    claude --permission-mode acceptEdits --strict-mcp-config $2 --setting-sources project \
      --model claude-haiku-4-5-20251001 --output-format stream-json --verbose -p "$P" \
      </dev/null > "$f" 2>&1
    echo "$1 rep$i: $(detect "$f")"
  done
}
mkdir -p "$SP/.claude/skills"
[ -d "$SP/sub/.claude/skills/probe" ] && mv "$SP/sub/.claude/skills/probe" "$SP/.claude/skills/probe"
rm -rf "$SP/sub/.claude"
echo "=== ROOT path ==="
cell root-noflag ""
cell root-flag "--disable-slash-commands"
mkdir -p "$SP/sub/.claude/skills"
mv "$SP/.claude/skills/probe" "$SP/sub/.claude/skills/probe"
rm -rf "$SP/.claude"
echo "=== NESTED path ==="
cell nested-noflag ""
cell nested-flag "--disable-slash-commands"
echo "=== DONE ==="
