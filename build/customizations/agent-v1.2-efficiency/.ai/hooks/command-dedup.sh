#!/usr/bin/env bash
#
# command-dedup — B11 (v1.2) mechanism 5, the third of the version's executing controls.
# Registered as a PreToolUse hook on `Bash`, beside v1.1's repair-limit.sh.
#
# THE SPEC, at build/README.md#b11 step 5: "Command deduplication against the current code
# fingerprint." The claim it rests on is narrow and checkable: A COMMAND RE-RUN AGAINST
# UNCHANGED CODE CANNOT RETURN A DIFFERENT ANSWER, so running it again buys nothing. So the rule
# is not "never repeat a command"; it is "never repeat a command WITHOUT HAVING CHANGED
# ANYTHING". Edit one line and every command is available again.
#
# *** HOW THIS DIFFERS FROM v1.1's REPAIR LIMIT, WHICH IS ON THE SAME EVENT. *** repair-limit.sh
# allows 3 attempts at the same fingerprint and 7 repeats per run, and clears a fingerprint when
# it succeeds. This hook refuses the SECOND attempt when the code has not moved. It is strictly
# stricter on that one case, and that is the efficiency mechanism rather than a conflict: the
# runs v1.1 spends on attempts 2 and 3 of an unchanged command are exactly the waste this step
# was written to remove. Both hooks run; either may block; both log.
#
# THE CODE FINGERPRINT is sha256 over `git status --porcelain` plus `git diff` in the worktree.
# That is content-sensitive for tracked files and name-sensitive for untracked ones, and it is
# two cheap git calls rather than a tree walk, because this runs in front of every Bash call
# under a 15-second hook timeout.
#   *** IT IGNORES BUILD OUTPUT, AND THAT WAS CHECKED RATHER THAN HOPED. *** `target/` is in
#   sample-service/.gitignore (verified 2026-09-29 in agent-observatory-benchmarks), so `./mvnw
#   test` does not move the fingerprint by running. Had it moved it, the fingerprint would differ
#   after every build, no repeat would ever be refused, and the mechanism would have been VOID BY
#   CONSTRUCTION with a log full of allows — a control reporting success over nothing, which is
#   this project's house failure mode.
#
# THE KNOWN FALSE-POSITIVE CLASS, NAMED BEFORE THE BATCH RATHER THAN DISCOVERED AFTER IT: a
# command whose output depends on something other than the code — a clock, the network, a flaky
# test — can legitimately return a different answer on a second run, and this hook refuses it.
# NO ALLOWLIST IS BUILT, on purpose: an allowlist of "non-deterministic commands" is a list I
# would have invented, unmeasured, inside the one variable this step registers. The refusals are
# logged with their commands, so if this class fires the log names it.
#
# THE LOG IS OUTSIDE THE WORKTREE for the reason recorded in retrieval-budget.sh (B7's preflight
# pair, exit 21, E-016:227-237). Documented path: `.agent/dedup-log.jsonl`.
#
# EXIT CODES: 0 allow · 2 BLOCK · anything else non-blocking error, the call proceeds.
set -uo pipefail

WT="${CLAUDE_PROJECT_DIR:-unknown}"
DIR="${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}"
LOG="${AGENT_DEDUP_LOG:-$DIR/dedup-log-$(basename "$WT").jsonl}"
STORE="${AGENT_DEDUP_STORE:-$DIR/dedup-store-$(basename "$WT").json}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

emit() {  # emit <decision> <reason> <fingerprint> <codeFingerprint> <command>
  jq -nc --arg ts "$(now)" --arg hook command-dedup --arg tool Bash --arg d "$1" --arg r "$2" \
         --arg fp "${3:-}" --arg code "${4:-}" --arg cmd "${5:-}" \
     '{ts:$ts,hook:$hook,tool:$tool,decision:$d,reason:$r,fingerprint:$fp,codeFingerprint:$code,command:$cmd}' \
     >> "$LOG" 2>/dev/null || true
}

# Same normalisation as v1.1's repair-limit.sh, deliberately: two hooks on one event that
# disagreed about what "the same command" means would be unreadable afterwards.
fingerprint() {
  printf '%s' "$1" \
    | tr '\n' ' ' \
    | sed -e 's/[[:space:]][[:space:]]*/ /g' -e 's/^ //' -e 's/ $//' \
    | shasum -a 256 | cut -c1-16
}

code_fingerprint() {
  { git -C "$WT" status --porcelain=v1 2>/dev/null
    git -C "$WT" diff 2>/dev/null; } | shasum -a 256 | cut -c1-16
}

command -v jq >/dev/null 2>&1 || exit 0
# *** ONE jq FOR THE WHOLE INPUT, NOT TWO, AND THAT IS A MEASUREMENT AND NOT A STYLE CHOICE. ***
# `jq` costs about 0.68 s PER INVOCATION on this machine (measured 2026-09-29: 2.72 s for four
# no-op calls) and the two git calls below about 1.8 s under load. The first version of this hook
# made five jq calls and ran in 4-6.5 s per Bash tool call. At roughly a hundred tool calls per
# run that is ten minutes of pure hook latency, and it also brings a 15-second hook timeout into
# range — a timed-out hook is a control that silently did not run. So every hook in this overlay
# parses its stdin ONCE and reads its state ONCE. The tab separator is safe because neither field
# can contain one: `tool_name` is an identifier and the command is JSON-decoded here, where a real
# tab would already have been \t on the wire.
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
{ IFS= read -r TOOL; IFS= read -r CMD; } <<<"$(printf '%s' "$IN" \
  | jq -r '(.tool_name // ""), ((.tool_input.command // "") | gsub("[\n\t]"; " "))' 2>/dev/null)"
[[ "${TOOL:-}" == Bash ]] || exit 0
[[ -n "${CMD:-}" ]] || { emit error no-command-in-tool-input; exit 0; }

FP="$(fingerprint "$CMD")"
[[ -n "$FP" ]] || { emit error fingerprint-failed "" "" "$CMD"; exit 0; }
CODE="$(code_fingerprint)"
[[ -n "$CODE" ]] || { emit error code-fingerprint-failed "$FP" "" "$CMD"; exit 0; }

[[ -f "$STORE" ]] || printf '{}\n' > "$STORE"
[[ -r "$STORE" ]] || { emit error store-unreadable "$FP" "$CODE" "$CMD"; exit 0; }

# One read, both fields — see the note on jq's cost above and the note on the separator.
{ IFS= read -r PRIOR; IFS= read -r WHEN; } <<<"$(jq -r --arg fp "$FP" \
  '(.[$fp].code // ""), (.[$fp].ts // "?")' "$STORE" 2>/dev/null)"
PRIOR="${PRIOR:-}"; WHEN="${WHEN:-?}"
if [[ -n "$PRIOR" && "$PRIOR" == "$CODE" ]]; then
  emit block "duplicate-under-unchanged-code" "$FP" "$CODE" "$CMD"
  cat >&2 <<MSG
BLOCKED by command deduplication: you already ran this exact command at ${WHEN}, and NOTHING IN
THE CODE HAS CHANGED SINCE (fingerprint ${CODE}).

Re-running it will produce the result you already have. Do one of these instead: use the output
you got; change the code, after which this command is available again immediately; run a
DIFFERENT command that answers the question you actually have now; or, if you are stuck, stop and
report what is blocking you and what you have already tried.
MSG
  exit 2
fi

tmp="$STORE.tmp.$$"
if jq --arg fp "$FP" --arg code "$CODE" --arg ts "$(now)" --arg cmd "$CMD" \
      '.[$fp] = {code:$code, ts:$ts, command:$cmd}' "$STORE" > "$tmp" 2>/dev/null; then
  mv "$tmp" "$STORE"
else
  rm -f "$tmp"
  emit error store-write-failed "$FP" "$CODE" "$CMD"
  exit 0
fi
if [[ -n "$PRIOR" ]]; then
  emit allow "repeat-after-code-changed" "$FP" "$CODE" "$CMD"
else
  emit allow first-run "$FP" "$CODE" "$CMD"
fi
exit 0
