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
reviewed_utc:    20260909T204857Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-013-specialist-skill-BE004.md
    sha:  db1ade51e220
    dirty: false
lab_head:        dc27b82
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-013-specialist-skill-BE004.md
  verdict: ACCEPT
  summary: Experiment with messy but disclosed methodology; measurements clean (10 of 10 vs 3 of 10 on test-quality anchor 2, p = 0.0031, both harnesses agree on 40 of 40 cells), KEEP supported by BE-004's own data, and every structural defect (row 0 sha clause, BE-003 citation in Decision, SUPERSEDED blocks, P1 mis-specification, P3 measure limitation) named and resolved on the record.
  blocking: []
  non_blocking:
    - reason: "Decision rule row 0 names BE-003's rubric sha (`396e1799eb2b`) instead of BE-004's (`6252778b8472`); applied literally, row 0 fires VOID on every BE-004 sheet. The artifact explicitly discusses this contradiction at lines 754-789, names it as a defect, and adopts CONFIRM by row 1."
      evidence: experiments/E-013-specialist-skill-BE004.md:207
    - reason: "The Decision section's first paragraph (line 679) cites BE-003's p-value alongside BE-004's, sitting 100 lines before the resolution ('the stop's KEEP decision stands on E-012 alone' at line 783). A reader who stops at the Decision's lead gets the cross-task impression; the file resolves it but not where the §4a response claims."
      evidence: experiments/E-013-specialist-skill-BE004.md:679
    - reason: "Three sections (Independent variable, How delivered, Controlled variables) describe `phases-v1.0` as the carrier when the batch ran on a carrier overlay; SUPERSEDED blocks at lines 81-89, 104-112, 129-137 mark the correction. Per §4 step 12 the original text is preserved, not edited."
      evidence: experiments/E-013-specialist-skill-BE004.md:81
    - reason: "The 'cleanest single-variable comparison' claim at line 100 was premised on both arms having four tools, but the carrier has five (Skill added to `tools:`). The premise is stale; the SUPERSEDED block at lines 81-89 is the correction."
      evidence: experiments/E-013-specialist-skill-BE004.md:100
    - reason: "P1's void condition (<9 of 10 activations → VOID) conflates delivery with selection; selection rate measured at 4 of 5 (lines 417-418), so a treated arm of 10 expected ~8 activations. Disclosed at lines 425-431, with ITT and per-protocol both reported."
      evidence: experiments/E-013-specialist-skill-BE004.md:47
    - reason: "P3's `count-state-reread.py` measure barely separates arms on BE-004 (10 of 10 vs 8 of 10) while the rubric separates at 10 of 10 vs 3 of 10; both numbers reported at lines 626-640 with the measure's limitation named."
      evidence: experiments/E-013-specialist-skill-BE004.md:626
    - reason: "The §4a response for E-013 #5 (line 747) claims the Decision section is 'now BE-004's own' but the text still leads with BE-003's p-value; the response overstates what the fix did."
      evidence: experiments/E-013-specialist-skill-BE004.md:747
  disputed:
    - finding: "E-013 #4 (1/2): The re-read measure counts any `get` rather than anchor 2's two clauses — line-level §4a finding."
      why: "The artifact already addresses this in 'P3's measure behaves differently here' (lines 626-640): the control's 8 of 10 is reported beside the treated 10 of 10, what the measure cannot see is named, and the `get('/shipments/…')` count is labeled a necessary condition rather than a measure. The §4a response records 'ALREADY DISCLOSED.' The finding's evidence exists in the document with the control number; it is not a hidden defect."
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 211s |
| ollama-cloud/glm-5.2 | ok | 150s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Decision rule, fixed before the run | 1/1 | L3 |
| Decision | 1/1 | L3 |
| §4a review round 1 — what the acceptance gate rejected, and what was done about each finding | 1/1 | L3 |
| Predictions | 1/1 | L3 |
| Independent variable | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L3 |
| Controlled variables | 1/1 | L3 |
| Deliberate failure — registered here, run at §4 step 9 | 1/1 | L3 |
| Amendment — 2026-09-09, §4 step 5 second attempt | 1/1 | L3 |
| Decision — §4 step 10 | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

→ Read experiments/E-013-specialist-skill-BE004.md [offset=790]
### Question
**Verdict:** no finding

### Hypothesis
**Verdict:** no finding

### Predictions
**Verdict:** no finding

### Independent variable
**Verdict:** no finding

The SUPERSEDED block at the head of the section names the correction (carrier overlay, not `phases-v1.0`) and points at the Amendment. The original text is marked, not edited. A reviewer who reads the supersession block has the correct carrier; one who skips it does not, but the block is the first thing in the section.

### How the treatment is delivered — and proved
**Verdict:** no finding

Same SUPERSEDED structure as above. The delivery table's content hash (`0876025fa451af5f…`) and overlay path (`skill-v1.0-testing/`) are superseded by the Amendment's carrier and sha (`7bea904863fb79a5…`), and the supersession block says so.

### Controlled variables
**Verdict:** no finding

SUPERSEDED block present. The rubric sha `6252778b8472` is registered here and flagged as "not BE-003's `396e1799eb2b`" — which is the correct sha for this task. The contradiction with the decision rule is a finding against the decision rule, not against this section.

### Runs
**Verdict:** no finding

### Minimum detectable effect
**Verdict:** no finding

The MDE table is derived from the measured reference population (3 of 10). The actual control held at 3 of 10, so the MDE was not computed against a moving target. The §4a finding about MDE calibration (E-012 #1) applies to E-012, not here.

### Deterministic evaluation
**Verdict:** no finding

### Exclusions, registered before the data
**Verdict:** no finding

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Row 0 reads *"a sheet's rubric sha is not `396e1799eb2b`"* → VOID. Every BE-004 sheet carries `6252778b8472` (the sha this file's own Controlled-variables section registers, three headings above, explicitly flagged "not BE-003's"). By the letter, row 0 fires on every sheet and the experiment is VOID. The artifact adopts CONFIRM by intent (row 1, 10 of 10 ≥ 9). Two reviewers diverge: one follows the rule as written (VOID, nothing claimed), the other follows the stated meaning (CONFIRM, `p = 0.0031`). The sha `396e1799eb2b` is BE-003's, carried over from E-012's shape. The rule contradicts its own document, and nothing executes to catch that — the artifact names a `verify-decision-rule.sh` that would be L2 but states it is not built.

A second defect in the same rule: row 0's activation threshold (fewer than 9 of 10 → VOID) is inconsistent with the measured selection rate of 4 of 5 (Amendment, "The selection rate"). At that rate a treated arm of 10 expects ~8 activations. A batch landing at 8 of 10 — a normal outcome — would be declared VOID despite per-run delivery proof (`skillsHash` non-null, init read-back `delivered n=5`). The batch got 10 of 10, so the threshold did not fire, but the rule as registered would void a valid delivery.
**Layer of the implied fix:** L3
**Anchor:** *"fewer than 9 of 10 treated runs record a skill activation, or any control records one, or a sheet's rubric sha is not `396e1799eb2b`"*

### Threats to validity, registered before the run
**Verdict:** no finding

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** no finding

The original registration (n = 3, two clauses) was initially run at n = 1 with one clause, undisclosed. The §4a gate caught this. The artifact's response was to run the registration as written (n = 3, both clauses, carrier configuration), reported in the §4a section. The original text is unedited; the correction is in the §4a section.

### §4 step 4 — the build
**Verdict:** skipped

Empty placeholder (`<!-- filled at step 4 -->`). Content was added in the Amendment.

### §4 step 5 — the preflight pair
**Verdict:** skipped

Empty placeholder. Content was added in the Amendment.

### §4 step 6 — the batch
**Verdict:** skipped

Empty placeholder. Content was added in the Amendment.

### Results
**Verdict:** skipped

Empty placeholder. Results are in the Amendment under "§4 step 7" and "§4 step 8."

### Which predictions held
**Verdict:** skipped

Empty placeholder. The predictions-held table is in the Amendment under "Which predictions held — BE-004."

### Decision
**Verdict:** finding
**Failure:** The file opens with *"No verdict is computed across the two files"* (line 12). The Decision section's KEEP rationale leads with BE-003's result — *"10 of 10 against 0 of 10 on BE-003 (`p = 1.08 × 10⁻⁵`) and 10 of 10 against 3 of 10 on BE-004 (`p = 0.0031`)"* — pools selection across both tasks (*"20 of 20 treated runs"*), and cites BE-003's maintainability cell (*"BE-003 `maintainability`, treated 2 of 10 against control 5 of 10"*). Two reviewers diverge: one reads the KEEP as standing on BE-004's own 10-of-10 against 3-of-10 (the registered outcome in this file), the other reads the dual citation and pooled counts as the KEEP relying on both tasks together — which is the cross-task verdict the file declares it does not compute. The qualifier *"two tasks registered separately with no verdict computed across them"* is present but sits inside a sentence that cites both p-values to justify a single KEEP.
**Layer of the implied fix:** L3
**Anchor:** *"`test-quality` anchor 2: **10 of 10 against 0 of 10** on BE-003 (`p = 1.08 × 10⁻⁵`) and **10 of 10 against 3 of 10** on BE-004 (`p = 0.0031`), two tasks registered separately with no verdict computed across them"*

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** no finding

The Amendment is the largest section and contains the actual results, probe data, selection-rate measurement, batch results, hand re-read, scores, predictions-held table, and P3 measure disclosure. The P3 table (line 621) reports REFUTED at 10 of 10 without the control's 8 of 10, but the text immediately below (lines 629–640) reports the control number, names what the measure cannot see, and labels the `get("/shipments/…")` count as a necessary condition rather than a measure. The subagent empty-sheet incident (lines 715–730) is disclosed with the tally unaffected. The instrument defects (lines 446–540) are disclosed with excluded runs named by id. The selection-rate finding (P1 threshold inconsistency) is disclosed and P1 is reported as refuted in its premise. None of these produce a wrong answer without also carrying the control number or the disclosure that bounds it.

### §4a review round 1 — what the acceptance gate rejected, and what was done about each finding
**Verdict:** finding
**Failure:** The §4a response for finding E-013 #5 (2/2) reads *"FIXED — the Decision section in this file is now BE-004's own, and says where BE-003's identical decision was taken."* The Decision section text (lines 679–696) still leads with BE-003's p-value, pools selection counts across both tasks, and cites BE-003's maintainability cell. The claimed fix does not match the text. Two reviewers diverge: one reads the §4a response and concludes the BE-003 citation was removed; the other opens the Decision section and finds it still present. The §4a response overstates what the fix did — the qualifier "no verdict computed across them" was added, but the BE-003 data was not removed and the Decision is not "BE-004's own" in the sense the response implies.
**Layer of the implied fix:** L3
**Anchor:** *"FIXED — the Decision section in this file is now BE-004's own, and says where BE-003's identical decision was taken."*

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. `test-quality` anchor 2 (the registered outcome) measures test structure; the evaluator pass rate (P6) measures functional correctness. They are different instruments checking different things. The evaluator passed 10 of 10 on both arms; `test-quality` separated them at 10 of 10 against 3 of 10. No duplication.

- Which single section would two reviewers diverge on most, and by how much? The Decision rule section, by a full verdict level. Row 0's sha clause (`396e1799eb2b`) is BE-003's rubric sha, not BE-004's (`6252778b8472`), and the rule as written fires VOID on every BE-004 sheet. One reviewer reads the rule literally and gets VOID; the other reads the controlled-variables section three headings above, sees the sha is a copy-paste error, and gets CONFIRM. The artifact discloses both readings and adopts one — but the rule as registered produces the other.

- What did the artifact not say that it needed to say? The Decision section says at line 783 that *"the stop's KEEP decision stands on E-012 alone"* — meaning E-013's own KEEP is non-load-bearing — but this appears 100 lines into the Decision section, inside the row-0 discussion, not at the KEEP itself. A reader who stops at line 677 (*"KEEP"*) does not know E-013's verdict is non-load-bearing until they reach line 783. The fact is present; its placement is not.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

→ Read experiments/E-013-specialist-skill-BE004.md [offset=790]
### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** P1's void condition (line 47: "Below 9 of 10 activations → VOID") conflates *delivery* with *selection*. The selection rate was measured at 4 of 5 (line 417-418), so a treated arm of 10 is expected to land at ~8 activations. A batch returning 8 of 10 would fire P1's void by its letter — voiding the entire comparison — while delivery is independently proven per run by `skillsHash` non-null and the init read-back `delivered n=5 [...,"Skill"]`. Two reviewers diverge: one applies row 0 mechanically and voids; the other reads P1's stated meaning ("the skill was not delivered") and keeps the comparison, since delivery is proven. The artifact got 10 of 10 so P1 held, but the registered void condition would have fired on a plausible outcome.
**Layer of the implied fix:** L3
**Anchor:** "Below 9 of 10 activations → VOID (decision-rule row 0), and a void here means *the skill was not delivered*, never *the skill did not work*."

### Independent variable
**Verdict:** finding
**Failure:** The section describes `phases-v1.0` with `agentHash b3450564b6f32d61` and four tools (line 93-95), but the batch ran on a carrier overlay with `agentHash 51ffaedf9a3edbfe` and five tools. The SUPERSEDED block at line 81-89 marks this, but the original text is kept unedited and nothing executes to prevent a reader from following it. A reviewer reading only the original text (skipping the blockquote) would believe the control arm has 4 tools and the treated arm has 4 tools + skill directory, when in fact both arms have 5 tools and differ only in the skill directory. Two reviewers given this section alone would reconstruct different experiments.
**Layer of the implied fix:** L3
**Anchor:** "Both arms carry `phases-v1.0` (agent `backend-feature-phases`, overlay sha256 `b3450564b6f32d6193e8580db766210e`), the same model, the same benchmark tree and the same evaluator."

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Same defect as Independent variable — the delivery table at line 115-121 describes `phases-v1.0` as the carrier, `agentHash b3450564b6f32d61`, and the v1.0 skill sha `0876025fa451af5f`, none of which match what the batch used. The SUPERSEDED block at line 104-112 marks this. A reviewer reading the delivery table to verify the treatment would check the wrong hashes against the wrong overlay and find a mismatch with the actual run records, or worse, find a match with the wrong quantities and conclude the treatment was delivered as described.
**Layer of the implied fix:** L3
**Anchor:** "`SKILL.md` sha256 **`0876025fa451af5f1f2970da67a02f0d`**, 675 words, added at §4 step 4 in commit `b0ca034`"

### Controlled variables
**Verdict:** finding
**Failure:** The table at line 140-149 registers `agentHash sha256:b3450564b6f32d61` and four tools, but the batch ran on `51ffaedf9a3edbfe` with five tools. The SUPERSEDED block at line 129-137 marks this. The rubric sha `6252778b8472` is correctly registered here, which makes the decision-rule row 0's reference to `396e1799eb2b` (a different sha) internally contradictory within one document — the variable is right, the rule is wrong. A reviewer cross-checking the controlled-variables table against the decision rule would find two different shas registered for the same experiment with no executing check to flag the contradiction.
**Layer of the implied fix:** L3
**Anchor:** "Agent overlay | `phases-v1.0`, `agentHash sha256:b3450564b6f32d61`, **on both arms**"

### Runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Minimum detectable effect
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions, registered before the data
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule, fixed before the run
**Verdict:** finding
**Failure:** Row 0 (line 207) requires "a sheet's rubric sha is not `396e1799eb2b`" to avoid VOID. Every BE-004 sheet carries `6252778b8472` — the sha this same file registers in Controlled variables. Read by its letter, row 0 fires VOID on every sheet. The artifact adopts CONFIRM by row 1 instead (line 775). Two reviewers diverge: one applies the registered rule mechanically and voids the experiment; the other reads row 0's stated meaning ("the skill was not delivered") and confirms, since delivery is proven. The registered rule does not produce the verdict the artifact adopts. Nothing executes to check that a sha in a decision rule matches the sha in the same experiment's controlled variables.
**Layer of the implied fix:** L3
**Anchor:** "fewer than 9 of 10 treated runs record a skill activation, or any control records one, or a sheet's rubric sha is not `396e1799eb2b` | **VOID**"

### Threats to validity, registered before the run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** finding
**Failure:** The section registers the deliberate failure at "n = 3" with two clauses (activation falls to 0 of 3; test-quality stays at control's level). The §4a review table (line 745) notes the first attempt ran at n = 1 with one clause, undisclosed. The re-run at n = 3 with both clauses appears at line 808. A reviewer reading only this section would believe n = 3 was always the plan; a reviewer who read the §4a table first would know the first run deviated from the registration. The section itself does not mention the deviation — it reads as if the registered n = 3 was what ran.
**Layer of the implied fix:** L3
**Anchor:** "the identical body with a `description` that names an unrelated domain, `n = 3`. **Prediction:** activation falls to **0 of 3**"

### §4 step 4 — the build
**Verdict:** skipped
**Failure:** Empty placeholder (`<!-- filled at step 4 -->`). Content appears in the Amendment.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair
**Verdict:** skipped
**Failure:** Empty placeholder. Content appears in the Amendment.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch
**Verdict:** skipped
**Failure:** Empty placeholder. Content appears in the Amendment at line 542.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** skipped
**Failure:** Empty placeholder. Content appears in the Amendment's subsections.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** skipped
**Failure:** Empty placeholder. Filled version at line 615 under `### Which predictions held — BE-004`.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** skipped
**Failure:** Empty placeholder. Filled version at `## Decision — §4 step 10` (line 675).
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment — 2026-09-09, §4 step 5 second attempt
**Verdict:** finding
**Failure:** The "P3's measure behaves differently here" subsection (line 626) reports `count-state-reread.py` returning 10 of 10 treated and 8 of 10 control — barely separating the arms — while the rubric separates them at 10 of 10 against 3 of 10. The measure counts "a separate `get(...)` following the mutating call" and cannot see that BE-004's anchor 2 requires a re-read of *both* the order *and* a shipment after a refused cancel. A reviewer using P3's measure to verify the rubric's verdict would find 10 vs 8 (barely different) and question the rubric's 10 vs 3; a reviewer using the rubric would find the measure inadequate. The artifact discloses this, but P3's registered wording ("≤ 5 of 10 re-read persisted state through a separate `get(...)`") is refuted by 10 of 10 while the control's 8 of 10 shows the measure cannot distinguish what the rubric distinguished. Two reviewers would diverge on whether P3's refutation means the behavior changed or the measure was wrong.
**Layer of the implied fix:** L3
**Anchor:** "On BE-004 it returns **treated 10 of 10** and **control 8 of 10** — so on this task the measure **barely separates the arms**"

### Decision — §4 step 10
**Verdict:** finding
**Failure:** The Decision section (line 679-684) cites BE-003's result — "10 of 10 against 0 of 10 on BE-003 (p = 1.08 × 10⁻⁵)" — in a file whose header declares "No verdict is computed across the two files" (line 12). The §4a review table (line 747) claims this was "FIXED — the Decision section in this file is now BE-004's own." A reviewer reading the §4a table believes the cross-task citation was removed; a reviewer reading the actual Decision text finds BE-003's p-value still present, with a qualifier ("two tasks registered separately with no verdict computed across them") added but the citation retained. These two reviewers would disagree on whether the fix was applied.
**Layer of the implied fix:** L3
**Anchor:** "`test-quality` anchor 2: **10 of 10 against 0 of 10** on BE-003 (`p = 1.08 × 10⁻⁵`) and **10 of 10 against 3 of 10** on BE-004 (`p = 0.0031`), two tasks registered separately with no verdict computed across them"

### §4a review round 1 — what the acceptance gate rejected, and what was done about each finding
**Verdict:** finding
**Failure:** The review table at line 747 claims E-013 #5 was "FIXED — the Decision section in this file is now BE-004's own, and says where BE-003's identical decision was taken." The Decision text at line 679-684 still cites BE-003's p-value and does not say where BE-003's decision was taken. A reviewer using the §4a table as a change log would mark the finding resolved; a reviewer opening the Decision section would find the cited text still present. The table's claim of "FIXED" does not match the file's content.
**Layer of the implied fix:** L3
**Anchor:** "FIXED — the Decision section in this file is now BE-004's own, and says where BE-003's identical decision was taken."

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `test-quality` anchor 2 is the registered outcome (P2, decision rule rows 1-4) and is also what the evaluator's pass/fail gate measures indirectly — P6's evaluator floor of ≥ 9 of 10 is a correctness gate, and `test-quality` is a quality measure. They measure different things (correctness vs test quality), so this is not a duplication. No category restates a gate.
- **Which single section would two reviewers diverge on most, and by how much?** "Decision rule, fixed before the run" — row 0's sha clause. One reviewer voids the experiment; another confirms it. The divergence is total: VOID vs CONFIRM on the same registered rule, on the same data. The artifact itself names both readings and picks one, which is the best disclosure can do, but the rule as written does not produce the adopted verdict.
- **What did the artifact not say that it needed to say?** Three sections (Independent variable, How the treatment is delivered, Controlled variables) describe an experiment that was not run. The SUPERSEDED blocks say what *was* run, but do not say whether the original text's claims about `phases-v1.0` being "the cleanest single-variable comparison this project has registered" (line 100) still hold for the carrier — the carrier is a different agent definition (5 tools, not 4), and the claim of cleanliness was premised on both arms being "the same agent definition with the same four tools." The carrier has five tools, so the claim's basis changed and was not re-evaluated in place.
