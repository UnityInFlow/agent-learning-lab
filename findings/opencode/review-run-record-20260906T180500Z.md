# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260906T180500Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        14e2121
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 39s |

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
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records can both use `B0-COPILOT-BE001-001` for separate executions. One reviewer treats the second as a retry overwriting the first; another treats both as independent samples, changing sample size and aggregate results.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A record with `id: BE-001`, `revision: 1`, and blank `benchmarkSha` can be evaluated after the benchmark changes. One reviewer resolves revision 1 from the current checkout; another excludes the run because its exact evaluator cannot be reconstructed, producing different scores or eligibility decisions.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs both record `name: github-copilot-cli` but leave `version` and `runnerCommit` blank while using different CLI or runner revisions. A reviewer may pool them as equivalent; another may separate or exclude them after noticing behavior changed between revisions.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run requests `haiku` but leaves `resolved` blank after the alias changes providers or versions. One reviewer groups the run by `requested`; another refuses comparison because the executed model is unknown, changing arm membership.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two arms list different `mcpServers` but carry the same blank `fingerprint`. One reviewer compares the explicit lists and rejects the match; another relies on the stated rule that fingerprints must match and treats two blank fingerprints as equal.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For a control run with `instructions: none` and `instructionsProvenLoaded: false`, one reviewer reads false as an expected result because there were no instructions to load; another reads it as a failed preflight and invalidates the run. The same record receives different validity decisions.
**Layer of the implied fix:** L3
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run makes zero tool calls but leaves `toolCalls` blank, while another run loses tool telemetry and also leaves it blank. One reviewer converts both blanks to zero; another treats both as unknown, changing tool-use and efficiency comparisons.
**Layer of the implied fix:** L2
**Anchor:** modelCalls:
  toolCalls:

### efficiency
**Verdict:** finding
**Failure:** A record can state `{ value: 12400, source: null, estimated: false }` or `{ value: null, source: provider, estimated: false }`. The artifact only says the validator rejects a bare number, so one reviewer may accept these mappings as provenance-bearing while another rejects them as internally inconsistent.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** For a run where 8 of 10 tests pass, one reviewer records `tests: 8`; another records `tests: 0.8`; a third records a pass/fail value. The same execution therefore yields incompatible `finalScore` inputs.
**Layer of the implied fix:** L3
**Anchor:** tests:
  hiddenTests:
  acceptanceScore:

### measurement
**Verdict:** finding
**Failure:** A run with missing token telemetry but valid test results can be marked `valid` with `telemetryComplete: false`, or `excluded` because telemetry is incomplete. The artifact names both fields but does not state which status follows, so reviewers can include different run sets.
**Layer of the implied fix:** L3
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** Given a note describing a flattering harness anomaly, two reviewers may phrase it differently, but the block is explicitly free-form and no downstream decision or numeric interpretation is assigned to its wording.
**Layer of the implied fix:** n/a
**Anchor:** Anything surprising. Especially anything that made the agent look good —

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category explicitly duplicates a stated pass/fail gate. Reviewers are most likely to diverge on `evaluation`: the concrete 8-of-10 test result can become `8`, `0.8`, or a Boolean, a three-way divergence that can propagate into `finalScore`. Across the artifact, blank scalar fields do not distinguish zero, not applicable, not collected, and collection failure; for example blank `toolCalls` can describe either zero calls or missing telemetry.
**Layer of the implied fix:** L3
**Anchor:** evaluation:
  compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

