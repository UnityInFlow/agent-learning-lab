#!/usr/bin/env bash
#
# retrieval-budget — B11 (v1.2) mechanism 2, and one of the version's three EXECUTING controls.
#
# Registered by ../../.claude/settings.json as a PreToolUse hook on TWO matchers:
#   Read|Grep|Glob            — the budget itself
#   Edit|Write|NotebookEdit   — the PHASE MARKER, and nothing else
#
# WHY ONE SCRIPT ON TWO MATCHERS. Two of the three limits are "before design": the spec's own
# words are `max_initial_searches` and `max_files_before_design`. "Before design" needs an
# event that ENDS the design phase, and the only such event a hook can see is the first
# Edit/Write of the run. A second script would need the same state file and the same locking,
# so the phase marker lives here and is a five-line branch.
#
# THE LIMITS ARE READ FROM .ai/policies/retrieval-budget.yaml, NOT HARD-CODED. A policy file
# whose numbers the enforcing script does not read is decoration — B7's whole finding. If the
# file cannot be read the hook FAILS OPEN and records that it did, so that a run whose budget
# silently died is afterwards distinguishable from one that allowed everything.
#
# THERE IS NO OVERRIDE CHANNEL, AND THAT IS DELIBERATE. build/README.md#b11 says "exceeding
# requires a recorded reason". An override the model can write is an override it can write
# without a reason, so the limit would be L3 wearing L2's clothes — the exact demotion stop 7
# recorded for `allowed-tools`. The limit refuses; the refusal is logged with its cause; the
# reason, if there is one, lands in the model's own report where a human reads it. The "recorded
# reason" half of that spec line is therefore NOT converted, and the workbook says so.
#
# THE LOG IS WRITTEN OUTSIDE THE WORKTREE, and that is not a detail. B7's preflight pair
# 2077432c and 88b861f3 SOLVED their tasks and were scored exit 21 — "unrelated production
# files changed" — where the single unrelated file was the guardrail's own log
# (E-016:227-237). B9 hit the same wall (E-022 Amendment 1). The evaluator's ignore pattern is
# a REGISTERED VARIABLE and moving it is a §7 halt, so the documented path stays
# `.agent/budget-log.jsonl` and the actual file lives beside B8's run-state under $TMPDIR with
# the worktree in its name.
#
# THE LOG IS WRITTEN ON EVERY CALL, ALLOW OR BLOCK. B7's rule inherited: a hook that writes
# only on the interesting path is indistinguishable from a hook that never ran. It is also the
# ONLY per-run delivery proof available, because `customization.hooksHash` has been null on
# every run this project has ever recorded.
#
# EXIT CODES
#   0   allow — the tool call proceeds
#   2   BLOCK — the call does not happen and stderr is fed back to the model
#   any other   NON-BLOCKING ERROR; the call proceeds anyway. Every internal failure is
#               fail-OPEN and recorded as its own decision.
set -uo pipefail

WT="${CLAUDE_PROJECT_DIR:-unknown}"
DIR="${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}"
LOG="${AGENT_BUDGET_LOG:-$DIR/budget-log-$(basename "$WT").jsonl}"
STATE="${AGENT_BUDGET_STATE:-$DIR/budget-state-$(basename "$WT").json}"
POLICY="${AGENT_BUDGET_POLICY:-$WT/.ai/policies/retrieval-budget.yaml}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# Append one JSON object per decision. `jq -nc` rather than printf so a path holding a quote
# cannot produce a line no reader can parse — the manifest-field defect the b08/b09 drivers
# both recorded, applied to a log instead of a TSV.
emit() {  # emit <tool> <decision> <reason> <counters...>
  jq -nc --arg ts "$(now)" --arg hook retrieval-budget --arg tool "$1" --arg d "$2" \
         --arg r "$3" --arg phase "${4:-unknown}" --arg searches "${5:-0}" \
         --arg files "${6:-0}" --arg target "${7:-}" \
     '{ts:$ts,hook:$hook,tool:$tool,decision:$d,reason:$r,phase:$phase,
       searches:($searches|tonumber),distinctFiles:($files|tonumber),target:$target}' \
     >> "$LOG" 2>/dev/null || printf '{"ts":"%s","hook":"retrieval-budget","decision":"%s","reason":"emit-failed"}\n' \
        "$(now)" "$2" >> "$LOG" 2>/dev/null
}

init_state() {
  cat > "$STATE" <<JSON
{
  "schemaVersion": "b11-v1.2",
  "documentedLogPath": ".agent/budget-log.jsonl",
  "worktree": "$WT",
  "startedAt": "$(now)",
  "phase": "design",
  "searches": 0,
  "filesRead": [],
  "blocks": []
}
JSON
}

# A limit read from the policy file. Prints the integer, or nothing when the key is missing or
# is not an integer — the caller then fails open rather than substituting a number of its own.
limit_of() {  # limit_of <key>
  [[ -r "$POLICY" ]] || return 1
  awk -v k="$1" '
    $1 == k":" { inkey = 1; next }
    inkey && $1 == "value:" { print $2; exit }
    inkey && /^  [a-z_]+:/ { exit }
  ' "$POLICY" | grep -E '^[0-9]+$'
}

fail_open() {  # fail_open <tool> <reason>
  emit "$1" error "$2"
  exit 0
}

command -v jq >/dev/null 2>&1 || exit 0   # nowhere to record it; fail open, silently and honestly
# ONE jq for the whole input, and one for the whole state — see the note in
# .ai/hooks/command-dedup.sh. This hook sits in front of every Read, Grep and Glob, so its
# process count is multiplied by the busiest tool in the run.
IN="$(cat)"
# *** THE FIELDS ARE READ ONE PER LINE, NOT TAB-SEPARATED, AND THE FIXTURE SET CAUGHT WHY. ***
# The first version of this read was `IFS=$'\t' read -r A B <<<"$(jq ... | @tsv)"`. A TAB IS IFS
# WHITESPACE, so bash strips it when it leads the string and collapses runs of it: a first field
# that is legitimately EMPTY disappears and every later field shifts left by one. On a store with
# no entry for this fingerprint that turned ("", "?") into ("?", "") — so a FIRST RUN read as a
# REPEAT, and the hook would have refused nothing while logging that it had. Caught by
# tools/verify-command-dedup.sh case 1 before a single run was paid for; it is the same
# plausible-wrong-answer class as `grep -c` counting lines. One value per line, `IFS= read -r`
# per field, empty lines preserved.
{ IFS= read -r TOOL; IFS= read -r TGT; IFS= read -r LIM; } <<<"$(printf '%s' "$IN" | jq -r \
  '(.tool_name // ""), ((.tool_input.file_path // .tool_input.pattern // .tool_input.path // "") | gsub("[\n\t]"; " ")), (.tool_input.limit // "")' 2>/dev/null)"
[[ -n "${TOOL:-}" ]] || exit 0
TGT="${TGT:-}"; LIM="${LIM:-}"
[[ -f "$STATE" ]] || init_state
[[ -f "$STATE" ]] || exit 0

PHASE="$(jq -r '.phase // "design"' "$STATE" 2>/dev/null)"

# ---- the phase marker. An Edit/Write ENDS the design phase and is never itself refused here.
case "$TOOL" in
  Edit|Write|NotebookEdit)
    if [[ "$PHASE" != implementation ]]; then
      tmp="$STATE.tmp.$$"
      jq --arg ts "$(now)" '.phase="implementation" | .designEndedAt=$ts' "$STATE" >"$tmp" 2>/dev/null && mv "$tmp" "$STATE"
      emit "$TOOL" allow phase-marker-design-ended implementation
    else
      emit "$TOOL" allow phase-already-implementation implementation
    fi
    exit 0 ;;
esac

MAX_SEARCH="$(limit_of max_initial_searches || true)"
MAX_FILES="$(limit_of max_files_before_design || true)"
MAX_LOGLINES="$(limit_of max_full_log_lines || true)"
[[ -n "$MAX_SEARCH" && -n "$MAX_FILES" && -n "$MAX_LOGLINES" ]] \
  || fail_open "$TOOL" "policy-unreadable: $POLICY"

# The two counters and the already-read answer in ONE read of the state.
{ IFS= read -r SEARCHES; IFS= read -r NFILES; IFS= read -r KNOWN; } <<<"$(jq -r --arg p "$TGT" \
  '(.searches // 0), ((.filesRead // []) | length), (((.filesRead // []) | index($p)) != null)' "$STATE" 2>/dev/null)"
[[ "${SEARCHES:-}" =~ ^[0-9]+$ ]] || fail_open "$TOOL" unreadable-search-counter
[[ "${NFILES:-}" =~ ^[0-9]+$ ]] || fail_open "$TOOL" unreadable-file-counter
KNOWN="${KNOWN:-false}"

block() {  # block <tool> <reason> <message>
  tmp="$STATE.tmp.$$"
  jq --arg ts "$(now)" --arg t "$1" --arg r "$2" \
     '.blocks += [{"ts":$ts,"tool":$t,"reason":$r}]' "$STATE" >"$tmp" 2>/dev/null && mv "$tmp" "$STATE"
  emit "$1" block "$2" "$PHASE" "$SEARCHES" "$NFILES" "${TARGET:-}"
  printf '%s\n' "$3" >&2
  exit 2
}

case "$TOOL" in
  Grep|Glob)
    TARGET="$TGT"
    if [[ "$PHASE" == design && "$SEARCHES" -ge "$MAX_SEARCH" ]]; then
      block "$TOOL" "initial-search-limit: $SEARCHES of $MAX_SEARCH already used" \
"BLOCKED by the retrieval budget: you have already made ${SEARCHES} searches before writing
anything, and this version's budget is ${MAX_SEARCH} before design.

Searching more is not what is missing. Write the design down — which files you will change and
what each change is — and start changing them. Searching is unrestricted again once you have
made your first edit. Do not route around this by reading files one at a time instead."
    fi
    tmp="$STATE.tmp.$$"
    jq --argjson s "$((SEARCHES + 1))" '.searches=$s' "$STATE" >"$tmp" 2>/dev/null && mv "$tmp" "$STATE"
    emit "$TOOL" allow "search-$((SEARCHES + 1))-of-$MAX_SEARCH" "$PHASE" "$((SEARCHES + 1))" "$NFILES" "$TARGET"
    exit 0 ;;

  Read)
    TARGET="$TGT"
    [[ -n "$TARGET" ]] || fail_open "$TOOL" no-file-path-in-tool-input

    # max_full_log_lines: 0 — an UNBOUNDED read of a log-shaped path. This is the one limit that
    # applies in both phases, because a 40 000-line surefire report costs the same after the
    # first edit as before it.
    if [[ "$MAX_LOGLINES" == 0 && -z "$LIM" ]] && \
       [[ "$TARGET" == *.log || "$TARGET" == *.jsonl || "$TARGET" == */logs/* || "$TARGET" == */surefire-reports/* ]]; then
      block "$TOOL" "full-log-read: $TARGET with no limit" \
"BLOCKED by the retrieval budget: reading a whole log file is refused at this version
(max_full_log_lines: 0).

Read a bounded window instead — pass a \`limit\`, or grep the file for the failing test name or
the first \`ERROR\`. A full log is almost never the shortest path to the one line that matters."
    fi

    if [[ "$PHASE" == design && "$KNOWN" != true && "$NFILES" -ge "$MAX_FILES" ]]; then
      block "$TOOL" "files-before-design-limit: $NFILES of $MAX_FILES distinct files already read" \
"BLOCKED by the retrieval budget: you have already opened ${NFILES} distinct files before
writing anything, and this version's budget is ${MAX_FILES} before design.

Re-reading a file you have already opened is still allowed. Opening a new one is not, until you
have made your first edit. Write down the change you intend and begin it."
    fi
    if [[ "$KNOWN" == true ]]; then
      emit "$TOOL" allow "already-read: $NFILES of $MAX_FILES distinct" "$PHASE" "$SEARCHES" "$NFILES" "$TARGET"
    else
      tmp="$STATE.tmp.$$"
      jq --arg p "$TARGET" '.filesRead += [$p]' "$STATE" >"$tmp" 2>/dev/null && mv "$tmp" "$STATE"
      emit "$TOOL" allow "file-$((NFILES + 1))-of-$MAX_FILES" "$PHASE" "$SEARCHES" "$((NFILES + 1))" "$TARGET"
    fi
    exit 0 ;;
esac

emit "$TOOL" allow not-a-budgeted-tool "$PHASE" "$SEARCHES" "$NFILES"
exit 0
