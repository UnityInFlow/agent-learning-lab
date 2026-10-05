# opencode review — run-b11-deliberate-failure

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20261005T190720Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/b11/run-b11-deliberate-failure.sh
    sha:  10ccdc6b69b8
    dirty: false
  - path: evidence/b11/verify-b11-deliberate-failure.sh
    sha:  4724d96a02e4
    dirty: false
lab_head:        141cf90
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/b11/run-b11-deliberate-failure.sh
  verdict: REJECT
  summary: A control that is supposed to prove the hook's refusal does not leak the file body silently degrades to "passes regardless" when its probe subject lacks the expected syntax — exactly the configuration the artifact exposes via DF_SUBJECT.
  blocking:
    - reason: D4's "no body leaked" check is vacuous when BODY_LINE is empty
      wrong_action: A reader who overrides DF_SUBJECT with a Kotlin file containing only `package` and top-level `val`/`var` declarations (a configuration the script documents as supported — see line 38) will get a green D4 even if the hook dumps the entire file body into its stderr refusal. The artifact's own header claims D4 proves "no body leaked into the refusal", so the result is recorded as evidence of non-leakage when no check was actually performed.
      anchor: "if [[ -n \"$BODY_LINE\" ]] && grep -qF \"$BODY_LINE\" \"$OUT/.last.err\"; then check 4 \"refusal leaked a source line\" \"absent\" \"PRESENT\" else check 4 \"refusal leaked a source line\" \"absent\" \"absent\" fi"
      evidence: evidence/b11/run-b11-deliberate-failure.sh:127-131
  non_blocking:
    - reason: Case F's fixture passes a path to a file that was never created; the case description ("a recorder that is not executable") and the actual condition tested (nonexistent file) are not the same, so the case would still pass if a future refactor loosened the prereq to `[[ -f ]]` and the case no longer exercised the non-executable branch it advertises.
      evidence: evidence/b11/verify-b11-deliberate-failure.sh:14,68
    - reason: The driver records the subject file's sha (SRC_SHA, COPY_SHA) but never gates it against a registered value; only the hook's EXPECT_SHA is pinned. The asymmetry is by design (subject is an input, hook is the integrity boundary) but the rationale is not stated in the artifact, so a reader who notices the gap has nothing to resolve it against.
      evidence: evidence/b11/run-b11-deliberate-failure.sh:48-53,67-68
    - reason: The D4 sub-assertion that the refusal "names the path and the sha" (`sha256` substring on stderr) is a substring match that would also match a debug log line that mentions sha256 incidentally; the test is not as specific as the comment suggests. No wrong action follows because the test is additive to the body-leak check, not a primary control.
      evidence: evidence/b11/run-b11-deliberate-failure.sh:132-133
  disputed:
    - finding: "D5's double-break in verifier case C (where DF_HOOK is already the broken copy, and the driver builds a second broken copy from it) does not affect the outcome"
      why: The line-level pass claims this without weighing it. Case C sets DF_HOOK to the broken copy and DF_EXPECT_SHA to that copy's sha; the driver's sha gate passes, then the driver builds ITS broken copy from the already-broken input by stripping lines 85-91 again. The second strip is a no-op (those lines are already gone) so the resulting "broken" copy is identical to the input — D5 is then run against the original broken copy, not a more-broken one. The line-level pass's claim that this "does not affect the outcome" happens to be true (D1/D2 already drive the FAIL counter), but the construction is wasteful, not load-bearing. Not a finding against the artifact, but the line-level pass overstates the design.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 261s |
| ollama-cloud/glm-5.2 | ok | 294s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| D4 — the refusal carries metadata, not the file body. | 1/1 | L2 |
| verify-b11-deliberate-failure — case list (cases A–G) | 1/1 | L2 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### run-b11-deliberate-failure — §4 step 9 for stop 26 (B11, v1.2), mechanism 3.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header comment, exit-code table, and provenance claims (delivered artifact vs fixture copy, subject is a byte copy not the worktree file) are internally consistent with the code that follows. The four exit codes (0, 2, 3, 4) are each produced by a distinct, traceable code path. The `set -uo pipefail` without `set -e` is correct for a probe that counts assertion failures and reports them rather than aborting on the first.

### THE BREAK: the mismatch branch removed from a COPY, and nothing else.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** `awk 'NR>=85 && NR<=91 {next} {print}' "$HOOK" > "$BROKEN"`

The hardcoded line range 85–91 is pinned indirectly: the EXPECT_SHA gate on lines 48–53 refuses any hook whose content differs from the registered overlay, so the line numbers are stable for the pinned version. The verify script's case C independently confirms the break targets the right clauses (D1 and D2 fail, D3 survives), which would catch a wrong line range in most maintenance scenarios. The subject-copy discipline (copy sha recorded beside the source sha, copy used for mutation) is sound and matches the §6 rationale in the comment.

### D6 — the seed is written by the DELIVERED RECORDER, not by hand.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Using the delivered recorder to seed the store, rather than hand-writing a JSON entry, means the store's key format and entry shape are whatever the recorder actually produces. The two D6 assertions (rc=0 + reason="stored", and `has($p)` in the store) cover both the recorder's exit contract and its write effect.

### D3 — hash match: the read is REFUSED.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The check composes rc, `.decision`, and `.reason` into a single string and compares to `"2 block hash-match"`. The `lastline` helper returns `NOLOG` on a missing or malformed log, which would fail the comparison — a correct failure mode. The log format is sha-pinned through the hook, so the expected values are stable.

### D4 — the refusal carries metadata, not the file body.
**Verdict:** finding
**Failure:** Set `DF_SUBJECT` to a valid Kotlin file whose first matching line under `grep -m1 -E '^[[:space:]]*(class|fun|import) '` does not exist — for example, a file containing only `package com.example` and top-level `val`/`var` declarations. `BODY_LINE` becomes empty. The `[[ -n "$BODY_LINE" ]]` guard on line 127 then takes the else branch and runs `check 4 "refusal leaked a source line" "absent" "absent"`, which always passes regardless of what the hook wrote to stderr. A hook that leaked the entire file body into its refusal message would still get a passing D4 on this assertion. The second D4 check (path + sha256 in stderr) still runs and is unaffected, but the "no body leaked" half of D4 is vacuous. Two reviewers would diverge: one says the default subject is `ShipmentController.kt` and always has a `class` line, the other notes `DF_SUBJECT` is explicitly configurable and nothing rejects a subject without the expected syntax — the control passes when it cannot perform its check, which is the opposite of fail-closed.
**Layer of the implied fix:** L2
**Anchor:** `BODY_LINE="$(grep -m1 -E '^[[:space:]]*(class|fun|import) ' "$SUBJECT" | sed 's/^[[:space:]]*//')"`

### D1 — the file CHANGES, so the entry is now stale.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The stale-maker appends a unique line per rep (`$TAG` + `$i`), guaranteeing the file content differs from the recorded entry. The expected `"0 allow stale-refused"` composes the three observable signals (rc, decision, reason) into one string, which is strict and correct.

### D2 — the entry was DELETED, not ignored: the store loses the key and a repeat call is a miss.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

D2's first check verifies the store dropped the key (`has($p)` → false) after D1's stale-handling. The second check verifies a repeat call is a miss (rc=0, reason="miss"), proving the deletion was real and not merely ignored. The ordering — store check before repeat call — is correct because the repeat call might re-create the entry.

### D5 — THE BREAK, on an identical stale state: a changed file is refused as unchanged.
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

D5 uses an isolated store and log (`BST`, `BLG`), seeds with the delivered recorder, mutates the file, then calls the broken copy. The expected `"2 hash-match"` is the signature of the bug: the broken hook cannot detect the stale entry and falls through to the hash-match path. The verify script's case C confirms this clause fails for the right reason.

### RESULT.md generation and exit
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The RESULT.md table is generated from the clause counters, which are populated by the `check` function. The `shellcheck disable=SC2016` is correct — the backticks in the printf format strings are literal code spans, not command substitution. The exit logic (`FAIL -eq 0` → 0, else → 2) matches the documented exit codes.

### verify-b11-deliberate-failure — the fixture set
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The seven cases (A–G) cover all four exit codes plus two semantic checks (case C's clause identity, case G's reason text). The case G PATH-shim construction is non-obvious but correct: the kernel resolves the shebang `/usr/bin/env bash` using the restricted PATH, finds the symlinked bash, and the driver's first external command (`command -v jq`) fails. The comment documenting two earlier wrong versions of case G is valuable — it shows the fixture was empirically derived, not assumed.

### Case C is the one that matters
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The dual grep for `FAIL D1` and `FAIL D2` ensures the break removed the mismatch branch specifically, not just any branch. The `ok   D3` grep confirms the refusal path is intact, proving the break is minimal. Without case C, a green case A would be worthless — the comment says so and the code enforces it. The grep patterns are brittle (exact spacing), but both scripts are in the same artifact and maintained together.

### Case G must refuse for the jq reason, not by accident
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The grep for `PREREQ: jq is not on PATH` in stderr confirms the exit-4 was for the documented reason, not a coincidental crash. This is the right control — an exit code alone is ambiguous, the reason text disambiguates.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The D1–D6 clauses are behavioral assertions about the hook; the exit codes (0/2/3/4) are the driver's gate. The verify script's cases prove the gates are reachable for the right reasons. No clause restates a gate.
- Which single section would two reviewers diverge on most, and by how much? D4. One reviewer reads `DF_SUBJECT` as configurable and sees the vacuous-pass on empty `BODY_LINE` as a hole; the other reads the default subject as fixed by the sha-gated worktree and sees no live defect. The gap is one full verdict (finding vs no finding) on whether a control that passes when it cannot perform its check is acceptable.
- What did the artifact not say that it needed to say? The D4 check's dependency on the subject file containing a `class`/`fun`/`import` line is not stated. The `[[ -n "$BODY_LINE" ]]` guard silently degrades the assertion to a tautology when the subject lacks such a line, and nothing in the script or comments acknowledges that degradation or rejects it.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### THE REGISTERED PROBE / WHAT IS UNDER TEST / THE SUBJECT FILE
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The sha gate at lines 48–53 is the load-bearing control: the delivered reader is hashed and compared to the pinned `EXPECT_SHA` before anything else happens, exiting 3 on mismatch. The subject is a byte copy (not the worktree file itself), and both shas are recorded in the output for audit. The design rationale — changing a file inside `evidence.local/b11-worktrees/` would rewrite evidence — is sound and the copy/sha-record pattern makes the substitution auditable.

### EXIT CODES
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

All four exit codes (0, 2, 3, 4) are reachable, and the verifier proves each one for the reason it claims. The exit points in the driver are: line 53 (exit 3, sha mismatch), lines 41–46/55/60/66 (exit 4, prereq or I/O failure), line 186 (exit 2, assertion failure), line 187 (exit 0, all pass). No path exits with an unexpected code. `set -uo pipefail` without `-e` is intentional given the `rc=$?` capture pattern in `call()`, and all variables are initialized with defaults or explicitly set before use.

### THE BREAK
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The awk range `NR>=85 && NR<=91` is pinned to the registered hook's sha — if the hook's content changes, the sha check at line 48 refuses before the awk runs. The broken copy's sha is recorded in the output. The same range appears in the verifier, and divergence between the two is caught: case A runs the full driver (including D5 with the driver's broken copy) and would exit 2 if the driver's range removed the wrong lines; case C's reason check would fail if the verifier's range removed the wrong lines. The duplication is a maintenance hazard but not an undetected failure mode.

### Helper functions (payload / call / lastline / check)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`call()` captures rc via `|| rc=$?` with `rc=0` initialized. `lastline()` returns `NOLOG` on empty/invalid log lines, which would cause the corresponding `check` to fail — correct behavior for a hook that doesn't log. `check()` uses string equality, which is appropriate for the pinned hook's log format. The `pipefail` setting without `-e` means pipe failures in `$(...)` assignments are silently ignored, but `DIFF_LINES` and `BODY_LINE` are non-critical (reporting and a negative check respectively), and both are handled defensively downstream.

### D6 / D3 / D4 / D1 / D2 / D5 (main loop)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The clause ordering is dependency-correct: D6 seeds the store → D3 tests the fresh refusal → D4 reads `.last.err` from D3's call (no intervening call overwrites it) → D1 modifies the subject and tests stale-allow → D2 verifies deletion and repeat-miss → D5 is independent with a fresh store and the broken copy. D4's body-leak check reads `.last.err` (stderr); the hook's structured JSON response on stdout (`.last.out`) is not checked for body content, but for a Claude Code PreToolUse hook the refusal message is on stderr by convention, and the hook is pinned by sha so the output channel is known. D5's double-break in verifier case C (where `DF_HOOK` is already the broken copy, and the driver builds a second broken copy from it) does not affect the outcome: D1/D2 use `$HOOK` (single-broken) and fail as expected; D5 uses the double-broken copy but D5's result doesn't change the exit code (D1/D2 already set `FAIL > 0`).

### RESULT.md and exit
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The `} > "$LOGFILE"` redirection at line 182 could silently fail (disk full, permission loss) without affecting the exit code — the driver would exit 0 with no RESULT.md. But this is an infrastructure failure, not an artifact logic defect, and the verifier's case A captures the driver's stdout/stderr independently. The SC2016 disable is correctly justified: the backticks in the printf formats are literal code spans.

### verify-b11-deliberate-failure — case list (cases A–G)
**Verdict:** finding
**Failure:** Case F is described as *"a recorder that is not executable"* but the fixture passes `DF_RECORDER=$SCRATCH/broken-summary-cache.sh.notexec` — a path to a file that was never created. The driver's check `[[ -x "$RECORDER" ]]` (line 45) rejects both nonexistent and non-executable files identically (exit 4), so the case passes today. But if the driver's prereq were refactored to `[[ -f "$RECORDER" ]]` (exists but not necessarily executable) — a plausible refactor that someone might make to give a better error message for a missing file — case F would still pass (the nonexistent file fails `-f` too), while the driver would now silently accept a non-executable recorder and fail later with a confusing error. The verifier would not catch this regression. Two reviewers would disagree on whether case F tests what its description claims: one would say "exit 4 is exit 4, the contract is satisfied," the other would say "the case claims to cover non-executable, and it doesn't."
**Layer of the implied fix:** L2 — the fixture should `touch` the file and `chmod -x` it (or `chmod 644`) so that it exists but is not executable, making the case test the exact condition its description names. The verifier already executes and would enforce the distinction.
**Anchor:** `case F  a recorder that is not executable .............................. 4`

### Case C must fail for the REGISTERED reason / Case G must refuse for the jq reason
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The case C reason check (lines 76–86) verifies that D1 and D2 specifically failed (not just that the driver exited 2 for any reason), and that D3 still passed (the break is minimal). The case G reason check (lines 89–93) verifies the jq-specific prereq message appeared in stderr. Both add specificity beyond the exit code, which is the verifier's stated purpose. The case G PATH-shim construction (lines 69–70) is correct: `/usr/bin/env bash` resolves bash from the overridden PATH, and the driver's first command (`command -v jq`) fails because jq is absent from the shim directory. The comment explaining why two earlier versions of case G failed (macOS ships jq in `/usr/bin`; empty PATH kills the shebang) is the kind of provenance that makes the fixture trustworthy.

### Final report
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not applicable — this is a probe/verifier pair, not a scoring rubric. The probe's six clauses (D1–D6) are behavioral assertions about the delivered hook, not score categories. No clause restates a gate that the verifier already enforces; the verifier proves the probe's exit codes are reachable, which is a different concern.
- **Which single section would you expect two reviewers to diverge on most, and by how much?** The case F description/fixture mismatch. One reviewer reads "exit 4 is exit 4, the contract holds" and moves on; the other reads "the case claims non-executable and tests nonexistent" and flags it. The divergence is one finding vs no finding — a single-section swing — and it is the kind of ambiguity this lab cares about: the case list is prose (L3) describing what the fixtures (L2) prove, and the two don't match on case F.
- **What did the artifact not say that it needed to say?** The driver records the subject file's sha (`SRC_SHA` / `COPY_SHA`) in the output but never checks it against a registered value — only the hook's sha is gated. If the worktree's `ShipmentController.kt` were modified between batch creation and probe run, the probe would test a different subject and record its sha, but nothing would refuse. The worktree is the registered batch's kept worktree, so this is stable in practice, but the artifact doesn't say why the subject's sha is recorded-but-not-gated (the hook's sha gate is the integrity boundary; the subject is an input whose sha is for audit, not admission). A reader who notices the asymmetry has no stated rationale to resolve it.
