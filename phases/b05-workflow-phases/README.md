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

Two tasks, two experiments, **no verdict computed across them** (author decision 9). This section
carries BE-003; BE-004's row is filled when its batch closes.

### BE-003 — [E-010](../../experiments/E-010-workflow-phases-BE003.md), key `EXP-B5-PHASES-BE003`

`n = 10` per arm, interleaved treated/control, `KEEP=1 ISOLATE_USER_SETTINGS=1
MODEL=claude-haiku-4-5-20251001`, benchmark tree `eeb15a75` at benchmarks `eea144ef`, evaluator
BE-003 `1.0.0` unchanged since B2. All 20 admitted by `check-run-gate.sh`.

| What the stop asked | Number | Where it came from |
|---|---|---|
| markers observable | **10 of 10** treated, **0 of 10** control | `check-phase-contract.py` check 1 |
| no code before DESIGN | **10 of 10** treated | check 2; first mutation is the *next event* after `DESIGN` in every run |
| token overhead | **−20.4 %** on `estimatedCost` median ($0.1178 vs $0.1480) | run records, two re-derived from raw telemetry |
| turn overhead | **−6.8 %** on `modelCalls` median (20.5 vs 22), quartiles overlapping | same |
| quality | `test-quality` anchor 2 **1 of 10** treated, 1 of 10 control, `p = 1.0` | codex, rubric `396e1799eb2b`, 20 sheets |
| correctness | **10 of 10** both arms at 7/7 acceptance | `evaluation.json` per run |

**Against B4.** B4 ([E-006](../../experiments/E-006-agent-boundary.md)) closed `INCONCLUSIVE`; B5
closes `INCONCLUSIVE` on BE-003 too, and for a **different reason worth keeping separate**. B4
could not resolve an effect. B5 resolved one and it was **backwards**: the decision rule has no row
for a treatment that was predicted to cost 25 % more and cost 20 % less, so it lands on row 5 by
construction rather than by weakness of evidence.

**What B5 has that B4 did not** is an executable observation of the behaviour it claims. B4's
boundary was a `tools:` list whose delivery the runtime rewrote (E-005). B5's phases are checked
by a script over the transcript, on every run, with a fixture set that is shown to fail the
retroactive-narration shape. That is the difference between a claim and a measurement, and it is
the only part of this stop that improved on its predecessor.

**The one thing the workbook's own expectation got wrong.** It said, in one line, so that the exit
gate could not be written to fit the data: *"the markers appear, the code order follows them, the
price is real and the rubric sees nothing."* Three of the four are right. **The price is not
real.** It is negative, and it is the second time in this project (after E-007) that a
customization predicted to cost more has cost less.

## Deliberate failure

**Run 2026-09-09, `n = 3`, against a prediction committed at `5777b07` before any run of this stop.**
The scaffold's TODO asked whether *"prose alone holds the workflow"*. It does not.

The overlay `build/customizations/phases-v1.0-nomarkers-DELIBERATE-FAILURE` (sha256
`2e2f708cbc05b54d8f359e4de67fc644`) is v1.0 with **one variable removed** — the machine-readable
marker instruction, nine occurrences of `<<PHASE:X>>` reduced to zero — and the six phases left in
place as prose headings, every other word unchanged.

| | markers, real checker | markers, naive text checker | evaluator |
|---|---|---|---|
| v1.0, `n = 10` | **10 of 10** | — | 10 of 10 |
| no-markers, `n = 3` | **0 of 3** | **0 of 3** | 3 of 3 pass, 66–73 added lines |

**The answer to the scaffold's question is the second column.** Prose alone does not hold the
workflow, and it does not even hold the *narration*: the naive checker greps the assistant text for
the six phase words and found none. Removing the instruction to announce a phase removed the phases
from the transcript entirely, so what was measured at 10 of 10 in Lab B5.1 is **L3 compliance with
one specific instruction**, not with the six-phase prose that surrounds it.

**And the prediction was half wrong, which is recorded and not revised.** It expected the phase
words to survive as closing-summary narration, so that a text-only checker would still pass where
the real one failed. Both checkers failed. Detail in
[E-010](../../experiments/E-010-workflow-phases-BE003.md) §4 step 9.

## Learning block — BE-003

*The six questions from `build/README.md#after-every-step`, answered from this stop's evidence.
BE-004's block is added when its batch closes; nothing below is computed across the two tasks.*

```yaml
learning:
  what_was_added: >
    build/customizations/phases-v1.0 — one agent overlay file,
    .claude/agents/backend-feature-phases.md, sha256:b3450564b6f32d6193e8580db766210e,
    declaring six phases with a machine-readable marker per phase and an output contract per
    phase. Plus tools/check-phase-contract.py, the instrument that reads a run's transcript and
    decides whether the phases were followed or narrated, with a 15-of-15 fixture set.
  why_it_exists: >
    The build track's stated purpose is to prevent premature coding and false completion. Both
    halves needed a measurement that a text search cannot fake, because the failure mode the
    trap names is a model that writes first and announces the phases afterwards in its summary.
  observed_effect: >
    Premature coding: prevented, 10 of 10, and tightly — the first mutating tool call is the very
    next event after the DESIGN marker in every treated run. Markers: 10 of 10 treated, 0 of 10
    control. False completion: leaked, 2 of 10 emit DONE without its four contract fields.
    Quality: nothing. test-quality anchor 2 is 1 of 10 in both arms, p = 1.0, and every other
    category is p = 1.0 as well.
  unexpected_effect: >
    THE COST WENT DOWN. estimatedCost median $0.1178 treated against $0.1480 control, -20.4%,
    against a registered +25%; modelCalls 20.5 against 22. The mechanism registered for P6 —
    one agent carrying one growing context through six phases, compounding input cost — is
    refuted, and refuted in the same direction E-007 was. What the treatment actually did to
    cost is narrow the spread: control modelCalls range 14-31, treated 16-24. THAT LAST SENTENCE IS A
    POST-HOC READING OF AN UNREGISTERED QUANTITY and is hedged here to match E-010's own hedge on it
    (§4a review finding 8, which caught this block stating as established what the experiment file
    two sections away calls a hypothesis for the next stop to register). A structure that
    stops the model wandering is cheaper than one that lets it, and the cheapest single run in
    the batch is still a control.
    Second unexpected effect, unregistered: addedLines median 79 treated against 41.5 control,
    with the control visibly bimodal (19,20,24,24 against 59,62,63,65). Twice the lines, fewer
    turns, less money.
  keep_or_remove: >
    KEEP phases-v1.0, unpromoted, on the gate and not on the decision rule. Removed instead is a
    belief: the compounding-context mechanism, now refuted twice. REMOVE nothing from the
    overlay — the DONE contract leak at 2 of 10 is a v1.1 item, and a version that has been
    measured is never edited.
  next_question: >
    Is the cost reduction the phases, or is it any structure that stops the model wandering?
    This stop cannot tell them apart: it has one treated arm and no arm with a different
    structure at the same price point. The registered comparison that would separate them is a
    prose-only arm with the six phases and no markers — which is exactly the deliberate-failure
    overlay this stop builds for a different purpose, and reading it that way would be reusing a
    control for a question it was not registered against. That is the next stop's prediction,
    not this one's finding.
```

## §5 validation table — BE-003

Every row is filled from a path, a sha or a run id. **The layer column is about the proof, not the
artifact**: it asks what would have to run for the row to be false. BE-004's table is added when
its batch closes; no row below is computed across the two tasks.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| *"phase markers observable in the transcript"* | `tools/check-phase-contract.py` check 1 over the 10 treated stream-json transcripts `$TMPDIR/observatory-agent-<id>.log`; run ids in `evidence/b05/batch-BE-003-20260909T075939Z/manifest.tsv` (pairs 01–08) and `…-20260909T093440Z/manifest.tsv` (pairs 09–10). 10 of 10 `markers_found: 6`; 0 of 10 controls | **L2** — a script executes and reports `FAIL` on a transcript without them; its fixture set `tools/verify-phase-contract-checker.sh` is 15 of 15 and includes fixture C, the retroactive-narration shape that a text-level checker passes | `python3 tools/check-phase-contract.py --json $TMPDIR/observatory-agent-<run-id>.log` for each treated id and read `facts.markers_found` |
| *"no code written before DESIGN"* | same tool, check 2, same 10 transcripts. `design_marker_position` < `first_mutating_position` in 10 of 10: 16/17, 18/19, 16/17, 12/13, 12/13, 18/19, 14/15, 20/21, 15/16, 16/17 | **L2** — same executing checker; `MUTATING` is defined at `tools/check-phase-contract.py:63-68` and deliberately excludes `Bash`, so the blind spot is counted separately and printed as a NOTE rather than hidden | same command; compare the two positions. The pre-`DESIGN` `Bash` write-shape count is `facts.bash_write_shape_before_design` — 0 in 9 of 10 |
| *"overhead measured, not assumed"* | `estimatedCost` and `modelCalls` per run from the observatory API `http://127.0.0.1:18081/api/runs/<id>`; medians treated $0.1178 / 20.5 against control $0.1480 / 22. Two runs re-derived from raw telemetry: `agent-observatory/infra/telemetry-out/events.jsonl`, counting `claude_code.api_request` records keyed on `observatory.run.id` — `5395964c` 20 calls / $0.0996592, `42f3f80b` 24 calls / $0.172395 | **L2 for the number, L3 for its interpretation** — the telemetry and the API are two independent sources that agree exactly, so the *value* does not rest on anyone's word; what it *means* is prose in E-010 and executes nowhere | `curl -s http://127.0.0.1:18081/api/runs/<id>` per id, or `grep` the run id in `events.jsonl` and sum `cost_usd` over `claude_code.api_request` records |
| **Void condition** — the treatment reached the model and not the control (E-010 P1) | `customization.agentHash = sha256:b3450564b6f32d6193e8580db766210e` on 10 of 10 treated, `null` on 10 of 10 control; `instructionsHash` `null` on all 20; column 6 of both manifests | **L2** — the batch driver `evidence/b05/run-b5-batch.sh` asserts it per run and exits 8 (row 0a) if it fails, and `evidence/b05/verify-b5-batch-guards.sh` drives that refusal on fixtures | read column 6 of the two manifests, or `curl` each run record and read `customization.agentHash` |
| **Admission** — only gate-admitted runs enter any comparison | `./tools/check-run-gate.sh $TMPDIR/observatory-run-<id>/evaluation.json` — 20 admitted, 0 refused; the same checker returns `rc = 2` on all four aborted runs (`81b1d617`, `79b9b300`, `f34a2eb4`, `fe6c2d96`) | **L2** — it executes, and it was **shown to refuse** in the same session rather than only shown to accept | run the same command over both sets and compare exit codes |
| **Registered scorer** — one rubric, unmoved | 20 sheets under `findings/codex/score-observatory-run-<id>-*.yaml`, every one carrying `rubric_sha: 396e1799eb2b`; `shasum -a 256 benchmark/rubrics/backend-quality.yaml \| cut -c1-12` = `396e1799eb2b` | **L1 for the identity** — the sha is the file; a changed rubric cannot present the same one. **L3 for "the right rubric was chosen"** | `grep rubric_sha findings/codex/score-observatory-run-*<id>*.yaml` for each of the 20 ids |
| **Hand re-read** (§5 requires at least one) | run `5395964c`, `test-quality`: hand value **1**, sheet value **1**, both citing that persisted state is not re-read through a separate `get(...)`; hand reading recorded in E-010 §5 at commit `618a969`, **before** the sheets were opened | **L3** — a human-equivalent reading of source; nothing executes. It is recorded as L3 precisely because it is the row a reader is most tempted to call proof | open the worktree's `ShipmentControllerTest.kt`, apply the `test-quality` anchors at rubric sha `396e1799eb2b`, and check the three clauses of anchor 2 at lines 100, 105-107, 123 and the absence of `get(...)` in `:85-131` |

**Independence check, as §5 requires it — what else changed between the arms.** `runtime.model` is
`claude-haiku-4-5-20251001` on all 20 run records; `instructionsHash` is `null` on all 20; the
benchmark tree and evaluator are one commit for both arms. **One difference is not the treatment
and is recorded rather than discovered:** pair 04's *control* made one delegating call, which the
batch driver writes to the manifest on every run including when it is zero, and which is threat 7
registered before the batch. A *treated* delegation would have been decision-rule row 0a and would
have stopped the run.

**What is not proved here.** Nothing in this table shows the phases produced better code — the
rubric found no difference the anchors can see (`p = 1.0` on every category), and 50 of its 100
points had zero variance across both arms. The table proves the procedure was followed and priced,
and that is all it proves.

## Exit gate

**From the build track:** phase markers observable in the transcript · no code written before
DESIGN · overhead measured, not assumed.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
