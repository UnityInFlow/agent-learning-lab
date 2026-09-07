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
reviewed_utc:    20260907T072723Z
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
  summary: A reviewer filling this template cannot reliably populate the `evaluation` block (gate outputs and rubric scores share a section with no boundary), the `approvals` field (comment claims an interactivity flag the bare scalar cannot carry), or `failureClass`/`exclusionReason` (the template names structures it does not define or link to).

  blocking:
    - reason: The `evaluation` section places gate outputs (`compile`, `tests`, `hiddenTests`) alongside rubric-style measurements (`acceptanceScore`, `unintendedChanges`, `finalScore`) with no boundary marker between "what the gate decided" and "what the rubric measured."
      wrong_action: A future rubric author reads this template and anchors a category on `compile: pass` or `tests: pass` as if it were a rubric dimension — the exact pattern that killed the lab's previous rubric (CLAUDE.md: *"the rubric only scores gate-passing submissions, so any anchor restating a gate is a constant across everything it can score. 60% of the weight carried no information"*). The template at hand is the contract the next rubric reads; it should not invite the same defect.
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

    - reason: `approvals` is commented *"permission requests — and whether anyone could answer"* — the comment claims the field carries an interactivity flag — but the schema shows a bare scalar that can hold only one value.
      wrong_action: A reviewer writes `approvals: 0` meaning "no permission requests" and silently loses the interactivity information. "0 unanswered requests" and "0 answered requests" have opposite implications for whether the run was actually constrained, and the reader cannot tell them apart from the same scalar. The comment makes a structural claim the schema contradicts.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:45

    - reason: `failureClass: # F01-F15` and `exclusionReason: # structured, registered in advance` both reference structures the template does not define or link to. The comments assert a closed enum and an external registry that no sibling field, comment, or pointer can verify.
      wrong_action: A reviewer writes `failureClass: F16` (out of range) or `failureClass: harness-crash` (free string) and the template accepts it; a reviewer writes `exclusionReason: had-to-go` (free excuse) and the comment's "registered in advance" claim is silently false. Nothing in the artifact distinguishes a registered code from arbitrary text, and no validator is named for either block.
      anchor: |
        failureClass:            # F01-F15
        exclusionReason:         # structured, registered in advance
      evidence: templates/run-record.yaml:73,79

  non_blocking:
    - reason: `runId` example shown (`B0-COPILOT-BE001-001`) but the format is not specified — a copy-paste reader will match the example; a fresh reader will diverge.
      evidence: templates/run-record.yaml:1

    - reason: `task.revision` has no comment while its sibling `task.benchmarkSha` does — `revision` is ambiguous between task-definition version and run attempt number.
      evidence: templates/run-record.yaml:5

    - reason: `harness.runnerCommit` has no comment, leaving it ambiguous between the runner-script commit (`tools/codex-score.sh` and friends) and the harness-binary commit.
      evidence: templates/run-record.yaml:11

    - reason: `environment.fingerprint` is commented *"hash of the above; arms must match"* but does not name the algorithm, the exact set of fields hashed, or who computes it — the "arms must match" check is unenforceable from the template alone.
      evidence: templates/run-record.yaml:26

    - reason: `configuration.instructionsProvenLoaded: false` does not disambiguate "preflight ran and failed to load expected instructions" (defect) from "no instructions configured, so the assertion is not applicable" (fine). A run with no instructions and `false` may be excluded as invalid by one reviewer and accepted by another.
      evidence: templates/run-record.yaml:31

    - reason: `behavior.filesRead` has no default marker (`[]`) while its sibling `filesChanged: []` does — readers may treat them as different types when they are presumably the same. The asymmetry is suspicious.
      evidence: templates/run-record.yaml:41-42

    - reason: `evaluation` fields other than `failureClass` carry no type annotation or comment — a reviewer cannot tell which are booleans, exit codes, counts, or numeric scores, and cannot distinguish `acceptanceScore` from `finalScore` (same metric recorded twice, or two different metrics).
      evidence: templates/run-record.yaml:69-74

    - reason: Only the `efficiency` block names its validator (`tools/validate-run-record.sh`, *"this block is Layer 3 on its own"*); the other ten sections do not say whether they are L2 (validator-enforced) or L3 (comments only). A reviewer who assumes L2 where nothing enforces will trust fields that nothing checks.
      evidence: templates/run-record.yaml:51-65 (named) vs. lines 1-50, 67-80 (silent)

  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 114s |

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
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### runId
**Verdict:** finding
**Failure:** Two reviewers recording the same run independently could produce different IDs — one writes `B0-COPILOT-BE001-001` (matching the example), another writes `B0-COPILOT-CLI-BE-001-1` (expanding the harness name, hyphenating the task differently, using a different sequence format). The template shows a concrete value but does not document the format or reference where it is defined. If the validator does not enforce a format, these two records refer to the same run with different keys and cannot be joined.
**Layer of the implied fix:** L3
**Anchor:** `runId: B0-COPILOT-BE001-001`

### task
**Verdict:** finding
**Failure:** `revision` has no comment. A reviewer recording a run after the task definition was updated writes `revision: 2`. Another reviewer interprets `revision` as the run attempt number and writes `revision: 1` for the first attempt. The two records for the same run disagree on a field that determines which version of the task was attempted. `benchmarkSha` is commented ("the commit the task/evaluator were resolved from"), which makes the omission on `revision` visible by contrast.
**Layer of the implied fix:** L3
**Anchor:** `revision: 1`

### harness
**Verdict:** finding
**Failure:** `runnerCommit` has no comment. One reviewer records the commit of the lab's runner script (`tools/codex-score.sh` and friends); another records the commit of the harness binary itself. If the runner script changes between runs but the harness doesn't (or vice versa), the two records disagree on what `runnerCommit` means, and a reader comparing runs cannot tell whether a difference in `runnerCommit` is a runner change or a harness change.
**Layer of the implied fix:** L3
**Anchor:** `runnerCommit:`

### model
**Verdict:** no finding

### environment
**Verdict:** finding
**Failure:** `fingerprint` is commented "hash of the above; arms must match" but does not specify the hash algorithm, the exact set of fields hashed, or whether the hash is computed by a tool or by hand. Two arms with identical environments but different fingerprint implementations produce different fingerprints and fail the "arms must match" check — a false positive that invalidates a valid comparison. Conversely, two arms with different `settingsSources` but a fingerprint computation that omits that field produce matching fingerprints — a false negative that hides a real confound.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` is commented "preflight assertion result." When `instructions: none` (no custom instructions configured), a reviewer sets `instructionsProvenLoaded: false` — but this could mean either "the preflight ran and failed to load instructions that should have been there" (a defect) or "there were no instructions to load, so the assertion is not applicable" (fine). Two reviewers reading the same record disagree on whether `false` here is a finding or a no-op. A run with no instructions and `false` might be excluded as invalid by one reviewer and accepted by another.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is commented "permission requests — and whether anyone could answer," implying the field must capture both a count and an interactivity flag. But the field is a bare scalar with no structure shown. One reviewer writes `3` (count only); another writes `{ count: 3, interactive: false }`. A reader comparing runs cannot tell whether a run with `approvals: 0` had no permission requests or had requests that nobody could answer — the two cases have opposite implications for whether the run was constrained. The same ambiguity applies to `filesRead`, which has no default value (unlike `filesChanged: []`) and no comment indicating whether it is a count or a list.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is commented `# F01-F15` but none of the 15 classes are defined or referenced. Two reviewers classifying the same failure — say, an agent that produced correct code but modified an unrelated file — might assign F03 (unintended changes) or F07 (scope drift) depending on where they draw the boundary. The classification is supposed to be structured, but the structure is external and not pointed at. The same section also leaves `compile` and `tests` without type annotations (booleans? exit codes? counts?) and does not distinguish `acceptanceScore` from `finalScore` — a reviewer does not know whether they are the same metric recorded twice or two different metrics.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is commented "structured, registered in advance" but shows no structure. One reviewer writes `exclusionReason: harness-crash`; another writes `exclusionReason: { code: HARNESS_CRASH, registeredAs: ERC-003 }`. A reader cannot tell whether a bare string is a registered reason code or a free-text excuse. The "registered in advance" requirement is unenforceable from the template — nothing links the value to a registry, so a reviewer can write any string and it reads as registered.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? `evaluation.compile` and `evaluation.tests` record the same facts the evaluator's gate checks. If the rubric also scored these (the v2 rubric dropped `functional-correctness` for exactly this reason), they would be constants across all gate-passing runs. The template does not separate gate results from rubric scores — `acceptanceScore` and `finalScore` sit in the same section as `compile` and `tests` with no boundary between "what the gate decided" and "what the rubric measured."
- Which single section would two reviewers diverge on most? `evaluation` — three independently underspecified fields (`compile`/`tests` type, `acceptanceScore` vs `finalScore`, `failureClass` enum) compound within one section. A reviewer could fill the entire section three different ways and all three would pass the template.
- What did the artifact not say that it needed to say? Which sections `validate-run-record.sh` actually checks. The template explicitly names the validator for the efficiency block ("rejects a bare number") and is silent about every other section. A reader cannot tell whether the remaining 10 sections are L2 (validator-enforced) or L3 (comments only). The efficiency block is the only one whose layer is stated; the rest are left to inference, and a reviewer who assumes L2 where the validator does not check will trust fields that nothing enforces.
