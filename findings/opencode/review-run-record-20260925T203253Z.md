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
reviewed_utc:    20260925T203253Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        3294a16
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template reads as a controlled instrument — fields carry comments like "arms must match", "F01-F15", "valid / excluded / pilot / invalidated", "preflight assertion result", and "permission requests — and whether anyone could answer" — but none of these commitments are backed by an executable check the artifact names. The single validator referenced (validate-run-record.sh) is scoped only to the token block. Two reviewers reading the same template can each produce a record that the other cannot join.
  blocking:
    - reason: `requested` and `resolved` flag that an alias re-point between runs is significant but give no rule for treating such a pair.
      wrong_action: Reviewer 1 pools two `requested: haiku` runs whose `resolved` values differ as "haiku runs" and reports a single result. Reviewer 2 refuses to compare. The disagreement lives in the data, not the analysis.
      anchor: "These differing is not a detail. An alias can silently re-point between runs."
      evidence: templates/run-record.yaml:16
    - reason: `fingerprint` is described as a hash that "arms must match" but the template names no validator that recomputes or verifies that hash against the fields it claims to summarise.
      wrong_action: A reviewer filling Arm 2 copies Arm 1's fingerprint on the reasoning that "arms must match" means the hash should be identical; the two rows now claim equal environments while carrying different plugin/skill lists, and a downstream comparison is silently invalid.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `instructionsProvenLoaded: false` is labelled a "preflight assertion result" but states no consequence — the field does not say whether `false` excludes the run, downgrades it, or merely annotates it.
      wrong_action: Reviewer 1 excludes the run on the grounds the treatment was not applied (the measurement is then of the control, not the treatment). Reviewer 2 keeps it with a caveat. Both write to the same dataset; downstream counts of "treatment runs" differ by reviewer.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: `approvals` is annotated "permission requests — and whether anyone could answer" but the field is a bare scalar — the comment promises a structure (request vs answerability) the field does not deliver. `retries` and `compactions` carry no comment and no shape.
      wrong_action: Reviewer 1 writes `approvals: 3` (a count of permission prompts). Reviewer 2 writes `approvals: [{tool, answered}, ...]`. A downstream analysis that groups runs by "unanswered approval rate" runs on Reviewer 2's data and silently produces nothing from Reviewer 1's.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:44-46
    - reason: `durationMs` is a bare scalar with the comment "The runner always knows this one" while every other field in the efficiency section carries a provenance block `{ value, source, estimated }` precisely so gaps read as gaps. The comment's claim is contradicted by a documented failure mode — `opencode run` processes that hang and never return leave the runner without a duration, while an external observer has one.
      wrong_action: A reviewer records `durationMs: 600000` for a run killed after 10 minutes; that value is now visually identical to a 10-minute run that actually executed, and any duration analysis includes hung runs at full weight.
      anchor: "durationMs:              # wall clock. The runner always knows this one."
      evidence: templates/run-record.yaml:49
    - reason: `failureClass` is annotated `# F01-F15` and `status` is annotated `# valid / excluded / pilot / invalidated`, but neither constraint is executable. An unenumerated failure (or a pilot with a telemetry gap) is one reviewer's "force into F03 / pick a status" and another's "invent F16 / use a free-form value".
      wrong_action: A reviewer encounters a failure outside F01–F15 and writes `failureClass: F16`. Downstream, `group_by(failureClass)` produces a one-row bucket with no siblings — a count that says nothing, and a misclassified run that the template has not authorised.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `evaluation.acceptanceScore` / `evaluation.finalScore` sit alongside `measurement.status` with no stated precedence. The gate that admits runs to scoring (`check-run-gate.sh`, named in the lab's instruments) is not referenced; the template does not say whether a non-null `finalScore` implies the gate passed or whether `finalScore` may be set on a run whose `status` is `excluded`.
      wrong_action: A reviewer excludes a run via `status: excluded` and writes `finalScore: 0.85` from the evaluator anyway. Score aggregation includes the row because `finalScore` is non-null; the gate had decided it should be excluded. The duplication is not adjudicated.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:67-77
  non_blocking:
    - reason: Seven of the nine `behavior` fields are bare scalars with no declared type (`modelCalls`, `toolCalls`, `filesRead`, `commands`, `retries`, `compactions`, and `approvals`). Only `toolsUsed` and `filesChanged` are typed (`[]`). Two reviewers filling in the same run will produce different shapes for at least two of these fields; that is an L3 hazard for any cross-run behaviour join but does not mis-state a measurement on its own.
      evidence: templates/run-record.yaml:37-46
    - reason: The `notes` field example frames the artifact rather than describing the field — "five of our seven harness bugs were caught fast because they looked bad; the two that survived review were the two that flattered the result." It would be clearer either as a separate warning at the top of the template or as a referenced document.
      evidence: templates/run-record.yaml:81-84
    - reason: The template references `tools/validate-run-record.sh` exactly once, for rejecting bare numbers in the token block. A reviewer cannot tell from the template which other fields the validator enforces. A small annotation — "enforced by validate-run-record.sh" or "guidance-only" — on each commented field would close the asymmetry; without it, every field comment is implicitly L3.
      evidence: templates/run-record.yaml:59-60
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 151s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

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
**Verdict:** finding
**Failure:** Two runs record `requested: haiku` but `resolved` differs (`claude-haiku-4-5-20251001` vs `claude-haiku-4-5-20251115`) because the alias re-pointed between runs. The comment says "These differing is not a detail" but gives no rule for what to do. Reviewer 1 treats both as "haiku runs" and pools them; Reviewer 2 sees two different models and refuses to compare. The template produces no signal that resolves the disagreement — the field pair flags the issue and then abandons it.
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** Arm 1 has `plugins: [rtk]`, Arm 2 has `plugins: []`. Reviewer 1 computes each arm's `fingerprint` from its own fields. Reviewer 2, filling in Arm 2, copies Arm 1's fingerprint on the reasoning that "arms must match" means the hash should be identical. The fingerprints now disagree with the actual environment, the arms are not comparable, and nothing in the template or any named validator checks the hash against the fields it claims to summarise. The invariant is stated in prose and stops there.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** A run records `instructionsProvenLoaded: false` — the preflight assertion failed, meaning the treatment (custom instructions) was not confirmed loaded. The template labels this an "assertion result" but does not say whether a `false` value excludes the run, downgrades it, or is merely noted. Reviewer 1 excludes the run (the treatment was not applied, so the measurement is of the control, not the treatment). Reviewer 2 keeps the run and writes a note, treating the failed assertion as a caveat rather than a disqualifier. Both are defensible readings of the same field; the template gives no rule.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` carries the comment "permission requests — and whether anyone could answer," which promises a structure that distinguishes a request from its answerability. The field itself is a bare scalar with no shape defined. Reviewer 1 writes `approvals: 3` (a count of permission prompts). Reviewer 2 writes `approvals: [{tool: "edit", answered: false}, {tool: "bash", answered: true}]` (a structured log). A downstream analysis that counts unanswered approvals works on Reviewer 2's data and silently produces nothing from Reviewer 1's. The same ambiguity applies to `retries` and `compactions`, which have no comments at all.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** `durationMs` is a bare scalar with the comment "The runner always knows this one." The lab's own CLAUDE.md documents `opencode run` processes that hang and never return — in that case the runner does not know the duration; an external observer does. Every other field in this section carries a provenance block (`{ value, source, estimated }`) precisely so a gap reads as a gap and not a zero. `durationMs` has no such block. When a run is killed after 10 minutes, Reviewer 1 writes `durationMs: 600000` from the external timer with no way to mark the source. Reviewer 2 writes `durationMs: null` because the runner never reported it. The first looks like a 10-minute run; the second looks like a missing field. The comment's claim is falsified by a failure mode the lab has already observed.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15` but the constraint lives in a comment. A reviewer encounters a failure mode outside the enumerated set — say, "agent wrote correct code in the wrong language" — and writes `failureClass: F16` or `failureClass: wrong-language`. Nothing in the template rejects either value. Two reviewers facing the same run: one forces it into F03 (closest fit), another invents F16. Downstream analysis that groups runs by failure class now has a singleton category that no other run shares, or a misclassified run, and neither reviewer is wrong by the template's rules. Separately, `unintendedChanges` has no comment and no structure — a boolean, a file list, and a count are all equally valid writes.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` is annotated `# valid / excluded / pilot / invalidated` but the four values are not declared mutually exclusive, and nothing enforces the set. A run is a pilot that also had a telemetry gap. Reviewer 1 writes `status: pilot` (the run's intended role). Reviewer 2 writes `status: invalidated` (the gap disqualified it). Both values appear in the comment's list; neither is wrong. Downstream, the run is counted as a pilot in one analysis and dropped in another. The same section's `telemetryComplete` is a bare scalar whose comment ("a gap must not read as a zero") describes a principle about the telemetry data, not about this field — leaving a reviewer to guess whether the field is boolean or a description of what is missing.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.finalScore` and `evaluation.acceptanceScore` sit inside the run record alongside `measurement.status`. The lab's `check-run-gate.sh` is the gate that decides whether a run may be scored at all. The template does not say whether a non-null `finalScore` implies the gate passed, or whether `finalScore` can be set on a run whose `status` is `excluded`. If both are filled independently, a run can be excluded by the gate and still carry a `finalScore` — the gate and the field duplicate each other with no stated precedence.
- **Which section would two reviewers diverge on most?** `behavior`. Five of its nine fields are bare scalars with no defined type or structure (`toolCalls`, `retries`, `approvals`, `compactions`, and `filesRead`), and the one comment that hints at structure (`approvals`) promises richness the field does not deliver. Two reviewers filling in the same run would almost certainly produce different shapes for at least two of these fields.
- **What did the artifact not say that it needed to say?** The template references `tools/validate-run-record.sh` once — for rejecting bare numbers in the token block. A reviewer filling in the template does not know which of the other 30+ fields the validator checks and which are guidance-only. Every field-level comment in this artifact is L3 unless that validator enforces it, and the artifact never says where that boundary is. A reviewer who assumes the comment on `failureClass` is enforced writes differently from one who assumes it is not, and neither can tell from the template alone.
