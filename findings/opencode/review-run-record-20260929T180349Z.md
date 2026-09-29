# opencode review — run-record

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260929T180349Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        0f28718
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml
  verdict: REJECT
  summary: The template makes prose claims about field semantics — the F01–F15 failure-class legend, the "arms must match" fingerprint rule, the benchmarkSha that pins reproducibility, and the encoding of `evaluation.tests` / `behavior.approvals` — without any executable backing or even an in-artifact definition; a reader filling it in produces records the aggregation cannot reliably consume.
  blocking:
    - reason: `failureClass: # F01-F15` references a classification legend that is not defined anywhere in the artifact.
      wrong_action: A reviewer assigns `F07` thinking it means compile failure; another reviewer assigns `F02` for the same event. Any aggregation keyed on failureClass (e.g. "what fraction of excluded runs were harness vs task bugs") conflates incompatible taxonomies and the resulting numbers cannot be compared across reviewers.
      anchor: "  failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: `benchmarkSha` is a blank scalar by default, but it is the only field that pins which task/evaluator a run actually exercised.
      wrong_action: A reviewer produces a record with `benchmarkSha:` left blank, intending to back-fill later, and ships it. The record is silently unreproducible — no future reader can re-run the same task/evaluator against the same code state, defeating the template's stated purpose as evidence.
      anchor: "  benchmarkSha:            # the commit the task/evaluator were resolved from"
      evidence: templates/run-record.yaml:6
    - reason: `fingerprint: # hash of the above; arms must match` is an unexecutable constraint — the template asserts the rule and names no validator or matching definition.
      wrong_action: Two arms are recorded with different fingerprints. One reviewer treats the mismatch as `measurement.status: invalidated`; another treats it as a note in `notes:`. Nothing in the artifact forces either reading, so the "arms must match" claim is silently either honored or violated depending on the reviewer.
      anchor: "  fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `harness.version` and `harness.runnerCommit` are blank scalars with no anchor at all — no comment, unlike every other blank field in the file — so their meaning and encoding are unspecified.
      wrong_action: Reviewer A writes `version: 1.2.3` from `cli --version` and `runnerCommit: abc123`. Reviewer B writes `version: github-copilot-cli 1.2.3 (build abc123)` from the package manifest and leaves `runnerCommit:` blank. Two arms report "the same harness" while the recorded binary identity is incomparable; any "same harness" assertion across arms is unfounded.
      anchor: "  version:"
      evidence: templates/run-record.yaml:11-12
    - reason: `evaluation.tests` is a bare blank scalar with no anchor and no encoding convention; the same partial-pass outcome admits at least three incompatible encodings.
      wrong_action: For an 8/10 pass, one reviewer writes `tests: 8` (integer count), another writes `tests: "8/10"` (string fraction), a third writes `tests: false` reading it as a pass/fail flag. Downstream averaging by `tests` either fails to parse or yields incomparable means; the field is silently a category test for the reader.
      anchor: "  tests:"
      evidence: templates/run-record.yaml:69
    - reason: `behavior.approvals` is a blank scalar carrying the comment "permission requests — and whether anyone could answer", but no encoding (count vs structured list with answerability) is specified.
      wrong_action: One reviewer writes `approvals: 3` (scalar count); another writes a structured list of `{prompt, answerable}` entries. A downstream approval-rate calculation treats one as a number and the other as a list, producing silently different rates or parse failures from the same underlying event.
      anchor: "  approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45
  non_blocking:
    - reason: `runId: B0-COPILOT-BE001-001` is a concrete value rather than a blank or a `<RUN_ID>` placeholder, so a reader who forgets to update it ships a record whose identifier is the template's own.
      evidence: templates/run-record.yaml:1
    - reason: The five behavior count fields (`modelCalls`, `toolCalls`, `filesRead`, `retries`, `compactions`) are blank scalars while neighbouring list fields default to `[]`, so a blank reads ambiguously between "zero" and "not recorded".
      evidence: templates/run-record.yaml:38-46
    - reason: `configuration` uses the literal `none` across five sibling fields (`instructions`, `skills`, `customAgent`, `hooks`, `mcp`) without stating whether `none` is reserved distinct from blank; `instructions: none` next to `instructionsProvenLoaded: false` is internally consistent but the convention is undocumented.
      evidence: templates/run-record.yaml:29-35
    - reason: `durationMs` is a bare scalar blank sitting directly above the provenance block whose stated purpose is to prevent a gap reading as a zero; `durationMs` is not wrapped in `{value, source, estimated}` and the comment "The runner always knows this one" asserts a behavior, not an executor.
      evidence: templates/run-record.yaml:49-60
    - reason: `measurement.exclusionReason` carries the comment "structured, registered in advance" but names neither the allowed values nor the registry location.
      evidence: templates/run-record.yaml:78
  disputed:
    - finding: "Two operators copy the template for separate executions and both retain `B0-COPILOT-BE001-001`; one treats it as an illustrative value to replace, while the other treats it as a generated identifier. Aggregation keyed by `runId` overwrites or conflates the runs."
      why: The artifact is in a single-author workbook (CLAUDE.md: "What is committed here is evidence") with one operator per run. The multi-operator aggregation-conflict consequence does not apply here — the more honest concern is that a specific value in a template invites copy-paste retention, which is captured in `non_blocking` rather than as a blocking aggregation failure.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 38s |
| ollama-cloud/deepseek-v4-pro | ok | 50s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| runId | 1/2 | L2 |
| task | 2/2 | L2 |
| harness | 2/2 | L2 |
| model | 1/2 | L2 |
| environment | 2/2 | L2 |
| configuration | 2/2 | L2 |
| behavior | 2/2 | L2 |
| efficiency | 2/2 | L2 |
| evaluation | 2/2 | L2 |
| measurement | 2/2 | L2 |
| Cross-cutting | 1/2 | L2 |

> **3 of 11 rows were raised by one family only.** Recurrence is counted per HEADING
> TEXT: two families describing one defect under different headings appear as two rows
> of 1/2. Read the solo rows against each other before treating them as separate.


---

## Run 1 of 2 — codex

### runId
**Verdict:** finding
**Failure:** Two operators copy the template for separate executions and both retain `B0-COPILOT-BE001-001`; one treats it as an illustrative value to replace, while the other treats it as a generated identifier. Aggregation keyed by `runId` overwrites or conflates the runs.
**Layer of the implied fix:** L2
**Anchor:** runId: B0-COPILOT-BE001-001

### task
**Verdict:** finding
**Failure:** BE-001 revision 1 is evaluated before and after an evaluator-only commit, but both records leave `benchmarkSha` blank. One reviewer groups them as repetitions of the same task; another excludes them because the resolved evaluator cannot be identified.
**Layer of the implied fix:** L2
**Anchor:** benchmarkSha:            # the commit the task/evaluator were resolved from

### harness
**Verdict:** finding
**Failure:** Two runs use different Copilot CLI and runner versions while both `version` and `runnerCommit` remain blank. A reviewer can accept them as matched arms based on `name`; another can reject them as incomparable because harness identity is unresolved.
**Layer of the implied fix:** L2
**Anchor:** version:
  runnerCommit:

### model
**Verdict:** finding
**Failure:** The alias `haiku` resolves to model A on Monday and model B on Friday, but both fields remain blank in both records. The runs can be reported as repetitions of one model even though the actual models differ.
**Layer of the implied fix:** L2
**Anchor:** requested:               # what you asked for, e.g. "haiku"
  resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"

### environment
**Verdict:** finding
**Failure:** Control and treatment runs load different settings but both leave `fingerprint` blank. One reviewer treats the arms as matched because the listed arrays are empty; another treats the missing fingerprint as evidence that matching was never established.
**Layer of the implied fix:** L2
**Anchor:** fingerprint:             # hash of the above; arms must match

### configuration
**Verdict:** finding
**Failure:** A run registers non-default instructions but records `instructionsProvenLoaded: false`, then receives `measurement.status: valid`. One reviewer counts it in the treatment arm because `instructions` names the intended treatment; another excludes it because loading was not proven.
**Layer of the implied fix:** L2
**Anchor:** instructionsProvenLoaded: false    # preflight assertion result

### behavior
**Verdict:** finding
**Failure:** A run triggers three permission prompts, only one of which could be answered. One recorder writes `approvals: 3`; another writes a list containing prompt and answerability details. Downstream code expecting either a scalar or structured events produces different approval rates or fails to parse one record.
**Layer of the implied fix:** L2
**Anchor:** approvals:               # permission requests — and whether anyone could answer

### efficiency
**Verdict:** finding
**Failure:** A record uses `{ value: null, source: provider, estimated: false }`. The examples describe Levels A–C but do not state cross-field validity rules; one reviewer accepts it as provider provenance with missing usage, while another rejects it because a null value should have null provenance.
**Layer of the implied fix:** L2
**Anchor:** { value: null,  source: null,            estimated: null  }   # Level C

### evaluation
**Verdict:** finding
**Failure:** For a suite with 8 of 10 tests passing, one evaluator records `tests: 8`, another records `tests: false`, and a third records `tests: "8/10"`. Each is consistent with the unlabeled field, but score aggregation yields incompatible results or parser failures.
**Layer of the implied fix:** L2
**Anchor:** tests:

### measurement
**Verdict:** finding
**Failure:** A run has `telemetryComplete: false`, no exclusion reason, and `status: valid`. One reviewer includes its performance result because status controls inclusion; another excludes it because incomplete telemetry contradicts validity.
**Layer of the implied fix:** L2
**Anchor:** status:                  # valid / excluded / pilot / invalidated
  exclusionReason:         # structured, registered in advance
  telemetryComplete:       # a gap must not read as a zero

### notes
**Verdict:** no finding
**Failure:** Two recorders describe the same unexpected flattering behavior with different prose; because `notes` is explicitly free-form and no computation or inclusion decision is specified as depending on it, the variation does not by itself produce a wrong answer.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
**Verdict:** finding
**Failure:** No explicit scoring category duplicates a pass/fail gate in this artifact; `compile`, `tests`, and `hiddenTests` may feed `finalScore`, but their relationship is unstated rather than demonstrably duplicated. Reviewers would diverge most on `evaluation`: the same 8/10 outcome could be encoded as `8`, `false`, or `"8/10"`, producing differences from full inclusion to parse failure. The artifact needed executable rules for field types, requiredness, cross-field invariants, and whether invalid or incomplete records may contribute to results; the only named executable check covers bare usage numbers.
**Layer of the implied fix:** L2
**Anchor:** `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own.


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** finding
**Failure:** `benchmarkSha:` is a blank scalar whose only content is a comment ("the commit the task/evaluator were resolved from"). A record can be written with it empty and nothing executes to reject it. Two reviewers — one who back-fills the SHA after the run, one who leaves it because the run already happened — produce records that are identical except one is reproducible and the other isn't. Downstream, `benchmarkSha` is the only thing that pins which task/evaluator the run actually exercised; an empty value silently makes the record unreproducible rather than loudly invalid.
**Layer of the implied fix:** L3
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** finding
**Failure:** `version:` and `runnerCommit:` are both blank with no anchor at all — not even a comment, unlike every other blank field in the file. A reviewer records the harness version but not `runnerCommit`, or fills `version` from a different source than another reviewer (CLI `--version` vs package manifest vs git tag). Two arms then report the "same" harness at different actual commits, and nothing in the record captures that the two blank fields were supposed to co-identify a single binary. `harness.name` is a fixed sample value, so the record's only real harness identity is these two blanks.
**Layer of the implied fix:** L3
**Anchor:** `version:` / `runnerCommit:`

### model
**Verdict:** no finding
**Failure:** n/a — the `requested`/`resolved` distinction is documented with concrete examples and a note that divergence matters.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** `fingerprint:` carries the instruction "hash of the above; arms must match", but nothing in the artifact names the thing that executes the comparison. Two arms can be recorded with different fingerprints and both be accepted — the mismatch sits in a YAML file until a human happens to read it. The word "arms" is also never defined in this artifact: a reviewer has to know from elsewhere that "arms" means the two halves of a comparison. Given a record with `fingerprint: a1b2c3` and a counterpart with `fingerprint: d4e5f6`, one reviewer treats the mismatch as an exclusion (`measurement.status: invalidated`), another treats it as a note. Nothing forces either.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** The value `none` is used as a literal string across five fields (`instructions`, `skills`, `customAgent`, `hooks`, `mcp`) but the template never states whether `none` is a reserved token distinct from a blank. Reviewer A leaves `instructions:` blank (null) to mean "nothing configured"; reviewer B writes `none` to mean the same thing. A validator that requires the field to be non-empty passes `none` and fails the blank; a check that looks for the literal `"none"` to confirm "explicitly empty" flags the blank as a gap. The same underlying state scores differently depending on which convention the writer happened to pick, and `instructionsProvenLoaded: false` sits next to `instructions: none` with no rule tying the two together (is `none` with `false` a contradiction, or the expected preflight result?).
**Layer of the implied fix:** L3
**Anchor:** `instructions: none` (and the four sibling `none` values)

### behavior
**Verdict:** finding
**Failure:** Five count fields — `modelCalls`, `toolCalls`, `filesRead`, `retries`, `compactions` — are blank scalars with no anchor, while the neighboring list fields default to `[]`. A blank `modelCalls` is ambiguous between "zero calls" and "not recorded". Reviewer A records `0` for a run that made no calls; reviewer B leaves it blank because nobody captured it. Blank parses as null (a gap) and `0` parses as a measured zero, so the same run reports a gap in one arm and a zero in the other. The file's own measurement section warns "a gap must not read as a zero" (line 79), but behavior provides no mechanism to distinguish them. Additionally `filesRead` is a blank scalar while `filesChanged` is a list — the two most analogous fields use different types, so a reviewer recording "read X" doesn't know whether to write a count or a list.
**Layer of the implied fix:** L3
**Anchor:** `modelCalls:` / `filesRead:` (blank scalars)

### efficiency
**Verdict:** finding
**Failure:** `durationMs:` is a bare scalar blank sitting directly above the block whose entire stated purpose is that "a gap reads as a gap and not as a very efficient run" and that every usage value carries `{ value, source, estimated }` provenance. `durationMs` is not wrapped in that structure, so a blank `durationMs` reads as nothing — indistinguishable from `0` or from "not recorded" — precisely the failure the adjacent comment says the provenance block exists to prevent. The comment "The runner always knows this one" is an assertion that the runner *should* always fill it, not a thing that executes when it doesn't. A run where the runner crashed before recording duration is indistinguishable on disk from a run that took 0 ms.
**Layer of the implied fix:** L3
**Anchor:** `durationMs:              # wall clock. The runner always knows this one.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass:            # F01-F15` references a classification scheme that is defined nowhere in this artifact. Two reviewers assigning a failure class have no shared legend: one records `F07` for a compile failure, another `F02` for the same event. `compile`, `tests`, and `hiddenTests` are blank scalars with no anchor — a blank is ambiguous between "not run", "failed", and "passed", and a reviewer recording a failing run cannot tell whether to write `failed`, `1`, or a count. `acceptanceScore` and `finalScore` are two distinct scores with no statement of how they differ or which is authoritative; a reviewer must guess which one the experiment's number comes from.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason:         # structured, registered in advance` asserts a structure and a registry but names neither the allowed values nor where they are registered. Two reviewers excluding the same run write `harness-bug-7` vs `permission-mode-timeout` and no validator can reconcile them, so the exclusion reason — the field that says *why* a run is not scored — is free text in practice. `telemetryComplete:` is a blank with the comment "a gap must not read as a zero", but `telemetryComplete` itself has no default: a blank is ambiguous between "false" (incomplete) and "not recorded", which is exactly the gap-vs-zero ambiguity the comment is warning the rest of the file about.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a — free-text field, explicitly for anything surprising.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.acceptanceScore` and `evaluation.finalScore` are two scores whose relationship is never stated; if `acceptanceScore` restates a gate (the evaluator's recorded verdict) and `finalScore` is the experiment's number, the template has re-introduced the "restating a gate is a constant" defect that the v2 rubric was rebuilt to remove, without saying which one carries weight. `compile`/`tests`/`hiddenTests` may likewise restate gate outcomes.
- **Which single section would two reviewers diverge on most, and by how much?** `behavior` — the five blank count scalars (`modelCalls`, `toolCalls`, `filesRead`, `retries`, `compactions`) plus the `filesRead`-scalar-vs-`filesChanged`-list type asymmetry. A reviewer who records `0` for "no calls" and one who leaves the field blank disagree on every one of those five fields, and a gap-vs-zero disagreement is not a cosmetic one: it changes whether the run is counted as complete or as having missing telemetry.
- **What did the artifact not say that it needed to say?** It never defines the blank-vs-zero-vs-`none` convention that governs nearly every scalar field in the file; it never defines the `failureClass` F01–F15 legend or the registered `exclusionReason` values; and it names only one thing that executes (`tools/validate-run-record.sh`, line 60, and only against bare numbers in the efficiency block) while leaving the `fingerprint` "arms must match", the `benchmarkSha`, and the `instructionsProvenLoaded` assertion as prose with no named executor. Everything except the one validator call is L3.
