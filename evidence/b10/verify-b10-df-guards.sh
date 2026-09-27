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
trap 'kill "${STUB_PID:-}" 2>/dev/null; rm -rf "$TMP"; rm -f "$LAB/evidence/b10/.df.lock"' EXIT

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
  # B10_DF_SETTLE=0 in every case: the settling sweep is a REAL delay in the real driver and
  # 20 s per case would make this fixture set take minutes. Case R below sets it non-zero once,
  # so the delay itself is still exercised.
  out="$(env B10_DF_SETTLE=0 "$@" "$DF" 2>&1)"; rc=$?
  if [[ "$rc" == "$want" ]]; then
    printf 'PASS  %-58s rc=%s\n' "$label" "$rc"; PASS=$((PASS+1))
  else
    printf 'FAIL  %-58s rc=%s want=%s\n' "$label" "$rc" "$want"; FAIL=$((FAIL+1))
    printf '      %s\n' "$(printf '%s' "$out" | tail -3 | tr '\n' '|')"
  fi
}

OBS_OK="$TMP/obs-ok"; mk_stub "$OBS_OK" yes
OBS_NORID="$TMP/obs-norid"; mk_stub "$OBS_NORID" no

# *** THE ENV VAR IS B10_API, NOT API, AND THAT MATTERED. ***
# run-b10-df.sh does `export API="${B10_API:-http://127.0.0.1:8081}"`, so an incoming `API=` is
# OVERWRITTEN and every case that thought it was pointing at a closed port was in fact hitting the
# real stack at 8081 and looking up a stub uuid that does not exist there. The cases passed, for the
# wrong reason, and the comment above case K claimed a closed port it never used. Found while fixing
# §4a round 1's findings, and it is the same shape as every other defect this project has paid for:
# A CONTROL REPORTING SUCCESS OVER A SCOPE SMALLER THAN IT CLAIMS.

# --- a stub API, so the happy path has a record the driver can actually READ ------------------
# Cases I, K and L used to point API at a closed port and expect exit 0. §4a round 1 was right
# that "an unreadable record still writes RESULT.md and exits 0" is a defect, so that is now
# exit 11 -- which means the happy path needs a REAL readable record. This serves one canned run
# record for any path, on a port the OS picks, and is torn down by the EXIT trap.
STUB_REC="$TMP/stub-record.json"
cat > "$STUB_REC" <<'JSON'
{"runId":"11111111-2222-3333-4444-555555555555",
 "evaluation":{"exitCode":0},
 "customization":{"instructionsHash":"sha256:ebf489800a60a156986f98ea4f127848",
                  "knowledgeHash":"sha256:0770219ae7f4281a80071d78dadea285",
                  "skillsHash":null,"agentHash":null,"agentsHash":null,
                  "hooksHash":null,"mcpHash":null},
 "runtime":{"model":"gpt-5.6-sol","version":"codex-cli 0.154.0","userSettingsIsolated":true},
 "efficiency":{"reportedTotalTokens":25551,"durationMs":135000,"estimatedCost":null,
               "inputTokens":null,"outputTokens":null},
 "behavior":{"modelCalls":null,"toolCalls":null},
 "result":{"changedFiles":["a.kt","b.kt","c.kt"]}}
JSON
STUB_PORT="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')"
python3 - "$STUB_REC" "$STUB_PORT" >/dev/null 2>&1 <<'PY' &
import sys, json, http.server
body = open(sys.argv[1], 'rb').read()
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.send_header('Content-Type','application/json')
        self.send_header('Content-Length', str(len(body))); self.end_headers(); self.wfile.write(body)
    def log_message(self, *a): pass
http.server.HTTPServer(('127.0.0.1', int(sys.argv[2])), H).serve_forever()
PY
STUB_PID=$!
STUB_API="http://127.0.0.1:$STUB_PORT"
# Wait for it, bounded: a fixture that races its own stub is a flaky fixture.
for _ in $(seq 1 40); do
  if curl -s -m 1 "$STUB_API/api/runs/x" >/dev/null 2>&1; then break; fi
  sleep 0.25
done
if curl -s -m 2 "$STUB_API/api/runs/x" | grep -q '"runId"'; then
  printf 'PASS  %-58s (port %s)\n' "S the stub API serves a readable record" "$STUB_PORT"; PASS=$((PASS+1))
else
  printf 'FAIL  %-58s\n' "S the stub API serves a readable record"; FAIL=$((FAIL+1))
fi



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
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-i" "TMPDIR=$TMP/t-i" "B10_API=$STUB_API"
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
# API points at the STUB, so the record is readable and RESULT.md is complete with every DF-P4
# field populated. This case USED to point at a closed port and expect exit 0 -- §4a round 1 found
# that "an unreadable record still exits 0" is a defect, not a feature, so the unreadable shape is
# now case O at exit 11 and this is the genuine happy path.
E="$TMP/e-k"; T="$TMP/t-k"; mkdir -p "$T"
run_case "K happy path, READABLE record -> 0" 0 \
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$E" "TMPDIR=$T" "B10_API=$STUB_API"
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
  "B10_OBS=$OBS_GROW" "B10_EVID_ROOT=$E" "TMPDIR=$T" "B10_API=$STUB_API"
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

# ============================================================================================
# CASES M-R: added 2026-09-27 after §4a round 1, one per finding the review returned. Every one
# of them FAILED against the version that produced DF1 (sha 02a2147479fcbe06) and passes now.
# ============================================================================================

# --- case M: exit 5, .claude/settings.json is present but is NOT the registered file ----------
# THE REVIEW'S STRONGEST FINDING. The old driver hashed the two portable files and merely stat-ed
# the one file the DF is actually about, so swapping it left every digest unchanged and let the run
# test a different treatment while RESULT.md still called the overlay registered.
O="$TMP/ov-badsettings"; mk_overlay "$O"
printf '{"hooks":{"PreToolUse":[]}}\n' > "$O/.claude/settings.json"
run_case "M settings.json present but wrong sha -> 5" 5 \
  "B10_DF_OVERLAY=$O" "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$TMP/e-m" "TMPDIR=$TMP/t-m"

# --- case N: exit 10, the runner returns non-zero AFTER printing a run id ---------------------
# DF-P1 *is* "the runner did not refuse", so exiting 0 here let one reader see a completed DF
# where another saw a failed run.
OBS_RCFAIL="$TMP/obs-rcfail"; mk_stub "$OBS_RCFAIL" yes
perl -i -pe 's/^exit 0$/exit 1/' "$OBS_RCFAIL/runner/run-agent.sh"
E="$TMP/e-n"
run_case "N runner rc non-zero -> 10" 10 \
  "B10_OBS=$OBS_RCFAIL" "B10_EVID_ROOT=$E" "TMPDIR=$TMP/t-n" "B10_API=http://127.0.0.1:1"
D="$(newest_df "$E")"
if [[ -f "$D/RESULT.md" ]] && /usr/bin/grep -q 'DF-P1 CANNOT BE CLAIMED' "$D/RESULT.md" \
   && /usr/bin/grep -q 'DF-P2 is NOT claimed either' "$D/RESULT.md"; then
  printf 'PASS  %-58s\n' "N' exit 10 writes RESULT.md withholding BOTH claims"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "N' exit 10 writes RESULT.md withholding BOTH claims"; FAIL=$((FAIL+1)); fi

# --- case O: exit 11, the run record is unreadable -------------------------------------------
# EMPTY IS NOT NULL (§6: "a missing cell is not a null cell"). The old driver wrote a DF-P4 table
# of blanks that read exactly like a run whose fields were genuinely null.
E="$TMP/e-o"
run_case "O record unreadable (API closed) -> 11" 11 \
  "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$E" "TMPDIR=$TMP/t-o" "B10_API=http://127.0.0.1:1"
D="$(newest_df "$E")"
if [[ -f "$D/RESULT.md" ]] && /usr/bin/grep -q 'RECORD UNREADABLE' "$D/RESULT.md" \
   && ! /usr/bin/grep -q 'instructionsHash' "$D/RESULT.md"; then
  printf 'PASS  %-58s\n' "O' exit 11 marks it AND reports no DF-P4 field"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "O' exit 11 marks it AND reports no DF-P4 field"; FAIL=$((FAIL+1)); fi
if [[ -s "$D/sweep-late.tsv" || -f "$D/sweep-late.tsv" ]]; then
  printf 'PASS  %-58s\n' "O'' exit 11 still ran the settling sweep"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "O'' exit 11 still ran the settling sweep"; FAIL=$((FAIL+1)); fi

# --- case P: the sweep survives a filename containing a NEWLINE -------------------------------
# DF-P2 is a DIFF of two inventories; `ls -1` emitted such a name as TWO records and broke the
# path-to-line-count mapping the whole negative observation rests on.
E="$TMP/e-p"; T="$TMP/t-p"; mkdir -p "$T"
NL_NAME="$T/policy-events-$(printf 'a\nb').jsonl"
: > "$NL_NAME" 2>/dev/null && HAVE_NL=1 || HAVE_NL=0
if [[ "$HAVE_NL" == 1 ]]; then
  echo '{"x":1}' > "$NL_NAME"
  run_case "P a newline in a log filename -> 11 (API closed)" 11 \
    "B10_OBS=$OBS_OK" "B10_EVID_ROOT=$E" "TMPDIR=$T" "B10_API=http://127.0.0.1:1"
  D="$(newest_df "$E")"
  # ONE record for the pathological file, not two, and it is flagged rather than silently mangled.
  if [[ "$(wc -l < "$D/sweep-before.tsv" | tr -d ' ')" == 1 ]] \
     && /usr/bin/grep -q 'UNREPRESENTABLE-PATH' "$D/sweep-before.tsv"; then
    printf 'PASS  %-58s\n' "P' one flagged record, not two split ones"; PASS=$((PASS+1))
  else
    printf 'FAIL  %-58s (%s rows)\n' "P' one flagged record, not two split ones" \
      "$(wc -l < "$D/sweep-before.tsv" | tr -d ' ')"; FAIL=$((FAIL+1))
  fi
else
  printf 'SKIP  %-58s (filesystem refused the name)\n' "P a newline in a log filename"
fi

# --- case Q: the lock is ATOMIC, not checked-then-written -------------------------------------
# Two copies started together could both pass `[[ -e "$LOCK" ]]` before either wrote. This case
# proves the create-or-fail form by holding the lock with a LIVE pid and then, separately, by
# showing that a second create against an existing lock fails rather than overwriting it.
rm -f "$LAB/evidence/b10/.df.lock"
( set -o noclobber; echo 4242 > "$LAB/evidence/b10/.df.lock" ) 2>/dev/null
if ! ( set -o noclobber; echo 9999 > "$LAB/evidence/b10/.df.lock" ) 2>/dev/null; then
  printf 'PASS  %-58s\n' "Q noclobber refuses a second create (atomicity)"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "Q noclobber refuses a second create (atomicity)"; FAIL=$((FAIL+1)); fi
if [[ "$(cat "$LAB/evidence/b10/.df.lock")" == 4242 ]]; then
  printf 'PASS  %-58s\n' "Q' the first writer's pid SURVIVED the second attempt"; PASS=$((PASS+1))
else printf 'FAIL  %-58s\n' "Q' the first writer's pid SURVIVED the second attempt"; FAIL=$((FAIL+1)); fi
rm -f "$LAB/evidence/b10/.df.lock"

# --- case R: the settling sweep actually delays and actually re-reads -------------------------
# The ONE case that does not set B10_DF_SETTLE=0. A settling sweep that never sleeps cannot rule
# out a hook child appending just after the runner exits, so the delay is part of the control.
E="$TMP/e-r"; T="$TMP/t-r"; mkdir -p "$T"
OBS_LATE="$TMP/obs-late"; mk_stub "$OBS_LATE" yes
{ echo '#!/usr/bin/env bash'
  echo 'echo "started run 11111111-2222-3333-4444-555555555555"'
  # A CHILD that appends AFTER the runner returns - exactly the false-negative the finding named.
  echo "( sleep 2; echo '{\"late\":1}' > \"\$TMPDIR/policy-events-observatory-run-lateccc.jsonl\" ) &"
  echo 'exit 0'
} > "$OBS_LATE/runner/run-agent.sh"
chmod +x "$OBS_LATE/runner/run-agent.sh"
START=$(date +%s)
out="$(env B10_DF_SETTLE=6 "B10_OBS=$OBS_LATE" "B10_EVID_ROOT=$E" "TMPDIR=$T" \
       "B10_API=http://127.0.0.1:1" "$DF" 2>&1)"; rc=$?
ELAPSED=$(( $(date +%s) - START ))
if [[ "$rc" == 11 ]]; then printf 'PASS  %-58s rc=11\n' "R late-append case runs to the record check"; PASS=$((PASS+1))
else printf 'FAIL  %-58s rc=%s want=11\n' "R late-append case runs to the record check" "$rc"; FAIL=$((FAIL+1)); fi
if (( ELAPSED >= 6 )); then
  printf 'PASS  %-58s (%ss)\n' "R' the settling delay actually elapsed" "$ELAPSED"; PASS=$((PASS+1))
else printf 'FAIL  %-58s (%ss)\n' "R' the settling delay actually elapsed" "$ELAPSED"; FAIL=$((FAIL+1)); fi
D="$(newest_df "$E")"
IMMEDIATE="$(LC_ALL=C comm -13 "$D/sweep-before.tsv" "$D/sweep-after.tsv" | wc -l | tr -d ' ')"
LATE="$(LC_ALL=C comm -13 "$D/sweep-before.tsv" "$D/sweep-late.tsv" | wc -l | tr -d ' ')"
# THE POINT OF THE WHOLE CASE: the immediate sweep misses it and the settling sweep catches it.
if [[ "$IMMEDIATE" == 0 && "$LATE" == 1 ]]; then
  printf 'PASS  %-58s\n' "R'' immediate sweep MISSES it, settling sweep CATCHES it"; PASS=$((PASS+1))
else
  printf 'FAIL  %-58s (imm=%s late=%s, want 0 and 1)\n' \
    "R'' immediate sweep MISSES it, settling sweep CATCHES it" "$IMMEDIATE" "$LATE"; FAIL=$((FAIL+1))
fi


echo ""
echo "verify-b10-df-guards: $PASS passed, $FAIL failed"
[[ "$FAIL" == 0 ]] || exit 1
echo "all cases behaved as specified"
