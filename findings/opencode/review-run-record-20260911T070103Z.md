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
reviewed_utc:    20260911T070103Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        96be718
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Seven fields either claim structure the schema cannot deliver or rely on enumerations the artifact never names; a filler following the template alone produces records whose dependent variables — model identity, failure class, exclusion rate, permission state, treatment load, env comparability, benchmark pin — are incomparable across reviewers and across runs, and the efficiency block is the only one that names its own validator or layer.
  blocking:
    - reason: evaluation.failureClass is annotated `# F01-F15` but the 15 classes are never enumerated anywhere in the artifact; a filler has to look elsewhere or guess, and the comment asserts an enum the template does not provide.
      wrong_action: Three reviewers facing the same stalled run classify it F09, F15, and free-text "harness-stall" respectively; the failure-class distribution across the run corpus is then three reviewers' guesses under one label.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: measurement.exclusionReason is commented "structured, registered in advance" but the field is a bare scalar with no structure shown and no registry named; the comment asserts a contract the schema cannot satisfy.
      wrong_action: A reliability analyst computes the per-cause exclusion rate and gets a flat distribution, because every cause has been relabelled ("harness stall" / "opencode run failed to return" / "model unresponsive") — the dependent variable for any reliability analysis is unmeasurable.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
    - reason: behavior.approvals is a YAML list whose comment says it captures "whether anyone could answer" — a list holds items, not the "who could answer" property; an unattended run that stalls on an unanswered permission prompt and a run that never hit a prompt both record `[]` and are indistinguishable downstream.
      wrong_action: An analyst computes the zero-approval rate across N runs and concludes permission prompts are rare — when in fact N−k runs were dropped for stalling on unanswered prompts whose structure was never recorded.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: configuration.instructionsProvenLoaded defaults to false with comment "preflight assertion result" — the template records the boolean but says nothing about what `false` means for scoring eligibility; a filler can set it correctly, but a downstream reader cannot tell whether `false` is "assertion didn't run" or "treatment not proven loaded."
      wrong_action: A run with a silently-unproven treatment is published as evidence for that treatment's effect because `false` was read as "the assertion didn't run, so we don't know — score it" rather than "exclude."
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: environment.fingerprint carries "hash of the above; arms must match" but no algorithm, no comparison rule (byte-equality / subset / component-level), and no validator reference; two reviewers legitimately diverge on what counts as a match.
      wrong_action: Reviewer A publishes a cross-arm comparison because the fingerprints are "close"; Reviewer B excludes the same comparison because they don't match by the strict criterion — and neither is wrong by the template.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: model.resolved is left blank in the template with a comment warning that an alias "can silently re-point between runs" but no validator reference; the efficiency block names `validate-run-record.sh` as its enforcement, this block names nothing — a filler has no signal the field must be filled from telemetry, and the warning the comment itself issues is unbacked.
      wrong_action: Two runs requested "haiku" months apart are compared as same-model when the alias re-pointed between them, because `resolved` was left blank and downstream tooling fell back to `requested`.
      anchor: "resolved:                # what telemetry reports, e.g. \"claude-haiku-4-5-20251001\""
      evidence: templates/run-record.yaml:15
    - reason: task.benchmarkSha is left blank with a comment naming the field but no validator reference and no rule for what blank means at fill time (current commit? unknown? exclude?); the asymmetry with the efficiency block is the defect — one block tells you its enforcement exists, this one tells you nothing.
      wrong_action: A run recorded against task revision 2 is later scored against revision 3's evaluator and the score is silently wrong, because `benchmarkSha` was blank and downstream tooling fell back to "current."
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
  non_blocking:
    - reason: evaluation.compile / tests / hiddenTests record gate outputs without naming a scoring consumer — the same constant-across-gate-passing-runs pattern that killed the seven-category rubric per CLAUDE.md, but the template doesn't claim they're scoring fields and a runner can keep them as provenance.
      evidence: templates/run-record.yaml:68-74
    - reason: measurement.status is a 4-value enum spelled out in the comment (valid / excluded / pilot / invalidated) — better than `failureClass` but with no decision criteria for which value applies; a reviewer still has to guess on the borderline cases.
      evidence: templates/run-record.yaml:77
    - reason: notes is unstructured free-text by design and correctly labelled as such.
      evidence: templates/run-record.yaml:81-84
    - reason: The efficiency block is well-specified (names its validator, defines a 3-level provenance system, explains why null is a measurement) and could serve as the model the other blocks should be rewritten against — worth flagging because the asymmetry is the smoking gun, not a defect in itself.
      evidence: templates/run-record.yaml:48-65
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 92s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| task | 1/1 | L3 |
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
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
**Verdict:** finding
**Failure:** `benchmarkSha` and `revision` are blank with only a comment. A run is recorded against task revision 2 but the `revision` field is left blank. Later, the benchmark advances to revision 3. The run is scored against revision 3's evaluator. Reviewer A assumes blank means "current at time of scoring"; Reviewer B assumes blank means "unknown, exclude." The run's score is either wrong or discarded depending on who fills it in. The efficiency block explicitly names `validate-run-record.sh` as its enforcement — this block names nothing, so a reviewer cannot tell whether leaving it blank is caught or silent.
**Layer of the implied fix:** L3
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** `resolved` is blank in the template. A run requests `haiku`, the alias resolves to `claude-haiku-4-5-20251001`, but the reviewer leaves `resolved` blank because nothing flags it as required. Between runs the alias silently re-points to a different model. Two runs are compared as if against the same model. The comment warns this "is not a detail" but the template provides no enforcement and, unlike the efficiency block, names no validator that checks it. A reviewer who trusts the template's structure over its comments would leave it blank.
**Layer of the implied fix:** L3
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"`

### environment
**Verdict:** finding
**Failure:** `fingerprint` carries the comment "arms must match" but the template provides no enforcement reference and no definition of what "match" means (exact string equality? same hash algorithm? subset?). Two arms are compared: Arm A loaded plugin X, Arm B did not. Their fingerprints differ. Reviewer A publishes the comparison because "the fingerprint is just informational"; Reviewer B excludes it because "arms must match." The template gives no way to resolve this. The efficiency block's comment shows the template *can* name its enforcement mechanism when one exists — this block does not.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` defaults to `false`. A run is recorded with `instructions: custom-v2`, `instructionsProvenLoaded: false`, and `measurement.status: valid`. The preflight assertion never fired (the harness loaded the wrong file, or the assertion was skipped). The run is scored as a valid measurement of custom-v2's effect. Reviewer A reads `false` as "the assertion didn't run, so we don't know — score it"; Reviewer B reads `false` as "the treatment wasn't proven loaded, exclude it." The template records the boolean but says nothing about what `false` means for scoring eligibility.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a list with the comment "permission requests — and whether anyone could answer." An unattended run hits a permission prompt, nobody answers, the agent stalls for 10 minutes and produces partial output. The reviewer records `approvals: []` because no approvals were *granted*. A second run needs no approvals and also records `approvals: []`. The two runs are indistinguishable: one ran freely, one was blocked. The comment says the field should capture "whether anyone could answer" but the list structure has no place for "prompted, unanswered" — only granted approvals appear as items.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15` but the 15 classes are never defined anywhere in the template. A run fails because the harness hung — a known failure mode per the lab's own findings. Reviewer A classifies it as F15 (assuming F15 is "harness failure"); Reviewer B classifies it as F09 (assuming F09 is "timeout"); Reviewer C writes "harness-stall" because they don't know the enum is closed. The failure-class distribution across runs is now incomparable. The comment asserts an enum but the template provides no enumeration, no reference to where F01-F15 are defined, and no validator reference (unlike the efficiency block, which names its validator).
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is commented "structured, registered in advance" but the field is a bare scalar with no structure shown and no reference to a registry. A run stalls on `opencode run` (a known harness hang). Reviewer A excludes with reason `"harness stall"`. Reviewer B excludes with reason `"opencode run failed to return"`. Reviewer C excludes with reason `"model unresponsive"`. All three describe the same event. The exclusion rate — the dependent variable for any reliability analysis — is now unmeasurable because the same cause appears under three names. The comment claims pre-registration but the template provides neither the registry nor the structure that would make it enforceable.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile`, `evaluation.tests`, and `evaluation.hiddenTests` record gate outputs. In any scored run the gate has already passed, so these are constants across the scored population. The run record is a measurement instrument and recording gate outputs is provenance — but if these fields are ever consumed for scoring or comparison, they carry no information, exactly the defect that killed the seven-category rubric. The template does not say which consumer reads them.
- **Which section would two reviewers diverge on most?** `measurement`. The `status` / `exclusionReason` pair is the most subjective decision in the record, and the template provides the least structure for it — a bare scalar for the reason and a four-value enum for the status with no decision criteria. Two reviewers facing the same stalled run would diverge on both whether to exclude and what to call it.
- **What did the artifact not say that it needed to say?** Four things: (1) the F01–F15 failure-class enumeration; (2) the exclusion-reason registry it claims to use; (3) what `instructionsProvenLoaded: false` means for scoring eligibility; (4) how `approvals` records "prompted but unanswered" as distinct from "no prompts." The efficiency block demonstrates the template *can* name its enforcement mechanism and acknowledge its own layer — the other sections that need enforcement do not, and a reviewer cannot tell from the template alone whether silence means "the validator checks it" or "nothing checks it."
