#!/usr/bin/env bash
# check-agent-overlay.sh — refuse an agent overlay that does not name its tools.
#
# WHY THIS EXISTS. On both runtimes that have the field, OMITTING `tools` means the agent gets
# EVERY tool:
#
#   Claude Code: "Inherits every tool available to subagents if omitted."
#   Copilot:     "If no tools are specified, all available tools are enabled."
#
# So a `reviewer` agent written without the key is a FULL-CAPABILITY agent wearing a read-only
# description, and every check short of executing it passes. `build/README.md#b4` calls this
# "the one that bites". Until this script existed nothing in this repository could catch it.
#
# It also refuses an alias in `model:`. The model-configuration page says aliases "point to the
# recommended version for your provider and update over time", with a worked example of one
# re-pointing across releases. The model id is this track's controlled variable; an alias in an
# overlay is a variable that changes without a commit.
#
# EXIT CODES — every one is proved by ./tools/verify-agent-overlay-checker.sh.
#   0  every agent file declares `tools:` and pins `model:`
#   1  usage error, or the target does not exist            (infrastructure, not a finding)
#   2  an agent file has NO `tools:` key                    (the defect this exists for)
#   3  the target contains NO agent file at all             (an overlay that installs nothing)
#   4  an agent file is MALFORMED                           (frontmatter absent/unterminated,
#                                                            or `name:`/`description:` missing)
#   5  `model:` is absent, or is an ALIAS rather than a pinned id or `inherit`
#
# EVERY finding is printed even when a more severe one decides the exit code. Stop 8 shipped a
# checker where exit 3 was swallowed by exit 2 and the caller could not tell which had happened.
set -uo pipefail

usage() {
  cat >&2 <<'USAGE'
usage: check-agent-overlay.sh [--allow-missing-model] <overlay-dir-or-file> [...]

Checks Claude Code agents (.claude/agents/*.md) and Copilot agents (.github/agents/*.agent.md)
found anywhere under each target, or a single agent file given directly.

  --allow-missing-model   do not apply the model check (exit 5). Off by default: this track
                          pins the model id, and a default that has to be asked for is not a
                          control.
USAGE
}

ALLOW_MISSING_MODEL=false
TARGETS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-missing-model) ALLOW_MISSING_MODEL=true; shift ;;
    -h|--help) usage; exit 1 ;;
    -*) echo "check-agent-overlay: unknown option '$1'" >&2; usage; exit 1 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then usage; exit 1; fi

# Aliases the model-configuration page documents. `inherit` is NOT here: it is a documented
# subagent value meaning "the main conversation's model", and this track pins that.
ALIASES=" default best fable sonnet opus haiku opusplan sonnet[1m] opus[1m] "

FOUND_MALFORMED=false
FOUND_NO_TOOLS=false
FOUND_MODEL=false
AGENT_COUNT=0

check_file() {
  local f="$1" rel="$2"
  AGENT_COUNT=$((AGENT_COUNT + 1))

  # Strip CR so a CRLF file is parsed as its author meant it. A stop 8 review found a checker
  # that passed a CRLF file by reading `tools:\r` as a different key than `tools:`.
  local body; body="$(tr -d '\r' < "$f")"

  local first; first="$(printf '%s\n' "$body" | head -1)"
  if [[ "$first" != "---" ]]; then
    echo "MALFORMED  ${rel}: no frontmatter (first line is not '---')"
    FOUND_MALFORMED=true; return
  fi

  # frontmatter = lines 2..(next '---')
  local fm; fm="$(printf '%s\n' "$body" | awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}')"
  # unterminated frontmatter: no closing --- anywhere after line 1
  if ! printf '%s\n' "$body" | awk 'NR==1{next} /^---[[:space:]]*$/{found=1; exit} END{exit !found}'; then
    echo "MALFORMED  ${rel}: frontmatter opened and never closed"
    FOUND_MALFORMED=true; return
  fi

  local has_name=false has_desc=false has_tools=false model_val=""
  local line key val
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]] ]] && continue      # nested value, not a top-level key
    [[ "$line" == \#* ]] && continue
    [[ "$line" != *:* ]] && continue
    key="${line%%:*}"
    val="${line#*:}"
    val="${val#"${val%%[![:space:]]*}"}"           # ltrim
    val="${val%"${val##*[![:space:]]}"}"           # rtrim
    case "$key" in
      name)        [[ -n "$val" ]] && has_name=true ;;
      description) [[ -n "$val" ]] && has_desc=true ;;
      tools)       [[ -n "$val" ]] && has_tools=true ;;
      model)       model_val="$val" ;;
    esac
  done <<<"$fm"

  if [[ "$has_name" != true || "$has_desc" != true ]]; then
    echo "MALFORMED  ${rel}: frontmatter is missing a non-empty 'name:' or 'description:'"
    FOUND_MALFORMED=true; return
  fi

  if [[ "$has_tools" != true ]]; then
    echo "NO-TOOLS   ${rel}: no 'tools:' key — this agent inherits EVERY tool"
    FOUND_NO_TOOLS=true
  else
    echo "ok         ${rel}: tools declared"
  fi

  if [[ "$ALLOW_MISSING_MODEL" != true ]]; then
    if [[ -z "$model_val" ]]; then
      echo "MODEL      ${rel}: no 'model:' key — the subagent model order decides, and the parent's model is fourth of four"
      FOUND_MODEL=true
    elif [[ "$ALIASES" == *" ${model_val} "* ]]; then
      echo "MODEL      ${rel}: 'model: ${model_val}' is an ALIAS — aliases re-point over time; pin the id or use 'inherit'"
      FOUND_MODEL=true
    fi
  fi
}

for target in "${TARGETS[@]}"; do
  if [[ -f "$target" ]]; then
    check_file "$target" "$target"
    continue
  fi
  if [[ ! -d "$target" ]]; then
    echo "check-agent-overlay: target not found: ${target}" >&2
    exit 1
  fi
  # -L so a symlinked agents/ directory is walked. Stop 8 shipped a checker blind to exactly
  # that, and its eleven fixtures all passed because none of them used a symlink.
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    check_file "$f" "${f#"$target"/}"
  done < <(find -L "$target" \( -path '*/.claude/agents/*.md' -o -path '*/.github/agents/*.agent.md' \) -type f 2>/dev/null | sort)
done

if [[ "$AGENT_COUNT" -eq 0 ]]; then
  echo "NO-AGENT   no agent file found under: ${TARGETS[*]}"
  echo "check-agent-overlay: 0 agent files — exit 3"
  exit 3
fi

echo "check-agent-overlay: ${AGENT_COUNT} agent file(s) checked"
# Severity order, and every finding above is printed regardless of which one decides this.
if [[ "$FOUND_MALFORMED" == true ]]; then echo "check-agent-overlay: MALFORMED present — exit 4"; exit 4; fi
if [[ "$FOUND_NO_TOOLS"  == true ]]; then echo "check-agent-overlay: NO-TOOLS present — exit 2";  exit 2; fi
if [[ "$FOUND_MODEL"     == true ]]; then echo "check-agent-overlay: MODEL present — exit 5";     exit 5; fi
exit 0
