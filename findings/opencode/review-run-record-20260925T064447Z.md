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
reviewed_utc:    20260925T064447Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        492e6b6
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Five fields central to cross-run analysis — benchmark provenance, environment fingerprint, failure classification, acceptance-vs-final score, and the treatment-loaded invariant — are presented with intent (in comments or by name) but no structural enforcement or in-artifact definition, so two faithful readers will record the same run with different outcome numbers and the records will not be comparable.
  blocking:
    - reason: `acceptanceScore` and `finalScore` are similarly named fields with no disambiguation comment; the artifact's own cross-cutting note names this as the field pair reviewers diverge on most.
      wrong_action: A reviewer records the evaluator's pass/fail verdict in `acceptanceScore` and the rubric's numeric score in `finalScore`; another reverses them. Downstream aggregation then reads the rubric number where the evaluator verdict belongs (or vice versa) and the per-harness comparison is contaminated.
      anchor: |
        evaluation:
          compile:
          tests:
          hiddenTests:
          acceptanceScore:
          unintendedChanges:
          failureClass:            # F01-F15
          finalScore:
      evidence: templates/run-record.yaml:67-74
    - reason: `failureClass` is commented `# F01-F15` but the fifteen codes are not defined in the artifact and no codebook is referenced.
      wrong_action: A reviewer classifying a "correct output via a banned tool" failure as F03 cannot be corrected by another reviewer who says F07, because neither can cite an in-artifact definition; the classification is unreproducible across analysts and the failure-mode breakdown is not comparable across runs.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `fingerprint` is commented "hash of the above; arms must match" but no algorithm, no canonical field set, and no validator is named — the comment is unenforceable prose.
      wrong_action: Reviewer A hashes `bare` through `settingsSources` with SHA-256; reviewer B hashes only `hooks` through `mcpServers` with SHA-1. The same control and treatment environments produce different fingerprints: reviewer A excludes a control-vs-treatment pair (mismatch), reviewer B includes it (match), and the per-arm sample size differs between analysts.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `benchmarkSha` is left blankable — the field has no required marker and no validator reference; two runs recorded with `task.id: BE-001` can resolve the task from different benchmark commits without the schema flagging the divergence.
      wrong_action: An analyst comparing run A and run B treats them as the same task and attributes the score difference to the treatment, when in fact the benchmark was revised between them and the difference reflects the task having changed.
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
    - reason: `instructionsProvenLoaded: false` is structurally independent of `measurement.status`. Nothing in the schema forbids `status: valid` when the treatment was not proven to have loaded.
      wrong_action: One reviewer excludes the run (the treatment never applied, so the record measures the baseline, not the treatment); another includes it (the evaluator passed, so the run is data). The per-arm count depends on the reviewer's interpretation and the experiment's headline number is unstable.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
  non_blocking:
    - reason: `approvals` is a count but its comment names two dimensions (count + answerability). The comment flags the limitation; `notes` is the documented escape hatch for the second dimension.
      evidence: templates/run-record.yaml:45
    - reason: The Level A/B/C token-type system does not address the `{value: N, source: null, estimated: null}` case (value present, no provenance). The artifact explicitly tags this block "Layer 3 on its own" and names `validate-run-record.sh` only for the bare-number case; the value-without-source question is a validator question, not a template one.
      evidence: templates/run-record.yaml:51-65
    - reason: `status: pilot` is listed in the enum comment without explicit inclusion/exclusion semantics. The other three statuses imply their semantics from their names; `pilot` does not, though `exclusionReason` (described as "structured, registered in advance") provides a documented place to record the per-status reason.
      evidence: templates/run-record.yaml:77
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 121s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| task | 1/1 | L2 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L2 |
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
**Verdict:** finding
**Failure:** `benchmarkSha` can be left blank. Two runs both record `task.id: BE-001` — run A resolved the task/evaluator from commit X, run B from commit Y (the benchmark was updated between runs). With `benchmarkSha` blank in either record, a reader comparing the two runs treats them as the same task and attributes the score difference to the treatment, not to the task having changed underneath. One reviewer fills it in because the comment says to; another leaves it blank because nothing rejects blank, and the run is still accepted.
**Layer of the implied fix:** L2 (a validator that rejects a blank `benchmarkSha` would execute and stop this; the comment alone is L3)
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

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
**Failure:** `fingerprint` is commented as "hash of the above; arms must match" but no algorithm, no field set, and no match-rule is specified. Reviewer A hashes `bare` through `settingsSources` using SHA-256; reviewer B hashes only `hooks`, `plugins`, `skills`, `mcpServers` using SHA-1. The same environment produces two different fingerprints. When comparing a control arm and a treatment arm, reviewer A sees a mismatch (environment differs) and excludes the run; reviewer B sees a match and includes it. The "arms must match" instruction is unenforceable prose — nothing computes or compares the hash.
**Layer of the implied fix:** L3 (the comment describes an intention; no executable computes or validates the fingerprint)
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` records that the treatment (custom instructions) was not confirmed to have loaded, but nothing in the template connects this to `measurement.status`. A run where instructions silently failed to load but the agent produced correct code anyway — because the task was simple enough — can be recorded as `instructionsProvenLoaded: false` alongside `measurement.status: valid`. One reviewer excludes the run (the treatment never applied, so the result measures the baseline, not the treatment); another includes it (the output was correct, the evaluator passed). The template allows both readings because the two fields are structurally independent.
**Layer of the implied fix:** L2 (a validator that rejects `status: valid` when `instructionsProvenLoaded: false` would execute and stop this; today nothing does)
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a single count field, but its comment describes two dimensions: "permission requests — and whether anyone could answer." Run A records `approvals: 0` (no requests were made). Run B records `approvals: 3` (three requests were made in a non-interactive run, none could be answered, and the agent stalled or skipped those actions). Both are valid values for the field, but the answerability dimension — which is the part the comment flags as important — has no structural home. A reader comparing the two records sees 0 vs 3 and concludes B had more permission friction; they cannot see that B's requests went entirely unanswered, which is a harness failure, not agent behavior. One reviewer records answerability in `notes`; another does not, because the field structure doesn't prompt for it.
**Layer of the implied fix:** L3 (the comment describes a second dimension the field cannot structurally capture; relying on `notes` to carry it is guidance)
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The Level A/B/C provenance system defines three consistent states: `{value: N, source: provider, estimated: false}` (A), `{value: N, source: local-tokenizer, estimated: true}` (B), `{value: null, source: null, estimated: null}` (C). But the template does not address the inconsistent state `{value: 12400, source: null, estimated: null}` — a value present with no provenance. The comment says the validator "rejects a bare number," which enforces the object shape, but nothing is said about rejecting a value-without-source. One reviewer accepts `value: 12400, source: null` as a valid Level-C-adjacent reading (at least the number is there); another rejects it as meaningless (a number you cannot trace is worse than null, because it looks like data). If the validator only checks key presence and not value-source consistency, the inconsistent state passes, and a run reports token counts that look authoritative but are unverifiable.
**Layer of the implied fix:** L2 (a validator that rejects `value` present with `source` null would execute and stop this; the comment block itself is L3)
**Anchor:** `#   { value: null,  source: null,            estimated: null  }   # Level C`

### evaluation
**Verdict:** finding
**Failure:** Two problems, the more serious first. (1) `acceptanceScore` and `finalScore` are adjacent fields with no disambiguating comment. One reviewer puts the evaluator's pass/fail verdict in `acceptanceScore` and the rubric's numeric score in `finalScore`; another puts the rubric score in `acceptanceScore` (reading "acceptance" as the rubric accepting the submission) and leaves `finalScore` for something else. A run that passed the evaluator but scored low on the rubric is recorded differently by each — the fields are swapped, and downstream analysis reads the wrong number. (2) `failureClass` is commented `# F01-F15` but the fifteen codes are never defined in the template. A run where the agent produced correct code using a banned tool — one reviewer classifies as F03, another as F07, and neither can cite a definition to settle it.
**Layer of the implied fix:** L3 (both are comment-as-enum and adjacent-unnamed-fields; no validator is referenced for either)
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` is commented `# valid / excluded / pilot / invalidated` but "pilot" is not defined as included or excluded. A first-time run on a new harness configuration is marked `pilot` by one reviewer (meaning "we ran it to see if the harness works, the data is exploratory") and `valid` by another (meaning "it ran, it produced a score, it counts"). The same run is either in the dataset or out of it. The other three statuses have clear inclusion semantics; "pilot" does not.
**Layer of the implied fix:** L3 (the enum is a comment; no validator is referenced, and even if one checked membership, "pilot" is a valid member that passes)
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile` and `evaluation.tests` record the evaluator's gate outputs. They are not restatements in the rubric sense — they are the gate results themselves, recorded here. But `acceptanceScore` may duplicate the evaluator's overall verdict that `check-run-gate.sh` already records; if so, it is a constant across every gate-passing run this record can describe, and its information content is zero within the scored set. The template does not distinguish "the evaluator's verdict" from "a separate acceptance score," so the duplication cannot be confirmed or ruled out.
- **Which single section would two reviewers diverge on most?** `evaluation`, by a wide margin. `acceptanceScore` vs `finalScore` is an unlabelled pair of similar-named fields, and `failureClass` references an undefined 15-code taxonomy. A reviewer filling in this template has to make two independent judgement calls with no structural support, and the section carries the experiment's outcome numbers.
- **What did the artifact not say that it needed to say?** The F01–F15 failure-class codes are referenced and never defined. The `environment.fingerprint` hash algorithm and field set are unspecified. The relationship between `acceptanceScore` and `finalScore` is unstated. Whether `instructionsProvenLoaded: false` should force `measurement.status` to a non-valid value is unstated. Whether `task.benchmarkSha` may be blank is unstated. Each of these is a point where two faithful readers diverge, and each is currently held by a comment or by nothing.
