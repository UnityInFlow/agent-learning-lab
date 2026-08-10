# B4 — Agent boundary

**Track A first:** [Phase 4A](../04a-agents-permissions/) · **Layer 2 — tool list only**
**Version:** **v1.0**
**Spine position:** 10 of 28 · after [Phase 4A](../04a-agents-permissions/) · before [Phase 4B](../04b-orchestration/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b4).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.3 core/boundaries.md
     BUSINESS-REQUIREMENTS §10.7 backend-feature-implementer.md
     BUSINESS-REQUIREMENTS G7    enforce hard requirements deterministically
     V1-WHAT-NEXT §1             what v1 already defines -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. The distinction to pin down: the agent's *description* is
     Layer 3, the *tool list* is Layer 2. Only one of them constrains. -->

## Build

**Build:** one narrowly scoped `backend-feature-implementer`.

Ten sections, no more: mission · supported tasks · required inputs · allowed tools ·
boundaries · workflow · skill-selection rules · output contract · escalation conditions ·
completion rules.

```
Allowed     inspect relevant code · modify relevant code and tests
            run approved commands · produce analysis and verification summaries
Prohibited  deployment · infrastructure · credentials · unrelated refactoring
            destructive schema changes · new dependencies
Approval    breaking API change · destructive migration · cross-module architectural change
            security-sensitive redesign · new external dependency
```

**The one that bites:** if `tools:` is omitted, Copilot custom agents get **all tools**. Name
them explicitly. And remember the agent's *description* is Layer 3 — only the tool list
constrains.

## Predict before you run

<!-- TODO: the gate below asks specifically whether the diff became more
     focused. Predict that number before measuring it. -->

## Lab B4.1 — measure against B3

<!-- TODO: 3 comparisons vs B3. -->

## Deliberate failure

<!-- TODO: omit the tool list and see what the agent reaches for.
     Then try to talk it past a Prohibited item using only prose —
     that is the Layer 2 vs Layer 3 demonstration. -->

## Exit gate

**From the build track:** 3 comparisons vs B3 · record specifically whether the **diff became
more focused**, since scope discipline is what a boundary buys.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
