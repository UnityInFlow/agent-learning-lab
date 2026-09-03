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
opencode:        1.18.21
reviewed_utc:    20260903T164550Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        911ee54
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template is L3 throughout, but its field names and comments make L2-shaped claims ("Proven", "must match", "registered in advance") that nothing in the template or its structure enforces — and the `behavior:` block carries the same gap-reads-as-zero problem the `efficiency:` block was specifically redesigned to prevent.
  blocking:
    - reason: The field name `instructionsProvenLoaded` is past tense — it asserts the value IS the result of an actual preflight assertion. The template provides no provenance (no timestamp, no tool reference, no signature) to distinguish a real assertion output from a self-report. A reviewer who skips the preflight can write `true` and the record reads identically to one where the preflight ran and passed.
      wrong_action: A downstream reader trusts `instructionsProvenLoaded: true` as evidence the configuration loaded; when it was a self-report, the experiment's configuration attribution is silently false.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: The `behavior:` block holds bare counters (`modelCalls`, `toolCalls`, `approvals`, `retries`, `compactions`) with no provenance, no null-vs-zero distinction, and no link to the per-field level of `measurement.telemetryComplete`. The template's own `efficiency:` block was given a value/source/estimated provenance mapping specifically because "a gap reads as a gap and not as a very efficient run" (line 54); the `behavior:` block has the same shape and no equivalent structure. Two reviewers recording the same run could disagree on whether `approvals:` blank means zero happened or the run was never tracked.
      wrong_action: A reader interprets `approvals:` blank as "0 permission requests" and another as "permission requests were not tracked" — the experiment's permission data is ambiguous by construction, and `telemetryComplete: true` does not rescue it because the boolean is record-wide, not per-field.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:38-46
    - reason: The comment on `measurement.exclusionReason` says "registered in advance" but the template field is a free-form scalar — no required `code`, no required registration date, no whitelist of accepted values. A post-hoc rationalization ("model seemed confused") is structurally indistinguishable from a pre-registered exclusion with a structured code. This is exactly what pre-registration is meant to prevent: cherry-picking bad runs out of the dataset after seeing the result.
      wrong_action: A reader treats `status: excluded` with a free-text reason as a principled, pre-committed exclusion; in fact it may be a post-hoc rationalization to drop an unfavorable run, and the template provides no way to tell the two apart.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
    - reason: The `environment.fingerprint` comment asserts "hash of the above; arms must match" — a constraint claim — but the template does not define which fields are hashed, does not require a `value:` and `algorithm:`, and provides no validator hook to compare arms. A reviewer can write any string into `fingerprint:` (or leave it blank) and the template reads identically regardless of whether arms are actually comparable.
      wrong_action: A reader trusts `fingerprint:` as a proof that two runs had comparable environments; when it was fabricated or computed against a different field set, the cross-run comparison the fingerprint is supposed to license is silently ungrounded.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: The `efficiency:` block documents two provenance sources (`provider`, `local-tokenizer`) but the source field is a free-form string with no enum or validator check. A reviewer computing `cost` from `inputTokens × price` has no template-level guidance for that provenance; another reviewer labelling the same derived number as `source: provider, estimated: false` (mislabelled) produces a record indistinguishable from a real provider-reported cost. The provenance label is a self-report, not an executable check.
      wrong_action: A reader trusts `cost: { source: provider }` as the provider's reported number when it was actually derived locally; the experiment's cost provenance is silently wrong.
      anchor: "#   { value: 12400, source: provider,        estimated: false }   # Level A"
      evidence: templates/run-record.yaml:51-60
  non_blocking:
    - reason: The `notes:` field (line 81-84) is the only place that names the danger of flattering findings — useful guidance, and its existence is evidence the template author knew about this class of failure. The same acknowledgment is not propagated to the fields that need it; this asymmetry is captured in the blocking reasons above.
      evidence: templates/run-record.yaml:81-84
    - reason: The `task.benchmarkSha` field is empty and commented as "the commit the task/evaluator were resolved from" — a useful pointer, not a defect, but it sits alongside the L2-claim L3-fields pattern (no enum, no validator hook) and is worth noting for the same reason.
      evidence: templates/run-record.yaml:6
  disputed:
    - finding: "Reviewer A … both pass validate-run-record.sh" — the line-level pass claims the validator accepts `derived` as an efficiency source, never touches the `model:` section, type-checks only `telemetryComplete`, and passes fabricated `instructionsProvenLoaded: true` and free-text `exclusionReason`.
      why: These are claims about `tools/validate-run-record.sh`, which is not the artifact under review. The template-level gaps (no enum on `source`, no provenance on `instructionsProvenLoaded`, no structure on `exclusionReason`, no `fingerprint` algorithm) stand on their own and are verifiable from this artifact; the validator's behaviour is not, and is outside this gate's evidence set.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 146s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| model | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

✱ Glob "tools/validate-run-record*.sh" 1 match
✱ Glob "**/run-record*" 1 match
→ Read tools/validate-run-record.sh
✱ Glob "**/GUARDRAILS.md" 1 match
✱ Glob "**/classify-model-output.sh" 1 match
→ Read GUARDRAILS.md
→ Read tools/classify-model-output.sh
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
**Failure:** Two reviewers record the same run. Reviewer A fills both `requested: haiku` and `resolved: claude-haiku-4-5-20251001`. Reviewer B fills `requested: haiku` and leaves `resolved:` blank. Both pass `validate-run-record.sh`, which never touches this section. Reviewer B's record cannot detect that the alias re-pointed — the exact failure the template's own comment calls "not a detail." The comment identifies the danger and provides no control for it, and the validator does not compensate.
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### configuration
**Verdict:** finding
**Failure:** Reviewer A runs the preflight check and records `instructionsProvenLoaded: true` (honest). Reviewer B skips the preflight and records `instructionsProvenLoaded: true` (fabricated). Both pass `validate-run-record.sh`. The field name asserts it is the *result* of a preflight assertion, but nothing distinguishes a real assertion output from a self-report. A run whose instructions silently failed to load is indistinguishable from one where they loaded and were verified.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** A run where no permission approvals were requested and a run where approvals were not tracked both produce `approvals:` blank. The `efficiency:` block was given a provenance mapping specifically so that "a gap reads as a gap and not as a very efficient run" (line 54); the `behavior:` block has the same gap-reads-as-zero problem and no provenance structure. `measurement.telemetryComplete` is a single boolean for the whole record and nothing in the template or validator ties it to individual `behavior:` fields — a record with `telemetryComplete: true` and `approvals:` blank passes, and two reviewers reading it diverge on whether blank means zero or untracked. This is the exact class of failure the template calls harness bug #7.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The template's comment documents two sources (`provider`, `local-tokenizer`) and three levels (A/B/C). The validator accepts a third source, `derived` (with `estimated: true`). A reviewer who computes `cost` from `inputTokens × price` finds no guidance for a derived value in the template. Reviewer A writes `source: derived, estimated: true` (correct, but undocumented in the template). Reviewer B writes `source: provider, estimated: false` for the same computed cost (mislabelled — it was not provider-reported). Both pass `validate-run-record.sh`. Reviewer B's record claims provider-reported provenance for a derived number, and the validator cannot distinguish them because the source label is a self-report the validator only type-checks.
**Layer of the implied fix:** L3
**Anchor:** `#   { value: 12400, source: provider,        estimated: false }   # Level A`

### evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### measurement
**Verdict:** finding
**Failure:** A run is excluded. Reviewer A writes `status: excluded` with `exclusionReason: { code: E001, registered: 2026-08-01 }` (pre-registered). Reviewer B writes `status: excluded` with `exclusionReason: model seemed confused` (post-hoc rationalization). Both pass `validate-run-record.sh`, which checks only that `telemetryComplete` exists. The template says "registered in advance" but a free-text exclusion invented after seeing the result is structurally indistinguishable from a pre-registered one. The pre-registration requirement — the thing that prevents cherry-picking exclusions — is unenforced.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? The `evaluation` block (`compile`, `tests`, `hiddenTests`, `acceptanceScore`) is the gate output. The rubric lives elsewhere and v2 already dropped `functional-correctness` and `requirement-completeness` for this reason. No duplication inside the template.
- Which single section would two reviewers diverge on most, and by how much? `behavior:` — every field is a bare counter with no provenance, no units, and no null-vs-zero distinction. Two reviewers recording the same run could disagree on whether `approvals:` blank means 0 or untracked, `retries:` blank means 0 or untracked, and so on. The divergence is wide: every field in the block is ambiguous in the same way, and the validator does not touch any of them.
- What did the artifact not say that it needed to say? The template acknowledges its own L3 nature exactly once — line 60, for `efficiency:` — and points to the L2 validator. Every other field with a comment that implies a constraint (`instructionsProvenLoaded` is a "preflight assertion result," `exclusionReason` is "registered in advance," `fingerprint` where "arms must match," `model.resolved` where a mismatch "is not a detail") makes the same implicit claim and gets no equivalent acknowledgment. A reader who trusts the `efficiency:` acknowledgment as a pattern will assume the other comments are also backed by enforcement; they are not.
