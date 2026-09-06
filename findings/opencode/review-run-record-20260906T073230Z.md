# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260906T073230Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        3047ef6
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
| runId | 1/1 | L3 |
| task | 1/1 | L3 |
| harness | 1/1 | L3 |
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two runs with identical `runId: B0-COPILOT-BE001-001` can both be recorded because no uniqueness mechanism or identifier grammar is specified. One reviewer may treat the duplicate as a retry of the same run; another may treat it as an accidental collision and exclude it.
**Layer of the implied fix:** L3
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** Given `id: BE-001`, `revision: 1`, and a blank `benchmarkSha`, one reviewer can resolve revision 1 from the current checkout while another resolves it from an earlier commit. They can execute different task or evaluator content while labeling both records identically.
**Layer of the implied fix:** L3
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** A record with blank `version` and `runnerCommit` cannot distinguish runs before and after a harness behavior change. One reviewer may pool the runs because `name` matches; another may separate them because the executable provenance is unknown.
**Layer of the implied fix:** L3
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** For a run requested as `haiku` whose telemetry reports no model identifier, one reviewer may infer the currently mapped Haiku model while another marks model identity unknown. The resulting run can be grouped under a concrete model or excluded from that comparison.
**Layer of the implied fix:** L3
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two records can both carry the same manually entered `fingerprint` while differing in `permissionMode` or loaded plugins because nothing shown computes or verifies the hash. One reviewer may accept them as matched arms; another may recompute the environment and reject the comparison.
**Layer of the implied fix:** L3
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run can state `instructions: none` while also leaving `instructionsHash` blank and setting `instructionsProvenLoaded: false`. One reviewer may classify it as a valid no-instructions control; another may interpret the false preflight result as an invalid run because the intended configuration was not proven.
**Layer of the implied fix:** L3
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run with blank `toolCalls` and `toolsUsed: []` can mean either zero tool calls or missing telemetry. One reviewer may score it as a tool-free run; another may treat tool behavior as unknown.
**Layer of the implied fix:** L3
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** The stated validator rejects a bare number, but the artifact does not say it rejects contradictory objects such as `{ value: 12400, source: provider, estimated: true }` or `{ value: null, source: provider, estimated: false }`. If accepted, one reviewer can treat the first as provider truth while another treats `estimated: true` as an estimate; the second can be read as missing usage or a provider-reported null.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** For `compile: false`, `tests: 8/10`, `hiddenTests: 0/2`, and `acceptanceScore: 0.8`, the artifact gives no definition or aggregation rule for `finalScore`. One reviewer may assign zero because compilation failed; another may calculate a nonzero score from the test and acceptance results.
**Layer of the implied fix:** L3
**Anchor:** finalScore:

### measurement
**Verdict:** finding
**Failure:** A record can set `status: valid`, leave `telemetryComplete` blank, and give no `exclusionReason`. One reviewer may retain it because status is valid; another may exclude it because telemetry completeness is unknown.
**Layer of the implied fix:** L3
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** No concrete input or diff makes the free-form notes field itself produce a wrong measurement or force divergent classification; it is explicitly a place for surprising observations rather than a scored control.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is defined precisely enough to establish duplication with a pass/fail gate; `compile` and `tests` may be gates or score inputs, while `acceptanceScore` and `finalScore` may duplicate them, but the artifact does not say. Reviewers would diverge most on `evaluation`: for a compile failure with 8/10 visible tests, 0/2 hidden tests, and acceptance 0.8, plausible final scores range from 0 to 0.8. The artifact needed executable validation and semantics for requiredness, null-versus-zero, allowed values, cross-field consistency, provenance, identifier uniqueness, fingerprint computation, exclusion handling, and final-score aggregation.
**Layer of the implied fix:** L2
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

