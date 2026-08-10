# B11 — Efficiency

**Track A first:** [Phase 6B](../06b-knowledge-retrieval/) + [Phase 10](../10-production-observability/)
**Version:** **v1.2 closes here**
**Spine position:** 26 of 28 · after [Phase 10](../10-production-observability/) · before [B12](../b12-governed-self-learning/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b11).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.5 core/context-policy.md
     BUSINESS-REQUIREMENTS §13.4 token and context metrics
     BUSINESS-REQUIREMENTS P1    correctness before token optimization
     BUSINESS-REQUIREMENTS Risk: optimizing for tokens instead of outcomes
     EFFICIENCY-SELF-LEARNING §  v1.2 efficiency and context optimization -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO -->

## Build

**Only after correctness is stable.** Efficiency work on an incorrect agent optimises the
wrong thing.

**Build, in this order:**

1. **Task classifier** — API / JPA / Kafka / cache / security / build / test-only / migration.
   Output drives what loads.
2. **Retrieval budget** — `max_similar_implementations: 2`, `max_initial_searches: 5`,
   `max_files_before_design: 15`, `max_full_log_lines: 0`. Exceeding requires a recorded reason.
3. **File-summary cache** keyed on `sha256` — reuse only on hash match; **never trust a stale
   summary.**
4. **Verification planner** — smallest safe sequence for the change type. Final independent
   verification stays unchanged.
5. **Command deduplication** against the current code fingerprint.

## Predict before you run

<!-- TODO: predict the saving per mechanism, separately, before building
     all five. The gate is all-or-nothing, so a mechanism that costs more
     than it saves will hide inside the aggregate unless you predicted it. -->

## Lab B11.1 — measure against v1.1

<!-- TODO: seven conditions, all must hold. Note that the cache-creation
     finding from EXP-BE002-CLAUDEMD-V2 is directly relevant: carrying a
     context file cost ~5,300 cache-creation tokens, but roughly two
     thirds of the premium was the extra *work* prescribed, not the
     context occupied. Shrinking context may not recover what you expect. -->

## Deliberate failure

<!-- TODO: feed the file-summary cache a stale entry and confirm the hash
     check refuses it. -->

## Exit gate

**From the build track — all must hold vs v1.1:** same or better acceptance · same hidden-test
success · fewer repeated reads · fewer unnecessary tool calls · lower median input tokens ·
lower median time-to-green · **no increase in material review corrections.**

> Efficiency improvements are rejected when quality declines. No exceptions.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
