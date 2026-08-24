# opencode review — run-record

```yaml
reviewer:        lab-critic
model:           ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
opencode:        1.18.21
agent_sha:       877d376359ad
reviewed_utc:    20260824T200711Z
runs:            2           # independent sessions; findings unioned below
artifacts:
  - path: templates/run-record.yaml
    sha:  00c929a0f8d8
lab_head:        9d5cb08
lab_dirty:       true
```

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| runId | 1/2 | L3 |
| environment | 2/2 | L3 |
| configuration | 2/2 | L3 |
| behavior | 2/2 | L3 |
| efficiency | 2/2 | L3 |
| evaluation | 2/2 | L3 |
| measurement | 2/2 | L3 |
| task | 1/2 | L3 |
| harness | 1/2 | L3 |
| environment (permissionMode) | 1/2 | L3 |
| behavior (retries) | 1/2 | L3 |
| evaluation (finalScore vs acceptanceScore) | 1/2 | L3 |
| measurement (telemetryComplete) | 1/2 | L3 |


---

## Run 1 of 2


> lab-critic · deepseek-v4-pro

### runId
**Verdict:** finding
**Failure:** The arm (control vs treatment) is encoded only as a string prefix (`B0`) in `runId`, with no separate field and no documented meaning anywhere in the artifact. A reviewer who must group records by arm to compute the treatment effect has to parse `B0`/`B1` out of the ID string. Two competent reviewers can disagree on whether `B0` denotes the control arm or the treatment arm — or whether it denotes an arm at all — and the measured effect inverts. The `environment.fingerprint` comment ("arms must match") references arms that no field in the record actually names.
**Layer of the implied fix:** L3
**Anchor:** `runId: B0-COPILOT-BE001-001`

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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** `fingerprint` is annotated "hash of the above; arms must match", but "the above" is not bounded. It sits under `environment`, so a reviewer may hash only the environment fields (bare, permissionMode, hooks, plugins, skills, mcpServers, settingsSources), while another hashes environment plus `model` plus `configuration`. Two arms that differ only in `configuration` (the treatment) would produce identical fingerprints under the first reading and different fingerprints under the second. A reviewer using the fingerprint to assert "arms differ only in treatment" reaches opposite conclusions depending on which fields they believe the hash covers. There is also no field recording *which* fields were hashed, so the fingerprint is not reproducible from the record alone.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is a boolean annotated "preflight assertion result", but the assertion itself is undefined. What does "proven loaded" mean — a grep for the instruction text in the agent's context, a hook that exits non-zero, a manual check? Two reviewers scoring the same run disagree on whether the instruction was "proven loaded" because they are applying different assertions. The field then reads as a fact when it is actually an unanchored judgment, and a downstream analysis that filters on `instructionsProvenLoaded: true` silently includes or excludes runs based on an undefined test.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is annotated "permission requests — and whether anyone could answer", which names two dimensions but provides one untyped field. The second dimension ("whether anyone could answer") has no field at all. Concrete divergence: a run where the agent requested a permission and the harness auto-denied because no human was present. Reviewer A records the request count in `approvals`; reviewer B records nothing because "no one could answer" and there is no field to say so. The record cannot distinguish "zero permission requests" from "requests that could not be answered", which is exactly the distinction the comment says matters. `retries` is likewise untyped — a count, a list of retry events, and a boolean all fit.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** `cost` is untyped with no currency or unit. Reviewer A records USD, reviewer B records cents, reviewer C records the raw API cost before cache discount. Aggregating `cost` across records is then off by 100× or mixes currencies, and the record gives no way to detect it. The same untypedness applies to `durationMs` (is it wall-clock or model time?) but `cost` is the one where the unit ambiguity produces a wrong number rather than a wrong label.
**Layer of the implied fix:** L3
**Anchor:** `cost:`

### evaluation
**Verdict:** finding
**Failure:** Three distinct problems, each with its own divergence:
1. `failureClass` references a taxonomy "F01-F15" that is not defined anywhere in the artifact. A run where the agent produced a wrong answer via a hallucinated API call: Reviewer A assigns F03 (hallucination), Reviewer B assigns F07 (wrong tool selection). The record has no anchor to disambiguate, so failure-class distributions are not comparable across reviewers.
2. `acceptanceScore` and `finalScore` are two score fields with no defined relationship. A run that passes all tests (`acceptanceScore` 1.0) but has `unintendedChanges`: Reviewer A leaves `finalScore` at 1.0, Reviewer B drops it. The two fields can carry contradictory values with no rule saying which is authoritative.
3. `unintendedChanges` is untyped — a count, a list of file paths, and a boolean all fit, and each produces a different downstream interpretation.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `status` enumerates "valid / excluded / pilot / invalidated" but the boundaries between states are undefined, and `exclusionReason` ("structured, registered in advance") is not tied to any state. Concrete divergence: a run that hit harness bug #7 (permissionMode). Reviewer A marks `invalidated`, Reviewer B marks `excluded`. Downstream, "invalidated" is read as "drop entirely" and "excluded" as "drop from primary but keep in sensitivity analysis", so the same run lands in different analysis populations. Separately, `telemetryComplete` is untyped — the comment "a gap must not read as a zero" states the intent, but a boolean, a timestamp, and a list of missing fields all fit, and a blank value is indistinguishable from "not yet filled in".
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Scoring category duplicating a pass/fail gate:** `acceptanceScore` and `finalScore` both sit alongside the pass/fail gates `compile` / `tests` / `hiddenTests`, and neither score's derivation from those gates is defined. `acceptanceScore` is the likely duplicate of the `tests`/`hiddenTests` gate, and `finalScore` is the likely duplicate of `acceptanceScore` — but the artifact never states which is authoritative, so a reviewer can record a `finalScore` that contradicts the raw gate results with no rule to catch it.
- **Section most likely to diverge:** `evaluation`, by a wide margin. The `F01-F15` taxonomy is referenced but not defined, so two reviewers assigning `failureClass` to the same run have no shared anchor and will diverge on essentially every non-trivial failure. `measurement.status` is a close second.
- **What the artifact did not say that it needed to say:** it never defines the arm structure (which runId prefix is control vs treatment), never defines the F01-F15 failure taxonomy, never states the relationship between `acceptanceScore` and `finalScore`, and never gives a type or unit for any field (`cost`, `retries`, `unintendedChanges`, `telemetryComplete`, `approvals`). Every one of these gaps is an L3 gap — the fix is "add words or fields to the template", and nothing in the artifact describes a validator, hook, or script that would enforce any of it, so none of these constraints actually bind a reviewer.

---

## Run 2 of 2


> lab-critic · deepseek-v4-pro

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** finding
**Failure:** `benchmarkSha` is the reproducibility anchor — the comment says it is "the commit the task/evaluator were resolved from" — but nothing in the record asserts it is non-empty. Two runs of `BE-001` with different (or blank) `benchmarkSha` values are structurally indistinguishable from two runs of the same commit. Reviewer A treats a blank `benchmarkSha` as "not yet filled in, exclude from comparison"; reviewer B treats it as "resolved from HEAD, include". Same record, opposite inclusion decisions.
**Layer of the implied fix:** L3 — a note that the field is mandatory constrains nothing; no validator rejects a blank value.
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

### harness
**Verdict:** finding
**Failure:** `runnerCommit` is undefined. It could mean the commit of the harness runner binary, the commit of the lab's own runner code, or the commit of the evaluation harness. Two reviewers recording the same run fill it with different SHAs (one the copilot-cli version's commit, one the lab runner's commit). The field then fails its purpose — pinning the exact harness code — because the two values are not comparable.
**Layer of the implied fix:** L3 — a definition of the term is prose; nothing checks the SHA actually corresponds to the harness.
**Anchor:** `runnerCommit:`

### model
**Verdict:** no finding
**Failure:** n/a — the requested/resolved split and the alias-repointing warning are already handled in the artifact's own comment.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** `fingerprint` is "hash of the above; arms must match", but the canonical input is unspecified — which fields, in what order, with what serialization. Reviewer A hashes `{bare, permissionMode, hooks, plugins, skills, mcpServers, settingsSources}` in YAML order; reviewer B hashes only `{hooks, plugins, skills, mcpServers}`. The same environment yields two different fingerprints, so a valid run is flagged as "arms don't match" — or, worse, two genuinely different environments collide because each reviewer hashed a different subset. The field that exists to detect environment drift cannot detect it.
**Layer of the implied fix:** L3 — "specify the canonical hash input" is prose; unless a script computes the fingerprint, nothing enforces the two arms actually hashed the same thing.
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### environment (permissionMode)
**Verdict:** finding
**Failure:** `permissionMode` enumerates `acceptEdits / plan / default`, but `default` is not a mode — it is a reference to whatever the harness's default happens to be, which is itself version-dependent (and `harness.version` is blank). Two reviewers recording the same run: one writes `default`, the other writes the concrete mode the harness actually resolved to (`plan`). The record then disagrees with itself about what permission surface the agent ran under, which is exactly the variable the lab is trying to control.
**Layer of the implied fix:** L3 — the enum is prose; nothing resolves `default` to a concrete value at record time.
**Anchor:** `permissionMode:          # acceptEdits / plan / default — see harness bug #7`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` is a boolean that conflates two states: "the preflight assertion ran and proved the instructions did NOT load" versus "the preflight assertion never ran". A run where the assertion was skipped leaves `false`, which is byte-identical to a run where the assertion ran and genuinely failed. Reviewer A reads `false` as "instructions not loaded → exclude the run"; reviewer B reads `false` as "assertion not executed → investigate, don't exclude". Divergent treatment of the same record.
**Layer of the implied fix:** L3 — making it tri-state (or adding an `assertionRan` field) is a schema note; nothing enforces the assertion actually ran before the flag is trusted.
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a single scalar whose comment demands two orthogonal facts: "permission requests — and whether anyone could answer". Reviewer A records the count of requests (`approvals: 3`); reviewer B records the count of requests that were answerable (`approvals: 0`, because no human was present to answer). Same run, two different numbers, and the "whether anyone could answer" fact is silently lost in both. The field cannot hold what its comment asks it to hold.
**Layer of the implied fix:** L3 — splitting into two fields is a schema note; nothing prevents a reviewer from collapsing the two facts into one number.
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### behavior (retries)
**Verdict:** finding
**Failure:** `retries` is an unqualified scalar. Retries of what — model calls, tool calls, commands, or the whole task? Reviewer A counts tool-call retries; reviewer B counts model-call retries. The same run produces different numbers, and the retry signal (which is a proxy for agent flailing) is not comparable across records.
**Layer of the implied fix:** L3 — qualifying the term is prose; nothing validates what was counted.
**Anchor:** `retries:`

### efficiency
**Verdict:** finding
**Failure:** `cost` has no unit or currency. Reviewer A records USD; reviewer B records the harness's native billing unit (e.g., credits or a different currency). Two records of the same run carry different magnitudes, and any downstream cost comparison is wrong by a constant factor that nothing in the record exposes.
**Layer of the implied fix:** L3 — stating the unit is prose; nothing normalizes the value at record time.
**Anchor:** `cost:`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` references an enum `F01-F15` that is not defined anywhere in the artifact. Two reviewers classifying the same failure (say, the agent silently skipped a required file) have no shared anchor: one assigns `F03`, the other `F07`. The classification — which is the whole point of the field — is unanchored and therefore not reproducible.
**Layer of the implied fix:** L3 — pinning the taxonomy is prose; nothing validates the value against the enum.
**Anchor:** `failureClass:            # F01-F15`

### evaluation (finalScore vs acceptanceScore)
**Verdict:** finding
**Failure:** `acceptanceScore` and `finalScore` are two scores with no defined relationship. Reviewer A sets `finalScore = acceptanceScore`; reviewer B sets `finalScore = acceptanceScore` minus an `unintendedChanges` penalty. The same run yields two different `finalScore` values, and the record gives no rule for which is authoritative. This is a scoring category that duplicates another scoring category.
**Layer of the implied fix:** L3 — defining the derivation is prose; nothing computes `finalScore` from the other fields.
**Anchor:** `acceptanceScore:` / `finalScore:`

### measurement
**Verdict:** finding
**Failure:** `status` enumerates `valid / excluded / pilot / invalidated`, but these are not mutually exclusive. A run with a known harness bug could be `excluded` (bug invalidates it) or `invalidated` (bug invalidates it) or `pilot` (it was a pilot run that also hit a bug). Reviewer A marks `excluded`, reviewer B marks `invalidated`, reviewer C marks `pilot`. The same run lands in three different buckets, and `exclusionReason` ("registered in advance") does not disambiguate which status a given reason maps to.
**Layer of the implied fix:** L3 — making the vocabulary orthogonal is prose; nothing enforces a single valid status per reason.
**Anchor:** `status:                  # valid / excluded / pilot / invalidated`

### measurement (telemetryComplete)
**Verdict:** finding
**Failure:** `telemetryComplete` is a boolean whose own comment warns "a gap must not read as a zero" — but the field cannot express the distinction it is warning about. A run where `modelCalls` is genuinely zero (the agent never called the model) and a run where `modelCalls` is zero because telemetry was never collected both leave `telemetryComplete` ambiguous. Reviewer A reads the field as "complete, and the zero is real"; reviewer B reads it as "incomplete, the zero is a gap". The field is a two-state flag trying to hold a three-state fact.
**Layer of the implied fix:** L3 — a tri-state (complete / incomplete / not-collected) is a schema note; nothing distinguishes the two zero cases at record time.
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a — free text, and the comment correctly directs attention to the flattering-failure asymmetry.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Scoring category duplicating a pass/fail gate:** `evaluation.finalScore` duplicates `evaluation.acceptanceScore` (no derivation rule), and both sit alongside `tests` / `hiddenTests` as overlapping pass/fail signals. The clearest duplication is `finalScore` vs `acceptanceScore`.
- **Section most likely to diverge:** `measurement` — the `status` vocabulary is non-orthogonal (`excluded`/`invalidated`/`pilot` overlap) and `telemetryComplete` is a tri-state squeezed into a boolean. Two reviewers would diverge on both the status bucket and the completeness reading, by a full category each.
- **What the artifact did not say:** it never defined the `F01-F15` taxonomy, the canonical input to `fingerprint`, the relationship between `acceptanceScore` and `finalScore`, the unit of `cost`, the operational meaning of "proven loaded" (assertion ran vs. assertion passed), or what `runnerCommit` and `settingsSources` refer to. Every one of these is a place where the record can silently disagree with itself, and every implied fix is L3 — prose that constrains nothing.
