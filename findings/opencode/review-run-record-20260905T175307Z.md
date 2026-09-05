# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T175307Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        e7b80f1
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 34s |

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
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two independently repeated runs both retain `B0-COPILOT-BE001-001`; one reviewer treats them as duplicate records and discards the second, while another treats the identifier as descriptive and includes both, changing the arm sample size.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** BE-001 revision 1 is evaluated once before and once after its evaluator changes, with `benchmarkSha` blank in both records. One reviewer groups the runs as the same task revision; another excludes the comparison because the resolved task/evaluator cannot be shown to match.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs have identical treatment data but blank `version` and `runnerCommit`; the runner changed permission handling between them. One reviewer attributes the outcome difference to the treatment, while another classifies it as harness drift.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Two records request `haiku`; the alias resolves to different model versions, but `resolved` remains blank. One reviewer compares them as the same model, while another rejects the comparison because model identity is unknown.
**Layer of the implied fix:** L2
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Arm A loads plugin X and arm B does not, but both records leave `fingerprint` blank. One reviewer accepts the arms because the empty fingerprints match textually; another compares the listed environment fields and rejects them as mismatched.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A completed run records non-`none` instructions while `instructionsProvenLoaded` remains `false`. One reviewer scores the run as a treatment run; another excludes it because the registered treatment was not proven active.
**Layer of the implied fix:** L2
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A record contains two entries in `toolsUsed` but leaves `toolCalls` blank. One reviewer interprets the blank as unknown telemetry; another coerces it to zero and reports a zero-tool-call run despite the contradictory list.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** `inputTokens` is recorded as `{ value: null, source: provider, estimated: false }`. It is not a bare number, so the only stated rejection does not clearly catch it; one reviewer treats it as provider-confirmed zero/absence, while another treats it as missing usage and excludes efficiency comparisons.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** A run compiles and passes visible tests but fails hidden tests; `acceptanceScore` is 0.8 and `finalScore` is 0.8. One reviewer treats `finalScore` as the authoritative aggregate and passes it, while another treats hidden-test failure as a gate and fails it because no aggregation or precedence rule is stated.
**Layer of the implied fix:** L3
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record has `status: valid`, `telemetryComplete: false`, and a blank `exclusionReason`. One reviewer includes it because status is authoritative; another excludes it because incomplete telemetry contradicts validity.
**Layer of the implied fix:** L2
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** No concrete input or diff in the supplied evidence makes two competent reviewers necessarily interpret the free-form observational notes differently in a way that changes a recorded measurement.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** The artifact does not establish whether `evaluation.hiddenTests` is a pass/fail gate duplicated by or feeding `evaluation.finalScore`; for the same run (`hiddenTests: false`, `finalScore: 0.8`), one reviewer fails the run and another accepts the numeric score. Reviewers would diverge most on `evaluation`, potentially by the full pass/fail outcome. The artifact also does not say which fields are mandatory for each `measurement.status`, how blanks differ from zero or unknown outside the usage tuples, how `finalScore` is derived, or which contradictions must invalidate a record.
**Layer of the implied fix:** L2
**Anchor:** hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

