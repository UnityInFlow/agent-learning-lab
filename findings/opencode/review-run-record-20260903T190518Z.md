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
reviewed_utc:    20260903T190518Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        1dc0e3b
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: A template whose ten shape-bearing fields are presented as if equivalent, but six are underspecified enough that two reviewers will produce structurally incompatible records — and the lab's analytical machinery (cross-harness comparison, fingerprint-based arm matching, failure classification, exclusion audit) depends on these shapes being consistent.
  blocking:
    - reason: Three sibling fields in `behavior` are typed as lists (`[]`) while six are unmarked (`filesRead`, `modelCalls`, `toolCalls`, `retries`, `approvals`, `compactions`) — a reviewer fills the unmarked ones as either a count or a list, and the records become structurally incompatible.
      wrong_action: Reviewer A writes `filesRead: 12` (count) because the field has no `[]`; Reviewer B writes `filesRead: [src/Main.kt]` because the parallel `filesChanged` is a list. Aggregation tooling iterating the field sees a scalar on one record and a list on another, and either crashes or reports a length-of-1 — silently corrupting the average.
      anchor: "  filesRead:"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:41
    - reason: `task.revision` is unmarked while `task.benchmarkSha` immediately below it carries the comment "the commit the task/evaluator were resolved from" — a reviewer reads `revision` as either the task's int revision or the benchmark's sha.
      wrong_action: Reviewer A writes `revision: 1` (int, the task's revision number); Reviewer B writes `revision: 396e1799` (sha string, the benchmark's revision, matching the `benchmarkSha` comment style). Cross-run comparison keys on this field; the int compares numerically, the string compares as characters, and mixed records produce wrong matches.
      anchor: "  revision: 1"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:5
    - reason: `evaluation.failureClass` references `F01-F15` but the fifteen classes are not defined or linked from this artifact — a reviewer who cannot find the registry guesses, reproducing the very misclassification this field was designed to prevent.
      wrong_action: Reviewer A cannot find the registry, guesses `F05` for a permission-blocked run; Reviewer B leaves the field blank. Either path loses the data point or reproduces the misclassification the field exists to prevent — a failure mode already recorded against this lab.
      anchor: "  failureClass:            # F01-F15"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:73
    - reason: `measurement.exclusionReason` says "structured, registered in advance" but names no registry — a reviewer invents a post-hoc reason, which is exactly what the constraint is meant to forbid.
      wrong_action: Reviewer A writes `exclusionReason: model-hung` after seeing the result, where the registered reason was `harness-stall`. Audit tooling cannot distinguish registered reasons from invented ones, and the "registered in advance" guarantee becomes a note in a comment rather than a check.
      anchor: "  exclusionReason:         # structured, registered in advance"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:78
    - reason: `environment.fingerprint` says "hash of the above; arms must match" without specifying which fields are hashed, in what order, or what an "arm" is — different reviewers hash different field sets.
      wrong_action: Reviewer A includes `bare` in the hash (it is listed under `environment:`); Reviewer B excludes it ("it's not really an environment variable, it's a CLI flag"). Two runs in the same experimental arm produce different fingerprints and the arm-matcher flags them as mismatched when they are not.
      anchor: "  fingerprint:             # hash of the above; arms must match"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:26
    - reason: `harness.name` has no pattern, enum, or registry, and the example (`github-copilot-cli`) uses a kebab-case style that the lab's own CLAUDE.md does not follow — CLAUDE.md uses bare `codex` and `opencode` throughout. A reviewer following the lab's documented convention writes a different name from a reviewer following the example.
      wrong_action: Reviewer A reads CLAUDE.md first (the documented entry point) and writes `harness.name: codex`; Reviewer B follows the template's example and writes `harness.name: openai-codex-cli`. Cross-harness comparison groups them as two distinct harnesses, and the E-001 cross-harness sheet — built on exactly this comparison — silently splits.
      anchor: "  name: github-copilot-cli"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:9
  non_blocking:
    - reason: `# see harness bug #7` in `permissionMode` is a dangling forward reference — a reader who cannot find the bug is left with an unverified claim. Real, worth linking, but the field is still usable without the reference.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:20
    - reason: The cross-cutting observation that only `efficiency` acknowledges its own L3 status and points to the validator, while the other nine sections present their fields with equal weight, is real but is the aggregate of the per-field findings above — not a separate defect.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:60
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 153s |

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
| environment | 1/1 | L3 |
| behavior | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L3 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

✱ Glob "tools/validate-run-record*.sh" 1 match
✱ Glob "tools/classify-model-output*.sh" 1 match
✱ Glob "**/run-record*.yaml" 1 match
→ Read tools/validate-run-record.sh
✱ Glob "**/run-record*.json" 0 matches
✱ Glob "**/run-record*schema*" 0 matches
✱ Glob "**/verify-run-record-validator.sh" 1 match
✱ Glob "**/GUARDRAILS.md" 1 match
→ Read tools/verify-run-record-validator.sh
→ Read GUARDRAILS.md
✱ Glob "tools/fixtures/run-records/*.yaml" 11 matches
→ Read tools/fixtures/run-records/valid-level-a.yaml
→ Read tools/fixtures/run-records/valid-level-c.yaml
→ Read tools/fixtures/run-records/valid-mixed.yaml
### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The example value `B0-COPILOT-BE001-001` is illustrative. A blank or mis-formatted runId reads as a gap, not as a wrong answer, and uniqueness is a process concern outside the template's scope.

### task
**Verdict:** finding
**Failure:** Two reviewers fill `revision` differently on the same run. Reviewer A puts `1` (the task's revision number within the benchmark). Reviewer B puts `396e1799` (the benchmark revision, because the `benchmarkSha` comment says "the commit the task/evaluator were resolved from" and they read `revision` as the benchmark's revision). Downstream tooling that keys on `task.revision` to look up the task spec gets a number from one record and a sha from another. The validator does not check this field, so both pass.
**Layer of the implied fix:** L3
**Anchor:** `  revision: 1`

### harness
**Verdict:** finding
**Failure:** The same harness gets different names across records. A codex run is recorded as `harness.name: codex` by one reviewer and `harness.name: openai-codex-cli` by another. A cross-harness comparison groups them as two different harnesses and the comparison silently splits. No enum, no registry reference, no validator check — the example `github-copilot-cli` is the only hint at a naming convention, and the lab's own CLAUDE.md uses bare `codex` and `opencode`, which do not match the template's style.
**Layer of the implied fix:** L3
**Anchor:** `  name: github-copilot-cli`

### model
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The comment explicitly flags the alias-repoint risk and the two fields are named precisely (`requested` vs `resolved`). A blank `resolved` reads as a gap, not as a wrong answer.

### environment
**Verdict:** finding
**Failure:** The `fingerprint` comment says "hash of the above; arms must match" but does not define which fields are hashed, in what order, or what "arms" means. Reviewer A hashes all eight fields including `bare`; reviewer B excludes `bare` because "it's not really an environment variable." Two runs in the same experimental arm get different fingerprints for the same environment. Downstream arm-matching reports them as mismatched when they are not, or as matched when they differ in a field one reviewer excluded.
**Layer of the implied fix:** L3
**Anchor:** `  fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

`instructionsProvenLoaded` is well-named: `false` means "not proven loaded," which honestly covers both "preflight ran and failed" and "no preflight was run." The comment "preflight assertion result" is sufficient guidance.

### behavior
**Verdict:** finding
**Failure:** Three fields are explicitly lists (`toolsUsed: []`, `filesChanged: []`, `commands: []`) but parallel fields are left blank with no type marker: `filesRead:`, `modelCalls:`, `toolCalls:`, `retries:`, `approvals:`, `compactions:`. Reviewer A fills `filesRead: 12` (a count, since it has no `[]`); reviewer B fills `filesRead: [src/Main.kt, src/Helper.kt]` (a list, since `filesChanged` is a list and `filesRead` is its parallel). Downstream tooling that iterates `filesRead` as a list breaks on the integer. The `approvals` comment — "permission requests — and whether anyone could answer" — specifies what to record but not whether it is a count, a boolean, or a structured object, so the same divergence applies.
**Layer of the implied fix:** L3
**Anchor:** `  filesRead:` (and the five other unmarked fields in the same block)

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The provenance shape is documented with three concrete examples, three measurement levels, and an explicit acknowledgment that the template is L3 on its own. The validator (`validate-run-record.sh`) enforces the shape, rejects bare scalars, rejects null-with-source, rejects source/estimated mismatches, and is tested by 11 registered fixtures. This is the model section.

### evaluation
**Verdict:** finding
**Failure:** `failureClass` carries the comment `# F01-F15` but the 15 classes are neither defined nor linked. GUARDRAILS.md documents that a permission-blocked run was recorded as F05 (incorrect code) when it should have been infrastructure — the exact misclassification this field exists to prevent. A reviewer who cannot find the F01–F15 definitions guesses, and the guess is the failure that already happened. Nothing in the validator checks `failureClass` against the enum.
**Layer of the implied fix:** L3
**Anchor:** `  failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is commented "structured, registered in advance" but the registry is not named or linked. Reviewer A excludes a run with reason `model-hung` (invented post-hoc after seeing the result); reviewer B excludes with `harness-stall` (a pre-registered reason). The "registered in advance" constraint is the field's entire purpose — without the registry reference, a reviewer cannot follow it, and nothing enforces it. `telemetryComplete`, by contrast, is validator-checked and sound.
**Layer of the implied fix:** L3
**Anchor:** `  exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The guidance is sound and the caution about results that flatter is specific to this lab's history.

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The `evaluation` section records gate outcomes (`compile`, `tests`, `hiddenTests`) as measurements; it does not re-score them. The rubric is a separate artifact, and the CLAUDE.md documents that the old rubric's gate-restating anchors were removed as constants.
- **Which single section would two reviewers diverge on most, and by how much?** `behavior` — the mix of `[]`-marked lists and unmarked blanks is the widest ambiguity. A reviewer could fill six fields as counts or as lists and produce a record that downstream tooling either parses or crashes on. The divergence is not a point or two of score; it is a structural incompatibility between records.
- **What did the artifact not say that it needed to say?** Which fields are validator-enforced and which are guidance-only. Only `efficiency` acknowledges its own L3 status and points to the validator. The other ten sections present their fields with equal weight, but the validator checks exactly two of them (`efficiency.*` and `measurement.telemetryComplete`). A reviewer filling in the template has no signal that `harness.name`, `behavior.filesRead`, `evaluation.failureClass`, and `environment.fingerprint` will not be checked — and the failure scenarios above all turn on that missing signal.
