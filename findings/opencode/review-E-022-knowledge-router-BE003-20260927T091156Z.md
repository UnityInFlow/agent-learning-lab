# opencode review — E-022-knowledge-router-BE003

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
reviewed_utc:    20260927T091156Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-022-knowledge-router-BE003.md
    sha:  131816d287a7
    dirty: false
lab_head:        077bacb
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
| codex | ok | 85s |
| codex | ok | 64s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Question | 1/1 | L2 |
| Predictions | 1/1 | L2 |
| Independent variable | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Controlled variables | 1/1 | L3 |
| Runs | 1/1 | L2 |
| Exclusions | 1/1 | L2 |
| Decision rule | 1/1 | L2 |
| Observed telemetry | 1/1 | L2 |
| Which predictions held | 1/1 | L3 |
| Failure analysis | 1/1 | L2 |
| Sanity checks | 1/1 | L2 |
| Follow-up | 1/1 | L2 |
| Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction | 1/1 | L2 |
| Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway | 1/1 | L2 |
| Amendment 4 — the batch died twice, the deaths were the harness, and the throughput decision is recorded here before it was acted on | 1/1 | L3 |
| Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-003 the difference is one run and one word | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |
| Minimum detectable effect | 1/1 | L2 |
| Decision | 1/1 | L2 |
| Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation | 1/1 | L2 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** finding
**Failure:** Run BE-003 06 reads `index.yaml` and the summary directly without invoking the router. One reviewer answers “yes, retrieval happened”; another answers “no, the router was not used.” The artifact later reports 20% while corpus contact was 30%, so the stated instrumentation question has two incompatible answers.
**Layer of the implied fix:** L2
**Anchor:** “can this instrument record that a retrieval happened at all?”

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** Prediction 3 equates a non-empty router log with router use and says this decides whether anything was tested. In BE-003 06, the agent reads the index and summary directly, produces no router log, and is counted as no uptake. Counting retrieval gives H=3 and REJECT; counting router invocations gives H=2 and VOID.
**Layer of the implied fix:** L2
**Anchor:** “THE ROUTER IS USED, and this decides whether anything was tested. `.agent/knowledge-log.jsonl` is non-empty on ≥ 7 of 10 treated runs”

### Independent variable
**Verdict:** finding
**Failure:** If the treated arm improves, one reviewer can attribute the change to corpus content, another to the router executable, and another to the added `CLAUDE.md` clause. All three differ together, so the claim “Exactly one thing” does not support a component-level causal interpretation even though the confound is later acknowledged.
**Layer of the implied fix:** L3
**Anchor:** “Exactly one thing: the customization overlay.”

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The second preflight has no treated router log, so assertion (b) fails and the preflight exits 2. The artifact nevertheless starts the batch after a separate capability probe. A reviewer applying “If (b) fails, the batch does not start” rejects the batch; the artifact’s later reviewer admits it.
**Layer of the implied fix:** L2
**Anchor:** “If (b) fails, the batch does not start.”

### Controlled variables
**Verdict:** finding
**Failure:** The registered control says permissions are unchanged from B8, but Amendment 2 adds `Bash(.ai/knowledge/router.sh:*)` to every run. A reviewer checking the table reports permissions controlled at the B8 value; a reviewer checking the amendment reports a different three-entry allowlist.
**Layer of the implied fix:** L3
**Anchor:** “permissions / permission mode — as B8's batch, unchanged”

### Runs
**Verdict:** finding
**Failure:** The stated budget arithmetic includes 20 batch runs and 2 preflight runs, but the experiment actually performs eight preflight runs across two attempts, permission probes, an in-worktree probe, and orphaned runs. A reviewer treating `≤ $3.20` as the experiment ceiling rejects the run; one treating it as only the final BE-003 batch budget accepts it.
**Layer of the implied fix:** L2
**Anchor:** “Total budget: ≤ $3.20 for this task (20 batch runs at B8's `$0.12` median = `$2.40`, plus 2 preflight runs, plus headroom)”

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

### Exclusions
**Verdict:** finding
**Failure:** Run `413bcf23-65f4-49d3-a789-c29b3dcf1b48` completed with evaluator exit 0 and recoverable evidence but lacked a manifest row. One reviewer classifies that as an infrastructure failure and replaces it; another classifies it as a completed run requiring reconstruction. The exclusion rule gives no operational boundary between those outcomes.
**Layer of the implied fix:** L2
**Anchor:** “infrastructure failures of the F13/F15 class, permission blocks, quota exhaustion → excluded”

### Decision rule
**Verdict:** finding
**Failure:** For H=3 and M=6, row 2 returns `INCONCLUSIVE — SEPARATED FROM HISTORY`, although the MDE table says only 7/10 clears the historical null and 6/10 does not. The rule therefore emits a factually unsupported verdict label for a concrete enumerated input.
**Layer of the implied fix:** L2
**Anchor:** “`H ≥ 3` and `M` is 6 or 7 | INCONCLUSIVE — SEPARATED FROM HISTORY”

### Observed telemetry
**Verdict:** finding
**Failure:** BE-003 06 directly reads the corpus but has no router log. The section says the other eight runs did not act on the instruction, incorrectly placing that run among non-users; the later census shows three corpus-contact runs, not two.
**Layer of the implied fix:** L2
**Anchor:** “The other eight read the instruction and did not act on it.”

### Results
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** finding
**Failure:** The table assigns a held/refuted outcome to all five predictions, but the prose says only four are answerable. A reviewer counting table classifications reports five answerable predictions; a reviewer treating the VOID causal result as making P1 unanswerable reports four.
**Layer of the implied fix:** L3
**Anchor:** “Four of five registered predictions are answerable”

### Failure analysis
**Verdict:** finding
**Failure:** BE-003 06 consulted the corpus directly, so it is false that at most the two logged runs could have been influenced. If run 06 is one of the five anchor-2 successes, up to three successes could have been influenced; the artifact does not provide the cross-tab needed to decide.
**Layer of the implied fix:** L2
**Anchor:** “eight of them never opened the log, so at most two of those five could have been influenced by the corpus at all.”

### Sanity checks
**Verdict:** finding
**Failure:** The flattering-number check treats absence of a knowledge log as absence of knowledge exposure. Run 06 is a counterexample: it has no log but reads the index and summary. Two reviewers therefore classify the treated arm as either eight unexposed runs or seven unexposed runs.
**Layer of the implied fix:** L2
**Anchor:** “eight of the ten treated runs never opened the knowledge log, so the arm is mostly control runs wearing a hash.”

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** finding
**Failure:** The section calls 2/10 the unqualified “hit rate measured.” The later census establishes 2/10 router invocation but 3/10 corpus contact. A downstream §5 table can therefore record either 20% or 30% depending on what its reviewer understands “hit” to mean.
**Layer of the implied fix:** L2
**Anchor:** “B9's gate clause ‘hit rate measured’ is answered by this batch, and the answer is 20 %”

### Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction
**Verdict:** finding
**Failure:** The unconditional allow rule can affect a control if the agent creates `.ai/knowledge/router.sh` and then executes it: that Bash call is newly allowed despite the path not existing initially. One reviewer accepts the claim that controls cannot change; another rejects it using that concrete generated-path case.
**Layer of the implied fix:** L2
**Anchor:** “An allow rule for a path that does not exist cannot change a control run's behaviour.”

### Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway
**Verdict:** finding
**Failure:** The second preflight exits 2 because the registered uptake assertion fails, yet this amendment authorizes the batch by reinterpreting the gate as testing mere executability. A reviewer following the explicit preflight contract stops; a reviewer following this amendment proceeds. No precedence rule says which instruction governs.
**Layer of the implied fix:** L2
**Anchor:** “`evidence/b09/preflight-20260926T131746Z/`, four runs, exit 2”

### Amendment 4 — the batch died twice, the deaths were the harness, and the throughput decision is recorded here before it was acted on
**Verdict:** finding
**Failure:** The registered exclusion covers a batch spanning machine sleep, but the amendment extends it to a rate-limit window and excludes the paired control “conservatively” without evidence that its 160-second duration was contaminated. A reviewer applying only the registered case keeps that control duration; the artifact excludes it.
**Layer of the implied fix:** L3
**Anchor:** “Concretely that is BE-003 01 treated (5 420 000 ms) and, conservatively, its pair partner 01 control.”

### Hand re-read — written 2026-09-26, BEFORE any scoring sheet for this batch exists
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-003 the difference is one run and one word
**Verdict:** finding
**Failure:** Run BE-003 06 reads `index.yaml` and the summary directly but produces no router log. Under the registered proxy H=2 and the verdict is VOID; under the stated substantive construct “the corpus was consulted,” H=3 and the verdict is REJECT. The primary verdict therefore turns on an instrumentation omission, not merely terminology.
**Layer of the implied fix:** L2
**Anchor:** “had `H` been registered as the run consulted the corpus, it would read 3, row 0 would not fire, and row 3 (`H ≥ 3` and `M ≤ 5`, with `M = 5`) would — a REJECT”

### Cross-cutting
**Verdict:** finding
**Failure:** Duplicate gate/category: no scoring category duplicates the evaluator or `check-run-gate.sh` pass/fail gate; maintainability anchor 2 is an outcome, not an admission gate. Greatest divergence: `Amendment 5 — H counts router invocations, not corpus consultations, and on BE-003 the difference is one run and one word`; reviewers can differ by one H count (2 versus 3), changing VOID to REJECT and changing the disposition from retaining the corpus to removing it. Missing statement: the artifact needed a pre-registered, exhaustive definition of retrieval/contact covering router calls and direct file reads, plus an executed recorder that observes both.
**Layer of the implied fix:** L2
**Anchor:** n/a


---

## Run 2 of 2 — codex

### Question
**Verdict:** finding
**Failure:** Run BE-003 06 reads `index.yaml` and a summary directly but never invokes the router. One reviewer answers “retrieval happened”; another answers “no” because the registered instrument observes only router invocations. The question does not define which event counts.
**Layer of the implied fix:** L3
**Anchor:** “can this instrument record that a retrieval happened at all?”

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete input or diff makes the stated causal alternatives yield divergent readings.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** For observed counts M=6 and C=3, prediction 1 fails its registered ≥8 threshold and prediction 2 achieves the registered ≥+4 difference, while Fisher significance may still fail. Reviewers can therefore disagree whether prediction 2 “held” based on the effect threshold or the later significance language.
**Layer of the implied fix:** L3
**Anchor:** “Treated minus control is ≥ +4 anchor-2 runs.”

### Independent variable
**Verdict:** no finding
**Failure:** The corpus/router/instruction bundle and the resulting limitation on causal attribution are explicitly registered, so no unacknowledged divergent interpretation was found.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The second preflight has a matching corpus and no denial but an absent log. The stated rule says the batch must not start; Amendment 3 starts it anyway. Two competent operators following different operative passages would stop or launch the same batch.
**Layer of the implied fix:** L2
**Anchor:** “If (b) fails, the batch does not start.”

### Controlled variables
**Verdict:** finding
**Failure:** A reviewer checking the original list records permissions as unchanged from B8, while a reviewer applying Amendment 2 records a new third `--allowedTools` entry. The same run is consequently classified as controlled or changed.
**Layer of the implied fix:** L2
**Anchor:** “permissions / permission mode — as B8's batch, unchanged”

### Runs
**Verdict:** no finding
**Failure:** The registered batch size, interleaving, budget, and timing are stated concretely; no conflicting population definition appears within this section.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** With M=6, the decision rule assigns `INCONCLUSIVE — SEPARATED FROM HISTORY`, although this section states only ≥7 clears the historical one-arm test. The artifact therefore asserts historical separation for a count its own calculation does not separate.
**Layer of the implied fix:** L2
**Anchor:** “≥ 7 of 10 already clears `p = 0.0318`”

### Deterministic evaluation
**Verdict:** no finding
**Failure:** The evaluator gate, scorer, rubric revision, and second-reader role are identified without a concrete conflicting case.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** finding
**Failure:** A completed orphan run with evaluator output and a complete log is excluded as an “infrastructure failure” because its manifest row was not written, then replaced. Another reviewer could classify only execution failures as F13/F15-class infrastructure exclusions and retain this completed run, changing the population.
**Layer of the implied fix:** L3
**Anchor:** “infrastructure failures of the F13/F15 class, permission blocks, quota exhaustion”

### Decision rule
**Verdict:** finding
**Failure:** For M=5 with two router invocations plus one direct corpus consultation, the registered rule returns VOID because H=2; counting actual corpus consultation returns H=3 and REJECT. This exact batch contains that input, so the verdict and disposition turn on an observation definition that does not match “the treatment was not tested.”
**Layer of the implied fix:** L2
**Anchor:** “`H` = treated runs whose `.agent/knowledge-log.jsonl` is non-empty.”

### Observed telemetry
**Verdict:** finding
**Failure:** BE-003 06 directly consulted two corpus files but produced no router log. The table reports H=2 correctly as router-log telemetry, while the following prose concludes the other eight did not act on the instruction; run 06 makes that conclusion false.
**Layer of the implied fix:** L2
**Anchor:** “The other eight read the instruction and did not act on it.”

### Results
**Verdict:** no finding
**Failure:** The registered population, category values, costs, and contaminated-key behavior are explicitly separated; no concrete arithmetic or population mismatch is visible in the supplied evidence.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** finding
**Failure:** All five rows receive a `Held?` outcome, but the prose says only four are answerable. Reviewers can count prediction 2 as answerable from the registered +4 threshold or unanswerable because its inferential test is underpowered, producing totals of five or four.
**Layer of the implied fix:** L3
**Anchor:** “Four of five registered predictions are answerable”

### Failure analysis
**Verdict:** finding
**Failure:** Run 06 consulted the corpus directly without opening the router log. The section treats every no-log run as a non-consultation, so it wrongly says eight runs did not consult the corpus and uses that false premise in its causal account.
**Layer of the implied fix:** L2
**Anchor:** “on eight of ten runs the agent did not consult it.”

### Sanity checks
**Verdict:** finding
**Failure:** The flattering-number check says eight treated runs never opened the knowledge log and concludes the arm is mostly control runs. Run 06 directly read the corpus, so no-log status does not establish control-equivalent exposure; two reviewers can classify that run differently.
**Layer of the implied fix:** L2
**Anchor:** “the arm is mostly control runs wearing a hash.”

### Decision
**Verdict:** finding
**Failure:** On the actual data, the registered log definition gives H=2 and VOID, while the observed-treatment definition gives three corpus contacts and REJECT. The decision presents “treatment was not tested” without carrying this one-run sensitivity into the decision block.
**Layer of the implied fix:** L2
**Anchor:** “`VOID — THE TREATMENT WAS NOT TESTED`, by decision-rule row 0 (`H ≤ 2`)”

### Follow-up
**Verdict:** finding
**Failure:** The section answers the gate’s unqualified “hit rate measured” with 20%, but BE-003 06 shows that 20% is router invocation, not corpus contact; corpus contact is 30%. A downstream §5 table can therefore record the wrong rate depending on which meaning of hit it assumes.
**Layer of the implied fix:** L3
**Anchor:** “B9's gate clause "hit rate measured" is answered by this batch, and the answer is 20 %”

### Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation
**Verdict:** finding
**Failure:** The amendment moves evidence to a deterministic `/tmp`-derived path but specifies no executed cleanup or freshness check. A stale non-empty file for a reused worktree basename can satisfy preflight condition (b) even when the current run never invokes the router.
**Layer of the implied fix:** L2
**Anchor:** “`${KNOWLEDGE_EVENT_LOG:-${TMPDIR:-/tmp}/knowledge-log-$(basename "$ROOT").jsonl}`”

### Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction
**Verdict:** no finding
**Failure:** The denied-attempt and non-attempt cases are concretely distinguished, and the permission probe identifies the executing control that rejected the command.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway
**Verdict:** finding
**Failure:** The in-worktree probe proves executability only when the prompt causes a router call; both treated preflight runs still make no attempt. One reviewer can treat this as satisfying the original ≥1-line preflight, while another must stop because the actual treated preflight still fails it.
**Layer of the implied fix:** L3
**Anchor:** “Deliverability is now proven in-harness by the probe above, so the batch can test it.”

### Amendment 4 — the batch died twice, the deaths were the harness, and the throughput decision is recorded here before it was acted on
**Verdict:** finding
**Failure:** The exclusion rule names infrastructure failures such as permission blocks or quota exhaustion, but this amendment extends it to a successfully completed, fully readable run whose manifest row was missing. Keeping versus replacing that run changes which stochastic result occupies sequence 03.
**Layer of the implied fix:** L3
**Anchor:** “Excluded and replaced”

### Hand re-read — written 2026-09-26, BEFORE any scoring sheet for this batch exists
**Verdict:** no finding
**Failure:** The cited construct, absence of `else`, and consumption of the expression value uniquely support the recorded score for the supplied run.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-003 the difference is one run and one word
**Verdict:** finding
**Failure:** The amendment demonstrates that the executed decision rule measures router invocation while its verdict text claims whether the treatment was tested. On the actual batch, invocation yields VOID and consultation yields REJECT, so the validator can exhaustively enforce the wrong semantic partition.
**Layer of the implied fix:** L2
**Anchor:** “The verdict turns on one run and on one word.”

### Cross-cutting
**Verdict:** finding
**Failure:** The scoring category `maintainability` anchor 2 does not duplicate a pass/fail gate: evaluator correctness admits runs, while the rubric scores the Kotlin construct. The greatest reviewer divergence is in `Decision rule`: the same observed batch yields VOID at H=2 or REJECT at three corpus contacts, a full disposition change from retaining to removing the corpus. The artifact needed to say, before execution, whether “tested,” “retrieval,” “used,” and “hit” mean router invocation or any corpus access, and to enforce that definition with telemetry covering direct reads.
**Layer of the implied fix:** L2
**Anchor:** “`H` = treated runs whose `.agent/knowledge-log.jsonl` is non-empty.”

