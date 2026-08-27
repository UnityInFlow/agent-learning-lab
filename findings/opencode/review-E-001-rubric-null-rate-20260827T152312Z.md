# opencode review — E-001-rubric-null-rate

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
opencode:        1.18.21
reviewed_utc:    20260827T152312Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  02caf8092670
lab_head:        b19b705
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: Two structural defects in the Decision rule mean the experiment cannot produce an interpretable KEEP/REJECT verdict regardless of how the runs come out, and neither defect is in the artifact's acknowledged blocker list.
  blocking:
    - reason: The KEEP condition ("↓ cell below other cells AND non-↓ cells equal to each other") cannot distinguish rubric discrimination from the spot-the-difference contamination the Hypothesis section itself names as Prediction 3's trap — if every non-↓ cell matches the baseline perfectly and only the ↓ cell differs, both KEEP sub-conditions fire and the experiment declares success while measuring "differs from baseline" rather than "violates the rubric's convention."
      wrong_action: A reader would record KEEP for architecture-consistency or maintainability when the scorer actually detected any difference from baseline, not the specific convention violation the rubric claims to score, and would treat that as evidence the rubric works.
      anchor: "KEEP         if the null rate is at or under your predicted number AND each fixture\n             the ↓ cell in each column scores below the other cells in that column AND\n             the non-↓ cells in that column are equal to each other — without the second\n             half, a fixture that is simply worse everywhere satisfies KEEP while\n             discriminating nothing"
      evidence: experiments/E-001-rubric-null-rate.md:318-322; the trap is named at lines 152-154
    - reason: The REJECT condition ("any category is constant across all five variants") cannot fire for test-quality, whose only discrimination test is the strong-vs-weak pair — 3 of its 5 cells are structural nulls by Decision A, so the category has 3 nulls + 2 scored cells, and "constant across all five" never applies even if both scored cells agree.
      wrong_action: A reader would fail to declare REJECT when test-quality fails its only discrimination test (e.g., strong and weak both score 1), because the structural nulls prevent "constant across all five" from triggering, leaving the experiment's sole two-cell comparison with no REJECT guard.
      anchor: "REJECT       if any category is constant across all five variants — it carries no\n             information regardless of how defensible its anchors read"
      evidence: experiments/E-001-rubric-null-rate.md:323-324; test-quality's 2-of-5 decidability at line 74
  non_blocking:
    - reason: The Question section says the one-cause property is "checkable rather than claimed" two paragraphs before admitting L3 (nothing executes to check) — the L3 admission is present so a careful reader catches the contradiction, but the wording invites a scanner to trust the property more than they should.
      evidence: experiments/E-001-rubric-null-rate.md:54 vs lines 64-65
    - reason: The decision rule registers no threshold for how much of the denominator can be excluded before the run stops being interpretable — explicitly a TODO at the bottom of the arithmetic table, so acknowledged, but worth flagging because the table above it files outcomes into tallies without bounding the excluded fraction.
      evidence: experiments/E-001-rubric-null-rate.md (TODO beneath the "What every outcome does to the arithmetic" table, around line 376)
  disputed: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| ## Question | 1/1 | L3 |
| ## Decision rule | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### # Experiment E-001 — does the four-category rubric decide anything?
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The status block registers two open blockers (rubric unwritten, predictions empty) and one cleared, with the cleared item's correction traced to a commit. The 20/24 denominator correction carries a provenance note disclosing it was AI-derived and not independently verified by the author, and the superseded reasoning is retained rather than deleted. No ambiguity a reviewer would resolve differently.

### ## Question
**Verdict:** finding
**Failure:** The held-constant table argues the fixture notes make the one-cause property "checkable rather than claimed," then two sentences later admits "It is an assertion in prose, so L3: nothing executes to check that `good-nested-ifs` did not also drift on architecture." Concrete scenario: `good-nested-ifs` drifts on architecture-consistency in addition to maintainability (the note's held-constant claim is wrong). The maintainability ↓ cell now has two candidate causes and the discrimination result is uninterpretable — but the section has already labeled this property "checkable." Two reviewers diverge: one reads "checkable" and trusts the one-cause property is verified; one reads the L3 admission and treats it as unverified prose. The L3 note is correct; the "checkable rather than claimed" phrasing is not — the property is claimed by the note, auditable by a human reading the code, and checked by nothing.
**Layer of the implied fix:** L3
**Anchor:** "which is what makes the one-cause property checkable rather than claimed"

### ## Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design (TODO, blocker 2). The "Evidence already on file" table is labeled as recorded observations, not predictions, and each row that was superseded by Decision B is struck through inline.

### ## Predictions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty, acknowledged as blocker 2. The instruction to fill and commit before the first run, and to verify the commit timestamp precedes `startedAt`, is stated. The three required prediction shapes (null rate as two numbers, discrimination per column, agreement with blind scores) are specified.

### ## Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The fixture is the IV; one-dimension-per-variant is the property benchmarks#10 provides. `known-good` is held constant as the attached baseline, making the five commensurable. Sound.

### ## How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The L1/L2/L3 labels are qualified correctly: control assertion is "L1 through this script, L3 outside it," with the bypass (`opencode run --continue` by hand) and its consequence (provenance header records `session: fresh` because the script wrote it, not because anything checked) both stated. The output guard's five exit codes are L2 — `classify-score-output.sh` executes and CI runs `verify-score-output-classifier.sh` against eight registered fixtures. The baseline-attachment failure mode (missing `LAB_SCORE_BASELINE` fails the run rather than silently producing the pre-Decision-B measurement) is registered.

### ## Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Two unchecked items (rubric sha, blind scores) are both blocked by open blockers and marked as such. Model, temperature, session, harness version, and benchmark revision are all pinned. The hanging-model warning is registered.

### ## Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Repetitions are undecided (TODO). The 2/12 critic variance is correctly attributed to `opencode-review.sh` — a different instrument with a different contract — and explicitly not transferred to the scorer. The scorer's unmeasured variance is flagged as a separate experiment, not this one.

### ## Minimum detectable effect
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The MDE table is empty (TODO). The TODO correctly identifies that a 0–2 scale with weights 35/25/25/15 means a 1-point category move shifts the normalised total by a fixed amount, and asks the author to compute it and set the discrimination threshold. The shape is registered; the numbers are the author's. Incompleteness is acknowledged.

### ## Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

No deterministic evaluator by design. The gate-passing guard is now executed rather than asserted: every gate-passing variant is a registered `run_case` in CI, so a fixture that stops clearing the gates fails CI instead of silently leaving the scored population. The baseline is covered by the same guard, which matters more now that it is attached rather than scored.

### ## Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The "hunting" exclusion is honestly flagged as L3 and weaker than it looks: the check fires on a citation, read-ish tools are ON, and "nothing records what the scorer read." The `fixture-notes` boundary (benchmarks repo, outside opencode's project root) is stated with the caveat "Should. Nothing has tested that, and nothing records what the scorer read. The L2 version is a tool-call log, and it does not exist." The empty-then-rerun rule (one `empty` is infrastructure, a second is a finding) is specified. The correction from the earlier draft — which excluded "exits 0 with no scores" and would have discarded the wholesale-undecidable outcome — is documented.

### ## Decision rule
**Verdict:** finding
**Failure:** Two gaps in the same rule. (a) More serious: the KEEP condition "the ↓ cell in each column scores below the other cells in that column" cannot distinguish true discrimination from spot-the-difference contamination. The Hypothesis section explicitly predicts the baseline attachment "may turn architecture-consistency and maintainability into spot-the-difference — an easier task and a different measurement." Concrete scenario: `good-inline-envelope` scores low on architecture-consistency because it differs from the `known-good` baseline in any way, not because the architecture convention is violated. KEEP fires — the ↓ cell is below the others — and the experiment declares success while measuring the wrong thing. The decision rule has no condition that separates "the rubric detected the convention violation" from "the rubric detected any difference from baseline," even though the Hypothesis section names this as the trap. (b) The REJECT condition "any category is constant across all five variants" cannot fire for `test-quality`: 3 of its 5 cells are structural nulls, so it is never constant across all five. If the scorer scores `good-strong-tests` and `good-weak-tests` both at 1, test-quality has failed its only discrimination test and REJECT does not fire. The experiment's sole two-cell comparison has no REJECT guard.
**Layer of the implied fix:** L3
**Anchor:** "KEEP if the null rate is at or under your predicted number AND each fixture the ↓ cell in each column scores below the other cells in that column"

### ## The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Step 1 names `backend-quality.yaml` at the seven-category sha; blocker 1 and the treatment table both flag that the four-category rewrite is pending. The path is correct for the post-#21 state (the file will be overwritten in place). Blind scoring before reading scorer output (step 2) is stated.

### ## Observed telemetry
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty. The artifact marks "Everything below is filled in AFTER the runs."

### ## Results
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty.

### ## Which predictions held
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty. The table structure is pre-registered.

### ## Failure analysis
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty.

### ## Sanity checks
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty. The three checklist items (dramatic number, flattering number, suspicious agreement) are pre-registered.

### ## Decision
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty.

### ## Follow-up
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, correctly empty.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The artifact explicitly drops functional-correctness and requirement-completeness ("the gates own them"), and the Deterministic evaluation section confirms `evaluator.sh` already passed all six fixtures. The four categories (architecture-consistency, maintainability, test-quality, change-focus) are all post-gate properties. No duplication.
- Which single section would two reviewers diverge on most, and by how much? The Decision rule — by a full verdict. One reviewer reads the KEEP condition as adequate (↓ cell below the others = discrimination); the other reads it as unable to separate discrimination from the spot-the-difference contamination the Hypothesis section itself predicts. The same section carries a second, independent gap (REJECT "constant across all five" can't fire for test-quality). Two reviewers could reach KEEP vs. REJECT on identical data.
- What did the artifact not say that it needed to say? The decision rule registers no threshold for how much of the denominator can be excluded before the run stops being interpretable. The TODO at the bottom asks for it, but the exclusion table above it already files outcomes into tallies without bounding the excluded fraction. A run where 8 of 17 cells drop out (off-contract + hunting) still produces a defect rate over 9, and the artifact does not say whether that rate is a result or an artifact of the exclusions.
