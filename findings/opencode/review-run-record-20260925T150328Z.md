# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260925T150328Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        d984799
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template's core recording fields (approvals, cost, acceptanceScore/finalScore) admit multiple valid readings, so two reviewers filling the same run produce different records; and no field carries the rubric version sha, so cross-run score comparisons silently conflate rubric revisions.
  blocking:
    - reason: The `approvals` field is a single scalar but the comment says it should capture both "permission requests" and "whether anyone could answer" — two reviewers can record the same run as `approvals: 3` (requests made) or `approvals: 0` (requests answered), and the template provides no structure to distinguish.
      wrong_action: A reviewer records `approvals` as the count of requests made; downstream analysis cannot tell a run that was blocked by unanswered permissions from one that proceeded cleanly.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: The `cost` field reuses the {value, source, estimated} structure defined for token counts but inherits none of the unit constraint — `value` could be 0.42 (dollars) or 42 (cents) and both pass validation, while the Level A/B/C provenance described in the comment ("provider reported", "local tokenizer guessed", "nobody knows") is token-flavoured, not cost-flavoured, where the Levels should be "billed by provider" vs "computed from tokens × pricing."
      wrong_action: A reviewer records cost in dollars, another in cents; downstream cost analysis sees a 100x discrepancy that looks like real variation but is unit confusion.
      anchor: "cost:                { value: null, source: null, estimated: null }"
      evidence: templates/run-record.yaml:65
    - reason: `acceptanceScore` and `finalScore` are entirely unscoped — no type, no scale, no comment, and no stated relationship to the acceptance gate or the rubric. CLAUDE.md describes both a gate (pass/fail) and a rubric (4 categories, 100 points) but the fields carry neither type nor range, so two reviewers can swap which field carries the gate verdict vs the rubric score.
      wrong_action: Reviewer A records `acceptanceScore: pass, finalScore: 3`; Reviewer B records `acceptanceScore: 3, finalScore: 4`; downstream analysis reading `finalScore` across runs sees mixed strings, booleans, and numbers in one column with no way to distinguish them.
      anchor: "acceptanceScore:"
      evidence: templates/run-record.yaml:71
    - reason: The record carries `task.benchmarkSha` (the task/evaluator commit) but no `rubricSha` — the rubric is versioned independently per CLAUDE.md (`backend-quality.yaml ... sha 396e1799eb2b`), and a rubric change between runs would silently invalidate cross-run score comparisons.
      wrong_action: An analyst compares `finalScore` across two runs scored under different rubric revisions and reports a regression or improvement that is actually a rubric change.
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
  non_blocking:
    - reason: `evaluation.compile`, `evaluation.tests`, `evaluation.hiddenTests` carry no comment and no defined type — could be filled as exit codes (0/1), booleans (pass/fail), or counts (failures), with no way to tell which.
      evidence: templates/run-record.yaml:68-70
    - reason: `evaluation.failureClass` references the F01-F15 taxonomy without defining it in the template; a reviewer filling the field needs external knowledge to pick a valid code.
      evidence: templates/run-record.yaml:73
    - reason: `behavior.commands` and `behavior.compactions` carry no comment or shape — array elements could be command names or full command strings, and "compactions" is undefined.
      evidence: templates/run-record.yaml:43,46
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 80s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### behavior
**Verdict:** finding
**Failure:** A run in `permissionMode: default` where the operator stepped away mid-run. The agent made 3 permission requests, all unanswered, and the run stalled. Reviewer A records `approvals: 3` (counting requests made). Reviewer B records `approvals: 0` (counting requests answered). Same run, two valid readings of the same field, and downstream analysis cannot distinguish a run that was blocked by unanswered permissions from one that proceeded cleanly. The comment instructs the recorder to capture "whether anyone could answer" but the template provides no field for it — `environment.permissionMode` records the mode, not human presence.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** A run costs $0.42 as billed by the provider. Reviewer A records `cost: { value: 0.42, source: provider, estimated: false }` (dollars). Reviewer B records `cost: { value: 42, source: provider, estimated: false }` (cents). Both pass `validate-run-record.sh` — both carry full provenance, neither is a bare number. A downstream cost comparison across runs sees a 100x discrepancy and cannot detect it. The Level A/B/C provenance scheme is defined for token counts (provider-reported vs local-tokenizer-guessed vs unknown); it does not map to cost, where the provenance question is "billed by provider" vs "computed from tokens × pricing," not "reported vs guessed." The same `{ value, source, estimated }` structure carries different semantics for `cost` than for the four token fields above it, and nothing in the template says so.
**Layer of the implied fix:** L3
**Anchor:** `cost:                { value: null, source: null, estimated: null }`

### evaluation
**Verdict:** finding
**Failure:** A run passes the acceptance gate (opencode review returns "pass") and scores 3 out of 4 on the rubric. Reviewer A records `acceptanceScore: pass, finalScore: 3` (acceptance = gate verdict, final = rubric score). Reviewer B records `acceptanceScore: 3, finalScore: 4` (acceptance = rubric score, final = rubric maximum). Same run, same inputs, mixed types land in the same fields. Neither field has a defined scale, type, or relationship to the gate/rubric system the CLAUDE.md describes. A downstream analysis reading `finalScore` across runs gets numbers, booleans, and strings in the same column with no way to tell which is which.
**Layer of the implied fix:** L3
**Anchor:** `acceptanceScore:` and `finalScore:`

### measurement
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? `evaluation.acceptanceScore` records the acceptance gate's result, and `compile`/`tests`/`hiddenTests` record the evaluator gate's results. In the run record this is recording, not duplicating — the record is the evidence sink. No duplication. The risk is the inverse: `acceptanceScore` is so underspecified that a reviewer might put the rubric score there instead of the gate verdict, silently turning a gate recording into a score recording.
- `evaluation` — two reviewers would diverge most, by a full type swap. The score fields have no scale, no type, and no stated relationship to the gate/rubric split the rest of the lab depends on. Every other section's fields are either self-evident (counts, durations) or carry inline guidance specific enough to act on (the Level A/B/C block, the `telemetryComplete` note). `evaluation` has five blank fields and one comment (`failureClass: # F01-F15`) that references an external taxonomy without defining it.
- What the artifact did not say: which rubric and which gate produced the `evaluation` fields. The `task` block records `id` and `benchmarkSha` but nothing links a run record to the rubric version that scored it. The CLAUDE.md tracks rubric revisions by sha (`396e1799eb2b`); the run record has no field to carry that sha, so two runs scored under different rubric versions are indistinguishable in the record.
