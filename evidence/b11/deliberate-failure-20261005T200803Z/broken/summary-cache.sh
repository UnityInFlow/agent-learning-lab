#!/usr/bin/env bash
#
# summary-cache — B11 (v1.2) mechanism 3, THE READER HALF, and the second of the version's three
# executing controls. Registered as a PreToolUse hook on `Read`.
#
# THE SPEC, at build/README.md#b11 step 3: "File-summary cache keyed on sha256 — reuse only on
# hash match; never trust a stale summary." The two halves of that sentence are two different
# executing decisions, and this file makes both:
#
#   HASH MATCH   — the file has not changed since it was read. The re-read is REFUSED (exit 2)
#                  and the cached summary is handed back on stderr. This is the only mechanism
#                  at this version that acts on gate clause 3, "fewer repeated reads".
#   HASH MISMATCH— the file HAS changed. The cache entry is REFUSED, not reused, the read is
#                  allowed, and the refusal is logged as `stale-refused`. That log line is the
#                  evidence that "never trust a stale summary" executed rather than being a
#                  sentence in a CLAUDE.md.
#
# *** AND IT MAKES A METRIC THE TELEMETRY CANNOT. *** The gate's clause 3 is unmeasurable from
# the observatory: a repeated read is defined by its TARGET, and the collector deletes
# `tool.arguments` on purpose (infra/otel-collector/config.yaml:48; 0 occurrences in the live
# events.jsonl). This log records the target, so repeated reads become countable — BUT ONLY IN
# THE TREATED ARM, because the control has no hook. That is a one-armed instrument and it can
# never produce a treated-vs-control comparison. The workbook says so before the batch; nothing
# in the decision rule reads it.
#
# WHY THE READ IS REFUSED AND NOT SILENTLY SERVED FROM CACHE. A PreToolUse hook cannot return a
# tool result; it can only allow or block. So "reuse the summary" is delivered as a block whose
# stderr IS the summary. That is honest about the layer: the model is told what the cache holds
# and decides what to do, and the thing that executed is the refusal.
#
# THE STORE AND THE LOG LIVE OUTSIDE THE WORKTREE, for the reason recorded in
# retrieval-budget.sh: B7's preflight pair was scored exit 21 for its own guardrail's log file
# and the evaluator's ignore pattern is a registered variable. Documented path:
# `.agent/cache-log.jsonl`.
#
# EXIT CODES: 0 allow · 2 BLOCK · anything else non-blocking error, call proceeds.
set -uo pipefail

WT="${CLAUDE_PROJECT_DIR:-unknown}"
DIR="${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}"
LOG="${AGENT_CACHE_LOG:-$DIR/cache-log-$(basename "$WT").jsonl}"
STORE="${AGENT_CACHE_STORE:-$DIR/summary-cache-$(basename "$WT").json}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

emit() {  # emit <decision> <reason> <path> <sha> <cachedSha>
  jq -nc --arg ts "$(now)" --arg hook summary-cache --arg tool Read --arg d "$1" --arg r "$2" \
         --arg p "$3" --arg sha "${4:-}" --arg cached "${5:-}" \
     '{ts:$ts,hook:$hook,tool:$tool,decision:$d,reason:$r,target:$p,sha:$sha,cachedSha:$cached}' \
     >> "$LOG" 2>/dev/null || true
}

command -v jq >/dev/null 2>&1 || exit 0
# ONE jq for the whole input. See the note in .ai/hooks/command-dedup.sh: jq costs ~0.68 s per
# invocation on this machine, and this hook sits in front of every Read.
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
{ IFS= read -r TOOL; IFS= read -r P; } <<<"$(printf '%s' "$IN" \
  | jq -r '(.tool_name // ""), ((.tool_input.file_path // "") | gsub("[\n\t]"; " "))' 2>/dev/null)"
[[ "${TOOL:-}" == Read ]] || exit 0    # the matcher is shared with retrieval-budget.sh; ignore the rest
P="${P:-}"
[[ -n "$P" ]] || { emit allow no-file-path ""; exit 0; }
[[ -f "$STORE" ]] || printf '{}\n' > "$STORE"
[[ -r "$STORE" ]] || { emit error store-unreadable "$P"; exit 0; }

# A file that does not exist cannot be hashed and cannot have been cached from a real read.
if [[ ! -f "$P" ]]; then emit allow target-not-a-file "$P"; exit 0; fi

SHA="$(shasum -a 256 "$P" 2>/dev/null | cut -d' ' -f1)"
[[ -n "$SHA" ]] || { emit error sha-failed "$P"; exit 0; }

ENTRY="$(jq -c --arg p "$P" '.[$p] // empty' "$STORE" 2>/dev/null)"
if [[ -z "$ENTRY" ]]; then emit allow miss "$P" "$SHA"; exit 0; fi

{ IFS= read -r CACHED; IFS= read -r LINES; IFS= read -r BYTES; IFS= read -r WHEN; } \
  <<<"$(printf '%s' "$ENTRY" | jq -r '(.sha // ""), (.lines // "?"), (.bytes // "?"), (.ts // "?")')"

emit block hash-match "$P" "$SHA" "$CACHED"
cat >&2 <<MSG
BLOCKED by the file-summary cache: you already read this file at this exact content.

  path        ${P}
  read at     ${WHEN}
  sha256      ${SHA}
  size        ${BYTES} bytes, ${LINES} lines

The file has not changed since — the hash is identical — so this read would return exactly what
you already have. Use what you read. If you need only one part of it again, grep for that part,
or read a bounded window with an offset and a limit. If the file changes, this cache drops its
entry by itself and the next read goes through.
MSG
exit 2
