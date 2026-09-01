# opencode review — backend-quality

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
  panel:         # every family is a registered variable; changing the set
    - codex
    - ollama-cloud/deepseek-v4-pro
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.21
reviewed_utc:    20260828T085728Z
runs:            2           # independent sessions; findings unioned below
families:        2           # distinct models; the recurrence denominator
artifacts:
  - path: benchmark/rubrics/backend-quality.yaml
    sha:  396e1799eb2b
lab_head:        5cfbd14
lab_dirty:       true
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: benchmark/rubrics/backend-quality.yaml
  verdict: ACCEPT
  summary: The four-category rubric is internally consistent, the ladder rule at lines 62–66 is total and matches the "Anchor 1 is an illustration" rule at lines 67–70, the previous rubric's two structural defects (gate-restating anchors, undecidable evaluator citations) are both removed, and the open test-coverage limitation is named in the file rather than hidden.
  blocking: []
  non_blocking:
    - reason: The precondition for test-quality treats "a test file that makes no assertion at all" as a null trigger, but the file never defines which test constructs count as assertions; a test using only MockK `verify(...)` would be classified differently by a strict "response/assert* only" reader than by a reader applying Kotlin testing convention. Worth tightening before the next rubric revision, but the artifact targets a Kotlin-fluent panel and MockK `verify` is conventionally an assertion.
      evidence: benchmark/rubrics/backend-quality.yaml:168
    - reason: "What counts as a refusal" for architecture-consistency is defined in the comment block (lines 124–131) rather than in anchor 0 or anchor 2, even though both anchors rest the score on the term. A scorer who only reads the anchors has no definition to apply; a scorer who reads the whole rubric does. Moving the definition into the anchor text would close the gap, but the definition is present in the artifact and the rubric's own philosophy (the long preamble, the ladder-rule commentary) assumes whole-file reading.
      evidence: benchmark/rubrics/backend-quality.yaml:124-131,134,136
    - reason: Test-quality anchor 1 is framed as a hard condition ("Any assertion reads a response body, and at least one clause of 2 is absent") while the other three categories' anchor 1 is framed as "typically." A reader applying the text literally to a status-code-only re-read could find no anchor that reaches; the ladder rule still scores it 1, but the framing inconsistency invites confusion. The ladder rule at lines 62–66 and the illustration-not-definition rule at lines 67–70 are the contract and would resolve a careful read.
      evidence: benchmark/rubrics/backend-quality.yaml:159,171
  disputed:
    - finding: "architecture-consistency: 'refusal' is undefined in the anchors, so a submission using `check(...)` for state validation will be scored 1 by one faithful scorer and 2 by another"
      why: The comment block at lines 124–131 defines "Any path that ends the request without the success response — including one taken by `check(...)`, `require(...)`, `!!` or a bare `throw`" and the rubric is plainly read as a unit (the design rule at lines 28–38, the ladder-rule preamble at lines 40–71, the per-category commentary all live in the same file as the anchors). A faithful scorer reads the whole file; the divergence the finding describes only arises for a scorer who reads the anchors and ignores the comment, which is not the rubric's stated mode of use.
    - finding: "maintainability anchor 1's clause 'a `when` that is neither exhaustive nor carries an `else`' cannot be satisfied by any compiling Kotlin program, so the clause is unreachable"
      why: The artifact is explicit at lines 67–70 that "Anchor 1's text is therefore an ILLUSTRATION of the residual, not its definition. Read it as the most common shape of 'neither the defect nor the full convention', and score 1 for any other shape that is also neither." The ladder rule at lines 62–66 is the contract; the unreachable clause being unreachable is harmless because every "neither 0 nor 2" case is caught by "1 otherwise" regardless of which clauses of the illustration happen to hold. The finding reads anchor 1 as a definition despite the artifact saying it is not one.
    - finding: "change-focus: a moved blank line inside a method body could be classified as invisible whitespace (anchor 0) or as a difference (anchor 1)"
      why: Anchor 0's enumeration of "invisible whitespace" is three specific items — trailing spaces, line-ending style, trailing newline at EOF — and a blank line inside a method body is none of those three; the enumeration is exclusive by the natural reading. Anchor 1 then explicitly lists "a moved blank line" as a difference, which is the consistent reading: blank lines are not in the anchor-0 list, so anchor 1's example controls. The finding's "Scorer A classifies it as invisible whitespace" requires reading the three-item list as illustrative rather than exhaustive, but anchor 0's phrasing ("Those three are never a difference under this category, at any anchor") makes the list exclusive.
    - finding: "test-quality anchor 1's hard condition means a status-code-only re-read (state re-read but no body asserted) finds no anchor that reaches it, leading to literal-null confusion"
      why: Same resolution as the maintainability dispute: lines 67–70 make anchor 1 an illustration, the ladder rule catches every "neither 0 nor 2" case as 1, and a careful scorer applies the ladder rather than testing the literal text of anchor 1 against the submission. The finding identifies a real framing inconsistency (test-quality anchor 1 is the only residual stated as a hard condition) but overstates the consequence because the ladder rule is the contract and is the rule scorers must apply.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 46s |
| ollama-cloud/deepseek-v4-pro | ok | 99s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 independent families (2 run(s))

How many DIFFERENT model families flagged each section — not how often one model
repeated itself. A section flagged twice by the same family counts once, so a chatty
model cannot outvote the panel.

**1/2 is not weak evidence.** Families find different classes of defect: on
2026-08-28, glm-5.2 found gaps in the anchor ladder and an anchor citing evidence that
is not attached, while deepseek-v4-pro found four textual ambiguities in the same file.
Neither saw the other's list. A 1/2 row is one lens holding something the others do
not — read it first, not last.

| Section | Families | Layer of implied fix |
|---|---|---|
| categories | 1/2 | L3 |
| Cross-cutting | 1/2 | L3 |
| architecture-consistency | 1/2 | L3 |
| maintainability | 1/2 | L3 |
| test-quality | 1/2 | L3 |
| change-focus | 1/2 | L3 |


---

## Run 1 of 2 — codex

### version
**Verdict:** no finding
**Failure:** No concrete failure scenario found for the declared version.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### task
**Verdict:** no finding
**Failure:** No concrete failure scenario found for the task identifier.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### scale
**Verdict:** no finding
**Failure:** The scale and the stated residual-selection rule assign 0, 1, or 2 without an uncovered numeric value.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### categories
**Verdict:** finding
**Failure:** A submitted test contains only `verify(exactly = 1) { repository.save(any()) }`. One reviewer treats mock verification as an assertion, passes the precondition, and scores test-quality 1 because neither anchor 0 nor anchor 2 holds. Another treats only response or conventional `assert*` checks as assertions and emits null. If the other three categories score 2, those choices produce totals of 87.5 and 100 respectively.
**Layer of the implied fix:** L3
**Anchor:** a test file that makes no assertion at all → score: null, reason: nothing to grade.

### Cross-cutting
**Verdict:** finding
**Failure:** No scoring category demonstrably duplicates a named pass/fail gate: architecture-consistency, maintainability, test-quality, and change-focus assess properties not stated as evaluator gates. Reviewers would diverge most on test-quality: the mock-verification example yields null versus 1, causing up to a 12.5-point difference when the other categories score 2. The artifact needed to say which executable test constructs count as assertions for the precondition; without that rule, null eligibility is reviewer-dependent.
**Layer of the implied fix:** L3
**Anchor:** n/a


---

## Run 2 of 2 — ollama-cloud/deepseek-v4-pro


> lab-critic · deepseek-v4-pro

### architecture-consistency
**Verdict:** finding
**Failure:** A submission whose missing-shipment branch throws the baseline `ResourceNotFoundException`, but whose state validation is `check(shipment.status == CONFIRMED) { "not confirmed" }` — throwing `IllegalStateException`. Scorer A, reading the comment block's "WHAT COUNTS AS A REFUSAL" (lines 124–131), treats the `check(...)` as a refusal throwing a non-`ApiException` and scores anchor 1. Scorer B, reading only the anchors — where "refusal" is never defined — reserves "refusal" for explicit response branches and scores anchor 2. Divergence: 1 vs 2, on a weight-35 category. The resolution ("It is a refusal") exists only in the comment, not in any anchor, so the definition that decides the score is not part of the scoring text.
**Layer of the implied fix:** L3
**Anchor:** "Every refusal throws an `ApiException` subclass that ALREADY EXISTS IN THE ATTACHED BASELINE — `ResourceNotFoundException` for a missing shipment, `ConflictException` for a state refusal — and no `ApiError` or `ApiErrorBody` is constructed anywhere in the shipment package."

### maintainability
**Verdict:** finding
**Failure:** A submission uses `when (shipment.status)` in STATEMENT position (value discarded) with no `else` and not all enum constants covered. Anchor 0's third case ("a `when` in STATEMENT position") scores 0. Anchor 1's third case ("a `when` that is neither exhaustive nor carries an `else`") scores 1. The ladder rule resolves to 0 (anchor 0 holds first), but a scorer reading anchor 1's text literally scores 1. Divergence: 0 vs 1. Worse, anchor 1's clause is unreachable: a statement-position `when` is always anchor 0, and an expression-position `when` that is neither exhaustive nor carries an `else` does not compile, so it cannot appear in any gate-passing submission. The clause describes a case that cannot be scored.
**Layer of the implied fix:** L3
**Anchor:** "also a `when` that is neither exhaustive nor carries an `else`" (anchor 1) against "a `when` in STATEMENT position — its value discarded, used by nothing" (anchor 0).

### test-quality
**Verdict:** finding
**Failure:** A test file that re-reads persisted state through a second `get(...)` but asserts only status codes on every request — no response body read anywhere. Anchor 0 fails (it re-reads state through a second request). Anchor 2 fails (clause (a) requires the second response's BODY asserted). Anchor 1's text requires "Any assertion reads a response body," which is false here. The ladder rule scores 1, but anchor 1 is the only category whose residual states a hard condition rather than "typically," so a scorer reading anchor 1 literally finds no anchor that reaches this case. Divergence: 1 (ladder rule) vs null/confusion (literal anchor reading). This is a distinct gap from the one the comment registers at lines 52–54, which assumes the repeat's body is asserted.
**Layer of the implied fix:** L3
**Anchor:** "Any assertion reads a response body, and at least one clause of 2 is absent" (anchor 1).

### change-focus
**Verdict:** finding
**Failure:** A submission where one unnamed method differs from the baseline only by a blank line inserted or removed inside its body. Anchor 0 excludes "INVISIBLE WHITESPACE" (trailing spaces, line-ending style, trailing newline at EOF) as "never a difference." Anchor 1 lists "a moved blank line" as a difference. A blank line is whitespace and arguably invisible, so Scorer A classifies it as invisible whitespace (not a difference → anchor 2 if nothing else differs), while Scorer B follows anchor 1's explicit example and scores 1. Divergence: 1 vs 2. The three-item enumeration of "invisible whitespace" does not say whether a blank line is inside or outside the set.
**Layer of the implied fix:** L3
**Anchor:** "anything beyond INVISIBLE WHITESPACE — trailing spaces, line-ending style, a trailing newline at end of file" (anchor 0) against "a moved blank line" (anchor 1).

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The two gate-duplicating categories (`functional-correctness`, `requirement-completeness`) were dropped, and the remaining four score quality dimensions the gates do not own. The comment's own reasoning holds.
- Which single section would two reviewers diverge on most, and by how much? `test-quality`, by the largest margin: the null precondition (null vs 0) is a categorical difference that changes the denominator and the total, and the anchor-1 hard condition adds a second, independent divergence on the body-reading axis. A scorer who ignores the L3 precondition and scores 0 for "no test file" produces a number where another produces null — the two totals are then not even the same measurement.
- What did the artifact not say that it needed to say? (1) The "refusal" definition belongs in the anchors, not only in the comment block — the anchor that depends on it is the one that decides 1 vs 2. (2) Whether a blank line is "invisible whitespace" — the three-item enumeration leaves the boundary to the reader. (3) `test-quality`'s anchor 1 is the only residual stated as a hard condition rather than "typically," breaking the ladder rule's stated contract that anchor 1 is an illustration, not a definition. (4) `maintainability`'s anchor 1 contains a clause that no passing submission can satisfy, which a scorer cannot discover without reasoning about Kotlin's exhaustiveness rules rather than the rubric's own text.

Note: `version`, `task`, and `scale` are trivial metadata and carry no finding; the substantive content is the four categories above.
