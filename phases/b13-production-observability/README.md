# B13 — Production observability and the promotion gate

**Track A first:** [Phase 10](../10-production-observability/)
**Version:** — (closes the track)
**Spine position:** 28 of 28 · after [B12](../b12-governed-self-learning/) · **end of the spine**
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b13).
> Everything else is yours to fill.

---

## Goal

<!-- TODO -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §17   initial promotion rules
     BUSINESS-REQUIREMENTS §13.7 derived metrics
     BUSINESS-REQUIREMENTS NFR-008 low-cardinality metrics
     BUSINESS-REQUIREMENTS Risk: metrics become developer surveillance
     BUSINESS-REQUIREMENTS Risk: sensitive code enters external telemetry
     BUSINESS-REQUIREMENTS §24   definition of done -->

### External — the technique

<!-- TODO -->

## Extract

<!-- TODO. Two constraints belong here and they pull in opposite
     directions: measure enough to decide, and never measure individual
     employee productivity. Quote both. -->

## Build

**Build:** the decision layer.

```
JSONL → Markdown/CSV comparison → OpenTelemetry → Prometheus → Grafana
```

**In that order.** Both business-case documents say do not start with Grafana; you already
did, and both documents were right. Local artifacts first, dashboards only when enough runs
exist to make one meaningful.

**Promotion gate** — a configuration becomes the default only when all seven hold:

1. deterministic checks do not regress
2. benchmark quality improves or stays within approved tolerance
3. safety guardrails do not regress
4. cost increase is justified
5. enough repetitions exist
6. a human reviewed the qualitative diff
7. **rollback is defined**

```yaml
successful_run_rate:      { minimum: 0.80 }
quality_score:            { minimum: 80 }
critical_findings:        { maximum: 0 }
forbidden_changes:        { maximum: 0 }
first_pass_success:       { must_not_decrease: true }
human_review_minutes:     { must_not_increase: true }
tokens_per_accepted_task: { maximum_allowed_increase: 0.15 }
```

## Predict before you run

<!-- TODO -->

## Lab B13.1 — run the gate against every version you built

<!-- TODO: v1.0, v1.1, v1.2, v1.3 through the same seven conditions.
     The answer to the business question is whatever this table says. -->

## Deliberate failure

<!-- TODO: feed the gate a version that improves cost and regresses
     quality. Confirm it refuses. -->

## Exit gate

**From the build track:** the seven promotion conditions are implemented and a version has been
evaluated against all of them.

**Plus, for this to count as a learned phase:**

<!-- TODO: answer the question from BUSINESS-REQUIREMENTS §1 in one
     paragraph, with the evidence. That is what the whole track was for. -->

## Commit

<!-- TODO -->
