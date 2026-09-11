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
reviewed_utc:    20260911T102225Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        f77778e
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
| configuration | 1/1 | L2 |
| behavior | 1/1 | L2 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records from separate reruns both retain `B0-COPILOT-BE001-001`. One reviewer treats the second as an overwrite of the first; another treats both as distinct observations. Run counts and aggregate results then differ.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** A record has `id: BE-001`, `revision: 1`, and a blank `benchmarkSha`, while revision 1 has changed in the working tree. One reviewer resolves the historical task definition; another evaluates against the current definition, producing different scores for the same run.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs both say `name: github-copilot-cli` but leave `version` and `runnerCommit` blank; one used a runner before a command-capture fix and one after it. A reviewer may pool them as comparable while another excludes one, changing tool-call and command comparisons.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run leaves `requested` and `resolved` blank after invoking the `haiku` alias. One reviewer groups it with other requested-haiku runs; another refuses to group it because the concrete model is unknown. If the alias re-pointed, the first reviewer attributes results to the wrong model.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two arms list identical plugin names and both provide the same manually copied `fingerprint`, but one loaded different plugin versions or settings contents. One reviewer accepts the fingerprint as proof that arms match; another compares the effective environment and rejects comparability.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run records `instructions: none`, leaves `instructionsHash` blank, and sets `instructionsProvenLoaded: false`. One reviewer classifies this as a valid no-instructions control; another classifies it as a failed preflight because the instructions were not proven loaded. The run enters different experimental arms.
**Layer of the implied fix:** L2
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run records `toolCalls: 3` but leaves `toolsUsed: []`. One reviewer trusts the count and reports three tool calls; another treats the empty list as evidence of zero or incomplete telemetry. Behavior statistics diverge for the same record.
**Layer of the implied fix:** L2
**Anchor:** toolCalls:
  toolsUsed: []

### efficiency
**Verdict:** finding
**Failure:** A record uses `{ value: null, source: provider, estimated: false }`. It is not a bare number, so the stated validator guarantee does not establish that it is rejected. One reviewer reads this as provider-confirmed zero/missing usage; another treats it as an invalid provenance tuple, producing different completeness and efficiency conclusions.
**Layer of the implied fix:** L2
**Anchor:** inputTokens:         { value: null, source: null, estimated: null }
  outputTokens:        { value: null, source: null, estimated: null }
  cachedInputTokens:   { value: null, source: null, estimated: null }
  cacheCreationTokens: { value: null, source: null, estimated: null }
  cost:                { value: null, source: null, estimated: null }

### evaluation
**Verdict:** finding
**Failure:** Two reviewers evaluate a run with all tests passing, one unintended formatting change, and `acceptanceScore: 8`. One interprets the score as 8/10 and subtracts for the unintended change; the other interprets it as eight passed criteria and sets `finalScore` independently. The record has no scale or derivation rule, so final scores differ.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A run has complete token data but missing command telemetry and records `telemetryComplete: false` with `status: valid`. One reviewer includes it because status is valid; another excludes it because telemetry is incomplete. The template does not state which field controls inclusion or which missing telemetry makes a run invalid.
**Layer of the implied fix:** L3
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
**Failure:** No explicit scoring category duplicates a stated pass/fail gate. `evaluation` is the section most likely to diverge: for `acceptanceScore: 8` and blank `finalScore`, competent reviewers can assign incompatible scales or derive final scores differing by the full range of their chosen scale. The artifact needed to state scoring scales and derivation, required-field/completeness rules, provenance-tuple validity, identifier uniqueness, fingerprint construction, and the precedence between measurement status and telemetry completeness.
**Layer of the implied fix:** L3
**Anchor:** evaluation:
  compile:
  tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

