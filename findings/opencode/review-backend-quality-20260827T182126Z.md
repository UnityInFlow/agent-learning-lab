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
reviewed_utc:    20260827T182126Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  7aec2ab585bb
lab_head:        a3db760
lab_dirty:       true
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

acceptance:
  artifact: /Users/jirihermann/Documents/workspace-1-ideas/ai-agents/ai-learning/agent-learning-lab/benchmark/rubrics/backend-quality.yaml
  verdict: ACCEPT
  summary: A four-category scoring rubric whose procedure (precondition-first, then the ladder at lines 63–65) is explicitly stated and whose L3 limitations are honestly disclosed; the two line-level findings name real seams but the artifact's stated order and full disclosure bound them to non-blocking concerns.
  blocking: []
  non_blocking:
    - reason: "Anchor 0 ('Every assertion is a status code. No assertion reads a response body, and no assertion re-reads state through a second request.') is a universal quantifier vacuously true on the empty assertion set. A reader applying only the ladder at lines 63–65 returns 0 on no-test-file inputs; a reader applying the full procedure (line 72 plus line 139) returns null. The artifact flags L3-ness at line 138 but does not call out the vacuous-truth seam, so a less careful reader can enter the ladder without the precondition check. Three of five gate-passing variants are affected."
      evidence: "benchmark/rubrics/backend-quality.yaml:63-65, :138-141"
    - reason: "The artifact calls the gate-failure exclusion 'the single most important rule in the business case' (line 94) and then discloses that `opencode-score.sh` will compute a number on `known-bad-*` anyway because the filter lives in E-001's Exclusions document (L3) and the L2 scorer-side refusal 'does not exist' (lines 96–100). The disclosure is honest, but the rubric produces a number in its own units on the input class it names."
      evidence: "benchmark/rubrics/backend-quality.yaml:91-100"
  disputed:
    - finding: "The precondition and the ladder contradict each other on the no-test-file input, and the artifact does not state which takes precedence."
      why: "Line 72 states the precedence explicitly: '`null` keeps exactly two jobs: a precondition failed (no test file, no baseline), or the evidence does not let you decide whether the 0 condition holds. Never as a shrug.' The artifact does state the order; the seam is in a reader missing line 72, not in the artifact's content."
    - finding: "The ladder actively produces 0 because anchor 0 is a universal quantifier over the empty set."
      why: "Only when applied without the precondition. The artifact's stated procedure is precondition-first, ladder-second. On no-test-file inputs the ladder is not entered. The finding conflates the ladder's output in isolation with the rubric's procedure as written."
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| categories | 2/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

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

**Verdict:** finding
**Failure:** A submission with no test file (three of the five gate-passing variants). Scorer A applies the ladder from lines 63–65: anchor 0 says "Every assertion is a status code. No assertion reads a response body, and no assertion re-reads state through a second request." With zero assertions all three sentences are vacuously true, the 0 condition holds, the ladder returns 0. Scorer B reads the precondition on line 139 ("No file under src/test/ → score: null … Never 0") and returns null. The two scores diverge: 0 pulls the category into the denominator as a zero; null excludes it from both sums. The same submission gets either a four-category total depressed by a vacuous 0 or a three-category total with the category absent — different numbers, different comparability class. The artifact acknowledges the precondition is L3 ("nothing executes to reject a 0 here," line 138) but frames the risk as the scorer *failing to reject* a 0. The actual risk is stronger: the ladder *actively produces* 0, because anchor 0 is a universal quantifier over an empty set. The precondition and the ladder contradict each other on this input, and the artifact does not state which takes precedence — it says null is checked first (line 72) but that check is itself the L3 thing that can be skipped.
**Layer of the implied fix:** L3
**Anchor:** "Every assertion is a status code. No assertion reads a response body, and no assertion re-reads state through a second request. Cite the assertion list." (line 141)

---

**Verdict:** finding
**Failure:** `opencode-score.sh` is handed a gate-failing submission (the artifact names `known-bad-*` as the class, line 98). The rubric scores it — say architecture 1, maintainability 2, test-quality null, change-focus 2 — and emits ~77. That number is reported beside passing runs' scores and a reader ranks them. The artifact states "do not compute a score for it in order to rank it against passing runs" (line 93) and "the single most important rule in the business case" (line 94), then states "AND NOTHING HERE ENFORCES IT" (line 96) and labels the guard L3 (line 99). Two reviewers diverge: one treats the rubric as valid because it discloses the gap; the other treats a rubric whose central validity condition is an unenforced L3 instruction as defective on the input class it explicitly names. The disclosure is honest, but the rubric will produce a number wearing this rubric's units on exactly the input it says must never be scored.
**Layer of the implied fix:** L3
**Anchor:** "opencode-score.sh will score any directory it is handed, known-bad-* included. The filter lives in E-001's Exclusions, which is a document. L3. The L2 version is the scorer refusing a target that is not a registered gate-passing run_case; it does not exist." (lines 98–100)

---

**Verdict:** no finding
**Failure:** n/a — the four gap examples (lines 47–57) are each closed to 1 by the ladder rule (lines 63–65), and the ladder is a total partition. The architecture gap (new `ApiException` subclass in `com.unityinflow.sample.api`) fails anchor 2's "existing" clause and anchor 0's literal requirement, landing at 1; the maintainability gap (non-exhaustive `when`, no `else`) fails both 0 and 2, landing at 1; the test-quality gap (repeat + re-read but no `$.error.code` assertion) fails 0 (a body assertion exists) and 2 (third clause absent), landing at 1; the change-focus gap (reordered unrelated import, all named methods identical) fails 0 (needs two or more *methods*) and 2 (an import `confirm` does not require differs), landing at 1. The residual-anchor text is explicitly an illustration (lines 67–70), not the definition, so a shape the illustration does not picture still scores 1 by the ladder. No two faithful scorers diverge on these.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** No. The artifact dropped `functional-correctness` (25) and `requirement-completeness` (20) precisely because they restated gates. The four survivors score constructs the gates do not check: `architecture-consistency` scores *how* a refusal is produced (thrown `ApiException` vs hand-built `ApiError`), not *whether* the right status returns; `test-quality` scores assertion depth, not endpoint behavior; `maintainability` scores `when` exhaustiveness, not runtime correctness; `change-focus` scores diff scope, not behavior. The artifact does not explicitly verify the four survivors against the gate set — it only argues the two it dropped — but on the evidence the separation holds.

- **Which single section would two reviewers diverge on most, and by how much?** `test-quality`, by a full score point (0 vs null) on three of five gate-passing variants. The vacuous-truth finding above is not a seam in the residual; it is a contradiction between the ladder and the precondition on the most common input shape in the fixture (60% of gate-passing variants have no test file). The gate-failure rule is a close second, but there the divergence is about whether the rubric is defective at all, not about a specific score.

- **What did the artifact not say that it needed to say?** It did not state the precedence between a category's precondition and the ladder when they conflict on the same input. Line 72 says null is checked when "a precondition failed," implying precondition-first, but the precondition is L3 and the ladder is the defined procedure — a scorer that applies only the ladder (the thing the artifact spent 30 lines making total and unambiguous) gets a different answer than a scorer that applies the precondition. The artifact needed to say that the ladder is only entered after the precondition passes, and it needed to flag that anchor 0's universal quantifier is vacuously true on the empty set — which is exactly the input the precondition guards. It said "nothing executes to reject a 0"; it did not say "the ladder asserts 0."
