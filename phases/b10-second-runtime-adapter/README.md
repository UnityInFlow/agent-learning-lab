# B10 — Port the adapter to a second runtime

**Track A first:** [Phase 4A](../04a-agents-permissions/)
**Version:** **v1.2**
**Spine position:** 21 of 28 · after [B9](../b09-knowledge-router/) · before [Phase 7](../07-plugins/)
**Status:** ✅ **CLOSED at spine stop 21, 2026-09-27 — `NOT DETECTABLE AT THIS n` on both tasks,
row 4 of each decision rule.** v1.2's codex port is **kept and not promoted**. The verdict is not the
finding: the registered outcome was at its ceiling in the control on 5 of 5 on both tasks. Branch
`stop21/b10-second-runtime-adapter`.

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b10).
> Everything else is yours to fill.
>
> ⚠️ **Placement is provisional.** B10's prerequisite (4A) clears at spine position 9, but its
> version tag (v1.2) holds it to position 21 — twelve stops of cleared prerequisite. See the
> open decision in [`build/README.md`](../../build/README.md) about whether prerequisite order
> or version order is authoritative.

---

## Goal

Test **P5 — "portable core and thin adapters"** by moving the one overlay this track has
actually measured, `build/customizations/agent-v1.2-knowledge/`, from the `claude` runtime to
the `codex` runtime, and answer gate `#b10` from what that move costs and from what the
instrument can still see once it is done.

**The second runtime is `codex`.** Copilot is removed by Decision G and §6 of the run prompt
forbids any claim about a Copilot-run agent, so the `adapters/copilot/` row in the Build block
below is dead text kept for the record. `LEARNING-PATH.md:73` still calls this step *"Port the
Copilot adapter to Claude"*; that title predates Decision G and the direction is the reverse of
what happens here — claude is the measured runtime and codex is the port target.

**Placement decision, taken here because `LEARNING-PATH.md:127` asks for it before B10 is
written.** B10 and B12 stay where the spine puts them, in **version order**: B10 at stop 21,
not at stop 10 where its 4A prerequisite would allow it. Reason: the v1.x blocks stay
contiguous, and a version boundary that moves because a prerequisite cleared early is a version
boundary that means nothing. This is the pre-made decision in §3 of the run prompt and it is
recorded here as `LEARNING-PATH.md` asks.
*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-27.*

**What this stop cannot do, stated before it starts.** The gate asks to *"compare quality"*
across runtimes. Three separate things block that claim and none of them is fixable here:

1. `agent-observatory#47` — *permission-mode block recorded as incorrect code* — is **still
   open** (checked by API, 2026-09-27: `state: open`, `closed_at: null`). The workbook's own
   scaffold said to check it before trusting cross-runtime numbers.
2. The model necessarily moves with the adapter. `claude-haiku-4-5-20251001` does not run on
   codex; the eight stored codex runs are all `gpt-5.6-sol`. The step's own Build block says
   *"change the adapter and the model"* — that is **two** variables, and §6's one-variable rule
   is not suspended because a step's own text asks for it.
3. HANDOFF, seventh session: cross-arm quality claims are blocked.

So no quality verdict is computed across runtimes at this stop. What is computed is stated in
`## Predict before you run`, and *"quality is not comparable here, and here is the evidence that
it is not"* is an answer to the gate clause, not a gap in it.

## Required reading

### Internal — the requirement

- `businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md` **P5** (line 191) *"Keep reusable
  concepts provider-neutral. Keep Codex-, Claude-, and Copilot-specific configuration in
  adapters."* — the claim under test.
- the same file, **G6** (line 140), **§10.15** `.ai/adapters/codex/` (line 608), **§10.16**
  `.ai/adapters/claude-code/` (line 616), **NFR-004** (line 719).
- [`build/README.md#b10`](../../build/README.md#b10) — the gate, verbatim in `## Exit gate`.
- [`SOURCES.md`](../../SOURCES.md) rows 82, 100, 108, 125 — the codex docs, already extracted at
  stops 9 and 18. Row 108 carries the sentence this stop is built on: *"A `tools:` boundary is
  therefore **unportable to codex**, which constrains B10 at stop 21."*
- `agent-observatory/runner/run-agent.sh` — the runtime dispatch, lines 278–330, 390–420,
  486–532, 599–610, 890–935, 1118–1145, 1223–1245. Seven separate places where the runtime is
  branched on; each one is a place the port can fail.
- `agent-observatory/runner/lib/telemetry-env.sh:65-70` — the codex telemetry block.
- `HANDOFF.md`, seventh session — cross-arm quality claims blocked.
- `agent-observatory#47`, `#10`, `#65` — read by API, not from memory.

### External — the technique

The codex docs are in `SOURCES.md` and were extracted at earlier stops; they are **not** re-read
here because they moved host once already (`SOURCES.md:42`) and a moved page is a page whose
version nobody can cite. The source used instead for every capability claim below is **the
installed binary's own `--help`, `codex-cli 0.154.0`**, which is the only statement of what this
machine will actually do. Where a doc row and the binary disagree, the binary is recorded.

## Extract

Eleven facts, each one measured or read off a file this session, each one a way the port can
fail. Nothing here is inferred from a flag.

**1 — The overlay is eleven files, and that number is the denominator.**
`build/customizations/agent-v1.2-knowledge/` holds `CLAUDE.md`; `.claude/settings.json`;
`.claude/agents/backend-feature-phases.md`; `.ai/hooks/{policy-gate,repair-limit,repair-record}.sh`;
`.ai/policies/protected-paths.yaml`; `.ai/knowledge/{index.yaml,router.sh}` and two documents
under `documents/` and `summaries/`.

**2 — `CLAUDE.md` is a rename, and the runner enforces it.** `run-agent.sh:399` sets
`INSTRUCTION_FILE=AGENTS.md` and `FOREIGN_INSTRUCTIONS=(CLAUDE.md)` for codex, and lines 401–411
`die` when the overlay carries only the foreign name. **L2** — it executes and it refuses.

**3 — `--agent` does not exist on codex, and this is now confirmed against the binary rather
than a doc.** `codex exec --help` on `codex-cli 0.154.0` lists no `--agent`. `run-agent.sh:320-327`
already refuses to forward it to any runtime but claude, with the reason written out: an arm that
accepts a boundary flag and drops it is *"a baseline wearing the treatment's label"*. **L2.**

**4 — the `.claude/agents/` directory is a foreign glob on codex and the runner dies on it.**
`run-agent.sh:492-527`: for every runtime but claude, `NATIVE_AGENT_GLOB` is empty and both
`.claude/agents/*.md` and `.github/agents/*.md` are foreign. The remedy it prints is explicit —
*"codex reads no agent directory at all … Run this overlay on claude, which does, or drop the
agent files from it."* **So `agent-v1.2-knowledge` cannot be handed to the codex arm as it
stands: the run would not start.** That refusal is the single most useful thing the instrument
does for this stop, and it was built for a different reason.

**5 — codex *does* have subagents, and they are a different shape.** `SOURCES.md:108`, extracted
2026-09-04: TOML under `.codex/agents/`, required `name` / `description` / `developer_instructions`,
and **no `tools` field at all** — capability is restricted by `sandbox_mode`. The claude overlay's
agent file restricts by a `tools:` list. There is no expression of that constraint on the codex
side, so the port of the *file* is possible and the port of the *boundary* is not.

**6 — the hook wiring is claude-only in this runner, and the files are not.** The three
`.ai/hooks/*.sh` are POSIX shell and are provider-neutral as text. What makes them the **L2**
control that B7 proved on 17 of 17 runs is `.claude/settings.json`, which only claude reads and
which the runner does nothing with on codex. Codex has hooks — `codex exec --help` lists
`--dangerously-bypass-hook-trust`, and `run-agent.sh:141` records that the cmux wrapper injects
`-c hooks.X=…` — but **this runner wires nothing**, so on codex today the three scripts are files
that sit in a worktree. **The portable half of the overlay is the inert half.**

**7 — `hooksHash` is not in the run record's hash tuple at all.** `run-agent.sh:668` writes
exactly `{instructionsHash, skillsHash, agentHash, agentsHash, knowledgeHash}`. `hooksHash` and
`mcpHash` exist in the API schema and are `null` on every run ever recorded. So the hook overlay
has **no per-run delivery proof on either runtime**, and that is not a codex problem.

**8 — the codex arm records no cost and no model calls, on 8 of 8 runs that exist.** Queried from
the API this session: every `runtime.product == "codex"` record has `estimatedCost: null`,
`modelCalls: null`, `inputTokens: null`, `outputTokens: null`. What it does have is
`reportedTotalTokens`, scraped out of the agent log by `run-agent.sh:1236-1244` — a **total only,
no split, no cost**. `run-agent.sh:1223` names the cause: *"`codex exec` has no OTel path
(ADR-001, #10)"*. This is gate clause *"observability capability"*, answered from stored records
before a single new run.

**9 — a cost ceiling is therefore inert on the codex arm, and the stop must not write one in
dollars.** Stop 17a's ceiling and stop 20's both read `estimatedCost`. On codex that field is
`null` by construction, so a dollar ceiling cannot fire. The ceiling for this step is registered
in runs and wall-clock instead. *(This is the same class of defect the state file already carries
as instrument fact 3b, met here for a structural reason rather than a telemetry outage.)*

**10 — `--enable-skills` is a no-op on codex, and codex seeds six skills of its own.**
`ENABLE_SKILLS` is consumed at `run-agent.sh:849` inside the `claude)` branch only. The guard at
line 433 still refuses a `SKILL.md` overlay when the flag is absent, so the flag must be passed
on a codex skill arm and **changes nothing when it is**. Meanwhile `run-agent.sh:934-940` records
that codex seeds six skills into `skills/.system` and that stripping them *"would make this arm
something other than codex-as-shipped"*. B6's specialist skill — the track's only clean positive
— therefore has no delivery proof on codex and an uncontrolled six-skill background it does not
have on claude.

**11 — the codex isolation control is FAILING on this machine today, and it is an L2 control of
this step's own arm.** `agent-observatory/runner/verify-codex-isolation.sh`, run 2026-09-27:
`ISOLATION LEAKS: the agent reached the operator's instruction files with HOME redirected.`
It exited 0 at the previous session's preflight. This is recorded in `preflight:` in
`TRACK-B-STATE.md` with both observations kept. **It is not treated as a settled fact from one
run** — an isolation probe asks a live model to go looking, and a model that did not look is not
a model that could not. Re-running it is the first act of §4 step 4, and `codex exec --help`
offers `--ignore-user-config`, `--ignore-rules` and `--ephemeral`, none of which the runner
currently passes and any of which may be the fix. That would be an additive instrument PR.

### What the eleven facts add up to

Sort the eleven overlay files by **what it takes to make them behave the same on codex**:

| # files | class | files |
|---|---|---|
| 7 | **byte-identical** | `.ai/policies/protected-paths.yaml`, `.ai/knowledge/` ×4, and 2 of the 3 `.ai/hooks/*.sh` as text |
| 1 | **rename only** | `CLAUDE.md` → `AGENTS.md` (fact 2) |
| 1 | **no analogue, wiring** | `.claude/settings.json` (facts 6, 7) |
| 1 | **no analogue, boundary** | `.claude/agents/backend-feature-phases.md` (facts 3, 4, 5) |
| 1 | **portable as text, dead as a control** | the third hook script, counted above as text and again here |

**8 of 11 files copy across, and that fraction is the trap.** It reads as *"P5 holds, 73 %"*.
But every **L2 control this track has ever measured** — B7's policy gate on 17 of 17 runs, B8's
repair limit, B4's and B5's named-agent boundary — is delivered by one of the two files that do
**not** port. Count files and P5 looks true; count *delivered controls* and it is false. The
prediction below must commit to both numbers separately, before either is measured, or the stop
will report whichever one flatters the claim.

---

## Build

**Build:** the same portable agent behind a second provider adapter.

```
adapters/claude-code/     CLAUDE.md + @AGENTS.md or --append-system-prompt-file, subagent, hooks
adapters/copilot/         .github/agents/*.agent.md, .github/hooks/*.json
adapters/codex/           AGENTS.md, subagents, sandbox flags
```

**This is not optional busywork.** Copilot's quota is exhausted on this account, so v1 is
currently unrunnable as written. The port is forced — and it is the only real test of whether
"portable core, thin adapters" was true or just an aspiration.

**Freeze everything else.** Same task, commit, skill, verification, rubric. Change the adapter
and the model, nothing else.

## Design and layers — §4 step 2

### The trap, and which layer converts it

`build/README.md#b10` names no trap in a labelled line, so it is named here from the step's own
text and from the census in `## Extract`:

> **The trap: a file count reads as a portability fraction.** 8 of the 11 overlay files copy to
> codex unchanged. Reported alone, that is *"P5 holds at 73 %"*. Every **L2 control this track
> has measured** is delivered by one of the 3 that do not copy. The step's own Build block invites
> the trap by phrasing the port as a directory layout.

**Which layer converts it: L2, and it already exists and was built for another reason.**
`run-agent.sh` refuses, at run time, each of the three non-portable pieces — the foreign
instruction filename (line 401), the `--agent` flag on a non-claude runtime (line 324), and a
`.claude/agents/` directory on a runtime with no native one (line 519). A port that is only a
file copy **does not start**. The census is L2 in its proof because the runner executes the
distinction; the count in the table is only the summary of what the runner already enforces.

The other half of the trap has **no** L2 conversion and that is a finding rather than a gap:
`.ai/hooks/*.sh` copy cleanly, nothing wires them on codex, `hooksHash` is `null` on every run
ever recorded (Extract fact 7), and therefore **nothing executes to tell a future reader that
the hooks arm is inert on codex**. That is **L3** and it is labelled L3 wherever it is claimed.

### Artifacts and their layers

| Artifact | What it is | Layer | Why |
|---|---|---|---|
| `adapters/codex/agent-v1.2-knowledge-codex/AGENTS.md` | the v1.2 `CLAUDE.md` body, renamed | **L2** | the runner reads and hashes it as `instructionsHash`, per run, per arm; and it `die`s if the name is wrong |
| the same overlay's `.ai/knowledge/**` | corpus, index, `router.sh` | **L2** for arrival (`knowledgeHash`), **L3** for uptake | stop 20 measured exactly this distinction on claude: 20 of 20 delivered, 3 of 20 consulted |
| the same overlay's `.ai/policies/` + `.ai/hooks/` | shell + YAML | **L3** | nothing wires them on codex, and no hash carries them on either runtime |
| the portability census table | counts | **L2** | the runner's three refusals execute; the table restates them |
| *not built:* `.codex/agents/*.toml` | a codex subagent | — | see the decision below |
| *not built:* a `hooksHash` instrument | — | — | it would be an instrument PR with no measurement behind it at this stop; recorded in `author_notes` |

### Decision — what the port contains, and what it deliberately omits

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-27.*

**The ported overlay is eight files: `AGENTS.md` plus `.ai/**` verbatim.** It omits
`.claude/settings.json` and `.claude/agents/backend-feature-phases.md`, and it **does not**
substitute a `.codex/agents/*.toml` subagent for the latter.

Reason, and it is the reason rather than a convenience: **codex's subagent has no `tools` field
at all** (Extract fact 5). The claude artifact being ported is a *boundary* — a `tools:`
allowlist — and E-005 measured what that allowlist does and does not stop. Writing the same
prose into a TOML file with no `tools` field ports the *text* and drops the *treatment*, which
is precisely the failure mode `run-agent.sh:319-327` was written to refuse and which this
project has now paid for four times. Building runner support for a mechanism that cannot carry
the treatment is instrument work with no measurement behind it.

**So the ported overlay is v1.2 minus both of its L2 controls, and saying so is the result, not
a caveat.** The portable core, delivered on the second runtime, is the part that stop 20 already
measured as `VOID` on the first one.

**Declared alternative, not taken:** fold the agent file's prose into `AGENTS.md`. Refused
because E-008/E-009 already measured prose-without-the-split on claude, and repeating it on
codex with the model changed would answer neither question.

#### Correction, additive, 2026-09-27 — the overlay is **nine** files, not eight

*By Opus 5 (claude-opus-5), autonomously, at §4 step 4. The sentence above is kept verbatim and
is not rewritten; §4 step 12 protects the text and this is the amendment that carries the fix.*

`find` over `build/customizations/agent-v1.2-knowledge/.ai` returns **eight** files, not seven:
three under `.ai/hooks/`, four under `.ai/knowledge/`, one under `.ai/policies/`. So the port is
`AGENTS.md` **plus eight** = **nine files**, and `run-agent.sh --check-customization` reads back
`tracked overlay files in the setup commit: 9 of 9`
(`evidence/b10/census-port-20260927.txt`).

**No prediction moves, and that is worth stating rather than assuming.** Prediction 1 is *"files
that port unchanged: 8 of 11"*, whose mechanism is *"everything under `.ai/` plus nothing else"* —
and `.ai/` is exactly those eight. The census confirms it at exactly 8 of 11. The slip was in the
prose count of the *ported directory* (9 files, of which 8 are unchanged copies and 1 is a
rename), never in the registered number. The same slip appears in `TRACK-B-STATE.md`'s
`next_action` note for this step and is corrected there the same way.

**The census result for both predictions is in the two experiment files** under *"Census result —
predictions 1 and 2"*, with the five executed probes and their exit codes.

**And one of those two files' census sentences is corrected there, additively, at §4 step 9:** the
customization block has **seven** fields, not five, and **`hooksHash` is one of them** — present and
`null` on 20 of 20 runs of this batch. `settingsHash` genuinely does not exist. The census read the
runner's five-hash `--check-customization` read-back and generalised it to the API record, which is
a narrower surface than the claim named; the correct version was already on record as the stop-16
author note. **Prediction 2, its verdict and its layer label do not move** — a field that is present
and `null` is not a control that ran — and the claim gets sharper, not weaker: the schema reserves a
field for exactly what the port drops and never populates it. Headline: 8 of 11 and
0 of 2, both as predicted, with the layer split the prediction did not anticipate — the named-agent
boundary is refused by something that runs (**L2**, `run-agent.sh:325` and `:522`), the policy gate
is lost with nothing executing to say so (**L3**, probe 5 exits 0 and tracks the file).

### Arms, and what is cited rather than re-run

| Arm | Runtime | Model | Overlay | `n` | Source |
|---|---|---|---|---|---|
| codex-treated | `codex` | `gpt-5.6-sol` | the **9**-file port *(this cell said `8-file`; corrected additively 2026-09-27 at §4a round 1, finding 1 — 8 of the 9 are unchanged copies and 1 is a rename)* | 5 per task | **new, this stop** |
| codex-control | `codex` | `gpt-5.6-sol` | none | 5 per task | **new, this stop**, interleaved |
| claude-treated | `claude` | `claude-haiku-4-5-20251001` | `agent-v1.2-knowledge` (11 files) | 10 per task | **cited** — stop 20, E-022 / E-023 |
| claude-control | `claude` | `claude-haiku-4-5-20251001` | none | 10 per task | **cited** — stop 20, E-022 / E-023 |

The claude rows are cited and **not re-run**: same benchmark sha, same evaluator, same model,
same overlay, closed eight hours before this stop opened. Re-running them would spend money to
produce a second copy of an existing measurement, and §6 protects evidence rather than volume.
That satisfies the gate's *"≥3 runs per runtime"* on the claude side with `n = 10` per arm per
task.

**The two runtimes do not carry the same overlay and no effect is compared across them.** The
claude arms carry 11 files, the codex arms carry **9** — 8 unchanged copies and 1 rename *(this
sentence said `8`; corrected additively 2026-09-27 at §4a round 1)*. That difference *is* the port, and it is why
the only verdicts computed here are **within** a runtime — codex-treated against codex-control,
per task, under decision 9.

### Budget and the stop rule, in runs and wall-clock because dollars are unavailable

`estimatedCost` is `null` on 8 of 8 codex runs ever recorded (Extract fact 8), so a dollar
ceiling **cannot fire on this arm** and is not written. The ceiling is:

- **20 codex runs** (2 tasks × 2 arms × 5), floor 3 per arm per §4 step 6;
- **4 hours of batch wall-clock**, from the stored codex durations on BE-003: 35 s, 97 s, 115 s,
  121 s, 455 s — median **115 s** — excluding `77c7d1c3`, whose `durationMs` of 35 342 s is a
  machine-sleep artefact and is excluded as *duration*, not as a run (§4 step 6). BE-004 is five
  files and two suites and is expected longer;
- **early end** at: codex refusing on quota (§4c, report the population that occurred, precedent
  E-016 at `n = 7`); or a preflight that cannot show `instructionsHash` and `knowledgeHash` set
  on the treated arm and `null` on the control.

**A named risk, registered before the batch:** codex is also the *registered scorer* (Decision
C). Twenty benchmark runs on codex draw on the same quota the sheets need. If the scorer is
refused after the batch, §4c steps 1–4 apply — wait, do not substitute, score when it returns.
Decision H is **not** fired by this; it promotes deepseek, which stop 20 refused.

---

## Predict before you run

Registered in `experiments/E-024-second-runtime-adapter-BE003.md` and
`experiments/E-025-second-runtime-adapter-BE004.md`, one prediction commit per task per decision
9. The **portability census** below is task-independent, is measurable with no run at all, and is
registered once here and cited by both.

**P5's number, predicted before the census is computed — two numbers, not one, because the trap
in `## Design and layers` is that they differ:**

| | predicted | mechanism |
|---|---|---|
| **files that port unchanged** | **8 of 11** (73 %) | everything under `.ai/` plus nothing else; `CLAUDE.md` needs a rename, and the two `.claude/` files have no analogue |
| **measured L2 controls that survive the port** | **0 of 2** (0 %) | the policy gate and the repair limit are wired by `.claude/settings.json`; the named-agent boundary needs `--agent`. Both wirings are claude-only in this runner |

**If both hold, P5 is true of text and false of controls, and that sentence is the stop's
headline.**

Everything else predicted is in the two experiment files, with direction, magnitude and
mechanism, and each carries the line *"the author did not review before the run."*

## Lab B10.1 — same agent, two runtimes

`≥3 runs per runtime` is satisfied as the arms table in `## Design and layers` sets out: the
claude side is **cited** from stop 20 at `n = 10` per arm per task; the codex side is **run** at
`n = 5` per arm per task, interleaved control-then-treated.

**`agent-observatory#47` is still open** — checked by API 2026-09-27, `state: open`. The scaffold
said to check it before trusting the numbers. It voids *cross-runtime* quality comparison, which
this lab does not perform for three independent reasons (`## Goal`). It does **not** void a
within-runtime treated-vs-control comparison on codex, because a permission block misrecorded as
incorrect code would fall on both codex arms alike.

## Deliberate failure

**Registered as a TODO with its options, and the choice is deferred to §4 step 9 on purpose** —
which mechanism is worth breaking depends on what the batch shows was load-bearing, which is
exactly how stop 20's step 9 was decided and why it produced a result. Prediction first, in
writing, committed, then the run.

Candidates, in the order they are currently ranked:

1. **Break the rename.** Ship the port with `CLAUDE.md` instead of `AGENTS.md` on codex and show
   `run-agent.sh:401` refuses before a run starts. **Weak** — it proves a guard that is already
   proved by its own fixtures, and it spends nothing because no run happens.
2. **Prove fact 6 by measurement rather than by reading the runner.** Ship the port *with*
   `.claude/settings.json` alongside `AGENTS.md`, which the runner permits (it only refuses the
   foreign *instruction* name when the native one is absent), and show **zero** hook executions
   on codex against B7's 17 of 17 on claude. This is the candidate that converts an L3 claim into
   an L2 observation and is currently ranked first.
3. **Break the corpus path.** Point `.ai/knowledge/index.yaml` at a document that is not there.
   Ranked last: stop 20 measured corpus contact at 3 of 20 on claude, so at `n = 5` on codex the
   broken path would reach roughly zero runs, and the arithmetic for that was already written
   down at stop 20.

### The choice — candidate 2, and the ranking above is amended additively rather than rewritten

*Chosen and predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-27, at §4 step 9, after the
batch and the scoring closed at §0 boundary 3. The three candidates above are kept verbatim; §4
step 12 protects the text and this section carries the decision.*

**Candidate 2 runs.** It is the only one of the three that changes what this stop can *prove* rather
than what it can *say*: it converts the stop's one remaining **L3** claim — prediction 2's second
half, *"the policy gate does not survive the port"*, currently proved by **reading**
`run-agent.sh` and by `hooksHash` being `null` — into an **L2** observation of a script that is
proved to run, installed, and logging nothing.

**Candidate 1 is refused as written:** it proves `run-agent.sh:406` refuses a foreign instruction
filename, which that guard's own fixture set already proves, and no run happens, so it buys a
second copy of an existing L2 proof.

**Candidate 3 is dead, and saying why matters more than re-ranking it quietly.** Its stated
mechanism was *"corpus contact at 3 of 20 on claude, so at `n = 5` on codex the broken path would
reach roughly zero runs"*. The batch **refuted that premise at 5 of 5 per task, 10 of 10 treated**
(prediction 4, E-024 / E-025). So breaking the corpus path on codex would now hit every treated
run and would be a **different and better experiment** than the one that was ranked last — a real
measurement of what the agent does when the router's target is missing, on a runtime where it
demonstrably reads it. It is recorded in `author_notes` as that, not re-ranked into this slot.

#### The observable is settled before the prediction, because the obvious one does not exist

`TRACK-B-STATE.md` `preflight:` row 6b, re-confirmed this session and the one before it: **the run
record has no hook-execution field at all.** The only hook-ish key in the whole JSON is
`hooksHash`, `null` on every run ever recorded. So *"zero hook executions"* is **not** read off a
record here, and no absence in a record is reported as a measurement.

**The observable is `policy-gate.sh`'s own log**, which its header names as *"the ONLY per-run
delivery proof available"* and which it appends to **on allow as well as on deny** for exactly this
reason. It is written outside the worktree — B7 moved it there after the log's own presence in the
diff scored two solved runs `exit 21` — at
`${POLICY_EVENT_LOG:-${TMPDIR:-/tmp}/policy-events-$(basename ${CLAUDE_PROJECT_DIR:-unknown}).jsonl}`.

**And the sweep is a glob, not a predicted filename.** `grep -n 'CLAUDE_PROJECT_DIR\|POLICY_EVENT_LOG'
runner/run-agent.sh` returns **nothing**: the runner sets neither, so on a codex run the log's name
is not predictable in advance — it would be `policy-events-unknown.jsonl` if anything wrote it at
all. Looking in one predicted place and calling the absence a measurement is this project's house
failure mode, so the check sweeps `${TMPDIR}/policy-events-*.jsonl` **and** `/tmp/policy-events-*.jsonl`
for anything created inside the run window.

#### Predictions — DF1, registered before the run

Overlay: `evidence/b10/census-fixtures/port-plus-claude-settings/` — **ten files, already tracked,
already the subject of census probe 5**, re-verified on disk at §4 step 9: `diff -r` against the
registered nine-file port differs by `.claude/` **and nothing else**, `settings.json` byte-identical
to v1.2's, modes `755` on all four `.sh` and `644` on the rest, `instructionsHash`
`sha256:ebf489800a60a156986f98ea4f127848` and `knowledgeHash` `sha256:0770219ae7f4281a80071d78dadea285`
— the registered values. Task **BE-003**, runtime `codex`, model `gpt-5.6-sol`, key
**`EXP-B10-DF-BE003`** — its own key, **not in E-024's population**, exactly as the preflight pair was.

| | prediction | magnitude | mechanism | refuted if |
|---|---|---|---|---|
| **DF-P1** | the runner **does not refuse** the extra `.claude/settings.json` on codex and the run completes | 1 of 1, `tracked overlay files in the setup commit: 10 of 10` | census probe 5 already exited **0** at `--check-customization`; a real run adds only the model call and no refusal sits between them | the overlay install path returns non-zero |
| **DF-P2** | **zero** hook executions: no `policy-events-*.jsonl` is created anywhere in `$TMPDIR` or `/tmp` inside the run window, **while the run changes ≥ 1 file** | **0 log lines**, against B7's **20** treated logs and **0** control logs (`find evidence/b07/batch-* -name '*-treated-policy-events.jsonl' \| wc -l` → 20; `…-control-…` → 0; E-016's scored population 17 of 17) | `.claude/settings.json` is read by claude-code's own hook dispatcher and by nothing else; `codex exec` has no hook protocol, and the runner copies the file into the setup commit without interpreting it | any log line appears |
| **DF-P3** | the **positive control** fires in the same session on the **same script sha**: the installed `policy-gate.sh` at `f432abbcbf1f3b90ec4dd801a23c333a5f7e6c40fe0b54b11fd5689f9938cbca` — B7's registered value, verified bit-for-bit on the fixture — invoked directly, exits **2** on `sample-service/pom.xml` and **0** on a `.kt` path, writing **one log line each** | 2 of 2 exit codes, 2 log lines | B7 measured exactly this; §5 requires a verification command be re-run immediately before the assertion it supports | either exit code or either log line is missing |
| **DF-P4** | **no hash sees the added file**: `instructionsHash` and `knowledgeHash` come back at the two registered values **unchanged by the tenth file**, and **no `settingsHash` or `hooksHash` key exists anywhere in the record JSON** | 2 values identical, 0 such keys | `run-agent.sh` hashes `AGENTS.md` (`:572-576`) and the `.ai/knowledge` tree (`:653-668`) and nothing else | either hash moves, or such a key exists |

**DF-P2 is VOID rather than held if the run changes 0 files**, and that clause is registered here
rather than discovered afterwards: an empty trigger population makes an empty log unattributable.
B7's own `unexpected_effect` (2) is that *"the delivery proof cannot distinguish 'no hook installed'
from 'hook broken, denying everything'; both leave no log."* **DF-P3 is what removes the second
horn** — a script proved to execute and to log, at the sha B7 measured — and **DF-P2 without DF-P3
proves nothing and leaves the L3 label standing.** The two are reported together or not at all.

**What this converts, stated before the result is known.** If DF-P1 through DF-P4 all hold, the
sentence *"0 of 2 measured L2 controls survive the port"* is proved for **both** halves by things
that ran: the named-agent boundary by two executing refusals (census probes 3 and 4, `run-agent.sh:325`
and `:522`), and the policy gate by a working hook that was installed, tracked, and never invoked.
If DF-P2 is refuted, prediction 2 of both experiments is **wrong on its second half**, the census's
L3 label was wrong in the other direction, and that is the more interesting outcome of the two.

**Cost and ceiling:** one codex run under its own key, outside E-024's population and outside the
batch manifest the 20-run ceiling counts, plus two direct hook invocations that cost nothing.
Expected 2–4 minutes. `estimatedCost` is `null` on every codex run ever recorded, so no dollar
figure is available and none is quoted.

#### DF1 result — 2026-09-27, all four held, and the conversion happened

*Read by Opus 5 (claude-opus-5), autonomously, after the run. Measurement at
`evidence/b10/df-20260927T163230Z/RESULT.md` (driver output plus a dated addendum); run record kept
verbatim at `run-record.json` beside it. Prediction commit `5400278` at **`16:28:09Z`**, run
`startedAt` **`16:32:31Z`** — **4 m 22 s** before, read from git and from the record, not from prose.*

Run `18eac7c0-971f-496d-8868-8799d4fec2b5`, BE-003, `codex` / `gpt-5.6-sol` / `codex-cli 0.154.0`,
key `EXP-B10-DF-BE003`, `--isolate-user-settings --keep`, evaluator **`exitCode 0`**, 3 changed
files, 25 551 tokens, 135 s.

| | verdict | what was measured |
|---|---|---|
| **DF-P1** | **HELD, on replacement evidence** | runner `rc = 0`, the run completed and the evaluator returned 0. **But the read-back string I registered does not exist on a real run** — `tracked overlay files in the setup commit: N of N` is printed by `--check-customization`, which is where the census saw it. The replacement is author decision 11 item 9 condition (a) and is stronger: the setup commit `9652494fa571`'s own tree lists **10 paths** including **`.claude/settings.json`**, byte-identical at `925a3823…`. **The guardrail's wiring file was committed into the run's evaluation baseline and the run proceeded.** |
| **DF-P2** | **HELD, and not VOID** | `policy-events-*.jsonl` across `$TMPDIR` and `/tmp`: **0 before, 0 after, 0 new or grown**, by name *and* by line count. Trigger population **non-empty**: 3 Kotlin source files changed, all `Edit`/`Write` targets, all **allow** paths — so on claude the gate would have written three `allow` lines. Against B7's **20** treated logs / **0** control logs. |
| **DF-P3** | **HELD twice** | the installed gate at B7's sha `f432abbc…` → exit **2** on `pom.xml`, exit **0** on `ApiError.kt`, **2** log lines. And then again **from the run's own worktree after the run**, exit **2** with a `deny` line. |
| **DF-P4** | **HELD** | `instructionsHash` and `knowledgeHash` back at the two registered values, **unmoved by the tenth file**; `hooksHash` **`null`**; the only keys matching `/hook\|settings/i` anywhere in the record are `customization.hooksHash` and `runtime.userSettingsIsolated`. |

**The conversion is done: prediction 2's second half is now L2.** It was *"`run-agent.sh` does
nothing with `.claude/settings.json` on codex"* — a sentence derived by reading source, which §5
makes **L3**. It is now: a hook **proved to execute**, at the sha B7 measured **17 of 17**, committed
`100755` into the run's own baseline, still executable and still firing after the run, with a
non-empty and correctly-typed trigger population, **logging nothing**. Both halves of *0 of 2
measured L2 controls survive the port* are now proved by things that ran — the named-agent half by
two executing refusals (census probes 3 and 4), the policy-gate half by this.

#### Correction, additive, 2026-09-27 after §4a round 1 — **DF-P4 is REFUTED on its second clause, and "all four held" was wrong**

*By Opus 5 (claude-opus-5), autonomously, after the codex review of this workbook and of E-024
returned the same finding twice at 2/2 recurrence. **The prediction above is not edited and the
result table above is not edited**; §4 step 12 protects both, and this section carries the
correction. The reviewer was right and I was wrong.*

DF-P4 as registered has **two** clauses and a refutation rule that covers both:

> *"`instructionsHash` and `knowledgeHash` come back at the two registered values **unchanged by the
> tenth file**, and **no `settingsHash` or `hooksHash` key exists anywhere in the record JSON**." …
> **refuted if** either hash moves, **or such a key exists**.*

**`hooksHash` exists.** It is `null`, on 20 of 20 batch runs and on the DF run. **A null key is a
key**, so DF-P4's own registered refutation clause fires:

| clause | verdict |
|---|---|
| neither registered hash moves when a tenth file is added | **HELD** — both back at `sha256:ebf489800a60a156986f98ea4f127848` and `sha256:0770219ae7f4281a80071d78dadea285` |
| no `settingsHash` **or `hooksHash`** key exists anywhere in the record | **REFUTED** — `settingsHash` indeed does not exist; **`hooksHash` does** |

**So the DF's score is three predictions held and one split — held on its first clause, refuted on
its second — and every sentence in this workbook and in E-024/E-025 that reads *"all four
predictions held"* is wrong as written and is corrected by this section.**

**How it happened, because that is the part worth keeping.** DF-P4 was registered in commit
`5400278` at `16:28:09Z`, drafted from the census's sentence *"the five fields are
`instructionsHash`, `skillsHash`, `agentHash`, `agentsHash`, `knowledgeHash`"*. **I then discovered
that sentence was wrong** and committed the seven-field correction in `94f4312` — **two commits
later, in the same session, and never went back to the clause the discovery refutes.** A correction
was written and its consequence for a live prediction was not traced. That is a smaller version of
exactly the failure the correction itself describes, and it took a second model family to see it.

**The substantive conclusion does not move, and saying so is not a softening.** No hash saw the
tenth file: `hooksHash` is `null` on every run ever recorded, so the overlay that ships a dead
guardrail is still indistinguishable, in every field the record carries, from the overlay that does
not ship it. **What moves is the prediction's score**, and a prediction whose wording was refuted
while its intent survived is recorded as refuted, not as "held in spirit" — that distinction is the
only thing keeping the other twelve verdicts in this stop worth reading.

**Six alternative explanations were closed by command, not by argument**, and they are tabulated in
the RESULT addendum: not-installed, installed-non-executable (the mode bit no hash sees, stop 20's
precedent), deleted-mid-run, broken-and-dying-silently, empty-trigger-population, and — the one a
validator should ask hardest — **a detector that was never shown to fire**, closed by
`verify-b10-df-guards.sh` case L, which plants a log, grows it, writes another, and requires the
sweep to report `2`.

**And the DF returned something nobody predicted, which is the part worth carrying.** In the *same
run*, from the *same directory*, `.ai/knowledge/router.sh` **did** write its log — one `hit` with the
task's own query — while `.ai/hooks/policy-gate.sh` wrote nothing. Two shell scripts, one overlay,
one runtime: one ran, one did not, and the difference is **who invokes it**. The router is called by
*the model*, having read about it in `AGENTS.md`; the gate must be called by *the runtime*.

> **What ports is what the model can call. What does not port is what the runtime must call.**

That is a better statement of P5 than *8 of 11* is, because it is a rule a reader can apply to a file
they have not seen yet, and it also closes the alternative reading that `.ai/` simply does not
function on codex. It is a co-variate of **one run**, labelled `n = 1` and stated as true of this run
rather than as a property (§5). It was not registered and it is **not** this stop's verdict.


## Decide — keep, modify, remove · §4 step 10

*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-27. Four decisions, and the second one is
a refusal to decide, with the reason it is not an evasion.*

### 1. The nine-file codex port — **KEEP**, unedited

It delivered on 10 of 10 treated runs at the two registered digests, on both tasks, with all five
hashes `null` on 10 of 10 controls, 0 void. It is the artifact this stop was built to produce and it
works. **And it is not edited, now or later**: §3's pre-made decision is that *"a version that has
been measured is never edited; a change is a new version"*, and this one has been measured at
`n = 5` per arm per task.

### 2. The knowledge corpus inside it — **NO keep/remove decision is taken**, and that is the finding

§4 step 10 says *"a rule with no measured effect is removed, and its removal is recorded as the
finding."* **It does not apply here, and conflating the two cases would be the worst mistake
available at this step.** What happened is not a measured no-effect. It is **an outcome with no
headroom**: `architecture-consistency` is a 0–2 scale and **the control scored 2 on 5 of 5 on
BE-003 and 5 of 5 on BE-004**. An improvement was *arithmetically impossible* before the first
treated run started; the only direction open was down. A "no measured effect" is a corpus that had
room to move something and did not. This corpus was never given room.

Removing it on that basis would delete the mechanism the batch's co-variates suggest is doing the
most visible work in it — `maintainability` moved from a control median of 0 to 2 on 5 of 5 **on both
tasks**, same direction, same magnitude, zero within-arm variance. That was **not** a registered
outcome, E-004 refused exactly this promotion for exactly this reason, and so does this stop: it is
recorded as a co-variate and it is **not** grounds for keeping either. **Neither decision is
available from this batch.** The honest output is the registered outcome a later codex stop should
use, which is in `author_notes`.

### 3. `.claude/settings.json` in a codex overlay — **REMOVE, and now the no-effect is measured**

The registered port deliberately omitted it, on a *reading* of `run-agent.sh`. DF1 turned that
reading into a measurement: shipped, committed `100755` into the run's own evaluation baseline,
byte-identical, with a non-empty trigger population — and **zero hook executions**, against B7's 20
treated logs on claude. So the omission stands with its evidence, and the recorded finding is the one
§4 step 10 asks for:

> **A `.claude/settings.json` in a codex overlay is not a guardrail with no effect. It is a document
> that reads like a guardrail.** Shipping it would be worse than omitting it, because a reader who
> saw it in the tree would believe the policy gate was active. It is refused from every codex overlay
> from here on, and the reason is a run id rather than a paragraph.

### 4. The three `.ai/hooks/*.sh` that the port *does* carry — **KEPT under protest, and named**

**Measured: one of the three. Inferred for the other two, and the inference is named rather than
hidden.** DF1 observed `policy-gate.sh` not firing. `repair-limit.sh` and `repair-record.sh` were not
separately observed — but **all three are wired by the single file DF1 proved is read by nothing**:
`jq` over `.claude/settings.json` returns `PreToolUse → policy-gate.sh`, `PreToolUse →
repair-limit.sh`, `PostToolUse → repair-record.sh` and no other entry. So the claim about the other
two rests on one measurement plus one file, and that is **L3 for them** while the `policy-gate.sh`
half is L2. Both labels appear in the §5 table. **They stay**, because decision 1 above forbids editing a measured overlay, and because
removing them would change `AGENTS.md`'s registered digest's sibling files and therefore the
artifact two experiments cite. **What is recorded instead** is that the nine-file port contains
**three files that cannot execute on its target runtime**, so its honest description is not *"the
portable core"* but *"the portable core plus three inert files"*. A codex-targeted **v1.3** would
carry six, and that is a build decision for whoever opens one — not an edit here. This is the
sharpest available illustration of the trap named in `## Design and layers`: **a file count reads as
a portability fraction**, and 8 of 11 counts three files that do nothing.

## Learning · §4 step 11

The six questions from [`build/README.md`](../../build/README.md#after-every-step), answered from
evidence rather than from intent.

```yaml
learning:
  what_was_added: >
    build/customizations/agent-v1.2-knowledge-codex/ — the v1.2 overlay's CLAUDE.md renamed to
    AGENTS.md plus .ai/** byte-identical, nine files, delivered by run-agent.sh --customization on
    the codex runtime. Plus three instruments that are not the treatment: evidence/b10/census-port.sh
    (five real --check-customization probes), evidence/b10/probe-codex-isolation.sh (three runs), and
    evidence/b10/run-b10-df.sh with 22 fixture cases. NOT added: .codex/agents/*.toml, a hooksHash
    instrument, a .claude/settings.json in the port.
  why_it_exists: >
    To test P5 — "portable core and thin adapters" — by moving the one overlay this track has
    actually measured onto a second runtime, and to answer gate #b10 from what the move costs and
    from what the instrument can still see afterwards. The port was forced rather than chosen:
    Decision G removed the Copilot arm, so codex is the only second runtime available.
  observed_effect: >
    On P5's text: 8 of 11 files port unchanged (73%), exactly as predicted, diff -r over .ai
    returning nothing. On P5's controls: 0 of 2 survive, exactly as predicted. On the agent: NOTHING
    THE REGISTERED OUTCOME COULD SEE, on both tasks — architecture-consistency medians 2 vs 2,
    exact Mann-Whitney p = 1.0000 (BE-003) and 0.4444 (BE-004), decision-rule row 4, NOT DETECTABLE
    at this n. On uptake: 10 of 10 treated runs called the router exactly once, every call a hit with
    the task's own query; 0 of 10 controls. On the evaluator: 20 of 20 exitCode 0. On delivery: 10 of
    10 treated at both exact registered digests, 10 of 10 controls with all five hashes null, 0 void.
  unexpected_effect: >
    Four, and the first is the stop's real result. (1) THE REGISTERED OUTCOME WAS AT ITS CEILING IN
    THE CONTROL BEFORE THE FIRST TREATED RUN STARTED — architecture-consistency is 0-2 and the
    control scored 2 on 5 of 5 on BOTH tasks, so an improvement was arithmetically impossible and
    the only direction open was down, which two BE-004 treated runs took. Registering the MDE as
    "undefined before the batch; the concurrent control is its first measurement" was honest AND WAS
    NOT ENOUGH. (2) That shows author decision 9's headroom fix DOES NOT TRANSFER ACROSS RUNTIMES:
    BE-004 was added because BE-003 was ceilinged on claude-haiku-4-5-20251001, and on gpt-5.6-sol
    both tasks are ceilinged alike. (3) Corpus contact went from 3 of 20 on claude to 10 of 10 on
    codex with the same corpus, the same instruction text and the same two digests — prediction 4
    refuted, not narrowly, and stop 20's claude rate was the wrong reference class. (4) DF1's
    co-variate at n = 1: in one run, from one directory, the router's log was written and the policy
    gate's was not, because the router is called by the MODEL and the gate must be called by the
    RUNTIME.
  keep_or_remove: >
    KEEP the port, unedited (a measured version is never edited). REMOVE .claude/settings.json from
    every codex overlay, and now the no-effect is MEASURED rather than read: DF1 shipped it,
    committed 100755 into the run's own baseline, with a non-empty trigger population, and got zero
    hook executions against B7's 20 treated logs. NO KEEP/REMOVE DECISION IS TAKEN ON THE KNOWLEDGE
    CORPUS, and that refusal is the most important line here: §4 step 10's "a rule with no measured
    effect is removed" does not apply to AN OUTCOME WITH NO HEADROOM, and conflating the two would
    delete the mechanism the co-variates suggest is doing the most visible work in the batch.
    Nothing is promoted; B13's gate requires a measured benefit and there is none on this outcome.
  next_question: >
    For any later codex stop: register maintainability as the primary outcome, not
    architecture-consistency. It is the only category that moved in the same direction and magnitude
    on BOTH tasks (control median 0, treated 2 on 5 of 5, zero within-arm variance) and it had
    headroom where the registered outcome did not. It was NOT registered here and is therefore NOT
    this stop's result. Before that, two things this batch should have bought and did not: a CONTROL
    ARM RUBRIC CENSUS before choosing the outcome — 18 seconds of codex would have shown the ceiling
    — and a second reader for change-focus, which moved 1 -> 0 on 5 of 5 on BE-004 and is the
    instrument's noisiest dimension at 18 of 34 concordance (decision 10.2).
```

### Was this the agent, or the harness? — §4 step 11's last question

**Both, and the split is unusually clean at this stop, which is why it is worth stating in full.**

**The harness produced the verdict.** `NOT DETECTABLE` on both tasks is a fact about
`architecture-consistency` being a three-level scale whose top level the control already occupied.
No property of the agent, the overlay or the runtime could have moved it. **The instrument chose the
answer before the treatment was delivered**, and the defect is in outcome selection, not in the
model: E-006 found the same shape on BE-003 under claude and author decision 9 was written to fix it,
and the fix did not transfer.

**The agent produced the uptake result.** 10 of 10 router calls against 3 of 20 on claude is a
behavioural difference on the same corpus, the same instruction text and the same digests. That is
the agent — or more precisely the runtime-and-model pair, which §6 forbids separating here — and
it is the one number at this stop that is about the thing under test.

**The harness produced the deliberate failure's answer too, and that is the point of it.** *Nothing
on codex invokes `.claude/settings.json`* is a statement about `run-agent.sh` and `codex exec`, not
about `gpt-5.6-sol`. DF1 exists precisely because that sentence had been a **reading** of a harness
and §5 required it to become an **observation** of one.

**And one number is neither.** `estimatedCost`, `modelCalls` and `toolCalls` are `null` on 20 of 20.
That is not the agent being cheap and not the harness being broken; it is `codex exec` having no
OTel path (ADR-001, obs#10). It is reported as an observability limit and never as an efficiency
result — which is what gate clause *"observability capability"* was asking for.

## Exit gate

**From the build track:** ≥3 runs per runtime · compare quality, correction effort, usage **and
observability capability** · document each provider's limitations · pick primary and fallback.

*Answered by Opus 5 (claude-opus-5), autonomously, 2026-09-27, from the evidence in the §5 table
below. Every number carries its `n`; nothing from `n < 5` is stated as a property (§5).*

### Clause 1 — ≥3 runs per runtime · **MET**

| runtime | arms | `n` per arm per task | source |
|---|---|---|---|
| `codex` | treated / control | **5** | **run**, this stop, batch `20260927T125809Z`, 20 runs, interleaved, 0 void |
| `claude` | treated / control | **10** | **cited**, stop 20 / E-022 / E-023 — same benchmark sha, same evaluator, same model, closed hours before this stop opened |

The claude rows are **not re-run**. §6 protects evidence rather than volume, and a second copy of an
existing measurement costs money to tell you nothing. Both runtimes clear the floor of 3, one at
`n = 5` and one at `n = 10`, and the `n` is attached wherever either is quoted.

### Clause 2 — compare quality, correction effort, usage and observability capability

**Quality: NOT COMPARED ACROSS RUNTIMES, and the evidence that it cannot be is the answer, not a
gap in it.** Three independent blockers, each sufficient on its own: `agent-observatory#47` is open
(`state: open`, checked by API 2026-09-27); the model necessarily moves with the adapter
(`claude-haiku-4-5-20251001` does not run on codex — that is **two** variables and §6's one-variable
rule is not suspended because a step's own text asks for it); and cross-arm quality claims are
blocked by HANDOFF's seventh session. **Within codex, quality was compared and is the verdict:**

| task | `architecture-consistency` control (`n = 5`) | treated (`n = 5`) | medians | exact Mann-Whitney | row |
|---|---|---|---|---|---|
| BE-003 | 2, 2, 2, 2, 2 | 2, 2, 2, 2, 2 | **2 vs 2** | **p = 1.0000** | **4 — NOT DETECTABLE at this `n`** |
| BE-004 | 2, 2, 2, 2, 2 | 1, 1, 2, 2, 2 | **2 vs 2** | **p = 0.4444** | **4 — NOT DETECTABLE at this `n`** |

**And the reason is the finding rather than the verdict: the control was at the scale's maximum on
5 of 5 on both tasks, so an improvement was arithmetically impossible before the first treated run
started.** The only direction open was down, and two BE-004 treated runs went there.

**Correction effort: NOT MEASURABLE ON THIS RUNTIME, and that is a limitation, not a null result.**
The available proxies are `modelCalls` and `toolCalls`, and both are `null` on **20 of 20** codex
runs. `changedFiles` is reported instead and is not a correction-effort measure: BE-003 median
3 → 2, BE-004 median 7 → 7. No correction-effort claim is made for codex in either direction.

**Usage: measured, reported, never a verdict.** `reportedTotalTokens` is non-null on 20 of 20
(prediction 5's registered number). BE-003 median **25 840 → 34 736** (+34.4 %); BE-004 median
**29 624 → 33 349** (+12.6 %). Durations BE-003 **85 000 → 108 000 ms**, BE-004
**138 000 → 145 000 ms**. **`estimatedCost` is `null` on 20 of 20, so no dollar figure exists for
this runtime and none is quoted** — and a token increase beside an undetectable quality change is
row 5 material, not an efficiency finding.

**Observability capability: answered as a number, which is what makes this the clause the stop
answered best.** Prediction 5 registered it in advance and it held on both halves:

| field | codex, `n = 20` | claude, stop 20 |
|---|---|---|
| `estimatedCost` | **null on 20 of 20** | populated |
| `modelCalls` | **null on 20 of 20** | populated |
| `toolCalls` | **null on 20 of 20** | populated |
| `reportedTotalTokens` | **non-null on 20 of 20** (predicted ≥ 8 of 10) | populated |
| `customization.instructionsHash` / `knowledgeHash` | **exact registered values on 10 of 10 treated, null on 10 of 10 controls** | same digests, bit for bit |
| `customization.hooksHash` | **null on 20 of 20** — the field exists and is never populated | null on every run ever recorded |

`codex exec` has no OTel path (ADR-001, obs#10); `run-agent.sh:1236-1244` scrapes a bare total out of
the agent log, which is why exactly one of the four efficiency fields survives.

### Clause 3 — document each provider's limitations · **MET**

| limitation | provider | evidence | layer of the proof |
|---|---|---|---|
| no named subagent: `--agent` is not forwarded | codex | `run-agent.sh:325`, census probe 3, **exit 1** | **L2** |
| no agent directory at all | codex | `run-agent.sh:522`, census probe 4, **exit 1** | **L2** |
| a codex subagent has **no `tools` field**, so a `tools:` allowlist cannot be ported at all — only its prose | codex | Extract fact 5; and E-005 measured what the allowlist does, so porting the prose without it drops the treatment | **L3** — read from docs, nothing executes |
| the foreign instruction filename is refused | codex | `run-agent.sh:406`, census probe 2, **exit 1** | **L2** |
| **`.claude/settings.json` is accepted, tracked, and read by nothing — so hooks, the policy gate and the repair limit are silently inert** | codex | census probe 5 **exit 0**; then **DF1** run `18eac7c0`: 10 files in setup commit `9652494fa571`, gate `100755`, 3 changed files, **0 policy-event logs**, and the same gate firing on demand before and after | **L2 for `policy-gate.sh`** (observed); **L3 for `repair-limit.sh` / `repair-record.sh`** (same wiring file, not separately observed) |
| three of four efficiency fields unavailable | codex | table in clause 2, `n = 20` | **L2** — read from 20 records |
| no `hooksHash` or `settingsHash` control: the schema reserves `hooksHash` and never populates it | both | `jq '.customization\|keys'` → 7 keys; `hooksHash` null on 20 of 20 | **L2** for the null, **L3** for what it implies |
| Copilot: **no claims at all** | — | Decision G; §6 forbids any claim about a Copilot-run agent | — |

### Clause 4 — pick primary and fallback · **MET**

**Primary: `claude`. Fallback: `codex`.** Decided on the two things that are comparable across
runtimes — **what the instrument can see** and **what the harness can enforce** — and explicitly
**not** on quality, which clause 2 shows is not comparable here.

1. **Observability.** claude populates `estimatedCost`, `modelCalls` and `toolCalls`; codex
   populates none of the three on 20 of 20. A runtime on which cost cannot be measured cannot be the
   primary of a track whose promotion gate (B13) is written in `tokens_per_accepted_task`.
2. **Enforcement.** Every **L2** control this track has built — B7's policy gate, B8's repair
   limit, B4/E-005's named-agent boundary — is delivered by a mechanism codex does not have. On
   codex they are prose. DF1 measured that rather than argued it.
3. **What the fallback is good for, because this is not a dismissal.** codex ran the task
   **20 of 20 with evaluator `exitCode 0`**, at token counts within +13 % to +34 % of its own
   control, and it **read the knowledge corpus on 10 of 10 treated runs** where claude read it on
   3 of 20. As a *runner of the task* it is entirely serviceable; as a *carrier of guardrails* it is
   not. That is the honest shape of a fallback.

### Plus, for this to count as a learned phase: was "portable core, thin adapters" true?

**True of the text. False of the controls. And the file count is the trap, not the answer.**

- **8 of 11 files port unchanged (73 %)** — `diff -r` over `.ai` returns nothing, `CLAUDE.md` →
  `AGENTS.md` is a rename, the two `.claude/` files have no analogue.
- **0 of 2 measured L2 controls survive (0 %)** — and after DF1 **both halves are proved by things
  that ran**: the named-agent boundary by two executing refusals, the policy gate by a working hook
  that was installed, committed `100755`, and never invoked.
- **The adapter is not thin. It is where every control lived.** The three files that did not port
  carry 100 % of the enforcement; the eight that did carry the prose and the corpus.
- **And 8 of 11 overstates even the text**, because the ported eight include **three `.ai/hooks/*.sh`
  that cannot execute on the target runtime**. The port's honest description is *the portable core
  plus three inert files*. A codex-targeted v1.3 would carry six of eleven — **55 %**.
- **DF1's unpredicted co-variate is the best one-line statement of P5 this stop produced**, and it is
  `n = 1`, stated as true of that run and not as a property: in one run, from one directory, the
  router's log was written and the gate's was not. **What ports is what the model can call. What does
  not port is what the runtime must call.**


## §5 validation table — §4 step 13

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-27. Every gate clause of `#b10`, one row
each, plus the two registered predictions and the delivery/independence rows §5 requires. **Evidence
is a path or an id, never a sentence.** The **layer column is about the proof, not the artifact** —
where the only proof is that I say so, the row reads **L3** and says what would make it L2. Every
command in the last column was re-run immediately before this table was written; the outputs are in
the commit that carries it.*

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| *≥3 runs per runtime* — codex | `evidence/b10/batch-20260927T125809Z/manifest.tsv`, 20 rows, `n = 5` per arm per task, interleaved control-then-treated; 0 rows `VOID-0a` | **L2** — the manifest is appended by the driver per finished cell, not typed | `awk -F'\t' '$1 ~ /^BE-/ {print $1,$2,$3,$4}' evidence/b10/batch-20260927T125809Z/manifest.tsv \| wc -l` → `20`; `awk -F'\t' '$14=="VOID-0a"' …` → empty |
| *≥3 runs per runtime* — claude | **cited, not re-run**: stop 20, `experiments/E-022-*.md` / `E-023-*.md`, `n = 10` per arm per task | **L2** for the runs existing, **L3** for "same benchmark sha and evaluator" being sufficient to cite them | open either experiment's `## Runs`; compare `runtime.model` and the benchmarks sha in stop 20's manifest against this one's manifest header |
| *compare quality* — **within codex** | `evidence/b10/batch-20260927T125809Z/codex-sheets.tsv` → 20 sheets under `findings/codex/`, rubric shas **`396e1799eb2b`** (BE-003) and **`6252778b8472`** (BE-004). `architecture-consistency`: BE-003 `2,2,2,2,2` vs `2,2,2,2,2`; BE-004 `2,2,2,2,2` vs `1,1,2,2,2` | **L2** — 20 sheets on disk, each with exactly four `score:` lines | `tail -n +2 codex-sheets.tsv \| while IFS=$'\t' read -r t s a r x sh; do awk '/category:/{c=$3} /score:/{print c"="$2}' "$sh"; done` — re-derived in the orchestrator's own context, not only by a subagent |
| *compare quality* — **across runtimes** | **REFUSED, with three independent reasons on record**: `agent-observatory#47` `state: open` (API, 2026-09-27); the model moves with the adapter (`runtime.model` `gpt-5.6-sol` vs `claude-haiku-4-5-20251001` — two variables); HANDOFF seventh session | **L3** — a refusal is a decision, and nothing executes to enforce it | `gh api repos/UnityInFlow/agent-observatory/issues/47 --jq .state` → `open`; `jq -r .runtime.model` on one run of each stop |
| *compare correction effort* | **NOT MEASURABLE**: `modelCalls` and `toolCalls` `null` on **20 of 20**; `changedFiles` reported instead (BE-003 median 3→2, BE-004 7→7) and explicitly not a correction-effort measure | **L2** — the nulls are read from 20 records | `awk -F'\t' '$1 ~ /^BE-/ {print $18,$19}' manifest.tsv \| sort \| uniq -c` → `20 null null` |
| *compare usage* | `reportedTotalTokens` non-null **20 of 20**; medians BE-003 **25 840 → 34 736**, BE-004 **29 624 → 33 349** | **L2** | `awk -F'\t' '$1=="BE-003" && $3=="control" {print $21}' manifest.tsv \| sort -n` (and the three other arm/task pairs) |
| *compare **observability capability*** | Prediction 5, registered before the batch: `estimatedCost` / `modelCalls` / `toolCalls` **null on 20 of 20**; `reportedTotalTokens` **non-null on 20 of 20** against a predicted ≥ 8 of 10 | **L2** — 20 records | `awk -F'\t' '$1 ~ /^BE-/ {print $20}' manifest.tsv \| sort \| uniq -c` → `20 null` |
| *document each provider's limitations* — the three refusals that execute | `evidence/b10/census-port-20260927.txt`, exit 0. Probe 2 → `run-agent.sh:406` exit 1; probe 3 → `:325` exit 1; probe 4 → `:522` exit 1 | **L2** — three real `--check-customization` invocations, each returning 1 | `./evidence/b10/census-port.sh` and read the transcript's per-probe exit codes |
| *document each provider's limitations* — the one that is **silent** | census probe 5 **exit 0** with the file tracked; **then DF1**, run **`18eac7c0-971f-496d-8868-8799d4fec2b5`**, `evidence/b10/df-20260927T163230Z/RESULT.md` + addendum | **L2 for `policy-gate.sh`** — a hook proved to execute, committed `100755` into setup commit `9652494fa571`, non-empty trigger population, **0 log lines**. **L3 for `repair-limit.sh` and `repair-record.sh`** — same wiring file, **not separately observed** | `git -C <worktree> ls-tree -r 9652494fa571 \| grep -E '\.claude/\|policy-gate'` → `.claude/settings.json` and `100755 … policy-gate.sh`; then `comm -13 sweep-before.tsv sweep-after.tsv` → empty; then invoke the gate from the worktree → exit 2 and one `deny` line. **To make the other two L2, wire each to write its own log and re-run DF1** |
| *document each provider's limitations* — codex subagents have no `tools` field | `## Extract` fact 5, from the codex docs | **L3** — read from documentation; nothing in this repository executes it | open the cited doc; there is no fixture and there should not be one until a run needs it |
| *pick primary and fallback* | **primary `claude`, fallback `codex`**, decided on observability and enforcement and explicitly not on quality — `## Exit gate` clause 4, with the two tables it cites | **L3** — a judgement, and it is labelled L3 rather than dressed up | read clause 4; the two inputs (the observability table and the limitations table) are each **L2** and the choice made from them is not |
| **Prediction 1** — *files that port unchanged: 8 of 11* | `evidence/b10/census-port-20260927.txt`; `diff -r` over `.ai` **empty**; `CLAUDE.md`→`AGENTS.md` same bytes at a different path | **L2** — the runner's refusals execute and the diff is a command | `diff -r build/customizations/agent-v1.2-knowledge/.ai build/customizations/agent-v1.2-knowledge-codex/.ai` → no output; `find … -type f \| wc -l` on both trees |
| **Prediction 2** — *measured L2 controls that survive: 0 of 2* | named-agent half: census probes 3 and 4. Policy-gate half: **DF1**, as the row above | **L2 on both halves** — this is what DF1 converted; it was **L3** on the second half until 2026-09-27 | the two commands in the two rows above, run in either order |
| **Prediction 3** — *both hashes set on 5 of 5 treated, null on 5 of 5 controls* — *registered as most likely to be wrong* | manifest columns 9–13: `sha256:ebf489800a60a156986f98ea4f127848` and `sha256:0770219ae7f4281a80071d78dadea285` on **10 of 10** treated, **exact values not merely non-null**; all five null on **10 of 10** controls | **L2** — read back from the API record per run, not inferred from the flag | `awk -F'\t' '$1 ~ /^BE-/ {print $3,$9,$10}' manifest.tsv`; and re-derive a digest by hand: `shasum -a 256 <overlay>/AGENTS.md \| cut -c1-32` |
| **Prediction 4** — *corpus contact ≤ 1 of 5 on the treated arm* | **REFUTED at 5 of 5 per task, 10 of 10 treated, 0 of 10 control.** Ten one-line router logs at `evidence/b10/batch-20260927T125809Z/router-logs/`, each a `hit` with the task's own query | **L2** — the router writes its own log; H counts router invocations and is a **floor**, because a run that reads `index.yaml` by hand raises no counter | `wc -l evidence/b10/batch-20260927T125809Z/router-logs/*.jsonl` → ten files, one line each; `awk -F'\t' '$17=="router"' manifest.tsv \| wc -l` → `10` |
| **Prediction 7 (E-025)** — *BE-004's evaluator pass rate falls below 5 of 5* | **REFUTED**: `exitCode 0` on **20 of 20**, both arms, both tasks | **L2** — the evaluator's own exit code per run | `awk -F'\t' '$1 ~ /^BE-/ {print $6}' manifest.tsv \| sort \| uniq -c` → `20 0` |
| **DF1 — the deliberate failure** | prediction commit **`540027895084ffaef88d5ef3d3ec522709323f0c`** at **`2026-09-27T16:28:09Z`**; run `startedAt` **`2026-09-27T16:32:31Z`**; driver `evidence/b10/run-b10-df.sh`; fixtures **22 of 22** | **L2** — including **case L**, which plants a `policy-events` log, grows it and writes another, and requires the sweep to report `2`. **A negative observation whose detector was never shown to fire is not evidence, and that is the case that closes it** | `git log 5400278 -1 --format=%cI`; `jq -r .startedAt evidence/b10/df-20260927T163230Z/run-record.json`; `./evidence/b10/verify-b10-df-guards.sh` |
| **DF1 — DF-P4's second clause** | **REFUTED**, by `hooksHash` existing and being `null`. `jq -c '.customization\|keys'` → **7** keys on every record | **L2** — the key list is read from the record | `jq -r '.customization\|keys\|join(",")'` on any run of this batch → includes `hooksHash`. The correction is under `## Deliberate failure`; the prediction and the result table are **not edited** (§4 step 12) |
| **§4a review, round 1** | three artefacts, **41 findings**, `-P codex`, `-n 2` each, files at `findings/opencode/review-{README,run-b10-df,E-024-second-runtime-adapter-BE003}-20260927T16*.md`. Dispositions in `## §4a review — round 1` | **L2** for the line-level panel (**codex ok / codex ok** on all three, 30–64 s). **L3 — there is NO acceptance verdict**: the gate returned `opencode exit 1` on all three because `lab-acceptance` is on the stalled provider, and that is recorded as *did not run*, not as `UNDECIDED` and not as a pass | open the three findings files; `grep -c '^### '` → 29, 15, 46; `grep -A2 '^## Acceptance'` → *"The gate failed to run (opencode exit 1)"* on each |
| **the DF driver after review** | `evidence/b10/verify-b10-df-guards.sh` → **`36 passed, 0 failed`**, up from 22 cases. Six new cases (**M–R**) each **failed against the pre-review driver** `02a2147479fcbe06` before passing | **L2** — the fixtures execute, and case **R** proves the settling sweep catches what the immediate sweep misses | `./evidence/b10/verify-b10-df-guards.sh`; then `git stash` the driver to `02a2147479fcbe06` and watch M–R fail |
| **§5: one scored cell re-read by hand, off the kept worktree, before any sheet was opened** | `evidence/b10/hand-reread/RESULT.md`, committed in **`e34d4cd` at `2026-09-27T17:53:30+02:00`**, which is **3 minutes before the first sheet was written** (`…-20260927T155628Z.yaml`, i.e. `17:56:28+02:00`) — the ordering is a git fact plus a filename, and it is stated that way rather than as "before the driver was committed", because the hand re-read and the driver share one commit. Two cells, both `architecture-consistency` — the **registered primary outcome**, not a convenient cell: run `4df04e27` → hand **2**, sheet **2**; run `05611c81` → hand **2**, sheet **2** | **L2** — the worktree and the rubric at its registered sha; and the subagent's reading was **re-derived in the orchestrator's own context** and agreed | `git log --format=%H -1 -- evidence/b10/hand-reread/RESULT.md` vs the score driver's commit; then re-walk the anchors against the worktree named in the file |
| **§5: independence check — what else changed between arms** | Same benchmark sha (manifest header), same evaluator, `runtime.model` `gpt-5.6-sol` on **20 of 20**, `runtime.version` `codex-cli 0.154.0` on 20 of 20, `userSettingsIsolated: true`, rubric shas unmoved at `396e1799eb2b` / `6252778b8472`. **The only difference between arms is the overlay**, and it is read back per run as an exact digest | **L2** — read from the records and the manifest, **not from the flags** | `awk -F'\t' '$1 ~ /^BE-/ {print $7,$8}' manifest.tsv \| sort \| uniq -c`; `shasum -a 256 benchmark/rubrics/backend-quality*.yaml \| cut -c1-12` |
| **§5: isolation observed rather than inferred** | `evidence/b10/iso-probe/`, **3 of 3** `ok: ALL THREE checks hold for codex-cli 0.154.0`, exit 0, every positive control firing first | **L2** at `n = 3` — and recorded as **resolved-at-`n`-observed, not as a fix**: an isolation probe asks a live model to go looking, and a model that did not look is not a model that could not. The earlier single `LEAKS` report is **UNREPRODUCED, not refuted**, because its output was never kept | `./evidence/b10/probe-codex-isolation.sh` and read the three transcripts |
| **§5: the second reader** | **DEFERRED, and it is the one hole in this stop.** `opencode-score.sh` / `ollama-cloud` has stalled on its weekly limit for **six consecutive sessions**; the newest artefact is `findings/opencode/review-run-record-20260927T161910Z.md` at **903 bytes with 0 `### ` sections** — a stall, kept as evidence per §6, **not** a clean review | **L3 — there is no second reading, so the 20 registered sheets are one harness unchecked**, and `change-focus` is the cell that most needs it: it moved `1 → 0` on 5 of 5 on BE-004 and is the instrument's noisiest dimension at 18 of 34 concordance (decision 10.2) | `wc -c findings/opencode/review-run-record-20260927T161910Z.md` → `903`; `grep -c '^### '` → `0` |

### What this table does **not** close, stated here rather than left for a validator to find

1. **The second reader does not exist for this batch.** Twenty registered sheets, one harness. Row 15
   says so and the exit gate does not lean on any single-cell reading.
2. **`repair-limit.sh` and `repair-record.sh` are L3.** DF1 observed one of the three hooks. The other
   two share the wiring file DF1 proved is read by nothing, which is a strong inference and is still an
   inference. The fix is named in the row: give each its own log and re-run DF1.
3. **`test-quality` anchor 2 and the control-arm rubric census.** No control-arm census was taken
   before choosing the registered outcome. **18 seconds of codex would have shown the ceiling** and
   the batch would have registered `maintainability` instead. That is in `author_notes` as the single
   cheapest instrument this track is still missing.
4. **The claude arms are cited, not re-run.** If stop 20's manifest were wrong about its model or its
   benchmark sha, clause 1's claude half would fall with it. The row says what to compare.

## §4a review — round 1, and what it changed · §4 step 13a

*Run and dispositioned by Opus 5 (claude-opus-5), autonomously, 2026-09-27. **Routed to `-P codex`**,
because §0a row 2 has stalled on the `ollama-cloud` weekly limit for **six consecutive sessions** and
row 3b proved codex live. `-n 2` per artefact, three artefacts.*

| artefact | findings file | bytes | `### ` sections | line-level panel | acceptance gate |
|---|---|---|---|---|---|
| this workbook | `findings/opencode/review-README-20260927T164606Z.md` | 17 695 | 29 | **codex ok / codex ok**, 55 s + 64 s | **DID NOT RUN** |
| `evidence/b10/run-b10-df.sh` | `findings/opencode/review-run-b10-df-20260927T164939Z.md` | 9 293 | 15 | **codex ok / codex ok**, 42 s + 30 s | **DID NOT RUN** |
| `experiments/E-024-…-BE003.md` | `findings/opencode/review-E-024-second-runtime-adapter-BE003-20260927T165223Z.md` | 25 035 | 46 | **codex ok / codex ok** | **DID NOT RUN** |

**41 findings. The acceptance gate did not run on any of the three**, and that is recorded as *did
not run* rather than as `UNDECIDED` or as a pass: `opencode exit 1` on all three, because
`lab-acceptance` lives on the same `ollama-cloud` provider that has stalled for six sessions. §4a's
stopping rule is *"`ACCEPT`, or every remaining line-level finding disputed and the gate's own
objection answered"* — **there is no gate objection to answer, because there is no gate**. So the
line-level findings are dispositioned one by one below and the stop is closed with **no acceptance
verdict on record**. `E-025` was **not sent**; §4a caps invocations at four artefacts and its text is
E-024's with the task swapped, so its findings are taken to be E-024's and the omission is named here
as §4a requires.

### The two findings that changed a stated result

| # | finding | recurrence | disposition |
|---|---|---|---|
| **1** | *"DF-P4's own refutation rule is met by a null `hooksHash`, yet the artifact still marks it HELD"* — raised on this workbook **and** independently on E-024 | **2/2 on both** | **ACCEPTED, and it is the most important line in this review.** DF-P4 is now recorded **REFUTED on its second clause**; *"all four predictions held"* is corrected everywhere. See the additive correction under `## Deliberate failure`. I found the `hooksHash` fact myself and failed to trace it back to a live prediction two commits later; a second model family saw it and I did not |
| **2** | *"Prediction 5 is marked HELD without checking its own registered `inputTokens`/`outputTokens` condition; the telemetry section reports `toolCalls`/`permissionDenials`/`retries` instead"* | **2/2** | **ACCEPTED as a gap in the evidence, and now CLOSED BY MEASUREMENT.** The reviewer was right that two of P5's four registered fields were never checked. Checked now, across all 20 batch runs: `efficiency.inputTokens` and `efficiency.outputTokens` **exist and are `null` on 20 of 20** (`jq -r '[(.efficiency.inputTokens // "ABSENT-OR-NULL"),(.efficiency.outputTokens // "ABSENT-OR-NULL")]\|@tsv'` → `20  ABSENT-OR-NULL ABSENT-OR-NULL`). **P5's verdict stands, and it stands on evidence that did not exist when it was written** |

### The six findings on the DF driver — all six accepted, all six fixed, and all six closed against DF1 itself

The driver that produced DF1 is sha **`02a2147479fcbe06`**. Every finding is fixed in the version this
PR carries, and **every one is separately closed against DF1's own run by evidence rather than by
argument** — because a fix does not retroactively validate a measurement taken without it.

| # | finding | fix | why it could not have affected DF1 |
|---|---|---|---|
| **4** | the pid lock was **checked-then-written**, so two copies could both pass `[[ -e ]]` and both spend a run | atomic `( set -o noclobber; echo $$ > "$LOCK" )`, and a stale lock is **removed and re-raced** rather than overwritten | **exactly one** DF ever ran: one `df-*` directory (`find -maxdepth 1 -type d`), and **one** run under `EXP-B10-DF-BE003` in the API |
| **5** | `.claude/settings.json` was checked for **existence, not identity** — so swapping the treatment left all three digests unchanged | its sha is now **registered** (`925a3823…`) and mismatch is exit 5. **This was the sharpest finding**: the driver hashed the two portable files and merely stat-ed the one file the DF is about | the setup commit's copy was verified **by sha** afterwards: `git show 9652494fa571:.claude/settings.json \| shasum -a 256` → `925a3823…`, equal to v1.2's. Verified post hoc, which **is** the gap — now closed prospectively |
| **6** | a filename containing a newline made `ls -1` emit **two records**, corrupting the diff DF-P2 rests on | the sweep is **null-delimited** (`find -print0` / `sort -z` / `read -d ''`), and an unrepresentable path is **flagged**, not normalised | both sweeps were **empty** (`wc -l` → 0 and 0), so no filename existed to misparse |
| **7** | the driver could **exit 0 after a non-zero runner rc**, and DF-P1 *is* "the runner did not refuse" | new **exit 10**: RESULT.md is written and marked, withholding **both** DF-P1 and DF-P2 — the latter because an incomplete run has an unknown trigger population | runner `rc = 0` |
| **8** | a hook **child** appending just after `run-agent.sh` exits would be a false negative | a **settling sweep** after `B10_DF_SETTLE` seconds (default 20); both the immediate and the settled observation are reported | a **late re-sweep ~30 minutes after the run** found **0** logs and **0** new-or-grown, kept as `sweep-late.tsv` in the DF directory |
| **9** | unchecked `curl`/`jq` on a timeout or an HTML 502 still wrote RESULT.md and exited 0 | new **exit 11**, and the record must parse **and** carry `runId`, `evaluation`, `customization` | `run-record.json` is valid JSON with `evaluation.exitCode`, `customization.instructionsHash` and three `changedFiles` all populated |
| **10** | *"no runner return code or API-response condition is defined as valid"* (cross-cutting) | answered by **exits 10 and 11 together**: the two conditions are now named, enforced, and each has a fixture | subsumed by 7 and 9 above |

**The fixture set went from 22 cases to 36, and every one of the six new cases FAILED against
`02a2147479fcbe06` before it passed.** Cases **M** (wrong `settings.json` sha → 5), **N** (runner rc
→ 10, withholding both claims), **O** (unreadable record → 11, reporting **no** DF-P4 field), **P** (a
newline in a log filename → **one** flagged record, not two), **Q** (`noclobber` refuses a second
create and the first writer's pid survives), **R** (a child that appends 2 s late: **the immediate
sweep misses it and the settling sweep catches it**), plus **S**, a stub API so the happy path has a
record it can actually read. `./evidence/b10/verify-b10-df-guards.sh` → **`36 passed, 0 failed`**.

### Two defects found *while fixing* the review's findings, and both are the house failure mode

Neither was in the review. Both were found because a fixture that had been passing started failing
once it was pointed at what it claimed to be pointing at.

1. **The fixture set was never testing the closed port its own comment described.** Cases I, K and L
   passed `API=http://127.0.0.1:1`, and `run-b10-df.sh:86` does `export API="${B10_API:-…8081}"` —
   **an incoming `API=` is overwritten.** So those cases were hitting the **live stack at 8081** and
   looking up a stub uuid that does not exist there. They passed, for the wrong reason, under a
   comment claiming *"API is pointed at a closed port … deliberate"*. **A control reporting success
   over a scope smaller than it claims**, in the fixture set written to prevent exactly that.
2. **`jq -e` on empty input exits 0.** `printf '' | jq -e '.runId != null'` → **exit 0**: jq emits
   nothing and succeeds. So exit 11's guard, *written as the fix for finding 9*, passed when the API
   returned absolutely nothing — **the fix reproduced the defect it was fixing**, and it was only
   visible after defect 1 above was repaired. The guard now tests emptiness first. This is why
   `verify-*.sh` is described in §4a as *"the review that executes"*: the codex reviewer read the fix
   and could not have seen this; a fixture could.

### Findings accepted as limitations, recorded and not fixed here

| # | finding | recurrence | why it is recorded rather than fixed |
|---|---|---|---|
| **11** | *"decision-rule rows 2/3 (IMPROVED) and row 4 (NOT DETECTABLE) both fire on an exact one-point median difference; ordering alone breaks the tie"* — the only **L1** finding in the batch | **2/2** | **ACCEPTED as a real defect in the decision rule, and the rule is a registered variable** — §6 makes editing it mid-experiment a halt, and the batch is scored. **It did not bite here**: both tasks' median differences are **0**, not 1, so no tie arose and no verdict depends on row ordering. Named in `author_notes` as a fix for the next decision rule written in this track |
| **13, 14** | *"an intermittent isolation leak need not hit both arms equally; an imbalanced realisation can manufacture an uncontrolled difference"* | **2/2, twice** | **ACCEPTED, and it is a better statement of the limitation than the one already in the file.** The isolation section says the earlier single `LEAKS` report is *unreproduced, not refuted*; the reviewer's point is sharper — `n = 3` clean probes bound the **rate**, not the **balance**. Recorded as a limitation of the isolation evidence. Nothing available at this stop distinguishes them; a per-run isolation assertion would, and is an instrument nobody has built |
| **16** | *"the void rule covers only treated delivery failures; there is no handling for a contaminated control run with a non-null hash"* | **1/2** | **ACCEPTED as a genuine gap in row 0a's wording.** It did not bite: all **10** controls came back with **all five hashes `null`**, read from the records. A row 0a that is silent about the control arm is still an incomplete rule and is named for the next one |
| **3** | *"the independence claim is undercut by codex seeding six skills"* | **2/2** | **PARTIALLY DISPUTED, with the reason.** The seeded skills are present on **both** arms — same runtime, same binary, same flags, verified as `runtime.version codex-cli 0.154.0` on 20 of 20 — so they cannot manufacture a **between-arm** difference, which is what the independence check is for. The finding is right that they are an **uncontrolled feature of the runtime**, and that is already why no cross-runtime claim appears anywhere in this stop. Recorded, not fixed |

### Findings about the file count — accepted, and corrected additively in three more places

Findings **1** and **12**: the arms table still said *"the 8-file port"* and the delivery mechanism row
still totalled *"`AGENTS.md` + `.ai/**` (7 files)"* while the digest row and the §4-step-4 correction
say **nine**. All three now carry the count additively. **No prediction moves** — prediction 1 is
*8 of 11 port **unchanged***, and the ported directory is 9 files of which 8 are unchanged copies and
1 is a rename, which is what the census measured. **The reviewer found the third and fourth copies of
a slip the stop had already corrected twice**, which is an argument for the count being derived rather
than retyped.

### The 22 findings not listed

The review's own *"Layer of the implied fix"* marks them **L3** — ambiguity and guidance, no
mechanism-level failure scenario. Eleven on the workbook, eleven on E-024. §4a says a finding at 1/2
recurrence is still a finding, so they are **not dismissed**; they are not individually dispositioned
here, the findings files are committed in full, and the three paths are named in the PR body. A
stranger re-derives every one of them by opening those files.

## Commit — §4 step 14, 2026-09-27

| what | where |
|---|---|
| version | **v1.2, the codex port. KEPT, NOT PROMOTED.** `build/customizations/agent-v1.2-knowledge-codex/` — nine files, unedited from here on (§3: a measured version is never edited) |
| experiments | [`E-024`](../../experiments/E-024-second-runtime-adapter-BE003.md) `EXP-B10-RUNTIME-PORT-BE003` · [`E-025`](../../experiments/E-025-second-runtime-adapter-BE004.md) `EXP-B10-RUNTIME-PORT-BE004` |
| verdict | **`NOT DETECTABLE AT THIS n`** on both tasks — decision-rule **row 4** on each. `architecture-consistency` medians **2 vs 2**, exact Mann-Whitney **`p = 1.0000`** (BE-003) and **`0.4444`** (BE-004), `n = 5` per arm per task. Row 0a does not fire (0 void of 20); row 1 does not fire (`H = 10`, not 0) |
| **why the verdict is not the finding** | **the registered primary outcome was at its ceiling in the control on 5 of 5 on BOTH tasks.** `architecture-consistency` is 0–2 and the control scored 2 every time, so an improvement was arithmetically impossible before the first treated run started. The only direction open was down, and two BE-004 treated runs went there |
| census (predictions 1 and 2) | **8 of 11 files port unchanged; 0 of 2 measured L2 controls survive.** Both as predicted. `evidence/b10/census-port-20260927.txt`, five real `--check-customization` probes, exit 0 |
| deliberate failure | **DF1**, `EXP-B10-DF-BE003`, run `18eac7c0-971f-496d-8868-8799d4fec2b5`, `n = 1` + two direct hook invocations. **All four predictions held**, and it **converted prediction 2's second half from L3 to L2**: the policy gate committed `100755` into the run's own baseline, a non-empty trigger population, **0 hook executions**, and the same gate firing on demand before and after. `evidence/b10/df-20260927T163230Z/RESULT.md` |
| disposition (§4 step 10) | four decisions: the port **KEPT unedited**; **no keep/remove decision on the knowledge corpus**, because an outcome with no headroom is not a measured no-effect; `.claude/settings.json` **REMOVED** from every codex overlay with the no-effect now measured; the three `.ai/hooks/*.sh` **kept under protest and named as inert** |
| predictions refuted | **BE-003 one of six** (P4, corpus contact); **BE-004 two of seven** (P4, and P7 the evaluator pass rate). **Both refutations outweigh the ten holds.** P4 predicted ≤ 1 of 5 and measured **5 of 5 on each task, 10 of 10 treated, 0 of 10 control** — stop 20's 3-of-20 on claude was the wrong reference class. P7's refutation makes BE-004's perfect evaluator record **a property of the task, not of the pinned model** |
| prediction registered as most likely wrong | **P3 HELD** — all ten treated records carry the **exact** registered digests, not merely non-null, and all ten controls carry all five hashes `null` |
| primary / fallback | **primary `claude`, fallback `codex`** — on observability and enforcement, explicitly not on quality |
| scoring | **20 of 20 codex sheets, four `score:` lines each, first attempt, zero stalls**, 400 s for the whole pass (median 18 s/sheet). One null cell, bounded: `efd94f24` `maintainability`, the scorer's own ambiguity hatch naming 0 vs 1 — **both below the treated arm's 2, so no direction depends on it** |
| instruments added with this stop | `evidence/b10/census-port.sh` (5 probes) · `evidence/b10/probe-codex-isolation.sh` (3 of 3 at `n = 3`) · `evidence/b10/run-b10-df.sh` + `verify-b10-df-guards.sh` (**22 of 22**, including case L, which proves the sweep detector fires) |
| additive corrections made inside this stop | the overlay is **nine** files not eight (§4 step 4) · **the customization block has seven fields and `hooksHash` is one of them**, the census's "five fields" sentence being wrong and the correct version already on record as the stop-16 author note (§4 step 9) |
| still owed, and named rather than buried | the **second reader** — six consecutive stalls, so 20 registered sheets are one harness unchecked, and `change-focus` most needs it · a **control-arm rubric census before choosing an outcome**, which 18 s of codex would have bought · own logs for `repair-limit.sh` / `repair-record.sh` so their inertness becomes L2 · `maintainability` as the registered outcome for any later codex stop |
| boards | **NOT republished** — the author's, by decision 12 item 4. The board CI check is RED and the red is expected |

