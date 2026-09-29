#!/usr/bin/env bash
#
# verify-summary-cache — the fixture set for B11's second executing control, both halves:
#   build/customizations/agent-v1.2-efficiency/.ai/hooks/summary-cache.sh         (PreToolUse)
#   build/customizations/agent-v1.2-efficiency/.ai/hooks/summary-cache-record.sh  (PostToolUse)
#
# THE ONE CASE THAT MATTERS MOST IS THE ONE THE SPEC PUTS SECOND: "never trust a stale summary."
# A cache that refuses a re-read of a file THAT HAS CHANGED would hand the model an answer about
# code that no longer exists, and it would do it silently, and the run would then be scored on a
# decision made from a lie. Case 3 below is that case, and it is a NEGATIVE CONTROL because the
# naive implementation — key on path, ignore the hash — gets it wrong and still looks like it
# works on every other case in this file.
#
# It exercises THE REGISTERED FILES, never copies.
#
# Usage: tools/verify-summary-cache.sh      (exit 0 = every case behaved as specified)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
OVERLAY="$PWD/build/customizations/agent-v1.2-efficiency"
READER="$OVERLAY/.ai/hooks/summary-cache.sh"
WRITER="$OVERLAY/.ai/hooks/summary-cache-record.sh"
[[ -x "$READER" ]] || { echo "summary-cache.sh not found or not executable: $READER" >&2; exit 30; }
[[ -x "$WRITER" ]] || { echo "summary-cache-record.sh not found or not executable: $WRITER" >&2; exit 30; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-62s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-62s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
export CLAUDE_PROJECT_DIR="$SANDBOX/observatory-run-fixture"
mkdir -p "$CLAUDE_PROJECT_DIR"
export AGENT_CACHE_LOG="$SANDBOX/cache-log.jsonl"
export AGENT_CACHE_STORE="$SANDBOX/summary-cache.json"
reset() { rm -f "$AGENT_CACHE_LOG" "$AGENT_CACHE_STORE"; }

F="$SANDBOX/Controller.kt"
printf 'line one\nline two\nline three\n' > "$F"
SECRET="THE_FILE_BODY_MUST_NOT_APPEAR_IN_THE_REFUSAL"
G="$SANDBOX/Secret.kt"; printf '%s\n' "$SECRET" > "$G"

pre()  { printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":{"file_path":"%s"}}' "${2:-Read}" "$1" | "$READER" >/dev/null 2>&1; }
pre_stderr() { { printf '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"%s"}}' "$1" | "$READER" >/dev/null; } 2>&1; }
post() { printf '{"hook_event_name":"PostToolUse","tool_name":"%s","tool_input":{"file_path":"%s"},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":false}}' "${2:-Read}" "$1" | "$WRITER" >/dev/null 2>&1; }
lastdec() { [[ -f "$AGENT_CACHE_LOG" ]] && tail -1 "$AGENT_CACHE_LOG" | jq -r '.decision + ":" + .reason' || echo NOFILE; }
loglines() { [[ -f "$AGENT_CACHE_LOG" ]] && grep -c . "$AGENT_CACHE_LOG" || echo 0; }

echo "verify-summary-cache: the hash match, the stale entry, and what the refusal is allowed to say"

# --- 1. a first read is a miss and is allowed; the recorder stores it -------------------------
reset
pre "$F"; rc=$?
[[ "$rc" == 0 ]] && ok "the first Read of a file" "exit 0" || bad "first Read" "exit 0" "$rc"
[[ "$(lastdec)" == "allow:miss" ]] && ok "the first Read logs a miss" "allow:miss" || bad "first Read log" "allow:miss" "$(lastdec)"
post "$F"
st="$(jq -r --arg p "$F" '.[$p].sha // "none"' "$AGENT_CACHE_STORE")"
[[ "$st" != none && ${#st} == 64 ]] && ok "the recorder stored a full sha256" "64 hex" || bad "stored sha" "64 hex chars" "$st"
ln="$(jq -r --arg p "$F" '.[$p].lines' "$AGENT_CACHE_STORE")"
by="$(jq -r --arg p "$F" '.[$p].bytes' "$AGENT_CACHE_STORE")"
[[ "$ln" == 3 && "$by" == 29 ]] && ok "the summary is the size, not the content" "3 lines / 29 bytes" || bad "stored summary" "3 lines / 29 bytes" "$ln/$by"

# --- 2. the second read of the SAME content is refused ----------------------------------------
pre "$F"; rc=$?
[[ "$rc" == 2 ]] && ok "a second Read at an identical hash" "exit 2" || bad "second Read" "exit 2" "$rc"
msg="$(pre_stderr "$F")"
grep -q 'file-summary cache' <<<"$msg" && ok "the refusal names the cache" "named" || bad "refusal text" "'file-summary cache'" "$(head -c 50 <<<"$msg")"
grep -q '3 lines' <<<"$msg" && ok "the refusal hands back the summary" "line count present" || bad "refusal summary" "the line count" "absent"

# --- 3. NEGATIVE CONTROL: the file CHANGED — the entry is refused, not reused -----------------
printf 'line one\nline two\nline three\nline four\n' > "$F"
pre "$F"; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a Read after the file changed" "exit 0" || bad "read after a change" "exit 0 — a stale summary is never served" "$rc"
[[ "$(lastdec)" == "allow:stale-refused" ]] && ok "the stale entry is logged as REFUSED" "allow:stale-refused" || bad "stale log line" "allow:stale-refused" "$(lastdec)"
gone="$(jq -r --arg p "$F" 'has($p)' "$AGENT_CACHE_STORE")"
[[ "$gone" == false ]] && ok "the stale entry was dropped from the store" "dropped" || bad "stale entry" "removed from the store" "still present"

# --- 4. the cache re-arms on the new content -------------------------------------------------
post "$F"
pre "$F"; rc=$?
[[ "$rc" == 2 ]] && ok "the cache re-arms at the NEW hash" "exit 2" || bad "re-armed cache" "exit 2" "$rc"

# --- 5. the refusal must not leak the file body ----------------------------------------------
reset
pre "$G" >/dev/null 2>&1; post "$G"
msg="$(pre_stderr "$G")"
if grep -q "$SECRET" <<<"$msg"; then
  bad "the refusal quotes the file body" "a summary only" "the body"
else ok "the refusal is a summary, not the content" "no body in stderr"; fi

# --- 6. a path that is not a file is passed through ------------------------------------------
reset
pre "$SANDBOX/does-not-exist.kt"; rc=$?
[[ "$rc" == 0 ]] && ok "a Read of a path that does not exist" "exit 0" || bad "missing path" "exit 0" "$rc"
[[ "$(lastdec)" == "allow:target-not-a-file" ]] && ok "and it is logged as such" "allow:target-not-a-file" || bad "missing-path log" "allow:target-not-a-file" "$(lastdec)"

# --- 7. the matcher is shared: a Grep must pass through untouched and UNLOGGED ---------------
# NEGATIVE CONTROL. settings.json puts this hook on `Read|Grep|Glob` alongside the budget hook.
# A cache that logged a Grep would inflate H3, the delivery metric, with calls it never decided.
reset
before="$(loglines)"
pre "$F" Grep; rc=$?
after="$(loglines)"
[[ "$rc" == 0 && "$before" == "$after" ]] && ok "NEGATIVE CONTROL: a Grep on the shared matcher" "exit 0, no log line" || bad "a Grep through the cache" "exit 0 and no log line" "rc=$rc lines $before->$after"
post "$F" Grep
[[ ! -s "$AGENT_CACHE_STORE" || "$(jq -r --arg p "$F" 'has($p)' "$AGENT_CACHE_STORE" 2>/dev/null)" == false ]] \
  && ok "the recorder ignores a non-Read too" "no entry" || bad "recorder on a Grep" "no entry" "an entry"

# --- 8. every log line parses, and the log records the target -------------------------------
reset
pre "$F" >/dev/null 2>&1; post "$F"; pre "$F" >/dev/null 2>&1
if grep -qv '^{' "$AGENT_CACHE_LOG"; then bad "log line JSON" "each line an object" "a line that is not"
else ok "every log line parses as JSON" "parses"; fi
t="$(grep '"decision":"block"' "$AGENT_CACHE_LOG" | tail -1 | jq -r '.target')"
[[ "$t" == "$F" ]] && ok "the log names the read TARGET" "the path" || bad "logged target" "$F" "$t"

# --- 9. NEGATIVE CONTROL: an unreadable store fails OPEN ------------------------------------
reset
printf 'not json at all\n' > "$AGENT_CACHE_STORE"
pre "$F"; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a corrupt store" "exit 0, fails OPEN" || bad "corrupt store" "exit 0" "$rc"

rm -rf "$SANDBOX"
echo ""
printf 'verify-summary-cache: %s passed, %s failed, %s total.\n' "$PASS" "$FAIL" "$N"
[[ "$FAIL" == 0 ]] || exit 1
echo "verify-summary-cache: all $N cases behaved as specified."
