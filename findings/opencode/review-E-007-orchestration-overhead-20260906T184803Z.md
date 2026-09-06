# opencode review — E-007-orchestration-overhead

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260906T184803Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-007-orchestration-overhead.md
    sha:  57ec91d5c79d
    dirty: false
  - path: phases/04b-orchestration/README.md
    sha:  a8b244214fd1
    dirty: true
lab_head:        086bb58
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 96s |
| codex | ok | 85s |

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
| How the treatment is delivered — and proved | 1/1 | L3 |
| Controlled variables | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions, registered before the data | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Amendment 2026-09-06 — what `matches` means, and the harness move it forced | 1/1 | L3 |
| Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG | 1/1 | L3 |
| The database loss — read this before any number below it | 1/1 | L3 |
| Results — §4 step 8, as far as the surviving evidence allows | 1/1 | L2 |
| Observed telemetry | 1/1 | L3 |
| §4 step 7 — the hand re-read, written before any sheet for this batch existed | 1/1 | L3 |
| §4 step 7 — the twenty registered sheets, and the one cell that was checked by hand | 1/1 | L3 |
| §4 step 8 — the report, and why the registered tool could not produce it | 1/1 | L2 |
| §4 step 9 — the deliberate failure, variant P2: predictions registered BEFORE the run | 1/1 | L2 |
| Results | 1/1 | L1 |
| Which predictions held | 1/1 | L3 |
| Failure analysis | 1/1 | L2 |
| Sanity checks | 1/1 | L2 |
| Decision — §4 step 10, per element | 1/1 | L3 |
| Results — the stop's verdict in one place | 1/1 | L3 |
| Verified reading | 1/1 | L3 |
| The real reason to decompose | 1/1 | L3 |
| Extract | 1/1 | L3 |
| §4 step 2 — design, layers, and the trap | 1/1 | L3 |
| Predict before you run | 1/1 | L3 |
| Lab 4B.1 — Pipeline vs monolith | 1/1 | L3 |
| Lab 4B.2 — Orchestrator/worker fan-out | 1/1 | L3 |
| Lab 4B.3 — Handoff fidelity | 1/1 | L3 |
| Lab 4B.4 — When decomposition loses | 1/1 | L3 |
| Exit gate | 1/1 | L3 |
| Learning block — the six questions, §4 step 11 | 1/1 | L3 |
| §5 — validation table | 1/1 | L3 |
| Commit | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** Arm O scores test-quality 2 on 5/10 runs while arm C scores 2 on 0/10. One reviewer reads “returns nothing the evaluator or the rubric can see” literally and rejects the hypothesis because the rubric saw a difference; another restricts “returns” to registered O6/O7 outcomes and retains it.
**Layer of the implied fix:** L3
**Anchor:** returns nothing the evaluator or the rubric can see

### Predictions
**Verdict:** finding
**Failure:** For an observed O2 change of −13.4%, one reviewer applies “refuted below +25%” and calls O2 refuted; another applies “A result inside its MDE is NOT DETECTABLE” and calls it not detectable. The artifact itself later uses both treatments of sub-MDE results.
**Layer of the implied fix:** L3
**Anchor:** refuted below **+25 %** (the MDE) or above **+150 %**

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** A run delivers the complete four-tool set in a different order and receives `order-differs`. The table says the schema is checked “against Read, Grep, Glob, Task,” but does not state here whether order is part of delivery. A strict reviewer rejects the run; a set-based reviewer admits it.
**Layer of the implied fix:** L3
**Anchor:** `init.tools` per run, checked by `runner/lib/check-init-schema.sh` against `Read, Grep, Glob, Task`

### Controlled variables
**Verdict:** finding
**Failure:** The registered text says Claude Code version was held equal to E-006 batch 2 (2.1.261), while all experiment runs used 2.1.263. One reviewer treats runtime version as a violated controlled variable and invalidates the comparison to registered reference magnitudes; another accepts the later amendment and retains the within-batch comparison.
**Layer of the implied fix:** L3
**Anchor:** Held equal to E-006 batch 2 and recorded per run in the batch manifest: `runtime.model`, Claude Code version

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** With O2 observed at −13.4%, one reviewer follows this section and reports NOT DETECTABLE because the magnitude is below 25%; another follows the Predictions wording and reports REFUTED because the result is below +25%. The same numeric input therefore receives incompatible verdicts.
**Layer of the implied fix:** L3
**Anchor:** A result inside its MDE is **NOT DETECTABLE at this `n`**, never refuted.

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** finding
**Failure:** Suppose one arm has an F13 exit after incurring a very high cost but before completing. The rule excludes it “from every median,” so one reviewer removes its cost, duration, tool-call, and model-call values; another removes only unavailable or session-limit-contaminated measures. Their arm medians differ, and the artifact does not define which fields an F13 run still validly measures.
**Layer of the implied fix:** L3
**Anchor:** F13 session-limit exits are reported with their count and excluded from every median.

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Use the actual data: O2 −13.4%, O3 +34.1%, O6 tied, O7 4/10 versus 5/10, but test-quality is 2 on 5/10 arm-O runs and 0/10 controls. One reviewer interprets “nothing improved” as none of O2/O3/O6/O7 and fires row 4; another interprets it as nothing measured by the rubric and does not fire row 4. The final experiment verdict changes.
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
**Verdict:** finding
**Failure:** For delivered and declared lists containing the same four tools in different orders, the amendment changes exit 6 from batch-fatal to admissible after seeing three probe transcripts from the treatment. One reviewer treats the probe as pre-batch evidence legitimately resolving ambiguity; another treats it as treatment-informed relaxation of exclusion 0a. The artifact supplies rationale but no pre-existing rule that decides between those validity judgments.
**Layer of the implied fix:** L3
**Anchor:** Reading B is adopted because a `tools:` allowlist is a statement about **capability**

### §4 step 5 — the preflight pair, observed 2026-09-06T08:00–08:05Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG
**Verdict:** finding
**Failure:** Orders A and D have different declarations but the same delivered array; orders B and C produce another array. A reviewer can infer that declaration order affects delivery, but the experiment provides no behavioral comparison between delivered arrays. Any later claim that order is inert or behaviorally relevant would be decided differently by competent reviewers.
**Layer of the implied fix:** L3
**Anchor:** Whether the *delivered* order changes model behaviour — whether position acts as a priority, a default-selection order, or anything at all — is **still unmeasured**.

### §4 step 6 — the batch, recorded 2026-09-06T08:09:06–08:53:40Z
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The database loss — read this before any number below it
**Verdict:** finding
**Failure:** A reader extracting current state from the section encounters both “THERE WAS NO DATABASE LOSS” and preserved assertions that every run record is gone and O7 is unmeasurable. A parser or reviewer that does not implement the prose retraction scope reports BLOCKED; one that treats the blockquote as superseding the section reports the database healthy and O7 measured.
**Layer of the implied fix:** L3
**Anchor:** Every claim below this block is FALSE and is kept verbatim, unedited

### Results — §4 step 8, as far as the surviving evidence allows
**Verdict:** finding
**Failure:** This table reports O7 as BLOCKED and says the decision is undecidable, while a later additive subsection reports O7 = 4/10 and completes row 4. A reviewer asked for the Results verdict can return BLOCKED or NOT DETECTABLE depending on whether later amendments supersede earlier tables; no machine-readable current-status field rejects the stale result.
**Layer of the implied fix:** L2
**Anchor:** **O7** `maintainability` anchor 2 | 1–3 of 10 | **BLOCKED** | **not measurable**

### Observed telemetry
**Verdict:** finding
**Failure:** The section contains only “(after the run)” and no telemetry. One reviewer treats the detailed telemetry material in neighboring sections as satisfying it; another treats this named section as unpopulated and therefore incomplete.
**Layer of the implied fix:** L3
**Anchor:** *(after the run)*

### §4 step 7 — the hand re-read, written before any sheet for this batch existed
**Verdict:** finding
**Failure:** The real submission has a statement-position `when` without `else`. Anchor 0 names statement position, while anchor 1 also names a non-exhaustive `when` without `else`. One scorer assigns 0 by the residual precedence rule; another assigns 1 from the literal anchor-1 example.
**Layer of the implied fix:** L3
**Anchor:** Anchor 1 of `maintainability` lists, among the residual cases, *"also a `when` that is neither exhaustive nor carries an `else`"*.

### §4 step 7 — the twenty registered sheets, and the one cell that was checked by hand
**Verdict:** finding
**Failure:** Arm O has test-quality 2 on 5/10 runs and arm C on 0/10, but the section says the decision rule question is deferred without specifying whether this unregistered rubric dimension counts as an improvement. One reviewer includes it under row 4’s “nothing improved”; another excludes it because only O7 was registered as quality.
**Layer of the implied fix:** L3
**Anchor:** Whether that clears the decision rule registered before the batch is §4 step 10's question

### §4 step 8 — the report, and why the registered tool could not produce it
**Verdict:** finding
**Failure:** The registered report pools both arms under one experiment key, yielding a 100 s median that cannot answer the comparison. If a future reviewer runs only the registered command, they report the pooled number; a reviewer using the bespoke `per-arm.py` reports 118 s versus 88 s.
**Layer of the implied fix:** L2
**Anchor:** `baseline-report.py` is single-arm: it selects on `experimentKey` and pools everything under it.

### §4 step 9 — the deliberate failure, variant P2: predictions registered BEFORE the run
**Verdict:** finding
**Failure:** F2 defines self-writing as `Write`, `Edit`, or `MultiEdit`, while the surrounding structural claim also treats `Bash` as a code-writing capability. A P2 orchestrator that modifies a file only through `Bash` is scored as no self-write by one reviewer and as a boundary failure by another.
**Layer of the implied fix:** L2
**Anchor:** ≥ 1 `tool_result` for `Write`, `Edit` or `MultiEdit` **in the orchestrator's own stream**

### Results
**Verdict:** finding
**Failure:** The section is only “(after the run)” even though results appear later under another heading with the same name. A heading-based extractor records an empty Results section; a narrative reader associates the later material with it.
**Layer of the implied fix:** L1
**Anchor:** *(after the run)*

### Which predictions held
**Verdict:** finding
**Failure:** O2 at −13.4% is called REFUTED, while the MDE rule says any result inside 25% is NOT DETECTABLE. A reviewer enforcing the MDE labels O2 not detectable; a reviewer enforcing the directional prediction labels it refuted by sign.
**Layer of the implied fix:** L3
**Anchor:** **O2** | **+60 %** cost, detectable ≥ +25 % | **−13.4 %** | **REFUTED, and in the opposite direction.**

### Failure analysis
**Verdict:** finding
**Failure:** The analysis cites run `eac5b2b1`, but that run ID does not appear in the displayed 20-run batch table. One reviewer accepts it as a full-ID prefix or separate transcript reference; another cannot join it to an arm and rejects the claimed one-call mechanism as unsupported by the complete evidence set.
**Layer of the implied fix:** L2
**Anchor:** on run `eac5b2b1` it made **exactly one tool call, `Agent`**, and nothing else

### Sanity checks
**Verdict:** finding
**Failure:** The row claims “No registered variable moved between E-006 batch 2 and this batch,” yet the artifact explicitly establishes Claude Code moved from 2.1.261 to 2.1.263. One reviewer treats runtime version as registered and marks the sanity check failed; another excludes it because the amended driver only asserts the current version.
**Layer of the implied fix:** L2
**Anchor:** **No registered variable moved between E-006 batch 2 and this batch**

### Decision — §4 step 10, per element
**Verdict:** finding
**Failure:** The stated default says a rule with no measured effect is removed, but the `tools:` line is kept after delegation is 10/10 with it and 5/5 without it. For the same null result, one reviewer applies the default and removes it; another accepts the unsampled-tail argument and keeps it. No registered retention criterion resolves the choice.
**Layer of the implied fix:** L3
**Anchor:** **KEEP, against the default rule.**

### Results — the stop's verdict in one place
**Verdict:** finding
**Failure:** The block calls F2 “REFUTED at 0 of 5,” although the preregistration explicitly says 0/5 “refute[s] nothing” about L3/L2 equivalence. One reviewer interprets REFUTED as only the point prediction `≥1/5`; another reads it as refuting the deliberate-failure hypothesis. Those are materially different conclusions.
**Layer of the implied fix:** L3
**Anchor:** **Deliberate failure** | **F2 REFUTED at 0 of 5**

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
**Failure:** The section says raw pages were stored only in an uncommitted scratchpad. A later reviewer cannot reproduce whether each quoted fragment existed in the source snapshot used on 2026-09-05; one reviewer trusts the described process, another rejects quote verification because the evidence is absent from the complete set.
**Layer of the implied fix:** L3
**Anchor:** Raw pages are in the session scratchpad, not committed.

### The real reason to decompose
**Verdict:** finding
**Failure:** For a split that adds a clean worker context but does not reduce the parent’s context, one reviewer says decomposition still has a real reason because isolation exists; another applies the stated test and calls it overhead. “Real reason” and the operational test are not equivalent.
**Layer of the implied fix:** L3
**Anchor:** **if a split does not reduce what the parent must hold, it is overhead.**

### Extract
**Verdict:** finding
**Failure:** The section first states that capability partition is not expressible, then preserves that claim after observation proves the opposite. A reviewer extracting the declarative conclusion reports “unavailable”; another applies the correction and reports “available through an `--agent` overlay.”
**Layer of the implied fix:** L3
**Anchor:** **A capability partition between orchestrator and worker ... is not expressible in this runtime.**

### §4 step 2 — design, layers, and the trap
**Verdict:** finding
**Failure:** The design labels P1 “A structural split,” while its own layer table classifies the operative `tools:` boundary as L2 because the bad value remains writable and the runtime rejects it. One reviewer reports the split as L1 from the arm description; another reports L2 from the explicit layer algorithm.
**Layer of the implied fix:** L3
**Anchor:** **A structural split** — *if* the worker still inherits a pool that can write.

### Predict before you run
**Verdict:** finding
**Failure:** The prompt asks “At what task size does decomposition start to pay?” without defining task size. A 3-file/69-line task and a 10-file/40-line task can be ordered oppositely by file count and added lines, so two reviewers can choose different thresholds from the same future data.
**Layer of the implied fix:** L3
**Anchor:** At what task size does decomposition start to pay?

### Lab 4B.1 — Pipeline vs monolith
**Verdict:** finding
**Failure:** If the pipeline costs more and produces the same diff but improves evaluator correctness, the quoted rule calls it overhead while another reviewer says the correctness gain is a return. “Same diff” does not determine whether decomposition paid.
**Layer of the implied fix:** L3
**Anchor:** If it costs more and produces the same diff, you have found overhead.

### Lab 4B.2 — Orchestrator/worker fan-out
**Verdict:** finding
**Failure:** For workers taking 10 s, 10 s, and 60 s versus a monolith taking 70 s, one reviewer says parallelism pays because wall-clock falls to about 60 s; another says coordination eats the gain because the join waits 50 s for the slow worker. No payoff metric or threshold selects the verdict.
**Layer of the implied fix:** L3
**Anchor:** Where does parallelism pay, and where does coordination eat the gain?

### Lab 4B.3 — Handoff fidelity
**Verdict:** finding
**Failure:** If stage 3 reconstructs the missing fact independently and passes, one reviewer scores the handoff successful by final correctness; another scores it failed because the contract did not carry the fact. The lab does not define whether fidelity measures transmission or downstream recovery.
**Layer of the implied fix:** L3
**Anchor:** Does it survive?

### Lab 4B.4 — When decomposition loses
**Verdict:** finding
**Failure:** The section concludes decomposition “neither improved nor measurably cost anything the gate can see,” but the same table reports modelCalls +4 with separated quartiles and test-quality 2 on 5/10 versus 0/10 elsewhere. One reviewer restricts “gate” to decision-rule inputs and accepts the conclusion; another treats registered modelCalls as visible cost and rejects it.
**Layer of the implied fix:** L3
**Anchor:** decomposition **neither improved nor measurably cost** anything the gate can see

### Exit gate
**Verdict:** finding
**Failure:** The final item calls a 1,000-agent cap L1 because a 1,001st agent cannot be spawned, but under the supplied layer algorithm a runtime executes and rejects the request, which is L2 unless the value cannot be represented at all. A request for 1,001 agents can still be written down.
**Layer of the implied fix:** L3
**Anchor:** the caps are **L1** — *"Up to 16 concurrent agents"*, *"1,000 agents total per run — Prevents runaway loops."*

### Learning block — the six questions, §4 step 11
**Verdict:** finding
**Failure:** `observed_effect` says the split changed “nothing the rubric can see,” but the rubric’s test-quality category differs: five arm-O scores of 2 versus zero in control. A literal reviewer marks the learning claim false; a reviewer silently narrows “rubric” to registered O7 accepts it.
**Layer of the implied fix:** L3
**Anchor:** it changed neither correctness (10/10 vs 10/10) nor anything the rubric can see

### §5 — validation table
**Verdict:** finding
**Failure:** The row “No registered variable moved” cites Claude Code 2.1.263 for this batch but does not present E-006’s 2.1.261 value, already acknowledged elsewhere. Running the stated verifier can pass the current-batch guard while the cross-batch claim remains false, so the named L2 check does not enforce the claim it purports to prove.
**Layer of the implied fix:** L3
**Anchor:** **No registered variable moved between E-006 batch 2 and this batch**

### Commit
**Verdict:** finding
**Failure:** The commit block lists only `.claude/agents/*.md` and `findings/B4b-orchestration.md`, while the artifact says the measured overlay lives under `build/customizations/...` and describes numerous experiment, evidence, runner, and workbook files. One reviewer treats the block as the intended commit scope; another treats it as an obsolete template. Their commits materially differ.
**Layer of the implied fix:** L3
**Anchor:** `.claude/agents/*.md · workflow definition`

### Cross-cutting
**Verdict:** finding
**Failure:** The pass/fail delivery gate O1 duplicates scoring outcome O1: exclusion/row 0a voids the batch when O1 < 9/10, while Predictions also scores delegation as O1. The greatest reviewer divergence is in “Decision rule, fixed before the run”: with the actual test-quality difference, row 4 can be YES or not fire at all, changing the verdict by one full category from NOT DETECTABLE to no defined verdict. The artifact needed to define “nothing improved,” specify whether unregistered rubric dimensions count, and give a single precedence rule by which additive amendments supersede retained false tables and claims.
**Layer of the implied fix:** L2
**Anchor:** O1 < 9 of 10 | **VOID** — the treatment was not delivered; nothing below is read


---

## Run 2 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** If arm O costs 175% more, O2 classifies the result as refuted because it is “above +150 %,” while decision-rule row 1 classifies it as CONFIRM because it is also at least +25%. Two reviewers following the two registered statements produce opposite verdicts.
**Layer of the implied fix:** L3
**Anchor:** refuted below **+25 %** (the MDE) or above **+150 %**

### Independent variable
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** No concrete divergent reading remains after the explicit amendment distinguishing set equality from literal order.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Controlled variables
**Verdict:** finding
**Failure:** A reviewer treating “held equal to E-006 batch 2” as an admission condition rejects the 2.1.263 batch because E-006 used 2.1.261; a reviewer following the later amendment admits it using only within-batch equality.
**Layer of the implied fix:** L3
**Anchor:** Held equal to E-006 batch 2 and recorded per run in the batch manifest: `runtime.model`, Claude Code version

### Runs
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** finding
**Failure:** With O2 observed at −13.4%, one reviewer applies “inside its MDE is NOT DETECTABLE, never refuted”; another applies O2’s registered directional rule, “refuted below +25%,” and reports REFUTED. Both outcomes appear later in the artifact’s reasoning.
**Layer of the implied fix:** L3
**Anchor:** A result inside its MDE is **NOT DETECTABLE at this `n`**, never refuted.

### Deterministic evaluation
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** no finding
**Failure:** The later amendment resolves the otherwise ambiguous meaning of `matches` before the batch.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** For the observed data, test-quality improves from 0/10 controls at score 2 to 5/10 treatment runs at score 2. One reviewer reads “nothing improved” literally and refuses row 4; another limits improvement to O6 and O7 and selects NOT DETECTABLE. The rule does not define the scope.
**Layer of the implied fix:** L3
**Anchor:** O2 < +25 % and O3 < +40 % and nothing improved

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — registered at §4 step 9, not here
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06 — what `matches` means, and the harness move it forced
**Verdict:** no finding
**Failure:** The amendment names both readings, adopts one, and identifies the executing policy that enforces it.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair, observed 2026-09-06T08:00–08:05Z
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment 2026-09-06, second — I measured the premise and MY PREDICTION WAS WRONG
**Verdict:** no finding
**Failure:** The refuted premise and remaining unmeasured question are explicitly separated.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch, recorded 2026-09-06T08:09:06–08:53:40Z
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The database loss — read this before any number below it
**Verdict:** finding
**Failure:** A parser or reviewer extracting assertions by heading reads “GET /api/runs… returns 0 runs” and concludes O7 is unavailable; a reviewer honoring the embedded retraction concludes the API has 325 records and O7 is measurable. The section deliberately preserves mutually exclusive operational facts.
**Layer of the implied fix:** L3
**Anchor:** **`GET /api/runs?limit=500` returns 0 runs. Every observatory run record this project has ever produced … is gone from the database.**

### Results — §4 step 8, as far as the surviving evidence allows
**Verdict:** finding
**Failure:** A reviewer stopping at this complete-looking results table reports O7 BLOCKED and the verdict undecidable; a reviewer continuing to the later additive subsection reports O7=4/10 and row 4 NOT DETECTABLE.
**Layer of the implied fix:** L3
**Anchor:** | **O7** `maintainability` anchor 2 | 1–3 of 10 | **BLOCKED** | **not measurable** |

### Observed telemetry
**Verdict:** no finding
**Failure:** The section explicitly contains only a post-run placeholder; no claim is made from it.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 7 — the hand re-read, written before any sheet for this batch existed
**Verdict:** no finding
**Failure:** The overlap between maintainability anchors 0 and 1 is identified with a concrete submission and resolved by the rubric’s residual precedence rule.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 7 — the twenty registered sheets, and the one cell that was checked by hand
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 8 — the report, and why the registered tool could not produce it
**Verdict:** no finding
**Failure:** The pooled-report defect is disclosed and the per-arm derivation is clearly distinguished.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 9 — the deliberate failure, variant P2: predictions registered BEFORE the run
**Verdict:** no finding
**Failure:** The registered source substitution and its acceptance condition are specified before the substituted measurement is applied.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** This heading contains only an explicit placeholder and makes no substantive claim.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** finding
**Failure:** For O2 at −13.4%, this section says REFUTED, while the global MDE rule says an effect inside the ±25% instrument floor is NOT DETECTABLE and never refuted. Two reviewers applying those statements classify the same observation differently.
**Layer of the implied fix:** L3
**Anchor:** | **O2** | **+60 %** cost, detectable ≥ +25 % | **−13.4 %** | **REFUTED, and in the opposite direction.**

### Failure analysis
**Verdict:** finding
**Failure:** A reviewer attempting to reproduce the claimed one-call orchestrator trace cannot join run `eac5b2b1` to any of the 20 main-batch run IDs listed earlier; another may assume it is an undocumented full-ID prefix and accept the causal explanation. The cited run is not identified sufficiently to verify the claim from this evidence.
**Layer of the implied fix:** L3
**Anchor:** on run `eac5b2b1` it made **exactly one tool call, `Agent`**, and nothing else

### Sanity checks
**Verdict:** finding
**Failure:** A reviewer checking the stated condition against E-006 rejects it because Claude Code moved from 2.1.261 to 2.1.263; the table nevertheless treats the 2.1.263 evidence as proving that no registered variable moved.
**Layer of the implied fix:** L2
**Anchor:** | **No registered variable moved between E-006 batch 2 and this batch** | `runtime.model` `claude-haiku-4-5-20251001` and Claude Code `2.1.263` on 20 of 20

### Decision — §4 step 10, per element
**Verdict:** no finding
**Failure:** The departure from the default removal rule is explicitly marked as a judgment call and bounded to the untested tail case.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results — the stop's verdict in one place
**Verdict:** finding
**Failure:** With the observed 5/10 versus 0/10 test-quality improvement, a literal reader of row 4’s “nothing improved” condition does not select NOT DETECTABLE; the summary selects row 4 without stating why this scored rubric improvement is excluded.
**Layer of the implied fix:** L3
**Anchor:** **Main batch verdict** | **NOT DETECTABLE** (decision rule row 4)

### Follow-up
**Verdict:** no finding
**Failure:** The anchor overlap is attached to a concrete statement-position `when` and correctly deferred because the rubric is registered.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Goal
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Verified reading
**Verdict:** no finding
**Failure:** Skipped sources are explicitly named and their limited dependency is stated.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The real reason to decompose
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Extract
**Verdict:** finding
**Failure:** A caller can request 1,001 agents in a workflow, so the bad value can still be written; the runtime then enforces the 1,000-agent cap. Under the mandated layer test this is L2, but the artifact labels it L1.
**Layer of the implied fix:** L2
**Anchor:** limits "Up to 16 concurrent agents" and "1,000 agents total per run — Prevents runaway loops" (the 50-subagent failure mode above, made structural — an L1 cap).

### §4 step 2 — design, layers, and the trap
**Verdict:** finding
**Failure:** For P1, a reviewer following “A structural split” labels the `tools:` restriction L1; a reviewer following the section’s own layer table labels it L2 because the YAML can name an unavailable tool and the runtime rejects its use. The same control receives two layers.
**Layer of the implied fix:** L3
**Anchor:** **A structural split** — *if* the worker still inherits a pool that can write.

### Predict before you run
**Verdict:** no finding
**Failure:** These are prompts for predictions rather than adjudication rules.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.1 — Pipeline vs monolith
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.2 — Orchestrator/worker fan-out
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.3 — Handoff fidelity
**Verdict:** no finding
**Failure:** No concrete divergent reading or wrong-answer scenario identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab 4B.4 — When decomposition loses
**Verdict:** finding
**Failure:** The treatment improves test-quality to score 2 on 5/10 runs versus 0/10 controls. One reviewer therefore rejects the claim that it changed “nothing the gate can see”; another ignores test-quality because it was not named in the decision rule and accepts NOT DETECTABLE.
**Layer of the implied fix:** L3
**Anchor:** decomposition **neither improved nor measurably cost** anything the gate can see

### Exit gate
**Verdict:** finding
**Failure:** A workflow specification may request a 1,001st agent, after which a running cap rejects it. The artifact calls this L1, but the required first-yes test makes it L2 because the bad request remains representable and something executes to reject it.
**Layer of the implied fix:** L2
**Anchor:** the caps are **L1** — *"Up to 16 concurrent agents"*, *"1,000 agents total per run — Prevents runaway loops."*

### Learning block — the six questions, §4 step 11
**Verdict:** finding
**Failure:** A reader of `observed_effect` concludes the rubric saw no change, but the same artifact reports test-quality score 2 in 5/10 treatment runs and 0/10 controls. A downstream learner extracting this YAML loses that observed rubric difference.
**Layer of the implied fix:** L3
**Anchor:** it changed neither correctness (10/10 vs 10/10) nor anything the rubric can see

### §5 — validation table
**Verdict:** finding
**Failure:** The row claiming no registered variable moved is falsified by its own evidence: E-006 used Claude Code 2.1.261 and this batch used 2.1.263. One reviewer marks the gate failed; another treats the later runtime amendment as superseding the row.
**Layer of the implied fix:** L2
**Anchor:** **No registered variable moved between E-006 batch 2 and this batch**

### Commit
**Verdict:** finding
**Failure:** A reviewer treating this as the promised commit inventory expects only `.claude/agents/*.md` and `findings/B4b-orchestration.md`; another sees the experiment repeatedly cite newly committed drivers, verifiers, collectors, evidence, and workbook changes. The block does not define whether it is illustrative or exhaustive.
**Layer of the implied fix:** L3
**Anchor:** `.claude/agents/*.md · workflow definition
findings/B4b-orchestration.md`

### Cross-cutting
**Verdict:** finding
**Failure:** The pass/fail delivery gate O1 (at least 9/10 delegations in decision row 0a) duplicates scoring outcome O1 (delegation 10/10, control 0/10, exactly one on at least 7/10). The section most likely to diverge is “Decision rule, fixed before the run”: on the observed test-quality improvement, reviewers can differ by a full final verdict—NOT DETECTABLE versus no registered row applicable. The artifacts needed to define whether “nothing improved” means only O6/O7, every registered outcome, or every scored rubric category; they also needed one authoritative supersession rule so retracted database claims and corrected results could not remain simultaneously machine-readable as current claims.
**Layer of the implied fix:** L3
**Anchor:** O1 < 9 of 10 | **VOID** — the treatment was not delivered; nothing below is read

