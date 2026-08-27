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
reviewed_utc:    20260827T135651Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  136359e665e0
  - path: experiments/E-001-prediction-worksheet.md
    sha:  5f5d54f7d23d
lab_head:        2e25f7c
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: The artifact is in honest draft state (its own admission: "Status: unregistered. Two blockers remain."), and the arithmetic table in the Decision rule section silently re-aggregates wholesale-undecidable into defect nulls in a way that contradicts the cell-boundary statement in the Question section — a contradiction that would change the diagnosis a reader reaches from the same numbers.
  blocking:
    - reason: The arithmetic table row "empty (3) confirmed by a repeat" records +4 in the nulls numerator and counts in the denominator, treating wholesale-undecidable as four defect nulls. The cell-boundary statement in the Question section explicitly distinguishes "no `categories:` block at all" from nulls and calls the wholesale case "the strongest result this experiment can produce." The artifact's own section on undecidability (lines 88–95) makes the same distinction. A reader computing the rubric-level rate from the table will conflate anchor-defective and wholesale-undecidable and report a wrong diagnosis.
      wrong_action: A reader reports "the rubric's anchors are defective (X / 17)" when the right report is "the rubric is wholesale-undecidable for this fixture (X−4 / 17 defect, 4 wholesale separately)" — same rate, different fix (rewrite anchors vs rewrite the rubric).
      anchor: "| `empty` (3) confirmed by a repeat | +4 | counts | **REJECT** for that fixture |"
      evidence: experiments/E-001-rubric-null-rate.md:317
  non_blocking:
    - reason: The "exactly one dimension" claim for the three non-test variants is asserted (line 187) but verified in the worksheet only for the two test variants. The artifact points to `fixture-notes/` for the assignments (line 50) but does not summarize the verification, so a reader cannot confirm from the artifact alone that e.g. `good-inline-envelope` depresses only `architecture-consistency` and not also `maintainability`. If it depresses both, the `maintainability` discrimination test has two candidate causes.
      evidence: experiments/E-001-rubric-null-rate.md:50,187; experiments/E-001-prediction-worksheet.md:33-37
    - reason: The "went hunting" exclusion defines the failure mode but names no automated check. Two reviewers applying it to the same output could split on edge cases (citation to a file present in both fixture and baseline; paraphrase with no path; citation to the rubric file attached via `-f`). The artifact's own framework elsewhere annotates controls L1/L2/L3; this exclusion has no annotation, consistent with L3, but the artifact says "a rate without its exclusion count is not a result" — which the L3 check cannot guarantee.
      evidence: experiments/E-001-rubric-null-rate.md:278
    - reason: The KEEP condition's third clause ("the non-↓ cells in that column are equal to each other") does not handle structural nulls in the `test-quality` column, where three of four non-↓ cells are structural nulls. The artifact flags this column as a two-cell pair (line 61, worksheet line 60) but the suggested condition is a TODO (line 304) explicitly inviting the author to refine it.
      evidence: experiments/E-001-rubric-null-rate.md:61,297-299
    - reason: The worksheet's decidability question (line 16) was written before Decision B (lines 105–131) and not updated. A reader filling the grid from the question alone judges without `known-good` in the evidence set; a reader who has read Decision B judges with it. The main record does describe Decision B (line 119, lines 135–139), so a reader who reads the main record first has the right framing. The defect is in the worksheet's ordering, not in the substance.
      evidence: experiments/E-001-prediction-worksheet.md:16,105-131
  disputed: []
  needed_to_decide: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Independent variable | 1/1 | L3 |
| Exclusions | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| The question for every cell | 1/1 | L3 |


---

## Run 1 of 1


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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Independent variable
**Verdict:** finding
**Failure:** The artifact asserts "each of the five variants differs from `known-good` on exactly one dimension" and that "an observed score difference has one candidate cause." The worksheet verifies this for the two test variants (production code byte-identical to `known-good`), but does not verify it for the three non-test variants. `good-inline-envelope` is described as "builds the envelope by hand, returns `ResponseEntity` instead of throwing" and assigned to depress `architecture-consistency`. A reviewer who reads that description as a maintainability defect (hand-rolled code is harder to maintain) rather than — or in addition to — an architecture-consistency defect would expect the `maintainability` column to have two depressed cells (`good-inline-envelope` and `good-nested-ifs`), not one. The discrimination test for `maintainability` ("`good-nested-ifs` below the other four") is then confounded: if `good-inline-envelope` also scores low on `maintainability`, the "non-↓ cells are equal" half of the KEEP condition fails for a reason that is a fixture-design issue, not a rubric defect. Two reviewers — one who trusts the `fixture-notes/` assignment and one who reads the inline-envelope description as cross-cutting — would predict different null rates and different discrimination outcomes for the same column.
**Layer of the implied fix:** L3
**Anchor:** "Each of the five variants differs from `known-good` on exactly one dimension, which is the property benchmarks#10 was built to provide — an observed score difference has one candidate cause."

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

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
**Verdict:** finding
**Failure:** The "went hunting" exclusion drops a cell from the denominator when "the scorer's `evidence` cites a file not in the attachment set." The attachment set is defined (fixture `.kt` files + `known-good` `.kt` files), but the detection mechanism is unspecified. No script is named; no check is automated. A human reads the scorer's evidence field and decides whether a cited path is inside or outside the set. Two reviewers applying this to the same output would split on edge cases: a citation to `ShipmentController.kt` without a fixture prefix (both the fixture and `known-good` have this file), a paraphrase of file content with no path at all, or a citation to the rubric file (attached via `-f` but not source evidence). The strict reviewer excludes the cell, shrinking the denominator and changing the rate; the lenient reviewer keeps it. The artifact says "a rate without its exclusion count is not a result" but does not standardize the check that produces the count, so the same output yields different exclusion counts — and different rates — under different reviewers.
**Layer of the implied fix:** L3
**Anchor:** "A cell where the scorer's `evidence` cites a file not in the attachment set — it went hunting, and the result is not from the evidence it was given"

### Decision rule
**Verdict:** finding
**Failure:** The arithmetic table row "empty (3) confirmed by a repeat" records `+4` in the nulls numerator and `counts` in the denominator — the same contribution as four individually-null cells. But the cell boundary statement in the Question section says: "Twenty-four nulls is a result and is scored as twenty-four nulls; it is not 'no output'. 'No output' means no `categories:` block at all, and that is a different class with a different exit code." An "empty" (exit 3) fixture has no `categories:` block — it is "no output," which the cell boundary explicitly distinguishes from nulls. The arithmetic table silently erases that distinction by treating "no output confirmed" as four nulls. Two reviewers reporting the same run would produce different findings: one reports "6 / 17 (0 excluded), of which 4 are wholesale-undecidable" and the other reports "6 / 17 (0 excluded)" — identical rate, different conclusion about whether the rubric's anchors are defective or the rubric is wholesale-undecidable for that fixture. The per-fixture REJECT verdict is separate, but the +4 feeds the rubric-level rate, and the artifact does not say to break it out.

Separately, the suggested KEEP condition's third clause — "the non-↓ cells in that column are equal to each other" — does not account for structural nulls. In the `test-quality` column, three of the four non-↓ cells are structural nulls (no test file). A reviewer who reads "equal" as requiring identical values would see {2, null, null, null} and fail the clause; a reviewer who reads "equal among scoreable cells" would see a single non-↓ scoreable cell and trivially pass. The suggestion is a TODO, but it is the template the author will register, and the structural-null case is the one column where the discrimination test is a two-cell pair.
**Layer of the implied fix:** L3
**Anchor:** "| `empty` (3) confirmed by a repeat | +4 | counts | **REJECT** for that fixture |"

### The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observed telemetry
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** skipped
**Failure:** n/a — post-run section, empty by design.
**Layer of the implied fix:** n/a
**Anchor:** n/a

---

### The question for every cell
**Verdict:** finding
**Failure:** The worksheet's decidability question says "Given **only** the `.kt` files under this one fixture — no diff, no `known-good` beside it, no test runner, no evaluator output." Decision B, later in the same worksheet, says "`opencode-score.sh` attaches the `known-good` tree alongside the fixture, so a change is visible and the anchor can be cited at `path:line` in both trees." The question was written before Decision B and was not updated. A reader filling the grid from the question judges decidability without `known-good` in the evidence set; a reader who has read Decision B judges with `known-good` present. For `change-focus` this flips the prediction: without `known-good` there is no diff to see, so the cell looks undecidable; with `known-good` the diff is visible, so it is scoreable. For `architecture-consistency` and `maintainability` the question says "judge this submission" but the actual condition is "spot the difference against the baseline" — a different and easier task. Two readers filling the same grid from the same worksheet would predict different null rates for at least three of the four categories.
**Layer of the implied fix:** L3
**Anchor:** "Given **only** the `.kt` files under this one fixture — no diff, no `known-good` beside it, no test runner, no evaluator output — can this category's anchor separate a 0 from a 1 from a 2, and can I cite `path:line` for the answer?"

### What each fixture actually hands the scorer
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The grid — 20 cells
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Two decisions that move whole rows before you count
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Prediction 2 — discrimination
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Prediction 3 — agreement with your blind scores
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The mechanism
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The deterministic evaluation section explicitly drops `functional-correctness` and `requirement-completeness` from the rubric because `evaluator.sh` owns them. The four remaining categories (architecture-consistency, maintainability, test-quality, change-focus) are not pass/fail gates. The `test-quality` precondition (null when no test file) is a decidability rule, not a gate — it does not assert the tests are bad, it says the category is undecidable.
- **Which single section would two reviewers diverge on most, and by how much?** The worksheet's "The question for every cell" — one reviewer reads it in isolation and fills the grid without `known-good` in the evidence set; the other has read Decision B and fills it with `known-good` present. This flips the predicted null rate for `change-focus` (4 of the 17 scoreable cells) and changes the decidability judgment for `architecture-consistency` and `maintainability` (8 more). Thirteen of seventeen cells are affected by which condition the reviewer assumes. The divergence is large because the contradiction is within the same document and unflagged.
- **What did the artifact not say that it needed to say?** The "exactly one dimension" claim for the non-test variants is asserted but not demonstrated. The dimension assignments live in `fixture-notes/` outside the scorer's glob, and the artifact points there but does not quote or summarize the justification. A reader cannot verify from the artifact alone that `good-inline-envelope` depresses only `architecture-consistency` and not also `maintainability` — and if it depresses both, the independent variable is confounded and the discrimination test for `maintainability` has two candidate causes instead of one.
