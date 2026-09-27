# opencode review — E-024-second-runtime-adapter-BE003

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260927T165223Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-024-second-runtime-adapter-BE003.md
    sha:  21fd3e88ffb1
    dirty: false
lab_head:        12cf1c4
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
| codex | ok | 66s |
| codex | ok | 65s |

Stall budget: 900s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Predictions | 1/1 | L3 |
| Census result — predictions 1 and 2, answered 2026-09-27 with no run and no money | 1/1 | L3 |
| Controlled variables | 1/1 | L2 |
| Isolation, resolved at n = 3 before the arm opened — 2026-09-27 | 1/1 | L2 |
| Preflight result — §4 step 5, 2026-09-27, PASSED 4 of 4 | 1/1 | L2 |
| Decision rule | 1/1 | L1 |
| Observed telemetry | 1/1 | L2 |
| Which predictions held | 1/1 | L2 |
| Sanity checks | 1/1 | L3 |
| Decision | 1/1 | L3 |
| Deliberate failure — DF1, registered 2026-09-27 at §4 step 9, before the run | 1/1 | L2 |
| Cross-cutting | 1/1 | L3 |
| Hypothesis | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Runs | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions | 1/1 | L2 |
| Results | 1/1 | L3 |
| Failure analysis | 1/1 | L3 |
| Follow-up | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete input or diff makes the stated questions produce divergent interpretations.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete failure scenario identified; the two claimed measured controls and the predicted mechanism are stated explicitly.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** Prediction 2 can be counted as either two or three controls. One reviewer can count the policy gate, repair limit, and named-agent boundary separately and expect a denominator of 3; another can follow “0 of 2” and treat the policy gate plus repair limit as one settings-delivered control. The later census separately names B7’s policy gate, B8’s repair limit, and the named-agent boundary, so the reported 0/2 result depends on an unstated grouping rule.
**Layer of the implied fix:** L3
**Anchor:** “Measured L2 controls that survive the port: 0 of 2 (0 %). Mechanism: the policy gate and repair limit are wired by `.claude/settings.json` …; the named-agent boundary needs `--agent`”

### Independent variable
**Verdict:** no finding
**Failure:** No concrete scenario identified; the within-batch intervention and prohibited cross-runtime comparison are explicit.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** No concrete scenario identified; installation, exact hashes, modes, preflight proof, and control proof are specified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Census result — predictions 1 and 2, answered 2026-09-27 with no run and no money
**Verdict:** finding
**Failure:** The section retains the claim that the policy-gate loss is only L3, but the same complete artifact later reports DF1 as an executing L2 test. A reviewer evaluating the census paragraph literally records the second loss as L3; a reviewer applying the later evidence records it as L2. Those reviewers produce different layer classifications for the same claimed control loss.
**Layer of the implied fix:** L3
**Anchor:** “So that control's absence is provable only by reading the runner and by `hooksHash` being null on every run ever recorded — **L3**, and it is labelled L3 here and in the workbook.”

### Controlled variables
**Verdict:** finding
**Failure:** An intermittent isolation leak need not affect both arms equally merely because both use the same path. For example, if one of five treated runs reads an operator instruction and zero of five controls do, the leak can create a treatment-control difference despite being a shared possible exposure. One reviewer can accept it as non-differential; another must treat realized leak incidence by arm as an uncontrolled confounder.
**Layer of the implied fix:** L2
**Anchor:** “if it leaks on both arms alike it is recorded as a shared uncontrolled variable”

### Isolation, resolved at n = 3 before the arm opened — 2026-09-27
**Verdict:** finding
**Failure:** The section asserts that an intermittent leak cannot manufacture a within-runtime difference, but stochastic realization can be arm-imbalanced. A concrete batch with leaks on treated runs 1 and 2 and no control leaks can change treated outputs only, even though both arms traverse the same isolation code. The three pre-batch passes do not execute during and reject that bad batch state.
**Layer of the implied fix:** L2
**Anchor:** “an intermittent leak would fall on treated and control alike and cannot manufacture a within-runtime difference”

### Runs
**Verdict:** no finding
**Failure:** No concrete scenario identified; repetitions, cross-experiment run ceiling, wall-clock ceiling, and duration exclusion are stated.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Preflight result — §4 step 5, 2026-09-27, PASSED 4 of 4
**Verdict:** finding
**Failure:** The control assertion says “all five” customization hashes are null after the correction establishes that the record has seven hash fields. If `hooksHash` or `mcpHash` were non-null while the five displayed/read-back hashes were null, one reviewer would mark the control assertion satisfied and another would mark it contaminated. The table does not expose the omitted fields.
**Layer of the implied fix:** L2
**Anchor:** “all five `customization.*Hash` `null`”

### Minimum detectable effect
**Verdict:** no finding
**Failure:** No concrete scenario identified; undefined pre-run rubric sensitivity and transferred reference populations are disclosed rather than converted into inferential claims.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deterministic evaluation
**Verdict:** no finding
**Failure:** No concrete scenario identified; correctness and rubric scoring are assigned separate roles.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** no finding
**Failure:** No concrete scenario identified; exclusions distinguish runs, duration-only exclusions, refusals, quota events, and delivery-proof voids.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** finding
**Failure:** Rows 2/3 overlap row 4 at an exactly one-point median difference. With treated median 2 and control median 1, row 2 says IMPROVED because the advantage is ≥1, while row 4 also says NOT DETECTABLE if “within 1 point” is inclusive. The ordered-row rule forces IMPROVED, but a competent reader using the ordinary inclusive meaning of “within one” can expect row 4. The same conflict occurs at treated 1 versus control 2 between rows 3 and 4.
**Layer of the implied fix:** L1
**Anchor:** “medians differ by ≥ 1 point” / “the medians are within 1 point”

### Observed telemetry
**Verdict:** finding
**Failure:** Prediction 5 named `inputTokens` and `outputTokens`, but this section substitutes `toolCalls`, `permissionDenials`, and `retries` and never reports the two predicted token fields. For a run where `inputTokens` is non-null but `toolCalls` is null, one reviewer following the registered prediction marks it refuted while another following this section marks the telemetry shape held.
**Layer of the implied fix:** L2
**Anchor:** “`estimatedCost`, `modelCalls`, `toolCalls`, `permissionDenials` and `retries` are `null` on 20 of 20 runs”

### Results
**Verdict:** no finding
**Failure:** No concrete scenario identified; the population, gate result, scorer, unavailable second reader, registered outcome, covariates, and cost row are separated.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** finding
**Failure:** Prediction 5 is marked HELD without reporting its registered `inputTokens` and `outputTokens` conditions. If either field is non-null on even one of the ten E-024 runs, the registered prediction is false, yet the displayed Actual column would still label it held because it checks different fields. Two reviewers using the prediction text versus the Actual column therefore reach different verdicts.
**Layer of the implied fix:** L2
**Anchor:** “`estimatedCost`, `modelCalls`, `toolCalls` `null` on 20 of 20 …; `reportedTotalTokens` non-null on 10 of 10”

### Failure analysis
**Verdict:** no finding
**Failure:** No concrete scenario identified; the transferred-reference failure, ceiling defect, bounded null cell, and prohibited cross-runtime conclusion are separately scoped.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** finding
**Failure:** The dramatic-number check treats proof of contact as a tested explanation for unexpectedly high contact. Router logs establish that five treated runs contacted the corpus, but they do not test why codex produced 5/5 while the transferred claude rate was 3/20. For example, identical router logging could coexist with either an AGENTS.md effect or a model effect; reviewers can accept different causal explanations while all cited checks still pass.
**Layer of the implied fix:** L3
**Anchor:** “Explanation: the router was invoked, and it is **tested rather than asserted**”

### Decision
**Verdict:** finding
**Failure:** The primary/fallback choice is said to be answered from this batch even though the design repeatedly prohibits a cross-runtime verdict and the batch contains only codex arms. Given identical codex results, one reviewer can choose claude using prior-track evidence while another can refuse to rank runtimes because model and adapter move together and claude is absent from the concurrent batch.
**Layer of the implied fix:** L3
**Anchor:** “**Primary runtime: claude. Fallback: codex** — the gate's *‘pick primary and fallback’* clause, answered from this batch”

### Deliberate failure — DF1, registered 2026-09-27 at §4 step 9, before the run
**Verdict:** finding
**Failure:** DF-P4 predicted that there was no `hooksHash` key anywhere in the record, while the additive correction establishes that `hooksHash` exists and DF1 itself reports it as `null`. Therefore “all four predictions HELD” is impossible under the registered wording: a reviewer scoring key absence marks DF-P4 refuted, while a reviewer silently changing the prediction to “hooksHash is null” marks it held.
**Layer of the implied fix:** L2
**Anchor:** “neither registered hash moves, with no `settingsHash` or `hooksHash` key anywhere in the record (DF-P4)”

### Follow-up
**Verdict:** no finding
**Failure:** No concrete scenario identified; each follow-up identifies a bounded future action or citation prohibition.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates the deterministic evaluator pass/fail gate: `architecture-consistency` is a graded rubric outcome, while `evaluator.sh` is the correctness gate. The section most likely to split reviewers is `Decision rule`: an exact one-point difference can yield IMPROVED or REJECT under rows 2/3, or NOT DETECTABLE under row 4—a full verdict-class divergence. The artifact needed to state whether “within 1 point” includes exactly 1, define whether policy gate and repair limit are one control or two, report the registered `inputTokens` and `outputTokens` fields, and reconcile DF-P4 with the established existence of `hooksHash`.
**Layer of the implied fix:** L3
**Anchor:** “Rows are checked **in order** and the first that matches is the verdict.”


---

## Run 2 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** The section identifies exactly two measured L2 controls as “B7's policy gate” and “B4/B5's named-agent boundary,” but Prediction 2 later calls the relevant controls “the policy gate and repair limit.” A reviewer counting the named-agent boundary gets 0 of 2; one counting policy gate and repair limit also gets 0 of 2, but they audit different evidence and can disagree about whether the boundary was part of the registered claim.
**Layer of the implied fix:** L3
**Anchor:** The two pieces that this track has ever *measured* as Layer 2 — B7's policy gate (17 of 17 executions) and B4/B5's named-agent boundary

### Predictions
**Verdict:** finding
**Failure:** Prediction 2 changes the identity of the two controls mid-paragraph: its opening count inherits policy gate plus named-agent boundary from the hypothesis, while its mechanism first names policy gate plus repair limit and then discusses the named-agent boundary. Given a port where the policy gate and boundary are lost but the repair limit survives, one reviewer scores 0 of 2 and another scores 1 of 2.
**Layer of the implied fix:** L3
**Anchor:** Mechanism: the policy gate and repair limit are wired by `.claude/settings.json` ...; the named-agent boundary needs `--agent`

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The mechanism row says the port contains `AGENTS.md` plus seven `.ai/**` files, which totals eight files, while the content-hash row calls the digest one “of all nine files” and lists nine files. A reviewer reproducing the digest from the stated 1+7 inventory hashes eight files; a reviewer following the enumerated list hashes nine and obtains the registered value.
**Layer of the implied fix:** L2
**Anchor:** `AGENTS.md` (the v1.2 `CLAUDE.md` body verbatim) + `.ai/**` (7 files, byte-identical)

### Census result — predictions 1 and 2, answered 2026-09-27 with no run and no money
**Verdict:** finding
**Failure:** The census initially concludes that the policy-gate loss is L3, but the additive correction establishes that `hooksHash` exists, and the later DF1 section says the same loss is now L2. A reviewer extracting the experiment's final layer from the preserved census text records L3; a reviewer applying the later evidence records L2.
**Layer of the implied fix:** L3
**Anchor:** So that control's absence is provable only by reading the runner and by `hooksHash` being null on every run ever recorded — **L3**, and it is labelled L3 here and in the workbook.

### Controlled variables
**Verdict:** finding
**Failure:** The model is said to be “forwarded and enforced” by runner lines, but no per-run model read-back is required here. If one run record reports a fallback model while the command used `--model gpt-5.6-sol`, one reviewer treats the command-line enforcement as sufficient and retains the run; another treats the model as moved and rejects comparability.
**Layer of the implied fix:** L2
**Anchor:** model — **`gpt-5.6-sol`**, exact id, forwarded and enforced by `run-agent.sh:305-312`

### Isolation, resolved at n = 3 before the arm opened — 2026-09-27
**Verdict:** finding
**Failure:** The claim that an intermittent leak “cannot manufacture” a within-runtime difference does not follow from both arms using the same path. If leakage occurs on runs 1–5 and the driver schedules all treated runs first, treated is contaminated 5/5 and control 0/5 despite identical configuration, producing a spurious arm difference.
**Layer of the implied fix:** L2
**Anchor:** an intermittent leak would fall on treated and control alike and cannot manufacture a within-runtime difference

### Runs
**Verdict:** finding
**Failure:** The ceiling is stated as 20 runs across E-024 and E-025, but this artifact does not specify how that shared budget is allocated or which experiment stops first. If E-025 consumes 14 runs before E-024 starts, one operator may stop E-024 after six total runs while another may still run its registered five-per-arm design.
**Layer of the implied fix:** L3
**Anchor:** Total budget: **20 codex runs across E-024 and E-025, 4 h of batch wall-clock**.

### Preflight result — §4 step 5, 2026-09-27, PASSED 4 of 4
**Verdict:** finding
**Failure:** The section says all five customization hashes were null on controls after the correction established that the API block has seven fields. If a control has `hooksHash` non-null but the five runner-printed hashes null, one reviewer passes the assertion; another applying the later seven-field schema fails it.
**Layer of the implied fix:** L2
**Anchor:** all five `customization.*Hash` `null`

### Minimum detectable effect
**Verdict:** finding
**Failure:** The rule says any result “inside an MDE” becomes NOT DETECTABLE, but the primary rubric MDE is explicitly undefined. For a one-point median difference, one reviewer treats undefined as no threshold and applies the decision rule's IMPROVED/REJECT row; another treats the result as not demonstrable and reports NOT DETECTABLE.
**Layer of the implied fix:** L3
**Anchor:** A result that lands inside an MDE is recorded as NOT DETECTABLE at this `n`, never as refuted.

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** finding
**Failure:** The registered exclusion says a control run with any non-null hash is void, but Decision row 0a only produces a VOID verdict for at least two treated delivery failures and supplies no handling for contaminated controls. With one control run carrying a non-null `hooksHash`, one reviewer removes that run and proceeds at n=4; another declares the batch void or reruns it.
**Layer of the implied fix:** L2
**Anchor:** **row 0a, void before scoring:** a treated run whose `instructionsHash` *or* `knowledgeHash` is `null`, or a control run with any hash non-null.

### Decision rule
**Verdict:** finding
**Failure:** Rows 2/3 trigger at a median difference of at least one point, while row 4 triggers when medians are “within 1 point.” At an exact +1 treated difference, both rows 2 and 4 are true; ordering yields IMPROVED, while a reviewer using the ordinary inclusive meaning of “within one” can report NOT DETECTABLE.
**Layer of the implied fix:** L3
**Anchor:** **4** | `H ≥ 1` and the medians are within 1 point | **NOT DETECTABLE at this `n`**

### Observed telemetry
**Verdict:** finding
**Failure:** Prediction 5 names `inputTokens` and `outputTokens`, but the observed account replaces them with `toolCalls`, `permissionDenials`, and `retries` and still says prediction 5's subject was measured. If `inputTokens` is non-null on one run while the listed five fields remain null, one reviewer marks Prediction 5 refuted and another marks it held because the reported audit never checks that field.
**Layer of the implied fix:** L2
**Anchor:** **`estimatedCost`, `modelCalls`, `toolCalls`, `permissionDenials` and `retries` are `null` on 20 of 20 runs of this batch.**

### Results
**Verdict:** finding
**Failure:** The section reports an “exact” two-sided Mann–Whitney p-value of 1.0000 for two samples consisting entirely of tied values, without defining the exact-test treatment of ties. One implementation refuses exact inference with ties or switches to an asymptotic method; another returns 1.0, so two competent reviewers cannot reproduce the stated method from the artifact.
**Layer of the implied fix:** L3
**Anchor:** Mann–Whitney U = 12.5, **exact** two-sided `p = 1.0000`

### Which predictions held
**Verdict:** finding
**Failure:** Prediction 5 originally requires `inputTokens` and `outputTokens` to be null, but the held table reports only `estimatedCost`, `modelCalls`, and `toolCalls`. If either token component is populated on any run, the registered prediction is false even though the reported subset remains true.
**Layer of the implied fix:** L2
**Anchor:** `estimatedCost`, `modelCalls`, `toolCalls` `null` on 20 of 20

### Failure analysis
**Verdict:** finding
**Failure:** The proposed pre-batch census is one control run, but a single score of 2 cannot establish that the control distribution is at ceiling. If that pilot scores 2 while the next four controls score 0, one reviewer abandons the outcome as ceiling-bound; another keeps it because the pilot provides no variance estimate.
**Layer of the implied fix:** L3
**Anchor:** One codex control run scored on the registered rubric ... would have shown `architecture-consistency = 2` and made the choice of primary outcome a decision rather than an accident.

### Sanity checks
**Verdict:** finding
**Failure:** The isolation item says the question “did resolve” and then immediately describes a prior leak and wedge, whereas the isolation section classifies intermittency as an unresolved shared variable. A reviewer deciding whether isolation passed can mark it resolved from this checklist; another must mark it unresolved from the earlier registered interpretation.
**Layer of the implied fix:** L3
**Anchor:** The isolation question that opened §4 step 4 *did* resolve

### Decision
**Verdict:** finding
**Failure:** The choice of claude as primary and codex as fallback is said to be answered by a codex-only batch that explicitly forbids cross-runtime verdicts. If claude loses the same observability fields and costs 50% more, the stated evidence still selects claude; a reviewer honoring the no-cross-runtime rule cannot make that selection from this experiment.
**Layer of the implied fix:** L3
**Anchor:** **Primary runtime: claude. Fallback: codex** — the gate's *"pick primary and fallback"* clause, answered from this batch

### Deliberate failure — DF1, registered 2026-09-27 at §4 step 9, before the run
**Verdict:** finding
**Failure:** DF-P4 predicts no `hooksHash` key anywhere in the record, but the earlier additive correction says `hooksHash` exists and is null, and the result itself reports `hooksHash null`. One reviewer must mark DF-P4 refuted because key absence was predicted; the artifact marks all four predictions held by treating null as equivalent to absence.
**Layer of the implied fix:** L3
**Anchor:** neither registered hash moves, with no `settingsHash` or `hooksHash` key anywhere in the record (DF-P4)

### Follow-up
**Verdict:** finding
**Failure:** The proposed census says the primary outcome is chosen after scoring one control run, but it gives no rule for preventing outcome selection from being optimized to that observed sheet. Given a sheet with architecture-consistency 2 and maintainability 0, one reviewer selects maintainability for headroom; another treats any post-score selection as outcome registration after data.
**Layer of the implied fix:** L3
**Anchor:** Register a control-arm rubric census before any future batch — one control run scored on the registered rubric before the primary outcome is chosen.

### Cross-cutting
**Verdict:** finding
**Failure:** Duplicate gate: `Deterministic evaluation` makes evaluator exit status the pass/fail correctness gate, while `Results` also gates scoring through `check-run-gate.sh`; no scoring category itself clearly duplicates that correctness gate. Greatest expected divergence: `Decision rule`, by a full verdict at an exact one-point median difference—IMPROVED/REJECT versus NOT DETECTABLE. Missing statement: the artifact needed one authoritative inventory of the two “measured L2 controls,” one authoritative seven-field customization schema, and explicit handling of contaminated control runs and exact one-point differences.
**Layer of the implied fix:** L3
**Anchor:** Rows are checked **in order** and the first that matches is the verdict.

