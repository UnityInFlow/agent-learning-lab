#!/usr/bin/env bash
# Prove that run-b8-batch.sh's guards REFUSE, one case each, WITHOUT spending a benchmark run.
#
# Same reason as evidence/b05, b06 and b07's guard verifiers: "a control that has never been
# shown to reject anything is indistinguishable from one that rejects nothing" (§6). The driver
# runs every guard and exits 0 under B8_GUARDS_ONLY=1, so each case below perturbs exactly one
# registered value and asserts BOTH the exit code AND that the refusal names the right thing.
#
# THE CASES THAT MATTER MOST ARE D THROUGH H. Stop 17's comparison rests on the two arms
# carrying a byte-identical agent file and differing only by agent-v1.1's CLAUDE.md and its two
# Bash hooks. A driver that would run a batch with any of those broken is a driver that would
# produce a confident number about the wrong comparison — which is exactly what stop 9 found
# when a four-name `tools:` list arrived as two. The perturbations are made in COPIES of the
# overlays, never in the registered ones.
#
# Exit 0 all cases behaved · 1 at least one guard did not refuse, or refused for the wrong reason.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

DRIVER="evidence/b08/run-b8-batch.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

run_case() {  # run_case <name> <want_rc> <want_text> [VAR=value ...]
  local name="$1" want_rc="$2" want_text="$3"; shift 3
  local out rc
  out="$(env B8_LOCK="$TMP/lock.$RANDOM" B8_GUARDS_ONLY=1 "$@" bash "$DRIVER" 2>&1)"; rc=$?
  if [[ "$rc" == "$want_rc" ]] && /usr/bin/grep -qF "$want_text" <<<"$out"; then
    echo "  ok   — $name (exit $rc)"; pass=$((pass+1))
  else
    echo "  FAIL — $name: wanted exit $want_rc naming '$want_text', got exit $rc"
    echo "         $(head -3 <<<"$out" | tr '\n' ' ')"
    fail=$((fail+1))
  fi
}

echo "verify-b8-batch-guards: driving $DRIVER with B8_GUARDS_ONLY=1"

# A. the happy path — every guard passes and NOTHING is run. If this case ever fails, the
#    verifier's other nine results mean nothing: they would all be refusing for a reason that
#    is present in the registered configuration too.
run_case "A: the registered configuration passes all guards and runs nothing" 0 \
  "every guard passed and NOTHING was run"

# B. the API endpoint. :8081 on this machine answers 000 and belongs to a SECOND, EMPTY stack;
#    a batch against it would record runs nobody can find and read as data loss.
run_case "B: a dead API port is refused, naming the code it answered" 7 \
  "ABORT: API" B8_API="http://127.0.0.1:18099"

# C. the OTLP collector. 4318 is a leaked limactl listener here: a run that reaches it records
#    null modelCalls and null cost, which looks exactly like a run that made no model calls.
run_case "C: a dead OTLP endpoint is refused" 7 \
  "ABORT: OTLP" B8_OTLP="http://localhost:4318"

# ---- the one-variable guards. Each perturbs a COPY; the registered overlays are untouched.
mkdir -p "$TMP/ov"
cp -R build/customizations/agent-v1.1  "$TMP/ov/t"
cp -R build/customizations/verify-v1.0 "$TMP/ov/c"

# D. the arms' agent files must be byte-identical. This is the treatment boundary itself.
cp -R "$TMP/ov/c" "$TMP/ov/c-agentdrift"
printf '\n<!-- one byte of drift -->\n' >> "$TMP/ov/c-agentdrift/.claude/agents/backend-feature-phases.md"
run_case "D: a control whose agent file drifted is refused" 6 \
  "the arms' agent files DIFFER" B8_OVERLAY_C="$TMP/ov/c-agentdrift"

# E. and it must be the REGISTERED agent file, not merely the same one in both arms. Identical
#    and wrong is the failure D alone cannot see.
cp -R "$TMP/ov/t" "$TMP/ov/t-both-wrong"; cp -R "$TMP/ov/c" "$TMP/ov/c-both-wrong"
for d in t-both-wrong c-both-wrong; do
  printf '\n<!-- same drift in BOTH arms -->\n' >> "$TMP/ov/$d/.claude/agents/backend-feature-phases.md"
done
run_case "E: an agent file that drifted in BOTH arms alike is still refused" 6 \
  "agent file is not the registered one" B8_OVERLAY_T="$TMP/ov/t-both-wrong" B8_OVERLAY_C="$TMP/ov/c-both-wrong"

# F. the treated CLAUDE.md is the independent variable; its sha is registered in E-018/E-019 and
#    read back per run as instructionsHash. A drifted one is a different treatment.
cp -R "$TMP/ov/t" "$TMP/ov/t-instrdrift"
printf '\nA sentence nobody registered.\n' >> "$TMP/ov/t-instrdrift/CLAUDE.md"
run_case "F: a drifted treated CLAUDE.md is refused" 6 \
  "treated CLAUDE.md is not the registered one" B8_OVERLAY_T="$TMP/ov/t-instrdrift"

# G. the control must carry NO CLAUDE.md. P1's second half is `instructionsHash null on 10 of
#    10 control runs`; a control with any CLAUDE.md cannot produce it, and the B4 overlay
#    force-add is the precedent for this arriving by accident.
cp -R "$TMP/ov/c" "$TMP/ov/c-hasclaude"
printf 'anything at all\n' > "$TMP/ov/c-hasclaude/CLAUDE.md"
run_case "G: a control overlay carrying a CLAUDE.md is refused" 6 \
  "CONTROL overlay has a CLAUDE.md" B8_OVERLAY_C="$TMP/ov/c-hasclaude"

# H. the treated hooks must exist and be executable — a non-executable hook is a hook that
#    never runs, and the run-state file would be ABSENT on a treated run, which decision rule
#    row 0 reads as the treatment not having been delivered. Two runs like that VOID the batch.
cp -R "$TMP/ov/t" "$TMP/ov/t-nohook"; rm -f "$TMP/ov/t-nohook/.ai/hooks/repair-record.sh"
run_case "H: a treated overlay missing repair-record.sh is refused" 6 \
  "missing an executable .ai/hooks/repair-record.sh" B8_OVERLAY_T="$TMP/ov/t-nohook"
cp -R "$TMP/ov/t" "$TMP/ov/t-unexec"; chmod -x "$TMP/ov/t-unexec/.ai/hooks/repair-limit.sh"
run_case "H2: a treated hook that is present but NOT executable is refused" 6 \
  "missing an executable .ai/hooks/repair-limit.sh" B8_OVERLAY_T="$TMP/ov/t-unexec"

# I. the control must NOT carry the treated hooks, or the treatment is in both arms and the
#    comparison measures nothing. The mirror of H, and the half a present-file check misses.
cp -R "$TMP/ov/c" "$TMP/ov/c-hashooks"
cp "$TMP/ov/t/.ai/hooks/repair-limit.sh" "$TMP/ov/c-hashooks/.ai/hooks/repair-limit.sh"
run_case "I: a control overlay carrying repair-limit.sh is refused" 6 \
  "CONTROL overlay carries .ai/hooks/repair-limit.sh" B8_OVERLAY_C="$TMP/ov/c-hashooks"

# J. the pid lock. A second batch on one machine would interleave two experiments' runs and
#    contaminate both; stop 15 lost a session to two live builders on one tree.
echo $$ > "$TMP/livelock"
run_case "J: a live lock refuses a second batch" 8 \
  "a batch is already running" B8_LOCK="$TMP/livelock"

# K. and a STALE lock must NOT refuse — a crashed batch would otherwise block every later one
#    and the fix would be to delete a file, which nobody would remember to do.
echo 999999 > "$TMP/stalelock"
run_case "K: a stale lock (dead pid) does not block a batch" 0 \
  "every guard passed and NOTHING was run" B8_LOCK="$TMP/stalelock"

echo ""; echo "verify-b8-batch-guards: $pass passed, $fail failed"
[[ "$fail" -eq 0 ]] || exit 1
