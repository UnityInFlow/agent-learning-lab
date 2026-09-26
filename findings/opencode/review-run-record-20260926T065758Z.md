# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/glm-5.2          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260926T065758Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        92e9500
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A template intended to be copied for cross-run comparison leaves enough structure unspecified that two reviewers filling it in produce non-comparable records; runId additionally ships with a concrete value that hides itself as "done."
  blocking:
    - reason: runId ships with a concrete value `B0-COPILOT-BE001-001` while every surrounding field is blank; a reviewer copying the template may treat it as filled in and file multiple runs under the same id
      wrong_action: Two reviewers each copy the template without updating runId; downstream tooling that keys on runId silently overwrites one record with the other, or merges unrelated runs into one
      anchor: "runId: B0-COPILOT-BE001-001"
      evidence: templates/run-record.yaml:1
    - reason: `approvals`, `retries`, and `compactions` carry only a vague comment (or nothing) and no schema; the artifact's own token-provenance block at lines 51-65 demonstrates the correct convention with explicit `{value, source, estimated}` and Level A/B/C examples — the inconsistency is itself the defect
      wrong_action: Reviewer A records `approvals: 3` (count); Reviewer B records `approvals: [{tool: "edit", granted: true, responded: true}]` (event list); aggregation treats them as the same field — a count cannot answer "did anyone respond," and an event list cannot be summed. The same divergence applies to `retries` and `compactions`
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:44-46
    - reason: `acceptanceScore` and `finalScore` have no documented scale; bare numbers pass through with no rejection of incompatible units
      wrong_action: Reviewer A records `4` on a 0–5 rubric; Reviewer B records `80` on a 0–100 percentage; an average across runs treats run B as scoring 20× higher when they scored identically on different scales
      anchor: "acceptanceScore:"
      evidence: templates/run-record.yaml:71-72
  non_blocking:
    - reason: `permissionMode` documents its valid values in a comment but does not enforce them; whether `validate-run-record.sh` rejects variants depends on the validator (not attached)
      evidence: templates/run-record.yaml:20
    - reason: `instructionsProvenLoaded` defaults to `false`; whether that blocks scoring depends on the validator — the line-level finding is conditional on validator behavior
      evidence: templates/run-record.yaml:31
    - reason: `failureClass` hints at enum `F01-F15` in a comment but does not reject `F00` or `none`; conditional on validator
      evidence: templates/run-record.yaml:73
    - reason: The artifact does not document which fields are required, optional, or gap-tolerant; the validator (not attached) would have to encode this
      evidence: templates/run-record.yaml:1-84
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 109s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| evaluation | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
**Verdict:** finding
**Failure:** The template ships with a concrete value `B0-COPILOT-BE001-001` while every other identifying field is blank. A reviewer copies the template, fills in the empty fields, and overlooks the one field that already "looks done." Two runs filed with the same default runId collide — downstream tooling that keys on runId either silently overwrites one with the other or merges unrelated records. An empty value (or a placeholder like `<required>`) would have made the gap visible; a concrete plausible-looking ID hides it.
**Layer of the implied fix:** L3
**Anchor:** `runId: B0-COPILOT-BE001-001`

### task
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** `permissionMode` documents its valid values in a comment (`acceptEdits / plan / default — see harness bug #7`) but nothing in the template rejects variants. A reviewer writes `accept-edits` (hyphenated) or `AcceptEdits` (capitalized) or `auto`. If `validate-run-record.sh` does not check this field against the three-value enum, two runs with the same permission mode are recorded under different strings and downstream analysis treats them as distinct environments — or silently drops the unrecognized one. The comment references "harness bug #7," confirming this field matters for interpretation, which makes the unenforced enum a real divergence point.
**Layer of the implied fix:** L3
**Anchor:** `permissionMode:          # acceptEdits / plan / default — see harness bug #7`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` defaults to `false` and nothing in the template says a `false` value blocks scoring. The field records whether the preflight confirmed the registered instructions were actually loaded — the difference between "the treatment was applied" and "we don't know if the treatment was applied." A reviewer who never ran the preflight files the record with the default `false`; a reviewer who did files `true`. If the validator does not reject `false`, both runs are scored side by side as if the treatment was equally confirmed in each. Two reviewers would diverge on whether a `false` run is scoreable at all.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` has a comment — "permission requests — and whether anyone could answer" — but no structure. Reviewer A records `approvals: 3` (a count). Reviewer B records `approvals: [{tool: "edit", granted: true, responded: true}]` (a list of events). Reviewer C records `approvals: {requested: 3, granted: 1, autoApproved: 2}` (a summary object). Downstream analysis cannot compare across runs because the three shapes are incompatible — a count can't tell you whether any approval was answered by a human, and an event list can't be summed without parsing. The comment hints at two dimensions (requests, and whether anyone could answer) but doesn't bind them to a structure, so each reviewer invents their own.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `acceptanceScore` and `finalScore` carry no documented scale. Reviewer A records `acceptanceScore: 4` on a 0–5 rubric scale. Reviewer B records `acceptanceScore: 80` on a 0–100 percentage scale. Both are valid numbers, both pass a bare-number check, and downstream analysis that averages or compares across runs treats them as the same unit when they are not. The failure: a cross-run comparison reports run B as scoring 20× higher than run A when they scored identically on different scales. `failureClass` has the same shape of problem (an enum `F01-F15` in a comment with no rejection of `F00` or `none`), but the missing scale on the scores is the more serious defect because it produces a silently wrong comparison rather than a categorization gap.
**Layer of the implied fix:** L3
**Anchor:** `acceptanceScore:` and `finalScore:`

### measurement
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- `evaluation.acceptanceScore` may duplicate the acceptance gate if that gate is binary (pass/fail). The CLAUDE.md names an "acceptance gate" as a distinct role (opencode-only, a review not a measurement). If the gate produces a binary verdict and `acceptanceScore` records that same verdict, the field is a constant across all gate-passing runs — the same defect that killed the seven-category rubric's gate-restating anchors. If the gate produces a granular score, it is not a duplicate. The template does not say which, and two reviewers would disagree on whether to fill it with a boolean or a number.
- **`behavior`** is the section two reviewers would diverge on most. `approvals` is the worst offender (completely unspecified structure), but `commands`, `retries`, and `compactions` share the problem — none have a documented type or shape. The divergence is not marginal: one reviewer's `commands: ["npm test", "npm run build"]` and another's `commands: 2` cannot be reconciled after the fact.
- The artifact does not say which fields are required. It references `validate-run-record.sh` exactly once (the token-provenance comment), but a reviewer filling in the template has no way to know which other fields the validator enforces, which are optional, and which will cause a silent gap vs. a rejected record. The template and the validator are the two halves of the same contract, and only one half is visible here.
