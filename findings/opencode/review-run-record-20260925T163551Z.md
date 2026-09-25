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
reviewed_utc:    20260925T163551Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        22cb9af
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A template with three concrete defects that would silently mislead downstream consumers — the example runId does not match the implied task-id format, the failure taxonomy has no entry for success, and the explicit `false` default for `instructionsProvenLoaded` conflates "preflight was never run" with "preflight ran and failed."
  blocking:
    - reason: The shipped runId example drops the hyphen from the taskId shown two lines below, and the template offers no rule for how to construct a runId from `task.id`, `revision`, harness name, or sequence number.
      wrong_action: One user copies the example verbatim and writes `B0-COPILOT-BE001-001`; another constructs a runId from `task.id: BE-001` and writes `B0-COPILOT-BE-001-001`. A downstream `JOIN … ON runId` matches neither string against the other and silently drops rows from the joined set — the runId is the join key for run records, so this is a silent data-loss defect.
      anchor: "runId: B0-COPILOT-BE001-001"
      evidence: templates/run-record.yaml:1
    - reason: The `failureClass` field is annotated `# F01-F15`, defining a closed 15-element taxonomy with no member for "no failure to classify." A successful run that compiled, passed every test, and produced no unintended changes has nothing to write here, and the template does not say what to write.
      wrong_action: One reviewer of a successful run leaves `failureClass` blank (read as "no failure"); another invents a sentinel such as `F00` or `none` (explicit no-failure marker). A filter `WHERE failureClass IS NOT NULL` excludes the first population; a filter `WHERE failureClass = 'F00'` excludes the second. The same successful run lands in different downstream populations depending on who filled the record, and a join on `failureClass` silently partitions the data.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `instructionsProvenLoaded` is shipped with the explicit value `false` (not blank), as the template default. There is no third state for "preflight was not applicable to this harness."
      wrong_action: A reviewer whose harness has no preflight mechanism keeps the default `false`. A downstream reviewer reads `false` as "preflight ran and the assertion failed; treat the run as if instructions may not have loaded" and excludes the run. The boolean collapses three distinguishable states (ran-and-passed, ran-and-failed, not-run) into two, and the template's own default forces the worst collapse for the entire population that never had the option.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
  non_blocking:
    - reason: The provenance pattern (`{ value, source, estimated }`) introduced by the `efficiency.inputTokens` family (lines 61–65) is not adopted by adjacent fields with the same gap-vs-zero problem: `durationMs`, `environment.fingerprint`, `evaluation.compile`, `evaluation.tests`, and `configuration.instructionsHash` remain bare scalars. Real consistency gap, but each field's comment supplies enough context that a careful reader still interprets a blank as "unknown" rather than zero.
      evidence: templates/run-record.yaml:50,61-65
    - reason: `environment.fingerprint` is described as "hash of the above; arms must match" but the template does not name which inputs feed the hash, the algorithm, or where the hash is computed. A reader with two filled records cannot reproduce or verify the fingerprint.
      evidence: templates/run-record.yaml:32
    - reason: `evaluation.compile` and `evaluation.tests` record outcomes of the evaluator's own gate, which already decides pass/fail by exit code. On a gate-passing population the two fields are constants; the artifact admits (in the `notes` section, line 81–84) that constants are the failure mode.
      evidence: templates/run-record.yaml:68-69
  disputed:
    - finding: "`benchmarkSha:` is blank with a comment but no required marker"
      why: The artifact is a blank template field awaiting fill, not a populated record. The comment on the same line states what the field IS for; the template makes no claim about how to interpret the blank state of an unfilled record because the unfilled state is not a record. The defect the critic names — two runs from different benchmark commits both leaving it blank — is true of every blank template field, and the artifact does not stand on its own as a record any of those critics cite.
    - finding: "`harness.version:` and `runnerCommit:` are blank with no way to distinguish 'no version string' from 'not recorded'"
      why: Same reason. The artifact is a template; version and runnerCommit are explicitly named as fields to be populated once known. Nothing in the template asserts that a blank equals a specific state.
    - finding: "`model.resolved:` is blank so the alias-drift warning is unenforced"
      why: The template cannot know the resolved model at design time; the comment at line 16 already names the hazard ("An alias can silently re-point between runs"). The defect the critic names is in whatever fills this template, not in the template itself. The warning is unenforced, which is non-blocking: a downstream reader reading both `requested` and `resolved` sees the alias when only one is populated.
    - finding: "`durationMs` is a bare scalar that reads blank as zero"
      why: The comment at line 50 — "wall clock. The runner always knows this one." — names the runner as the writer. A bare scalar populated by the runner, not by a human, does not face the human-fills-blank-with-zero problem the critic names. The token fields needed the structured object because their values can come from humans, providers, or guessers; `durationMs` has a single named writer.
    - finding: "`measurement.telemetryComplete` is a boolean that conflates 'not checked' with 'checked and failed'"
      why: The artifact's shipped default for `telemetryComplete` is BLANK (line 79), not `false`. Blank reads as "not set / not asserted," which matches the same line's comment ("a gap must not read as a zero"). The critic conflates this field with `instructionsProvenLoaded` (which IS explicitly `false`); the two have different defaults and different semantics in the artifact.
    - finding: "`evaluation.compile` and `evaluation.tests` are gate restatements and so carry no information"
      why: Restating a gate is a real concern but not a wrong-action defect — the field copy in a record lets a reader spot a discrepancy between the gate decision and the recorded outcome, which is the only finding that survived review (per the `notes` block, line 81–84). Flagged as non-blocking, not disputed as a finding.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 109s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L2 |
| task | 1/1 | L2 |
| harness | 1/1 | L2 |
| model | 1/1 | L2 |
| environment | 1/1 | L2 |
| configuration | 1/1 | L1 |
| efficiency | 1/1 | L1 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L1 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
**Verdict:** finding
**Failure:** The example `runId: B0-COPILOT-BE001-001` drops the hyphen from `task.id: BE-001`. A reviewer constructing the runId from the task ID would write `B0-COPILOT-BE-001-001`; one copying the template example writes `B0-COPILOT-BE001-001`. A lookup for one fails to find the other, and a downstream join on runId drops the run silently.
**Layer of the implied fix:** L2
**Anchor:** `runId: B0-COPILOT-BE001-001` (vs `task.id: BE-001`)

### task
**Verdict:** finding
**Failure:** `benchmarkSha:` is blank with a comment ("the commit the task/evaluator were resolved from") but no required marker. Two runs from different benchmark commits both leave it blank. Reviewer A compares them as same-evaluator runs; Reviewer B refuses to compare because the evaluator version is unknown. The comment explains what the field is for but does not say whether a blank value means "not yet filled in" or "not applicable."
**Layer of the implied fix:** L2
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** finding
**Failure:** `version:` and `runnerCommit:` are blank. A run on harness v1.2 and a run on v1.3 both leave `version:` empty. Reviewer A treats them as the same harness; Reviewer B treats the blank as "version unknown, comparison invalid." The template provides no way to distinguish "harness has no version string" from "version was not recorded."
**Layer of the implied fix:** L2
**Anchor:** `version:`

### model
**Verdict:** finding
**Failure:** A run records `requested: haiku` and leaves `resolved:` blank. The comment warns that "an alias can silently re-point between runs," but the template does not require `resolved` to be filled. Reviewer A accepts the run — the requested model is known. Reviewer B excludes it — without `resolved`, the alias could have re-pointed to a different model and the comparison is invalid. The danger the comment names is invisible when the field that would catch it is blank.
**Layer of the implied fix:** L2
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"`

### environment
**Verdict:** finding
**Failure:** Two arms have different `settingsSources` arrays but both leave `fingerprint:` blank. The comment says "arms must match," but a blank fingerprint matches every blank fingerprint. Reviewer A compares the arms as equivalent (no fingerprint mismatch); Reviewer B refuses to compare (fingerprint missing, equivalence unproven). Nothing in the template computes the hash or rejects a blank one.
**Layer of the implied fix:** L2
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` is the template default. A run where the preflight script was never executed (the harness doesn't support it) and a run where the preflight ran and failed both produce `false`. Reviewer A reads `false` as "preflight failed, instructions may not have loaded, exclude." Reviewer B reads `false` as "preflight wasn't run, the run is valid but unverified." The boolean conflates "not run" with "ran and failed."
**Layer of the implied fix:** L1
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### efficiency
**Verdict:** finding
**Failure:** `durationMs` is a bare scalar. A run where the runner crashed leaves `durationMs:` blank. Reviewer A reads the blank as "zero duration" (a very fast run); Reviewer B reads it as "missing data." The token fields solved exactly this problem with the `{ value, source, estimated }` provenance object — a null there reads as "unknown," not "zero." `durationMs` got no such structure, and the comment's claim that "the runner always knows this one" is an assertion about the runner, not a constraint on the field.
**Layer of the implied fix:** L1
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15`. A run that compiled, passed all tests, and had no unintended changes has no failure to classify. Reviewer A leaves `failureClass:` blank (no failure). Reviewer B writes `F00` or `none` (explicit no-failure marker). A downstream filter that selects runs where `failureClass` is non-blank drops reviewer A's run and keeps reviewer B's — the same run, different populations. The template defines the failure range but not the success case.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `telemetryComplete` is a boolean with default unset (blank). A run where nobody checked telemetry completeness and a run where completeness was checked and found incomplete both produce a blank or `false`. Reviewer A reads blank as "not verified, run is valid"; Reviewer B reads `false` as "incomplete, exclude the run." The comment says "a gap must not read as a zero" but the field itself can't distinguish "not checked" from "checked and failed" — the same boolean ambiguity as `instructionsProvenLoaded`.
**Layer of the implied fix:** L1
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? `evaluation.compile` and `evaluation.tests` record gate outcomes (the evaluator runs them and exits non-zero on failure). `evaluation.acceptanceScore` and `evaluation.finalScore` are scores derived from those gates plus rubric scoring. `finalScore` does not duplicate a gate — it is a composite — but `compile` and `tests` are gate restatements: they carry no information that the gate didn't already produce, and a blank `compile` is ambiguous in the same way as a blank `benchmarkSha` (not-yet-filled vs not-applicable).
- Which single section would two reviewers diverge on most, and by how much? `evaluation.failureClass` — the success case is genuinely undefined. One reviewer leaves it blank; another invents a sentinel. The divergence is total: the same run lands in different populations depending on who filled the record. I'd expect disagreement on every successful run.
- What did the artifact not say that it needed to say? The efficiency section introduced a provenance pattern (`{ value, source, estimated }`) that distinguishes "unknown" from "zero" and grades confidence. No other section adopted it. `durationMs`, `instructionsProvenLoaded`, `telemetryComplete`, `compile`, `tests`, and `fingerprint` all face the same blank-means-what problem and all solve it differently or not at all. The template needs a general rule for "this field is blank" — not five ad-hoc ones.
