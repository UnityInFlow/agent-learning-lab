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
reviewed_utc:    20260925T051137Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        d4faa7e
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Five fields are documented as if they enforce something the template and validator do not enforce, so the record will silently misrepresent the run — the treatment that did not load reads as loaded, a blocked run reads as hands-off, a failure mode reads as a different failure mode, the environment fingerprint is unfillable as the comment intends, and a null telemetryComplete passes the L2 control that exists to prevent it.
  blocking:
    - reason: treatment-applied is recorded as `instructionsProvenLoaded: false` by default, and no check rejects a record that left the treatment unproven — the field's name promises a preflight assertion but the only writable default is "not proven"
      wrong_action: an analyst reads the record and treats the run as evidence about the custom configuration when the agent actually ran on defaults — the same shape as the `--dir` silently-falls-back-to-default-agent failure documented in CLAUDE.md
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: `approvals` has no shape; the comment names the distinction it is supposed to capture ("whether anyone could answer") but two reviewers fill it in as a count vs a mapping of `requested`/`timedOut`, both pass
      wrong_action: an analyst grouping runs by approval behavior groups "agent timed out waiting for permission" with "agent never needed permission" — opposite experimental conclusions share one bucket
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: `failureClass` is documented as an enum (`# F01-F15`) in a comment with no validator, schema, or registry; `F03`, `compile`, `"build error"` all parse and all pass
      wrong_action: an analyst grouping runs by failure class splits the same failure across categories — cross-run comparisons of what went wrong are silently corrupted
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `fingerprint` says "hash of the above; arms must match" but specifies no hash algorithm and no field set; "arms" is undefined in the artifact and the validator
      wrong_action: an analyst checking environment consistency across treatment arms of an experiment cannot compute the comparison — the field is unfillable as the comment intends, so reviewers diverge by category (hash string vs boolean vs nested mapping), not by degree
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `telemetryComplete` defaults to blank, which parses as null; the L2 control the field is supposed to satisfy only checks presence (per the line-level pass, which read the validator) — a null value passes while carrying no information
      wrong_action: an analyst scanning for incomplete-telemetry runs does not flag this record as a gap; the gap is hidden behind a key that exists with a null value, which is the exact failure the field's own comment says it prevents ("a gap must not read as a zero")
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:79
  non_blocking:
    - reason: `resolved` is blank with a comment warning about alias re-pointing; the comment documents the risk but a reader can fill it in from the example — the defect is unenforcement, not unfillability
      evidence: templates/run-record.yaml:15-16
    - reason: `durationMs` comment "The runner always knows this one" is contradicted by documented harness hangs, but `durationMs:` (blank) parses as null in YAML, so "unknown" is expressible — the defect is in the comment, not the field
      evidence: templates/run-record.yaml:49
    - reason: only the `efficiency` block (line 60) names its own enforcement layer ("this block is Layer 3 on its own"); a person filling in the template has no map of which fields the validator rejects versus which are guidance that nothing runs — `failureClass`, `status`, `telemetryComplete`, `instructionsProvenLoaded`, `resolved` are all unenforced but unlabeled as such
      evidence: templates/run-record.yaml:60
 - reason: `exclusionReason` is commented "structured, registered in advance" without naming the registry or the structure; a real concern but downstream registration lives elsewhere, and the line-level pass does not show the artifact contradicting itself here
      evidence: templates/run-record.yaml:78
  disputed:
    - finding: "`durationMs` is unfillable as 'unknown' — the field is not a provenance mapping like the other five efficiency fields, so `null` is indistinguishable from 'instant' or 'nobody filled it in'"
      why: the artifact itself shows `durationMs:` blank, which parses as null in YAML; "unknown" is writable. The defect the line-level pass names is real (the comment is wrong about the runner always knowing) but the field's expressiveness is not what the finding says — the gap is in the comment, not the field
 - finding: "`evaluation.compile`/`tests`/`hiddenTests` restate the gate from `check-run-gate.sh`"
      why: the artifact records per-run outcomes, not scoring categories; the v1-rubric gate-restating anchor pattern does not transfer cleanly. A reviewer who reads `evaluation.compile: pass` next to `evaluation.finalScore: 3` may still not be able to tell how the score was computed, but the artifact does not claim the score is independent of the gate — the line-level pass asserts a contradiction the artifact does not state
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 155s |

Stall budget: 900s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L2 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L2 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

✱ Glob "tools/validate-run-record.sh" 1 match
✱ Glob "tools/verify-run-record-validator.sh" 1 match
✱ Glob "**/run-record*.yaml" 1 match
→ Read tools/validate-run-record.sh
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
**Verdict:** finding
**Failure:** A run records `requested: haiku` and leaves `resolved:` blank. Months later the `haiku` alias is re-pointed from `claude-haiku-4-5` to `claude-haiku-5-0`. The blank `resolved` makes it impossible to tell which model actually executed the run — the exact failure the comment warns about. Two reviewers would diverge on whether `resolved` is required: the comment says the difference "is not a detail" but the field is blank in the template and no validator checks it, so one reviewer fills it in and another leaves it blank, and both records pass.
**Layer of the implied fix:** L3
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"` and `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** The `fingerprint` comment says "hash of the above; arms must match" but "arms" is undefined. Three reviewers given the same run would do three different things: one computes a hash of the environment block and checks it matches a value in a separate experiment manifest; another checks that the fingerprint is identical across treatment arms of the same experiment; a third ignores the comment entirely because no term in it is defined. None of the three is rejected by anything, and the three records are incompatible. The comment also does not say what happens when arms do not match — is the run excluded, flagged, or just noted?
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` defaults to `false`, which means "the preflight check did not prove the instructions were loaded." A run with `instructionsProvenLoaded: false` is a run where the treatment was never applied — the agent ran with default instructions, not the custom configuration the experiment is testing. Nothing rejects this record. The validator does not check the field. A run where the treatment failed to load is silently scored as if the treatment was applied, which is the same shape as the `--dir` silently-falls-back-to-default-agent failure documented in CLAUDE.md. The field name says "proven loaded" but a `false` value blocks nothing.
**Layer of the implied fix:** L2
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** The `approvals` field has the comment "permission requests — and whether anyone could answer" but no shape. Two automated runs produce incompatible records: Reviewer A writes `approvals: 0` (no permission requests were made). Reviewer B writes `approvals: { requested: 3, timedOut: 3 }` (three permission requests that no human answered, so the agent was blocked). Both are valid YAML, neither is rejected. Downstream analysis cannot distinguish a hands-off run from a blocked run — which is the distinction the comment is trying to capture. The same ambiguity applies to `retries` and `compactions`, but `approvals` is the one where the divergence changes the experimental conclusion.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** `durationMs` is a bare scalar with no provenance shape, and the comment claims "The runner always knows this one." This lab's own CLAUDE.md documents that `opencode run` hangs and fails to return on roughly five of eight calls (2026-08-28), with wedged processes aged 10–12 days. A killed run may have no duration to report. The template provides no way to express "durationMs is unknown" — it is not a provenance mapping like the other five fields, so `durationMs:` (null) is the only writable form of "unknown," and it is indistinguishable from "the run was instant" or "nobody filled it in." The validator explicitly excludes `durationMs` from the provenance check, so nothing catches this. The comment's assumption is contradicted by the lab's own measured experience.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15`, an enum in a comment. Nothing enforces it. A run that fails with a compile error gets `failureClass: F03` from one reviewer (who looked up the code list) and `failureClass: "compile"` from another (who did not). Both are valid YAML, neither is rejected. Downstream analysis that groups runs by failure class silently misgroups the second run, and the error is invisible — there is no validator, no schema, and no registry to check against. The same unenforced-enum pattern repeats in `measurement.status`, but `failureClass` is the one where a wrong value corrupts a cross-run comparison rather than a single record.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** The validator checks that `telemetryComplete` is *present* (line 116: `if "telemetryComplete" not in m`) but not that it is a boolean. The template's own default is `telemetryComplete:` with no value, which parses as `null`. The key is present, so the validator passes. But `null` carries no information — it is neither `true` (telemetry arrived) nor `false` (it did not). A record with `telemetryComplete: null` is accepted by the L2 control while being semantically identical to the missing field the control is supposed to prevent. The comment on the field says "a gap must not read as a zero," but a null `telemetryComplete` is a gap that the validator reads as "present" and a human reads as "unknown" — the exact failure the control exists to catch, one layer up. Separately, `exclusionReason` is commented "structured, registered in advance" without saying where the registry lives or what the structure is; two reviewers would produce incompatible values for the same exclusion.
**Layer of the implied fix:** L2
**Anchor:** `telemetryComplete:       # a gap must not read as a zero` and `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? The `evaluation` block records `compile`, `tests`, and `hiddenTests` — which are the evaluator's gate outputs — alongside `acceptanceScore` and `finalScore`. If the evaluator gate already owns pass/fail (and `check-run-gate.sh` admits runs by that verdict), then `compile`/`tests`/`hiddenTests` in the run record restate the gate. They are not a constant across scored runs the way the v1 rubric's gate-restating anchors were, because the run record records what happened in one run, not what is scored across all runs. But a reviewer who reads `evaluation.compile: pass` and `evaluation.finalScore: 3` cannot tell from the template whether the score was computed from the gate output or independently of it.
- Which single section would two reviewers diverge on most, and by how much? `environment.fingerprint` — "arms must match" is undefined jargon with no referent in the artifact or the validator. I would expect two reviewers to produce structurally different values for this field (a hash string vs. a boolean vs. a nested mapping) and disagree on whether it is even checkable. The divergence is total — not a matter of degree but of category.
- What did the artifact not say that it needed to say? The template labels exactly one section's enforcement boundary: the `efficiency` comment at line 60 says "this block is Layer 3 on its own" and names the validator as the L2 version. No other section gets this treatment. A person filling in the template has no way to know that `failureClass`, `status`, `telemetryComplete`, `instructionsProvenLoaded`, and `resolved` are all unenforced — that the validator checks 6 of roughly 40 fields. The template should state its own enforcement perimeter: which fields the validator rejects and which are guidance that nothing runs.
