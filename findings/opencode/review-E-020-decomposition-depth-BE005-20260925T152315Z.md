# opencode review — E-020-decomposition-depth-BE005

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
reviewed_utc:    20260925T152315Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-020-decomposition-depth-BE005.md
    sha:  91790e008e16
    dirty: false
  - path: phases/b08a-decomposition-depth/README.md
    sha:  4c2bc84181a3
    dirty: false
  - path: evidence/b08a/shape/SHAPE-RULE.md
    sha:  842b3433811e
    dirty: false
  - path: evidence/b08a/tally.py
    sha:  8742c57df8b9
    dirty: false
lab_head:        dff87f6
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-020-decomposition-depth-BE005.md
  verdict: ACCEPT
  summary: >
    A thorough, self-aware experiment artifact whose measurements are documented
    and reproducible, whose decision rule is applied with acknowledged composition
    gaps, and whose verdict (NO ROW FIRES, ladder closes, not promoted, kept as a
    measured configuration) follows from the recorded evidence. The defects the
    line-level pass raised are real but none of them would mislead a reader into
    a wrong action.
  blocking: []
  non_blocking:
    - reason: >
 The "factor of twelve" arithmetic (1.83× ÷ 0.15) is dimensionally
        inconsistent — it divides a cost ratio by an allowed-increase fraction.
        The natural comparisons are 1.83 ÷ 1.15 ≈ 1.59 (multiplier over the
        allowed multiplier) or (1.83 − 1.0) ÷ 0.15 ≈ 5.5 (excess over the
        allowed excess). The verdict direction is unambiguous (1.83× exceeds
        1.15×), and the B13 refusal is redundant to the ladder-closure clause
        that fires from decision 11 item 2, so the wrong magnitude does not
        mislead about the outcome.
      evidence: experiments/E-020-decomposition-depth-BE005.md:380,621-622

    - reason: >
        The summary "two held and five are refuted" does not specify which two.
        The table is referenced at `evidence/b08a/REPORT.md` §§2–6 but is not
        echoed here. P3 clearly held; the second-held reading most plausibly
        treats P2 as held by direction (treated 7/8 > control 3/8) rather
        than by threshold (P2 p = 0.1189 does not clear p ≤ 0.05).
      evidence: experiments/E-020-decomposition-depth-BE005.md:343-346,516-522

    - reason: >
        The Results section attributes P1's refutation to the MDE prediction
        ("I predict this prediction cannot be measured"). P1 actually carries
        two predictions — magnitude (2 vs 0) and unmeasurability. The magnitude
        was refuted (measured 0 vs 0); the unmeasurability partially held
        (control n = 3 < n < 5). The Results section conflates the two and
        claims the refutation was predicted when only the unmeasurability was.
      evidence: experiments/E-020-decomposition-depth-BE005.md:525-527,40-44,516    - reason: >
        The Results section claims "That gap was predicted in this file's own
        MDE section before the batch" for the decision-rule composition gap
        ("no row for exactly one of two rates separating"). The MDE section
        predicts a different composition defect — that the instrument cannot see
        its own registered outcome — not the rule gap. The two are related        but distinct.
      evidence: experiments/E-020-decomposition-depth-BE005.md:354-356,156-163

    - reason: >
        P3 is reported as "separates" (8/8 vs 2/8, p = 0.0070) without
        echoing SHAPE-RULE.md's caveat that the tally is "unconfirmed by the
        author" until they overrule any row. A reader of E-020 alone would
        treat P3 as confirmed. P3 is one of two secondaries and the verdict
        does not rest solely on it, so the omission does not mislead the
        outcome.
      evidence: experiments/E-020-decomposition-depth-BE005.md:518,
                 evidence/b08a/shape/SHAPE-RULE.md:76-77

    - reason: >
        The B13 promotion refusal applies the raw cost ratio (1.83× =
        $0.7149 ÷ $0.3912) where the registered metric is `estimatedCost per
        evaluator-passing run against the concurrent control`. Under
        per-accepted-task interpretation (total cost ÷ passing count: treated
        ≈ $0.82, control ≈ $1.04, ratio ≈ 0.78×), the gate would pass. The
        verdict is correct by ladder closure regardless, so the wrong B13
        arithmetic is redundant and does not change the outcome.
      evidence: experiments/E-020-decomposition-depth-BE005.md:380,201-204

    - reason: >
        "NO ROW FIRES" is not one of the four registered verdicts (VOID,
        IMPROVED, REJECT, NOT DETECTABLE); the rule says "the first that
        fires is the verdict" and is silent on the complement. The artifact
        resolves this by referencing decision 11 item 2 and `build/README.md
        #b8a`, which make ladder closure conditional on row 2 firing
        IMPROVED. The resolution is honest, but the rule itself is not
        self-contained on this outcome.
      evidence: experiments/E-020-decomposition-depth-BE005.md:363-364,
                 192-197,359-364

    - reason: >
        Decision rule row 2 requires "≥ 8 of 10 against a control at ≤ 2 of 10";
        at n = 8 per arm (row 0b fired), "8 of 10" is unreachable. The artifact
        handles this because row 0b fires first, so the count threshold is
        never evaluated; the question of whether 8 of 8 would satisfy "≥ 8 of
        10" never arises. A reader who notices the impossibility would still
        find the population cut explicit.
      evidence: experiments/E-020-decomposition-depth-BE005.md:192-197,
                 350-353
  disputed:
    - finding: >
        The line-level pass reads the summary "the experiment's predictions
        about the treatment did not [hold]" as contradicting "two held and
        five are refuted."
      why: >
        The two statements are consistent: "two held" = P3 (separates) and one
        other (most plausibly P2 by direction or P1's unmeasurability claim),
        and "did not [hold]" reads as "did not all hold" rather than "none        held." The phrasing is awkward but not self-contradictory.
    - finding: >
        The line-level pass suggests the "two held and five are refuted"
        count requires classifying P2 as "held" by direction, which would
        make the count internally inconsistent because P2's registered
        threshold (p ≤ 0.05) was not met (measured p = 0.1189).
      why: >
        The artifact does not specify which two held; it points to the
        table in `evidence/b08a/REPORT.md` §§2–6. A reader following the
        reference gets the full partition. The ambiguity is a clarity gap,
        not an internal contradiction within E-020 itself.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 193s |
| ollama-cloud/glm-5.2 | ok | 201s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Budget, overlay and instrument — decided at §4 step 9, before a dollar was spent | 1/1 | L3 |
| Predictions | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| Results · Which predictions held · Failure analysis · Sanity checks · Decision · Follow-up | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

## Question
**Verdict:** no finding

## Hypothesis
**Verdict:** no finding

## Predictions
**Verdict:** no finding

The Fisher arithmetic in P2 (8/10 vs 2/10 → p = 0.0230; 7/10 vs 2/10 → p = 0.0698; 7/10 vs 1/10 → p = 0.0198) checks out. P1's self-prediction of unmeasurability and P4's self-prediction of being wrong are registered honestly with mechanisms.

## Independent variable
**Verdict:** no finding

## How the treatment is delivered — and proved
**Verdict:** no finding

## Controlled variables
**Verdict:** no finding

The evaluator-version disagreement (1.0.0 executes, 1.1.0 declared) is resolved correctly by the layer rule — the string that runs is the version of record.

## Runs
**Verdict:** no finding

## Minimum detectable effect
**Verdict:** no finding

The MDE table is thorough and the "none computable" for the primary outcome is registered before the batch with the arithmetic showing why.

## Deterministic evaluation
**Verdict:** no finding

## Exclusions
**Verdict:** no finding

## Decision rule
**Verdict:** finding
**Failure:** The batch was expected to stop at n ≈ 8 per arm (preflight budget transfer, README §Preflight: "the batch is expected to stop at n ≈ 8 per arm, not 10"), and it did. Row 2's threshold is stated as "≥ 8 of 10 against a control at ≤ 2 of 10 (p ≤ 0.05 by Fisher)." At n = 8, "8 of 10" is literally impossible — the maximum is 8 of 8. The Results section silently drops the count condition and reads only the p-value ("row 2 requires both rates at p ≤ 0.05"), but the rule as written states both a count and a p-value conjunctively. Two reviewers diverge: one reads "7 of 8" as failing the "≥ 8 of 10" count condition regardless of p, the other reads the p-value as operative and the count as an n=10 instantiation. The verdict is the same either way (P2 at p = 0.1189 fails the p-condition), but the reasoning the artifact reports is an interpretation the rule does not state. Separately, the rule has no row for "exactly one of two rates separates" — P3 separates (p = 0.0070), P2 does not (p = 0.1189) — and the artifact writes "NO ROW FIRES" as the verdict, which is not one of the four registered verdicts (VOID, IMPROVED, REJECT, NOT DETECTABLE). The artifact acknowledges this gap was predicted in the MDE section, but the rule was not amended before the batch to close it.
**Layer of the implied fix:** L3
**Anchor:** `evaluator pass rate and shape classification both reach ≥ 8 of 10 against a control at ≤ 2 of 10 (p ≤ 0.05 by Fisher)`

## Deliberate failure — prediction registered before it is built
**Verdict:** no finding

### Budget, overlay and instrument — decided at §4 step 9, before a dollar was spent
**Verdict:** no finding

The 21× estimate error is acknowledged honestly and the $4.00 ceiling had sufficient margin that it did not affect the outcome.

## Observed telemetry
**Verdict:** no finding

(First instance is a placeholder — "To be filled after the batch" — and the second instance carries the actual data. Both are treated here as one section.)

## Deliberate failure — the result, 2026-09-25, `n = 5`
**Verdict:** no finding

The condition (d) grep defect (counts attempts, not completions) is identified, its failure scenario is named ("a future arm where an attempt is refused on all three specialists would be reported as fully delivered"), and the fix is described. The artifact does not hide it.

## Results · Which predictions held · Failure analysis · Sanity checks · Decision · Follow-up
**Verdict:** finding
**Failure:** The summary states "two held and five are refuted" for the seven registered predictions, but does not specify which two held, and the README's own table does not cleanly partition into those categories. The README table labels P2 as "does not separate" and P7 as "below threshold" — neither is "held" by any normal reading. The only prediction that clearly held is P3 (shape classification, 8/8 vs 2/8, p = 0.0070). The most natural way to make the count work (2 + 5 = 7) is to classify P2 as "held" because its direction was correct (treated 7/8 > control 3/8) — but P2's registered threshold is explicitly "p = 0.0230" and "p ≤ 0.05," and the measured p = 0.1189 does not meet it. Two reviewers diverge: one reads "held" as "direction was right" (P2 held), the other reads "held" as "registered threshold met" (P2 refuted, only P3 held, and the count is wrong). The experiment file's own statement that "the experiment's predictions about the treatment did not [hold]" compounds the ambiguity — if the treatment predictions did not hold, how did two of them hold?

Separately, the Decision paragraph states "the gate is failed by a factor of twelve." The measured cost is 1.83× (83% increase) against a 15% allowed increase. The natural computation is 0.83 / 0.15 ≈ 5.5, not 12. The only way to reach ~12 is 1.83 / 0.15 = 12.2, which divides a cost ratio by an allowed-increase fraction — dimensionally inconsistent. Two reviewers checking the arithmetic get different magnitudes (5.5 vs 12) depending on which division they perform. The verdict (promotion refused) is unchanged either way, but the stated magnitude is wrong.
**Layer of the implied fix:** L3
**Anchor:** `Of the seven registered predictions, two held and five are refuted`

## The F13 decision
**Verdict:** no finding

The four-part decision is well-reasoned, both populations are reported, and the p-value is identical to four decimals either way (0.1189). The 4abf7f01 mislabeling is reported as a third population rather than hidden.

## Observed telemetry
**Verdict:** no finding

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** P2 (evaluator pass rate) and P3 (shape classification) were registered as measuring the same underlying thing — P2's mechanism says "pass rate *is* shape on this ticket." The artifact found they disagree on 4 of 16 runs in both directions, which refutes P2's mechanism. This is acknowledged and reported as a finding, not hidden. No unacknowledged duplication remains.
- **Which single section would two reviewers diverge on most, and by how much?** The Results summary's "two held and five are refuted." One reviewer reads P2 as "held" (direction correct), the other as "refuted" (registered p-value threshold not met). The divergence is on the classification of one prediction out of seven, and it does not change the verdict — but it does change whether the summary count is internally consistent.
- **What did the artifact not say that it needed to say?** The decision rule was registered with thresholds stated as "of 10" and a cost ceiling that was expected (post-preflight, pre-batch) to stop the batch at n = 8. The rule was not amended to restate thresholds for the expected population. The artifact reports this as a discovered composition failure, but the preflight budget transfer that predicted n ≈ 8 occurred before the batch and after the rule was registered — the gap was visible before the first registered run and the rule was not updated. The SHAPE-RULE.md's caveat that the tally is "unconfirmed by the author" until the author overrules is not echoed in E-020's reporting of P3 as "separates" — a reader of E-020 alone would not know P3's classification is provisional.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** finding
**Failure:** P1 registers two predictions in one block: a magnitude ("median 2 against a control median of 0") and an unmeasurability claim ("I predict this prediction cannot be measured … I expect P1 to come back at n < 5 per arm"). The Results table reports P1 as "REFUTED" because the measured was 0 vs 0, not 2 vs 0. But the unmeasurability prediction partially held — the control's rubric population was n=3, below the n<5 threshold the prediction named. One reviewer reads P1 as refuted (magnitude wrong); another reads it as partially self-confirmed (unmeasurability right, magnitude never testable at n=3). The Results section says "two of those refutations were predicted in the experiment file itself, with the mechanism: P1 ('I predict this prediction cannot be measured')." But the prediction was about *measurability*, not about the magnitude being 0 vs 0. The refutation (0 vs 0) was not predicted; the unmeasurability was. Conflating the two lets the section claim a refutation was predicted when what was predicted was the opposite — that the magnitude could not be tested at all.
**Layer of the implied fix:** L3
**Anchor:** "P1 — registered outcome. `architecture-consistency` (codex, rubric `945817b8c509`) is HIGHER in the treated arm, median 2 against a control median of 0, on gate-passing runs." and "I predict this prediction cannot be measured"

### Independent variable
**Verdict:** no finding

### How the treatment is delivered — and proved
**Verdict:** no finding

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
**Failure:** Row 2 fires when "evaluator pass rate and shape classification both reach ≥ 8 of 10 against a control at ≤ 2 of 10 (p ≤ 0.05 by Fisher)." The batch stopped at n=8 per arm (row 0b), so "8 of 10" is unreachable — a treated arm with n=8 can never produce "8 of 10." The Results section evaluates row 2 using the p-value alone ("row 2 requires both rates at p ≤ 0.05"), silently dropping the count threshold. One reviewer reads the rule as written and concludes row 2 can never fire at n=8 because the count condition is impossible; another reads the p-value as the sole operative gate and the count threshold as an illustrative magnitude registered at the predicted n=10. The rule does not say which interpretation is correct, and the two lead to different conclusions about whether the rule was applied as registered or reinterpreted after the population shrank.
**Layer of the implied fix:** L3
**Anchor:** "evaluator pass rate **and** shape classification both reach **≥ 8 of 10** against a control at ≤ 2 of 10 (p ≤ 0.05 by Fisher)"

### Deliberate failure — prediction registered before it is built
**Verdict:** no finding

### Observed telemetry
**Verdict:** no finding

### Deliberate failure — the result, 2026-09-25, `n = 5`
**Verdict:** no finding

### Results · Which predictions held · Failure analysis · Sanity checks · Decision · Follow-up
**Verdict:** finding
**Failure:** Two issues, the more serious first. (a) The promotion refusal says "the measured figure is 1.83×, so the gate is failed by a factor of twelve regardless of quality." The "factor of twelve" is 1.83 / 0.15 = 12.2, which divides a cost *multiplier* (1.83×) by an allowed *increase fraction* (0.15). The correct comparisons are either increase-vs-increase (0.83 / 0.15 ≈ 5.5×) or multiplier-vs-multiplier (1.83 / 1.15 ≈ 1.59×). Neither is twelve. Separately, the gate is on "tokens_per_accepted_task as estimatedCost per evaluator-passing run," not on the raw cost ratio. If "per evaluator-passing run" means cost divided by the number of passing runs, the treated arm's per-pass cost (8 × $0.7149 / 7 ≈ $0.82) is *lower* than the control's (8 × $0.3912 / 3 ≈ $1.04), a 0.78× ratio that would *pass* the 15% gate. One reviewer computes the gate as failed (raw cost 1.83×); another computes it as passed (per-accepted-task 0.78×); neither gets 12×. The promotion refusal — a load-bearing output of this stop — depends on which reading is correct. (b) The section claims "That gap was predicted in this file's own MDE section before the batch and registered as a finding." The MDE section predicts the primary will be unmeasurable and the verdict will rest on secondaries; it does not predict the decision rule will have no row for exactly one of two rates separating. The "composition" finding the MDE names is about the instrument not seeing its registered outcome, not about the decision rule failing to resolve.
**Layer of the implied fix:** L3
**Anchor:** "the measured figure is 1.83×, so the gate is failed by a factor of twelve regardless of quality"

### The F13 decision
**Verdict:** no finding

### Observed telemetry
**Verdict:** no finding

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** P2 (evaluator pass rate) and the evaluator exit code measure the same underlying quantity — the evaluator's per-run verdict — read two ways: P2 as a between-arms rate comparison, the gate as a per-run filter. They are not duplicative in the decision rule (P2 is a Fisher test, the gate is per-run), but they share a single instrument. The artifact acknowledges this by registering P3 (shape classification from the diff) as the independent read, and the P2/P3 disagreement is reported as a finding. The duplication is named, not hidden.
- **Which single section would two reviewers diverge on most, and by how much?** The Results section, by a wide margin. Three independent ambiguities — the "factor of twelve" arithmetic, the "tokens_per_accepted_task" interpretation, and the MDE-prediction claim — each admit opposite readings. A reviewer who accepts all three reaches "promotion refused, ladder closed, NO ROW FIRES." A reviewer who challenges the tokens_per_accepted_task calculation may reach "promotion gate passes on per-accepted-task cost" and the refusal needs a different basis. A reviewer who challenges the MDE claim may read the decision-rule gap as an unregistered defect rather than a predicted finding. The divergence is not a hair-split; it changes whether the stop's central output (promotion refused) is supported by the arithmetic or undermined by it.
- **What did the artifact not say that it needed to say?** The decision rule does not define a verdict for "no row fires." It says "the first that fires is the verdict" and is silent on the complement. The artifact creates "NO ROW FIRES" as a novel verdict, justified by a ladder-closure clause that lives in the README, not in the experiment file's own decision rule. The experiment file's decision rule is not self-contained: it does not define what happens when no row fires, and it does not define the ladder-closure condition. A reader of the experiment file alone cannot determine that "NO ROW FIRES" leads to ladder closure without consulting a separate document.
