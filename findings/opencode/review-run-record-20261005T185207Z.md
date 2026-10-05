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
reviewed_utc:    20261005T185207Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        64d8272
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A run-record template whose comments and absent types let two faithful reviewers record the same run differently; approvals, failureClass, and fingerprint are the load-bearing cases, because the wrong record changes downstream aggregates and cross-run matching.
  blocking:
    - reason: The `approvals` field is documented as "permission requests — and whether anyone could answer" — two different quantities in one field with no type. Reviewer A records `3` (requests), Reviewer B records `0` (answered), Reviewer C records `{requested: 3, answered: 0}`. A consumer parsing the YAML as a scalar fails on C; a consumer computing approval rate divides by the wrong denominator on A and B.
      wrong_action: A consumer aggregating approval rates across runs reads `3` as the count when the actual answered count is `0`, producing a 100% approval rate for a run where no one answered any request — and the YAML parse on the object variant fails outright, taking the whole record with it.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: `failureClass` is documented as `# F01-F15` but the taxonomy is not in this artifact. A reviewer working from the template alone cannot classify a failure correctly; a reviewer with the taxonomy may still guess the wrong slot.
      wrong_action: One reviewer classifies a compile failure as F01; another classifies the same failure as F07. A downstream analysis grouping by `failureClass` splits one logical failure into two buckets and understates the count of either, so the experiment's failure-mode distribution is wrong.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: The `fingerprint` comment "hash of the above; arms must match" uses "arms" without definition, and "the above" is ambiguous about whether empty-list fields (e.g. `hooks: []`) are included in the hash input. Two reviewers hash different inputs and produce different fingerprints for identical environments.
      wrong_action: A cross-run equality check using fingerprint rejects a match between two runs with identical environments, marking the run as anomalous when it is not — and the same mismatch, reproduced systematically, makes every cross-run check untrustworthy.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
  non_blocking:
    - reason: `runnerCommit` has no comment. A reviewer may fill it with the commit of `tools/` (the runner scripts) or with the harness release tag; both are reasonable interpretations, and the structure (`harness.runnerCommit`) does not disambiguate.
      evidence: templates/run-record.yaml:11
    - reason: `task.revision` semantics are unclear — is `revision` the task revision or the benchmark revision? `benchmarkSha` is a separate field, but a reviewer could reasonably map `revision` to either, and a consumer grouping by `task.id` + `task.revision` could split one logical task into two groups across a benchmark bump.
      evidence: templates/run-record.yaml:4-6
    - reason: `instructionsProvenLoaded` defaults to `false`, which conflates "preflight ran and failed" with "preflight not run." A consumer filtering for "runs where instructions were proven absent" gets both. The field would benefit from a tri-state (true/false/null) or a comment clarifying the default.
      evidence: templates/run-record.yaml:31
    - reason: The validator referenced at line 60 (`validate-run-record.sh`) is not enumerated in the template. A reviewer filling from the template alone cannot tell which fields the validator enforces and which are free-form prose, so they cannot predict what will fail validation.
      evidence: templates/run-record.yaml:60
  disputed:
    - finding: "evaluation.compile and evaluation.tests restate the evaluator's own exit conditions… carry no information that distinguishes one admitted run from another."
      why: The run record captures all runs, including those that did not pass the evaluator's gate; a failed-compile run is still a valid record (with `measurement.status: invalidated` or similar). The fields are not constant across all *recorded* runs — they are constant only across *scored* runs, which is the rubric's concern, not the run record's. The structural defect the lab identified in the seven-category rubric applies to the rubric, not here.
    - finding: "telemetryComplete is a boolean. A run where token usage was reported but toolCalls was not captured is partially complete. Reviewer A records true, Reviewer B records false."
      why: The field is a high-level summary flag, not a per-field measurement. `false` means "this run has gaps" — which is honest. The principle "a gap must not read as a zero" applies to individual measurements (like `inputTokens`), where a null value would collapse to zero. `telemetryComplete: false` is a coarse filter, not a measurement, and correctly communicates that the run should not be used for analysis. A consumer wanting per-field completeness reads the individual `behavior.*` and `efficiency.*` fields, not this summary.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 105s |

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
**Failure:** The benchmark is updated to a new commit but the task definition (id BE-001) is unchanged. Reviewer A records `revision: 1` (the task didn't change) and `benchmarkSha: <new>`. Reviewer B records `revision: 2` (the benchmark revision bumped) and the same sha. A consumer grouping runs by `task.id` + `task.revision` to compare across the same task revision now sees two groups for one logical task, or one group spanning two benchmark versions — either way the grouping is wrong and the two reviewers' records are not mergeable.
**Layer of the implied fix:** L3
**Anchor:** `revision: 1`

### harness
**Verdict:** finding
**Failure:** `runnerCommit` has no comment. Reviewer A fills it with the git sha of `tools/` (the runner scripts that executed the run). Reviewer B fills it with the version-control commit of the harness itself (e.g. the copilot-cli release tag). A consumer trying to reproduce the run checks out the wrong repository and gets a different runner behavior. Both reviewers believe they recorded the right thing; nothing in the template disambiguates.
**Layer of the implied fix:** L3
**Anchor:** `runnerCommit:`

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** The `fingerprint` comment says "hash of the above; arms must match." "Arms" is undefined. Reviewer A interprets "arms" as the treatment-vs-control comparison arms and hashes all environment fields to verify the control run matches. Reviewer B interprets "arms" as a typo for "runs" and ignores it. Separately, "hash of the above" is ambiguous about whether empty-list fields (`hooks: []`) are included in the hash input — Reviewer A includes them, Reviewer B omits empty fields — producing different fingerprints for identical environments. A cross-run match check that relies on fingerprint equality now produces false mismatches.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is a boolean. Run A ran the preflight assertion and it failed (instructions were not loaded) → `false`. Run B never ran preflight at all (the harness doesn't support it) → also `false`. A consumer filtering for "runs where instructions were proven absent" gets both, but Run B carries no information about whether instructions loaded — it is an absence, not a negative result. This is the null-vs-zero collapse the lab's own `measurement.telemetryComplete` comment warns about, applied to a different field in the same artifact.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is commented "permission requests — and whether anyone could answer" but has no type. In a run where the agent requested 3 permissions and received 0 responses (unattended), Reviewer A records `approvals: 3`, Reviewer B records `approvals: { requested: 3, answered: 0 }`, Reviewer C records `approvals: 0` (interpreting "whether anyone could answer" as the answer count). A consumer comparing approval rates across runs divides by the wrong denominator or parses a YAML mapping where it expected a scalar. `retries` has the same shape problem (retries of what — model calls? tool calls?) but `approvals` is the more divergent one because the comment itself describes two different quantities in one field.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is commented `# F01-F15` but the fifteen classes are not defined in this artifact. Reviewer A has the taxonomy document and classifies a compile failure as F02. Reviewer B, working from the template alone, guesses F01 (the first compile-related code) or leaves it blank. Two records of the same run carry different failure classes, and a downstream analysis grouping by `failureClass` splits one failure into two buckets. Additionally, `compile` and `tests` have no type indicator — a reviewer could record `compile: true`, `compile: 0`, or `compile: "exit 1"` — but the failure-class gap is the one that produces a wrong aggregate, not just a parse error.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `telemetryComplete` is a boolean. A run where token usage was reported by the provider (Level A) but `behavior.toolCalls` was not captured by the harness is partially complete. Reviewer A records `telemetryComplete: true` (some telemetry is present). Reviewer B records `false` (not all fields are filled). A consumer using `telemetryComplete` as an inclusion filter for token-analysis either admits a run with missing tool-call data or drops a run with valid token data, depending on which reviewer filled the record. The artifact's own comment — "a gap must not read as a zero" — states the principle this field violates.
**Layer of the implied fix:** L3
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile` and `evaluation.tests` restate the evaluator's own exit conditions. If the evaluator already gates on compile-pass and test-pass (as the CLAUDE.md describes — "the rubric only scores gate-passing submissions"), then across every record the evaluator admits, `compile` is constant-true and `tests` is constant-true. They carry no information that distinguishes one admitted run from another. This is the same structural defect the lab identified in the seven-category rubric — a gate restated as a scoring field is a constant — now appearing as a recording field rather than a scoring category.
- **Which single section would two reviewers diverge on most, and by how much?** `evaluation`, by a wide margin. It combines three independent ambiguities — untyped `compile`/`tests`, an undefined fifteen-class taxonomy, and `acceptanceScore` with no scale or source — so two faithful reviewers filling the same run independently would likely disagree on at least two of the seven fields. `behavior` is second, driven solely by `approvals`.
- **What did the artifact not say that it needed to say?** It did not define: what `task.revision` counts (task vs. benchmark); what `harness.runnerCommit` points at; what "arms" means in the fingerprint comment; the F01–F15 failure-class taxonomy; the type of `compile`, `tests`, and `hiddenTests`; and which fields `validate-run-record.sh` actually enforces versus which are free-form. The validator is referenced once (line 60) but the template never tells the reader which fields it gates — so a person filling the record from the template alone is writing L3 prose next to an L2 checker they cannot see.
