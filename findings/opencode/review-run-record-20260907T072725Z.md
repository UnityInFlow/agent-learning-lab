# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260907T072725Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        a11a114
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The efficiency block demonstrates the template's intended rigor (explicit Level A/B/C semantics, named validator, "a gap must not read as a zero"), but every other section either has no schema for the fields that get compared (evaluation), or asserts a rule that no tool in the artifact names ("arms must match", "registered in advance", "preflight assertion result", "F01-F15"). A reader filling this template can record `finalScore: 8` without knowing whether 8 is a count or an 8/10 score, and the artifact offers no way to tell.
  blocking:
    - reason: The evaluation block has no schema for its fields; tests, hiddenTests, acceptanceScore, finalScore, and unintendedChanges are all blank with no type, scale, denominator, or derivation; failureClass references "F01-F15" without enumerating the classes.
      wrong_action: A reviewer aggregates `finalScore: 8` across runs and treats them as equivalent, when one record means "8 of 10" and another means "8 tests passed" — corrupting the comparison the artifact exists to support.
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
    - reason: `environment.fingerprint` is annotated "hash of the above; arms must match" but no matcher is named; the rule is prose with no executor in the artifact.
      wrong_action: A reviewer accepts a treatment/control arm pair where the fingerprint is blank in both arms because the values "match as blank" under the stated rule, when the arms actually have different plugin lists — and the comparison is invalid.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `configuration.instructionsProvenLoaded: false` is annotated "preflight assertion result" but no preflight is named; a false value cannot be connected to exclusion because nothing in the template enforces it.
      wrong_action: A reviewer scores a treatment run as valid despite the false flag, on the assumption the flag means what its name implies, when nothing in the template proves a check ran.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: `failureClass: F01-F15` references a taxonomy the template does not enumerate; a reader filling the field cannot verify which class a failure belongs to without an external document the template does not name.
      wrong_action: A reviewer assigns `failureClass: F07` guessing what F07 means, and an aggregator groups incomparable failures under a shared label.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `measurement.exclusionReason: structured, registered in advance` references a registry that is not named anywhere in the artifact; the comment is a governance claim with no executable backing.
      wrong_action: A reviewer treats a blank exclusionReason on `status: excluded` as a registered exclusion, masking a post-hoc decision as a pre-planned one.
      anchor: "exclusionReason:         # structured, registered in advance"
      evidence: templates/run-record.yaml:78
    - reason: `task.benchmarkSha` is blank and the template does not state what to do when it is blank; two runs of the same `task.id`+`task.revision` from different evaluator commits are indistinguishable from runs at the same evaluator commit.
      wrong_action: A reviewer compares scores across two runs that resolved the task at different evaluator versions, on the assumption "same task ID" means comparable, when evaluator drift makes the comparison invalid.
      anchor: "benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
    - reason: The behavior block fields (modelCalls, toolCalls, filesRead, filesChanged, commands, retries, approvals, compactions) are all blank with no provenance or null-vs-zero semantics, in contrast to the efficiency block which has explicit Level A/B/C semantics. The template's own example is not applied to the fields it most needs to govern.
      wrong_action: A reviewer records `toolCalls: 0` for a run with no telemetry and another reviewer records blank; aggregation treats 0 and missing as the same thing, understating one arm's behavior.
      anchor: |
        behavior:
          modelCalls:
          toolCalls:
          toolsUsed: []
          filesRead:
      evidence: templates/run-record.yaml:38-46
  non_blocking:
    - reason: `runId: B0-COPILOT-BE001-001` is an example with no uniqueness or collision rule. Fixable by adding a uniqueness rule (e.g., append timestamp or harness+commit hash) without restructuring the template.
      evidence: templates/run-record.yaml:1
    - reason: `harness.version` and `harness.runnerCommit` are blank fields; without them, harness drift between runs is invisible. Fixable by adding the same provenance structure the efficiency block demonstrates.
      evidence: templates/run-record.yaml:10-11
    - reason: The efficiency block's classification rule for `{ value: X, source: null, estimated: ... }` is stated in prose ("Level C is that nobody knows") but the validator's stated rule only enforces "no bare numbers"; the two rules do not overlap on all inputs. The example `{ value: 12400, source: null, estimated: false }` passes the validator's stated rule but its level classification depends on a separate comment, not on the validator.
      evidence: templates/run-record.yaml:51-65
    - reason: The model section has the right framing ("These differing is not a detail. An alias can silently re-point between runs.") — exactly the kind of insight that prevents harm — but does not state an executable rule that the two fields must match.
      evidence: templates/run-record.yaml:15-16
    - reason: The notes section is honest about the project's experience with harness bugs ("five of our seven harness bugs were caught fast because they looked bad; the two that survived review were the two that flattered the result") and serves as a useful signal about what to watch for.
      evidence: templates/run-record.yaml:81-83
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 46s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/1 | L3 |
| task | 1/1 | L3 |
| harness | 1/1 | L3 |
| model | 1/1 | L3 |
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### runId
**Verdict:** finding
**Failure:** Two records both use `B0-COPILOT-BE001-001` but differ in `model.resolved`; one reviewer treats the later record as a rerun that replaces the first, while another counts both as independent observations. The artifact defines neither uniqueness nor collision handling.
**Layer of the implied fix:** L3
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** Run A resolves BE-001 revision 1 before an evaluator fix and Run B resolves it after the fix, while both leave `benchmarkSha` blank. One reviewer compares their scores as repetitions of the same benchmark; another excludes the comparison because the evaluator versions cannot be shown to match.
**Layer of the implied fix:** L3
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two records name `github-copilot-cli`; one ran harness version 0.0.340 at runner commit A and the other 0.0.341 at commit B, but both fields are blank. One reviewer attributes a tool-call difference to the treatment, while another treats harness drift as a confound and excludes the pair.
**Layer of the implied fix:** L3
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** A run leaves `requested` and `resolved` blank after requesting `haiku`; the provider alias had moved from model X to model Y between arms. One reviewer groups the runs by the common request alias, while another refuses the comparison because the actual model is unknown.
**Layer of the implied fix:** L3
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** The control arm has `plugins: []`; the treatment arm has `plugins: [github]`; both leave `fingerprint` blank. One reviewer accepts them because the fingerprint values match as blank, while another notices the list difference and rejects the arm comparison. No executing matcher is named.
**Layer of the implied fix:** L3
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run declares `instructions: experiment.md`, records an `instructionsHash`, and has `instructionsProvenLoaded: false`. One reviewer excludes it because the treatment was not proven active; another scores it as a failed treatment run because no validity rule connects the false value to exclusion.
**Layer of the implied fix:** L3
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** One recorder uses `toolCalls: 0` and `filesRead: 0` for a run with no observed activity; another leaves both blank because telemetry was unavailable. A reviewer aggregating blanks as zero reports identical behavior, while a reviewer treating blanks as missing excludes the second run. The section does not define null-versus-zero semantics.
**Layer of the implied fix:** L3
**Anchor:** modelCalls:
  toolCalls:
  toolsUsed: []
  filesRead:

### efficiency
**Verdict:** finding
**Failure:** A record contains `{ value: 12400, source: null, estimated: false }`. It is not a bare number, so the only stated validator rule does not establish that it is rejected. One reviewer classifies it as provider-grade because `estimated` is false; another classifies it as unknown because `source` is null.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

### evaluation
**Verdict:** finding
**Failure:** For the same run, one evaluator records `tests: 8` to mean eight tests passed and another records `tests: 8` to mean an 8/10 score; both set `finalScore: 8`. One reviewer treats the results as equivalent, while another cannot compare them because neither field's type, denominator, or derivation is defined.
**Layer of the implied fix:** L3
**Anchor:** tests:
  hiddenTests:
  acceptanceScore:
  unintendedChanges:
  failureClass:            # F01-F15
  finalScore:

### measurement
**Verdict:** finding
**Failure:** A record sets `status: excluded`, leaves `exclusionReason` blank, and has `telemetryComplete: false`. One reviewer excludes it as registered; another treats it as an undocumented post-hoc exclusion. The comments name intended values and properties but name no executing validation or registry check.
**Layer of the implied fix:** L3
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring rubric is present, so no scoring category can be shown to duplicate a pass/fail gate. Reviewers would diverge most on `evaluation`: the same `tests: 8` and `finalScore: 8` can reasonably be interpreted as counts, points, or an 8/10 score, producing differences from inclusion as equivalent through rejection as incomparable. The artifact needed to state executable validity rules and field semantics for missing values, score scales and derivation, arm comparability, identifier uniqueness, and exclusion registration; currently only rejection of bare efficiency numbers names something that runs.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.

