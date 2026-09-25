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
reviewed_utc:    20260925T183734Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        2a32e0a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template's comments warn against three failure modes (a gap reading as a zero, an ambiguous scalar masking a second dimension, a wall-clock the runner "always knows" silently turning null), but its structure — bare fields, default `false`, default `null`, default `[]` — produces exactly those failure modes. It claims L2-style safety and delivers L3.
  blocking:
    - reason: The `approvals` comment names two dimensions ("permission requests — and whether anyone could answer") and the field is a bare scalar, so two reviewers of the same run can both write `approvals: 3` while disagreeing on what 3 means (3 answered vs 3 unanswered); downstream aggregation cannot recover the dimension the comment promises is captured.
      wrong_action: A reader comparing two runs treats one with 3 answered permission prompts and another with 3 unanswered prompts as identical — the dimension the comment names has no field to live in.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: `durationMs` is the one field whose comment asserts universal availability ("The runner always knows this one"), but the template's own L3 note (line 60) names only the token fields as gated by `validate-run-record.sh`; a `durationMs: null` therefore passes, and downstream readers cannot tell "run invalid, exclude" from "wall-clock not recorded by this harness."
      wrong_action: A reader records a run on a harness that does not report wall clock; the null fields silently while the comment promised they could not; downstream either excludes a run whose duration is genuinely unknown, or admits one it should have excluded — the consumer's choice, not the template's enforcement.
      anchor: "durationMs:              # wall clock. The runner always knows this one."
      evidence: templates/run-record.yaml:49
    - reason: `telemetryComplete` defaults to null and the comment names the exact hazard it creates ("a gap must not read as a zero"); the template cites no validator that enforces a boolean here, so a run whose operator forgot to flip the field after a successful telemetry capture is downstream-indistinguishable from one with genuinely missing telemetry, and `if record.measurement.telemetryComplete` evaluates null as false, excluding the very runs the comment says must not be excluded.
      wrong_action: A reader completes a fully captured run and forgets to set `telemetryComplete: true`; downstream code treats the run as telemetry-incomplete and excludes it — the precise failure mode the comment warns against, enabled by the structure.
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:79
  non_blocking:
    - reason: `cost` carries a structured `{value, source, estimated}` block (matching the other token fields) but no currency field, so a USD `0.42` and a EUR `0.42` from two reviewers sum as if same-unit; same defect shape as `approvals` in efficiency form.
      evidence: templates/run-record.yaml:65
    - reason: `filesRead:` has no default while the sibling `filesChanged: []` defaults to a list, so `filesRead: 5` (count) and `filesRead: [path, ...]` (list) both parse; the asymmetry is not a finding in either direction alone, only when paired with `filesChanged` whose type is locked.
      evidence: templates/run-record.yaml:41-42
    - reason: `instructionsProvenLoaded: false` defaults to the assertion's negative — distinct from the null default of `telemetryComplete` but producing the same null/false-reads-as-zero failure (operator forgot to flip after a passing preflight reads as "instructions NOT proven loaded").
      evidence: templates/run-record.yaml:31
  disputed: []
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
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

runId
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
**Failure:** Two runs, identical behavior: three permission prompts, all answered in Run A; three permission prompts, none answerable in Run B (unattended session, no human present). Reviewer 1 records both as `approvals: 3`. Reviewer 2 records Run A as `approvals: 3` and Run B as `approvals: { requested: 3, answered: 0 }`. Downstream analysis comparing the two runs cannot distinguish "3 answered" from "3 unanswered" when the field is a scalar — the dimension the comment names ("whether anyone could answer") has no field to live in. Separately, `filesRead:` is a bare scalar while `filesChanged: []` defaults to a list. Reviewer 1 fills `filesRead: 5` (a count); Reviewer 2 fills `filesRead: ["src/main.py", ...]` (a list). Code expecting one shape breaks on the other.
**Layer of the implied fix:** L3 — the template is a YAML file with comments; nothing executes to reject a scalar where a structured object was intended, or a number where a list was intended. Making `approvals` a structured block like the token fields would still be L3 unless `validate-run-record.sh` also checked its shape.
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** `durationMs` is a bare scalar with no provenance block, while every token field carries `{ value, source, estimated }`. The comment says "The runner always knows this one," but a runner that crashes mid-run, or a harness that does not report wall-clock (a different harness from the one the comment was written for), leaves `durationMs:` null. The comment on the token fields says `validate-run-record.sh` rejects bare numbers for those fields — it says nothing about rejecting a null `durationMs`. So a null `durationMs` passes the validator and is indistinguishable from "not recorded" downstream. Two reviewers diverge: one treats the null as "run invalid, exclude"; the other treats it as "value missing, keep run." Additionally, `cost: { value: null, source: null, estimated: null }` has no currency field. Reviewer 1 records `cost: { value: 0.42, source: provider, estimated: false }` in USD; Reviewer 2 records the same run in EUR. A cross-run comparison sums them as if same-unit.
**Layer of the implied fix:** L3 — adding a provenance block or a currency field to the template changes nothing until a validator rejects the absence. The existing validator (per the comment) only gates the token fields.
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### measurement
**Verdict:** finding
**Failure:** An operator completes a run with full telemetry but forgets to set `telemetryComplete: true`. The field stays null (YAML default for an unset value). The comment says "a gap must not read as a zero," but in YAML null is falsy: any downstream code that does `if record.measurement.telemetryComplete` evaluates null as false, marking the run as telemetry-incomplete. The run is excluded from analysis. The comment names the hazard ("a gap must not read as a zero") but the structure produces exactly the hazard it warns against — an unset boolean reads as false, which reads as zero, which reads as "telemetry incomplete." Nothing in the template or (per the artifact's own comments) in the validator prevents this.
**Layer of the implied fix:** L3 — the comment is guidance a human must remember. A schema requiring a non-null boolean would be L1, but YAML has no schema enforcement; only a validator that rejects null for this field would be L2, and the artifact does not name one that checks it.
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? This is a record template, not a rubric, so there are no scoring categories. `evaluation.failureClass` (F01–F15) and `measurement.status` (valid/excluded/pilot/invalidated) are adjacent and could overlap — a failure class like F15 might imply invalidation — but they serve different purposes (root-cause classification vs. measurement eligibility), so this is not a duplication.
- Which single section would two reviewers diverge on most, and by how much? **behavior**, by a wide margin. The `approvals` comment names two dimensions but the field holds one value, and `filesRead` vs `filesChanged: []` sets up a scalar/list asymmetry with no disambiguating rule. Two faithful reviewers could produce structurally different records for the same run and both believe they followed the template.
- What did the artifact not say that it needed to say? The type (count vs. list) of six scalar fields in `behavior` (`modelCalls`, `toolCalls`, `filesRead`, `retries`, `approvals`, `compactions`); the currency unit for `cost`; and what should happen when `durationMs` — the one field claimed to be always known — is not known.
