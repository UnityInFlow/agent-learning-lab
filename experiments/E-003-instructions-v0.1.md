# Experiment E-003 — `instructions-v0.1` against a concurrent plain baseline

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-03T17:05:00Z; the author did not
review before the run.` Every prediction below is written by the same model that built the
treatment and will run the comparison. That contamination is not summarised away: it is the
same defect E-001 was designed to avoid by using the author's predictions, and there is no
author in this session to supply them. Read every result with that in view.

**Spine stop 6 · B3 · Layer 3 treatment, measured at Layer 2.**

## Question

B2 established that the plain agent **reads** conventions better than predicted — an L3 prose
convention was honoured 14 of 14 — and **defends** worse than predicted: it chose the construct
that makes a future unhandled case a compile error on **1 of 5** scored runs, and on a second
repository it did not extract the shared helper its own codebase's precedent called for, 0 of 6,
*in both arms, including one carrying a real `CLAUDE.md` with those conventions in it*.

So the question B3 can actually answer is not "do instructions help". It is:

> **Does a rule aimed at the one thing the baseline measurably fails at change what the agent
> builds — and does a rule aimed at something it already does change anything at all?**

## Hypothesis

An instruction moves behaviour only where behaviour has somewhere to move. The baseline is at
ceiling on convention-following (14/14) and at floor on defensive construct choice (1/5). A file
containing one rule of each kind should therefore split: the defensive rule should move the
maintainability construct, and the convention rule should move nothing, on the same runs, under
the same file.

**Mechanism.** The agent is not failing to *know* that an exhaustive `when` in expression
position exists; Kotlin makes it the idiomatic form and the model writes idiomatic Kotlin
elsewhere in the same diff. It is failing to *choose* it, because nothing in the task asks for
future-proofing and the tests pass either way. An always-on rule changes what the model treats
as part of the task. That mechanism predicts a large effect where the gap is a choice, and no
effect where the behaviour is already produced.

## Predictions

Registered before any run of this experiment. Direction, magnitude and mechanism, one per rule,
plus two about the file as a whole.

1. **R1 — the defensive rule moves the maintainability construct.** Treatment reaches the
   rubric's `maintainability` anchor 2 on **≥ 8 of 10** runs against a control at ≤ 3 of 10.
   Mechanism: the rule renames "make it pass" as "make an unhandled case impossible", and the
   construct that satisfies it is one the model already writes fluently elsewhere.
2. **R2 — the verification rule costs and buys nothing measurable here.** `toolCalls` median
   rises by **≥ 5 calls** and duration by **≥ 40 %**, while the evaluator verdict is unchanged
   at 10/10 passing in both arms. Mechanism: BE-003's tests already pass on every baseline run,
   so a rule to run them adds work with no verdict to change. This is the *cost half* of the
   L3 question and is predicted to be real and useless at once.
3. **R3 — the convention rule moves nothing at all.** No outcome separates the arms on any
   metric attributable to it, and the `ApiError.kt` KDoc convention is honoured in both arms at
   the same rate B2 measured (14/14). Mechanism: the behaviour is already at ceiling, so the
   rule has no room. **R3 is in the file deliberately, as the internal negative control that
   makes the gate's "remove every rule with no measured effect" clause testable rather than
   rhetorical.**
4. **The file as a whole costs less than a conventions document.** `EXP-BE002-CLAUDEMD-V2`
   measured **+39 %** cost for identical acceptance on a full conventions file. This file is 57
   words. Predicted cost increase over the concurrent control: **positive but under +25 %**,
   i.e. cheaper per rule than the file that produced the +39 %.
5. **Nothing regresses.** `architecture-consistency` and `change-focus` medians do not fall.
   Mechanism: none of the three rules touches the error hierarchy or the diff's scope, and a
   57-word file is far below any plausible dilution threshold.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing:** the presence of `build/customizations/instructions-v0.1/CLAUDE.md` in the
agent's repository at start. Everything else — benchmark sha, evaluator, model id, harness
version, isolation regime, machine, day — is held, and the arms are **interleaved** rather than
run as two blocks, so a drift in any of them lands on both arms equally.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `--customization build/customizations/instructions-v0.1`, copied to the worktree root and committed as a setup commit before the agent starts |
| Content hash | `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 57 words, three rules. **The runner stores the first 32 hex characters of the SHA-256 digest, not the whole thing.** Verify with `shasum -a 256 build/customizations/instructions-v0.1/CLAUDE.md \| cut -c1-32`; the full digest is `90f95226cc3d429f6f3e157e4741bbd10a79d09f20c0294dd6bf14fd33b74218`. The truncation is real and was undocumented until the acceptance gate caught it — a 32-character string labelled `sha256:` is the length of an MD5, and a reviewer running the obvious command gets a 64-character answer that cannot match |
| Preflight assertion | One treatment run before the batch; `customization.instructionsHash` on its run record must equal the hash above. The batch does not start otherwise |
| Control assertion | Control runs pass **no** `--customization`. The runner hashes `CLAUDE.md` *in the worktree*, and the worktree is built by `git archive` from an allowlist of `sample-service` and `.gitignore` only — the benchmarks repo's own `CLAUDE.md` is **not extracted**. So `instructionsHash: null` on a control run means no instruction file was present, not merely that none was installed |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this. The
> runner now refuses a customization whose instruction file the runtime does not read, which
> makes the *filename* half of that failure L2. The content half is still this table's job.

## Controlled variables

- [x] starting commit / benchmark revision SHA — `0448643`, the sha E-002 ran on
- [x] task + revision — BE-003, `evaluator.sh` version `1.0.0`
- [x] harness + version — one `claude` CLI version for all runs; recorded per run and asserted
      identical across arms after the batch
- [x] model — `claude-haiku-4-5-20251001`, the exact id B2's claude arm registered
- [x] permissions / permission mode — runner default, identical on both arms
- [x] environment — `ISOLATE_USER_SETTINGS=1` on **every** run of both arms. Proved from
      telemetry, not from the flag: `claude_code.hook_execution_start` must be 0 per run
- [x] runner commit — one commit for the whole batch, recorded

## Runs

Repetitions per arm: **10 treatment + 10 control, interleaved.** Deliberate-failure arm: 5.
Total budget: 25 runs × ~$0.15 median = **~$3.75**.

*One run is a story. Five is a hint. Ten is the minimum for a decision.* n=10 is not a
preference here; it is the smallest n at which the effect this experiment cares about is
detectable at all. See below.

## Minimum detectable effect

**Derived from the measured arm before any threshold was written**, which is E-002 follow-up 6
— the finding that E-002's own MDE column had been filled with its prediction thresholds and
two of its three refutations therefore sat inside its detection limit.

Baseline for the primary outcome: `EXP-B2-BASELINE-CLAUDE`, `maintainability` anchor 2 reached
on **1 of 5** scored runs. Baselines for the cost outcomes: the same nine runs, and E-002's
isolated arm where the duration tail did not fire.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| **primary:** `maintainability` anchor 2 reached, per arm | B2 claude arm, 1 of 5 | Fisher exact, 10 v 10 from a control of 2/10: **8/10 → p = 0.023**; 7/10 → p = 0.070, **not detectable**. At n=5/arm only a perfect **5/5** clears 0.05 (p = 0.048), which is why n=5 was rejected | yes |
| secondary: `toolCalls` | B2 arm median 17, range 14–20; E-002 isolated 18, range 15–22 | Mann-Whitney 10 v 10 needs near-complete separation for p < 0.05; in practice **≥ +5 calls** on the median with non-overlapping quartiles | yes |
| secondary: duration | B2 arm range 70 s – **3 790 s** (ratio 54); E-002 isolated ratio 1.75 | **≥ +40 %** on the median *and* the tail rule below not firing. The B2 arm's own spread cannot resolve less | yes |
| secondary: cost | B2 arm median $0.149, range $0.108–$0.167 (ratio 1.54) | **≥ +25 %** on the median | yes |
| R3's outcome | B2, 14 of 14 | **none — the baseline is at ceiling.** An effect cannot be detected in the direction the rule points, only in the direction of harm. Registered as such rather than as a threshold | yes |

**A result that lands inside an MDE is recorded as NOT DETECTABLE at this `n`, never as
refuted.** That sentence is here because the previous experiment did not have it.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` version `1.0.0` decides correctness — exit 0 or
the run is not scored. `tools/check-run-gate.sh` enforces that before any sheet is written.
Quality among passing runs is `benchmark/rubrics/backend-quality.yaml` **v2, sha
`396e1799eb2b`**, scored by `codex` (Decision C), with `opencode` as the second reader on a
subset.

> **AMENDED 2026-09-03, after the runs, on the acceptance gate's blocking finding.** This
> paragraph originally ended *"No registered variable moves between B2 and this experiment."*
> **That is false and the original wording is kept here rather than deleted.** The rubric,
> evaluator, benchmark sha and model are unmoved — which is what the sentence was reaching for
> — but `harness + version` is row 3 of this experiment's own controlled-variables table, and
> it moved: B2's claude arm ran on `2.1.251`, every run here on `2.1.259`. **That is precisely
> why this experiment compares against a concurrent control rather than against B2's stored
> numbers**, so the design was already right and only the sentence was wrong. B2 is used as a
> consistency check on the control, not as a comparator.

## Exclusions

Registered now, not after seeing the data.

- Any run whose record does not reach the observatory (the batch asserts its own `n`).
- Any run with `evaluation.exitCode != 0` is excluded from the **quality** comparison and
  reported separately in the verdict comparison; it is not deleted.
- Any run whose `claude_code.hook_execution_start` count is not 0 — the isolation regime failed
  and the run is not in the registered population.
- Duration only, on any run whose duration exceeds **10× its own arm's median** (the E-002 tail
  rule). The run stays in every other outcome.
- F13/F15 infrastructure failures, permission blocks, quota exhaustion.
- **A machine sleep during a batch voids the duration outcome for that batch, not the runs.**

## Decision rule

Registered before data.

| | |
|---|---|
| **KEEP `instructions-v0.1`** | R1's prediction holds at p < 0.05 **and** prediction 5 holds (nothing regresses). The version is kept *as a whole* only if at least one rule earned it |
| **KEEP THE RULE, DROP THE OTHERS** | The per-rule table below decides each rule separately. A rule whose registered outcome lands inside its MDE is **removed**, and the removal is the finding |
| **REJECT** | R1 lands inside its MDE *and* cost rises beyond +25 %: the file bought nothing and was not free |
| **INCONCLUSIVE** | Any outcome unsettleable — an isolation failure, a voided duration, or a treatment/control hash separation that is not perfect |

**Per-rule decision, because the gate says "remove every rule with no measured effect".**
Attribution rests on the three rules pointing at **disjoint outcomes** — R1 at a rubric
category, R2 at tool calls and duration, R3 at a behaviour already at ceiling. That is a real
assumption and it is registered as a threat, not asserted as a fact: if R2 inflates duration it
cannot mask R1, which is scored from the diff, but a rule interaction that changes *what* the
agent writes would be attributed to R1 by this design and could belong to R2.

## Threats to validity, registered before the run

1. **The rule is one inferential step from the rubric's anchor.** `maintainability` anchor 2
   rewards a `when` in expression position with no `else`; R1 says "prefer a construct that
   makes an unhandled case fail at compile time". R1 never names `when`, `else`, expression
   position or Kotlin, and it is a rule a real team would write — but it points at the same
   construct the scorer rewards. **If R1's prediction holds, the honest claim is "an instruction
   moved the agent onto the construct the rubric measures", not "instructions improve
   maintainability".** Teaching to the test is a bounded claim, not a void one, and the bound is
   written here rather than discovered by a reviewer.
2. **The predictions and the treatment share an author, and it is not the human.** See the
   provenance line at the top.
3. **`n=10` per arm still cannot resolve a moderate effect.** 7/10 versus 2/10 is p = 0.07 and
   will be reported as not detectable. This experiment can see a large effect or nothing.
4. **The isolation fields do not persist on this instrument.** `GET /api/runs/<id>` returns a
   four-key `runtime` block; `userSettingsIsolated` is absent, not null. The regime is therefore
   proved per run from `claude_code.hook_execution_start` in the telemetry, which is what the
   controlled-variables table registers. It is a stronger proof than the flag and a weaker
   record than a persisted field.

## Deliberate failure — the same three rules, diluted 25×

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-03T17:20:00Z; committed before the
first run of this arm.`

**What is broken on purpose.** `build/customizations/instructions-v0.1-bloated/CLAUDE.md` —
**1 455 words**, `sha256:807c5d03f77cc66106aa90d72fe50245` — carries the *identical three rules*,
verbatim, under the same heading, inside a plausible engineering handbook: layout, naming,
formatting, Kotlin idiom, Spring, errors, validation, persistence, concurrency, testing,
logging, dependencies, configuration, documentation, PRs, reviews, performance, security,
deprecation. Nothing in it contradicts the three rules and nothing in it is about BE-003.

This is the *dilution* arm, not a bloat-for-bloat's-sake arm. It separates two explanations that
the main comparison cannot: **"the rule worked"** from **"a 57-word file worked"**. If the rules
carry their effect at 1 455 words, the mechanism is the rule. If the effect disappears while the
words are still there, the mechanism is attention, and every conventions document this project
has ever recommended is on notice.

Registered arm: `EXP-B3-BLOAT-CLAUDE`, `variant: instructions`, **n = 5**, interleaved with
nothing — run as a block after the main batch, which is a registered weakness of this arm and
the reason its cost outcome is compared to the main *treatment* arm run the same hour rather
than to B2.

| # | Prediction | Magnitude | Mechanism |
|---|---|---|---|
| **DF1** | Cost rises against the `v0.1` arm | **≥ +25 %** median | 1 400 extra words enter the prompt on every run. `EXP-BE002-CLAUDEMD-V2` measured **+39 %** for a full conventions file at identical acceptance |
| **DF2** | `cacheCreationTokens` rises | **≥ +1 500 tokens** median | The overlay is committed into the repository before the agent starts, so it is read as project memory and lands in the prefix. This is the deterministic half of DF1 and the one that can falsify the *explanation* rather than the effect |
| **DF3** | R1's construct rate **falls** against the `v0.1` arm | direction only | Dilution: the same instruction competing with 19 other headings. **Explicitly not resolvable at n = 5 vs 10 unless separation is near-complete** — registered as a direction, and a null here means *not detectable*, not *no effect* |
| **DF4** | The evaluator verdict does not change | **5 of 5 pass** | None of the 19 added sections touches the acceptance criteria. If this fails, the added prose is doing something the experiment did not intend and the arm is void, not interesting |

**What would make this arm void rather than informative:** any run in it failing the evaluator
for a reason traceable to the handbook (DF4), or a harness version change between the main batch
and this arm. Both are checked from the run records before the arm is read.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

`Read and written by Opus 5 (claude-opus-5), autonomously, 2026-09-03T18:11Z. The author has
not reviewed this section.`

All 25 registered runs reached the observatory. Every one exited the evaluator 0.

| Arm | key | n | hash on the record | evaluator |
|---|---|---|---|---|
| treatment | `EXP-B3-INSTRUCTIONS-CLAUDE` | 10 | `sha256:90f95226cc3d429f6…` on **10 of 10** | 10/10 exit 0 |
| control | `EXP-B3-CONTROL-CLAUDE` | 10 | `null` on **10 of 10** | 10/10 exit 0 |
| deliberate failure | `EXP-B3-BLOAT-CLAUDE` | 5 | `sha256:807c5d03f77cc6610…` on **5 of 5** | 5/5 exit 0 |
| preflight | `EXP-B3-PREFLIGHT` | 1 | treatment hash, asserted before the batch | exit 0 |

**The hash separation is perfect**, which is the condition the decision rule names for *not*
being forced to INCONCLUSIVE. Held identical across all 25: runtime `claude-code 2.1.259`,
model `claude-haiku-4-5-20251001`, benchmark sha `0448643…`, evaluator `1.0.0`.

The arms were interleaved as registered — treatment 17:03, control 17:05, treatment 17:07,
control 17:09, and so on to 17:53. The bloat arm ran as a block afterwards, 17:55–18:05, which
is its registered weakness and the reason it is compared to the treatment arm rather than to
B2.

## Results

Four measurements, each in its own evidence file, each re-derivable by the recipe printed at
its top.

| | evidence |
|---|---|
| Main comparison, 7 continuous outcomes + the construct | `evidence/b03/arm-comparison-20260903T180015Z.txt` |
| Construct census, all 20 runs, read before any scorer | `evidence/b03/construct-census-20-runs-20260903T175514Z.txt` |
| R3 convention census, all 20 runs | `evidence/b03/convention-census-r3-20-runs-20260903T180900Z.txt` |
| Rubric, both arms scored, 20 sheets | `evidence/b03/rubric-comparison-both-arms-20260903T181125Z.txt` |
| Deliberate failure arm | `evidence/b03/bloat-arm-comparison-20260903T180936Z.txt` |

**Not one outcome separates the arms.** The smallest p in the whole experiment is 0.165, on
duration, and it points the wrong way — the treated arm ran *faster*.

```
outcome                  treatment med   control med   delta %     MW p
estimatedCost                    0.152        0.1559      -2.5    0.684
durationMs                     8.9e+04     1.005e+05     -11.4    0.165
cacheCreationTokens          2.514e+04     2.613e+04      -3.8    0.529
inputTokens                       1412          1420      -0.6    0.971
outputTokens                      6910          6578      +5.0    0.912
toolCalls                           18            18      +0.0    1.000
modelCalls                        21.5          22.5      -4.4    0.912

maintainability anchor 2       2 of 10       3 of 10             1.000 (Fisher)
R3 convention honoured        10 of 10      10 of 10             1.000 (Fisher)
architecture-consistency       med 2         med 2               1.000
change-focus                   med 1         med 1               1.000
```

**The scorer and the hand census agree on all twenty runs, cell for cell.** The maintainability
reading was committed before any scorer ran; the codex sheets afterwards name the same two
treatment runs and the same three control runs, with no disagreement in either direction.

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| **R1** | the defensive rule moves the construct: treatment ≥ 8/10 vs control ≤ 3/10 | **NO — refuted as a claim about the treated arm; NOT DETECTABLE as a difference.** See the correction below, which the acceptance gate forced | **2/10 vs 3/10**, p = 1.0. The control half held exactly (3/10, consistent with B2's 1/5). The treatment half failed |
| **R2** | the verification rule costs: toolCalls ≥ +5, duration ≥ +40 %, verdict unchanged | **half NO, half YES** | Verdict unchanged at **10/10 both arms** — that half held. The cost did not appear: toolCalls Δ **0** (p=1.0), duration **−11.4 %**. Both land inside the registered MDE, so the cost is **NOT DETECTABLE at this n**, not refuted. R2 was predicted to be *real and useless at once*; it measured as **useless and free** |
| **R3** | the convention rule moves nothing at all | **YES, in both halves** | **20 of 20 honoured, both arms**, p = 1.0. And the ceiling claim it rests on reproduced: B2 measured 14/14, this measures 20/20, pooled **34 of 34** |
| **4** | the file costs more than the control but under +25 % | **NOT DETECTABLE** — *this row said "refuted" until the acceptance gate caught it contradicting the artifact's own MDE rule in the same cell* | Predicted *positive but under +25 %*. Observed **−2.5 %**, p = 0.68, **inside the registered ±25 % MDE**. The rule is absolute: inside the MDE is *not detectable at this n*, never refuted. The point estimate sits on the opposite side of zero from the prediction, and that is worth noting and is not a falsification: this experiment cannot resolve a cost effect smaller than 25 %, in either direction. **The file is not measurably paid for; it is also not measurably free** |
| **5** | nothing regresses | **YES** | architecture-consistency med 2 = 2, change-focus med 1 = 1, p = 1.0 on both. Not merely non-falling — identical |

| # | Deliberate failure | Held? | Actual |
|---|---|---|---|
| **DF1** | cost ≥ +25 % against the v0.1 arm | **NOT DETECTABLE** | +4.2 %, p = 0.68 |
| **DF2** | cacheCreationTokens ≥ +1 500 | **NOT DETECTABLE** | **+610**, p = 0.68, while `cachedTokens` moved **+13.2 %** |
| **DF3** | the construct rate falls under dilution | **NOT DETECTABLE, direction reversed** | **3/5** against the concentrated file's 2/10, p = 0.25 |
| **DF4** | the verdict does not change, 5/5 | **YES** | 5 of 5 exit 0; the arm is informative, not void |

### R1's verdict, corrected — the acceptance gate's finding, and it is the sharpest of the run

`lab-acceptance / minimax-m3` returned **REJECT** on this artifact, and its first blocking
finding is right in a way that changes what R1 is entitled to claim.

**What was written, and why it was wrong.** The defence of "refuted" read: *"8/10 vs 2/10 would
have given p = 0.023, so the registered effect was inside what this design could see."* **2/10 is
the treatment rate that was observed, not the control.** The control that occurred was **3/10**.
The MDE table registered before the run assumed a control of 2/10 — taken from B2's 1-of-5 — and
against that assumption 8/10 does give p = 0.023. Against the control that actually turned up it
does not:

| registered effect, treatment | vs the **assumed** control 2/10 | vs the **occurred** control 3/10 |
|---|---|---|
| 8 of 10 | p = 0.023 ✔ | **p = 0.070 ✘** |
| 9 of 10 | p = 0.006 | p = 0.020 ✔ |

**The control rate is not something a design chooses.** It came in one run higher than the
baseline it was projected from, and that alone moved this experiment's resolving power at the
registered effect size from inside p < 0.05 to outside it. The experiment was very slightly
underpowered against the world that showed up, and nothing in the registration was careless —
this is what it looks like when an MDE is derived honestly and reality still lands on the other
side of the line.

**So R1 splits, and both halves must be stated:**

| reading of R1 | verdict | on what |
|---|---|---|
| **as a difference** between arms at p < 0.05 | **NOT DETECTABLE at this n** | 8/10 vs the occurred 3/10 is p = 0.070. A reader applying this artifact's own MDE rule lands here, and the rule says *never refuted* |
| **as the claim it literally makes about the treated arm** — *"treatment reaches anchor 2 on ≥ 8 of 10 runs"* | **REFUTED** | If the treated rate were truly 0.8, the chance of observing ≤ 2 of 10 is **0.000078**. This is a point claim about one arm, it does not need the control to test, and it fails by four orders of magnitude |

**The decision does not move; the epistemic label does.** REJECT still follows — from the
treated arm's own rate, from the direction being against the rule, and from the per-rule clause.
What is withdrawn is the stronger sentence *"the effect was inside what this design could see"*.
At the effect size registered, against the control that occurred, **it was marginally outside**,
and saying otherwise would have been this project's own recurring failure — a claim about an
instrument that was never checked against the instrument.

**What this costs the next experiment, concretely.** An MDE derived from a point estimate of the
baseline inherits that estimate's own uncertainty and does not say so. B2's control was 1 of 5;
projecting it to 2 of 10 was reasonable and was still wrong by one run. **Follow-up 6: derive the
MDE against the upper end of the baseline's interval, not its point estimate** — here that would
have registered n = 12 or 15 per arm rather than 10, and the difference reading would have been
decidable either way.

## Failure analysis

**The hypothesis was wrong, and it was wrong in the half it was most confident about.**

The mechanism said: an instruction moves behaviour only where behaviour has somewhere to move,
so a rule aimed at a floor (1/5 on the construct) should move it and a rule aimed at a ceiling
(14/14 on the convention) should not. The ceiling half is now measured twice and holds at
34/34. **The floor half is refuted.** Room to move is not sufficient. The agent had somewhere
to go, was told to go there in a file proved present on every run, and went there 2 times in 10
— less often than the arm that was told nothing.

**What the dilution arm did to the leading explanation.** The obvious rescue for R1 is that 57
words got lost among everything else in context. The bloat arm tests the opposite end of that
axis and refuses to cooperate: at 1 455 words the construct appeared **3 of 5**, more often
than at 57 words, not less. Across all three arms the construct appears **8 of 25** with no
pair separating. The most defensible summary is that on this task, at this model, the construct
is chosen at roughly one run in three **regardless of what the instruction file says or
whether one exists at all**.

**What this does not license.** It does not show instructions never work. One rule, one task,
one model, n=10 per arm, and a design that by its own registered MDE can see a large effect or
nothing. What it does show, on the sharpest instrument this project has, is that the specific
recommendation these repositories have been making — write a short global instruction file, it
will change what the agent builds — produced **no measurable change in anything**, including
its own cost.

## Sanity checks

- [x] **Did any dramatic number appear? Has it been explained *and* the explanation tested?**
  Yes: `test-quality` null on 4 of 10 treatment runs and 0 of 10 control. The explanation —
  the scorer failing — was tested and rejected: the nulls track exactly the runs that changed
  no test file, verified twice, once on `result.changedFiles` and once on `git status` in the
  worktree. The scorer was right and `null` was the correct value. The *interesting* reading —
  that the arm told to verify wrote tests less often — is p = 0.087, was never registered as an
  outcome, and is recorded as an untested hypothesis in the evidence file and as follow-up 1.
  It is **not** a result of this experiment.
- [x] **Did any flattering number appear? Has it been disbelieved twice?** The flattering number
  is the 20-of-20 scorer/hand agreement, and it flatters the instrument rather than the
  hypothesis. Disbelief 1: the hand census was committed at 17:55 and the treatment sheets
  written 17:59–18:02, control sheets 18:06–18:09, so the reading could not have been fitted to
  the sheets. Disbelief 2: agreement is on a construct with a mechanical definition — a `when`
  in expression position with no `else` — so this is agreement about something checkable, and
  it is evidence the scorer reads the named construct, **not** evidence the rubric measures
  maintainability.
- [x] **If a fix motivated this run, did the original symptom actually disappear?** The fix
  carried in was E-002 follow-up 6: an MDE column filled with prediction thresholds instead of
  being derived. This experiment derived every MDE from a measured spread before the run, and
  it changed the verdicts — R2's and prediction 4's misses are reported as NOT DETECTABLE
  rather than refuted precisely because of it. The symptom is gone and the fix did work that
  was visible in the output.

Two more, unprompted:

- [x] **Was the treatment delivered?** 10/10 hash present, 10/10 hash absent, one preflight
  asserted before the batch. This is the one thing Phase 1 could not do and it is now L2.
- [x] **Did the isolation regime hold?** `claude_code.hook_execution_start` = 0 on every run of
  the registered population, which is how the controlled-variables table registered it — the
  run record's isolation fields still do not persist (threat 4), and the telemetry proof is the
  stronger of the two.

## Decision

**REJECT `instructions-v0.1`. Remove all three rules. Ship the empty result.**

Reached through the registered rule, which needs its own note because the rule as written does
not have a row for what happened:

| Registered row | Applies? |
|---|---|
| KEEP the version | No. R1 did not hold at p < 0.05 |
| REJECT | **The row's stated condition is *R1 inside its MDE **and** cost above +25 %*. The second half is false — cost was −2.5 %.** By the letter, REJECT does not fire |
| INCONCLUSIVE | No. Hash separation was perfect, no isolation failure, no voided duration |
| KEEP THE RULE, DROP THE OTHERS — *"a rule whose registered outcome lands inside its MDE is removed, and the removal is the finding"* | **Yes, and it applies to all three.** R1 refuted; R2 not detectable; R3 held at "moves nothing". Every rule is removed, and a file with every rule removed is an empty file |

**The per-rule clause emptied the file and the version-level rows never fired.** That is a
defect in the decision rule and it is recorded rather than smoothed over: REJECT was written
to require the file to be *expensive as well as useless*, which quietly assumes a useless file
is worth keeping if it is cheap. **A free useless rule is still a rule someone has to read,
trust and maintain**, and this experiment is the argument against keeping it. Registered as
follow-up 4, to be fixed in the rule *before* the next experiment uses it, not retroactively
here.

Per rule, on evidence:

| Rule | Verdict | On what |
|---|---|---|
| **R1** defensive construct | **REMOVE** | Refuted at the registered n. 2/10 vs 3/10 |
| **R2** run the verification command | **REMOVE** | No measured effect on either registered outcome. Its one visible correlate — 4 runs with no test written — is unregistered and untested |
| **R3** follow documented conventions | **REMOVE** | Held: moves nothing, because 34/34 needs no help |

**The version is not replaced by a better one.** B3's build deliverable is "minimal global
instructions", and the honest minimum this experiment supports is **no global instruction
file**, until a rule exists that has been shown to move something. That is what goes to the
gate.

## Follow-up

1. **Test-writing rate as a registered primary outcome.** 4/10 vs 0/10, p = 0.087, unregistered
   and therefore not a result. The mechanism to register: *"run the verification command"
   redirects effort from writing a check to running an existing one, because the task's
   acceptance does not require a new test.* Needs n ≥ 20 per arm, and the outcome declared
   before the runs.
2. **The cache-bucket explanation now has two experiments' worth of unexplained numbers and
   still one test.** E-002 explained an `inputTokens` collapse by bucket migration; DF2 has
   `cacheCreationTokens` +610 while `cachedTokens` moved +84 000 for 1 400 added words. The arm
   that separates it is a fixed-content overlay run twice against a cold and a warm cache.
3. **Was R1 too abstract, or is the effect absent?** R1 never names `when`, `else` or Kotlin —
   deliberately, threat 1. The cheap discriminator is a second treatment naming the construct
   outright. If the explicit rule moves it and the abstract one does not, the finding is about
   the *distance* between rule and construct, which is a far more useful thing to know than
   "instructions work".
4. **Repair the decision rule's REJECT row** so that useless-and-cheap reaches a verdict
   without going through the per-rule clause. See the Decision section.
5. **The bloat arm's real finding was never registered:** a 25× larger always-on file costs
   +4.2 %. This project's brevity recommendation rests on `EXP-BE002-CLAUDEMD-V2`'s +39 %,
   which moved more than one variable. Someone should decide whether the recommendation stands.
6. **Derive the MDE against the upper end of the baseline's interval, not its point estimate.**
   B2's control was 1 of 5; this experiment projected 2 of 10 and the control came in at 3 of 10,
   which moved the registered effect size from p = 0.023 to p = 0.070 — from decidable to not.
   Registering n = 12 or 15 per arm would have covered it. **This is the first time an MDE in
   this project has been derived correctly and still been too small**, and the fix is about the
   baseline's uncertainty rather than about anyone's carelessness.
