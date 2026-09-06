#!/usr/bin/env bash
# Does the E-007 P2 (deliberate-failure) batch driver REFUSE?
#
#   ./evidence/p04b/lab-4b4/verify-run-e007-p2.sh
#
# `run-e007-p2.sh` spends about $4 of benchmark runs and writes evidence that cannot be deleted
# afterwards. Every guard in front of that is therefore a control, and a control that has never
# been shown to reject anything is indistinguishable from one that rejects nothing. This drives
# each guard until it fires, and asserts BOTH the exit code and the sentence.
#
# HOW THE OVERLAY GUARDS ARE REACHED WITHOUT TOUCHING THE REAL OVERLAY. Cases 3–6 build a
# throwaway tree — `$TMP/lab/evidence/p04b/lab-4b4/run-e007-p2.sh` plus a COPY of the overlay — and
# mutate the copy. `run-e007-p2.sh` resolves its own LAB from its own path, so the copy's guards
# read the copy's files. The registered overlay is never written to by this script, and case 0
# re-checks its two hashes afterwards to prove it.
#
# WHAT THIS DOES NOT PROVE, said here rather than left to be assumed: exit 0 and the runner's
# exit 9 both require real benchmark runs, so neither is a fixture. The happy path is proved
# only as far as "every overlay guard passes and the batch reaches the environment guards"
# (case 7). The §4 step 5 preflight pair is what exercises the rest, on its own experiment key.
set -uo pipefail
cd "$(dirname "$0")/../../.." || exit 1

LAB="$(pwd)"
DRIVER="$LAB/evidence/p04b/lab-4b4/run-e007-p2.sh"
[[ -x "$DRIVER" ]] || { echo "verify-run-e007-p2: $DRIVER missing or not executable"; exit 2; }

# Nine driven guards, plus three invariants that are cases in their own right: a refused batch
# must not delete the live holder's lock, must not leave a `batch-<STAMP>/` directory behind,
# and none of this may touch the registered overlay.
EXPECTED_CASES=12
pass=0
fail=0

TMP="$(mktemp -d)" || exit 2
trap 'rm -rf "$TMP"' EXIT

REAL_ORCH="$LAB/build/customizations/orchestration-4b4-P2/.claude/agents/orchestrator.md"
REAL_IMPL="$LAB/build/customizations/orchestration-4b4-P2/.claude/agents/implementer.md"
ORCH_HASH_BEFORE="$(shasum -a 256 "$REAL_ORCH" | cut -c1-16)"
IMPL_HASH_BEFORE="$(shasum -a 256 "$REAL_IMPL" | cut -c1-16)"

# Build a throwaway LAB whose overlay is a copy, and whose sibling repos exist but do not
# match — so a fixture that gets past every overlay guard stops at the benchmarks-sha guard
# instead of launching a run.
make_tree() {
  local root="$1"
  rm -rf "$root"
  mkdir -p "$root/lab/evidence/p04b/lab-4b4" \
           "$root/lab/build/customizations/orchestration-4b4-P2/.claude/agents" \
           "$root/agent-observatory" "$root/agent-observatory-benchmarks" || return 1
  cp "$DRIVER" "$root/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"
  chmod 755 "$root/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"
  cp "$REAL_ORCH" "$root/lab/build/customizations/orchestration-4b4-P2/.claude/agents/orchestrator.md"
  cp "$REAL_IMPL" "$root/lab/build/customizations/orchestration-4b4-P2/.claude/agents/implementer.md"
  git -C "$root/agent-observatory-benchmarks" init -q 2>/dev/null
  git -C "$root/agent-observatory-benchmarks" -c user.email=v@v -c user.name=v \
      commit -q --allow-empty -m fixture 2>/dev/null
  git -C "$root/lab" init -q 2>/dev/null
  git -C "$root/lab" -c user.email=v@v -c user.name=v \
      commit -q --allow-empty -m fixture 2>/dev/null
}

# check <label> <want_rc> <want_substring> -- <command...>
check() {
  local label="$1" want_rc="$2" want_txt="$3"; shift 4
  local out rc
  out="$("$@" 2>&1)"
  rc=$?
  if [[ "$rc" == "$want_rc" && ( -z "$want_txt" || "$out" == *"$want_txt"* ) ]]; then
    pass=$((pass + 1))
    printf '  ok    %-42s rc=%s\n' "$label" "$rc"
  else
    fail=$((fail + 1))
    printf '  FAIL  %-42s rc=%s (want %s)\n        wanted text: %s\n        got: %s\n' \
      "$label" "$rc" "$want_rc" "$want_txt" "$(echo "$out" | tail -3 | tr '\n' ' ')"
  fi
}

echo "verify-run-e007-p2: the lock — the fix stop 10 owed, because 'is a batch running?' must execute"

# 1. a live holder. $$ is this verifier, which is certainly alive.
LOCK1="$TMP/live.lock"; echo "$$" > "$LOCK1"
check "live lock refuses a second batch" 4 "REFUSING TO START" -- \
  env E007_LOCK="$LOCK1" E007_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER"
if [[ -f "$LOCK1" && "$(cat "$LOCK1")" == "$$" ]]; then
  pass=$((pass + 1)); printf '  ok    %-42s pid %s still holds it\n' "refusal left the live lock intact" "$$"
else
  fail=$((fail + 1)); printf '  FAIL  %-42s the refused batch removed or rewrote it\n' "refusal left the live lock intact"
fi

# 2. a dead holder. PID 99999 is not running; the lock must be cleared and reported, and the
#    batch must then stop at the next guard rather than proceeding on a cleared lock.
LOCK2="$TMP/stale.lock"; echo "99999" > "$LOCK2"
check "stale lock is cleared and reported" 1 "stale lock from pid 99999" -- \
  env E007_LOCK="$LOCK2" E007_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER"

echo "verify-run-e007-p2: the treatment — every guard on the overlay, driven on a copy"

# 3. the orchestrator's tools: line PRESENT. That file is P1, the treatment — and running the
#    treatment under the deliberate failure's key and name is the specific mistake this driver
#    exists to refuse. The P1 verifier's case 3 is this case with the arms swapped.
make_tree "$TMP/t3"
{ head -4 "$REAL_ORCH"; echo 'tools: Read, Grep, Glob, Task'; tail -n +5 "$REAL_ORCH"; } \
  > "$TMP/t3/lab/build/customizations/orchestration-4b4-P2/.claude/agents/orchestrator.md"
check "P1 (tools: line present) is refused" 1 "P2 IS the file WITHOUT it" -- \
  env E007_LOCK="$TMP/t3.lock" E007_CAFFEINATED=1 PAIRS=1 "$TMP/t3/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"

# 4. ANY tools: line, not just the registered one. The guard is `^tools:`, so a narrowed or
#    widened list must be refused too — otherwise the guard would only catch the exact P1 file.
make_tree "$TMP/t4"
{ head -4 "$REAL_ORCH"; echo 'tools: Read'; tail -n +5 "$REAL_ORCH"; } \
  > "$TMP/t4/lab/build/customizations/orchestration-4b4-P2/.claude/agents/orchestrator.md"
check "any other tools: line is refused too" 1 "P2 IS the file WITHOUT it" -- \
  env E007_LOCK="$TMP/t4.lock" E007_CAFFEINATED=1 PAIRS=1 "$TMP/t4/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"

# 5. the worker given its own allowlist. Registered as inheriting the session pool (probe, 3/3).
make_tree "$TMP/t5"
{ head -1 "$REAL_IMPL"; echo "tools: Read, Edit"; tail -n +2 "$REAL_IMPL"; } \
  > "$TMP/t5/lab/build/customizations/orchestration-4b4-P2/.claude/agents/implementer.md"
check "implementer with a tools: line is refused" 1 "implementer.md declares a tools: line" -- \
  env E007_LOCK="$TMP/t5.lock" E007_CAFFEINATED=1 PAIRS=1 "$TMP/t5/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"

# 6. the body edited, the tools: line intact — caught by the hash and by nothing else.
make_tree "$TMP/t6"
printf '\nAn edit the tools: guard cannot see.\n' \
  >> "$TMP/t6/lab/build/customizations/orchestration-4b4-P2/.claude/agents/orchestrator.md"
check "an edited body is refused by the hash" 1 "orchestrator.md is" -- \
  env E007_LOCK="$TMP/t6.lock" E007_CAFFEINATED=1 PAIRS=1 "$TMP/t6/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"

echo "verify-run-e007-p2: the environment"

# 7. an untouched copy gets past every overlay guard and stops at the benchmarks sha.
make_tree "$TMP/t7"
check "an intact overlay reaches the bench guard" 1 "benchmarks HEAD is" -- \
  env E007_LOCK="$TMP/t7.lock" E007_CAFFEINATED=1 PAIRS=1 "$TMP/t7/lab/evidence/p04b/lab-4b4/run-e007-p2.sh"

# 8 and 9 run against the REAL tree, where the overlay and benchmarks guards pass, so they are
# the only way to reach these two. Neither can start a run: both fail before the batch loop.
check "a moved runtime version is refused" 1 "the runtime moved under the batch" -- \
  env E007_LOCK="$TMP/v.lock" E007_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER"

check "an unreachable prediction commit is refused" 1 "is not in this repository" -- \
  env E007_LOCK="$TMP/p.lock" E007_CAFFEINATED=1 PAIRS=1 PRED_COMMIT=deadbee "$DRIVER"

# --- a refused invocation must leave NO batch directory ----------------------
# The two cases above run against the REAL tree, so if `mkdir` were still ahead of the guards
# they would each drop an empty `batch-<STAMP>/` into the evidence directory — which is exactly
# what happened on this verifier's first outing, five times.
echo "verify-run-e007-p2: a refused batch leaves no directory in the evidence tree"
before="$(ls -d "$LAB"/evidence/p04b/lab-4b4/batch-* 2>/dev/null | wc -l | tr -d ' ')"
env E007_LOCK="$TMP/nodir.lock" E007_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER" >/dev/null 2>&1
after="$(ls -d "$LAB"/evidence/p04b/lab-4b4/batch-* 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$before" == "$after" ]]; then
  pass=$((pass + 1)); printf '  ok    %-42s %s dirs before and after\n' "no batch dir created by a refusal" "$after"
else
  fail=$((fail + 1)); printf '  FAIL  %-42s %s -> %s\n' "a refusal created a batch dir" "$before" "$after"
fi

# --- case 0: the registered overlay is byte-identical to what it was ---------
echo "verify-run-e007-p2: the registered overlay was not touched by any of the above"
ORCH_AFTER="$(shasum -a 256 "$REAL_ORCH" | cut -c1-16)"
IMPL_AFTER="$(shasum -a 256 "$REAL_IMPL" | cut -c1-16)"
if [[ "$ORCH_AFTER" == "$ORCH_HASH_BEFORE" && "$IMPL_AFTER" == "$IMPL_HASH_BEFORE" ]]; then
  pass=$((pass + 1))
  printf '  ok    %-42s %s / %s\n' "overlay unchanged" "$ORCH_AFTER" "$IMPL_AFTER"
else
  printf '  FAIL  %-42s %s->%s / %s->%s\n' "overlay CHANGED" \
    "$ORCH_HASH_BEFORE" "$ORCH_AFTER" "$IMPL_HASH_BEFORE" "$IMPL_AFTER"
  fail=$((fail + 1))
fi

echo
echo "verify-run-e007-p2: ${pass} passed, ${fail} failed"
if [[ "$((pass + fail))" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-run-e007-p2: EXECUTED $((pass + fail)) cases, REGISTERED $EXPECTED_CASES" >&2
  exit 1
fi
[[ "$fail" -eq 0 ]] || exit 1
echo "verify-run-e007-p2: all ${EXPECTED_CASES} cases behaved as specified"
exit 0
