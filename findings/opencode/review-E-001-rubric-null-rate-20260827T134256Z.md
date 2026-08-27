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
reviewed_utc:    20260827T134256Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  121a6b09a0bd
lab_head:        dc7ef82
lab_dirty:       true
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: ACCEPT
  summary: A pre-run experiment record that correctly self-registers as unregistered with two real blockers (the four-category rubric does not exist on disk; the three predictions are empty), and has appropriately-placed TODOs throughout; the line-level finding about the asymmetric scoring condition in the suggested KEEP rule is a valid methodological concern but is non-blocking because the rule itself is an unfinished TODO and the asymmetry is already partially acknowledged in the Hypothesis section.
  blocking: []
  non_blocking:
    - reason: The suggested KEEP condition in the Decision rule TODO compares scores produced under asymmetric conditions — known-good without baseline vs. variants with known-good as baseline — but does not specify how to interpret "equal elsewhere" when the two sides were not produced commensurably. The asymmetry is registered in the Hypothesis section ("Its 4 cells see one tree; the other twenty see two"), but the TODO does not say how the rule adjusts for it. The author will need to address this when filling in the rule.
      evidence: experiments/E-001-rubric-null-rate.md:240
    - reason: The suggested KEEP condition's "equal elsewhere" clause is precisely what the asymmetric scoring threatens; the TODO acknowledges the suggested shape is "not an answer" and asks the author to note what they would do differently — so the author has explicit license to revise it, but the suggested form still stands as the default if they adopt without thinking
      evidence: experiments/E-001-rubric-null-rate.md:238-247
    - reason: The entire 24-cell denominator (4 categories × 6 fixtures) is predicated on the lab#21 four-category rubric rewrite, which is unwritten; the file on disk is the seven-category worked example (sha 21aa658d030d). Running against the file on disk would measure the artifact this experiment exists to replace. This is Blocker 1 and is honestly flagged.
      evidence: experiments/E-001-rubric-null-rate.md:9-15,143
    - reason: Six pre-run TODOs remain alongside the two top-level blockers: Hypothesis mechanism, three Predictions, Repetitions count, MDE per category, blind scores, and the decision-rule threshold. All are explicitly marked TODO; none are hidden.
      evidence: experiments/E-001-rubric-null-rate.md:60,119,122,125,160,167,189,278
  disputed: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Decision rule | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### Status
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The two blockers are stated honestly and the cleared one is struck through with its resolution cited. The correction of "eight fixtures, not four" in blocker 3 is the kind of self-correction the record should carry. No failure scenario attaches.

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The three failure modes (undecidable per cell, undecidable wholesale, constant) are distinct and non-overlapping. The cell-boundary definition ("a sheet is a sheet when it carries `scorer: lab-scorer` and a `categories:` block") is concrete enough that two readers would apply it identically, and the classifier enforces it (L2). The "six, not five" correction is internally consistent with the 24-cell denominator used elsewhere.

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The hypothesis itself is a TODO, acknowledged as blocker 2. The "Evidence already on file" table is the strongest part of the artifact: each row cites a specific file, and superseded rows are struck through with the commit that superseded them. The L3-as-L2 warning on the `test-quality` precondition ("nothing executes to reject a `0`") is correctly labeled. No failure scenario attaches to anything in this section that isn't already flagged.

### Predictions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

All three predictions are empty TODOs. This is blocker 2. The note that the previously adopted set broke on a rubric authoring error is context, not a claim. Nothing to find beyond the acknowledged gap.

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"The fixture" with "one thing" varied per variant is clear. "Five fixtures" here refers to the five variants differing from `known-good`, which is consistent with six total. No ambiguity.

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The L2 claims name executing scripts (`opencode-score.sh` fails on `--dir` repoint; `classify-score-output.sh` returns per-outcome exit codes; `verify-score-output-classifier.sh` runs in CI). The L1 claim about `--continue` being unreachable through the script is structural — no flag, no branch — and the L3 escape ("running `opencode run --continue` by hand bypasses it") is honestly noted. The rubric row correctly flags that the sha on disk is the wrong rubric (blocker 1). No failure scenario attaches.

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Checked items are pinned with specific versions/shas. Unchecked items (`rubric sha`, `blind scores`) are the acknowledged blockers. The hanging-models warning is operational, not a control claim. No finding.

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Repetitions and total are blank (TODO). The 2/12 critic figure is appropriately hedged — "Treat 2/12 as a reason to ask the question about the scorer, not as an answer for it" — and the distinction between the critic's contract (decides what to report) and the scorer's contract (fixed output shape) is correct. No finding beyond the acknowledged TODO.

### Minimum detectable effect
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The MDE and "Registered before the run?" columns are empty. The TODO asks to compute the per-category effect of a 1-point move on the normalised total. This is an acknowledged gap, not a hidden one. No failure scenario attaches to a table that is explicitly unfinished.

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"None, by design" is the correct answer for this experiment. The rationale (evaluator.sh already decided pass/fail; what's being measured is non-deterministic discrimination) is sound. The note that benchmarks#21 registered gate-passing variants as `run_case`s so a fixture that stopped clearing gates would fail CI is a concrete L2 enforcement claim, and it names the mechanism. No finding.

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The five exclusion classes are distinct and non-overlapping. The correction of the earlier draft that "swept up the wholesale-undecidable outcome" is the right fix. The "empty → re-run → second empty is a finding" protocol is clear, and "the repeat is what decides" establishes the general principle that the re-run's class replaces the first run. The "went hunting" exclusion ("cites a file not in the attachment set") has a clear criterion and a defined attachment set. "Excluded means dropped from the denominator, not scored as a null" prevents the 33%-or-35% ambiguity. No failure scenario attaches.

### Decision rule
**Verdict:** finding
**Failure:** `known-good` is scored without a baseline (it *is* the baseline); the five variants are scored with `known-good` attached as baseline. The decision rule's KEEP condition requires each fixture to "score below known-good on its own dimension AND equal to it elsewhere." But the two scores being compared were produced under different conditions: the variant's scorer saw two trees and could spot-the-difference; `known-good`'s scorer saw one. A variant that differs only on architecture-consistency might also score lower on maintainability — not because its maintainability is worse, but because its scorer had a baseline to compare against and `known-good`'s did not. Two reviewers handed the same sheets would diverge on whether "equal elsewhere" held: one would say the gap is real discrimination, the other would say it's an artifact of the asymmetric scoring conditions. The KEEP verdict flips on which reading wins.
**Layer of the implied fix:** L3
**Anchor:** "each fixture scores below known-good on its own dimension AND is equal to it elsewhere"

The artifact records the asymmetry in the Hypothesis section ("Its 4 cells see one tree; the other twenty see two") and the "Prediction 3 is the trap for it" note warns that the baseline may turn categories into spot-the-difference for the variants. But that note addresses the variants having an *easier* task; it does not address the comparison being *non-commensurable* — `known-good`'s scores and the variants' scores are produced under different conditions and then compared as if they were on the same scale. The decision rule has no adjustment for this. The provenance header records `baseline_state` so the asymmetry is "provable rather than remembered," but provable is not resolved — nothing in the rule says how to interpret a gap that spans different scoring conditions.

### The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Four steps, in order, with the blind-scoring step correctly including all six fixtures. Step 1 critiques the rubric that doesn't exist yet (blocker 1), but the procedure is labeled "from #21" — it's the procedure for after the rewrite lands. No finding beyond the acknowledged blocker.

### Observed telemetry
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, intentionally empty. Skipped because there are no runs to report.

### Results
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, intentionally empty. Skipped because there are no runs to report.

### Which predictions held
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, intentionally empty. Skipped because there are no predictions yet and no runs.

### Failure analysis
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, intentionally empty. Skipped because there are no runs to analyze.

### Sanity checks
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run checklist, intentionally unchecked. Skipped because there are no runs to sanity-check.

### Decision
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, intentionally empty. Skipped because the experiment has not been run.

### Follow-up
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Post-run section, intentionally empty. Skipped because the experiment has not been run.

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The four categories (architecture-consistency, maintainability, test-quality, change-focus) are all non-gate dimensions. The artifact explicitly dropped functional-correctness and requirement-completeness because the gates own them — the CLAUDE.md context confirms this. No duplication.
- Which single section would two reviewers diverge on most, and by how much? The Decision rule, on the known-good asymmetry. The divergence is one full verdict level: one reviewer accepts the KEEP comparison as valid (known-good is the reference, scoring it without a baseline is correct by definition); the other rejects it as confounded (scores produced under different conditions are not commensurable, so "equal elsewhere" is uninterpretable). The artifact records the asymmetry but does not resolve its consequence for the rule, so both readings are defensible from the text.
- What did the artifact not say that it needed to say? Whether scores produced under asymmetric conditions (known-good alone vs. variant + baseline) are commensurable enough to support a direct comparison in the decision rule. The artifact proves the asymmetry exists (`baseline_state` in the provenance header) but stops there — it does not say whether the KEEP/REJECT/INCONCLUSIVE logic adjusts for it, ignores it, or is invalidated by it.
