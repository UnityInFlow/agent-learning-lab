#!/usr/bin/env bash
# DOES run-b10-batch.sh ACTUALLY REFUSE WHAT IT SAYS IT REFUSES?
#
#   ./evidence/b10/verify-b10-batch-guards.sh
#
# A control that has never been shown to reject anything is indistinguishable from one that
# rejects nothing (§4 step 4). Each case below drives the real driver to a real exit code.
#
# *** NO CASE INVOKES THE REAL RUNNER OR SPENDS A CENT. *** B10_RUNNER is stubbed with a script
# that prints a plausible `run <uuid>` line and a worktree path and exits. Case O of
# verify-b9-df-guards.sh once stubbed the API instead and thereby started run-agent.sh for real;
# it was killed after 110 s and nothing was spent, but a fixture that CAN start a paid run is a
# defect in the fixture, not a close call.
#
# Case A is the HAPPY PATH and it is first on purpose: a fixture set of nine refusals proves
# nothing about a driver that refuses everything.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
DRIVER="$LAB/evidence/b10/run-b10-batch.sh"
PASS=0; FAIL=0
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- the stub runner ------------------------------------------------------------------------
# Prints what the driver greps for and nothing else. STUB_RC lets a case make the run "fail".
mkdir -p "$TMP/bin"
cat > "$TMP/bin/stub-runner" <<'STUB'
#!/usr/bin/env bash
uuid="$(uuidgen | tr 'A-Z' 'a-z')"
echo " run        $uuid"
echo " worktree   ${TMPDIR:-/tmp}/observatory-run-$uuid"
exit "${STUB_RC:-0}"
STUB
chmod +x "$TMP/bin/stub-runner"
# curl must not reach a real API either: an empty body makes every jq field `null`, which is
# exactly the shape a control arm must record, so the happy path stays meaningful.
cat > "$TMP/bin/curl" <<'STUB'
#!/usr/bin/env bash
printf '%s' "${STUB_RECORD:-{\}}"
STUB
chmod +x "$TMP/bin/curl"

# A good overlay copy the cases can corrupt without touching the registered one.
good_overlay() {
  local d="$TMP/overlay-$1"; rm -rf "$d"; mkdir -p "$d"
  cp -R "$LAB/build/customizations/agent-v1.2-knowledge-codex/.ai" "$d/.ai"
  cp "$LAB/build/customizations/agent-v1.2-knowledge-codex/AGENTS.md" "$d/AGENTS.md"
  echo "$d"
}

# run_case <label> <expected_exit> <expected_grep> [KEEP_LOCK] <VAR=val ...> -- [driver args...]
# KEEP_LOCK as the 4th word means the case planted a lock on purpose and run_case must not
# clear it. Case G failed on the first run of this suite for exactly that reason: run_case
# removed the lock the case had just planted, so the case tested nothing and said so.
run_case() {
  local label="$1" want="$2" needle="$3"; shift 3
  local keep=no
  [[ "${1:-}" == KEEP_LOCK ]] && { keep=yes; shift; }
  local -a envs=() dargs=() seen_sep=no
  for a in "$@"; do
    if [[ "$a" == "--" ]]; then seen_sep=yes; continue; fi
    if [[ "$seen_sep" == yes ]]; then dargs+=("$a"); else envs+=("$a"); fi
  done
  local out rc
  out="$TMP/out-$RANDOM.txt"
  [[ "$keep" == yes ]] || rm -f "$LAB/evidence/b10/.batch.lock"
  ( export PATH="$TMP/bin:$PATH"
    export B10_RUNNER="$TMP/bin/stub-runner"
    export B10_OBS="$TMP"
    export B10_EVID_ROOT="$TMP"
    env "${envs[@]}" bash "$DRIVER" "${dargs[@]}" ) > "$out" 2>&1
  rc=$?
  if [[ "$rc" == "$want" ]] && grep -qE "$needle" "$out"; then
    printf '  ok   %-52s exit %s\n' "$label" "$rc"; PASS=$((PASS+1))
  else
    printf '  FAIL %-52s exit %s (wanted %s, needle %s)\n' "$label" "$rc" "$want" "$needle"
    sed 's/^/        /' "$out" | tail -6
    FAIL=$((FAIL+1))
  fi
}

echo "verify-b10-batch-guards:"

# A. HAPPY PATH — one seq, one task, both arms, stubbed runner. Must reach the end and write rows.
OV_A="$(good_overlay a)"
run_case "A happy path, n=1 on one task, 2 rows written" 0 'batch .* finished: 2 runs' \
  B10_N=1 B10_OVERLAY_T="$OV_A" TMPDIR="$TMP" -- BE-003

# B. exit 5 — the instruction file's digest moved.
OV_B="$(good_overlay b)"; printf '\nmutant line\n' >> "$OV_B/AGENTS.md"
run_case "B exit 5, AGENTS.md digest moved" 5 'the treated overlay is not the registered one' \
  B10_N=1 B10_OVERLAY_T="$OV_B" TMPDIR="$TMP"

# C. exit 5 — the corpus moved, with AGENTS.md untouched. Two independent halves, two cases.
OV_C="$(good_overlay c)"; printf '\n# mutant\n' >> "$OV_C/.ai/knowledge/index.yaml"
run_case "C exit 5, knowledge corpus digest moved" 5 'knowledgeHash    want' \
  B10_N=1 B10_OVERLAY_T="$OV_C" TMPDIR="$TMP"

# D. exit 5 — a RENAMED document. The digest is over (path, content), so a rename must be a
#    difference and not a collision. This is the half a content-only digest would miss.
OV_D="$(good_overlay d)"
mv "$OV_D/.ai/knowledge/documents/kotlin-exhaustive-when.md" \
   "$OV_D/.ai/knowledge/documents/kotlin-when.md"
run_case "D exit 5, a corpus document RENAMED, content identical" 5 'knowledgeHash    want' \
  B10_N=1 B10_OVERLAY_T="$OV_D" TMPDIR="$TMP"

# E. exit 5 — the mode bit. THE CASE STOP 20 DID NOT HAVE: both digests are identical and the
#    router is not executable. That shipped, was not refused, and produced a VOID batch.
OV_E="$(good_overlay e)"; chmod -x "$OV_E/.ai/knowledge/router.sh"
run_case "E exit 5, router.sh not executable, digests IDENTICAL" 5 'are not executable' \
  B10_N=1 B10_OVERLAY_T="$OV_E" TMPDIR="$TMP"

# F. exit 8 — a second batch, while a live pid holds the lock.
OV_F="$(good_overlay f)"
sleep 120 & LIVE=$!
echo "$LIVE" > "$LAB/evidence/b10/.batch.lock"
out_f="$TMP/out-f.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_N=1 B10_OVERLAY_T="$OV_F" TMPDIR="$TMP" bash "$DRIVER" ) > "$out_f" 2>&1
rc_f=$?
kill "$LIVE" 2>/dev/null
if [[ "$rc_f" == 8 ]] && grep -q 'already running as pid' "$out_f"; then
  printf '  ok   %-52s exit %s\n' "F exit 8, a second batch is refused" "$rc_f"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted 8)\n' "F exit 8, a second batch is refused" "$rc_f"; FAIL=$((FAIL+1))
fi
rm -f "$LAB/evidence/b10/.batch.lock"

# G. the lock is TAKEN OVER when the pid is dead, rather than refusing forever.
OV_G="$(good_overlay g)"
echo "999999" > "$LAB/evidence/b10/.batch.lock"
run_case "G stale lock is taken over, not refused" 0 'stale lock for pid 999999' \
  KEEP_LOCK B10_N=1 B10_OVERLAY_T="$OV_G" TMPDIR="$TMP" -- BE-003

# H. exit 13 — a --resume tag that is not a tag.
OV_H="$(good_overlay h)"
rm -f "$LAB/evidence/b10/.batch.lock"
out_h="$TMP/out-h.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_OVERLAY_T="$OV_H" TMPDIR="$TMP" bash "$DRIVER" --resume yesterday ) > "$out_h" 2>&1
rc_h=$?
if [[ "$rc_h" == 13 ]] && grep -q 'wants a batch TAG' "$out_h"; then
  printf '  ok   %-52s exit %s\n' "H exit 13, --resume with a non-tag" "$rc_h"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted 13)\n' "H exit 13, --resume with a non-tag" "$rc_h"; FAIL=$((FAIL+1))
fi

# I. exit 6 — the run ceiling, and it must count the rows ALREADY in the manifest. Seeded with a
#    manifest holding 20 data rows, so a fresh invocation must refuse at once rather than add 20.
OV_I="$(good_overlay i)"
TAG_I="20260101T000000Z"; EV_I="$TMP/batch-$TAG_I"
rm -rf "$EV_I"; mkdir -p "$EV_I"
{ printf 'task\tseq\tarm\trun_id\n'
  for i in $(seq 1 20); do printf 'BE-003\t%02d\tcontrol\tx\n' "$i"; done; } > "$EV_I/manifest.tsv"
rm -f "$LAB/evidence/b10/.batch.lock"
out_i="$TMP/out-i.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_N=1 B10_OVERLAY_T="$OV_I" TMPDIR="$TMP" bash "$DRIVER" --resume "$TAG_I" BE-004 ) > "$out_i" 2>&1
rc_i=$?
if [[ "$rc_i" == 6 ]] && grep -q '20-run ceiling is reached' "$out_i" && grep -q 'holds 20 run' "$out_i"; then
  printf '  ok   %-52s exit %s\n' "I exit 6, ceiling counts recorded rows too" "$rc_i"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted 6)\n' "I exit 6, ceiling counts recorded rows too" "$rc_i"; FAIL=$((FAIL+1))
  sed 's/^/        /' "$out_i" | tail -5
fi
rm -rf "$EV_I"

# J. exit 7 — the wall-clock ceiling, forced to 0 s.
OV_J="$(good_overlay j)"
run_case "J exit 7, wall-clock ceiling" 7 'wall-clock ceiling is reached' \
  B10_N=1 B10_OVERLAY_T="$OV_J" B10_MAX_SECONDS=0 TMPDIR="$TMP" -- BE-003

# K. A RECORDED CELL IS NEVER RE-RUN. Seed one row, resume, and require the SKIP line.
OV_K="$(good_overlay k)"
TAG_K="20260102T000000Z"; EV_K="$TMP/batch-$TAG_K"
rm -rf "$EV_K"; mkdir -p "$EV_K"
{ printf 'task\tseq\tarm\trun_id\n'; printf 'BE-003\t01\tcontrol\talready-ran\n'; } > "$EV_K/manifest.tsv"
rm -f "$LAB/evidence/b10/.batch.lock"
out_k="$TMP/out-k.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_N=1 B10_OVERLAY_T="$OV_K" TMPDIR="$TMP" bash "$DRIVER" --resume "$TAG_K" BE-003 ) > "$out_k" 2>&1
rc_k=$?
if [[ "$rc_k" == 0 ]] \
   && grep -q 'BE-003 01 control already in the manifest' "$out_k" \
   && [[ "$(awk -F'\t' '$1=="BE-003" && $2=="01" && $3=="control"' "$EV_K/manifest.tsv" | wc -l | tr -d ' ')" == 1 ]]; then
  printf '  ok   %-52s exit %s\n' "K a recorded cell is skipped, not re-run" "$rc_k"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted 0 + a SKIP line)\n' "K a recorded cell is skipped, not re-run" "$rc_k"
  FAIL=$((FAIL+1)); sed 's/^/        /' "$out_k" | tail -5
fi
rm -rf "$EV_K"

# L. ROW 0a IS RECORDED, NOT FATAL — a treated run whose record carries no hashes. The stub curl
#    returns {} so every field is null; on the TREATED arm that is precisely row 0a.
OV_L="$(good_overlay l)"
rm -f "$LAB/evidence/b10/.batch.lock"
out_l="$TMP/out-l.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_N=1 B10_OVERLAY_T="$OV_L" TMPDIR="$TMP" bash "$DRIVER" BE-003 ) > "$out_l" 2>&1
rc_l=$?
if [[ "$rc_l" == 0 ]] && grep -q 'delivery=VOID-0a' "$out_l" && grep -q '1 void on delivery' "$out_l"; then
  printf '  ok   %-52s exit %s\n' "L treated with null hashes = VOID-0a, recorded" "$rc_l"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted 0 + VOID-0a + 1 void)\n' "L treated with null hashes = VOID-0a" "$rc_l"
  FAIL=$((FAIL+1)); sed 's/^/        /' "$out_l" | tail -6
fi

# M. THE CONTROL ARM'S MIRROR IMAGE: a control whose record carries a hash is ALSO VOID-0a. A
#    delivery proof that only checks the treated arm cannot see a contaminated control.
OV_M="$(good_overlay m)"
rm -f "$LAB/evidence/b10/.batch.lock"
out_m="$TMP/out-m.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  export STUB_RECORD='{"customization":{"instructionsHash":"sha256:deadbeef"}}'
  B10_N=1 B10_OVERLAY_T="$OV_M" TMPDIR="$TMP" bash "$DRIVER" BE-003 ) > "$out_m" 2>&1
rc_m=$?
n_void_m="$(grep -c 'delivery=VOID-0a' "$out_m" || true)"
if [[ "$rc_m" == 0 && "$n_void_m" == 2 ]]; then
  printf '  ok   %-52s exit %s\n' "M control carrying a hash is VOID-0a too" "$rc_m"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s, %s void lines (wanted 0 and 2)\n' "M control carrying a hash is VOID-0a too" "$rc_m" "$n_void_m"
  FAIL=$((FAIL+1)); sed 's/^/        /' "$out_m" | tail -6
fi

# N. H COUNTS A ROUTER LOG THAT EXISTS, AND THE LOG IS COPIED OUT OF $TMPDIR. macOS reaps $TMPDIR
#    in about three days and H is read from that file, so "it was there at the time" is not a
#    record. This case plants a log for the run the stub will report and requires the copy.
OV_N="$(good_overlay n)"
rm -f "$LAB/evidence/b10/.batch.lock"
cat > "$TMP/bin/stub-runner-logging" <<'STUB'
#!/usr/bin/env bash
uuid="11111111-2222-3333-4444-555555555555"
printf '{"q":"kotlin when","status":"hit"}\n' > "${TMPDIR:-/tmp}/knowledge-log-observatory-run-$uuid.jsonl"
echo " run        $uuid"
echo " worktree   ${TMPDIR:-/tmp}/observatory-run-$uuid"
STUB
chmod +x "$TMP/bin/stub-runner-logging"
out_n="$TMP/out-n.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner-logging" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_N=1 B10_OVERLAY_T="$OV_N" TMPDIR="$TMP" bash "$DRIVER" BE-003 ) > "$out_n" 2>&1
rc_n=$?
copied="$(find "$TMP" -path '*/router-logs/*' -name 'knowledge-log-observatory-run-11111111-*.jsonl' 2>/dev/null | head -1)"
if [[ "$rc_n" == 0 ]] && grep -q 'contact=router' "$out_n" && grep -q 'H=2' "$out_n" && [[ -s "$copied" ]]; then
  printf '  ok   %-52s exit %s\n' "N router log counted in H and copied out of TMPDIR" "$rc_n"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted contact=router, H=2, a copied log)\n' "N router log counted and copied" "$rc_n"
  FAIL=$((FAIL+1)); sed 's/^/        /' "$out_n" | tail -6
fi
# *** NO `rm -rf` HERE, AND THE REASON IS THAT THE FIRST VERSION OF THIS LINE WAS
# `rm -rf "$(dirname "$(dirname "$copied")")"` AND IT DELETED $TMP ITSELF. ***
# `find "$TMP" -name knowledge-log-...` matches TWO files: the copy under
# $TMP/batch-<tag>/router-logs/, and the ORIGINAL the stub planted at $TMP/knowledge-log-...
# (TMPDIR is $TMP in these cases). `head -1` returned the original, so dirname-twice resolved
# to the PARENT of $TMP — and the next case failed with exit 127 because $TMP/bin no longer
# existed. A cleanup that computes its target from a glob it does not control is how a fixture
# deletes something outside itself. The `trap rm -rf "$TMP"` at the top of this file is the
# only cleanup, it names a path this script created, and nothing else deletes anything.
# *** The case's assertion is narrowed to the copy, so the original cannot satisfy it either. ***

# O. CORPUS CONTACT WITHOUT A ROUTER CALL is recorded as `by-hand` and does NOT raise H. This is
#    the exact gap stop 20's census found by accident; here it is a fixture.
OV_O="$(good_overlay o)"
rm -f "$LAB/evidence/b10/.batch.lock"
cat > "$TMP/bin/stub-runner-byhand" <<'STUB'
#!/usr/bin/env bash
uuid="$(uuidgen | tr 'A-Z' 'a-z')"
echo " run        $uuid"
echo " worktree   ${TMPDIR:-/tmp}/observatory-run-$uuid"
echo "cat .ai/knowledge/index.yaml"
STUB
chmod +x "$TMP/bin/stub-runner-byhand"
out_o="$TMP/out-o.txt"
( export PATH="$TMP/bin:$PATH" B10_RUNNER="$TMP/bin/stub-runner-byhand" B10_OBS="$TMP" B10_EVID_ROOT="$TMP"
  B10_N=1 B10_OVERLAY_T="$OV_O" TMPDIR="$TMP" bash "$DRIVER" BE-003 ) > "$out_o" 2>&1
rc_o=$?
if [[ "$rc_o" == 0 ]] && grep -q 'contact=by-hand' "$out_o" && grep -q 'H=0' "$out_o"; then
  printf '  ok   %-52s exit %s\n' "O corpus read by hand is by-hand, H stays 0" "$rc_o"; PASS=$((PASS+1))
else
  printf '  FAIL %-52s exit %s (wanted contact=by-hand and H=0)\n' "O corpus read by hand, H stays 0" "$rc_o"
  FAIL=$((FAIL+1)); sed 's/^/        /' "$out_o" | tail -6
fi

# NOTHING TO CLEAN UP, AND THAT IS THE FIX RATHER THAN A CLEANUP. Every case writes its batch
# directory under $TMP via B10_EVID_ROOT, which the trap removes. The first version of this
# suite swept evidence/b10 afterwards with a `find -newermt` heuristic; a sweep that decides by
# timestamp which directories are fixtures is one machine-clock surprise away from deleting a
# recorded batch, and §6 forbids deleting evidence.

echo ""
printf 'verify-b10-batch-guards: %s passed, %s failed\n' "$PASS" "$FAIL"
[[ "$FAIL" == 0 ]] || exit 1
