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
reviewed_utc:    20260909T051053Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        b6ceffe
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A template that documents constraints in comments but leaves fields shaped to violate them — most starkly `approvals`, where the comment encodes two dimensions a scalar cannot hold, and the `measurement` block, whose `status` / `telemetryComplete` / `exclusionReason` ambiguities determine whether a run counts at all.
  blocking:
    - reason: "`approvals` is a YAML scalar but the comment says it carries two dimensions ('permission requests — and whether anyone could answer'). A scalar holds one. Reviewer A records `approvals: 3` as a count, Reviewer B records `approvals: \"unattended\"` as answerability. A plan-mode run with three approval requests and zero answered because nobody was present collapses into the same field as a run that needed zero approvals."
      wrong_action: A reader records the count when the comment asks for both, and downstream comparisons treat unattended plan-mode runs as zero-approval runs.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: "`failureClass` is annotated `# F01-F15` (a constraint) but the schema accepts any value. A record with `failureClass: F99`, `failureClass: \"timeout\"`, or `failureClass: null` passes validation. The analysis groups runs by this field — if the recorder's choice is unconstrained, the failure-mode distribution is whatever the recorder felt like writing, and two reviewers aggregating the same data produce different breakdowns."
      wrong_action: A reviewer codes `F99` as unrecognized and drops it; another maps it to the nearest valid class; another treats it as a new class. Three failure-mode tables from one dataset.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: "The `measurement` block decides whether a run enters the analysis, and three of its fields are ambiguous in ways the schema cannot tell apart. (a) `status` is annotated `# valid / excluded / pilot / invalidated` but no enum is enforced — `status: maybe` or `status: null` passes. (b) `telemetryComplete` has a key-presence check but no value check — `telemetryComplete: null` passes, even though the template's own comment reads 'a gap must not read as a zero', naming exactly the failure mode the schema admits. (c) `exclusionReason` is annotated 'structured, registered in advance' but is a scalar; Reviewer A writes `{ code: M01, detail: \"model hung\" }`, Reviewer B writes `\"model hung\"`, and exclusions cannot be aggregated across runs."
      wrong_action: Reviewer A excludes a record with `status: valid, telemetryComplete: null`; Reviewer B includes the same record. The two 'what runs count' populations diverge on the schema, not on the data.
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:76-81
  non_blocking:
    - reason: "`benchmarkSha:` is blank in the template with a comment describing it as 'the commit the task/evaluator were resolved from'. A filled-in record with `benchmarkSha:` still blank passes validation. Two reviewers comparing runs: one excludes, one treats as 'same as the runId prefix'. Real gap — but it is the validator's job to enforce, not the template's alone, and the constraint is named in the comment."
      evidence: templates/run-record.yaml:6
    - reason: "`resolved:` is blank with the comment 'These differing is not a detail. An alias can silently re-point between runs.' The template marks the field as critical but provides no required marker. Real gap; validator's job."
      evidence: templates/run-record.yaml:15-17
    - reason: "`fingerprint:` is blank with the comment 'hash of the above; arms must match'. Two blank fingerprints 'match' trivially. Real gap; validator's job."
      evidence: templates/run-record.yaml:26
    - reason: "`instructionsProvenLoaded` defaults to `false` — which the comment calls the preflight assertion result, meaning `false` says the treatment was never confirmed loaded. The default value admits a record where the treatment was not applied. Real gap; a downstream gate should reject `false` from any treatment arm."
      evidence: templates/run-record.yaml:31
    - reason: "`durationMs:` is blank with the comment 'wall clock. The runner always knows this one.' The strongest reliability claim in the block, and the one field the validator's USAGE tuple excludes by design. Real gap; validator's job."
      evidence: templates/run-record.yaml:49
    - reason: "The `evaluation` block records `compile`, `tests`, `hiddenTests`, `acceptanceScore` as scalars — these are the evaluator's gates. A rubric that scores on these fields would be restating a gate that already admitted the run, the same constant-across-everything-it-can-score defect the lab documented in its v1 rubric. The template does not flag this for downstream rubric authors."
      evidence: templates/run-record.yaml:67-72
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 129s |

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
| configuration | 1/1 | L2 |
| behavior | 1/1 | L1 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L2 |
| measurement | 1/1 | L2 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

✱ Glob "**/run-record*" 1 match
✱ Glob "tools/validate-run-record*" 1 match
→ Read tools/validate-run-record.sh
✱ Glob "**/verify-run-record-validator*" 1 match
✱ Glob "**/run-record*.yaml" 1 match
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
**Verdict:** finding
**Failure:** A filled-in record with `benchmarkSha:` left blank passes `validate-run-record.sh` — the validator never reads the `task` block. Two runs submitted against different benchmark commits (the evaluator was revised between them) are compared as if against the same task. Reviewer A notices the blank and excludes the run; Reviewer B treats the blank as "same as the runId prefix" and includes it. The comparison is contaminated either way — one includes a run that should be excluded, the other excludes one that could have been scored.
**Layer of the implied fix:** L2 — the validator would need to reject a blank `benchmarkSha`, or a separate gate would. The template comment (`# the commit the task/evaluator were resolved from`) is L3 and stops nothing.
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** A record with `requested: haiku` and `resolved:` (blank) passes validation. The template's own comment says *"These differing is not a detail. An alias can silently re-point between runs"* — but a blank `resolved` is worse than a differing value: it is an alias drift that is invisible. Two reviewers comparing runs: one treats blank `resolved` as "unknown model, drop from cross-model comparison", another infers it from `requested` and keeps it in. The alias-drift signal the comment exists to flag is lost precisely when it is most likely (the harness reported nothing).
**Layer of the implied fix:** L2 — the validator would need to reject a blank `resolved` when `requested` is present. The comment is L3.
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"`

### environment
**Verdict:** finding
**Failure:** `fingerprint:` is blank in the template and a filled-in record with `fingerprint:` still blank passes validation. The comment says *"hash of the above; arms must match"*, making this the control that ensures two arms in a comparison are actually comparable. But two records with blank fingerprints "match" trivially — any string equals any string when both are absent. Two reviewers: one says "blank fingerprints can't confirm the environments match, exclude the comparison", another says "both blank, both default, proceed". A run with hooks loaded and a run with hooks not loaded are compared as same-environment.
**Layer of the implied fix:** L2 — a cross-record check would need to reject a comparison where either fingerprint is blank or they differ. The template comment is L3.
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` defaults to `false` and a record with `instructionsProvenLoaded: false` passes validation. The comment calls it *"preflight assertion result"* — meaning `false` is the preflight saying the treatment was never confirmed loaded. A run where the custom instructions were not loaded is the control arm wearing the treatment arm's label. Two reviewers: one treats `false` as "treatment not applied, this run is invalid", another treats it as "preflight didn't run, but the instructions were probably loaded anyway". The entire experiment's validity rests on this field and nothing rejects the value that invalidates it.
**Layer of the implied fix:** L2 — the validator (or a downstream gate) would need to reject `instructionsProvenLoaded: false` before a record is admitted as a treatment arm. The field's presence in the template is L3.
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a scalar but the comment encodes two dimensions: *"permission requests — and whether anyone could answer"*. A scalar holds one. Reviewer A fills in `approvals: 3` (the count). Reviewer B fills in `approvals: "unattended"` (the answerability). The records are incomparable — one says "3 approvals needed", the other says "nobody was there to approve", and neither holds both. A run in `plan` mode that needed 3 approvals and got 0 because the session was unattended is indistinguishable from a run that needed 0 approvals, once the field is collapsed to a single value.
**Layer of the implied fix:** L1 — the field shape itself is wrong for the information the comment says it carries. A scalar cannot hold two dimensions; the bad state (one dimension lost) is unrepresentable only if the field is a mapping.
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** `durationMs:` is blank in the template and a filled-in record with `durationMs:` blank passes `validate-run-record.sh` — the validator's `USAGE` tuple excludes it by design (*"durationMs is wall clock the runner owns and always knows"*). But "always knows" is the strongest reliability claim in the block, and it is the one field the L2 control does not touch. A record with `durationMs: null` passes. Two reviewers comparing efficiency: one drops the record (no duration = can't compare), another treats null as "valid run, duration not recorded" and keeps it in the comparison with imputed duration. The five provenance-tagged usage keys are well-defended; the one field claimed to be infallible is the one with no defense.
**Layer of the implied fix:** L2 — the validator would need to reject a blank `durationMs`. The comment is L3.
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` carries the comment `# F01-F15` but nothing enforces the range. A record with `failureClass: F99` passes, as does `failureClass: "timeout"`, `failureClass: null`, or `failureClass: "unknown"`. Two reviewers aggregating failure modes: one codes `F99` as "unrecognized, drop from failure-mode breakdown", another maps it to the nearest valid class, another treats it as a new class. The failure-mode distribution is whatever the recorder felt like writing. The same applies to `finalScore` — no range, no type check, no provenance — but `failureClass` is the more structural gap because it is the field the analysis groups by.
**Layer of the implied fix:** L2 — the validator would need to check `failureClass` against the registered F01–F15 set. The comment is L3.
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** Two problems, the first more serious. (1) `status` carries the comment `# valid / excluded / pilot / invalidated` but the validator never reads it — a record with `status: maybe` or `status: null` passes. This is the field that determines whether a run enters the analysis. Two reviewers: one includes `status: valid, telemetryComplete: false` (the validator only checks `telemetryComplete` *exists*, not that it is `true` or even a boolean — `telemetryComplete: null` passes because the key is present), another excludes it. The template says *"a gap must not read as a zero"* but `telemetryComplete: null` is a gap the validator admits, and nothing says whether `status: valid` requires `telemetryComplete: true`. (2) `exclusionReason` is commented as *"structured, registered in advance"* but is a scalar — Reviewer A writes `exclusionReason: { code: M01, detail: "model hung" }`, Reviewer B writes `exclusionReason: "model hung"`, and the exclusion reasons cannot be aggregated across runs.
**Layer of the implied fix:** L2 — the validator would need to check `status` against the enum and `telemetryComplete` for type and value. The comments are L3.
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The template's `evaluation` block restates `compile`, `tests`, `hiddenTests`, and `acceptanceScore` — these are the evaluator's gates, recorded as scalars with no provenance. If a downstream rubric scores on `acceptanceScore`, it is scoring a restatement of the gate that already admitted the run, which is the same constant-across-scored-runs defect the lab documented in the v1 rubric. The template does not flag this.
- **Which single section would two reviewers diverge on most?** `measurement`. The `status` enum, the `telemetryComplete` presence-only check, and the `exclusionReason` shape are three independent ambiguities in the block that decides whether a run counts at all. A reviewer could include or exclude the same record on any of the three and produce a different experiment population.
- **What did the artifact not say that it needed to say?** The template never states which fields are enforced by `validate-run-record.sh` and which are L3. A person filling it in has no way to know that `efficiency` provenance is the only thing that will be rejected if wrong, and that `instructionsProvenLoaded: false`, `benchmarkSha: null`, `resolved: null`, and `status: maybe` will all pass. The comment on line 60 says *"this block is Layer 3 on its own"* for `efficiency` — the same is true of every other block, and nothing says so.
