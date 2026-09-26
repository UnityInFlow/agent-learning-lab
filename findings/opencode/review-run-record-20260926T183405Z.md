# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260926T183405Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        3d6b9ff
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 46s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L3 |
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
**Failure:** Given `B0-COPILOT-BE001-001`, one reviewer can treat `B0` as the benchmark version and `001` as the replicate, while another can treat `B0-COPILOT` as the arm and `BE001-001` as an opaque suffix. They will group the same run differently because the identifier grammar and uniqueness scope are unstated.
**Layer of the implied fix:** L3
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A record can contain `revision: 1` with an empty `benchmarkSha` after the evaluator changes. One reviewer can accept the revision as sufficient provenance; another can exclude the run because the exact task/evaluator commit cannot be recovered.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs can both say `name: github-copilot-cli` while leaving `version` and `runnerCommit` empty, even though one runner includes a telemetry fix and the other does not. A reviewer can pool them by harness name, while another excludes them as non-reproducible.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** An alias such as `haiku` can resolve to model A in one run and model B in another while `resolved` remains blank. One reviewer can compare the runs by requested alias; another can reject the comparison because silent alias drift cannot be ruled out.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two semantically identical records can list `hooks` or `plugins` in different orders. Without a canonical serialization rule, one implementation can produce different fingerprints while another sorts the lists and produces the same fingerprint, causing reviewers to disagree about whether the arms matched.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run can specify non-`none` instructions with an empty `instructionsHash` and `instructionsProvenLoaded: false`, yet still be recorded. One reviewer can retain it as a treatment run; another can invalidate it because neither treatment identity nor successful loading was established.
**Layer of the implied fix:** L2
**Anchor:** instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** For a run with unavailable tool telemetry, `toolCalls` can be left blank while `toolsUsed: []`. One reviewer can read this as zero tool calls; another can read it as unknown telemetry, producing different behavioral comparisons for the same record.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** The documented shape permits a contradictory entry such as `{ value: null, source: provider, estimated: false }`. The only stated executable check rejects bare numbers, so one reviewer can accept this as provider-reported missing data while another rejects it because a provider provenance claim accompanies no value.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** For a run with all tests passing but one unintended file change, one reviewer can assign `acceptanceScore: 1` and `finalScore: 1`; another can assign `acceptanceScore: 100` and reduce `finalScore` because of the unintended change. No scale or aggregation rule selects between those answers.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record can use `status: excluded` with `exclusionReason: slow run`, even if that reason was not registered before execution. One reviewer can accept the free-text explanation; another can reject it because the record contains no structured reason code or reference proving preregistration.
**Layer of the implied fix:** L2
**Anchor:** exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category duplicates a pass/fail gate because this artifact defines no scoring categories or explicit pass/fail gates. Reviewers are most likely to diverge on `evaluation`: the same outcome can receive incompatible `acceptanceScore` and `finalScore` values, including 1 versus 100, because scales and aggregation are absent. The artifact also does not state which blank fields mean unknown, which are optional, or which executable validator rejects incomplete and internally inconsistent records.
**Layer of the implied fix:** L2
**Anchor:** evaluation:
  compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

