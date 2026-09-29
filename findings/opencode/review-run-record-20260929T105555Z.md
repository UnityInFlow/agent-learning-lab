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
reviewed_utc:    20260929T105555Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        64a1254
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template defines five fields whose contract two people will execute differently — fingerprint, approvals, durationMs, evaluation results, and exclusionReason — so run records produced from it are not comparable by construction, and the lab's own history (60%-of-weight restating a gate; the fingerprint "must match" check that no procedure backs) names exactly this defect shape as a prior cost.
  blocking:
    - reason: fingerprint has no procedure
      wrong_action: Two reviewers hash the environment fields with different procedures (e.g. SHA-256 of canonicalised JSON vs MD5 of colon-joined values) and report an environment mismatch on runs whose underlying `bare`, `permissionMode`, `hooks`, `plugins`, `skills`, `mcpServers`, `settingsSources` arrays are byte-identical — a false positive on the one field whose stated job is to catch real mismatches, costing the run pair.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: approvals holds two facts in one untyped field
      wrong_action: A reviewer reading "permission requests — and whether anyone could answer" as "requests the agent made" records `approvals: 3` for a run in `acceptEdits` mode; a reviewer reading it as "approvals a human actually granted" records `approvals: 0` from the same run. An analysis correlating approval friction with run outcome flips sign across the two recorders on the same evidence.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: durationMs lacks the provenance structure that token fields have
      wrong_action: A hung run killed at the 600s timeout is recorded as `durationMs: 600000` by one reviewer (the kill timeout, as an estimate) and as `durationMs: null` by another (the runner never returned). Token fields directly below (lines 61-65) already carry `{value, source, estimated}` so "nobody knows" is visible; durationMs is the documented exception, so a null and a 600000 both sit beside a real 10000ms run with no template-level way to tell them apart, and the comment "The runner always knows this one" is what gets quoted when the runner does not.
      anchor: "durationMs:              # wall clock. The runner always knows this one."
      evidence: templates/run-record.yaml:49
    - reason: evaluation result fields are untyped and acceptanceScore/finalScore are indistinguishable
      wrong_action: On the same run — zero compile errors, 8 of 8 tests, 8 of 8 hidden tests — one reviewer records `compile: true, tests: true, hiddenTests: true` (booleans, "it passed") and another records `compile: 0, tests: 8, hiddenTests: 8` (counts). A downstream filter on `tests == true` works on the first set and silently drops the second; a sum produces `true + 8` across the union. `acceptanceScore` and `finalScore` follow on the next two lines with no comment, so a reviewer cannot tell whether one is the gate's binary result and the other is the rubric's weighted score, or whether both are rubric outputs, and downstream analysis treats them differently in the two cases.
      anchor: "compile:\n  tests:\n  hiddenTests:\n  acceptanceScore:\n  finalScore:"
      evidence: templates/run-record.yaml:68-72
    - reason: exclusionReason claims structure but defines none
      wrong_action: One reviewer records `exclusionReason: {code: telemetry-gap, detail: "inputTokens missing"}`; another records `exclusionReason: "telemetry-gap"`. Downstream grouping by `.code` works on the first set and throws on the second. The comment "structured, registered in advance" implies a registry of valid reasons exists somewhere, but the template names neither the structure nor the registry, so the two reviewers cannot discover the same set of valid values.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
  non_blocking: []
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 115s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| environment | 1/1 | L3 |
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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** Two arms of the same experiment are filled in by different people. Both have identical `bare`, `permissionMode`, `hooks`, `plugins`, `skills`, `mcpServers`, and `settingsSources` values. Reviewer A serializes the environment as sorted JSON and hashes with SHA-256; Reviewer B concatenates the string values with `:` and hashes with MD5. The fingerprints differ. The comparison reports an environment mismatch where none exists, and the run pair is dropped or flagged as confounded — a false positive on the single field whose stated purpose is to detect real mismatches.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### behavior
**Verdict:** finding
**Failure:** A run executes in `acceptEdits` mode. The agent attempts three operations that, in `default` mode, would prompt for human approval; in `acceptEdits` they are auto-approved and no human is in the loop. Reviewer A records `approvals: 3`, reading the comment as "count of permission requests the agent made." Reviewer B records `approvals: 0`, reading it as "count of approvals a human actually granted." Both are faithful to the comment, which says *"permission requests — and whether anyone could answer"* but provides a single untyped field for two distinct facts. A downstream analysis correlating approval friction with run outcome gets opposite signals from the same run.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** A run hangs and is killed after the `LAB_REVIEW_TIMEOUT` window (600s). The runner did not return a clean duration. Reviewer A records `durationMs: 600000` (the kill timeout, as an estimate). Reviewer B records `durationMs:` (null, because the runner never reported). Every token field has a Level C structure — `{ value: null, source: null, estimated: null }` — that makes "nobody knows" visible and distinguishable from "not filled in yet." `durationMs` has no such structure. A null duration reads identically to a forgotten field, and a timeout-as-duration reads as a measured 600-second run. Two reviewers, two different measurements of the same event, with no template-level way to tell them apart.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** The fields `compile`, `tests`, and `hiddenTests` carry no type. On the same run — which compiled with zero errors and passed 8 of 8 tests — Reviewer A records `compile: true, tests: true, hiddenTests: true` (booleans, "it passed"). Reviewer B records `compile: 0, tests: 8, hiddenTests: 8` (integer counts: zero errors, eight passed). A downstream parser that filters on `tests == true` works for A's records and silently drops B's; one that sums `tests` works for B and produces `true + 8` for A. Separately, `acceptanceScore` and `finalScore` appear side by side with no comment distinguishing them — a reviewer who does not know the lab's gate-vs-rubric convention cannot tell whether they are the same value recorded twice or two different scores, and the template gives no help.
**Layer of the implied fix:** L3
**Anchor:** `compile:` / `tests:` / `hiddenTests:` / `acceptanceScore:` / `finalScore:`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is commented as *"structured, registered in advance"* but the template defines no structure and names no registry. A run is excluded for a telemetry gap. Reviewer A records `exclusionReason: { code: telemetry-gap, detail: "inputTokens missing" }`. Reviewer B records `exclusionReason: "telemetry-gap"`. Downstream analysis that groups exclusions by `.code` works for A's records and throws on B's. The phrase "registered in advance" implies the valid reasons exist somewhere before the run, but the template does not reference where, so two reviewers cannot discover the same set.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile` and `evaluation.tests` restate what the benchmark evaluator already determines — the same results that the gate uses to admit or reject a submission. If the run record is only ever populated for gate-passing runs, these fields are constants, identical to the defect that killed the seven-category rubric (60% of weight carrying no information). The template does not say whether these are the evaluator's raw outputs or an independent re-check, so two reviewers may treat them as either redundant or corroborating.
- **Which single section would two reviewers diverge on most, and by how much?** `behavior.approvals`. The comment explicitly names two facts — request count and answerability — and the field holds one. Every other ambiguous field is ambiguous about *type*; this one is ambiguous about *which measurement to record*. I would expect divergence on every run that used a non-default permission mode, and agreement only on runs where the answer is unambiguously zero.
- **What did the artifact not say that it needed to say?** The template does not specify the fingerprint algorithm or the serialization it hashes, so "arms must match" is a comparison between two values computed by an unspecified procedure. It does not give `durationMs` the same provenance structure it gives every token field, creating an asymmetry that makes a missing duration invisible. And it does not define the structure that `exclusionReason` claims to have, leaving "structured, registered in advance" as an assertion with no referent.
