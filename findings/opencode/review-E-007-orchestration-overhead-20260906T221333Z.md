# opencode review — E-007-orchestration-overhead

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260906T221333Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-007-orchestration-overhead.md
    sha:  519bd2a0878b
    dirty: false
  - path: phases/04b-orchestration/README.md
    sha:  cd6b3e42fded
    dirty: false
lab_head:        45ef6b5
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 90s |
| codex | ok | 100s |

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
| Independent variable | 1/1 | L1 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Controlled variables | 1/1 | L2 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions, registered before the data | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L2 |
| Amendment 2026-09-06 — what `matches` means, and the harness move it forced | 1/1 | L2 |
| Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG | 1/1 | L3 |
| Results — §4 step 8, as far as the surviving evidence allows | 1/1 | L3 |
| Observed telemetry | 1/1 | L1 |
| Results | 1/1 | L1 |
| Failure analysis | 1/1 | L3 |
| Sanity checks | 1/1 | L2 |
| Decision — §4 step 10, per element | 1/1 | L3 |
| Results — the stop's verdict in one place | 1/1 | L3 |
| Verified reading | 1/1 | L3 |
| The real reason to decompose | 1/1 | L3 |
| Extract | 1/1 | L1 |
| §4 step 2 — design, layers, and the trap | 1/1 | L2 |
| Predict before you run | 1/1 | L3 |
| Lab 4B.2 — Orchestrator/worker fan-out | 1/1 | L3 |
| Lab 4B.3 — Handoff fidelity | 1/1 | L3 |
| Lab 4B.4 — When decomposition loses | 1/1 | L3 |
| Exit gate | 1/1 | L3 |
| Learning block — the six questions, §4 step 11 | 1/1 | L3 |
| §5 — validation table | 1/1 | L3 |
| §4a review round — every finding, fixed or disputed | 1/1 | L3 |
| Commit | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |
| Verdict: **NOT DETECTABLE** (row 4). The lower bound the gate asked for is NOT set. | 1/1 | L3 |
| §4 step 8 — the report, and why the registered tool could not produce it | 1/1 | L3 |
| Follow-up | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** For a run where the orchestrator immediately delegates without reading repository files, reviewer A treats the hypothesis as falsified because the parent does not retain or duplicate the worker’s context; reviewer B tests only the predicted cost increase and calls the hypothesis merely not detected. The artifact later documents exactly this behavior but never fixes which part constitutes the hypothesis under test.
**Layer of the implied fix:** L3
**Anchor:** the split does not reduce what the parent must hold, because the parent holds almost nothing to begin with; it only adds a second context that re-reads the repository

### Predictions
**Verdict:** finding
**Failure:** With O7 = 4/10, reviewer A marks O7 false because the registered band is 1–3/10; reviewer B marks it substantively held because 4/10 is inside the MDE and shows no detectable change. Both treatments appear later in the artifact, changing the count of predictions held from three to four.
**Layer of the implied fix:** L3
**Anchor:** 1–3 of 10, no change; only ≥ 9 of 10 would be detectable

### Independent variable
**Verdict:** finding
**Failure:** Given P1 versus the plain control, reviewer A attributes any effect to decomposition; reviewer B attributes the extra test lines or test-quality movement to the implementer’s four-line body, which exists only in the treatment. The design explicitly cannot distinguish these causes, so the independent variable cannot support a decomposition-only claim.
**Layer of the implied fix:** L1
**Anchor:** it is disclosed that the treatment is the split including that minimal prose

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** For an arm-O run with the correct four-tool init set and one delegation but an accidentally different overlay body, reviewer A admits it because the listed proof checks init, telemetry, and the setup tree generally; reviewer B rejects it because no run-record hash binds that exact overlay to that run. The same observable evidence can therefore admit two materially different treatments.
**Layer of the implied fix:** L2
**Anchor:** Independence rests on the `init` record, the setup commit's tree and the telemetry

### Controlled variables
**Verdict:** finding
**Failure:** A reviewer comparing the registered design to E-006 reads “held equal” and voids or flags runs on Claude Code 2.1.263 because E-006 used 2.1.261; another follows the later amendment and accepts them using the concurrent control. The artifact says the variable was controlled and later says it moved.
**Layer of the implied fix:** L2
**Anchor:** Held equal to E-006 batch 2 and recorded per run in the batch manifest: `runtime.model`, Claude Code version

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** For an observed cost change of −30%, reviewer A calls it detectable because its absolute magnitude exceeds 25%; reviewer B refuses because the stated MDE is directional, “≥ +25%,” and permits only detection of an increase. The artifact later treats −13.4% as inside the floor, but the MDE section never defines whether negative effects use absolute magnitude.
**Layer of the implied fix:** L3
**Anchor:** **≥ +25 %** on the median

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** finding
**Failure:** For an F13 run with a valid evaluator result, reviewer A excludes only its duration and cost medians; reviewer B excludes it from toolCalls, modelCalls, addedLines, and every other median because the rule says “every median.” The resulting arm medians can differ even with the same run set.
**Layer of the implied fix:** L3
**Anchor:** F13 session-limit exits are reported with their count and excluded from every median.

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Use O2 = 0%, O3 = 0%, O6 = 10/10 versus control 7/10, and O7 = 4/10. Reviewer A applies row 4 first and returns NOT DETECTABLE; reviewer B applies row 5 and returns REFUTE. The stated precedence only says rows 3 and 5 outrank row 1, not that row 5 outranks row 4, and “nothing improved” is itself undefined.
**Layer of the implied fix:** L2
**Anchor:** Rows 3 and 5 outrank row 1.

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — registered at §4 step 9, not here
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06 — what `matches` means, and the harness move it forced
**Verdict:** finding
**Failure:** For a future runtime that returns exit 6 while also dropping a tool because the checker’s exit-code contract changes, the policy admits the run solely because code 6 was registered as nonfatal. Reviewer A trusts the exit code; reviewer B rechecks set equality. The amendment binds admission to a code rather than specifying an executed end-to-end assertion of the delivered set at the decision point.
**Layer of the implied fix:** L2
**Anchor:** Exactly one exit code moved: 6.

### §4 step 5 — the preflight pair, observed 2026-09-06T08:00–08:05Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG
**Verdict:** finding
**Failure:** For a later experiment using declared order D instead of A, reviewer A treats it as equivalent because the capability set is identical; reviewer B treats it as a new treatment because the artifact explicitly leaves behavioral effects of delivered order unmeasured. Those reviewers can attribute a changed delegation rate differently.
**Layer of the implied fix:** L3
**Anchor:** Whether the *delivered* order changes model behaviour — whether position acts as a priority, a default-selection order, or anything at all — is **still unmeasured**.

### §4 step 6 — the batch, recorded 2026-09-06T08:09:06–08:53:40Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The database loss — read this before any number below it
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results — §4 step 8, as far as the surviving evidence allows
**Verdict:** finding
**Failure:** For O2 = −13.4%, reviewer A records “REFUTED” because the +60% prediction has the wrong sign; reviewer B records “NOT DETECTABLE” because the magnitude is inside the registered MDE. Both verdicts are used in this artifact, so an automated prediction tally and an effect-level analysis produce different answers.
**Layer of the implied fix:** L3
**Anchor:** **REFUTED — and in the opposite direction**

### Observed telemetry
**Verdict:** finding
**Failure:** A reader asked for the telemetry evidence encounters only “(after the run)” under this top-level section and must infer that later step sections supply it; another treats the section as intentionally empty. A completeness checker keyed to top-level sections would report missing evidence while a narrative reader would not.
**Layer of the implied fix:** L1
**Anchor:** *(after the run)*

### Results
**Verdict:** finding
**Failure:** This top-level key occurs twice. A parser that maps headings to keys overwrites the first empty Results section with “Which predictions held,” while a parser that preserves arrays retains both. The artifact therefore produces different section sets depending on a competent parser’s duplicate-key policy.
**Layer of the implied fix:** L1
**Anchor:** ## Results

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** finding
**Failure:** For the claim that O2’s mechanism failed, reviewer A accepts the cited P2 run because it shows freely chosen one-call delegation; reviewer B rejects it because P2 is outside the main batch and differs by removal of the tools restriction. The mechanism conclusion for the main treatment consequently depends on cross-treatment evidence not defined as admissible.
**Layer of the implied fix:** L3
**Anchor:** on run `eac5b2b1` — **a §4 step 9 P2 run, NOT one of the twenty in the table above; cited because its orchestrator is unrestricted

### Sanity checks
**Verdict:** finding
**Failure:** For a batch on version 2.1.263 after registration against 2.1.261, reviewer A says the version guard is L2 because the driver enforces 2.1.263 within this batch; reviewer B says it cannot establish the registered cross-batch equality and marks that claim failed. The check enforces a revised value, not the original controlled-variable claim.
**Layer of the implied fix:** L2
**Anchor:** **L2** — asserted per batch by `run-e007.sh`, which refuses any other version

### Decision — §4 step 10, per element
**Verdict:** finding
**Failure:** Given the stated default “a rule with no measured effect is removed” and delegation of 10/10 with L2 versus 5/5 without it, reviewer A removes the tools line; reviewer B keeps it based on an unmeasured tail-risk argument. The artifact chooses KEEP while admitting the registered rule points to REMOVE, so the same data yield opposite decisions.
**Layer of the implied fix:** L3
**Anchor:** **By the letter of the rule, the `tools:` line should be removed.**

### Results — the stop's verdict in one place
**Verdict:** finding
**Failure:** Under reading A of “nothing improved,” row 4 yields NOT DETECTABLE; under reading B, test-quality improved and no row fires. This section presents only NOT DETECTABLE as the main verdict, so two reviewers following the artifact’s explicitly preserved readings report different final statuses.
**Layer of the implied fix:** L3
**Anchor:** **Main batch verdict** | **NOT DETECTABLE** (decision rule row 4)

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Goal
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Verified reading
**Verdict:** finding
**Failure:** A reviewer attempting to verify the quotations from the complete repository evidence cannot do so because the raw pages were left in an uncommitted scratchpad; another accepts the author’s statement that fragments were checked. The evidence standard therefore depends on trust in an unavailable source copy.
**Layer of the implied fix:** L3
**Anchor:** Raw pages are in the session scratchpad, not committed.

### The real reason to decompose
**Verdict:** finding
**Failure:** For a split where the parent reads nothing and the worker performs all exploration, reviewer A says decomposition succeeds because the parent’s context is isolated; reviewer B says the test fails because “reduce what the parent must hold” lacks a measurable baseline and threshold. The later experiment infers context movement from one transcript without a registered context-size measure.
**Layer of the implied fix:** L3
**Anchor:** **if a split does not reduce what the parent must hold, it is overhead.**

### Extract
**Verdict:** finding
**Failure:** The section first concludes that capability partition is unavailable, then preserves a correction showing the runtime permits a write-capable worker under a narrowed parent. A retrieval system that extracts the first declarative paragraph reports the opposite runtime capability from one that follows the later correction.
**Layer of the implied fix:** L1
**Anchor:** **A capability partition between orchestrator and worker ... is not expressible in this runtime.**

### §4 step 2 — design, layers, and the trap
**Verdict:** finding
**Failure:** For P1, reviewer A follows the registered delivery proof requiring schema verdict `matches` and voids all ten `order-differs` runs; reviewer B follows the later amendment and admits them by set equality. Because the original gate and its amendment coexist in the section, the same batch can be VOID or admissible.
**Layer of the implied fix:** L2
**Anchor:** verdict `matches` for P1

### Predict before you run
**Verdict:** finding
**Failure:** Two reviewers answering “At what task size does decomposition start to pay?” can order a 3-file/69-line task and a 10-file/40-line task oppositely because no size metric or ordering rule is defined. The later text defers this choice, so the requested prediction is not reproducible.
**Layer of the implied fix:** L3
**Anchor:** At what task size does decomposition start to pay?

### Lab 4B.1 — Pipeline vs monolith
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.2 — Orchestrator/worker fan-out
**Verdict:** finding
**Failure:** For a task with two independent workers taking 10 s and 100 s, reviewer A reports 90 s of parallelism saved relative to 110 s sequential time; reviewer B reports the 100 s barrier as coordination cost. The lab asks where coordination “eats the gain” without defining the counterfactual or cost calculation.
**Layer of the implied fix:** L3
**Anchor:** Where does parallelism pay, and where does coordination eat the gain?

### Lab 4B.3 — Handoff fidelity
**Verdict:** finding
**Failure:** If stage 1 knows acceptance criteria A and B, stage 2 forwards only A, and stage 3 independently rediscovers B, reviewer A records successful fidelity because the final output contains B; reviewer B records handoff loss because B was absent from the handoff. The section does not define whether fidelity measures transmission or final recovery.
**Layer of the implied fix:** L3
**Anchor:** Does it survive?

### Lab 4B.4 — When decomposition loses
**Verdict:** finding
**Failure:** With modelCalls +4 beyond its MDE and test-quality 5/10 versus 0/10, reviewer A says decomposition measurably costs and returns something; reviewer B applies the registered decision rule, which reads neither effect, and returns NOT DETECTABLE. The section states it “neither improved nor measurably cost anything the gate can see,” despite documenting both movements.
**Layer of the implied fix:** L3
**Anchor:** decomposition **neither improved nor measurably cost** anything the gate can see

### Exit gate
**Verdict:** finding
**Failure:** For the 1,001st requested spawn, reviewer A labels the cap L2 because a runtime executes and rejects it; reviewer B follows the final sentence and labels it L1 because the runner “cannot spawn” it. Both classifications appear in the same gate item after an explicit L1-to-L2 correction.
**Layer of the implied fix:** L3
**Anchor:** a runner that cannot spawn a 1 001st agent is L1.

### Learning block — the six questions, §4 step 11
**Verdict:** finding
**Failure:** For the observed cost median at −13.4% inside the MDE, reviewer A preserves the factual median but says no cost effect was established; reviewer B reads “cost NOTHING” and “CHEAPER” as an established zero or beneficial effect. Those lead to different lessons about whether decomposition has monetary cost.
**Layer of the implied fix:** L3
**Anchor:** It cost NOTHING in money — arm O was 13.4 % CHEAPER

### §5 — validation table
**Verdict:** finding
**Failure:** For the 1,000-agent product cap, reviewer A follows the corrected Exit gate classification and records L2; reviewer B follows this validation row and records L1. The validation table therefore certifies the exact layer error the artifact says it corrected.
**Layer of the implied fix:** L3
**Anchor:** the cap it cites is **L1** in the product being quoted

### §4a review round — every finding, fixed or disputed
**Verdict:** finding
**Failure:** A reviewer treats the artifact as reviewed after its corrections because the review round exited 0; another treats the material corrections as unreviewed because the artifact explicitly says it did not rerun review and the acceptance gate was skipped. These produce different confidence statuses for the final claims.
**Layer of the implied fix:** L3
**Anchor:** **Not re-run after revision**

### Commit
**Verdict:** finding
**Failure:** A reviewer trying to reproduce a run after macOS removes `$TMPDIR` finds no kept worktree, and a database loss removes the only run record; another reviewer working before cleanup can reproduce both. The committed artifact list therefore does not preserve the complete evidence required for stable reproduction.
**Layer of the implied fix:** L2
**Anchor:** the kept worktrees live under `$TMPDIR/observatory-run-<runId>` and macOS reaps them; the run records live only in the observatory database, which **has no backup**

### Cross-cutting
**Verdict:** finding
**Failure:** The scoring category `maintainability` duplicates the pass/fail evaluator gate for BE-003 where both inspect the same status/error-path implementation: a submission with the correct evaluator behavior but a statement-position `when` passes the gate while scoring maintainability 0, so reviewers can treat the same code shape as correctness-only or quality failure. The section most likely to diverge is `Decision rule, fixed before the run`: on the explicit wider reading of “nothing improved,” one reviewer returns NO VERDICT, while the adopted reading returns NOT DETECTABLE—a full categorical difference. The artifacts needed to specify a total precedence order for decision rows, define “nothing improved,” define task-size ordering, and preserve run records plus quoted source evidence in durable committed storage.
**Layer of the implied fix:** L2
**Anchor:** O2 < +25 % and O3 < +40 % and nothing improved


---

## Run 2 of 2 — codex

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

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Controlled variables
**Verdict:** finding
**Failure:** A reviewer using this section records Claude Code 2.1.261 as controlled, while a reviewer following the later amendment records 2.1.263 and treats the historical reference population as cross-version. They consequently disagree on whether the registered control held.
**Layer of the implied fix:** L3
**Anchor:** Held equal to E-006 batch 2 and recorded per run in the batch manifest: `runtime.model`, Claude Code version

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
**Verdict:** finding
**Failure:** With O2 = −13.4%, O3 = +34.1%, O6 tied, O7 = 4/10, and unregistered `test-quality` improving 5/10 versus 0/10, one reviewer reads “nothing improved” as “no registered outcome improved” and returns row 4, NOT DETECTABLE; another reads it literally and finds that no row fires. The artifact itself later computes both outcomes.
**Layer of the implied fix:** L3
**Anchor:** O2 < +25 % and O3 < +40 % and nothing improved

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — registered at §4 step 9, not here
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06 — what `matches` means, and the harness move it forced
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair, observed 2026-09-06T08:00–08:05Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch, recorded 2026-09-06T08:09:06–08:53:40Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The database loss — read this before any number below it
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results — §4 step 8, as far as the surviving evidence allows
**Verdict:** finding
**Failure:** A reviewer extracting O2 provenance from this section reports that cost came only from a committed table because the API was lost; a reviewer following the preceding retraction reports the same observation as API-rederivable. The O7 row has an explicit supersession marker, but the false provenance statement for the other metrics remains operative-looking.
**Layer of the implied fix:** L3
**Anchor:** Nothing here is stated as re-derivable from the API, because the API can no longer derive any of it.

### Verdict: **NOT DETECTABLE** (row 4). The lower bound the gate asked for is NOT set.
**Verdict:** finding
**Failure:** For the observed `test-quality` result of 5/10 versus 0/10, a reviewer applying the heading as the experiment’s unconditional verdict reports NOT DETECTABLE; a reviewer applying the later recorded literal reading of “nothing improved” reports that no decision-rule row fires. The heading does not qualify itself with the adopted registered-outcomes-only reading.
**Layer of the implied fix:** L3
**Anchor:** ## Verdict: **NOT DETECTABLE** (row 4). The lower bound the gate asked for is NOT set.

### Observed telemetry
**Verdict:** finding
**Failure:** A reviewer asked to locate the artifact’s observed telemetry finds an empty section and reports no telemetry results; another searches later sections and reconstructs delegation and tool-call observations from §4 step 7. The section named for the evidence contains only “(after the run)”.
**Layer of the implied fix:** L3
**Anchor:** *(after the run)*

### §4 step 7 — the hand re-read, written before any sheet for this batch existed
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 7 — the twenty registered sheets, and the one cell that was checked by hand
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 8 — the report, and why the registered tool could not produce it
**Verdict:** finding
**Failure:** Given the displayed medians, one reviewer reports arm O as cheaper, while another applies the artifact’s later O2 correction and reports only that a +25% penalty was not detected because −13.4% is inside the instrument floor. Those are materially different claims about cost.
**Layer of the implied fix:** L3
**Anchor:** Arm O is **slower** and **cheaper**: +34 % on median duration, −13 % on median cost.

### §4 step 9 — the deliberate failure, variant P2: predictions registered BEFORE the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** finding
**Failure:** A reviewer using this section concludes that only `maintainability` varied and that the rubric saw no arm difference. A reviewer using the twenty-sheet table finds `test-quality` at 5/10 versus 0/10 with Fisher p = 0.0325. The first reviewer therefore gives a wrong account of which rubric dimensions moved.
**Layer of the implied fix:** L3
**Anchor:** Only `maintainability` moved, and it moved by one run in the *control's* favour. **So O7 is a weak instrument reading, not a strong null**, and the sentence that survives is the one with its `n` attached: *of these ten runs per arm, the rubric saw no difference*.

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision — §4 step 10, per element
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results — the stop's verdict in one place
**Verdict:** finding
**Failure:** A downstream reader consuming this purported single-place result reports NOT DETECTABLE without qualification. A reader applying the artifact’s recorded wider interpretation of “nothing improved” reports NO ROW FIRES because `test-quality` improved. The table omits that alternative verdict even though it is part of the complete evidence set.
**Layer of the implied fix:** L3
**Anchor:** **Main batch verdict** | **NOT DETECTABLE** (decision rule row 4), `n = 10` per arm

### Follow-up
**Verdict:** finding
**Failure:** A future experimenter treating this section as the action list schedules the rubric-anchor repair and BE-004 but omits the repeatedly named “first follow-up”: a decision rule that reads `modelCalls` and a preregistered policy for `test-quality`. Another reader following the earlier prose schedules those changes. The next experiment therefore differs depending on which section is treated as authoritative.
**Layer of the implied fix:** L3
**Anchor:** - **`maintainability` anchors 0 and 1 overlap** on a statement-position `when` that carries no
  `else` — anchor 0 names it by position, anchor 1 names it in its residual list.
- The threshold, not the bound: the same design on BE-004 at stop 12 under author decision 9.

### Goal
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Verified reading
**Verdict:** finding
**Failure:** The extract attributes exact vendor wording to raw HTML, but a reviewer with only the complete evidence set cannot inspect those pages because they were left in an uncommitted scratchpad. One reviewer accepts the claimed verification; another cannot distinguish a verified fragment from a transcription error.
**Layer of the implied fix:** L3
**Anchor:** Raw pages are in the session scratchpad, not committed.

### Extract
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predict before you run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.1 — Pipeline vs monolith
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.2 — Orchestrator/worker fan-out
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.3 — Handoff fidelity
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.4 — When decomposition loses
**Verdict:** finding
**Failure:** With the observed −13.4% median cost difference, one reviewer repeats this section’s claim that arm O was cheaper; another follows E-007’s explicit correction and refuses to claim a cheaper effect because the magnitude is inside the MDE. The lab’s principal interpretation changes from directional savings to nondetection.
**Layer of the implied fix:** L3
**Anchor:** Arm O was **cheaper**.

### Exit gate
**Verdict:** finding
**Failure:** For a script that requests a 1,001st agent, one reviewer follows the corrected paragraph and labels the cap L2 because the request can be written and the runtime rejects it; another follows the final sentence and labels the same runtime cap L1. The artifact produces two layer answers for the identical input.
**Layer of the implied fix:** L3
**Anchor:** a runner that cannot spawn a 1 001st agent is L1.

### Learning block — the six questions, §4 step 11
**Verdict:** finding
**Failure:** For O2 = −13.4% inside the registered MDE, one reviewer records “cost NOTHING” and a cheaper treatment; another follows the experiment’s correction and records that no cost effect was established in either direction. These yield different learned claims from the same ten pairs.
**Layer of the implied fix:** L3
**Anchor:** It cost NOTHING in money — arm O was 13.4 % CHEAPER against a registered +60 %

### §5 — validation table
**Verdict:** finding
**Failure:** For the product’s 1,000-agent runtime cap, a reviewer using this table labels the proof L1; a reviewer using the corrected Exit gate labels it L2 because a 1,001st spawn remains expressible and is rejected at execution. This is the same concrete control assigned incompatible layers.
**Layer of the implied fix:** L3
**Anchor:** the cap it cites is **L1** in the product being quoted

### §4a review round — every finding, fixed or disputed
**Verdict:** finding
**Failure:** A reviewer interprets “every finding, fixed or disputed” as a completed review disposition; another notes that the revision was not re-reviewed and that the executable P2 tools were never sent to the critic. A defect introduced by a correction or residing in those tools can therefore be treated either as reviewed or outside review scope.
**Layer of the implied fix:** L3
**Anchor:** **Not re-run after revision, and the reason.**

### Commit
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** `maintainability` anchor 2 is both a scoring category and a pass/fail decision gate: O7 supplies the score, while decision-rule row 3 turns O7 ≥ 9/10 into REFUTE. Reviewers would diverge most on `Decision rule, fixed before the run`: the exact observed data yields either NOT DETECTABLE or no verdict, a full one-state difference. The artifacts needed a preregistered definition of “nothing improved,” an exhaustive fallback when no row fires, and a policy for measured but unregistered rubric dimensions.
**Layer of the implied fix:** L3
**Anchor:** O7 ≥ 9 of 10 in arm O | **REFUTE**

