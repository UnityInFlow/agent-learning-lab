# opencode review — backend-quality

```yaml
line_level:
  agent:         lab-critic
  model:         ollama-cloud/deepseek-v4-pro          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.21
reviewed_utc:    20260828T055602Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  f63ef7037a55
lab_head:        32e6153
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: benchmark/rubrics/backend-quality.yaml
  verdict: REJECT
  summary: All four category anchors carry textual ambiguities that would cause two faithful scorers to assign different scores to the same submission; the artifact's preamble names exactly this failure mode ("Two faithful scorers reach different numbers") as something to avoid, but the fixes only closed ladder gaps, not the anchor text itself.
  blocking:
    - reason: architecture-consistency anchor 0 reads "constructs an error body itself — an `ApiError(...)` or `ApiErrorBody(...)` literal, or a map, appears inside a controller method". The list item "or a map" is not qualified as an error-body map. A submission that returns a success shape as a map (e.g. `ResponseEntity<Map<String, Any>>` carrying shipment details on the happy path) with refusals correctly throwing `ConflictException` matches anchor 0 by a literal reading of "a map, appears inside a controller method" and anchor 2 by a reading of the opening clause as governing the list.
      wrong_action: A literal-text scorer records 0 on a 35-weight category for a submission that the rubric's stated intent says is correct; a context-reading scorer records 2. That is a 17.5-point swing on a 100-point total from one submission, which is the kind of unreliability the artifact's preamble says it was written to prevent.
      anchor: "The shipment package constructs an error body itself — an `ApiError(...)` or `ApiErrorBody(...)` literal, or a map, appears inside a controller method."
      evidence: benchmark/rubrics/backend-quality.yaml:117
    - reason: maintainability anchors 0 and 2 both define "expression position" narrowly as "its value returned or assigned" (anchor 0) / "neither returned nor assigned" (anchor 2). Kotlin's actual expression position is wider: a `when` passed as a function argument is expression-position and therefore compiler-enforced, but its value is neither returned nor assigned. A submission like `return ResponseEntity.ok(mapOf("status" to when (shipment.status) { PENDING -> "p"; SHIPPED -> "s"; CANCELLED -> "c" }))` is exhaustive, has no `else`, and is compiler-enforced — but a scorer reading the rubric text literally places it in anchor 0's "statement position" branch.
      wrong_action: An exhaustively-correct, compiler-enforced `when` is scored 0 (12.5 points of 25) by a literal text reader and 2 by a reader who knows Kotlin's expression/statement distinction. Two-point divergence on a 25-weight category, and the divergence is between "correct" and "defect" — not between "good" and "great".
      anchor: "One `when (shipment.status)` in EXPRESSION position — its value returned or assigned — carrying no `else`."
      evidence: benchmark/rubrics/backend-quality.yaml:141,143
    - reason: test-quality anchor 2 clause 1 says "confirm is called twice and the second response is asserted" without saying what is asserted. The whole category's axis is status-only (anchor 0) versus body-reading (anchor 2), so "asserted" is doing unstated work in a body-reading rubric. A test that calls confirm twice, asserts only the second response's HTTP status, re-reads state via a separate `get(...)`, and asserts one refusal's `$.error.code` satisfies clause 1 by a status-as-asserts reading and fails it by a body-must-be-asserted reading.
      wrong_action: A submission exercising all three of the rubric's stated behaviors — repeat, re-read, envelope assertion — is scored 2 (12.5 of 25) by one faithful reader and 1 (6.25 of 25) by another. One-point divergence on a category that already carries three structural nulls, and the divergence is between a score that credits the work and a score that withholds it.
      anchor: "All three hold, each citable: confirm is called twice and the second response is asserted; the persisted state is re-read through a separate `get(...)` rather than trusted from the mutating call's own body; and at least one refusal asserts the envelope's `$.error.code` rather than the status alone."
      evidence: benchmark/rubrics/backend-quality.yaml:155
    - reason: change-focus anchor 0 carves out only "trailing whitespace" and anchor 2 requires "character-identical". A submission that is byte-for-byte the same as the baseline except for a CRLF→LF conversion, or except for the presence/absence of a trailing newline at EOF, differs at every byte of every method while being visually and semantically identical. A "character-identical" reader at byte level will treat this as different and score 1; a reader who treats line endings and EOF newlines as invisible whitespace will score 2. The carve-out names "trailing whitespace" but not line endings or EOF, and these are not the same thing in any conventional reading of "whitespace".
      wrong_action: A submission whose only difference from the baseline is a line-ending normalization is scored 1 (3.75 of 15) by a byte-level reader and 2 (7.5 of 15) by a visible-text reader, on a category whose entire purpose is to credit "only the named method changed".
      anchor: "Every method the ticket did not name is character-identical to the baseline. Only `confirm`, and the imports it requires, differ. Name the methods checked."
      evidence: benchmark/rubrics/backend-quality.yaml:164,166
  non_blocking:
    - reason: The L2-vs-L3 unenforcement of the gate-passing filter ("AND NOTHING HERE ENFORCES IT. ... The filter lives in E-001's Exclusions, which is a document. **L3.** The L2 version is the scorer refusing a target that is not a registered gate-passing `run_case`; it does not exist.") is registered explicitly in the artifact and the L2 alternative is named. Per the gate rules an acknowledged gap with a recorded decision is not blocking.
      evidence: benchmark/rubrics/backend-quality.yaml:96-102
    - reason: architecture-consistency anchor 2's "throws an `ApiException` subclass" brushes the correctness boundary, but the anchor is built on which TYPE is thrown (baseline-existing vs. submission-introduced) rather than whether a refusal happens, so it is a "how well" judgment among gate-passing submissions rather than a gate restatement. Not a constant across the population the rubric can score.
      evidence: benchmark/rubrics/backend-quality.yaml:119
  disputed: []
  needed_to_decide: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| architecture-consistency | 1/1 | L3 |
| maintainability | 1/1 | L3 |
| test-quality | 1/1 | L3 |
| change-focus | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · deepseek-v4-pro

### version
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### scale
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### architecture-consistency
**Verdict:** finding
**Failure:** Anchor 0 equates "a map" with "an error body" without qualification. A controller that returns a success shape as a map — e.g. `ResponseEntity<Map<String, Any>>` carrying shipment details on the happy path, with refusals correctly throwing `ConflictException` — is read by a literal scorer as "a map appears inside a controller method" → anchor 0 → score 0. A second scorer reads the opening clause "constructs an error body itself" as governing the whole list, sees the map is a *success* body, and scores anchor 2. Two-point divergence on a 35-weight category from one submission.
**Layer of the implied fix:** L3
**Anchor:** "constructs an error body itself — an `ApiError(...)` or `ApiErrorBody(...)` literal, or a map, appears inside a controller method"

### maintainability
**Verdict:** finding
**Failure:** The anchor defines expression position as "its value returned or assigned", and anchor 0 defines statement position with the *same* narrow test ("its value neither returned nor assigned"). Kotlin's actual expression position is wider: a `when` passed as a function argument is expression-position and compiler-enforced, but its value is neither returned nor assigned. A submission like `return ResponseEntity.ok(mapOf("status" to when (shipment.status) { PENDING -> "p"; SHIPPED -> "s"; CANCELLED -> "c" }))` — exhaustive, no `else`, value passed to `mapOf` — is scored 0 by a literal reader (statement position) and 2 by a Kotlin-aware reader (expression position, exhaustiveness enforced). Two-point divergence on a 25-weight category.
**Layer of the implied fix:** L3
**Anchor:** "One `when (shipment.status)` in EXPRESSION position — its value returned or assigned — carrying no `else`"

### test-quality
**Verdict:** finding
**Failure:** Anchor 2 clause 1 says "the second response is asserted" without saying *what* is asserted. The whole category's axis is status-only (anchor 0) versus body-reading (anchor 2), so "asserted" is doing unstated work. A test that calls confirm twice, asserts the second response's HTTP status only, re-reads state via a separate `get(...)`, and asserts one refusal's `$.error.code` — Reviewer A reads "asserted" as satisfied by the status assertion → all three clauses → 2; Reviewer B reads "asserted" in a body-reading rubric as requiring a body assertion → clause 1 absent → 1. One-point divergence on a 25-weight category, and the category already carries three structural nulls.
**Layer of the implied fix:** L3
**Anchor:** "confirm is called twice and the second response is asserted"

### change-focus
**Verdict:** finding
**Failure:** Anchor 2 requires "character-identical" and anchor 0 carves out only "trailing whitespace". Line-ending conversion (CRLF↔LF) or a trailing-newline-at-EOF difference changes every byte of a file while being invisible to a human reader. A submission identical to the baseline except for a CRLF→LF conversion: Reviewer A reads "character-identical" at byte level → fails → residual 1; Reviewer B treats line endings as whitespace → character-identical → 2. The carve-out names "trailing whitespace" but not line endings or EOF newline, so the two readers diverge on a 15-weight category.
**Layer of the implied fix:** L3
**Anchor:** "Every method the ticket did not name is character-identical to the baseline."

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No — the artifact explicitly dropped `functional-correctness` and `requirement-completeness` for exactly this reason, and the remaining four anchors are all "how well" constructs, not gate restatements. The one near-miss is architecture anchor 2's "throws an `ApiException` subclass", which brushes the correctness boundary, but it is anchored on *which* type is thrown (baseline-existing vs. introduced), not on whether the refusal happens, so it is not a constant across the gate-passing population.
- **Which single section would two reviewers diverge on most, and by how much?** `test-quality`. It carries 25 of 100, three of its five cells are structurally null before an anchor is read, and its anchor 2 clause 1 ("the second response is asserted") is under-specified on the exact axis the category is built around. Expected divergence of one full point (score 1 vs 2) on a non-null cell, plus the null-vs-0 boundary in the precondition, which the artifact itself admits is L3 and unenforced.
- **What did the artifact not say that it needed to say?** It admits, in the preamble, that the single most important rule — "a run that failed a gate is unsuccessful, do not score it" — is enforced nowhere: the filter lives in E-001's Exclusions, a document, and `opencode-score.sh` will score any directory it is handed. The artifact names the L2 version ("the scorer refusing a target that is not a registered gate-passing `run_case`") and states it does not exist, but stops there. It needed to say whether that L2 mechanism is in scope for this file or tracked elsewhere, because as written the rubric's entire premise ("the gates own correctness") is a claim the scoring tool does not honor.
