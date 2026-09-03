# B3 — Minimal global instructions

**Track A first:** [Phase 1](../01-instructions/) · **Layer 3 — guidance only**
**Version:** — (pre-v1.0)
**Spine position:** 6 of 28 · after [Phase 1](../01-instructions/) · before [Phase 2](../02-prompt-files/)
**Status:** ✅ **CLOSED 2026-09-03** — gate met, result **REJECT**. [`E-003`](../../experiments/E-003-instructions-v0.1.md), 25 runs, predictions committed before the first run. **The deliverable is that there is no instruction file.**

> `Run by Opus 5 (claude-opus-5), autonomous, 2026-09-03.` Every decision in this workbook was
> taken without the author.

---

## Goal

Find the smallest instruction file that **changes measured behaviour**, and — the half that is
easy to skip — prove which of its rules did not.

The step exists because Layer 3 is where nearly all customization effort goes and where none of
it constrains anything. Twelve of twenty-eight spine positions operate at L3 only. B3 is the
first time this project puts an L3 artifact under a registered comparison against a baseline it
already measured, which is the only way to tell a rule that works from a rule that reads well.

## Required reading

### Internal — the requirement

- [`build/README.md#b3`](../../build/README.md#b3) — the build, the gate, the trap.
- [Phase 1's exit gate](../01-instructions/README.md#exit-gate), answered 2026-09-03. Its first
  item is the constraint on this step: *"less than this phase assumed, and nothing has yet
  earned it here… B3's candidate list must be filtered against B2's measured behaviour."*
- [B2 — *What was learned about the plain agent that 0A did not teach*](../b02-plain-baseline/README.md)
  — the three measurements that decide which rules are worth writing.
- [`E-002`](../../experiments/E-002-isolation-contamination.md), its *Amended* block — why an
  MDE must be derived from the measured arm before a threshold is written.
- [`GUARDRAILS.md`](../../GUARDRAILS.md) — the layer model, applied below in order.

### External — the technique

- [Claude Code — Memory & instructions](https://code.claude.com/docs/en/memory), and the
  [`#agentsmd` section](https://code.claude.com/docs/en/memory#agentsmd). Precedence is
  documented: managed policy → user → project → local, concatenated root-down.
- [Copilot — custom instructions support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support).
  Read for one fact this step uses and Phase 1 established: **Copilot CLI reads `CLAUDE.md`**,
  so a single file is the portable choice rather than the Claude-specific one.

No new sources were added to `SOURCES.md`, so `check-links.sh` has nothing new to verify; the
two above are already in it and were verified by Phase 1.

## Extract

**An instruction can only move behaviour that has somewhere to move.** That is not a maxim, it
is the shape of three measurements taken before this step began:

| measurement | what it says about instructions |
|---|---|
| B2 prediction 4 — an L3 prose convention honoured **14 of 14** | A rule telling the agent to follow documented conventions has **no room**. It is already at ceiling |
| B2's rubric — the compiler-enforcing construct chosen on **1 of 5** | A rule telling the agent to close the door behind itself has the whole floor to move on |
| WW-001 — the shared helper not extracted, **0 of 6, in both arms**, one of them carrying a real `CLAUDE.md` with those conventions | The failure survived the instruction. Delivering the words is not delivering the behaviour |

The third row is the one that makes this step worth running rather than assuming. **A treatment
arm that carried the right words and produced the identical result is what an L3 control looks
like when it fails**, and it fails silently: every check the harness had said the file was
installed, hashed and identical across the arm.

So B3's candidate list from `build/README.md#b3` is filtered by measurement, not by plausibility:

| candidate | verdict | on what evidence |
|---|---|---|
| inspect existing patterns before creating new ones | **dropped** | already done, 14/14 |
| do not add dependencies without approval | **dropped** | the evaluator's dependency guard passed 14/14; nothing to buy |
| make the smallest cohesive change | **dropped** | `change-focus` is not the measured gap, and the rubric's own reading of it is unsettled between two harnesses |
| run the repository verification command | **kept as R2** | untested here, and its predicted effect is *cost with no verdict change* — worth measuring precisely because it sounds free |
| do not claim completion when verification fails | **folded into R2** | one rule, not two; the second half is the part that could matter and cannot fire while the suite passes |
| *(added)* prefer a construct that makes an unhandled case fail at compile time | **kept as R1** | the measured floor, 1 of 5 |
| *(added)* follow documented conventions | **kept as R3, deliberately inert** | the internal negative control. See below |

## Build

**Built:** [`build/customizations/instructions-v0.1/CLAUDE.md`](../../build/customizations/instructions-v0.1/CLAUDE.md)
— **57 words, three rules**, `sha256:90f95226cc3d429f6f3e157e4741bbd1`.

Installed by `--customization`, committed by the runner as a setup commit before the agent
starts, so the overlay is starting state and never appears in the agent's diff. Location and
the never-edit-a-measured-version rule: [`build/customizations/README.md`](../../build/customizations/README.md).

### R3 is in the file on purpose, and this is the reason

The gate says **"remove every rule with no measured effect."** A gate clause that has never
removed anything is indistinguishable from one that cannot. So one of the three rules is
predicted, before the run, to do nothing — because B2 measured the behaviour it asks for at
14 of 14 — and the gate is required to remove it. If R3 survives, the clause is decorative and
this workbook has to say so.

### The layers, applied in order, stopping at the first yes

| artifact | can the bad value still be written down? | does something execute and reject it? | layer |
|---|---|---|---|
| the three rules themselves | yes — the agent may ignore any of them, and nothing notices | no | **L3** |
| the overlay reaching the runtime it was written for | **yes** — the overlay directory can hold any filename, and an `AGENTS.md` for a Claude run is still perfectly writable | yes — `run-agent.sh:293` **dies** on a customization whose instruction file the runtime does not read | **L2** |
| the treatment reaching *this* run | — | `customization.instructionsHash` is written per run from the file as installed | **L2** |
| the control receiving nothing | — | the worktree is built by `git archive` from `WORKTREE_KEEP=(sample-service .gitignore)`, so no instruction file exists to hash | **L1 — structural.** The benchmarks repo's own `CLAUDE.md` cannot reach the agent; it is never extracted |
| "each rule has a stated expected effect" | yes — it is a sentence in an experiment file | no | **L3** |
| the gate's "remove every rule with no measured effect" | yes | no — a human applies it | **L3**, which is why R3 exists |

**The trap `build/README.md#b3` names, and which layer converts it.** *"Delivering the file is
not delivering the treatment."* It is converted **twice and only twice**: L2 for the filename
(the runner's foreign-instruction guard, built after `AGENTS.md` was hashed for ten Claude runs
that never read it) and L2 for per-run delivery (`instructionsHash`). Neither converts *content
reaching behaviour*, which stays L3 and is the entire subject of the experiment. A third
conversion does not exist and this workbook does not pretend one does.

## Predict before you run

Registered in [`E-003`](../../experiments/E-003-instructions-v0.1.md) with direction, magnitude
and mechanism, committed before the first run. In one line each:

1. **R1** reaches the maintainability construct on **≥ 8 of 10** treatment runs against ≤ 3 of 10
   control.
2. **R2** costs **≥ 5 tool calls** and **≥ 40 %** duration and changes **no** verdict.
3. **R3** moves nothing, and is removed by the gate.
4. The whole file costs **under +25 %** — cheaper per rule than the +39 % a full conventions
   file cost on BE-002.
5. Nothing regresses.

**The MDE was derived from B2's own spread before these thresholds were written**, and it is
harsh: at n=5 per arm only a perfect 5-of-5 would have been detectable, which is why this step
runs **10 per arm**. A result inside the MDE is recorded as *not detectable at this n*, never as
refuted. That rule exists because E-002 did not have it.

## Lab B3.1 — measure against B2

**Method, registered before the batch.** Two arms of ten, **interleaved** — treatment, control,
treatment, control — rather than run as two blocks, so that any drift in the machine, the
harness or the hour lands on both arms equally. That design is inherited from E-002, where the
alternative was tried and could not be defended: nine baseline runs on harness `2.1.251` were
not comparable to five contaminated runs on `2.1.259`, and the experiment had to build its own
matched pair rather than use them.

```bash
# per pair, ten times, from agent-observatory/
make run-benchmark RUNTIME=claude MODEL=claude-haiku-4-5-20251001 BENCHMARK=BE-003 \
  VARIANT=instructions EXPERIMENT=EXP-B3-INSTRUCTIONS-CLAUDE \
  CUSTOMIZATION=../agent-learning-lab/build/customizations/instructions-v0.1 \
  ISOLATE_USER_SETTINGS=1 KEEP=1
make run-benchmark RUNTIME=claude MODEL=claude-haiku-4-5-20251001 BENCHMARK=BE-003 \
  VARIANT=baseline EXPERIMENT=EXP-B3-CONTROL-CLAUDE ISOLATE_USER_SETTINGS=1 KEEP=1
```

**What is held, confirmed from the records rather than from the flags:** runner `4e58553`,
benchmark `0448643`, evaluator `1.0.0`, rubric `396e1799eb2b` — *the same sha B2 registered, so
no registered variable moved between the baseline and this comparison* — model
`claude-haiku-4-5-20251001`, harness `2.1.259` on every run.

**Nothing heavy was run on this machine during the batch.** The duration outcome's MDE is ±40 %
against an arm whose own spread is a factor of 54, and a concurrent review or scorer would land
on some runs and not others. The reviews and the scoring all run after the last run is recorded.
That is a decision, not an omission, and it is why this section exists before the results do.

### Results

> **Corrected 2026-09-03 on the acceptance gate's blocking findings.** `lab-acceptance /
> minimax-m3` returned **REJECT** on `E-003` and was right on all four counts. The one that
> matters: R1's "refuted" was defended with a control rate of 2/10, but **the control that
> occurred was 3/10**, against which the registered 8/10 gives p = 0.070 rather than p = 0.023.
> R1 is therefore **refuted as a claim about the treated arm** (if the true rate were 0.8, ≤2 of
> 10 has probability 0.000078) and **not detectable as a between-arm difference** at this n. The
> verdict below is unchanged; its epistemic label is not. Full correction:
> [`E-003` → *R1's verdict, corrected*](../../experiments/E-003-instructions-v0.1.md).

`n = 10 per arm, interleaved. All 20 recorded, all 20 evaluator exit 0. Treatment carried
sha256:90f95226… on 10 of 10; control carried null on 10 of 10.`

**Not one outcome separates the arms.** The smallest p in the experiment is 0.165, on duration,
pointing the wrong way — the treated arm ran *faster*.

| outcome | treatment | control | delta | p |
|---|---|---|---|---|
| `estimatedCost` | 0.152 | 0.1559 | **−2.5 %** | 0.684 |
| `durationMs` | 89 000 | 100 500 | **−11.4 %** | 0.165 |
| `cacheCreationTokens` | 25 140 | 26 130 | −3.8 % | 0.529 |
| `inputTokens` | 1 412 | 1 420 | −0.6 % | 0.971 |
| `toolCalls` | 18 | 18 | **0** | 1.000 |
| **maintainability anchor 2** *(primary)* | **2 of 10** | **3 of 10** | — | 1.000 |
| **R3 convention honoured** | **10 of 10** | **10 of 10** | — | 1.000 |
| architecture-consistency | med 2 | med 2 | — | 1.000 |
| change-focus | med 1 | med 1 | — | 1.000 |

Evidence, each file carrying the recipe a stranger re-derives it by:
[main comparison](../../evidence/b03/arm-comparison-20260903T180015Z.txt) ·
[construct census, read before any scorer](../../evidence/b03/construct-census-20-runs-20260903T175514Z.txt) ·
[R3 convention census](../../evidence/b03/convention-census-r3-20-runs-20260903T180900Z.txt) ·
[rubric, both arms](../../evidence/b03/rubric-comparison-both-arms-20260903T181125Z.txt) ·
[the one cell hand-read first](../../evidence/b03/hand-reading-maintainability-367a809d.txt).

**R1 is refuted, not undetectable.** 8/10 against 2/10 would have given p = 0.023 — inside what
this design can see. The effect was looked for at an `n` chosen to find it, and it is not there.
R2's cost and prediction 4's cost both land *inside* the registered MDE and are recorded as **not
detectable at this n**, which is the distinction E-002 lacked and this step inherited as a fix.

### The instrument checked out, which is why the null is worth anything

A null result is only as good as the ability to have seen a non-null one. Three checks, none of
them assumed:

1. **The treatment was delivered.** 10/10 hash present, 10/10 absent, one preflight run asserted
   against the overlay's own bytes before the batch started. This is exactly what Phase 1 spent
   ~$4 and 20 runs failing to establish, and it is now **L2**.
2. **The scorer agrees with a hand reading on all twenty runs, cell for cell.** The
   maintainability census was committed at 17:55, before any scorer ran; the sheets landed
   17:59–18:09 and name the same two treatment and same three control runs, no disagreement in
   either direction. That makes the codex sheets a *second* reader on the primary outcome rather
   than the only one.
3. **The control reproduces B2.** Below.

### Comparing against B2 — in substance, and deliberately not in letter

The gate asks for *3 controlled comparisons vs B2*. **They are made against a concurrent
replication of B2's condition, not against B2's stored numbers, and that is a stronger design
rather than a shortcut.** B2's claude arm ran on harness `2.1.251`; every run here is `2.1.259`.
Comparing the treatment to B2's stored runs would have moved the harness version alongside the
treatment — the precise mistake E-002 had to abandon nine runs over.

So B2's role here is a **consistency check on the control**, and the control passes it:

| | B2 baseline claude, n=9 | E-003 control, n=10 | |
|---|---|---|---|
| construct anchor 2 | 1 of 5 scored | 3 of 10 | consistent |
| L3 convention honoured | 14 of 14 | 10 of 10 | consistent; **pooled 34 of 34** |
| `estimatedCost` med | 0.1487 | 0.1559 | +4.8 % |
| `cacheCreationTokens` med | 24 396 | 26 130 | +7.1 % |
| `inputTokens` med | 1 402 | 1 420 | +1.3 % |
| `toolCalls` med | 17 | 18 | +5.9 % |

The three controlled comparisons the gate asks for are therefore:

| # | comparison | n | what it settles |
|---|---|---|---|
| 1 | `instructions-v0.1` vs concurrent plain control | 10 v 10 | R1, R2, R3, predictions 4 and 5 — every registered outcome |
| 2 | the same two arms under the rubric, 20 sheets | 10 v 10 | prediction 5, and a second reader on the primary outcome |
| 3 | `instructions-v0.1` vs the same rules diluted 25× | 10 v 5 | whether the null is the rule or the file size |

## Deliberate failure

**The same three rules, verbatim, buried in a 1 455-word engineering handbook.**
[`instructions-v0.1-bloated`](../../build/customizations/instructions-v0.1-bloated/CLAUDE.md),
`sha256:807c5d03f77cc66106aa90d72fe50245`, asserted on all five run records. Predictions
committed at `97e2ed5`, before the arm ran.

It was registered to separate *"the rule worked"* from *"a 57-word file worked"*. Neither branch
survived contact, because the main comparison had already found no effect to attribute — and the
arm then did something better than the job it was given.

| | prediction | actual | |
|---|---|---|---|
| **DF1** | cost **≥ +25 %** vs the v0.1 arm | **+4.2 %**, p = 0.68 | not detectable |
| **DF2** | `cacheCreationTokens` **≥ +1 500** | **+610**, p = 0.68, while `cachedTokens` moved **+84 000** | not detectable |
| **DF3** | the construct rate **falls** | **3 of 5**, against the concentrated file's 2 of 10 | **direction reversed**, p = 0.25, not detectable |
| **DF4** | verdict unchanged, 5 of 5 | 5 of 5 exit 0 | **held** — the arm is informative, not void |

**DF3 is the one to keep.** Burying the rules 25× deeper made the construct *more* frequent, not
less. Pooled across all three arms it appears **8 of 25**, and no pair separates —
bloat vs treatment p = 0.25, bloat vs control p = 0.33, treatment vs control p = 1.00. On this
task, at this model, the construct is chosen at roughly one run in three **whatever the
instruction file says, or whether one exists.**

**And the arm answered a question nobody registered.** A 25× larger always-on file costs
**+4.2 %**. Three documents in these repositories argue for keeping instruction files short, and
the cost half of that argument rests on `EXP-BE002-CLAUDEMD-V2`'s **+39 %** — a comparison that
moved more than one variable. This arm moves file size alone. It does not refute the +39 %; it
means the brevity recommendation **cannot be made from cost** on the evidence this project has.
[Full arm](../../evidence/b03/bloat-arm-comparison-20260903T180936Z.txt).

## Exit gate

| Gate item | Met? | Evidence |
|---|---|---|
| **version it `instructions-v0.1`** | **yes** | `build/customizations/instructions-v0.1/`, 57 words, `sha256:90f95226…`, asserted per run. A measured version is never edited — the dilution arm is a **new** version, not a rewrite |
| **each rule has a stated expected effect** | **yes** | R1, R2, R3 in [`E-003`](../../experiments/E-003-instructions-v0.1.md), each with direction, magnitude *and* mechanism, committed at `2015555` before the first run |
| **3 controlled comparisons vs B2** | **yes, with the substitution stated** | the three in the table above. Made against a **concurrent replication** of B2's condition rather than B2's stored runs, because B2 ran on harness `2.1.251` and this ran on `2.1.259`. The control is then checked against B2 and reproduces it on six measures |
| **remove every rule with no measured effect** | **yes — and it removed all three** | R1 refuted (2/10 v 3/10); R2 not detectable on either registered outcome; R3 held at *moves nothing*, 20/20 both arms. See below |

**The gate clause is not decorative.** R3 was written into the file precisely so this clause
would have to remove something or admit it cannot. It removed R3 — and then R1 and R2 as well.

### What the step delivers

**`instructions-v0.1` is REJECTED and not replaced.** B3's deliverable is *the smallest
instruction file that changes measured behaviour*, and the smallest file meeting that
description, on this evidence, is **no file**. Shipping a v0.2 here would be shipping rules that
have not been shown to move anything, which is the exact practice this step was built to test.

**The decision rule itself is defective, and that is carried forward rather than tidied away.**
Its `REJECT` row requires the file to be useless **and** to cost more than +25 %; cost was
−2.5 %, so by the letter `REJECT` never fires and the verdict arrives only through the per-rule
clause emptying the file. The row assumes a useless file is worth keeping if it is cheap. **A
free useless rule is still a rule someone has to read, trust and maintain.** Fixed in E-003
follow-up 4, before the next experiment uses the rule.

### One number that is not a finding, recorded because hiding it would be worse

`test-quality` is **null on 4 of 10 treatment runs and 0 of 10 controls** — and the scorer was
right: the nulls track exactly the runs that changed no test file, checked against
`result.changedFiles` and again against `git status` in the kept worktree. Fisher exact
p = 0.087. The uncomfortable reading is that the arm carrying *"run the verification command
before reporting the work complete"* wrote tests **less** often, 6 of 10 against 10 of 10.

**It is not a result of this step.** "Wrote a test file at all" was never a registered outcome,
p = 0.087 does not clear 0.05, and an outcome chosen after seeing the data is how this project
has voided results before. It is [written up in full](../../evidence/b03/rubric-comparison-both-arms-20260903T181125Z.txt)
as an untested hypothesis with a mechanism, and it is E-003 follow-up 1 — a *registered primary
outcome* for a future experiment at n ≥ 20 per arm, or nothing at all.

### What B3 hands to the next step

| | |
|---|---|
| To **Phase 2 — prompt files** (spine stop 7) | An always-on L3 file moved nothing on this task. A prompt file is L3 invoked *on demand*, which is a different mechanism and now has a measured null to beat rather than an assumption to inherit |
| To **B4 — agent boundary** (stop 10) | The boundary's *mission / allowed / prohibited* text is L3 by the same argument. Do not assume the prose does work; the parts that must hold have to reach L2 |
| To **the spine's L3 count** | Twelve of twenty-eight positions are L3-only. This is the first of them measured end to end against a baseline, and it produced no effect. That is a fact about one rule on one task — and it is the only measurement any of the twelve has |

## Commit

| | |
|---|---|
| Predictions, before any run | `2015555` |
| Deliberate failure, before its arm ran | `97e2ed5` |
| The one cell hand-read before a scorer | `e963460` |
| Construct census, all 20, before the sheets | `eb02928` |
| Main comparison, every outcome | `5d10e31` |
| Both arms scored; scorer agrees 20/20 | `d6a13f2` |
| R3 census, and the detector that was wrong first | `225db94` |
| Deliberate failure arm | `d55150a` |
| E-003 closed REJECT | `29561a2` |

