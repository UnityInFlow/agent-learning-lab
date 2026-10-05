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
#   case F  a recorder that EXISTS and is NOT executable ................... 4
#   case H  a subject with no class/fun/val/var line, so D4 would be vacuous  4
#   case K  a subject whose sha is not the registered one ................... 3
#   case L  a hook that LEAKS the file body: D4 must detect it .............. 2
#   case M  a hook whose lines 85-91 are not the mismatch branch ............ 3
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
# Case B must refuse for the SHA reason, not for the line-range reason: both now exit 3, and a case
# that stopped distinguishing them would pass while testing the wrong gate.
if grep -q 'the delivered reader hashes' "$SCRATCH/B.err"; then
  PASS=$((PASS+1)); printf '  ok   case B refused on the SHA, not on the line range\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case B exited 3 for the wrong reason: %s\n' "$(head -1 "$SCRATCH/B.err")"
fi
run_case C 2 DF_REPS=1 "DF_HOOK=$BROKEN" "DF_EXPECT_SHA=$BROKEN_SHA" "DF_SKIP_BREAK_ASSERT=1"
run_case D 4 DF_REPS=1 "DF_WORKTREE=$SCRATCH/nope"
run_case E 4 DF_REPS=1 "DF_SUBJECT=$SCRATCH/not-a-file.kt"
# Case F used to point at a path that was never created, so it proved "a recorder that does not
# exist" while claiming "a recorder that is not executable" — the §4a review round of 2026-10-05,
# non-blocking 1. It now creates the file and removes the bit, so the case tests its own sentence.
NOEXEC="$SCRATCH/recorder-not-executable.sh"
cp "$WT/.ai/hooks/summary-cache-record.sh" "$NOEXEC"
chmod -x "$NOEXEC"
run_case F 4 DF_REPS=1 "DF_RECORDER=$NOEXEC"
if grep -q 'PREREQ: recorder not executable' "$SCRATCH/F.err"; then
  PASS=$((PASS+1)); printf '  ok   case F named the recorder as the failing prerequisite\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case F exited 4 without naming the recorder\n'
fi

# Case K exercises the SUBJECT-SHA gate, which had no case at all until the second review round
# asked for one — a gate claimed in a comment and proved by nothing. A copy of the real subject with
# one byte appended must be REFUSED at exit 3, naming both shas.
MOVED="$SCRATCH/moved-subject.kt"
cp "$WT/sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt" "$MOVED"
printf '\n// one byte more than the registered subject\n' >> "$MOVED"
run_case K 3 DF_REPS=1 "DF_SUBJECT=$MOVED"
if grep -q 'the subject hashes' "$SCRATCH/K.err"; then
  PASS=$((PASS+1)); printf '  ok   case K  a subject whose sha moved is refused at exit 3, naming it\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case K  exited 3 without naming the subject sha\n'
fi

# Case H is the BLOCKING finding of that round, turned into a case: a subject with no
# class/fun/import line gave D4 nothing to search for, and the first version of the driver reported
# "no body leaked" anyway. The driver must now REFUSE rather than pass vacuously.
NOBODY="$SCRATCH/no-source-line.kt"
printf 'package com.unityinflow.sample\n\n// a file with no class, fun, val or var line\n' > "$NOBODY"
# It must pin its OWN sha: since the subject-sha gate acquired a real default (round 2, blocking 1)
# an unpinned substitute is refused at exit 3 BEFORE the prerequisite this case is about is reached.
# Case H caught that the moment the default landed, which is the cases earning their keep on each
# other — so the case satisfies the pin deliberately and then tests the thing it is named for.
NOBODY_SHA="$(shasum -a 256 "$NOBODY" | cut -d' ' -f1)"
run_case H 4 DF_REPS=1 "DF_SUBJECT=$NOBODY" "DF_EXPECT_SUBJECT_SHA=$NOBODY_SHA"
if grep -q 'so D4 cannot be decided' "$SCRATCH/H.err"; then
  PASS=$((PASS+1)); printf '  ok   case H named D4 as the clause that cannot be decided\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case H exited 4 without naming D4\n'
fi
mkdir -p "$SCRATCH/nobin"
ln -sf "$(command -v bash)" "$SCRATCH/nobin/bash"
run_case G 4 DF_REPS=1 "PATH=$SCRATCH/nobin"

# Case C must fail for the REGISTERED reason, not for any reason: D1 and D2 are the clauses the
# missing branch breaks, and **D3** must still pass. A driver that returned 2 because of a typo
# would satisfy the exit code and teach nothing.
#
# *** D5 IS DELIBERATELY NOT ASSERTED HERE, and the second review round was right that the comment
# used to claim it was. *** In case C the hook under test is ALREADY the broken copy, so the driver
# builds its D5 copy by deleting lines 85-91 of a file those line numbers no longer describe. What
# D5 does under a double break is not a property of the break this probe registers, so asserting
# anything about it would be asserting a coincidence. D5's real proof is case A, where it runs
# against the delivered hook.
if grep -q 'FAIL D1' "$SCRATCH/C.out" && grep -q 'FAIL D2' "$SCRATCH/C.out"; then
  PASS=$((PASS+1)); printf '  ok   case C failed on D1 and D2, the clauses the break removes\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case C did not fail on D1 and D2\n'
  grep -E 'FAIL D' "$SCRATCH/C.out" | sed 's/^/         /' | head -6
fi
for cl in D4 D6; do
  if grep -q "ok   $cl" "$SCRATCH/C.out"; then
    PASS=$((PASS+1)); printf '  ok   case C still passed %s — the break is minimal there too\n' "$cl"
  else
    FAIL=$((FAIL+1)); printf '  FAIL case C lost %s; the break reaches further than the mismatch branch\n' "$cl"
  fi
done
if grep -q 'ok   D3' "$SCRATCH/C.out"; then  # D3 only — see the note above about D5 under a double break
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

# ---- case L: D4's FAILURE path, which nothing exercised until round 3 of the §4a review said so.
# Cases A-K prove D4 cannot pass VACUOUSLY; none proved it can FAIL. A hook that refuses while
# echoing the file body is handed to the driver as the delivered reader, with its own sha registered,
# and D4 must report PRESENT — a leak detected — while D1 and D2 still fail for the usual reason
# (this hook has no stale branch at all). Without this case an inverted D4 would read green forever,
# which is the same sentence as the blocking finding that started round 1.
LEAKY="$SCRATCH/leaky-summary-cache.sh"
cat > "$LEAKY" <<'LEAK'
#!/usr/bin/env bash
set -uo pipefail
DIR="${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}"
LOG="${AGENT_CACHE_LOG:-$DIR/cache-log.jsonl}"
STORE="${AGENT_CACHE_STORE:-$DIR/summary-cache.json}"
IN="$(cat)"
P="$(printf '%s' "$IN" | jq -r '.tool_input.file_path // ""')"
[[ -n "$P" && -f "$P" ]] || exit 0
SHA="$(shasum -a 256 "$P" | cut -d' ' -f1)"
CACHED="$(jq -r --arg p "$P" '.[$p].sha // ""' "$STORE" 2>/dev/null)"
jq -nc --arg d block --arg r hash-match --arg p "$P" --arg sha "$SHA" --arg c "$CACHED"    '{ts:"now",hook:"leaky",tool:"Read",decision:$d,reason:$r,target:$p,sha:$sha,cachedSha:$c}' >> "$LOG"
# THE DEFECT, on purpose: the refusal hands back the file instead of its metadata.
{ echo "BLOCKED by the file-summary cache: you already read this file at this exact content."; cat "$P"; } >&2
exit 2
LEAK
chmod +x "$LEAKY"
LEAKY_SHA="$(shasum -a 256 "$LEAKY" | cut -d' ' -f1)"
run_case L 2 DF_REPS=1 "DF_HOOK=$LEAKY" "DF_EXPECT_SHA=$LEAKY_SHA" "DF_SKIP_BREAK_ASSERT=1"
if grep -q 'FAIL D4 refusal leaked a source line' "$SCRATCH/L.out"; then
  PASS=$((PASS+1)); printf '  ok   case L  D4 DETECTS a leaked body line — its failure path is reachable\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case L  D4 did not report the leak\n'
  grep -E 'D4' "$SCRATCH/L.out" | sed 's/^/         /' | head -3
fi

# ---- case M: the break's LINE RANGE is asserted, not assumed. Round 3 of the §4a review pointed
# out that `85..91` is hardcoded and nothing checked that those lines are the mismatch branch. The
# recorder half is handed over as the reader, with its own sha registered so the sha gate lets it
# through: its lines 85-91 do not exist, so the removed text cannot contain the comparison and the
# driver must refuse at exit 3 rather than call the result "the break".
WRONGHOOK="$SCRATCH/not-the-reader.sh"
cp "$WT/.ai/hooks/summary-cache-record.sh" "$WRONGHOOK"
chmod +x "$WRONGHOOK"
WRONGHOOK_SHA="$(shasum -a 256 "$WRONGHOOK" | cut -d' ' -f1)"
run_case M 3 DF_REPS=1 "DF_HOOK=$WRONGHOOK" "DF_EXPECT_SHA=$WRONGHOOK_SHA"
if grep -q 'are not the hash-mismatch branch' "$SCRATCH/M.err"; then
  PASS=$((PASS+1)); printf '  ok   case M  the line range is checked against its content, not trusted\n'
else
  FAIL=$((FAIL+1)); printf '  FAIL case M  exited 3 without naming the mismatch branch\n'
fi

printf 'verify-b11-deliberate-failure: %s ok, %s failed.\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1
printf 'verify-b11-deliberate-failure: all %s cases behaved as specified.\n' "$PASS"
exit 0
