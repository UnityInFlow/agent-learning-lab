#!/usr/bin/env bash
#
# run-b11-deliberate-failure — §4 step 9 for stop 26 (B11, v1.2), mechanism 3.
#
# THE REGISTERED PROBE, from phases/b11-efficiency/README.md: "feed the file-summary cache a stale
# entry and confirm the hash check refuses it." Six clauses D1-D6, five repetitions each, no
# benchmark run and no model call. The prediction is committed BEFORE this script runs; the commit
# is checked by `git show -s --format=%cI` against this run's tag, never by prose.
#
# WHAT IS UNDER TEST IS THE *DELIVERED* ARTIFACT, not a fixture copy: the reader and recorder are
# executed from inside a kept treated worktree of the registered batch, and their sha is asserted
# against the registered overlay's before anything else happens (exit 3 if it moved). That is the
# claim tools/verify-summary-cache.sh cannot make.
#
# THE SUBJECT FILE IS A BYTE COPY OF A WORKTREE FILE, NOT THE FILE ITSELF, and the reason is §6:
# a stale entry is produced by CHANGING the file, and changing a file inside
# evidence.local/b11-worktrees/ would rewrite evidence. The copy's sha is recorded beside the
# original's so the substitution is auditable, and the content is therefore real.
#
# EXIT CODES — every one of them is proved by evidence/b11/verify-b11-deliberate-failure.sh:
#   0  every clause held on every repetition
#   2  a clause FAILED (the probe worked, the prediction did not)
#   3  the delivered hook is not the registered one — refuse rather than measure the wrong file
#   4  a prerequisite is missing (jq, the worktree, the subject file, the recorder)
set -uo pipefail

LAB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" || exit 4
cd "$LAB" || exit 4

TAG="${DF_TAG:-$(date -u +%Y%m%dT%H%M%SZ)}"
REPS="${DF_REPS:-5}"
RUNID="${DF_RUNID:-40af8ffb-f0fa-4250-80cb-c6d829941d51}"
WT="${DF_WORKTREE:-$LAB/evidence.local/b11-worktrees/$RUNID}"
HOOK="${DF_HOOK:-$WT/.ai/hooks/summary-cache.sh}"
RECORDER="${DF_RECORDER:-$WT/.ai/hooks/summary-cache-record.sh}"
# The registered overlay's reader, as committed at build/customizations/agent-v1.2-efficiency/.
EXPECT_SHA="${DF_EXPECT_SHA:-e78e6623725b426ffc241461711a7e318205fe674aecc3c76f0970e60d357df9}"
SUBJECT_SRC="${DF_SUBJECT:-$WT/sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt}"
OUT="${DF_OUT:-$LAB/evidence/b11/deliberate-failure-$TAG}"

command -v jq >/dev/null 2>&1 || { echo "PREREQ: jq is not on PATH" >&2; exit 4; }
command -v shasum >/dev/null 2>&1 || { echo "PREREQ: shasum is not on PATH" >&2; exit 4; }
[[ -d "$WT" ]]           || { echo "PREREQ: no worktree at $WT" >&2; exit 4; }
[[ -x "$HOOK" ]]         || { echo "PREREQ: reader not executable: $HOOK" >&2; exit 4; }
[[ -x "$RECORDER" ]]     || { echo "PREREQ: recorder not executable: $RECORDER" >&2; exit 4; }
[[ -f "$SUBJECT_SRC" ]]  || { echo "PREREQ: no subject file at $SUBJECT_SRC" >&2; exit 4; }

GOT_SHA="$(shasum -a 256 "$HOOK" | cut -d' ' -f1)"
if [[ "$GOT_SHA" != "$EXPECT_SHA" ]]; then
  echo "REFUSING: the delivered reader hashes $GOT_SHA, registered is $EXPECT_SHA." >&2
  echo "          A probe against an unregistered artifact measures the wrong file." >&2
  exit 3
fi

mkdir -p "$OUT/broken" "$OUT/per-rep" || exit 4
LOGFILE="$OUT/RESULT.md"

# ===== THE BREAK: the mismatch branch removed from a COPY, and nothing else.
BROKEN="$OUT/broken/summary-cache.sh"
awk 'NR>=85 && NR<=91 {next} {print}' "$HOOK" > "$BROKEN" || exit 4
chmod +x "$BROKEN"
DIFF_LINES="$(diff "$HOOK" "$BROKEN" | grep -c '^<')"
BROKEN_SHA="$(shasum -a 256 "$BROKEN" | cut -d' ' -f1)"

SUBJECT="$OUT/subject-ShipmentController.kt"
cp "$SUBJECT_SRC" "$SUBJECT" || exit 4
SRC_SHA="$(shasum -a 256 "$SUBJECT_SRC" | cut -d' ' -f1)"
COPY_SHA="$(shasum -a 256 "$SUBJECT" | cut -d' ' -f1)"
# A real source line of the subject, used by D4 to prove no body leaked into the refusal.
BODY_LINE="$(grep -m1 -E '^[[:space:]]*(class|fun|import) ' "$SUBJECT" | sed 's/^[[:space:]]*//')"

payload() { jq -nc --arg p "$1" '{tool_name:"Read",tool_input:{file_path:$p}}'; }

# call <hook> <store> <log> <path> -> prints the exit code, appends to the log
call() {
  local h="$1" st="$2" lg="$3" p="$4" rc=0
  payload "$p" | AGENT_CACHE_STORE="$st" AGENT_CACHE_LOG="$lg" CLAUDE_PROJECT_DIR="$OUT" \
    "$h" >"$OUT/.last.out" 2>"$OUT/.last.err" || rc=$?
  printf '%s' "$rc"
}

lastline() { [[ -s "$1" ]] && tail -1 "$1" | jq -r "$2" 2>/dev/null || printf 'NOLOG'; }

PASS=0; FAIL=0
declare -a CLAUSE_PASS CLAUSE_FAIL
for c in D1 D2 D3 D4 D5 D6; do CLAUSE_PASS[${c:1}]=0; CLAUSE_FAIL[${c:1}]=0; done

check() {  # check <clause-number> <description> <expected> <actual>
  local n="$1" what="$2" exp="$3" act="$4"
  if [[ "$exp" == "$act" ]]; then
    CLAUSE_PASS[n]=$(( CLAUSE_PASS[n] + 1 )); PASS=$((PASS+1))
    printf '    ok   D%s %-46s %s\n' "$n" "$what" "$act"
  else
    CLAUSE_FAIL[n]=$(( CLAUSE_FAIL[n] + 1 )); FAIL=$((FAIL+1))
    printf '    FAIL D%s %-46s expected %s, got %s\n' "$n" "$what" "$exp" "$act"
  fi
}

echo "B11 deliberate failure — tag $TAG, $REPS repetitions"
echo "  delivered reader   $HOOK"
echo "  reader sha         $GOT_SHA (registered)"
echo "  broken copy        $BROKEN_SHA ($DIFF_LINES lines removed)"
echo "  subject            $SUBJECT_SRC"
echo "  subject sha        src $SRC_SHA / copy $COPY_SHA"

for ((i=1;i<=REPS;i++)); do
  R="$OUT/per-rep/$i"; mkdir -p "$R"
  ST="$R/store.json"; LG="$R/cache-log.jsonl"
  printf '{}\n' > "$ST"; : > "$LG"
  cp "$SUBJECT" "$R/subject.kt"
  S="$R/subject.kt"
  echo "  rep $i"

  # D6 — the seed is written by the DELIVERED RECORDER, not by hand.
  rc="$(call "$RECORDER" "$ST" "$LG" "$S")"
  check 6 "recorder stored the entry (rc, reason)" "0 stored" \
        "$rc $(lastline "$LG" '.reason')"
  check 6 "store holds the subject's key" "true" \
        "$(jq --arg p "$S" 'has($p)' "$ST")"

  # D3 — hash match: the read is REFUSED.
  rc="$(call "$HOOK" "$ST" "$LG" "$S")"
  check 3 "fresh entry refused (rc, decision, reason)" "2 block hash-match" \
        "$rc $(lastline "$LG" '.decision') $(lastline "$LG" '.reason')"

  # D4 — the refusal carries metadata, not the file body.
  if [[ -n "$BODY_LINE" ]] && grep -qF "$BODY_LINE" "$OUT/.last.err"; then
    check 4 "refusal leaked a source line" "absent" "PRESENT"
  else
    check 4 "refusal leaked a source line" "absent" "absent"
  fi
  check 4 "refusal names the path and the sha" "yes" \
        "$(grep -qF "$S" "$OUT/.last.err" && grep -qiE 'sha256' "$OUT/.last.err" && echo yes || echo no)"
  cp "$OUT/.last.err" "$R/d3-refusal.txt"

  # D1 — the file CHANGES, so the entry is now stale.
  printf '\n// stale-maker %s rep %s\n' "$TAG" "$i" >> "$S"
  rc="$(call "$HOOK" "$ST" "$LG" "$S")"
  check 1 "stale entry allowed (rc, decision, reason)" "0 allow stale-refused" \
        "$rc $(lastline "$LG" '.decision') $(lastline "$LG" '.reason')"

  # D2 — the entry was DELETED, not ignored: the store loses the key and a repeat call is a miss.
  check 2 "store dropped the stale key" "false" \
        "$(jq --arg p "$S" 'has($p)' "$ST")"
  rc="$(call "$HOOK" "$ST" "$LG" "$S")"
  check 2 "repeat call is a miss (rc, reason)" "0 miss" \
        "$rc $(lastline "$LG" '.reason')"

  # D5 — THE BREAK, on an identical stale state: a changed file is refused as unchanged.
  BST="$R/broken-store.json"; BLG="$R/broken-cache-log.jsonl"
  printf '{}\n' > "$BST"; : > "$BLG"
  cp "$SUBJECT" "$R/broken-subject.kt"
  BS="$R/broken-subject.kt"
  call "$RECORDER" "$BST" "$BLG" "$BS" >/dev/null
  printf '\n// stale-maker %s rep %s broken\n' "$TAG" "$i" >> "$BS"
  rc="$(call "$BROKEN" "$BST" "$BLG" "$BS")"
  check 5 "break refuses a CHANGED file (rc, reason)" "2 hash-match" \
        "$rc $(lastline "$BLG" '.reason')"
  cp "$OUT/.last.err" "$R/d5-refusal.txt"
done

rm -f "$OUT/.last.out" "$OUT/.last.err"

# The RESULT.md body is markdown: the backticks inside these single-quoted formats are
# literal code spans, not command substitution. SC2016 is a false positive on every line of it.
# shellcheck disable=SC2016
{
  printf '# B11 §4 step 9 — deliberate failure, tag %s\n\n' "$TAG"
  printf 'Repetitions: %s. No benchmark run, no model call, no run id.\n\n' "$REPS"
  printf '| what | value |\n|---|---|\n'
  printf '| delivered reader | `%s` |\n' "${HOOK#"$LAB"/}"
  printf '| reader sha (registered) | `%s` |\n' "$GOT_SHA"
  printf '| broken copy sha | `%s` |\n' "$BROKEN_SHA"
  printf '| lines removed from the copy | %s |\n' "$DIFF_LINES"
  printf '| subject in the worktree | `%s` |\n' "${SUBJECT_SRC#"$LAB"/}"
  printf '| subject sha, source / copy | `%s` / `%s` |\n' "$SRC_SHA" "$COPY_SHA"
  printf '\n| clause | passed | failed |\n|---|---|---|\n'
  for n in 1 2 3 4 5 6; do
    printf '| D%s | %s | %s |\n' "$n" "${CLAUSE_PASS[$n]}" "${CLAUSE_FAIL[$n]}"
  done
  printf '\nTotal assertions: %s passed, %s failed.\n' "$PASS" "$FAIL"
} > "$LOGFILE"

echo "  -> $LOGFILE"
echo "  assertions: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 2
exit 0
