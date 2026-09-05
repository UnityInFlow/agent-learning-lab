# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T115350Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        4b28fb0
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 47s |

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
| configuration | 1/1 | L2 |
| behavior | 1/1 | L2 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L2 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two completed records both use `B0-COPILOT-BE001-001`; one reviewer treats the second as a retry of the same run, while another treats it as a duplicate to discard. A results import keyed by `runId` can also overwrite one record.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A record is committed with `id: BE-001`, `revision: 1`, and an empty `benchmarkSha`. One reviewer accepts the revision as sufficient; another rejects the run because the exact task and evaluator cannot be reproduced.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs report `name: github-copilot-cli` but leave `version` and `runnerCommit` blank; between them, the CLI changes tool-call handling. One reviewer pools the runs because the names match, while another excludes them as incomparable.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run leaves `requested` and `resolved` blank. One reviewer groups it with the requested `haiku` arm from the experiment plan; another marks the model unknown because no telemetry resolution is recorded, producing different arm-level results.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** One recorder hashes the YAML serialization of the environment while another hashes a sorted JSON serialization; identical environments receive different fingerprints and fail the stated arm-match rule. Conversely, the artifact does not identify which fields and normalization feed the hash, so reviewers cannot independently verify a match.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For `instructionsProvenLoaded: false`, one reviewer interprets the run as a valid no-instructions control because `instructions: none`; another interprets it as a failed preflight and invalidates the run. The field does not distinguish “not applicable” from “assertion failed.”
**Layer of the implied fix:** L2
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A recorder writes `filesRead: 12`, while another writes `filesRead: ["a.py", "b.py"]`; both readings are plausible because the template provides no type or unit. Reviewers then compute incompatible behavior summaries—count versus file identities.
**Layer of the implied fix:** L2
**Anchor:** filesRead:
  filesChanged: []
  commands: []

### efficiency
**Verdict:** finding
**Failure:** A record contains `{ value: null, source: provider, estimated: false }`. The named validator is only said to reject bare numbers, so one reviewer accepts this as provider-confirmed missing usage while another rejects it as internally inconsistent provenance. Cost also has no stated currency, so `value: 1.20` can mean dollars or another billing unit.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** Two reviewers receive `acceptanceScore: 0.8` and `finalScore: 80`; one treats both as equivalent percentages, while another treats them as values on distinct unspecified scales. The record can therefore yield different pass/fail or ranking outcomes from the same values.
**Layer of the implied fix:** L2
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record uses `status: excluded` with `exclusionReason: timeout` even though no registered reason list is present. One reviewer accepts the prose token as pre-registered; another treats it as an unregistered post-hoc exclusion. The status values and structured-reason requirement exist only as comments, so nothing shown executes and rejects either interpretation.
**Layer of the implied fix:** L3
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** `evaluation.compile`, `evaluation.tests`, and `evaluation.hiddenTests` can operate as pass/fail gates while `evaluation.finalScore` can score the same outcomes again; because the final-score formula is absent, one reviewer may double-count test success and another may not. Reviewers are most likely to diverge on `evaluation`: for the concrete values `acceptanceScore: 0.8` and `finalScore: 80`, they can differ by a factor of 100 in the interpreted score and can reach opposite pass/fail decisions. The artifact needed to state executable validation and semantics for requiredness, types, units, score ranges/formula, fingerprint construction, uniqueness, nullability, and registered exclusion reasons; without those, most comments remain guidance rather than controls.
**Layer of the implied fix:** L2
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

