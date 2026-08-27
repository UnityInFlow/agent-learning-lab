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
reviewed_utc:    20260827T124519Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  c30edb033237
lab_head:        ee0d49a
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: Four internal contradictions or omissions that would mislead anyone filling the TODOs and running it: MDE denominator is 20 cells while Predictions registers 24; the output guard and Exclusions both discard exactly the wholesale-empty-body outcome the evidence table documents as a rubric defect; the Question section enumerates only two of three observed failure modes; the decision rule's KEEP condition drops the "equal elsewhere" half of the discrimination prediction.
  blocking:
    - reason: The MDE table registers the null-rate denominator as 20 cells while Predictions registers it as 24 cells (with an explicit paragraph justifying the inclusion of `known-good`), so the decision rule's "null rate at or under your predicted number" threshold flips depending on which denominator a reviewer reads first.
      wrong_action: On an observed 8 nulls the rate is 33% (24-base) or 40% (20-base); two reviewers applying the same data to the same rule reach KEEP vs REJECT purely from picking a denominator.
      anchor: "secondary: null rate across the 20 cells"
      evidence: experiments/E-001-rubric-null-rate.md:134
    - reason: The output guard (line 104) and the Exclusions (line 157) both classify "exits 0 with no scores" as infrastructure to discard, but the evidence table documents this exact outcome as a rubric defect (seven-category rubric emitted an empty body — "Not a bad score. Nothing"). The harness discards the very signal the experiment is designed to detect, and the Question section's mode set has no bucket for it anyway.
      wrong_action: A run where the four-category rubric makes the scorer emit an empty or all-null sheet is re-run as a broken script and never recorded as the experiment's primary detectable phenomenon — the experiment's most informative signal is thrown away by its own harness.
      anchor: "The script fails the run when opencode exits 0 having produced no scores, rather than reporting an empty success"
      evidence: experiments/E-001-rubric-null-rate.md:104
    - reason: The Question section enumerates two failure modes (Undecidable, Constant) but the evidence table documents a third distinct outcome — wholesale empty body, neither a per-cell null nor a constant — and the decision rule's KEEP/REJECT/INCONCLUSIVE trichotomy has no registered slot for it.
      wrong_action: A reviewer encountering an empty or all-null sheet has no place in the decision rule to file it; the same sheet could be classified as a rubric defect, as infrastructure, or as an unregistered new mode, yielding three different verdicts on identical data.
      anchor: "Two failure modes, and they are not the same: - **Undecidable** … - **Constant** …"
      evidence: experiments/E-001-rubric-null-rate.md:21
    - reason: The decision rule's KEEP condition is "each fixture scores below known-good on its own dimension" while the discrimination prediction is "scores lower than known-good on that dimension and equal elsewhere" — a globally worse fixture (lower on all four categories) satisfies KEEP but fails the discrimination definition the rule is supposed to operationalize. The artifact labels the rule a "suggested shape, not an answer," but it is the only registered shape.
      wrong_action: A reader applying the decision rule would KEEP a rubric whose anchor truly discriminates nothing (every fixture is lower because every fixture is worse), while the discrimination prediction the rule operationalizes would REJECT the same rubric on the same data.
      anchor: "KEEP         if the null rate is at or under your predicted number AND each fixture scores below known-good on its own dimension"
      evidence: experiments/E-001-rubric-null-rate.md:166
  non_blocking:
    - reason: The Runs section's lower-bound justification transfers the critic's 2/12 section-run disagreement rate to the scorer without establishing the analogy; the artifact itself names both instruments (`opencode-score.sh` and `opencode-review.sh`) in the same sentence, but the under-reporting claim has not been demonstrated for the scorer specifically.
      evidence: experiments/E-001-rubric-null-rate.md:127
    - reason: The boundary "exits 0 with no scores" is undefined at the cell level — a sheet of score:null entries is "scores present but null" to a YAML parser and "no scores" to the output guard, so the harness's pass/fail boundary and the experiment's finding/infra boundary both depend on a distinction the artifact never defines.
      evidence: experiments/E-001-rubric-null-rate.md:104
    - reason: The Exclusions' "evidence cites a file not in attachment set" check is L3 with no executor and an undefined boundary — reviewer disagreement on what counts as "hunting" (noting the absence of tests in a no-test fixture, citing the rubric's own anchor text, citing a *.kt file present in the fixture but not in the 2–3 files actually attached) is unresolvable from the registered text.
      evidence: experiments/E-001-rubric-null-rate.md:159
  disputed:
    - finding: The line-level pass's Exclusions finding claims the rubric and agent definition are part of the scorer's "attachment set" such that citing them would not be "hunting"
      why: The artifact defines the attachment set as "*.kt under the fixture — nothing else" in the evidence table; the rubric and agent are inputs, not attachments. The broader concern that the hunting boundary is undefined stands, but the specific claim that the rubric is part of the attachment set is not supported by the artifact text — and Reviewer B's stated basis ("the rubric was provided; the file is in the fixture") collapses once the attachment-set definition is read.
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Question | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Runs | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L1 |
| Exclusions | 1/1 | L2 |
| Decision rule | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### Question
**Verdict:** finding
**Failure:** The Question registers exactly two failure modes — per-cell `Undecidable` and `Constant`. The Evidence table on file records a third, distinct outcome: the seven-category rubric made the scorer "emit an empty body. Not a bad score. Nothing." That is neither a per-cell null (there is no cell) nor a constant (there is no score to be constant). A run that reproduces this wholesale-empty-body outcome has no registered interpretation. Reviewer A reads it as the `Undecidable` mode at the sheet level and files it as a rubric defect; Reviewer B reads it as infrastructure (the scorer produced nothing) and re-runs; Reviewer C reads it as a new mode not covered by the decision rule and declares INCONCLUSIVE. Three reviewers, three verdicts on the same output — because the Question's mode set excludes an outcome its own evidence says has happened.
**Layer of the implied fix:** L3
**Anchor:** "Two failure modes, and they are not the same: - **Undecidable** … - **Constant** …"

### Hypothesis
**Verdict:** no finding
**Failure:** n/a — the section is an empty TODO under an explicitly blocked experiment, and the block is declared in the status header.
**Layer of the implied fix:** L3
**Anchor:** "<!-- TODO — yours. What do you predict, and BY WHAT MECHANISM? … -->"

### Predictions
**Verdict:** no finding
**Failure:** n/a — empty TODOs under a registered block. The 24-cell denominator established here is internally consistent with the "six, not five" justification; the defect against it lives in Minimum detectable effect.
**Layer of the implied fix:** L3
**Anchor:** "Of the 4 categories × 6 fixtures = **24 cells**, how many come back `null`?"

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** L3
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The output guard fails the run when opencode "exits 0 having produced no scores," and the Exclusions register classifies that same signal as "infrastructure, re-run, do not score." The experiment's own prior evidence (the seven-category empty body) shows the scorer can produce exactly this signal as a rubric defect, not as infra. Run the four-category rubric; all four categories cite facts the scorer cannot see; the scorer emits an empty/all-null sheet. The output guard fires, the exclusion says re-run as infrastructure, and the run is discarded — the harness has thrown away the experiment's primary detectable phenomenon and labeled it a broken script. Nothing in the harness distinguishes "scorer nulled wholesale (rubric undecidable, a finding)" from "scorer crashed (infra, discard)." Secondary: the "Control assertion — fresh session every run, never `--continue`" sits in the same table as two L2 guards (preflight, output guard) that actually execute, but nothing executes to reject a `--continue` invocation; its layer is ambiguous, and a reviewer may treat it as enforced when it is L3.
**Layer of the implied fix:** L2
**Anchor:** "The script fails the run when opencode exits 0 having produced no scores, rather than reporting an empty success"

### Controlled variables
**Verdict:** no finding
**Failure:** n/a — the unchecked items (rubric sha, blind scores) are the declared block, not a hidden gap.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Runs
**Verdict:** finding
**Failure:** The section justifies a single-run-is-a-lower-bound concern by citing "The critic disagreed with itself on 2 of 12 section-runs at temperature 0." That 2/12 figure is from the critic (`opencode-review.sh`), a different instrument from the scorer (`opencode-score.sh`). The artifact transfers the critic's under-reporting rate to the scorer without establishing they share a failure mode. Reviewer A reads 2/12 as evidence the scorer also under-reports and demands N≥2 per fixture (which the script cannot do — it has no `-n`); Reviewer B reads it as critic-specific and runs once. On a fixture where the scorer's single run misses a discrimination signal, A catches it and B does not — the divergence is caused by an unexamined analogy between two instruments, not by data.
**Layer of the implied fix:** L3
**Anchor:** "The critic disagreed with itself on 2 of 12 section-runs at temperature 0, so a single run is a lower bound rather than a value."

### Minimum detectable effect
**Verdict:** finding
**Failure:** The MDE table measures the secondary outcome as "null rate across the 20 cells." Predictions item 1 defines the null-rate denominator as "4 categories × 6 fixtures = 24 cells," with an explicit paragraph justifying the inclusion of `known-good`. 20 = 5×4 excludes `known-good`; 24 = 6×4 includes it. On an observed 8 nulls, the rate is 33% (24-base) or 40% (20-base). The decision rule keys off "null rate at or under your predicted number," so the threshold flips with the denominator a reviewer chooses. Two reviewers applying the same data to the same rule reach KEEP vs REJECT because the pre-registration names two different denominators for the same quantity.
**Layer of the implied fix:** L1
**Anchor:** "secondary: null rate across the 20 cells"

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a — the absence of a deterministic evaluator is stated and justified as the experiment's reason for existing.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Exclusions
**Verdict:** finding
**Failure:** The third exclusion — "evidence cites a file not in the attachment set — it went hunting" — is a manual check with no named executor and an undefined boundary. The attachment set is "`*.kt` under the fixture — nothing else," but the scorer is also handed the rubric YAML and the agent definition as inputs, and has read-ish tools ON. When the scorer cites the rubric's own anchor text, or cites a `*.kt` file present in the fixture directory but not in the 2–3 files actually attached, Reviewer A excludes the cell (not in `*.kt` attachment), Reviewer B keeps it (the rubric was provided; the file is in the fixture). The exclusion also cannot distinguish "scorer noted the absence of tests" (a legitimate observation about a no-test fixture) from "scorer went hunting" — both reference files not in the attachment set. Nothing executes to make this determination; it is L3 presented as a gate.
**Layer of the implied fix:** L2
**Anchor:** "A cell where the scorer's `evidence` cites a file not in the attachment set — it went hunting, and the result is not from the evidence it was given"

### Decision rule
**Verdict:** finding
**Failure:** The suggested KEEP condition is "each fixture scores below known-good on its own dimension." Predictions item 2 defines discrimination as "scores lower than known-good on that dimension and equal elsewhere." The decision rule drops the "equal elsewhere" half. A fixture that is globally worse — lower on its own dimension AND lower on the other three — satisfies the decision rule's KEEP (it is below known-good on its dimension) but fails the prediction's discrimination criterion (it does not match elsewhere; the score difference has more than one candidate cause). Reviewer A applying the decision rule keeps the rubric; Reviewer B applying the prediction's definition rejects it as non-discriminating. The rule and the prediction it is supposed to operationalize are misaligned on the same axis. (Noted: this is a commented "suggested shape, not an answer," but it is the only registered shape.)
**Layer of the implied fix:** L3
**Anchor:** "KEEP         if the null rate is at or under your predicted number AND each fixture scores below known-good on its own dimension"

### The procedure, from #21
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** L3
**Anchor:** n/a

### Observed telemetry
**Verdict:** skipped
**Failure:** n/a — post-run section, empty because the experiment is blocked and unrun.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Results
**Verdict:** skipped
**Failure:** n/a — post-run section, empty.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Which predictions held
**Verdict:** skipped
**Failure:** n/a — post-run section, empty; also the predictions themselves are unwritten.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Failure analysis
**Verdict:** skipped
**Failure:** n/a — post-run section, empty.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Sanity checks
**Verdict:** no finding
**Failure:** n/a — the three checks (dramatic number, flattering number disbelieved twice, suspicious scorer agreement) directly address the labels-in-fixtures and read-your-scores confounds declared elsewhere. The "disbelieved twice" and "check whether it read your scores" items are the right guards for this experiment's specific flattery risk.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Decision
**Verdict:** skipped
**Failure:** n/a — post-run section, empty.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Follow-up
**Verdict:** skipped
**Failure:** n/a — post-run section, empty.
**Layer of the implied fix:** L3
**Anchor:** n/a

### Cross-cutting
- The Exclusions' "exits 0 with no scores → infrastructure, re-run" gate and the Question's `Undecidable` mode overlap on the wholesale-empty-body outcome: the gate is registered to discard exactly the signal the Question is trying to detect. The output guard (L2) executes the discard; the Question's mode (L3) has no executor. The gate wins by default.
- Most divergence: **Minimum detectable effect** — the 20-vs-24 denominator is a single integer that flips the decision rule's threshold, and neither reviewer has a textual basis to pick one over the other (Predictions justifies 24; MDE asserts 20 with no justification). I would expect two reviewers to land on different denominators and opposite KEEP/REJECT verdicts on the same data.
- The artifact did not say what "no scores" means at the cell level: a sheet of `score: null` entries is "scores present but null" to a YAML parser and "no scores" to the output guard. The harness's pass/fail boundary and the experiment's finding/infra boundary both depend on that undefined distinction.
