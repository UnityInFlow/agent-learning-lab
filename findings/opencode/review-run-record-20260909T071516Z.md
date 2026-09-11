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
reviewed_utc:    20260909T071516Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        1031a99
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Five places where the template documents a constraint in a comment but names no validator and provides no schema, so a writer can produce a value the comment says is wrong without anything rejecting it — and one of those places (status) is the very gate that decides which runs enter the analysis.
  blocking:
    - reason: fingerprint comment says "arms must match" but specifies no algorithm, no serialization, and no canonicalization rule
      wrong_action: two reviewers fingerprinting the same environment with SHA-256 over YAML vs MD5 over JSON produce different hashes; the "arms must match" check fails and the discrepancy is investigated as an environment difference when the environments are byte-identical
      anchor: "  fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: status enum is comment-only with no validator referenced, while the efficiency block on the same template explicitly names `tools/validate-run-record.sh` as its enforcer
      wrong_action: a writer records `skipped` (or any string outside the four listed) for an abandoned run, the record is admitted to analysis, and the measurement that decides which runs enter the comparison is the very field with no enforcement behind it
      anchor: "  status:                  # valid / excluded / pilot / invalidated"
      evidence: templates/run-record.yaml:77
    - reason: instructionsProvenLoaded records a boolean but no rule in the template connects false to measurement.status
      wrong_action: a reviewer marks status: valid for a run whose preflight failed (instructions file missing or wrong), and the broken run is admitted to the comparison it was supposed to be excluded from — the treatment was not proven loaded yet the analysis treats it as loaded
      anchor: "  instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:32
    - reason: the behavior block has six fields (modelCalls, toolCalls, filesRead, retries, approvals, compactions) as bare keys with no type indicator, sitting beside three sibling fields (toolsUsed, filesChanged, commands) that use `[]` as a list signal
      wrong_action: three competent reviewers produce three incompatible shapes for the same run — approvals: 5 (count), approvals: [{request, answered}] (list), approvals: {requested, answered} (dict); downstream aggregation averages the count with the dict and the list silently, and the "whether anyone could answer" signal the comment asks for is preserved in one, lost in another, and ambiguous in the third
      anchor: "  approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:38-46
    - reason: compile, tests, hiddenTests, finalScore are bare keys with no type indicator, and finalScore could be the rubric score, the evaluator score, or a composite of both
      wrong_action: if finalScore incorporates compile/tests/hiddenTests, the gate is restated inside the score — the duplication CLAUDE.md names as "a constant across everything this rubric can score" that "carried no information" when it killed the seven-category rubric; the template does not say which, so two reviewers can produce two different finalScore values for the same submission and the analysis cannot tell them apart
      anchor: "  compile:" / "  tests:" / "  finalScore:"
      evidence: templates/run-record.yaml:68-74
  non_blocking:
    - reason: failureClass comment references F01-F15 taxonomy that the template does not define; a reader without external docs either guesses or skips
      evidence: templates/run-record.yaml:73
    - reason: permissionMode comment references "harness bug #7" without defining it
      evidence: templates/run-record.yaml:20
    - reason: requested vs resolved model distinction is acknowledged in a comment ("An alias can silently re-point between runs") but no check enforces that the two fields actually match what telemetry reports
      evidence: templates/run-record.yaml:14-16
    - reason: benchmarkSha, harness.version, harness.runnerCommit, environment.fingerprint and others are empty with no required-field marker, so a record can be filled in with a critical provenance gap and nothing in the template flags the omission
      evidence: templates/run-record.yaml:6,10,11,26 - reason: exclusionReason comment says "structured, registered in advance" but names no registry and no validator; a post-hoc reason can be written and nothing stops it
      evidence: templates/run-record.yaml:78
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 121s |

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
**Failure:** Two arms with byte-identical environments are fingerprinted by two different people. One hashes the YAML serialization with SHA-256; the other hashes the JSON serialization with MD5. The fingerprints differ. The "arms must match" check fails, and the discrepancy is investigated as an environment difference when none exists. The template says "hash of the above" but names no algorithm, no serialization format, and no canonicalization rule — so the bad value (a mismatched fingerprint for a matched environment) can be written down and nothing in the template prevents it.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** A run completes where the preflight assertion failed — `instructionsProvenLoaded: false` — because the instructions file was missing or the wrong one was found. Reviewer A reads this as a factual record and sets `measurement.status: valid`, since the template places no constraint connecting the two fields. Reviewer B reads a failed preflight as an invalidated run and sets `status: invalidated`. The same run is admitted to one analysis and excluded from the other. The template records the preflight result but never states what a `false` means for the run's measurement status.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** A non-interactive Copilot run issues five permission prompts that nobody answers. Reviewer A records `approvals: 5` (a count). Reviewer B records `approvals: [{request: "edit ShipmentController.kt", answered: false}, ...]` (a structured list). Reviewer C records `approvals: {requested: 5, answered: 0}` (a summary). The comment "permission requests — and whether anyone could answer" implies the answered/unanswered distinction matters, but the field gives no schema, no type hint, and no structural indication — unlike `toolsUsed: []`, `filesChanged: []`, and `commands: []` which signal lists with `[]`. The three records are incompatible downstream, and the "whether anyone could answer" signal is preserved in one, lost in another, and ambiguous in the third. The same type ambiguity affects `modelCalls`, `toolCalls`, `filesRead`, `retries`, and `compactions` — all bare keys with no `[]` and no comment, sitting beside fields that do have `[]`.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** A run compiles with zero errors and all tests pass. Reviewer A records `compile: true` and `tests: true` (booleans). Reviewer B records `compile: 0` and `tests: 0` (error/failure counts). Both are reasonable readings of bare keys with no type indicator and no comment. Downstream aggregation that averages `compile` across runs gets `true` from one and `0` from the other for the same outcome. Separately, `finalScore` is undefined — it could be the evaluator's score, the rubric's score, or a composite of both. If it is a composite that incorporates `compile` and `tests` (gate results), and the rubric also scores quality over the same submission, the gate is restated inside the score — the exact duplication the lab's own CLAUDE.md says "carried no information" when it killed the seven-category rubric. The template does not say which.
**Layer of the implied fix:** L3
**Anchor:** `compile:` / `tests:` / `finalScore:`

### measurement
**Verdict:** finding
**Failure:** A reviewer writes `status: skipped` for a run that was abandoned before execution. The template's comment lists four values — `valid / excluded / pilot / invalidated` — but nothing in the template rejects `skipped`. Unlike the efficiency block, which explicitly names `tools/validate-run-record.sh` as the thing that rejects bare numbers, this section makes no reference to any validator for the status enum. If the validator does not check `status` against the four values (and the template gives no signal that it does), the bad value is written down and admitted. The same gap covers `exclusionReason`: "structured, registered in advance" is guidance, but nothing in the template enforces pre-registration — a post-hoc exclusion reason can be written and nothing stops it.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The `evaluation` section places gate results (`compile`, `tests`, `hiddenTests`) and scores (`acceptanceScore`, `finalScore`) in the same block without defining their relationship. If `finalScore` is computed from the gate results, and the rubric also scores the same submission, the gate is restated inside the score. The template does not say whether `finalScore` is the rubric score, the evaluator score, or a composite — so the duplication risk is unresolvable from the artifact alone.
- **Which section would two reviewers diverge on most?** `behavior`, by a wide margin. Six fields have no type indicator, and `approvals` actively misleads — its comment implies structured data ("whether anyone could answer") while its form gives no schema. Three competent reviewers could produce three incompatible shapes for the same run.
- **What did the artifact not say that it needed to say?** Three things: (1) the fingerprint hash algorithm and serialization format — "hash of the above" is under-specified to the point that two people cannot produce comparable values; (2) the connection between a failed preflight (`instructionsProvenLoaded: false`) and the run's measurement status — the template records the fact but not its consequence; (3) which fields are required versus optional — a run record missing `failureClass` or `fingerprint` or `resolved` model is not flagged by anything in the template, and the reader cannot tell whether the validator catches the omission or whether the gap is acceptable.
