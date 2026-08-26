# Contributing

This is a workbook, not a library. What is committed here is evidence — predictions made
before a run, results that contradicted them, and the reasoning in between. That makes the
standard for a change unusual: **the artifact is not the deliverable, the learning is.**

## The rule

> A feature is not learned when the file exists. It is learned when you can explain what
> changed in the agent, prove that it happened, measure its effect, and identify its failure
> mode.

Every phase runs the same loop, and skipping PREDICT is the most common way to learn nothing:
if you did not write down what you expected, any result feels like it confirms something.

```
LEARN THE MECHANISM → READ VERIFIED DOCS → PREDICT → BUILD THE SMALLEST VERSION
      → RUN A CONTROLLED TASK → OBSERVE → RUN DETERMINISTIC EVALS
      → DELIBERATELY BREAK IT → EXPLAIN THE FAILURE → COMPARE WITH BASELINE
      → COMMIT THE ARTIFACT → PASS EXIT GATE
```

## Order of work in a phase

1. Open the phase folder. Read its `README.md` top to bottom **before touching a tool**
2. Work the verified reading. Add new sources to `SOURCES.md` so `check-links.sh` covers them
3. Write predictions into a copy of `templates/experiment.md`, and **commit it before the
   first run**. Check the commit timestamp precedes the run's `startedAt` — getting that
   wrong once voided nine runs
4. Run the labs, recording with `templates/run-record.yaml`
5. Break it deliberately and name the failure
6. Tick the exit gate. If you cannot answer a gate question out loud, you are not done

## Predictions are the point

A prediction adopted from someone else measures nothing. If you take one from a colleague, a
model, or a previous phase, **record that provenance** — a rubric scored against its own
author's predictions is a weaker claim than one scored against yours, and the difference has
to be visible when the result is read.

Record predictions that were wrong as wrong. They are the only part of this that teaches
anything, and quietly revising one destroys the evidence.

## Classify every change by layer

See [`GUARDRAILS.md`](GUARDRAILS.md). L1 means the bad state cannot be represented. L2 means
something executes and rejects it. **L3 means words a human reads and chooses to follow.**

Twelve of twenty-eight spine positions operate at L3 only. Saying a change is L3 is not a
criticism of it; claiming L2 for something that merely reads well is the problem, and it has
already cost this project a voided twenty-run experiment.

## The review harness

`.opencode/` holds two agents that critique work without rewriting it, deliberately: the
artifact stays with whoever is learning from it.

```bash
./tools/opencode-review.sh -n 2 <artifact>     # union across independent runs
./tools/opencode-score.sh <rubric> <impl-dir>  # blind second scoring
```

Two things measured about the reviewer itself, worth knowing before you read its output.
It **under-reports rather than hallucinating** — two runs at temperature 0 over the same
artifact disagreed on 2 of 12 sections, and both flips were real findings the earlier run
missed. So a single run is a lower bound, and low recurrence is a detection-threshold
signal, not a falsity signal. And three models hang indefinitely on non-interactive runs:
`opencode-go/kimi-k3`, `opencode-go/glm-5.3`, `ollama-cloud/kimi-k2.6`.

Score anything yourself **before** reading the harness's output. Reading it first produces
agreement that measures nothing.

## Commit messages

Explain what was learned, not what was written. Where a result contradicted a prediction,
say so in the message — that is the finding.

## What does not belong here

The instrument lives in
[`agent-observatory`](https://github.com/UnityInFlow/agent-observatory). Tasks, evaluators
and fixtures live in
[`agent-observatory-benchmarks`](https://github.com/UnityInFlow/agent-observatory-benchmarks).
This repository holds the curriculum, the labs, the verified reading, the predictions and the
findings.
