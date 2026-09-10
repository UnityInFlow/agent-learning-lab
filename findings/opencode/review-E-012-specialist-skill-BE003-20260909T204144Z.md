# opencode review — E-012-specialist-skill-BE003

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
reviewed_utc:    20260909T204144Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-012-specialist-skill-BE003.md
    sha:  373945e3c191
    dirty: false
lab_head:        dc27b82
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-012-specialist-skill-BE003.md
  verdict: ACCEPT
  summary: Comprehensive experiment writeup; the registered verdict (KEEP, test-quality anchor 2 at 10 of 10 vs 0 of 10, p = 1.08 × 10⁻⁵, second reader unanimous on three of four categories) is well-supported. Documentation defects flagged by the line-level pass are real but non-blocking: they affect completeness or consistency of disclosure, not the measured outcome.
  blocking: []
  non_blocking:
    - reason: "Threats to validity Threat 5 states \"Both arms carry phases-v1.0, so this stop inherits its defects, including the DONE completion contract leaking at 2 in 10. That is a controlled variable here, not a confound.\" The arms actually carried the carrier (agentHash 51ffaedf9a3edbfe…, five tools including Skill), and the DONE-leak rate at 2 in 10 was measured on phases-v1.0, not on the carrier. A reader could record DONE-leak at 2 in 10 as a measured property of both arms when it is unmeasured on the carrier; the §4a review at line 803 supplied SUPERSEDED blocks to the three sections above this one but did not flag it here."
      evidence: experiments/E-012-specialist-skill-BE003.md:228
    - reason: "Decision section cites BE-004's p-value (p = 0.0031) and count alongside BE-003's in a file that opens by declaring \"No verdict is computed across the two files.\" The §4a review fixed the inverse pattern in E-013 but did not flag E-012's analogous defect (the §4a review table at line 805 documents the asymmetry). The disclaimer (\"two tasks registered separately with no verdict computed across them\") is in the same paragraph."
      evidence: experiments/E-012-specialist-skill-BE003.md:771
    - reason: "The note below the decision-rule table defines \"improved\" as \"the registered outcome P2 moved in the predicted direction by at least the MDE,\" but P2 predicts downward (≤ 4 of 10) while the MDE table is calibrated upward (≥ 7 of 10). The decision-rule table itself uses unambiguous raw counts and the verdict on this batch (10 of 10, row 1, CONFIRM) is unaffected."
      evidence: experiments/E-012-specialist-skill-BE003.md:210
    - reason: "§4 step 9 deliberate failure moved from skill-alone (Amendment registration, \"and nowhere else\") to the carrier (file-end completion) with a justification (\"the only configuration in which a skill can be selected at all\") that the artifact's own selection-rate probe contradicts (4 of 5 in both configurations). Outcome (0 of 3 activations) is the same either way."
      evidence: experiments/E-012-specialist-skill-BE003.md:435-439; selection-rate probe at line 462-471
    - reason: "Results section remains the unedited placeholder; per-arm medians appear in \"Which predictions held\" (P4 median $0.1309 vs $0.1211; P5 median 22.5 vs 20.5) without ranges (quartiles/IQR/min-max), against the placeholder's own standard \"Median and range, never a mean alone.\" Spread exists in the manifests (referenced at line 758)."
      evidence: experiments/E-012-specialist-skill-BE003.md:308; medians at line 668-678
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 165s |
| ollama-cloud/glm-5.2 | ok | 197s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Threats to validity, registered before the run | 1/1 | L3 |
| §4a review round 1 — what the acceptance gate rejected, and what was done about each finding | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Deliberate failure — registered here, run at §4 step 9 | 1/1 | L3 |
| Results | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

→ Read experiments/E-012-specialist-skill-BE003.md [offset=807]
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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The SUPERSEDED block at the head of this section correctly marks the original text as describing a carrier that was not run, and points to the Amendment. The claim "This is the cleanest single-variable comparison this project has registered" was written about a four-tool configuration that was never run, but the supersession makes that clear.

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

The MDE was calibrated against a historical control of 1 of 10; the actual concurrent control was 0 of 10. This makes the registered thresholds conservative (a treated count of 5 would clear `p < 0.05` against 0 but is tabled as "not detectable" against 1). The §4a review at the end of the file accepts this as a real design lesson and notes it cannot have manufactured a false positive. The observed 10 of 10 is above every threshold in the table. Adequately disclosed.

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule, fixed before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Row 4 ("treated is strictly below the control → REFUTE") is unreachable when the control is 0 of 10, since nothing is strictly below 0. This is a direct consequence of the MDE calibration issue already disclosed in the §4a review (the rule was built against control = 1, the actual control was 0). A skill that scored 0 of 10 against a control of 0 of 10 would correctly fall to row 3 ("NOT DETECTABLE") rather than row 4, because 0-of-10 vs 0-of-10 genuinely cannot distinguish "no effect" from "negative effect" — row 3 is the right verdict for that data. The dead row is a limitation of the design at this `n`, not a misclassification.

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** Threat 5 says "Both arms carry `phases-v1.0`, so this stop inherits its defects, including the `DONE` completion contract leaking at 2 in 10. That is a controlled variable here, not a confound." The batch ran on the carrier (`agentHash 51ffaedf9a3edbfe…`, five tools including `Skill`), not `phases-v1.0` (`agentHash b3450564b6f32d61`, four tools). The Independent variable, delivery, and controlled-variables sections each received a dated `SUPERSEDED IN PART` block correcting the carrier; this section did not. A reader who skips the Amendment reads that the arms carry `phases-v1.0` with its measured `DONE`-leak rate of 2 in 10 as a controlled variable, when the arms carried a different agent definition with a different tool pool. Two reviewers would diverge: one would treat the carrier as "phases-v1.0 plus one line, so the defects carry over" and accept the threat as stated; another would note the `DONE`-leak rate was never measured on the carrier and the tool-pool change (4 → 5 tools) could alter completion behaviour, making the claimed controlled variable unmeasured.
**Layer of the implied fix:** L3
**Anchor:** "Both arms carry `phases-v1.0`, so this stop inherits its defects, including the `DONE` completion contract leaking at 2 in 10. That is a controlled variable here, not a confound."

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The §4a review caught that the first attempt ran `n = 1` skill-alone instead of the registered `n = 3`, and the completion at the end of the file re-runs it at `n = 3` in the carrier configuration with both clauses. The skill-alone run is kept as a fourth observation and explicitly not counted in the `n = 3`.

### §4 step 4 — the build
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Placeholder (`<!-- filled at step 4, including the skill's content hash -->`). The build details and content hash are in the Amendment section. Skipped because there is no content to review.

### §4 step 5 — the preflight pair, and it stopped the stop
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The Amendment at line 327 corrects the section's conclusion that "the agent's tool list is not the cause" as too strong — both blockers (tool list and description) are present. The correction is properly disclosed and the original text is not edited away.

### §4 step 6 — the batch
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Placeholder (`<!-- filled at step 6 -->`). The batch results are in the Amendment subsection "§4 step 6 — the BE-003 batch, and P1" at line 627. Skipped because the content is elsewhere.

### Results
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Placeholder (`<!-- filled at step 8 -->`). Results are in the Amendment subsections. Skipped because the content is elsewhere.

### Which predictions held
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Placeholder (`<!-- filled at step 8 -->`). The predictions table is in the Amendment subsection "Which predictions held" at line 668. Skipped because the content is elsewhere.

### Decision
**Verdict:** skipped
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Placeholder (`<!-- filled at step 10 -->`). The decision is in the Amendment section "## Decision — §4 step 10" at line 767. Skipped because the content is elsewhere.

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The 2×2 probe design (description × tool pool) properly separates the two blockers. Each cell is `n = 1` and is stated as such — "Nothing here is stated as a property." The carrier decision, selection-rate measurement, P1 mis-specification disclosure, hand re-read, batch results, registered scores, prediction verdicts, second-reader comparison, and report gap are all internally consistent. The `maintainability` counter-direction (2 of 10 treated vs 5 of 10 control, `p = 0.35`) is reported in the results, in the predictions section, and in the Decision, with the explicit note that it is not separated at this `n`.

### §4a review round 1 — what the acceptance gate rejected, and what was done about each finding
**Verdict:** finding
**Failure:** The §4a review table lists E-013 #5 (2/2) as "The Decision section cites BE-003 p-values in a file that opens by declaring no verdict is computed across the two tasks" and marks it FIXED — "the Decision section in this file is now BE-004's own, and says where BE-003's identical decision was taken." The same pattern exists in E-012's Decision section (line 771): it cites BE-004's p-value (`p = 0.0031`) and result ("10 of 10 against 3 of 10") in a file that opens by declaring "This experiment covers BE-003 only" and "No verdict is computed across the two files." The §4a review did not flag this for E-012. Two reviewers applying the §4a review's own standard would diverge: one would remove the BE-004 p-values from E-012's Decision and replace them with a reference to E-013's decision (as was done for E-013 in reverse); the other would accept the BE-004 numbers as context because the Decision explicitly says "two tasks registered separately with no verdict computed across them." The disclaimer is the same one the §4a review found insufficient for E-013.
**Layer of the implied fix:** L3
**Anchor:** "test-quality anchor 2: 10 of 10 against 0 of 10 on BE-003 (p = 1.08 × 10⁻⁵) and 10 of 10 against 3 of 10 on BE-004 (p = 0.0031), two tasks registered separately with no verdict computed across them"

### §4 step 9, completed at its registered `n` and in its registered configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The completion runs `n = 3` in the carrier configuration with both registered clauses. Clause 1 (0 of 3 activations) and clause 2 (test-quality not distinguishable from control) both hold. The `n = 1` skill-alone run is kept as a fourth observation and explicitly excluded from the `n = 3`. The `p`-values cited (0.231 for 1-of-3 vs 0-of-10, 0.0385 for 1-of-3 vs 10-of-10) are arithmetically correct.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The decision rule's row 5 (evaluator pass differs by ≥ 3) records a correctness effect "beside whichever row fires and never instead of it," so it does not replace the `check-run-gate.sh` gate. The rubric's `test-quality` category measures anchor 2 attainment, which is not a gate condition.
- **Which single section would two reviewers diverge on most, and by how much?** The Decision section's citation of BE-004 p-values. The §4a review fixed the identical pattern in E-013 at 2/2 recurrence but did not flag it in E-012. A reviewer applying the §4a standard uniformly would call this a defect; a reviewer reading the Decision's own disclaimer ("no verdict computed across them") as sufficient would not. The gap is one full finding — present or absent — not a score difference.
- **What did the artifact not say that it needed to say?** The Threats to validity section needed the same `SUPERSEDED IN PART` block that the three sections above it received. Threat 5's claim that "both arms carry `phases-v1.0`" and its specific citation of the `DONE`-leak rate as a controlled variable are both unmeasured on the carrier that was actually run. The §4a review identified the three sections that needed correction but missed the fourth.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

→ Read experiments/E-012-specialist-skill-BE003.md [offset=807]
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

### Exclusions, registered before the data
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** The note below the table defines "improved" as "the registered outcome P2 moved in the predicted direction by at least the MDE." P2's predicted direction is *downward* (≤ 4 of 10 — the skill does not work). The MDE is 7 of 10 — a threshold for detecting an *upward* effect. One reviewer reads "moved in the predicted direction" as "P2 was right, the count stayed low" (≤ 4, the null). Another reads it as "the skill improved the outcome, the count rose to ≥ 7" (the MDE direction). These are opposite directions, and the sentence does not disambiguate. The decision-rule rows themselves use raw counts and are unambiguous, so the verdict on this batch (10 of 10, row 1, CONFIRM) is not affected — but the note's definition of "improved" is the one a reader carries into the Decision section, and two readers arrive there with opposite understandings of what "improved" means.
**Layer of the implied fix:** L3
**Anchor:** *"improved" in this file means **the registered outcome P2 moved in the predicted direction by at least the MDE**.*

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** finding
**Failure:** The Amendment's §4 step 9 (lines 435–439) states the deliberate failure is run "in the skill-alone configuration and nowhere else," with the justification that skill-alone is "the only configuration in which this skill has ever been recorded activating." The completion at the file's end (lines 813–842) runs it "inside the agent overlay — the carrier" and justifies this as "the only one in which a skill can be selected at all." Both justifications cannot be true: the skill-alone probe `ba8b4b98` activated, and the selection-rate probe showed 4 of 5 in *both* configurations. The heading itself claims "in its registered configuration," but the Amendment had already narrowed the registration to skill-alone. One reviewer reads "registered configuration" as the original section (no configuration specified, so carrier is valid); another reads it as the Amendment's explicit "skill-alone and nowhere else" (so carrier is a deviation). The result — 0 of 3 activations — is the same in both configurations, so the outcome does not change. The defect is that the configuration change is not disclosed as a change, and the completion's stated reason for it is factually wrong on the point that distinguishes it from the Amendment.
**Layer of the implied fix:** L3
**Anchor:** *Why it is run in the skill-alone configuration and nowhere else.* (line 435) vs. *inside the agent overlay — the carrier, which is the agent overlay the batch itself used and the only one in which a skill can be selected at all.* (line 816–817)

### §4 step 4 — the build
**Verdict:** skipped
**Failure:** Empty placeholder, never filled. No content to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair, and it stopped the stop
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch
**Verdict:** skipped
**Failure:** Empty placeholder (`<!-- filled at step 6 -->`). The actual batch results are in the Amendment's `### §4 step 6 — the BE-003 batch, and P1` (line 627), reviewed under the Amendment heading.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** finding
**Failure:** The section is an empty placeholder: `<!-- filled at step 8. Median and range, never a mean alone. -->`. The actual per-arm medians appear in "Which predictions held" (P4: median $0.1309 vs $0.1211; P5: median 22.5 vs 20.5) but report medians only — no ranges (quartiles, IQR, min/max) are given for any continuous outcome. The placeholder's own instruction says "Median and range, never a mean alone," and the results as delivered do not meet it. A reviewer checking whether P4's ±15% band held needs the spread to judge whether the +8.0% median difference is stable or driven by outliers; with only the median, two reviewers could disagree on whether the band is a meaningful summary or a single-point artifact. The cost and turns data exist in the manifests, so this is not missing data — it is a reporting gap against the artifact's own stated standard.
**Layer of the implied fix:** L3
**Anchor:** *<!-- filled at step 8. Median and range, never a mean alone. -->*

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision — §4 step 10
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. Decision-rule row 0 checks the rubric sha and activation count, which are integrity conditions on the scoring instrument, not restatements of a scoring category. The four scored categories (`architecture-consistency`, `maintainability`, `test-quality`, `change-focus`) are distinct from the gate conditions (evaluator pass rate, skill activation, rubric sha).
- **Which single section would two reviewers diverge on most, and by how much?** The "Deliberate failure" section, by a wide margin. The Amendment specifies skill-alone; the completion runs carrier; the heading says "registered configuration"; and the completion's justification ("the only one in which a skill can be selected at all") is contradicted by the artifact's own probe data showing activation in both configurations. One reviewer accepts the carrier as valid because the original registration did not specify a configuration and the result is the same; another rejects it as an undisclosed deviation from the Amendment's explicit narrowing. The result doesn't change (0 activations either way), but whether the registered design was followed does.
- **What did the artifact not say that it needed to say?** The per-arm ranges (quartiles or min/max) for `estimatedCost` and `modelCalls` are absent. The placeholder in Results says "Median and range, never a mean alone," and the medians are reported in "Which predictions held" without any spread. P4 and P5 are band-based predictions on medians, and without the range a reviewer cannot judge whether the band is a robust summary or a single-point artifact — particularly for P4, where the +8.0% is inside a ±15% band but the control's own q1–q3 from the reference population spans $0.1012–$0.1217, a 17% spread.
