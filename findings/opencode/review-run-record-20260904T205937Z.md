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
reviewed_utc:    20260904T205937Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        b86401c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template uses field names and comments to claim proof or enforcement that nothing executes; six fields would mislead two readers in incompatible ways before any value is read.
  blocking:
    - reason: Field name "instructionsProvenLoaded" plus comment "preflight assertion result" claim proof, but no validator refuses `true` without a preflight having run.
      wrong_action: A reviewer sets the field to `true` without any preflight; downstream analysis trusts the name and treats the run as instruction-loading-verified when nothing was verified.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: Comment "arms must match" uses enforcement language for a cross-arm invariant that no executable enforces.
      wrong_action: Two arms in the same experiment record diverging fingerprints (one loaded an extra plugin); both pass the gate and get pooled, though the environments were not equivalent.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: Comment "permission requests — and whether anyone could answer" packs two distinct facts into one unstructured field with no schema to separate them.
      wrong_action: Reviewer A records `approvals: 0` (no requests); Reviewer B records `approvals: false` (nobody could answer); an aggregator treats both as a count and reports the agent was not blocked when it was.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: The level model defines three states by `source` (A: provider, B: local-tokenizer, C: null/null/null) but has no slot for "value present, source missing."
      wrong_action: A reader sees `inputTokens: { value: 12400, source: null, estimated: null }` and interprets it as Level C (no measurement) when a number was recorded, silently discarding it — or as Level A when no provenance was given.
      anchor: "#   { value: null,  source: null,            estimated: null  }   # Level C"
      evidence: templates/run-record.yaml:57
    - reason: failureClass range "F01-F15" exists only in a comment; nothing rejects `timeout` or `F99`.
      wrong_action: A reviewer records `failureClass: timeout`; downstream filtering by F01-F15 silently drops the run or treats it inconsistently across reviewers.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: status enum "valid / excluded / pilot / invalidated" exists only in a comment; nothing rejects `preliminary`. The field may also conflict with an executable gate, with no precedence rule stated.
      wrong_action: A reviewer records `status: preliminary` and it sits on disk as a fifth unregistered state; or the field says `excluded` while the gate returns "valid," and the conflict is unresolvable from the artifact.
      anchor: "status:                  # valid / excluded / pilot / invalidated"
      evidence: templates/run-record.yaml:77
  non_blocking:
    - reason: benchmarkSha and model.resolved are blank with descriptive comments only — no enforcement claim is made, so the divergence is treating an empty template field as filled, a normal template gap rather than a false claim.
      evidence: templates/run-record.yaml:6, templates/run-record.yaml:14-15
  disputed:
    - finding: Cross-cutting claim that evaluation.compile, tests, hiddenTests, and acceptanceScore duplicate a pass/fail gate.
      why: The artifact never references the evaluator gate. The finding's premise ("if this record is only kept for gate-passing runs") is conditional, and the artifact does not assert it.
    - finding: Cross-cutting claim that "every other field in the template is L3 by default unless the validator covers it, and the artifact never says where that coverage ends."
      why: The artifact references validate-run-record.sh exactly once (line 60) and explicitly describes its scope as Layer 3 for the efficiency block only. The extrapolation that silence elsewhere implies L3 status goes beyond what the artifact states.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 70s |

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
**Verdict:** finding
**Failure:** A run is recorded with `benchmarkSha:` left blank (as the template ships it). The task is later revised at the same SHA-qualified revision number. Two reviewers comparing this run against a re-run cannot tell whether both used the same task/evaluator version — one treats the gap as "same revision, safe to compare" and the other excludes the run for irreproducibility. The comment tells the writer what to fill in but nothing rejects the empty value, so the run lands on disk either way.
**Layer of the implied fix:** L3
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** The comment explicitly warns that "an alias can silently re-point between runs" — that is the failure mode this field pair exists to catch. A run records `requested: haiku` and `resolved:` (empty, as shipped). The alias re-pointed to a different model on that run. Two reviewers reading the record diverge: one says "requested was honored, resolved is just missing telemetry" and proceeds; the other says "without resolved we cannot confirm the alias did not move, exclude." The template's own warning names the defect it cannot prevent — nothing executes to refuse a record where `resolved` is blank while `requested` is filled.
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** `fingerprint` carries the comment "arms must match," implying a cross-arm comparison invariant. Two arms in the same experiment record different fingerprints (one loaded an extra plugin the other did not). Nothing in the template or any named validator rejects the pair — the comment is the entire control. One reviewer treats the arms as comparable because both passed their gates; the other invalidates the comparison because the environments diverged. The "must" in the comment reads as enforcement; it is a sentence a human has to remember.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is commented as "preflight assertion result" and its name asserts that something was *proven*. A writer sets it to `true` without running any preflight — nothing in the template or any named tool checks that a preflight actually executed before this field is set. Two reviewers reading the finished record diverge: one trusts the boolean name and treats the run as having confirmed instruction loading; the other asks for the preflight log, finds none, and questions whether the field was asserted at all. A field whose name claims proof but that can be set by typing `true` manufactures false confidence that is strictly worse than a blank.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is commented "permission requests — and whether anyone could answer" but has no defined structure. One reviewer records a count (`approvals: 3`); another records a list of objects (`approvals: [{request: "edit file", answered: false}]`); a third records a boolean (`approvals: false` meaning "nobody could answer"). When a run in `--bare` mode records zero approvals, one reviewer reads the empty field as "no approvals requested" and another reads it as "approvals were requested but nobody could answer, so the agent was blocked." The comment conflates two distinct facts — the requests and the ability to respond — into one unstructured field.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The provenance model defines three levels by the `source` field: A (provider), B (local-tokenizer), C (null/null/null — "nobody knows"). A run records `inputTokens: { value: 12400, source: null, estimated: null }` — a value is present but `source` is null. This is neither Level A, B, nor C as defined: Level C is "nobody knows" which the template encodes as `value: null`, but here someone *did* know a number. Two reviewers diverge: one reads it as "Level C, the value is a placeholder, ignore it"; the other reads it as "someone filled in a real measurement but forgot the source, so it is Level A or B with missing provenance — treat as unreliable but not absent." The template's own level definitions have no slot for "value present, source missing."
**Layer of the implied fix:** L3
**Anchor:** `#   { value: null,  source: null,            estimated: null  }   # Level C`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is commented `# F01-F15`, defining an enum range entirely in a comment. A run records `failureClass: timeout` or `failureClass: F99`. Nothing in the template or any named validator rejects it — the comment is the only statement of the range. Two reviewers filtering runs by failure class diverge: one accepts `timeout` as a reasonable label, the other rejects it because it is not in F01–F15. Separately, `compile`, `tests`, `hiddenTests`, and `acceptanceScore` are not distinguished from the evaluator gate's own results. If this record is only kept for gate-passing runs (as the rubric's v2 design assumes), these fields are constants — the same structural defect that killed the v1 rubric, where 60% of weight carried no information because it restated a gate. One reviewer treats `compile: pass` as independent confirmation; the other treats it as a gate restatement with no information content.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` is commented `# valid / excluded / pilot / invalidated`, an enum in a comment with no enforcement. A run records `status: preliminary`. One reviewer accepts it as a reasonable state; the other rejects it because it is not one of the four. More critically, `status` potentially duplicates `check-run-gate.sh` (Decision D), which independently decides whether a run may be scored. A run records `status: excluded` but the gate returns "valid," or vice versa. Two reviewers diverge on which signal wins: the human-written field in the record, or the executable gate. The template gives no precedence rule, and the two controls operate at different layers — the gate is L2, the field is L3 — so a conflict is not just possible but unresolvable from the artifact alone.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Yes. `evaluation.compile`, `evaluation.tests`, `evaluation.hiddenTests`, and `evaluation.acceptanceScore` are not distinguished from the evaluator gate's own verdicts. If the run record only exists for gate-passing runs, these fields are constants — the same defect that made the v1 rubric's gate-restating anchors carry zero information. The template does not say whether these are independent re-measurements or gate echoes.
- **Which single section would two reviewers diverge on most, and by how much?** `configuration.instructionsProvenLoaded` — by a wide margin. The field name claims proof and the comment calls it an "assertion result," but nothing asserts. One reviewer trusts the name; the other demands evidence. The divergence is not about interpretation of a value but about whether the field is a measurement or a self-attestation, and the template gives no way to tell.
- **What did the artifact not say that it needed to say?** The one L2 control referenced — `validate-run-record.sh` — is described only as rejecting "a bare number" for token fields. The template does not say what else the validator checks: whether it rejects an empty `benchmarkSha`, an empty `resolved` model, an out-of-range `failureClass`, an undefined `status`, or a `true` value for `instructionsProvenLoaded` with no preflight log. Every other field in the template is L3 by default unless the validator covers it, and the artifact never says where that coverage ends.
