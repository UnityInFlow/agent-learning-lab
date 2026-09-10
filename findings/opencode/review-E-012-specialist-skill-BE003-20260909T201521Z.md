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
reviewed_utc:    20260909T201521Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-012-specialist-skill-BE003.md
    sha:  2d11e2570cd7
    dirty: false
lab_head:        874577c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-012-specialist-skill-BE003.md
  verdict: REJECT
  summary: The KEEP verdict is grounded in real measurements (test-quality 10/10 vs 0/10, p = 1.08 × 10⁻⁵), but the pre-Amendment "Independent variable", "How the treatment is delivered", and "Controlled variables" sections describe both arms as carrying `phases-v1.0` with `agentHash sha256:b3450564b6f32d61` and four tools, when the actual batch ran on the carrier overlay `phases-v1.0-skillcarrier/` with `agentHash sha256:51ffaedf9a3edbfe` and five tools; the Amendment additively introduces the carrier but does not mark the top sections as superseded, and the deliberate failure's pre-registered n=3 prediction (with a test-quality clause) is silently re-registered at n=1 with only activations tested.
  blocking:
    - reason: The "Independent variable", "How the treatment is delivered", and "Controlled variables" sections make present-tense factual claims about both arms carrying `phases-v1.0` with `agentHash sha256:b3450564b6f32d61` and four tools `["Read","Edit","Write","Bash"]`, but the actual batch (§4 step 6) ran on the carrier overlay with `agentHash sha256:51ffaedf9a3edbfe` and five tools (Skill added).
      wrong_action: A replayer following the top would set up `phases-v1.0` + SKILL.md, get 0 activations because v1.0 lacks the Skill tool, and report a void — the opposite of the artifact's measured 10/10 activations on the carrier.
      anchor: "Both arms carry `phases-v1.0` (agent `backend-feature-phases`, overlay sha256 `b3450564b6f32d6193e8580db766210e`), the same model, the same benchmark tree and the same evaluator."
      evidence: experiments/E-012-specialist-skill-BE003.md:77-79
    - reason: The "Deliberate failure" section registers n=3 with two clauses (activations AND test-quality), but the Amendment (§4 step 9, lines 396-422) re-registers at n=1 with only activations tested; the original n=3 prediction is not marked as superseded.
      wrong_action: A reader checking the deliberate failure would see "the prediction committed at 4d3d166 held" (line 458) at n=1, but the original prediction was n=3 with two clauses including test-quality; the test-quality clause was silently dropped without disclosure.
      anchor: "**Prediction:** activation falls to **0 of 3** while the file remains on disk and readable, and `test-quality` stays at the control's level."
      evidence: experiments/E-012-specialist-skill-BE003.md:201-202
  non_blocking:
    - reason: The decision rule's MDE threshold is calibrated against a reference population of control=1/10 (stop 12), but the actual concurrent control came in at 0/10; against control=0/10, treated counts of 5 and 6 clear p < 0.05 but the rule classifies them as NOT DETECTABLE, and the artifact does not disclose the actual control differed from the reference.
      evidence: experiments/E-012-specialist-skill-BE003.md:124-138
    - reason: The maintainability counter-movement (2/10 treated vs 5/10 control, p=0.35) is recorded but not separated; acknowledged as not answerable at n=10.
      evidence: experiments/E-012-specialist-skill-BE003.md:660-666
    - reason: The P1 mis-specification (conflates delivery with selection) is identified as a finding of this stop but not edited; at the measured 4/5 selection rate, P1's void condition would fire at n=10 while its stated meaning ("the skill was not delivered") is false.
      evidence: experiments/E-012-specialist-skill-BE003.md:438-452
    - reason: The baseline-report instrument is arm-blind and aggregates by experiment key, so the two-arm design's pooled distribution answers no registered question; recorded as an instrument gap.
      evidence: experiments/E-012-specialist-skill-BE003.md:708-732
    - reason: The §4 step 5 instrument defects (guard against wrong quantity, locality bug in `one_run`, log truncation in `run-deliberate-failure.sh`) are all disclosed with mechanism, fix and exclusion by name; the four excluded runs (`4452e08a`, `9402d9fe`, `8a7c7dbf`, `8f9326ee`) are excluded for reasons independent of their outcomes.
      evidence: experiments/E-012-specialist-skill-BE003.md:461-555
  disputed:
    - finding: "Decision rule MDE calibration drift — against control=0/10, a treated count of 5 or 6 clears p < 0.05, but the rule classifies them as NOT DETECTABLE."
      why: The artifact's MDE section (line 124-138) explicitly acknowledges that the design only detects large effects and that 4, 5 or 6 will be reported as "not detectable and never as refuted"; the actual outcome (10/10 vs 0/10) cleared all thresholds, so the KEEP verdict is unaffected. The defect is methodological and applies to future reusers of the rule, not to this experiment's outcome.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 206s |
| ollama-cloud/glm-5.2 | ok | 181s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Decision rule, fixed before the run | 1/1 | L3 |
| Deliberate failure — registered here, run at §4 step 9 | 1/1 | L3 |
| Independent variable | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L3 |
| Controlled variables | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

This section states `agentHash sha256:b3450564b6f32d61, on both arms`, but the actual batch ran on the carrier (`51ffaedf9a3edbfe…`). The Amendment discloses and corrects this under the additive protocol, and the correction is findable by step number. Not a finding against the artifact's own methodology.

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Same pattern as above: the content hash (`0876025fa451…`) is superseded by v1.1 (`7bea904863fb…`) in the Amendment. Disclosed additively.

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Same agentHash supersession as above. The rubric sha, scorer, model, ports, and benchmark pins are all consistent with what the batch actually used.

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

The MDE table is correctly computed against its stated reference population (stop 12, control = 1 of 10). The issue that arises from this calibration is in the Decision rule section, not here.

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
**Failure:** The MDE table and the count thresholds in rows 1–3 are calibrated against a control of **1 of 10** (the stop 12 reference). The actual concurrent control scored **0 of 10**. Against a control of 0, a treated count of 5 gives two-sided Fisher *p* ≈ 0.033 and a treated count of 6 gives *p* ≈ 0.011 — both clear *p* < 0.05. But row 2 classifies 5 or 6 as **NOT DETECTABLE, upper**, and row 1 requires ≥ 7. So a replication that produced 5 or 6 against a control of 0 would be verdicted "not detectable" when the effect is statistically significant. Two reviewers diverge: one follows the pre-registered count threshold (NOT DETECTABLE), the other computes the actual *p*-value against the actual control (detectable). The artifact never notes that the control came in lower than the reference the thresholds were built from.
**Layer of the implied fix:** L3
**Anchor:** `| 1 | test-quality anchor 2 in the treated arm is ≥ 7 of 10 | CONFIRM — the skill removes the failure, p ≤ 0.0198 against the control |`

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Threat 3 (cannot separate "a skill" from "more words") is the right limitation to name, and the separating arm is identified as the author's under §7. Threat 5 says "both arms carry phases-v1.0" which is superseded by the carrier, but this is the same additive-amendment pattern and the threat's substance (inherited defects) is partially preserved.

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** finding
**Failure:** The pre-registration says `n = 3` and predicts `activation falls to 0 of 3 while the file remains on disk and readable, and test-quality stays at the control's level`. The Amendment's §4 step 9 executes **one run** (`81899960`) and reports `0 activations` — and the result section says `The prediction committed at 4d3d166 held`. Two reviewers diverge: one reads "n = 3 was planned, n = 1 was run, the prediction is underpowered and untested"; the other reads "the Amendment re-registered at n = 1 and the result confirms." The artifact never says the sample size changed, and the original prediction's second clause (`test-quality stays at the control's level`) is silently dropped — the result reports only activations, not test-quality.
**Layer of the implied fix:** L3
**Anchor:** `the identical body with a description that names an unrelated domain, n = 3. Prediction: activation falls to 0 of 3 while the file remains on disk and readable, and test-quality stays at the control's level.`

### §4 step 4 — the build
**Verdict:** skipped
**Failure:** n/a — placeholder, filled at step 4.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair, and it stopped the stop
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The original conclusion ("the agent's tool list is not the cause") is too strong, and the Amendment corrects it to "two blockers, not one" with a 2×2 probe that isolates each. The correction is explicit, evidence-backed, and findable by step number. This is the additive-amendment process working as designed.

### §4 step 6 — the batch
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Placeholder in the original; filled by the Amendment at line 594. The batch results (10 of 10 activations treated, 0 of 10 control, all `status: measured`) are clearly reported.

### Results
**Verdict:** skipped
**Failure:** n/a — placeholder, filled at step 8.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Filled by the Amendment at line 635. The table is complete: P1 HELD, P2/P3 REFUTED, P4/P5/P6 HELD. The narrative distinguishes magnitude from direction and names the mechanism change honestly.

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Filled by the Amendment at line 734. KEEP is justified by the measured effect, the carrier/product distinction is explicit, and the maintainability counter-movement is disclosed without being dismissed.

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The correction (two blockers, not one) is well-evidenced by the 2×2 probe. The selection-rate measurement (4 of 5 in both configurations, n = 5 each) is honestly reported and its implication for P1 is stated as a finding of the stop rather than an inconvenience. The three instrument defects (guard against wrong quantity, locality bug, log truncation) are all disclosed with mechanism, fix, and exclusion by name. The §5 hand re-read cites `path:line` for each clause. The second-reader results (60 of 60 on three categories, `change-focus` reproducing its known defect) are reported without overclaiming. The P3 counter bug is disclosed, fixed, and verified. No finding against this section.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. `architecture-consistency` is a constant (10 of 10 at anchor 2 on both arms) but it is not restating the evaluator gate — it carries no information because all gate-passing submissions happen to score the same, not because it re-checks the gate. The artifact notes this: `constant — no information, as at stops 12 and 11`.
- **Which single section would two reviewers diverge on most, and by how much?** The Decision rule. One reviewer treats the pre-registered count thresholds as fixed and conservative (the result was 10 of 10, so the miscalibration is moot); the other treats the thresholds as miscalibrated for the actual control and requiring a post-hoc adjustment or at minimum an acknowledgment. The divergence is wide — it's the difference between "the instrument is valid" and "the instrument's detection threshold is wrong for the data it was applied to."
- **What did the artifact not say that it needed to say?** Two things. First, that the concurrent control (0 of 10) came in below the reference population (1 of 10) the MDE and decision-rule thresholds were derived from, and what that does to the thresholds' calibration. Second, that the deliberate failure's sample size changed from the pre-registered n = 3 to the executed n = 1, and that the original prediction's test-quality clause was dropped.

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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Independent variable
**Verdict:** finding
**Failure:** The section states "Both arms carry `phases-v1.0`" with "the same four tools" and agent hash `b3450564b6f32d61`. The actual batch (Amendment, "What B6 does about it") used a carrier overlay with agent hash `51ffaedf9a3edbfe` and five tools (`Skill` added). A validator checking the batch manifest's `agentHash` against this section would find `51ffaedf` where the text says `b3450564`, and would need to read ~200 lines into the Amendment to learn the carrier replaced `phases-v1.0` on both arms. Two reviewers diverge: one who reads only the pre-Amendment sections believes the batch compared `phases-v1.0`+skill vs `phases-v1.0`; one who reads the Amendment knows it compared carrier+skill vs carrier. The same factual discrepancy appears in "How the treatment is delivered — and proved" (overlay path `skill-v1.0-testing/`, hash `0876025f…` — the batch used `phases-v1.0-skillcarrier/`, hash `7bea9048…`) and in "Controlled variables" (`agentHash sha256:b3450564b6f32d61, on both arms` — the batch used `51ffaedf`).
**Layer of the implied fix:** L3
**Anchor:** "Both arms carry `phases-v1.0` (agent `backend-feature-phases`, overlay sha256 `b3450564b6f32d6193e8580db766210e), the same model, the same benchmark tree and the same evaluator." … "both arms are the *same agent definition* with the *same four tools*."

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Same as "Independent variable." The delivery table specifies overlay `build/customizations/skill-v1.0-testing/`, `SKILL.md` sha `0876025fa451af5f1f2970da67a02f0d`, agent file `b3450564b6f32d61`. The batch that produced the registered scores used overlay `build/customizations/phases-v1.0-skillcarrier/`, `SKILL.md` sha `7bea904863fb79a544ee2068cb2f0f43`, agent file `51ffaedf9a3edbfe`. The Amendment discloses the replacement but this table — the one a reviewer would check against the batch artifacts — describes a treatment that was not the one run.
**Layer of the implied fix:** L3
**Anchor:** "Overlay | `build/customizations/skill-v1.0-testing/` — the phases agent file **byte-identical** to `phases-v1.0` (`diff -q` clean, sha `b3450564b6f32d61`) **plus** `.claude/skills/testing-and-verification/SKILL.md`"

### Controlled variables
**Verdict:** finding
**Failure:** Same factual discrepancy. The table lists `agentHash sha256:b3450564b6f32d61, on both arms` and `instructionsHash: null on both arms`. The batch's manifests report `sha256:51ffaedf9a3edbfe…` on both arms. A validator running `check-run-gate.sh` or a hash comparison against this table would flag a mismatch. The Amendment's own carrier table gives the correct hash, but this table — the registered controlled-variables reference — is wrong for the experiment whose results are reported below it.
**Layer of the implied fix:** L3
**Anchor:** "| Agent overlay | `phases-v1.0`, `agentHash sha256:b3450564b6f32d61`, **on both arms** |"

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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** finding
**Failure:** The section registers the deliberate failure at **n = 3** ("activation falls to **0 of 3**"). The Amendment's §4 step 9 runs it at **n = 1** ("One run, BE-003") and reports "The prediction committed at `4d3d166` held." Two reviewers diverge: one reads "0 of 3" in the registration and "held" in the result, and concludes three runs confirmed 0 activations; the other reads "One run" and concludes a single observation showed 0. At n=1 the claim "the description is the selector; the body is not" rests on one data point plus E-004's prior, not on the registered n=3. The n change is not disclosed anywhere in the artifact.
**Layer of the implied fix:** L3
**Anchor:** "**Prediction:** activation falls to **0 of 3** while the file remains on disk and readable, and `test-quality` stays at the control's level."

### §4 step 4 — the build
**Verdict:** no finding
**Failure:** n/a (placeholder)
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair, and it stopped the stop
**Verdict:** no finding
**Failure:** The section concludes "the agent's tool list is not the cause." The Amendment corrects this to "two blockers, not one" and explains why the original conclusion was too strong. The correction is additive, clearly labeled, and grounded in evidence already on disk. The self-correction is adequate.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch
**Verdict:** no finding
**Failure:** n/a (placeholder, filled by Amendment sub-section)
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** n/a (placeholder, filled by Amendment sub-sections)
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** n/a (placeholder, filled by Amendment sub-section)
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** no finding
**Failure:** n/a (placeholder, filled by "Decision — §4 step 10")
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** no finding
**Failure:** The Amendment is large and contains the actual results. I checked the sub-sections: the two-blocker correction is evidence-grounded; the v1.1 revision is disclosed with a new hash; the 2×2 probe is appropriately cautious ("Nothing here is stated as a property"); the carrier is disclosed as a fixture, not a version; the selection-rate measurement (N=5, 4 of 5 both configurations) is sound; the P1 mis-specification is identified transparently and not edited; the excluded runs are named with reasons independent of outcomes; the §5 hand re-read was done before sheets existed and agrees with the scorer; the batch results (10 of 10 / 0 of 10, p = 1.08 × 10⁻⁵) are internally consistent; the maintainability counter-movement is recorded; the P3 counter bug is disclosed with a fix and test fixtures; the second reader's `change-focus` disagreement is consistent with the known harness defect; the `baseline-report` arm-blindness is recorded as an instrument gap. The one issue — the deliberate failure n change — is reported under the "Deliberate failure" section above, where the registered n appears.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision — §4 step 10
**Verdict:** no finding
**Failure:** The KEEP decision is grounded in the registered outcome (test-quality 10 of 10 vs 0 of 10, p = 1.08 × 10⁻⁵, clearing the MDE of 7 of 10), the behaviour measure (P3, 10 of 10 vs 0 of 10), the unanimous second reader on the registered outcome, and the cost/turns/floor bounds all holding. The carrier-vs-product distinction is explicit. The maintainability counter-movement is recorded as a follow-up, not hidden. The BE-004 citation (10 of 10 vs 3 of 10, p = 0.0031) is from a sibling file I cannot verify, but the artifact states no verdict is computed across the two files and the BE-003 verdict stands on its own.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `architecture-consistency` is 10 of 10 on both arms (constant, "no information"), as it was at stops 12 and 11. It does not restate the evaluator gate — it measures a different dimension that happens to be saturated in this fixture set. The artifact acknowledges the constancy. The rubric's v2 already dropped the categories that *did* restate gates (`functional-correctness`, `requirement-completeness`); `architecture-consistency` is a residual constant, not a gate duplicate.
- **Which single section would two reviewers diverge on most, and by how much?** "Independent variable" / "How the treatment is delivered" / "Controlled variables." One reviewer reads the Amendment as adequate additive correction and sees the carrier disclosure as transparent; the other reads the three pre-Amendment sections as making false factual claims about the batch (wrong agent hash, wrong tool count, wrong overlay path) that a validator would flag before reaching the correction ~200 lines later. The divergence is wide — one says "the experiment is correctly described," the other says "the experiment described in the registration is not the experiment that was run."
- **What did the artifact not say that it needed to say?** The deliberate failure's n change from 3 to 1 is not disclosed. The pre-Amendment sections describing v1.0 are not marked as superseded by the carrier design — a reader has no signal at the point of reading them that the claims about agent hash, tool count, and overlay path were later retracted.
