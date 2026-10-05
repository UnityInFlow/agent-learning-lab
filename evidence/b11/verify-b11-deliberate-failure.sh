#!/usr/bin/env bash
#
# verify-b11-deliberate-failure — the fixture set for run-b11-deliberate-failure.sh.
#
# §4 step 4: "a control that has never been shown to reject anything is indistinguishable from one
# that rejects nothing." The probe driver asserts six clauses and reports 0 when they hold. This
# set proves it reports something ELSE when they do not, and that each of its four exit codes is
# reachable for the reason it claims:
#
#   case A  the real probe, delivered hook, 2 repetitions .................. 0
#   case B  the BROKEN copy passed as the delivered reader ................. 3 (sha refusal)
#   case C  the broken copy WITH its own sha registered .................... 2 (clause failure)
#   case D  a worktree that does not exist ................................. 4
#   case E  a subject file that does not exist ............................. 4
#   case F  a recorder that is not executable .............................. 4
#   case G  an empty PATH, so jq cannot be found ........................... 4
#
# macOS now ships /usr/bin/jq, so `PATH=/usr/bin:/bin` does NOT remove it — the first version of
# case G passed exit 0 for exactly that reason, and this set caught it. An EMPTY PATH does not work
# either: the shebang is `/usr/bin/env bash` and env then looks bash up in the NEW PATH, so the
# child dies at 127 before the driver's first line. The case therefore uses a shim directory
# holding bash and nothing else — the jq check is the driver's first command, so nothing more is
# needed to reach it. Two wrong versions of one fixture case, both found by running it.
#
# Case C is the one that matters: it shows the driver can FAIL, and names which clause. Without it,
# a green case A would be worth nothing.
set -uo pipefail

LAB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" || exit 1
cd "$LAB" || exit 1
DRIVER="$LAB/evidence/b11/run-b11-deliberate-failure.sh"
SCRATCH="${TMPDIR:-/tmp}/b11-df-verify-$$"
mkdir -p "$SCRATCH" || exit 1
trap 'rm -rf "$SCRATCH"' EXIT

RUNID=40af8ffb-f0fa-4250-80cb-c6d829941d51
WT="$LAB/evidence.local/b11-worktrees/$RUNID"
HOOK="$WT/.ai/hooks/summary-cache.sh"
PASS=0; FAIL=0

run_case() {  # run_case <name> <expected rc> <env assignments...>
  local name="$1" want="$2"; shift 2
  local rc=0
  ( env "$@" DF_OUT="$SCRATCH/out-$name" DF_TAG="verify-$name" "$DRIVER" \
      >"$SCRATCH/$name.out" 2>"$SCRATCH/$name.err" ) || rc=$?
  if [[ "$rc" == "$want" ]]; then
    PASS=$((PASS+1)); printf '  ok   case %s exit %s\n' "$name" "$rc"
  else
    FAIL=$((FAIL+1)); printf '  FAIL case %s expected exit %s, got %s\n' "$name" "$want" "$rc"
    sed -n '1,4p' "$SCRATCH/$name.err" | sed 's/^/         /'
  fi
}

[[ -x "$DRIVER" ]] || { echo "no driver at $DRIVER" >&2; exit 1; }
[[ -d "$WT" ]]     || { echo "no kept worktree at $WT — this set needs the batch's evidence" >&2; exit 1; }

# The broken copy, built the same way the driver builds it, for cases B and C.
BROKEN="$SCRATCH/broken-summary-cache.sh"
awk 'NR>=85 && NR<=91 {next} {print}' "$HOOK" > "$BROKEN"
chmod +x "$BROKEN"
BROKEN_SHA="$(shasum -a 256 "$BROKEN" | cut -d' ' -f1)"

run_case A 0 DF_REPS=2
run_case B 3 DF_REPS=1 "DF_HOOK=$BROKEN"
run_case C 2 DF_REPS=1 "DF_HOOK=$BROKEN" "DF_EXPECT_SHA=$BROKEN_SHA"
run_case D 4 DF_REPS=1 "DF_WORKTREE=$SCRATCH/nope"
run_case E 4 DF_REPS=1 "DF_SUBJECT=$SCRATCH/not-a-file.kt"
run_case F 4 DF_REPS=1 "DF_RECORDER=$SCRATCH/broken-summary-cache.sh.notexec"
mkdir -p "$SCRATCH/nobin"
ln -sf "$(command -v bash)" "$SCRATCH/nobin/bash"
run_case G 4 DF_REPS=1 "PATH=$SCRATCH/nobin"

# Case C must fail for the REGISTERED reason, not for any reason: D1 and D2 are the clauses the
# missing branch breaks, and D3/D5 must still pass. A driver that returned 2 because of a typo
# would satisfy the exit code and teach nothing.
if grep -q 'FAIL D1' "$SCRATCH/C.out" && grep -q 'FAIL D2' "$SCRATCH/C.out"; then
  PASS=$((PASS+1)); printf '  ok   case C failed on D1 and D2, the clauses the break removes\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case C did not fail on D1 and D2\n'
  grep -E 'FAIL D' "$SCRATCH/C.out" | sed 's/^/         /' | head -6
fi
if grep -q 'ok   D3' "$SCRATCH/C.out"; then
  PASS=$((PASS+1)); printf '  ok   case C still passed D3 — the refusal path is intact\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case C lost D3 as well; the break is not minimal\n'
fi

# Case G must refuse for the jq reason, not by accident.
if grep -q 'PREREQ: jq is not on PATH' "$SCRATCH/G.err"; then
  PASS=$((PASS+1)); printf '  ok   case G named jq as the missing prerequisite\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case G exited 4 without naming jq\n'
fi

printf 'verify-b11-deliberate-failure: %s ok, %s failed.\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1
printf 'verify-b11-deliberate-failure: all %s cases behaved as specified.\n' "$PASS"
exit 0
