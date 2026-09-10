#!/usr/bin/env bash
#
# policy-gate — B7's ONE executing control, and the first Layer 2 control in Track B.
#
# Registered as a PreToolUse hook on Edit|Write|NotebookEdit by ../../.claude/settings.json.
# Reads the tool call on stdin as JSON, decides against .ai/policies/protected-paths.yaml,
# APPENDS ITS DECISION TO A LOG EITHER WAY, and on a denial writes the policy's message to
# stderr and exits 2.
#
# WHY THE LOG IS WRITTEN ON ALLOW AS WELL AS DENY, and it is the whole point of the design:
# a hook that logs only denials is indistinguishable from a hook that never ran, and this
# project's house failure mode is a control reporting success over a scope smaller than it
# claims. The log is also the ONLY per-run delivery proof available — run-agent.sh records
# instructionsHash, skillsHash and agentHash and NO settings or hook hash (run-agent.sh:625-629),
# and GET /api/runs/{id} carries no environment object, so hookExecutions is not in the API
# record either. A hash would prove a file was copied. This proves the thing executed.
#
# EXIT CODES, and the third row is why this script is defensive about its own failure:
#   0   allow — the action proceeds
#   2   DENY  — the action is blocked and stderr is fed back to the model
#   any other   NON-BLOCKING ERROR. THE ACTION PROCEEDS. (Claude Code hooks reference,
#               extracted in phases/05a-guardrails/#extract.) So every internal failure in
#               this script is fail-OPEN, and the only honest response is to log that it
#               happened, under a decision of its own, so a run whose gate silently died is
#               distinguishable afterwards from a run whose gate allowed everything.
set -uo pipefail

LOG="${CLAUDE_PROJECT_DIR:-.}/.ai/policy-events.jsonl"
POLICY="${CLAUDE_PROJECT_DIR:-.}/.ai/policies/protected-paths.yaml"

emit() {  # emit <decision> <tool> <path> <reason>
  printf '{"ts":"%s","decision":"%s","tool":"%s","path":"%s","reason":"%s","policy":"protected-paths","pid":%s}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" "$3" "$4" "$$" >> "$LOG" 2>/dev/null || true
}

IN="$(cat)"
if ! command -v jq >/dev/null 2>&1; then
  emit error "" "" "jq-not-on-path-FAIL-OPEN"; exit 0
fi
TOOL="$(printf '%s' "$IN" | jq -r '.tool_name // ""' 2>/dev/null)"
RAW="$(printf '%s' "$IN"  | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // ""' 2>/dev/null)"
if [[ -z "$RAW" ]]; then
  emit error "$TOOL" "" "no-path-in-tool-input-FAIL-OPEN"; exit 0
fi
if [[ ! -r "$POLICY" ]]; then
  emit error "$TOOL" "$RAW" "policy-file-unreadable-FAIL-OPEN"; exit 0
fi

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
REL="${RAW#"$ROOT"/}"; REL="${REL#./}"

# The deny list, read out of the YAML rather than restated here — a second copy of the rules
# in the code is a rule that can disagree with the file it claims to enforce.
DENIED=0; MATCHED=""
while IFS= read -r pat; do
  [[ -z "$pat" ]] && continue
  # A `**/x` pattern is a BASENAME rule: it must match `pom.xml` at the root as well as
  # `service/pom.xml`, and case-globbing `**/pom.xml` against a bare `pom.xml` does not.
  # The glob on the right of == is deliberate — `**/*.lock` has to stay a glob.
  # shellcheck disable=SC2053
  case "$pat" in
    '**/'*) if [[ "$(basename "$REL")" == ${pat#'**/'} ]]; then DENIED=1; MATCHED="$pat"; break; fi ;;
  esac
  # shellcheck disable=SC2254
  case "$REL" in
    ${pat}) DENIED=1; MATCHED="$pat"; break ;;
  esac
done < <(sed -n '/^deny:/,/^[a-z]/p' "$POLICY" | sed -n 's/^  - "\(.*\)".*/\1/p')

if [[ "$DENIED" -eq 1 ]]; then
  emit deny "$TOOL" "$REL" "matched:$MATCHED"
  sed -n '/^message:/,$p' "$POLICY" | tail -n +2 | sed "s#{path}#$REL#g" >&2
  exit 2
fi
emit allow "$TOOL" "$REL" "no-deny-pattern-matched"
exit 0
