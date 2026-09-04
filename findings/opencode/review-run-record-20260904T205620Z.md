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
reviewed_utc:    20260904T205620Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        b86401c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: ACCEPT
  summary: Template is structurally complete with reasonable comment hints; the line-level findings are documentation gaps (vague or incomplete comments) rather than false claims, and a reviewer can resolve them from the validator/fixtures.
  blocking: []
  non_blocking:
    - reason: The `fingerprint` comment "hash of the above; arms must match" uses an undefined term "arms" — two reviewers could compute the hash over different field sets without either being wrong against the template alone, producing non-comparable fingerprints across the same experimental arm.
      evidence: templates/run-record.yaml:26
    - reason: The `efficiency` provenance comment documents only `provider` and `local-tokenizer` as named sources, but the validator and `valid-mixed.yaml` use a third source `derived` for `cost`. The comment is incomplete (says 2, the system has 3) rather than false; a reviewer with a derived value has only the two labeled sources to choose from unless they read the fixtures.
      evidence: templates/run-record.yaml:52-57
    - reason: The `approvals` comment "permission requests — and whether anyone could answer" does not specify a type or shape — three reasonable formats (integer count, request/answered pair, boolean) all pass the validator, and a downstream reader cannot distinguish "no approvals needed" from "approvals needed but unattended" from "nobody could answer."
      evidence: templates/run-record.yaml:45
    - reason: The `failureClass` comment "# F01-F15" references a code scheme the template does not define or link; a reviewer classifying a failure has no guidance from this artifact alone and may invent codes.
      evidence: templates/run-record.yaml:73
    - reason: The `permissionMode` comment "acceptEdits / plan / default — see harness bug #7" references an external document not attached here; a reviewer cannot verify which modes are valid from this artifact alone.
      evidence: templates/run-record.yaml:20
    - reason: `configuration.instructionsProvenLoaded` defaults to `false`, and the validator does not enforce the field — a runner that forgets to update the field after preflight silently gets `false` and the record passes. This is a runner-behavior concern dressed up as a template default; the template itself is not making a false claim, but the default value is the worst-case interpretation.
      evidence: templates/run-record.yaml:31
  disputed:
    - finding: Validator at line 116 has an `isinstance(m, dict)` guard that silently bypasses the `telemetryComplete` presence check when the `measurement` block is missing entirely; the fixture set does not cover this bypass.
      why: The finding cites `tools/validate-run-record.sh` line 116, which is not part of the attached artifact (templates/run-record.yaml). I have not read the validator and cannot substantiate that the bypass exists or that the fixture set omits it. Even if true, the defect would be in the validator, not in this template — the template defines `telemetryComplete` as a required field by inference; whether the validator enforces it is a separate question I cannot resolve without reading the validator.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 116s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| environment | 1/1 | L3 |
| configuration | 1/1 | L3 |
| behavior | 1/1 | L3 |
| efficiency | 1/1 | L3 |
| evaluation | 1/1 | L3 |
| measurement | 1/1 | L2 |


---

## Run 1 of 1 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

→ Read tools/validate-run-record.sh
→ Read tools/verify-run-record-validator.sh
→ Read tools/fixtures/run-records
→ Read tools/fixtures/run-records/valid-level-a.yaml
→ Read tools/fixtures/run-records/valid-level-c.yaml
→ Read tools/fixtures/run-records/valid-mixed.yaml
→ Read tools/fixtures/run-records/bad-bare-scalar.yaml
→ Read tools/fixtures/run-records/bad-zero-for-unknown.yaml
→ Read tools/fixtures/run-records/bad-value-without-source.yaml
→ Read tools/fixtures/run-records/bad-provider-estimated.yaml
→ Read tools/fixtures/run-records/bad-null-with-source.yaml
→ Read tools/fixtures/run-records/bad-unknown-source.yaml
→ Read tools/fixtures/run-records/bad-missing-telemetry-complete.yaml
→ Read tools/fixtures/run-records/bad-missing-block.yaml
### runId
**Verdict:** no finding

### task
**Verdict:** no finding

### harness
**Verdict:** no finding

### model
**Verdict:** no finding

### environment
**Verdict:** finding
**Failure:** A reviewer fills in `fingerprint:` with a hash of the environment fields. The comment says "arms must match" but "arms" is not defined anywhere in the template. One reviewer interprets "arms" as experimental treatment arms and computes the fingerprint across the five listed fields (`bare`, `permissionMode`, `hooks`, `plugins`, `skills`, `mcpServers`, `settingsSources`). Another reads "arms" as something else and computes it over a different set. Two records from the same experimental arm carry fingerprints that disagree, and nothing in the template or validator says which is correct.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded` is commented "preflight assertion result" and defaults to `false`. The validator does not check this field. A run where the preflight assertion failed (instructions were not proven loaded) produces a record with `instructionsProvenLoaded: false` that passes validation. Two reviewers score the same run: one treats `false` as "preflight failed, the run is invalid" and excludes it; the other treats `false` as "the default template value, I forgot to set it" and includes it. The validator admits both, and the template does not say whether `false` invalidates the record.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** The `approvals` comment says "permission requests — and whether anyone could answer" but does not specify a type. One reviewer writes `approvals: 0` (no permission requests were made). Another writes `approvals: { requested: 3, answered: 0 }` (three requests, none answered because the run was unattended). A third writes `approvals: false` (nobody could answer). All three pass the validator — it checks no `behavior` fields. Downstream, a reader cannot distinguish "no approvals needed" from "approvals needed but unattended" from "nobody could answer," which are three different facts about the run.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The template's provenance comment documents two named sources — `provider` (Level A) and `local-tokenizer` (Level B) — plus `null` (Level C). The validator accepts a third source, `derived` (with `estimated: true`), and the `valid-mixed.yaml` fixture uses it for `cost`. A reviewer following only the template's comment has a cost value derived from a price table and writes `source: local-tokenizer` (the only non-provider source they can see), producing a mislabelled Level B measurement for what is actually a derived value. Another reviewer discovers `derived` from the validator or fixtures and labels it correctly. The two records carry different measurement levels for the same fact, which is the exact failure the provenance model exists to prevent.
**Layer of the implied fix:** L3
**Anchor:** `#   { value: 12400, source: provider,        estimated: false }   # Level A`

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is commented "F01-F15" but the template does not define what each code means or reference where they are defined. Two reviewers classifying the same failure — say, an agent that produced correct code but edited a file outside the task scope — one calls it F07, the other F12. Neither the template nor the validator constrains the value; `failureClass: F99` or `failureClass: "agent went rogue"` both pass. The classification is uncomparable across runs.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** The validator checks `telemetryComplete` presence only inside a dict-typed `measurement`. If `measurement` is absent entirely, `doc.get("measurement")` returns `None`, `isinstance(None, dict)` is `False`, and the check is silently skipped — no error is appended. A record with no `measurement` block at all passes validation, despite the template requiring `telemetryComplete` and the validator existing to enforce that. The `bad-missing-telemetry-complete.yaml` fixture tests a `measurement` dict missing the key, but no fixture tests a missing `measurement` block, so this bypass is untested. Two reviewers: one omits `measurement` (thinks it's optional), the other includes `telemetryComplete: false`. Both pass. The first record has no telemetry signal at all — the exact gap the validator was built to reject.
**Layer of the implied fix:** L2
**Anchor:** `if isinstance(m, dict) and "telemetryComplete" not in m:` (validator line 116)

### notes
**Verdict:** no finding

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not applicable — this is a run-record template, not a scoring rubric. But `configuration.instructionsProvenLoaded` restates a preflight gate (the assertion that instructions loaded), and the validator does not enforce it. If a downstream scoring rubric treated `instructionsProvenLoaded: false` as a gate failure, the gate and the rubric would overlap; today neither enforces it, so the overlap is latent.
- **Which single section would two reviewers diverge on most?** `measurement`. The `telemetryComplete` presence check is the one L2 control in this artifact, and it has a bypass (missing `measurement` block) and a type gap (null value passes). Two reviewers inspecting the validator would disagree on whether a record with no `measurement` block is valid — one reads the `isinstance` guard as intentional (skip non-dict), the other reads it as an oversight (should error). The fixture set does not settle it.
- **What did the artifact not say that it needed to say?** The template documents two of three valid `source` values (`provider`, `local-tokenizer`) but the validator and fixtures use a third (`derived`). The template's provenance comment is the only place a reviewer learns what sources are available, and it is incomplete. A reviewer who needs to label a derived cost has no guidance from the artifact they are filling in.
