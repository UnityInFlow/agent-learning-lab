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
reviewed_utc:    20260911T191449Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        9626d5c
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
| codex | ok | 58s |

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
**Failure:** Two completed records retain `B0-COPILOT-BE001-001`; one is valid and one is excluded. A reviewer treating `runId` as unique overwrites or joins them, while another preserves both, producing different run counts.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** Two runs both say `id: BE-001` and `revision: 1`, but were resolved from different evaluator commits while `benchmarkSha` remains blank. One reviewer pools them as repetitions of one task; another separates them, changing the reported treatment effect.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** A harness bug is fixed between two runs, but both records leave `version` and `runnerCommit` blank. One reviewer attributes the score difference to the treatment; another excludes the comparison as a harness change.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Two runs request `haiku` before and after that alias is repointed, while `resolved` is blank in both. One reviewer treats the model as held constant; another treats the runs as using different models.
**Layer of the implied fix:** L2
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two runs list the same `settingsSources` filename, but its contents differ by an enabled tool permission. Because the fingerprint is described as a hash only “of the above,” both environments can appear equivalent even though one agent has an extra capability; reviewers can therefore disagree on whether the arms match.
**Layer of the implied fix:** L2
**Anchor:** settingsSources: []
  fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For `instructionsProvenLoaded: false`, one reviewer reads the result as proof that instructions were not loaded and classifies the run as untreated; another reads it as a failed or unperformed preflight and invalidates the run. The record does not distinguish those cases.
**Layer of the implied fix:** L2
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** If tool telemetry is unavailable, the untouched template records `toolCalls:` and `toolsUsed: []`. One reviewer interprets the empty list as zero tools used; another treats it as missing telemetry, producing different behavioral conclusions.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** A record can contain `{ value: null, source: provider, estimated: false }`. The only named validator behavior rejects bare numbers, so this contradictory tuple may pass; one reviewer treats provider usage as missing, while another treats the populated provenance as evidence that collection succeeded.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** A run records `acceptanceScore: 0.8` and `finalScore: 80`. One reviewer interprets both as equivalent scores on 0–1 and 0–100 scales; another interprets them as materially different results because neither scale nor derivation is defined.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A run fails because of an unregistered harness outage and is marked `excluded`. One reviewer accepts the status because the comment lists it as valid; another calls it `invalidated` or rejects the exclusion because `exclusionReason` was not registered in advance. No executable registry check or status semantics resolves the disagreement.
**Layer of the implied fix:** L2
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance

### notes
**Verdict:** no finding
**Failure:** No concrete divergent measurement outcome follows from the free-text field itself because the artifact does not make `notes` an input to scoring, inclusion, or validity decisions.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is defined well enough to establish duplication with a pass/fail gate; in particular, the relationship among `tests`, `hiddenTests`, `acceptanceScore`, and `finalScore` is unstated. Reviewers would diverge most on `evaluation`: the same numeric pair can differ by a factor of 100, and `finalScore` has no stated derivation. The artifact needed executable completeness and consistency rules, score units and derivations, status semantics, and a named registry for permitted exclusion reasons.
**Layer of the implied fix:** L2
**Anchor:** tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

