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
reviewed_utc:    20260910T092058Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        8a1a231
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: The template records gating facts (treatment-loaded, telemetry-complete, fingerprint-matched, taxonomy-classified) but connects none of them to a consequence — two reviewers can produce records that are structurally valid yet incomparable, and a run can be marked `status: valid` while every gate is unverified.
  blocking:
    - reason: The `approvals` field is a bare key with a comment that implies at least three dimensions (requested, answered, effect on the run), but the field has no structure. Three reviewers would write three different values and all would be valid YAML.
      wrong_action: Reviewer A writes `0` (no approvals needed); Reviewer B writes `{requested: 2, answered: 0}` (two prompts, none answered); Reviewer C writes `true` (approvals happened). All three pass template validation. An aggregation that reads `approvals` as a count records "0 approvals" for the run that hung on an unanswered prompt and "0 approvals" for the run that needed none, treating them as equivalent.
      anchor: "approvals:               # permission requests — and whether anyone could answer"
      evidence: templates/run-record.yaml:44
    - reason: `fingerprint` is described as "hash of the above; arms must match" but the template specifies no algorithm, no field set, and no normalisation rule. "The above" is ambiguous given the mix of scalar and list-valued fields above it.
      wrong_action: Reviewer A computes SHA-256 over the serialised YAML of all eight environment fields; Reviewer B computes it over the five scalar fields only, excluding `settingsSources: []`, `hooks: []`, `plugins: []`, `skills: []`, `mcpServers: []`. Two arms with identical environments under B's method get matching fingerprints; under A's method, list-field ordering differences produce divergent hashes. A comparison that should be valid is invalidated, or — worse — a comparison with a real plugin difference is treated as matched.
      anchor: "fingerprint:             # hash of the above; arms must match"
      evidence: templates/run-record.yaml:26
    - reason: `failureClass: # F01-F15` references a taxonomy that is not defined in the template and not pinned to any version, sha, or URL.
      wrong_action: A timeout is recorded as `failureClass: F04` under the current taxonomy and `failureClass: F03` under a prior revision. Two records from different dates that both say `F07` may refer to different failure modes. Aggregations bucketing runs by failure class silently mix incompatible categories; a reviewer trying to compute "how many timeouts across all runs" gets a number that depends on when each record was written.
      anchor: "failureClass:            # F01-F15"
      evidence: templates/run-record.yaml:73
    - reason: The efficiency block defines a three-level provenance scheme (A/B/C) and explicitly rejects bare numbers, but it does not address the mixed state where `value` is non-null and `source` is null. The structure `{value: 12400, source: null, estimated: null}` is valid under the template and under the comment's own description of what each level means.
      wrong_action: Reviewer A reads `{value: 12400, source: null, estimated: null}` as "Level A with provenance forgotten — the value is real." Reviewer B reads it as "Level C with a stray value — the value is unverified." The same record produces a real efficiency datapoint under A and a missing one under B, and an aggregation that averages efficiency reads it one way and discards it the other.
      anchor: "# validate-run-record.sh rejects a bare number — this block is Layer 3 on its own."
      evidence: templates/run-record.yaml:60-65
    - reason: `instructionsProvenLoaded` is annotated as "preflight assertion result," implying it is a gate, but the template provides no rule linking `false` to `measurement.status` or `exclusionReason`.
      wrong_action: A run with `instructionsProvenLoaded: false` (the treatment's instructions may not have loaded — the agent may have run with defaults) is scored identically to a run with `true`. The recorded `configuration` block describes what was requested, not what was received, and a reader has no signal in the template that one is more trustworthy than the other.
      anchor: "instructionsProvenLoaded: false    # preflight assertion result"
      evidence: templates/run-record.yaml:31
    - reason: `telemetryComplete` is commented "a gap must not read as a zero" but the field is not connected to `status`. The structure `{value: null, source: null, estimated: null}` for any usage field is exactly the Level C state the comment defines, yet the template places it on a row with the same shape as Level A.
      wrong_action: A run with `telemetryComplete: false` and several null usage entries is scored the same as one with `telemetryComplete: true` and genuine low usage. An efficiency comparison cannot distinguish "the runner never reported tokens" from "the agent used almost no tokens," because the template does not route the first state to `status: excluded`.
      anchor: "telemetryComplete:       # a gap must not read as a zero"
      evidence: templates/run-record.yaml:79
    - reason: The template records gating facts in three places — `instructionsProvenLoaded`, `telemetryComplete`, and the implicit requirement that fingerprints match — but never defines any of them as gates. The `measurement.status` / `exclusionReason` pair exists to exclude runs, and nothing in the template is reachable from it.
      wrong_action: A reader fills in a record with `instructionsProvenLoaded: false`, `telemetryComplete: false`, a mismatched `fingerprint`, and marks it `status: valid` because the template does not say otherwise. The `exclusionReason` field is left blank because no field instructs the reader to populate it. The cross-cutting note from the line-level pass is correct: a run can carry every gate in an unverified state and still be `status: valid`.
      anchor: "status:                  # valid / excluded / pilot / invalidated"
      evidence: templates/run-record.yaml:77-78
  non_blocking:
    - reason: The `notes` field is a freeform string; the template's own instruction to record "anything that made the agent look good" is good practice but unstructured, so two reviewers' notes cannot be aggregated without losing meaning.
      evidence: templates/run-record.yaml:81-84
    - reason: `benchmarkSha`, `version`, `runnerCommit`, `requested`, and several environment fields are present as blank keys without null vs missing distinction; a runner that omits a field and a runner that explicitly writes `null` produce indistinguishable records.
      evidence: templates/run-record.yaml:6,10,11,14,19,26 - reason: The `efficiency` comment block is internally inconsistent: it states "A record starts at Level C for everything, because that is true until a run fills it in" while also describing Level A/B examples, without specifying what shape the empty state must take versus a partial fill.
      evidence: templates/run-record.yaml:53-65
  disputed: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 120s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| model | 1/1 | L3 |
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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** A harness that does not report the resolved model name (some CLI tools expose only the alias) leaves `resolved` blank. The comment warns that "an alias can silently re-point between runs" — the entire protection depends on comparing `requested` vs `resolved`. With `resolved` blank, two runs that both say `requested: haiku` are assumed to have used the same model, but the alias may have re-pointed between them. Reviewer A excludes the run for unverifiable model identity; Reviewer B scores it, noting "resolved unknown." The template records the gap but does not connect it to `measurement.status` or any exclusion rule, so the two runs enter the same comparison as if they were comparable.
**Layer of the implied fix:** L3
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"` — the field is optional by construction; nothing rejects a blank value or flags the consequence.

### environment
**Verdict:** finding
**Failure:** `fingerprint` is described as "hash of the above; arms must match" but the template specifies no hash algorithm, no field set ("the above" could include or exclude `settingsSources`, `hooks`, `plugins`), and no normalisation for list-valued fields like `settingsSources: []`. Reviewer A computes SHA-256 over the serialised YAML of all eight fields; Reviewer B computes it over the five non-list fields only. Two arms with identical environments get different fingerprints under B's method, and the mismatch is read as an environmental difference — invalidating a comparison that should have been valid. Conversely, two arms with different `plugins` lists that Reviewer B excluded from the hash get matching fingerprints, masking a real difference. "Arms must match" is a comment; nothing executes a comparison and rejects a mismatched pair.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` records whether a preflight check confirmed the treatment (instructions) actually loaded. If `false`, the run's treatment is unverified — the agent may have run with default instructions, meaning the recorded "configuration" does not describe what actually happened. The template records this fact but connects it to nothing. A run with `instructionsProvenLoaded: false` is scored the same as one with `true`. Reviewer A excludes the run (the treatment isn't confirmed); Reviewer B scores it (the field is informational, not a gate). The template gives no rule to resolve this.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is commented as "permission requests — and whether anyone could answer," implying at least two dimensions (count requested, count answered, and whether the run was affected by unanswered prompts). The field is a bare key with no structure. Reviewer A writes `0` (no approvals needed). Reviewer B writes `{requested: 2, answered: 0}` (two prompts, none answered in an unattended run). Reviewer C writes `true` (approvals happened). All three are valid YAML under the template. A run that hung on an unanswered permission prompt and a run that needed no approvals are indistinguishable if both happen to record `0`.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The template defines three provenance levels (A/B/C) and says "a record starts at Level C for everything." But it does not address the mixed state where `value` is non-null and `source` is null — e.g. `{ value: 12400, source: null, estimated: null }`. The validator rejects bare numbers (structural check), but nothing rejects a value with no provenance. Reviewer A reads this as "Level A with missing source — the value is real, provenance was forgotten." Reviewer B reads it as "Level C with a stray value — the value is unverified, treat as unknown." The two interpretations produce different efficiency comparisons from the same record. The template's own comment acknowledges "this block is Layer 3 on its own," but the mixed-state gap is not the same gap the comment addresses — the comment is about bare numbers, not about partial fills.
**Layer of the implied fix:** L3
**Anchor:** `# validate-run-record.sh rejects a bare number — this block is Layer 3 on its own.`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is annotated `# F01-F15` but the taxonomy is not defined in the template and no pointer to its definition is given. If the F01–F15 taxonomy is revised between runs (a failure class is renumbered, merged, or added), two records from different dates that both say `failureClass: F07` refer to different failure modes. Reviewer A classifies a timeout using the current taxonomy as `F04`; Reviewer B, using a prior version, classifies the same timeout as `F03`. The records are structurally valid but semantically incomparable, and nothing in the template pins the taxonomy version (no sha, no version number, no URL).
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** `telemetryComplete` is commented "a gap must not read as a zero," meaning incomplete telemetry should be flagged, not silently filled. But the field is not connected to `status`. A run with `telemetryComplete: false` and `status: valid` is structurally valid under the template. Reviewer A excludes the run (incomplete telemetry means the efficiency block is unreliable, so the measurement is invalid). Reviewer B scores it (the field is informational; the run still produced a result). The template records the fact but provides no rule linking `telemetryComplete: false` to `status: excluded` or to `exclusionReason`.
**Layer of the implied fix:** L3
**Anchor:** `telemetryComplete:       # a gap must not read as a zero`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- `evaluation.failureClass` (F01–F15) and `measurement.status` (excluded / invalidated) potentially overlap: a failure class that implies the run should be excluded (e.g. a harness bug that invalidates the result) has no defined connection to `status`. The template records both independently, so a run can carry `failureClass: F07` and `status: valid` simultaneously, with no rule to reconcile them.
- `behavior.approvals` is the section two reviewers would diverge on most. The comment implies three dimensions (requested, answered, effect on the run) but the field has no structure, so the divergence is not a matter of judgment but of format — they would produce structurally different records for the same run.
- The template records gating facts (`instructionsProvenLoaded`, `telemetryComplete`, `fingerprint` mismatch) but does not connect any of them to a consequence. It never says what happens when a preflight fails, when telemetry is incomplete, or when arms don't match. The `measurement.status` / `exclusionReason` pair exists to exclude runs, but nothing in the template routes the gating facts into it. The template can describe a run where the treatment wasn't loaded, telemetry is incomplete, and the environment fingerprint doesn't match — and still mark it `status: valid`.
