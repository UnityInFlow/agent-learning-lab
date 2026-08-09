# Phase 8 — Agentic workflows / unattended agents

**Status:** ⬜ Not started · **Depends on:** Phase 7

## Goal

Move from *human initiates every agent run* to *event or schedule initiates the agent*.

**This is a major risk transition.** Everything you learned about approval prompts stops
applying, because there is nobody to prompt.

## Verified reading

- [ ] ✅ [gh-aw home](https://github.github.com/gh-aw/) — **Public Preview.** Pin versions, revalidate every cohort
- [ ] ✅ [Creating workflows](https://github.github.com/gh-aw/setup/creating-workflows/)
- [ ] ✅ [Safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/)
- [ ] ✅ [Permissions](https://github.github.com/gh-aw/reference/permissions/)
- [ ] ✅ [A/B experiments](https://github.github.com/gh-aw/experimental/experiments/)

## The architecture that matters

```
event → read-only agent job → structured requested output
      → safe-output validation / threat checks → separate scoped write job
```

**The agent should not simply receive a broad write token.** The separation between the job
that thinks and the job that writes is the whole design.

## Predict before you run

1. What fraction of a daily drift report will be genuinely actionable in week one? Week
   three?
2. What does your workflow do with an issue body containing adversarial instructions?
3. What is the run cost per useful finding?

## Lab 8.1 — Read-only scheduled report

First unattended workflow: a daily standards-drift report. Artifact or staged result, **no
repository mutation**.

Measure: useful finding rate · false positive rate · run cost · runtime · duplicate/noise
rate.

## Lab 8.2 — Safe output in staged mode

A workflow proposing an issue/PR, run staged/preview first. Inspect: agent job permissions ·
downstream write permissions · structured output · sanitization · final action.

## Lab 8.3 — Prompt injection fixture

A test issue body with adversarial instructions. Expected: it must not directly obtain write
capability; safe outputs and policy limit blast radius; security detections fire.

## Lab 8.4 — A/B experiment

One variant: concise prompt vs detailed prompt.

> Concise variant reduces AI units/tokens by ≥15% while keeping evaluation score above 0.9.

Multiple runs. This is where controlled experiments beat preference — and where the
lessons from Phase 1 about *registering the bar before you see the data* pay off.

## The noise kill rule

If an unattended workflow generates ignored or noisy output for two consecutive weeks:

```
disable → analyze → redesign → re-evaluate
```

**Do not preserve automation because "AI-first".**

## Exit gate

- [ ] Human-triggered vs unattended risk
- [ ] Read-only default
- [ ] Safe-output separation
- [ ] Schedule/event attack surface
- [ ] Why auto-merge should not be the first target

## Commit

```
.github/workflows/<workflow>.md
experiments/B8-agentic-workflows.md
security/unattended-agent-threat-model.md
```
