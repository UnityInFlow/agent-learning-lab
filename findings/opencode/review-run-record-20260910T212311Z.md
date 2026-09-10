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
reviewed_utc:    20260910T212311Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        387c4c1
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: ACCEPT
  summary: A permissive template whose prose comments label fields without enforcing structure — five section-level L3 gaps are real but the artifact makes no claim it cannot back, and a named validator covers the only specific enforcement claim.
  blocking: []
  non_blocking:
    - reason: The fingerprint field is constrained by prose ("hash of the above; arms must match") with no executor named and no rule for which subset of the seven preceding fields to hash. Two arms following the same comment but hashing different subsets produce incomparable digests and a reader cannot tell drift from computation disagreement.
      evidence: templates/run-record.yaml:26
    - reason: The approvals field is labeled `# permission requests — and whether anyone could answer` with no schema; a count, a list, and an object are all faithful readings and downstream aggregation cannot combine them.
      evidence: templates/run-record.yaml:45
    - reason: The efficiency block documents three illustrative states (Level A/B/C) and a validator that "rejects a bare number", but the artifact does not say the list is closed. A filled record carrying `{ value: 12400, source: null, estimated: null }` is a fourth state the template does not name — reviewers will disagree about whether it is valid, a Level C, or a Level A with missing metadata.
      evidence: templates/run-record.yaml:53-65
    - reason: `acceptanceScore` and `finalScore` are two blank fields with no comment relating them. A reader cannot determine which is authoritative without a convention the artifact does not state.
      evidence: templates/run-record.yaml:71-72
    - reason: `failureClass: # F01-F15` is an enum in a comment but no validator is named that rejects values outside the range, so a reviewer who writes `F00` has no signal from the template.
      evidence: templates/run-record.yaml:74
    - reason: `exclusionReason` is labeled "structured, registered in advance" but no structure is given and no registry is referenced; the constraint is unverifiable from the artifact alone.
      evidence: templates/run-record.yaml:78
    - reason: `permissionMode` lists `acceptEdits / plan / default` in a comment but does not name what rejects other values, so `permissionMode: auto` is unaddressed.
      evidence: templates/run-record.yaml:20
    - reason: No field is marked required versus optional. A reader of a completed record cannot distinguish an intentionally-empty value from a forgotten one — and the artifact's only reference to a validator (line 60) scopes the rejection claim to one block, leaving every other field's correctness to a comment the reader has to trust.
      evidence: templates/run-record.yaml:1-84
    - reason: `instructionsProvenLoaded: false` defaults to `false` with comment `# preflight assertion result`; if no preflight ever runs, the field records nothing meaningful and `false` cannot be distinguished from "preflight ran and failed".
      evidence: templates/run-record.yaml:31
  disputed:
    - finding: "Cross-cutting: evaluation.compile and evaluation.tests restate the run gate as data and so carry no information that the gate has not already encoded."
      why: The artifact is a TEMPLATE with empty values — it does not assert these fields are independent measurements, only that they record what an evaluator produced. Whether they duplicate the gate is a property of how a filled record is used (the rubric/scoring concern flagged in lab memory), not a defect of the template's structure. Substantiating the claim requires opening the gate script and the filled-record use case, neither of which is attached.
    - finding: "Cross-cutting: which single section would two reviewers diverge on most."
      why: The line-level pass flagged this as a meta-question, not a defect of the artifact. The template allows divergence on multiple sections (approvals, exclusionReason, fingerprint, efficiency levels) — picking a single one is the critic's ranking, not something the artifact says or contradicts.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 68s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| environment | 1/1 | L3 |
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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### environment
**Verdict:** finding
**Failure:** Two arms of the same experiment fill in `fingerprint:` with hashes computed from different subsets of the seven fields above it — one hashes all seven, another omits `settingsSources` because it was empty. The records both pass. A reader comparing the two fingerprints to confirm "arms must match" sees different hashes and cannot tell whether the mismatch is a configuration drift (the thing the fingerprint exists to catch) or a computation disagreement. The constraint is stated in prose and nothing computes or verifies the hash. Separately, `permissionMode:` documents an enum (`acceptEdits / plan / default`) in a comment, but a reviewer who writes `permissionMode: auto` — a real mode in some harnesses — has no way to know from the template whether that is rejected or accepted.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### behavior
**Verdict:** finding
**Failure:** The `approvals` field is commented `# permission requests — and whether anyone could answer` but has no structure. Reviewer A records `approvals: 3` (a count of prompts). Reviewer B records `approvals: [{ request: "file write", answered: false }]` (a list, capturing that nobody was there to approve). Reviewer C records `approvals: { count: 3, anyAnswered: false }`. All three are faithful readings of the comment. A downstream analysis that asks "how many runs had unanswerable approval requests?" gets a number from A, a list from B, and an object from C, and cannot aggregate them without first re-reading every record to normalize — which is the thing a structured field is supposed to prevent.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** finding
**Failure:** The comment defines exactly three levels: A (value + `source: provider` + `estimated: false`), B (value + `source: local-tokenizer` + `estimated: true`), and C (`value: null`, `source: null`, `estimated: null`). A filled record carrying `{ value: 12400, source: null, estimated: null }` — a concrete token count with no provenance — matches none of the three. The validator is said to reject a bare number, but the artifact does not claim it rejects a value-without-source. Reviewer A reads this as "Level C, the value is noise, ignore it." Reviewer B reads it as "Level A with missing metadata, use 12400." They produce different efficiency comparisons from the same record. The three-level model has a gap for the fourth state, and nothing in the artifact names it or says what to do with it.
**Layer of the implied fix:** L3
**Anchor:** `#   { value: null,  source: null,            estimated: null  }   # Level C`

### evaluation
**Verdict:** finding
**Failure:** The section has both `acceptanceScore:` and `finalScore:` with no comment relating them. Reviewer A treats `acceptanceScore` as the evaluator's raw verdict and `finalScore` as the experiment's adjusted score — fills both, differently. Reviewer B treats them as synonyms and fills only one. Reviewer C fills `acceptanceScore` from the evaluator output and leaves `finalScore` blank because "the final score is the acceptance score." A reader of the completed record cannot determine which field is authoritative without a convention that the artifact does not state. Separately, `failureClass: # F01-F15` is an enum in a comment; a reviewer who writes `failureClass: F00` (a class outside the range) has no signal from the template that this is wrong.
**Layer of the implied fix:** L3
**Anchor:** `acceptanceScore:` and `finalScore:`

### measurement
**Verdict:** finding
**Failure:** `exclusionReason:` is commented `# structured, registered in advance` but gives no structure and names no registry. Reviewer A writes `exclusionReason: harness-hang` (a code). Reviewer B writes `exclusionReason: "opencode run stalled at 12m, no output"` (prose). Reviewer C writes `exclusionReason: { code: "H03", registeredAt: "2026-09-01" }` (an object). "Registered in advance" implies a fixed vocabulary that exists somewhere outside this template, but the template does not reference it. Two reviewers who each believe they are following the instruction produce records that cannot be filtered or counted by exclusion reason without per-record re-interpretation.
**Layer of the implied fix:** L3
**Anchor:** `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `evaluation.compile` and `evaluation.tests` record the same outcomes the evaluator's exit codes already determine. If the run gate (Decision D, `check-run-gate.sh`) admits or refuses a run based on those exit codes, then recording them here restates a gate as data — the values are constants across every gate-passing run, carrying no information that the gate has not already encoded. `acceptanceScore` may be the same gate restated a third time; the artifact does not say whether it is the evaluator's verdict (a gate output) or an independent measurement.
- **Which single section would two reviewers diverge on most, and by how much?** `behavior.approvals`. The comment is a sentence, not a schema. The divergence is not marginal — one reviewer produces a scalar, another a list, a third an object. The field is unaggregatable across runs as written, and the gap is wide enough that two reviewers would not even recognize they had filled the same field differently without comparing records side by side.
- **What did the artifact not say that it needed to say?** Which fields are required versus optional. The template uses empty values and `[]` interchangeably for "not yet filled," but a reader of a completed record cannot tell an intentionally-empty field from a forgotten one. The one place the artifact names an enforcement mechanism (`validate-run-record.sh` rejects a bare number), it scopes the claim to a single check — it does not say what else the validator enforces, so every other field's correctness hangs on a comment the reader has to trust.
