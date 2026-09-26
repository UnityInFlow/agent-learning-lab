#!/usr/bin/env bash
#
# verify-b9-batch-guards — the fixture set for run-b9-batch.sh's guards and, above all, for
# AUTHOR DECISION 13's COMPUTED COST CEILING.
#
# WHY THE CEILING NEEDS A FIXTURE SET AT ALL. Decision 13 item (iv): *the ceiling only stays L2 if
# the driver computes it; a multiplication living in prose is Layer 3 again.* A driver that reads a
# manifest and multiplies is only a control if the reading and the multiplying are shown to work
# and shown to refuse. Stop 17a's flat $9.70 fired correctly and still produced an unevaluable
# threshold because the NUMBER was wrong, not the mechanism; this file tests the mechanism, and the
# number it produces is whatever the preflight measured.
#
# NO CASE STARTS A BENCHMARK RUN. A–D and H exit inside guards-only mode or before it; E–G use
# stop-rule-only mode, which evaluates the single comparison the batch loop uses and runs nothing;
# I is refused by the pid lock, the first thing the script does.
#
# Usage: evidence/b09/verify-b9-batch-guards.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b09/run-b9-batch.sh"
C="$LAB/build/customizations/agent-v1.1"
EXPECTED_CASES=11

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0
ok()  { echo "  ok   — $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL — $1"; fail=$((fail + 1)); }

# A synthetic preflight manifest. Column 13 is `cost`, columns 1 and 2 are task and arm — the same
# positions run-b9-preflight.sh writes, which is the coupling this fixture has to keep.
mkmanifest() {  # mkmanifest <name> <treated-cost> <control-cost> [task]
  local f="$WORK/$1.tsv" task="${4:-BE-003}"
  printf '# synthetic\ntask\tarm\trun_id\trc\teval\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\tlog_hits\tcorpus_match\tcost\tmodel_calls\ttool_calls\tduration_ms\tchanged\tinit_tools\tworktree\n' > "$f"
  printf '%s\ttreated\tr1\t0\t0\tsha256:x\tsha256:y\tsha256:z\tPRESENT\t3\t2\tMATCH\t%s\t9\t20\t1000\t3\tx/ok\t/tmp/w1\n' "$task" "$2" >> "$f"
  printf '%s\tcontrol\tr2\t0\t0\tnull\tsha256:y\tsha256:z\tABSENT\t0\t0\tABSENT-as-registered\t%s\t9\t20\t1000\t3\tx/ok\t/tmp/w2\n' "$task" "$3" >> "$f"
  echo "$f"
}

# The expected ceiling line, BUILT from the numbers rather than typed, with the dollar sign held in
# a variable: ShellCheck reads a literal `$0.3000` inside quotes as an expansion, and a test whose
# assertion is a typo passes for the wrong reason.
# EVERY CASE BUT K PASSES ITS OWN LOCK PATH, and the first run of this file is why: the registered
# lock at evidence/b09/.batch.lock is SHARED with run-b9-preflight.sh on purpose, so with a
# preflight in flight all eleven cases exited 8 and only K was reading what it thought it was.
# A fixture set that cannot be run while the thing it guards is running is a fixture set nobody
# runs at the moment it matters.
FREELOCK="$WORK/free.lock"

DOL='$'
ceil_line() {  # ceil_line <task> <pair> <multiplier> <ceiling>
  printf 'ceiling %s: pair %s%s x %s = %s%s' "$1" "$DOL" "$2" "$3" "$DOL" "$4"
}

echo "verify-b9-batch-guards: $EXPECTED_CASES cases against $DRIVER"

# A — THE CEILING IS COMPUTED, AND THE ARITHMETIC IS ASSERTED ON THE PRINTED LINE. 0.2000 + 0.1000
#     is a pair of $0.3000; x 11 is $3.3000. A driver carrying a hard-coded figure, or multiplying
#     by 25 as stop 17a's did, fails here.
M="$(mkmanifest A 0.2000 0.1000)"
out="$(env B9_LOCK="$FREELOCK" B9_GUARDS_ONLY=1 B9_PREFLIGHT_MANIFEST="$M" "$DRIVER" 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && grep -qF "$(ceil_line BE-003 0.3000 11 3.3000)" <<<"$out"; then
  ok "A the ceiling is computed from the preflight pair: \$0.3000 x 11 = \$3.3000 (exit 0)"
else
  bad "A computed ceiling — exit $rc, line: $(grep -m1 'ceiling BE-003' <<<"$out" || echo none)"
fi

# B — TWO TASKS, TWO CEILINGS (decision 13 item iii). One task's pair must not set the other's.
M2="$(mkmanifest B1 0.2000 0.1000 BE-003)"
{ tail -n +3 "$(mkmanifest B2 0.5000 0.4000 BE-004)"; } >> "$M2"
out="$(env B9_LOCK="$FREELOCK" B9_GUARDS_ONLY=1 B9_PREFLIGHT_MANIFEST="$M2" "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && grep -qF "$(ceil_line BE-003 0.3000 11 3.3000)" <<<"$out" \
                   && grep -qF "$(ceil_line BE-004 0.9000 11 9.9000)" <<<"$out"; then
  ok "B each task gets its OWN ceiling (\$3.3000 and \$9.9000)"
else
  bad "B two ceilings — exit $rc: $(grep -m2 'ceiling BE-00' <<<"$out" | tr '\n' ' ')"
fi

# C — NO MANIFEST: the ceiling is not computable, so the batch REFUSES. This is the case that keeps
#     decision 13 at Layer 2: a driver that fell back to a default would be carrying a number again.
out="$(env B9_LOCK="$FREELOCK" B9_PREFLIGHT_MANIFEST="$WORK/does-not-exist.tsv" "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 12 ]]; then ok "C an unreadable preflight manifest refuses the batch (exit 12)"
else bad "C unreadable manifest — wanted 12, got $rc"; fi

# D — A NULL COST in the pair: still not computable, and a ceiling that treated an unmeasured cost
#     as free would be a control reporting over a smaller scope than it claims.
M="$(mkmanifest D null 0.1000)"
out="$(env B9_LOCK="$FREELOCK" B9_PREFLIGHT_MANIFEST="$M" "$DRIVER" 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 12 ]]; then ok "D a null cost in the pair refuses the batch (exit 12)"
else bad "D null cost — wanted 12, got $rc"; fi

# E — A HALF PAIR: one arm only is not a pair, and 11 x one run is not the registered ceiling.
M="$(mkmanifest E 0.2000 0.1000)"; grep -v $'\tcontrol\t' "$M" > "$M.half"
out="$(env B9_LOCK="$FREELOCK" B9_PREFLIGHT_MANIFEST="$M.half" "$DRIVER" 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 12 ]]; then ok "E a manifest with only one arm refuses the batch (exit 12)"
else bad "E half pair — wanted 12, got $rc"; fi

# F/G/H — THE STOP RULE ITSELF, the same expression the batch loop calls. Below, exactly at, and
#         above the ceiling: `>=` is the registered comparison, so equality must fire.
out="$(env B9_STOPRULE_ONLY=1 B9_TEST_COST=3.2999 B9_TEST_CEILING=3.3000 "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 0 ]]; then ok "F cost just below the ceiling does not fire (exit 0)"
else bad "F below ceiling — wanted 0, got $rc"; fi
out="$(env B9_STOPRULE_ONLY=1 B9_TEST_COST=3.3000 B9_TEST_CEILING=3.3000 "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 11 ]]; then ok "G cost EQUAL to the ceiling fires (exit 11) — >= is the registered test"
else bad "G equal to ceiling — wanted 11, got $rc"; fi
out="$(env B9_STOPRULE_ONLY=1 B9_TEST_COST=9.9999 B9_TEST_CEILING=3.3000 "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 11 ]]; then ok "H cost above the ceiling fires (exit 11)"
else bad "H above ceiling — wanted 11, got $rc"; fi

# I — THE ONE-VARIABLE GUARD still refuses, and it refuses BEFORE the ceiling is computed, so a
#     broken pair of arms cannot be masked by a readable manifest.
d="$WORK/ctl-with-corpus"; rm -rf "$d"; cp -R "$C" "$d"; mkdir -p "$d/.ai/knowledge"
printf 'topics:\n' > "$d/.ai/knowledge/index.yaml"
M="$(mkmanifest I 0.2000 0.1000)"
out="$(env B9_LOCK="$FREELOCK" B9_GUARDS_ONLY=1 B9_OVERLAY_C="$d" B9_PREFLIGHT_MANIFEST="$M" "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 6 ]]; then ok "I the CONTROL carrying .ai/knowledge refuses the batch (exit 6)"
else bad "I treatment in both arms — wanted 6, got $rc"; fi

# J — a dead API, with the guards and the ceiling both passing, so this proves the endpoint check
#     runs after them and before any run.
M="$(mkmanifest J 0.2000 0.1000)"
out="$(env B9_LOCK="$FREELOCK" B9_API="http://127.0.0.1:1" B9_PREFLIGHT_MANIFEST="$M" "$DRIVER" 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 7 ]]; then ok "J a dead API refuses the batch (exit 7)"
else bad "J dead API — wanted 7, got $rc"; fi

# K — the pid lock. A duplicate benchmark run is evidence that cannot be deleted.
printf '%s\n' "$$" > "$WORK/held.lock"
M="$(mkmanifest K 0.2000 0.1000)"
out="$(env B9_LOCK="$WORK/held.lock" B9_PREFLIGHT_MANIFEST="$M" "$DRIVER" 2>&1)"; rc=$?
if [[ $rc -eq 8 ]]; then ok "K a held pid lock refuses a second batch (exit 8)"
else bad "K held lock — wanted 8, got $rc"; fi

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-b9-batch-guards: ${ran} cases ran, ${EXPECTED_CASES} registered — the announced"
  echo "scope and the executed scope disagree, which is the failure this line exists to catch."
  exit 1
fi
echo "verify-b9-batch-guards: ${pass} passed, ${fail} failed, ${ran} of ${EXPECTED_CASES} cases ran."
[[ "$fail" -eq 0 ]] || exit 1
