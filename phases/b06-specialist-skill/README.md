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

**Two tasks, two experiments, no verdict computed across them** (author decision 9). `n = 10` per
arm per task, interleaved, `--keep`, `claude-haiku-4-5-20251001`, benchmarks `eea144ef`.

### How this lab knows the skill ran

The precedent named above is the reason this is checked rather than assumed: `EXP-BE002-CLAUDEMD`
was voided because a skill activated in 5 of 23 runs and `skillsHash` was structurally incapable of
reporting it. Here **delivery and selection are two different measurements**, and the difference is
the whole design:

| | Instrument | What it can and cannot say | Layer |
|---|---|---|---|
| **Delivery** | `customization.skillsHash` in the run record | the file arrived. Says nothing about whether it was chosen | **L2** — the runner computes it per run |
| **Selection** | `tools/skill-activation.sh` over `agent-observatory/infra/telemetry-out/events.jsonl` | the model chose it. **Exits 3 when a run is absent from telemetry**, so a `0` is a measurement and never missing data | **L2** — it executes and it refuses |
| Tool availability | the runner's `init` read-back, `INIT_SCHEMA_DIR` | whether `Skill` was even in the pool | **L2** — declared-vs-delivered compared per run |

### The result

| | BE-003 | BE-004 |
|---|---|---|
| Batch | `evidence/b06/batch-BE-003-20260909T173701Z/` | `evidence/b06/batch-BE-004-20260909T182606Z/` |
| Experiment | [`E-012`](../../experiments/E-012-specialist-skill-BE003.md) | [`E-013`](../../experiments/E-013-specialist-skill-BE004.md) |
| Rubric sha | `396e1799eb2b` | `6252778b8472` |
| **Recorded activations** | **10 of 10 treated, 0 of 10 control** | **10 of 10 treated, 0 of 10 control** |
| **`test-quality` anchor 2** | **10 of 10 vs 0 of 10**, `p = 1.08 × 10⁻⁵` | **10 of 10 vs 3 of 10**, `p = 0.0031` |
| Cost | **+8.0 %** | **−5.3 %** |
| `modelCalls` | **+2** (22.5 vs 20.5) | **0** (29.0 vs 29.0) |
| Corrections / evaluator | **10 of 10 pass, both arms** | **10 of 10 pass, both arms** |
| Second reader | `test-quality` **20 of 20 identical to codex** | see E-013 |

**The gate's four axes, answered:** quality **moved**, on both tasks, on the registered outcome and
on the behaviour underneath it; **tokens/cost** did not move beyond the registered ±15 %; **context
— turns** did not move beyond ±3; **corrections** did not move at all, the evaluator floor holding
at 10 of 10 in all four arms.

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

### §5 validation table

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| *"Build: exactly one."* | `build/customizations/phases-v1.0-skillcarrier/.claude/skills/testing-and-verification/SKILL.md`, sha `7bea904863fb79a544ee2068cb2f0f43`; the treated overlay holds exactly 2 files and the driver refuses otherwise | **L2** — `run-b6-batch.sh` guard, fixture E2 in `verify-b6-batch-guards.sh` | `find build/customizations/phases-v1.0-skillcarrier -type f` → 2; `./evidence/b06/verify-b6-batch-guards.sh` |
| *"Chosen from a measured failure in B2–B5"* | workbook §4 step 2; the clause is the one stop 12's hand re-reads found missing on both tasks — BE-004 run `fdb51fbd` at `OrderControllerTest.kt:168,172` | **L3** — a reading of stop 12's evidence, written down | open `phases/b05-workflow-phases/README.md` §5 and the two stop-12 hand re-reads |
| *"A skill answers eight questions"* | the eight top-level headings of `SKILL.md`, in the gate's order | **L3** — headings, nothing executes | `grep '^## ' …/SKILL.md` → 8 lines |
| **"activation is *recorded*, not inferred from the answer text"** | `tools/skill-activation.sh` over `events.jsonl`: **40 of 40 runs `status: measured`**; treated `projectSettings=1` on 10 of 10 per task, control 0 of 10 per task | **L2** — the tool executes and **exits 3** rather than reporting 0 for a run it cannot see | `./tools/skill-activation.sh ../agent-observatory/infra/telemetry-out/events.jsonl <run id>` for any id in either manifest |
| *"…not inferred from the answer text"* — negative control | deliberate failure `81899960`: same 675-word body, E-004's CSS description, **0 activations** against 4 of 5 for the domain description in the identical configuration | **L2** — same instrument, same `status: measured` | `evidence/b06/deliberate-failure/manifest.txt`, then the tool on that id |
| **"runs with and without compared on quality"** | codex sheets, `396e1799eb2b` / `6252778b8472`: `test-quality` anchor 2 **10/10 vs 0/10** (`p = 1.08e-5`) and **10/10 vs 3/10** (`p = 0.0031`) | **L2** for the sheets and the gate that admitted the runs; **L3** for reading them as "quality" | `./tools/check-run-gate.sh` then `./tools/codex-score.sh <rubric> --run-id <id>`; sheet paths are in E-012/E-013 |
| — the same, hand-checked | pair 01 of each task hand-read **before any sheet existed**: BE-003 treated `3070d353` = 2 / control `3f30195f` = 1; BE-004 treated `6d7a004d` = 2 / control `b5dab364` = 1 — all four agree with the sheets | **L3** — a human reading, and that is exactly why it is written beside the sheet | the `path:line` citations in E-012 and E-013 against the kept worktrees |
| **"…on tokens, context and corrections"** | cost **+8.0 %** / **−5.3 %**; `modelCalls` **+2** / **0**; evaluator **10 of 10 in all four arms** | **L2** — read from the run records, not from a flag | `curl 127.0.0.1:18081/api/runs/<id>` → `efficiency.estimatedCost`, `behavior.modelCalls`, `evaluation` |
| **"keep, modify, or remove"** | **KEEP**, decided below from the measured effect | **L3** — a decision | the Decision section below |
| Independence — one variable | `agentHash sha256:51ffaedf9a3edbfe…` **identical on all 40 runs**; `skillsHash` non-null on 20 treated and `null` on 20 control; `instructionsHash` `null` on all 40; 0 delegations on all 40; `claude 2.1.266` asserted constant per run | **L2** — read back per run and the batch aborts on a mismatch; proved to abort by fixtures C, C2, E | the manifests' `agent_hash` / `skill_hash` / `instr_hash` columns |
| Prediction before run | prediction commit `133de65` (2026-09-09T17:00:47+02:00); first run of the BE-003 batch is in `batch-BE-003-20260909T173701Z` (17:37Z) | **L2** — the driver refuses if the clock says otherwise | `git log --format=%cI -1 133de65` against the batch directory's stamp |

### Plus, for this to count as a learned phase

**What changed in the agent, and it is not "it read more words".** A skill is **selected at the
moment it is needed and named in the transcript when it is**. That is the difference from
[E-003](../../experiments/E-003-instructions-v0.1.md), where a 57-word instruction file proved
delivered by hash on 10 of 10 runs moved nothing measurable, and from
[E-007](../../experiments/E-007-orchestration.md), where a split returned nothing the gate could
see. **This is the first treatment in Track B that moved its registered outcome on both tasks.**

**What it cost to find out, and this is the part worth carrying.** The stop spent **three
instrument defects and four excluded runs** before a single valid batch row existed, and all three
defects have the same shape — *a check that believed more than it measured*:

1. a guard registered against `SKILL.md`'s sha when the runner reads the **skills subtree** hash;
2. `read -r a s i` not declared `local`, so every control log **overwrote the last one**;
3. `tools/count-state-reread.py` missing extracted `confirmShipment()` helpers, disagreeing with a
   sheet that was right.

**None of the three could have been caught by the fixture set**, because `B6_GUARDS_ONLY=1` can
only exercise guards that fire **before the first run**. That is a real limit of this project's
favourite control and it is the thing this stop learned about its own instruments.

**Was this the agent, or the harness?** The **agent**, and the separation is measured rather than
argued. Three configurations, each isolating the others:

| Configuration | `Skill` in the pool | Description | Activations |
|---|---|---|---|
| skill alone | yes | technique | **0** (`2e972b72`) |
| skill alone | yes | **domain** | **4 of 5** (`ba8b4b98` + selection-rate probe) |
| agent, no `Skill` in `tools:` | **no** | domain | **0** (`e711fd4a`) |
| **carrier** — agent **with** `Skill` | yes | domain | **4 of 5** probe, **20 of 20** in the batches |

The harness can silence a skill two independent ways — an absent `Skill` tool, and a description
that names a technique rather than the task — and **both were ruled out before the effect was
claimed**. What is left is the model reading the skill and writing a different test.

## Learning block

```yaml
learning:
  what_was_added: >
    One skill, `testing-and-verification`, 675 words, sha 7bea904863fb79a544ee2068cb2f0f43,
    answering the gate's eight questions as its eight headings. Plus a carrier overlay --
    phases-v1.0's agent with `Skill` added to `tools:`, one line, installed on BOTH arms --
    because phases-v1.0 as it stands is delivered n=4 tools and cannot invoke a skill at all.
    The carrier is an experiment fixture; it is not a version and nothing is promoted.
  why_it_exists: >
    Both of stop 12's hand re-reads, on both tasks, found the same clause missing: after a
    mutating call the agent asserted on that call's own response body instead of re-reading
    persisted state through a separate get(...). BE-004 run fdb51fbd does it at
    OrderControllerTest.kt:168,172 with repository.findById() where an HTTP get was the thing
    under test. The skill names that one habit and nothing else.
  observed_effect: >
    test-quality anchor 2, codex, registered rubric shas: BE-003 treated 10 of 10 against
    control 0 of 10, two-sided Fisher p = 1.08e-5; BE-004 treated 10 of 10 against control
    3 of 10, p = 0.0031. Two tasks, registered separately, no verdict computed across them.
    The behaviour underneath the verdict moves with it (a separate get(...) after the
    mutation: BE-003 10 of 10 vs 0 of 10). Selection was RECORDED on 20 of 20 treated runs
    and absent on 20 of 20 controls, status `measured` on all 40. The second reader agrees
    with codex on test-quality 40 of 40 cells. Cost +8.0% / -5.3%, modelCalls +2 / 0,
    evaluator 10 of 10 in all four arms -- every one inside its registered bound.
    THIS IS THE FIRST TREATMENT IN TRACK B THAT MOVED ITS REGISTERED OUTCOME.
  unexpected_effect: >
    Three, and the first is the one to carry. (1) BE-003 maintainability went the OTHER way,
    treated 2 of 10 against control 5 of 10, p = 0.35 -- not separated at this n, recorded
    rather than left out, and named as the follow-up most likely to matter. (2) The
    description is a harder selector than E-004 showed: a description naming a TECHNIQUE the
    task needs is not selected (0), while the same 675-word body under a description naming
    the task's DOMAIN is (4 of 5, then 20 of 20). E-004 separated right domain from wrong
    domain; this separates the task's domain from a technique it needs, which is a much
    tighter constraint on what a specialist skill can be. (3) P1's void condition conflates
    DELIVERY with SELECTION -- it counts activations and calls a shortfall "the skill was not
    delivered". It did not bite here (10 of 10) but the defect is real and is recorded.
  keep_or_remove: >
    KEEP the skill, on the measured effect on both tasks. Nothing is removed: nothing built
    here failed to move a measured outcome. What is NOT kept is the carrier -- promoting the
    skill into the product needs phases-v1.0's `tools:` line to change, and that is a B8
    decision at the v1.1 boundary, not a B6 one.
  next_question: >
    Does a skill cost production-code structure to buy test structure? BE-003's
    maintainability cell is the only signal and p = 0.35 cannot answer it. It needs its own
    registered outcome and a larger n, not a re-read of these forty runs.
```

### What this stop learned about its own instruments

Three defects, one shape -- *a check that believed more than it measured* -- and **the fixture set
could not have caught any of them**, because `B6_GUARDS_ONLY=1` only exercises guards that fire
**before the first run**:

1. a guard registered against `SKILL.md`'s sha where the runner reads the **skills subtree** hash;
2. `read -r a s i` not declared `local`, so every control log **overwrote the last one** — evidence
   being destroyed while the batch ran, which is why it was stopped by hand rather than finished;
3. `count-state-reread.py` missing extracted `confirmShipment()` helpers and disagreeing with a
   sheet that was right.

Four runs were excluded by name for it, all folders kept, all reasons independent of their
outcomes. **And one hard rule was broken:** `run-b6-batch.sh` was patched while an instance was
still executing it, which §6 forbids outright. Recorded rather than tidied away, because a process
violation only the violator can see is not a control.

## Commit

- **`b0ca034`** — the skill, 675 words, built after both prediction commits
- **`133de65`** — E-012 and E-013 registered **before** the artifact existed
- **`4d3d166`** — the deliberate failure registered **before** it was run
- **`c3b3621`, `d85cb6e`** — the v1.1 description, the 2×2 that separates the two blockers
- **`0a01fbf`, `420ce1f`, `ebbd5c7`** — the selection rate, and the three instrument defects
  recorded rather than tidied away
- **`61d8738`, `bd51255`, `abf7366`, `c928f62`** — the two batches, both harnesses, the hand
  re-reads

