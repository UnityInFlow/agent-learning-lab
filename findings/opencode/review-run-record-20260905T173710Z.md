# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:      skipped    # -A
opencode:        1.18.27
reviewed_utc:    20260905T173710Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        fd24fdb
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 30s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** finding
**Failure:** Two runs use task id BE-001 and revision 1, but one resolves the evaluator from commit A and the other from commit B while both leave benchmarkSha blank. One reviewer groups them as replicates; another excludes them as incomparable.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two records both say github-copilot-cli but leave version and runnerCommit blank; one ran before a harness bug fix and one after it. A reviewer can treat them as the same harness while another splits or excludes them.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Two runs request haiku on different dates, the alias points to different models, and resolved is blank in both records. One reviewer compares them as the same model; another considers model identity unknown and rejects the comparison.
**Layer of the implied fix:** L2
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two runners load identical settings but serialize list order differently, producing different fingerprints; alternatively, two runners use different plugin versions while recording only the same plugin name, producing the same fingerprint. Reviewers therefore disagree on whether the arms match.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A skill is configured but fails to load, while instructionsProvenLoaded is true because the instructions loaded. One reviewer treats the registered treatment as delivered; another invalidates the run because no equivalent load-proof field exists for skills, customAgent, hooks, or mcp.
**Layer of the implied fix:** L2
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run makes zero model calls and another loses model-call telemetry; both can record modelCalls as blank. One reviewer converts both blanks to zero, while another treats both as missing, changing efficiency and validity conclusions.
**Layer of the implied fix:** L2
**Anchor:** modelCalls:

### efficiency
**Verdict:** finding
**Failure:** A record contains { value: 12400, source: null, estimated: false } or { value: null, source: provider, estimated: false }. It is not stated whether the named validator rejects these inconsistent triples, so one reviewer accepts provider-grade usage while another classifies it as unknown.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** Two evaluators record acceptanceScore as 0.8 and 80 for the same outcome, or use finalScore as a raw point total versus a normalized fraction. Both fit the template, causing different rankings and pass decisions.
**Layer of the implied fix:** L2
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A run with telemetryComplete false has status valid, while another reviewer interprets incomplete telemetry as invalidated or excluded. The comments permit all combinations and do not identify an executable check that rejects the contradictory state.
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
**Failure:** No scoring category is present, so no scoring category can be shown to duplicate a pass/fail gate. Reviewers would diverge most on evaluation: the same score could be read as 0.8 or 80, a 100-fold numeric difference, with no defined pass threshold. The artifact needed to state which executable validator runs over the complete record and which field combinations, types, ranges, and required values it rejects; currently only rejection of bare efficiency numbers is claimed.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

