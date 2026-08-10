# B3 — Minimal global instructions

**Track A first:** [Phase 1](../01-instructions/) · **Layer 3 — guidance only**
**Version:** — (pre-v1.0)
**Spine position:** 6 of 28 · after [Phase 1](../01-instructions/) · before [Phase 2](../02-prompt-files/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b3).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.2 core/principles.md
     BUSINESS-REQUIREMENTS P1    correctness before token optimization
     BUSINESS-REQUIREMENTS §17   initial promotion rules -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. Phase 1 already owns the sentence that voided our first
     experiment — "Claude Code reads CLAUDE.md, not AGENTS.md". The
     extract here should be about what an instruction can and cannot
     buy, not about file placement. -->

## Build

**Build:** the smallest instruction file that changes measured behaviour.

Start with rules B2 actually violated. Candidates:

- inspect existing patterns before creating new ones
- make the smallest cohesive change
- do not add dependencies without approval
- run the repository verification command
- **do not claim completion when verification fails**

**The trap Phase 1 already cost us:** delivering the file is not delivering the treatment.
Claude reads `CLAUDE.md`, not `AGENTS.md`. Assert the content reached the model — hash it,
and preflight-check that the hash appears in context — before the first run.

## Predict before you run

<!-- TODO: per rule, state the expected behavioural effect BEFORE running.
     A rule with no predicted effect cannot be evaluated, and the gate
     below requires you to delete it. -->

## Lab B3.1 — measure against B2

<!-- TODO: 3 controlled comparisons vs the B2 baseline.
     Known result to beat: on BE-002, a CLAUDE.md conventions file cost
     +39% (p<.01) for identical acceptance — see EXP-BE002-CLAUDEMD-V2.
     Predict whether BE-003 behaves the same way before you look. -->

## Deliberate failure

<!-- TODO: bloat the file deliberately and measure the cost, or contradict
     a rule and see whether the agent notices. Phase 1's Lab 1.3 is the model. -->

## Exit gate

**From the build track:** version it `instructions-v0.1` · each rule has a stated expected effect ·
3 controlled comparisons vs B2 · **remove every rule with no measured effect.**

**Plus, for this to count as a learned phase:**

<!-- TODO: how many rules survived, and what does the survival rate tell
     you about Layer 3? -->

## Commit

<!-- TODO -->
