# opencode review — E-015-verification-policies-BE003

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
reviewed_utc:    20260911T085300Z
runs:            1           # independent sessions; findings unioned below
families:        1           # distinct models; the recurrence denominator
artifacts:
  - path: experiments/E-015-verification-policies-BE003.md
    sha:  4b76f3830266
    dirty: false
  - path: experiments/E-016-verification-policies-BE004.md
    sha:  49dc8f8e9725
    dirty: false
  - path: phases/b07-verification-policies/README.md
    sha:  afb72fc6552a
    dirty: false
  - path: /private/tmp/claude-501/-Users-jirihermann-Documents-workspace-1-ideas-ai-agents-ai-learning/026728f1-6cdb-4451-8222-b687f17522a6/scratchpad/review/protected-paths.yaml
    sha:  76c4c34c0f4c
    dirty: false
lab_head:        f39476d
lab_dirty:       true   # the TREE, not the artifact - see each artifact's own dirty:
```


## Acceptance

The gate failed to run (opencode exit 1).
## Panel

What actually ran. A family that stalled or failed is dropped from the recurrence
denominator and named here — a panel that quietly became smaller is the failure this
tool exists to catch.

| Family | Outcome | |
|---|---|---|
| codex | ok | 229s |

Stall budget: 600s per family (LAB_REVIEW_TIMEOUT).

## Recurrence across 1 run(s)

How many independent runs flagged each section. Low recurrence is a detection-threshold
signal, not a falsity signal — read those findings, do not discount them.

One family only. -P runs a panel of different models instead, which measures the
artifact rather than this model's detection threshold.

| Section | Families | Layer of implied fix |
|---|---|---|
| Hypothesis | 1/1 | L3 |
| Predictions | 1/1 | L2 |
| Independent variable | 1/1 | L2 |
| How the treatment is delivered — and proved | 1/1 | L2 |
| Controlled variables | 1/1 | L2 |
| Runs | 1/1 | L2 |
| Minimum detectable effect | 1/1 | L3 |
| Deterministic evaluation | 1/1 | L2 |
| Exclusions | 1/1 | L2 |
| Decision rule | 1/1 | L1 |
| Amendment, 2026-09-10 — the treatment's hash moved before its first registered run, and why | 1/1 | L3 |
| Which predictions held | 1/1 | L3 |
| Amendment, 2026-09-11 (third) — §4 step 9, the two deliberate failures: DF1 held, DF2 is refuted in the opposite direction | 1/1 | L2 |
| Amendment, 2026-09-11 — the population that occurred is n = 7 per arm, and what that does to each registered threshold | 1/1 | L1 |
| Amendment, 2026-09-11 (second) — P7 is measured and it holds on all four categories; the verdict is row 3 | 1/1 | L3 |
| Goal | 1/1 | L2 |
| Extract | 1/1 | L3 |
| Design — and the two measurements that decided it | 1/1 | L3 |
| Build | 1/1 | L3 |
| Predict before you run | 1/1 | L2 |
| Lab B7.1 — measure against B6, and close v1.0 against B2 | 1/1 | L3 |
| Exit gate | 1/1 | L3 |
| §5 validation table | 1/1 | L2 |
| Commit | 1/1 | L3 |
| applies_to | 1/1 | L2 |
| deny | 1/1 | L2 |
| message | 1/1 | L3 |
| Cross-cutting | 1/1 | L2 |


---

## Run 1 of 1 — codex

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** A run edits an existing plugin version in `pom.xml` without adding a dependency or touching an unrelated file. The policy denies it, but the cited exit-20/21 census can remain zero; one reviewer calls this a member of the gate's true-positive population, while another accepts the claim that the population is empty.
**Layer of the implied fix:** L3
**Anchor:** “So the population the gate exists to catch is, on this evidence, empty.”

### Predictions
**Verdict:** finding
**Failure:** A treated run has 36 allowed edits, but only 20 are later judged ticket-legitimate. One reviewer uses all 36 as P3's denominator because the table says all `Edit`/`Write` calls; another uses only the 20 legitimate calls because P3 is named a false-positive rate. The artifact supplies no legitimacy adjudication rule.
**Layer of the implied fix:** L2
**Anchor:** “Of all `Edit`/`Write` calls in the treated arm, the fraction denied is 0”

### Independent variable
**Verdict:** finding
**Failure:** The treated settings file installs the registered policy hook plus an additional non-logging hook that changes tool input. The policy event log and equal agent hash still pass, so one reviewer accepts the one-variable claim while another rejects it because settings and hook content were not read back from each run.
**Layer of the implied fix:** L2
**Anchor:** “Treated and control differ by `.claude/settings.json`, `.ai/policies/protected-paths.yaml` and `.ai/hooks/policy-gate.sh`, and by nothing else.”

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** A wrong `.claude/settings.json` loads a different hook which also writes correctly shaped policy-event lines. The event log exists and the agent hash matches, so the stated proof passes although the registered gate was not the process that ran.
**Layer of the implied fix:** L2
**Anchor:** “The event log is the delivery proof”

### Controlled variables
**Verdict:** finding
**Failure:** A hook from `~/.claude/settings.json` executes but writes no entry to the policy gate's private log. One reviewer treats the log naming only `policy-gate.sh` as proof of isolation; another correctly observes that the log cannot enumerate unrelated hooks.
**Layer of the implied fix:** L2
**Anchor:** “it is proved by the event log naming only `policy-gate.sh`”

### Runs
**Verdict:** finding
**Failure:** Runs are ordered T,T,T,T,T,T,T,T,T,T,C,C,C,C,C,C,C,C,C,C during a load change. This satisfies the stated arm counts but not a competent reviewer's meaning of “interleaved”; another reviewer may accept any alternation somewhere in the manifest.
**Layer of the implied fix:** L2
**Anchor:** “treated `verify-v1.0`, control `phases-v1.0` · interleaved”

### Minimum detectable effect
**Verdict:** finding
**Failure:** For P7, treated/control maintainability values are `0 0 0 0 2 2 2 2 2 2` versus `0 0 0 0 0 0 2 2 2 2`. The median gap is 2, but the underlying rate difference is only two runs. Because no rubric spread or power basis defines the one-point threshold, reviewers can reasonably classify this as outside the MDE or as an underpowered binary-rate difference.
**Layer of the implied fix:** L3
**Anchor:** “No rubric category's treated median differs from the control's by more than 1 point”

### Deterministic evaluation
**Verdict:** finding
**Failure:** All 20 evaluator results pass, and `verify-sh.sh` also passes all 20. The reported zero disagreement is compatible both with equivalent failure detection and with `verify-sh.sh` missing every failure class, because no failing worktree occurs in the comparison.
**Layer of the implied fix:** L2
**Anchor:** “the interesting number is how often it and the evaluator disagree”

### Exclusions
**Verdict:** finding
**Failure:** A run lasts 18 minutes and another 36 minutes while ordinary runs last about 3 minutes. One reviewer labels both machine-sleep contamination and excludes duration; another labels them machine load and retains them because no operational test for “machine sleep” is specified.
**Layer of the implied fix:** L2
**Anchor:** “runs contaminated by a machine sleep — duration only is excluded”

### Decision rule
**Verdict:** finding
**Failure:** Cost is outside its MDE in the worse direction while P1–P3 and P5–P7 hold. Row 3 cannot hold because it requires P4 inside its MDE, yet row 5 requires both “Row 3 holds” and cost outside its MDE. One reviewer chooses row 4 INCONCLUSIVE; another applies the intended row 5 REJECT.
**Layer of the implied fix:** L1
**Anchor:** “Row 3 holds and cost is outside its MDE in the worse direction”

### Deliberate failure (§4 step 9)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment, 2026-09-10 — the treatment's hash moved before its first registered run, and why
**Verdict:** finding
**Failure:** The registered P1 requires `.ai/policy-events.jsonl`, but the amended treatment writes `$TMPDIR/policy-events-<worktree-basename>.jsonl`. One reviewer scores literal P1 as failed because the named file is absent; another treats the amendment as a valid pre-run change and scores P1 against the new path.
**Layer of the implied fix:** L3
**Anchor:** “It is still exactly one file per run … so nothing about the delivery proof weakens.”

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
**Failure:** P3 is recorded as `0 / 36`, but all observed calls are `Edit`; the registered claim explicitly covers `Edit`/`Write`. One reviewer marks the combined-path prediction held, while another marks it unmeasured for `Write`.
**Layer of the implied fix:** L3
**Anchor:** “HELD, with its denominator corrected downward”

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment, 2026-09-11 (second) — P7 is measured, and it is refuted; the verdict is row 4, INCONCLUSIVE
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment, 2026-09-11 (third) — §4 step 9, the two deliberate failures: DF1 held, DF2 is refuted in the opposite direction
**Verdict:** finding
**Failure:** The text says absence of the log represents both an uninstalled control hook and a broken treated hook, but P1 row 0 still declares any treated run without a log VOID. A syntactically broken treated hook therefore gets classified as missing treatment rather than failed enforcement, producing different diagnoses from the same observation.
**Layer of the implied fix:** L2
**Anchor:** “`.ai/policy-events.jsonl` is absent in two situations that mean opposite things”

### Question
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Hypothesis
**Verdict:** finding
**Failure:** A run modifies `build.gradle.kts` without adding a dependency and still passes evaluator exits 20 and 21. The gate would deny it despite the cited census remaining zero, so the census does not establish that the gate's true-positive population is empty.
**Layer of the implied fix:** L3
**Anchor:** “So the population the gate exists to catch is, on this evidence, empty.”

### Predictions
**Verdict:** finding
**Failure:** A protected-path denial occurs on an edit that the ticket genuinely requires. One reviewer counts it under P2 as a “real violation,” triggering KEEP; another counts it under P3 as a false positive, triggering REJECT. No independent rule determines whether a denied call is legitimate before the decision table is applied.
**Layer of the implied fix:** L2
**Anchor:** “P2 … a real violation was denied”

### Independent variable
**Verdict:** finding
**Failure:** A changed settings file carries both the policy hook and another project hook. Equal agent hashes and policy logs do not detect the added hook, so the claimed single-variable comparison can contain an unmeasured second treatment.
**Layer of the implied fix:** L2
**Anchor:** “and by nothing else”

### How the treatment is delivered — and proved
**Verdict:** finding
**Failure:** A stand-in hook produces the expected event log while the registered `f432…` hook is absent. The stated event-log proof succeeds even though the registered treatment was not delivered.
**Layer of the implied fix:** L2
**Anchor:** “the log proves the process ran”

### Controlled variables
**Verdict:** finding
**Failure:** An operator hook executes silently alongside `policy-gate.sh`. Because the policy log records only policy-gate activity, it still names only `policy-gate.sh`; reviewers diverge on whether this proves zero operator hooks.
**Layer of the implied fix:** L2
**Anchor:** “proved by the event log naming only `policy-gate.sh`”

### Runs
**Verdict:** finding
**Failure:** The first seven treated runs occur before all seven controls during a runtime-load shift. The document supplies no sequence, blocking, or randomization rule, so “interleaved” cannot rule out time-order confounding.
**Layer of the implied fix:** L2
**Anchor:** “interleaved”

### Minimum detectable effect
**Verdict:** finding
**Failure:** At the actual n=7, a rubric median changes by two points because one arm has four anchor-2 cells and the other has three. With no registered rubric variance or power calculation, one reviewer applies the fixed one-point cutoff and another treats the single-cell threshold crossing as unresolved.
**Layer of the implied fix:** L3
**Anchor:** “No power calculation was registered against a measured rubric spread”

### Deterministic evaluation
**Verdict:** finding
**Failure:** All 14 evaluator runs pass. A `verify-sh.sh` that always returns exit 0 would show perfect agreement on this population, so the promised disagreement measurement does not test whether failures are detected consistently.
**Layer of the implied fix:** L2
**Anchor:** “the interesting number is how often they disagree”

### Exclusions
**Verdict:** finding
**Failure:** The 1,084,000 ms and 2,177,000 ms runs can be called either machine sleep or machine load. Since the artifact specifies no executed classifier, two reviewers can exclude different duration observations.
**Layer of the implied fix:** L2
**Anchor:** “runs contaminated by a machine sleep”

### Decision rule
**Verdict:** finding
**Failure:** With worse-direction cost outside the MDE, row 3 is false by definition, making row 5's prerequisite “Row 3 holds” impossible. Reviewers must choose between row 4 and the apparently intended cost rejection.
**Layer of the implied fix:** L1
**Anchor:** “Row 3 holds and cost is outside its MDE”

### Deliberate failure (§4 step 9)
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment, 2026-09-10 — the treatment's hash moved before its first registered run, and why
**Verdict:** finding
**Failure:** A reviewer applying the committed P1 literally looks for `.ai/policy-events.jsonl` and declares every treated batch run void; another applies the amendment's `$TMPDIR` path and declares P1 held.
**Layer of the implied fix:** L3
**Anchor:** “The log moves out of the repository under test”

### Amendment, 2026-09-11 — the population that occurred is n = 7 per arm, and what that does to each registered threshold
**Verdict:** finding
**Failure:** Observed model-call difference is 4.5 calls. It exceeds the registered P5 text `≤ 4` but is below the reconstructed n=7 limit of 4.89. The amendment labels this “un-decidable,” while the unchanged decision table has no state for an undecidable P5, so reviewers can either withhold all verdicts or treat P5 as outside and fire row 4.
**Layer of the implied fix:** L1
**Anchor:** “It enters no decision-rule row”

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
**Failure:** All 55 calls are `Edit`, but the registered P3 claim covers `Edit`/`Write`. One reviewer reports the prediction held as written; another reports the `Write` portion untested.
**Layer of the implied fix:** L3
**Anchor:** “P3 … HELD … All 55 calls were `Edit`”

### Decision
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Amendment, 2026-09-11 (second) — P7 is measured and it holds on all four categories; the verdict is row 3
**Verdict:** finding
**Failure:** For run `e0075ad9`, the registered scorer and hand reader assign 0 while the second reader assigns 2 from the same rubric text. The artifact explicitly establishes two competent readings but still treats the category median as an unqualified measurement, so a different competent scorer can change P7 and the row-3 verdict.
**Layer of the implied fix:** L3
**Anchor:** “the rubric does not say whether a test fixture is ‘a method the ticket did not name’”

### Amendment, 2026-09-11 (third) — §4 step 9, the two deliberate failures: DF1 held, DF2 is refuted in the opposite direction
**Verdict:** finding
**Failure:** A treated hook fails before logging and denies every edit. The registered P1 classifies the absent treated log as VOID, while the amendment interprets it as installed-but-broken enforcement; the same inputs therefore receive incompatible failure classes.
**Layer of the implied fix:** L2
**Anchor:** “P1's registered wording … cannot separate them”

### Goal
**Verdict:** finding
**Failure:** A repository has a failing test. The harness later runs `tools/verify-sh.sh`, records failure, but neither blocks the agent nor refuses completion. One reviewer says the goal is met because a command executes; another says it is not because the requested verification control does not “execute and refuse” in the agent workflow.
**Layer of the implied fix:** L2
**Anchor:** “Give the agent one verification command with a machine-readable result”

### Required reading
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Extract
**Verdict:** finding
**Failure:** A syntax error placed near the start of the shell hook makes Bash exit 2 and blocks all edits, as DF2 later demonstrates. The Extract instead lists syntax errors among fail-open cases. A reviewer designing tests from this section expects allow; a reviewer using the observed amendment expects deny.
**Layer of the implied fix:** L3
**Anchor:** “a syntax error … produce[s] ‘the action proceeds’”

### Design — and the two measurements that decided it
**Verdict:** finding
**Failure:** A new protected-path violation is attempted after the census. The prose says the census “refuses” unbuilt policies at L2, but no named validator rejects adding those files or requires rebuilding them when incidence changes. A contributor can add `command-policy.yaml` and nothing executes to reject it.
**Layer of the implied fix:** L3
**Anchor:** “the number `0 of 325` is produced by a script over the store, and it is what refuses three of the four policy files”

### Build
**Verdict:** finding
**Failure:** One reviewer follows the scaffold and checks `scripts/verify.sh` plus four files under `policies/`; another follows “What was built” and checks `tools/verify-sh.sh` plus only the overlay protected-path policy. The first reports missing deliverables; the second reports intentional omissions.
**Layer of the implied fix:** L3
**Anchor:** “`scripts/verify.sh` … `policies/protected-paths.yaml` `policies/command-policy.yaml` `policies/allowed-dependencies.yaml` `policies/database-policy.yaml`”

### Predict before you run
**Verdict:** finding
**Failure:** A treated call uses `Write` on a legitimate Kotlin file and is denied because the Write parsing branch is defective. Neither batch contains a Write call, so the registered zero false-positive prediction is reported held although this concrete legitimate command fails.
**Layer of the implied fix:** L2
**Anchor:** “false-positive rate measured on legitimate commands”

### Lab B7.1 — measure against B6, and close v1.0 against B2
**Verdict:** finding
**Failure:** The heading says the step comparison is against B6, but the table uses a concurrent `phases-v1.0` control, while the version comparison uses stored B2/B5 arms. A reviewer treating `phases-v1.0` as B6-equivalent accepts the comparison; another cannot establish that equivalence from this evidence set.
**Layer of the implied fix:** L3
**Anchor:** “measure against B6”

### Deliberate failure
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### Exit gate
**Verdict:** finding
**Failure:** A run completes with failing tests. `policy-gate.sh` returns 0 because no protected path was edited, while harness-run `verify-sh.sh` returns failure after completion. One reviewer marks “one verification command with one exit code” unmet because verification is non-blocking; the table marks it met by substituting the three-outcome policy gate for the verification entry point.
**Layer of the implied fix:** L3
**Anchor:** “one command, one exit code — yes, and it is not `verify.sh`”

### §5 validation table
**Verdict:** finding
**Failure:** A stranger hashes the file named in the first row and obtains the amended `f432abbc…` artifact, but the row identifies the obsolete `c558f78a…` hash. Another reviewer follows the amendments and verifies `f432…`; they are validating different registered artifacts.
**Layer of the implied fix:** L2
**Anchor:** “`policy-gate.sh`, sha `c558f78ace02066223746bd216e4c848326bdc382fa2cfd35f1569d9fe22cbac`”

### Commit
**Verdict:** finding
**Failure:** The protected-path policy and settings were changed before the batch and the experiments contain dated amendments, yet the section says registered artifacts are “added to, never edited.” One reviewer interprets that as a post-batch rule; another reads it literally and rejects the commit history.
**Layer of the implied fix:** L3
**Anchor:** “The registered artefacts … are added to, never edited.”

### version
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### policy
**Verdict:** no finding
**Failure:** n/a
**Layer of the implied fix:** n/a
**Anchor:** n/a

### applies_to
**Verdict:** finding
**Failure:** A `NotebookEdit` targets `infra/analysis.ipynb`. The policy declares that tool in scope, but the surrounding experiment repeatedly describes the executing `PreToolUse` matcher as `Edit`/`Write`. One reviewer expects denial from this key; another expects the hook never to run for NotebookEdit.
**Layer of the implied fix:** L2
**Anchor:** “applies_to: [Edit, Write, NotebookEdit]”

### deny
**Verdict:** finding
**Failure:** The worktree contains a root-level `pom.xml` or `.env`. Under fnmatch implementations where `**/pom.xml` and `**/.env` require a slash, neither pattern matches; under globstar-style implementations they do. The artifact says only “fnmatch semantics” without naming the implementation, so reviewers predict different allow/deny results.
**Layer of the implied fix:** L2
**Anchor:** “Patterns are matched … with fnmatch semantics”

### message
**Verdict:** finding
**Failure:** After denial, the model retries the same protected edit three times. The hook can deny each attempt, but nothing executes to enforce “Do not retry” or require a `Not done` record. A reviewer may mistake the imperative for an enforced policy although it remains guidance.
**Layer of the implied fix:** L3
**Anchor:** “Do not retry this edit … and record it under ‘Not done’”

### Cross-cutting
**Verdict:** finding
**Failure:** The scoring category `maintainability` duplicates the pass/fail effect of P7's `>1` median gate: the observed 0/2-only anchors turn one category into a binary row-4 trigger. Reviewers diverge most on `change-focus` for BE-004 by 2 points, demonstrated by hand/codex = 0 versus second reader = 2. The evidence needed an executable legitimacy classifier for P2/P3, an executable treatment-identity check for settings/hooks, a specified run-order rule, and a reachable decision row for worse-direction cost outside the MDE.
**Layer of the implied fix:** L2
**Anchor:** “the rubric does not say whether a test fixture is ‘a method the ticket did not name’”

