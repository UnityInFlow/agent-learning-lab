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
# I is refused by the pid lock, the first thing the script does. N–Q cover --resume and exit inside
# resume-validate-only or resume-plan-only mode, both of which run nothing and — case Q — must not
# write to the manifest they read. Q exists because the first version of the resume code appended
# its banner BEFORE the plan-only exit, so a dry run mutated a real batch's manifest.
#
# Usage: evidence/b09/verify-b9-batch-guards.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b09/run-b9-batch.sh"
C="$LAB/build/customizations/agent-v1.1"
EXPECTED_CASES=17

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0
ok()  { echo "  ok   — $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL — $1"; fail=$((fail + 1)); }

# A synthetic preflight manifest. *** THE COLUMN ORDER HERE IS DELIBERATELY NOT THE REAL ONE IN
# CASE L. *** The first version of this helper wrote its own header with `cost` at column 13 and the
# driver read `$13` by position; when two columns were later inserted ahead of cost in the REAL
# manifest, the driver summed the string `no` as 0, produced a $0.0000 ceiling, did not refuse, and
# this fixture set passed. A fixture that writes its own format is testing a copy of the format.
# The header below is the real preflight manifest's, and case L shifts it on purpose.
REAL_HDR='task\tarm\trun_id\trc\teval\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\tlog_hits\trouter_mentions\trouter_denied\tcorpus_match\tcost\tmodel_calls\ttool_calls\tduration_ms\tchanged\tinit_tools\tworktree'
mkmanifest() {  # mkmanifest <name> <treated-cost> <control-cost> [task]
  local f="$WORK/$1.tsv" task="${4:-BE-003}"
  { printf '# synthetic\n'; printf '%b\n' "$REAL_HDR"
    printf '%s\ttreated\tr1\t0\t0\tsha256:x\tsha256:y\tsha256:z\tPRESENT\t3\t2\t3\tno\tMATCH\t%s\t9\t20\t1000\t3\tx/ok\t/tmp/w1\n' "$task" "$2"
    printf '%s\tcontrol\tr2\t0\t0\tnull\tsha256:y\tsha256:z\tABSENT\t0\t0\t0\tno\tABSENT-as-registered\t%s\t9\t20\t1000\t3\tx/ok\t/tmp/w2\n' "$task" "$3"
  } > "$f"
  echo "$f"
}

# EVERY CASE BUT K PASSES ITS OWN LOCK PATH, and the first run of this file is why: the registered
# lock at evidence/b09/.batch.lock is SHARED with run-b9-preflight.sh on purpose, so with a
# preflight in flight all cases exited 8 and only K was reading what it thought it was.
FREELOCK="$WORK/free.lock"

# The expected ceiling line, BUILT from the numbers rather than typed, with the dollar sign held in
# a variable: ShellCheck reads a literal `$0.3000` inside quotes as an expansion, and a test whose
# assertion is a typo passes for the wrong reason.
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

# L — THE COLUMN SHIFT THAT ACTUALLY HAPPENED. `cost` is moved to a different position with its
#     NAME intact; a driver reading by position gets whatever now sits at the old index, and the
#     value put there is the literal string `no`, which awk sums as 0. The ceiling must still be
#     $3.3000 — read by name — and must NOT be $0.0000.
SHIFT="$WORK/shifted.tsv"
{ printf '# synthetic, columns reordered\n'
  printf 'task\tarm\tcost\trouter_denied\trun_id\n'
  printf 'BE-003\ttreated\t0.2000\tno\tr1\n'
  printf 'BE-003\tcontrol\t0.1000\tno\tr2\n'
} > "$SHIFT"
out="$(env B9_LOCK="$FREELOCK" B9_GUARDS_ONLY=1 B9_PREFLIGHT_MANIFEST="$SHIFT" "$DRIVER" 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 0 ]] && grep -qF "$(ceil_line BE-003 0.3000 11 3.3000)" <<<"$out"; then
  ok "L a REORDERED manifest still computes \$3.3000 — the cost column is found by NAME"
else
  bad "L column shift — exit $rc, line: $(grep -m1 'ceiling BE-003' <<<"$out" || echo none)"
fi

# M — A NON-NUMERIC COST. `no`, `null`, an empty field or any string in the cost column is NOT zero;
#     it is unreadable, and a ceiling that treats an unmeasured cost as free is a control reporting
#     over a smaller scope than it claims.
NUM="$WORK/nonnumeric.tsv"
{ printf '# synthetic\n'; printf 'task\tarm\tcost\n'
  printf 'BE-003\ttreated\tno\n'; printf 'BE-003\tcontrol\t0.1000\n'
} > "$NUM"
out="$(env B9_LOCK="$FREELOCK" B9_PREFLIGHT_MANIFEST="$NUM" "$DRIVER" 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 12 ]]; then ok "M a NON-NUMERIC cost refuses the batch (exit 12) rather than summing it as 0"
else bad "M non-numeric cost — wanted 12, got $rc"; fi

# --- N–Q: --resume. A resume that joined the wrong batch would pool two populations under one tag.

# A synthetic BATCH manifest (not a preflight manifest — different header), with the four registered
# hash strings the driver greps for. Written from the driver's own defaults so a hash change breaks
# this fixture rather than silently passing it.
KH='sha256:0770219ae7f4281a80071d78dadea285'
AH='sha256:b3450564b6f32d6193e8580db766210e'
IT='sha256:ebf489800a60a156986f98ea4f127848'
IC='sha256:a94237242e8c1308fb1d434a06a03463'
BATCH_HDR='task\tseq\tarm\trun_id\trc\teval\tf13\tedits\truntime_ver\tmodel\tknowledge_hash\tinstr_hash\tagent_hash\tlog_state\tlog_lines\tlog_hits\tfirst_status\trouter_mentions\trouter_denied\tcorpus_match\tmodel_calls\ttool_calls\tcost\tduration_ms\tchanged\tinit_tools\tworktree'
mkbatch() {  # mkbatch <TAG> <n> [omit-hash]
  local tag="$1" n="$2" omit="${3:-}" d="$WORK/evidence/b09/batch-$1" kh="$KH"
  # *** THE WRONG-POPULATION CASE HAS TO CHANGE THE HASH EVERYWHERE, not only in the header comment.
  # The first version of case O changed the comment and left the real hash in the data rows, the
  # driver's grep found it there, and the case passed for the wrong reason — a fixture reporting over
  # a scope smaller than it claims, which is the house failure mode arriving inside its own control.
  [[ "$omit" == knowledge ]] && kh='sha256:ffffffffffffffffffffffffffffffff'
  mkdir -p "$d"
  { printf '# B9 REGISTERED BATCH %s  n=%s per arm per task, interleaved (author decision 9)\n' "$tag" "$n"
    printf '# expected knowledgeHash treated %s / control null\n' "$kh"
    printf '# expected agentHash BOTH arms %s; instructionsHash treated %s / control %s\n' "$AH" "$IT" "$IC"
    printf '%b\n' "$BATCH_HDR"
    printf 'BE-003\t01\ttreated\tr-t1\t0\t0\tno\t3\t2.1.283\tclaude-haiku-4-5-20251001\t%s\t%s\t%s\tPRESENT\t2\t1\thit\t2\tno\tMATCH\t24\t21\t0.2000\t118000\t3\tx/match\t/tmp/wt1\n' "$kh" "$IT" "$AH"
    printf 'BE-003\t01\tcontrol\tr-c1\t0\t0\tno\t3\t2.1.283\tclaude-haiku-4-5-20251001\tnull\t%s\t%s\tABSENT\t0\t0\tn/a\t0\tno\tABSENT-as-registered\t21\t20\t0.1000\t123000\t3\tx/match\t/tmp/wt2\n' "$IC" "$AH"
    printf 'BE-003\t02\ttreated\tr-t2\t0\t0\tno\t3\t2.1.283\tclaude-haiku-4-5-20251001\t%s\t%s\t%s\tABSENT\t0\t0\tn/a\t0\tno\tMATCH\t26\t21\tnull\t5420000\t3\tx/match\t/tmp/wt3\n' "$kh" "$IT" "$AH"
  } > "$d/manifest.tsv"
  echo "$d/manifest.tsv"
}
# The resume paths read $B9_EVID_ROOT/batch-<TAG>; the sandbox moves ONLY that root, so the
# one-variable guards still run against the REAL overlays under $LAB.
RESUME_ENV=(B9_LOCK="$FREELOCK")

# N — A TAG WITH NO MANIFEST. Nothing to join, so nothing is joined.
out="$(env "${RESUME_ENV[@]}" B9_EVID_ROOT="$WORK/evidence/b09" B9_RESUME_VALIDATE_ONLY=1 B9_PREFLIGHT_MANIFEST="$(mkmanifest N 0.2000 0.1000)" \
        "$DRIVER" --resume 20990101T000000Z 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 13 ]]; then ok "N --resume on a TAG with no manifest refuses (exit 13)"
else bad "N missing manifest — wanted 13, got $rc"; fi

# O — A DIFFERENTLY-REGISTERED POPULATION. The corpus hash in the joined manifest is not the one
#     this driver would deliver, so the two are not one population and the resume is refused.
mkbatch 20260101T000000Z 10 knowledge >/dev/null
out="$(env "${RESUME_ENV[@]}" B9_EVID_ROOT="$WORK/evidence/b09" B9_RESUME_VALIDATE_ONLY=1 B9_PREFLIGHT_MANIFEST="$(mkmanifest O 0.2000 0.1000)" \
        "$DRIVER" --resume 20260101T000000Z 10 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 13 ]]; then ok "O --resume onto a manifest registering a DIFFERENT corpus refuses (exit 13)"
else bad "O wrong population — wanted 13, got $rc"; fi

# P — A DIFFERENT n. A resume may not change the registered population size; E-022's prediction 1 is
#     a one-arm binomial at >= 8 of 10 and is not evaluable at another n.
mkbatch 20260202T000000Z 10 >/dev/null
out="$(env "${RESUME_ENV[@]}" B9_EVID_ROOT="$WORK/evidence/b09" B9_RESUME_VALIDATE_ONLY=1 B9_PREFLIGHT_MANIFEST="$(mkmanifest P 0.2000 0.1000)" \
        "$DRIVER" --resume 20260202T000000Z 5 BE-003 2>&1)"; rc=$?
if [[ $rc -eq 13 ]]; then ok "P --resume with n=5 onto a manifest registering n=10 refuses (exit 13)"
else bad "P n mismatch — wanted 13, got $rc"; fi

# Q — THE SKIP SET, THE SEEDED COST, AND THE NULL COST — and the manifest is NOT written to. Three
#     recorded rows: 01 treated, 01 control, 02 treated. So 02 control must be RUN, 01 both SKIP,
#     the seeded BE-003 cost must be $0.3000 (0.2000 + 0.1000, with the third row's `null` NOT
#     summed as zero), and the file must come out byte-identical.
BM="$(mkbatch 20260303T000000Z 10)"
cp "$BM" "$WORK/q-before.tsv"
out="$(env "${RESUME_ENV[@]}" B9_EVID_ROOT="$WORK/evidence/b09" B9_RESUME_PLAN_ONLY=1 B9_PREFLIGHT_MANIFEST="$(mkmanifest Q 0.2000 0.1000)" \
        "$DRIVER" --resume 20260303T000000Z 10 BE-003 2>&1)"; rc=$?
q_ok=1
grep -qF 'SKIP BE-003 01 treated' <<<"$out" || q_ok=0
grep -qF 'SKIP BE-003 01 control' <<<"$out" || q_ok=0
grep -qF 'SKIP BE-003 02 treated' <<<"$out" || q_ok=0
grep -qF 'RUN  BE-003 02 control' <<<"$out" || q_ok=0
grep -qF 'RUN  BE-003 10 control' <<<"$out" || q_ok=0
grep -qF "BE-003 already spent ${DOL}0.3000" <<<"$out" || q_ok=0
cmp -s "$WORK/q-before.tsv" "$BM" || q_ok=0
if [[ $rc -eq 0 && $q_ok -eq 1 ]]; then
  ok "Q the skip set and the seeded cost ${DOL}0.3000 are right, a null cost is NOT summed as 0, and the manifest is untouched"
else
  bad "Q resume plan — exit $rc, q_ok=$q_ok: $(grep -m1 'already spent' <<<"$out" || echo 'no spend line'); manifest $(cmp -s "$WORK/q-before.tsv" "$BM" && echo identical || echo MUTATED)"
fi

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-b9-batch-guards: ${ran} cases ran, ${EXPECTED_CASES} registered — the announced"
  echo "scope and the executed scope disagree, which is the failure this line exists to catch."
  exit 1
fi
echo "verify-b9-batch-guards: ${pass} passed, ${fail} failed, ${ran} of ${EXPECTED_CASES} cases ran."
[[ "$fail" -eq 0 ]] || exit 1
