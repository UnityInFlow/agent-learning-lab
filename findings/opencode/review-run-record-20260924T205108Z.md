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
reviewed_utc:    20260924T205108Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        d4faa7e
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: ACCEPT
  summary: A run-record template with several field-design issues — four identifier fields ship concrete example values, `instructionsProvenLoaded: false` defaults to a state that conflates "checked and failed" with "never checked," the `approvals:` comment promises a two-part fact the scalar shape cannot carry, and `failureClass` references an F01–F15 enum it never lists — but none produce a load-bearing misreading on their own; several other flagged items name validator gaps rather than template defects.
  blocking: []
  non_blocking:
    - reason: Four identifying fields (runId, task.id, task.revision, harness.name) ship concrete example values while sibling identifier fields in the same sections are blanked. A copy-paste operator who forgets to overwrite inherits stale values that downstream indexing cannot distinguish from hand-typed ones; the validator does not check these fields, so the inherited literal passes cleanly.
      evidence: templates/run-record.yaml:1 (runId: B0-COPILOT-BE001-001); :4-5 (id: BE-001, revision: 1); :9 (name: github-copilot-cli)
    - reason: `instructionsProvenLoaded: false` ships as a concrete default. The comment on the same field frames it as the result of a preflight check, so `false` is ambiguous between "preflight ran, didn't prove" and "preflight never ran." A reviewer treating `false` as the former could exclude a valid run from scoring; one treating it as the latter would admit an un-preflighted run. The conflation is exactly the case the line-level pass calls out as the most likely place for two reviewers to diverge, but the comment next to the field marks it as a deliberate "assertion result" and makes the conflation discoverable — so this is a template-default defect, not a hidden misclaim. Default the field to no value so the operator's deliberate choice of true/false is what is recorded.
      evidence: templates/run-record.yaml:31
    - reason: `approvals:` is a bare scalar but the comment on the same field describes a two-part fact ("permission requests — and whether anyone could answer"). A scalar cannot represent both halves, so the "was anyone there to answer" half is structurally unrecoverable from the field alone. Either widen the schema (e.g. an object with `requested` and `answeredBy`) or trim the comment to match the scalar.
      evidence: templates/run-record.yaml:46
    - reason: `failureClass` references an enum F01–F15 in its comment but never lists the codes. A reviewer classifying a run's failure has no canonical list to consult from this file. Either enumerate the F01–F15 codes inline or link to the companion registry.
      evidence: templates/run-record.yaml:74
    - reason: The template does not mark which fields are validator-enforced and which are descriptive. An operator filling this in has no indication that `measurement.telemetryComplete` and the five efficiency usage keys are required while everything else is informational. The efficiency block self-documents its provenance discipline (lines 52–60), but no other block carries a similar marker.
      evidence: templates/run-record.yaml:48-65 (efficiency block self-documents its provenance discipline); :67-79 (evaluation and measurement blocks ship silently)
    - reason: `evaluation.acceptanceScore` and `evaluation.finalScore` are bare scalars while the parallel efficiency block carries a value+source+estimated provenance discipline for its numbers. The asymmetry is a discipline choice rather than a misclaim — the template does not say scores come from a provider — but it means a guess and a measurement are visually indistinguishable on these two fields where they would not be in the efficiency block.
      evidence: templates/run-record.yaml:71-72 (bare scalars); :52-57 (the prose discipline limited to efficiency)
  disputed:
    - finding: model.resolved blank — nothing checks it, alias drift goes undetected
      why: The template marks `resolved:` blank with a comment naming the alias-drift risk ("An alias can silently re-point between runs"). That is a contract on the runner/operator, not a claim the template has enforced. The validator's missing enforcement is a validator defect, not a template defect.
    - finding: environment.fingerprint blank — no arm-match check
      why: Same shape. The template marks the field blank with the comment "hash of the above; arms must match," pointing the operator at a contract the runner must execute. Template does not claim the hash is computed or enforced.
    - finding: efficiency.durationMs blank — validator excludes it, gap passes as zero
      why: Template marks blank with the comment "The runner always knows this one." That describes a contract on the runner, not on the template; the empty field is not rendered as a zero by YAML. Validator gap is the validator's defect.
    - finding: measurement.telemetryComplete type/value not validator-enforced — strings like "yes" pass
      why: Validator defect, not template defect. The template marks the field blank with the comment "a gap must not read as a zero"; it has not claimed a boolean type or a validator check.
    - finding: evaluation.failureClass value not range-checked (F99, "compile-error" pass)
      why: Validator defect, not template defect. The template carries the comment "F01-F15" as a hint, not as an enforced contract. (The separate defect that the F01–F15 list is not enumerated is recorded in non_blocking.)
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 4681s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L3 |
| task | 1/1 | L3 |
| harness | 1/1 | L3 |
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

Let me check what the validator actually enforces before I assess the layer of each section.
✱ Glob "tools/verify-run-record*" 1 match
✱ Glob "tools/validate-run-record*" 1 match
→ Read tools/validate-run-record.sh
→ Read tools/verify-run-record-validator.sh
### runId
**Verdict:** finding
**Failure:** The template ships `runId: B0-COPILOT-BE001-001` as a literal value, not a blank. Two operators who copy the template and forget to overwrite `runId` both produce records that pass `validate-run-record.sh` (which never reads `runId`) and are indistinguishable in any index keyed by run id. One reviewer scoring run B0-COPILOT-BE001-002 reads the inherited `runId`, believes it is run 001, and scores it against the wrong task. A second reviewer checks the actual run directory name and scores correctly. Every other identifying field in the template is blanked; this one is not.
**Layer of the implied fix:** L3
**Anchor:** `runId: B0-COPILOT-BE001-001`

### task
**Verdict:** finding
**Failure:** `task.id: BE-001` and `task.revision: 1` are concrete literals, same defect as `runId`. A record for task BE-002 that inherits `id: BE-001` passes validation. The scoring scripts admit a run by the evaluator's recorded verdict (Decision D), not by cross-checking `task.id` against the run directory, so a mismatched `task.id` is never caught downstream. Two reviewers would score the same artifact against different task IDs.
**Layer of the implied fix:** L3
**Anchor:** `id: BE-001` / `revision: 1`

### harness
**Verdict:** finding
**Failure:** `harness.name: github-copilot-cli` is a concrete literal. A run executed on `codex` that inherits this value passes validation. The harness name is the treatment identifier for the experiment — a mislabelled record is scored against the wrong harness's behavioral expectations, and the cross-harness comparison (codex vs. opencode) silently corrupts. `harness.version` and `harness.runnerCommit` are correctly blanked, making the concrete `name` the one field a copy-paste operator inherits without noticing.
**Layer of the implied fix:** L3
**Anchor:** `name: github-copilot-cli`

### model
**Verdict:** finding
**Failure:** The comment says "These differing is not a detail. An alias can silently re-point between runs." But nothing executes against this. A record with `requested: haiku` and `resolved:` (empty) passes `validate-run-record.sh`. The entire purpose of the `resolved` field is to detect alias drift, and a record that omits it is indistinguishable from one where the operator checked and the alias was stable. Two reviewers would diverge: one treats empty `resolved` as "not verified, exclude," another treats it as "not filled in, score anyway."
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** `fingerprint:` is blank with the comment "hash of the above; arms must match." Nothing computes the hash, and nothing validates that two records compared as arms of the same experiment have matching fingerprints. A run with `bare: true` and a run with `bare: false` both pass validation with `fingerprint:` empty. Two reviewers comparing them as arms would diverge: one notices the environment mismatch from the individual fields, another trusts the empty fingerprint as "not yet computed, proceed."
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` ships as a concrete default. The comment says "preflight assertion result," meaning `false` should signal "the preflight ran and the instructions were NOT proven loaded." But a copy-paste operator who never ran the preflight also leaves `false`. The two states — "checked, failed" and "never checked" — are indistinguishable. Two reviewers would handle the same record differently: one excludes the run (instructions not proven), another scores it (operator just didn't flip the flag).
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals:` is a bare scalar with the comment "permission requests — and whether anyone could answer." The comment identifies a two-part fact (was approval requested, was anyone there to answer), but the field shape is a single scalar. An unattended run where the agent requested permission and stalled produces `approvals:` with no way to distinguish "no approvals requested" from "approval requested, nobody answered, run timed out." Two reviewers would record the same stalled run differently — one writes `approvals: 0` (no approvals granted), another writes `approvals: 1` (one was requested) — and the stall, which is the finding, is lost either way.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The comment on `durationMs` says "The runner always knows this one," but `validate-run-record.sh` excludes `durationMs` from its checks, and nothing else requires it to be present. A record with `durationMs:` (empty) passes validation. A run where the runner crashed before recording wall-clock time is indistinguishable from a run where the operator forgot to fill it in. Two reviewers diverge: one excludes the run (no duration = can't compare efficiency), another scores it (validator passed, the usage block is complete). The provenance-enforced usage block is sound; this is the one field the template claims is always known and then does not enforce.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass:` carries the comment "F01-F15," defining an enum in prose. Nothing validates the value is in that range. A record with `failureClass: F99` or `failureClass: "compile-error"` passes `validate-run-record.sh`. Two reviewers classifying the same run's failure would write different codes, and an out-of-range code is never caught. Separately, `acceptanceScore:` and `finalScore:` are bare scalars with no provenance — the same discipline the `efficiency` block enforces (value + source + estimated) is not applied to scores. A record with `finalScore: 85` and no source passes, while `efficiency.cost: 85` without source is rejected. Two reviewers would disagree on whether an unsourced score is a measurement or a guess.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `validate-run-record.sh` checks that the key `telemetryComplete` exists (line 116) but does not check its type or value. A record with `telemetryComplete: "pending"` or `telemetryComplete: "yes"` passes. The field's purpose is "a gap must not read as a zero," but a string `"false"` is truthy in Python and falsy in bash, so two downstream consumers would read the same record differently. Additionally, `status:` is an enum in a comment (`valid / excluded / pilot / invalidated`) with no enforcement — a record with `status: excluded` and `exclusionReason:` (empty) passes, producing an excluded run with no recorded reason.
**Layer of the implied fix:** L3
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The `evaluation` block carries `compile`, `tests`, and `hiddenTests` — gate results restated in the run record. The rubric (v2) dropped `functional-correctness` and `requirement-completeness` for exactly this reason: restating a gate is a constant across everything the rubric can score. The run record is not the rubric, so restating gate results here is not a duplication — but `evaluation.acceptanceScore` and `evaluation.finalScore` are summary scores with no provenance, while the actual scoring sheet (produced by `codex-score.sh`) is the registered measurement. A reviewer reading the run record's `finalScore` and the scoring sheet's score would see two numbers with different authority and no link between them.
- **Which section would two reviewers diverge on most?** `configuration.instructionsProvenLoaded: false`. The default `false` is a single bit carrying two distinct facts — "the preflight ran and failed" vs. "nobody ran the preflight" — and the template gives no way to tell them apart. I'd expect a one-score swing on any run that ships the default.
- **What did the artifact not say that it needed to say?** The template never says which fields are required for a run to be scored versus which are descriptive. `validate-run-record.sh` enforces only the five `efficiency` usage keys and `measurement.telemetryComplete` — everything else, including `runId`, `task.id`, `harness.name`, `model.resolved`, and `evaluation.finalScore`, can be blank or wrong and the record passes. An operator filling in the template has no indication of which fields the validator will check and which it will not. The template also references `failureClass` values F01–F15 but never lists them; a reviewer cannot classify a failure without the enum definition, and the template is the natural place to find it.
