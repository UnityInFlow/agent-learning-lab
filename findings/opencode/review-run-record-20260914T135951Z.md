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
reviewed_utc:    20260914T135951Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        c16011d
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Template specifies which fields to record but not what they mean — acceptanceScore scale, benchmarkSha commit, fingerprint canonicalization, toolCalls/retries semantics, telemetryComplete definition, and instructionsProvenLoaded polarity each admit incompatible reader interpretations, so a record filled today and read tomorrow will produce different measurements from the same underlying execution.
  blocking:
    - reason: acceptanceScore has no declared type or scale; identical evaluator output is recorded as 8 by one reader and 0.8 by another
      wrong_action: a reviewer fills `acceptanceScore: 8` for "8 of 10 criteria passed" while another fills `0.8`; downstream aggregation treats the integer as a raw count and the float as a proportion, so the same run lands at different percentiles depending on which interpretation survives
      anchor: "acceptanceScore:"
      evidence: templates/run-record.yaml:61
    - reason: benchmarkSha is one field bundling two artifacts (task and evaluator may resolve from different commits)
      wrong_action: a reviewer records the task commit while another records the evaluator commit; downstream comparability is decided by which reader's interpretation is kept, and the artifact itself never names which to use
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
    - reason: fingerprint is claimed as the basis for arm-matching ("arms must match") but its computation and canonicalization are unspecified
      wrong_action: two identical environments serialize plugins/skills/mcpServers in different orders and receive different fingerprints; one reviewer rejects them as mismatched arms, another canonicalizes and accepts them — the artifact names the control but does not let either reader verify what the other did
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: toolCalls and retries are separate fields but their counting semantics are unspecified; the same three-attempt sequence can be recorded two ways
      wrong_action: a reviewer records `toolCalls: 1, retries: 2` (matching the template's separate fields); another records `toolCalls: 3` (treating retries as calls); efficiency comparisons differ across reviewers
      anchor: "toolCalls:
  retries:"
      evidence: templates/run-record.yaml:38,44
    - reason: telemetryComplete is undefined; the comment "a gap must not read as a zero" states an intent but no rule
      wrong_action: a reviewer with complete token telemetry but missing approval telemetry sets `telemetryComplete: true` (efficiency metrics present) while another sets `false` (any gap invalidates); inclusion decisions differ by one full run
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:79
    - reason: instructionsProvenLoaded: false is indistinguishable between "expected because instructions: none" and "preflight failed"
      wrong_action: a reviewer of a control run with `instructions: none` reads `false` as expected and keeps the run; another reads it as a failed preflight and invalidates the run, changing inclusion
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
  non_blocking:
    - reason: harness.version and harness.runnerCommit are blank with no requiredness marker; runners may legitimately not know the harness build but the template offers no convention for recording "unknown" vs "not collected"
      evidence: templates/run-record.yaml:10-11
    - reason: model.requested vs model.resolved is a useful distinction but no field-level comment explains the fallback when telemetry is unavailable — readers will diverge on whether to copy requested into resolved or leave blank
      evidence: templates/run-record.yaml:14-15
  disputed:
    - finding: efficiency block — a record with `{value: 12400, source: null, estimated: false}` is read as provider-grade by one reviewer and unknown by another
      why: the template's own comment block at templates/run-record.yaml:51-60 establishes three levels with explicit examples, including the Level C shape `{value: null, source: null, estimated: null}`. The finding's example is internally malformed (estimated should be null when source is null, per the documented Level C). A faithful reader following the documented levels would read it as C. The template does specify the levels; reviewer disagreement here reflects the malformed record, not a template defect.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 54s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L3 |
| task | 1/1 | L1 |
| harness | 1/1 | L3 |
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L3 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records for separate executions both retain `B0-COPILOT-BE001-001`; one reviewer treats the second as a duplicate to discard, while another treats it as a rerun and keeps both, changing the sample count.
**Layer of the implied fix:** L3
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** The task is resolved from commit A but the evaluator is resolved from commit B. The single `benchmarkSha` can record only one; reviewers choosing A versus B attribute the result to different benchmark states.
**Layer of the implied fix:** L1
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs use different harness builds but leave `version` and `runnerCommit` blank. One reviewer groups them as comparable runs; another excludes them because harness identity is unknown.
**Layer of the implied fix:** L3
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** Telemetry reports no resolved model for a run requested as `haiku`. One reviewer records `resolved` as `haiku`; another leaves it blank, causing different conclusions about whether the model was held constant.
**Layer of the implied fix:** L3
**Anchor:** resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Two identical environments list plugins in different orders. Because the serialization and ordering used for the hash are unspecified, they can receive different fingerprints and be rejected as mismatched arms despite equivalent contents.
**Layer of the implied fix:** L3
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** For a control run with `instructions: none` and `instructionsProvenLoaded: false`, one reviewer reads false as the expected result because there were no instructions to load; another reads it as a failed preflight and invalidates the run.
**Layer of the implied fix:** L3
**Anchor:** instructions: none
  instructionsHash:
  instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** An agent issues one tool request, retries it twice after failures, and succeeds on the third attempt. One reviewer records `toolCalls: 3`; another records `toolCalls: 1` and `retries: 2`, producing different efficiency comparisons.
**Layer of the implied fix:** L3
**Anchor:** toolCalls:
  toolsUsed: []
  filesRead:
  filesChanged: []
  commands: []
  retries:

### efficiency
**Verdict:** finding
**Failure:** A record contains `{ value: 12400, source: null, estimated: false }`. It is not a bare number, so the stated rejection rule does not establish that the validator rejects it, yet one reviewer treats it as provider-grade measured usage while another treats it as unknown provenance.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** An evaluator returns 8 accepted criteria out of 10. One reviewer records `acceptanceScore: 8`; another records `acceptanceScore: 0.8`, so identical performance produces different final-score inputs.
**Layer of the implied fix:** L3
**Anchor:** acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A run has complete token telemetry but missing approval telemetry. One reviewer sets `telemetryComplete: false` because any gap makes telemetry incomplete; another sets it true because all efficiency metrics are present, causing different inclusion decisions.
**Layer of the implied fix:** L3
**Anchor:** telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** No concrete scenario was identified in which the free-form notes field itself changes a measured answer or forces competent reviewers into incompatible handling.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category is shown to duplicate a pass/fail gate because neither scoring-category definitions nor pass/fail-gate definitions are present. `measurement` is expected to diverge most: the same partially observed run can be marked valid or excluded, changing inclusion by one full run. The artifact needed to state field types, requiredness, null semantics, scoring scales, count semantics, fingerprint canonicalization, status-transition rules, and the executable checks—if any—that reject violations.
**Layer of the implied fix:** L3
**Anchor:** finalScore:

measurement:
  status:                  # valid / excluded / pilot / invalidated

