# opencode review — E-021-print-mode-mcp-hole-06a

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
reviewed_utc:    20260925T195204Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-021-print-mode-mcp-hole-06a.md
    sha:  17ea0db7427f
    dirty: false
lab_head:        aa98487
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — REJECT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-021-print-mode-mcp-hole-06a.md
  verdict: REJECT
  summary: The artifact registers arm E (DF5) to test whether `--strict-mcp-config` blocks a `.mcp.json` above the cwd, the §4a disposition of finding 3 announces that "It is answered by arm E," and the Decision settles "--strict-mcp-config is L2" without qualification and Follow-up item 1 says "Nothing to fix: the flag is passed on every run" — but arm E was never run (26 runs reported, not 31; DF5 is absent from the Results table, "Which predictions held," Spend, and Follow-up; spend stayed at $0.2393, the post-D3 level, instead of the ~$0.29 it would land on with arm E included), so the L2 label is unproven for the only configuration location this project's benchmark worktrees are operationally exposed to.
  blocking:
    - reason: The §4a review's disposition of finding 3 and the Decision's unqualified L2 label are stated as if arm E was run and answered; arm E was registered but never executed.
      wrong_action: A reader trusts the Decision's "settled L2" and Follow-up item 1's "nothing to fix: the flag is passed on every run," concludes `--strict-mcp-config` blocks an operator's `.mcp.json` from any location relative to the run, and stops there — never learning that the flag's effect on a `.mcp.json` ABOVE the cwd was never measured. The §4a review's own framing of finding 3 — "every benchmark run this project has ever made was exposed to any `.mcp.json` above its worktree" (line 559–561) — is exactly the failure scenario the artifact's current framing invites.
      anchor: "It is answered by **arm E**, registered above with its prediction committed before the arm existed, rather than by softening a sentence."
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:553
    - reason: DF5 is absent from every post-run section that follows the deliberate-failure extension, so the registered prediction has no verdict and no row saying "not run / pending / deferred."
      wrong_action: A reader scans "Which predictions held" (the experiment's scorecard) or the Results raw table and concludes every registered prediction has been answered. The contingency prediction 5 (A′) is properly listed as "not run" with its trigger condition (line 456); DF5 — which carries the higher-stakes refutation, "if DF5 is refuted... every benchmark run this project has ever made was exposed" (line 330) — receives no comparable disposition.
      anchor: "**Four of the five main predictions held and both deliberate-failure predictions were refuted.**"
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:462
    - reason: The Spend section reports "$0.2393 of the registered $0.50 ceiling, over 26 runs" and the post-D3 prediction in the arm E section gives the same number — the budget did not move past the D3 level, confirming arm E was not executed. 26 = P(1)+A(5)+B(5)+D(5)+D2(5)+D3(5); 31 would include arm E.
      wrong_action: A reader cross-checking whether arm E ran against the spend math finds the population is shorter than the section's arm inventory implies; combined with the §4a claim that arm E "answered" the question, the artifact contradicts itself, and a reader using the L2 label as a settled result is acting on a claim the artifact's own accounting shows is unmade.
      anchor: "**$0.2393 of the registered $0.50 ceiling, over 26 runs.** The ceiling was not reached; the batch stopped at its registered `n`, not on budget."
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:446
  non_blocking:
    - reason: Decision-rule row 3 keys only on "A = 0 of 5" while the test of "A = 0 of 5 AND B ≥ 1 of 5" would yield "flag is adding a source" rather than "no hole" — the rule is sound on the combination that occurred (5/0/5 → row 1) but the rule itself is exhaustive but not sound on one cell, and the combination did not occur so row 3 never had to be wrong on disk. Dispositioned in §4a item 1 (lines 539–548), with the artifact's reasoning that "a decision rule is registered before data and stays as registered, wrong rows included."
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:539-548
    - reason: Prediction 4's registered string-grep detector (`can_use_tool`, `permission_request`, `permission_denial`, two prose strings) never fired; the registered prediction holds via a different mechanism — structural `result.permission_denials: []` and `terminal_reason: completed` plus the timing of arm A's tools being delivered inside a five-second non-interactive run. Disclosed in Failure analysis item 2, including the candid line that "a control that has never been shown to reject anything is indistinguishable from one that rejects nothing."
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:484-494
    - reason: The F13 detector matched the routine per-run `rate_limit_event`/`allowed` record on every run and would have emptied the population into the exclusion list; corrected to a structural `jq` test before the batch started, with no run in flight, and the run it mislabelled was re-derived by hand. Disclosed in Failure analysis item 1.
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:472-482
  disputed:
    - finding: "The CLI version is not re-recorded for arms D, D2 and D3" (reviewer 2)
      why: The §4a review at lines 556–562 argues that each driver writes `claude : $("$CLAUDE_BIN" --version)` into its evidence directory's `HASHES.txt` before the first run of the arm and refuses to start if the recorded version is not the registered one. I have not read `HASHES.txt` for `deliberate-failure-20260925T185104Z/`, `walk-D2-20260925T185343Z/`, or `walk-D3-20260925T185343Z/`, and neither has the reviewer — the claim is sustained by the artifact's own description of its precondition and by the `verify-mcp-hole-probe-guards.sh` cases C/D the §4a review names, both outside this document. The defect, if real, would not change the rejection above; the artifact's text makes a defensible case that the invariant is enforced rather than observed.
  needed_to_decide: []
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 191s |
| ollama-cloud/glm-5.2 | ok | 251s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Deliberate failure, second extension — arm E, registered BEFORE it exists | 1/1 | L3 |
| Decision | 1/1 | L3 |
| Deliberate failure — §4 step 9, registered BEFORE it runs | 1/1 | L2 |
| Prediction-commit ordering | 1/1 | L3 |
| Results | 1/1 | L2 |
| Which predictions held | 1/1 | L3 |
| §4a review — amendments, added at step 13a and editing nothing above | 1/1 | L2 |
| Follow up | 1/1 | L3 |


---

## Run 1 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

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

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — §4 step 9, registered BEFORE it runs
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure, extension — arms D2 and D3, registered BEFORE either exists
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure, second extension — arm E, registered BEFORE it exists
**Verdict:** finding
**Failure:** Arm E is registered with prediction DF5, its budget is stated as inside the ceiling, and the §4a review says it "answers" the L2-without-qualification finding — but arm E was never run. The Spend section reports $0.2393 over 26 runs (P=1, A=5, B=5, D=5, D2=5, D3=5 = 26; arm E would make 31). The Results table has no row for E. The "Which predictions held" table has no DF5 row. The Prediction-commit ordering section has no arm E commit sha. Two reviewers diverge: one reads the §4a review's "answered by arm E" as "the answer is in"; the other notes arm E is absent from every post-run section and the answer is not in. The operational consequence is concrete: DF5's refutation case — "the tool appears with the flag ON and the file above the cwd" — is the scenario that would overturn the L2 label, and it is the one scenario the artifact registered a test for and then did not report.
**Layer of the implied fix:** L3
**Anchor:** "It is answered by **arm E**, registered above with its prediction committed before the arm existed, rather than by softening a sentence."

### Prediction-commit ordering
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Failure analysis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** The Decision states "`--strict-mcp-config` is L2" and "the workbook's provisional layer label is settled" without the scope qualification that arm B only tested a `.mcp.json` in the cwd. The §4a review (finding 3, this artifact's own text) flags exactly this: every arm with the file above the cwd ran with the flag OFF, so "L2" is proven only for the cwd case. Arm E was registered to test the flag ON with the file above — the operationally important combination — and its result is absent (see the arm E finding). A reader who acts on the Decision as written believes the flag rejects a `.mcp.json` from any source. If arm E (unrun) would have refuted DF5, the flag rejects the cwd's file but not an ancestor's, and an operator with a `.mcp.json` in their home directory who runs a benchmark worktree below it is exposed with the flag ON. The Follow-up item 1 compounds this: it says "One flag at `run-agent.sh:776` is the whole boundary. Nothing to fix: the flag is passed on every run" — which is only true if arm E holds, and arm E has not been run.
**Layer of the implied fix:** L3
**Anchor:** "The workbook's provisional layer label is settled: `--strict-mcp-config` is L2. Something executes and rejects the configuration, and the rejection is visible in the run's own delivered tool set on 5 of 5 against a control that receives it on 5 of 5."

### §4a review — amendments, added at step 13a and editing nothing above
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Follow up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? Name both. No scoring categories exist in this artifact — it has no rubric and no evaluator. The decision rule's row 1 verdict ("L2") and the Decision section's L2 label are the same claim stated twice, but neither is a gate; both are post-hoc verdicts.
- Which single section would you expect two reviewers to diverge on most, and by how much? The Decision section. One reviewer reads "L2" as settled for all configuration sources; the other reads the §4a review's finding 3 and the arm E registration, notices arm E's result is absent, and reads "L2" as proven only for the cwd. The divergence is on whether the label is qualified, and it is wide enough to change an operator's action: the first trusts the flag against an ancestor `.mcp.json`; the second does not.
- What did the artifact not say that it needed to say? It needed to say either arm E's result or that arm E was registered but not run, and the Decision needed to carry the scope qualification either way. The §4a review identified the gap and registered the test; the post-run sections did not close it.

---

## Run 2 of 2 — ollama-cloud/glm-5.2


> lab-critic · glm-5.2

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

### Exclusions
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure — §4 step 9, registered BEFORE it runs
**Verdict:** finding
**Failure:** Arm E is registered in the "Deliberate failure, second extension" sub-section with prediction DF5 (tool ABSENT 5 of 5 with `--strict-mcp-config` ON and `.mcp.json` one level above cwd), at a cost of ~$0.05 inside the $0.50 ceiling, with $0.2393 spent after D3 leaving ~$0.26 of headroom. The Results section reports 26 runs (P=1, A=5, B=5, D=5, D2=5, D3=5 = 26); arm E would add 5 for 31. Arm E appears nowhere in Results, "Which predictions held," or Spend. DF5 appears in no results table. No statement anywhere — not in Follow-up, not in §4a, not in Decision — says arm E was deferred, skipped, or will be run later. Two reviewers diverge: one reads the arm E registration and the §4a claim that it "is answered by arm E" and concludes DF5 was run and held; another counts the runs (26, not 31), finds no DF5 result, and concludes arm E was never executed. The artifact produces a wrong answer for any reader who relies on the §4a statement that the L2-qualification gap "is answered by arm E" — the answering experiment was registered but not run, and the gap remains open.
**Layer of the implied fix:** L2
**Anchor:** "It is answered by **arm E**, registered above with its prediction committed before the arm existed, rather than by softening a sentence."

### Prediction-commit ordering
**Verdict:** finding
**Failure:** The ordering table records the prediction commit sha and timestamp for the main predictions, arm D (`054b0b8`), and arms D2/D3 (`2c27630`). Arm E's prediction commit — dated 2026-09-25T19:40Z in its own sub-section header — has no sha and no entry in this table. A reader verifying pre-registration ordering for arm E has nothing to check against. This is a minor gap subsumed by the larger arm E absence, but it is a separate concrete failure: the section's stated purpose is to record prediction-commit ordering from git, and one registered prediction is missing from it.
**Layer of the implied fix:** L3
**Anchor:** "Arm D's prediction was committed at `054b0b8` (2026-09-25T18:50Z) before arm D's driver existed; arms D2 and D3's predictions at `2c27630` (2026-09-25T18:53Z) before theirs did."

### Observed telemetry
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Results
**Verdict:** finding
**Failure:** The raw results table lists arms P, A, B, D, D2, D3 — six arms. Arm E is absent. The "deliberate failure, and its extension" table reports DF1–DF4 but not DF5. The Spend section says "$0.2393 of the registered $0.50 ceiling, over 26 runs" — 26 is the count without arm E (P+ A+ B+ D+ D2+ D3 = 1+5+5+5+5+5 = 26). A reader of Results alone would not know arm E existed. The failure scenario: one reviewer reads Results and concludes the experiment covered six arms and reached its conclusion; another reads the Deliberate failure sub-sections and knows a seventh arm was registered with a high-stakes prediction ("if DF5 is refuted… every benchmark run this project has ever made was exposed") and sees no trace of it in the results. The two reach different understandings of what the experiment proved.
**Layer of the implied fix:** L2
**Anchor:** "**$0.2393 of the registered $0.50 ceiling, over 26 runs.**"

### Which predictions held
**Verdict:** finding
**Failure:** The table reports predictions 1–5 and DF1–DF4. DF5 is absent. There is no row saying "DF5 — not run" or "DF5 — pending." The table's structure implies every registered prediction has a verdict. A reader scanning this table as the experiment's scorecard would conclude the experiment has no outstanding predictions. The contingency prediction 5 (A′) is listed as "not run" with a clear trigger condition — DF5 deserves the same treatment and does not receive it.
**Layer of the implied fix:** L3
**Anchor:** "DF4 | a git root at the cwd does NOT stop the walk, 5 of 5 | `2c27630`, 18:53Z | present 5 of 5; the file sits two levels **above** the repository root | **HELD**"

### Failure analysis
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** The Decision states "`--strict-mcp-config` is L2" without qualification. Arm B proved the flag filters a `.mcp.json` in the cwd. Arms D, D2, and D3 proved the loader walks upward with the flag OFF. The combination that matters operationally — flag ON, file above cwd — is arm E, which was registered but never run (26 runs, not 31). The §4a review (finding 3, accepted as "the most valuable finding of the four rounds") explicitly identified this: "every arm that put the `.mcp.json` above the cwd — D, D2 and D3 — ran with the flag OFF." The Decision restates the unqualified L2 label that the §4a review said was wrong. Two reviewers diverge: one reads the Decision and concludes L2 is settled; another reads §4a finding 3 and the arm E registration, notices arm E's result is absent, and concludes the L2 label is unproven for the above-cwd case — which is the only case that matters for this project's benchmark worktrees.
**Layer of the implied fix:** L2
**Anchor:** "**The workbook's provisional layer label is settled: `--strict-mcp-config` is L2.** Something executes and rejects the configuration, and the rejection is visible in the run's own delivered tool set on 5 of 5 against a control that receives it on 5 of 5."

### §4a review — amendments, added at step 13a and editing nothing above
**Verdict:** finding
**Failure:** Finding 3 says the unqualified L2 label "is answered by arm E, registered above with its prediction committed before the arm existed, rather than by softening a sentence." Arm E was never run. The claim that the finding "is answered" is false — a prediction registered before an arm exists does not answer a question; running the arm and reporting the result does. The artifact chose the stronger fix (run arm E, an L2 test) over the weaker one (qualify the prose, L3), announced that choice, and then did not execute it. A reader who trusts this section's disposition of finding 3 believes the L2-qualification gap is closed. It is not.
**Layer of the implied fix:** L2
**Anchor:** "It is answered by **arm E**, registered above with its prediction committed before the arm existed, rather than by softening a sentence."

### Follow up
**Verdict:** finding
**Failure:** The Follow-up section lists four items, none of which names arm E or DF5 as open, pending, or deferred. Item 3 registers "how far up the walk goes" as open — but arm E (does the flag stop the walk?) is a different question and is not listed. The section's silence on arm E is the same absence that appears in Results, "Which predictions held," and Spend: a registered prediction with a high-stakes refutation condition ("every benchmark run this project has ever made was exposed") that appears nowhere in the post-run sections. A reader using Follow-up as the experiment's forward-looking agenda would not know arm E exists.
**Layer of the implied fix:** L3
**Anchor:** "Registered as open, not run here: how far up the walk goes (`$HOME`? `/`?), and whether `--add-dir` or a symlinked worktree changes it."

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No scoring exists at this stop — the experiment has no rubric and no evaluator, by design. The decision rule is the only gate, and its row 1 verdict ("CONTROL EXECUTES") is the same claim the Decision section restates as L2. That is not a duplication; it is the rule producing the verdict. The defect is that the verdict's L2 label is unqualified, and the qualifying test (arm E) was registered but not run.
- Which single section would two reviewers diverge on most, and by how much? **Decision**, by a wide margin. One reviewer reads "`--strict-mcp-config` is L2" and the 5-of-5 / 0-of-5 evidence and accepts the label. Another reads the §4a review finding 3, the arm E registration with its high-stakes refutation condition, counts 26 runs (not 31), and concludes the L2 label is unproven for the above-cwd case — which is the only case that matters for this project's worktrees. The first reviewer's reading is defensible from the Decision section alone; the second's is defensible from the §4a and arm E sections. The artifact does not reconcile them.
- What did the artifact not say that it needed to say? That arm E was registered, never run, and that the L2 label in the Decision is therefore unqualified on the dimension arm E was designed to test. The artifact says the opposite — §4a finding 3 says the gap "is answered by arm E." One sentence in Follow-up — "arm E registered, not run; the L2 label is unqualified for above-cwd files with the flag on" — would have closed the gap between what the artifact claims and what it measured. Its absence is the single largest discrepancy in the artifact.
