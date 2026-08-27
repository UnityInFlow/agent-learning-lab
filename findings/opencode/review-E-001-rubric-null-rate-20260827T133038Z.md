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
reviewed_utc:    20260827T133038Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  0d35ecfceec2
lab_head:        8c18466
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: The artifact is explicitly unregistered with predictions as the named blocker, and two structural defects the critic raised both hold up against the text — the Exclusions/24-cell denominator is ambiguous, and the Decision rule is silent on exit classes 2 and 5.
  blocking:
    - reason: The three required predictions and the hypothesis body are all TODO/empty; the artifact's own status block names this as the blocker and the header warns that running `opencode-score.sh` without committed predictions voids the runs.
      wrong_action: A reader treats the structural completeness as "ready pending metadata" and runs the scoring harness against one or more fixtures. The runs produce data with no predictions to test against, and per the header warning the entire run set is invalidated — the same failure mode the artifact records as having already cost nine runs.
      anchor: "**Status: unregistered. One blocker remains, and it is the predictions.**"
      evidence: experiments/E-001-rubric-null-rate.md:7
    - reason: The Exclusions section removes a "went hunting" cell from scoring but never specifies whether the 24-cell denominator drops by one (to 23) or stays at 24 with one missing cell.
      wrong_action: A "went hunting" cell is excluded. Reviewer A reads "excluded" as removed-from-denominator and computes the null rate over 23; Reviewer B reads "excluded" as not-scored-but-counted and computes over 24. On 8 observed nulls that is 35% vs 33% — large enough to flip a KEEP/INCONCLUSIVE verdict against the predicted threshold.
      anchor: "A cell where the scorer's `evidence` cites a file not in the attachment set — it went hunting, and the result is not from the evidence it was given"
      evidence: experiments/E-001-rubric-null-rate.md:209
    - reason: The Decision rule classifies `empty` (exit 3) and all-null sheets as REJECT but is silent on `off contract` (exit 2) and `declared error` (exit 5), which the Exclusions section registers as "recorded, not re-run."
      wrong_action: A scorer returns `off contract` for `good-nested-ifs`. Reviewer A treats it as REJECT by analogy to wholesale-undecidable and counts the 4 cells toward the null rate; Reviewer B treats it as unclassifiable and discards them. The fixture gets two opposite verdicts from the same output, and the 24-cell denominator is affected four cells either way.
      anchor: "A run classed `off contract` (`2`) or `declared error` (`5`) is recorded, not re-run. It is what this scorer did when handed this rubric"
      evidence: experiments/E-001-rubric-null-rate.md:205
  non_blocking:
    - reason: The hypothesis body is a TODO separate from the three numbered predictions; the status block names only "predictions" as the blocker even though the hypothesis is also empty.
      evidence: experiments/E-001-rubric-null-rate.md:48
    - reason: Rubric sha is recorded as "pre-rewrite — record the new sha here once #21 lands" and the Controlled variables checklist flags this as unchecked — acknowledged but not a separate blocking issue.
      evidence: experiments/E-001-rubric-null-rate.md:130
    - reason: Repetitions and total blank, MDE table cells empty, Decision rule body is a TODO with only the wholesale-undecidable paragraph filled in. All are correctly labeled as pre-run sections; the artifact does not claim they are complete.
      evidence: experiments/E-001-rubric-null-rate.md:154-230
  disputed: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|


---

## Run 1 of 1


> lab-critic · glm-5.2

# Experiment E-001 — does the four-category rubric decide anything?

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The status block honestly declares the record unregistered with predictions as the blocker. The cleared benchmarks#20 item is traced to its fix commit. No hidden defect.

## Question

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The three failure modes (undecidable per cell, undecidable wholesale, constant) are distinct and well-separated. The cell-boundary statement — "A sheet is a sheet when it carries `scorer: lab-scorer` and a `categories:` block, *whatever is in the cells*" — closes the ambiguity between 24 nulls and no output. The pointer to `classify-score-output.sh` for where the distinction executes is the right L2 anchor.

## Hypothesis

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The hypothesis body is a TODO, acknowledged in the status block. The "Evidence already on file" subsection is the substantive content. Each row is sourced to a file in `findings/opencode/` or a tool script. Decision A (no-test-fixture cells are predicted null, not guaranteed null) is correctly labeled as L3 — "the precondition is YAML read by a model, nothing executes to reject a `0`." Decision B (known-good attached as baseline) flags its own trap: the baseline is available to all four categories and may turn two of them into spot-the-difference. The artifact warns itself about this and points to Prediction 3 as the trap. No hidden defect in what is filled in.

## Predictions

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — the status block names this as the blocker. The three required predictions (null rate, discrimination, agreement with blind scores) are specified with enough structure that two readers would fill them in the same shape. The note that the previous adopted set was Claude's and broke on an authoring error is the right framing for why independent predictions matter.

## Independent variable

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"The fixture. Everything else is held." One variable, one dimension per fixture, sourced to benchmarks#10. Clean.

## How the treatment is delivered — and proved

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The layer labels are honest. The control assertion correctly self-identifies as "L1 through this script, L3 outside it" — the script has no branch reaching `--continue`, but running `opencode run --continue` by hand bypasses it, and "the provenance header records `session: fresh` because the script wrote it, not because anything checked." That is exactly the L3-worn-as-L2 distinction the project tracks, and the artifact states it rather than hiding it. The output guard row correctly identifies `classify-score-output.sh` as L2 and names the eight-fixture verifier in CI. The rubric sha is a placeholder (`pre-rewrite — record the new sha here once #21 lands`), acknowledged in Controlled variables as unchecked.

## Controlled variables

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Six items checked, two unchecked (rubric sha pending #21, blind scores not yet recorded). Both unchecked items are acknowledged elsewhere. The model-pin note ("an unpinned scorer model is an unregistered variable") is guidance, not a control, but the artifact doesn't claim it's L2 — it's a checklist item. The hang-warning for three models is operational, not structural.

## Runs

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Repetitions and total are blank (pre-run). The discussion of the 2/12 critic disagreement is carefully scoped: "Treat 2/12 as a reason to ask the question about the scorer, not as an answer for it." The distinction between the critic's contract (decides what to report, under-reporting is the failure) and the scorer's contract (fixed output shape, variance would show as cell flips) is correct and prevents importing one instrument's variance figure into another's.

## Minimum detectable effect

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The MDE table cells are empty (pre-run). The TODO asks the right question — a 0–2 scale with weights 35/25/25/15 means a 1-point move in one category shifts the normalised total by a fixed amount, and the threshold for "real difference vs noise" needs that number. Not yet answered, but the question is registered before data, which is what the section requires.

## Deterministic evaluation

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"None. This experiment has no deterministic evaluator, by design." The rationale is sound: evaluator.sh already decided pass/fail for all six, and since benchmarks#21 that is executed (registered `run_case` in CI) rather than asserted. The experiment measures whether a non-deterministic instrument discriminates among things the deterministic one cannot. The blind human-scorer agreement check is correctly identified as the substitute for deterministic evaluation.

## Exclusions

**Verdict:** finding
**Failure:** A scorer returns a score of 2 for `good-strong-tests` on `test-quality`, and its `evidence` field cites a path that is not in the attachment set — say, a file from `fixture-notes/` or a line range from `known-good` that the reviewer is unsure belongs to the attachment set for this fixture. The exclusion says the cell is excluded because "the result is not from the evidence it was given," but does not say what happens to it in the 24-cell denominator. Reviewer A reads "excluded" as "remove from the denominator — it is now 23 cells, and the null rate is over 23." Reviewer B reads "excluded" as "the cell is not scored but the denominator stays 24 — it is neither null nor scored, so the null rate is over 24 with one cell simply missing." On 8 observed nulls, that is 33% (over 24) or 35% (over 23) — and if the threshold for INCONCLUSIVE is "nulls concentrated in one category," the denominator change could move a cell count across the line. The Decision rule says "The denominator is 24" and the Exclusions section says the cell is excluded, but neither says how an excluded cell relates to the 24.
**Layer of the implied fix:** L3
**Anchor:** "A cell where the scorer's `evidence` cites a file not in the attachment set — it went hunting, and the result is not from the evidence it was given"

## Decision rule

**Verdict:** finding
**Failure:** The filled-in wholesale-undecidable paragraph classifies two outcomes: a confirmed `empty` (exit 3, two in a row) and a sheet with 4 null cells for a fixture are both REJECT for that fixture, counting 4 cells toward the null rate. But the Exclusions section defines two more run-level outcomes that are "recorded, not re-run": `off contract` (exit 2) and `declared error` (exit 5). The decision rule does not classify either. A scorer returns output that `classify-score-output.sh` classes as `off contract` (2) for `good-nested-ifs`. Reviewer A says "the decision rule only defines REJECT for empty and all-null; off-contract is recorded as a finding but has no verdict, so the fixture is neither KEEP nor REJECT — it is unclassifiable, and the experiment has no result for it." Reviewer B says "off-contract is a failed run for that fixture, analogous to wholesale-undecidable, so it is REJECT and its 4 cells count toward the null rate." The two readers reach opposite verdicts on the same output, and the 24-cell denominator is affected: if the 4 cells count, the null rate denominator is 24; if they don't, it is 20 for this fixture's absence. The filled-in part of the decision rule is silent on outcomes 2 and 5, and the Exclusions section's "recorded, not re-run" does not specify a verdict.
**Layer of the implied fix:** L3
**Anchor:** "A confirmed `empty` (two in a row on the same rubric and fixture), or a sheet whose 4 cells for a fixture are all `null`, is a **REJECT** for that fixture and counts its 4 cells toward the null rate — not INCONCLUSIVE, and never a re-run."

## The procedure, from #21

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Four steps, ordered. Step 2 (blind scores before reading scorer output) is the integrity gate and is correctly placed before step 3. Step 1 (critique the rubric before applying it) catches anchor defects before they produce nulls. The "six, not five" note for known-good prevents the reference from being unscored. Clean.

## Observed telemetry

**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section, experiment has not run.

## Results

**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section. The "Median and p25/p75. Never an average alone." instruction is correct guidance for what will go here.

## Which predictions held

**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

## Failure analysis

**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

## Sanity checks

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Three checkboxes, post-run. The "flattering number — disbelieve twice" and "suspiciously often — check whether it read your scores" checks are the right guards against confirmation bias. Nothing to find in an unrun checklist.

## Decision

**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

## Follow-up

**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty — post-run section.

### Cross-cutting

- **Does any scoring category duplicate a pass/fail gate?** No. The four categories (architecture-consistency, maintainability, test-quality, change-focus) are quality dimensions, not pass/fail. The Deterministic evaluation section confirms evaluator.sh owns pass/fail, and the CLAUDE.md context confirms functional-correctness and requirement-completeness were dropped because the gates own them. `test-quality` is adjacent to the test gate but measures test quality, not test passage — no duplication.

- **Which single section would two reviewers diverge on most, and by how much?** The Exclusions section, on the "went hunting" cell exclusion's effect on the 24-cell denominator. The divergence is one cell in the denominator (24 vs 23), which on a null-rate threshold is ~4% — enough to flip a KEEP/INCONCLUSIVE verdict if the observed null count sits near the predicted threshold. A secondary divergence on the Decision rule's silence about outcomes 2 and 5 is wider: one reviewer classifies off-contract as REJECT, the other as unclassifiable, a difference of 4 cells in the denominator (24 vs 20) and a categorical difference in verdict.

- **What did the artifact not say that it needed to say?** How excluded cells (the "went hunting" rule) and unclassified run outcomes (exit 2, exit 5) relate to the 24-cell denominator. The denominator is stated as fixed at 24, but the Exclusions section defines cell-level and run-level exclusions without saying whether they reduce it, count as null, or leave a gap. The filled-in wholesale-undecidable paragraph addresses exits 3 and all-null but not 2 and 5. Two readers with the same output file can reach different verdicts because the classification of excluded and unclassified cells is unspecified.
