# Phase 8 — Unattended agents: event- and schedule-triggered (gh-aw)

> **Renamed.** "Agentic workflows" here means GitHub's `gh-aw` — agents triggered by events
> and schedules with no human present. Designing an analyze → plan → execute pipeline is a
> different subject: [Phase 4B](../04b-orchestration/).

**Guardrail layer: L1 — token scopes and safe-output separation** · [`GUARDRAILS.md`](../../GUARDRAILS.md)
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

---

## Extract

From the gh-aw safe-outputs reference, read 2026-08-09. Quotes verbatim.

### The whole idea in one sentence

> "**Safe outputs enforce security through separation: agents run read-only and request
> actions via structured output, while separate permission-controlled jobs execute those
> requests.**"

### Two phases, two permission sets

| Phase | Permissions | Does |
|---|---|---|
| **Agent job** | minimal — typically `contents: read`, `issues: read` | analyses, produces a **structured request** |
| **Write job** | elevated — `issues: write`, `contents: write` | validates the request, then executes it |

> "**The agent never receives write tokens directly.**"

This is the **structural** guardrail from [`GUARDRAILS.md`](../../GUARDRAILS.md) in its purest
form. There is no detection step to evade — a compromised agent cannot write, because the
process it runs in has no write credential. Compare that with a hook, which must correctly
recognise the bad action first.

### What it buys

> "This provides **least privilege, defense against prompt injection, auditability, and
> controlled limits per operation.**"

Four properties from one architectural decision. That ratio is what makes structural
guardrails worth reaching for before deterministic ones.

### The output types are a closed set

Issues and discussions (`create-issue`, `update-issue`, `close-issue`, …), pull requests
(`create-pull-request`, `create-pull-request-review-comment`, …), labels and assignment
(`add-labels`, `add-reviewer`, `assign-milestone`, …), projects and releases, security
(`create-code-scanning-alert`, `create-check-run`), plus system types `noop`,
`missing-tool`, `missing-data`.

**A closed vocabulary is itself the control.** The agent cannot request an operation that has
no handler — so the attack surface is the list, not "anything the token permits."

### Sanitisation

`allowed-domains` and `allowed-github-references` restrict which URLs and references may
appear in output; `max-bot-mentions` and `mentions` filtering limit spam and manipulation.

> Note what this defends against: the agent writing something *user-facing* that contains an
> attacker's link. Output is an injection vector in both directions.

### Take this pattern back to Track B

The read-only-then-scoped-write split is not gh-aw-specific. It is the shape your backend
agent should have at B10 and B13: the agent proposes a diff; something else with different
credentials applies it. `read-only → sandboxed write → branch → PR → human review` is the
same idea at a different scale.

---

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
