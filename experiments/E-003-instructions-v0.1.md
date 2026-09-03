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
| Content hash | `sha256:90f95226cc3d429f6f3e157e4741bbd1` — 57 words, three rules |
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
subset. **No registered variable moves between B2 and this experiment.**

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

## Results

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | | | |

## Failure analysis

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

## Follow-up
