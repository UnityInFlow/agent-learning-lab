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
reviewed_utc:    20260925T064317Z
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
  summary: The template claims a record is a comparable instrument for cross-run analysis but does not enforce field shapes, does not mark required fields, and cites external concepts (harness bug #7, F01–F15, "arms", "registered in advance") without pointing to their definitions — two reviewers filling in the same template will produce records that cannot be unioned.
  blocking:
    - reason: behavior.approvals / retries / compactions have no type
      wrong_action: a reader summing approvals across runs gets 3 + true + list-length depending on who filled the record; cross-run aggregation of these fields is meaningless
      anchor: "  approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:44-46
    - reason: evaluation.compile / tests / hiddenTests / acceptanceScore / unintendedChanges / finalScore have no type
      wrong_action: a reader comparing compile outcomes across runs gets "true" vs "0" vs "BUILD FAILED" — the comparison is meaningless
      anchor: "  compile:"
      evidence: templates/run-record.yaml:68-71
    - reason: evaluation.failureClass references F01–F15 without defining them or saying whether one or many codes are permitted
      wrong_action: a run with both a compile and a test failure is recorded as "F03" by one reviewer and "[F03, F07]" by another; the disagreement is structural, not just a value difference
      anchor: "  failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: model.resolved is described as critical ("not a detail") but not marked required, so reviewers leave it blank as often as they fill it
      wrong_action: an alias re-pointing between runs (the exact failure mode the comment warns about) is invisible because resolved is unfilled in roughly half of records
      anchor: "# These differing is not a detail. An alias can silently re-point between runs."
      evidence: templates/run-record.yaml:14-16
    - reason: task.benchmarkSha has no required marker; a blank field is indistinguishable from "not recorded" or "not applicable"
      wrong_action: a run against benchmark commit X cannot be distinguished from a run against Y when both leave benchmarkSha blank — irreproducibility is hidden in the record set
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
    - reason: harness.version is a bare blank field with no comment at all
      wrong_action: a regression introduced by a harness update is invisible across the record set; two runs on different versions are indistinguishable from runs where nobody checked
      anchor: "  version:"
      evidence: templates/run-record.yaml:20
    - reason: environment.permissionMode references "harness bug #7" without naming a file, URL, or document where bug #7 is described
      wrong_action: a reviewer without prior knowledge cannot tell which values are valid; records `acceptEdits` correctly while another records `default` correctly, both thinking they followed the template
      anchor: "  permissionMode:          # acceptEdits / plan / default — see harness bug #7"
      evidence: templates/run-record.yaml:20
    - reason: environment.fingerprint says "arms must match" but "arms" is undefined in the template
      wrong_action: a reviewer does not know what to hash or what matching requires; the field is left blank or filled as a free-text guess, defeating the cross-arm comparison the comment demands
      anchor: "  fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: measurement.exclusionReason says "structured, registered in advance" but does not point to where the registry lives, in what format, or who maintains it
      wrong_action: a post-hoc exclusion written as free text is indistinguishable from a pre-registered one — the pre-registration guarantee the comment claims is unenforceable from the template alone
      anchor: "  exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:79
    - reason: cross-cutting — the template never distinguishes required fields from optional ones, so a blank benchmarkSha, a blank version, and a blank resolved are all gaps with no provenance, indistinguishable from "not applicable"
      wrong_action: a downstream reader cannot tell "data was not collected" from "data was collected and is null" — the only section that solves this (efficiency, via Level A/B/C) does not propagate its pattern to the rest of the template
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6,14-16,20
  non_blocking:
    - reason: behavior.modelCalls and toolCalls have the same type-ambiguity as approvals/retries/compactions; the line-level pass flagged the latter three and missed these two (consistent under-report per CLAUDE.md)
      evidence: templates/run-record.yaml:38-39
    - reason: runId at line 1 carries a concrete example value (B0-COPILOT-BE001-001); a first-time reviewer may treat it as a template convention to keep rather than a per-run field to replace
      evidence: templates/run-record.yaml:1
  disputed: []
  needed_to_decide: []
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
| task | 1/1 | L3 |
| harness | 1/1 | L3 |
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
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
**Failure:** `benchmarkSha` is shown blank with a comment ("the commit the task/evaluator were resolved from") but no marker that it is required. Reviewer A fills it in because the comment tells them what it is; Reviewer B leaves it blank because the template shows it blank and nothing says they must not. Two runs of the same task against different benchmark commits are now indistinguishable from a run where the sha was simply not recorded — the record cannot tell "irreproducible" from "not filled in."
**Layer of the implied fix:** L3
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** finding
**Failure:** `version` is a bare blank field with no comment at all. Reviewer A records the harness version string; Reviewer B leaves it blank, assuming it is optional. Two runs on different harness versions with blank `version` fields are indistinguishable — a regression caused by a harness update is invisible in the record. `runnerCommit` has the same problem but at least has a self-explanatory name; `version` does not even have that.
**Layer of the implied fix:** L3
**Anchor:** `  version:`

### model
**Verdict:** finding
**Failure:** The comment warns that `requested` and `resolved` differing "is not a detail" because "an alias can silently re-point between runs." But the template does not require `resolved` to be filled. Reviewer A fills both; Reviewer B fills only `requested` (what they asked for) and leaves `resolved` blank because no comment says it must be populated. The alias-re-pointing signal the comment calls critical is silently lost — a run where `haiku` resolved to a different model is indistinguishable from a run where nobody checked.
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** Two problems, the more serious first. `permissionMode` has the comment `# acceptEdits / plan / default — see harness bug #7`. "Harness bug #7" is a dangling reference — the template names no file, no URL, no document where bug #7 is described. A contributor who does not already know what bug #7 is cannot determine what values are valid or how the bug affects what they should record. Reviewer A (who knows the bug) records `acceptEdits`; Reviewer B (who does not) guesses `default` or leaves it blank. Second: `fingerprint` says "hash of the above; arms must match." "Arms" is undefined jargon in this template — it does not appear elsewhere. A new contributor does not know whether "arms" means experimental arms, harness arms, or something else, and does not know what "must match" requires them to do with the hash.
**Layer of the implied fix:** L3
**Anchor:** `permissionMode:          # acceptEdits / plan / default — see harness bug #7`

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### behavior
**Verdict:** finding
**Failure:** Three fields have no type specification, and two reviewers would record them in incompatible shapes. `approvals` says "permission requests — and whether anyone could answer" — is this a count, a list of events, a boolean, or a structured object? Reviewer A writes `3`; Reviewer B writes `[{tool: "bash", granted: true}, ...]`; Reviewer C writes `true`. The records are not comparable. `retries` has no comment at all — retries of what (model calls? tool calls?) and in what shape (count? list?). `compactions` likewise has no comment. A downstream analysis that counts approvals across runs gets `3`, `true`, or a list length depending on who filled in the record.
**Layer of the implied fix:** L3
**Anchor:** `  approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** Two problems, the more serious first. `compile` and `tests` are bare fields with no comment and no type. Are they booleans (passed/failed), exit codes (0/1), counts (12 passed), or strings (error messages)? Reviewer A writes `true`; Reviewer B writes `0`; Reviewer C writes `"BUILD FAILED"`. A cross-run comparison of compile outcomes is meaningless. Second: `failureClass` says `# F01-F15` but the template does not define what F01 through F15 are, does not say whether only one class may be recorded or multiple, and does not point to where the definitions live. A run with both a compile failure and a test failure: Reviewer A records `F03` (the primary); Reviewer B records `[F03, F07]`. The records disagree on structure, not just value.
**Layer of the implied fix:** L3
**Anchor:** `  failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` has the comment "structured, registered in advance." The template does not say where exclusion reasons are registered, in what format, or by whom. Reviewer A writes a free-text string ("harness stalled"); Reviewer B tries to look up a registry they cannot find and writes nothing; Reviewer C invents a structured object. The "registered in advance" constraint — which is the whole point of pre-registering exclusions — is unenforceable from the template alone, and a post-hoc exclusion written as free text is indistinguishable from a pre-registered one in the record.
**Layer of the implied fix:** L3
**Anchor:** `  exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The `evaluation` section records gate *outcomes* (compile, tests, acceptanceScore) — it is a run record, not a rubric. Recording what a gate returned is not restating the gate's rule.
- Which single section would two reviewers diverge on most, and by how much? `behavior` — three fields (`approvals`, `retries`, `compactions`) have no type, and the divergence is structural (number vs list vs boolean), not merely a different value of the same type. Two reviewers would produce records that cannot be unioned without a schema decision the template does not make.
- What did the artifact not say that it needed to say? The template never distinguishes required fields from optional ones. A reviewer filling it in for the first time does not know which blanks are acceptable gaps and which are missing data. The `efficiency` section solves this for tokens with the Level A/B/C default ("starts at Level C"), and `measurement.telemetryComplete` solves it for telemetry ("a gap must not read as a zero") — but no other section has an equivalent. A blank `benchmarkSha`, a blank `version`, and a blank `resolved` are all gaps with no provenance, indistinguishable from "not applicable."
