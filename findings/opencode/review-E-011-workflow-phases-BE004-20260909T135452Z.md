# opencode review — E-011-workflow-phases-BE004

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260909T135452Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-011-workflow-phases-BE004.md
    sha:  129d8e892d6c
    dirty: false
  - path: benchmark/rubrics/backend-quality-be004.yaml
    sha:  6252778b8472
    dirty: false
lab_head:        cf18269
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 106s |
| ollama-cloud/deepseek-v4-pro | FAILED | rc=1 77s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Predictions | 1/1 | L3 |
| Independent variable | 1/1 | L1 |
| Controlled variables | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions, registered before the data | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Threats to validity, registered before the run | 1/1 | L1 |
| §4 step 4 — the rubric proof | 1/1 | L2 |
| Results | 1/1 | L2 |
| Decision | 1/1 | L3 |
| architecture-consistency | 1/1 | L3 |
| maintainability | 1/1 | L3 |
| test-quality | 1/1 | L3 |
| change-focus | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### What is different here, stated before anything is predicted
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** Suppose treated test-quality anchor-2 counts are 6/10 and control counts are 0/10. One reviewer can treat P7 as held because 6 is “specifically not ≥ 5” is false and therefore refuted; another can use the later registered ≥7 threshold and call 6 merely below detection. The artifact gives incompatible operative boundaries for the same outcome, so reviewers can classify the identical batch differently.
**Layer of the implied fix:** L3
**Anchor:** “the `test-quality` anchor 2 count in the treated arm is ≤ 3 of 10, and specifically not ≥ 5 of 10”

### Independent variable
**Verdict:** finding
**Failure:** A control run has 29 tools including `Task`, while a treated run has only four tools and cannot delegate. If the control delegates and finishes with fewer calls, one reviewer attributes the difference to the phase procedure while another attributes it to tool availability. Thus the stated one-variable claim is false for the actual delivered inputs.
**Layer of the implied fix:** L1
**Anchor:** “One thing changes”

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** No additional concrete failure beyond the tool-list confound reported under “Independent variable.”
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Controlled variables
**Verdict:** finding
**Failure:** The rubric row calls sha `6252778b8472` “proved” and says it was written after proof, while the rubric file itself remains labeled “DRAFT, UNPROVEN.” A reviewer checking the experiment file accepts it as proved; a reviewer treating the versioned rubric as the authority rejects its use for run scoring. The same 20 sheets therefore enter or fail admissibility depending on which artifact controls status.
**Layer of the implied fix:** L3
**Anchor:** “Rubric | **`benchmark/rubrics/backend-quality-be004.yaml`, sha `6252778b8472`** — ported at `c42120b`, **proved at §4 step 4 before any run was scored**”

### Runs
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** For treated/control anchor-2 counts of 7/10 versus 7/10, one reviewer reads the threshold as satisfied because treated is ≥7; another reads “against the concurrent control, two-sided Fisher” as requiring a between-arm effect and rejects it. The table does not state whether ≥7 is an absolute threshold, a difference, or merely the count used in a test.
**Layer of the implied fix:** L3
**Anchor:** “`test-quality` anchor 2 | **none — the rubric does not exist yet** | **≥ 7 of 10 treated** against the concurrent control, two-sided Fisher”

### Deterministic evaluation
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** finding
**Failure:** If one run has non-null telemetry fields but its `events.jsonl` does not grow, rule 3 says telemetry “did not export” and excludes it, while the Controlled variables section says growth is required before turn or cost numbers are trusted. One reviewer excludes the entire run from every comparison; another keeps it for evaluator and rubric outcomes but discards only telemetry metrics. The exclusion scope is not defined.
**Layer of the implied fix:** L3
**Anchor:** “A run whose telemetry did not export is excluded”

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** With P2=P3=10/10, P5 and P6 failing their registered increase thresholds, evaluator passes tied, and treated cost 9.9% lower with separated quartiles, one reviewer fires row 4 because neither registered overhead outcome cleared; another says lower cost means “something improved” and fires row 7. The artifact itself took the second route, but “nothing improved” never defines its metrics or direction, so the verdict is not reproducible.
**Layer of the implied fix:** L3
**Anchor:** “neither P5 nor P6 clears **and** nothing improved”

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** The list contains two items numbered 7. A later instruction to act on “threat 7” can mean either the coarse `n=10` threshold issue or the treated/control tool-list confound; two reviewers can therefore verify different threats while both claiming compliance.
**Layer of the implied fix:** L1
**Anchor:** “7. **`n = 10` per arm is coarse.**” and “7. **The treated arm is delivered four tool names and the control twenty-nine**”

### Deliberate failure — run once, on BE-003, and here is why
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 4 — the rubric proof
**Verdict:** finding
**Failure:** The section concludes the rubric is proved even though its off-dimension invariance is checked only by the rubric being tested. A fixture can accidentally drift in architecture while retaining an existing `ApiException` pattern that still earns 2; the grid reports the off-dimension cell as held although the claimed one-dimension-only fixture construction is false. Two reviewers inspecting the source diff versus only the score grid can therefore accept or reject the proof.
**Layer of the implied fix:** L2
**Anchor:** “Every variant scored 2 on all three dimensions it does not vary.”

### §4 step 5 — the preflight pair
**Verdict:** no finding
**Failure:** No additional concrete failure beyond the tool-list confound reported under “Independent variable.”
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch
**Verdict:** no finding
**Failure:** No concrete divergent-review or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** finding
**Failure:** The registered mitigation requires counting actual `Task` use in every control transcript and reporting the count even when zero. The Results report only that control runs were delivered `Task`, then declare the threat “closed mechanically.” If one control transcript actually delegates, a reviewer relying on this section treats the confound as inert while a reviewer inspecting transcripts treats cost and turn comparisons as multiply caused.
**Layer of the implied fix:** L2
**Anchor:** “Threat 7 is closed mechanically on this task as it was on BE-003.”

### Which predictions held
**Verdict:** no finding
**Failure:** Given the artifact’s stated prediction definitions, the held/refuted table reproduces the reported observations. The threshold ambiguity is reported under “Predictions” and “Minimum detectable effect.”
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** For the observed negative cost difference, row 4 and row 7 remain simultaneously plausible because the decision section resolves “nothing improved” after seeing the data by appealing to the row’s gloss. A reviewer applying only registered predicates can choose row 4; the artifact chooses row 7. This changes the formal verdict from NOT DETECTABLE to INCONCLUSIVE on the identical batch.
**Layer of the implied fix:** L3
**Anchor:** “The same ambiguity the §4a review raised against E-010's row 4 applies here and is resolved the same way”

### architecture-consistency
**Verdict:** finding
**Failure:** Consider a diff that changes only the order controller, while an unchanged shipment controller contains a refusal implemented with `check(...)`. Because the scorer receives only changed files and their pre-agent versions, the shipment controller is absent. One reviewer scores 2 from the attached order refusal sites; another cannot establish “every refusal in either package” and scores 1 or null. The required universal claim is not decidable from the declared evidence set.
**Layer of the implied fix:** L3
**Anchor:** “Every refusal in EITHER package throws an `ApiException` subclass”

### maintainability
**Verdict:** finding
**Failure:** Consider `return when (order.status) { ACTIVE -> cancel(); CANCELLED -> conflict() }`. One reviewer treats the `when` value as used because it is returned and assigns 2; another notes that both branch calls return `Unit`, so the expression’s value carries no decision result and treats it as effectively statement-position, assigning 0. The syntactic “used” definition does not resolve whether a Unit-valued return qualifies.
**Layer of the implied fix:** L3
**Anchor:** “Expression position means its value is USED — returned, assigned, passed as an argument, or the last expression of a lambda; anything but discarded.”

### test-quality
**Verdict:** finding
**Failure:** Consider a test that calls `cancel` twice, asserts the second response body, then issues one `get('/orders/{id}?includeShipments=true')` whose body contains both order and shipment statuses. One reviewer scores clause (b) met because both states were re-read through a GET; another scores it unmet because “separate `get(...)` requests” requires distinct order and shipment requests. The same test can therefore receive 1 or 2.
**Layer of the implied fix:** L3
**Anchor:** “the order's status AND at least one of its shipments' statuses are re-read through separate `get(...)` requests”

### change-focus
**Verdict:** finding
**Failure:** Consider a diff that adds a required import and an IDE also alphabetically reorders two pre-existing imports. One reviewer treats the whole import block as permitted because it contains an import required by a named method; another treats the unrelated reorder as a difference beyond the allowed list and scores 1. “Imports it requires BY SYMBOL” does not specify how mixed required and unrelated import-block changes are classified.
**Layer of the implied fix:** L3
**Anchor:** “the new `cancel` method and the imports it requires BY SYMBOL”

### Cross-cutting
**Verdict:** finding
**Failure:** The delivery scoring in P1 duplicates the pass/fail run gate where rubric-sha or delivery defects can make data inadmissible, while decision-rule row 0 again turns those conditions into VOID. The greatest reviewer divergence is in “Decision rule, fixed before the run”: the observed batch can be NOT DETECTABLE under row 4 or INCONCLUSIVE under row 7, a full verdict-category difference. The artifact also needed to state an executable precedence rule for rubric proof status, define “nothing improved,” and report actual control-arm `Task` invocation counts rather than tool availability.
**Layer of the implied fix:** L3
**Anchor:** “Applied **in order**, stopping at the first row that fires.”

