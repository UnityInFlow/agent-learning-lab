# opencode review — run-record

```yaml
reviewer:        lab-critic
model:           ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
opencode:        1.18.21
agent_sha:       877d376359ad
reviewed_utc:    20260824T195623Z
artifacts:
  - path: templates/run-record.yaml
    sha:  00c929a0f8d8
lab_head:        9d5cb08
lab_dirty:       true
```


> lab-critic · deepseek-v4-pro

### runId
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** `runId: B0-COPILOT-BE001-001`

A single illustrative value with no stated segment grammar. I cannot construct a concrete two-reviewer divergence that isn't speculative, so I won't manufacture one.

---

### task
**Verdict:** finding
**Failure:** `benchmarkSha` is blank and nothing in the schema rejects a recorded run whose `benchmarkSha` is empty. Two arms resolve the task/evaluator from different commits (task revision `1` vs a later fix), both record `benchmarkSha:` empty, and the aggregation compares them as if they were the same benchmark. The field exists but has no non-empty constraint, so the reproducibility guarantee it promises is advisory only.
**Layer of the implied fix:** L1 — the field is a data constraint; a non-empty/required check on the record is structural, not prose.
**Anchor:** `benchmarkSha:            # the commit the task/evaluator were resolved from`

---

### harness
**Verdict:** finding
**Failure:** `version` and `runnerCommit` are both blank with no gate. Harness behavior is explicitly load-bearing (the `permissionMode` field defers to "harness bug #7"), so a run recorded without a pinned `version`/`runnerCommit` cannot be reproduced or audited after the fact. Two reviewers hitting different harness builds both leave these fields empty, and the divergent `permissionMode` semantics they observed get attributed to the treatment instead of the harness.
**Layer of the implied fix:** L1 — required/pinned fields on the record.
**Anchor:** `version:` / `runnerCommit:`

---

### model
**Verdict:** finding
**Failure:** The comment correctly flags that `requested` ≠ `resolved` is load-bearing ("An alias can silently re-point between runs"), but there is no field, flag, or status linkage that records the *consequence* of a mismatch. Two reviewers observe the same `requested: haiku` / `resolved: claude-sonnet-4` alias drift: reviewer A marks the run `invalidated` in `measurement.status`, reviewer B leaves it `valid` and files it as a normal data point. The only thing in the schema speaking to this is the comment — prose.
**Layer of the implied fix:** L3 — the current signal is a comment; any fix that adds a "check this" instruction is guidance and constrains nothing.
**Anchor:** `# These differing is not a detail. An alias can silently re-point between runs.`

---

### environment
**Verdict:** finding
**Failure:** `fingerprint` is described as "hash of the above; arms must match", but the canonicalization is unspecified. Reviewer A hashes `JSON.stringify` of the environment object in insertion order; reviewer B sorts keys before hashing. Same loaded environment, two different fingerprints, and the "arms must match" check spuriously fails — or, worse, two reviewers each use *their own* canonicalization consistently and never detect a genuine environment drift because their hashes are mutually incomparable. Also, `permissionMode` includes the value `default`, which is not a real permission mode but an escape hatch meaning "I didn't inspect"; two reviewers recording the same session produce `default` and `acceptEdits` respectively.
**Layer of the implied fix:** L2 — a hashing contract (algorithm + canonical field ordering) is a spec that a tool can enforce; as written it is a comment with no enforcement.
**Anchor:** `fingerprint:             # hash of the above; arms must match`

---

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` records a "preflight assertion result" and can be `false`, but there is no linkage between that boolean and `measurement.status`. A run recorded with `instructionsProvenLoaded: false` can still carry `status: valid` with no field forcing the two into conflict. Two reviewers: one treats a `false` preflight as automatically `invalidated`, the other treats it as a recorded-but-passed note. The assertion is enforced nowhere; it is a checkbox.
**Layer of the implied fix:** L2 at best if wired to a gate, but as written the implied fix is "remember to check it" — L3.
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

---

### behavior
**Verdict:** finding
**Failure:** The section mixes blank scalars (`modelCalls:`, `toolCalls:`, `filesRead:`) with empty collections (`toolsUsed: []`, `filesChanged: []`), and nothing in the schema distinguishes "not captured" from "captured and zero". The `measurement.telemetryComplete` comment explicitly says "a gap must not read as a zero", but the behavior fields carry no sentinel to make that distinction. Concrete divergence: the agent made zero file changes and the telemetry was never collected — one reviewer records `filesChanged: []` (asserting zero), the other records `filesChanged:` blank (asserting unknown); `telemetryComplete: true` is then set identically by both, and a run with *missing* tool-call telemetry is aggregated as a run with *zero* tool calls.
**Layer of the implied fix:** L1 — a nullable/`unknown` sentinel distinct from `0`/`[]` is a schema structural property, not wording.
**Anchor:** `filesChanged: []` vs `filesRead:` (blank) and `# a gap must not read as a zero`

---

### efficiency
**Verdict:** finding
**Failure:** `cost:` has no unit or currency anchor. Two reviewers recording the same run disagree on whether the number is USD, milli-USD, or the harness's internal billing token, producing two different `cost` values for one run — and nothing downstream can reconcile them. Minor, but it is a concrete divergence the field does not prevent.
**Layer of the implied fix:** L1 — unit/currency is a field type constraint.
**Anchor:** `cost:`

---

### evaluation
**Verdict:** finding
**Failure:** `acceptanceScore` and `finalScore` are two distinct scalar fields with no rule stating whether one is derived from the other, whether they are independent, or which one the lab reports. Two reviewers recording the same run produce different values in each, and the lab has no way to know which is authoritative. Additionally, `failureClass: # F01-F15` defers to an enum defined off-document, and `unintendedChanges` is untyped (count? list of paths? boolean?) — so reviewer A records `unintendedChanges: 2`, reviewer B records `unintendedChanges: ["src/foo.ts"]`, and the schema accepts both.
**Layer of the implied fix:** L1 — score composition and field typing are schema-structural.
**Anchor:** `acceptanceScore:` / `finalScore:` / `unintendedChanges:` / `failureClass:            # F01-F15`

---

### measurement
**Verdict:** finding
**Failure:** `exclusionReason` is described as "structured, registered in advance", but there is no field pointing at the registry the reason must come from. Two reviewers exclude the same run: reviewer A writes free text (`"model alias drift"`), reviewer B writes a registry key (`"E07"`). Aggregation cannot group exclusions, and the "structured" promise is unenforceable because the registry is never referenced. The `status` enum itself includes `pilot`, whose meaning is never defined, so two reviewers disagree on whether a pilot run counts toward the same population as `valid`.
**Layer of the implied fix:** L2 — a closed value set pulled from a registry is enforceable by tooling; as written the implied fix is "use the registry" — L3.
**Anchor:** `exclusionReason:         # structured, registered in advance`

---

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Free text; the guidance itself is sensible and the field is unconstrained by design.

---

### Cross-cutting
- **Duplicate pass/fail gate:** `evaluation.acceptanceScore` and `evaluation.finalScore` are two numeric verdicts with no composition rule — both are candidate "did it pass" numbers. Also `evaluation.tests` / `hiddenTests` / `acceptanceScore` form an undefined chain where `acceptanceScore` is likely derived from the test fields, but nothing states the derivation, so a reader cannot tell which is the gate and which is the raw input.
- **Most divergent section:** `evaluation` — by a wide margin. Four independent ambiguities live there (two untyped/undefined numeric scores, an off-document `F01-F15` enum, an untyped `unintendedChanges`), and each independently produces a different recorded value between two reviewers. Expected divergence: two reviewers would disagree on `finalScore` for the same run a majority of the time, because the composition rule does not exist.
- **What the artifact did not say:** it never defined the fingerprint canonicalization (algorithm + field ordering), never defined a blank-vs-zero sentinel so `telemetryComplete` can actually distinguish a gap from a zero, never defined how `acceptanceScore` and `finalScore` relate, never defined the `F01-F15` enum or the exclusion-reason registry, never gave `cost` a unit/currency, and never wired the `model` requested/resolved mismatch or `instructionsProvenLoaded: false` into a status outcome — all six are flagged as load-bearing by the artifact's own comments yet carry no enforcement, which is the precise L3 trap the template's own `notes` section warns about.
