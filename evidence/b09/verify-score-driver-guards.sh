#!/usr/bin/env bash
# Prove every guard in evidence/b09/score-b9-batch.sh REFUSES, rather than asserting it does.
# A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing (§6), and the guard that matters most here — the stall budget — was added
# only because the thing it guards against had already happened once, undetected, for an hour.
#
#   ./evidence/b09/verify-score-driver-guards.sh     from agent-learning-lab/
#
# Exit 0 all cases pass · 1 a case failed.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
DRIVER=evidence/b09/score-b9-batch.sh
pass=0; fail=0
ck() { # <name> <expected> <actual>
  if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "  ok   $1 ($3)";
  else fail=$((fail+1)); echo "  FAIL $1: expected $2, got $3"; fi
}
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

echo "A  rubric sha moved -> exit 2"
sed 's/396e1799eb2b/deadbeefdead/' "$DRIVER" > "$tmp/a.sh"; chmod +x "$tmp/a.sh"
cp "$tmp/a.sh" evidence/b09/.verify-a.sh; ./evidence/b09/.verify-a.sh >/dev/null 2>&1
ck "BE-003 sha guard" 2 $?; rm -f evidence/b09/.verify-a.sh
sed 's/6252778b8472/deadbeefdead/' "$DRIVER" > "$tmp/a2.sh"; chmod +x "$tmp/a2.sh"
cp "$tmp/a2.sh" evidence/b09/.verify-a2.sh; ./evidence/b09/.verify-a2.sh >/dev/null 2>&1
ck "BE-004 sha guard" 2 $?; rm -f evidence/b09/.verify-a2.sh

echo "B  manifest unreadable -> exit 3"
sed 's|run-ids.tsv|run-ids-does-not-exist.tsv|' "$DRIVER" > "$tmp/b.sh"; chmod +x "$tmp/b.sh"
cp "$tmp/b.sh" evidence/b09/.verify-b.sh; ./evidence/b09/.verify-b.sh >/dev/null 2>&1
ck "missing manifest" 3 $?; rm -f evidence/b09/.verify-b.sh

echo "C  the stall budget fires, and leaves nothing running"
# shellcheck disable=SC1090
run_limited() { local secs="$1" rcfile="$2"; shift 3; set -m; ( "$@" ) & local pid=$!;
  ( sleep "$secs"; kill -TERM -"$pid" 2>/dev/null; sleep 5; kill -KILL -"$pid" 2>/dev/null ) & local dog=$!
  wait "$pid"; local rc=$?; kill "$dog" 2>/dev/null; wait "$dog" 2>/dev/null; set +m
  [ "$rc" -ge 128 ] && rc=124; echo "$rc" > "$rcfile"; }
start=$(date +%s)
run_limited 3 "$tmp/rc" -- bash -c 'sleep 600 & wait'
elapsed=$(( $(date +%s) - start ))
ck "expired call reports 124" 124 "$(cat "$tmp/rc")"
if [ "$elapsed" -lt 20 ]; then ck "killed within budget" under20 under20; else ck "killed within budget" under20 "${elapsed}s"; fi
sleep 1
left=$(pgrep -f 'sleep 600' | wc -l | tr -d ' ')
ck "no orphan child left" 0 "$left"
echo "C2 a call that finishes inside the budget is NOT killed"
run_limited 20 "$tmp/rc2" -- bash -c 'exit 7'
ck "real exit code preserved" 7 "$(cat "$tmp/rc2")"

echo "D  sheet_complete separates a stall artefact from a real sheet"
sheet_complete() { [ "$(grep -c '^ *score:' "$1" 2>/dev/null)" -eq 4 ]; }
real=$(find findings/codex -name 'score-observatory-run-1108e1e5*' | head -1)
stalled=$(find findings/codex -name 'score-observatory-run-4bf8abf5*' | head -1)
sheet_complete "$real"; ck "real 4-category sheet accepted" 0 $?
sheet_complete "$stalled"; ck "header-only stall artefact refused" 1 $?
printf 'score: 1\nscore: 1\nscore: 1\n' > "$tmp/three.yaml"
sheet_complete "$tmp/three.yaml"; ck "three categories refused" 1 $?
printf 'score: 1\nscore: 1\nscore: 1\nscore: 1\nscore: 1\n' > "$tmp/five.yaml"
sheet_complete "$tmp/five.yaml"; ck "five categories refused" 1 $?

echo "E  an id already in the output file is skipped, not re-scored"
grep -q '4bf8abf5' evidence/b09/batch-20260926T151319Z/codex-sheets.tsv
ck "the stalled id is NOT recorded, so it will be retried" 1 $?
grep -q '	c49eec44-10fe-4996-ba2b-edd31e3a79e8	' evidence/b09/batch-20260926T151319Z/codex-sheets.tsv
ck "a scored id IS recorded, so it will be skipped" 0 $?

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
