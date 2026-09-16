# opencode review — repair-limit

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260916T175132Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/repair-limit.sh
    sha:  fa38193a5093
    dirty: false
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/repair-record.sh
    sha:  7339e63045fa
    dirty: false
  - path: tools/check-run-state.sh
    sha:  d25aff086bfa
    dirty: false
  - path: tools/check-completion-contract.sh
    sha:  cff2cb96c14d
    dirty: false
lab_head:        ed154ba
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: B8 stop-17 hook+checker set (repair-limit.sh, repair-record.sh, tools/check-run-state.sh, tools/check-completion-contract.sh)
  verdict: REJECT
  summary: The four artifacts claim enforcement over scopes they do not execute: repair-limit's named constants bound byte-identical retries rather than repair attempts and silently fail-open without the header's promised audit record; check-run-state validates against the file's self-declared limits rather than the registered3 and 7 and accepts enum values outside the documented set; check-completion-contract duplicates one gate bit as two clauses, vacuously PASSes its authoritative clause on empty deny-list extraction or invalid baseline, and exits 0 with up to four of seven clauses undecidable.
  blocking:
    - reason: repair-limit's fingerprint is sha256 of the command text (lines 63–68), so trivial variation — `./mvnw test` vs `./mvnw test -q` vs `mvn test` — produces distinct fingerprints; each is attempt 1 and never advances, and `totalRepairAttempts` only increments when PRIOR ≥ 1. The named constants MAX_REPAIR_ATTEMPTS_PER_FAILURE=3 and MAX_TOTAL_REPAIR_ATTEMPTS=7 therefore bound byte-identical retries, not repair attempts. A run can issue unbounded failing repairs under argument variation while both limits sit untouched.
      wrong_action: A reviewer trusts the header's named constants to bound the run's repair budget and signs off a run that has, in fact, retried a failing repair ten times under cosmetic argument changes — the budget check returns "well under 7" because no fingerprint ever accumulated.
      anchor: when this call would exceed MAX_REPAIR_ATTEMPTS_PER_FAILURE (3) for the fingerprint or MAX_TOTAL_REPAIR_ATTEMPTS (7) for the run. Those two constants are the build spec's, at businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md:103-104.
      evidence: scratchpad/review/repair-limit.sh:9-10, scratchpad/review/repair-limit.sh:63-68
 - reason: The run-state path is `/tmp/run-state-<basename(CLAUDE_PROJECT_DIR)>.json` (line 54) — the project's directory name, not the run's. Two sequential runs of the same project share the file: run 1 ending at totalRepairAttempts=7 leaves the state file there, and run 2's first repair attempt is blocked on arrival. The header (lines 35–37) explicitly claims the file "lives under $TMPDIR with the run in its own name", contradicting the executed computation.
      wrong_action: A reviewer reads the header's isolation claim and trusts run 2 starts with a clean budget; in fact run 2's first failing command is refused the moment it arrives, and run 1's audit trail is overwritten in place.
      anchor: .agent/run-state.json stays the documented production path and is what the schema is named for; here the same file lives under $TMPDIR with the run in its own name.
      evidence: scratchpad/review/repair-limit.sh:35-37, scratchpad/review/repair-limit.sh:54
    - reason: repair-limit's header promises fail-open auditability (lines 46–48: "every internal failure below is fail-OPEN and is recorded as its own decision"), but line 116 `command -v jq >/dev/null 2>&1 || exit 0` exits silently with no `hookExecutions` entry written when jq is absent. The same shape exists on the allow-branch write (lines 167–174): if jq fails there, the failed `jq ... && mv ...` is followed by unconditional `exit 0`, counters stay stale, and the call still proceeds. A command can retry indefinitely with PRIOR never advancing, unrecorded.
      wrong_action: A reader believes a failed limiter is afterwards distinguishable from one that never ran, by inspecting `hookExecutions`; in fact the absence of jq looks identical to a successful allow path.
      anchor: any other   NON-BLOCKING ERROR; THE CALL PROCEEDS. So every internal failure below is fail-OPEN and is recorded as its own decision, so that a run whose limiter silently died is afterwards distinguishable from one that allowed everything.
      evidence: scratchpad/review/repair-limit.sh:46-48, scratchpad/review/repair-limit.sh:116, scratchpad/review/repair-limit.sh:167-174
    - reason: check-run-state validates the .decision enum with `inside("allow block success error")` (line 86). jq treats strings as arrays of codepoints, so any input whose every codepoint appears somewhere in "allow block success error" passes — `"allo"`, `"aloe"`, `"allow block"`, `"oke"`, etc. The documented enum is `allow | block | success | error`; the checker accepts values outside it.
      wrong_action: A reviewer hands the checker a state file with a typo'd or truncated decision (e.g. `"allo"` from a half-written record) and gets exit 0 "valid against schema b8-v1.1", then trusts subsequent decisions derived from the same file.
      anchor: if jq -e '[.hookExecutions[] | select((.decision // "") | inside("allow block success error") | not)] | length > 0' "$FILE" >/dev/null 2>&1; then
      evidence: tools/check-run-state.sh:86
    - reason: check-run-state reads its ceilings from the file's own `.limits` (lines 76, 79), with fallbacks of 3 and 7 only when the field is absent. A state file declaring `{"limits":{"maxTotalRepairAttempts":1000},"totalRepairAttempts":999}` exits 0 as valid, because the "limit did not hold" check measures against the file's self-declared 1000, not the build spec's 7. The whole point of the checker is to enforce the registered schema; instead the schema's limits are whatever the file says they are.
      wrong_action: A reader relies on this checker as the guarantee that the registered constants held; in fact a tampered or mis-authored file passes the very check meant to catch tampering.
      anchor: if jq -e '(.limits.maxTotalRepairAttempts // 7) as $m | (.totalRepairAttempts // 0) > $m' "$FILE" >/dev/null 2>&1; then
      evidence: tools/check-run-state.sh:76, tools/check-run-state.sh:79
    - reason: check-completion-contract clauses 2 ("build passed") and 3 ("required tests passed") are both driven off the single `--evaluator-exit` value (lines 68–79): exit 0 ⇒ both PASS, non-zero ⇒ both FAIL. There is no input that makes them diverge, yet both are printed as independently decided and each increments DECIDED. At scoring time on gate-passing worktrees the evaluator exit is 0 by construction, so both clauses are constants carrying no information — the exact defect the v2 rubric was written to remove (CLAUDE.md: "restating a gate is a constant across everything it can score").
      wrong_action: A reader treats the printed "decidable clauses: N of 7" headline as evidence of independent verification; in fact two of those N are the same single bit, and the scoring summary overstates fulfillment.
      anchor: if [[ "$EVAL_EXIT" == "0" ]]; then
        pass 2 "build passed"          "evaluator exit 0"
        pass 3 "required tests passed" "evaluator exit 0"
      evidence: tools/check-completion-contract.sh:68-79
    - reason: check-completion-contract discards stderr from `git diff "$BASELINE" -- .` (line 110, also line 90). With an invalid baseline (typo, missing ref, dangling branch), the command fails, CHANGED becomes empty, and clauses 5 ("no critical findings") and 6 ("no forbidden files changed") report PASS while no comparison with the baseline occurred.
      wrong_action: A reviewer invokes the script with a wrong baseline SHA and trusts PASS verdicts on the critical-findings and forbidden-files clauses; in fact neither clause was evaluated.
      anchor: CHANGED="$(git -C "$WORKTREE" diff --name-only "$BASELINE" -- . 2>/dev/null)"
      evidence: tools/check-completion-contract.sh:90, tools/check-completion-contract.sh:110
    - reason: check-completion-contract extracts the deny list from protected-paths.yaml via `sed -n '/^deny:/,/^[a-z]/p' | sed -n 's/^  - "\(.*\)".*/\1/p'` (line 123), which silently yields zero patterns if the YAML is indented differently or uses unquoted scalars. With zero patterns the outer `while IFS= read -r pat` iterates zero times, HITS stays empty, and clause 6 reports `pass 6 … "no changed path matches the deny list"` while the script read nothing. The header (line 102) calls clause 6 the one this script is "genuinely authoritative on".
      wrong_action: A reviewer treats clause 6 PASS as proof the deny list was checked; in fact the checker extracted an empty list and vacuously passed, even though forbidden paths may have changed.
      anchor: pass 6 "no forbidden files changed" "no changed path matches the deny list"
      evidence: tools/check-completion-contract.sh:102, tools/check-completion-contract.sh:110-128
    - reason: check-completion-contract exits 0 when every DECIDABLE clause passes (lines 154–155). With `--evaluator-exit 0` and `--summary <file>` but no `--baseline`, clauses 1, 4, 5, 6 are UNDECIDABLE and the script still returns 0. A downstream gate keying on exit 0 records "§10.6 contract satisfied" while four of seven clauses were never evaluated — the exact failure mode the header warns against (lines 22–25: "A checker that green-ticked those would be a control reporting success over a scope smaller than it claims").
      wrong_action: A downstream automation records the worktree's §10.6 completion contract as satisfied; in fact four of seven clauses were never decided, and the exit code cannot distinguish "no decidable clause failed" from "all seven clauses met".
      anchor: [[ "$DECIDED" -eq 0 ]]; then
        echo "  nothing could be decided — this is NOT a pass" >&2
        exit 2
      [[ "$FAILED" -eq 0 ]] || exit 1
      exit 0
      evidence: tools/check-completion-contract.sh:22-25, tools/check-completion-contract.sh:148-155
    - reason: The run-state file is read-modify-written by both repair-limit and repair-record without any locking (repair-limit.sh:144-174, repair-record.sh:54-63). Two concurrent bash calls race: call A's PostToolUse invocation deletes the fingerprint that call B's PreToolUse update just inserted, so the next retry is treated as attempt 1 even though the most recent execution failed. Repeated overlap can prevent the limit from firing at all.
      wrong_action: A reader trusts that the limiter's view of "what counts as a repeated failing attempt" reflects the actual sequence of events; in fact concurrent writes can lose increments and the file's record drifts away from what happened.
      anchor: jq --arg ts "$(now)" --arg fp "$FP" --arg cmd "$CMD" \
         '.updatedAt=$ts
          | .repairAttemptsByFingerprint = (.repairAttemptsByFingerprint | del(.[$fp]))
      evidence: scratchpad/review/repair-record.sh:54-63, scratchpad/review/repair-limit.sh:144-174
    - reason: repair-record's fingerprint() (lines 36–43) is a deliberate copy of repair-limit's; the header says "verify-repair-limit.sh asserts the two agree", but nothing executes that verification on the hook path. If one rule is edited and not the other, the limiter increments key A while the oracle clears key B, and `repairAttemptsByFingerprint` accumulates monotonically until every fingerprint eventually blocks. The "success oracle" silently does nothing on every call.
      wrong_action: A reader trusts that a successful command clears the limiter's counter for that command; in fact a drifted rule means no counter ever matches its clear, and the limiter over-blocks while the recorder looks healthy.
      anchor: Byte-identical to repair-limit.sh's. A second, drifting copy of the rule is a rule that can disagree with the one it claims to mirror; verify-repair-limit.sh asserts the two agree.
      evidence: scratchpad/review/repair-record.sh:36-43
  non_blocking:
    - reason: check-run-state's `want_type` (lines 30–35) accepts any `number` type, so `totalRepairAttempts: 2.5` passes the type check and the `< 0` / `> $m` invariant checks. The `try ... catch "missing"` branch on line 32 is dead (jq yields `null`, not an error, for absent fields), but the function still rejects absent fields because `null` ≠ `string`/`number`. Style and minor robustness, not a behavioural break.
      evidence: tools/check-run-state.sh:30-35, tools/check-run-state.sh:38-50
    - reason: repair-record's success predicate is "PostToolUse fired, therefore exit 0" (header lines 17–20), not task-success. `./mvnw test -Dtest=DoesNotExist` runs zero tests and exits 0, clearing the counter for a command that did not repair anything. The header explicitly defends the limitation, so it is an acknowledged gap rather than a hidden one.
      evidence: scratchpad/review/repair-record.sh:17-20
 - reason: The init_state bootstrap writes the full schema unconditionally on first touch (lines 74–100) and is invoked only when the state file is absent (line 117). A second run that finds the leftover file therefore reuses the first run's counters AND will not pick up a new `handoff.fromAgent`/`toAgent` even when the user changes agents between runs. Compounds the run-identity defect above but does not by itself silently lose data.
      evidence: scratchpad/review/repair-limit.sh:74-100, scratchpad/review/repair-limit.sh:117
  disputed:
    - finding: "Start with an otherwise readable state file whose `hookExecutions` value is `{}` instead of an array. The `PRIOR` and `TOTAL` reads succeed, but the allow-path `jq` update fails at `.hookExecutions += [...]` …"
 why: init_state (lines 74–100) writes `"hookExecutions": []` and both hooks only modify the field via `+=`, so a `{}` value cannot arise from the artifacts' own code paths — only from external intervention or hand-editing. The artifact itself never produces that state in normal operation. The related defect — silent fail-open when jq fails — is real and is named separately under blocking.
 needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 66s |
| ollama-cloud/deepseek-v4-pro | ok | 187s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/repair-limit.sh | 1/2 | L2 |
| /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/repair-record.sh | 1/2 | L2 |
| tools/check-run-state.sh | 1/2 | L2 |
| tools/check-completion-contract.sh | 1/2 | L2 |
| Cross-cutting | 1/2 | L2 |
| repair-limit.sh | 1/2 | L3 |
| repair-record.sh | 1/2 | L3 |
| check-run-state.sh | 1/2 | L2 |
| check-completion-contract.sh | 1/2 | L3 |

> **Every row above is 1/2, and no two families used the same heading.**
> Recurrence is counted per HEADING TEXT, so one defect filed under two different
> headings appears as two lonely rows rather than one corroborated one. Before treating
> any row as a single lens, read the runs against each other and check whether they are
> describing the same thing.


---

## Run 1 of 2 — codex

### /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/repair-limit.sh
**Verdict:** finding
**Failure:** Start with an otherwise readable state file whose `hookExecutions` value is `{}` instead of an array. The `PRIOR` and `TOTAL` reads succeed, but the allow-path `jq` update fails at `.hookExecutions += [...]`; because the failed `jq ... && mv ...` is followed by unconditional `exit 0`, every invocation proceeds without incrementing either counter. The same failing command can then run indefinitely, while one reviewer may regard the documented fail-open behavior as satisfied and another may regard the absence of the promised `decision":"error"` record as a limiter failure.
**Layer of the implied fix:** L2
**Anchor:** jq --arg ts "$(now)" --arg fp "$FP" --arg cmd "$CMD" --arg r "$REASON" \
   --argjson attempt "$ATTEMPT" --argjson total "$NEW_TOTAL" \
   '.updatedAt=$ts
    | .repairAttemptsByFingerprint[$fp] = $attempt
    | .totalRepairAttempts = $total
    | .lastAttempt = {"ts":$ts,"fingerprint":$fp,"command":$cmd,"attempt":$attempt}
    | .hookExecutions += [{"hook":"repair-limit","ts":$ts,"decision":"allow","fingerprint":$fp,"reason":$r}]' \
   "$STATE" > "$tmp" 2>/dev/null && mv "$tmp" "$STATE"
exit 0

### /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/7275b73d-bbbf-4a95-a875-e1abed6c20cd/scratchpad/review/repair-record.sh
**Verdict:** finding
**Failure:** Run two identical Bash calls concurrently against the same state file: call A starts and later succeeds, while call B starts afterward and fails. B's PreToolUse update records an outstanding attempt, but A's delayed PostToolUse invocation then deletes that fingerprint. The next retry is treated as attempt 1 even though the most recent execution failed. Reviewers can therefore reconstruct opposite states—“cleared by success” versus “failure still outstanding”—from the same event ordering, and repeated overlap can prevent the limit from firing.
**Layer of the implied fix:** L2
**Anchor:** | .repairAttemptsByFingerprint = (.repairAttemptsByFingerprint | del(.[$fp]))

### tools/check-run-state.sh
**Verdict:** finding
**Failure:** Give the checker a state whose hook execution has `"decision":"allo"`. In jq, `"allo" | inside("allow block success error")` is true because it is a substring, so the checker exits 0 even though `allo` is not one of the documented enum values. One reviewer applying the printed enum rejects the file; the executing checker accepts it.
**Layer of the implied fix:** L2
**Anchor:** if jq -e '[.hookExecutions[] | select((.decision // "") | inside("allow block success error") | not)] | length > 0' "$FILE" >/dev/null 2>&1; then

### tools/check-completion-contract.sh
**Verdict:** finding
**Failure:** Invoke the script with `--baseline does-not-exist` on a worktree that changed a denied path. Both `git diff` commands fail, but stderr is discarded: the clause-5 pipeline becomes a zero count and clause 6 receives an empty `CHANGED` value. The script can report PASS for both “no critical findings” and “no forbidden files changed,” then exit 0 if the other supplied decidable inputs pass, although no comparison with the baseline occurred.
**Layer of the implied fix:** L2
**Anchor:** CHANGED="$(git -C "$WORKTREE" diff --name-only "$BASELINE" -- . 2>/dev/null)"

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is present, so none duplicates a pass/fail gate. Reviewers would diverge most on `tools/check-completion-contract.sh`: with an invalid baseline, one follows its two emitted PASS results while another marks clauses 5 and 6 undecidable or failed—a two-clause divergence that can also change the process exit from 0 to nonzero. The artifacts needed to state and enforce concurrency/serialization requirements for the shared run-state file and needed to establish that a supplied baseline resolves successfully before any diff-derived clause can pass.
**Layer of the implied fix:** L2
**Anchor:** STATE="${AGENT_RUN_STATE_FILE:-${AGENT_RUN_STATE_DIR:-${TMPDIR:-/tmp}}/run-state-$(basename "${CLAUDE_PROJECT_DIR:-unknown}").json}"


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### repair-limit.sh
**Verdict:** finding
**Failure:** A run that issues a failing command with trivial variation each retry never trips either limit. `./mvnw test` (fails), `./mvnw test -q` (fails), `./mvnw test --no-transfer-progress` (fails), `mvn test` (fails), and so on: each is a distinct fingerprint, so `repairAttemptsByFingerprint[$fp]` is written to 1 on first sight and never advances, and `totalRepairAttempts` never increments (line 135 increments only when `PRIOR >= 1`). The run can issue unbounded failing repair attempts while both `MAX_REPAIR_ATTEMPTS_PER_FAILURE=3` and `MAX_TOTAL_REPAIR_ATTEMPTS=7` sit untouched. Reviewer A reads the spec constants as bounding *repairs per failure / per run* and concludes the control enforces a much weaker quantity — byte-identical retries — than the constant names promise; reviewer B points to the fingerprint comment's own `echo 1`/`echo 2` example and calls it working-as-intended. The header defends the fingerprint choice without ever stating that the two named ceilings are thereby trivially bypassable.
**Layer of the implied fix:** L3
**Anchor:** `when this call would exceed MAX_REPAIR_ATTEMPTS_PER_FAILURE (3) for the fingerprint or MAX_TOTAL_REPAIR_ATTEMPTS (7) for the run.`

The same block, two further defects:

- **No run identity, no reset.** `init_state` runs only when the file is absent (line 117). A second run of the same project reuses the leftover `/tmp/run-state-<project>.json` with the first run's `totalRepairAttempts` intact, and `basename "${CLAUDE_PROJECT_DIR}"` is the *project* name, not the run name — so line 36's claim "the same file lives under $TMPDIR with the run in its own name" is false. Concrete: run 1 ends at `totalRepairAttempts=7`; run 2's first repair attempt is blocked on arrival. Two sequential runs contaminate one another's budget. Implied fix: L2 (scope or clear the state per run, which executes at start).
- **Fail-open without record, contradicting the header.** Line 116 exits 0 silently when `jq` is missing, writing no `hookExecutions` entry — the exact "indistinguishable from a hook that never ran" state the header (lines 46–48) promises to prevent. The allow-branch write (lines 167–174) has the same shape: if `jq` fails there, the counter stays stale and the call still proceeds, so a command can be retried indefinitely with `PRIOR` never advancing, unrecorded. Implied fix: L2.

### repair-record.sh
**Verdict:** finding
**Failure:** A second, drifting copy of the fingerprint rule. The comment (lines 36–37) says the two copies must stay byte-identical and that `verify-repair-limit.sh` asserts agreement — but that verification is a test you must remember to run, and nothing executes it on the hook path. Concrete diff: someone edits `repair-limit.sh`'s `fingerprint()` (say, drops the `cut -c1-16`, or adds lower-casing) and not this one's. `repair-limit` then increments key *A* while `repair-record` clears key *B*, so no entry ever matches — `repairAttemptsByFingerprint` accumulates monotonically and every fingerprint eventually blocks, with the "success oracle" silently doing nothing. The divergence is clean: the limiter and the oracle stop describing the same world and nothing fails loudly.
**Layer of the implied fix:** L3
**Anchor:** `Byte-identical to repair-limit.sh's. A second, drifting copy of the rule is a rule that can disagree with the one it claims to mirror; verify-repair-limit.sh asserts the two agree.`

Secondary: the success predicate is exit-0, not task-success. Lines 17–20 assert "if this hook fired for a command, that command succeeded", but the probe only established that non-zero exits don't fire PostToolUse. `./mvnw test -Dtest=DoesNotExist` runs zero tests and exits 0 — PostToolUse fires, `repair-record` clears the fingerprint, and the counter resets for a command that did not repair anything. "Exit 0" is being used as "the failure is resolved", which is not what exit 0 means.

### check-run-state.sh
**Verdict:** finding
**Failure:** The checker trusts the file's own `.limits` as the ceiling instead of pinning the registered constants. Lines 76 and 79 read `$m` from `.limits.maxRepairAttemptsPerFailure` and `.limits.maxTotalRepairAttempts`, falling back to 3 and 7 only when the field is absent. A state file carrying `{"limits":{"maxTotalRepairAttempts":1000},"totalRepairAttempts":999}` exits 0 as "valid against schema b8-v1.1", because the checker measures the counter against the file's self-declared limit of 1000, not the spec's 7. The whole point of this checker is to enforce "the limit did not hold" against the registered schema — but the limit is data inside the same L3 file it is validating, so the file sets its own pass bar. Reviewer A says the checker's job is structural-invariant validation and the limits are part of the schema; reviewer B says the registered constants are 3 and 7 per the build spec and the checker must pin them, otherwise the enforcement is circular.
**Layer of the implied fix:** L2
**Anchor:** `(.limits.maxTotalRepairAttempts // 7) as $m | (.totalRepairAttempts // 0) > $m`

Minor, same block: `want_type` accepts any `number` type, so `totalRepairAttempts: 2.5` passes both the type check and the `< 0` / `> $m` invariant checks; and the `catch "missing"` branch at line 32 is dead — jq yields `null` (not an error) for an absent field, so the "found missing" message can never appear.

### check-completion-contract.sh
**Verdict:** finding
**Failure:** Clauses 2 and 3 are the same single bit reported twice, and both restate a gate the scoring path has already passed. Lines 68–79 drive "build passed" and "required tests passed" off the one `--evaluator-exit` value: exit 0 ⇒ both PASS, non-zero ⇒ both FAIL. There is no input that makes them diverge, yet they are printed as two independently-decided clauses and each increments `DECIDED`, inflating "decidable clauses: N of 7". Because this checker runs at scoring time on gate-passing worktrees, `--evaluator-exit` is 0 by construction, so clauses 2 and 3 are constants carrying no information — the precise defect the v2 rubric removed ("restating a gate is a constant across everything it can score"). A scored worktree always reports 2 PASS and 3 PASS, making the completion contract look more fulfilled than it is.
**Layer of the implied fix:** L3
**Anchor:** `pass 2 "build passed"          "evaluator exit 0"` / `pass 3 "required tests passed" "evaluator exit 0"`

Two further defects in the same file:

- **Empty deny-list ⇒ false PASS on the one "authoritative" clause.** Lines 110–124 extract the deny list with `sed -n '/^deny:/,/^[a-z]/p'` plus a two-space, double-quoted scalar assumption. If `protected-paths.yaml` formats `deny:` with a different indent or unquoted scalars, extraction yields zero patterns, `HITS` stays empty, and line 128 reports `pass 6 … "no changed path matches the deny list"` — a green tick while the checker read nothing. Nothing checks the extracted list is non-empty. Implied fix: L2.
- **Exit 0 with three of seven clauses UNDECIDABLE.** With no `--baseline` and no `--summary`, clauses 1, 4, 5, 6 are `undec` and 2, 3, 7 decidable; if those pass, the script exits 0. A downstream gate keying on the exit code records "§10.6 contract satisfied" while four of the seven clauses were never evaluated. The header's own warning (lines 22–25) names "reporting success over a scope smaller than it claims" as the house failure mode, and the exit code does exactly that for any consumer that treats 0 as "contract met". Implied fix: L3.

### Cross-cutting
- **Duplicate pass/fail gate:** `check-completion-contract.sh` clauses 2 and 3 both duplicate the evaluator's exit code (Decision D / `check-run-gate.sh`), and duplicate each other — a single bit rendered as two decided clauses. Separately, the registered constants 3 and 7 appear in `repair-limit.sh` (lines 51–52) and again, unpinned, in `check-run-state.sh`'s fallback (lines 76, 79), so the "schema limits" are self-asserted rather than compared to the build spec.
- **Most divergence:** `repair-limit.sh` — the definition of "repair attempt" (identical fingerprint vs actual failure). The header both acknowledges and defends the substitution, so a faithful reader scores it working-as-intended while another reads `MAX_TOTAL_REPAIR_ATTEMPTS=7` as effectively void against argument-level variation. Expect the two readers to disagree by the full weight of the total-limit guarantee.
- **Not said:** (a) nothing states how a *new run* is isolated from a prior run's counters — there is no run identifier and no reset, yet the file is claimed to be "the run in its own name"; (b) the checker never pins 3 and 7, so the schema's limits are whatever the file says they are; (c) no exit-code contract tells a downstream gate what "0" means when clauses are undecidable, so "no decidable clause failed" and "§10.6 contract met" are conflated.
