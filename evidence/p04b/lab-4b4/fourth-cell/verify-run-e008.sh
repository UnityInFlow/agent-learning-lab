#!/usr/bin/env bash
# Does the E-008 fourth-cell batch driver REFUSE?
#
#   ./evidence/p04b/lab-4b4/fourth-cell/verify-run-e008.sh
#
# `run-e008.sh` spends about $3 of benchmark runs and writes evidence that cannot be deleted
# afterwards. Every guard in front of that is a control, and a control that has never been shown
# to reject anything is indistinguishable from one that rejects nothing. This drives each guard
# until it fires and asserts BOTH the exit code and the sentence.
#
# HOW THE OVERLAY GUARDS ARE REACHED WITHOUT TOUCHING THE REAL OVERLAY. Cases 3–6 build a
# throwaway tree — a copy of the driver, a copy of the overlay and a copy of the P1 implementer.md
# it must match — and mutate the copies. `run-e008.sh` resolves LAB from its own path, so the
# copy's guards read the copy's files. Case 0 re-checks the registered overlay's hash afterwards.
#
# WHAT THIS DOES NOT PROVE: exit 0, the runner's exit 9 and the per-run delivery abort (exit 8)
# all need real benchmark runs, so none is a fixture. The happy path is proved only as far as
# "every overlay guard passes and the batch reaches the environment guards" (case 7). The
# read-back pair on EXP-4B-FOURTH-CELL-PREFLIGHT exercises the rest.
set -uo pipefail
cd "$(dirname "$0")/../../../.." || exit 1

LAB="$(pwd)"
DRIVER="$LAB/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"
[[ -x "$DRIVER" ]] || { echo "verify-run-e008: $DRIVER missing or not executable"; exit 2; }

EXPECTED_CASES=12
pass=0
fail=0

TMP="$(mktemp -d)" || exit 2
trap 'rm -rf "$TMP"' EXIT

REAL_OVERLAY="$LAB/build/customizations/implementer-prose-4b4/CLAUDE.md"
REAL_SOURCE="$LAB/build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md"
HASH_BEFORE="$(shasum -a 256 "$REAL_OVERLAY" | cut -c1-16)"

# A throwaway LAB whose overlay and source are copies, and whose sibling repos exist but hold
# no BE-003 tree — so a fixture that gets past every overlay guard stops at the tree guard.
make_tree() {
  local root="$1"
  rm -rf "$root"
  mkdir -p "$root/lab/evidence/p04b/lab-4b4/fourth-cell" \
           "$root/lab/build/customizations/implementer-prose-4b4" \
           "$root/lab/build/customizations/orchestration-4b4-P1/.claude/agents" \
           "$root/agent-observatory" "$root/agent-observatory-benchmarks" || return 1
  cp "$DRIVER" "$root/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"
  chmod 755 "$root/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"
  cp "$REAL_OVERLAY" "$root/lab/build/customizations/implementer-prose-4b4/CLAUDE.md"
  cp "$REAL_SOURCE" "$root/lab/build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md"
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
    printf '  ok    %-44s rc=%s\n' "$label" "$rc"
  else
    fail=$((fail + 1))
    printf '  FAIL  %-44s rc=%s (want %s)\n        wanted text: %s\n        got: %s\n' \
      "$label" "$rc" "$want_rc" "$want_txt" "$(echo "$out" | tail -3 | tr '\n' ' ')"
  fi
}

echo "verify-run-e008: the lock"

# 1. a live holder. $$ is this verifier, which is certainly alive.
LOCK1="$TMP/live.lock"; echo "$$" > "$LOCK1"
check "live lock refuses a second batch" 4 "REFUSING TO START" -- \
  env E008_LOCK="$LOCK1" E008_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER"
if [[ -f "$LOCK1" && "$(cat "$LOCK1")" == "$$" ]]; then
  pass=$((pass + 1)); printf '  ok    %-44s pid %s still holds it\n' "refusal left the live lock intact" "$$"
else
  fail=$((fail + 1)); printf '  FAIL  %-44s the refused batch removed or rewrote it\n' "refusal left the live lock intact"
fi

# 2. a dead holder: cleared, reported, and the batch then stops at a later guard.
LOCK2="$TMP/stale.lock"; echo "99999" > "$LOCK2"
check "stale lock is cleared and reported" 1 "stale lock from pid 99999" -- \
  env E008_LOCK="$LOCK2" E008_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER"

echo "verify-run-e008: the treatment — every guard on the overlay, driven on a copy"

# 3. a second file in the overlay: a .claude/agents/ creeping back in makes this a split again.
make_tree "$TMP/t3"
mkdir -p "$TMP/t3/lab/build/customizations/implementer-prose-4b4/.claude/agents"
cp "$REAL_SOURCE" "$TMP/t3/lab/build/customizations/implementer-prose-4b4/.claude/agents/implementer.md"
check "a second overlay file is refused" 1 "exactly one file" -- \
  env E008_LOCK="$TMP/t3.lock" E008_CAFFEINATED=1 PAIRS=1 "$TMP/t3/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"

# 4. the one file under the wrong name: the claude runtime does not read AGENTS.md.
make_tree "$TMP/t4"
mv "$TMP/t4/lab/build/customizations/implementer-prose-4b4/CLAUDE.md" \
   "$TMP/t4/lab/build/customizations/implementer-prose-4b4/AGENTS.md"
check "a file that is not CLAUDE.md is refused" 1 "is not CLAUDE.md" -- \
  env E008_LOCK="$TMP/t4.lock" E008_CAFFEINATED=1 PAIRS=1 "$TMP/t4/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"

# 5. the overlay edited, the source not: no longer "the same words". Caught by the diff.
make_tree "$TMP/t5"
printf '\nOne more sentence the worker never had.\n' \
  >> "$TMP/t5/lab/build/customizations/implementer-prose-4b4/CLAUDE.md"
check "an overlay that is not verbatim is refused" 1 "NOT byte-identical" -- \
  env E008_LOCK="$TMP/t5.lock" E008_CAFFEINATED=1 PAIRS=1 "$TMP/t5/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"

# 6. BOTH edited consistently — the diff is clean and only the hash can see it.
make_tree "$TMP/t6"
printf '\nOne more sentence, in both places.\n' \
  >> "$TMP/t6/lab/build/customizations/implementer-prose-4b4/CLAUDE.md"
printf '\nOne more sentence, in both places.\n' \
  >> "$TMP/t6/lab/build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md"
check "a consistent edit of both files is refused by the hash" 1 "the treatment moved" -- \
  env E008_LOCK="$TMP/t6.lock" E008_CAFFEINATED=1 PAIRS=1 "$TMP/t6/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"

echo "verify-run-e008: the environment"

# 7. an untouched copy gets past every overlay guard and stops at the BE-003 tree guard.
make_tree "$TMP/t7"
check "an intact overlay reaches the tree guard" 1 "BE-003 tree is" -- \
  env E008_LOCK="$TMP/t7.lock" E008_CAFFEINATED=1 PAIRS=1 "$TMP/t7/lab/evidence/p04b/lab-4b4/fourth-cell/run-e008.sh"

# 8 and 9 run against the REAL tree, where the overlay and tree guards pass. Neither can start
# a run: both fail before the batch loop.
check "a moved runtime version is refused" 1 "the runtime moved under the batch" -- \
  env E008_LOCK="$TMP/v.lock" E008_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER"

check "an unreachable prediction commit is refused" 1 "is not in this repository" -- \
  env E008_LOCK="$TMP/p.lock" E008_CAFFEINATED=1 PAIRS=1 PRED_COMMIT=deadbee "$DRIVER"

# --- a refused invocation must leave NO batch directory ----------------------
echo "verify-run-e008: a refused batch leaves no directory in the evidence tree"
before="$(ls -d "$LAB"/evidence/p04b/lab-4b4/fourth-cell/batch-* 2>/dev/null | wc -l | tr -d ' ')"
env E008_LOCK="$TMP/nodir.lock" E008_CAFFEINATED=1 PAIRS=1 EXPECT_CLAUDE=0.0.0 "$DRIVER" >/dev/null 2>&1
after="$(ls -d "$LAB"/evidence/p04b/lab-4b4/fourth-cell/batch-* 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$before" == "$after" ]]; then
  pass=$((pass + 1)); printf '  ok    %-44s %s dirs before and after\n' "no batch dir created by a refusal" "$after"
else
  fail=$((fail + 1)); printf '  FAIL  %-44s %s -> %s\n' "a refusal created a batch dir" "$before" "$after"
fi

# --- case 0: the registered overlay is byte-identical to what it was ---------
echo "verify-run-e008: the registered overlay was not touched by any of the above"
HASH_AFTER="$(shasum -a 256 "$REAL_OVERLAY" | cut -c1-16)"
if [[ "$HASH_AFTER" == "$HASH_BEFORE" ]]; then
  pass=$((pass + 1)); printf '  ok    %-44s %s\n' "overlay unchanged" "$HASH_AFTER"
else
  fail=$((fail + 1)); printf '  FAIL  %-44s %s->%s\n' "overlay CHANGED" "$HASH_BEFORE" "$HASH_AFTER"
fi

echo
echo "verify-run-e008: ${pass} passed, ${fail} failed"
if [[ "$((pass + fail))" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-run-e008: EXECUTED $((pass + fail)) cases, REGISTERED $EXPECTED_CASES" >&2
  exit 1
fi
[[ "$fail" -eq 0 ]] || exit 1
echo "verify-run-e008: all ${EXPECTED_CASES} cases behaved as specified"
exit 0
