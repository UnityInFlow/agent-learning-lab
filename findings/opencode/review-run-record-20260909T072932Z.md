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
reviewed_utc:    20260909T072932Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        42bc6ca
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A run-record template whose purpose is producing comparable experimental data lets two reviewers fill it incompatibly on at least six fields, because the template states invariants ("provenance required", "arms must match", "preflight assertion result", "structured, registered in advance") that it does not specify — so the same record can be filled two ways and mean opposite things downstream.
  blocking:
    - reason: evaluation.acceptanceScore and evaluation.finalScore have no scale; a 0–1 and a 0–100 record of the same run are both reasonable, and downstream aggregation treats them as numerically equal (a 100× error on the same data).
      wrong_action: a downstream analysis averages 0.85 and 85 as if both are scores, producing a 100× corrupted dependent variable; or a reviewer who picks the wrong scale writes a value that looks plausible and is silently incompatible with the rest of the corpus.
      anchor: "acceptanceScore:"
      evidence: templates/run-record.yaml:71

    - reason: efficiency.{input,output,cached,cacheCreation,cost}Tokens claim provenance is mandatory ("Every usage value carries its own provenance, so a gap reads as a gap and not as a very efficient run") but the only enforcement the template names is `tools/validate-run-record.sh` "rejects a bare number." A record with `{ value: 12400, source: null, estimated: null }` is structured (passes the described validator) and yet has no provenance — exactly the failure mode the comment forbids. The template's stated invariant and its described validator do not match.
      wrong_action: a reviewer writes a real-looking number with source: null, the validator passes it, and the run is later treated as measured data when it is unmeasured; the dependent variable becomes "telemetry reported an unknown number," not a gap.
      anchor: "Every usage value carries its own provenance, so a gap reads as a gap and not as a very efficient run."
      evidence: templates/run-record.yaml:51-60

    - reason: behavior.approvals has no type and its comment ("permission requests — and whether anyone could answer") describes two distinct facts in one slot. A count (3), a log ([{tool, granted}]), and a summary ({count, unanswered}) are all reasonable readings.
      wrong_action: one reviewer writes `3`, another writes a list; downstream code that reads `approvals` as a number crashes on the list, code that reads it as a list gets undefined from the number, and the two records are not comparable in any analysis that treats approvals as a variable.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45

    - reason: configuration.instructionsProvenLoaded: false conflates "preflight ran and treatment is absent" (run must be excluded) with "preflight never ran" (treatment state unknown, run is unverified but not necessarily untreated). These are opposite consequences.
      wrong_action: the same field value drives one reviewer to exclude the run from scoring and another to include it; a downstream filter that respects "instructionsProvenLoaded: false ⇒ exclude" silently drops unverified runs, and a filter that reads it as "we just didn't check" silently scores untreated runs as if treated.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31

    - reason: environment.fingerprint is annotated "hash of the above; arms must match" but neither the field set being hashed nor the meaning of "arms" nor the matching rule is specified. Two reviewers will compose the hash differently (one hashes every field under environment; another hashes only the customizable surface hooks/plugins/skills/mcpServers and excludes harness-controlled bare and permissionMode, because those are not the treatment).
      wrong_action: two runs in the same experimental arm produce different fingerprints and a downstream "same arm ⇒ same fingerprint" check flags them as cross-arm; or two runs in different arms match by one definition and not another, and the experiment's arm-membership signal is whatever the reviewer happened to hash.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
  non_blocking:
    - reason: failureClass is annotated "# F01-F15" but the taxonomy is not defined in or referenced from the artifact — a reviewer without the external source classifies the same failure under two codes.
      evidence: templates/run-record.yaml:73
    - reason: measurement.exclusionReason claims to be "structured, registered in advance" but does not name the structure, the registry location, or how a reviewer verifies their reason was registered; a free-text string and an object are both reasonable.
      evidence: templates/run-record.yaml:78
    - reason: filesRead has no default while filesChanged: [] does, suggesting one is a count and one a list; reviewers will produce different shapes for semantically parallel fields.
      evidence: templates/run-record.yaml:41-42
    - reason: model.requested and model.resolved are documented to diverge ("An alias can silently re-point between runs") but there is no field capturing which provider/source was checked, so the divergence is observable but not attributable.
      evidence: templates/run-record.yaml:14-16
  disputed:
    - finding: "evaluation.compile, evaluation.tests, and evaluation.hiddenTests restate the evaluator's gate results, and if the run record is only filled for gate-passing runs these three fields are constants across the population that matters."
      why: the run record is the raw observation instrument, not the scoring rubric; measurement.status enumerates valid / excluded / pilot / invalidated, and failureClass only carries meaning for non-passing runs. The CLAUDE.md "rubric only scores gate-passing submissions" rule applies to the rubric's anchors, not to this template's coverage. The premise that the population that matters is gate-passing-only does not hold for the run record.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 115s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L2 |
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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** Two reviewers filling `fingerprint` independently would not produce the same hash. The comment says "hash of the above; arms must match" but does not define "arms" or "match." Reviewer A hashes every field under `environment` and checks that runs in the same experimental arm share it. Reviewer B hashes only `hooks`/`plugins`/`skills`/`mcpServers` (the customizable surface) and excludes `bare` and `permissionMode` because those are harness-controlled, not treatment. Their fingerprints differ for the same run, and a downstream comparison that expects matching fingerprints within an arm flags a mismatch that is an artifact of the hash definition, not a real configuration drift.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` is the default, but `false` conflates two states with opposite consequences: (a) the preflight ran and the instructions were NOT loaded — the treatment is absent, the run should be excluded, and (b) the preflight never ran — the treatment state is unknown, the run is unverified but not necessarily untreated. A reviewer reading a record with `false` cannot distinguish "this run has no treatment, exclude it" from "we forgot to check." One reviewer excludes the run; another scores it. Same field, same value, opposite outcomes.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** The `approvals` field has no type and its comment — "permission requests — and whether anyone could answer" — describes two distinct pieces of information in one untyped slot. Reviewer A writes `3` (a count of prompts). Reviewer B writes `[{ tool: "edit", granted: true }, { tool: "bash", granted: false }]` (a log). Reviewer C writes `{ count: 3, unanswered: 2 }` (a summary). Downstream code that reads `approvals` as a number crashes on the list; code that reads it as a list gets `undefined` from the number. The three records are not comparable. Separately, `filesRead` has no default while `filesChanged: []` does — one reviewer treats `filesRead` as a count (matching the bare `modelCalls`/`toolCalls` style) and another as a list (matching `filesChanged`), producing different shapes for semantically parallel fields.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The comment states the intent: "Every usage value carries its own provenance, so a gap reads as a gap and not as a very efficient run." The enforcement it names is narrower: "`tools/validate-run-record.sh` rejects a bare number." A reviewer who writes `inputTokens: { value: 12400, source: null, estimated: null }` has produced a number with no provenance — exactly the "very efficient run" the comment says must not happen — but this is not a "bare number," it is a structured object. If the validator only rejects bare scalars, this record passes validation while violating the stated invariant. The gap between the intent (provenance required) and the described enforcement (bare numbers rejected) is a hole a non-malicious reviewer falls through by writing a number and forgetting the source.
**Layer of the implied fix:** L2
**Anchor:** `# `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.`

### evaluation
**Verdict:** finding
**Failure:** `acceptanceScore` and `finalScore` have no scale. Reviewer A records `acceptanceScore: 0.85` (0–1). Reviewer B records `acceptanceScore: 85` (0–100). A downstream analysis that averages these treats them as 0.85 and 85.0 — a 100× difference from the same evaluation. The same applies to `finalScore`. Separately, `compile`, `tests`, and `hiddenTests` have no type guidance: `compile` could be a boolean, an exit code, or a log string; `tests` could be a count, a ratio, or a pass/fail tuple. Two reviewers produce different shapes for the same run. And `failureClass` is annotated `# F01-F15` but the 15 codes are neither defined nor referenced — a reviewer who does not have the external taxonomy cannot fill this field, and two reviewers with different versions of the taxonomy classify the same failure differently.
**Layer of the implied fix:** L3
**Anchor:** `acceptanceScore:` / `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is commented "structured, registered in advance" but neither the structure nor the registry is specified in the artifact. A reviewer who needs to exclude a run does not know whether to write a string (`"harness stall, no output past 9m"`), an object (`{ code: "H03", detail: "..." }`), or a reference to a pre-registered reason ID. Two reviewers excluding for the same cause write different shapes, and a downstream filter that expects a code field gets nothing from the string and crashes on the object. The "registered in advance" instruction has no pointer to where registrations live, so a reviewer cannot verify that their reason was registered before the run.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile`, `evaluation.tests`, and `evaluation.hiddenTests` restate the evaluator's gate results. If the run record is only filled for gate-passing runs (the CLAUDE.md context says the rubric only scores gate-passing submissions), these three fields are constants — always pass — across every scored record. They carry no information that distinguishes one scored run from another, the same structural defect that killed the v1 rubric's 60% dead weight. In a run record the duplication is less harmful than in a rubric (this is documentation, not scoring weight), but the fields still consume a reviewer's attention to fill and a reader's attention to parse, for a value that never varies within the population that matters.
- **Which single section would two reviewers diverge on most, and by how much?** `evaluation`. Every field in it is untyped. The divergence is not in borderline judgment calls but in the fundamental shape of the data — one reviewer's `compile: true` is another's `compile: 0` is another's `compile: "BUILD SUCCESSFUL in 4s"`. I would expect near-zero agreement on the representation, let alone the value, for at least four of the seven fields.
- **What did the artifact not say that it needed to say?** The scale of `acceptanceScore` and `finalScore`. The definition or source of the F01–F15 failure-class taxonomy. The composition of `environment.fingerprint` (which fields are hashed) and the meaning of "arms must match." The type of `behavior.approvals`. Whether `tools/validate-run-record.sh` enforces the full provenance requirement (source non-null when value is non-null) or only the bare-number rejection it is described as performing. What "structured, registered in advance" means for `exclusionReason` and where the registry lives.
