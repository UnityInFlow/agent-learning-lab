# B3 — Minimal global instructions

**Track A first:** [Phase 1](../01-instructions/) · **Layer 3 — guidance only**
**Version:** — (pre-v1.0)
**Spine position:** 6 of 28 · after [Phase 1](../01-instructions/) · before [Phase 2](../02-prompt-files/)
**Status:** 🟡 **RUNNING 2026-09-03** — `instructions-v0.1` registered as [`E-003`](../../experiments/E-003-instructions-v0.1.md), predictions committed before the first run

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
| the overlay reaching the runtime it was written for | no — `run-agent.sh` **dies** if a customization installs an instruction file the runtime does not read | `run-agent.sh:293` | **L2** |
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

<!-- results filled after the batch -->

## Deliberate failure

<!-- prediction first, committed, then the bloated file -->

## Exit gate

<!-- filled from evidence -->

## Commit

<!-- filled from evidence -->
