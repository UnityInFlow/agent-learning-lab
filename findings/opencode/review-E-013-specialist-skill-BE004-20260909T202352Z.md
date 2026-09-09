# opencode review — E-013-specialist-skill-BE004

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
reviewed_utc:    20260909T202352Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-013-specialist-skill-BE004.md
    sha:  4e1c8d2947b5
    dirty: false
lab_head:        874577c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-013-specialist-skill-BE004.md
  verdict: REJECT
  summary: The registered decision rule's row 0 fires VOID on every BE-004 sheet (it checks for BE-003's rubric sha 396e1799eb2b, but every sheet carries BE-004's 6252778b8472, which the controlled-variables table itself explicitly identifies as "not BE-003's"); the KEEP verdict bypasses this without acknowledgement, and §4 step 10 cites BE-003 results as part of the same KEEP, violating the opening's "no verdict is computed across the two files" declaration under author decision 9.
  blocking:
    - reason: Decision rule row 0 unconditionally VOIDs every sheet of this experiment, yet the verdict is KEEP and the contradiction is never acknowledged.
      wrong_action: A reviewer who applies the registered rule literally concludes VOID on all 20 sheets before any outcome row is considered; a reviewer who reads the controlled-variables table and corrects the copy-paste from E-012 concludes KEEP. The artifact never states which reading applies, so two reviewers diverge on VOID vs KEEP from the same data.
      anchor: "a sheet's rubric sha is not `396e1799eb2b`"
      evidence: experiments/E-013-specialist-skill-BE004.md:174
    - reason: The controlled-variables table registers the BE-004 rubric sha as `6252778b8472` and explicitly states "**not** BE-003's `396e1799eb2b`", so the author knew the value in row 0 is wrong for this experiment; the rule was never corrected.
      wrong_action: A reader who trusts the controlled-variables table cannot reconcile it with the decision rule, and a reader who trusts the decision rule voids an experiment the controlled-variables table plainly authorises. Either reader is acting on what the artifact literally says.
      anchor: "Rubric | `benchmark/rubrics/backend-quality-be004.yaml`, sha **`6252778b8472`** — proved on five fixtures at stop 12 §4 step 4, and **not** BE-003's `396e1799eb2b`"
      evidence: experiments/E-013-specialist-skill-BE004.md:114
    - reason: §4 step 10 reports a single KEEP for the skill and cites BE-003 results ("10 of 10 against 0 of 10 on BE-003 (p = 1.08 × 10⁻⁵)") and a cross-file activation aggregate ("Selection was recorded on 20 of 20 treated runs") as part of the KEEP justification, contradicting the opening's "No verdict is computed across the two files" rule.
      wrong_action: A reader who treats the decision as covering the skill across both tasks sees a verdict the artifact declares will not exist; a reader who treats it as BE-004-only must ignore the BE-003 p-value and the 20-of-20 activation count, which the decision cites as supporting evidence. Either way the decision text disagrees with its own scope rule.
      anchor: "test-quality anchor 2: 10 of 10 against 0 of 10 on BE-003 (p = 1.08 × 10⁻⁵) and 10 of 10 against 3 of 10 on BE-004 (p = 0.0031), two tasks registered separately with no verdict computed across them, both clearing their own MDE"
      evidence: experiments/E-013-specialist-skill-BE004.md:646
  non_blocking:
    - reason: Delivery table pins SKILL.md sha `0876025fa451af5f1f2970da67a02f0d` and overlay `build/customizations/skill-v1.0-testing/`, but the batch ran on `build/customizations/phases-v1.0-skillcarrier/` with sha `7bea904863fb79a544ee2068cb2f0f43`; the amendment discloses this. A validator checking the table alone would fail, but the correction is in the same document.
      evidence: experiments/E-013-specialist-skill-BE004.md:96
    - reason: Independent-variable section calls the design "the cleanest single-variable comparison this project has registered" while claiming both arms carry unmodified `phases-v1.0` with four tools; the amendment and decision both acknowledge the carrier adds `Skill` and that `phases-v1.0` cannot receive a skill at all. The framing is misleading without the amendment but the artifact discloses the actual design.
      evidence: experiments/E-013-specialist-skill-BE004.md:87
    - reason: `count-state-reread.py` returns control 8 of 10 on BE-004, which the registered P3 wording treats as sufficient but which the artifact itself notes "barely separates the arms" and is "a necessary condition for clause (b), not a measure of it." The discrepancy is reported, not hidden.
      evidence: experiments/E-013-specialist-skill-BE004.md:593
    - reason: `change-focus` agrees 8 of 20 between codex and opencode, vs the project's stated 18-of-20 cross-harness baseline; the artifact reports the number without placing it in that context.
      evidence: experiments/E-013-specialist-skill-BE004.md:675
    - reason: `architecture-consistency` is 10 of 10 in both arms ("constant — no information") and `maintainability` is floored at 0 of 10 / 0 of 10 across 20 runs; the artifact labels both as no-information cells. A rubric-author decision, not an artifact defect.
      evidence: experiments/E-013-specialist-skill-BE004.md:567
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 140s |
| ollama-cloud/glm-5.2 | ok | 109s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Independent variable | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Amendment — 2026-09-09, §4 step 5 second attempt | 1/1 | L3 |
| Decision — §4 step 10 | 1/1 | L3 |
| The second reader — BE-004 | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** no finding

### Independent variable
**Verdict:** finding
**Failure:** The section states both arms use "the same agent definition with the same four tools" and calls this "the cleanest single-variable comparison this project has registered." The amendment replaces the agent with a carrier that adds `Skill` to `tools:` on both arms — five tools, not four — and the agent file sha changes from `b3450564b6f32d61` to `51ffaedf9a3edbfe`. A reviewer reading only this section believes the comparison is unmodified `phases-v1.0` with four tools on both arms and treats the result as measuring what the skill adds to `phases-v1.0`. A reviewer who reads the amendment realizes the carrier is a non-product fixture and the result measures what the skill adds to an agent that can invoke skills — which the decision section itself concedes when it says "phases-v1.0 as it stands cannot receive a specialist skill at all." The original framing and the amendment's correction support different readings of what was measured.
**Layer of the implied fix:** L3
**Anchor:** "both arms are the same agent definition with the same four tools. The skill is added to a customization that already exists in the control. This is the cleanest single-variable comparison this project has registered."

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** The delivery table pins `SKILL.md` sha256 `0876025fa451af5f1f2970da67a02f0d` and overlay `build/customizations/skill-v1.0-testing/`. The amendment changes both: the batch ran on `build/customizations/phases-v1.0-skillcarrier/` with `SKILL.md` sha `7bea904863fb79a544ee2068cb2f0f43`. A validator checking the delivery table's hash against the actual batch's skill file would fail — the hash in the table does not describe the treatment that was administered. The amendment discloses the v1.1 hash and the carrier overlay, but the original table stays as written, so a reader who stops before the amendment verifies the wrong hash against the wrong overlay.
**Layer of the implied fix:** L3
**Anchor:** "`SKILL.md` sha256 `0876025fa451af5f1f2970da67a02f0d`, 675 words, added at §4 step 4 in commit `b0ca034`"

### Controlled variables
**Verdict:** no finding

### Runs
**Verdict:** no finding

### Minimum detectable effect
**Verdict:** no finding

### Deterministic evaluation
**Verdict:** no finding

### Exclusions, registered before the data
**Verdict:** no finding

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Row 0 fires VOID when "a sheet's rubric sha is not `396e1799eb2b`." The rubric used is `backend-quality-be004.yaml` at sha `6252778b8472` (Controlled variables, line 114), and `396e1799eb2b` is explicitly identified there as BE-003's rubric. Every sheet carries `rubric_sha: 6252778b8472` in its provenance block (line 562). Applied in order as written, row 0 fires VOID on every sheet because `6252778b8472 ≠ 396e1799eb2b` — the experiment voids itself before any result is considered. The decision reports KEEP (row 1, CONFIRM), meaning row 0 was not applied. Two reviewers: one applies row 0 literally and voids the entire experiment; one recognizes the sha as a copy-paste error from sibling E-012 and proceeds to row 1. The outcome — KEEP or VOID — depends on which reviewer you ask.
**Layer of the implied fix:** L3
**Anchor:** "a sheet's rubric sha is not `396e1799eb2b`"

### Threats to validity, registered before the run
**Verdict:** no finding

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** no finding

### §4 step 4 — the build
**Verdict:** skipped
Placeholder, filled in the amendment.

### §4 step 5 — the preflight pair
**Verdict:** skipped
Placeholder, filled in the amendment.

### §4 step 6 — the batch
**Verdict:** skipped
Placeholder, filled in the amendment.

### Results
**Verdict:** skipped
Placeholder, filled in the amendment.

### Which predictions held
**Verdict:** skipped
Placeholder, filled in the amendment.

### Decision
**Verdict:** skipped
Placeholder, filled under "Decision — §4 step 10."

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** finding
**Failure:** The sub-section "P3's measure behaves differently here" reports `count-state-reread.py` returns control 8 of 10 on BE-004, while the rubric scores control 3 of 10 at anchor 2. The measure counts "a separate `get(...)` following the mutating call" — any `get`, not the two-clause re-read (order *and* shipment after a refused cancel) that anchor 2 requires. P3 predicted ≤ 5 of 10 treated on this measure; the result is 10 of 10, refuting P3. But the measure's control count of 8 of 10 shows it barely separates the arms on this task, while on BE-003 it separated them completely (10 vs 0). A reviewer reading P3's refutation alongside the control's 8 of 10 on the same measure would ask whether P3 was testing the right thing: the prediction names the specific clauses (b) and (d), the measure counts any `get`. The text acknowledges this ("a necessary condition for clause (b), not a measure of it"), but P3 was registered against this measure, so the refutation is of a coarser claim than P3's wording states. Two reviewers: one reads "P3 refuted, 10 of 10 against ≤ 5" and moves on; one reads the control's 8 of 10 and asks whether the measure can distinguish "the skill worked" from "the measure was too coarse to see whether it worked."
**Layer of the implied fix:** L3
**Anchor:** "P3 — the clause, named. Of the treated runs that write a test for `cancel`, ≤ 5 of 10 re-read persisted state through a separate `get(...)` after the mutating call"

### Decision — §4 step 10
**Verdict:** finding
**Failure:** The file's opening states "No verdict is computed across the two files" (line 12). The decision section cites both experiments' results under a single KEEP: "test-quality anchor 2: 10 of 10 against 0 of 10 on BE-003 (p = 1.08 × 10⁻⁵) and 10 of 10 against 3 of 10 on BE-004 (p = 0.0031), two tasks registered separately with no verdict computed across them, both clearing their own MDE." It aggregates "Selection was recorded on 20 of 20 treated runs and absent on 20 of 20 controls" — a cross-file sum (10 + 10 per arm). It also cites a BE-003 maintainability concern ("treated 2 of 10 against control 5 of 10, p = 0.35") in the BE-004 decision. Two reviewers: one reads the disclaimer "no verdict computed across them" as sufficient and treats each result as independently reported; one reads a single KEEP verdict citing both p-values, a 20-of-20 aggregate, and a BE-003 follow-up as a cross-file verdict regardless of the disclaimer.
**Layer of the implied fix:** L3
**Anchor:** "two tasks registered separately with no verdict computed across them, both clearing their own MDE"

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `architecture-consistency` is 10 of 10 in both arms (line 567, "constant — no information"), which is the same shape the v1 rubric purge removed when it dropped `functional-correctness` and `requirement-completeness` for restating gates. Here the constant is across arms rather than across the gate-passing population, but the effect is the same: the category carries no information about the treatment. It is not a gate restatement — the evaluator gate is separate — but it is a dead cell that occupies 35 of the rubric's 100 points.
- **Which single section would two reviewers diverge on most, and by how much?** The Decision rule, specifically row 0's rubric sha. One reviewer applies it literally and voids the experiment; another corrects the copy-paste error and confirms. The divergence is total — VOID vs KEEP — and it turns on whether a typo in a pre-registered rule should be followed as written or corrected in spirit.
- **What did the artifact not say that it needed to say?** The decision rule row 0 checks the wrong rubric sha and the artifact never notices. The delivery table and independent-variable section describe v1.0, but the batch ran on the carrier with v1.1 — the amendment discloses this but the original sections are never corrected, so a reader who trusts the original sections over the amendment verifies the wrong hash against the wrong overlay. The artifact needed to say, at the point of decision, that row 0's sha was wrong and was not applied, or to correct it before the batch ran.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

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

### Exclusions, registered before the data
**Verdict:** no finding

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Row 0 says VOID if "a sheet's rubric sha is not `396e1799eb2b`". The controlled-variables table (line 114) registers the BE-004 rubric sha as `6252778b8472`, and every scored sheet carries `rubric_sha: 6252778b8472` (line 562). `6252778b8472` is not `396e1799eb2b`, so the row-0 condition is true on every sheet. Applied as written, the decision rule fires VOID before any outcome row is reached. The applied verdict is KEEP (line 644). Two reviewers diverge: one reads the rule literally and voids the experiment; the other infers a copy-paste from E-012 (BE-003, whose sha is `396e1799eb2b`) and substitutes the correct sha. The divergence is VOID vs KEEP — the most consequential split available.
**Layer of the implied fix:** L3
**Anchor:** `a sheet's rubric sha is not 396e1799eb2b`

### Threats to validity, registered before the run
**Verdict:** no finding

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** no finding

### §4 step 4 — the build
**Verdict:** skipped
Placeholder filled by amendment.

### §4 step 5 — the preflight pair
**Verdict:** skipped
Placeholder filled by amendment.

### §4 step 6 — the batch
**Verdict:** skipped
Placeholder filled by amendment.

### Results
**Verdict:** skipped
Placeholder filled by amendment.

### Which predictions held
**Verdict:** skipped
Placeholder filled by amendment.

### Decision
**Verdict:** skipped
Placeholder filled by amendment.

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** no finding

### §4 step 6 — the BE-004 batch
**Verdict:** no finding

### §5 hand re-read — BE-004 pair 01, written before any BE-004 sheet existed
**Verdict:** no finding

### §4 step 7 — the registered scores, BE-004
**Verdict:** no finding

### Which predictions held — BE-004
**Verdict:** no finding

### P3's measure behaves differently here, and that is reported rather than swapped out
**Verdict:** no finding

### §4 step 8 — the report, and what it cannot answer
**Verdict:** no finding

### Decision — §4 step 10
**Verdict:** finding
**Failure:** The decision is KEEP, but the registered decision rule (row 0) would fire VOID on every sheet because it checks for `396e1799eb2b` (BE-003's sha) while every BE-004 sheet carries `6252778b8472`. The decision section does not acknowledge this contradiction. A reviewer who applies the rule as registered gets VOID; a reviewer who reads the controlled-variables table and infers the intent gets KEEP. The section states "the measured effect, not an assumed one" but the verdict itself rests on an unacknowledged bypass of a registered gate.
**Layer of the implied fix:** L3
**Anchor:** `**KEEP.**`

### The second reader — BE-004
**Verdict:** finding
**Failure:** `change-focus` reports 8 of 20 identical between codex and opencode — 12 of 20 disagreements. The project's previous cross-harness baseline (CLAUDE.md) was 18 of 20 exact. A 6× increase in the disagreement rate is reported as a bare number with no investigation, no comparison to the baseline, and no statement of whether it matters. Two reviewers diverge: one reads 8 of 20 as a passing glance and moves on; the other reads it as a rubric-anchor or harness defect that the `change-focus` category may be unreliable at this sha, and asks whether the same anchor instability could touch `test-quality` on a different task. The artifact does not give either reader the information to decide.
**Layer of the implied fix:** L3
**Anchor:** `| `change-focus` | **8 of 20** |`

### A subagent reported values for a sheet that has none, and it was caught by opening the file
**Verdict:** no finding

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. Decision-rule row 5 records an evaluator-pass difference *beside* whichever outcome row fires, not instead of it; `check-run-gate.sh` is the gate and runs before any sheet is opened. P6 is a prediction about the gate's output, not a restatement of the gate.
- Which single section would two reviewers diverge on most, and by how much? **Decision rule, fixed before the run** — maximally. One reads `396e1799eb2b` literally and voids the experiment; the other infers a copy-paste from E-012 and keeps it. The split is VOID vs KEEP on the same data.
- What did the artifact not say that it needed to say? Two things. (1) The decision-rule sha is wrong for this experiment and the KEEP verdict bypasses the registered rule without acknowledging it. (2) The 12-of-20 `change-focus` disagreement is a 6× increase over the project's stated cross-harness baseline and is not placed in that context, so a reader cannot judge whether the category is stable at this rubric sha.
