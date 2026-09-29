#!/usr/bin/env bash
#
# verify-command-dedup — the fixture set for B11's third executing control,
# build/customizations/agent-v1.2-efficiency/.ai/hooks/command-dedup.sh.
#
# THE CASE THIS FILE EXISTS FOR IS CASE 3, AND IT IS THE ONE THE BATCH CANNOT EVER SHOW. The hook
# refuses a repeated command only WHEN THE CODE HAS NOT MOVED, and the whole mechanism is void by
# construction if the code fingerprint changes for a reason that is not the model's edit — a build
# writing into an untracked `target/`, a lockfile, a log. `target/` is gitignored in
# sample-service (checked 2026-09-29), but "checked once by hand" is not a control. Case 3 builds
# a git repo, writes a gitignored file, and asserts the repeat is STILL refused; case 4 changes a
# tracked line and asserts it is allowed. Between them they prove the fingerprint measures the
# thing it is named after.
#
# A batch can only ever show that a refusal HAPPENED. It cannot show that a refusal was RIGHT, and
# a control never shown to reject anything is indistinguishable from one that rejects nothing.
#
# It exercises THE REGISTERED FILE, never a copy.
#
# Usage: tools/verify-command-dedup.sh      (exit 0 = every case behaved as specified)
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
OVERLAY="$PWD/build/customizations/agent-v1.2-efficiency"
HOOK="$OVERLAY/.ai/hooks/command-dedup.sh"
[[ -x "$HOOK" ]] || { echo "command-dedup.sh not found or not executable: $HOOK" >&2; exit 30; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-62s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-62s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
export CLAUDE_PROJECT_DIR="$SANDBOX/observatory-run-fixture"
mkdir -p "$CLAUDE_PROJECT_DIR"
export AGENT_DEDUP_LOG="$SANDBOX/dedup-log.jsonl"
export AGENT_DEDUP_STORE="$SANDBOX/dedup-store.json"
reset() { rm -f "$AGENT_DEDUP_LOG" "$AGENT_DEDUP_STORE"; }

# A REAL git worktree, because the code fingerprint is two git calls and a fixture that stubbed
# them would be testing the stub.
git -C "$CLAUDE_PROJECT_DIR" init -q 2>/dev/null
git -C "$CLAUDE_PROJECT_DIR" config user.email fixture@example.com
git -C "$CLAUDE_PROJECT_DIR" config user.name fixture
printf 'target/\n' > "$CLAUDE_PROJECT_DIR/.gitignore"
mkdir -p "$CLAUDE_PROJECT_DIR/src"
printf 'fun main() {}\n' > "$CLAUDE_PROJECT_DIR/src/Main.kt"
git -C "$CLAUDE_PROJECT_DIR" add -A >/dev/null 2>&1
git -C "$CLAUDE_PROJECT_DIR" commit -qm "fixture baseline" >/dev/null 2>&1

run()  { printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":{"command":%s}}' "${2:-Bash}" "$(jq -Rn --arg c "$1" '$c')" | "$HOOK" >/dev/null 2>&1; }
run_stderr() { { printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')" | "$HOOK" >/dev/null; } 2>&1; }
lastdec() { [[ -f "$AGENT_DEDUP_LOG" ]] && tail -1 "$AGENT_DEDUP_LOG" | jq -r '.decision + ":" + .reason' || echo NOFILE; }
loglines() { [[ -f "$AGENT_DEDUP_LOG" ]] && grep -c . "$AGENT_DEDUP_LOG" || echo 0; }

echo "verify-command-dedup: the repeat, the fingerprint, and the two ways it could be void"

# --- 1. the first run of a command is allowed -------------------------------------------------
reset
run './mvnw test'; rc=$?
[[ "$rc" == 0 ]] && ok "the first run of a command" "exit 0" || bad "first run" "exit 0" "$rc"
[[ "$(lastdec)" == "allow:first-run" ]] && ok "and it is logged as the first run" "allow:first-run" || bad "first-run log" "allow:first-run" "$(lastdec)"

# --- 2. the same command with nothing changed is refused -------------------------------------
run './mvnw test'; rc=$?
[[ "$rc" == 2 ]] && ok "the same command with no code change" "exit 2" || bad "repeat, unchanged code" "exit 2" "$rc"
msg="$(run_stderr './mvnw test')"
grep -q 'command deduplication' <<<"$msg" && ok "the refusal names the mechanism" "named" || bad "refusal text" "'command deduplication'" "$(head -c 50 <<<"$msg")"
grep -q 'NOTHING IN' <<<"$msg" && ok "the refusal says WHY, not just that" "cause given" || bad "refusal cause" "the code-unchanged sentence" "absent"

# --- 3. NEGATIVE CONTROL: a gitignored build artifact must NOT unlock the repeat --------------
# If it did, `./mvnw test` would move the fingerprint by running and no repeat would ever be
# refused. The mechanism would be VOID BY CONSTRUCTION and its log would be full of allows —
# a control reporting success over nothing.
mkdir -p "$CLAUDE_PROJECT_DIR/target/classes"
printf 'compiled bytes\n' > "$CLAUDE_PROJECT_DIR/target/classes/Main.class"
run './mvnw test'; rc=$?
[[ "$rc" == 2 ]] && ok "NEGATIVE CONTROL: a gitignored target/ write" "exit 2, still refused" || bad "after a target/ write" "exit 2 — build output is not a code change" "$rc"

# --- 4. a real change to tracked code unlocks the same command -------------------------------
printf 'fun main() { println("x") }\n' > "$CLAUDE_PROJECT_DIR/src/Main.kt"
run './mvnw test'; rc=$?
[[ "$rc" == 0 ]] && ok "the same command after editing tracked code" "exit 0" || bad "repeat after a real edit" "exit 0" "$rc"
[[ "$(lastdec)" == "allow:repeat-after-code-changed" ]] && ok "and the reason names the change" "allow:repeat-after-code-changed" || bad "unlock log line" "allow:repeat-after-code-changed" "$(lastdec)"
run './mvnw test'; rc=$?
[[ "$rc" == 2 ]] && ok "and it re-arms at the new fingerprint" "exit 2" || bad "re-armed dedup" "exit 2" "$rc"

# --- 5. a NEW untracked file is a change (it is code until proven otherwise) ------------------
printf 'fun helper() {}\n' > "$CLAUDE_PROJECT_DIR/src/Helper.kt"
run './mvnw test'; rc=$?
[[ "$rc" == 0 ]] && ok "an untracked, un-ignored new file unlocks it" "exit 0" || bad "after a new source file" "exit 0" "$rc"

# --- 6. a DIFFERENT command is never blocked by another command's entry ----------------------
reset
run 'echo one' >/dev/null 2>&1
run 'echo two'; rc=$?
[[ "$rc" == 0 ]] && ok "a different command" "exit 0" || bad "a different command" "exit 0" "$rc"

# --- 7. whitespace normalisation: the SAME command spelled loosely is the same command -------
# It shares repair-limit.sh's normalisation on purpose. Two hooks on one event that disagreed
# about what "the same command" means would be unreadable afterwards.
reset
run './mvnw   test' >/dev/null 2>&1
run './mvnw test'; rc=$?
[[ "$rc" == 2 ]] && ok "the same command with collapsed whitespace" "exit 2" || bad "whitespace variant" "exit 2 — same fingerprint" "$rc"

# --- 8. the log is written on every call, allow and block alike ------------------------------
reset
run 'ls' >/dev/null 2>&1; a="$(loglines)"
run 'ls' >/dev/null 2>&1; b="$(loglines)"
[[ "$a" == 1 && "$b" == 2 ]] && ok "allow and block each write one line" "1 then 2" || bad "log growth" "1 then 2" "$a then $b"
if grep -qv '^{' "$AGENT_DEDUP_LOG"; then bad "log line JSON" "each line an object" "a line that is not"
else ok "every log line parses as JSON" "parses"; fi
c="$(tail -1 "$AGENT_DEDUP_LOG" | jq -r '.command')"
[[ "$c" == ls ]] && ok "the log records the refused command" "ls" || bad "logged command" "ls" "$c"

# --- 9. a command carrying a double quote does not break the log ------------------------------
# NEGATIVE CONTROL for the defect the b08 and b09 drivers both recorded on a TSV field, applied
# to a JSONL log: a printf-built line would be unparseable here.
reset
run 'grep -r "confirm shipment" src/' >/dev/null 2>&1
if [[ "$(tail -1 "$AGENT_DEDUP_LOG" | jq -r '.command')" == 'grep -r "confirm shipment" src/' ]]; then
  ok "NEGATIVE CONTROL: a command containing a quote" "logged intact"
else bad "quoted command" "the command, intact" "$(tail -1 "$AGENT_DEDUP_LOG" | jq -r '.command // "unparseable"')"; fi

# --- 10. a non-Bash tool on the same event is ignored and UNLOGGED ---------------------------
reset
run 'ls' Read; rc=$?
[[ "$rc" == 0 && "$(loglines)" == 0 ]] && ok "a non-Bash tool" "exit 0, no log line" || bad "a non-Bash tool" "exit 0 and no log line" "rc=$rc lines=$(loglines)"

# --- 11. NEGATIVE CONTROL: an empty command fails open and is recorded -----------------------
reset
run ''; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: an empty command" "exit 0, fails OPEN" || bad "empty command" "exit 0" "$rc"
[[ "$(lastdec)" == "error:no-command-in-tool-input" ]] && ok "the fail-open is recorded, not silent" "error:no-command-in-tool-input" || bad "empty-command log" "error:no-command-in-tool-input" "$(lastdec)"

# --- 12. NEGATIVE CONTROL: a corrupt store fails open ---------------------------------------
reset
printf 'not json\n' > "$AGENT_DEDUP_STORE"
run './mvnw test'; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a corrupt store" "exit 0, fails OPEN" || bad "corrupt store" "exit 0" "$rc"

# --- 13. NEGATIVE CONTROL: no git repo at all fails open, it does not block everything -------
reset
NOGIT="$SANDBOX/no-git-here"; mkdir -p "$NOGIT"
CLAUDE_PROJECT_DIR="$NOGIT" run './mvnw test'; rc=$?
[[ "$rc" == 0 ]] && ok "NEGATIVE CONTROL: a worktree with no git" "exit 0" || bad "no git repo" "exit 0" "$rc"
CLAUDE_PROJECT_DIR="$NOGIT" run './mvnw test'; rc=$?
[[ "$rc" == 2 ]] && ok "and it still dedups on the empty fingerprint" "exit 2" || bad "no-git repeat" "exit 2" "$rc"

rm -rf "$SANDBOX"
echo ""
printf 'verify-command-dedup: %s passed, %s failed, %s total.\n' "$PASS" "$FAIL" "$N"
[[ "$FAIL" == 0 ]] || exit 1
echo "verify-command-dedup: all $N cases behaved as specified."
