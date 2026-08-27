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
reviewed_utc:    20260827T133527Z
runs:            1           # independent sessions; findings unioned below
artifacts:
  - path: experiments/E-001-rubric-null-rate.md
    sha:  4f3f1e13593f
lab_head:        7435f16
lab_dirty:       true
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-001-rubric-null-rate.md
  verdict: REJECT
  summary: The artifact itself declares itself unready (line 7) with empty Predictions, empty Hypothesis mechanism, no runs count, no MDE, and an unbounded gap in the arithmetic table that the author must resolve before this record can be read as a valid experiment.
  blocking:
    - reason: Predictions section is empty — the three required predictions (null rate, discrimination, agreement) are TODOs at lines 106, 109, 112. The artifact's own front-matter (line 7) and the run-block rule (line 9-10) state this is the blocker.
      wrong_action: A reader treats this record as run-ready, commits, and runs `opencode-score.sh` against empty predictions — the artifact's own header warns this "voided nine runs" (line 4-5) when it happened before.
      anchor: "**Status: unregistered. One blocker remains, and it is the predictions.**"
      evidence: experiments/E-001-rubric-null-rate.md:7
    - reason: Hypothesis body is empty (line 48 TODO) and asks for a *mechanism*, which is a distinct deliverable from the numbered Predictions. The "interestingly wrong" guard at line 49 ("A hypothesis without a mechanism cannot be interestingly wrong") is silently unmet.
      wrong_action: A reader who runs the experiment fills the three numeric predictions but leaves the mechanism unwritten, so any post-hoc failure cannot be distinguished from "wrong by mechanism the author never stated" from "wrong despite what the author said would happen."
      anchor: "<!-- TODO — yours. What do you predict, and BY WHAT MECHANISM? A hypothesis without a mechanism cannot be interestingly wrong. -->"
      evidence: experiments/E-001-rubric-null-rate.md:48
    - reason: Decision-rule arithmetic table has no row for "all *remaining* cells null after exclusion." The hunting rule (line 250) drops 1 cell; the wholesale-null rule (line 247) requires 4 nulls. A fixture with 3 nulls and 1 hunted cell yields two reader-verdicts on identical data.
      wrong_action: Two reviewers tally the same run differently — one applies REJECT (+4/4) by intent, the other does not (+3/3) by text — so the Decision section cannot produce a stable verdict and the artifact's whole purpose (a registered decision rule) is unmet.
      anchor: "| All 4 cells `null` for a fixture | +4 | counts | **REJECT** for that fixture |"
      evidence: experiments/E-001-rubric-null-rate.md:247
    - reason: Three more pre-run slots are unfilled: repetitions/total blank (line 154), MDE table fully empty (lines 172-173), rubric sha unchecked (line 146) — and the template's own note at line 154-163 says a single-run scorer's variance is unmapped.
      wrong_action: A reader runs one score per fixture without registering `n`, then later compares cell values across fixtures as if the scorer were proven repeatable — inheriting exactly the kind of unmeasured instrument variance this lab keeps re-learning about.
      anchor: "Repetitions per fixture: ____ · Total: ____"
      evidence: experiments/E-001-rubric-null-rate.md:154
  non_blocking:
    - reason: Style, section ordering, and the cleared-benchmark narrative (line 12-15) are well-documented and not load-bearing for run-readiness.
      evidence: experiments/E-001-rubric-null-rate.md:12
    - reason: Post-run sections (Observed telemetry, Results, Which predictions held, Failure analysis, Decision, Follow-up) are correctly labelled as filled in after the runs (line 280).
      evidence: experiments/E-001-rubric-null-rate.md:280
  disputed: []
  needed_to_decide: []
```
## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

| Section | Flagged | Layer of implied fix |
|---|---|---|
| Experiment E-001 — does the four-category rubric decide anything? | 1/1 | L3 |
| Hypothesis | 1/1 | L3 |
| Decision rule | 1/1 | L3 |


---

## Run 1 of 1


> lab-critic · glm-5.2

### Experiment E-001 — does the four-category rubric decide anything?
**Verdict:** finding
**Failure:** The status block at line 7 says "One blocker remains, and it is the predictions." But the Hypothesis section (line 48) is also empty — its TODO asks for a prediction with a mechanism, which is a distinct deliverable from the numbered Predictions at line 94. Two reviewers preparing this experiment for a run would diverge: one treats "one blocker" literally and fills only the Predictions section, leaving the Hypothesis TODO empty; the other reads the Hypothesis as a separate required section and counts two blockers. The first reviewer runs with a missing mechanism-level prediction and the experiment's "interestingly wrong" guard (line 49: "A hypothesis without a mechanism cannot be interestingly wrong") is silently unmet.
**Layer of the implied fix:** L3
**Anchor:** "One blocker remains, and it is the predictions."

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** finding
**Failure:** See the front-matter finding — the Hypothesis body is empty (TODO at line 48) while the Evidence sub-section below it is filled. The status block does not count this as a blocker. A reviewer who reads only the status block before deciding whether the record is run-ready would miss that the mechanism-level prediction is unwritten. The Evidence table (lines 55–63) is labeled "read before predicting, do not treat as a prediction," so it cannot substitute for the empty hypothesis body.
**Layer of the implied fix:** L3
**Anchor:** "<!-- TODO — yours. What do you predict, and BY WHAT MECHANISM? A hypothesis without a mechanism cannot be interestingly wrong. -->"

### Predictions
**Verdict:** no finding

### Independent variable
**Verdict:** no finding

### How the treatment is delivered — and proved
**Verdict:** no finding

### Controlled variables
**Verdict:** no finding

### Runs
**Verdict:** no finding

### Minimum detectable effect
**Verdict:** no finding

### Deterministic evaluation
**Verdict:** no finding

### Exclusions
**Verdict:** no finding

### Decision rule
**Verdict:** finding
**Failure:** The arithmetic table (line 246) says "All 4 cells `null` for a fixture → +4, counts, REJECT for that fixture." The hunting exclusion (line 250) says a cell that went hunting "drops that 1" from the denominator. Consider a fixture where one cell went hunting and the other three came back `null`. Reviewer A reads the wholesale-null rule literally: "all 4 cells null" is not met because one cell is excluded, not null — no REJECT, the fixture contributes 3 nulls over a 3-cell denominator. Reviewer B reads the intent: 3 of 3 countable cells are null, which is wholesale undecidability for that fixture — REJECT, +4 nulls over 4. On identical data the two reach different verdicts and different denominators. The table has no row for "all *remaining* cells null after exclusion."
**Layer of the implied fix:** L3
**Anchor:** "| All 4 cells `null` for a fixture | +4 | counts | **REJECT** for that fixture |"

### The procedure, from #21
**Verdict:** no finding

### Observed telemetry
**Verdict:** skipped
**Failure:** n/a — post-run section, intentionally empty at pre-run stage.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** skipped
**Failure:** n/a — post-run section, intentionally empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** skipped
**Failure:** n/a — post-run section, intentionally empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** skipped
**Failure:** n/a — post-run section, intentionally empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** no finding

### Decision
**Verdict:** skipped
**Failure:** n/a — post-run section, intentionally empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow-up
**Verdict:** skipped
**Failure:** n/a — post-run section, intentionally empty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? The experiment record does not list the rubric's four categories by name; it references `backend-quality.yaml` by sha. The Deterministic evaluation section states the gates already decided pass/fail for all six and all six passed, and the rubric "only scores gate-passing submissions" (line 208). The CLAUDE.md context says `functional-correctness` and `requirement-completeness` were dropped from the rubric because the gates own them — but this is not stated inside the artifact. A reviewer reading only this record cannot confirm no category duplicates a gate; they would need to open the rubric file. Not a finding against this artifact, but a gap a reader should be told about.
- Which single section would two reviewers diverge on most, and by how much? The Decision rule — specifically the hunting × wholesale-null interaction. The divergence is not subtle: on a fixture with 3 nulls and 1 hunting exclusion, one reviewer applies REJECT (+4 over 4), the other does not (+3 over 3). That is a verdict-level flip, not a rounding difference.
- What did the artifact not say that it needed to say? Two things: (1) how the wholesale-null REJECT rule behaves when one or more cells in that fixture are excluded rather than null; (2) whether the empty Hypothesis body is a run-blocking gap or is subsumed by the Predictions section. Both are ambiguities that two careful readers would resolve differently on identical text.
