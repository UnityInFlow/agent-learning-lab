# opencode review — memory-policy

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
reviewed_utc:    20260929T114050Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: governance/memory-policy.md
    sha:  d4aed90965b0
    dirty: false
lab_head:        f49b01b
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: governance/memory-policy.md
  verdict: ACCEPT
  summary: An L3 policy document that honestly classifies itself as unenforceable and documents its own review process; the line-level findings are real but none cause a reader to take wrong action.
  blocking: []
  non_blocking:
    - reason: §2 states "nine questions" but the table has 8 rows; "admin inspect / export / delete" can be counted 1, 2, or 3 ways, so the count is indeterminate and the artifact's own rule ("an unanswered row is a real gap and is written as one") would have it write the missing row.
      evidence: governance/memory-policy.md:37-49
    - reason: §1 declares "Everything below is derived state" from Git, but §2 grants Claude auto memory and Observatory Postgres independent authority ("Git wins about what the code is"); the tension is visible but §2 refines §1 within the same table.
      evidence: governance/memory-policy.md:18-23 vs 48-49
    - reason: §6's closing paragraph references "the round-2 findings are the ones that apply to this text" while only round-1 documentation is present; the current review IS round 2, so this is forward-pointing but ambiguous about whether round-2 results exist yet at the time of writing.
      evidence: governance/memory-policy.md:128-131
    - reason: §6 itself records that the artifact was edited three times during its own review (§4a rule 4 violation, "never edit the artifact while its review is running"); the author flagged this rather than tidying it away, and the mitigation (re-run on revised text) is what is happening now.
      evidence: governance/memory-policy.md:126-131
  disputed:
    - finding: §4 classifies "The absence of any staleness check" as "not a layer at all" — Run 1's finding claims this violates a three-step model where step 3 is "otherwise → L3."
      why: The artifact does not define the layer model's three steps; the reviewer applies external model knowledge (the layer model referenced in CLAUDE.md as GUARDRAILS.md). Without that model attached, the disagreement between "L3" and "not a layer at all" cannot be resolved from the artifact alone, and the artifact's own argument ("a record is not a control; no control does not [lie]") is internally consistent — it explicitly argues that absence-of-a-control is categorically different from a narrow L2 control, which is a separate claim from whether the model's taxonomy admits the category.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 148s |
| ollama-cloud/glm-5.2 | ok | 75s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| 2. The governance questions, answered | 1/1 | L3 |
| 4. Layers — applied in order, stopping at the first yes | 1/1 | L3 |
| 1. Ownership — who owns what, and what "Owns" means | 1/1 | L3 |
| 6. §4a review — round 1, and what was done with each finding | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### 1. Ownership — who owns what, and what "owns" means
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 2. The governance questions, answered
**Verdict:** finding
**Failure:** The text says "The README asks **nine** questions of every memory mechanism." The table has 8 rows. "admin inspect / export / delete" could be read as one question (8 total), two questions (9 total), or three (10 total) — none of these readings is the obviously correct one, and nothing in the table or its surrounding text says which. A reviewer who counts 8 rows and cannot make 9 flags a missing question; a reviewer who reads "inspect" and "export / delete" as two separate questions arrives at 9 and sees no problem. They diverge without either being wrong from the text they were given.
**Layer of the implied fix:** L3
**Anchor:** "The README asks nine questions of every memory mechanism. Answering them per system is the point of the exercise; an unanswered row is a real gap and is written as one."

### 3. Lab 9.4's three questions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 4. Layers — applied in order, stopping at the first yes
**Verdict:** finding
**Failure:** The last row classifies "The absence of any staleness check" as "**not a layer at all**." The layer model being applied has three steps, and step 3 says "Otherwise → L3." The absence of a check is not a fix (step 1's "after the fix" has no referent) and nothing executes (step 2 is no), so it lands in "otherwise." A reviewer who applies the model's steps mechanically — which the section header instructs them to do — classifies this as L3. A reviewer who follows the row's own argument ("a record is not a control"; "no control does not [lie]") accepts "not a layer at all." The model defines no such category, so the two reviewers cannot resolve the disagreement from the model itself. The row's rhetorical force — "this is the row that matters" — depends on the classification the model does not support.
**Layer of the implied fix:** L3
**Anchor:** "The absence of any staleness check | **not a layer at all** | This is the row that matters. A narrow L2 control lies to a reader; **no control does not.**"

### 5. What is not built, and the reason
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 6. §4a review — round 1, and what was done with each finding
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- **Does any scoring category duplicate a pass/fail gate?** Not applicable — this artifact is a policy, not a rubric. No scoring categories are present.
- **Which single section would you expect two reviewers to diverge on most, and by how much?** §4, by a full layer label. The disagreement is not about nuance within a category but about which category applies — "L3" vs. "not a layer at all" — and the model's own steps give a different answer than the text's argument. A reviewer who trusts the mechanical application and one who trusts the argument will land one category apart with no shared ground to reconcile on.
- **What did the artifact not say that it needed to say?** The preamble (lines 1–9) was skipped — it carries no heading and is not a top-level key, so it is not reviewed here. It contains the claim "none of it moves a registered variable," which is a claim about the artifact's own content that a reviewer with the registered-variable list could check and one without it cannot; that asymmetry is noted but not raised as a finding because no concrete divergence can be constructed from the text alone.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

### 1. Ownership — who owns what, and what "Owns" means
**Verdict:** finding
**Failure:** The ownership block states `Git → authoritative. Everything below is derived state.`, then lists memtrace, Claude auto memory, and Observatory Postgres beneath it. But Claude auto memory is described in §2 as "the agent, unprompted, during a session" writing "this machine's session preferences" stored "outside both repos" — that is not derived from Git in any sense. Observatory Postgres holds run records that §2 says "win about what happened" — an authoritative, independent record of an event, not a derivation of repository contents. A reviewer reading §1 alone would conclude both systems can be reconstructed from Git; a reviewer reading §2 would conclude neither can. The two sections give opposite answers to the same question, and nothing in the artifact flags the tension.
**Layer of the implied fix:** L3
**Anchor:** `Git                   → authoritative. Everything below is derived state.`

### 2. The governance questions, answered
**Verdict:** finding
**Failure:** The text says "The README asks nine questions of every memory mechanism" and "an unanswered row is a real gap and is written as one." The table has eight rows. If "admin inspect / export / delete" is one question, that is eight questions answered and one missing — but no gap is written for the ninth, violating the artifact's own stated rule. If "admin inspect / export / delete" is three questions, that is ten, not nine. Two reviewers counting differently would either flag a missing row or a miscount, and the artifact gives them no way to reconcile. The ninth question is either silently dropped or the count is wrong, and the artifact's own convention ("an unanswered row is a real gap and is written as one") makes the silence a defect rather than an omission.
**Layer of the implied fix:** L3
**Anchor:** `The README asks nine questions of every memory mechanism. Answering them per system is the point of the exercise; an unanswered row is a real gap and is written as one.`

### 3. Lab 9.4's three questions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 4. Layers — applied in order, stopping at the first yes
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 5. What is not built, and the reason
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### 6. §4a review — round 1, and what was done with each finding
**Verdict:** finding
**Failure:** The closing paragraph says "the round-2 findings are the ones that apply to this text," implying a second review run was performed on the revised artifact. But this file documents only round 1 — there is no round-2 table, no round-2 finding list, no round-2 verdict. A reader cannot tell whether round 2 has run (and its results are missing) or has not run yet (and the sentence is a promise). The distinction matters because the artifact was edited three times during round 1, so round 1's findings were against a different text. If round 2 never happened, the current text has been reviewed only against an earlier draft and the seven "fixed" findings have not been verified against the text that now exists. Two reviewers would diverge: one reads "the round-2 findings are the ones that apply" as evidence round 2 is done; the other reads it as a forward statement of intent with no backing evidence.
**Layer of the implied fix:** L3
**Anchor:** `the round-2 findings are the ones that apply to this text.`

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Not applicable — this is a policy document, not a rubric. §1's `Git → authoritative` and §2's `authoritative vs Git` row do restate the same claim, but neither is a gate.
- Which single section would two reviewers diverge on most, and by how much? §2's "nine questions" against eight table rows. One reviewer counts "admin inspect / export / delete" as three (getting ten), another as one (getting eight), a third goes looking for the missing ninth — three readings, none reconcilable from the text alone.
- What did the artifact not say that it needed to say? Whether round 2 of the §4a review has actually been run, and if so, what it found. The sentence that references round-2 findings provides no evidence the run occurred, and the entire round-1 table is known to have been against a different version of the text.
