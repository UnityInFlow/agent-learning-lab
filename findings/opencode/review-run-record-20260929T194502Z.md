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
reviewed_utc:    20260929T194502Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        0b09394
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template permits blanks and ambiguities in the very fields that pin a run's identity, with two reviewers of the same run able to record opposite conclusions — it would mislead anyone who filled it in as-is.
  blocking:
    - reason: `benchmarkSha` is comment-only and the template has no validator that rejects a blank, so two runs with identical `id`/`revision` but different benchmark SHAs become indistinguishable from a same-SHA pair.
      wrong_action: A reviewer treats both runs as comparable and aggregates their results; if the evaluator changed between them, the comparison is invalid and downstream conclusions are corrupted.
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
    - reason: `resolved` is comment-only with no required-value constraint, and the comment itself flags the alias-re-pointing risk the template does nothing to defend against.
      wrong_action: A reviewer keeps a run whose `requested: haiku` has been silently re-pointed to a different model version, treating the run as comparable to an earlier haiku run — the comment's own warning is realized because the template did not enforce it.
      anchor: "resolved:                # what telemetry reports, e.g. \"claude-haiku-4-5-20251001\""
      evidence: templates/run-record.yaml:16
    - reason: `environment` and `configuration` share field names (`hooks`, `skills`, `mcp`/`mcpServers`) with only a prose boundary, and `fingerprint` says "hash of the above" without naming algorithm or inclusion set.
      wrong_action: Two reviewers filling in the same run place a custom hook in different sections, hash different field sets, produce different fingerprints, and cannot reconcile arms — the cross-arm check that exists to catch drift fails for reasons neither reviewer can diagnose.
      anchor: "environment:               # everything that loaded but was not the treatment"
      evidence: templates/run-record.yaml:18,34
    - reason: `instructionsProvenLoaded: false` is the template default with no tri-state — "assertion ran, not loaded" and "assertion never ran" both read false.
      wrong_action: One reviewer reads false as "confirmed not loaded, exclude"; another reads it as "we don't know, keep pending" — the same record produces opposite inclusion decisions for the same run.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: `approvals` has no provenance structure and an empty value is indistinguishable from "no permission requests were issued," even though the comment names the unknown-approvals case.
      wrong_action: A non-interactive `opencode run` that stalled waiting for an unanswerable permission request gets recorded as a clean run, and a downstream reviewer A treats it as evidence the harness completed without intervention.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: `failureClass` references F01–F15 but the taxonomy is neither defined nor located anywhere in the artifact; reviewers must import an external document whose version they cannot verify.
      wrong_action: Two reviewers classify the same run as different F-numbers (e.g. F01 vs F02 depending on which external taxonomy they hold), and any aggregate analysis of failure modes is corrupted by the disagreement.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `telemetryComplete` is a single boolean so blank and false collapse to the same value, and `exclusionReason` references a "registered in advance" registry whose location the artifact does not name.
      wrong_action: One reviewer treats blank `telemetryComplete` as "not assessed, follow up"; another coerces it to false and excludes the run — and even when exclusion is the right call, two reviewers may record different reason strings for the same cause, breaking aggregation of exclusions.
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:79
 - reason: `evaluation.compile`, `evaluation.tests`, and `evaluation.hiddenTests` restate outcomes the lab's gates (`verify-evaluator.sh`, `check-run-gate.sh`) already decide on, so for any run the gates admit, these fields are constants and cannot discriminate.
      wrong_action: A reader treats these fields as carrying information about run quality and either weights them in an aggregate or uses them to differentiate runs that the gate already forced to be identical — the same defect CLAUDE.md names in the old seven-category rubric ("any anchor restating a gate is a constant across everything it can score") is reproduced here in the evaluation section.
      anchor: "evaluation:"
      evidence: templates/run-record.yaml:67-70
  non_blocking:
    - reason: The efficiency token-usage blocks already model provenance correctly (`value`/`source`/`estimated`) — this is the right pattern and the same tri-state should be applied to `approvals` and `telemetryComplete`.
      evidence: templates/run-record.yaml:61-65
    - reason: The notes section's closing guidance ("five of our seven harness bugs were caught fast because they looked bad; the two that survived review were the two that flattered the result") is a useful standing instruction; consider making it a header above the field rather than free-text.
      evidence: templates/run-record.yaml:81-84
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 62s |

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
**Failure:** Two runs both record `id: BE-001, revision: 1` but one leaves `benchmarkSha` blank. The benchmark was updated between them — the evaluator changed, the task definition changed. A downstream comparison treats both as "BE-001 rev 1" because the only field that pins the commit is empty. Reviewer A excludes the blank-sha run as unverifiable; Reviewer B accepts it because the task id and revision match. They produce different experiment conclusions from the same data.
**Layer of the implied fix:** L3
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** A run records `requested: haiku` and leaves `resolved:` blank. The comment warns that "an alias can silently re-point between runs," but nothing in the template requires `resolved` to be filled. Weeks later the `haiku` alias is re-pointed to a different model version. Reviewer A reads the blank as "unverifiable model identity, exclude from cross-run comparison"; Reviewer B reads `requested: haiku` as sufficient and keeps the run. The alias-re-pointing risk the comment warns about is realized, and the template's own guidance is the only thing that could have caught it.
**Layer of the implied fix:** L3
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"`

### environment
**Verdict:** finding
**Failure:** `hooks` (line 21), `skills` (line 23), and `mcpServers` (line 24) appear in `environment`, and `hooks` (line 34), `skills` (line 32), and `mcp` (line 35) appear in `configuration`. The only thing separating them is a prose comment: environment is "everything that loaded but was not the treatment," configuration is "the registered treatment." A custom hook that was loaded by the user's global config AND is the thing being tested lands in both buckets. Reviewer A puts it in `configuration.hooks` (it is the treatment); Reviewer B puts it in `environment.hooks` (it loaded from the user config, not the experiment). The two run records describe the same run with different arms, and `fingerprint` — "hash of the above" — hashes different field sets, so the arms don't match and neither reviewer can tell why. The fingerprint computation is also unspecified: "hash of the above" names neither the algorithm nor the exact field inclusion set, so two people computing it for the identical environment produce different hashes.
**Layer of the implied fix:** L3
**Anchor:** `environment:               # everything that loaded but was not the treatment`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` defaults to `false` in the template. The comment says "preflight assertion result," implying `false` means "the assertion ran and the result was negative." But a reviewer filling in the template who never ran the preflight also leaves it at `false` — the template default. Three states collapse into two values: "assertion ran, instructions not confirmed" and "assertion never ran, unknown" both read `false`. Reviewer A reads `false` as "confirmed not loaded, exclude the run"; Reviewer B reads it as "preflight wasn't run, we don't know, keep it pending." The same run record produces opposite inclusion decisions.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is commented "permission requests — and whether anyone could answer." In a non-interactive `opencode run` (the lab's primary mode), if the agent requests permission, nobody can answer, and the run may stall. But `approvals` left empty reads identically to "no permissions were requested." The `measurement.telemetryComplete` field carries the "a gap must not read as a zero" guidance; `approvals` has no equivalent. Reviewer A reads an empty `approvals` as "clean run, no approvals needed"; Reviewer B reads it as "approvals may have been requested and not recorded, the stall risk is unknown." The same run record produces different confidence levels about whether the run was clean.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15` but the fifteen classes are neither defined nor located in the artifact. A run fails to compile because the agent generated a Kotlin file with a syntax error. Reviewer A looks up the taxonomy in one document and classifies it as F02 (compile failure); Reviewer B finds a different version of the taxonomy where F02 is "test failure" and F01 is "compile failure," and classifies it as F01. The same run gets different failure classes, and any aggregate analysis of failure modes is corrupted. The artifact references an enum it does not contain.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `telemetryComplete` is a single boolean field with the comment "a gap must not read as a zero." But a blank `telemetryComplete` and `telemetryComplete: false` are different YAML states that two reviewers handle differently: Reviewer A treats blank as "not assessed, flag for follow-up"; Reviewer B treats blank as `false` (YAML coercion or downstream parser default), reads it as "telemetry was incomplete," and excludes the run. The comment identifies the problem but the field type doesn't enforce the distinction — a boolean has no "unknown" state. Separately, `exclusionReason` says "structured, registered in advance" without specifying where the registry lives, so two reviewers excluding runs for the same reason may record different reason strings and the exclusions can't be aggregated.
**Layer of the implied fix:** L3
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile`, `evaluation.tests`, and `evaluation.hiddenTests` record the same outcomes the evaluator gates on (the lab's `verify-evaluator.sh` and `check-run-gate.sh`). If those gates pass before the run record is filled in, these fields are constants across every recordable run — they restate the gate rather than carrying information. This is the same defect the CLAUDE.md identifies in the old seven-category rubric ("any anchor restating a gate is a constant across everything it can score"), now present in the run record's evaluation section.
- **Which section would two reviewers diverge on most?** `environment` / `configuration` — by a wide margin. The overlapping field names (`hooks`, `skills`, `mcp`/`mcpServers`) with only a prose boundary means the same run's customizations land in different sections depending on who fills in the record, and the `fingerprint` hash then disagrees for reasons neither reviewer can diagnose. I would expect disagreement on nearly every run that has a hook or skill active.
- **What did the artifact not say that it needed to say?** Three things: (1) where the F01–F15 failure-class taxonomy is defined, (2) what hash algorithm and field set `fingerprint` uses, and (3) where the "registered in advance" exclusion-reason registry lives. All three are referenced by name and none are located. A reader picking up this template cold cannot fill in `failureClass`, compute `fingerprint`, or structure `exclusionReason` without external knowledge the artifact does not point to.
