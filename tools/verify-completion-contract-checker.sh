#!/usr/bin/env bash
#
# verify-completion-contract-checker — the fixture set for tools/check-completion-contract.sh.
#
# The thing most worth proving here is NOT that the checker passes a good worktree. It is that
# UNDECIDABLE NEVER READS AS PASS. Three of §10.6's seven clauses cannot be decided from a
# finished worktree, and a checker that quietly counted them as satisfied would report seven
# green clauses over a scope of four — which is this project's house failure mode and the exact
# shape that voided a twenty-run experiment.
#
# Usage: tools/verify-completion-contract-checker.sh
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 30
CHECK="$PWD/tools/check-completion-contract.sh"
POLICY="$PWD/build/customizations/agent-v1.1/.ai/policies/protected-paths.yaml"
[[ -x "$CHECK"  ]] || { echo "check-completion-contract.sh not executable" >&2; exit 30; }
[[ -r "$POLICY" ]] || { echo "policy not readable: $POLICY" >&2; exit 30; }

PASS=0; FAIL=0; N=0
ok()  { N=$((N+1)); PASS=$((PASS+1)); printf '  ok   %-60s %s\n' "$1" "$2"; }
bad() { N=$((N+1)); FAIL=$((FAIL+1)); printf '  FAIL %-60s expected %s, got %s\n' "$1" "$2" "$3"; }

SANDBOX="$(mktemp -d)"
WT="$SANDBOX/observatory-run-fixture"
mkdir -p "$WT/src" "$WT/service"
git -C "$WT" init -q 2>/dev/null || { mkdir -p "$WT"; git -C "$WT" init -q; }
git -C "$WT" config user.email f@x; git -C "$WT" config user.name f
printf 'class A {}\n'          > "$WT/src/A.java"
printf '<project/>\n'          > "$WT/service/pom.xml"
git -C "$WT" add -A; git -C "$WT" commit -qm baseline
BASE="$(git -C "$WT" rev-parse HEAD)"
SUMMARY="$SANDBOX/summary.md"; printf 'changed A.java to satisfy criterion 1\n' > "$SUMMARY"

run() { "$CHECK" "$WT" "$@" >"$SANDBOX/out.txt" 2>&1; echo $?; }
line() { grep -E "^  [A-Z]+ +$1\." "$SANDBOX/out.txt" | awk '{print $1}'; }

# a clean change: one ordinary source file
printf 'class A { void f(){} }\n' > "$WT/src/A.java"
git -C "$WT" add -A; git -C "$WT" commit -qm work

echo "verify-completion-contract-checker: fixture set for tools/check-completion-contract.sh"
echo
echo "A CLEAN WORKTREE WITH EVERY INPUT SUPPLIED:"
G=$(run --baseline "$BASE" --evaluator-exit 0 --summary "$SUMMARY" --policy "$POLICY")
[[ "$G" == 0 ]] && ok "exit 0 when every decidable clause passes" "exit 0" || bad "clean worktree" "exit 0" "exit $G"
[[ "$(line 6)" == PASS ]] && ok "clause 6 (forbidden files) decided PASS" "PASS" || bad "clause 6" "PASS" "$(line 6)"
[[ "$(line 7)" == PASS ]] && ok "clause 7 (final summary) decided PASS" "PASS" || bad "clause 7" "PASS" "$(line 7)"

echo
echo "UNDECIDABLE NEVER READS AS PASS — the reason this fixture set exists:"
for c in 1 4; do
  [[ "$(line $c)" == UNDECIDABLE ]] && ok "clause $c is reported UNDECIDABLE, not PASS" "UNDECIDABLE" \
    || bad "clause $c" "UNDECIDABLE" "$(line $c)"
done
D="$(grep -o 'decidable clauses: [0-9]* of 7' "$SANDBOX/out.txt")"
[[ "$D" == "decidable clauses: 5 of 7" ]] && ok "the count says 5 of 7, not 7 of 7" "$D" \
  || bad "the decidable count" "decidable clauses: 5 of 7" "$D"

echo
echo "MISSING INPUTS MAKE CLAUSES UNDECIDABLE — they do not make them pass:"
G=$(run)
for c in 2 3 5 6 7; do
  [[ "$(line $c)" == UNDECIDABLE ]] && ok "no flags: clause $c is UNDECIDABLE" "UNDECIDABLE" \
    || bad "no flags: clause $c" "UNDECIDABLE" "$(line $c)"
done
[[ "$G" == 2 ]] && ok "nothing decidable at all is exit 2, NOT exit 0" "exit 2" \
  || bad "nothing decidable" "exit 2" "exit $G"

echo
echo "IT REFUSES — each decidable clause driven to FAIL:"
G=$(run --baseline "$BASE" --evaluator-exit 21 --summary "$SUMMARY" --policy "$POLICY")
[[ "$G" == 1 ]] && ok "a failing evaluator exit is exit 1" "exit 1" || bad "failing evaluator" "exit 1" "exit $G"
[[ "$(line 2)" == FAIL ]] && ok "clause 2 (build) FAILS on evaluator exit 21" "FAIL" || bad "clause 2" "FAIL" "$(line 2)"
[[ "$(line 3)" == FAIL ]] && ok "clause 3 (tests) FAILS on evaluator exit 21" "FAIL" || bad "clause 3" "FAIL" "$(line 3)"

printf '<project><dep/></project>\n' > "$WT/service/pom.xml"
git -C "$WT" add -A; git -C "$WT" commit -qm "touch a forbidden file"
G=$(run --baseline "$BASE" --evaluator-exit 0 --summary "$SUMMARY" --policy "$POLICY")
[[ "$G" == 1 ]] && ok "a changed pom.xml is exit 1" "exit 1" || bad "forbidden file changed" "exit 1" "exit $G"
[[ "$(line 6)" == FAIL ]] && ok "clause 6 FAILS on a deny-list path" "FAIL" || bad "clause 6 on pom.xml" "FAIL" "$(line 6)"
git -C "$WT" revert --no-edit HEAD >/dev/null 2>&1

printf 'class A { void f(){ /* TODO finish this */ } }\n' > "$WT/src/A.java"
git -C "$WT" add -A; git -C "$WT" commit -qm "leave a TODO"
G=$(run --baseline "$BASE" --evaluator-exit 0 --summary "$SUMMARY" --policy "$POLICY")
[[ "$(line 5)" == FAIL ]] && ok "clause 5 FAILS on an added TODO" "FAIL" || bad "clause 5 on TODO" "FAIL" "$(line 5)"
[[ "$G" == 1 ]] && ok "…and that alone makes the whole check exit 1" "exit 1" || bad "TODO overall" "exit 1" "exit $G"
git -C "$WT" revert --no-edit HEAD >/dev/null 2>&1

G=$(run --baseline "$BASE" --evaluator-exit 0 --summary "$SANDBOX/no-such-summary.md" --policy "$POLICY")
[[ "$(line 7)" == FAIL ]] && ok "clause 7 FAILS on a missing summary file" "FAIL" || bad "clause 7 missing" "FAIL" "$(line 7)"
: > "$SANDBOX/empty-summary.md"
G=$(run --baseline "$BASE" --evaluator-exit 0 --summary "$SANDBOX/empty-summary.md" --policy "$POLICY")
[[ "$(line 7)" == FAIL ]] && ok "NEGATIVE CONTROL: an EMPTY summary FAILS, it does not pass on existence" "FAIL" \
  || bad "clause 7 empty" "FAIL" "$(line 7)"

echo
echo "NEGATIVE CONTROLS — legitimate things that must NOT be refused:"
G=$(run --baseline "$BASE" --evaluator-exit 0 --summary "$SUMMARY" --policy "$POLICY")
[[ "$G" == 0 ]] && ok "the clean worktree still passes after all that" "exit 0" || bad "clean again" "exit 0" "exit $G"
printf 'class B { /* a pre-existing TODO the run did not add */ }\n' > "$WT/src/B.java"
git -C "$WT" add -A; git -C "$WT" commit -qm add-b
NEWBASE="$(git -C "$WT" rev-parse HEAD)"
printf 'class A { void g(){} }\n' > "$WT/src/A.java"
git -C "$WT" add -A; git -C "$WT" commit -qm later
G=$(run --baseline "$NEWBASE" --evaluator-exit 0 --summary "$SUMMARY" --policy "$POLICY")
[[ "$(line 5)" == PASS ]] && ok "NEGATIVE CONTROL: a TODO already in the baseline is not blamed on the run" "PASS" \
  || bad "pre-existing TODO" "PASS" "$(line 5)"

echo
echo "USAGE errors are exit 30, distinct from FAIL:"
"$CHECK" >/dev/null 2>&1; G=$?; [[ "$G" == 30 ]] && ok "no worktree argument" "exit 30" || bad "no argument" "exit 30" "exit $G"
"$CHECK" "$SANDBOX/nope" >/dev/null 2>&1; G=$?; [[ "$G" == 30 ]] && ok "a path that is not a directory" "exit 30" || bad "bad path" "exit 30" "exit $G"
"$CHECK" "$SANDBOX" >/dev/null 2>&1; G=$?; [[ "$G" == 30 ]] && ok "a directory that is not a git worktree" "exit 30" || bad "not a repo" "exit 30" "exit $G"
"$CHECK" "$WT" --nonsense >/dev/null 2>&1; G=$?; [[ "$G" == 30 ]] && ok "an unknown flag" "exit 30" || bad "unknown flag" "exit 30" "exit $G"

echo
echo "  $PASS of $N cases pass"
rm -rf "$SANDBOX"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
