#!/usr/bin/env bash
# Fixture set for evidence/b10/run-b10-df.sh — every registered exit code, proved.
#
# §4 step 4: "a control that has never been shown to reject anything is indistinguishable from
# one that rejects nothing." This is that proof for the DF driver.
#
# THE ONE RULE THIS FIXTURE SET EXISTS TO OBEY: no case may reach the real run-agent.sh.
# verify-b9-df-guards.sh case O did, and started a PAID run that had to be killed after 110 s.
# Every case here either exits BEFORE the run (codes 2, 3, 5, 8) or stubs the runner through
# B10_RUNNER (codes 0 and 9). The happy path IS covered — a fixture set that only proves
# refusals is a fixture set that has never seen the driver work.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DF="$LAB/evidence/b10/run-b10-df.sh"
PASS=0; FAIL=0
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"; rm -f "$LAB/evidence/b10/.df.lock"' EXIT

# A stub runner. It prints the two things the driver greps for and nothing else, so the driver's
# parsing is exercised without a model call. STUB_RID controls whether a run id appears at all.
mk_stub() {  # mk_stub <dir> <emit_rid:yes|no>
  mkdir -p "$1/runner"
  { echo '#!/usr/bin/env bash'
    echo 'echo "tracked overlay files in the setup commit: 10 of 10"'
    if [[ "$2" == yes ]]; then
      echo 'echo "started run 11111111-2222-3333-4444-555555555555"'
      echo 'echo "worktree /tmp/observatory-run-11111111-2222-3333-4444-555555555555"'
    fi
    echo 'exit 0'
  } > "$1/runner/run-agent.sh"
  chmod +x "$1/runner/run-agent.sh"
}

# A copy of the real DF overlay we can damage without touching the tracked fixture.
mk_overlay() {  # mk_overlay <dest>
  cp -R "$LAB/evidence/b10/census-fixtures/port-plus-claude-settings" "$1"
}

newest_df() {  # newest_df <evid_root> -> the single df-* directory under it
  find "$1" -maxdepth 1 -type d -name 'df-*' 2>/dev/null | LC_ALL=C sort | tail -1
}

run_case() {  # run_case <label> <expected_rc> <env assignments...> ; reads no stdin
  local label="$1" want="$2"; shift 2
  local out rc
  out="$(env "$@" "$DF" 2>&1)"; rc=$?
  if [[ "$rc" == "$want" ]]; then
    printf 'PASS  %-58s rc=%s\n' "$label" "$rc"; PASS=$((PASS+1))
  else
    printf 'FAIL  %-58s rc=%s want=%s\n' "$label" "$rc" "$want"; FAIL=$((FAIL+1))
    printf '      %s\n' "$(printf '%s' "$out" | tail -3 | tr '\n' '|')"
  fi
}

OBS_OK="$TMP/obs-ok"; mk_stub "$OBS_OK" yes
OBS_NORID="$TMP/obs-norid"; mk_stub "$OBS_NORID" no

# --- case A: exit 2, an unknown flag ---------------------------------------------------------
out="$("$DF" --nope 2>&1)"; rc=$?
if [[ "$rc" == 2 ]]; then printf 'PASS  %-58s rc=2\n' "A unknown flag -> 2"; PASS=$((PASS+1))
else printf 'FAIL  %-58s rc=%s want=2\n' "A unknown flag -> 2" "$rc"; FAIL=$((FAIL+1)); fi

# --- case B: exit 5, the instructionsHash is not the registered one ---------------------------
O="$TMP/ov-badinstr"; mk_overlay "$O"; echo "drift" >> "$O/AGENTS.md"
run_case "B AGENTS.md drifted -> 5" 5 \
  "B10_DF_OVERLAY=$O" "B10_OBS=$OBS_OK" "B10_RUNNER=runner/run-agent.sh" \
  "B10_EVID_ROOT=$TMP/e-b" "TMPDIR=$TMP/t-b"

# --- case C: exit 5, the knowledgeHash is not the registered one ------------------------------
O="$TMP/ov-badknow"; mk_overlay "$O"; echo "drift" >> "$O/.ai/knowledge/index.yaml"
run_case "C .ai/knowledge drifted -> 5" 5 \
  "B10_DF_OVERLAY=$O" "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-c" "TMPDIR=$TMP/t-c"

# --- case D: exit 5, policy-gate.sh is not the sha B7 measured --------------------------------
# THE CASE THIS DRIVER MOST NEEDS. The whole DF rests on the gate being the same script B7 ran,
# and a gate whose body drifted would produce a perfectly clean-looking empty log.
O="$TMP/ov-badgate"; mk_overlay "$O"
printf '\n# drift that no other hash sees\n' >> "$O/.ai/hooks/policy-gate.sh"
run_case "D policy-gate.sh not B7's sha -> 5" 5 \
  "B10_DF_OVERLAY=$O" "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-d" "TMPDIR=$TMP/t-d"

# --- case E: exit 5, the overlay has no .claude/settings.json ---------------------------------
# A DF that does not contain its own treatment is the deliberate failure of the deliberate
# failure. The nine-file port is a legitimate overlay and an illegitimate DF subject.
run_case "E no .claude/settings.json (the plain port) -> 5" 5 \
  "B10_DF_OVERLAY=$LAB/build/customizations/agent-v1.2-knowledge-codex" \
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-e" "TMPDIR=$TMP/t-e"

# --- case F: exit 5, a shell file lost its exec bit, which NO HASH SEES ------------------------
O="$TMP/ov-noexec"; mk_overlay "$O"; chmod -x "$O/.ai/knowledge/router.sh"
run_case "F router.sh not executable -> 5" 5 \
  "B10_DF_OVERLAY=$O" "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-f" "TMPDIR=$TMP/t-f"

# --- case G: exit 3, the positive control does not fire ----------------------------------------
# Built by removing the POLICY FILE, not the gate: the gate's sha must stay B7's so the driver
# reaches DF-P3 (case D already covers a drifted gate). policy-gate.sh fails OPEN on an
# unreadable policy — exit 0 where the deny case wants 2 — which is precisely the "hook installed
# but broken" horn DF-P3 exists to close.
O="$TMP/ov-nopolicy"; mk_overlay "$O"; rm -f "$O/.ai/policies/protected-paths.yaml"
run_case "G gate cannot deny (policy gone) -> 3" 3 \
  "B10_DF_OVERLAY=$O" "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-g" "TMPDIR=$TMP/t-g"

# --- case H: exit 8, a second DF is already running -------------------------------------------
# A live pid that is not this driver: `sleep` is enough, because the lock only asks kill -0.
sleep 300 & SLEEPER=$!
echo "$SLEEPER" > "$LAB/evidence/b10/.df.lock"
run_case "H a live pid holds the lock -> 8" 8 \
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-h" "TMPDIR=$TMP/t-h"
kill "$SLEEPER" 2>/dev/null; wait "$SLEEPER" 2>/dev/null
rm -f "$LAB/evidence/b10/.df.lock"

# --- case I: a STALE lock is taken over, not obeyed -------------------------------------------
# 99999 is not a live pid. The driver must proceed to the stubbed happy path, exit 0.
echo 99999 > "$LAB/evidence/b10/.df.lock"
run_case "I a stale lock is taken over -> 0" 0 \
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-i" "TMPDIR=$TMP/t-i" "API=http://127.0.0.1:1"
rm -f "$LAB/evidence/b10/.df.lock"

# --- case J: exit 9, the run produced no run id ------------------------------------------------
run_case "J stub runner emits no run id -> 9" 9 \
  "B10_OBS=$OBS_NORID" "B10_EVID_ROOT=$TMP/e-j" "TMPDIR=$TMP/t-j"
if [[ -n "$(find "$TMP/e-j" -name RESULT.md -size +0 2>/dev/null)" ]]; then
  printf 'PASS  %-58s\n' "J' exit 9 still writes RESULT.md"; PASS=$((PASS+1))
else
  printf 'FAIL  %-58s\n' "J' exit 9 still writes RESULT.md"; FAIL=$((FAIL+1))
fi

# --- case K: exit 0, THE HAPPY PATH, and its artefacts are the ones the DF cites ---------------
# API is pointed at a closed port so curl returns empty and every jq read becomes "null". That is
# deliberate: it proves the driver writes a complete RESULT.md even when the record is unreadable,
# which is the shape a validator will meet if the stack is down when they re-derive it.
E="$TMP/e-k"; T="$TMP/t-k"; mkdir -p "$T"
run_case "K happy path, unreachable API -> 0" 0 \
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$E" "TMPDIR=$T" "API=http://127.0.0.1:1"
D="$(newest_df "$E")"
for f in RESULT.md sweep-before.tsv sweep-after.tsv positive-control-policy-events.jsonl run.log; do
  if [[ -f "$D/$f" ]]; then printf 'PASS  %-58s\n' "K' artefact $f exists"; PASS=$((PASS+1))
  else printf 'FAIL  %-58s\n' "K' artefact $f exists"; FAIL=$((FAIL+1)); fi
done
if [[ "$(wc -l < "$D/positive-control-policy-events.jsonl" | tr -d ' ')" == 2 ]]; then
  printf 'PASS  %-58s\n' "K'' the positive control wrote exactly 2 lines"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "K'' the positive control wrote exactly 2 lines"; FAIL=$((FAIL+1)); fi
if /usr/bin/grep -q 'DF-P3 — the positive control' "$D/RESULT.md"; then
  printf 'PASS  %-58s\n' "K''' RESULT.md carries all four DF sections"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "K''' RESULT.md carries all four DF sections"; FAIL=$((FAIL+1)); fi

# --- case L: THE SWEEP ACTUALLY DETECTS A LOG, which is the one thing DF-P2 depends on ---------
# If the sweep cannot see a log that IS there, then "0 new or grown" is not a measurement and the
# whole DF is worthless. So: plant a policy-events log in TMPDIR that the stub runner GROWS, and
# require new_or_grown >= 1. A negative observation whose detector was never shown to fire is the
# house failure mode, and this is the case that closes it.
E="$TMP/e-l"; T="$TMP/t-l"; mkdir -p "$T"
echo '{"pre":"existing line"}' > "$T/policy-events-observatory-run-plantedaaa.jsonl"
OBS_GROW="$TMP/obs-grow"; mk_stub "$OBS_GROW" yes
{ echo '#!/usr/bin/env bash'
  echo 'echo "tracked overlay files in the setup commit: 10 of 10"'
  echo 'echo "started run 11111111-2222-3333-4444-555555555555"'
  echo "echo '{\"grown\":\"line\"}' >> \"\$TMPDIR/policy-events-observatory-run-plantedaaa.jsonl\""
  echo "echo '{\"brandnew\":1}' > \"\$TMPDIR/policy-events-observatory-run-newbbb.jsonl\""
  echo 'exit 0'
} > "$OBS_GROW/runner/run-agent.sh"
chmod +x "$OBS_GROW/runner/run-agent.sh"
run_case "L sweep sees a grown AND a new log -> 0" 0 \
  "B10_OBS=$OBS_GROW" "B10_EVID_ROOT=$E" "TMPDIR=$T" "API=http://127.0.0.1:1"
D="$(newest_df "$E")"
N="$(LC_ALL=C comm -13 "$D/sweep-before.tsv" "$D/sweep-after.tsv" | wc -l | tr -d ' ')"
if [[ "$N" == 2 ]]; then
  printf 'PASS  %-58s (2 detected)\n' "L' the detector FIRES: new_or_grown == 2"; PASS=$((PASS+1))
else
  printf 'FAIL  %-58s (got %s, want 2)\n' "L' the detector FIRES: new_or_grown == 2" "$N"; FAIL=$((FAIL+1))
fi
if /usr/bin/grep -q 'new or grown' "$D/RESULT.md"; then
  printf 'PASS  %-58s\n' "L'' RESULT.md reports the non-zero sweep"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "L'' RESULT.md reports the non-zero sweep"; FAIL=$((FAIL+1)); fi

echo ""
echo "verify-b10-df-guards: $PASS passed, $FAIL failed"
[[ "$FAIL" == 0 ]] || exit 1
echo "all cases behaved as specified"
