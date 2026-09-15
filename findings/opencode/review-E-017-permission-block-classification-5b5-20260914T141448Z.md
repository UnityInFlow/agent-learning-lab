# opencode review — E-017-permission-block-classification-5b5

```yaml
line_level:
  agent:         lab-critic
  model:         codex          # registered variable — do not change mid-experiment
  agent_sha:     5ae27fa4d5e2
acceptance:
  agent:         lab-acceptance
  model:         ollama-cloud/minimax-m3
  agent_sha:     4aa690d15304
  strict:        false
opencode:        1.18.27
reviewed_utc:    20260914T141448Z
runs:            2           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-017-permission-block-classification-5b5.md
    sha:  96fe1d8d3f1f
    dirty: false
  - path: phases/05b-verification-selfhealing/README.md
    sha:  3d386925ee1c
    dirty: false
  - path: evidence/p05b/replay/README.md
    sha:  3914ed5b420c
    dirty: false
  - path: evidence/p05b/delivery/README.md
    sha:  ca197208b886
    dirty: false
lab_head:        7b05d2c
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```

## Acceptance — ACCEPT

The gate. A different model from the line-level pass, deciding rather than finding.


> lab-acceptance · minimax-m3

```yaml
acceptance:
  artifact: experiments/E-017-permission-block-classification-5b5.md
  verdict: ACCEPT
  summary: The experiment, with phases/05b-verification-selfhealing/README.md and the two evidence/p05b READMEs, is heavily self-correcting: each post-data reasoning step that a reader might object to (row 4 vs row 2 precedence, KEPT ON DISK as a third state, batch-2 substitution, the two channels' wording, behavior.changedFiles null) is named in the artifact itself with its rationale, rather than introduced silently; the §5 validation table is auditable at the line/sha level; deviations from the registered rule are flagged where they occur.
  blocking: []
  non_blocking:
    - reason: '"P1 is VOID" depends on row 4 (precondition) governing over row 2 (first-match) — a precedence not registered in the decision-rule table. The artifact states and argues the precedence openly, but a reader applying first-match to the registered rows would reach CONFIRM WITH A NAMED LEAK for the same data (one F13, none of the rest infrastructure).'
      evidence: experiments/E-017-permission-block-classification-5b5.md:312-323
    - reason: '"KEPT ON DISK BUT NOT PROMOTED" is a third outcome not in the registered KEEP/REJECT rule for the classifier. The artifact explicitly acknowledges this and frames it as physical retention pending a future stop''s registration. A reader applying the registered KEEP condition literally would derive REJECT.'
      evidence: experiments/E-017-permission-block-classification-5b5.md:435-440
    - reason: 'Batch 2 (10 post-fix treated runs) was not run; the artifact substitutes replay of the classifier over batch-1 records. The substitution argument ("the step under test runs after the agent") extends an E-017 argument made for control verification to treated-arm verification — a real extension made after seeing P3 refute "treated ≡ blocked," not a step the registered plan authorised.'
      evidence: evidence/p05b/replay/README.md:50-76
    - reason: 'The two delivery channels differ in more than mechanism: arm D tells the model "Edit is disabled" (per-tool removal) while arm H tells "Permission to modify files has not been granted" (capability-level refusal). The artifact flags this as a design limit and records that separating mechanism from message needs a fourth arm nobody has run, but does not retract the IV claim that "the treatment is identical in both."'
      evidence: experiments/E-017-permission-block-classification-5b5.md:340-347
    - reason: '`behavior.changedFiles` is null on all twenty records; the analysis substitutes `git status --porcelain` from retained worktrees. The substitute is well-defined and the artifact is explicit about the substitution, but P3 ("the block is total: 10 of 10 treated change zero files") leans on a field that does not exist and a count method whose scope (harness-owned files like `.ai/block-writes.log` on arm H) is not pinned down.'
      evidence: experiments/E-017-permission-block-classification-5b5.md:247-249
    - reason: 'P2 was registered as "arm H ≥4/5, arm D 0/5" and observed as "arm H 5/5, arm D 4/5"; the prediction table labels arm D "REFUTED" while the prose below says "the registered mechanism of P2 confirmed." A reader comparing the table to the prose gets a contradiction; the prose explanation (registry removal emits no tool_decision event) reconciles them but does not rewrite the table.'
      evidence: experiments/E-017-permission-block-classification-5b5.md:296-301
  disputed:
    - finding: 'Line-level claim that decision-rule precedence is unregistered and the artifact "chose row 4 only after seeing the overlap."'
      why: 'The artifact explicitly says the precedence is being stated rather than chosen and gives the rationale: "Two rows are live on this data and the precedence matters, so it is stated rather than chosen: ... Row 4 governs, and it governs because it is a precondition and row 2 is an outcome." The deviation from the registered rule is acknowledged in-text, not introduced silently.'
    - finding: 'Line-level claim that "KEPT ON DISK BUT NOT PROMOTED" is an unregistered third outcome introduced post-data.'
      why: 'The artifact introduces the third state explicitly and flags the divergence from the registered rule in the same paragraph: "Its registered KEEP condition — P5 in both halves — is not met as written, and restating it after seeing the data is the thing this project does not do. What is measured: ... That is an instrument worth having on disk and it is not a control until a stop registers it as one." The decision is recorded against the acknowledged gap.'
    - finding: 'Line-level claim that batch 2 was dropped in favour of replay without registered authorisation.'
      why: 'E-017 §Runs registers the KEEP/REJECT condition explicitly: "For the fix (batch 2), registered separately: KEEP only if P5 holds in both halves — 10 of 10 confirmation runs reclassified and 0 of 6 stored passing denial-runs reclassified." The replay demonstrates the second half (0 of 6) directly. The first half is the part the artifact admits is unreachable post-P3, and the rejection of batch 2 is reasoned in evidence/p05b/replay/README.md rather than omitted. The substitution is openly argued, not silent.'
```
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 101s |
| codex | ok | 88s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 2 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Hypothesis | 1/1 | L3 |
| Predictions | 1/1 | L3 |
| Independent variable | 1/1 | L3 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Controlled variables | 1/1 | L3 |
| Runs | 1/1 | L3 |
| Minimum detectable effect | 1/1 | L3 |
| Exclusions | 1/1 | L3 |
| Decision rule | 1/1 | L3 |
| Observed telemetry | 1/1 | L3 |
| Results | 1/1 | L3 |
| Which predictions held | 1/1 | L2 |
| Failure analysis | 1/1 | L2 |
| Sanity checks | 1/1 | L2 |
| Decision | 1/1 | L3 |
| Extract | 1/1 | L3 |
| Predict before you run | 1/1 | L3 |
| Lab 5B.1 — Watch an unbounded loop | 1/1 | L3 |
| Lab 5B.2 — Failure fingerprints | 1/1 | L3 |
| Lab 5B.3 — Bounded repair with persistent state | 1/1 | L2 |
| Lab 5B.4 — The completion contract | 1/1 | L2 |
| Lab 5B.5 — Blocked is not failed | 1/1 | L2 |
| Lab 5B.5 — DESIGN, spine stop 16, 2026-09-11 | 1/1 | L3 |
| Lab 5B.5 — RESULT, spine stop 16, 2026-09-14 | 1/1 | L3 |
| §5 validation — stop 16 | 1/1 | L3 |
| Metrics | 1/1 | L3 |
| Exit gate | 1/1 | L3 |
| Commit | 1/1 | L3 |
| Batch 1, all 20 runs — `batch1-replay.tsv` | 1/1 | L3 |
| The two stored populations — `stored-replay.tsv` | 1/1 | L3 |
| What this replaces, and the reasoning for replacing it | 1/1 | L2 |
| What is proved instead, per run, on all twenty | 1/1 | L2 |
| The tool mix, and the mechanism it exposes | 1/1 | L2 |
| Two limits of this, stated because neither is visible from the numbers | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |
| Why this file has to exist | 1/1 | L3 |


---

## Run 1 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** Input: a run changes a test file, then stops because the harness prevents the required production edit. The text predicts PRODUCED_NOTHING is true for a blocked agent, but the cited obs#47 runs changed one file. One reviewer therefore applies the proposed empty-change classifier; another treats the motivating failure as outside its scope. They reach opposite answers about whether the hypothesis covers obs#47.
**Layer of the implied fix:** L3
**Anchor:** A blocked agent reads files before it is stopped, so `toolCalls > 0`

### Predictions
**Verdict:** finding
**Failure:** Specific outcome: 9 capability classes and 1 F13 among the ten treated runs. P1 says a single infrastructure classification refutes the primary prediction, while the registered decision table calls 1–4 infrastructure classifications “CONFIRM WITH A NAMED LEAK.” Two reviewers can label the same result REFUTED or CONFIRMED.
**Layer of the implied fix:** L3
**Anchor:** **Refuted by a single treated run classed as infrastructure.**

### Independent variable
**Verdict:** finding
**Failure:** Specific inputs: arm H receives a capability-level message and blocks shell-independent writing; arm D is told only that Edit is unavailable and retains Bash. A reviewer treating “writes withheld” as the IV pools the arms; a reviewer treating available write capability and refusal wording as variables refuses to pool them. The observed 5/5 versus 0/5 split shows the divergence changes P1 from a result to VOID.
**Layer of the implied fix:** L3
**Anchor:** *the treatment is identical in both* — writes are withheld — and only the **channel** differs

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** Input: an arm-D worktree tracks the registered settings file, the runtime refuses Edit, and the agent writes through Bash. The registered arm-D preflight requires zero changed files, so it fails. One reviewer treats this as failed delivery and stops the batch; the artifact later treats it as successful delivery of an ineffective restriction. Those paths produce different admissible datasets.
**Layer of the implied fix:** L2
**Anchor:** for arm D, zero files changed with `toolCalls > 0`

### Controlled variables
**Verdict:** finding
**Failure:** Specific comparison: arm H and arm D use different settings payloads, different refusal text, and one has an executing hook and log while the other does not. A reviewer checking only the listed model, CLI, task, and permission-mode boxes calls the channels controlled; another identifies message and executable-hook differences as uncontrolled causes of the total outcome split.
**Layer of the implied fix:** L3
**Anchor:** The treated arm has writes withheld; the control does not. Both arms are otherwise the same runner invocation, model, benchmark commit and evaluator.

### Runs
**Verdict:** finding
**Failure:** Registered input is 30 runs, including 10 post-fix confirmation runs. Actual input is 20 runs plus replay. One reviewer follows the preregistration and marks the experiment incomplete; another accepts replay as a substitute. P5 consequently becomes either unexecuted or substantively answered.
**Layer of the implied fix:** L3
**Anchor:** Total **30 runs**

### Minimum detectable effect
**Verdict:** finding
**Failure:** At n=10, observing one infrastructure-classified run is possible under every nonzero true rate; the stated 26% calculation is power to observe at least one event, not a test that distinguishes a rate from zero with a defined false-positive rate. For an observed 1/10, one reviewer calls the rate detected because it exceeds zero; another says no inferential decision rule was specified.
**Layer of the implied fix:** L3
**Anchor:** **Below ~26 % this arm cannot distinguish the rate from zero**

### Deterministic evaluation
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** finding
**Failure:** Specific run: a treated run has missing telemetry and is classified F15, but its worktree proves the hook blocked writing. The exclusion rule removes it because telemetry is missing, while P1 says every blocked treated run’s recorded class is the outcome. One reviewer excludes it as infrastructure corruption; another counts it as the infrastructure event that refutes P1.
**Layer of the implied fix:** L3
**Anchor:** A run classed `F15` for **contamination** or for missing telemetry

### Decision rule
**Verdict:** finding
**Failure:** Observed input activates row 2 (one F13) and row 4 (only five actually blocked). No precedence was registered. One competent reviewer applies the first matching numbered row and returns CONFIRM WITH A NAMED LEAK; another treats row 4 as a precondition and returns VOID. The artifact chose the latter only after seeing the overlap.
**Layer of the implied fix:** L3
**Anchor:** Rows are exhaustive over P1's outcome

### Observed telemetry
**Verdict:** finding
**Failure:** All twenty registered `behavior.changedFiles` values are null, so the analysis substitutes `git status --porcelain` from retained worktrees. If an untracked harness log or post-run inspection artifact exists, one reviewer counts it as a changed file while another counts only task-output files. A run can move between “blocked” and “produced work,” changing row 4, because the counting scope is not defined.
**Layer of the implied fix:** L3
**Anchor:** The changed-file count is taken instead from each kept worktree with `git status --porcelain`

### Results
**Verdict:** finding
**Failure:** Input: arm D’s runtime rejects Edit but Bash writes the task files. One reviewer interprets the treatment as “the named tools are denied” and marks it successfully delivered; another uses the registered IV “permitted to write” and marks it undelivered. This changes the result from an ineffective capability control to a failed manipulation.
**Layer of the implied fix:** L3
**Anchor:** **The result of this experiment is that its two delivery channels are not one treatment**

### Which predictions held
**Verdict:** finding
**Failure:** P5 predicts that confirmation runs are “recorded as infrastructure,” but no confirmation runs occurred and the classifier is explicitly not wired into the run record. A reviewer scoring literal recorded outcomes marks the first half not run; another scoring classifier replay marks five blocked runs successfully reclassified. The artifact alternates between “unanswerable” and substantive replay evidence.
**Layer of the implied fix:** L2
**Anchor:** First half **not answerable as written**

### Failure analysis
**Verdict:** finding
**Failure:** For the actual counts—one infrastructure class and five blocked treated runs—rows 2 and 4 both fire. The claim that row 4 governs is an unregistered semantic precedence rule. A first-match implementation returns row 2; a precondition-first implementation returns row 4.
**Layer of the implied fix:** L2
**Anchor:** **Row 4 governs, and it governs because it is a precondition and row 2 is an outcome.**

### Sanity checks
**Verdict:** finding
**Failure:** The hand reread’s independence is established by finding no sheet containing the new run IDs, but a sheet could already exist under a filename without its run ID or in another scorer directory not covered by the search. One reviewer accepts “zero sheets”; another sees only “zero matching filenames.” The claimed ordering of independent judgments is then unproved.
**Layer of the implied fix:** L2
**Anchor:** checked to be so with `grep -rl` over `findings/` for every new run id

### Rubric sheets — a reported population, entering no decision row
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** Registered KEEP requires both P5 halves, including 10/10 confirmation runs. Those runs were not made, yet the classifier is “KEPT ON DISK.” One reviewer interprets KEEP as authorization to retain the implementation and says the condition was violated; another distinguishes physical retention from promotion and says KEEP was not invoked. The same diff is accepted or rejected depending on that undefined distinction.
**Layer of the implied fix:** L3
**Anchor:** **The classifier is KEPT on disk and NOT PROMOTED to a registered control.**

### Follow-up
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Goal
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Verified reading
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Extract
**Verdict:** finding
**Failure:** Specific implementation: a hook keeps its counter only in process memory but always exits 2 after the configured threshold during one long-lived process. Something executes and rejects the excess, so it is L2 for that execution even though it does not survive reinvocation. The artifact calls an in-process hook counter “L3 wearing L2’s clothes,” causing two reviewers to classify the same executing control differently.
**Layer of the implied fix:** L3
**Anchor:** a counter held in a hook's own process is L3 wearing L2's clothes

### The problem
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predict before you run
**Verdict:** finding
**Failure:** Input: an agent makes three repairs, each aimed at a different failure, while the total diff grows by generated files but the production diff shrinks. “Does the diff get smaller or larger?” has no defined diff scope or measurement point. One reviewer answers larger; another answers smaller.
**Layer of the implied fix:** L3
**Anchor:** Does the diff get smaller or larger with each repair?

### Lab 5B.1 — Watch an unbounded loop
**Verdict:** finding
**Failure:** Specific sequence: attempts 1 and 3 apply textually different patches that implement the same semantic change. One reviewer records “same fix tried twice” by intent; another records no repetition by patch hash. The lab has no operational identity rule for a fix.
**Layer of the implied fix:** L3
**Anchor:** whether the same fix was tried twice

### Lab 5B.2 — Failure fingerprints
**Verdict:** finding
**Failure:** Inputs: `NullPointerException at OrderService.kt:41` and `NullPointerException at PaymentService.kt:41` under the same test command. If normalization strips full paths before affected-module extraction, they collide; if module is preserved, they differ. The required stripping rules and ordering are absent, so competent implementations group them differently.
**Layer of the implied fix:** L3
**Anchor:** Timestamps, paths, and object hashes must be stripped

### Lab 5B.3 — Bounded repair with persistent state
**Verdict:** finding
**Failure:** At exactly three attempts for one fingerprint, `<= 3` permits a fourth attempt only if the counter represents completed attempts, but forbids it if the counter represents the next attempt number. Two wrappers can enforce different maxima while both following the text.
**Layer of the implied fix:** L2
**Anchor:** attempts for same fingerprint <= 3

### Lab 5B.4 — The completion contract
**Verdict:** finding
**Failure:** Specific diff: all required tests pass, but one non-required test fails. One reviewer checks “required tests passed” and permits DONE; another interprets “build passed” as requiring the full suite and rejects DONE. The checklist does not define the command set or precedence.
**Layer of the implied fix:** L2
**Anchor:** required tests passed

### Lab 5B.5 — Blocked is not failed
**Verdict:** finding
**Failure:** Input: a run hits a permission denial, then succeeds through an allowed tool and passes. The instruction says classify permission blocks as infrastructure, while later evidence establishes denial alone must not trigger classification. One implementation discards the passing run; the conjunctive implementation keeps it.
**Layer of the implied fix:** L2
**Anchor:** classify permission blocks, quota exhaustion, and infrastructure faults as **infrastructure**

### Lab 5B.5 — DESIGN, spine stop 16, 2026-09-11
**Verdict:** finding
**Failure:** Specific arm-D run: the settings file is tracked and Edit is refused, but Bash changes three files. The design labels the overlay L2 because “the runtime enforces the deny,” while the registered bad state is retaining write capability. Applying the layer test to that bad state yields no enforcing rejection. One reviewer calls the named-tool restriction L2; another calls the claimed write boundary absent, not L3 or L2.
**Layer of the implied fix:** L3
**Anchor:** The reproduction overlay (`.claude/settings.json` deny rules) | **L2 as delivered**

### Lab 5B.5 — RESULT, spine stop 16, 2026-09-14
**Verdict:** finding
**Failure:** Specific control: `permissions.deny` rejects Edit while Bash remains available and writes. The text calls this “L3 wearing L2’s clothes,” but an executable runtime did reject the forbidden Edit value, satisfying the supplied L2 test for that control. Reviewers will disagree because the artifact silently switches the bad state from “use Edit” to “write any file.”
**Layer of the implied fix:** L3
**Anchor:** a guardrail that removes a tool name is L3 wearing L2's clothes

### §5 validation — stop 16
**Verdict:** finding
**Failure:** Specific evidence row: twenty JSON files exist but contain fabricated or mismatched run IDs. File existence does not make that bad state unrepresentable, and nothing in the cited `ls` command rejects it. One reviewer follows the table and labels the proof L1; another applies the mandated layer order and labels it L3 unless a validator executes.
**Layer of the implied fix:** L3
**Anchor:** **L1** — the files exist or they do not

### Metrics
**Verdict:** finding
**Failure:** Input: a repair loop makes two failed attempts, is interrupted, resumes, and succeeds. One reviewer counts two repair attempts; another counts three because the successful repair is also an attempt. The metric names supply no event boundaries or denominators, so reported rates differ.
**Layer of the implied fix:** L3
**Anchor:** repair attempts · repair attempts per fingerprint · repeated fingerprints

### Exit gate
**Verdict:** finding
**Failure:** The checked clause asks for “the difference between FAILED, BLOCKED and DONE, and where each is recorded,” but its own evidence says BLOCKED has no representation and is not recorded. One reviewer marks the clause unmet because one requested location does not exist; another accepts “nowhere” as the answer and marks it met, as the artifact does.
**Layer of the implied fix:** L3
**Anchor:** - [x] **The difference between FAILED, BLOCKED and DONE, and where each is recorded**

### Commit
**Verdict:** finding
**Failure:** The listed deliverables include `.agent/run-state.json`, `scripts/verify.sh`, fingerprint tests, and a findings file, while the phase states Labs 5B.1–5B.4 did not run and those artifacts are unbuilt. One reviewer treats this block as a required commit contract and marks the phase incomplete; another treats it as a future placeholder.
**Layer of the implied fix:** L3
**Anchor:** `.agent/run-state.json schema · scripts/verify.sh · fingerprint tests`

### Why this phase is placed here
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Batch 1, all 20 runs — `batch1-replay.tsv`
**Verdict:** finding
**Failure:** Input: an arm-H worktree contains only `.ai/block-writes.log`, created by the harness hook. Raw `git status --porcelain` gives a nonzero changed-file count, so the classifier returns not-blocked; excluding harness-owned paths gives zero and returns blocked. The replay does not define whether such files are removed from the count.
**Layer of the implied fix:** L3
**Anchor:** the count is taken from each kept worktree with `git status --porcelain`

### The two stored populations — `stored-replay.tsv`
**Verdict:** finding
**Failure:** Batch-1 counts come from worktree status, while stored-population counts come from `.result.changedFiles`. If the result field excludes untracked files but worktree status includes them, identical diffs receive different classifier inputs. A reviewer can obtain 0/6 while another re-deriving from worktrees obtains a nonzero reclassification count.
**Layer of the implied fix:** L3
**Anchor:** for the stored populations it is `.result.changedFiles | length`

### Two preflight runs, reported as a co-variate and entering no decision row
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### What this replaces, and the reasoning for replacing it
**Verdict:** finding
**Failure:** Registered diff: execute 10 post-fix treated runs. Actual diff: execute none and replay old runs. A reviewer enforcing preregistration marks P5 untested because “recorded as infrastructure” includes runner integration and record mutation; another accepts pure classifier replay because the classifier runs after the agent. Those are not equivalent when the classifier is explicitly unwired from recording.
**Layer of the implied fix:** L2
**Anchor:** That batch is **not run**

### Why this file has to exist
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### What is proved instead, per run, on all twenty
**Verdict:** finding
**Failure:** Specific setup commit tracks the correct `.claude/settings.json`, but the runtime is launched without `--setting-sources project`. `git ls-files` and the hash still pass although the treatment is not consumed. One reviewer says delivery is proved; another says only presence is proved. The separate refusal proves some restriction fired, but not that the hashed file caused it.
**Layer of the implied fix:** L2
**Anchor:** overlay files **tracked in the setup commit** (`git ls-files`, not "the file is present")

### The tool mix, and the mechanism it exposes
**Verdict:** finding
**Failure:** Specific change: Bash remains available but is configured read-only by sandbox policy. The deny list still removes Edit/Write/NotebookEdit, and no write capability remains. The conclusion “a tool list filters names, not capabilities” does not follow from the deny list alone; it depends on Bash’s effective permissions, which are not part of the table’s control definition.
**Layer of the implied fix:** L2
**Anchor:** both leave `Bash` in the pool, and `Bash` writes files

### Two limits of this, stated because neither is visible from the numbers
**Verdict:** finding
**Failure:** The section says arm D’s write attempt count is exactly one per run but also says `cd563cee` attempted both Edit and Write. One reviewer counts write-tool invocations and gets two for that run; another counts only Edit and gets one. This directly affects the claim that denial counts bear no relation to attempted writes.
**Layer of the implied fix:** L3
**Anchor:** Arm D made exactly **one** write attempt per run

### Cross-cutting
**Verdict:** finding
**Failure:** Duplicate gate: P3’s “10 of 10 treated runs change zero files” duplicates decision-rule row 4’s pass/fail treatment-delivery gate; the same changed-file observation both scores a prediction and decides whether P1 is answerable. Greatest reviewer divergence: `Decision rule`, where the observed data triggers rows 2 and 4 and produces CONFIRM WITH A NAMED LEAK versus VOID—a full verdict-category difference, not a one-point scoring difference. Missing specification: registered precedence for overlapping decision rows; an operational definition of “blocked,” “produced nothing,” and changed-file scope; whether harness-created files count; and whether replay can replace confirmation runs that were required to be recorded through an unwired classification path.
**Layer of the implied fix:** L2
**Anchor:** Rows are exhaustive over P1's outcome


---

## Run 2 of 2 — codex

### Question
**Verdict:** no finding
**Failure:** No concrete input makes two competent reviewers interpret the stated measurement question differently.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** no finding
**Failure:** No concrete counterexample within the supplied evidence makes the preregistered hypothesis indeterminate; its later failure is handled as an experimental result.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predictions
**Verdict:** finding
**Failure:** If all five H runs block and all five D runs write files, as actually occurred, P5 still demands that “10 of 10 confirmation runs” be infrastructure even though the registered confirmation arm includes both channels. One reviewer will score P5 false at 5/10; another will call it unanswerable because only blocked runs are eligible. The prediction does not specify which treatment-failure interpretation governs.
**Layer of the implied fix:** L3
**Anchor:** “10 of 10 confirmation runs are recorded as infrastructure”

### Independent variable
**Verdict:** finding
**Failure:** Give arm H the message “Permission to modify files has not been granted for this session” and arm D “No such tool available: Edit,” while leaving their mechanisms unchanged. A reviewer can attribute the 5/5 versus 0/5 blocking split to mechanism; another can attribute it to the different messages. The design cannot identify the asserted channel effect.
**Layer of the implied fix:** L1
**Anchor:** “the treatment is identical in both — writes are withheld — and only the channel differs”

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** An arm-D run can have the deny overlay correctly installed, make several read-only tool calls, never attempt a write, and change zero files. It satisfies “zero files changed with toolCalls > 0” even though the deny rule never fired, so one reviewer will accept delivery and another will reject it as unproved.
**Layer of the implied fix:** L2
**Anchor:** “for arm D, zero files changed with `toolCalls > 0`”

### Controlled variables
**Verdict:** finding
**Failure:** Run H with the hook’s capability-level refusal and D with the runtime’s tool-name refusal. Every checklist item can remain checked, yet model-visible wording changes between arms and can change whether the model tries Bash. A reviewer treating wording as environment will reject the one-variable claim; one using the checklist will accept it.
**Layer of the implied fix:** L2
**Anchor:** “Both arms are otherwise the same runner invocation, model, benchmark commit and evaluator.”

### Runs
**Verdict:** finding
**Failure:** After observing batch 1, omit the registered ten-run batch 2 and replay the newly built classifier over batch-1 records instead. One reviewer will treat replay as the same post-agent test and accept completion; another will treat the absent fresh confirmation batch as a preregistration deviation. The section registers no rule permitting that substitution.
**Layer of the implied fix:** L3
**Anchor:** “batch 2 (confirmation, after the fix) — 10 treated”

### Minimum detectable effect
**Verdict:** finding
**Failure:** At n=10, observing one infrastructure classification is described as detectable with 95% probability when the true rate is at least 26%, but P1 is “refuted by a single treated run classed as infrastructure.” With exactly 1/10, one reviewer will invoke the single-run refutation; another will note that this observation neither estimates nor distinguishes a 26% rate from low nonzero rates. The decision meaning of the MDE is unspecified.
**Layer of the implied fix:** L3
**Anchor:** “Refuted by a single treated run classed as infrastructure.”

### Deterministic evaluation
**Verdict:** no finding
**Failure:** No supplied run shape makes the evaluator’s registered role or exit-code gate ambiguous.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exclusions
**Verdict:** no finding
**Failure:** The listed exclusion cases give determinate outcomes for the concrete anomalous runs described in the artifact.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision rule
**Verdict:** finding
**Failure:** For the observed input—one treated run classified F13 and only five of ten treated runs actually blocked—rows 2 and 4 both fire and prescribe different outcomes. One reviewer can report “CONFIRM WITH A NAMED LEAK”; another can report “VOID.” The later assertion that row 4 governs is post-data precedence absent from the registered table.
**Layer of the implied fix:** L1
**Anchor:** “Rows are exhaustive over P1’s outcome”

### Observed telemetry
**Verdict:** finding
**Failure:** The artifact says treatment firing was proved “per run, all twenty,” but controls have no treatment and the delivery table gives them no firing assertion. One reviewer will read “all twenty” as delivery-state verification including absence; another will read it literally as treatment execution on controls.
**Layer of the implied fix:** L3
**Anchor:** “the treatment observably firing, per run, all twenty”

### Results
**Verdict:** no finding
**Failure:** Given the supplied worktree and log evidence, the reported arm-level results are numerically determinate and explicitly limited to their observed runs.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Which predictions held
**Verdict:** finding
**Failure:** For observed P1 counts of eight capability classes, one F13, and one pass, the registered row 2 says CONFIRM WITH A NAMED LEAK while the table reports VOID by invoking row 4. Two reviewers following different live rows produce different verdicts because precedence was not preregistered.
**Layer of the implied fix:** L1
**Anchor:** “P1 … VOID — see the decision rule below”

### Failure analysis
**Verdict:** finding
**Failure:** On the actual data, the section resolves the row-2/row-4 collision by newly declaring a precondition to outrank an outcome. A reviewer enforcing only registered text reports row 2; a reviewer accepting this post-run hierarchy reports row 4.
**Layer of the implied fix:** L3
**Anchor:** “Row 4 governs, and it governs because it is a precondition and row 2 is an outcome.”

### Sanity checks
**Verdict:** finding
**Failure:** A malicious or mistaken setup commit can track the correct overlay files and hashes while the runner omits `--setting-sources project`. The listed tracked-file proof passes, but the treatment is not loaded. H has an execution log that catches this; D relies on runtime behavior elsewhere, so “tracks exactly its own registered files” alone does not establish delivery.
**Layer of the implied fix:** L2
**Anchor:** “each treated arm tracks exactly its own registered files”

### Rubric sheets — a reported population, entering no decision row
**Verdict:** no finding
**Failure:** The population, scorer, rubric identifier, null cell, and non-decision status are explicitly bounded; no concrete supplied sheet changes an experiment verdict.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Decision
**Verdict:** finding
**Failure:** Using the registered condition “KEEP only if P5 holds in both halves,” the first half is not met and the prescribed outcome is not KEEP. One reviewer will treat “not answerable” as failure of the KEEP condition and reject/remove the classifier; another will accept the newly introduced “KEPT ON DISK BUT NOT PROMOTED” third state. That state is absent from the registered rule.
**Layer of the implied fix:** L1
**Anchor:** “The classifier is KEPT on disk and NOT PROMOTED to a registered control.”

### Follow-up
**Verdict:** no finding
**Failure:** The follow-up items are explicitly identified as unrun future work and do not claim present evidence.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Goal
**Verdict:** no finding
**Failure:** No concrete lab outcome makes the stated phase goal internally ambiguous.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Verified reading
**Verdict:** no finding
**Failure:** The section identifies its sources and questions without using the checklist itself as experimental proof.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Extract
**Verdict:** finding
**Failure:** Implement a PreToolUse hook with an in-memory counter that rejects the fourth matching call by exit 2. The bad fourth attempt is executed and rejected, so the control is L2 for that uninterrupted process even though its state does not survive reinvocation or resume. A reviewer following the layer rule calls it L2 with inadequate persistence; the artifact calls it L3.
**Layer of the implied fix:** L3
**Anchor:** “a counter held in a hook’s own process is L3 wearing L2’s clothes”

### The problem
**Verdict:** no finding
**Failure:** The three outcome concepts and two unbounded-repair failure modes are distinguished sufficiently for this problem statement.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Predict before you run
**Verdict:** finding
**Failure:** Two reviewers measuring “how the diff evolved” can use changed-file count versus total changed lines. A repair changing one file from 10 to 100 lines is “same size” by the first measure and “larger” by the second, producing opposite answers to prediction 2.
**Layer of the implied fix:** L3
**Anchor:** “Does the diff get smaller or larger with each repair?”

### Lab 5B.1 — Watch an unbounded loop
**Verdict:** finding
**Failure:** An agent applies the same semantic repair twice using different textual patches. One reviewer counts this as “the same fix was tried twice”; another counts distinct diffs and says no. The lab supplies no identity rule for a repair attempt.
**Layer of the implied fix:** L3
**Anchor:** “whether the same fix was tried twice”

### Lab 5B.2 — Failure fingerprints
**Verdict:** finding
**Failure:** Errors `/tmp/a/Foo.kt:10: expected 1` and `/repo/Foo.kt:10: expected 2` share command and module. A normalizer stripping paths and numeric tokens merges genuinely different expected values; one reviewer calls that required line-number normalization and another calls it over-stripping. No normalization contract resolves the case.
**Layer of the implied fix:** L3
**Anchor:** “Timestamps, paths, and object hashes must be stripped”

### Lab 5B.3 — Bounded repair with persistent state
**Verdict:** finding
**Failure:** With `attempts` equal to 3 before a fourth repair, “attempts <= 3” can mean reject the fourth before it runs or allow it and block only when the stored counter becomes 4. Two implementations therefore execute different numbers of repairs while both claim compliance.
**Layer of the implied fix:** L2
**Anchor:** “attempts for same fingerprint <= 3”

### Lab 5B.4 — The completion contract
**Verdict:** finding
**Failure:** A task changes a generated lockfile outside the requested source directory. One reviewer marks it forbidden because it is outside task scope; another allows it because the build regenerated it. The script cannot deterministically decide “no forbidden file changed” without a defined forbidden set.
**Layer of the implied fix:** L3
**Anchor:** “no forbidden file changed”

### Lab 5B.5 — Blocked is not failed
**Verdict:** finding
**Failure:** A run hits a permission denial, then successfully completes through Bash. A classifier following “classify permission blocks … as infrastructure” can discard it; a classifier requiring no produced work retains it. The short lab instruction omits the conjunction later found necessary.
**Layer of the implied fix:** L3
**Anchor:** “classify permission blocks, quota exhaustion, and infrastructure faults as infrastructure”

### Lab 5B.5 — DESIGN, spine stop 16, 2026-09-11
**Verdict:** finding
**Failure:** The design labels the reproduction overlay L2 because the runtime rejects Edit, then later concludes that removing Edit is “L3 wearing L2’s clothes” because Bash still writes. Under the stated layer algorithm, the bad value “call Edit” is executed and rejected, so it is L2; the actual defect is that the controlled bad state was defined as a tool name instead of file mutation. Two reviewers will assign different layers depending on which bad state they choose.
**Layer of the implied fix:** L3
**Anchor:** “The reproduction overlay (`.claude/settings.json` deny rules) | L2 as delivered”

### Lab 5B.5 — RESULT, spine stop 16, 2026-09-14
**Verdict:** finding
**Failure:** For the same deny configuration, the runtime executes and rejects Edit. The section nevertheless calls the guardrail L3 because Bash remains available. A reviewer applying the mandatory first-yes rule to the written deny value assigns L2; a reviewer evaluating the intended write capability assigns no effective control. “L3 wearing L2’s clothes” is not a valid layer result.
**Layer of the implied fix:** L3
**Anchor:** “a guardrail that removes a tool name is L3 wearing L2’s clothes”

### Metrics
**Verdict:** finding
**Failure:** For a run that claims DONE twice before passing on the third check, one reviewer reports two “completion-contract failures after a DONE claim”; another reports one run with any such failure. The metric has no denominator or unit.
**Layer of the implied fix:** L3
**Anchor:** “completion-contract failures after a DONE claim”

### Exit gate
**Verdict:** finding
**Failure:** The clause asks for “the difference between FAILED, BLOCKED and DONE, and where each is recorded,” but it is checked MET while stating BLOCKED has no representation and is not recorded. One reviewer checks it because the absence was identified; another leaves it open because the requested recording location does not exist.
**Layer of the implied fix:** L3
**Anchor:** “BLOCKED has no representation at all.”

### Commit
**Verdict:** finding
**Failure:** A reviewer can interpret the fenced list as artifacts required for the phase commit, yet the exit gate says Labs 5B.1–5B.4 did not run and the classifier files actually discussed have different paths. Another reviewer can treat it as a future placeholder. The section does not state which, producing different completion judgments.
**Layer of the implied fix:** L3
**Anchor:** “.agent/run-state.json schema · scripts/verify.sh · fingerprint tests”

### Why this phase is placed here
**Verdict:** no finding
**Failure:** No concrete ordering input in the supplied evidence contradicts the stated dependencies.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Batch 1, all 20 runs — `batch1-replay.tsv`
**Verdict:** no finding
**Failure:** The table’s three exit outcomes exhaust the reported replay records and its arm counts sum to twenty.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### The two stored populations — `stored-replay.tsv`
**Verdict:** no finding
**Failure:** The two populations, sample sizes, predictions, and replay outcomes are explicitly identified.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Two preflight runs, reported as a co-variate and entering no decision row
**Verdict:** no finding
**Failure:** The two runs are explicitly excluded from registered counts and separately labelled.
**Layer of the implied fix:** n/a
**Anchor:** n/a

### What this replaces, and the reasoning for replacing it
**Verdict:** finding
**Failure:** Build the classifier using batch-1 failures and real-run fixtures, then replay it on those same records instead of running the registered post-fix batch. A reviewer can accept this as deterministic equivalence; another will reject it as in-sample confirmation because the replay records helped motivate and test the conjunction. The artifact has no independent holdout criterion.
**Layer of the implied fix:** L3
**Anchor:** “That batch is not run”

### Why this file has to exist
**Verdict:** finding
**Failure:** The section says “the flag was passed” is all a hash can say, but all hashes are null and none represents `.claude/settings.json`. For a run with the flag omitted, the same null hashes appear. A reviewer therefore cannot infer even flag passage from those hashes.
**Layer of the implied fix:** L3
**Anchor:** “So ‘the flag was passed’ is all a hash can say here”

### What is proved instead, per run, on all twenty
**Verdict:** finding
**Failure:** A setup commit can track the registered settings file and hash while the runtime is launched without loading project settings. The table’s tracked-file and hash checks pass although delivery fails. H’s log and D’s refusal prove execution separately, so the heading overstates what the file checks themselves prove.
**Layer of the implied fix:** L2
**Anchor:** “overlay files tracked in the setup commit”

### The tool mix, and the mechanism it exposes
**Verdict:** finding
**Failure:** The artifact calls denial of Edit/Write/NotebookEdit a speed bump and implies it is not enforcement. For input `Edit(file)`, the runtime executes and rejects the bad call, which is L2; for input `Bash("printf … > file")`, it permits the mutation. Two reviewers choosing tool use versus file mutation as the bad state assign different layers and control effectiveness.
**Layer of the implied fix:** L3
**Anchor:** “`permissions.deny` on `Edit`/`Write`/`NotebookEdit` is not a write boundary.”

### Two limits of this, stated because neither is visible from the numbers
**Verdict:** finding
**Failure:** The final sentence says P2’s registered mechanism is confirmed, but P2 predicted arm D at 0/5 and observed 4/5 with counts unrelated to write attempts. One reviewer treats the absence of an event for the removed Edit tool as mechanism confirmation; another treats the overall denial-count prediction as refuted. The referent of “mechanism” is ambiguous.
**Layer of the implied fix:** L3
**Anchor:** “This is the registered mechanism of P2 confirmed”

### Cross-cutting
**Verdict:** finding
**Failure:** Duplicate gate: P3’s “10 of 10 treated runs change zero files” duplicates decision-rule row 4’s pass/fail treatment-delivery gate (“fewer than 8 of 10 … blocked”), since both decide whether P1 is answerable from the same blocked/changed-files state. Reviewers diverge most on Decision: the registered binary KEEP/REJECT condition is unmet, while the report introduces “KEPT ON DISK BUT NOT PROMOTED”; outcomes can differ completely between reject and retain. The evidence set needed to preregister precedence among overlapping decision rows, define whether replay could replace batch 2 and what independence it required, define the prohibited capability rather than prohibited tool names, and specify denominators/identity rules for the repair and completion metrics.
**Layer of the implied fix:** L1
**Anchor:** “KEEP only if P5 holds in both halves”

