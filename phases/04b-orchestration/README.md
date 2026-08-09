# Phase 4B — Agent orchestration and multi-layer design

**Guardrail layer: L3 — unless the split is structural, in which case L1.**
**Status:** ⬜ Not started · **Depends on:** Phase 4A

## Goal

Phase 4A built *one* specialized agent. This is about *many* — decomposition, layering,
handoffs, and the question most multi-agent material skips: **when not to.**

This phase does not exist in the original curriculum. It is the gap between "a single
custom agent" and "that agent running unattended", and it is where the
ANALYSIS → DESIGN → IMPLEMENTATION → VERIFICATION → REVIEW → DONE workflow in your backend
agent v1 actually gets designed.

## Verified reading

- [ ] ✅ [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
  > *Workflow or agent — who chooses the next step?*

  **Extracted in [Phase 0A](../00a-agent-mechanics/README.md#extract).** Re-read the five
  patterns here: prompt chaining, routing, parallelization, orchestrator–workers,
  evaluator–optimizer. Your v1 workflow is **prompt chaining** with an evaluator-optimizer
  loop bolted on at VERIFICATION.
- [ ] ✅ [Anthropic — Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
  > *What does orchestrator/worker cost in tokens, and when does that pay?*
- [ ] ✅ [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents)
  > *What exactly is isolated — context, tools, model, permissions?*
- [ ] ✅ [Claude Code — Agent teams](https://code.claude.com/docs/en/agent-teams)
- [ ] ✅ [Claude Code — Dynamic workflows](https://code.claude.com/docs/en/workflows)
  > *When should orchestration be deterministic code rather than a model decision?*
- [ ] ✅ [A harness for every task](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code)
- [ ] ↪️ [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) · ✅ [Copilot custom agents](https://docs.github.com/en/copilot/reference/custom-agents-configuration)

## The real reason to decompose

Not "specialization." **Context isolation.**

From the Phase 0A extract: context rot means recall degrades as the window fills. A
sub-agent works in a clean window and returns a condensed summary, so the parent never
pays for the worker's exploration. That is the mechanism — everything else is a story.

Which gives you the test: **if a split does not reduce what the parent must hold, it is
overhead.**

---

## Extract

From *Multi-agent research system*, read 2026-08-09. Quotes verbatim.

### The architecture

A lead agent "analyzes [queries], develops a strategy, and spawns subagents to explore
different aspects simultaneously." Subagents run in parallel, **each with its own context
window**, and return findings to the lead for synthesis.

### The numbers — read these before designing anything

> - "agents typically use about **4× more tokens** than chat interactions, and multi-agent
>   systems use about **15× more tokens** than chats"
> - "a multi-agent system with Claude Opus 4 as the lead agent and Claude Sonnet 4 subagents
>   **outperformed single-agent Claude Opus 4 by 90.2%**"
> - "token usage by itself explains **80% of the variance**" in browsing agent performance

15× cost for a 90% gain is an excellent trade — **on the right task.** Which brings us to the
sentence that matters most for you:

### The warning aimed directly at this project

> "**Most coding tasks involve fewer truly parallelizable tasks than research.**"

Multi-agent suits "heavy parallelization, information that exceeds single context windows,
and interfacing with numerous complex tools" — breadth-first queries with independent
directions.

It is **poorly suited** to domains requiring "all agents to share the same context or
involve many dependencies between agents."

> A backend feature implementation is dependency-dense and context-shared. That is the
> profile the article names as a poor fit. Your v1 pipeline (ANALYSIS→DESIGN→…) is
> **prompt chaining**, not parallel fan-out — sequential stages, one context handed forward.
> That is the right pattern, and it is worth knowing you chose correctly for a reason rather
> than by luck.

### Scaling effort to complexity

> "Simple fact-finding requires just **1 agent with 3–10 tool calls**, direct comparisons
> might need **2–4 subagents with 10–15 calls each**, and complex research might use **more
> than 10 subagents**."

Put this in the orchestrator's prompt. Without it:

> "Without detailed task descriptions, agents duplicate work, leave gaps, or fail to find
> necessary information."

### Failure modes

> - "agents spawning **50 subagents for simple queries**, scouring the web endlessly for
>   nonexistent sources"
> - "minor changes cascade into large behavioral changes"
> - errors compound because "agents can run for long periods of time, maintaining state
>   across many tool calls"

The first is Lab 4B.4 in the wild. The second is why you change one variable at a time.

### On evaluating them

LLM-as-judge with a rubric — factual accuracy, citation accuracy, completeness, source
quality, tool efficiency — but: **"Human evaluation catches what automation misses,"**
including edge cases and source-selection bias.

---

## Predict before you run

1. Four agents (analyze/plan/execute/verify) vs one agent, same task — which uses more
   total tokens? By how much?
2. Which uses more *wall-clock*?
3. What will stage 3 not know that stage 1 knew?
4. At what task size does decomposition start to pay?

## Lab 4B.1 — Pipeline vs monolith

The same task twice: as one agent, and as ANALYSIS → DESIGN → IMPLEMENTATION →
VERIFICATION → REVIEW.

Measure total tokens, wall-clock, correctness, diff size, and scope discipline.

> Expect the pipeline to cost **more** tokens and produce a **tighter** diff. If it costs
> more and produces the same diff, you have found overhead.

## Lab 4B.2 — Orchestrator/worker fan-out

A task with genuinely independent parts. Fan out, then join.

Where does parallelism pay, and where does coordination eat the gain? Watch for the
barrier: if one worker is slow, the whole join waits.

## Lab 4B.3 — Handoff fidelity

Give stage 1 a piece of information that stage 3 needs and stage 2 has no reason to
forward. Does it survive?

This is the failure mode that makes multi-agent systems mysteriously worse than a single
agent — **nobody loses information visibly.** Design the handoff contract explicitly, then
test that it carries what you think it carries.

## Lab 4B.4 — When decomposition loses

**The most important lab here.** Run a task too small to split.

Most multi-agent material assumes more agents is better. You have an instrument that can
prove otherwise. Measure the overhead and write it down.

> "Consider adding complexity **only** when it demonstrably improves outcomes."

## Exit gate

- [ ] Workflow vs agent — who chooses the next step
- [ ] Name all five patterns and which one your v1 uses
- [ ] Why context isolation, not specialization, is the reason to split
- [ ] What your handoff contract carries, and what it drops
- [ ] **The task size below which decomposition costs more than it returns — as a number**
- [ ] When orchestration should be deterministic code rather than a model decision

## Commit

```
.claude/agents/*.md · workflow definition
findings/B4b-orchestration.md
```
