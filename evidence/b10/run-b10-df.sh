#!/usr/bin/env bash
# B10's DELIBERATE FAILURE — DF1, spine stop 21, §4 step 9.
#
#   ./evidence/b10/run-b10-df.sh
#
# THE QUESTION, and it is a conversion rather than a discovery: E-024/E-025 prediction 2 says
# "0 of 2 measured L2 controls survive the port". The NAMED-AGENT half is already L2 — census
# probes 3 and 4 are two refusals that EXECUTE (run-agent.sh:325 and :522, exit 1 each). The
# POLICY-GATE half is L3: it is proved by READING the runner and by hooksHash being null. §5 says
# the layer column is about the proof and not the artifact, so that half is currently a sentence.
#
# DF1 ships census probe 5's overlay — the nine-file port PLUS .claude/settings.json, which the
# runner PERMITS at exit 0 — on ONE real codex run, and asks whether the policy gate B7 measured
# at 17 of 17 treated runs executes. It should not. Showing that it does not is L2.
#
# WHAT THE OBSERVABLE IS, AND WHY IT IS NOT THE RUN RECORD:
#   The record has no hook-EXECUTION field. It has `customization.hooksHash`, which is NULL on
#   every run ever recorded, and a null hash says a file was not hashed, not that a hook did not
#   fire. So the observable is policy-gate.sh's OWN log, which its header names as "the ONLY
#   per-run delivery proof available" and which it appends to ON ALLOW AS WELL AS ON DENY for
#   exactly this reason.
#
# WHY THE SWEEP IS A GLOB AND NOT A PREDICTED FILENAME:
#   `grep -n 'CLAUDE_PROJECT_DIR\|POLICY_EVENT_LOG' runner/run-agent.sh` returns NOTHING. The
#   runner sets neither, so the log's name on a codex run is unpredictable — it would be
#   `policy-events-unknown.jsonl` if anything wrote it. Looking in ONE predicted place and
#   reporting the absence as a measurement is this project's house failure mode, so this script
#   inventories EVERY policy-events-*.jsonl in $TMPDIR and /tmp BEFORE the run and diffs the
#   inventory afterwards, by name AND by line count.
#
# WHY THE POSITIVE CONTROL RUNS FIRST AND ITS FAILURE IS FATAL (exit 3):
#   B7's own unexpected_effect (2): "the delivery proof cannot distinguish 'no hook installed'
#   from 'hook broken, denying everything'; both leave no log." DF-P2 WITHOUT DF-P3 PROVES
#   NOTHING. So the script invokes the INSTALLED policy-gate.sh directly first, at B7's registered
#   sha, and REFUSES TO SPEND A RUN if it does not fire. An empty log after a control that never
#   fired is not evidence, it is a wasted $0.20 and a claim a validator would delete.
#
# EXIT CODES, each proved by evidence/b10/verify-b10-df-guards.sh:
#   0   the DF completed and RESULT.md is written. THE VERDICT IS IN THE FILE, NOT IN THIS CODE —
#       a driver that exited non-zero on "DF-P2 refuted" would be a driver with an opinion.
#   2   unknown flag
#   3   THE POSITIVE CONTROL (DF-P3) FAILED. No run is started. See above.
#   5   the overlay is not the registered one (either hash, or a mode bit no hash sees —
#       stop 20's deliberate failure shipped an unexecutable router.sh past two identical hashes)
#   8   a second DF is already running (pid lock)
#   9   the run produced no run id, so there is nothing to read
#   10  THE RUNNER RETURNED NON-ZERO. RESULT.md is written and marked INVALID FOR DF-P1, because
#       DF-P1 *is* "the runner did not refuse" and a driver that exits 0 after a failed runner
#       lets one reader see a completed DF where another sees a failed run. (§4a round 1, `the run`.)
#   11  THE RUN RECORD IS UNREADABLE OR INCOMPLETE. An empty body or an HTML 502 makes every jq
#       read come back empty, and empty is not the same measurement as null. RESULT.md is written
#       and marked RECORD UNREADABLE. (§4a round 1, `REC`.)
#
# AMENDED 2026-09-27 AFTER §4a ROUND 1, which returned six findings on this file and was right
# about all six. The version that produced DF1 is sha 02a2147479fcbe06; all six are closed against
# DF1 itself by evidence rather than by argument (see the RESULT addendum), and all six are fixed
# here prospectively. What changed: the lock is created ATOMICALLY rather than checked-then-written;
# `.claude/settings.json` is checked BY SHA and not merely for existence -- it IS the treatment, and
# a driver that hashes the two portable files and only stats the one under test is the delivery
# proof this project has already paid for twice; the sweep is NULL-DELIMITED so a filename
# containing a newline cannot split one record into two; the runner's rc and the record's
# readability each get their own exit code; and a SETTLING re-sweep runs after a delay, because a
# hook child appending just after run-agent.sh exits would otherwise be a false negative.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1
LAB="$PWD"
OBS="${B10_OBS:-$(cd ../agent-observatory && pwd)}" || exit 1

OVERLAY="${B10_DF_OVERLAY:-$LAB/evidence/b10/census-fixtures/port-plus-claude-settings}"
TASK="${B10_DF_TASK:-BE-003}"
MODEL="${B10_DF_MODEL:-gpt-5.6-sol}"
RUNTIME="${B10_DF_RUNTIME:-codex}"
KEY="${B10_DF_KEY:-EXP-B10-DF-BE003}"
RUNNER="${B10_RUNNER:-runner/run-agent.sh}"
EXPECT_INSTR="${B10_EXPECT_INSTR_T:-sha256:ebf489800a60a156986f98ea4f127848}"
EXPECT_KNOW="${B10_EXPECT_KNOWLEDGE_T:-sha256:0770219ae7f4281a80071d78dadea285}"
# B7's registered policy-gate.sh sha, from phases/b07-verification-policies/README.md's §5 table.
EXPECT_GATE="${B10_EXPECT_GATE_SHA:-f432abbcbf1f3b90ec4dd801a23c333a5f7e6c40fe0b54b11fd5689f9938cbca}"
# THE TREATMENT'S OWN SHA. v1.2's .claude/settings.json, byte for byte, re-derived from
# build/customizations/agent-v1.2-knowledge/.claude/settings.json and from the setup commit of
# DF1's own run (9652494fa571). Registered as an EXACT VALUE for the same reason the other two
# digests are: existence is not identity, and this file is the one thing the DF is about.
EXPECT_SETTINGS="${B10_EXPECT_SETTINGS_SHA:-925a382322daada434a8d3716f8696882a1759b048ccc7f0d580a902ea27fb2b}"
SETTLE_SECONDS="${B10_DF_SETTLE:-20}"

export API="${B10_API:-http://127.0.0.1:8081}"
export WEB="${B10_WEB:-http://localhost:5174}"
export TEMPO_URL="${B10_TEMPO:-http://localhost:3200}"
export OTLP_HTTP_ENDPOINT="${B10_OTLP:-http://localhost:4318}"
export OTLP_GRPC_ENDPOINT="${B10_OTLP_GRPC:-http://localhost:4317}"

while [[ "${1:-}" == --* ]]; do
  echo "run-b10-df: unknown flag $1 (this driver takes none)" >&2; exit 2
done

TAG="${B10_DF_TAG:-$(date -u +%Y%m%dT%H%M%SZ)}"
EVID="${B10_EVID_ROOT:-$LAB/evidence/b10}/df-$TAG"
mkdir -p "$EVID"
RESULT="$EVID/RESULT.md"

# --- exit 8: the pid lock -------------------------------------------------------------------
# ATOMIC, not checked-then-written. §4a round 1: two copies started together could both pass an
# `[[ -e "$LOCK" ]]` test before either wrote, both overwrite the lock with their own pid, and both
# spend a run -- so the exit-8 guard was advertising mutual exclusion it did not provide.
# `set -o noclobber` makes the create-or-fail one operation, which is the only form that holds.
LOCK="$LAB/evidence/b10/.df.lock"
take_lock() { ( set -o noclobber; echo "$$" > "$LOCK" ) 2>/dev/null; }
if ! take_lock; then
  other="$(cat "$LOCK" 2>/dev/null)"
  if [[ -n "$other" ]] && kill -0 "$other" 2>/dev/null; then
    echo "run-b10-df: a DF is already running as pid $other ($LOCK). Refusing." >&2; exit 8
  fi
  # A stale lock is taken over -- but by REMOVING it and racing for the create again, so that two
  # processes finding the same stale lock cannot both proceed.
  echo "run-b10-df: stale lock for pid ${other:-?}, taking it over" >&2
  rm -f "$LOCK"
  if ! take_lock; then
    echo "run-b10-df: lost the race for a stale lock to another DF. Refusing." >&2; exit 8
  fi
fi
trap 'rm -f "$LOCK"' EXIT

# --- exit 5: the overlay is the registered one, checked before anything is spent -------------
instr_digest() { printf 'sha256:%s' "$(shasum -a 256 "$1/AGENTS.md" | cut -c1-32)"; }
knowledge_digest() {
  ( cd "$1" && find .ai/knowledge -type f 2>/dev/null | LC_ALL=C sort \
    | while IFS= read -r f; do printf '%s\n' "$f"; shasum -a 256 "$f" | cut -d' ' -f1; done ) \
    | shasum -a 256 | cut -c1-32 | sed 's/^/sha256:/'
}
GOT_INSTR="$(instr_digest "$OVERLAY")"
GOT_KNOW="$(knowledge_digest "$OVERLAY")"
GOT_GATE="$(shasum -a 256 "$OVERLAY/.ai/hooks/policy-gate.sh" | cut -d' ' -f1)"
if [[ "$GOT_INSTR" != "$EXPECT_INSTR" || "$GOT_KNOW" != "$EXPECT_KNOW" ]]; then
  echo "run-b10-df: the DF overlay is not the registered port. Refusing." >&2
  echo "  instructionsHash want $EXPECT_INSTR got $GOT_INSTR" >&2
  echo "  knowledgeHash    want $EXPECT_KNOW  got $GOT_KNOW"  >&2
  exit 5
fi
if [[ "$GOT_GATE" != "$EXPECT_GATE" ]]; then
  echo "run-b10-df: policy-gate.sh is NOT the sha B7 measured. The whole DF rests on it being" >&2
  echo "  the same script. want $EXPECT_GATE got $GOT_GATE" >&2
  exit 5
fi
if [[ ! -f "$OVERLAY/.claude/settings.json" ]]; then
  echo "run-b10-df: the DF overlay has no .claude/settings.json, which IS the deliberate" >&2
  echo "  failure. Refusing to run a DF that does not contain its own treatment." >&2
  exit 5
fi
# AND IT MUST BE THE REGISTERED ONE, not merely present. §4a round 1 found that changing only this
# file -- for instance to a configuration some runtime DOES read -- left GOT_INSTR, GOT_KNOW and
# GOT_GATE untouched and let the driver test a different treatment while RESULT.md still called the
# overlay registered.
GOT_SETTINGS="$(shasum -a 256 "$OVERLAY/.claude/settings.json" | cut -d' ' -f1)"
if [[ "$GOT_SETTINGS" != "$EXPECT_SETTINGS" ]]; then
  echo "run-b10-df: .claude/settings.json is NOT the registered v1.2 file. It IS the treatment," >&2
  echo "  so this is the one file whose identity the DF cannot infer." >&2
  echo "  want $EXPECT_SETTINGS" >&2
  echo "  got  $GOT_SETTINGS" >&2
  exit 5
fi
NOEXEC="$(find "$OVERLAY" -type f -name '*.sh' ! -perm -u+x | wc -l | tr -d ' ')"
if [[ "$NOEXEC" != 0 ]]; then
  echo "run-b10-df: $NOEXEC shell file(s) not executable, and NO HASH WOULD SEE THAT." >&2
  exit 5
fi

# --- DF-P3: THE POSITIVE CONTROL, FIRST, AND FATAL IF IT FAILS ------------------------------
# Its log goes into the evidence directory and NOT into $TMPDIR, so it cannot pollute the sweep
# that DF-P2 depends on. A positive control that contaminates its own negative observation is
# the same defect as a guardrail that writes into the repository it guards (B7, exit 21).
PC_LOG="$EVID/positive-control-policy-events.jsonl"
PC_ROOT="$EVID/pc-project"
mkdir -p "$PC_ROOT"
cp -R "$OVERLAY/.ai" "$PC_ROOT/.ai"
pc_call() {  # pc_call <path>  -> echoes the exit code
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$1" \
    | POLICY_EVENT_LOG="$PC_LOG" CLAUDE_PROJECT_DIR="$PC_ROOT" \
      "$PC_ROOT/.ai/hooks/policy-gate.sh" >/dev/null 2>"$EVID/positive-control-stderr.txt"
  echo $?
}
PC_DENY_RC="$(pc_call 'sample-service/pom.xml')"
PC_ALLOW_RC="$(pc_call 'sample-service/src/main/kotlin/com/unityinflow/sample/api/ApiError.kt')"
PC_LINES="$( [[ -f "$PC_LOG" ]] && wc -l < "$PC_LOG" | tr -d ' ' || echo 0 )"
echo "run-b10-df: positive control  deny_rc=$PC_DENY_RC allow_rc=$PC_ALLOW_RC log_lines=$PC_LINES"
if [[ "$PC_DENY_RC" != 2 || "$PC_ALLOW_RC" != 0 || "$PC_LINES" != 2 ]]; then
  echo "run-b10-df: DF-P3 FAILED — the installed gate did not fire as B7 measured it." >&2
  echo "  Expected deny_rc=2 allow_rc=0 log_lines=2. NO RUN IS STARTED: DF-P2 without DF-P3" >&2
  echo "  proves nothing, and an empty log after a control that never fired is not evidence." >&2
  exit 3
fi

# --- the pre-run inventory: what policy-events logs exist BEFORE the run --------------------
# NULL-DELIMITED, because DF-P2 is a claim about a DIFF of two inventories and `ls -1` emits a
# filename containing a newline as TWO records -- which would break the path-to-line-count mapping
# the whole negative observation rests on (§4a round 1, `the pre-run inventory`). A tab or newline
# inside a path is also reported explicitly rather than silently normalised, because a log the
# sweep cannot represent is a log the sweep cannot rule out.
sweep() {  # sweep -> "<path>\t<lines>" per existing log, sorted, one record per file
  { find "${TMPDIR:-/tmp}" -maxdepth 1 -name 'policy-events-*.jsonl' -print0 2>/dev/null
    find /tmp -maxdepth 1 -name 'policy-events-*.jsonl' -print0 2>/dev/null; } \
  | LC_ALL=C sort -z -u \
  | while IFS= read -r -d '' f; do
      case "$f" in
        *$'\n'*|*$'\t'*) printf 'UNREPRESENTABLE-PATH\t%s\n' "$(printf '%s' "$f" | od -An -c | tr -d ' \n')" ;;
        *) printf '%s\t%s\n' "$f" "$(wc -l < "$f" | tr -d ' ')" ;;
      esac
    done
}
sweep > "$EVID/sweep-before.tsv"
BEFORE_N="$(wc -l < "$EVID/sweep-before.tsv" | tr -d ' ')"
echo "run-b10-df: pre-run sweep found $BEFORE_N policy-events log(s)"

# --- the run --------------------------------------------------------------------------------
LOG="$EVID/run.log"
echo "run-b10-df: starting the codex run, key=$KEY task=$TASK $(date -u +%H:%M:%SZ)"
STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
( cd "$OBS" && INIT_SCHEMA_DIR="$EVID/init-schema" "$RUNNER" \
    --runtime "$RUNTIME" --benchmark "$TASK" --experiment "$KEY" --model "$MODEL" \
    --customization "$OVERLAY" --variant port-plus-claude-settings \
    --isolate-user-settings --keep ) > "$LOG" 2>&1
RC=$?
FINISHED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
RID="$(/usr/bin/grep -aoE 'run +[0-9a-f-]{36}' "$LOG" | head -1 | awk '{print $2}')"
WT="$(/usr/bin/grep -aoE '/[^ ]*observatory-run-[0-9a-f-]{36}' "$LOG" | head -1)"
echo "run-b10-df: rc=$RC run_id=${RID:-none}"

# --- the post-run sweep, diffed against the inventory ---------------------------------------
sweep > "$EVID/sweep-after.tsv"
AFTER_N="$(wc -l < "$EVID/sweep-after.tsv" | tr -d ' ')"
NEW_OR_GROWN="$(LC_ALL=C comm -13 "$EVID/sweep-before.tsv" "$EVID/sweep-after.tsv" | wc -l | tr -d ' ')"
NEW_OR_GROWN_DETAIL="$(LC_ALL=C comm -13 "$EVID/sweep-before.tsv" "$EVID/sweep-after.tsv" | tr '\t' ' ' | tr '\n' ';')"

# THE SETTLING SWEEP. A hook child that appends its policy event shortly AFTER run-agent.sh exits
# would make the immediate sweep a false negative (§4a round 1, `the post-run sweep`). An immediate
# zero and a zero N seconds later are two different observations, and only the second one rules
# that out. Both are reported; neither replaces the other.
sleep "$SETTLE_SECONDS"
sweep > "$EVID/sweep-late.tsv"
LATE_N="$(wc -l < "$EVID/sweep-late.tsv" | tr -d ' ')"
LATE_NEW="$(LC_ALL=C comm -13 "$EVID/sweep-before.tsv" "$EVID/sweep-late.tsv" | wc -l | tr -d ' ')"

# exit 10: DF-P1 IS "the runner did not refuse", so a non-zero rc is not a detail the reader can
# take or leave (§4a round 1, `the run`). The measurement is still written; only the claim is
# withheld.
if [[ "$RC" != 0 ]]; then
  # Same single-quote-on-purpose reason as the main report block below.
  # shellcheck disable=SC2016
  {
    printf '# B10 DF1 — THE RUNNER RETURNED %s, exit 10\n\n' "$RC"
    printf '**DF-P1 CANNOT BE CLAIMED FROM THIS RUN** — DF-P1 *is* "the runner does not refuse the\n'
    printf 'extra `.claude/settings.json`", and this runner refused, failed, or died. run id `%s`,\n' "${RID:-none}"
    printf 'log `%s`.\n\n' "$LOG"
    printf 'The sweeps ran and are reported so nothing is lost: before %s, after %s, new-or-grown\n' "$BEFORE_N" "$AFTER_N"
    printf '**%s**; settling sweep after %ss: %s log(s), new-or-grown **%s**. DF-P3 positive control:\n' "$NEW_OR_GROWN" "$SETTLE_SECONDS" "$LATE_N" "$LATE_NEW"
    printf 'deny `%s`, allow `%s`, log lines `%s`. **DF-P2 is NOT claimed either**, because a run that\n' "$PC_DENY_RC" "$PC_ALLOW_RC" "$PC_LINES"
    printf 'did not complete has an unknown trigger population, and DF-P2 without a non-empty trigger\n'
    printf 'population is registered VOID.\n'
  } > "$RESULT"
  echo "run-b10-df: runner rc=$RC. RESULT.md marked, DF-P1 and DF-P2 NOT claimed." >&2
  exit 10
fi

if [[ -z "$RID" ]]; then
  # Every printf format below is SINGLE-quoted ON PURPOSE: the backticks are markdown code spans
  # and `$TMPDIR` is the literal name of the variable being written about, not an expansion. Values
  # arrive as %s arguments, which is the form that cannot be broken by a value containing a $.
  # shellcheck disable=SC2016
  {
    printf '# B10 DF1 — NO RUN ID, exit 9\n\nrc=%s, log %s\nThe sweep still ran: before %s, after %s, new-or-grown %s\n' \
      "$RC" "$LOG" "$BEFORE_N" "$AFTER_N" "$NEW_OR_GROWN"
  } > "$RESULT"
  echo "run-b10-df: no run id in the log; nothing to read. RESULT.md written." >&2
  exit 9
fi

REC="$(curl -s -m 20 "$API/api/runs/$RID" 2>/dev/null)"
printf '%s' "$REC" > "$EVID/run-record.json"
# exit 11: EMPTY IS NOT NULL. An unreachable API or an HTML 502 makes every jq read come back
# empty, and a RESULT.md full of empty fields reads exactly like a run whose fields were genuinely
# null -- which is a measurement, not an absence (§6: "a missing cell is not a null cell").
# *** THE EMPTINESS TEST COMES FIRST, AND IT IS NOT REDUNDANT. *** `printf '' | jq -e '.x != null'`
# exits **0**: jq on empty input emits nothing and succeeds, so a check written as `jq -e` ALONE
# passes when the API returned absolutely nothing -- which is the exact failure the finding named,
# reproduced inside the fix for it. Caught by fixture case O, which only failed once the fixture
# itself stopped silently hitting the live stack.
if [[ -z "$REC" ]] \
   || ! printf '%s' "$REC" | jq -e '.runId != null and .evaluation != null and .customization != null' >/dev/null 2>&1; then
  # Same single-quote-on-purpose reason as the main report block below.
  # shellcheck disable=SC2016
  {
    printf '# B10 DF1 — RECORD UNREADABLE, exit 11\n\n'
    printf 'run id `%s`, runner rc `%s`. The API at `%s` returned nothing usable, so NO field of\n' "$RID" "$RC" "$API"
    printf 'DF-P4 is reported: empty is not null, and a table of blanks would read like a\n'
    printf 'measurement. The sweeps DID run and are valid on their own terms:\n\n'
    printf -- '- before %s, after %s, new-or-grown **%s**\n' "$BEFORE_N" "$AFTER_N" "$NEW_OR_GROWN"
    printf -- '- settling sweep after %ss: %s log(s), new-or-grown **%s**\n' "$SETTLE_SECONDS" "$LATE_N" "$LATE_NEW"
    printf -- '- DF-P3 positive control: deny `%s`, allow `%s`, log lines `%s`\n' "$PC_DENY_RC" "$PC_ALLOW_RC" "$PC_LINES"
    printf '\nRe-read the record and re-derive DF-P4 by hand; do not re-run the DF.\n'
  } > "$RESULT"
  echo "run-b10-df: the run record is unreadable. RESULT.md marked, DF-P4 NOT reported." >&2
  exit 11
fi
j() { printf '%s' "$REC" | jq -r "$1"; }
IH="$(j '.customization.instructionsHash // "null"')"
KH="$(j '.customization.knowledgeHash // "null"')"
CUST_KEYS="$(printf '%s' "$REC" | jq -r '.customization | keys | join(",")')"
HOOKISH="$(printf '%s' "$REC" | jq -r '[paths|join(".")]|map(select(test("(?i)hook|settings")))|join(",")')"
HOOKSHASH="$(j '.customization.hooksHash // "null"')"
EV="$(j '.evaluation.exitCode // "null"')"
CHG="$(j 'if .result.changedFiles then (.result.changedFiles|length) else "null" end')"
TOK="$(j '.efficiency.reportedTotalTokens // "null"')"
DUR="$(j '.efficiency.durationMs // "null"')"
# The setup commit, which is what DF-P1 is ACTUALLY evidenced by: the `tracked overlay files`
# line is printed by `--check-customization` and NOT by a real run (found at §4 step 9), so the
# read-back is the commit's own tree.
SETUP_COMMIT="$(/usr/bin/grep -aoE 'evaluation baseline moved to [0-9a-f]+' "$LOG" | head -1 | awk '{print $NF}')"
OVERLAY_IN_TREE="?"
if [[ -n "$SETUP_COMMIT" && -n "${WT:-}" && -d "$WT" ]]; then
  OVERLAY_IN_TREE="$(git -C "$WT" ls-tree -r --name-only "$SETUP_COMMIT" 2>/dev/null \
    | /usr/bin/grep -cE '^(AGENTS\.md|\.ai/|\.claude/)' || echo '?')"
fi

# Every printf format below is SINGLE-quoted ON PURPOSE: the backticks are markdown code spans
# and `$TMPDIR` is the literal name of the variable being written about, not an expansion. Values
# arrive as %s arguments, which is the form that cannot be broken by a value containing a $.
# shellcheck disable=SC2016
{
  printf '# B10 DF1 — the guardrail that ports as a file and not as a control\n\n'
  printf 'Driver `evidence/b10/run-b10-df.sh`, batch tag `%s`. Prediction registered BEFORE this\n' "$TAG"
  printf 'run in `phases/b10-second-runtime-adapter/README.md` and cross-referenced in E-024/E-025.\n\n'
  printf '| field | value |\n|---|---|\n'
  printf '| run id | `%s` |\n' "$RID"
  printf '| runner rc | `%s` |\n' "$RC"
  printf '| started / finished (UTC) | `%s` / `%s` |\n' "$STARTED_AT" "$FINISHED_AT"
  printf '| task / runtime / model | `%s` / `%s` / `%s` |\n' "$TASK" "$RUNTIME" "$MODEL"
  printf '| experiment key | `%s` (own key, NOT in E-024 population) |\n' "$KEY"
  printf '| overlay | `%s` (10 files) |\n' "${OVERLAY#"$LAB"/}"
  printf '| worktree | `%s` |\n' "${WT:-none}"
  printf '| evaluator exitCode | `%s` |\n' "$EV"
  printf '| changedFiles | **`%s`** |\n' "$CHG"
  printf '| reportedTotalTokens / durationMs | `%s` / `%s` |\n' "$TOK" "$DUR"
  printf '\n## DF-P1 — the runner does not refuse the extra `.claude/settings.json`\n\n'
  printf 'runner rc **`%s`**. The read-back is the SETUP COMMIT `%s`, whose tree holds **%s**\n' "$RC" "${SETUP_COMMIT:-none}" "$OVERLAY_IN_TREE"
  printf 'overlay path(s) matching `AGENTS.md|.ai/|.claude/` — author decision 11 item 9 condition (a).\n'
  printf '(The `tracked overlay files in the setup commit: N of N` line is printed by\n'
  printf '`--check-customization` and NOT by a real run; that was found at §4 step 9.)\n'
  printf '\n## DF-P2 — hook executions during the run\n\n'
  printf '`policy-events-*.jsonl` logs in `$TMPDIR` and `/tmp`: **%s before, %s after**, and\n' "$BEFORE_N" "$AFTER_N"
  printf '**%s new or grown**. Detail: `%s`\n\n' "$NEW_OR_GROWN" "${NEW_OR_GROWN_DETAIL:-(none)}"
  printf 'And a **settling sweep %ss later**: %s log(s), **%s new or grown**. An immediate zero and\n' "$SETTLE_SECONDS" "$LATE_N" "$LATE_NEW"
  printf 'a zero after a delay are two different observations, and only the second rules out a hook\n'
  printf 'child that appends just after the runner exits.\n\n'
  printf 'Inventories: `sweep-before.tsv`, `sweep-after.tsv` — by name AND by line count, so a\n'
  printf 'log that existed and GREW is caught as well as one that appeared.\n'
  printf '\n## DF-P3 — the positive control, on the same script sha\n\n'
  printf '`policy-gate.sh` sha `%s` (B7 registered).\n' "$GOT_GATE"
  printf 'deny path `sample-service/pom.xml` -> exit **`%s`**; allow path `…/api/ApiError.kt` -> exit **`%s`**;\n' "$PC_DENY_RC" "$PC_ALLOW_RC"
  printf 'log lines written **`%s`** in `positive-control-policy-events.jsonl`.\n' "$PC_LINES"
  printf '\n## DF-P4 — what the record sees of the tenth file\n\n'
  printf '| | |\n|---|---|\n'
  printf '| `instructionsHash` | `%s` |\n' "$IH"
  printf '| `knowledgeHash` | `%s` |\n' "$KH"
  printf '| `customization` keys | `%s` |\n' "$CUST_KEYS"
  printf '| keys anywhere in the record matching `/hook\\|settings/i` | `%s` |\n' "${HOOKISH:-(none)}"
  printf '| `hooksHash` | `%s` |\n' "$HOOKSHASH"
  printf '\nRecord kept verbatim at `run-record.json`.\n'
  printf '\n*The verdicts are NOT computed here. This file is the measurement; E-024, E-025 and the\n'
  printf 'workbook carry the reading, per §4b — a driver with an opinion is a driver that can be\n'
  printf 'wrong in a place nobody re-derives.*\n'
} > "$RESULT"

echo "run-b10-df: RESULT.md written -> $RESULT"
echo "  DF-P1 rc=$RC tracked='${TRACKED:-?}'"
echo "  DF-P2 new-or-grown policy-events logs: $NEW_OR_GROWN  (changedFiles=$CHG)"
echo "  DF-P3 deny=$PC_DENY_RC allow=$PC_ALLOW_RC lines=$PC_LINES"
echo "  DF-P4 instr=$IH knowledge=$KH hooksHash=$HOOKSHASH keys=$CUST_KEYS"
exit 0
