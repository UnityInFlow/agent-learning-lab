# B5 — Workflow phases

**Track A first:** [Phase 4B](../04b-orchestration/) · **Layer 3, unless you split structurally**
**Version:** **v1.0**
**Spine position:** 12 of 28 · after [Phase 4B](../04b-orchestration/) · before [B6](../b06-specialist-skill/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b5).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.4 core/workflow.md
     BUSINESS-REQUIREMENTS §10.6 completion-contract.md
     BUSINESS-REQUIREMENTS FR-011 workflow observation
     BUSINESS-REQUIREMENTS Risk: workflow costs more tokens than it saves -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. The question worth bringing: a workflow written as prose is
     still Layer 3. What would make it structural? -->

## Build

**Build:** `ANALYSIS → DESIGN → IMPLEMENTATION → VERIFICATION → REVIEW → DONE`, with an
output contract per phase.

| Phase | Must produce |
|---|---|
| ANALYSIS | restated goal · repository findings · risks · affected files · open questions |
| DESIGN | proposed change · alternatives · data and error flow · test strategy |
| IMPLEMENTATION | focused code matching the design |
| VERIFICATION | commands · results · failures · fixes |
| REVIEW | acceptance-criteria mapping · diff review · unresolved findings |
| DONE | completion contract passed |

**Purpose:** prevent premature coding and false completion. **Cost:** tokens. Measure both —
phases skipped, failed exits, time per phase, and the token overhead.

Risk profiles come later, and only if measured:

```
QUICK      ANALYSIS → IMPLEMENTATION → VERIFICATION → DONE
STANDARD   the six above
HIGH_RISK  + APPROVAL after DESIGN, + SECURITY_REVIEW and HUMAN_APPROVAL before DONE
```

## Predict before you run

<!-- TODO: predict the token overhead as a percentage before measuring it.
     The build track says "measure both" — a prediction makes that honest. -->

## Lab B5.1 — measure against B4

<!-- TODO -->

## Deliberate failure

<!-- TODO: instruct it to skip DESIGN and see whether the phase markers
     still appear. If prose alone holds the workflow, you have measured
     Layer 3 compliance, not enforcement. -->

## Exit gate

**From the build track:** phase markers observable in the transcript · no code written before
DESIGN · overhead measured, not assumed.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
