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
reviewed_utc:    20261005T195117Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: evidence/b11/run-b11-deliberate-failure.sh
    sha:  174ec1ce9668
    dirty: true
  - path: evidence/b11/verify-b11-deliberate-failure.sh
    sha:  3396d5705077
    dirty: true
lab_head:        85aa432
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: evidence/b11/run-b11-deliberate-failure.sh
  verdict: ACCEPT
  summary: The probe + verifier pair correctly tests the file-summary cache mechanism for the current sha-pinned hook, with all four exit codes (0, 2, 3, 4) reachable and proven by named cases (A→0, C→2, B/K→3, D/E/F/G/H→4); the D4 coverage gap and the one-line body-leak check are real but non-blocking limitations.
  blocking: []
  non_blocking:
    - reason: D4's failure path is unexercised — the verifier has no case that expects D4 to fail. Case C asserts D1/D2 fail and D3 pass, but not D4. An inverted D4 check (always reporting "absent") would not be caught: case C would still exit 2 via D1/D2, and case A would still exit 0 because the delivered hook doesn't leak.
      evidence: evidence/b11/verify-b11-deliberate-failure.sh:126-136
    - reason: D4's body-leak check greps for exactly one line (BODY_LINE, the first class/fun/val/var match). A refusal that leaked a different body line would not be caught. The check name "refusal leaked a source line" is ambiguous between "any source line" and "this specific line".
      evidence: evidence/b11/run-b11-deliberate-failure.sh:162-166
    - reason: The break (awk 'NR>=85 && NR<=91') is line-bounded but nothing executes to verify that lines 85-91 of the registered hook actually contain the mismatch branch. The sha gate pins content, but the line numbers are hardcoded and could drift from the mismatch branch's actual location if the hook is re-registered with a new sha.
      evidence: evidence/b11/run-b11-deliberate-failure.sh:63
    - reason: The header's exit-4 prerequisite list names jq, the worktree, the subject file, and the recorder, but not shasum (checked at line 45, same exit code). Documentation incompleteness, not a wrong answer.
      evidence: evidence/b11/run-b11-deliberate-failure.sh:7,45
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 336s |
| ollama-cloud/glm-5.2 | ok | 239s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Case C must fail for the REGISTERED reason, not for any reason | 1/1 | L2 |
| THE BREAK (lines 61-66) | 1/1 | L3 |
| Subject pinning and BODY_LINE vacuity gate (lines 68-105) | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### EXIT CODES
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The four exit codes (0, 2, 3, 4) are documented with their reasons, and every one is proven reachable by the verifier: 0 by case A, 2 by case C, 3 by cases B and K, 4 by cases D/E/F/G/H. The two distinct exit-3 triggers (hook sha mismatch and subject sha mismatch) are both exercised. The header's parenthetical prerequisite list omits `shasum` (checked at line 45, exits 4), but the exit code is correct regardless of which prerequisite is missing, so no wrong answer results.

### THE BREAK
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The break is line-bounded (`NR>=85 && NR<=91`) against a hook whose sha is gated to the registered value at lines 51-56. If the hook moves, the probe refuses at exit 3 before constructing the broken copy, so the line numbers are pinned by the sha gate. The broken copy's sha is reported in RESULT.md but not gated; this is acceptable because the copy is derived deterministically from the sha-gated original via a fixed awk command.

### THE SUBJECT IS PINNED TOO
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Two gates: copy matches source (lines 76-79) and source matches registered sha (lines 86-90). Both exit 3 on mismatch. Case K proves the second gate. The first gate (copy != source) is a disk-error path with no fixture case, but it is not a property that can be provoked without simulating cp failure, and its exit code is correct. The self-correction comment at lines 80-84 (a prior version claimed a default that did not exist) is honest and the current code has the real default.

### AN EMPTY BODY_LINE MAKES D4 VACUOUS, AND THAT IS A REFUSAL, NOT A PASS
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The emptiness check at lines 102-105 refuses exit 4 before D4 runs, and case H proves it. The case-H comment (lines 101-104) correctly identifies the interaction with the subject-sha gate: an unpinned substitute would be refused at exit 3 before the D4-vacuity prerequisite is reached, so case H pins its own sha deliberately. The `BODY_LINE` extraction regex `^[[:space:]]*(class|fun|val|var) ` correctly excludes `package`, `import`, and `vararg` (no space after `var` in `vararg`).

### The main loop — D1 through D6
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The six clauses are distinct properties, checked in sequence with isolated state for D5. D4's body-leak check greps for the first `class`/`fun`/`val`/`var` line only; a hook that leaked a *different* body line would not be caught. But D4 runs exclusively against the sha-gated delivered hook (D3's refusal), whose refusal format is fixed by the sha gate — a hook with a different format would be refused at exit 3 before D4 executes. So the one-line check is sufficient for the hook this probe can measure. The `[[ -n "$BODY_LINE" ]]` guard at line 162 is dead code (emptiness is refused at line 102), but it is harmless defensive code and does not produce a wrong answer.

### Case C must fail for the REGISTERED reason, not for any reason
**Verdict:** finding
**Failure:** Case C checks that D1 and D2 failed and D3 passed, but does not assert that D4 and D6 still pass. Consider a registered hook whose lines 85-91 contain not only the mismatch branch but also a line that suppresses a debug `cat "$file"` away from stderr. Removing lines 85-91 breaks the mismatch handling (D1/D2 fail, as expected) AND causes the debug cat to leak the file body into the refusal stderr (D4 fails). The verifier reports "case C failed on D1 and D2" and "case C still passed D3" — both true — and a reviewer reading the output concludes the break is minimal, that only D1 and D2 are affected. But D4 also failed, and the verifier never names it. The comment at line 117 says "names which clause" — if D4 is also broken, the name is incomplete. Two reviewers diverge: one says D3 passing (correct `decision` and `reason` strings) proves the refusal path is intact and covers D4 implicitly; the other says D3 checks two JSON fields while D4 checks whether file body text appears in stderr — a break that appends body to stderr while preserving the decision/reason fields would fail D4 but pass D3, and the verifier would not catch it.
**Layer of the implied fix:** L2
**Anchor:** `if grep -q 'FAIL D1' "$SCRATCH/C.out" && grep -q 'FAIL D2' "$SCRATCH/C.out"; then` … `if grep -q 'ok   D3' "$SCRATCH/C.out"; then  # D3 only`

### Cases A, B, D, E, F, G, H, K
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Case F was corrected (the old version pointed at a path that was never created; now it creates the file and removes the exec bit, testing the sentence it claims). Case G's PATH-shim approach is fragile — `dirname` is not on the shimmed PATH, so line 30's command substitution fails silently before the jq check is reached — but the script still reaches the jq prerequisite and exits 4 for the right reason, and the comment documents two prior wrong versions of this case. Case K exercises the subject-sha gate and checks the error names both shas. Case H pins its own sha to avoid being refused at the subject-sha gate before reaching the D4-vacuity check. All cases behave as specified.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? D6 (recorder stores the entry) is causally upstream of D3 (fresh entry refused) — if the recorder fails, D3 would be a miss rather than a refusal. But D6 is a functionality check (the recorder actually stores), while the gate at line 48 checks only existence and executability. They are different controls at different layers, not a duplication.
- Which single section would two reviewers diverge on most, and by how much? The case C minimality block. The gap is narrow: D3 passing is a strong proxy for the refusal path being intact, and the break is line-bounded against a sha-gated hook, so the scenario requires lines 85-91 to affect both the mismatch branch and the refusal stderr format — implausible but not proven impossible. A careful reviewer would split roughly 60/40 on whether this is a real gap or an over-read of the verifier's scope.
- What did the artifact not say that it needed to say? The header's exit-4 prerequisite list names jq, the worktree, the subject file, and the recorder, but not `shasum` (checked at line 45, same exit code). This is documentation incompleteness, not a wrong answer — the exit code is correct regardless of which prerequisite is missing.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### THE REGISTERED PROBE (header, lines 1-27)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The header documents four exit codes (0, 2, 3, 4) and each is proved reachable by the verifier (case A→0, C→2, B/K→3, D/E/F/G/H→4). The distinction between "hook sha mismatch" and "subject moved" both mapping to exit 3 is sound — both are refusals, and the verifier proves both paths independently (case B for the hook, case K for the subject).

### Prerequisites and sha gates (lines 28-56)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The reader-sha gate (lines 51-56) is L2: it executes and exits 3 on mismatch. The verifier's case B proves it refuses. The prerequisite checks (jq, shasum, worktree, hook, recorder, subject) each have a verifier case (G, D, E, F, H). The `set -uo pipefail` without `-e` is intentional — every critical operation has an explicit `|| exit 4`, and the `call` function captures rc manually. No gap.

### THE BREAK (lines 61-66)
**Verdict:** finding
**Failure:** The break is `awk 'NR>=85 && NR<=91 {next} {print}'` — a line-number range hardcoded in both the driver (line 63) and the verifier (line 61). The sha gate pins the hook's *content*, so for the currently registered sha the line numbers are deterministic. But nothing executes to verify that lines 85-91 of the registered hook actually contain the mismatch branch. The failure scenario: the hook is re-registered with a new `DF_EXPECT_SHA` after an edit that shifted the mismatch branch to, say, lines 88-94. The sha gate passes (sha was updated), the break now removes lines 85-91 which are a *different* part of the hook, and D5's expected `"2 hash-match"` either fails (caught by case A) or passes by coincidence if the removed code also routes to the match path. The verifier's case A is a partial L2 mitigation — it would catch most wrong breaks — but a coincidental D5 pass under a wrong break is invisible to every case. Two reviewers diverge: one says "the sha pins the content so the line numbers are fixed," the other says "the sha and the line numbers are independent hardcoded values and nothing checks they agree."
**Layer of the implied fix:** L3
**Anchor:** `# ===== THE BREAK: the mismatch branch removed from a COPY, and nothing else.`

### Subject pinning and BODY_LINE vacuity gate (lines 68-105)
**Verdict:** finding
**Failure:** D4's first check (line 162-166) is named `"refusal leaked a source line"` but it tests exactly one line — `BODY_LINE`, the first `class`/`fun`/`val`/`var` match in the subject. A refusal that leaked a *different* body line (e.g. a function signature that is not the first match) would satisfy the check as "absent" while a source line *did* leak. The check's description promises generality it does not deliver. Concrete scenario: a future hook version whose refusal message includes `fun confirm(...)` (the second body line, not the first) — D4 reports "absent" (pass), the leak is undetected, and the clause named "refusal leaked a source line" is green. Compounding this: the verifier never proves D4 can fail. Case C asserts `FAIL D1` and `FAIL D2` and `ok D3` but does not check D4 at all, and no verifier case constructs a hook that leaks a body line. If D4's check logic were inverted (reporting "absent" when a line *is* present), no verifier case would catch it — case C would still exit 2 via D1/D2, and case A would still exit 0 because the delivered hook doesn't leak. D4's failure path is unexercised.
**Layer of the implied fix:** L3
**Anchor:** `check 4 "refusal leaked a source line" "absent" "PRESENT"`

### Helpers and check function (lines 107-132)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`lastline` with `pipefail` and the `&&`/`||` chain is correct: an empty log file or a jq parse failure both yield `NOLOG`, which makes downstream string comparisons fail (not pass). The `check` function's string-equality comparison is strict — a missing log field produces `NOLOG` and fails the assertion. The array indexing (`${c:1}` → 1-6) matches the `check N` call sites.

### The repetition loop — D6, D3, D4, D1, D2, D5 (lines 141-198)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The clause ordering is logically sound: D6 seeds via the delivered recorder, D3 proves a fresh entry is refused, D4 checks the refusal content, D1 mutates the file and proves stale-allow, D2 proves the key was deleted (not ignored), D5 demonstrates the break on an isolated broken store. The `.last.err` overwrite sequence is safe — D4 reads D3's output before D1 overwrites it. D5 uses a separate store/log/subject, so no cross-contamination. The `BODY_LINE` non-empty guard at line 162 is now redundant (guaranteed by the gate at 102-105) but harmless.

### RESULT.md and final exit (lines 200-225)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The final `[[ "$FAIL" -eq 0 ]] || exit 2` is the correct gate: any clause failure across any repetition produces exit 2. The SC2016 disable is correctly scoped — the backticks in the printf format strings are literal code spans, not command substitution. The per-clause table (lines 215-218) uses the same array indices (1-6) that the loop initializes.

### Verifier fixture set — cases A-H, K (lines 1-114)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Each exit code is proved reachable for the reason it claims. Case G's PATH shim (symlink bash into a bare directory) correctly reaches the jq prerequisite without dying at the shebang — the comment documents two failed attempts that the running of the case itself caught. Case F was amended to create the file and remove the exec bit (matching its sentence). Case H pins its own sha before testing the vacuous-body gate, correctly avoiding preemption by the subject-sha gate. Case K appends one byte and proves the subject-sha refusal names both shas. The cases earn their keep on each other (case H caught the missing default, case K caught the missing gate).

### Verifier case C and G assertions (lines 116-148)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Case C's assertion that D1 and D2 fail while D3 passes proves the break is *minimal* — it removes the mismatch branch without collateral damage to the refusal path. The deliberate exclusion of D5 from case C's assertions (lines 119-125) is honest and correct: under a double break the line numbers no longer describe the same code, so asserting D5 there would be asserting a coincidence. Case G's jq-reason grep closes the loop. The summary and exit-1-on-failure are correct.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The six clauses (D1-D6) are behavioral assertions about the hook's cache semantics, not restatements of the exit-code gates. The exit codes (0/2/3/4) are the driver's output contract; the clauses are the measurements. The verifier proves the exit codes; the driver proves the clauses. No overlap.
- **Which single section would two reviewers diverge on most, and by how much?** The D4 check (subject pinning and BODY_LINE section). One reviewer reads `"refusal leaked a source line"` as "any source line" and flags the single-line scope as a false-negative risk; the other reads it as "a representative body line" and passes it. The verifier's silence on D4's fail path widens this — the section's claim is only as strong as the one BODY_LINE it picks, and nothing in the fixture set pressures that claim. Divergence: moderate — the finding is real but its live impact depends on a future hook version the sha gate currently prevents.
- **What did the artifact not say that it needed to say?** Two things. (1) It does not state what lines 85-91 of the registered hook actually contain — the comment says "the mismatch branch" but nothing verifies that claim against the file, so the break's correctness rests on an unchecked pairing of a sha and a line range. (2) It does not state that D4's leak check covers only the first body line — a reader who constructs a hook that leaks a different line would believe D4 catches it, and it does not.
