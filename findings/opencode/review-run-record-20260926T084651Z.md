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
reviewed_utc:    20260926T084651Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        1d9e26a
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
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L2 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L2 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records copied from this template can both retain `B0-COPILOT-BE001-001`; one reviewer treats the second as a retry of the same run while another treats it as a distinct run, causing overwrite or double-counting.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** Run A leaves `benchmarkSha` blank and executes BE-001 revision 1 before an evaluator change; Run B also leaves it blank and executes after that change. One reviewer groups them as the same benchmark revision while another excludes them as untraceable.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs both record `name: github-copilot-cli` but leave `version` and `runnerCommit` blank; one used a runner before harness bug #7 was fixed and one after. A reviewer may compare them directly, while another may invalidate the comparison.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run records `requested: haiku` but leaves `resolved` blank after the alias changes provider-side. One reviewer attributes the result to the alias as requested; another refuses attribution because the actual model is unknown.
**Layer of the implied fix:** L2
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two semantically identical environments serialize arrays or keys differently and produce different fingerprints, or two materially different environments use an implementation that omits empty versus absent values and collide. Because no canonicalization or hash algorithm is specified, competent runner authors can disagree whether the arms match.
**Layer of the implied fix:** L3
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For a control run with `instructions: none`, one reviewer interprets `instructionsProvenLoaded: false` as the expected result because nothing should load; another interprets it as a failed preflight assertion and invalidates the run.
**Layer of the implied fix:** L3
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run with no tool calls and a run whose telemetry failed can both leave `toolCalls` blank and retain `toolsUsed: []`. One reviewer scores both as zero-tool runs; another treats both as missing telemetry.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** `{ value: null, source: provider, estimated: false }` is not a bare number, so the only stated validator rejection does not cover it. One reviewer treats this as provider-confirmed zero/missing usage while another treats it as an internally invalid tuple.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** Given `compile: false`, `tests: 8/10`, `hiddenTests: 5/5`, and `acceptanceScore: 0.9`, one reviewer can assign a failing `finalScore` because compilation is a gate, while another can compute a high weighted score because no aggregation or gate rule is defined.
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
**Failure:** A run with `status: excluded` and `exclusionReason: slow` can be accepted by one reviewer as a structured, preregistered reason and rejected by another because neither the structure nor the preregistration registry is identified.
**Layer of the implied fix:** L2
**Anchor:** exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** No concrete input or diff in the supplied evidence makes this free-form notes field produce a wrong answer or forces two competent reviewers to interpret a measurement control differently.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is defined, so no scoring-category/pass-fail duplication can be established; however, `compile`, `tests`, and `hiddenTests` may be intended as gates while also feeding `finalScore`, and the artifact does not say. Reviewers would diverge most on `evaluation`: for the concrete result `compile: false`, `tests: 8/10`, `hiddenTests: 5/5`, and `acceptanceScore: 0.9`, plausible final scores range from an automatic fail or zero to roughly 0.9. The artifact needed executable completeness and consistency rules distinguishing zero, empty, unknown, and not applicable, plus a defined score aggregation/gating rule and an identifiable exclusion registry.
**Layer of the implied fix:** L2
**Anchor:** compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

