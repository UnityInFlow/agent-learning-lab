# opencode review — E-003-instructions-v0.1

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
reviewed_utc:    20260903T181703Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-003-instructions-v0.1.md
    sha:  2fe333289653
    dirty: false
  - path: phases/b03-global-instructions/README.md
    sha:  51fdc70ef1b9
    dirty: false
lab_head:        33f4350
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-003-instructions-v0.1.md
  verdict: REJECT
  summary: The artifact reaches REJECT through internal contradictions that flip the primary outcome's verdict and undermine the L2 preflight claim — a reader following the artifact's own MDE rule would land on "not detectable" where the table says "refuted," and the registered "no variable moves" sentence is directly contradicted by the companion README.
  blocking:
    - reason: R1's "refuted" verdict is defended with "8/10 vs 2/10 would have given p = 0.023, so the registered effect was inside what this design could see" — but the actual control was 3/10, not 2/10. Against 3/10, 8/10 gives Fisher exact two-tailed p ≈ 0.07, outside the experiment's own p < 0.05 threshold.
      wrong_action: A reader applying the artifact's MDE rule (line 128–129, "never as refuted") to the actual control rate lands on "not detectable at this n" — a claim about the instrument — rather than the printed "refuted" — a falsification of the mechanism. This flips the headline from "rule refuted" to "rule untestable at this n with the control that occurred."
      anchor: "8/10 vs 2/10 would have given p = 0.023, so the registered effect was inside what this design could see. It was looked for and it is not there"
      evidence: experiments/E-003-instructions-v0.1.md:292
    - reason: Prediction 4's row labels the outcome "NO — refuted in an unexpected direction" while the same cell states "Inside the MDE, so the honest reading is **the file is not measurably paid for at all**" — mutually exclusive under the artifact's own rule that an inside-MDE result is "never as refuted."
      wrong_action: Two readers applying the same MDE rule reach different verdicts: one records "refuted" (a falsification of cost direction) and one records "not detectable" (the instrument could not resolve cost at this n) — different epistemic claims about different things, both printed in one cell.
      anchor: "| **4** | the file costs more than the control but under +25 % | **NO — refuted in an unexpected direction** | Predicted *positive but under +25 %*. Observed **−2.5 %**, p = 0.68. Inside the MDE, so the honest reading is **the file is not measurably paid for at all** |"
      evidence: experiments/E-003-instructions-v0.1.md:295
    - reason: Line 137 claims "No registered variable moves between B2 and this experiment" but the controlled-variables table registers harness version as a held variable, and the companion README admits the harness moved from `2.1.251` (B2) to `2.1.259` (E-003).
      wrong_action: A reader of E-003 alone concludes all seven controlled variables (including harness version) are held between B2 and E-003 and reads the concurrent-control design as a belt-and-braces replication; a reader of the README sees the substitution was forced by the mismatch. The two readings yield different conclusions about whether B2's stored numbers are directly comparable.
      anchor: "**No registered variable moves between B2 and this experiment.**"
      evidence: experiments/E-003-instructions-v0.1.md:137
    - reason: The treatment hashes are labeled `sha256:` but provided as 32 hex characters — the length of MD5, half of SHA-256. Neither the truncation convention nor the verification procedure is documented, so the preflight's L2 claim (the file the runner hashes must equal the hash printed in the table) is not independently verifiable from the artifact.
      wrong_action: A reviewer running `sha256sum build/customizations/instructions-v0.1/CLAUDE.md` gets a 64-character digest that cannot equal a 32-character string and concludes either the file was modified, the hash is mislabeled, or the runner truncates — with no way from the artifact alone to determine which, leaving the L2 delivery proof unsupported.
      anchor: "Content hash | `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 57 words, three rules"
      evidence: experiments/E-003-instructions-v0.1.md:82
  non_blocking:
    - reason: The REJECT row's AND-condition ("R1 inside its MDE and cost above +25 %") never fires (cost was −2.5 %), and the verdict arrives only through the per-rule clause. The artifact names this as a defect in the decision rule and carries it forward as follow-up 4 — acknowledged gap, not hidden.
      evidence: experiments/E-003-instructions-v0.1.md:380-386
    - reason: The layer table answers "no" to "can the bad value still be written down?" yet assigns L2 to "the overlay reaching the runtime it was written for." Under the layer model's "stop at the first yes" rule, "no" would force L1. The reasoning chain is inconsistent but the L2 conclusion is correct (`run-agent.sh` does execute to reject), so the outcome stands.
      evidence: phases/b03-global-instructions/README.md:99
    - reason: The per-rule clause ("a rule whose registered outcome lands inside its MDE is removed") literally applies only to R2; R1 is refuted (not inside its MDE) and R3's MDE was "none — at ceiling." The artifact applies the clause to all three rules by intent rather than by literal text, but the intent is unambiguous and the per-rule verdicts do not change under either reading.
      evidence: experiments/E-003-instructions-v0.1.md:160
    - reason: The gate item "3 controlled comparisons vs B2" is met by three comparisons against a concurrent replication, with the substitution explicitly justified (harness version mismatch) and B2 used as a consistency check on the control rather than as a direct comparator — documented substitution, not a hidden one.
      evidence: phases/b03-global-instructions/README.md:228-231
  disputed:
    - finding: "The cache-bucket explanation now has two experiments' worth of unexplained numbers and still one test."
      why: E-003 follow-up 2 (lines 408–410) registers this exact issue with the proposed discriminator — a fixed-content overlay run twice against a cold and a warm cache — so the artifact names both the gap and the test, which the line-level finding treats as missing.
    - finding: "Was R1 too abstract, or is the effect absent? R1 never names `when`, `else` or Kotlin — deliberately, threat 1. The cheap discriminator is a second treatment naming the construct outright."
      why: E-003 follow-up 3 (lines 411–415) names this discriminator explicitly as future work; the line-level finding restates it as unraised but it is already on the artifact.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 85s |
| ollama-cloud/glm-5.2 | ok | 174s |

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
| Deterministic evaluation | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| Which predictions held | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Build | 1/1 | L3 |
| Exit gate | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** finding
**Failure:** Prediction 4 says the file costs "positive but under +25 %," a range that excludes zero and the negative. The MDE table registers the cost outcome as "≥ +25 % on the median." The observed result is −2.5 %, p = 0.68 — inside the MDE. The "Which predictions held" table labels this "NO — refuted in an unexpected direction," but the MDE rule (line 128–129) says: "A result that lands inside an MDE is recorded as NOT DETECTABLE at this n, never as refuted." R2's cost outcomes receive the correct "NOT DETECTABLE at this n, not refuted" treatment. Prediction 4 does not. Two reviewers would diverge: one reads "refuted" and concludes the prediction was falsified; another reads "inside the MDE" and concludes the experiment could not detect an effect either way. The two labels carry different epistemic weight — "refuted" is a claim about the world, "not detectable" is a claim about the instrument.
**Layer of the implied fix:** L3
**Anchor:** "NO — refuted in an unexpected direction | Predicted *positive but under +25 %*. Observed **−2.5 %**, p = 0.68. The prediction's stated range excludes zero and the observed point estimate is negative. Inside the MDE, so the honest reading is **the file is not measurably paid for at all**"

### Independent variable
**Verdict:** no finding

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The content hash is written as `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 32 hex characters, which is 128 bits. SHA-256 produces 256 bits = 64 hex characters. The bloat arm's hash `sha256:807c5d03f77cc66106aa90d72fe50245` is likewise 32 hex chars. The preflight assertion (line 82) says "customization.instructionsHash on its run record must equal the hash above." A reviewer who computes `sha256sum` on the CLAUDE.md file gets a 64-char digest that cannot match a 32-char value. One reviewer concludes the file was modified or the hash is wrong; another assumes the runner truncates to 32 chars for display and matches the prefix. The artifact documents neither convention, so the preflight — the experiment's L2 delivery proof — is not independently verifiable from the information given.
**Layer of the implied fix:** L3
**Anchor:** "Content hash | `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 57 words, three rules"

### Controlled variables
**Verdict:** no finding

### Runs
**Verdict:** no finding

### Minimum detectable effect
**Verdict:** no finding

### Deterministic evaluation
**Verdict:** finding
**Failure:** Line 137 states "No registered variable moves between B2 and this experiment." The controlled-variables table (line 93–94) lists "harness + version" as a held variable, asserted "identical across arms after the batch." The companion README (lines 210–212) states explicitly: "B2's claude arm ran on harness `2.1.251`; every run here is `2.1.259`." The harness version — a registered variable — moved between B2 and this experiment. The sentence is true if read as "no variable moves between the treatment and control arms within this experiment," but it is written as "between B2 and this experiment," which is false. A reviewer reading E-003 alone concludes the harness is the same as B2's; a reviewer who also reads the README knows it is not and that the comparison against B2 was deliberately restructured as a concurrent replication for this reason. The two reach different conclusions about whether the B2 baseline is directly comparable.
**Layer of the implied fix:** L3
**Anchor:** "**No registered variable moves between B2 and this experiment.**"

### Exclusions
**Verdict:** no finding

### Decision rule
**Verdict:** finding
**Failure:** The REJECT row requires "R1 inside its MDE *and* cost rises beyond +25 %." The observed cost is −2.5 %, so the REJECT row's condition is never met. The KEEP row requires R1 to hold at p < 0.05, which it did not. The INCONCLUSIVE row requires an unsettleable outcome, which did not occur. None of the three version-level rows fire for the observed outcome. The verdict REJECT is reached only through the per-rule clause ("a rule whose registered outcome lands inside its MDE is removed"), which is written as a sub-mechanism of "KEEP THE RULE, DROP THE OTHERS" — itself a version-level row that presupposes the version is kept. Two reviewers would handle this differently: one reads the per-rule clause as a standalone mechanism that empties the file and thus reaches REJECT; another reads it as contingent on the KEEP row, which did not fire, leaving no registered path to any verdict. The artifact acknowledges the gap (follow-up 4) but the decision as registered did not produce a verdict through any of its four stated rows.
**Layer of the implied fix:** L3
**Anchor:** "| **REJECT** | R1 lands inside its MDE *and* cost rises beyond +25 %: the file bought nothing and was not free |"

### Threats to validity, registered before the run
**Verdict:** no finding

### Deliberate failure — the same three rules, diluted 25×
**Verdict:** no finding

### Observed telemetry
**Verdict:** no finding

### Results
**Verdict:** no finding

### Which predictions held
**Verdict:** finding
**Failure:** Same defect as the Predictions section, restated because it lives here. Prediction 4's row says "NO — refuted in an unexpected direction" while the same row's "Actual" column says "Inside the MDE, so the honest reading is **the file is not measurably paid for at all**." The MDE rule on line 128–129 says a result inside the MDE is "never as refuted." R2's row in the same table correctly applies this: "NOT DETECTABLE at this n, not refuted." Prediction 4 does not. A reviewer using the MDE rule as the standard reads "not detectable"; a reviewer using the direction reversal reads "refuted." The artifact applies two different standards to the same class of outcome in the same table.
**Layer of the implied fix:** L3
**Anchor:** "| **4** | the file costs more than the control but under +25 % | **NO — refuted in an unexpected direction** | Predicted *positive but under +25 %*. Observed **−2.5 %**, p = 0.68. The prediction's stated range excludes zero and the observed point estimate is negative. Inside the MDE, so the honest reading is **the file is not measurably paid for at all** |"

### Failure analysis
**Verdict:** no finding

### Sanity checks
**Verdict:** no finding

### Decision
**Verdict:** no finding

### Follow-up
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The rubric scores quality among runs that already passed the evaluator (exit 0). The `maintainability` anchor 2 construct is not what the evaluator checks — the evaluator verifies correctness, the rubric scores how the correctness was achieved. R1's prediction targets the rubric, not the gate.
- Which single section would two reviewers diverge on most, and by how much? "Which predictions held" — prediction 4's verdict. One reviewer applies the MDE rule ("never as refuted") and reads "not detectable"; another reads the direction reversal and reads "refuted." The divergence is one label on one row, but it determines whether prediction 4 is counted as a falsification (the mechanism was wrong about cost direction) or a non-detection (the instrument could not see cost at this n). These are different claims about different things, and the artifact makes both simultaneously.
- What did the artifact not say that it needed to say? Two things: (1) whether the 32-hex-char hashes labeled `sha256:` are truncated SHA-256 digests or full MD5 digests mislabeled — the preflight's independent verifiability depends on this; (2) that the harness version moved from 2.1.251 to 2.1.259 between B2 and this experiment, which the "No registered variable moves" sentence in Deterministic evaluation denies and the README affirms.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** finding
**Failure:** Prediction 4 says the cost increase is "positive but under +25 %." The MDE table (line 125) sets the minimum detectable cost effect at ≥ +25 %. The entire predicted range — positive, under +25 % — sits below the experiment's own detection floor. By the rule at line 128–129 ("A result that lands inside an MDE is recorded as NOT DETECTABLE at this n, never as refuted"), prediction 4 can never be confirmed as "held"; it can only be not-detectable or refuted on direction. The result table (line 295) reports it as "NO — refuted in an unexpected direction" while the same cell says "Inside the MDE." R2's cost outcomes, which also landed inside their MDEs, are reported as "NOT DETECTABLE" (line 293). Two reviewers applying the experiment's own rule to the same kind of result — an inside-MDE outcome — would land on different verdicts for prediction 4 versus R2.
**Layer of the implied fix:** L3
**Anchor:** "Predicted cost increase over the concurrent control: **positive but under +25 %**" and "A result that lands inside an MDE is recorded as NOT DETECTABLE at this n, never as refuted."

### Independent variable
**Verdict:** no finding

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The content hash is recorded as `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 32 hex characters. SHA-256 produces 64 hex characters; 32 hex is the length of an MD5 digest. The preflight assertion (line 82) says `customization.instructionsHash` on the run record "must equal the hash above." If the runner stores a full 64-character SHA-256, equality against a 32-character string fails and the batch never starts. If the runner truncates to 32 characters, the assertion works but the document never states this convention. The bloat arm's hash (`807c5d03f77cc66106aa90d72fe50245`, also 32 chars) has the same problem. Two reviewers checking the preflight assertion would handle the hash differently: one treats 32 chars as a truncated identifier, the other as a mislabeled digest that breaks the assertion.
**Layer of the implied fix:** L3
**Anchor:** "Content hash | `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 57 words, three rules"

### Controlled variables
**Verdict:** no finding

### Runs
**Verdict:** no finding

### Minimum detectable effect
**Verdict:** finding
**Failure:** The primary-outcome MDE is derived from a control baseline of 2/10 (B2's 1 of 5). The calculation says 8/10 treatment vs 2/10 control gives p = 0.023 (two-tailed Fisher exact). But prediction R1 allows the control to be "≤ 3 of 10," and the observed control was 3 of 10. Against a 3/10 control, 8/10 gives p ≈ 0.070 (two-tailed) — not detectable at p < 0.05. The MDE's detectability claim is valid only against the 2/10 baseline, not against the control the prediction itself permits and the experiment actually observed. Two reviewers would diverge: one uses the pre-registered 2/10 MDE and says 8/10 was detectable; the other recomputes against the actual 3/10 control and says 8/10 was not detectable, which changes R1's verdict from "refuted" to "not detectable."
**Layer of the implied fix:** L3
**Anchor:** "Fisher exact, 10 v 10 from a control of 2/10: **8/10 → p = 0.023**; 7/10 → p = 0.070, **not detectable**."

### Deterministic evaluation
**Verdict:** no finding

### Exclusions
**Verdict:** no finding

### Decision rule
**Verdict:** finding
**Failure:** The per-rule clause (line 160) says "a rule whose registered outcome lands inside its MDE is removed." The Decision section (line 377) claims this clause "applies to all three" — R1 refuted, R2 not detectable, R3 held at "moves nothing." But R1 was refuted (not inside its MDE — the effect was looked for at an n chosen to find it), and R3's prediction held (its MDE was "none — at ceiling," not a detectable threshold it landed inside). The clause as written names one condition — "lands inside its MDE" — that literally covers only R2. R1 is removed by refutation and R3 by the gate's "no measured effect" clause, neither of which is the per-rule clause's stated condition. Two reviewers would diverge: one reads "lands inside its MDE" literally and finds the clause removes only R2; the other reads the intent and accepts it covers all three.
**Layer of the implied fix:** L3
**Anchor:** "A rule whose registered outcome lands inside its MDE is **removed**, and the removal is the finding"

### Threats to validity, registered before the run
**Verdict:** no finding

### Deliberate failure — the same three rules, diluted 25×
**Verdict:** no finding

### Observed telemetry
**Verdict:** no finding

### Results
**Verdict:** no finding

### Which predictions held
**Verdict:** finding
**Failure:** R1 is reported as "refuted, and this one *is* refuted rather than undetectable" (line 292), justified by "8/10 vs 2/10 would have given p = 0.023, so the registered effect was inside what this design could see." But the actual control was 3/10, not 2/10. Against 3/10, 8/10 gives p ≈ 0.070 (two-tailed) — outside detection. The justification for choosing "refuted" over "not detectable" depends on a 2/10 control that did not occur. Against the control that did occur, 8/10 would have been undetectable, so the observed 2/10 should be "not detectable" by the experiment's own rule, not "refuted." Two reviewers would land on different verdicts for R1 depending on which control rate they use.
**Layer of the implied fix:** L3
**Anchor:** "8/10 vs 2/10 would have given p = 0.023, so the registered effect was inside what this design could see. It was looked for and it is not there"

### Failure analysis
**Verdict:** no finding

### Sanity checks
**Verdict:** no finding

### Decision
**Verdict:** no finding

### Follow-up
**Verdict:** no finding

---

### Goal
**Verdict:** no finding

### Required reading
**Verdict:** no finding

### Extract
**Verdict:** no finding

### Build
**Verdict:** finding
**Failure:** The layer table (line 99) assigns **L2** to "the overlay reaching the runtime it was written for" while answering "no" to the first column, "can the bad value still be written down?" The layer model says apply in order and stop at the first yes: if the bad value cannot be written down (answer = no), the layer is L1 — stop. The table answers "no" but skips to the second question and assigns L2. The mechanism — `run-agent.sh` dies — is an execution that rejects a bad value that *was* written down (the customization was configured with a file the runtime doesn't read, then the script killed it). That makes the first-column answer "yes" (the bad value can be written down) and the layer L2. As written, the "no" and the L2 contradict each other under the model's own decision procedure. Two reviewers would diverge: one applies "no → L1" strictly; the other reads the run-agent.sh mechanism and says L2.
**Layer of the implied fix:** L3
**Anchor:** "| the overlay reaching the runtime it was written for | no — `run-agent.sh` **dies** if a customization installs an instruction file the runtime does not read | `run-agent.sh:293` | **L2** |"

### Predict before you run
**Verdict:** no finding

### Lab B3.1 — measure against B2
**Verdict:** no finding

### Deliberate failure
**Verdict:** no finding

### Exit gate
**Verdict:** finding
**Failure:** The gate item reads "3 controlled comparisons vs B2." The three comparisons delivered (line 228–231) are: (1) instructions-v0.1 vs concurrent plain control, (2) the same two arms under the rubric, (3) instructions-v0.1 vs the same rules diluted 25×. None of the three is a comparison against B2. The document substitutes "a concurrent replication of B2's condition" and justifies it by a harness-version mismatch (B2 ran on 2.1.251, this ran on 2.1.259). The justification is sound, but the gate as written says "vs B2," and a reviewer checking the gate literally would find none of the three comparisons names B2 as a comparator. Two reviewers would diverge: one accepts the substitution because the control reproduces B2 on six measures; the other reads the gate item verbatim and finds it unmet.
**Layer of the implied fix:** L3
**Anchor:** "**3 controlled comparisons vs B2** | **yes, with the substitution stated** | the three in the table above. Made against a **concurrent replication** of B2's condition rather than B2's stored runs"

### Commit
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? The `maintainability` anchor 2 (the primary outcome) rewards a `when` in expression position with no `else`. The evaluator gate (`evaluator.sh` exit 0) is a separate pass/fail. They do not duplicate — the gate is functional correctness, the anchor is a quality construct. No duplication.
- Which single section would you expect two reviewers to diverge on most, and by how much? **Minimum detectable effect** / **Which predictions held** — the MDE was derived from a 2/10 control but the actual control was 3/10, which changes whether 8/10 is detectable (p = 0.023 vs p ≈ 0.070) and therefore whether R1 is "refuted" or "not detectable." This is a full verdict flip on the experiment's primary outcome, driven by a baseline mismatch the document never addresses.
- What did the artifact not say that it needed to say? The MDE table never states that the control rate is a parameter of the Fisher exact calculation, nor that the observed 3/10 control shifts the detection threshold relative to the 2/10 baseline the MDE was derived from. The experiment's central verdict — R1 refuted rather than not detectable — depends on a p-value computed against a control that did not occur.
