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
reviewed_utc:    20260925T185923Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-021-print-mode-mcp-hole-06a.md
    sha:  10b24318db11
    dirty: false
lab_head:        34ccc0c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-021-print-mode-mcp-hole-06a.md
  verdict: ACCEPT
  summary: A pre-registered, mechanically-read experiment with its own positive control, decision rule, and a deliberately failed containment claim — substantive content is sound, with one framing gap (the L2 label is not scoped to the measured dimension) that the Follow-up section already partially mitigates.
  blocking: []
  non_blocking:
    - reason: The Decision settles `--strict-mcp-config` as L2 flatly, while the experiment's own deliberate-failure arms (D/D2/D3) tested the upward walk only WITHOUT the flag. A reader who applies "L2" to the above-cwd case would overstate the measurement; Follow-up item 1 names the upward-walk exposure, but the "What this does NOT decide" list does not include "whether the flag blocks a `.mcp.json` above the cwd." The L2 claim is correct for the cwd dimension and unmeasured for the upward dimension — that qualification is missing from the Decision section itself.
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:486, experiments/E-021-print-mode-mcp-hole-06a.md:497 - reason: Prediction 4's registered detector greps for specific strings (`can_use_tool`, `permission_request`, `permission_denial`, prose strings) and found nothing on 26 runs; the artifact substitutes structural evidence (`permission_denials: []`, `status: connected`, non-interactive completion) and marks the prediction "held, on better evidence than the one registered." The substitution is candid, but the registered prediction text is "no approval prompt appears in either arm's stream" (an event-observable claim) while the substituted evidence addresses no-blocking-approval (a behaviour claim) — an auto-resolved approval event would be consistent with both the structural evidence and the artifact's hypothesis that print mode cannot display the prompt. The artifact's transparency makes this non-blocking rather than hidden.
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:235, experiments/E-021-print-mode-mcp-hole-06a.md:451    - reason: The controlled-variables section pins `claude` 2.1.282 as recorded "before the first run and again after the last," but the deliberate-failure arms D/D2/D3 were registered and run after that section was written. Whether `claude --version` was re-recorded for the extension arms is not stated; the version for D/D2/D3 is inferred from a10-minute window. Within the bound of plausibility, but not directly evidenced.
      evidence: experiments/E-021-print-mode-mcp-hole-06a.md:122
  disputed:
    - finding: Decision-rule row 3's condition is `P ok · A = 0 of 5` with no mention of B, so a (P ok, A=0, B≥1) combination reaches row 3 and receives the "NO HOLE IN THIS CONFIGURATION" label — wrong for that subcase, since A=0 with B≥1 would mean the flag is adding the `.mcp.json` source rather than filtering it.
      why: The artifact's claim that rows are disjoint is technically violated by this subcase, but the case is implausible per the documented mechanism (the flag cannot add a source it does not also reach on its own), and the prescribed action (run A′) is reasonable under both readings. A reviewer following the artifact's mechanism would not land on a wrong action; a reviewer reading the table purely combinatorially would. The defect is real but cannot mislead into wrong record-keeping, so non-blocking at most.
    - finding: Cross-cutting "What did the artifact not say that it needed to say" — whether `--strict-mcp-config` blocks a `.mcp.json` located above the run's working directory is unmeasured and unsettled.
      why: This is the same gap as non_blocking finding1, restated. The artifact does name it implicitly (Follow-up item 1: "an operator `.mcp.json` anywhere above a benchmark worktree — not inside it, and not stopped by the worktree's own git root — reaches every `claude -p` run that omits `--strict-mcp-config`"), and Follow-up item 3 registers "how far up the walk goes" as open. The Follow-up items qualify the L2 claim more than the line-level critic credits; the gap is one of where the qualification appears (Follow-up vs Decision), not whether it appears.
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| ollama-cloud/glm-5.2 | ok | 210s |
| ollama-cloud/glm-5.2 | ok | 195s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Decision rule | 1/1 | L3 |
| Which predictions held | 1/1 | L3 |
| Failure analysis | 1/1 | L3 |
| Decision | 1/1 | L3 |


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
**Verdict:** finding
**Failure:** Row 3's condition is "P ok · A = 0 of 5" with no mention of B, so A=0, B=5 reaches row 3 and receives the verdict "NO HOLE IN THIS CONFIGURATION." But A=0 with B=5 means the tool is absent without `--strict-mcp-config` and present with it — the flag is *adding* the `.mcp.json` source rather than filtering it, which is the opposite of "no hole." Two reviewers diverge: one follows row 3 as written and reports "no hole, run A′"; the other reads B=5 alongside A=0 as an inverted flag, a different and more serious finding that no row captures. The prescribed action (run A′) is the same either way, but the label and verdict text are wrong for this subcase. The probability is low — under the stated mechanism B ≤ A — but the decision rule's own claim is that "every combination of (P, A-count, B-count) reaches exactly one," and the combination (P ok, A=0, B=5) reaches a row whose label misdescribes it.
**Layer of the implied fix:** L3
**Anchor:** `| **3 — NO HOLE IN THIS CONFIGURATION** | P ok · A = 0 of 5 | The documented sentence does not describe this launch. **Run A′.**`

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
- Does any scoring category duplicate a pass/fail gate? No. This experiment has no scoring categories — no rubric, no evaluator, no codex-score.sh. The decision-rule rows are verdict conditions, not score dimensions, and none restates a gate.
- Which single section would you expect two reviewers to diverge on most, and by how much? The Decision rule, on the row 3 subcase where A=0 and B≥1. The divergence is narrow — both would run A′ — but one calls it "no hole" and the other calls it an inverted flag. By a full verdict label, not by a hairline.
- What did the artifact not say that it needed to say? The artifact does not state the CLI version under which arms D, D2, and D3 were run. The controlled-variables section pins 2.1.282 and says it is recorded "before the first run and again after the last," but the deliberate-failure arms were added after the main batch, and the section that registers the version was written before they existed. The timestamps (everything within ~10 minutes) make a version change implausible, but the version for the extension arms is inferred from timing, not stated.

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
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Deliberate failure, extension — arms D2 and D3, registered BEFORE either exists
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

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
**Verdict:** finding
**Failure:** Prediction 4 is registered as *"No approval prompt appears in either arm's stream — no `permission` / `can_use_tool` event and no assistant text asking to approve an MCP server — on 10 of 10 runs of A and B."* The registered detector grepped for `can_use_tool`, `permission_request`, `permission_denial` and two prose strings, and found nothing on 26 runs. The artifact then pivots to structural evidence — `permission_denials: []` and servers reaching `connected` status — and marks the prediction "held, on better evidence than the one registered." Two reviewers diverge here: one reads "servers connected without delay, so no approval prompt blocked the run" and accepts prediction 4 as held; the other reads the prediction's actual text — *"no approval prompt appears in either arm's stream"* — and notes that `permission_denials: []` measures tool-use denials, not MCP-server approval events, and that a non-blocking auto-resolved approval event in the stream would still produce `permission_denials: []` and `connected` servers. The grep finding nothing could mean "no approval event" or "the stream uses different event names than the four the detector searched for" — and the artifact never distinguishes these. The prediction is about a specific stream observable; the substitute evidence is about blocking behaviour. A reviewer who accepts "held" and a reviewer who reads it as "the registered observable was never measured, only inferred from a proxy" would land on different verdicts for the same row of the same table.
**Layer of the implied fix:** L3
**Anchor:** *"held, on better evidence than the one registered"* and *"What actually carries prediction 4 is structural, and was found by reading the stream rather than by trusting the column"*

### Failure analysis
**Verdict:** finding
**Failure:** The section is transparent that the registered detector for prediction 4 never fired, and that is good practice. But the section then claims the prediction held on structural evidence without acknowledging that the structural evidence measures a different claim than the prediction states. The section says: *"every `result` record has `permission_denials: []` and `terminal_reason: completed`, and in arm A the servers reached `status: connected` with their tools delivered inside a five-second non-interactive run. A run that had waited for approval could not have delivered them."* This proves no *blocking* approval step. It does not prove no approval *event* appeared in the stream — an event that was auto-resolved by the CLI in print mode (where there is no user to answer it) would be consistent with all three observations. The artifact's own hypothesis section says the approval prompt *"is not in the path at all in print mode"* — but "not in the path" (non-blocking) and "does not appear in the stream" (no event) are different claims, and the experiment's evidence addresses only the first. Two reviewers reading this section would disagree on whether "the registered prediction held; the registered detector is not the reason" is an honest instrument-defect report (the prediction was about blocking, and blocking was refuted) or a category swap (the prediction was about stream events, and stream events were never measured).
**Layer of the implied fix:** L3
**Anchor:** *"What actually carries prediction 4 is structural, and was found by reading the stream rather than by trusting the column: every `result` record has `permission_denials: []` and `terminal_reason: completed`, and in arm A the servers reached `status: connected` with their tools delivered inside a five-second non-interactive run. A run that had waited for approval could not have delivered them."*

### Sanity checks
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** The Decision settles `--strict-mcp-config` as *"L2 control that executes"* and says *"the keep is now measured rather than assumed."* The measurement that supports this is the A-vs-B contrast: file in the run's cwd, flag on vs off, 5-of-5 vs 0-of-5. But the project's actual exposure — discovered by the experiment's own deliberate-failure arms D, D2 and D3 — is a `.mcp.json` *above* the worktree, not inside it. Arms D/D2/D3 all use arm-A flags (no `--strict-mcp-config`), so they prove the loader walks upward *without* the flag. They never test whether the flag *blocks* the upward walk. The Decision's L2 label is stated without qualification — not "L2 on the cwd dimension, unmeasured on the above-cwd dimension" — and the "What this does NOT decide" list does not include "whether `--strict-mcp-config` blocks an above-cwd `.mcp.json`." Two reviewers diverge: one says "the flag's documented mechanism is a source filter, so if it blocks one source it blocks all"; the other says "this experiment was built because the documentation was not trusted, the upward walk was itself unexpected, and the one case that matters for the project's benchmark runs — operator `.mcp.json` above the worktree, with the flag on — was never run." The Follow-up item 3 registers "how far up the walk goes" as open, but only without the flag; whether the flag closes the upward walk is not named as open, closed, or anything.
**Layer of the implied fix:** L3
**Anchor:** *"The workbook's provisional layer label is settled: `--strict-mcp-config` is L2. Something executes and rejects the configuration, and the rejection is visible in the run's own delivered tool set on 5 of 5 against a control that receives it on 5 of 5."*

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Cross-cutting
- Does any scoring category duplicate a pass/fail gate? No. The decision rule rows are the gate; the MDE table is the detection threshold; neither restates the other. The deliberate-failure arms are explicitly excluded from the A-vs-B decision rule.
- Which single section would you expect two reviewers to diverge on most, and by how much? **Decision**, by a full verdict flip. One reviewer reads "L2 control that executes" as settled by the 5-of-5 / 0-of-5 contrast and accepts it; the other reads the same section alongside the D/D2/D3 results and sees that the flag was never tested against the above-cwd case the project actually faces, making "L2" a claim about the measured dimension generalized to an unmeasured one. The Failure-analysis prediction-4 issue is the second most likely divergence, but it is smaller — a disagreement about what "held" means for one of nine predictions, not about the headline label.
- What did the artifact not say that it needed to say? Whether `--strict-mcp-config` blocks a `.mcp.json` located above the run's working directory. The experiment discovered the loader walks upward (arms D/D2/D3, all without the flag) and then settled the flag as L2 without testing it against the upward walk. The project's benchmark runs happen in worktrees nested under operator-controlled directories, so the above-cwd case is the one that matters. The artifact's own motivation was *"does `--strict-mcp-config` actually stop it?"* — and for the case that matters, the answer is still taken on the flag's help text, which is the documentation the experiment was built to not trust.
