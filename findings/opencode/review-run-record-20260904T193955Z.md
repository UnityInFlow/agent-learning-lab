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
reviewed_utc:    20260904T193955Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        03496ca
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The efficiency section's documented three-level provenance model has a fourth representable state (value present, source null) that the only declared L2 control does not catch, and behavior.approvals carries no type so two readers can produce structurally different records for the same behavior.
  blocking:
    - reason: The efficiency section documents three provenance levels (A: provider, B: local-tokenizer, C: null/null/null), but the schema permits a fourth state — value present with source null — that violates the model. The only declared L2 control ("rejects a bare number") catches a scalar in the field but not a structured object with null provenance, so this state passes validation.
      wrong_action: A reader fills `inputTokens: {value: 12400, source: null, estimated: null}`. Downstream analysis that filters on `source: provider` drops the record; analysis that filters on `value != null` keeps it. Two readers aggregate the same dataset and report different totals, with no record-level signal that the value is unclassifiable.
      anchor: "#   { value: null,  source: null,            estimated: null  }   # Level C"
      evidence: templates/run-record.yaml:54-65
    - reason: The behavior.approvals field has no type. The comment names two concepts ("permission requests" and "whether anyone could answer") but gives neither a structure, so the field is open to multiple interpretations.
      wrong_action: Reader A writes `approvals: 3` (count of requests), reader B writes `approvals: [{tool: edit, granted: false}]` (a list), reader C writes `approvals: {requested: 3, answered: 0}` (a structured object). Three runs with identical behavior produce three structurally different records, and downstream aggregation cannot combine them without first guessing each schema.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
  non_blocking:
    - reason: task.benchmarkSha is documented as "the commit the task/evaluator were resolved from" but the template does not state whether the validator rejects an empty value. A run with empty benchmarkSha would compare against runs from a different evaluator commit. The template is honest (line 60) that this block is L3 guidance, so the reader knows enforcement is not claimed.
      evidence: templates/run-record.yaml:6
    - reason: model.requested vs model.resolved carries the warning "An alias can silently re-point between runs" but no structural control enforces it. A run with empty resolved leaves the re-pointing undetectable. Same L3 framing as benchmarkSha.
      evidence: templates/run-record.yaml:16
    - reason: environment.fingerprint carries "arms must match" — strong language that implies a cross-record comparison, but no validator or script is named. Cross-record checks are out of scope for a single-record template; the comment documents intent without naming an executing control.
      evidence: templates/run-record.yaml:26
    - reason: evaluation.failureClass is documented as "F01-F15" but a run with F16 or a free-text label is representable. Real concern; non-blocking because the comment is descriptive, not enforced.
      evidence: templates/run-record.yaml:73
    - reason: measurement.telemetryComplete ("a gap must not read as a zero") and measurement.status ("valid / excluded / pilot / invalidated") have no types. Reader A writes a boolean, reader B writes a fraction, reader C writes a list — the same shape disagreement as approvals, but lower centrality to the experiment.
      evidence: templates/run-record.yaml:77-79
    - reason: Cross-cutting — the template declares L2/L3 status for the efficiency block (line 60) and is silent on every other field's enforcement level. A reader cannot tell from the template alone which comments are enforced and which are guidance.
      evidence: templates/run-record.yaml:60
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 84s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| task | 1/1 | L2 |
| model | 1/1 | L2 |
| environment | 1/1 | L2 |
| behavior | 1/1 | L1 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L2 |
| measurement | 1/1 | L1 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** finding
**Failure:** Two runs both carry `id: BE-001`, `revision: 1`. Run A filled `benchmarkSha` with the commit it resolved the task from; run B left it empty. A downstream comparison treats them as the same task against the same evaluator. If the benchmark changed between those commits — a revised evaluator, a different fixture set — the comparison is invalid, and nothing in the template flags the empty field as a problem. The comment on line 6 calls benchmarkSha "the commit the task/evaluator were resolved from," implying it is load-bearing for comparability, but the template does not state whether the validator rejects an empty value or whether the field is optional.
**Layer of the implied fix:** L2 (a validator that exits non-zero on empty benchmarkSha) — or L3 if the intent is guidance only, in which case the comment overstates the field's role.
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** The comment on line 16 identifies a real risk: "An alias can silently re-point between runs." The scenario is exactly the one described — `requested: haiku` resolves to `claude-haiku-4-5-20251001` in run A and to a different model under the same alias in run B. The template's only control against this is the presence of the `resolved` field. But `resolved` is empty in the template, and nothing states that the validator rejects a record where `resolved` is blank while `requested` is filled. If a run leaves `resolved` empty, the alias-re-pointing risk the comment warns about is undetectable after the fact. The comment identifies the defect; the template provides no structural or enforced control against it.
**Layer of the implied fix:** L2 (validator rejects `requested` present + `resolved` empty) — currently L3, a warning a human may or may not act on.
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** Line 26 says `fingerprint:             # hash of the above; arms must match`. "Arms must match" asserts a comparison control — that in a multi-arm experiment, the environment fingerprints of the arms are checked against each other. But the template provides no mechanism for this. The fingerprint field is a single scalar on a single run record. A reader filling in two run records (one per arm) writes a fingerprint into each; nothing in the template or its comments says what executes the comparison, what happens on mismatch, or whether the validator performs it. The scenario: arm A records fingerprint `abc123`, arm B records `def456` (a plugin was loaded in B but not A). The "must match" claim is violated, but unless an external tool checks it, both records pass and the arms are compared as if their environments were identical.
**Layer of the implied fix:** L2 (a script that reads two records and exits non-zero on fingerprint mismatch) — the comment implies this exists but does not name it.
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`instructionsProvenLoaded` defaults to `false`. The unsafe state (claiming loaded when it wasn't) requires active misrepresentation, and the safe state is the default. This is the right direction.

### behavior
**Verdict:** finding
**Failure:** Line 45: `approvals:               # permission requests — and whether anyone could answer`. The field has no type. The comment describes two distinct concepts — (1) permission requests occurred, (2) whether a human was present to answer them — but gives no structure. Reviewer A writes `approvals: 3` (a count of requests). Reviewer B writes `approvals: [{tool: "edit", granted: false}]` (a list). Reviewer C writes `approvals: { requested: 3, answered: 0 }` (a structured object). Three runs with identical behavior produce three incomparable records, and a downstream analysis cannot aggregate them without first guessing which schema each one used.
**Layer of the implied fix:** L1 (a typed schema that makes the wrong shape unrepresentable) or L2 (a validator that rejects non-conforming shapes). Currently L3 — a comment with no type.
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The provenance model on lines 55-57 defines three levels: A (value + `source: provider` + `estimated: false`), B (value + `source: local-tokenizer` + `estimated: true`), and C (`value: null, source: null, estimated: null`). The model does not define a fourth state: `value: 12400, source: null, estimated: null` — a number is present but its provenance is absent. This state is representable in the template (nothing prevents filling `value` while leaving `source` and `estimated` at their null defaults). A reader encountering it cannot classify it as A, B, or C, and the comment gives no guidance. The scenario: a run fills in `inputTokens: { value: 12400, source: null, estimated: null }` — a real measurement with no provenance. Downstream analysis that filters on `source: provider` drops it; analysis that filters on `value != null` keeps it but cannot grade its reliability. Two reviewers would handle it differently because the model doesn't name this state.

Separately, line 60's declaration — "`tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own" — is the one place in the entire template that states what the validator does. It is honest and correct. The finding is not about this declaration but about the gap it implicitly exposes: this is the only field whose L2 enforcement is documented.
**Layer of the implied fix:** L2 (validator rejects `value` present + `source` null) for the fourth-state gap. The existing L2/L3 declaration is sound.
**Anchor:** `#   { value: null,  source: null,            estimated: null  }   # Level C`

### evaluation
**Verdict:** finding
**Failure:** Line 73: `failureClass:            # F01-F15`. The comment defines an enum range, but the field is a bare scalar with no stated enforcement. The scenario: a run records `failureClass: F16` (a class outside the documented range) or `failureClass: "timeout"` (a free-text label). Two reviewers classifying the same failure would not necessarily agree on whether F16 is valid or whether free text is acceptable. The template does not say whether the validator rejects values outside F01-F15, so a reader cannot tell if the comment is L2 (enforced) or L3 (aspirational).
**Layer of the implied fix:** L2 (validator rejects values outside F01-F15) — currently L3, an enum in a comment.
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** Line 77: `status:                  # valid / excluded / pilot / invalidated` and line 79: `telemetryComplete:       # a gap must not read as a zero`. Two problems, the more serious first.

`telemetryComplete` has no type. The comment "a gap must not read as a zero" is a principle about interpretation, not a type declaration. Reviewer A writes `telemetryComplete: true` (boolean — all telemetry captured). Reviewer B writes `telemetryComplete: 0.8` (fraction of fields captured). Reviewer C writes `telemetryComplete: [inputTokens, outputTokens]` (list of fields that are complete). The records are incomparable, and the principle the comment states — that a gap must not read as a zero — is enforced by none of these shapes, because none of them distinguishes "field absent" from "field zero" at the downstream level.

`status` has the same enum-in-comment shape as `failureClass`. A run recording `status: maybe` is representable, and the template does not state whether the validator rejects it.
**Layer of the implied fix:** L1 (typed schema for telemetryComplete) or L2 (validator). Currently L3 for both.
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? `configuration.instructionsProvenLoaded` records the result of a preflight gate. It is not a duplication — it carries the gate's verdict forward into the record for provenance. The gate runs (or doesn't); this field reports what happened. No loss of information.
- Which single section would two reviewers diverge on most, and by how much? `behavior.approvals` — the field has no type and the comment describes two concepts in one slot. Two reviewers would produce structurally different values for the same run, not merely different scores on the same value. This is a shape disagreement, not a scoring disagreement.
- What did the artifact not say that it needed to say? The template states its validator's behavior for exactly one field — `efficiency`, line 60. For every other field with an implied constraint (benchmarkSha required, resolved must be filled, fingerprint must match across arms, failureClass in F01-F15, status in four values, telemetryComplete typed), the reader is left to guess whether the comment is backed by an executing check or is guidance alone. The template's own L2/L3 declaration on line 60 is correct and honest; its absence everywhere else is the gap. A reader who assumes the comments are enforced will be wrong for at least some of them, and a reader who assumes they are not will discard real constraints. Neither reader can tell from the template which fields are which.
