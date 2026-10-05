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
reviewed_utc:    20261005T211622Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        32a7c96
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template claims five L2/L3 controls in its comments (fingerprint equality, preflight-proven load, source-provenance enum, F01–F15 range, registered-in-advance exclusion reasons) but specifies no executable that enforces any of them, and its empty-field semantics are not uniform — every record made from this template inherits the ambiguity.
  blocking:
    - reason: The `fingerprint` field claims to gate cross-arm comparability ("arms must match") but the template names no script, no check, and no downstream consumer that verifies the hash; a reader fills in two records with different `permissionMode` and the template accepts both.
      wrong_action: A reader would record two arms that hash differently, treat both as valid runs, and aggregate them — a comparison that the artifact says must not happen, but that nothing prevents.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `instructionsProvenLoaded` is typed as a boolean, the comment asserts it is a "preflight assertion result," but no preflight is named, not in the template and not anywhere the template points to.
      wrong_action: A reader would write `true` after seeing the file path on disk, recording a human assertion as a preflight result; a run that never actually preflighted passes review.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: The efficiency block's `source` field is given as three example values in a comment (`provider`, `local-tokenizer`, `null`) without stating that these are exhaustive; the only validator behaviour named ("rejects a bare number") does not constrain `source`.
      wrong_action: A reader would fill in `source: "api-response"` (or any string) and the record would pass the validator; a downstream comparison would treat a Level-A run and an "undefined source" run as the same provenance class.
      anchor: "#   { value: 12400, source: provider,        estimated: false }   # Level A"
      evidence: templates/run-record.yaml:55
    - reason: `failureClass` carries the range `F01-F15` only as a comment, with no schema, no enum, and no link to where the F01–F15 definitions live; the template's stated validator is not stated to check the range.
      wrong_action: A reader would write `F16` (or `foo`) for an unrecognised failure and the record would pass; or two reviewers who haven't memorised F01–F15 would land on F03 vs F07 for the same failure, and the template gives no way to resolve it.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `exclusionReason` asserts two constraints in a comment — "structured" and "registered in advance" — but the field has no schema for structure and no sibling field for a registration timestamp, so neither constraint is checkable.
      wrong_action: A reader would write a reason after the run, treating it as legitimate; an exclusion invented post-hoc is indistinguishable from one registered before the run, and the measurement's exclusion status is silently untrustworthy.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
    - reason: The template mixes two empty-field conventions without defining either: `filesChanged: []` and `commands: []` initialise to an empty list (suggesting "known zero"), while `modelCalls:`, `toolCalls:`, `filesRead:`, `retries:`, `approvals:`, `compactions:`, `harness.version`, `runnerCommit`, `model.requested`, `model.resolved`, `behavior.modelCalls` are bare — the efficiency section explicitly says a gap must not read as a zero, and no other section does.
      wrong_action: A reader would record `modelCalls: 0` (or "no tool calls") for a run where telemetry was simply missing, and the experiment's per-run model-call count would be silently deflated.
      anchor: "  filesChanged: []"
      evidence: templates/run-record.yaml:42
  non_blocking:
    - reason: The `notes` block style ("Anything surprising. Especially anything that made the agent look good") is guidance, not a control, and does not affect scoring.
      evidence: templates/run-record.yaml:81
    - reason: `efficiency.durationMs` is stated as "wall clock. The runner always knows this one," which is the right provenance claim for a number the runner is the only source of.
      evidence: templates/run-record.yaml:49
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 147s |

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
| efficiency | 1/1 | L2 |
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
**Verdict:** finding
**Failure:** Two arms of a comparison run with different `permissionMode` values (one `acceptEdits`, one `default`). Both fill in their `environment` blocks faithfully. Their `fingerprint` hashes differ. The template accepts both records — nothing in the template, and nothing stated as running against it, compares fingerprints across arms. Reviewer A assumes a downstream step checks fingerprint equality and proceeds; Reviewer B assumes the human must catch the mismatch and flags it. The run is scored or not depending on which reviewer is on duty.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** A run loads instructions from a file but the preflight script that would set `instructionsProvenLoaded: true` is not run (the harness was started without it). The human fills in `true` because they believe the instructions were loaded — they saw the file path. Reviewer A reads `true` as "a preflight executed and confirmed the load"; Reviewer B reads `true` as "the human asserts it was loaded." The field records a boolean, not what proved it, so both readings are consistent with the filled-in record. A run that skipped its preflight passes review under reading B and fails under reading A.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### efficiency
**Verdict:** finding
**Failure:** The comment defines three provenance levels by example — A (`source: provider, estimated: false`), B (`source: local-tokenizer, estimated: true`), C (all null). A reviewer fills in `inputTokens: { value: 12400, source: "api-response", estimated: false }`, treating `source` as free-text describing where the number came from. Another reviewer fills in `source: provider` because they read the examples as an enum. The only stated enforcement is "validate-run-record.sh rejects a bare number" — whether it also validates `source` against `{provider, local-tokenizer, null}` is unstated. If the validator only checks structure (not a bare number), both records pass and the two runs are not comparable: one carries Level-A provenance, the other carries an undefined level that looks like Level A.
**Layer of the implied fix:** L2
**Anchor:** `#   { value: 12400, source: provider,        estimated: false }   # Level A`

### evaluation
**Verdict:** finding
**Failure:** A reviewer writes `failureClass: F16` for a failure mode they observed that is not in the F01–F15 list. Another reviewer writes `failureClass: F07`. The template defines the range only as a comment (`# F01-F15`) — no schema, no enum, no link to where F01–F15 are defined. Nothing in the template rejects F16. If the validator does not check the range either, the F16 record is accepted and later analysis groups it as an unknown class. Two reviewers who don't have the F01–F15 definitions memorized will diverge on whether a given failure maps to, say, F03 or F07, and the template gives them no way to resolve it.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** A run is marked `status: pilot` with `exclusionReason` left empty. Reviewer A says "pilot" means a practice run that was never meant to count, so no exclusion reason is needed. Reviewer B says any non-`valid` status requires an `exclusionReason`, because the comment says exclusionReason is "structured, registered in advance" and a pilot is a form of exclusion. The template lists four statuses in a comment but does not say which require an exclusion reason. Separately, "registered in advance" is a temporal constraint — the reason must exist before the run — but the template has no field recording when the reason was registered, so nothing can check "in advance." A run excluded for a reason invented after the fact passes review.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `measurement.status` (valid/excluded/pilot/invalidated) overlaps with `check-run-gate.sh` ("may this observatory run be scored?"), which the CLAUDE.md describes as a registered gate. If `status` is set by the human and the gate is set by a script, a run could be `status: valid` while the gate refuses it — or vice versa — and the template does not say which wins or whether they must agree. `evaluation.acceptanceScore` may also duplicate an acceptance gate's verdict; the template does not distinguish "the gate's decision" from "a human's score."
- **Which single section would two reviewers diverge on most, and by how much?** `efficiency`, by a full provenance level. The A/B/C model is defined in prose examples, the validator's actual scope is unstated, and the difference between Level A and "looks like Level A" is whether `source` is an enum or free text — a question the template does not answer. This is the section where the same run, scored by two faithful reviewers, produces non-comparable records.
- **What did the artifact not say that it needed to say?** Only `efficiency` addresses what an empty field means ("a gap reads as a gap and not as a very efficient run"). Every other section — `behavior.modelCalls`, `harness.version`, `behavior.toolCalls`, `evaluation.compile` — leaves empty undefined. A reviewer reading `modelCalls:` (empty) cannot tell whether the agent made zero calls or whether telemetry was missing. The efficiency section solved this; the rest of the template did not, and a gap in `behavior` or `evaluation` will be read as zero by one reviewer and as unknown by another.
