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
reviewed_utc:    20260929T111421Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        17b5905
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A run-record template whose sections vary from full typed provenance (efficiency tokens) to bare fields with prose-only hints (evaluation, measurement, behavior.approvals, efficiency.durationMs), so two honest fills produce records that cannot be aggregated.
  blocking:
    - reason: model.resolved has no provenance and no required marker, so an empty value reads as either "unmeasured" or "empty resolution" — and the warning two lines below ("an alias can silently re-point between runs") depends on this field actually being filled.
      wrong_action: A reader aggregating by `resolved` to detect alias re-pointing treats an empty value as "unmeasured" (drop the row) or "alias resolved to empty" (flag divergence). The two reads produce different aggregate verdicts on the same record set.
      anchor: '  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"'
      evidence: templates/run-record.yaml:15
    - reason: configuration.instructionsProvenLoaded is recorded as a boolean, but measurement.status (valid / excluded / pilot / invalidated) has no rule connecting it to instructionsProvenLoaded. The template documents the field but does not say what its value implies for the record's validity.
      wrong_action: Reviewer A sets `status: valid` because the run finished and the evaluator returned a verdict; Reviewer B sets `status: excluded` because the preflight failed and the treatment may not have been applied. The experiment's N includes or excludes the run depending on who filled it in, and downstream aggregates disagree.
      anchor: '  instructionsProvenLoaded: false    # preflight assertion result'
      evidence: templates/run-record.yaml:31
    - reason: behavior.approvals is documented as "permission requests — and whether anyone could answer" but has no type, no nested structure, and no example — so the same fact gets recorded three ways (count, object, ad-hoc trailing field).
      wrong_action: An automated run that stalls on two unanswered approvals is recorded as `approvals: 2` (count), `{requested:2, answered:0, outcome:stalled}` (object), or `2, stalled` (free text). The aggregator cannot parse the column, and the most important fact about the run (it stalled on an unanswered approval) is either lost or survives only in free text no downstream tool reads.
      anchor: '  approvals:               # permission requests — and whether anyone could answer'
      evidence: templates/run-record.yaml:45
    - reason: efficiency.durationMs is asserted to be "the runner always knows this one," but every other field in the same section carries a typed `{value, source, estimated}` provenance block so a gap reads as a gap and not a zero. durationMs has none of this — it is a bare integer next to fields that solve the exact problem it leaves open.
      wrong_action: After a runner crash-and-restart, Reviewer A records 45000 (the runner's second-attempt number); Reviewer B records 180000 (wall clock from an external timer). Both values live in the same field with no provenance, so the experiment's duration distribution is half one number and half the other with no way to tell which is correct.
      anchor: '  durationMs:              # wall clock. The runner always knows this one.'
      evidence: templates/run-record.yaml:49
    - reason: evaluation.failureClass references an enum (F01-F15) that is not defined anywhere in the template, while every other field in the section has at most a vague comment. The reader cannot fill in the field without external knowledge.
      wrong_action: A reviewer without access to the F01-F15 definitions leaves `failureClass` empty or guesses. Empty cells are treated as "no failure class," which is not the same as "unknown failure class," and the column's null rate conflates the two — the exact failure mode the rest of the lab has spent months guarding against.
      anchor: '  failureClass:            # F01-F15'
      evidence: templates/run-record.yaml:73
    - reason: evaluation.unintendedChanges has no comment at all — not even a one-word type hint — while sibling fields in the same section at least gesture at intent. Three plausible shapes (boolean / count / list of paths) are all consistent with the empty field.
      wrong_action: Reviewer A records `true`; Reviewer B records `3`; Reviewer C records `[path1, path2, path3]`. The aggregate cannot tell which reviewer meant "there were unintended changes," "three of them," or "here they are" — and silently picking one schema corrupts the other two.
      anchor: '  unintendedChanges:'
      evidence: templates/run-record.yaml:72
    - reason: measurement.telemetryComplete is a single boolean standing in for what is a multi-dimensional completeness check. The comment states the principle ("a gap must not read as a zero") but the type cannot express it.
      wrong_action: Reviewer A sets `true` ("most telemetry was captured") and includes the run in the cost analysis; Reviewer B sets `false` ("cache and cost are missing") and excludes it. The same record contributes to the experiment's token-cost aggregate or vanishes from it depending on who filled it in, and the experiment either double-counts a partial signal or silently drops the input-token data that was captured.
      anchor: '  telemetryComplete:       # a gap must not read as a zero'
      evidence: templates/run-record.yaml:79
    - reason: The evaluation section's `compile`, `tests`, `hiddenTests` fields duplicate the evaluator's gate outputs with no comment distinguishing them from gate-passed runs. If the dataset only contains gate-passing runs (as the old seven-category rubric did), these fields are constants carrying no information — the exact defect that killed that rubric.
      wrong_action: A reader weighting the evaluation section treats these fields as informative signals and either overweights a constant or, noticing the constant, excludes the section from the rubric and silently changes what was scored. The template does not say which world it lives in, so the reader has to guess.
      anchor: 'evaluation:'
      evidence: templates/run-record.yaml:67-70
  non_blocking:
    - reason: The template never distinguishes required from optional fields. efficiency is the only section that provides defaults (Level C) and a validator reference; every other section is bare fields with comments, and a reader must infer which fields must be filled for the record to be valid.
      evidence: templates/run-record.yaml:1-84
    - reason: `validate-run-record.sh` is mentioned once (line 60), only in the efficiency section, and its scope is unstated — a reader cannot tell whether it also checks model.resolved, configuration.instructionsProvenLoaded, or evaluation.failureClass.
      evidence: templates/run-record.yaml:60
    - reason: The warning on line 16 ("These differing is not a detail. An alias can silently re-point between runs.") is a strong claim about what the field means, but the field above it has no guard making the claim testable. This is L3 expressed as prose — visible to a careful reader, unenforceable by anything.
      evidence: templates/run-record.yaml:14-16
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 183s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| model | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
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
**Verdict:** finding
**Failure:** Run A records `requested: haiku, resolved: claude-haiku-4-5-20251001`. Run B records `requested: haiku, resolved:` (empty). The `haiku` alias re-pointed between the two runs. The comment warns this "is not a detail" and that "an alias can silently re-point between runs" — but with `resolved` empty in Run B, the divergence is undetectable. The warning cannot be acted on. Two reviewers would handle Run B differently: one would flag the missing `resolved` as excluding, another would accept it because the template never says the field is required.
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### configuration
**Verdict:** finding
**Failure:** A run completes with `instructionsProvenLoaded: false` — the preflight could not confirm the instructions file was loaded. The run still produced results. Reviewer A sets `measurement.status: valid` because the run finished and the evaluator returned a verdict. Reviewer B sets `measurement.status: excluded` because the preflight failed and the treatment may not have been applied. The template defines `instructionsProvenLoaded` in `configuration` and `status` (with values `valid / excluded / pilot / invalidated`) in `measurement`, but never connects them. Nothing in the template says `false` implies `excluded` or `invalidated`.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** An automated run hits two permission prompts and nobody is there to answer. The run stalls, then times out. Reviewer A records `approvals: 2`. Reviewer B records `approvals: { requested: 2, answered: 0, outcome: stalled }`. Reviewer C records `approvals: 2, stalled` as a separate ad-hoc field. The comment says "permission requests — and whether anyone could answer" but defines no structure, so the three recordings are incompatible when aggregated. The information that the run stalled on an unanswered approval — the most important fact about the run — is either lost or uncomparable.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** A runner process crashes mid-run and is restarted. The `durationMs` it reports covers only the second attempt — 45 seconds — not the 3 minutes of wall clock from the original start. Every token field in this section carries a provenance block (`{ value, source, estimated }`) with an explicit Level A/B/C system so a gap reads as a gap and not a zero. `durationMs` has none of this. The comment "The runner always knows this one" is an assertion about the runner, not a control on the value. Reviewer A records 45000 (the runner's number). Reviewer B records 180000 (wall clock from an external timer) in the same field. The two numbers are indistinguishable downstream, and the section that solved this exact problem for tokens left duration uncovered.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** A run passes 8 of 10 tests, compiles cleanly, and scores 72 on acceptance. Reviewer A records `compile: true, tests: 8, hiddenTests: 7, acceptanceScore: 72, failureClass: F03, finalScore: 72`. Reviewer B records `compile: true, tests: "8/10", hiddenTests: true, acceptanceScore: "72/100", failureClass: f03, finalScore: 0.72`. The template gives no type hints for any field in this section — unlike `efficiency`, which provides a full typed example with provenance levels. `failureClass` references an enum (`F01-F15`) in a comment but does not define what each class means, so a reviewer without external access to the class definitions cannot fill it in at all. `unintendedChanges` could be a boolean, a file count, or a list of paths — the template doesn't say. When these records are aggregated across runs, the type incompatibility makes the column unparseable.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** A run where the provider reported input and output tokens but not cache or cost. `telemetryComplete: true` is wrong — cost and cache are missing. `telemetryComplete: false` is misleading — it implies no telemetry exists, and a downstream analysis might exclude the run entirely, discarding the token data that was captured. The comment says "a gap must not read as a zero," which is the right principle, but a boolean cannot represent partial completeness. Two reviewers would choose differently: one would set `true` because "most telemetry was captured," another would set `false` because "not everything was captured." The run is either over- or under-counted in the aggregate depending on who filled it in.
**Layer of the implied fix:** L3
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The `evaluation` section records `compile`, `tests`, and `hiddenTests`, which are the evaluator's gate results. If the dataset only contains gate-passing runs (as the rubric does), these fields are constants — `compile: true, tests: true` on every row — carrying no information. The template does not say whether failing runs are recorded. If they are, the fields carry information; if they aren't, they're the same "restating a gate" constant the lab already identified as a defect in the old seven-category rubric. The template is silent on which world it lives in.
- **Which section would two reviewers diverge on most?** `evaluation`, by a wide margin. Seven fields, zero type hints, one enum referenced but not defined. The `efficiency` section is the counterexample: it gives a full typed example with three provenance levels and a validator reference. The gap between the two sections is the gap between a field a reviewer can fill in one way and a field they can fill in three.
- **What did the artifact not say that it needed to say?** The template never distinguishes required from optional fields. `efficiency` is the only section that provides defaults (Level C), a typed example, and a validator reference. Every other section is empty fields with comments, and the reader must infer which fields must be filled for the record to be valid. The validator (`validate-run-record.sh`) is mentioned once, in `efficiency`, and its scope is unstated — a reader cannot tell whether it also checks `model.resolved`, `configuration.instructionsProvenLoaded`, or `evaluation.failureClass`. The template's own layer model is visible in exactly one section and invisible everywhere else.
