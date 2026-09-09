# B5 — Workflow phases

**Track A first:** [Phase 4B](../04b-orchestration/) · **Layer 3, unless you split structurally**
**Version:** **v1.0**
**Spine position:** 12 of 28 · after [Phase 4B](../04b-orchestration/) · before [B6](../b06-specialist-skill/)
**Status:** 🟡 OPEN — opened at spine stop 12, branch `stop12/b5-workflow-phases`, 2026-09-09

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b5).
> Everything else is yours to fill.

---

## Goal

Measure what a **declared six-phase procedure inside one agent** does to a backend feature run,
and separate the two things the build track conflates: whether the phases are *observable*, and
whether they *change anything*.

Two tasks from here on, by **author decision 9**: `BE-003-confirm-shipment` and
`BE-004-cancel-order`. Each is its own experiment, its own prediction commit, its own concurrent
plain control, its own decision rule, its own §5 row. **No verdict is computed across tasks.**

The version is **v1.0 of the phase overlay**, and it is a different artifact from
`backend-feature-implementer` v1.0 (B4). Nothing is promoted at this stop.

## Required reading

### Internal — the requirement

Read from `~/Documents/workspace-1-ideas/ai-agents/be-agent-copilot/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md`,
opened at the lines cited, 2026-09-09.

| ✅ | Source | What it actually says, and its layer |
|---|---|---|
| ✅ | **§10.4 `.ai/core/workflow.md`** (`:373-401`) | Defines the phase list and the three future risk profiles. **Why:** *"It prevents premature coding and false completion."* **Measure:** *"Skipped phases, failed exits, time per phase, and additional token cost."* The document specifies a Markdown file. **L3** — it describes a procedure; nothing executes it. |
| ✅ | **§10.6 `.ai/core/completion-contract.md`** (`:424-440`) | Defines what `DONE` means — acceptance criteria mapped, build passed, tests passed, static analysis passed, no critical findings, no forbidden files changed, final summary generated. *"Code written is not the same as task completed."* **L3 as specified**; §10.11 `.ai/scripts/verify.sh` is where it would become L2, and that is **B7**, not this stop. |
| ✅ | **FR-011 Workflow observation** (`:688-690`) | *"Phase transitions should be recorded **when supported**."* The qualifier is the whole requirement — it makes recording conditional on the runtime, which is why this stop builds the recorder rather than assuming one. |
| ✅ | **Risk: Workflow costs more tokens than it saves** (`:1863`) | The registered risk this stop exists to measure. §10.4's own measure list names *"additional token cost"* first among costs. |
| ✅ | **`:1462`** *"Measure workflow token overhead."* | The checklist line the gate's third clause comes from. |

### External — the technique

| ✅ | Source | Extract |
|---|---|---|
| ✅ | [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) (SOURCES.md `:190`) | The distinction this stop turns on: a **workflow** is a system where LLM calls are orchestrated through *predefined code paths*; an **agent** directs its own process. A phase list the model is asked to follow is neither — it is an agent being told about a workflow. |
| ✅ | [Claude Code — Dynamic workflows](https://code.claude.com/docs/en/workflows) (SOURCES.md `:193`) | When orchestration should be deterministic code rather than a model decision. Read at Phase 4B; re-read here because B5 is the case where it is *not* code. |
| ✅ | [Anthropic — Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) (SOURCES.md `:191`) | Already extracted at 4B. Carried here for one line only: *"most coding tasks involve fewer truly parallelizable tasks than research."* B5 does not parallelize; it serializes. That is a different bet and it has not been measured here. |

No new SOURCES.md rows were added at this stop, so `./tools/check-links.sh` has nothing new to
check; it was run anyway and its result is recorded in the §5 table.

## Extract

**The scaffold's question — *a workflow written as prose is still Layer 3; what would make it
structural?* — has a sharper answer than it looks, and getting it right decides the design.**

1. **Nothing available at this stop makes the workflow itself structural.** A phase is
   structural when the agent *cannot* act outside it. The only two mechanisms this runtime
   offers are the `tools:` list and a hook. **Position 9 measured the first and it does not
   hold**: `tools:` filters names, not capabilities, and adding `Bash` to the allowlist made the
   boundary vanish, 10/10, `p = 1.0` against no list at all
   ([E-005](../../experiments/E-005-agent-tool-boundary.md)). A hook that refused `Edit` before a
   `DESIGN` marker *would* be L1 — and it is **B7's** build, not this one. So B5's workflow is
   **L3 in the agent, by construction, and the honest thing is to label it that way and measure
   what L3 buys.**

2. **What can be made structural is the *observation*, and that is FR-011's *"when supported"*
   turned into something that runs.** `tools/check-phase-contract.py` reads a run's
   `stream-json` transcript and answers five questions by **position in the event stream**, not
   by what the closing message claims: six markers present once each in order; the first
   *mutating* tool call falls after the `DESIGN` marker; no template placeholders survive; the
   `DONE` block carries all four fields; zero delegating calls and zero delegated events. Exit
   `0` pass, `2` check failed, `3` unusable input. Its negative control,
   `tools/naive-phase-checker.py`, greps the transcript for the six marker strings and passes
   runs the real checker fails — that is the difference between reading a narration and reading a
   position. **`verify-phase-contract-checker.sh`: 15 cases, 15 passed, exit 0**, re-run by me at
   this stop. **That instrument is L2 and it is the only L2 thing at this stop.**

3. **Phase 4B's exit gate is the axis, in one line:** *"The agent chooses turn by turn; the
   workflow chose in advance."* B5 asks the agent to *pretend* the choice was made in advance.
   Whether that is worth anything is the measurement.

4. **The strongest prior against this stop's treatment is this project's own, on this exact
   task, and it is barely two days old.** [E-007](../../experiments/E-007-orchestration-overhead.md)
   split BE-003 into orchestrator + implementer and `test-quality` anchor 2 came out **5 of 10
   against a concurrent control's 0 of 10**. [E-009](../../experiments/E-009-fourth-cell-second-registration.md)
   then delivered *the implementer's prose alone*, no split, and got **0 of 10 against its own
   control's 1 of 10, `p = 1.0`** — and `p = 0.0325` against the split. **A procedure delivered
   as prose to a single agent has already been measured, on this task, to return nothing the
   rubric can see.** B5's phases are prose plus markers inside one agent. That is the same shape,
   and this stop should expect the same answer on quality — while the *compliance* question
   (do the markers appear at all, in order, before any write?) is genuinely unmeasured.

5. **So the two questions must be scored separately, and only one of them is about the agent.**
   Compliance is a property of the transcript and is measured L2. Quality and overhead are
   properties of the run and are measured against a concurrent control. Answering "was this the
   agent, or the harness?" at the exit gate requires both, and E-007's own failure mode — a
   split that cost `+4 modelCalls` and returned a quality effect its decision rule could not
   name — is the warning about scoring only what was registered.

6. **The trap `build/README.md` names for this step is the token overhead**, and the reference
   population for it already exists at `n = 30`: three independent plain-control batches on
   BE-003 (E-006 batch 2, E-007 arm C, E-009 control) agree at `modelCalls` median **21.5–22**
   and `estimatedCost` median **$0.146–0.156**. A control that stable is what makes a `+25%`
   claim falsifiable. **BE-004 has no such population and will not have one until this stop
   produces it**, which is why its continuous outcomes are registered report-only here — see
   E-011.

*Extract written by Opus 5 (claude-opus-5), autonomously, 2026-09-09.*

## §4 step 2 — design, layers, and the trap

*Designed by Opus 5 (claude-opus-5), autonomously, 2026-09-09.*

### The artifacts, each labelled by the workspace rule applied in order

| Artifact | Layer | The rule, applied in order |
|---|---|---|
| `build/customizations/phases-v1.0/.claude/agents/backend-feature-phases.md` — the six-phase procedure and its markers | **L3** | (1) *Can the bad value still be written down?* **Yes** — nothing stops a run emitting `IMPLEMENTATION` first, or writing a file before `DESIGN`. Not L1. (2) *Does something execute and reject it?* **No** — the runtime delivers this file as an agent definition and never reads its content again. Not L2. → **L3.** |
| The overlay's `tools: Read, Edit, Write, Bash` frontmatter | **L3** | (1) A write is still expressible. (2) **E-005 measured the executing part and it does not hold**: `tools:` filters names, not capabilities, and the arm that added `Bash` to the allowlist scored 10/10 write attempts, `p = 1.0` against no list at all. **`Bash` is in this list.** So this frontmatter is not even the weak L2 it looks like. → **L3.** |
| `tools/check-phase-contract.py` + `verify-phase-contract-checker.sh` | **L2** | (1) The bad transcript can still exist — the checker is post-hoc. Not L1. (2) *Does something execute and reject it?* **Yes, and it is named:** `check-phase-contract.py` exits `2` on a failed check, and **15 of 15 registered fixtures pass, re-run by me at this stop, exit 0**, including two negative-control cases where the text-only `naive-phase-checker.py` passes runs the real checker fails. → **L2.** |
| The `DONE` completion contract (four fields) | **L3 in the agent, L2 in the check** | The agent is asked to print four fields; nothing refuses a run that does not. The checker's check 4 executes and rejects. **Both facts are true of different things** and the §5 table records the layer of the *proof*, not of the artifact. |

**So this stop builds exactly one L2 thing, and it is an instrument, not a control.** The
workflow is L3 and stays L3 until B7 puts a hook in front of `Edit`. That is not a defect of
the design; it is the measurement.

### The trap, and what converts it

`build/README.md#b5` names the cost trap — *"Cost: tokens. Measure both"* — and the header
carries the sharper one: **"Layer 3, unless you split structurally."** The trap is **claiming
the workflow prevented premature coding when only its narration was read.** An agent that
prints `<<PHASE:ANALYSIS>>` … `<<PHASE:DONE>>` in its closing summary, having written the code
in turn two, passes every text-level check anyone would write by hand. That exact fixture is
case C of the verifier, and the text-only checker passes it.

**What converts it: reading position in the event stream rather than text in the output.**
`check-phase-contract.py` records the index of the `DESIGN` marker and the index of the first
mutating `tool_use` and compares them. That is the difference between L3 and L2 here, and it is
the whole reason the instrument exists.

### The blind spot I am registering rather than closing

`MUTATING` is `{Edit, Write, MultiEdit, NotebookEdit, str_replace_editor}` and **`Bash` is
deliberately excluded** (`tools/check-phase-contract.py:63-68`): `bash -c "grep …"` is a read,
and naming `Bash` mutating would fail every run that searched the repo before designing.
The consequence is real and it is in the treatment's own tool list: **a run that writes its
whole change through a `Bash` heredoc before `DESIGN` does not fail check 2.** The checker
mitigates rather than closes this — it counts `Bash` calls carrying a write shape before the
`DESIGN` marker and prints them as a NOTE beside the verdict
(`tools/check-phase-contract.py:155, :187-195, :267-269`), which is validator pass 18's
recommendation adopted rather than widening `MUTATING`.

**I am registering that NOTE count as an outcome**, not leaving it as commentary — see **P4** in
[E-010](../../experiments/E-010-workflow-phases-BE003.md) and **P4** in
[E-011](../../experiments/E-011-workflow-phases-BE004.md). *(This sentence read "P5" when it was
written at `1031a99`; P5 is the turn-count prediction. Corrected by Opus 5 (claude-opus-5),
autonomously, 2026-09-09, before any run of this stop — no prediction is altered, only a
cross-reference that pointed at the wrong one.)* A treated run with zero
`Edit`/`Write` before `DESIGN` and three pre-`DESIGN` `Bash` writes has complied with the
letter of the check and not with the clause the gate asks about, and the only way that fact
survives into the exit gate is if it was registered before the run.

### Treatment delivery, and one disclosure I am not tidying away

The treatment is delivered by the runner's `--customization build/customizations/phases-v1.0`
plus `--agent backend-feature-phases`, and proved per run by `customization.agentHash` in the
run record — **a field that was `null` on every run in this project until `obs#76` (`27b3a7d`)
landed on 2026-09-08**, which is why arm membership at this stop can rest on it and could not
have two days ago. The control carries no `--customization` and no `--agent`, and its
`agentHash` must read `null`.

**Disclosure: the treatment overlay was written before this stop opened, and that is a §6
violation.** `backend-feature-phases.md` (131 lines, sha256 `b3450564b6…`) was authored and
merged on 2026-09-08 in **lab#77**, an *instrument* PR, while stop 12 was unopened — §6 says
*"never create a future step's artifacts early."* It is not referenced by any tool, verifier or
fixture, so it is not an instrument; it is the treatment. **I am not deleting it** — §7 forbids
destroying evidence — and I am not pretending this stop authored it. Stop 12 **adopts it as a
pre-existing draft**, with its date, its PR and its sha on the record here and in E-010's
delivery section; any change to it from here is a new version directory, never an edit. The
prompt anticipated this precise shape: five validator passes landed on an unopened stop 12 and
produced three instrument PRs and no §4 step 1.

---

## Build

**Build:** `ANALYSIS → DESIGN → IMPLEMENTATION → VERIFICATION → REVIEW → DONE`, with an
output contract per phase.

| Phase | Must produce |
|---|---|
| ANALYSIS | restated goal · repository findings · risks · affected files · open questions |
| DESIGN | proposed change · alternatives · data and error flow · test strategy |
| IMPLEMENTATION | focused code matching the design |
| VERIFICATION | commands · results · failures · fixes |
| REVIEW | acceptance-criteria mapping · diff review · unresolved findings |
| DONE | completion contract passed |

**Purpose:** prevent premature coding and false completion. **Cost:** tokens. Measure both —
phases skipped, failed exits, time per phase, and the token overhead.

Risk profiles come later, and only if measured:

```
QUICK      ANALYSIS → IMPLEMENTATION → VERIFICATION → DONE
STANDARD   the six above
HIGH_RISK  + APPROVAL after DESIGN, + SECURITY_REVIEW and HUMAN_APPROVAL before DONE
```

## Predict before you run

*Registered by Opus 5 (claude-opus-5), autonomously, 2026-09-09, before any run of this stop.*

The build track's instruction is *"Cost: tokens. Measure both"*, and the scaffold's TODO asked for
the token overhead **as a percentage, before measuring it**. It is registered here and, in its full
form with mechanisms and decision rules, in the two experiment files this stop runs under author
decision 9 — **one per task, no verdict computed across them**:

| | `BE-003-confirm-shipment` | `BE-004-cancel-order` |
|---|---|---|
| Experiment | [E-010](../../experiments/E-010-workflow-phases-BE003.md), key `EXP-B5-PHASES-BE003` | [E-011](../../experiments/E-011-workflow-phases-BE004.md), key `EXP-B5-PHASES-BE004` |
| **Token overhead, the number the scaffold asked for** | **≥ +25 %** on `estimatedCost` median vs its concurrent control, quartiles non-overlapping (E-010 P6) | **≥ +25 %** (E-011 P6) — **the same threshold, transferred not calibrated**, and E-011 says so in its MDE table |
| Turns | **≥ +4** on `modelCalls` median (P5) | **≥ +4** (P5); +4 is 13 % of BE-004's observed 30 where it is 18 % of BE-003's 22 |
| Markers observable | ≥ 9 of 10 treated (P2) | ≥ 9 of 10 treated (P2) |
| No code before DESIGN | ≥ 9 of 10 treated (P3) | ≥ 9 of 10 treated (P3) |
| Quality | `test-quality` anchor 2 **≤ 3 of 10** treated (P7) | **≤ 3 of 10** (P7), with a registered chance the anchor floors at 0 in both arms |
| Correctness | ≥ 9 of 10, a floor (P8) | ≥ 8 of 10 both arms, differing by < 3 (P8) |

**The mechanism behind the cost prediction, stated because it contradicts the nearest measured
prior.** [E-007](../../experiments/E-007-orchestration-overhead.md)'s structural split came out
**13.4 % cheaper** than its control, against a registered +60 %. There is **no subagent** at this
stop: one agent carries one growing context through six phases, so every announced phase re-reads
everything before it and input cost compounds instead of resetting. **If the treated arm comes out
cheaper here too, the compounding mechanism is wrong**, and that is worth more than the prediction.

**What this stop expects to find, in one line, so the exit gate cannot be written to fit the data:**
the markers appear, the code order follows them, the price is real and the rubric sees nothing —
because [E-009](../../experiments/E-009-fourth-cell-second-registration.md) already measured the
same procedure as prose to one agent at **0 of 10** against its control's 1 of 10, `p = 1.0`.

## Lab B5.1 — measure against B4

<!-- TODO -->

## Deliberate failure

<!-- TODO: instruct it to skip DESIGN and see whether the phase markers
     still appear. If prose alone holds the workflow, you have measured
     Layer 3 compliance, not enforcement. -->

## Exit gate

**From the build track:** phase markers observable in the transcript · no code written before
DESIGN · overhead measured, not assumed.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
