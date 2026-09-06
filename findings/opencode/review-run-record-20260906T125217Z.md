# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260906T125217Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        a4c219a
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 48s |

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
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two operators copy this template for separate runs and both retain `B0-COPILOT-BE001-001`; one reviewer treats the duplicate as two observations, while another deduplicates by runId, changing the reported sample size.
**Layer of the implied fix:** L3
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A record says `revision: 1` but leaves `benchmarkSha` blank after the evaluator changes. One reviewer resolves revision 1 from the current branch; another excludes the run because the executed evaluator cannot be identified. They evaluate different benchmark content.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs record `name: github-copilot-cli` with blank `version` and `runnerCommit`, but one used a runner commit containing a command-capture bug fix and the other did not. A reviewer may compare them as equivalent harness runs even though their telemetry was produced differently.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run requests `haiku` and records neither requested nor resolved model. After the alias is repointed, one reviewer groups the run with the model currently behind `haiku`; another treats the model as unknown, producing different arm membership.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two semantically identical environments list plugins in different orders. Without a specified fingerprint serialization, one implementation hashes the YAML order and declares an arm mismatch while another sorts lists and declares a match. Conversely, an implementation that omits `permissionMode` from the hash can accept materially different environments.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run has `instructions: custom.md`, a populated `instructionsHash`, and `instructionsProvenLoaded: false`, yet `measurement.status` is `valid`. One reviewer accepts the registered treatment based on the hash; another excludes it because loading was not proven.
**Layer of the implied fix:** L2
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** For an agent that invokes a tool, receives a transient failure, and invokes it again, one recorder writes `toolCalls: 2` and `retries: 1`; another writes `toolCalls: 1` and `retries: 1`, treating the retry as separate from calls. Both conform to the unlabeled fields, but derived efficiency differs.
**Layer of the implied fix:** L3
**Anchor:** toolCalls:
  toolsUsed: []
  filesRead:
  filesChanged: []
  commands: []
  retries:

### efficiency
**Verdict:** finding
**Failure:** A local tokenizer produces 11,950 input tokens, but the record says `{ value: 11950, source: local-tokenizer, estimated: false }`. The stated validator only promises to reject bare numbers; one reviewer accepts this as Level A-like exact usage while another treats all local-tokenizer values as estimates.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** The same successful run can be recorded as `acceptanceScore: 0.8` by a reviewer using a 0–1 fraction and as `acceptanceScore: 80` by one using a percentage. The artifact gives neither a scale nor aggregation rule, so comparisons and `finalScore` calculations can be wrong by a factor of 100.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A run loses half its telemetry because of an unregistered harness outage. One reviewer marks it `invalidated` because the evidence is unreliable; another marks it `excluded` and supplies a free-form reason. Both choices fit the comments, but they lead to different denominators and different treatment estimates.
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
**Failure:** No defined scoring categories exist, so duplication with pass/fail gates cannot be determined; `compile` and `tests` could either feed `finalScore` or duplicate thresholds inside it. Reviewers would diverge most on `evaluation`: the same `acceptanceScore` can differ by a factor of 100, and `finalScore` has no stated scale or aggregation. The artifact needed executable validation and explicit semantics for required fields, provenance consistency, fingerprint construction, score calculation, status transitions, and the registered exclusion-reason vocabulary.
**Layer of the implied fix:** L2
**Anchor:** evaluation:
  compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

