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
reviewed_utc:    20260910T183634Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        2bb6115
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A reviewer template that promises structure in seven of its comments but delivers bare scalars in every one of those fields; two plausible reviewers will record incompatible things for the same run, and the most serious case (acceptanceScore/finalScore) would reproduce the seven-category rubric defect CLAUDE.md specifically warns against.
  blocking:
    - reason: evaluation.acceptanceScore and evaluation.finalScore have no comments distinguishing them
      wrong_action: A researcher filtering gate-passing runs by acceptanceScore gets either a numeric range or the rubric score double-counted as the gate; the gate becomes a constant across gate-passing runs — the exact defect the seven-category rubric fell to.
      anchor: |
        acceptanceScore:
        finalScore:
      evidence: templates/run-record.yaml:70-71
    - reason: behavior.approvals is a bare scalar but its comment promises two dimensions ("permission requests — and whether anyone could answer")
      wrong_action: Reviewer A records a count (3), Reviewer B records {requested: 3, answered: 0}, Reviewer C records null because they couldn't tell what shape to use; a downstream query counting unanswered approvals returns three different answers for the same run.
      anchor: |
        approvals:               # permission requests — and whether anyone could answer
      evidence: templates/run-record.yaml:45
    - reason: environment.fingerprint says "hash of the above; arms must match" but "the above" is seven fields, five of them list-typed, with no canonicalization rule
      wrong_action: Two arms with identical environments but different list-ordering in their source files produce different fingerprints and fail the "arms must match" check; conversely an arm that drops permissionMode from the hash input matches an arm with a different permission mode and the confound is hidden.
      anchor: |
        fingerprint:             # hash of the above; arms must match
      evidence: templates/run-record.yaml:19-26
    - reason: configuration.instructionsProvenLoaded is a boolean that cannot represent "preflight was never attempted"
      wrong_action: A researcher filtering `instructionsProvenLoaded == false` to find runs with broken instruction loading conflates "preflight not supported by this harness" with "preflight ran and instructions not found," inflating the failure count and treating two different operational states as one.
      anchor: |
        instructionsProvenLoaded: false    # preflight assertion result
      evidence: templates/run-record.yaml:31
    - reason: measurement.exclusionReason says "structured, registered in advance" but the field is scalar-shaped and no structure is provided
      wrong_action: Reviewer A writes "model_usage_limit" (free string), Reviewer B writes {code: "M01", detail: "..."} (object); a query grouping exclusions by reason code returns strings from some runs and object fields from others, and the "registered in advance" set has no visible home so two reviewers can't agree on whether a novel reason is allowed.
      anchor: |
        exclusionReason:         # structured, registered in advance
      evidence: templates/run-record.yaml:78
    - reason: task.revision has no definition of when it increments
      wrong_action: Two reviewers record the same run differently after a task-spec wording tweak that landed in the same benchmarkSha commit — one increments revision to 2 because the spec text changed, the other keeps it at 1 because the sha already captures the change; a downstream diff grouping by (id, revision) treats them as different tasks.
      anchor: |
        revision: 1
      evidence: templates/run-record.yaml:5
    - reason: harness.version and harness.runnerCommit are side by side with no comment on either
      wrong_action: A cross-run join on harness.version matches runs on different commits (one reviewer puts semver in version and the git sha in runnerCommit; another puts the sha in version because their harness has no release tags) or misses runs on the same commit — silently, because nothing executes the split.
      anchor: |
        version:
        runnerCommit:
      evidence: templates/run-record.yaml:10-11
  non_blocking:
    - reason: evaluation.failureClass references an "F01-F15" taxonomy that is not defined or linked in this artifact; a reviewer has to find it externally or guess
      evidence: templates/run-record.yaml:72
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 89s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| task | 1/1 | L3 |
| harness | 1/1 | L3 |
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
**Verdict:** finding
**Failure:** Two reviewers record the same run after a task-spec wording tweak that landed in the same `benchmarkSha` commit. One increments `revision` to 2 because the spec text changed; the other leaves it at 1 because the commit sha already captures the change and "revision" must mean something orthogonal to the commit. The same run gets two different `task.revision` values, and a downstream diff that groups by `(id, revision)` treats them as different tasks.
**Layer of the implied fix:** L3
**Anchor:** `  revision: 1`

### harness
**Verdict:** finding
**Failure:** The template has `version` and `runnerCommit` side by side with no comment on either. Reviewer A puts the semver tag in `version` and the git sha in `runnerCommit`. Reviewer B, working with a harness that has no release tags, puts the git sha in `version` and leaves `runnerCommit` blank. A cross-run comparison that joins on `harness.version` now matches two runs on different commits, or misses two runs on the same commit.
**Layer of the implied fix:** L3
**Anchor:** `  version:` / `  runnerCommit:`

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** `fingerprint` is documented as "hash of the above" but the above includes five list fields (`hooks`, `plugins`, `skills`, `mcpServers`, `settingsSources`). Two arms with identical environments but different list-ordering in their source files produce different fingerprints, failing the "arms must match" check for a run that should pass. Conversely, an arm that silently drops `permissionMode` from the hash input produces a matching fingerprint against an arm with a different permission mode, masking a real confound.
**Layer of the implied fix:** L3
**Anchor:** `  fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is a boolean defaulting to `false`. A run where the preflight assertion never executed (the harness doesn't support preflight) and a run where the preflight executed and the instructions were not found both record `false`. A downstream analysis that filters on `instructionsProvenLoaded == false` to find "runs with broken instruction loading" now includes runs where loading was never attempted, inflating the failure count and conflating two different operational states.
**Layer of the implied fix:** L3
**Anchor:** `  instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a scalar-shaped field with a comment that says "permission requests — and whether anyone could answer." The comment describes two dimensions (count and answerability) but the field holds one value. Reviewer A records `3` (the count). Reviewer B records `{ requested: 3, answered: 0 }`. Reviewer C records `null` because they couldn't tell what shape to use and left it blank. A query that counts unanswered approvals across runs gets three different answers for the same run.
**Layer of the implied fix:** L3
**Anchor:** `  approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `acceptanceScore` and `finalScore` sit side by side with no comment distinguishing them. Reviewer A treats `acceptanceScore` as the gate verdict (pass/fail) and `finalScore` as the rubric total. Reviewer B, seeing no distinction, records the rubric total in both. A downstream query that uses `acceptanceScore` to filter gate-passing runs now either gets a numeric range instead of a boolean, or gets the rubric score double-counted as both the gate and the result — the same field means two different things across records.
**Layer of the implied fix:** L3
**Anchor:** `  acceptanceScore:` / `  finalScore:`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is commented "structured, registered in advance" but the field is scalar-shaped and no structure is defined. Reviewer A writes `"model_usage_limit"` (a free string). Reviewer B writes `{ code: "M01", detail: "codex hit usage limit mid-session" }` (an object). A query that groups exclusions by reason code gets strings from some runs and object fields from others, and the "registered in advance" set has no visible home — two reviewers can't agree on whether a novel reason is allowed.
**Layer of the implied fix:** L3
**Anchor:** `  exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.acceptanceScore` and `evaluation.finalScore` are the risk. If `acceptanceScore` is the gate verdict and `finalScore` is the rubric score, they are distinct — but the template never says so, and a reviewer who fills both with the rubric total has silently turned the gate into a constant across gate-passing runs, which is the exact defect that killed the seven-category rubric described in CLAUDE.md.
- **Which section would two reviewers diverge on most?** `behavior.approvals` — the field shape is completely unspecified (scalar vs object vs list), and the comment describes two dimensions that cannot fit in one scalar. I would expect the widest divergence here, by a large margin.
- **What did the artifact not say that it needed to say?** Three things: (1) the canonical input and ordering for `environment.fingerprint` — without it, "arms must match" is unenforceable; (2) the `failureClass` taxonomy F01–F15 is referenced but neither defined nor linked, so a filler who hasn't read the external doc is guessing; (3) the distinction between `acceptanceScore` and `finalScore` — the two most consequential numbers in the record are undifferentiated.
