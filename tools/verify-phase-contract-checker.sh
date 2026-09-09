#!/usr/bin/env bash
# Does check-phase-contract.py still REFUSE, or has it only ever been shown to pass?
#
#   ./tools/verify-phase-contract-checker.sh
#
# WHY THIS EXISTS. `check-phase-contract.py` is the instrument B5's gate rests on, and an
# instrument that has only been run against good input proves that good input passes. This
# project has shipped that mistake with ShellCheck clean and nine green fixtures behind it:
# none of those could catch "this gate admits something it should not", because every fixture
# was a case the author already believed was handled.
#
# So the fixtures below are weighted toward the ADMISSIONS that would be expensive. Case C is
# the one the whole tool exists for: an agent that edits the repository in turn two and then
# prints all six phase markers in its closing message. A checker that greps the final text
# passes it, reports six of six, and the arm becomes a plain baseline wearing phase markers.
#
# CHECKS
#   A  a clean phased run passes                                        exit 0
#   B  a missing phase marker is refused                                exit 2
#   C  markers emitted AFTER the first edit are refused — the narrated  exit 2
#      phase, which is what this instrument is for
#   D  phases out of registered order are refused                       exit 2
#   E  a surviving template token is refused                            exit 2
#   F  DONE without its completion fields is refused                    exit 2
#   G  a duplicated marker is refused                                   exit 2
#   H  an empty transcript is UNUSABLE, not FAIL — a harness finding    exit 3
#   I  a non-JSON file is UNUSABLE, not FAIL                            exit 3
#   J  a phased run that ALSO delegated still passes, and says so — the
#      confound is reported, never silently folded into the verdict     exit 0
#   K  a phased run that implemented NOTHING is refused, because an
#      ordering that never had code to order proves nothing             exit 2
#   L  a run that writes ONLY through Bash before DESIGN is refused —   exit 2
#      and the refusal says so, instead of claiming nothing was written
#   M  the residual hole, asserted rather than described: real work      exit 0
#      through Bash before DESIGN plus one Edit after PASSES, and the
#      write-shape count is reported beside the verdict
#
# NEGATIVE CONTROL, asserted rather than remembered: the same eleven fixtures are re-run
# against tools/naive-phase-checker.py — the text-only checker a reasonable person writes
# first — and the split must be exactly 2 passed, 11 failed, with fixture C coming back
# PASS (6 of 6 markers). Registered because this instrument's whole claim is that it catches
# what a text grep misses, and a claim measured against a scratch file nobody committed
# cannot be reproduced by anyone. Found by pass 18 §2.2.
#
# Exit 0 every case behaved as registered · 2 A CASE FAILED.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

CHECKER="${CHECKER_UNDER_TEST:-./tools/check-phase-contract.py}"
# 11 fixtures, plus two negative-control assertions that only the top-level invocation
# runs — a child driving a substitute checker must not recurse into them.
if [[ -n "${CHECKER_UNDER_TEST:-}" ]]; then EXPECTED_CASES=13; else EXPECTED_CASES=15; fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok   — $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL — $1"; fail=$((fail + 1)); }

# --- fixture builders ------------------------------------------------------
# Each line is one stream-json event, exactly as the runner keeps them.
say()  { printf '{"type":"assistant","message":{"content":[{"type":"text","text":%s}]}}\n' "$(printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"; }
use()  { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"%s"}]}}\n' "$1"; }
useb() { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":%s}}]}}\n' "$(printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"; }
sub()  { printf '{"type":"assistant","parent_tool_use_id":"toolu_x","message":{"content":[{"type":"text","text":"worker"}]}}\n'; }

done_block='<<PHASE:DONE>>
Requirement   Confirm a created shipment.
Changed       ShipmentController.kt — the endpoint had to exist.
Tests         repeat confirm, cancelled, unknown id.
Verification  ./mvnw test — 24 passed.'

good_run() {
  say "<<PHASE:ANALYSIS>> The ticket asks for an idempotent confirm."
  use Read
  say "<<PHASE:DESIGN>> Add confirm() to the service; reuse the ApiError envelope."
  use Edit
  use Bash
  say "<<PHASE:IMPLEMENTATION>> Endpoint added."
  say "<<PHASE:VERIFICATION>> ./mvnw test — 24 passed."
  say "<<PHASE:REVIEW>> AC3 and AC5 map to the two new tests."
  say "$done_block"
}

# A — the shape the treatment is supposed to produce
good_run > "$TMP/a.jsonl"
"$CHECKER" "$TMP/a.jsonl" >/dev/null 2>&1; rc=$?
[[ $rc -eq 0 ]] && ok "A: a clean phased run passes (exit 0)" \
                || bad "A: expected exit 0, got $rc"

# B — a phase simply skipped
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:DESIGN>> y"; use Edit
  say "<<PHASE:IMPLEMENTATION>> z"; say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/b.jsonl"
out=$("$CHECKER" "$TMP/b.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "missing phase marker" <<<"$out" && grep -q "VERIFICATION" <<<"$out"; then
  ok "B: a missing phase marker is refused and named (exit 2)"
else
  bad "B: expected exit 2 naming VERIFICATION, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# C — THE CASE THIS TOOL EXISTS FOR. Every marker present, every marker in order, all of them
# printed after the work was already done. A text-only checker reports 6 of 6 and passes it.
{ say "Let me just fix this."; use Edit; use Bash
  say "<<PHASE:ANALYSIS>> The ticket asks for an idempotent confirm."
  say "<<PHASE:DESIGN>> Reuse the envelope."
  say "<<PHASE:IMPLEMENTATION>> Endpoint added."
  say "<<PHASE:VERIFICATION>> ./mvnw test — 24 passed."
  say "<<PHASE:REVIEW>> AC3 and AC5 map to the two new tests."
  say "$done_block"; } > "$TMP/c.jsonl"
out=$("$CHECKER" "$TMP/c.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "code was written before DESIGN" <<<"$out"; then
  ok "C: markers printed after the first edit are refused — the narrated phase (exit 2)"
else
  bad "C: expected exit 2 on code-order, got $rc: $(head -3 <<<"$out" | tr '\n' ' ')"
fi

# D — DESIGN after IMPLEMENTATION
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:IMPLEMENTATION>> z"; say "<<PHASE:DESIGN>> y"; use Edit
  say "<<PHASE:VERIFICATION>> v"; say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/d.jsonl"
out=$("$CHECKER" "$TMP/d.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "out of registered order" <<<"$out"; then
  ok "D: phases out of registered order are refused (exit 2)"
else
  bad "D: expected exit 2 on order, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# E — the template echoed instead of instantiated
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:DESIGN>> y"; use Edit
  say "<<PHASE:IMPLEMENTATION>> Added {Entity}Controller."
  say "<<PHASE:VERIFICATION>> v"; say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/e.jsonl"
out=$("$CHECKER" "$TMP/e.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "template token" <<<"$out"; then
  ok "E: a surviving template token is refused (exit 2)"
else
  bad "E: expected exit 2 on placeholders, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# F — DONE that declares completion without the contract behind it
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:DESIGN>> y"; use Edit
  say "<<PHASE:IMPLEMENTATION>> z"; say "<<PHASE:VERIFICATION>> v"; say "<<PHASE:REVIEW>> w"
  say "<<PHASE:DONE>> All good, shipped it."; } > "$TMP/f.jsonl"
out=$("$CHECKER" "$TMP/f.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "missing contract field" <<<"$out"; then
  ok "F: DONE without its completion fields is refused (exit 2)"
else
  bad "F: expected exit 2 on completion, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# G — the same phase announced twice, which is a loop reported as a procedure
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:DESIGN>> y"; use Edit
  say "<<PHASE:DESIGN>> y again"; say "<<PHASE:IMPLEMENTATION>> z"
  say "<<PHASE:VERIFICATION>> v"; say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/g.jsonl"
out=$("$CHECKER" "$TMP/g.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "more than once" <<<"$out"; then
  ok "G: a duplicated phase marker is refused (exit 2)"
else
  bad "G: expected exit 2 on duplicate, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# H — an empty transcript is a HARNESS finding. Scoring it as FAIL would file a dead run as a
# treatment that did not work, which is how a batch loses its own strongest signal.
: > "$TMP/h.jsonl"
out=$("$CHECKER" "$TMP/h.jsonl" 2>&1); rc=$?
if [[ $rc -eq 3 ]] && grep -q "UNUSABLE" <<<"$out"; then
  ok "H: an empty transcript is UNUSABLE (exit 3), not a failed run"
else
  bad "H: expected exit 3, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# I — same separation, different cause
printf 'this is not json at all\n' > "$TMP/i.jsonl"
out=$("$CHECKER" "$TMP/i.jsonl" 2>&1); rc=$?
if [[ $rc -eq 3 ]] && grep -q "UNUSABLE" <<<"$out"; then
  ok "I: a non-JSON file is UNUSABLE (exit 3), not a failed run"
else
  bad "I: expected exit 3, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# J — a delegating run is not a contract violation, it is a DIFFERENT ARM. The checker must
# pass it and say so; folding the confound into the verdict would hide the one fact that
# separates the phases arm from the phases-plus-split arm.
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:DESIGN>> y"; use Task; sub; use Edit
  say "<<PHASE:IMPLEMENTATION>> z"; say "<<PHASE:VERIFICATION>> v"
  say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/j.jsonl"
out=$("$CHECKER" "$TMP/j.jsonl" 2>&1); rc=$?
if [[ $rc -eq 0 ]] && grep -q "this run delegated" <<<"$out"; then
  ok "J: a phased run that delegated passes, and the confound is reported (exit 0)"
else
  bad "J: expected exit 0 reporting delegation, got $rc: $(head -3 <<<"$out" | tr '\n' ' ')"
fi

# K — six markers, correct order, nothing implemented. The ordering check has nothing to order,
# and reporting PASS here would credit the treatment for a run that did no work.
{ say "<<PHASE:ANALYSIS>> x"; say "<<PHASE:DESIGN>> y"; say "<<PHASE:IMPLEMENTATION>> z"
  say "<<PHASE:VERIFICATION>> v"; say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/k.jsonl"
out=$("$CHECKER" "$TMP/k.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "nothing was implemented" <<<"$out"; then
  ok "K: six markers with no implementation is refused (exit 2)"
else
  bad "K: expected exit 2 on empty implementation, got $rc: $(head -2 <<<"$out" | tr '\n' ' ')"
fi

# L — pass 18 §3.1 fixture 31a, committed so the decision is reproducible. The old message on
# this run said "nothing was implemented" while two files had been written; a refusal is still
# right (check 2 has no Edit/Write to order) but the reason has to be true.
{ say "<<PHASE:ANALYSIS>> x"
  useb "cat > sample-service/src/main/kotlin/Order.kt <<'EOF'\nclass Order\nEOF"
  useb "cat > sample-service/src/test/kotlin/OrderTest.kt <<'EOF'\nclass OrderTest\nEOF"
  say "<<PHASE:DESIGN>> y"; useb "./mvnw test"
  say "<<PHASE:IMPLEMENTATION>> z"; say "<<PHASE:VERIFICATION>> v"
  say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/l.jsonl"
out=$("$CHECKER" "$TMP/l.jsonl" 2>&1); rc=$?
if [[ $rc -eq 2 ]] && grep -q "write shape" <<<"$out" \
   && ! grep -q "nothing was implemented" <<<"$out"; then
  ok "L: a Bash-only run is refused, and the refusal does not claim nothing was written"
else
  bad "L: expected exit 2 naming the write shapes, got $rc: $(head -3 <<<"$out" | tr '\n' ' ')"
fi

# M — pass 18 §3.1 fixture 31b/31c: THE RESIDUAL HOLE, registered as a passing case on purpose.
# Widening check 2 to treat Bash as mutating would fail every run that searched the repository
# before designing, which is the behaviour the phase order exists to encourage. So this run
# passes, and the write-shape count is printed beside the verdict for a reader to act on. If a
# later decision converts this into a refusal, THIS CASE IS THE ONE THAT MUST FLIP.
{ say "<<PHASE:ANALYSIS>> x"
  useb "sed -i '' 's/foo/bar/' sample-service/src/main/kotlin/Order.kt"
  useb "git apply /tmp/change.patch"
  say "<<PHASE:DESIGN>> y"; use Edit
  say "<<PHASE:IMPLEMENTATION>> z"; say "<<PHASE:VERIFICATION>> v"
  say "<<PHASE:REVIEW>> w"; say "$done_block"; } > "$TMP/m.jsonl"
out=$("$CHECKER" "$TMP/m.jsonl" 2>&1); rc=$?
if [[ $rc -eq 0 ]] && grep -q "BEFORE the DESIGN marker" <<<"$out"; then
  ok "M: the residual hole passes, and the pre-DESIGN write shapes are reported (exit 0)"
else
  bad "M: expected exit 0 reporting pre-DESIGN write shapes, got $rc: $(head -3 <<<"$out" | tr '\n' ' ')"
fi

# --- the negative control, run rather than described -----------------------
# Skipped when CHECKER_UNDER_TEST is set, both to avoid recursing and because the caller is
# then already driving a substitute checker deliberately.
if [[ -z "${CHECKER_UNDER_TEST:-}" ]]; then
  naive_out=$(CHECKER_UNDER_TEST=./tools/naive-phase-checker.py "$0" 2>&1 | tail -1)
  if grep -q "2 passed, 11 failed, of 13 registered cases" <<<"$naive_out"; then
    ok "NEG: the text-only checker scores 2 passed, 11 failed against these fixtures"
  else
    bad "NEG: expected the naive checker to score 2 passed, 11 failed; got: ${naive_out}"
  fi
  # The single case the whole instrument exists for, asserted by name. Captured to a variable
  # first, deliberately: the child exits 2 (nine of its cases fail, as registered), and under
  # `set -o pipefail` a pipeline inherits that non-zero even when grep matches — so piping the
  # child straight into `if ... | grep -q` reports a miss on a line that is present. Observed
  # here on the first attempt, and it is the same shape as every finding in this file: a check
  # that reports failure for a reason that has nothing to do with what it claims to test.
  naive_full=$(CHECKER_UNDER_TEST=./tools/naive-phase-checker.py "$0" 2>&1)
  if grep -q "C: expected exit 2 on code-order, got 0: naive: PASS (6 of 6 markers)" <<<"$naive_full"; then
    ok "NEG: fixture C — edits in turn two, six markers after — passes the text-only checker"
  else
    bad "NEG: fixture C did not come back PASS (6 of 6 markers) from the naive checker"
  fi
fi

echo
ran=$((pass + fail))
if [[ "$ran" -ne "$EXPECTED_CASES" ]]; then
  echo "verify-phase-contract-checker: ${ran} cases ran, ${EXPECTED_CASES} registered — the"
  echo "announced scope and the executed scope disagree, which is what this line catches."
  exit 2
fi
echo "verify-phase-contract-checker: ${pass} passed, ${fail} failed, of ${EXPECTED_CASES} registered cases"
[[ "$fail" -eq 0 ]] || exit 2
