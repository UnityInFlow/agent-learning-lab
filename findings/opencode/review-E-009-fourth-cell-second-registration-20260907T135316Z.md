# opencode review — E-009-fourth-cell-second-registration

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260907T135316Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-009-fourth-cell-second-registration.md
    sha:  519442a7487a
    dirty: false
lab_head:        f0d1fa5
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 121s |
| codex | ok | 115s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Question | 1/1 | L3 |
| Predictions | 1/1 | L3 |
| Controlled variables | 1/1 | L2 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions, registered before the data | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Threats to validity, registered before the run | 1/1 | L3 |
| §4 step 6 — the batch, recorded 2026-09-07T12:50:10–13:31:01Z | 1/1 | L3 |
| §4 step 7 — the twenty registered sheets | 1/1 | L3 |
| Results | 1/1 | L3 |
| Failure analysis | 1/1 | L3 |
| Sanity checks | 1/1 | L3 |
| Decision | 1/1 | L3 |
| Follow-up | 1/1 | L3 |
| §5 — validation table | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Which predictions held | 1/1 | L3 |
| The report-only metrics, and why they point the same way | 1/1 | L3 |
| `change-focus` moved on this model, which the record says it does not | 1/1 | L3 |


---

## Run 1 of 2 — codex

### What is unchanged from E-008, and why this is not a re-run of a broken thing
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Question
**Verdict:** finding
**Failure:** Suppose the prose affects `test-quality` only when placed in a worker system prompt, while identical words in project memory have no effect. E-007 arm O would score 5/10 and E-009 arm F 0/10 exactly as observed, yet the experiment would answer “the split” even though placement—or placement interacting with fresh context—caused the difference. Two reviewers can therefore classify the same results as “decomposition” or “seat/context.”
**Layer of the implied fix:** L3
**Anchor:** **Is the effect the decomposition, or the prose it carried?**

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** If the concurrent control produces `c = 2` and arm F produces `k = 7`, the registered magnitude “4–7 of 10” holds but the required Fisher result does not: the MDE table says `c = 2` requires `k ≥ 8`. One reviewer can mark the directional/magnitude prediction correct and significance prediction wrong; another can mark the single compound Q1 wholly refuted.
**Layer of the implied fix:** L3
**Anchor:** arm F **4–7 of 10**, control **0–1 of 10**; two-sided Fisher vs the concurrent control **`p < 0.05`**

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
**Verdict:** finding
**Failure:** Every pair runs F before C. If a time-varying condition—API load, cache warming, thermal throttling, or model-service drift—changes monotonically during each pair, all F runs receive the earlier condition and all controls the later one. A reviewer treating “interleaved” as adequate control will attribute a difference to treatment; a reviewer requiring counterbalanced within-pair order will identify an arm-correlated timing confound.
**Layer of the implied fix:** L2
**Anchor:** interleaved F/C pairs

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** Row 0a permits only 8 admitted runs per arm, but the displayed MDEs are calculated for 10 per arm. If exclusions leave 8 per arm, a reader may apply the stated `≥5`, `≥7`, or `≥8` separations even though their Fisher probabilities and power no longer match the table; another reader will recompute them for 8. The registered interpretation is therefore not fully specified for an allowed dataset.
**Layer of the implied fix:** L3
**Anchor:** MDE at `n = 10` per arm

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** finding
**Failure:** A run may pass the evaluator but have a missing or unparsable rubric sheet. `test-quality null` says it remains in Q1 as not-anchor-2, while row 0a counts “admitted runs” and the decision rule does not say whether admission means evaluator admission or availability of a valid score. One reviewer will include the run as a failure; another will treat the missing score as an instrumentation failure and exclude or void it.
**Layer of the implied fix:** L3
**Anchor:** a `test-quality` `null` counts as *not anchor 2* in Q1's count and is reported separately

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** With `c = 1`, `k = 0`, and E-007 arm O at 5/10, row 2 assigns the effect to “the split.” The same counts arise if decomposition has no effect but the prose works only in the worker-system-prompt seat. The rule forces a causal verdict that the interventions do not distinguish.
**Layer of the implied fix:** L3
**Anchor:** **reading (b) — `test-quality` is a return from the split**

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** The section correctly identifies that a null result cannot distinguish decomposition from instruction placement, but the registered decision rule still does so. Given F 0/10 and O 5/10, one reviewer will treat this threat as limiting the conclusion to “project-memory prose did not reproduce the effect”; another will accept the later categorical “return from the split.”
**Layer of the implied fix:** L3
**Anchor:** A null (row 2) means *the prose as an instruction file* does not reproduce the effect, not that the prose did nothing in the worker's seat.

### Deliberate failure
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch, recorded 2026-09-07T12:50:10–13:31:01Z
**Verdict:** finding
**Failure:** The other-project sweep is known to be alive only when the batch ended, but the artifact does not establish when it started or whether it overlapped one arm more than the other. If it began during pair 10 between F and control, the control duration and resource use are contaminated; if it began after both runs, neither is. Reviewers cannot determine which report-only telemetry is comparable.
**Layer of the implied fix:** L3
**Anchor:** a process belonging to **another project** (`scripts/gate03-sweep.sh`, a `.planning/` sweep — not this lab's, not a benchmark, scorer or review process of this experiment) was alive on the machine when the batch ended

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 7 — the twenty registered sheets
**Verdict:** finding
**Failure:** Only three of twenty cells were manually re-derived, and two were selected after seeing the sheets. If three unreviewed control scores of 1 were actually 2, `c` would become 4 and row 0b—not row 2—would apply. A reviewer may regard the checks as sufficient targeted validation because the observed 2 was checked; another may regard scorer error on the remaining sheets as unmeasured.
**Layer of the implied fix:** L3
**Anchor:** ### The hand re-read agrees, and so do two more cells I checked myself

### Results
**Verdict:** finding
**Failure:** The pooled-control comparisons combine controls from separate registrations and batches. If baseline anchor-2 frequency shifted between the E-007 and E-009 windows, pooling 0/10 with 1/10 yields `p = 0.0088` against arm O even though neither pooled observations nor exchangeability were registered. One reviewer may treat this as corroboration; another will reject the p-value as an unregistered cross-batch analysis.
**Layer of the implied fix:** L3
**Anchor:** arm O 5/10 vs the two concurrent plain controls pooled, 1 of 20

### Failure analysis
**Verdict:** finding
**Failure:** A stable scoring bias shared by Codex and the author's interpretation of the same ambiguous rubric clause would survive the three hand checks. For example, if another competent reviewer treats an assertion on the second confirm response as proof that state “changes nothing,” all ten F runs could qualify for anchor 2 without any delivery or telemetry check detecting the disagreement. The claim that no instrument remains between prediction and result is therefore stronger than the evidence.
**Layer of the implied fix:** L3
**Anchor:** **There is no instrument between the prediction and the result this time**

### Sanity checks
**Verdict:** finding
**Failure:** The checklist says no flattering number appeared, but the control's sole anchor-2 score raises `c` from 0 to 1 and therefore makes the treatment look worse, not better. If that score were wrongly high, correcting it to 1 would change the result from 0/10 versus 1/10 to 0/10 versus 0/10—still row 2 but less adverse to the hypothesis. Two reviewers can disagree about which direction is “flattering” because the statement reverses the comparison.
**Layer of the implied fix:** L3
**Anchor:** The single number that could have flattered it — the control's one 2 — was re-derived by hand, and it stands.

### Decision
**Verdict:** finding
**Failure:** Observed F 0/10 and E-007 O 5/10 are compatible both with a decomposition effect and with a worker-seat/fresh-context effect explicitly acknowledged under threats. The categorical sentence “Remove the decomposition, keep the words verbatim, and the effect disappears completely” lets one reviewer infer decomposition causality, while another can support only the narrower claim that moving those words into `CLAUDE.md` failed to reproduce the effect.
**Layer of the implied fix:** L3
**Anchor:** **Reading (b), decision rule row 2: `test-quality` is a return from the split, not from the prose it carried.**

### Follow-up
**Verdict:** finding
**Failure:** The proposed reverse cell strips the prose while retaining the split, but describes a positive result as separating “fresh context” from “decomposition plus any instruction.” Those remain bundled: a bare-instruction worker has both decomposition and fresh context. If it reproduces 5/10, one reviewer will attribute the effect to decomposition; another to fresh context, so the proposed test does not resolve the mechanism as claimed.
**Layer of the implied fix:** L3
**Anchor:** the reverse cell — the split with the worker's prose stripped to a bare *"implement the ticket"* — would say whether the return comes from the fresh context or from decomposition plus *any* instruction

### §5 — validation table
**Verdict:** finding
**Failure:** The proof that “no split in either arm” is asymmetric: an F delegation aborts, but a control delegation is merely recorded. For a control run containing a delegation, the stated gate clause “no split in either arm” would be false while the named L2 behavior would allow the batch to continue. One reviewer will read the row as proof of this observed batch only; another will read the L2 label as enforcement of the clause for both arms.
**Layer of the implied fix:** L3
**Anchor:** | no split in either arm | `deleg_stream` and `deleg_telemetry` both 0 on 20 of 20 (manifest columns 7–8); no `control-delegations.txt` was written | **L2** — an arm-F delegation aborts the batch; a control delegation is written to a file |

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates the evaluator pass/fail gate: the evaluator decides correctness, while the four rubric categories score admitted runs. Reviewers are most likely to diverge on `Decision`: one will report row 2 exactly as registered (“split”), while another will limit the conclusion to failure of prose delivered through project memory; that is a one-level difference from causal attribution to non-reproduction. The artifact needed to say that E-009 cannot distinguish decomposition from worker-seat/fresh-context effects, and it needed a rule for valid analysis when admission falls from 10 to the permitted minimum of 8 or when a rubric cell is null.
**Layer of the implied fix:** L3
**Anchor:** **Reading (b), decision rule row 2: `test-quality` is a return from the split, not from the prose it carried.**


---

## Run 2 of 2 — codex

### What is unchanged from E-008, and why this is not a re-run of a broken thing
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

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
**Verdict:** finding
**Failure:** Suppose one arm-F run has the wrong instructionsHash but Q1 lands inside its predicted range. One reviewer records Q1 as held and Q2 as failed; another treats Q2 solely as a void condition and says the experiment has no outcome because the batch is void. The artifact calls Q1 the “one registered outcome” while later counting Q2–Q4 among the predictions that held, so the registered prediction set has two competent interpretations.
**Layer of the implied fix:** L3
**Anchor:** “One registered outcome” / “Q2 | delivery: `customization.instructionsHash`” / “Which predictions held”

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Consider two implementations producing these same records: in A, the runtime reads and follows CLAUDE.md but does not adopt the requested test pattern; in B, the runtime reports the file hash but never reads its contents. Both yield arm F 0/10 and control 1/10, yet one refutes the behavioral hypothesis and the other is a delivery failure. Q1 cannot distinguish them, so the artifact cannot prove its chosen interpretation.
**Layer of the implied fix:** L2
**Anchor:** “What still cannot be proved from the run record: that the runtime *read* the file. … the content half is Q1's job.”

### Controlled variables
**Verdict:** finding
**Failure:** A non-lab process (`scripts/gate03-sweep.sh`) overlaps only the final five pairs and consumes enough CPU to alter timing or model-service contention. One reviewer treats “no other lab process” literally and keeps the batch because the process belongs to another project; another treats the intended control as no competing experimental process and marks the affected observations uncontrolled. The stated control does not define which interpretation applies.
**Layer of the implied fix:** L3
**Anchor:** “no other lab process during the batch”

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
**Verdict:** finding
**Failure:** Suppose treatment causes two implementations to fail the evaluator while all ten controls pass; the remaining eight treatment runs score 5/8 at anchor 2 and separate from control. Row 0a does not void because eight are admitted, and the artifact can declare a prose effect after excluding two treatment-caused failures. A reviewer estimating the effect on all assigned runs reaches a different answer because evaluator failure is a post-treatment outcome, not demonstrated infrastructure noise.
**Layer of the implied fix:** L3
**Anchor:** “evaluator exit ≠ 0 … excluded from scoring”

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** The observed `(c=1,k=0)` occurs both if decomposition itself causes E-007’s effect and if the prose causes the effect only when placed in a worker system prompt rather than CLAUDE.md. Row 2 assigns both worlds the same verdict—“return from the split”—although the artifact acknowledges that seat and decomposition changed together. Two reviewers can therefore accept the counts but reject or accept the causal verdict.
**Layer of the implied fix:** L3
**Anchor:** “reading (b) — `test-quality` is a return from the split”

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** With arm O using a worker system prompt and arm F using project memory, the actual 5/10 versus 0/10 pattern is compatible with a seat effect, a decomposition effect, or their interaction. One reviewer follows the first bullet and limits the conclusion to “instruction-file prose did not reproduce”; another follows the registered decision rule and concludes “the split caused it.” The threats section identifies the confound but supplies no rule preventing the broader conclusion.
**Layer of the implied fix:** L3
**Anchor:** “A null (row 2) means *the prose as an instruction file* does not reproduce the effect, not that the prose did nothing in the worker's seat.”

### Deliberate failure
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch, recorded 2026-09-07T12:50:10–13:31:01Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 7 — the twenty registered sheets
**Verdict:** finding
**Failure:** Seventeen of twenty sheets have no documented second reading. If one of those runs contains a `get(...)` after confirm but the scorer assigns test-quality 1, one reviewer accepts the asserted parser output and obtains `k=0`; another applies the stated second-reader obligation, corrects the cell to 2, and obtains `k=1`. The artifact establishes parsing and three hand checks, not agreement on every sheet as promised.
**Layer of the implied fix:** L3
**Anchor:** “the second reader is owed on every sheet”

### Results
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Q1 is REFUTED, and not narrowly
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** finding
**Failure:** If an arm-F run has a delegation event, Q3 is false but row 0a voids the experiment. One reviewer reports “Q3 failed”; another says no registered outcome was evaluated because Q3 is a delivery condition, consistent with the earlier statement that Q1 is the sole outcome. The table does not resolve whether Q2–Q4 are empirical predictions, validity gates, or both.
**Layer of the implied fix:** L3
**Anchor:** “Q3 | 0 arm-F delegations, both sources | yes”

### The report-only metrics, and why they point the same way
**Verdict:** finding
**Failure:** Suppose the other-project sweep overlaps the slower half of one arm’s runs. One reviewer treats the duration comparison as unusable under the registered overlap exclusion; another reports the full-arm 89-second medians because the overlapping process was not classified as a lab process. The reported equality can therefore depend on an unresolved exclusion decision.
**Layer of the implied fix:** L3
**Anchor:** “`durationMs` on any run overlapping another lab process … duration excluded” / “a process belonging to another project … was alive”

### `change-focus` moved on this model, which the record says it does not
**Verdict:** finding
**Failure:** For run `474fb3ea`, one reviewer awards 2 because the diff has zero deletions and is therefore “nearer” the anchor; another awards 1 because it changes three files and adds an ErrorCode constant and tests beyond `confirm` and its by-symbol imports. The artifact’s own defense relies on relative nearness, while the stated anchor is categorical, so the reported correction from “dead” to “rare” is reviewer-dependent.
**Layer of the implied fix:** L3
**Anchor:** “The anchor asks that only `confirm` and its by-symbol imports differ; a pure-addition diff is nearer that than one that removes existing lines, so the 2 is defensible”

### Failure analysis
**Verdict:** finding
**Failure:** A runtime that records the instructionsHash but silently ignores CLAUDE.md produces every listed successful harness check and the observed 0/10 result. One reviewer then attributes failure to delivery; another follows this section and attributes it to the agent. Because runtime content consumption is expressly unproved, “the agent” is not identified by the evidence.
**Layer of the implied fix:** L2
**Anchor:** “Was it the agent, or the harness? The agent.”

### Sanity checks
**Verdict:** finding
**Failure:** The control’s lone anchor-2 score makes the treatment look worse and strengthens the narrative that arm F is baseline-like; it is therefore potentially flattering to the eventual split-benefit conclusion even though it is adverse to the original prose hypothesis. One reviewer answers the check relative to the registered hypothesis and says none; another answers relative to the published decision and flags that cell. The reference claim for “flattering” is unspecified.
**Layer of the implied fix:** L3
**Anchor:** “Did any flattering number appear? None.”

### Decision
**Verdict:** finding
**Failure:** Under a seat-dependent-prose world, the same words cause anchor-2 tests in a worker system prompt but not in project memory; decomposition itself contributes nothing. The observed E-007 5/10 and E-009 0/10 data are then expected, yet this section states that the effect is “not from the prose it carried” and disappears when decomposition is removed. A reviewer respecting the registered threat limits the conclusion to this delivery seat; another accepts the stronger causal claim.
**Layer of the implied fix:** L3
**Anchor:** “`test-quality` is a return from the split, not from the prose it carried.”

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §5 — validation table
**Verdict:** finding
**Failure:** A control run can delegate, be written to `control-delegations.txt`, and still complete and enter analysis. Nothing executes and rejects that bad state, yet the combined “no split in either arm” proof is labeled L2. For a batch with one control delegation, one reviewer accepts L2 because the event is detected and recorded; another applies the layer rule and labels the control half L3 because recording is not rejection.
**Layer of the implied fix:** L3
**Anchor:** “no split in either arm … **L2** — an arm-F delegation aborts the batch; a control delegation is written to a file”

### Cross-cutting
**Verdict:** finding
**Failure:** The `test-quality` scoring category duplicates the gate only if evaluator correctness includes persisted-state verification; the artifact says the evaluator decides correctness but never states whether that exact clause is included, so two reviewers can classify it differently. The greatest expected divergence is in `Decision`: one reviewer reports only that CLAUDE.md prose failed to reproduce the effect, while another attributes the full 50-percentage-point E-007/E-009 difference to decomposition. The artifact needed to specify how the seat confound constrains the permitted causal claim, define whether Q2–Q4 are predictions or validity gates, and document a second-reader resolution for all twenty scored sheets.
**Layer of the implied fix:** L3
**Anchor:** “The evaluator decides correctness; the rubric scores only admitted runs.” / “Reading (b) … return from the split”

