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
reviewed_utc:    20260827T142726Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  0c6c8aa95724
lab_head:        97bed29
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: The artifact self-declares two pre-run blockers (rubric unwritten, predictions empty), and contains an internal arithmetic contradiction: line 158 says "four cells" are predicted structural nulls while the same bullet opens with "three of the five variants" and both the MDE table and the decision rule register 3 — a contradiction that shifts the defect-null denominator from 17 to 16.
  blocking:
    - reason: Line 158 says "Those four cells are predicted nulls" but the same bullet opens with "three of the five variants" and both the MDE table (line 253) and the decision rule (line 306) register 3 structural nulls. The defect-null denominator becomes 16 (20 − 4) instead of the registered 17 (20 − 3).
      wrong_action: A reviewer computing the defect-null rate divides by 16 instead of 17. On borderline data (e.g., 2 observed defect nulls: 2/17 = 11.8% KEEP vs 2/16 = 12.5% REJECT) the KEEP/REJECT verdict flips on identical observations.
      anchor: "Those four cells are *predicted* nulls, not guaranteed ones: the precondition is YAML read by a model, nothing executes to reject a `0`"
      evidence: experiments/E-001-rubric-null-rate.md:158
  non_blocking:
    - reason: Line 116 uses "Twenty-four nulls" illustratively inside a section about the cell-boundary concept ("whatever is in the cells"), while the canonical denominator is 20 at lines 34, 253, 303, and 306. Confusing but the canonical statement is consistent.
      evidence: experiments/E-001-rubric-null-rate.md:116
    - reason: The hunting exclusion at line 293 is defined by cited-evidence symptom, but the scorer has read tools ON and could read fixture-notes/ without citing them. The exclusion is missing the L-level label the artifact explicitly applies to a similar L3 control at line 213 ("L1 through this script, L3 outside it").
      evidence: experiments/E-001-rubric-null-rate.md:293
    - reason: The decision rule's REJECT condition "if any category is constant across all five variants" is ambiguous for test-quality (3 nulls, 2 scoreable cells). The TODO at line 309 acknowledges the rule needs author work, but the ambiguity is in the suggested shape itself — null-counting convention is not specified.
      evidence: experiments/E-001-rubric-null-rate.md:316
    - reason: The artifact explicitly names two unresolved pre-run blockers (rubric rewrite pending in lab#21; predictions empty) and records "do not run" decisions against them at lines 9–17.
      evidence: experiments/E-001-rubric-null-rate.md:9-17
  disputed:
    - finding: "Two reviewers computing the null rate from the same sheet would divide by different denominators" (line-level finding on line 116, Question section)
      why: Line 116 sits inside "A sheet is a sheet when … *whatever is in the cells*. Twenty-four nulls is a result and is scored as twenty-four nulls" — the number is illustrative of the cell-boundary concept, not a claim about this sheet's size. The canonical denominator of 20 is restated at lines 34, 253, 303, and 306; a reader who reaches the decision rule gets the right number.
  needed_to_decide: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Question | 1/1 | L3 |
| Hypothesis | 1/1 | L3 |
| Exclusions | 1/1 | L2 |
| Decision rule | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### Question
**Verdict:** finding
**Failure:** Line 116 says "Twenty-four nulls is a result and is scored as twenty-four nulls." The current denominator is 20 (4 × 5, `known-good` excluded), stated in the decision rule (line 303) and the MDE table (line 253). "Twenty-four" is a leftover from the superseded 24-cell population. A reviewer who reads it as a current claim about the sheet size now believes the denominator is 24, contradicting the 20 registered elsewhere. Two reviewers computing the null rate from the same sheet would divide by different denominators.
**Layer of the implied fix:** L3
**Anchor:** "Twenty-four nulls is a result and is scored as twenty-four nulls; it is not "no output"."

### Hypothesis
**Verdict:** finding
**Failure:** Line 158 says "Those four cells are predicted nulls" in the context of `test-quality` cells with no test file. The grid (line 42–46) marks 3 such cells with **S**. The decision rule (line 306) says "3 are structurally null." The MDE table (line 253) says "predicted at 3 of 20." The "four" counts `known-good`, which left the scored population — a stale count from the 24-cell version. A reviewer who latches onto "four" computes the defect-null denominator as 16, not 17. If the observed defect-null count is 2 and the KEEP threshold is 12%, the rate is 2/17 = 11.8% (KEEP) or 2/16 = 12.5% (REJECT) — the verdict flips on the same data.
**Layer of the implied fix:** L3
**Anchor:** "Those four cells are predicted nulls, not guaranteed ones: the precondition is YAML read by a model, nothing executes to reject a 0"

### Predictions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

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
**Failure:** The hunting exclusion (line 293) says "a cell where the scorer's evidence cites a file not in the attachment set — it went hunting." The detection mechanism is unspecified — no script, no check, no procedure. The scorer has read-ish tools ON (line 134), so it can read files outside the attachment set. The exclusion only fires if the scorer *cites* an outside file. If it reads `fixture-notes/good-nested-ifs.md` (outside the scorer's glob but accessible via tools), learns the variant depresses maintainability, then scores maintainability low while citing only the fixture's Kotlin source, the evidence looks legitimate and the hunting exclusion does not fire. Two reviewers inspecting the same score sheet would diverge: one trusts the citation at face value, the other suspects tool-assisted label leakage and excludes the cell. The denominator changes by 1, and on a 17-cell base that is a 6% swing.
**Layer of the implied fix:** L2
**Anchor:** "A cell where the scorer's evidence cites a file not in the attachment set — it went hunting, and the result is not from the evidence it was given"

### Decision rule
**Verdict:** finding
**Failure:** The suggested REJECT condition (line 316) says "if any category is constant across all five variants." `test-quality` has 3 structural nulls and only 2 scoreable cells. "Constant across all five" is ambiguous: does it mean all 5 cells including nulls (null ≠ 2, so never constant — the condition can never fire for this category), or all non-null cells (both test variants score 2 — constant, REJECT)? One reviewer reads `test-quality` as exempt from the constant check because 3 cells are null; the other reads a 2-of-2 tie as constant and rejects. They reach different verdicts on the same sheet. The condition is in a TODO marked "suggested shape, not an answer," but the ambiguity is in the shape itself and would carry into whatever the author registers.
**Layer of the implied fix:** L3
**Anchor:** "REJECT       if any category is constant across all five variants — it carries no information regardless of how defensible its anchors read"

### The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observed telemetry
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** skipped
**Failure:** Empty by design — filled after runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The artifact explicitly dropped `functional-correctness` and `requirement-completeness` because "the gates own them" (CLAUDE.md). The four remaining categories — architecture-consistency, maintainability, test-quality, change-focus — measure properties the deterministic evaluator does not assess. The `evaluator.sh` gate and the rubric are disjoint.
- Which single section would two reviewers diverge on most, and by how much? **Exclusions**, on the hunting clause. The scorer has tools ON, the attachment set is filesystem-resident alongside `fixture-notes/`, and the exclusion only triggers on cited evidence. The gap between "the scorer cited only attached files" and "the scorer only *used* attached files" is where two reviewers would split — one treating the citation list as sufficient, the other treating tool access as a contamination risk. The swing is 1 cell on a 17-cell base, which is enough to flip a borderline verdict.
- What did the artifact not say that it needed to say? How hunting is detected. The exclusion is defined by its symptom (a citation to an outside file) but the scorer can read outside files without citing them, and nothing in the artifact names the check that would catch that — a script, a tool-log inspection, a sandbox, or a manual procedure. Without it, the exclusion is a rule with no enforcement path, and the reader is left to assume the citation list is exhaustive evidence of what the scorer read.
