# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260904T100831Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        5d998c7
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 40s |

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
| behavior | 1/1 | L1 |
| efficiency | 1/1 | L1 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records both use `B0-COPILOT-BE001-001`; one is the original run and one is a rerun. One reviewer treats the second record as an overwrite, while another treats it as a separate observation, producing different run counts.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** Two runs both report `id: BE-001` and `revision: 1`, but one resolved the evaluator from commit A and the other from commit B. With `benchmarkSha` blank, a reviewer pools them while another excludes the second run as incomparable.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Run A uses a runner revision before a command-capture bug was fixed and run B uses the revision after it, but both leave `version` and `runnerCommit` blank. One reviewer compares their tool-use counts; another invalidates the comparison.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Two runs request the alias `haiku` on different dates after the alias is repointed, but both leave `resolved` blank. One reviewer groups them as the same model; another treats the underlying models as different arms.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** One run loads a global settings source that enables an MCP server while another does not, yet both retain empty arrays and a blank `fingerprint`. One reviewer accepts the arms as matched; another identifies environmental contamination and rejects the comparison.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For a control run with `instructions: none`, `instructionsProvenLoaded` remains `false`. One reviewer interprets this as the correct result because there were no instructions to load; another interprets it as a failed preflight and invalidates the run.
**Layer of the implied fix:** L1
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run makes zero model calls because the harness fails before invocation; another makes calls but telemetry capture fails. Both can have blank `modelCalls` and `toolCalls`. One reviewer converts blanks to zero while another treats them as missing, yielding different efficiency conclusions.
**Layer of the implied fix:** L1
**Anchor:** modelCalls:
  toolCalls:

### efficiency
**Verdict:** finding
**Failure:** Two records contain `cost.value: 0.10`; one provider reports USD and another reports EUR, or one reports dollars while another reports cents. Both satisfy the shown provenance shape, but reviewers calculate different costs because no currency or unit is represented.
**Layer of the implied fix:** L1
**Anchor:** cost:                { value: null, source: null, estimated: null }

### evaluation
**Verdict:** finding
**Failure:** A run has `acceptanceScore: 7` and `finalScore: 7`. One reviewer reads this as 7/10 and passing; another reads it as 7/100 and failing. The artifact provides neither scale nor threshold, so the run receives incompatible conclusions.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record uses `status: excluded` and `exclusionReason: flaky`. One reviewer accepts `flaky` as structured and preregistered based on local knowledge; another rejects it because the record contains no taxonomy value or registration reference. Nothing identified here executes to settle that disagreement.
**Layer of the implied fix:** L3
**Anchor:** exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category can be conclusively identified as duplicating a pass/fail gate because `compile`, `tests`, `hiddenTests`, `acceptanceScore`, and `finalScore` have no defined semantics or aggregation relationship. `evaluation` is the section on which reviewers would diverge most: the same score can be treated as passing or failing, a full verdict reversal. The artifact needed executable completeness rules for identity and provenance fields, explicit missing-versus-zero representation for behavior data, cost denomination, evaluation scales and aggregation rules, and an identifiable preregistered exclusion taxonomy.
**Layer of the implied fix:** L2
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

