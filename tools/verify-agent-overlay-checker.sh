#!/usr/bin/env bash
# verify-agent-overlay-checker.sh — prove check-agent-overlay.sh still REFUSES.
#
# A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing. Stop 8 shipped a lab tool three times over, each version passing its own
# fixtures, because a fixture set tests the cases its author thought of. So every case here
# asserts BOTH an exit code AND a line the script must print — an exit code alone cannot tell
# "it refused for the right reason" from "it refused for another one".
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
CHECKER="./tools/check-agent-overlay.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PASS=0; FAIL=0

mkagent() { # mkagent <dir> <relpath> <content>
  mkdir -p "$(dirname "$1/$2")"; printf '%s' "$3" > "$1/$2"
}

expect() { # expect <label> <want-exit> <want-substring> -- <checker args...>
  local label="$1" want_exit="$2" want_sub="$3"; shift 4
  local out ec
  out="$("$CHECKER" "$@" 2>&1)"; ec=$?
  if [[ "$ec" -eq "$want_exit" ]] && [[ "$out" == *"$want_sub"* ]]; then
    PASS=$((PASS+1)); printf 'ok   %-46s exit %s, matched %s\n' "$label" "$ec" "'$want_sub'"
  else
    FAIL=$((FAIL+1))
    printf 'FAIL %-46s want exit %s + %s; got exit %s\n' "$label" "$want_exit" "'$want_sub'" "$ec"
    printf '%s\n' "$out" | sed 's/^/       | /'
  fi
}

GOOD='---
name: r
description: Reviews code.
model: claude-haiku-4-5-20251001
tools: Read, Grep
---

body
'
d="$WORK/good";        mkagent "$d" ".claude/agents/r.md" "$GOOD"
expect "valid: tools + pinned model"            0 "1 agent file(s) checked"          -- "$d"
expect "valid: prints the ok line"              0 "ok         .claude/agents/r.md"   -- "$d"

d="$WORK/inherit";     mkagent "$d" ".claude/agents/r.md" "${GOOD/claude-haiku-4-5-20251001/inherit}"
expect "valid: model inherit is allowed"        0 "1 agent file(s) checked"          -- "$d"

d="$WORK/notools";     mkagent "$d" ".claude/agents/r.md" '---
name: r
description: Reviews code.
model: claude-haiku-4-5-20251001
---

body
'
expect "no tools key -> exit 2"                 2 "NO-TOOLS"                          -- "$d"
expect "no tools key names the consequence"     2 "inherits EVERY tool"               -- "$d"

d="$WORK/emptytools";  mkagent "$d" ".claude/agents/r.md" "${GOOD/tools: Read, Grep/tools:}"
expect "empty tools value -> exit 2"            2 "NO-TOOLS"                          -- "$d"

d="$WORK/indented";    mkagent "$d" ".claude/agents/r.md" '---
name: r
description: Reviews code.
model: claude-haiku-4-5-20251001
experimental:
  tools: Read
---

body
'
expect "indented tools: is NOT a declaration"   2 "NO-TOOLS"                          -- "$d"

d="$WORK/commented";   mkagent "$d" ".claude/agents/r.md" '---
name: r
description: Reviews code.
model: claude-haiku-4-5-20251001
#tools: Read
---

body
'
expect "commented tools: is NOT a declaration"  2 "NO-TOOLS"                          -- "$d"

d="$WORK/empty"; mkdir -p "$d/.claude/agents"
expect "no agent file at all -> exit 3"         3 "NO-AGENT"                          -- "$d"

d="$WORK/nofm";        mkagent "$d" ".claude/agents/r.md" 'no frontmatter here
'
expect "no frontmatter -> exit 4"               4 "no frontmatter"                    -- "$d"

d="$WORK/unterm";      mkagent "$d" ".claude/agents/r.md" '---
name: r
description: d
tools: Read
'
expect "unterminated frontmatter -> exit 4"     4 "never closed"                      -- "$d"

d="$WORK/noname";      mkagent "$d" ".claude/agents/r.md" '---
description: d
model: claude-haiku-4-5-20251001
tools: Read
---
b
'
expect "missing name -> exit 4"                 4 "missing a non-empty"               -- "$d"

d="$WORK/nodesc";      mkagent "$d" ".claude/agents/r.md" '---
name: r
model: claude-haiku-4-5-20251001
tools: Read
---
b
'
expect "missing description -> exit 4"          4 "missing a non-empty"               -- "$d"

d="$WORK/emptyname";   mkagent "$d" ".claude/agents/r.md" '---
name:
description: d
model: claude-haiku-4-5-20251001
tools: Read
---
b
'
expect "empty name -> exit 4"                   4 "missing a non-empty"               -- "$d"

d="$WORK/nomodel";     mkagent "$d" ".claude/agents/r.md" '---
name: r
description: d
tools: Read
---
b
'
expect "no model key -> exit 5"                 5 "fourth of four"                    -- "$d"
expect "no model key, suppressed by flag"       0 "1 agent file(s) checked"           -- --allow-missing-model "$d"

d="$WORK/alias";       mkagent "$d" ".claude/agents/r.md" "${GOOD/claude-haiku-4-5-20251001/haiku}"
expect "model alias 'haiku' -> exit 5"          5 "is an ALIAS"                       -- "$d"

d="$WORK/alias2";      mkagent "$d" ".claude/agents/r.md" "${GOOD/claude-haiku-4-5-20251001/sonnet[1m]}"
expect "model alias 'sonnet[1m]' -> exit 5"     5 "is an ALIAS"                       -- "$d"

d="$WORK/crlf"; mkdir -p "$d/.claude/agents"
printf '%s' "$GOOD" | sed 's/$/\r/' > "$d/.claude/agents/r.md"
expect "CRLF file still parses -> exit 0"       0 "1 agent file(s) checked"           -- "$d"

d="$WORK/symlink"; mkdir -p "$d/real/.claude" "$d/over/.claude"
mkagent "$d/real" ".claude/agents/r.md" '---
name: r
description: d
model: claude-haiku-4-5-20251001
---
b
'
ln -s "$d/real/.claude/agents" "$d/over/.claude/agents"
expect "symlinked agents/ dir is walked"        2 "NO-TOOLS"                          -- "$d/over"

d="$WORK/copilot";     mkagent "$d" ".github/agents/r.agent.md" '---
name: r
description: d
model: claude-haiku-4-5-20251001
---
b
'
expect "Copilot .agent.md, no tools -> exit 2"  2 "NO-TOOLS"                          -- "$d"

d="$WORK/sev1"; mkagent "$d" ".claude/agents/a.md" 'garbage
'; mkagent "$d" ".claude/agents/b.md" '---
name: r
description: d
model: claude-haiku-4-5-20251001
---
b
'
expect "malformed outranks no-tools -> exit 4"  4 "MALFORMED present"                 -- "$d"
expect "...and the no-tools line is STILL printed" 4 "NO-TOOLS"                       -- "$d"

d="$WORK/sev2"; mkagent "$d" ".claude/agents/a.md" '---
name: r
description: d
---
b
'
expect "no-tools outranks model -> exit 2"      2 "NO-TOOLS present"                  -- "$d"
expect "...and the model line is STILL printed" 2 "MODEL      "                       -- "$d"

expect "single file argument works"             0 "ok         $WORK/good/.claude/agents/r.md" -- "$WORK/good/.claude/agents/r.md"
expect "missing target -> exit 1"               1 "target not found"                  -- "$WORK/nope"
expect "unknown option -> exit 1"               1 "unknown option"                    -- --nope "$WORK/good"

# The experiment's own overlays. Arms C and D DELIBERATELY carry no tools key -- that is the
# treatment, not a defect -- so this checker is a gate on arm T only, and these two cases
# record that rather than leaving a later reader to assume the checker was run on everything.
expect "E-005 arm T (toollist) passes"          0 "1 agent file(s) checked"  -- build/customizations/agent-v0.1-toollist
expect "E-005 arm C is DELIBERATELY unbounded"  2 "NO-TOOLS"                 -- build/customizations/agent-v0.1-control
expect "E-005 arm D is DELIBERATELY unbounded"  2 "NO-TOOLS"                 -- build/customizations/agent-v0.1-description

echo
echo "verify-agent-overlay-checker: ${PASS} passed, ${FAIL} failed."
[[ "$FAIL" -eq 0 ]]
