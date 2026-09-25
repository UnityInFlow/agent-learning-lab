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
reviewed_utc:    20260925T132902Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        c0fb676
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A run-record template whose most consequential fields are defined by example or comment-as-prose rather than by type — evaluation scores, behavior counts, run status, duration-on-hang, failure category — so two reviewers filling in the same run produce records that cannot be aggregated.
  blocking:
    - reason: evaluation.acceptanceScore and evaluation.finalScore are not distinguished; the template does not say whether acceptanceScore is the evaluator's binary pass/fail verdict or a rubric score, so one reviewer records the gate verdict in acceptanceScore and another records a rubric score there.
      wrong_action: A reader computing mean finalScore across runs would bin "passed gate, scored 2/3 on rubric" alongside "gate verdict recorded as 2" in the same column and report a mean that mixes two different quantities — restating a gate as a measurement.
      anchor: " acceptanceScore:"
      evidence: templates/run-record.yaml:71
    - reason: behavior.approvals, behavior.retries, and behavior.compactions have no defined structure; the comment on approvals explicitly asks for more than a count ("whether anyone could answer") without specifying a shape, so reviewers fill in count / structured object / list of events in three different ways.
      wrong_action: A reader aggregating approval rates across runs would compute sum/count over runs recorded as a count and sum(answered)/count over runs recorded as a structured object — two different metrics in one comparison.
      anchor: "  approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
    - reason: configuration collapses five distinct fields (instructions, skills, customAgent, hooks, mcp) into the same string "none", erasing the difference between "not configured" and "configured but failed to load" — the latter being the most likely confounder for any performance difference.
      wrong_action: A reader investigating why a run underperformed would see `mcp: none` and rule out MCP entirely, missing that an MCP server was configured and failed to connect at startup.
      anchor: "  mcp: none"
      evidence: templates/run-record.yaml:35
    - reason: measurement.status enumerates four values (valid / excluded / pilot / invalidated) but does not define when excluded vs invalidated applies; the comment on exclusionReason ("structured, registered in advance") implies a pre/post-hoc distinction the template never states.
      wrong_action: A reader filtering on `status: excluded` to find pre-registered exclusions would silently miss runs marked `invalidated` for post-hoc crashes, dropping them from one analysis and including them in another.
      anchor: "  status:                  # valid / excluded / pilot / invalidated"
      evidence: templates/run-record.yaml:77
    - reason: efficiency.durationMs treats a hung run killed by LAB_REVIEW_TIMEOUT at 600s as a real 10-minute duration, with no guidance for the incomplete-run case — despite hung runs being a documented failure mode of this lab's harness (CLAUDE.md).
      wrong_action: A reader computing mean durationMs across runs would include the 600000 ms kill-time of hung runs alongside actual completion times and report the hung run as ten times slower than real runs, biasing every latency comparison.
      anchor: "  durationMs:              # wall clock. The runner always knows this one."
      evidence: templates/run-record.yaml:49
    - reason: evaluation.failureClass is annotated "# F01-F15" but the F01–F15 taxonomy is not defined anywhere in the template and no registry is referenced, so a first-time reviewer filling in `failureClass: F07` cannot determine what F07 means.
      wrong_action: A reviewer would guess at the category, producing categorical data that cannot be aggregated across runs because different reviewers used different interpretations of the same code — the field is effectively unfillable correctly on first contact.
      anchor: "  failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
  non_blocking:
    - reason: harness.runnerCommit has no comment disambiguating "the runner" (orchestrating script) from "the harness" (binary source), so two reviewers record different commits for the same run; narrower blast radius than the evaluation-block ambiguities.
      evidence: templates/run-record.yaml:11
    - reason: environment.permissionMode lists "acceptEdits / plan / default" with a reference to "harness bug #7", which can be read as either a closed set or as examples — the latter reading is what lets a new mode like "yolo" be recorded inconsistently across reviewers.
      evidence: templates/run-record.yaml:20
    - reason: configuration.instructionsProvenLoaded has no defined consequence for measurement.status, so a reviewer can defensibly mark the same run valid (with a note) or excluded; real but downstream of the status-field ambiguity already listed as blocking.
      evidence: templates/run-record.yaml:31
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 101s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| harness | 1/1 | L3 |
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
**Verdict:** finding
**Failure:** A run is orchestrated by a wrapper script at repo commit `abc123`, invoking harness binary version `1.2.3` (which was built from harness repo commit `def456`). The `harness` block already has `version: 1.2.3`, so `runnerCommit` is presumably not the harness version. Reviewer A records `runnerCommit: abc123` (the orchestrating script's commit). Reviewer B records `runnerCommit: def456` (the harness binary's source commit). Two records of the same run disagree on a field whose name does not disambiguate "the runner" (the script that ran the harness) from "the harness" (the thing that ran the model).
**Layer of the implied fix:** L3
**Anchor:** `runnerCommit:`

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** A harness introduces a new permission mode `"yolo"` (auto-approve every tool call, no human in the loop). Reviewer A writes `permissionMode: yolo` because the field is a free string and the comment only lists examples. Reviewer B writes `permissionMode: default` because the comment enumerates exactly three values (`acceptEdits / plan / default`) and treats them as a closed set. The two records disagree on a field that determines whether the agent could execute tools freely — the one environmental variable most likely to explain a performance difference.
**Layer of the implied fix:** L3
**Anchor:** `permissionMode:          # acceptEdits / plan / default — see harness bug #7`

### configuration
**Verdict:** finding
**Failure:** An MCP server was configured in the harness settings but failed to connect at startup. Reviewer A records `mcp: none` — nothing loaded, so "none." Reviewer B records the configured-but-failed state, because a failed load is an environment defect that could explain poor performance, while "not configured" is the intended treatment. The string `none` collapses "not configured," "not applicable," and "configured but failed to load" into one value. The same ambiguity applies to `instructions: none`, `skills: none`, `hooks: none`, and `customAgent: none`. Separately, `instructionsProvenLoaded: false` has no defined consequence — the template does not link it to `measurement.status`, so one reviewer marks the run `valid` with a note and another marks it `excluded`, and both are defensible.
**Layer of the implied fix:** L3
**Anchor:** `instructions: none` … `skills: none` … `customAgent: none` … `hooks: none` … `mcp: none`

### behavior
**Verdict:** finding
**Failure:** A run in `plan` mode where the agent requested permission 3 times and no human was present. Reviewer A records `approvals: 3` (a count). Reviewer B records `approvals: { requested: 3, answered: 0 }` (structured, capturing "whether anyone could answer" as the comment instructs). Reviewer C records a list of per-request objects. The three shapes cannot be aggregated across runs — a comparison of approval rates is impossible when the fields are not comparable. The same structure gap applies to `retries` and `compactions`, which could each be a count or a list of events.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** A run hangs after 8 minutes and is killed by `LAB_REVIEW_TIMEOUT` at 600s. Reviewer A records `durationMs: 600000` (wall clock to kill — the runner "always knows" the elapsed time). Reviewer B records `durationMs: null` (the run did not complete, so there is no duration to report). The efficiency comparison treats one as a slow-but-valid run and the other as a missing value — opposite conclusions from the same event. Unlike the token fields, `durationMs` has no provenance structure and no guidance for the incomplete-run case, even though hung runs are a known failure mode of this lab's harness.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** A run passes the evaluator (compile + tests green) and scores 2/3 on the quality rubric. Reviewer A puts the evaluator's binary pass in `acceptanceScore` and `2` in `finalScore`. Reviewer B puts `2` in both, reading `acceptanceScore` as the rubric's acceptance-threshold score rather than the evaluator's verdict. The same run produces records that one reader interprets as "passed gate, scored 2" and another as "scored 2 on both axes." Additionally, `failureClass` is annotated `# F01-F15` but the taxonomy is neither defined nor referenced — a reviewer filling in the template for the first time cannot look up what F07 means without searching the repo.
**Layer of the implied fix:** L3
**Anchor:** `acceptanceScore:` … `finalScore:` … `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** A run where the harness crashed mid-run, producing incomplete telemetry. The crash was not pre-registered as an exclusion reason. Reviewer A marks `status: excluded` (the run cannot be used). Reviewer B marks `status: invalidated` (it was invalidated post-hoc by the crash). The comment on `exclusionReason` says "structured, registered in advance," which implies `excluded` is for pre-registered exclusions and `invalidated` is for post-hoc ones — but the template never states this. Two reviewers split the same run across different status values, and a downstream filter on `status: excluded` picks up one but not the other.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.acceptanceScore` is the likely duplicate. If it records the evaluator's pass/fail verdict, it restates a gate that `compile` and `tests` already capture — a constant across every gate-passing run, carrying no information. If it records a rubric score, it does not duplicate the gate. The template does not say which, so the duplication is undetectable from the artifact alone.
- **Which single section would two reviewers diverge on most?** `behavior`. Three fields (`approvals`, `retries`, `compactions`) have no defined structure, and `approvals` carries a comment that explicitly asks for more than a count ("whether anyone could answer") without specifying the shape. Two reviewers filling in the same run would produce records that cannot be compared field-by-field.
- **What did the artifact not say that it needed to say?** It did not distinguish a missing field from a null field. The lab's own CLAUDE.md identifies this as a prior failure ("A missing cell is not a null cell"), yet the template provides no guidance on which fields are required, what a blank means versus an explicit `null`, and what a `none` string means versus an absent key. A run record with `compactions:` left empty and one with `compactions: 0` and one with `compactions: null` are three different facts that the template renders identically.
