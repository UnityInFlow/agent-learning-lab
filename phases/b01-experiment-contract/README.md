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
../agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/
                                 the task, acceptance criteria, forbidden changes,
                                 evaluator.sh, and eight fixtures — lives in the
                                 benchmarks repo, not here
benchmark/rubrics/backend-quality.yaml
                                 0–2 per category, weighted, normalized 0–100
templates/run-record.yaml        every field, and whether it is exact/estimated/absent
```

> **The task moved.** It is `tasks/BE-003-confirm-shipment/` in
> [agent-observatory-benchmarks](https://github.com/UnityInFlow/agent-observatory-benchmarks),
> merged in benchmarks#9 and #10, because the evaluator that reads it has to run beside the
> service under test. Nothing named `benchmark/tasks/` or `runs/` exists in this repo.

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

> **The score half of that table is superseded.** Applied to BE-003 it failed twice over:
> `functional-correctness` (25) and `requirement-completeness` (20) restate the gates, so they
> are constant across every submission the rubric is allowed to score, and `test-quality` (15)
> had no fixture with tests. Sixty percent of the weight carried no information. The
> replacement is four categories — architecture-consistency 35, maintainability 25,
> test-quality 25, change-focus 15 — anchored on differences observable *between fixture
> pairs*. Written in #21. The gates on the left are unchanged and still own correctness.

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

The shape lives in `templates/run-record.yaml`, and on its own it is **Layer 3** — a template
constrains nothing, and `inputTokens: 12400` stays perfectly writable. `tools/validate-run-record.sh`
is the Layer 2 version: it executes, it rejects a bare number, and CI runs it on every PR.
`tools/verify-run-record-validator.sh` registers eleven fixtures with the exit code each must
produce, because a control that has never been shown to reject anything is indistinguishable
from one that rejects nothing.

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

**From the build track:** one task repeats · one run record completes **and validates** ·
one quality score computes.

- [x] `./tools/verify-run-record-validator.sh` exits 0 — the provenance rule executes
- [ ] ~~The four-category rubric scores all five gate-passing fixtures without emitting `null`~~
      **Unreachable as written, found 2026-08-27.** `test-quality` carries 25% of the weight
      and three of the five variants submitted no test file, so Decision A nulls those three
      cells before any anchor is read. The corrected gate: **the rubric emits no *defect*
      null across the 17 cells where a score was possible**, with the 3 structural nulls
      predicted in advance and reported separately. That 25%-of-the-weight-on-2-of-5 problem
      is itself an input to lab#21, not something this gate can absorb
- [ ] Your blind scores and the second scorer's, compared, with the gap recorded
- [ ] `./tools/verify-score-output-classifier.sh` exits 0 — a run that found something is
      not discarded as a crash. Added 2026-08-27; the guard it replaced returned one code
      for five outcomes

**The population is five, not six.** `known-good` is the baseline attached to every run since
Decision B was built, not a submission — so the grid is 4 categories × 5 variants = **20
cells**, and discrimination is a comparison *among the five*, all scored under identical
conditions. Scoring `known-good` was only needed while that comparison had to happen between
sheets. Two of its four cells were structural nulls and the other two would have been the
grid's only one-tree cells. Derived from the fixture grid by Claude at the user's request;
the superseded six-cell reasoning is kept in `experiments/E-001-rubric-null-rate.md`.

**Decided 2026-08-27, before the rubric was written:**

1. **Anchors are source-decidable only.** The scorer receives changed source files and
   nothing else, so every anchor must be citable at `path:line` from those files alone.
   `functional-correctness` and `requirement-completeness` are dropped — the gates own them,
   and restating a gate produces a constant across everything the rubric is allowed to score.
   The alternatives — feeding the scorer evaluator output, or routing per category — were
   rejected: the first makes the scorer share an input with the gate it is supposed to be
   orthogonal to, the second is two instruments to keep in sync.
2. **The run record ships with its own validator.** B1 does not wait on
   UnityInFlow/agent-observatory#53 and does not close with an L3 control either.

**Plus, for this to count as a learned phase:**

<!-- TODO: the measured claim. What evidence shows the contract is stable? -->

## Commit

<!-- TODO -->
