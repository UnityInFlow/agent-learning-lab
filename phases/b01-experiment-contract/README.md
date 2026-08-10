# B1 — Experiment contract

**Track A first:** [Phase 0B](../00b-observatory/)
**Version:** — (pre-v1.0)
**Spine position:** 3 of 28 · after [0B](../00b-observatory/) · before [B2](../b02-plain-baseline/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b1).
> Everything else is yours to fill.

---

## Goal

<!-- TODO: what can be done after this step that could not be done before it.
     One sentence. Not "write three files" — what capability appears. -->

## Required reading

### Internal — the requirement

<!-- TODO: cite by section, not URL. Candidates for this step:
     BUSINESS-REQUIREMENTS §13.1 mandatory quality gates
     BUSINESS-REQUIREMENTS §13.2 quality score
     BUSINESS-REQUIREMENTS §14   token measurement levels A/B/C
     BUSINESS-REQUIREMENTS §15   provider-neutral run record
     BUSINESS-REQUIREMENTS §18   first benchmark task
     BUSINESS-REQUIREMENTS P7    unknown data remains unknown
     Bring a question to each, the way Track A does. -->

### External — the technique

<!-- TODO: verified links. Add them to ../../SOURCES.md as you go
     so tools/check-links.sh covers them before the next cohort. -->

## Extract

<!-- TODO: the passage that constrains this build, quoted verbatim, with
     what it forbids. Track A's extracts are the model. -->

## Build

**Build:** a task, a rubric, a run record. Nothing agent-related.

**Why first:** without a stable task and a stable way to record a run, every later comparison
is an opinion. Your own doc: *"Do not create the backend agent yet."*

**Files**

```
benchmark/tasks/BE-003-confirm-shipment.md   the task, acceptance criteria, forbidden changes
benchmark/rubrics/backend-quality.yaml        0–2 per category, weighted, normalized 0–100
runs/run-template.yaml                        every field, and whether it is exact/estimated/absent
```

**The task.** `confirm-shipment` — `POST /shipments/{id}/confirm`, validate state, idempotent
on repeat, persist `CONFIRMED`, correct status codes, unit + integration tests, no new
dependency, no unrelated refactoring. It exercises REST design, service logic, persistence,
transactions, state validation, idempotency, error handling and testing in one task.

**Two gates, never merged**

```
Quality gates (pass/fail)        Quality score (0–100, weighted)
build passed                     functional correctness   25%
required tests passed            requirement completeness 20%
acceptance criteria 100%         architecture consistency 15%
forbidden changes = 0            test quality             15%
critical findings = 0            error handling           10%
                                 maintainability          10%
                                 change focus              5%
```

> **A run that fails a gate is unsuccessful even when it used fewer tokens.** Compare
> efficiency only among runs that passed. This is the single most important rule in the
> business case and your analyzer does not yet implement it.

**Token honesty.** Every usage value carries its provenance:

```yaml
input_tokens: { value: 12400, source: provider,        estimated: false }   # Level A
input_tokens: { value: 11950, source: local-tokenizer, estimated: true  }   # Level B
input_tokens: { value: null,  source: null,            estimated: null  }   # Level C — record proxies
```

> **Unknown data remains unknown.** `null`, never a plausible number. A gap that reads as a
> zero is how `BehaviorDto` currently lies to you.

## Predict before you run

<!-- TODO: write these in ../../templates/experiment.md BEFORE building.
     B1 builds no agent, so predict about the instrument itself:
     what will the rubric disagree with you about, where will Level C bite. -->

## Lab B1.1 — the contract repeats

<!-- TODO: B1 has no previous version to measure against — it is the
     measuring apparatus. So the lab is a self-test: does the same task,
     scored twice, produce the same score? If not, the rubric is the
     variable and nothing downstream is interpretable. -->

## Deliberate failure

<!-- TODO: break it on purpose and prove the break is visible.
     e.g. submit a run that fails a gate but uses fewer tokens —
     does your record make the right call obvious? -->

## Exit gate

**From the build track:** one task repeats · one run record completes · one quality score computes.

**Plus, for this to count as a learned phase:**

<!-- TODO: the measured claim. What evidence shows the contract is stable? -->

## Commit

<!-- TODO -->
