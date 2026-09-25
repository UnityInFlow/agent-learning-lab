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
reviewed_utc:    20260925T083227Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        e0f2fb7
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Three template fields lack the shape or vocabulary the schema needs to enforce (a scalar with a comment demanding an object; five evaluation scalars with no type hint and no role separation; a controlled vocabulary referenced but not provided), so two faithful reviewers will produce structurally incompatible records and the cross-run comparison the template exists to support fails on the data side.
  blocking:
    - reason: The `approvals` field is a blank scalar but its inline comment names two dimensions ("permission requests — and whether anyone could answer"). Reviewers will record scalar counts and `{requests, answered}` objects interchangeably.
      wrong_action: A reader aggregating approvals across runs gets parse errors whenever a record uses the object form while the aggregator expects a scalar (or vice versa); the per-run approval-rate view is unrunnable without an undocumented fix-up step no downstream tool owns.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: `compile`, `tests`, `hiddenTests`, `acceptanceScore`, and `finalScore` are blank scalars with no type hint and no comment distinguishing `acceptanceScore` from `finalScore`. Reviewers will record booleans, integers, and strings interchangeably for the same field, and will assign the two score fields to different roles.
      wrong_action: A reader averaging `tests` across runs gets a mix of pass/fail booleans and integer counts that mean different things; a reader computing the experiment's headline number cannot tell whether `finalScore` is meant to equal, override, or complement `acceptanceScore`.
      anchor: "  acceptanceScore:"
      evidence: templates/run-record.yaml:68-74
    - reason: `exclusionReason` is annotated "structured, registered in advance" but the controlled vocabulary the comment references is not included in the artifact; reviewers cannot look up valid codes from this template.
      wrong_action: Two reviewers excluding runs for the same root cause name it differently (one writes `harness-bug-7`, another writes `{ code: HARNESS_BUG_7, registeredAt: ... }`); an exclusion-rate analysis cannot group them.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
  non_blocking:
    - reason: The `behavior` section uses explicit empty-list defaults (`toolsUsed: []`, `filesChanged: []`, `commands: []`) for some fields and blank scalars (`modelCalls`, `toolCalls`, `filesRead`, `retries`, `compactions`) for siblings of the same shape. A reader cannot tell whether a blank field expects an integer or a list. Worth fixing for consistency; resolves naturally once the blocking fields get explicit shape annotations.
      evidence: templates/run-record.yaml:38-46
    - reason: The failure-class range `F01-F15` is named in a comment but not defined; reviewers need an external document. Acceptable if the taxonomy is registered elsewhere and reviewers are pointed to it; otherwise, surface the definitions next to the field.
      evidence: templates/run-record.yaml:73
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 128s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| behavior | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
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
**Failure:** A non-interactive run produces 3 permission requests, none answered. Reviewer A writes `approvals: 3`. Reviewer B writes `approvals: { requests: 3, answered: 0 }`. The comment demands both dimensions ("permission requests — and whether anyone could answer"); the field is a single blank scalar. The two records are structurally incompatible — downstream tooling that reads `approvals` as a count breaks on the object form, and tooling that reads it as an object breaks on the scalar. Separately, the section mixes explicit list defaults (`toolsUsed: []`, `commands: []`, `filesChanged: []`) with blank scalars for structurally identical concepts (`filesRead`, `modelCalls`, `toolCalls`, `retries`, `compactions`). Reviewer A writes `filesRead: 5` (count); Reviewer B writes `filesRead: [foo.kt, bar.kt, ...]` (list). Both are faithful readings of a blank field whose siblings are lists.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `compile`, `tests`, and `hiddenTests` are blank scalars with no type annotation. Reviewer A writes `compile: true` (boolean pass/fail). Reviewer B writes `compile: 0` (error count). Reviewer C writes `compile: "success"` (string status). A cross-run analysis that averages `tests` values gets numbers from some runs and booleans from others. Separately, `acceptanceScore` and `finalScore` are both blank scalars with no comment distinguishing them. Reviewer A puts the evaluator's verdict in `acceptanceScore` and leaves `finalScore` blank; Reviewer B does the reverse; Reviewer C puts the same number in both. The records disagree on which field carries the experiment's score, and a downstream consumer cannot tell which is authoritative.
**Layer of the implied fix:** L3
**Anchor:** `compile:` / `acceptanceScore:` / `finalScore:`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is a blank scalar, but the comment says "structured, registered in advance." Reviewer A writes `exclusionReason: harness-bug-7` (a string). Reviewer B writes `exclusionReason: { code: HARNESS_BUG_7, registeredAt: 2026-09-01 }` (an object). The "registered in advance" requirement implies a controlled vocabulary that the template does not provide — a reviewer cannot look up what the pre-registered reasons are from this artifact, so two reviewers facing the same exclusion will name it differently. Additionally, the template permits `status: excluded` with a blank `exclusionReason` — a run is marked excluded with no reason recorded, and nothing in the template's structure rejects that combination.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The `evaluation` section carries `compile`, `tests`, and `hiddenTests`, which read as gate results. If the run record is only ever used for gate-passing submissions (as the rubric is), these fields are constants — the same shape of defect that killed the seven-category rubric. The template does not say whether it records gate-failing runs too, so a reader cannot tell whether these fields carry information or are always-true.
- **Which section would two reviewers diverge on most?** `behavior`, by the widest margin. Five fields are blank scalars whose siblings are explicit lists; one field (`approvals`) has a comment demanding two dimensions in a single scalar. Every reviewer must guess a shape, and the guesses will not agree.
- **What did the artifact not say that it needed to say?** The failure taxonomy `F01-F15` is named but never defined — a reviewer cannot classify a failure without an external document the template does not reference. The distinction between `acceptanceScore` and `finalScore` is unstated. The field types for `compile`, `tests`, and `hiddenTests` (boolean, count, or string) are unstated. The "registered in advance" vocabulary for `exclusionReason` is referenced but not included.
