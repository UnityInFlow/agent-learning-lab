# opencode review — E-010-workflow-phases-BE003

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
reviewed_utc:    20260909T102118Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-010-workflow-phases-BE003.md
    sha:  2c71e53edad7
    dirty: false
  - path: phases/b05-workflow-phases/README.md
    sha:  4c1d321ddf52
    dirty: false
lab_head:        3468506
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

→ Read experiments/E-010-workflow-phases-BE003.md [offset=765]
I need to read the rest of E-010 first — the line-level pass flagged that the file was capped at 764 and there may be more content.
```yaml
acceptance:
  artifact: experiments/E-010-workflow-phases-BE003.md
  verdict: ACCEPT
  summary: A complete experiment file with its registered decision rule walked in order, an explicit stress-test of the verdict, the build-track gate answered yes as a separate question, and a deliberate-failure gap that is itself disclosed and deferred; the line-level pass found nine real items, every one of which is either already addressed in the artifact's body or sits in an empty template the artifact makes no claim about.
  blocking: []
  non_blocking:
    - reason: Stale status header at line 4 reads "REGISTERED, no runs yet" but the file carries a full Results section, decision walk and verdict; a human reader who opens the file sees the contradiction immediately and is not misled, but a script that parses only the header would skip a fully-executed experiment      evidence: experiments/E-010-workflow-phases-BE003.md:4
    - reason: Decision-rule row 4's "nothing improved" clause is ambiguous on this data; the artifact stress-tests both readings at lines 892-928 (the symmetric-MDE reading, the all-10-treated-below-control-median reading, and an unregistered permutation test) and explicitly chooses row 5, so a reader who follows the stress-test reaches the same verdict
      evidence: experiments/E-010-workflow-phases-BE003.md:892-928
    - reason: Threat 7's "the affected runs are named and the comparison is read with them called out" is satisfied in the Independence check section (pair 04's control, `delegating_calls = 1`, named explicitly) rather than inside the per-arm Results table; the §5 validation table in the README names it again      evidence: experiments/E-010-workflow-phases-BE003.md:785-791; phases/b05-workflow-phases/README.md:357    - reason: The deliberate failure registered at E-010 lines 250-257 was not run; the B5 README's Deliberate failure section is an HTML-comment TODO at lines 280-284; the verdict (INCONCLUSIVE) does not depend on it, and the artifact's learning block next_question at lines 327-332 explicitly defers the mechanism question to the next stop
      evidence: experiments/E-010-workflow-phases-BE003.md:250-257, 327-332; phases/b05-workflow-phases/README.md:280-284
    - reason: The `test-quality` Fisher calculation at line 660 treats the four control nulls as "not anchor 2" in the registered n=10 denominator; the second hand re-read at lines 745-759 recomputes the null rate separately (treated 0/10, control 4/10, Fisher p=0.0867) and labels it "not a result of this experiment," so the P7 claim stands on the count (1 vs 1) rather than on the p-value
      evidence: experiments/E-010-workflow-phases-BE003.md:660, 745-759
    - reason: B5 README's Exit gate lists the three build-track clauses but leaves `<!-- TODO -->` for the "Plus, for this to count as a learned phase" criteria; the experiment-level verdict (INCONCLUSIVE) is on E-010's registered decision rule, separate from any phase-promotion claim the README is not yet ready to make
      evidence: phases/b05-workflow-phases/README.md:262-266, 364-371
    - reason: The learning block's `unexpected_effect` makes a causal claim ("A structure that stops the model wandering is cheaper than one that lets it") that the same author's token-composition section later in the file labels as "still a post-hoc explanation of an unregistered quantity"; the disclosure is in the artifact but not on the same line as the claim, so a future reader citing the learning block alone could miss the hedge
      evidence: experiments/E-010-workflow-phases-BE003.md:316, 614
    - reason: B5 README's Commit section is an empty TODO at lines 373-375; not blocking because the artifact makes no claim that a phase commit exists
      evidence: phases/b05-workflow-phases/README.md:373-375
  disputed: []
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 271s |
| ollama-cloud/glm-5.2 | STALLED | >600s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Question | 1/1 | L3 |
| Decision rule, fixed before the run | 1/1 | L3 |
| Threats to validity, registered before the run | 1/1 | L3 |
| Deliberate failure — registered here, run at §4 step 9 | 1/1 | L3 |
| Results | 1/1 | L3 |
| Lab B5.1 — measure against B4 | 1/1 | L3 |
| Deliberate failure | 1/1 | L3 |
| Learning block — BE-003 | 1/1 | L3 |
| Exit gate | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### Question
**Verdict:** finding
**Failure:** The header at line 4 reads `Status: REGISTERED, no runs yet.` The file contains a full Results section with 20 admitted runs, per-arm medians, quality sheets, and a second-reader comparison. A stranger scanning the file for status — or a script that parses the status line — reads "no runs yet" and stops, missing every result below. Two reviewers would agree the line is stale; they would diverge on whether it is cosmetic or material, because nothing in the file corrects it and the README's own status says OPEN.
**Layer of the implied fix:** L3
**Anchor:** `**Status:** REGISTERED, no runs yet.`

### Hypothesis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Independent variable
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### How the treatment is delivered — and proved
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Controlled variables
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

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
**Failure:** Row 4's condition `nothing improved` is undefined. On this batch's data, P2 = 10/10 and P3 = 10/10, so the rule reaches the row 3/4 boundary. P5 and P6 both missed their MDE in the *opposite* direction — turns and cost went *down*. A reviewer who reads "improved" as "any registered outcome moved favourably" counts the −20.4 % cost and −1.5 turns as improvements, so "nothing improved" is false, and the rule falls through to row 5 (INCONCLUSIVE) — which is what the artifact says. A reviewer who reads "improved" as "a registered *quality* outcome improved" sees P7 at p = 1.0 and P8 unchanged, concludes "nothing improved" is true, and lands on row 4 (NOT DETECTABLE). These are different verdicts: NOT DETECTABLE claims the phases were followed and cost nothing this n can resolve; INCONCLUSIVE claims the combination fits no row. The B5 README's "against B4" comparison depends on which one you pick — B4 was INCONCLUSIVE because it could not resolve, and NOT DETECTABLE would mean B5 *did* resolve and found nothing, which is a stronger claim.
**Layer of the implied fix:** L3
**Anchor:** `P2 ≥ 9 of 10 **and** P3 ≥ 9 of 10 **and** neither P5 nor P6 clears its MDE **and** nothing improved`

### Threats to validity, registered before the run
**Verdict:** finding
**Failure:** Threat 7's registered mitigation says: *"every control run's transcript is counted for `Task` use, and the count is reported beside the batch's numbers"* and *"If it is not zero, the affected runs are named and the comparison is read with them called out."* The §5 independence check names pair 04's control as having made one delegating call. But the Results per-arm comparison table — the table that carries every registered outcome and verdict — does not mention pair 04's control, does not flag the row, and does not say whether the comparison changes if that run is excluded. Two reviewers diverge: one reads the §5 mention as satisfying "reported beside the batch's numbers," the other reads the per-arm table as "the comparison" that was supposed to be "read with them called out" and finds it silent.
**Layer of the implied fix:** L3
**Anchor:** `the affected runs are named and the comparison is read with them called out`

### Deliberate failure — registered here, run at §4 step 9
**Verdict:** finding
**Failure:** The experiment registers a deliberate-failure prediction (markers vanish, narrative headings survive, `naive-phase-checker.py` still passes) and assigns it to §4 step 9. The §4 step 4 section confirms the overlay "does not exist yet and that is deliberate." The Results section contains no deliberate-failure results. The B5 README assigns a verdict ("B5 closes INCONCLUSIVE on BE-003"). Two reviewers diverge: one reads the deliberate failure as a separate step that can be deferred while the main experiment closes, the other reads it as a registered part of this experiment that was never run, making the verdict partial. The failure scenario: the deliberate failure is the one instrument that would distinguish "the marker text is the treatment" from "the prose is the treatment" — without it, the cost-reduction mechanism in the learning block ("a structure that stops the model wandering") is untested by this stop's own registered design.
**Layer of the implied fix:** L3
**Anchor:** `Prediction first, committed, then broken. The deliberate failure is a fifth pair run with build/customizations/phases-v1.0-nomarkers-DELIBERATE-FAILURE`

### §4 step 4 — the build, re-verified rather than rebuilt
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 5 — the preflight pair
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 6 — the batch
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §5 hand re-read — one scored cell, read off the worktree before any sheet was opened
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** finding
**Failure:** The `test-quality` Fisher comparison reports `p = 1.0` with a treated distribution of `1 × 9, 2 × 1` and a control distribution of `1 × 5, 2 × 1, null × 4`. A p of 1.0 requires both arms to have the same count (1 vs 1) over the same denominator (10 vs 10), which means the 4 control nulls are counted as "not anchor 2." A reviewer who excludes nulls from the denominator — arguing a null is an absence of a score, not a score of "not 2" — computes Fisher on 1/10 vs 1/6 and gets p ≠ 1.0. The MDE table says "two-sided Fisher exact at n = 10 per arm," which was registered before nulls were anticipated in the control (E-009's control had no nulls). Two reviewers diverge on whether that registration binds the denominator when the data contains a cell type the registration did not consider. The downstream consequence: the null-rate finding (p = 0.0867, reported in the second hand re-read) is called "the only quality-adjacent difference," but if the anchor-2 Fisher itself shifts when nulls are excluded, the claim that P7 "held" at p = 1.0 is the claim that depends on the unresolved choice.

The file was capped at line 764; any section after Results (including a possible verdict section) was not reviewed.
**Layer of the implied fix:** L3
**Anchor:** `| `test-quality` | 1 × 9, **2 × 1** | 1 × 5, 2 × 1, **null × 4** | `p = 1.0` |`

---

### Goal
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Required reading
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Extract
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### §4 step 2 — design, layers, and the trap
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Build
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predict before you run
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Lab B5.1 — measure against B4
**Verdict:** finding
**Failure:** This section says "B5 closes INCONCLUSIVE on BE-003 too" and assigns a verdict, while the Exit gate section below it carries `<!-- TODO -->` for the "learned phase" criteria — the criteria that decide whether the stop counts as learned at all. Two reviewers diverge: one reads the verdict as the experiment's (E-010's decision rule produces it), independent of the phase's exit gate; the other reads "closes" as a phase-level claim that cannot be made before the exit gate's own pass conditions are defined. The failure scenario: a reader takes "closes INCONCLUSIVE" as the stop's final word, but the exit gate — the mechanism that would confirm or refuse that closure — is an empty template.
**Layer of the implied fix:** L3
**Anchor:** `B5 closes INCONCLUSIVE on BE-003 too, and for a **different reason worth keeping separate**.`

### Deliberate failure
**Verdict:** finding
**Failure:** The section is an HTML comment: `<!-- TODO: instruct it to skip DESIGN and see whether the phase markers still appear. -->`. E-010 registers a deliberate-failure prediction with a mechanism and a falsification condition. The README's section for it is empty. The Lab B5.1 section assigns a verdict without it. Two reviewers diverge on whether the verdict is assignable while the deliberate failure — the one registered instrument that separates "markers are the treatment" from "prose is the treatment" — remains unrun and undocumented here.
**Layer of the implied fix:** L3
**Anchor:** `<!-- TODO: instruct it to skip DESIGN and see whether the phase markers
     still appear. If prose alone holds the workflow, you have measured
     Layer 3 compliance, not enforcement. -->`

### Learning block — BE-003
**Verdict:** finding
**Failure:** The `unexpected_effect` field states `A structure that stops the model wandering is cheaper than one that lets it` as a causal claim. The token-composition section in E-010 — the same data, same author, same session — calls the equivalent reading `still a post-hoc explanation of an unregistered quantity` and writes it `as the hypothesis the next stop should register in advance, not as a result of this one.` Two reviewers diverge: one reads the learning block as the appropriate place for post-hoc interpretation, the other reads the causal sentence as a result presented without the hedge the same data carries elsewhere. The failure scenario: a future stop cites the learning block's "a structure that stops the model wandering is cheaper" as an established finding rather than an unregistered hypothesis, because the learning block does not label it as such.
**Layer of the implied fix:** L3
**Anchor:** `A structure that stops the model wandering is cheaper than one that lets it, and the cheapest single run in the batch is still a control.`

### §5 validation table — BE-003
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exit gate
**Verdict:** finding
**Failure:** The build-track's three clauses are listed, followed by `<!-- TODO -->` for the "learned phase" criteria. The Lab B5.1 section above has already assigned a verdict. Two reviewers diverge: one reads the three build-track clauses as sufficient for the gate and the TODO as supplementary, the other reads the gate as incomplete and therefore the verdict as ungrounded. The failure scenario: the exit gate is the mechanism that converts "the experiment produced a number" into "the stop learned something." With the criteria undefined, the conversion is a claim, not a check.
**Layer of the implied fix:** L3
**Anchor:** `Plus, for this to count as a learned phase: <!-- TODO -->`

### Commit
**Verdict:** skipped
**Failure:** Skipped — the section is an empty template (`<!-- TODO -->`), and there is no content to review.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** `architecture-consistency` scores 2 on 20 of 20 runs — zero variance across both arms. The evaluator gate (P8) also passes 20 of 20. The rubric category is not restating the gate (it measures a different thing — architectural consistency, not correctness), but on this data they carry the same information: nothing moves. This is disclosed ("50 of the rubric's 100 points at zero variance across both arms") and is the reason author decision 9 added BE-004. Not a duplication by design, but a duplication by outcome on this task.
- **Which single section would two reviewers diverge on most, and by how much?** The Decision rule, specifically row 4's `nothing improved`. The divergence is not about whether the data is right — it is about which verdict word applies to data the decision rule did not anticipate. One reviewer lands on INCONCLUSIVE (row 5), the other on NOT DETECTABLE (row 4). That is a one-row difference, and it changes the stop's claim from "unresolvable" to "resolved and empty."
- **What did the artifact not say that it needed to say?** Three things: (1) whether 4 null cells in the control's `test-quality` column belong in the Fisher denominator — the registration said `n = 10` but did not anticipate nulls; (2) whether the deliberate failure was run before the verdict was assigned — the experiment registers it, the README's section is empty, and the verdict is stated; (3) the E-010 file was capped at line 764 of a longer file — any verdict section, limitations, or amendments after that line were not reviewed and may affect the findings above.
