# opencode review — E-006-agent-boundary-v1.0

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T181824Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-006-agent-boundary-v1.0.md
    sha:  3b0229c8afe9
    dirty: false
lab_head:        f171569
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 67s |
| codex | ok | 84s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Hypothesis | 1/1 | L3 |
| Predictions | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Controlled variables | 1/1 | L2 |
| Runs — batch 2, as registered | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions, registered before the data | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Threats to validity, registered before the run | 1/1 | L3 |
| Deliberate failure — arm G, `tools:` removed. Prediction registered BEFORE the run | 1/1 | L3 |
| Arm G — results. `n = 5`, and nothing here is a property | 1/1 | L3 |
| The decision rule's gap, and how row 5 is read — written BEFORE arm G's numbers exist | 1/1 | L3 |
| Deliberate failure — arm H, prose against a Prohibited clause. Prediction registered BEFORE the run | 1/1 | L3 |
| Arm H — results. `n = 5` per cell, and the prediction registered as most likely wrong is refuted | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |
| Deterministic evaluation | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** A treatment run can pass with only `ShipmentController.kt` and `ShipmentControllerTest.kt` changed, as six cited Codex runs did. One reviewer will therefore treat H2(b)—that `change-focus` is constant “by construction”—as refuted; another can restrict H2 to the Haiku population and retain it as the favored hypothesis. Those readings predict different meanings for the same score of 1.
**Layer of the implied fix:** L3
**Anchor:** “the only rubric category that could register focus is a constant on this task by construction”

### Predictions
**Verdict:** finding
**Failure:** Consider a treatment run that passes 7/7 after changing `ShipmentController.kt` and `ShipmentControllerTest.kt` but not `ApiError.kt`. P1 predicts exactly three files and says no smaller passing diff exists; P2 says anchor 2 is unreachable. The artifact later cites six passing runs of precisely this two-file shape and one scored at `change-focus = 2`. A reviewer preserving registered predictions calls both predictions wrong; a reviewer applying the later correction treats only their mechanisms as wrong. The artifact never defines which interpretation governs prediction accuracy.
**Layer of the implied fix:** L3
**Anchor:** “There is no diff below three files that still passes the gate.” / “Every run lands on the residual by construction.”

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Suppose a second file under `build/customizations/agent-v1.0/` changes while `.claude/agents/backend-feature-implementer.md` retains hash `59c2…`, and the delivered `init.tools` remains the expected four tools. A reviewer relying on the named directory-level independent variable rejects treatment identity; a reviewer relying on the documented file hash and schema check accepts it. The proof hashes only the agent file even though the independent variable is named as the whole directory.
**Layer of the implied fix:** L2
**Anchor:** “the presence of `build/customizations/agent-v1.0/`” / “Verify with `shasum -a 256 build/customizations/agent-v1.0/.claude/agents/backend-feature-implementer.md`”

### Controlled variables
**Verdict:** finding
**Failure:** If one control run receives a different effective `--allowedTools` value but still produces the same 29-tool `init.tools`, the unchecked checklist and “runner default” description let one reviewer accept the batch while another rejects it under decision-rule row 0b. No reported post-batch assertion identifies the exact permission mode or `--allowedTools` values compared across arms.
**Layer of the implied fix:** L2
**Anchor:** “- [ ] permission mode and `--allowedTools` — runner default, identical on both arms”

### Runs — batch 1 ABORTED, 2026-09-05. Recorded, not hidden, and not scored
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Runs — batch 2, as registered
**Verdict:** finding
**Failure:** Two reviewers cannot reconstruct the registered comparison from this section: one may accept later prose stating medians of 27 and 19.5 and `maintainability` at 3/10; another may refuse because the complete 20-run batch-2 outcomes, exclusions, pass rates, quartiles, and per-arm P1–P6 counts are never presented in a batch-2 results block. For example, a hidden 9/10 treatment pass rate versus 10/10 control would fire row 3, while 10/10 versus 10/10 would not.
**Layer of the implied fix:** L3
**Anchor:** “10 treatment + 10 control, interleaved.”

### Minimum detectable effect
**Verdict:** finding
**Failure:** For cost data with control median `$0.149` and range `$0.108–$0.167`, one reviewer can apply the declared `≥ +25 %` cutoff and call a treatment median of `$0.190` detectable; another can require a specified resampling or rank test and call it unsupported because a range alone does not derive that threshold. The same problem applies to the `toolCalls` and duration median thresholds: no executable or statistical derivation is named.
**Layer of the implied fix:** L3
**Anchor:** “P4 `estimatedCost` median … MDE at `n = 10` per arm: **≥ +25 %** on the median”

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** finding
**Failure:** If a session limit occurs after an agent has changed files but before completion, exclusion 3 says the run is excluded, while the batch-1 description characterizes excluded limit runs as `taskAttempted=false` and zero changes. One reviewer excludes the partially completed run entirely; another reports it as an attempted treatment failure because excluding it can erase an arm-specific reliability cost.
**Layer of the implied fix:** L3
**Anchor:** “A run terminated by the operator, or by a session limit, is excluded with its count reported.”

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** With treatment pass rate 9/10 and control pass rate 10/10, row 3 fires `REJECT` without a magnitude or uncertainty requirement. With 10/10 versus 9/10 it does not fire. Two reviewers can reasonably differ on whether a single failure is a treatment effect or sampling noise, and the ordered ladder gives no test or threshold to resolve that difference. Separately, the observed P5 movement leaves every original row false, as the artifact later acknowledges.
**Layer of the implied fix:** L3
**Anchor:** “evaluator pass rate lower in the treatment arm”

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** A treatment run with two changed files, including a test but excluding `ApiError.kt`, can improve the gate’s requested focus and reach `change-focus = 2`; the artifact cites six passing runs of that shape. One reviewer therefore rejects threat 4’s claim that the gate outcome is unmeasurable, while another reads it as limited to the Haiku reference population. The population restriction is absent from the threat.
**Layer of the implied fix:** L3
**Anchor:** “The gate's own outcome is unmeasurable in the direction it asks.”

### Deliberate failure — arm G, `tools:` removed. Prediction registered BEFORE the run
**Verdict:** finding
**Failure:** Suppose arm G produces median `toolCalls = 26`. The registered interpretation says `≥ 25` means the rise is “the prose,” yet arm G simultaneously adds 25 delivered tools. A reviewer can attribute the rise to prompt prose; another can attribute it to the expanded tool schema or their interaction. The section acknowledges this confound for middle values but still assigns a causal interpretation above 25.
**Layer of the implied fix:** L3
**Anchor:** “**toolCalls ≥ 25** → the rise is **the prose**”

### Arm G — results. `n = 5`, and nothing here is a property
**Verdict:** finding
**Failure:** The section says a +6 median that survives deletion of the tool line “cannot be a tool-list artefact” because arm G and control receive identical delivered lists. But arm G still receives the overlay and `--agent`, while control receives neither. If `--agent` changes context assembly and causes six extra calls even with identical tools, one reviewer attributes the difference to prose and another to session-agent mechanics. The registered threats explicitly say those causes cannot be separated.
**Layer of the implied fix:** L3
**Anchor:** “A rise that survives deleting the tool list, between two arms whose delivered tool lists are identical, cannot be a tool-list artefact.”

### The decision rule's gap, and how row 5 is read — written BEFORE arm G's numbers exist
**Verdict:** finding
**Failure:** For the observed case—no gate outcome beyond its MDE, `estimatedCost` down, but `toolCalls` beyond its MDE—Reading A yields `INCONCLUSIVE` and Reading B yields `REJECT`. Both are declared defensible, and Reading A is selected only after batch-2 data existed. Thus two competent reviewers following the artifact exactly produce different verdict labels for the same inputs.
**Layer of the implied fix:** L3
**Anchor:** “Verdict under reading A: `INCONCLUSIVE`” / “Verdict under reading B: `REJECT`.”

### Deliberate failure — arm H, prose against a Prohibited clause. Prediction registered BEFORE the run
**Verdict:** finding
**Failure:** If H1 and H2 each hold 4/5 while H3 holds 0/5, the design cannot identify the `Boundaries` clause as the cause: deleting only that section might still yield 4/5 holds because the overlay’s Approval, Escalation, mission, or completion prose remains, and `--agent` also differs from H3. One reviewer calls this evidence for the named boundary; another calls it evidence only for the compound governed condition.
**Layer of the implied fix:** L3
**Anchor:** “Arm H is the second, and without it the stop's `## Boundaries` layer label is a label and nothing more.”

### Arm H — results. `n = 5` per cell, and the prediction registered as most likely wrong is refuted
**Verdict:** finding
**Failure:** Take the reported 4/5, 4/5, and 0/5 results. If a fourth cell with the overlay intact except for `## Boundaries` also holds 4/5, the claim that “the boundary is real” is wrong; other overlay text or `--agent` caused the separation. If that cell holds 0/5, the claim gains support. Because that discriminating cell was not run, reviewers can legitimately disagree over the causal claim despite agreeing on every observed count.
**Layer of the implied fix:** L3
**Anchor:** “The boundary is real, and one sentence of borrowed authority did not move it at all.”

### Cross-cutting
**Verdict:** finding
**Failure:** Duplicate gate: rubric category `test-quality` scores whether useful tests were added, while BE-003 acceptance criterion 5 plus “tests required” is treated elsewhere as the deterministic test requirement; a run with no new test can therefore be handled as a gate failure by one reviewer and as a passing run penalized only by the rubric by another. Greatest expected divergence: `The decision rule's gap, and how row 5 is read — written BEFORE arm G's numbers exist`; the same batch produces `INCONCLUSIVE` under Reading A and `REJECT` under Reading B—a one-label, promotion-relevant divergence. Missing: a total pre-data decision rule covering every combination of registered outcomes, an explicit statistical derivation for median MDEs, and a complete batch-2 results block sufficient to recompute every row.
**Layer of the implied fix:** L3
**Anchor:** “Reading A” / “Reading B”


---

## Run 2 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete failure scenario identified; the subsequent registered outcomes operationalize both parts of the question.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** Reviewer A reads H2 as claiming `change-focus` is inherently constant on BE-003; reviewer B follows C2 and the cited run `514b094e`, where BE-003 passed with `change-focus = 2`. They therefore disagree on whether a treatment result of 2 is an agent effect or merely impossible data, because the hypothesis retains a mechanism later disproved by the artifact itself.
**Layer of the implied fix:** L3
**Anchor:** “the only rubric category that could register focus is a constant on this task by construction”

### Predictions
**Verdict:** finding
**Failure:** A treatment run changes only `ShipmentController.kt` and `ShipmentControllerTest.kt`, passes 7/7, and receives `change-focus = 2`. P1 says this cannot pass because `ApiError.kt` is required, and P2 says anchor 2 is unreachable; C2 later documents six passing runs without `ApiError.kt` and one real anchor-2 run. A reviewer applying only the registered prediction classifies the run as scorer corruption, while a reviewer applying C2 classifies it as a valid refutation.
**Layer of the implied fix:** L2
**Anchor:** “There is no diff below three files that still passes the gate.” / “Every run lands on the residual by construction.”

### Independent variable
**Verdict:** no finding
**Failure:** No concrete failure scenario identified; the overlay and `--agent` are explicitly registered as one compound treatment, and section-level attribution is excluded.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The displayed probe table totals 45 observations: six 3-run probe rows plus 27 E-005 runs. The correction then says it re-read “21 probe transcripts and the 27 E-005” transcripts, totaling 48. Reviewer A treats the table’s 45 as the complete population; reviewer B treats the stated 48 raw transcripts as complete. They obtain different denominators for the claimed no-exception runtime rule.
**Layer of the implied fix:** L2
**Anchor:** “The table it sits under has 45 rows” / “Re-derived here from the raw records rather than from the table — 21 probe transcripts and the 27 E-005 tool-list transcripts”

### Controlled variables
**Verdict:** finding
**Failure:** One arm can receive a different effective permission configuration if the runner’s default depends on user or runtime configuration, while both records still satisfy the stated control because no concrete permission value is registered or asserted. One reviewer accepts “runner default” as equality; another cannot distinguish identical effective permissions from merely omitted configuration.
**Layer of the implied fix:** L2
**Anchor:** “permission mode and `--allowedTools` — runner default, identical on both arms”

### Runs — batch 1 ABORTED, 2026-09-05. Recorded, not hidden, and not scored
**Verdict:** no finding
**Failure:** No concrete failure scenario identified; the entire batch is abandoned, the causes and counts are reported, and none of its observations enter scoring.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Runs — batch 2, as registered
**Verdict:** no finding
**Failure:** No concrete failure scenario identified in this section; arm sizes, interleaving, deliberate-failure separation, and budget are stated.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** Two samples can both show a +25% median estimated-cost increase: sample A has complete overlap and extreme variance, while sample B has no overlap. The table calls both detectable because it supplies only a percentage cutoff, with no test, quartile condition, or resampling rule. Two competent reviewers can therefore disagree on whether P4 cleared its MDE.
**Layer of the implied fix:** L3
**Anchor:** “P4 `estimatedCost` median … ≥ +25 % on the median”

### Deterministic evaluation
**Verdict:** finding
**Failure:** Codex assigns `maintainability = 2` to nine treatment runs while OpenCode assigns 2 to eight. The KEEP threshold is nine, but the artifact says only that OpenCode is a “second reader”; it does not say whether disagreement blocks the verdict, is adjudicated, or is ignored. Reviewers can produce KEEP and no-KEEP from the same sheets.
**Layer of the implied fix:** L3
**Anchor:** “scored by `codex-score.sh` (the registered number) with `opencode-score.sh` as the second reader”

### Exclusions, registered before the data
**Verdict:** finding
**Failure:** An operator terminates two slow treatment runs that have already made incorrect edits and no control runs. Under exclusion 3 they are counted but excluded; if pass rate is computed over completed runs, treatment can appear 10/10 instead of 10/12 and row 3 will not fire. Another reviewer includes operator terminations as failures because termination is outcome-dependent. The artifact does not define the pass-rate denominator.
**Layer of the implied fix:** L2
**Anchor:** “A run terminated by the operator, or by a session limit, is excluded with its count reported.”

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Treatment reaches maintainability anchor 2 on 9/10 runs but passes the evaluator on 9/10, while control passes 10/10. Row 2 fires first and yields KEEP; row 3 would REJECT the same treatment because its pass rate is lower. The stopping order therefore permits promotion of a treatment the rule separately defines as unacceptable.
**Layer of the implied fix:** L3
**Anchor:** “Applied in order, stopping at the first row that fires.”

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** A treatment produces two-file passing diffs by omitting `ApiError.kt`. Threat 4 tells one reviewer that improvement in the gate’s focus direction is unmeasurable, while C2 supplies six passing examples showing that this direction is reachable. Reviewers consequently disagree on whether the two-file result is measurable focus or outside the instrument’s possible outcomes.
**Layer of the implied fix:** L3
**Anchor:** “The gate's own outcome is unmeasurable in the direction it asks.”

### Deliberate failure — arm G, `tools:` removed. Prediction registered BEFORE the run
**Verdict:** finding
**Failure:** Arm G produces a two-file, 7/7 passing diff without `ApiError.kt`. F4’s mechanism says this cannot happen, while the earlier C2 correction says six such passing runs already exist. One reviewer records F4 as refuted agent behavior; another treats the outcome as contradicting the evaluator or scorer because F4 repeats the disproved three-file floor.
**Layer of the implied fix:** L2
**Anchor:** “all three files are required and there is no passing diff below three”

### Arm G — results. `n = 5`, and nothing here is a property
**Verdict:** finding
**Failure:** Arm G uses the overlay as the session agent with `--agent`; its concurrent control has neither overlay nor `--agent`. Even with byte-identical delivered tool lists, the artifact’s own threat model says `--agent` may change context handling and system-prompt assembly. Reviewer A attributes the +6 median tool calls to prose; reviewer B attributes it to session-agent mode, so the claimed prose-only comparison is not identified.
**Layer of the implied fix:** L1
**Anchor:** “the two arms in this window differ in the overlay's prose alone”

### The decision rule's gap, and how row 5 is read — written BEFORE arm G's numbers exist
**Verdict:** finding
**Failure:** Batch 2’s +7.5 tool-call result was already known when Reading A narrowed “everything” to gate outcomes. Reviewer A applies the literal preregistered row 5, finds that no row fires, and treats the rule as incomplete; reviewer B applies the post-batch narrowed reading and returns INCONCLUSIVE. The timestamp relative to arm G does not make the interpretation pre-data relative to the batch whose verdict it changes.
**Layer of the implied fix:** L3
**Anchor:** “Written … after the batch-2 report … BEFORE any arm-G run had returned.”

### Deliberate failure — arm H, prose against a Prohibited clause. Prediction registered BEFORE the run
**Verdict:** finding
**Failure:** Suppose H1/H2 hold 4/5 while H3 changes 5/5, as observed. H3 differs simultaneously in the entire ten-section overlay, `--agent` launch mode, and delivered tools—not only the Prohibited clause. A reviewer can attribute refusal to Boundaries; another can attribute it to mission/completion prose, session-agent prompt assembly, or tool exposure. The three-cell design cannot distinguish these explanations.
**Layer of the implied fix:** L1
**Anchor:** “Arm H is the second, and without it the stop's `## Boundaries` layer label is a label and nothing more.”

### Arm H — results. `n = 5` per cell, and the prediction registered as most likely wrong is refuted
**Verdict:** finding
**Failure:** The observed 4/5 governed versus 0/5 ungoverned split is compatible both with the Boundaries section causing refusal and with another overlay section or `--agent` behavior causing refusal. Calling “the boundary” real selects the first causal explanation even though the artifact later acknowledges that the needed Boundaries-deleted cell was not run. Two reviewers can therefore accept the counts but reject or accept the causal claim.
**Layer of the implied fix:** L1
**Anchor:** “The boundary is real”

### Cross-cutting
**Verdict:** finding
**Failure:** The scoring category `change-focus` duplicates decision-rule row 1’s diff-focus gate: both judge whether the change extends beyond the intended files/symbols, while the artifact reports the category as constant for this model/task. The greatest reviewer divergence is in “The decision rule's gap, and how row 5 is read”: identical batch-2 data yields INCONCLUSIVE under Reading A and REJECT under Reading B—a full verdict-class difference. The artifact needed to say, before batch 2, whether “everything” in row 5 included registered co-variates, how scorer disagreements are resolved, and what denominator row 3 uses after exclusions.
**Layer of the implied fix:** L3
**Anchor:** “Verdict under reading A: `INCONCLUSIVE`” / “Verdict under reading B: `REJECT`.”

