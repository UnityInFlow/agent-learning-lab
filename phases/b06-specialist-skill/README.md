# B6 — One specialist skill

**Track A first:** [Phase 3](../03-skills/) · **Layer 3**
**Version:** **v1.0**
**Spine position:** 13 of 28 · after [B5](../b05-workflow-phases/) · before [Phase 5A](../05a-guardrails/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b6).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.8 skills/<skill>/SKILL.md
     BUSINESS-REQUIREMENTS P4    evidence before complexity
     BUSINESS-REQUIREMENTS §1130 never install unreviewed skills into bank repositories -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO -->

## Build

**Build:** exactly one. Chosen from a **measured** failure in B2–B5, not from a wish list.

Candidates: `database-change` · `testing-and-verification` · `spring-backend-feature`.

A skill answers eight questions: when it activates · when it must not · required inputs ·
workflow · which references may load · which scripts run · required output · how success is
verified.

## Predict before you run

<!-- TODO: name the measured failure this skill is for, and predict how
     much of it the skill removes. If you cannot point at a failure in
     B2–B5, you are not ready for this step. -->

## Lab B6.1 — measure against B5, with and without

<!-- TODO: the gate demands activation be *recorded*, not inferred.
     Note the harness precedent: EXP-BE002-CLAUDEMD was voided because a
     skill activated in 5 of 23 runs and the field that should have caught
     it (skillsHash) was structurally incapable of reporting it. Decide
     how you will know this skill ran, before you run it. -->

## Deliberate failure

<!-- TODO: trigger it when it must not activate. -->

## Exit gate

**From the build track:** activation is *recorded*, not inferred from the answer text · runs with
and without compared on quality, tokens, context and corrections · keep, modify, or **remove**.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
