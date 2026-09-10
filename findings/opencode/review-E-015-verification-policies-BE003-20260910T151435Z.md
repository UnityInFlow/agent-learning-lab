# opencode review — E-015-verification-policies-BE003

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
reviewed_utc:    20260910T151435Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-015-verification-policies-BE003.md
    sha:  cf73eddfdc79
    dirty: false
  - path: experiments/E-016-verification-policies-BE004.md
    sha:  77e60fea2ef3
    dirty: false
  - path: phases/b07-verification-policies/README.md
    sha:  383a945c35c2
    dirty: false
  - path: /tmp/b7review/protected-paths.yaml
    sha:  76c4c34c0f4c
    dirty: false
lab_head:        2bb6115
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-015-verification-policies-BE003.md, experiments/E-016-verification-policies-BE004.md
  verdict: REJECT
  summary: The Amendment moved the policy log from `.ai/policy-events.jsonl` to `$TMPDIR/…` but did not update the three places in each experiment file that name the old path or hash; a literal reading of P1 voids the arm under Decision Rule row 0, the preflight assertion cannot fire on the new hook, and the delivery-table hash is stale. Three L3 text fixes unblock the artifact.
  blocking:
    - reason: P1's text still names `.ai/policy-events.jsonl` after the Amendment moved the log to `$TMPDIR/policy-events-<worktree-basename>.jsonl`. The Amendment explicitly says "No prediction in this file is edited."
      wrong_action: A literal reviewer checks for `.ai/policy-events.jsonl` in the treated worktree, finds nothing, marks P1 failed, applies Decision Rule row 0 → VOID. An intent reviewer reads the Amendment and passes P1. The divergence is a full verdict swing (KEEP ↔ VOID) on one reviewer's choice of literal vs. intent reading of the same sentence.
      anchor: "**P1** | **Delivery.** Every treated run writes `.ai/policy-events.jsonl` with **≥ 1** entry; every control run has **no such file**"
      evidence: "experiments/E-015-verification-policies-BE003.md:51, experiments/E-016-verification-policies-BE004.md:51"
    - reason: The preflight assertion still requires `.ai/policy-events.jsonl` present in the kept worktree after the Amendment moved the log to `$TMPDIR/`. The preflight that already passed (manifest at lines 200-205) was against the OLD hook writing to `.ai/`; no batch-run assertion has been registered for the NEW hook.
      wrong_action: A reviewer running preflight on the NEW hook (writing to `$TMPDIR/`) finds no `.ai/policy-events.jsonl` in the worktree and cannot distinguish "hook did not run" from "hook ran but wrote elsewhere." P1's literal claim and the assertion's literal claim fail by the same path.
      anchor: ".ai/policy-events.jsonl present with ≥ 1 entry in the kept worktree"
      evidence: "experiments/E-015-verification-policies-BE003.md:80, experiments/E-016-verification-policies-BE004.md:80"
    - reason: The delivery table at line 78 registers `policy-gate.sh` hash `c558f78ace02066223746bd216e4c848326bdc382fa2cfd35f1569d9fe22cbac` while the Amendment at line 190 shows the new hash `f432abbcbf1f3b90ec4dd801a23c333a5f7e6c40fe0b54b11fd5689f9938cbca` in a separate old/new table. The source-of-truth line was not updated in place.
      wrong_action: A reviewer cross-referencing the delivery table's hash against the actual hook sees a mismatch and concludes "treatment not delivered" before reading the Amendment. The artifact has two contradictory hash values for the same file with no pointer from line 78 to the Amendment.
      anchor: "`policy-gate.sh` `c558f78ace02066223746bd216e4c848326bdc382fa2cfd35f1569d9fe22cbac`"
      evidence: "experiments/E-015-verification-policies-BE003.md:78, experiments/E-016-verification-policies-BE004.md:78"
  non_blocking:
    - reason: Decision Rule Row 5's precondition is self-contradictory: Row 3 requires P4–P7 all inside MDE, and Row 5 requires "Row 3 holds AND cost is outside its MDE." Since P4 IS cost, the two cannot both hold. Likely intent was "Row 4 holds AND cost is in worse direction → REJECT on cost," but the literal text is unreachable as written.
      evidence: "experiments/E-015-verification-policies-BE003.md:156-158, experiments/E-016-verification-policies-BE004.md:156-158"
    - reason: The Amendment's claim "nothing about the delivery proof weakens" is contradicted by the preflight evidence (manifest at lines 200-205): the four preflight runs exercised the OLD hook writing to `.ai/`, not the NEW hook writing to `$TMPDIR/`. The author is aware and chose to proceed (line 248: "Amended by Opus 5"); the new hook's delivery proof is unmeasured. If the new hook has a defect (e.g. unset `$TMPDIR`, path-construction bug), every treated batch run will lack a log and fall to Row 0.
      evidence: "experiments/E-015-verification-policies-BE003.md:230, experiments/E-016-verification-policies-BE004.md:230"
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 136s |
| ollama-cloud/glm-5.2 | ok | 105s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Predictions | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| Amendment, 2026-09-10 — the treatment's hash moved before its first registered run, and why | 1/1 | L2 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** finding
**Failure:** P1 says "Every treated run writes `.ai/policy-events.jsonl` with ≥ 1 entry." The Amendment moves the log to `$TMPDIR/policy-events-<worktree-basename>.jsonl` and explicitly states "No prediction in this file is edited." After the fix, a treated batch run does NOT write `.ai/policy-events.jsonl` — the file at that path is absent by design. Decision rule row 0 says "a treated run with no event log → VOID." Reviewer A reads P1 as referring to the event log wherever it now lives and passes it; Reviewer B reads the path literally, finds no `.ai/policy-events.jsonl` in the treated worktree, and declares the arm VOID. The verdict diverges on whether the path in P1's text is load-bearing after the amendment explicitly refused to update it. Applies identically to E-016.
**Layer of the implied fix:** L3
**Anchor:** "Every treated run writes `.ai/policy-events.jsonl` with ≥ 1 entry; every control run has no such file"

### Independent variable
**Verdict:** no finding

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The Preflight assertion says "`.ai/policy-events.jsonl` present with ≥ 1 entry in the kept worktree." After the Amendment, the log is written to `$TMPDIR/`, not the worktree. A batch run satisfies the assertion's intent (the log exists) but not its text (the file is not in the kept worktree). The preflight already ran under the old path and passed; the batch runs will use the new path. A reviewer checking the preflight assertion against a batch worktree finds the file absent and cannot distinguish "hook did not run" from "hook ran but wrote elsewhere." Same root cause as the P1 finding, in a different section. Applies identically to E-016.
**Layer of the implied fix:** L3
**Anchor:** "`.ai/policy-events.jsonl` present with ≥ 1 entry in the kept worktree"

### Controlled variables
**Verdict:** no finding

### Runs
**Verdict:** no finding

### Minimum detectable effect
**Verdict:** no finding

### Deterministic evaluation
**Verdict:** no finding

### Exclusions
**Verdict:** no finding

### Decision rule
**Verdict:** finding
**Failure:** Row 5 says "Row 3 holds **and** cost is outside its MDE in the *worse* direction → REJECT on cost." Row 3 requires "P4–P7 all land inside their MDEs," and P4 is cost. If cost is outside its MDE, Row 3 cannot hold — Row 4 catches it as INCONCLUSIVE. Row 5's precondition is self-contradictory. Scenario: treated median cost is 35% higher than control (outside the 30% MDE on E-015, outside the 13% MDE on E-016, worse direction). Reviewer A reads Row 4 → INCONCLUSIVE. Reviewer B reads Row 5 → REJECT on cost. The verdict diverges on whether a cost increase in the worse direction is REJECT or INCONCLUSIVE, because Row 5 is unreachable as written. Applies identically to E-016.
**Layer of the implied fix:** L3
**Anchor:** "Row 3 holds **and** cost is outside its MDE in the *worse* direction"

### Deliberate failure (§4 step 9)
**Verdict:** no finding

### Amendment, 2026-09-10 — the treatment's hash moved before its first registered run, and why
**Verdict:** no finding

### Observed telemetry
**Verdict:** skipped — empty placeholder, filled after the run.

### Results
**Verdict:** skipped — empty placeholder, filled after the run.

### Which predictions held
**Verdict:** skipped — empty placeholder, filled after the run.

### Decision
**Verdict:** skipped — empty placeholder, filled after the run.

---

### Goal
**Verdict:** no finding

### Required reading
**Verdict:** no finding

### Extract
**Verdict:** no finding

### Design — and the two measurements that decided it
**Verdict:** no finding

### Build
**Verdict:** no finding

### Predict before you run
**Verdict:** skipped — TODO placeholder; predictions live in the experiment files.

### Lab B7.1 — measure against B6, and close v1.0 against B2
**Verdict:** skipped — TODO placeholder.

### Deliberate failure
**Verdict:** skipped — TODO placeholder; the experiment files carry the committed predictions.

### Exit gate
**Verdict:** no finding

### Commit
**Verdict:** skipped — TODO placeholder.

---

### protected-paths.yaml
**Verdict:** no finding

---

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. P6 (evaluator pass rate) compares treated to control; it does not restate the evaluator's own exit-code gate. The evaluator gate is a constant across both arms; P6 is a two-arm comparison. No duplication.
- **Which single section would two reviewers diverge on most, and by how much?** Predictions, specifically P1. The amendment changed the log path from `.ai/policy-events.jsonl` to `$TMPDIR/` and explicitly refused to edit any prediction. A literal reading of P1 fails the treated half (the file at the named path is absent by design) and triggers VOID under row 0; an intent reading passes it. That is a full verdict swing — from KEEP to VOID — on one reviewer's choice of literal vs. intent. The Row 5 unreachability is a smaller divergence (INCONCLUSIVE vs. REJECT) and requires a cost outcome that the hypothesis predicts will not occur.
- **What did the artifact not say that it needed to say?** The amendment needed to state that P1's path reference is superseded by the new location, or P1's text needed to move with the log. As written, the amendment says "No prediction in this file is edited" while changing the path two predictions and one assertion reference — and the decision rule's VOID row is path-specific. The artifact also did not say what happens to the preflight assertion text for the batch runs: the preflight passed under the old path, but the batch runs use the new path, and no updated assertion is registered for them.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** P1 says "Every treated run writes `.ai/policy-events.jsonl` with ≥ 1 entry." The Amendment (line 228–232) moves the log to `$TMPDIR/policy-events-<worktree-basename>.jsonl` and says "No prediction in this file is edited." After the amendment, a reviewer checking the treated worktree for `.ai/policy-events.jsonl` finds nothing — the file is in `$TMPDIR`, outside the worktree. Decision rule row 0 says P1 failing in either half → VOID. Reviewer A reads P1 literally, finds no `.ai/policy-events.jsonl` in the worktree, marks P1 failed, voids the arm. Reviewer B reads the amendment, checks `$TMPDIR`, finds the log, marks P1 held. The same divergence exists in E-016 line 51.
**Layer of the implied fix:** L3
**Anchor:** "Every treated run writes `.ai/policy-events.jsonl` with ≥ 1 entry; every control run has no such file"

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Two defects in the same section. (1) The delivery table at line 78 registers `policy-gate.sh` hash `c558f78ace02066223746bd216e4c848326bdc382fa2cfd35f1569d9fe22cbac`. The Amendment at line 190 replaces it with `f432abbcbf1f3b90ec4dd801a23c333a5f7e6c40fe0b54b11fd5689f9938cbca`. The delivery table was not updated in place; the amendment is a separate section. A reviewer verifying the treatment by hashing the actual `policy-gate.sh` and comparing to line 78 gets a mismatch and concludes the treatment was not delivered or was tampered with. (2) The preflight assertion at line 80 says "`.ai/policy-events.jsonl` present with ≥ 1 entry in the kept worktree." After the amendment the log is in `$TMPDIR`, not the worktree, so the registered assertion checks a path that will not exist. The preflight table at lines 200–205 was run with the old hook (hash `c558f78ace…`, writing to `.ai/`); the new hook (hash `f432abbcbf…`, writing to `$TMPDIR`) has not been preflighted. The amendment's claim that "nothing about the delivery proof weakens" is unsupported: the proof was for a different file. Both defects are present in E-016 lines 78 and 80.
**Layer of the implied fix:** L3
**Anchor:** "`policy-gate.sh` `c558f78ace02066223746bd216e4c848326bdc382fa2cfd35f1569d9fe22cbac`" (line 78) and "`.ai/policy-events.jsonl` present with ≥ 1 entry in the kept worktree" (line 80)

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment, 2026-09-10 — the treatment's hash moved before its first registered run, and why
**Verdict:** finding
**Failure:** The amendment changes `policy-gate.sh` (new hash `f432abbcbf…`, new log location `$TMPDIR/…`) but the preflight proof it cites (lines 200–205) was produced by the old hook (hash `c558f78ace…`, log at `.ai/policy-events.jsonl`). The four preflight runs exercised a different file than the one that will run in the batch. The amendment states "nothing about the delivery proof weakens" but the delivery proof — the event log's existence proving the hook executed — was generated by a hook writing to `.ai/`, not by a hook writing to `$TMPDIR`. If the new hook has a defect (e.g., `$TMPDIR` unset in the hook's environment, a path-construction bug in the new code), the log will not appear, P1 will fail, and the arm will be voided under row 0 — but the amendment presents the preflight as sufficient evidence that this cannot happen. Two reviewers diverge: one accepts the preflight as proof the mechanism works and attributes the hash change to a trivial path swap; the other notes that the thing preflighted is not the thing registered, and that the new hook's execution has zero direct evidence.
**Layer of the implied fix:** L2
**Anchor:** "nothing about the delivery proof weakens"

### Observed telemetry
**Verdict:** skipped
**Failure:** Empty — filled after runs. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** skipped
**Failure:** Empty — filled after runs. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** skipped
**Failure:** Empty — filled after runs. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** skipped
**Failure:** Empty — filled after runs. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

---

E-016 shares every finding above at the same structural locations (P1 line 51, delivery table line 78, preflight assertion line 80, amendment line 190/228). The MDE table and rubric sha differ correctly for BE-004. No additional finding unique to E-016.

---

### Goal
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Required reading
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Extract
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Design — and the two measurements that decided it
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Build
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predict before you run
**Verdict:** skipped
**Failure:** Scaffold TODO, not filled. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab B7.1 — measure against B6, and close v1.0 against B2
**Verdict:** skipped
**Failure:** Scaffold TODO, not filled. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure
**Verdict:** skipped
**Failure:** Scaffold TODO, not filled. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exit gate
**Verdict:** skipped
**Failure:** Scaffold TODO, not filled. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Commit
**Verdict:** skipped
**Failure:** Scaffold TODO, not filled. Nothing to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

---

### protected-paths.yaml
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. P6 measures the aggregate pass rate across 10 runs against the concurrent control; the evaluator's exit code is a per-run gate. P6 is a comparison of rates, not a restatement of a single-run pass/fail.
- Which single section would two reviewers diverge on most, and by how much? The Amendment. The claim "nothing about the delivery proof weakens" is the fault line: one reviewer treats a hash change plus a path swap as cosmetic and accepts the preflight; the other reads it as a new artifact that has zero execution evidence. The divergence is wide — it is the difference between proceeding to the batch and re-running the preflight.
- What did the artifact not say that it needed to say? The amendment needed to state either (a) that the new hook was re-preflighted after the path change, with the result, or (b) why the old preflight's proof of execution transfers to a hook with a different hash writing to a different location. It said neither. It also did not update P1's path or the preflight assertion's path, leaving three places in the same document that name `.ai/policy-events.jsonl` as the delivery proof while the amendment sends the file elsewhere.
