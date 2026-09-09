# B6 — One specialist skill

**Track A first:** [Phase 3](../03-skills/) · **Layer 3**
**Version:** **v1.0**
**Spine position:** 13 of 28 · after [B5](../b05-workflow-phases/) · before [Phase 5A](../05a-guardrails/)
**Status:** 🟨 open — §4 step 1 done, branch `stop13/b6-specialist-skill`

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b6).
> Everything else is yours to fill.

---

## Goal

Build **exactly one** specialist skill, chosen from a failure **measured** in B2–B5, and find out
whether a skill removes a failure that an agent definition did not.

**The measurement is against B5, not against a plain baseline.** `Lab B6.1` compares
`phases-v1.0` with and without the skill, so the only failures worth targeting are ones
**`phases-v1.0` still has**. That rules out more than it sounds like it does — see the choice
below.

## Required reading

### Internal — the requirement

- [`BUSINESS-REQUIREMENTS`](../../../BUSINESS-REQUIREMENTS.md) §10.8 — `skills/<skill>/SKILL.md`,
  the eight questions a skill answers.
- `BUSINESS-REQUIREMENTS` **P4** — evidence before complexity. B6 is where that principle is most
  easily broken, because a skill is cheap to write and expensive to justify.
- `BUSINESS-REQUIREMENTS` §1130 — never install unreviewed skills into bank repositories. The
  reason B6 builds **one** and measures it rather than shipping a library.

### Internal — the measurements this stop must not re-derive

- [`experiments/E-004-skill-description.md`](../../experiments/E-004-skill-description.md) —
  **the description is the selector**: matched 5 of 5, misdescribed 0 of 5, control 0 of 5,
  `p = 0.0079`, bodies byte-identical. **A skill that is not selected is not a treatment**, so the
  description is a registered variable here and not a matter of taste.
- The same file's instrument constraint: **`skill.name` is redacted to `custom_skill`** for a
  project-scope skill, so this observatory **cannot tell two installed skills apart**. B6 installs
  one. That is not a stylistic choice; with two, the outcome is not measurable at all.
- [`evidence/p03/skill-flag-probe-20260904T102230Z.md`](../../evidence/p03/skill-flag-probe-20260904T102230Z.md)
  — `--disable-slash-commands` means *"disable all skills"*, and it was on every claude run this
  project made before stop 8. **6 of 6 activated without it, 0 of 6 with it**, `p = 0.0022`.
  **Check the flag before believing a null.**
- [`experiments/E-010-workflow-phases-BE003.md`](../../experiments/E-010-workflow-phases-BE003.md)
  and [`E-011`](../../experiments/E-011-workflow-phases-BE004.md) — this stop's baseline, and the
  source of the failure chosen below.

### External — the technique

- Anthropic, *Agent Skills* — the `SKILL.md` contract, progressive disclosure, and the claim that
  a skill's body loads only when selected. **The last of those is measurable here** and is not
  measured by this stop.

## Extract

**1. A skill is selected; an agent definition is present.** E-004 settled the mechanism: the
description decides whether the body ever enters the context. An agent definition is delivered as
the system prompt and is there every turn. **So a skill can fail in a way `phases-v1.0` cannot —
by not being chosen** — and B6's first job is to prove selection happened rather than to infer it
from the answer.

**2. The gate wants activation *recorded*.** `build/README.md#b6` says *"activation is recorded,
not inferred from the answer text"*. Stop 8 established that the observatory records it
(`skill.source = projectSettings`, an `invocation_trigger`), so this is an **L2** proof available
on day one — and it is the only part of this stop that is L2 for free.

**3. Prose alone does not improve test quality, and that is already measured twice.**
[E-009](../../experiments/E-009-fourth-cell-second-registration.md) delivered a procedure as prose
to a single agent and reached `test-quality` anchor 2 on **0 of 10** against its control's 1 of 10,
`p = 1.0`. B5 then delivered a *declared, marker-checked* procedure and reached **1 of 10**
(BE-003) and **3 of 10** (BE-004). **Two different deliveries of "write good tests" as words have
now moved that dimension very little.** A skill is a third delivery of words. **The honest prior
for this stop is that it will not work**, and that prior is registered rather than discovered.

## §4 step 2 — the choice of failure, and the two it rules out

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-09. The spine requires the failure be
measured in B2–B5 and explicitly permits recording "no measured specialist failure, B6 not built"
as the result. It is not being recorded, because two failures are measured — and the reasoning for
picking between them is written here before any prediction.*

**Ruled out first, on the instrument.** `architecture-consistency` scored **2 on 40 of 40** runs
across both tasks at stop 12, and `maintainability` was identical in both arms on BE-003 and
**floored at 0 on 20 of 20** on BE-004. A skill aimed at either would be measured by a dimension
that has not moved in forty runs. **Not a candidate, and the reason is the instrument rather than
the skill.**

**Ruled out second, and this is the one that looks right until you check the baseline.**
Stop 12's most consistent finding was that the treated arm wrote scorable test code on **20 of 20**
runs while the plain control skipped it **7 times in 20**. It is tempting to build
`testing-and-verification` against *that*. **It has no headroom here.** B6 measures against **B5**,
and `phases-v1.0` already writes a test on 20 of 20. **A skill cannot improve a ceiling.** The
comparison that would show this effect is against a plain baseline, and that is not the comparison
this stop registers.

**Chosen: `test-quality` anchor 2, and specifically the one clause both hand re-reads found
missing.** Against `phases-v1.0` the headroom is real and large — anchor 2 is reached in **1 of 10**
runs on BE-003 and **3 of 10** on BE-004. And the failure is not diffuse: **two independent hand
re-reads, on two different tasks, found the same clause absent** —

> the persisted state is re-read through a **separate `get(...)` request** rather than trusted from
> the mutating call's own body.

On BE-003 (`5395964c`) that was the single missing clause of three; on BE-004 (`fdb51fbd`) it was
two of four, both of them the same idea — the agent verified through the repository it had just
written to, at `OrderControllerTest.kt:168,172`, instead of through a second request. The codex
sheets say the same thing in their own words: *"persisted state is not re-read"*.

**That is what a specialist skill is for**: one named, recurring, mechanically-checkable habit, not
a disposition. It maps onto the scaffold's `testing-and-verification` candidate, and it is the
narrowest target this stop can state.

**The runner-up is kept on record rather than discarded.** The `DONE` completion contract leaks in
**4 of 20** treated runs and is measured by an *executing* checker, which would make its outcome
**L2** on day one — a rare thing here. It was not chosen because its headroom is 20 % against
`test-quality`'s 70–90 %, and because a completion contract is a **guardrail**, which is B7's
subject and not B6's. If this stop's skill fails, the completion contract is the obvious second
attempt, and it needs no new measurement to justify it.

## §4 step 2 — layers, and the trap this step converts

**The layer rule, applied in order, stopping at the first yes** (workspace `CLAUDE.md`): can the
bad value still be written down after the fix? → L1. Does something *execute* and reject it? → L2.
Otherwise → L3.

| Artifact | Layer | Why, applied in order |
|---|---|---|
| `skills/testing-and-verification/SKILL.md` — the skill body | **L3** | Nothing stops the model writing a test that trusts the mutating call's own body. The skill is words the model may read. **This is the version being measured and it is L3, exactly as the spine says** |
| The skill's **`description`** | **L3 for behaviour, and a registered variable** | It decides *selection*, not conduct. E-004 measured that at `p = 0.0079`. It is registered because changing it changes whether the treatment is delivered at all — not because it enforces anything |
| **Activation recording** — `skill.source`, `invocation_trigger` in the run record | **L2** | The observatory writes it per run and a run without it is visibly untreated. **This is the delivery proof, and it is the one thing at this stop that executes** |
| `check-phase-contract.py` (carried from B5, unchanged) | **L2** | Still executes on every treated run; the phases overlay is present in both arms here, so it measures a controlled variable rather than the treatment |
| The **`test-quality` anchor 2 clause** the skill targets | **L3 as a control, L2 as a measurement** | Nothing rejects a test that omits the separate `get(...)`. But the rubric at sha `396e1799eb2b` / `6252778b8472` **is** applied by a scorer, so whether the clause was met is decided by an instrument rather than by opinion |

**The trap, named from the step and from what this project has already paid for.**
`build/README.md#b6`'s gate says *"activation is **recorded**, not inferred from the answer text"*.
The trap is that **a skill that is never selected produces exactly the same numbers as a skill that
is selected and useless** — and both look like "the skill did not work". Stop 8 paid for this
lesson twice: once when `--disable-slash-commands` silenced every skill in the project's history
(6 of 6 vs 0 of 6, `p = 0.0022`), and once when the runner's own contamination guard marked the
first *matched* run `EXCLUDE` for loading the skill it had been given — a guard that would have
ended the batch with the treatment arm at `n = 0` and a report saying the treatment produced no
usable runs.

**Which layer converts it:** the **L2** activation record. A run whose record carries no activation
is not a treated run, and this stop's decision rule voids on it rather than reading it as a null.
**That conversion is the reason this stop is worth running at all** — without it, B6's honest prior
(that a third delivery of words will not move `test-quality`) is unfalsifiable, because every
failure mode looks identical.

**What stays L3 and is not dressed up.** The skill body is words. If the skill activates and the
number does not move, the finding is *"a specialist skill, selected and read, did not move this
failure"* — which is a real result and is what §4 step 10's **remove** clause exists for.

## Build

**Build:** exactly one. Chosen from a **measured** failure in B2–B5, not from a wish list.

Candidates: `database-change` · `testing-and-verification` · `spring-backend-feature`.

A skill answers eight questions: when it activates · when it must not · required inputs ·
workflow · which references may load · which scripts run · required output · how success is
verified.

### What was built — `testing-and-verification`

One skill, 675 words, `.claude/skills/testing-and-verification/SKILL.md`. The eight questions are
its eight top-level headings, in the order the gate lists them: *When this applies · When this
does NOT apply · Required inputs · The workflow · Which references may load · Which scripts run ·
Required output · How success is verified.* Layer: **L3** — a skill is prose a model reads and
may choose to follow. The only thing about it that executes is whether it was *selected*, and
that is the activation record, not the skill.

**The failure it is for was measured, and §4 step 2 records why the other candidate was not
chosen.** Both of stop 12's hand re-reads found the same clause missing on both tasks: after a
mutating call, the agent asserts on the mutating call's own response body rather than re-reading
persisted state through a separate `get`. BE-004 run `fdb51fbd` does it at
`OrderControllerTest.kt:168,172`, using `repository.findById()` where an HTTP `get` was the
thing under test.

### The description is a registered variable, and it moved once, before any batch

| | v1.0 | v1.1 (registered) |
|---|---|---|
| `SKILL.md` sha256 | `0876025fa451af5f1f2970da67a02f0d` | **`7bea904863fb79a544ee2068cb2f0f43`** |
| Line 3 names | a **cross-cutting technique** | **the task's domain**, in `skill-v0.2`'s shape |
| Body | 675 words | **byte-identical** |
| Recorded activations, `Skill` in pool | **0** (`2e972b72`) | **1** (`ba8b4b98`) |

E-004 measured the description as the selector at `p = 0.0079`. The revision is disclosed in
[E-012](../../experiments/E-012-specialist-skill-BE003.md) and
[E-013](../../experiments/E-013-specialist-skill-BE004.md), carries a new hash, and happened
**before any registered run**.

### The carrier, and the fact that forced it — L2, and it is the stop's first real result

`phases-v1.0` declares `tools: Read, Edit, Write, Bash`. Its `init` read-back **executes** and
returns `delivered n=4` with **no `Skill`** (`evidence/b06/preflight/init-schema/`,
`evidence/b06/probe-v1.1/init-schema/`). **A skill cannot be selected by an agent that has no
`Skill` tool**, so on the v1.0 product the treatment is *undeliverable* — and no description
fixes that, which the 2×2 in E-012 shows directly.

§6 forbids editing a measured version, so `phases-v1.0` **is not edited**. The batch runs on a
**carrier**: a new overlay whose agent differs from it by one line and which is installed on
**both arms**, so the skill directory stays the only variable.

| | Treated | Control |
|---|---|---|
| Overlay | `build/customizations/phases-v1.0-skillcarrier/` | `build/customizations/phases-v1.0-skillcarrier-control/` |
| Agent sha256 (first 32) | `51ffaedf9a3edbfe5fd85009f70f84c5` | **the same** — `diff -q` clean |
| Skill | `7bea904863fb79a544ee2068cb2f0f43` | **absent** |
| Read back per run | `skillsHash` **non-null** | `skillsHash` **`null`** |

The carrier is an **experiment fixture, not a version** — the same standing
`agent-v0.1-toollist-bash` had at stop 9. The `v1.0 → v1.1` boundary stays at B8 where the spine
puts it.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*

### The driver and the fixture set that proves it refuses

`evidence/b06/run-b6-batch.sh`, ShellCheck clean, guards driven by
`evidence/b06/verify-b6-batch-guards.sh` — **13 cases, 13 pass**
(`evidence/b06/verify-b6-batch-guards-*.txt`). Its first run failed **7 of 13**, and every failure
was a real defect rather than a fixture bug: a registered hash invented from a 16-character
prefix; the *control carries a skill* guard shadowed by a file-count guard that named only the
symptom; and case D's fixture tripping an earlier guard before reaching the one it targets. Case
D — the guard that stops a batch whose carrier cannot select a skill, which is exactly the
failure the hand preflight caught — was re-verified by hand outside the harness.

## Predict before you run

Registered, per author decision 9, as **two experiments that share an artifact and share no
verdict**:

| Task | Experiment | Prediction commit | Registered before |
|---|---|---|---|
| BE-003 | [`E-012`](../../experiments/E-012-specialist-skill-BE003.md) | `133de65` | the skill existed |
| BE-004 | [`E-013`](../../experiments/E-013-specialist-skill-BE004.md) | `133de65` | the skill existed |

Both were committed **before `b0ca034` built the artifact they predict about**, which is the
order a validator should check and the reason no prediction here can have been shaped by reading
it.

## Lab B6.1 — measure against B5, with and without

<!-- TODO: the gate demands activation be *recorded*, not inferred.
     Note the harness precedent: EXP-BE002-CLAUDEMD was voided because a
     skill activated in 5 of 23 runs and the field that should have caught
     it (skillsHash) was structurally incapable of reporting it. Decide
     how you will know this skill ran, before you run it. -->

## Deliberate failure

Registered in [E-012](../../experiments/E-012-specialist-skill-BE003.md) §4 step 9 **before the
run**: the same 675-word body under `skill-v0.2-misdescribed`'s CSS-animation description, one run
in the **skill-alone** configuration — the only one in which this skill has ever been recorded
activating (`ba8b4b98`, 1 of 1). Predicted: `status: measured`, **0 activations**. A deliberate
failure needs a control that has been shown to say *yes*; a 0 against a 0 proves nothing about the
skill.

## Exit gate

**From the build track:** activation is *recorded*, not inferred from the answer text · runs with
and without compared on quality, tokens, context and corrections · keep, modify, or **remove**.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
