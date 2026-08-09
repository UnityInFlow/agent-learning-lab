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
