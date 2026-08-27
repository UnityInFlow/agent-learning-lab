# opencode review — E-001-rubric-null-rate

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
reviewed_utc:    20260827T133815Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  c6eff7bec75a
lab_head:        7839386
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: The record is honest about its two acknowledged blockers and correctly registers 24 as the denominator, but it has three internal contradictions that would cause two readers to reach different verdicts on identical data — the exact failure mode the artifact itself names and tries to prevent.
  blocking:
    - reason: The Question says "five submissions" but the cell-boundary paragraph and Decision rule use 4 × 6 = 24. The artifact's own MDE/decision-rule prose catches the exact failure ("on 8 observed nulls that is 33% or 40%, and two reviewers reading different sections first reach opposite verdicts on identical data. `lab-acceptance` caught it, blocking, on 2026-08-27") and credits `lab-acceptance` for catching it, but the Question is not corrected.
      wrong_action: A reader who reads the Question first computes denominator = 4 × 5 = 20; a reader who reads the Decision rule uses 24. On 8 observed nulls that is 40% vs 33%, and the artifact itself says this flips a verdict. The author fixed it in one place and left it standing in the other.
      anchor: "Applied to five submissions that all pass every gate, does the four-category rubric produce scores that differ between fixtures"
      evidence: experiments/E-001-rubric-null-rate.md:31
    - reason: The evidence table row 5 says "no `known-good` to compare against. Each fixture is scored in isolation," but Decision B (also in the artifact, line 82) attaches `known-good` as a baseline. The table is labeled "Recorded observations from the runs in `findings/opencode/`, not forecasts" but uses present tense to describe the mechanism, and the contradiction is not flagged.
      wrong_action: A reader who trusts the evidence table as the current mechanism applies the Exclusions hunting rule to a `known-good` citation, drops the cell from the denominator, and computes a different null rate than a reader who reads Decision B as binding.
      anchor: "The attachment set is `*.kt` under the fixture — nothing else. No diff, no test runner, no evaluator output, no `known-good` to compare against. Each fixture is scored in isolation"
      evidence: experiments/E-001-rubric-null-rate.md:67-68
    - reason: The Decision rule's KEEP and INCONCLUSIVE thresholds sit in an unadopted TODO ("Suggested shape, not an answer"), but the note at the bottom of the same section uses INCONCLUSIVE as if it were registered ("INCONCLUSIVE is reserved for nulls concentrated in one *category across fixtures*"). The arithmetic table registers REJECT for specific outcomes but registers nothing for the common partially-null case.
      wrong_action: For a fixture with 2 null cells and 2 scored cells, nulls concentrated in one category: a reader who reads the note as binding files INCONCLUSIVE; a reader who reads the TODO as unadopted finds no registered verdict and files the run as uninterpretable. Both readings are defensible from different parts of the same section, and they are filed differently.
      anchor: "INCONCLUSIVE is reserved for nulls concentrated in one *category across fixtures*, which indicts that category's anchors rather than the rubric."
      evidence: experiments/E-001-rubric-null-rate.md:274-279
  non_blocking:
    - reason: The four rubric categories are never named in one consolidated list. They appear scattered across the Evidence section and the Decision B paragraph, so a reader has to assemble the full set from context to make the 24-cell denominator meaningful.
      evidence: experiments/E-001-rubric-null-rate.md:67-91
    - reason: The cross-cutting concern about `test-quality` duplicating a gate is real but is a question about the unwritten four-category rubric, not about this record; the artifact explicitly states the gates own functional-correctness and requirement-completeness and the four categories are quality dimensions, so the record's framing is defensible.
      evidence: experiments/E-001-rubric-null-rate.md:220
  disputed: []
  needed_to_decide: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Question | 1/1 | L3 |
| Hypothesis | 1/1 | L3 |
| Decision rule | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

# Experiment E-001 — does the four-category rubric decide anything?

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The status block lists two blockers (rubric unwritten, predictions empty) and one cleared. The counts are consistent — two remain. The cleared item (benchmarks#20) is correctly struck through with the fix cited.

---

### Question

**Verdict:** finding
**Failure:** The opening sentence says "Applied to **five** submissions that all pass every gate," but the cell-boundary paragraph in the same section says "Twenty-four `null`s is a result" — 24 = 4 × 6, which implies six fixtures, not five. The Predictions section corrects to "Six, not five," and the Decision rule says "The denominator is 24 — 4 categories × 6 fixtures." The artifact itself caught and fixed this exact 20-vs-24 ambiguity in the MDE table (line 229: "on 8 observed nulls that is 33% or 40%, and two reviewers reading different sections first reach opposite verdicts on identical data") but left the same discrepancy standing in the Question. Failure scenario: a reviewer reads only the Question, calculates the denominator as 4 × 5 = 20, and on 8 observed nulls computes 40% and calls REJECT. A second reviewer reads the Decision rule, uses 24, computes 33% and calls INCONCLUSIVE. The artifact's own words describe this as flipping a verdict on identical data.
**Layer of the implied fix:** L3
**Anchor:** "Applied to five submissions that all pass every gate, does the four-category rubric produce scores that differ between fixtures"

---

### Hypothesis

**Verdict:** finding
**Failure:** The hypothesis body is an empty TODO — acknowledged as a blocker, not a finding. The finding is in the "Evidence already on file" table. Row 5 says: "The attachment set is `*.kt` under the fixture — nothing else. No diff, no test runner, no evaluator output, no `known-good` to compare against. Each fixture is scored in isolation." This is written in present tense as a fact about the mechanism. But Decision B (line 82) attaches `known-good` as a baseline, so the attachment set now includes `known-good`'s files and fixtures are no longer scored in isolation. The evidence table is labeled "Recorded observations from the runs in `findings/opencode/`, not forecasts" — historical observations — but the row uses present tense to describe the mechanism, not past tense to describe a run. Failure scenario: the scorer cites a `known-good` file in its evidence for a fixture. Reviewer A reads the evidence table as current mechanism state ("no `known-good` to compare against"), applies the Exclusions rule for hunting ("cites a file not in the attachment set"), and drops the cell from the denominator. Reviewer B reads Decision B ("`known-good` is attached as a baseline"), treats the citation as within the attachment set, and counts the cell. The denominator differs by 1, and on a close null rate the verdict flips.
**Layer of the implied fix:** L3
**Anchor:** "The attachment set is `*.kt` under the fixture — nothing else. No diff, no test runner, no evaluator output, no `known-good` to compare against. Each fixture is scored in isolation"

---

### Predictions

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — the artifact lists this as blocker 2 and says "Do not run `opencode-score.sh` until they are filled in and committed." The TODOs are explicit. No ambiguity in what is written.

---

### Independent variable

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"Each of the five fixtures differs from `known-good` on exactly one dimension" — five that vary, plus the reference, consistent with the six scored. The "one thing" principle is clearly stated.

---

### How the treatment is delivered — and proved

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Layer assignments checked: preflight assertion is L2 (opencode-score.sh executes and fails on `--dir` repoint — names the thing that runs). Control assertion is L1 through the script (no flag reaches `--continue`, so the bad state is unrepresentable through the registered mechanism) and L3 outside it (hand-running `opencode run --continue` bypasses, nothing detects it). Output guard is L2 (classify-score-output.sh executes, returns exit codes, CI runs verify-score-output-classifier.sh). All three are correctly labeled.

---

### Controlled variables

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Two unchecked boxes (rubric sha, blind scores) are known blockers. The model pin notes the override risk (`LAB_REVIEW_MODEL`). The hang-warning for three models is specific and actionable.

---

### Runs

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Repetition count is blank — known blocker. The 2/12 critic disagreement is correctly framed as a reason to ask about scorer variance, not an answer for it. The distinction between critic variance (under-reporting) and scorer variance (cell flipping) is clear.

---

### Minimum detectable effect

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

MDE table cells are empty — known blocker. The TODO notes the 0–2 scale with weights 35/25/25/15 and asks for the per-category normalised contribution. Not yet filled, acknowledged.

---

### Deterministic evaluation

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

"This experiment has no deterministic evaluator, by design" is the correct framing. The note that benchmarks#21 made gate-passing a registered `run_case` in CI (executed, not asserted) is specific and verifiable.

---

### Exclusions

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

The narrowing from "exits 0 with no scores" to "exits 1 or 4 only" is explained with the reason (it would have discarded the wholesale-undecidable signal). The empty-then-repeat protocol is clear: first empty is not a datum, re-run; second empty is REJECT; empty-then-sheet is infrastructure. The hunting exclusion is precise ("cites a file not in the attachment set"). The interaction with the stale evidence table is a finding about the evidence table, not about this section — the exclusion rule itself is unambiguous given a correct attachment set.

---

### Decision rule

**Verdict:** finding
**Failure:** The arithmetic table ("What every outcome does to the arithmetic") is registered 2026-08-27 and defines specific outcomes: wholesale-null fixture → REJECT, confirmed-empty → REJECT, declared-error → REJECT, off-contract → drop 4, hunting → drop 1. But the KEEP and INCONCLUSIVE thresholds are in the TODO above, marked "Suggested shape, not an answer" — not adopted. The table registers REJECT for specific outcomes but registers nothing for the case where a fixture has some nulls and some scores (the common case). The note at the bottom references INCONCLUSIVE ("INCONCLUSIVE is reserved for nulls concentrated in one category across fixtures"), a term defined only in the unadopted TODO. Failure scenario: a fixture produces 2 null cells and 2 scored cells, with the nulls concentrated in one category. Reviewer A reads the registered table, finds no REJECT condition fires (not all remaining cells null), and concludes no registered verdict applies — the run is uninterpretable. Reviewer B reads the note about INCONCLUSIVE, applies it (nulls concentrated in one category), and files INCONCLUSIVE. Both are defensible from different parts of the same section.
**Layer of the implied fix:** L3
**Anchor:** "INCONCLUSIVE is reserved for nulls concentrated in one *category across fixtures*, which indicts that category's anchors rather than the rubric."

---

### The procedure, from #21

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Four steps, ordered. Step 2 (blind scores before reading scorer output) is the integrity gate and is explicit. The procedure assumes #21 has landed, which is blocker 1 — acknowledged.

---

### Observed telemetry

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section.

---

### Results

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section.

---

### Which predictions held

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section.

---

### Failure analysis

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section.

---

### Sanity checks

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section. The three checkboxes are the right three (dramatic number, flattering number, suspicious agreement).

---

### Decision

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section.

---

### Follow-up

**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

Empty by design — post-run section.

---

### Cross-cutting

- **Does any scoring category duplicate a pass/fail gate?** Cannot be verified — the four-category rubric does not exist yet (blocker 1). The artifact states the old seven-category rubric duplicated gates (functional-correctness, requirement-completeness) and that the replacement drops them. Whether the new categories (architecture-consistency, maintainability, test-quality, change-focus) duplicate any gate is uncheckable until lab#21 lands. The CLAUDE.md says the gates own functional-correctness and requirement-completeness, and the four categories are quality dimensions — but "test-quality" scoring fixtures that pass a gate without requiring tests is adjacent enough that two reviewers could disagree on whether it restates the gate.

- **Which single section would two reviewers diverge on most, and by how much?** The Decision rule. The registered table defines arithmetic and some REJECT conditions; the KEEP/INCONCLUSIVE thresholds are in an unadopted TODO; and the note at the bottom uses INCONCLUSIVE as if it were in force. A reviewer who reads the table as the complete rule reaches "no verdict" for partially-null fixtures. A reviewer who reads the note as binding reaches INCONCLUSIVE. The divergence is not a hair-split — it is the difference between "this run produced no registered verdict" and "this run is INCONCLUSIVE," which are filed differently and trigger different follow-up.

- **What did the artifact not say that it needed to say?** The four categories being scored are never named in one place. They appear scattered: "change-focus" and "test-quality" in the Evidence section, "architecture-consistency" and "maintainability" in the Decision B paragraph. A reader who does not read CLAUDE.md cannot assemble the full category list from the experiment record alone. The 24-cell denominator is meaningless without knowing what the 4 categories are, and the artifact never lists them.
