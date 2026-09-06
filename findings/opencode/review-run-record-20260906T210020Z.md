# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260906T210020Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        58154f7
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
| configuration | 1/1 | L3 |
| behavior | 1/1 | L2 |
| efficiency | 1/1 | L1 |
| evaluation | 1/1 | L2 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records from separate reruns both retain `B0-COPILOT-BE001-001`; one reviewer treats them as duplicate measurements and drops one, while another treats the identifier as a descriptive label and includes both.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A run is executed after the benchmark changes from commit A to commit B, but `benchmarkSha` remains blank. One reviewer resolves `BE-001` at the current checkout B; another assumes revision 1 refers to A, producing different task and evaluator provenance for the same record.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs use different Copilot CLI versions or runner commits while both fields remain blank. One reviewer considers the arms comparable because `name` matches; another excludes them because harness equivalence cannot be established.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run requests alias `haiku`, which resolves to model version X today and Y tomorrow, but both model fields remain blank. One reviewer groups the runs under the requested alias; another treats the resolved models as distinct experimental conditions.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Arm A loads plugin P and arm B does not, yet both records leave `fingerprint` blank. One reviewer compares the visible lists and rejects the mismatch; another relies on the stated fingerprint rule, sees equal blank values, and accepts the arms as matching.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For a baseline with `instructions: none`, `instructionsProvenLoaded` remains `false`. One reviewer interprets false as expected because there were no instructions to load; another interprets it as a failed preflight assertion and invalidates the run.
**Layer of the implied fix:** L3
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run makes zero tool calls and leaves `toolCalls` blank, while another run loses tool telemetry and also leaves it blank. One reviewer converts both blanks to zero; another treats both as missing, changing efficiency comparisons and telemetry-completeness judgments.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:

### efficiency
**Verdict:** finding
**Failure:** Two records contain `cost: { value: 1.00, source: provider, estimated: false }`, one reported in USD and one in EUR. A reviewer who assumes USD compares them directly; a reviewer who infers provider billing currency converts one first, yielding different cost rankings.
**Layer of the implied fix:** L1
**Anchor:** cost:                { value: null, source: null, estimated: null }

### evaluation
**Verdict:** finding
**Failure:** Reviewer A records `acceptanceScore: 0.8` on a 0–1 scale; reviewer B records `acceptanceScore: 80` on a 0–100 scale for identical output. Both records fit the template, but aggregation makes the second run appear 100 times better.
**Layer of the implied fix:** L2
**Anchor:** acceptanceScore:

### measurement
**Verdict:** finding
**Failure:** A run with missing token telemetry is marked `valid` by one reviewer because task evaluation completed, while another marks it `excluded` because `telemetryComplete` is false. The template supplies statuses but no rule connecting telemetry gaps to status.
**Layer of the implied fix:** L3
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** No concrete input or diff in the supplied evidence makes the free-form notes instruction produce a wrong answer or force two competent reviewers into different required classifications.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is defined, so no duplication with a pass/fail gate can be established from this artifact. Reviewers would diverge most on `evaluation`: the same 8-of-10 result could be entered as `0.8`, `8`, `80`, or as a boolean under `tests`, producing up to a 100× score difference. The artifact needed to state field types, units and score scales; missing-value semantics; aggregation rules; validity/exclusion rules; and which executable validator enforces each constraint.
**Layer of the implied fix:** L2
**Anchor:** evaluation:
  compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

