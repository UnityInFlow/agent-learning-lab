#!/usr/bin/env bash
#
# summary-cache-record — B11 (v1.2) mechanism 3, THE WRITER HALF. Registered as a PostToolUse
# hook on `Read`. It stores the sha256 and a size summary of every file the model actually read,
# which is what .ai/hooks/summary-cache.sh (PreToolUse) later refuses a re-read against.
#
# PostToolUse IS THE RIGHT EVENT HERE AND THE WRONG ONE FOR ENFORCEMENT, and the difference is
# measured, not assumed: phases/05a-guardrails/README.md:58-60 — "PostToolUse merely shows
# stderr because the tool already ran". A recorder does not need to stop anything, so the event
# that fires after the fact is exactly right; the refusal lives in the PreToolUse half.
#
# *** IT RECORDS AFTER THE READ AND NOT BEFORE, SO THE CACHE ONLY EVER HOLDS FILES THE MODEL
# ACTUALLY RECEIVED. *** Writing the entry in the PreToolUse hook would have been one file fewer,
# and it would have cached reads that the retrieval budget then refused — a cache entry for
# content the model never saw, which would make the very next read a false "you already have
# this". Two hooks, because one event cannot honestly do both jobs.
#
# NOTE ON BASH: PostToolUse on `Bash` never fires for a FAILING command (probed 2026-09-15,
# 6 of 6 successes fired it, 0 of 6 failures, evidence/b08/hook-event-probe-20260915T153209Z).
# That is a fact about Bash and this hook is on `Read`, where the tool either returns content or
# errors; a read that errored leaves no entry because the file is hashed from disk, not from the
# tool result.
#
# EXIT CODES: 0 always. A recorder that blocked would be a control nobody registered.
set -uo pipefail

WT="${CLAUDE_PROJECT_DIR:-unknown}"
DIR="${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}"
LOG="${AGENT_CACHE_LOG:-$DIR/cache-log-$(basename "$WT").jsonl}"
STORE="${AGENT_CACHE_STORE:-$DIR/summary-cache-$(basename "$WT").json}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

emit() {  # emit <decision> <reason> <path> <sha>
  jq -nc --arg ts "$(now)" --arg hook summary-cache-record --arg tool Read --arg d "$1" \
         --arg r "$2" --arg p "$3" --arg sha "${4:-}" \
     '{ts:$ts,hook:$hook,tool:$tool,decision:$d,reason:$r,target:$p,sha:$sha}' \
     >> "$LOG" 2>/dev/null || true
}

command -v jq >/dev/null 2>&1 || exit 0
# ONE jq for the whole input — see the note in .ai/hooks/command-dedup.sh.
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
[[ "${TOOL:-}" == Read ]] || exit 0
P="${P:-}"
[[ -n "$P" && -f "$P" ]] || { emit skip no-readable-target "$P"; exit 0; }

SHA="$(shasum -a 256 "$P" 2>/dev/null | cut -d' ' -f1)"
[[ -n "$SHA" ]] || { emit error sha-failed "$P"; exit 0; }
BYTES="$(wc -c < "$P" 2>/dev/null | tr -d ' ')"
LINES="$(wc -l < "$P" 2>/dev/null | tr -d ' ')"

[[ -f "$STORE" ]] || printf '{}\n' > "$STORE"
tmp="$STORE.tmp.$$"
if jq --arg p "$P" --arg sha "$SHA" --arg ts "$(now)" \
      --argjson b "${BYTES:-0}" --argjson l "${LINES:-0}" \
      '.[$p] = {sha:$sha, ts:$ts, bytes:$b, lines:$l}' "$STORE" > "$tmp" 2>/dev/null; then
  mv "$tmp" "$STORE"
  emit record stored "$P" "$SHA"
else
  rm -f "$tmp"
  emit error store-write-failed "$P" "$SHA"
fi
exit 0
