# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T171205Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        107c3c8
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 32s |

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
| measurement | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records from separate reruns can both retain `B0-COPILOT-BE001-001`; one reviewer treats them as duplicate copies and drops one, while another treats them as two observations, changing the sample size and aggregate result.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A run can record `id: BE-001`, `revision: 1`, and a blank `benchmarkSha`. If the evaluator changes while the revision remains 1, one reviewer resolves the current evaluator and another resolves the evaluator used at run time, potentially assigning different test outcomes to the same run.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs can both say `name: github-copilot-cli` while leaving `version` and `runnerCommit` blank, even if one used a runner commit containing the referenced harness bug and the other used its fix. A reviewer may pool them as equivalent while another excludes the affected run.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run may leave `resolved` blank after requesting `haiku`. If that alias points to model A on Monday and model B on Friday, one reviewer groups both runs under the requested alias while another marks the Friday run incomparable because the actual model is unknown.
**Layer of the implied fix:** L2
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two arms can contain identical listed arrays and the same manually copied `fingerprint`, while differing in an unlisted loaded influence such as an environment variable or system instruction. One reviewer accepts the fingerprint as proof that environments match; another rejects comparability because “everything that loaded” does not define a closed set of inputs.
**Layer of the implied fix:** L2
**Anchor:** environment:               # everything that loaded but was not the treatment

### configuration
**Verdict:** finding
**Failure:** A treatment run can set `instructions: none` while also leaving `instructionsHash` blank and `instructionsProvenLoaded: false`. One reviewer classifies it as a valid no-instructions control; another classifies it as a failed preflight because the record does not distinguish intentional absence from instructions that failed to load.
**Layer of the implied fix:** L2
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run that made zero model calls and a run whose model-call telemetry was unavailable can both have blank `modelCalls`; likewise, blank `toolCalls`, `filesRead`, and `retries` conflate zero with unknown. One reviewer records zero activity and computes favorable efficiency ratios, while another treats the behavior data as missing.
**Layer of the implied fix:** L2
**Anchor:** modelCalls:
  toolCalls:

### efficiency
**Verdict:** finding
**Failure:** The stated validator rejects a bare number, but the artifact does not say that it rejects inconsistent provenance tuples. For `{ value: 12400, source: null, estimated: false }`, one implementation accepts the mapping because it is not a bare number, while another rejects it because a non-null value lacks provenance; downstream reviewers then respectively treat 12,400 as measured or invalid.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** Given `compile: true`, `tests: 8/10`, `hiddenTests: 0/2`, `acceptanceScore: 0.8`, `unintendedChanges: true`, and `finalScore: 0.8`, one reviewer accepts the recorded final score while another treats hidden-test failure or unintended changes as a pass/fail gate and assigns failure. No aggregation or precedence rule determines the answer.
**Layer of the implied fix:** L2
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record can set `status: valid`, leave `telemetryComplete` blank, and provide Level C token values. One reviewer includes it because “valid” controls inclusion; another excludes it because incomplete telemetry makes the efficiency result unusable. The fields have no stated precedence.
**Layer of the implied fix:** L2
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** `evaluation.compile`, `evaluation.tests`, and `evaluation.hiddenTests` look like possible pass/fail gates while `evaluation.finalScore` can encode the same outcome, but their relationship is unstated. For a run with failed hidden tests and `finalScore: 0.8`, reviewers can report failure versus 0.8. The greatest expected divergence is in `evaluation`: reviewers could differ by the full result range, from failure/0 to 0.8 (or whatever maximum the undefined score scale permits). The artifact also never states field types, allowed nullability, score scales, denominator conventions, required-field rules, cross-field invariants, or which executable validator enforces the record beyond rejecting bare efficiency numbers.
**Layer of the implied fix:** L2
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

