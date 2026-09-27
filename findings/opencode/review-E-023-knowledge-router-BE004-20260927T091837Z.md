# opencode review — E-023-knowledge-router-BE004

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
reviewed_utc:    20260927T091837Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-023-knowledge-router-BE004.md
    sha:  3026acf8be80
    dirty: false
lab_head:        20e7c9e
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
| codex | ok | 62s |
| codex | ok | 67s |

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
| Independent variable | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Controlled variables | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Decision rule | 1/1 | L2 |
| Observed telemetry | 1/1 | L3 |
| Results | 1/1 | L2 |
| Which predictions held | 1/1 | L3 |
| Failure analysis | 1/1 | L3 |
| Sanity checks | 1/1 | L3 |
| Decision | 1/1 | L3 |
| Follow-up | 1/1 | L3 |
| Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation | 1/1 | L2 |
| Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction | 1/1 | L3 |
| Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway | 1/1 | L3 |
| Amendment 4 — pointer: the batch deaths, the throughput decision and `--resume` | 1/1 | L3 |
| Hand re-read — written 2026-09-27, BEFORE any BE-004 scoring sheet for this batch exists | 1/1 | L3 |
| Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-004 the difference is zero, and the zero is the result | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** A treated run containing a bare `if` with fall-through can be scored 0 by a consequence-based reviewer and 1 by a syntax-based reviewer, as the later hand re-read explicitly demonstrates. In that case one observed movement from 0 to 1 is not “unambiguous” evidence that knowledge moved the registered anchor-2 outcome.
**Layer of the implied fix:** L3
**Anchor:** **any movement is unambiguous**

### Predictions
**Verdict:** finding
**Failure:** Prediction 3 registers only “non-empty on ≥ 7 of 10,” but Amendment 1 later says its registered thresholds also include “≥ 5 of 10 with the index lookup first.” With 7 non-empty logs but only 4 index-first logs, one reviewer would mark prediction 3 held from this section while another applying Amendment 1 would mark it partly refuted.
**Layer of the implied fix:** L3
**Anchor:** `.agent/knowledge-log.jsonl` is non-empty on **≥ 7 of 10** treated runs.

### Independent variable
**Verdict:** finding
**Failure:** After registration, Amendment 2 adds a third runner allowlist entry to both arms. A control run can now execute `.ai/knowledge/router.sh` if that path is created during the run, whereas an earlier control could not. One reviewer can therefore call the customization overlay the only independent variable because the flag is symmetric; another can treat the runner change as a second intervention relative to the historical floor used by P2.
**Layer of the implied fix:** L3
**Anchor:** **Exactly one thing: the customization overlay**

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The stated preflight requires a non-empty treated log and says the batch does not start if that fails. The second preflight had an absent treated log and exit 2, yet Amendment 3 authorizes the batch. A reviewer enforcing this section stops the experiment; a reviewer applying the amendment runs it.
**Layer of the implied fix:** L2
**Anchor:** **If the preflight's log condition fails, the batch does not start.**

### Controlled variables
**Verdict:** finding
**Failure:** Two operators reconstructing the run from this artifact can choose different permission configurations because “as B8's BE-004 batch” does not enumerate them, while Amendment 2 later establishes that the exact allowlist changes whether the router is denied. One produces `router_denied=yes`; the other produces `router_denied=no`.
**Layer of the implied fix:** L3
**Anchor:** permissions / permission mode — as B8's BE-004 batch

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** If scored populations are `n_t=7`, `n_c=10`, `M=5`, and `C=0`, the text asserts that the count threshold “holds down to `n = 7` per arm,” but it supplies calculations only for equal arm sizes. One reviewer may apply the registered count of 5 to this unequal case; another may require a separately established MDE for 5/7 versus 0/10.
**Layer of the implied fix:** L3
**Anchor:** **prediction 1's threshold is stated as a count, 5, and holds down to `n = 7` per arm.**

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
**Failure:** For `n_t=n_c=10`, `H=3`, `M=5`, and `C=1`, Fisher's exact test can be one-sided or two-sided and yield different p-values. The rule names only `Fisher(M,C) ≤ 0.05`; one implementation can select row 2 while another selects row 3.
**Layer of the implied fix:** L2
**Anchor:** `H ≥ 3` and `M ≥ 5` and `Fisher(M,C) ≤ 0.05`

### Observed telemetry
**Verdict:** finding
**Failure:** The section says the running evaluator-success total is `9 + 20 + 20 + 14 + 20` but does not map those counts to experiments or define whether preflights are included. A reviewer including the four successful preflight runs obtains a different total from one counting registered batches only.
**Layer of the implied fix:** L3
**Anchor:** 10 of 10 in both arms, which takes the running total to 9 + 20 + 20 + 14 + 20

### Results
**Verdict:** finding
**Failure:** With treated `test-quality` values of seven 1s and three 2s, the conventional even-sample median is 1; with five 1s and five 2s, it is 1.5. But the artifact never registers the median convention. An implementation using a lower median reports control 1 and no gap, while the reported implementation gives 1.5 and a 0.5 gap.
**Layer of the implied fix:** L2
**Anchor:** `test-quality` | **1** | **1.5** | 1×7, 2×3 | 1×5, 2×5

### Which predictions held
**Verdict:** finding
**Failure:** A run may obey or be influenced by the added `CLAUDE.md` instruction without invoking the router. For example, it may directly write an exhaustive `when` after reading the instruction but never open the corpus. This section classifies such a run as “a control with a different hash,” so a real instruction effect would be mislabeled as instrument noise.
**Layer of the implied fix:** L3
**Anchor:** An arm that never used its treatment is a control with a different hash

### Failure analysis
**Verdict:** finding
**Failure:** The claimed ticket-length mechanism is inferred from 1/10 uptake on BE-004 versus 2/10 on BE-003. Under repeated batches drawn from the same underlying uptake rate, those exact counts readily occur by chance; one reviewer can call the mechanism confirmed while another can call the one-run difference sampling noise.
**Layer of the implied fix:** L3
**Anchor:** **Why lower than BE-003's 2 of 10, and it was predicted.**

### Sanity checks
**Verdict:** finding
**Failure:** A treated run with `H=0` could still be affected by the overlay's `CLAUDE.md` text even without corpus contact. If that text distracts the model and lowers `test-quality`, one reviewer following this section discards the harm as noise, while another attributes it to the actual treatment package.
**Layer of the implied fix:** L3
**Anchor:** at `H = 1` the treated arm is not a treated arm, so they measure this instrument's noise, not a harm.

### Decision
**Verdict:** finding
**Failure:** The disposition says the corpus stays in the repository, while decision-rule row 1 says “corpus unchanged, pending” and the verdict says the treatment was not tested. One operator may leave the corpus available to later builds; another may interpret “not promoted” as excluding it from the next overlay. Those produce different subsequent treatments.
**Layer of the implied fix:** L3
**Anchor:** **Disposition (§4 step 10): not promoted; the corpus stays in the repository.**

### Follow-up
**Verdict:** finding
**Failure:** A future BE-004 experiment observing a 0.5 `test-quality` median difference could exceed this alleged “noise floor” only by being larger, while another reviewer could require a sampling distribution or confidence interval rather than a single realized difference. The two reviewers would admit different future effects.
**Layer of the implied fix:** L3
**Anchor:** Any later step claiming an effect of that size on this task has to clear this bar first.

### Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation
**Verdict:** finding
**Failure:** The default log filename is derived only from `basename "$ROOT"`. Two concurrent executions reusing the same worktree basename write to the same file, so a router call from run A can make run B's log non-empty and increment B's `H`. The prose says the run id is in the name, but no constraint here makes basename uniqueness structural or validates it.
**Layer of the implied fix:** L2
**Anchor:** with the run id in the file's own name — the worktree basename is `observatory-run-<runId>`

### Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction
**Verdict:** finding
**Failure:** A control run can create `.ai/knowledge/router.sh` or inherit such a path through an unexpected benchmark change; the unconditional allow rule would then permit behavior previously denied. In that input, the claim that the added permission “cannot change a control run's behaviour” is false.
**Layer of the implied fix:** L3
**Anchor:** An allow rule for a path that does not exist cannot change a control run's behaviour.

### Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway
**Verdict:** finding
**Failure:** The amendment overrides the explicit preflight gate after observing two treated non-attempts. A reviewer treating the gate as registered enforcement must stop; a reviewer accepting the new interpretation proceeds and can obtain the reported VOID. The artifact supplies no pre-registered precedence rule for resolving that contradiction.
**Layer of the implied fix:** L3
**Anchor:** **The resolution taken, with its reasons:**

### Amendment 4 — pointer: the batch deaths, the throughput decision and `--resume`
**Verdict:** finding
**Failure:** The operational rules governing orphan replacement and `--resume` exist only in E-022, which is outside the declared complete evidence set. If a BE-004 run has an orphaned record, one reviewer can replace it and another can count it or exclude it, producing different `n_t`, cost, and possibly row-0 outcomes.
**Layer of the implied fix:** L3
**Anchor:** the orphan-replacement rule as applied to `413bcf23-65f4-49d3-a789-c29b3dcf1b48`, and the `--resume` instrument change with its four new fixtures are all recorded **once**, in [`E-022` Amendment 4]

### Hand re-read — written 2026-09-27, BEFORE any BE-004 scoring sheet for this batch exists
**Verdict:** finding
**Failure:** The concrete diff contains a bare `if` with no `else`. A literal anchor reviewer assigns residual 1 because anchor 0 names an `if`/`else if`/`else` chain; a consequence-based reviewer assigns 0 because a new status falls through silently. The artifact itself acknowledges both readings, so the registered outcome is not reproducible across competent scorers.
**Layer of the implied fix:** L3
**Anchor:** A scorer reading only the first sentence of anchor 0 could defensibly return 1 here

### Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-004 the difference is zero, and the zero is the result
**Verdict:** finding
**Failure:** A treated run can read a corpus file through an unrecognized mechanism—for example, a subprocess whose captured log omits the command—and be classified `no-contact`. Because the census's observable event sources and blind spots are not specified here, one reviewer can accept 1/10 corpus contact while another cannot reproduce the classification.
**Layer of the implied fix:** L3
**Anchor:** the other nine | 0 | 0 | 0 | `no-contact`

### Cross-cutting
**Verdict:** finding
**Failure:** The `maintainability` anchor-2 count is both a scored category and the effective pass/fail outcome in decision-rule rows 2–5; router uptake `H` is also both Prediction 3's scored outcome and the gate that selects VOID versus substantive verdicts. The Hand re-read would produce the greatest reviewer divergence: the supplied bare-`if` diff can score 0 or 1, a full anchor point. The artifact needed to state the Fisher alternative, median convention, precedence of amendments over registered gates, and a reproducible definition of corpus-contact evidence.
**Layer of the implied fix:** L3
**Anchor:** `Fisher(M,C)`; `test-quality` **1** vs **1.5**; `A scorer reading only the first sentence of anchor 0 could defensibly return 1 here`


---

## Run 2 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** A treated run containing a bare `if` can be scored 0 by a reviewer applying the consequence clause or 1 by a reviewer applying the literal anchor wording, as the later hand re-read acknowledges. That makes a one-count movement potentially a scoring disagreement, contradicting the claim that any movement is unambiguous.
**Layer of the implied fix:** L3
**Anchor:** “any movement is unambiguous”

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
**Verdict:** finding
**Failure:** The registered gate says a missing treated log prevents the batch. The second preflight produced an absent treated log, yet Amendment 3 authorized the batch. One reviewer will reject the batch as violating its preflight gate; another will accept the later deliverability probe as satisfying the gate.
**Layer of the implied fix:** L2
**Anchor:** “If the preflight's log condition fails, the batch does not start.”

### Controlled variables
**Verdict:** finding
**Failure:** A reviewer checking permissions against B8 will find a two-entry allowlist, while the executed experiment used a three-entry allowlist after obs#90. One reviewer can mark permissions controlled because both concurrent arms shared the change; another can mark the registered controlled variable violated because it was not “as B8.”
**Layer of the implied fix:** L3
**Anchor:** “permissions / permission mode — as B8's BE-004 batch”

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** The text says a control is plausibly 0 to about 1 anchor-2 successes because the only historical non-zero was an anchor-1 score. Anchor 1 is not an anchor-2 success, so it cannot support a control anchor-2 count of 1. A reviewer using the stated binary outcome gets 0 of 36; another following this interval statement allows 1 of 10.
**Layer of the implied fix:** L3
**Anchor:** “the control's plausible range is `0` to about `1` of 10, since the only non-zero in 36 runs was a 1 at anchor 1”

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
**Failure:** With `n_t=n_c=10`, `H=10`, `M=3`, and `C=10`, row 4 declares the treatment separated from the historical floor even though its concurrent control performs substantially better. A reviewer applying the row literally reports P2 held; a reviewer treating the concurrent control as necessary context will not accept that interpretation.
**Layer of the implied fix:** L1
**Anchor:** “`H ≥ 3` and `M` is 3 or 4”

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** finding
**Failure:** A later experiment with treated/control `test-quality` medians of 1.5/1.0 and high verified uptake could be dismissed because the gap equals the asserted 0.5 “noise floor.” This experiment does not estimate a noise-floor bound from repeated null comparisons: the arms include one actual corpus contact, and a single observed median gap has no uncertainty interval.
**Layer of the implied fix:** L3
**Anchor:** “this instrument's noise floor on BE-004 at `n = 10`, measured here by accident”

### Which predictions held
**Verdict:** finding
**Failure:** For the same future 0.5 median gap, one reviewer will treat the present observation as a minimum effect that must be exceeded; another will treat it as one random null-arm realization that supplies no such cutoff. The section turns a single realized gap into a decision threshold without registering a statistic or error rate.
**Layer of the implied fix:** L3
**Anchor:** “no later step can read a gap of this size on this task as an effect without first clearing this bar”

### Failure analysis
**Verdict:** finding
**Failure:** The observed uptake is 1/10 on BE-004 versus 2/10 on BE-003. Those counts are compatible with the same underlying uptake rate, and task was not randomized as the cause. One reviewer can accept ticket length as the causal explanation; another can attribute the one-run difference to sampling variation.
**Layer of the implied fix:** L3
**Anchor:** “The instruction is L3 on both tasks and it loses to a longer ticket.”

### Sanity checks
**Verdict:** finding
**Failure:** Run `5bc8b735` at `$0.3263` is declared inside the control spread on other batches, but no referenced spread or acceptance bound is included in this complete evidence set. One reviewer may retain it based on the assertion; another cannot reproduce the comparison and may flag it as an unexplained extreme.
**Layer of the implied fix:** L3
**Anchor:** “Both are inside the control arm's own spread on other batches”

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** finding
**Failure:** A subsequent study observing a 0.5 `test-quality` median difference could either incorporate 0.5 as an MDE input, as directed here, or refuse because this artifact never defines how a single null realization becomes an MDE. Those choices produce different sample sizes and possibly different verdicts.
**Layer of the implied fix:** L3
**Anchor:** “It belongs in the MDE inputs for every BE-004 step after this one.”

### Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation
**Verdict:** finding
**Failure:** After moving the log to `$TMPDIR`, the original preflight table and later Amendment 5 still define or describe `H` using `.agent/knowledge-log.jsonl`. An implementer following those literal paths records `H=0`; an implementer following the amendment reads the external file and records `H=1`, potentially changing the decision row.
**Layer of the implied fix:** L1
**Anchor:** “Nothing above is rewritten; this section is the whole change.”

### Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction
**Verdict:** finding
**Failure:** In a control run, the agent can create `.ai/knowledge/router.sh` and execute it because the runner grants `Bash(.ai/knowledge/router.sh:*)` unconditionally. The assertion that a nonexistent initial path cannot affect control behavior then fails: treated and control differ in initial files, but both receive a new executable-command capability.
**Layer of the implied fix:** L2
**Anchor:** “An allow rule for a path that does not exist cannot change a control run's behaviour.”

### Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway
**Verdict:** finding
**Failure:** The second preflight again exited 2 because the registered log condition failed. The amendment substitutes a one-call capability probe for the registered requirement that a treated preflight actually produce a log. A strict reviewer halts the experiment; a reviewer accepting the amendment runs it, exactly the divergence the section documents.
**Layer of the implied fix:** L2
**Anchor:** “`evidence/b09/preflight-20260926T131746Z/`, four runs, exit **2**”

### Amendment 4 — pointer: the batch deaths, the throughput decision and `--resume`
**Verdict:** finding
**Failure:** A reviewer limited to the declared complete evidence set cannot inspect the batch-death chronology, orphan-replacement rule, or four `--resume` fixtures because they are incorporated only by reference to E-022. One reviewer may accept the pointer; another cannot establish that replacement runs were selected without outcome-dependent discretion.
**Layer of the implied fix:** L3
**Anchor:** “are all recorded **once**, in [`E-022` Amendment 4]”

### Hand re-read — written 2026-09-27, BEFORE any BE-004 scoring sheet for this batch exists
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-004 the difference is zero, and the zero is the result
**Verdict:** finding
**Failure:** For BE-004 run 08, the router itself may read the summary as part of servicing the invocation. Without an operational distinction between a router-mediated read and an independent agent read, one reviewer can classify it `router+direct`; another can classify it router-only. The claimed zero gap between invocation and corpus-contact counts depends on that classification.
**Layer of the implied fix:** L2
**Anchor:** “BE-004 08 | 1 | 1 (summary) | **1** | `router+direct`”

### Cross-cutting
**Verdict:** finding
**Failure:** The uptake gate duplicates a scored prediction: Prediction 3 tests router use at `H ≥ 7`, while decision-rule row 1 makes `H ≤ 2` a pass/fail gate yielding VOID. The largest expected reviewer divergence is in “How the treatment is delivered — and proved”/Amendment 3: strict enforcement yields no admissible batch, while the artifact yields a completed batch and VOID verdict—a full experiment-level difference, not a one-point score difference. The artifact needed one authoritative, post-amendment definition of the log path and preflight pass condition, plus a specified method for turning an observed null-arm median gap into a future MDE or noise threshold.
**Layer of the implied fix:** L2
**Anchor:** “If the preflight's log condition fails, the batch does not start.”

