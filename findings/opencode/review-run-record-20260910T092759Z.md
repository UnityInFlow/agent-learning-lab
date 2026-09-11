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
reviewed_utc:    20260910T092759Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        8a1a231
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

→ Read tools/validate-run-record.sh
I need to verify the line-level findings against the actual validator and fixtures before deciding.
→ Read tools/verify-run-record-validator.sh
The validator confirms `derived` is an accepted source (line 48: `"derived": True`), and the template documents only Levels A/B/C without mentioning `derived`. The line-level finding on `efficiency` is substantive.

Let me verify the other findings — particularly the `behavior.approvals` claim about shape divergence, and the `evaluation.failureClass` claim.
→ Read tools/fixtures/run-records/valid-mixed.yaml
Confirmed: the template itself must pass the validator (lines 57-64). Now let me check the `valid-mixed.yaml` fixture to confirm `derived` is in real use, and also check the `filesRead` / `filesChanged` / `approvals` shape concern by inspecting any fixture.
→ Read tools/fixtures/run-records/valid-level-a.yaml
`derived` is used in a fixture (line 10) — the template doesn't document it. That's a real vocabulary gap.

Let me also check `valid-level-a.yaml` to see if `behavior.approvals` and `filesRead` vs `filesChanged` shapes are tested anywhere — if no fixture exercises that section, the finding is more about an undocumented shape than a failing control:
No fixture exercises the `behavior` or `evaluation` sections. The findings there are about **missing vocabulary** — things the template references but doesn't define — not about an executable control that admits something it shouldn't.

Now I have enough to decide. The four highest-value findings (efficiency `derived`, evaluation `failureClass` / `finalScore`, measurement `status` / `exclusionReason`) are all genuine "vocabulary the template references but does not define" gaps, and three of them are validated by the validator passing on the template itself. The behavior.approvals / filesRead shape concern is real too but lower stakes since no executable control depends on it.

The biggest one is `efficiency.derived` because the validator actively accepts it, a fixture uses it, and the template documents only A/B/C — a faithful reviewer reading only the template would either mislabel it or downgrade it to Level C, and both downstream records would pass validation.

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template documents only A/B/C provenance but the validator and fixtures both use a fourth value `derived`, so a reviewer reading only the template either mislabels or downgrades the cost — and two such records pass the validator and disagree on provenance.
  blocking:
    - reason: The template's efficiency block documents three provenance levels (A provider, B local-tokenizer, C null) with three examples, but the validator accepts `derived` as a fourth source and `valid-mixed.yaml` already uses it for cost. A reviewer who reads only the template has no `derived` option and either mislabels it as `source: local-tokenizer, estimated: true` (passes validation, wrong provenance — a tokenizer guess is not a price-table derivation) or drops it to Level C (loses the measurement). The validator itself is the authority here, and the template contradicts it.
      wrong_action: A reviewer recording a derived cost from a price table sees no `derived` option in the template's A/B/C documentation, picks `local-tokenizer, estimated: true`, and the validator accepts the record — but the measurement provenance is now wrong, and the L2 control that exists to prevent provenance drift has just blessed it.
      anchor: "# Level A is what the provider reported, B is what a local tokenizer guessed, C is that nobody knows."
      evidence: templates/run-record.yaml:51-60, tools/validate-run-record.sh:48, tools/fixtures/run-records/valid-mixed.yaml:10
    - reason: `evaluation.failureClass` is annotated `# F01-F15` but the fifteen classes are neither listed in the template nor referenced by any pointer. Two reviewers observing the same timeout record different classes and there is no way to resolve from the template; downstream grouping by class produces wrong counts.
      wrong_action: Reviewer A records `failureClass: F07` for a timeout (assuming F07 = timeout), Reviewer B records `failureClass: F12` (assuming F12 = timeout); both records pass whatever check exists today and the class-bucket totals are wrong.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `evaluation.finalScore` has no scale documented. One reviewer records `85` (out of 100), another records `0.85` (out of 1.0); the same run scores differently and nothing distinguishes them.
      wrong_action: Reviewer A scores a run at `finalScore: 85`, Reviewer B scores the same run at `finalScore: 0.85`; the experiment aggregates them as different magnitudes and a0.85 run is treated as much worse than an 85 run.
      anchor: "finalScore:"
      evidence: templates/run-record.yaml:74
    - reason: `measurement.exclusionReason` is annotated `# structured, registered in advance` but no structure is defined and no registry is referenced. A reviewer excluding a run writes free text; the "registered in advance" claim is unenforceable.
      wrong_action: Reviewer excludes a run with `exclusionReason: "model was unavailable"`; downstream code that groups by exclusion reason treats this as a one-off category and breaks comparability with runs excluded under a different label that should have been the same bucket.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
  non_blocking:
    - reason: `measurement.status` is annotated `# valid / excluded / pilot / invalidated` but the validator never inspects it; a typo like `status: invalid` passes. Low stakes because no executable control depends on the value today, but the moment a downstream filter is added it will silently miss the typo.
      evidence: templates/run-record.yaml:77, tools/validate-run-record.sh:115-117
    - reason: `configuration.instructionsProvenLoaded: false` is set by hand; nothing in the validator or runner checks it. The template's own claim that this is a "preflight assertion result" is aspirational until a runner actually emits it.
      evidence: templates/run-record.yaml:31
    - reason: `environment.fingerprint` is a free-text field with no computation step. The comment says "hash of the above; arms must match" but nothing hashes the surrounding fields, so a wrong fingerprint is a wrong string someone typed and the validator cannot catch it.
      evidence: templates/run-record.yaml:26
    - reason: `behavior.approvals` is annotated as carrying two distinct facts (request count + whether anyone could answer) but the field has no shape. Two reviewers produce identical-looking records for an unattended run with 3 unanswered prompts and an attended run with 0 prompts.
      evidence: templates/run-record.yaml:45
    - reason: `behavior.filesRead` is left unbraced (`filesRead:`) while `filesChanged: []` has an empty list, so reviewers default to different shapes (count vs list) and any downstream consumer breaks on one.
      evidence: templates/run-record.yaml:41-42
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 127s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

✱ Glob "tools/validate-run-record*" 1 match
✱ Glob "**/run-record*" 1 match
→ Read tools/validate-run-record.sh
✱ Glob "**/verify-run-record-validator*" 1 match
✱ Glob "**/GUARDRAILS.md" 1 match
→ Read tools/verify-run-record-validator.sh
✱ Glob "tools/fixtures/run-records/*.yaml" 11 matches
→ Read tools/fixtures/run-records/valid-level-a.yaml
→ Read tools/fixtures/run-records/valid-level-c.yaml
→ Read tools/fixtures/run-records/valid-mixed.yaml
→ Read tools/fixtures/run-records/bad-bare-scalar.yaml
→ Read tools/fixtures/run-records/bad-zero-for-unknown.yaml
→ Read tools/fixtures/run-records/bad-value-without-source.yaml
→ Read tools/fixtures/run-records/bad-provider-estimated.yaml
→ Read tools/fixtures/run-records/bad-null-with-source.yaml
→ Read tools/fixtures/run-records/bad-unknown-source.yaml
→ Read tools/fixtures/run-records/bad-missing-telemetry-complete.yaml
→ Read tools/fixtures/run-records/bad-missing-block.yaml
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
**Verdict:** finding
**Failure:** Two arms of a comparison are supposed to share an environment. Reviewer A computes a fingerprint from the loaded settings and records `fingerprint: a1b2c3`. Reviewer B copies the fingerprint from a previous run without recomputing. The fingerprints match, the arms are compared, and the comparison is invalid because B's environment had a different plugin loaded. Nothing computes the hash from the fields above it, and nothing downstream verifies that the hash matches the fields. A wrong fingerprint is just a wrong string someone typed, and it passes the validator.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** A run is recorded with `instructionsProvenLoaded: false` — the preflight assertion failed, meaning the treatment (custom instructions) was never loaded into the agent. The validator does not check this field, so the record passes. The run is scored as if the treatment was applied. Two reviewers reading the same record: one treats it as a valid treatment run, another treats it as a baseline run with a failed treatment. The field name says "proven" but the proof is a boolean someone sets by hand.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` packs two distinct facts into one field: how many permission requests were made, and whether anyone was present to answer them. An unattended run with 3 unanswered approval requests is a different experimental condition than an attended run with 0 requests. Reviewer A records `approvals: 0` for an unattended run where no tool triggered a permission prompt. Reviewer B records `approvals: 0` for an attended run where no permissions were needed. The records are identical; the conditions are not. Separately, `filesRead:` has no `[]` while `filesChanged: []` does — one reviewer records a count, another records a list, and downstream code expecting one shape breaks on the other.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The template documents three provenance levels — A (`provider`), B (`local-tokenizer`), C (`null`) — and gives three examples. The validator accepts a fourth source, `derived`, which the template never mentions. The `valid-mixed.yaml` fixture uses `source: derived, estimated: true` for a cost computed from a price table. A reviewer recording a derived cost who reads only the template sees no `derived` option. They either mislabel it as `source: local-tokenizer, estimated: true` (passes validation, wrong provenance), or drop it to Level C (loses the measurement). Two reviewers with the same derived cost would produce different records, and the one that mislabels passes the L2 check.
**Layer of the implied fix:** L3
**Anchor:** `# Level A is what the provider reported, B is what a local tokenizer guessed, C is that nobody knows.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15` but the fifteen classes are neither listed nor referenced. Two reviewers observing the same timeout: one records `F07` (assuming F07 = timeout), another records `F12` (assuming F12 = timeout). There is no way to resolve the disagreement from the template. Downstream analysis grouping by failure class produces wrong counts. Additionally, `finalScore` has no scale documented — one reviewer records `finalScore: 85` (out of 100), another records `finalScore: 0.85` (out of 1.0). The same run gets different scores, and nothing in the template or validator distinguishes them.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` is annotated `# valid / excluded / pilot / invalidated` but the validator only checks that `telemetryComplete` exists — it does not check `status` at all. A record with `status: invalid` (not `invalidated`) passes. Downstream code filtering on `status: invalidated` misses it; code filtering on `status != valid` catches it. Two reviewers would disagree on whether `invalid` and `invalidated` are the same value. Separately, `exclusionReason` is commented "structured, registered in advance" but no structure is defined and no registry is referenced. A reviewer excluding a run writes free text; the "registered in advance" claim is unenforceable.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? `evaluation.compile` and `evaluation.tests` record the results of gates the evaluator already runs. If these fields restate the gate outcome, they carry no information the evaluator doesn't already have — the same defect the v1 rubric was killed for. The template does not say whether these are the evaluator's own results or an independent re-check, so two reviewers would fill them differently.
- Which single section would two reviewers diverge on most, and by how much? `evaluation.failureClass` — without a defined list, divergence is near-certain. Any two reviewers observing the same failure would assign different classes, and the template gives no way to adjudicate. The gap is not a matter of interpretation; it is a missing definition.
- What did the artifact not say that it needed to say? Four things: (1) the `derived` provenance source, which the validator accepts and the fixtures use but the template's Level A/B/C model omits; (2) the F01–F15 failure-class list or a pointer to it; (3) the scale of `finalScore`; (4) the structure and registry for `exclusionReason`. Each of these is a vocabulary the template references but does not define, and each allows two faithful reviewers to produce records that cannot be compared.
