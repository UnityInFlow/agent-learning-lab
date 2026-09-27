#!/usr/bin/env bash
# Prove every guard in evidence/b10/score-b10-batch.sh REFUSES, rather than asserting it does.
# A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing (§6). The driver is the stop-20 one with its manifest reader replaced, so the
# cases below are the stop-20 cases PLUS the two the new reader introduces: a manifest whose
# row count is not the registered 20, and a comment/header line being read as a run.
#
#   ./evidence/b10/verify-score-b10-guards.sh      from agent-learning-lab/
#
# Exit 0 all cases pass · 1 a case failed.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
DRIVER=evidence/b10/score-b10-batch.sh
MANIFEST=evidence/b10/batch-20260927T125809Z/manifest.tsv
pass=0; fail=0
ck() { # <name> <expected> <actual>
  if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "  ok   $1 ($3)";
  else fail=$((fail+1)); echo "  FAIL $1: expected $2, got $3"; fi
}
tmp=$(mktemp -d); trap 'rm -rf "$tmp"; rm -f evidence/b10/.verify-*.sh' EXIT

# Each case runs a MUTATED COPY of the driver from the real evidence/b10/ directory, because the
# driver cd's to its own ../.. and a copy in $tmp would resolve the repo root somewhere else.
run_mutant() { # <sed-expr> -> echoes the exit code
  sed "$1" "$DRIVER" > "evidence/b10/.verify-m.sh"; chmod +x evidence/b10/.verify-m.sh
  ./evidence/b10/.verify-m.sh >/dev/null 2>&1; echo $?
}

echo "A  a rubric sha that moved -> exit 2, on EITHER rubric"
ck "BE-003 sha guard" 2 "$(run_mutant 's/396e1799eb2b/deadbeefdead/')"
ck "BE-004 sha guard" 2 "$(run_mutant 's/6252778b8472/deadbeefdead/')"

echo "B  an unreadable manifest -> exit 3"
ck "missing manifest" 3 "$(run_mutant 's|manifest.tsv|manifest-does-not-exist.tsv|')"

echo "C  a manifest that is not the registered 20 data rows -> exit 3"
# The real manifest with one data row removed. Written into the batch dir under a name the
# driver can be pointed at, then removed; the REAL manifest is never touched.
grep -v '4df04e27' "$MANIFEST" > evidence/b10/batch-20260927T125809Z/.verify-19.tsv
ck "19 rows refused" 3 "$(run_mutant 's|/manifest.tsv|/.verify-19.tsv|')"
cat "$MANIFEST" > evidence/b10/batch-20260927T125809Z/.verify-21.tsv
tail -1 "$MANIFEST" >> evidence/b10/batch-20260927T125809Z/.verify-21.tsv
ck "21 rows refused" 3 "$(run_mutant 's|/manifest.tsv|/.verify-21.tsv|')"
rm -f evidence/b10/batch-20260927T125809Z/.verify-19.tsv evidence/b10/batch-20260927T125809Z/.verify-21.tsv

echo "D  the lock refuses a second driver -> exit 8"
# A live pid that is not this shell: a backgrounded sleep. kill -0 on it succeeds, which is
# exactly what the guard tests.
sleep 120 & held=$!
echo "$held" > evidence/b10/.score.lock
ck "second driver refused" 8 "$(run_mutant 's/^BUDGET=/BUDGET=/')"
kill "$held" 2>/dev/null; wait "$held" 2>/dev/null
rm -f evidence/b10/.score.lock
echo "D2 a STALE lock (pid gone) does NOT refuse"
echo 999999 > evidence/b10/.score.lock
rc=$(run_mutant 's|manifest.tsv|manifest-does-not-exist.tsv|')   # fails later, at the manifest
ck "stale lock passed through to the manifest check" 3 "$rc"
rm -f evidence/b10/.score.lock

echo "E  the manifest reader yields exactly the 20 registered runs, no comment and no header"
n=$(awk -F'\t' '!/^#/ && $1 != "task" && NF >= 4 {print $4}' "$MANIFEST" | wc -l | tr -d ' ')
ck "20 run ids parsed" 20 "$n"
u=$(awk -F'\t' '!/^#/ && $1 != "task" && NF >= 4 {print $4}' "$MANIFEST" | sort -u | wc -l | tr -d ' ')
ck "all 20 distinct" 20 "$u"
bad=$(awk -F'\t' '!/^#/ && $1 != "task" && NF >= 4 {print $4}' "$MANIFEST" \
  | grep -cv '^[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}$')
ck "every parsed field is a uuid (no header, no comment)" 0 "$bad"
t=$(awk -F'\t' '!/^#/ && $1 != "task" && NF >= 4 {print $1}' "$MANIFEST" | sort -u | tr '\n' ',')
ck "only the two registered tasks" "BE-003,BE-004," "$t"

echo "F  sheet_complete separates a stall artefact from a real sheet"
# The function under test, copied verbatim from the driver.
sheet_complete() {
  [ -n "${1:-}" ] || return 1
  local n; n=$(grep -c '^ *score:' "$1" 2>/dev/null)
  [ "${n:-0}" -eq 4 ]
}
real=findings/codex/score-good-inline-envelope-20260830T174314Z.yaml
stalled=findings/codex/score-good-nested-ifs-20260927T060410Z.yaml
sheet_complete "$real";    ck "real 4-category sheet accepted" 0 $?
sheet_complete "$stalled"; ck "0-score stall artefact refused" 1 $?
printf 'score: 1\nscore: 1\nscore: 1\n' > "$tmp/three.yaml"
sheet_complete "$tmp/three.yaml"; ck "three categories refused" 1 $?
printf 'score: 1\nscore: 1\nscore: 1\nscore: 1\nscore: 1\n' > "$tmp/five.yaml"
sheet_complete "$tmp/five.yaml"; ck "five categories refused" 1 $?
sheet_complete "$tmp/does-not-exist.yaml"; ck "a missing sheet refused with a DEFINED 1" 1 $?
sheet_complete ""; ck "an empty path refused with a DEFINED 1" 1 $?

echo "G  the wall-clock budget fires on the process GROUP and leaves nothing running"
run_limited() { local secs="$1" rcfile="$2"; shift 3; set -m; ( "$@" ) & local pid=$!;
  ( sleep "$secs"; kill -TERM -"$pid" 2>/dev/null; sleep 5; kill -KILL -"$pid" 2>/dev/null ) & local dog=$!
  wait "$pid"; local rc=$?; kill "$dog" 2>/dev/null; wait "$dog" 2>/dev/null; set +m
  [ "$rc" -ge 128 ] && rc=124; echo "$rc" > "$rcfile"; }
start=$(date +%s)
run_limited 3 "$tmp/rc" -- bash -c 'sleep 411 & wait'
elapsed=$(( $(date +%s) - start ))
ck "expired call reports 124" 124 "$(cat "$tmp/rc")"
if [ "$elapsed" -lt 20 ]; then ck "killed within budget" under20 under20; else ck "killed within budget" under20 "${elapsed}s"; fi
sleep 1
left=$(pgrep -f 'sleep 411' | wc -l | tr -d ' ')
ck "no orphan grandchild left" 0 "$left"
run_limited 20 "$tmp/rc2" -- bash -c 'exit 7'
ck "a call inside the budget keeps its real exit code" 7 "$(cat "$tmp/rc2")"

echo "H  the skip test finds a recorded id and not an unrecorded one"
# Tested against a SYNTHETIC progress file rather than the live one, so the case is decidable
# before the first sheet exists and stays decidable after. Testing it against the live file made
# the recorded half vacuous and made the unrecorded half exit 2 (grep on a file that does not
# exist yet) — which is the fixture reporting over a smaller scope than it claimed.
SYN="$tmp/progress.tsv"
printf 'task\tseq\tarm\trun_id\tscore_exit\tsheet\n' > "$SYN"
printf 'BE-003\t01\tcontrol\ta06c2daf-36ce-4a17-a6a7-2cd8e0c18775\t0\tfindings/codex/x.yaml\n' >> "$SYN"
grep -q "	a06c2daf-36ce-4a17-a6a7-2cd8e0c18775	" "$SYN"
ck "a recorded id IS found, so it is skipped" 0 $?
grep -q "	4df04e27-bd37-422e-bdd3-6d759558b22a	" "$SYN"
ck "an unrecorded id is NOT found, so it is scored" 1 $?
# A run id appearing in the `sheet` column must NOT count as recorded: the skip test is
# tab-delimited on both sides for exactly this reason.
printf 'BE-003\t02\tcontrol\td277c1fc-8cba-4603-a5c0-3a96c702a969\t0\tfindings/codex/score-observatory-run-deadbeef-0000-0000-0000-000000000000-x.yaml\n' >> "$SYN"
grep -q "	deadbeef-0000-0000-0000-000000000000	" "$SYN"
ck "an id only inside a sheet PATH is not read as recorded" 1 $?

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
