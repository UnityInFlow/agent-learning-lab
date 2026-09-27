# B10 — Port the adapter to a second runtime

**Track A first:** [Phase 4A](../04a-agents-permissions/)
**Version:** **v1.2**
**Spine position:** 21 of 28 · after [B9](../b09-knowledge-router/) · before [Phase 7](../07-plugins/)
**Status:** 🟨 OPEN at spine stop 21 — §4 step 3 (prediction commit), branch `stop21/b10-second-runtime-adapter`, 2026-09-27

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
| codex-treated | `codex` | `gpt-5.6-sol` | the 8-file port | 5 per task | **new, this stop** |
| codex-control | `codex` | `gpt-5.6-sol` | none | 5 per task | **new, this stop**, interleaved |
| claude-treated | `claude` | `claude-haiku-4-5-20251001` | `agent-v1.2-knowledge` (11 files) | 10 per task | **cited** — stop 20, E-022 / E-023 |
| claude-control | `claude` | `claude-haiku-4-5-20251001` | none | 10 per task | **cited** — stop 20, E-022 / E-023 |

The claude rows are cited and **not re-run**: same benchmark sha, same evaluator, same model,
same overlay, closed eight hours before this stop opened. Re-running them would spend money to
produce a second copy of an existing measurement, and §6 protects evidence rather than volume.
That satisfies the gate's *"≥3 runs per runtime"* on the claude side with `n = 10` per arm per
task.

**The two runtimes do not carry the same overlay and no effect is compared across them.** The
claude arms carry 11 files, the codex arms carry 8. That difference *is* the port, and it is why
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

## Exit gate

**From the build track:** ≥3 runs per runtime · compare quality, correction effort, usage **and
observability capability** · document each provider's limitations · pick primary and fallback.

**Plus, for this to count as a learned phase:**

<!-- TODO: was "portable core, thin adapters" true? -->

## Commit

<!-- TODO -->
