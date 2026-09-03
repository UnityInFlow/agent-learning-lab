# opencode review — E-002-isolation-contamination

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
reviewed_utc:    20260903T134641Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-002-isolation-contamination.md
    sha:  2841c4df23c8
    dirty: true
  - path: phases/b02-plain-baseline/README.md
    sha:  f2dff20286db
    dirty: true
lab_head:        33c6bbb
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-002-isolation-contamination.md
  verdict: ACCEPT
  summary: Predictions timestamped before the runs, results adjudicated by the registered decision rule, the rule fired as written, and the practical action (KEEP the flag) is supported by additional reasoning about unmeasured quality — the methodological concerns the line-level pass raised are real but disclosed in the artifact and did not change the outcome.
  blocking: []
  non_blocking:
    - reason: MDE column entries equal the prediction thresholds (±20% on duration, ±15% on cacheCreation, ±6% on inputTokens, ±2 on toolCalls), conflating "what difference matters" with a statistical minimum detectable effect. The duration MDE is registered as ±20% despite a baseline spread factor of 54; the artifact acknowledges this in the immediately following paragraph and treats the matched pair's tighter range (~1.75×) as the operative one.
 evidence: experiments/E-002-isolation-contamination.md:259-271
    - reason: The decision table has no row for "predictions unsettleable by MDE rather than refuted" — a state the MDE column itself admits is possible. It did not fire on this experiment's outcome (predictions 1 and 4 both fall inside the MDE band but the artifact reads them as refuted by their own thresholds) but the rule is incomplete.
      evidence: experiments/E-002-isolation-contamination.md:299-304
    - reason: "settleable" is used in two senses — tail exclusion did not fire, AND detection limit was reached. The MDE column says ±20% for duration and the observed +16.7% is inside that band; "settleable" is true for the first sense only.
      evidence: experiments/E-002-isolation-contamination.md:262,364
    - reason: Prediction 2's text reads "inputTokens is NOT" (grammatically back-referring to "≥15% higher") while the refuter reads "moving by more than its own baseline spread (>6%)" — two different thresholds for what would refute. The artifact's *Prediction 2 is the one worth reading twice* section picks the refuter reading and acknowledges it as the informative one. Either reading lands on the same row of the decision table in this outcome.
      evidence: experiments/E-002-isolation-contamination.md:99,108,381-401
    - reason: Cache-migration explanation is given for the open arm ("hook output pushes the task prompt into the cached prefix") but the symmetric explanation for the isolated arm (no hook output, so the task prompt is uncached input on first turn) is left implicit. A reader unfamiliar with cache breakpoint placement may need to flip the explanation.
      evidence: experiments/E-002-isolation-contamination.md:387-395
  disputed:
    - finding: "The B2 README at line 778 still says 'three times out of three' and 'the same mechanism firing on every run,' while the project's own CLAUDE.md amended that to 3-of-5 on 2026-09-01. The E-002 artifact inherits the phase's closure and would lead to a stale claim."
 why: The B2 README claim is about three B2 baseline runs (0a222393, 5bd24356, 8322e71b) where codex/opencode disagreed on change-focus 3-of-3. The CLAUDE.md amendment is about E-002's scored runs 4 and 5, a different cohort. The B2 README's "three times out of three" is accurate for the data it discusses; the CLAUDE.md amendment addresses the post-E-002 expansion of the scored set. These are not the same claim and the README is not stale relative to the amendment.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 188s |
| ollama-cloud/glm-5.2 | ok | 239s |

Stall budget: 900s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Decision rule | 1/1 | L3 |
| Results | 1/1 | L3 |
| Which predictions held | 1/1 | L3 |
| Decision | 1/1 | L3 |
| Predictions | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Why a matched pair, rather than one un-isolated run against the nine on record
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** no finding

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
**Failure:** The third row fires on "predictions 1, 2 and 4 all fail." Predictions 1 and 4 were refuted at observed effects that fall inside this experiment's own registered MDE: +16.7 % duration against a ≥ +20 % threshold with MDE ±20 %, and 0 toolCalls against a ≥ +2 threshold with MDE ±2. The experiment cannot distinguish +16.7 % from +20 %, or 0 from +2, by the detection limit it registered. Two reviewers reading the same results reach different verdicts: one counts 1 and 4 as failed ("the refuter fired as written"), the other counts them as unsettleable (the MDE says the refutation is below the detection limit). If 1 and 4 are unsettleable, no row in this table fires — the first row needs ≥ 2 to hold, the third needs all three to fail, and "unsettleable" is neither. The decision rule has no row for the state its own MDE says is possible. Only prediction 2's refutation (inputTokens −88 % vs ±6 % MDE) is clearly outside the band.
**Layer of the implied fix:** L3
**Anchor:** `| predictions 1, 2 and 4 all fail and 3 holds | INCONCLUSIVE, leaning REJECT-as-stated — isolation would be buying something this experiment cannot see. Record it; do not remove the flag on one experiment |`

### Timestamp check
**Verdict:** no finding

### Observed telemetry
**Verdict:** no finding

### Results
**Verdict:** finding
**Failure:** The text says "The duration tail did not reproduce, so duration is settleable." "Settleable" here means the tail exclusion did not fire — but the MDE of ±20 % was also registered for duration, and the observed +16.7 % is inside that band. A reader who takes "settleable" at face value accepts prediction 1's refutation; a reader who checks the MDE finds the refutation is below the detection limit. The same gap exists for toolCalls (MDE ±2, observed 0). The word "settleable" conflates "not excluded by the tail rule" with "detectable by the MDE," and only the first is argued.
**Layer of the implied fix:** L3
**Anchor:** `The duration tail did not reproduce, so duration is settleable.`

### Which predictions held
**Verdict:** finding
**Failure:** Predictions 1 and 4 are marked "NO" at effect sizes within the registered MDE. Prediction 1: +16.7 % vs ≥ +20 %, MDE ±20 %. Prediction 4: 0 vs ≥ +2, MDE ±2. The table says "The refuter fired exactly as written" for prediction 1, but the MDE says the experiment cannot distinguish the observed from the threshold. The decision's third row requires all three to fail, but only prediction 2's refutation (inputTokens −88 %, MDE ±6 %) is outside the MDE band. Whether the MDE, derived from the historical baseline's factor-of-54 spread, is conservative for the matched pair (whose ranges are ~1.75×) is not argued — so a reviewer cannot resolve whether +16.7 % is truly below +20 % or merely indistinguishable from it.
**Layer of the implied fix:** L3
**Anchor:** `Below the threshold, and *closer to the ~13 % prior from `EXP-BE002-NOHOOKS` on a different task than to the +35 % estimate that dismissed it.* The refuter fired exactly as written`

### Failure analysis
**Verdict:** no finding

### Sanity checks
**Verdict:** no finding

### Decision
**Verdict:** finding
**Failure:** The verdict is stated as "the third row of the registered decision table, fired exactly as written: predictions 1, 2 and 4 all fail and 3 holds." Two of the three failures are at effect sizes inside the experiment's own MDE. A reviewer who applies the MDE finds no row fires and the verdict is unregistered, not INCONCLUSIVE. The practical recommendation (KEEP the flag) is unaffected — it rests on the quality-not-measured argument, not on the verdict classification — but the classification itself is not supported by the detection limit the experiment registered.
**Layer of the implied fix:** L3
**Anchor:** `INCONCLUSIVE, leaning REJECT-as-stated — the third row of the registered decision table, fired exactly as written: predictions 1, 2 and 4 all fail and 3 holds.`

### Follow-up
**Verdict:** no finding

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The evaluator pass/fail is a gate (prediction 3). The rubric is mentioned in follow-up 1 but not applied to this experiment. No duplication.
- **Which single section would two reviewers diverge on most, and by how much?** The Decision rule. One reviewer reads "the refuter fired as written" and accepts the INCONCLUSIVE verdict. Another reads the MDE table and finds predictions 1 and 4 refuted below the detection limit, making the third row inapplicable and the verdict unregistered. The divergence is not a matter of degree — it changes the verdict from a registered state to an unregistered one.
- **What did the artifact not say that it needed to say?** The artifact registered an MDE for each outcome and then never referenced it when interpreting results. It did not say whether the MDE, derived from the historical baseline's factor-of-54 spread, applies to the matched pair (whose ranges are ~1.75×). It did not say what happens when a refutation falls inside the MDE band — whether the prediction is "failed" or "unsettleable." The decision rule has no row for "some predictions unsettleable by MDE," a state the MDE itself says is possible.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Why a matched pair, rather than one un-isolated run against the nine on record
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
**Verdict:** finding
**Failure:** Prediction 2's text and its refuter specify different thresholds for `inputTokens`, and the actual result (-88%) satisfies one and triggers the other. The prediction reads "the contaminated arm's `cacheCreationTokens` median is ≥ 15 % higher, and `inputTokens` is NOT" — where "is NOT" grammatically refers back to "≥ 15 % higher," making the claim "inputTokens is not ≥15% higher." The refuter reads "inputTokens moving by more than its own baseline spread (>6 %)." A -88% move is NOT ≥15% higher (prediction text satisfied) AND moved more than 6% (refuter triggered). Reviewer A reads the prediction text, adjudicates prediction 2 as held (cacheCreation +17.1% ≥ 15%, inputTokens is not ≥15% higher), and arrives at 1-of-4 held. Reviewer B reads the refuter, adjudicates as refuted, and arrives at 1-of-4 held for a different reason. The verdict coincidentally matches, but the path diverges — and if the inputTokens drop had been, say, -10% (not ≥15% higher, but >6% move), the two readings would produce opposite adjudications on prediction 2, flipping the count of held predictions between 1 and 2 and potentially changing which row of the decision table fires.
**Layer of the implied fix:** L3
**Anchor:** "the contaminated arm's `cacheCreationTokens` median is ≥ 15 % higher, and `inputTokens` is NOT" vs. "inputTokens moving by more than its own baseline spread (>6 %)"

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
**Verdict:** finding
**Failure:** Every "MDE at n=5/arm" value in the table is identical to the corresponding prediction's threshold: duration ±20% = prediction 1's ≥20%, cacheCreation ±15% = prediction 2's ≥15%, inputTokens ±6% = prediction 2's 6% spread, toolCalls ±2 = prediction 4's ≥+2. The MDE is a power concept — the smallest effect detectable at a given sample size and variance — and should be derived from the baseline spread and n, not copied from the prediction threshold. A reviewer who understands power analysis would reject these as MDEs; a reviewer who reads them as "pre-registered thresholds" would accept them. The conflation matters because the duration baseline spread is 70,000–3,790,000 (factor of 54), for which the actual MDE at n=5 would be far larger than ±20% — meaning the experiment is underpowered for duration in a way the table hides by labeling the threshold as the MDE.
**Layer of the implied fix:** L3
**Anchor:** "MDE at n=5/arm" column values matching prediction thresholds exactly

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** finding
**Failure:** The decision table has four rows but does not cover the case where exactly 1 of predictions {1, 2, 4} holds and prediction 3 holds. Row 1 requires ≥2 of {1,2,4}; row 3 requires all three fail. If exactly one holds (e.g., prediction 2 adjudicated as held per its text rather than its refuter), no row fires and the verdict is undefined. Two reviewers would diverge: one would say "no row matches, so VOID by exhaustion"; another would say "the table is incomplete, so the verdict is undecided." This gap did not fire in the actual experiment (all three failed, row 3 fired), but it is a defect in a pre-registered rule that a different result would have exposed.
**Layer of the implied fix:** L3
**Anchor:** "≥ 2 of predictions 1, 2, 4 hold and prediction 3 holds" and "predictions 1, 2 and 4 all fail and 3 holds"

### Timestamp check
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** finding
**Failure:** The -88% `inputTokens` finding is explained as "the ~1,400-token task prompt lands inside the cached prefix, so what is counted as uncached input is only the small remainder." This explains the open arm but not the isolated arm: in the isolated arm, the task prompt is also the first user input, yet `inputTokens` is 1,416 and `cacheCreationTokens` is 26,119 — so something else (system prompt, tool definitions) is being cached, and the task prompt is counted as uncached input. The explanation does not specify why the task prompt is `inputTokens` in one arm and `cacheCreationTokens` in the other. A reviewer who understands Claude's cache breakpoint accounting would accept the bucket-migration story; a reviewer who does not would take it on faith. The sanity check (cost rose 13.8%) is consistent with the explanation but does not distinguish "prefix grew because of hook output" from "prefix grew because the cache breakpoint shifted" — which is the follow-up the artifact itself registers but has not run.
**Layer of the implied fix:** L3
**Anchor:** "With hook output prepended, the ~1,400-token task prompt lands inside the cached prefix, so what is counted as uncached input is only the small remainder."

### Which predictions held
**Verdict:** finding
**Failure:** The adjudication table rephrases prediction 2 as "cacheCreationTokens ≥ +15% and inputTokens not moving beyond its 6% baseline spread" — adopting the refuter's 6% threshold rather than the prediction text's "is NOT [≥15% higher]" threshold. The rephrasing is silent: it does not acknowledge that the original prediction text used a different threshold. A reviewer scoring from the original prediction text would adjudicate prediction 2 as held (inputTokens -88% is not ≥15% higher); a reviewer scoring from the adjudication table would adjudicate as refuted (inputTokens moved >6%). The sub-section "Prediction 2 is the one worth reading twice" argues the refutation is informative, but it presupposes the refuter's threshold is the correct one without addressing why the prediction text says something different.
**Layer of the implied fix:** L3
**Anchor:** "cacheCreationTokens ≥ +15% and inputTokens not moving beyond its 6% baseline spread" (adjudication table) vs. "inputTokens is NOT" (original prediction)

### Failure analysis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** The decision table's row 3 says "Record it; do not remove the flag on one experiment." The Decision section says "KEEP `ISOLATE_USER_SETTINGS=1` in the runbook, now with a number attached instead of an argument, and with the argument corrected." "Do not remove" is neutral — don't change yet. "KEEP ... with the argument corrected" is an active endorsement that rewrites the runbook's justification. Two reviewers would diverge: one would say "do not remove = keep, so this is consistent"; another would say "the table says don't remove on one experiment, and this is actively revising the runbook's rationale, which is a stronger action than the rule authorizes." The artifact's reasoning (quality unmeasured on 9 of 10 runs) is sound, but it is an argument made after the rule was registered, not a consequence the rule specifies.
**Layer of the implied fix:** L3
**Anchor:** "Record it; do not remove the flag on one experiment" vs. "KEEP `ISOLATE_USER_SETTINGS=1` in the runbook, now with a number attached instead of an argument, and with the argument corrected"

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The evaluator's pass/fail (prediction 3) and the rubric's quality scoring are separate instruments, but the Decision section uses the *absence* of rubric scoring on 9 of 10 runs as the reason to keep the flag mandatory. This is not a duplication — it is an argument from missing data — but it means the decision's force rests on a measurement that was not taken, which is the same shape as the `userSettingsIsolated: null` problem the experiment was designed to escape.
- **Which single section would you expect two reviewers to diverge on most, and by how much?** Predictions / Which predictions held, by a full verdict. The prediction 2 text and its refuter specify different `inputTokens` thresholds, and the adjudication silently adopts the refuter's. A reviewer reading the prediction text scores prediction 2 as held; a reviewer reading the refuter scores it as refuted. In the actual experiment both paths land on 1-of-4 held and the same decision row fires, but a -10% `inputTokens` drop (instead of -88%) would split the two paths into 1-of-4 vs. 2-of-4, hitting the decision table's uncovered gap.
- **What did the artifact not say that it needed to say?** Two things. (1) It did not acknowledge that the prediction 2 text and refuter use different `inputTokens` thresholds, or explain which is authoritative. (2) The B2 README — the phase document this experiment closes — still says at line 778 that the cross-harness disagreement is "three times out of three" and "the same mechanism firing on every run," while the project's own CLAUDE.md amended that to 3-of-5 on 2026-09-01. The E-002 artifact does not reference this stale claim, but it inherits the phase's closure, and a reader following the link from E-002 to the B2 README would find a mechanism claim that has been refuted by two more runs and not corrected in place.
