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
reviewed_utc:    20260930T144620Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: templates/run-record.yaml
    sha:  7c59a58067c8
    dirty: false
lab_head:        b96f8b3
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: templates/run-record.yaml
  verdict: REJECT
  summary: Seven fields claim constraints in comments (enum sets, structured shapes, hash-that-must-match, preflight-result-with-consequence, two-dimensional concept) but the schema is permissive, so runs filled against this template will fragment in every dimension the comments were written to prevent — concrete wrong actions include merging runs that may have hit different models and grouping failure classes into non-comparable categories.
  blocking:
    - reason: "resolved is a blank scalar but the comment names it as the load-bearing field for catching alias re-points (\"These differing is not a detail\"); a runner that does not report resolved leaves it blank, which is exactly the divergence the field was written to surface."
      wrong_action: A reader comparing two runs (one with `resolved: claude-haiku-4-5-20251001`, one blank) merges them as the same population; if the alias re-pointed between runs, the blank hides the divergence that the comment was written to flag.
      anchor: ' resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"'
      evidence: templates/run-record.yaml:16
    - reason: "fingerprint is a free string with the comment \"hash of the above; arms must match\" but nothing in the schema computes it — the structural property of a hash (changes when inputs change) does not survive a free-typed field."
      wrong_action: An analyst sees identical fingerprints in two arms and concludes the environments matched, when the operator copied `fingerprint: abc123` into both records against different hooks and permission modes — the one field positioned as the guard is what lets the confounding through.
      anchor: '  fingerprint:             # hash of the above; arms must match'
      evidence: templates/run-record.yaml:26
    - reason: "instructionsProvenLoaded: false is documented as a preflight assertion result but the template does not connect `false` to any consequence — a run where the treatment was not loaded and a run where it was both appear admissible."
      wrong_action: One reviewer excludes the run as a failed treatment; another scores it as a valid observation; the dataset accepts contaminated data with no record of the decision.
      anchor: '  instructionsProvenLoaded: false    # preflight assertion result'
      evidence: templates/run-record.yaml:31
    - reason: "approvals is a scalar but the comment names two dimensions (\"permission requests — and whether anyone could answer\"); a scalar can carry one, so the second dimension is unrecoverable from a count or a string."
      wrong_action: Three valid forms (`approvals: 3`, `approvals: { requested: 3, answered: 0 }`, `approvals: "blocked on first approval"`) all parse; downstream analysis on whether-anyone-could-answer works for one form and silently misses or errors on the others.
      anchor: '  approvals:               # permission requests — and whether anyone could answer'
      evidence: templates/run-record.yaml:45
    - reason: "failureClass is a free string but the comment names a 15-value enum (F01-F15); the schema accepts any value, so the same failure can be recorded as F03, F3, or \"compile failure\" and parsed as three distinct categories."
      wrong_action: Grouping by failure class treats one logical failure as three buckets, fragmenting a dimension the comment defines as having exactly fifteen values.
      anchor: '  failureClass:            # F01-F15'
      evidence: templates/run-record.yaml:73
    - reason: "status is a free string but the comment names a four-value enum (valid/excluded/pilot/invalidated); a run marked `status: provisional` is silently admitted by a filter expecting `valid` and silently dropped by a filter expecting `valid`."
      wrong_action: Two reviewers using the same field disagree on whether a borderline run is admissible; neither can cite the template to settle it, and the decision leaves no trace.
      anchor: '  status:                  # valid / excluded / pilot / invalidated'
      evidence: templates/run-record.yaml:77
    - reason: "exclusionReason is a blank scalar but the comment says \"structured, registered in advance\"; a scalar cannot carry a code field, so the structured form and the prose form coexist with no way to tell them apart."
      wrong_action: A query on `exclusionReason.code` works for the structured form and returns nothing for the prose form, fragmenting exclusion analysis across records that should be comparable.
      anchor: '  exclusionReason:         # structured, registered in advance'
      evidence: templates/run-record.yaml:78
  non_blocking:
    - reason: "filesRead is a blank scalar while sibling filesChanged is `[]`; if the intended convention is count-vs-list, the assignment for filesRead is ambiguous against the pattern set by its neighbour."
      evidence: templates/run-record.yaml:41-42
    - reason: "retries and compactions are blank scalars with no comments — their intended type and meaning are unspecified, so two reviewers will write them differently."
      evidence: templates/run-record.yaml:44,46
    - reason: "unintendedChanges is a blank scalar with no comment defining what counts as unintended."
      evidence: templates/run-record.yaml:72
    - reason: "validate-run-record.sh is named once (for the efficiency block); a reader can assume the other ten sections are self-enforcing, and there is no statement of which sections the validator does or does not cover."
      evidence: templates/run-record.yaml:60
    - reason: "acceptanceScore (evaluator verdict) and finalScore (rubric score) both appear under evaluation with no stated relationship; the boundary between evaluator gate and rubric measurement is left to be inferred."
      evidence: templates/run-record.yaml:71,74
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 148s |

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
**Layer of the the implied fix:** n/a
**Anchor:** n/a

### model
**Verdict:** finding
**Failure:** The comment warns that `requested` and `resolved` differing "is not a detail" because an alias can silently re-point between runs. But `resolved` is a blank scalar with no requirement to fill it. A runner that does not report the resolved model leaves it blank. Run A records `requested: haiku, resolved: claude-haiku-4-5-20251001`. Run B records `requested: haiku, resolved:` (blank). If the alias re-pointed to a different model between runs, the blank in Run B hides exactly the divergence the comment was written to flag. Two reviewers comparing the runs would either treat the blank as "same as Run A" or as "unknown" — and the template gives no rule to decide which.
**Layer of the implied fix:** L3
**Anchor:** `resolved:                # what telemetry reports, e.g. "claude-haiku-4-5-20251001"` / `# These differing is not a detail. An alias can silently re-point between runs.`

### environment
**Verdict:** finding
**Failure:** `fingerprint` is described as "hash of the above; arms must match." The structural property of a hash — that it changes when its inputs change — only holds if something computes it from the environment fields. In the template it is a free string an operator types. Scenario: two arms of an experiment have different hooks and different permission modes, but the operator copies `fingerprint: abc123` into both records. The "arms must match" check passes on identical fingerprints while the environments differ. Any cross-arm comparison is confounded, and the fingerprint — the one field positioned as a structural guard against this — is the thing that let it through.
**Layer of the implied fix:** L3
**Anchor:** `fingerprint:             # hash of the above; arms must match`

### configuration
**Verdict:** finding
**Failure:** `instructionsProvenLoaded: false` is commented as "preflight assertion result," implying something executed and set this boolean. But the template does not say what happens when the value is `false`. A run where the preflight failed (instructions not loaded) and a run where the preflight passed could both appear in the same dataset. One reviewer reads `false` as "exclude this run — the treatment was not delivered." Another reads it as "informational; score it anyway." The template records the failure but does not connect it to any consequence, so the two reviewers diverge on whether the run is admissible.
**Layer of the implied fix:** L3
**Anchor:** `instructionsProvenLoaded: false    # preflight assertion result`

### behavior
**Verdict:** finding
**Failure:** `approvals` is a blank scalar, but its comment raises a two-dimensional concept: "permission requests — and whether anyone could answer." A scalar cannot represent both dimensions. One reviewer records `approvals: 3` (count of requests). Another records `approvals: { requested: 3, answered: 0 }`. A third writes `approvals: "blocked on first approval, no human present"`. All are valid YAML against this template. Downstream analysis that counts unanswerable approvals — the dimension the comment explicitly names — cannot extract it from the first or third form, and has no contract telling it which form to expect.
**Layer of the implied fix:** L3
**Anchor:** `approvals:               # permission requests — and whether anyone could answer`

### efficiency
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### evaluation
**Verdict:** finding
**Failure:** `failureClass` is commented `# F01-F15` but is a free string. A reviewer who reads the comment writes `failureClass: F03`. One who does not writes `failureClass: "compile failure"`. A third writes `failureClass: F3` (no leading zero). Downstream grouping by failure class treats these as three distinct categories, fragmenting a dimension that is supposed to have fifteen values. The comment names the valid set; nothing in the template rejects a value outside it.
**Layer of the implied fix:** L3
**Anchor:** `failureClass:            # F01-F15`

### measurement
**Verdict:** finding
**Failure:** Two issues in the same block. (1) `status` is commented `# valid / excluded / pilot / invalidated` but is a free string. A run marked `status: provisional` passes a filter for `status: pilot` or `status: valid` and is silently dropped from analysis. The comment lists the admissible values; nothing rejects an inadmissible one. (2) `exclusionReason` is commented "structured, registered in advance" but is a blank scalar with no structure defined and no registration referenced. One reviewer writes `exclusionReason: "model hung"`. Another writes `exclusionReason: { code: "M01", detail: "model hung" }`. A query that filters on `exclusionReason.code` works for the second and errors or misses for the first.
**Layer of the implied fix:** L3
**Anchor:** `status:                  # valid / excluded / pilot / invalidated` / `exclusionReason:         # structured, registered in advance`

### notes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** The `evaluation` block records `compile`, `tests`, `hiddenTests`, and `acceptanceScore` — these are the evaluator's gate verdicts, not rubric scores. The run record is factual input to scoring, so recording them is not a gate restatement. The risk is the opposite direction: if the rubric (a separate artifact) also scores "did it compile," that rubric category is a constant across gate-passing runs. The run record itself is not at fault, but it does not flag the boundary — a reader could conflate `acceptanceScore` (evaluator verdict) with `finalScore` (rubric score) since both appear under `evaluation` with no stated relationship.
- **Which section would two reviewers diverge on most?** `measurement`. The `status` enum and `exclusionReason` structure are both commented but unconstrained, and `telemetryComplete` is a boolean whose consequence is undefined. A reviewer deciding whether to score a run with `status: pilot, telemetryComplete: false` has no rule in the template to apply — one admits it, another excludes it, and neither can cite the template to settle the disagreement.
- **What did the artifact not say that it needed to say?** (1) Which fields are required versus optional — every field is present but blank, and the lab's own principle ("a missing cell is not a null cell") means a field omitted entirely and a field present-but-blank are different states the template cannot distinguish. (2) What validates the record as a whole — `validate-run-record.sh` is named once, for the efficiency block only, leaving a reader to assume the other ten sections are self-enforcing when they are not. (3) What happens when `measurement.status` is not `valid` — the template lists four statuses but does not say which are admissible for scoring, which is the one decision a downstream consumer needs to make.
