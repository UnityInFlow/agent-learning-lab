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
reviewed_utc:    20261005T181018Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        e4f9348
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml
  verdict: REJECT
  summary: A reader gets a template that names rules in comments it does not enforce and asks for information several fields cannot structurally represent — every comparison built on filled records is at risk of the data being read two ways.
  blocking:
    - reason: The `approvals` field is a scalar but its own comment requires recording both the count of requests and whether they were answered — a distinction the scalar cannot make.
      wrong_action: A reader writes `approvals: 3`; one reviewer reads "3 approvals granted" and another reads "3 requests, answer status unknown." A run with permission and a run that was blocked compare as identical because the field cannot express the difference.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:45
    - reason: The "arms must match" rule on `fingerprint` lives only in a comment; no comparison-time check is named.
      wrong_action: Two runs enter a comparison with different `fingerprint` values. The reader proceeds because nothing rejects. The comparison result is invalid because the environments differ in a way the template itself flags.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:26
    - reason: The efficiency block defines Levels A, B, C cleanly but does not define the mixed state `{value: <n>, source: null}` — value present, provenance absent.
      wrong_action: A reader enters a token value with no source. The value enters an efficiency average with no provenance — the reverse of the "gap must not read as a zero" rule the block itself states, an unprovenanced number reading as a measurement.
      anchor: "  #   { value: 12400, source: provider,        estimated: false }   # Level A"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:55
    - reason: `failureClass` is a free string; the comment names the range F01-F15 but no check enforces it.
      wrong_action: A reader writes `failureClass: F16`. It joins the F01-F15 distribution and silently invents a category. The aggregated failure-class counts are off by one with no signal that the category is out-of-range.
      anchor: "  failureClass:            # F01-F15"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:73
    - reason: `model.resolved` is empty in the template while the comment explicitly warns about alias re-pointing.
      wrong_action: A reader records `requested: haiku` and leaves `resolved` empty. Two runs with the same requested label but different actual models compare as the same treatment — the alias re-pointing the comment warns about, made undetectable because the field the warning is about is unenforceable.
      anchor: "  resolved:                # what telemetry reports, e.g. \"claude-haiku-4-5-20251001\""
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:15
    - reason: `acceptanceScore` and `finalScore` are both present with no comments distinguishing them.
      wrong_action: A reader fills both with the same value (treating them as duplicates) or with different values (treating one as the evaluator verdict, the other as the rubric number). Downstream consumers cannot tell which is which; the same record reads two ways and any aggregation conflates the two.
      anchor: "  acceptanceScore:\n  finalScore:"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:71-74
    - reason: `instructionsProvenLoaded: false` is a boolean; the comment names a three-state outcome (preflight not run vs. ran and failed vs. ran and passed).
      wrong_action: A reader records `false` for a preflight that was never run. Another reader records `false` for a preflight that ran and failed. The same value means "treatment not applied, exclude the run" in one case and "preflight pending, score the run" in the other.
      anchor: "  instructionsProvenLoaded: false    # preflight assertion result"
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:31
    - reason: The template names `validate-run-record.sh` exactly once, for the efficiency block, and is silent on which other fields the validator checks. The layer model is the artifact's own framing and the template does not apply it to itself for any field except that one.
      wrong_action: A reader cannot tell which comments are L2 (backed by a check) and which are L3 (guidance only). The distinction is the entire layer model. Any future L2/L3 disagreement about a field is unverifiable from the artifact — the template is the only place that could tell the reader, and it doesn't.
      anchor: "  # `tools/validate-run-record.sh` rejects a bare number — this block is Layer 3 on its own."
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:60
  non_blocking:
    - reason: `task.benchmarkSha` is empty in the template with a comment "the commit the task/evaluator were resolved from." A reader can leave it empty without an L2 reject. Recoverable in principle if `task.id` + `task.revision` resolve to a unique commit, but the template does not say so and the wrong-action is less direct than the blocking cases.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:6
    - reason: `harness.version` and `harness.runnerCommit` are both empty; the template does not say which is the canonical pin. The reader can adopt either, but a comparison across two such records can be made valid by adopting a single convention downstream.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:10-11
    - reason: `measurement.exclusionReason` is a free string; the comment names pre-registration but does not point to a registry or specify the structure. The wrong action (a reader invents a reason that was not pre-registered) is plausible but depends on consumer behavior, not the template alone.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:78
    - reason: `telemetryComplete: false` with `inputTokens: { value: null, source: null, estimated: null }` is a gap that "must not read as a zero" per the comment, but the template names no consumer-side check. The wrong action (null coerces to zero in the average) is plausible but depends on the consumer's arithmetic, which is not in the artifact.
      evidence: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/templates/run-record.yaml:62-79
  disputed: []
  needed_to_decide: []
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
| task | 1/1 | L2 |
| harness | 1/1 | L2 |
| model | 1/1 | L2 |
| environment | 1/1 | L2 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L1 |
| efficiency | 1/1 | L2 |
| evaluation | 1/1 | L2 |
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
**Failure:** A run is recorded with `benchmarkSha:` left empty (or filled with a branch name like `main`). The comment says this is "the commit the task/evaluator were resolved from," but the template does not mark the field as required or constrain it to a commit sha. Reviewer A reads the empty field as "task not pinned, exclude the run from comparison." Reviewer B reads it as "optional metadata, `task.id` + `task.revision` are sufficient, proceed." The same run is admitted to a comparison by one reader and rejected by the other.
**Layer of the implied fix:** L2 — the template is a free YAML file; nothing structurally prevents an empty or non-sha value. The fix is a validator check (`validate-run-record.sh` rejecting empty or non-hex `benchmarkSha`), which executes and exits non-zero. A comment saying "required" would be L3.
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** finding
**Failure:** A run is recorded with both `version:` and `runnerCommit:` empty. The template provides no comment on `runnerCommit` at all, and no constraint on whether `version` or `runnerCommit` is the canonical pin. Reviewer A treats the empty `runnerCommit` as a missing reproducibility pin and excludes the run; Reviewer B treats `harness.name` as sufficient identity and proceeds. Two runs with the same harness name but different runner versions are compared as if the harness was identical.
**Layer of the implied fix:** L2 — same as `task`: a validator check that at least one of `version` / `runnerCommit` is non-empty.
**Anchor:** `runnerCommit:`

### model
**Verdict:** finding
**Failure:** A run records `requested: haiku` and leaves `resolved:` empty. The comment warns that "an alias can silently re-point between runs," but the template does not mark `resolved` as required. The exact failure the comment identifies — alias re-pointing — is undetectable when `resolved` is missing, because there is nothing to compare `requested` against. Reviewer A says "resolved is missing, the model identity is unverified, exclude." Reviewer B says "requested is haiku, that is the treatment label, proceed." The run enters a comparison where the silent re-point the comment warns about may have occurred and cannot be detected.
**Layer of the implied fix:** L2 — a validator check rejecting a record where `resolved` is empty when `requested` is present (or vice versa). The comment already identifies the risk; what is missing is the thing that executes.
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"`

### environment
**Verdict:** finding
**Failure:** Two runs in a comparison carry `fingerprint: abc123` and `fingerprint: def456`. The comment says "arms must match," but the template names no executor for that constraint — it only references `validate-run-record.sh` for the efficiency block, not for fingerprint comparison. The comparison proceeds with mismatched environments because nothing rejects it. Reviewer A halts the comparison; Reviewer B proceeds, treating the fingerprint as informational.
**Layer of the implied fix:** L2 — a comparison-time check (or validator extension) that rejects cross-run comparisons where fingerprints differ. The comment "arms must match" is L3 until something executes it.
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** A run records `instructionsProvenLoaded: false`. The comment says this is the "preflight assertion result," but the template does not distinguish "the preflight did not run" from "the preflight ran and the assertion failed." Both states produce `false`. Reviewer A reads `false` as "instructions were not proven loaded, the treatment was not applied, exclude the run." Reviewer B reads `false` as "preflight hasn't been checked yet, the run is pending, score it." The same record is excluded by one and scored by the other.
**Layer of the implied fix:** L3 — the ambiguity is in what `false` *means*, not in whether it can be written. A three-state enum (`not_run` / `failed` / `passed`) would be L1 if the schema enforced it, but as a YAML template the fix is a comment or a validator check on the allowed values, which is L2 at best. The template as written is L3.
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** An automated run records `approvals: 3`. The comment says "permission requests — and whether anyone could answer," but the field is a scalar. There is no way to record that three permission requests were made and zero were answered (because no human was present). Reviewer A reads `approvals: 3` as "3 requests were approved." Reviewer B reads it as "3 requests were made, answer status unknown." The run's behavior profile is fundamentally different under the two readings — one implies the agent operated with permission, the other implies it was blocked.
**Layer of the implied fix:** L1 — the field structure itself cannot represent the distinction the comment asks for. A structured field (`{ requested: 3, answered: 0 }`) would make the bad state (scalar where a structure is needed) unrepresentable if the schema enforced it. As a free YAML template, the fix is L3 until a validator checks the shape.
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** A run records `inputTokens: { value: 12400, source: null, estimated: null }`. The template defines three clean levels (A: value+provider+false, B: value+local-tokenizer+true, C: null+null+null) but does not define this mixed state: a value is present but provenance is absent. The validator "rejects a bare number" — but this is not a bare number, it is an object, so it may pass. Reviewer A says "value present, source null — this is not Level A, B, or C, reject as malformed." Reviewer B says "value present is better than Level C, accept and mark provenance unknown." The record is accepted by one and rejected by the other, and if accepted, the value enters an efficiency average with no provenance — exactly the "gap reads as a zero" problem the template tries to prevent, but in reverse: an unprovenanced number reads as a measurement.
**Layer of the implied fix:** L2 — the validator already checks the efficiency block (rejecting bare numbers). Extending it to reject `{ value: <non-null>, source: null }` would execute and exit non-zero on the mixed state. The template's own comment says "this block is Layer 3 on its own," correctly identifying that the YAML template alone is L3.
**Anchor:** `#   { value: 12400, source: provider,        estimated: false }   # Level A`

### evaluation
**Verdict:** finding
**Failure:** A run records `failureClass: F16`. The comment says `F01-F15`, but the field is a free string with no schema constraint in the template. Unlike the efficiency block, the template does not reference `validate-run-record.sh` as the executor for this field. Reviewer A says "F16 is outside the documented range, reject." Reviewer B says "the range is a comment, not a constraint, accept." If accepted, `F16` enters a failure-class distribution that silently invents a category. Separately, `acceptanceScore` and `finalScore` are both present with no definition distinguishing them — one reviewer may treat `acceptanceScore` as the evaluator's pass/fail and `finalScore` as the rubric score, while another treats them as duplicates.
**Layer of the implied fix:** L2 — a validator check that `failureClass` is in the F01–F15 set. The comment is L3 until something executes it.
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** A run records `telemetryComplete: false` with `inputTokens: { value: null, source: null, estimated: null }`. The comment says "a gap must not read as a zero," but the template names no executor for that rule. Downstream, the null token value enters an efficiency average. Reviewer A excludes the run from the average (gap ≠ zero). Reviewer B includes it as 0 (null coerces to zero in the arithmetic). The average is pulled down by one reviewer and unchanged by the other. Separately, `exclusionReason` is commented "structured, registered in advance" but the field is a free string and the template does not say where the pre-registration lives or how to verify a reason was registered.
**Layer of the implied fix:** L3 — "a gap must not read as a zero" is guidance for the downstream consumer, not a check that executes. The fix would be L2 (a comparison script that refuses to average over `telemetryComplete: false` runs), but the template does not name one.
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile` and `evaluation.tests` record gate results. If the evaluator already checks compile/tests as pass/fail gates, then for gate-passing runs these fields are constants (always pass). They are not duplicates *in the run record* — the record captures all runs, including failing ones — but `finalScore` may duplicate the rubric scoring output, and the template does not define the boundary between `acceptanceScore` (evaluator verdict) and `finalScore` (rubric score). Two reviewers could treat `finalScore` as the rubric number or as a composite, and the template does not resolve it.
- **Which single section would two reviewers diverge on most, and by how much?** `efficiency`. The three-level provenance model is clean for the three states it defines, but the mixed state (value present, source null) is the most likely state a real run will produce — a harness reports a token count but not its provenance — and the template is silent on it. The divergence is not marginal: one reviewer admits the number into an average, the other rejects the record. That is a full point of efficiency score swinging on an undefined state.
- **What did the artifact not say that it needed to say?** Which fields `validate-run-record.sh` actually checks. The template references the validator exactly once, for the efficiency block. Every other constrained field — `failureClass` range, `status` enum, `exclusionReason` pre-registration, `fingerprint` match, `benchmarkSha` required, `resolved` required — carries its constraint in a comment with no statement of whether the validator enforces it. A reader cannot tell which comments are L2 (backed by a check) and which are L3 (guidance only). That distinction is the entire layer model, and the template leaves it implicit for every field except one.
