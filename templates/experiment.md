# Experiment E-XXX

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`. We got
> that wrong once and voided nine runs.

## Question

What are we trying to learn?

## Hypothesis

What do we predict, and by what mechanism? A hypothesis without a mechanism cannot be
interestingly wrong.

## Predictions

Numbered, specific, falsifiable. Include the direction and rough magnitude.

1.
2.
3.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

Exactly what changes between arms. **One thing.**

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | e.g. `CLAUDE.md` with `@AGENTS.md`, or `--append-system-prompt-file` |
| Content hash | |
| Preflight assertion | How do we prove it entered the model's context? |
| Control assertion | How do we prove the control did **not** receive it? |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.

## Controlled variables

- [ ] starting commit / benchmark revision SHA
- [ ] task + revision
- [ ] harness + version
- [ ] model — **exact ID, not an alias**
- [ ] permissions / permission mode
- [ ] environment: hooks, plugins, skills, MCP servers, settings sources
      (`--setting-sources project`? verify by observing 0 hook executions, not by trusting the flag)
- [ ] runner commit

## Runs

Repetitions per arm: ____ · Total budget: $____

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

**Derived from a measured arm, before any threshold below is written.** An MDE filled in with
the prediction's own thresholds measures nothing — `E-002` did that and two of its three
refutations turned out to sit inside its own detection limit.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: | | | |
| secondary: | | | |

**Derive it against the *interval* of the baseline, not the point estimate.** `E-003`, 2026-09-03:
the baseline was 1 of 5, the MDE was computed against a projected control of 2 of 10, and the
control came in at **3 of 10**. That one run moved the registered effect size from p = 0.023 to
**p = 0.070** — from decidable to not — with nothing careless anywhere in the design. Ask what
`n` the effect stays decidable at across the plausible range of the control, and register *that*
`n`. Here it was 12–15 rather than 10.

**A result that lands inside an MDE is recorded as NOT DETECTABLE at this `n`, never as
refuted.** Two claims can be made about an arm and they have different requirements:

| the prediction says | what tests it | what a null means |
|---|---|---|
| *"the arms differ"* | a two-arm test against the control that **occurred** | inside the MDE → **not detectable** |
| *"this arm reaches X on ≥ k of n"* | a one-arm binomial; **no control is needed** | far from k → **refuted**, regardless of the other arm |

State which one the prediction makes. If it makes both, report both.

## Deterministic evaluation

Which scripts/tests determine correctness. The evaluator decides, not the agent.

## Exclusions

What is excluded from analysis and why — registered **now**, not after seeing the data.
Infrastructure failures (F13/F15), permission blocks, quota exhaustion.

## Decision rule

Registered before data. What result produces KEEP / REJECT / INCONCLUSIVE?

**The rows must be exhaustive.** Write them, then find the combination that reaches no row —
if one exists, the rule is broken and you will discover it while holding data you cannot label.
`E-003` shipped with a `REJECT` row reading *"the treatment fails **and** costs more than
+25 %"*. The treatment failed and cost **−2.5 %**, so by the letter `REJECT` never fired and the
verdict arrived only through a per-rule clause that happened to empty the file.

**Useless-and-cheap is still a rejection.** An AND-condition pairing "it did not work" with "it
was expensive" quietly assumes a thing that does nothing is worth keeping while it is free. **A
free useless rule is still a rule someone has to read, trust and maintain.** Cost belongs in the
verdict as a separate row, never as a second condition on the failure row.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

Which spans/metrics/events.

## Results

Raw, then summary. **Median and p25/p75. Never an average alone.**

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | | | |

## Failure analysis

Why did failures happen? For each: was it the agent, or the harness?

> Before blaming the agent, ask what else changed. Seven of our findings were harness bugs.

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

Keep / change / reject / **void**, and why.

## Follow-up
