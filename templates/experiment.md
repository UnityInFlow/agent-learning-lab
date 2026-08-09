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
- [ ] environment: hooks, plugins, skills, MCP servers, settings sources (`--bare`?)
- [ ] runner commit

## Runs

Repetitions per arm: ____ · Total budget: $____

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

Derived from which measured arm? MDE per outcome:

| Outcome | MDE | Registered before B1 existed? |
|---|---|---|
| primary: | | |
| secondary: | | |

## Deterministic evaluation

Which scripts/tests determine correctness. The evaluator decides, not the agent.

## Exclusions

What is excluded from analysis and why — registered **now**, not after seeing the data.
Infrastructure failures (F13/F15), permission blocks, quota exhaustion.

## Decision rule

Registered before data. What result produces KEEP / REJECT / INCONCLUSIVE?

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
