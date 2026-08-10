# B9 — Knowledge router and hit rate

**Track A first:** [Phase 6A](../06a-code-intelligence/) + [Phase 6B](../06b-knowledge-retrieval/) · **Layer 3 — untrusted**
**Version:** **v1.2**
**Spine position:** 20 of 28 · after [Phase 6B](../06b-knowledge-retrieval/) · before [B10](../b10-second-runtime-adapter/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b9).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §10.9 knowledge/index.yaml
     BUSINESS-REQUIREMENTS FR-009 progressive context loading
     BUSINESS-REQUIREMENTS FR-010 no-reread preference
     Source principle 8: index, summary, then full document -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. 6B's write path is gated by Phase 9 — reading a curated corpus
     is retrieval, a corpus the agent writes to is self-learning. Keep
     that boundary in the extract. -->

## Build

**Build:** `knowledge/index.yaml` — triggers → summary → full document. **Not a vector DB.**

```yaml
topics:
  spring-transactions:
    triggers: [transactional, rollback, multiple repositories]
    summary: summaries/spring-transactions.md
    details: documents/spring-transactions-deep-dive.md
```

**Then instrument it:**

```
knowledge_hit_rate = useful knowledge matches / knowledge lookups
```

That number is what later justifies — or refuses — embeddings. Without it you can prove RAG
*ran*, not that it *helped*.

**Do not build a code or symbol index.** memtrace already provides `find_symbol`,
`find_code`, the AST graph and Cortex decision memory, and you pay for it every session.
Building vector search over your own repository duplicates a tool you already run. See
[Phase 9 — Architecture](../09-memory/README.md#architecture-you-already-run-three-memory-systems).

## Predict before you run

<!-- TODO: predict the hit rate before measuring it. A low hit rate is a
     result, not a failure — it is the evidence that refuses embeddings. -->

## Lab B9.1 — measure against B8 (v1.1)

<!-- TODO: context metrics are the comparison, not just quality. -->

## Deliberate failure

<!-- TODO: put a wrong summary in the index and see whether the agent
     trusts it. This is the Layer 3 untrusted demonstration — retrieved
     text is input, and input can be wrong or hostile. -->

## Exit gate

**From the build track:** retrieval order recorded per run (index → summary → full) · hit rate
measured · context metrics compared against B8.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
