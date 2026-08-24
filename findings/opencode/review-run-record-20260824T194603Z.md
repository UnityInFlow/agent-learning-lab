# opencode review — run-record

```yaml
reviewer:        lab-critic
model:           ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
opencode:        1.18.21
agent_sha:       877d376359ad
reviewed_utc:    20260824T194603Z
artifacts:
  - path: templates/run-record.yaml
    sha:  00c929a0f8d8
lab_head:        ff4b749
lab_dirty:       true
```


> lab-critic · deepseek-v4-pro

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
**Failure:** The comment correctly flags that `requested` and `resolved` can diverge, but the schema records only the *final* `resolved` value with no timestamp or per-call capture. Scenario: an alias (`haiku`) re-points from `claude-haiku-4-5-20251001` to `claude-haiku-4-5-20251101` between two runs. Both records show `requested: haiku`; the first shows the old `resolved`, the second the new. A reviewer comparing the two records cannot tell whether the model changed mid-run or between runs — the exact "silently re-point" failure the comment warns about is acknowledged but not detectable from the record itself.
**Layer of the implied fix:** L3
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** `fingerprint` is defined as "hash of the above; arms must match", but the hash input set is not enumerated. Scenario: reviewer A hashes only the six listed fields (`bare`, `permissionMode`, `hooks`, `plugins`, `skills`, `mcpServers`, `settingsSources`); reviewer B also folds in `harness.version` and `model.resolved`. Same run, two different fingerprints. The "arms must match" check then either fails spuriously (A vs B disagree on an identical environment) or passes spuriously (a real environment drift in `harness.version` is invisible to A's hash). The field that exists to *detect* drift is itself ambiguous about what it covers.
**Layer of the implied fix:** L2
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is a bare boolean with no definition of what "proven" means, and it sits next to `instructions: none` / `instructionsHash:` with no consistency rule. Scenario: a run where `instructions: none` but `instructionsHash` is populated. Reviewer A records `instructionsProvenLoaded: true` (the hash was computed, so "loaded" is proven); reviewer B records `false` (nothing was loaded because instructions is `none`). The preflight assertion — the one field meant to catch a silently-unloaded treatment — produces opposite values for the same run depending on whether "proven loaded" means "hash computed" or "content actually injected".
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a scalar field but its comment demands two dimensions: "permission requests — and whether anyone could answer". Scenario: a run with 3 permission requests, of which 1 was never answered by anyone. Reviewer A records `approvals: 3` (total requests); reviewer B records `approvals: 1` (the unanswered count, since that's the part the comment emphasizes). Two records of the same run disagree, and neither is wrong under the comment as written. A scalar cannot carry both the count and the answerability flag.
**Layer of the implied fix:** L2
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** `cost` has no unit or currency. Scenario: reviewer A records `cost: 0.42` (USD); reviewer B records `cost: 42` (cents). Downstream aggregation sums the two and produces a number off by ~100×. The same ambiguity applies to `durationMs` (is it milliseconds, as the name says, or seconds?) — but `cost` is the one with no unit hint at all in the name.
**Layer of the implied fix:** L3
**Anchor:** `cost:`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` references a taxonomy (`F01-F15`) that is not defined anywhere in the artifact. Scenario: a run where the agent produced a wrong answer but all tests passed. Reviewer A assigns `F07` (wrong-answer class); reviewer B assigns `F12` (silent-failure class). Without the F01–F15 definitions in the record, the two reviewers cannot converge, and the field — which is the primary classification output — is uninterpretable to anyone reading the record in isolation.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### evaluation (scores)
**Verdict:** finding
**Failure:** `acceptanceScore` and `finalScore` are two distinct numeric fields with no stated relationship. Scenario: a run where `acceptanceScore: 0.8` and `finalScore: 0.5`. Reviewer A reports "the run scored 0.8" (acceptance); reviewer B reports "the run scored 0.5" (final). The record contains two competing headline numbers and no rule for which one is authoritative or how they compose.
**Layer of the implied fix:** L3
**Anchor:** `acceptanceScore:` / `finalScore:`

### measurement
**Verdict:** finding
**Failure:** `telemetryComplete` is a boolean whose comment says "a gap must not read as a zero", but a boolean cannot localize *which* field is a gap. Scenario: `inputTokens` is missing. Reviewer A sets `telemetryComplete: false` and leaves `inputTokens` empty. Reviewer B sets `telemetryComplete: true` and writes `inputTokens: 0`. Both records are internally consistent, but downstream analysis treats one as a missing value and the other as a genuine zero — precisely the conflation the comment warns against, and the schema provides no field to prevent it. Additionally, `status` (valid/excluded/pilot/invalidated) and `exclusionReason` have no stated consistency rule: a record with `status: valid` and a populated `exclusionReason` is not flagged as contradictory.
**Layer of the implied fix:** L2
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Name both. — `evaluation.acceptanceScore` and `evaluation.finalScore` are two headline numbers with no composition rule; `evaluation.compile` / `tests` / `hiddenTests` are also pass/fail signals that overlap with `acceptanceScore` without a stated precedence. The clearest duplication is `acceptanceScore` vs `finalScore`.
- Which single section would you expect two reviewers to diverge on most, and by how much? — `evaluation.failureClass`. The F01–F15 taxonomy is referenced but absent, so two reviewers assigning a class to a non-obvious failure (wrong answer with green tests) will diverge on the *class label itself*, not just the score — a categorical disagreement, not a numeric one.
- What did the artifact not say that it needed to say? — (1) The F01–F15 failure-class definitions. (2) The exact input set for `environment.fingerprint`. (3) The definition of "proven loaded" for `instructionsProvenLoaded`. (4) The unit/currency of `cost`. (5) The relationship between `acceptanceScore` and `finalScore`. (6) How `telemetryComplete` localizes which field is missing.
