# opencode review — backend-quality

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
opencode:        1.18.21
reviewed_utc:    20260827T181512Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  dbf6f64fdfdc
lab_head:        0f58203
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/benchmark/rubrics/backend-quality.yaml
  verdict: REJECT
  summary: All four categories have boundary gaps where a submission matches no anchor fully, and the rubric is silent on what to do in gap cases — two faithful scorers will produce different scores for the same gap-case submission.
  blocking:
    - reason: "All four categories have boundary gaps where a submission matches no anchor fully, and the rubric's contract ('emit null rather than guessing') is stated for the anchor-undecidable case but does not address the anchor-absent case the gaps produce."
      wrong_action: "A scorer fed a submission that partially matches a higher anchor (e.g., test-quality A✓ B✓ C✗, or change-focus with method-identical-but-extra-import-shuffle) cannot determine whether to score it as null, the highest fully-satisfied anchor, or the highest partially-satisfied anchor. Two independent scorers will produce different scores for the same submission, and the rubric provides no tiebreak rule."
      anchor: "Categories scoring null are excluded from BOTH sums."
      evidence: "backend-quality.yaml:45, 75-77 (architecture-consistency gap: a new ApiException subclass in com.unityinflow.sample.api matches no anchor — score 1 requires 'not imported from' and score 2 requires 'an existing' subclass), 87-89 (maintainability gap: a non-exhaustive when-as-statement with no else matches no anchor), 99-101 (test-quality gap: A✓ B✓ C✗ matches no anchor — score 1's trigger requires 'one of the two behaviours missing', score 2 requires 'all three hold'), 110-112 (change-focus gap: method-identical to baseline but extra import-line differences matches no anchor); line-level-findings.md:60-82"
  non_blocking:
    - reason: "The gate-failure rule is in a prose comment (lines 56-59) rather than a structured `precondition` field. The artifact already acknowledges preconditions are L3 — YAML read by a model, not executable (lines 95-96: 'This precondition is YAML read by a model — Layer 3 — so nothing executes to reject a `0` here') — so the structural weakness is documentation clarity, not enforcement. The rule itself is stated clearly enough that a faithful scorer would follow it; moving it to a `precondition` would not change the enforcement level."
      evidence: "backend-quality.yaml:56-59, 95-96, 97-98, 108-109"
    - reason: "The artifact does not confirm whether the harness filters gate-failing runs from the scorer's input. The rubric assumes the gate filters (lines 24-26 say 'gates own correctness and completeness'); whether the harness actually does so is a system-level concern outside the rubric's scope. The rubric's stated rule stands as the backstop; the absence of a stated guarantee about the harness is a missing assertion about the system, not a defect in the rubric's instructions."
      evidence: "backend-quality.yaml:24-26, 56-59"
  disputed: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| A RUN THAT FAILED A GATE IS UNSUCCESSFUL | 1/1 | L3 |
| categories | 4/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### PROVENANCE
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### WHY THE PREVIOUS ONE DIED
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### THE DESIGN RULE, AND THE TEST FOR ANY FUTURE ANCHOR
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### SCORING
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### KNOWN AND REGISTERED, NOT A SURPRISE TO BE DISCOVERED LATER
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### A RUN THAT FAILED A GATE IS UNSUCCESSFUL
**Verdict:** finding
**Failure:** A gate-failing run that used fewer tokens is fed to the scorer — whether by a harness bug, a manual invocation, or a future pipeline change that bypasses the evaluator-to-scorer handoff. The scorer reads the files, applies the anchors, computes a score, and the run is ranked against passing submissions. The rule says "do not compute a score for it," but nothing in the rubric structurally prevents it: less-important rules (test-quality null, change-focus null) get `precondition` fields, while the "single most important rule in the business case" gets a comment with no precondition at all. Reviewer A says evaluator.sh handles this upstream so the comment is sufficient documentation; Reviewer B says the rubric gives its most important rule weaker structural support than its least important one, and if the upstream gate ever fails to filter, there is no backstop.
**Layer of the implied fix:** L3
**Anchor:** "Do not compute a score for it in order to rank it against passing runs. This is the single most important rule in the business case."

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

### categories

#### architecture-consistency
**Verdict:** finding
**Failure:** A submission adds a new exception class extending `ApiException` in package `com.unityinflow.sample.api` — say `ShipmentAlreadyConfirmedException` — and throws it from the controller. Score 1 requires "a new exception type that is not imported from `com.unityinflow.sample.api`" — this one IS from that package, so score 1 does not apply. Score 2 requires "an existing `ApiException` subclass" — this one is new, not existing, so score 2 does not apply. The submission is unscorable. Reviewer A says "it's imported from the right package and extends ApiException, so it follows the convention — score 2"; Reviewer B says "score 2 says *existing*, and this is a new type the baseline doesn't have — score 1."
**Layer of the implied fix:** L3
**Anchor:** "a new exception type that is not imported from `com.unityinflow.sample.api`" (score 1) vs. "an existing `ApiException` subclass imported from `com.unityinflow.sample.api`" (score 2)

#### maintainability
**Verdict:** finding
**Failure:** A submission uses `when (shipment.status)` as a *statement* (not assigned, not returned), covering three of five enum constants, with no `else` branch. In Kotlin a `when` statement compiles without exhaustiveness. A new `ShipmentStatus` constant compiles silently and takes no path at all — the same risk the rubric penalises at score 0. But score 0 requires "an `if` / `else if` / `else` chain, or a `when` carrying an `else` branch" — this has neither. Score 1 requires "an exhaustive `when`" — this is not exhaustive. Score 2 requires "one exhaustive `when`" — same. The submission falls outside all three anchors. Reviewer A says "the risk is identical to score 0, so call it 0"; Reviewer B says "no anchor names a non-exhaustive `when`-as-statement, so it's unscorable."
**Layer of the implied fix:** L3
**Anchor:** "The status decision is an `if` / `else if` / `else` chain, or a `when` carrying an `else` branch." (score 0)

#### test-quality
**Verdict:** finding
**Failure:** A test file exercises confirm twice and asserts the second response (clause A✓), re-reads persisted state through a separate `get(...)` (clause B✓), but no refusal test asserts `$.error.code` — every refusal assertion is a status code only (clause C✗). Score 1 requires "one of the two behaviours the ticket names in bold is missing" — neither A nor B is missing, so score 1's condition is not met. Score 2 requires "all three hold" — C does not. The submission is unscorable. Reviewer A says "neither named behaviour is missing, so it's not a 1; not all three hold, so it's not a 2 — null"; Reviewer B says "it's close to 2, the missing piece is a single assertion, give it 1." The third clause (error-code assertion) appears only in the score-2 anchor, not in score 1, so any submission satisfying A and B but not C has no anchor that describes it.
**Layer of the implied fix:** L3
**Anchor:** "one of the two behaviours the ticket names in bold is missing: the repeat is not exercised by a SECOND call to confirm, or the persisted state is never re-read" (score 1) vs. "All three hold ... at least one refusal asserts the envelope's `$.error.code`" (score 2)

#### change-focus
**Verdict:** finding
**Failure:** A submission's auto-formatter reorders the import block — moving existing imports around, adding blank lines — but no method the ticket did not name differs from the baseline. The imports confirm requires are present, but the reordering changed imports confirm does NOT require. Score 0 requires "two or more methods ... differ" — no methods differ. Score 1 requires "exactly one method ... differs" — no methods differ. Score 2 requires "Every method the ticket did not name is character-identical" (true) AND "Only `confirm`, and the imports it requires, differ" (false — extra import-line differences exist). The submission is between 1 and 2. Reviewer A says "methods are identical, the import shuffle is cosmetic — score 2"; Reviewer B says "score 2's second sentence is violated by the extra import differences, and no method differs for score 0 or 1 — unscorable."
**Layer of the implied fix:** L3
**Anchor:** "Every method the ticket did not name is character-identical to the baseline. Only `confirm`, and the imports it requires, differ." (score 2)

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The artifact explicitly dropped `functional-correctness` and `requirement-completeness` for this reason. `architecture-consistency` measures the *mechanism* (throw via ApiException vs. construct ApiError) while the gate measures the *outcome* (correct error response) — related in intent but not a duplicate. The separation is clean.
- **Which single section would two reviewers diverge on most, and by how much?** `test-quality`, by a full point. The two-vs-three clause gap (score 1 names two behaviours, score 2 requires three) produces a concrete submission shape — A✓ B✓ C✗ — that one reviewer scores 1 and another nulls. The `architecture-consistency` new-exception-type gap is the runner-up; it would split reviewers by a point on a different submission shape.
- **What did the artifact not say that it needed to say?** It never specifies what the scorer should do when a submission falls *between* two anchors — return null, pick the lower score, or pick the higher. The scoring formula handles explicit nulls (precondition-driven) but has no policy for gap-driven nulls. Four of the artifact's own anchors have boundary gaps that produce such submissions, and the scorer's contract (emit null rather than guess) is stated for the *anchor-undecidable* case but not for the *anchor-absent* case. The artifact also does not say whether the harness prevents gate-failing runs from reaching the scorer — it says evaluator.sh executes at L2, but it does not confirm that the scorer's input is filtered by gate results, leaving its most important rule dependent on an enforcement step it cannot see and does not describe.
