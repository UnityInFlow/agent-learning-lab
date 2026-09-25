# B8a — Decomposition depth

**Spine position 17a.** Inserted after B8 (stop 17) and before Phase 6A, so no stop number moves and
no document citing "stop 21" goes stale. Registered by **author decision 11** (prompt §3), adopted
2026-09-14, with its three opening conditions **discharged 2026-09-25**. **Version-neutral** — it is
measured against **v1.1 as it closed at B8**, its overlay is a candidate configuration and not a
version, and the spine's v1.2 stays at B11.

| | |
|---|---|
| Task | **BE-005 (`BE-005-partial-fulfilment`, ticket A′) ONLY** — decision 11 item 5, which amends decision 9 item 2 for this step alone |
| Rung | **4** — one orchestrator + three specialists, as a ladder with a stop rule (item 2) |
| Model | `claude-haiku-4-5-20251001` for **all four agents**, claude runtime. The bundles' `claude-opus-4-6` is not a knob |
| Registered rubric | `benchmark/rubrics/backend-quality-be005.yaml`, version `2-be005`, sha **`945817b8c509`** |
| Registered outcome | **`architecture-consistency`**, codex, on that sha — author decision 2026-09-25 item 1 |
| `change-focus` | ***UNMEASURED.*** Reads nothing: no decision-rule row, no MDE, no exit-gate answer |
| Reference population | **BE-005's own concurrent plain control at this stop, `n = 10`** — which IS BE-005's baseline measurement and is registered as such before it runs |
| Cost ceiling | **$9.70** = 25 × $0.388, ticket A′'s median plain-run cost (decision 11 item 11, median corrected by author decision 2026-09-25 item 3) |
| Promotion | **Only** by B13's seven clauses (item 6). Expected verdict: *measured, kept, not promoted* |
| Experiment key | `E-020-decomposition-depth-BE005` |
| Branch | `stop17a/b8a-decomposition-depth`, off `main` at `d4faa7e` |
| PR | **lab#117** — opened while the stop was halted, retitled when the halt was discharged |

*Opened at spine stop 17a by Opus 5 (claude-opus-5), autonomously, 2026-09-24; §4 step 1 written
2026-09-25 after the author discharged the §7 halt at the pre-step-1 rubric proof.*

## Goal

**Measure whether cutting one agent into a four-agent pipeline changes what the agent builds, on a
task where an early structural choice is punished by a later clause of the same ticket.**

The question is not "is multi-agent good". It is the one thing this instrument can see: **BE-005's
fork.** Gate B′ established that the pinned model reaches the **wrong shape on 4 of 5 plain runs** —
it filters and counts on a *stored* fulfilment value instead of recomputing it first. Cut B puts a
**planner** in front of the typing, whose only job is to write down, per read path, whether each
value is stored or computed. So the prediction is one sentence: *the planner meets the fork before
anything is typed, writes the shape into the handoff, and the treated arm reaches the derived shape
on more runs than the plain control.*

**What closing this stop means.** Not that the pipeline works. That the experiment's own decision
rule fired one of its rows from evidence — `VOID`, `NOT DETECTABLE`, `REJECT` or `IMPROVED` — and
that the rung-4 **ladder's stop rule** was applied: anything other than `IMPROVED` **closes the
ladder**, and *that closure is the result*. Rung 10 is not registered by decision 11 and may only be
proposed as a separate author decision if rung 4's own rule fires `IMPROVED`.

**The honest ceiling, written before any run.** The nearest rung is already measured and null: stop
11 ran one orchestrator plus one implementer against a single agent, `n = 20`, verdict
**`NOT DETECTABLE`** (E-007) — and decision 10.1's fourth cell then reattributed the one visible
effect to the implementer's **prose**, delivered with no split at all (E-008/E-009). A four-agent
proposal starts there, not at zero. The single clean positive in the whole track (B6, one skill,
10/10 vs 0/10 and 10/10 vs 3/10) chose its treatment from a failure the data already showed. This
step does the same thing — Gate B′'s 4-of-5 wrong shape is that failure — which is the only reason it
is worth the money.

## Required reading

### Internal — the design, which is the author's and not mine

| Source | What it fixes |
|---|---|
| **`B8A-BRAINSTORM.md`** (workspace root), Q1–Q8 | ***The cut. Read this first.*** Decided in working sessions with **the author present for every answer** — Q1–Q5 2026-09-16 (Fable 5.1), Q6–Q8 2026-09-21 (Opus 5). **Cut B, by phase**; orchestrator **route only**; the three `tools:` lists; the deliberate failure; **method-only** prose; four agent files and no skill; **one bounce** |
| `AUTHOR-DECISION-11-CONTINUE.md` (workspace root) | The standing instruction issued 2026-09-17 with the author present, which delegated acts (a)–(c) — port the rubric, prove it on codex, register the sha and record the adoption. **Carries two in-place corrections dated 2026-09-25** |
| Prompt `§3`, author decision 11, items 1–13 | Rung, spine position, task, version boundary, decision rule, the **four delivery conditions**, the budget, the three early-end conditions, and what is **explicitly not adopted** |
| Prompt `§3`, author decision 11 §*"When BE-005 gets designed, and by whom"* | Why no line of BE-005 is mine: *"never design BE-005 yourself — I do that with Fable"* |
| `TRACK-B-STATE.md` `author_decisions` item 12 | **The author's four decisions of 2026-09-25**, verbatim, which discharge the rubric-proof halt |

### Internal — the evidence this step is designed against

| Source | What it says |
|---|---|
| `evidence/gate-b2-decision-11/RESULT.md` | **Gate B′: WRONG 4 of 5**, all five rows author-confirmed. The medians this step's budget and MDE transfer from. The five deciding facts, one per run |
| `evidence/gate-b2-decision-11/RULE.md` | The shape-classification rule, committed **before** the runs: it counts the copy, not the writer |
| `evidence/b08a/rubric-proof/{PREDICTIONS.md,RESULT.md}` | 28 cells predicted before the first sheet; three dimensions separate, `change-focus` does not; the author's decision appended |
| `experiments/E-007-orchestration-overhead.md` | Rung 2, `n = 20`, **`NOT DETECTABLE`**. Its registered verdict is **not edited by anything this step finds**; a dated amendment carries any change |
| `experiments/E-008…`, `E-009…` (fourth cell) | The one E-007 effect reattributed to prose delivered **without** a split. The reason a null here is the expected outcome |
| `experiments/E-018…`, `E-019…` (B8, v1.1) | The baseline configuration. Both tasks landed decision-rule **row 3**, *kept as L2 with no measured effect* |
| `experiments/E-005-agent-tool-boundary.md` | **`tools:` filters names, not capabilities**, and the runtime **rewrites the list before the model sees it** — `Read, Grep, Glob, Bash` delivered as `["Read","Bash"]` on 10 of 10. Author decision 8's `init` read-back is mandatory because of this |
| `phases/b08-run-state-repair-limits/README.md` §*"Author decision 11 item 7"* | Where the `handoff` field was written, and that it was written **reserved** |
| `phases/04b-orchestration/README.md` | Rung 2's workbook — the primitive this step is the depth of |
| `GUARDRAILS.md`, workspace `CLAUDE.md` | The L1/L2/L3 rule, applied in order, stopping at the first yes |

### External — the technique

| Source | What it gives, and what it costs to believe |
|---|---|
| [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents) (`SOURCES.md` row 107) | 17 frontmatter fields, not 4. `tools` is an **allowlist that narrows**, `disallowedTools` a denylist — *not* a skill's pre-approving `allowed-tools`. `hooks`, `mcpServers` and `skills` are **per-subagent and are contamination channels**. Omitting `model` does **not** inherit the parent's |
| [Anthropic — Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) (row 191) | **15× tokens, +90.2 %** — and, in its own words, *"most coding tasks involve fewer truly parallelizable tasks than research."* Extracted at 4B. The 15× is why B13's 15 % token ceiling is the expected blocker |
| [Claude Code — Dynamic workflows](https://code.claude.com/docs/en/workflows) (row 193) | When orchestration should be deterministic code rather than a model decision — the argument against the thing this step measures |
| [Claude Code — Model configuration](https://code.claude.com/docs/en/model-config) (row 220) | A subagent is a **second place the model is chosen**, above which sits `CLAUDE_CODE_SUBAGENT_MODEL`. Four agents are four chances for the pinned model to be silently replaced |

**Nothing new is added to `SOURCES.md` at this step** — all four external rows already exist and are
already marked extracted, so `./tools/check-links.sh` has nothing new to check. Run it anyway before
the PR; a link that rotted since row 107 was written is a finding.

## Extract

Five things, each one established by opening the file named and not by inference. Together they say
what this step can prove, what it cannot, and which of its controls execute.

### 1. `agentHash` hashes exactly ONE file. A four-file overlay is three files no hash sees.

`agent-observatory/runner/run-agent.sh:609-611` and `:625-629`. `AGENT_FILE_REL` is set to
`.claude/agents/${AGENT_NAME}.md` — **the dispatched agent and nothing else** — and
`customization.agentHash` is `hash_of` that single path. Beside it, `skills_hash()` (`:616-624`)
hashes **the set**: every `SKILL.md` in the worktree, as one digest over the sorted `(path, content)`
pairs, *"sorted so the value does not depend on find order; path included so a renamed skill is a
difference rather than a collision."*

So the instrument already knows how to hash a set — it just does not do it for agents. **This is the
whole reason decision 11 item 9 spells out four delivery conditions and says "none a hash."** An
additive `agentsHash` over `.claude/agents/*.md`, written exactly as `skills_hash` is, is the
instrument PR item 9 calls *welcome*; it is the builder's merge under §4 step 14, and **the proof
does not depend on it**, because a schema field is not a control until a run record shows it written.

`hooksHash` and `mcpHash` exist in the API schema, are described in a runner comment as working, and
are **`null` on every run ever recorded** (stop 16 author note). Do not plan a proof on either.

### 2. The `handoff` field exists, and B8 wrote it **reserved** — so this step is the first thing to use it.

`build/customizations/agent-v1.1/CLAUDE.md:28` tells the agent the state file carries *"repair
counters, any blocks, and a `handoff` block"*, and `:32` says in terms: *"The `handoff` block is
**reserved and unused at this version**."* The hook agrees rather than the prose only:
`.ai/hooks/repair-limit.sh:71` — *"`handoff` is AUTHOR DECISION 11 ITEM 7 and is RESERVED FOR B8a —
nothing at this stop writes it"* — and `:90` emits the block.

Decision 11 item 7 is therefore **discharged at the right stop and in the right form**: the field was
written unconditionally at B8, before anyone knew whether B8a would run, which is the only way a
schema commitment means anything. **B8a is the first step that writes into it**, and that makes the
handoff an L1-shaped medium — the field is there or it is not — carrying an L3 payload, because
nothing executes on the *content* of `from`, `to`, `delivered`, `remains`.

### 3. The fork is one line of Kotlin, and Gate B′ names it five times out of five.

`evidence/gate-b2-decision-11/RESULT.md:15-19`. Four runs **WRONG**, evaluator exit 12, and each
deciding fact is the same mistake wearing a different method name: `findAllByFulfilment` /
`countByFulfilment` selecting on the stored field; `findByFulfilmentStatus` filtering
`it.fulfilment?.status`; `findByFulfilmentStatusPaginated` taking `total` from the stored value
*before* enrichment; `findAllPaged` → `findAll(status)` filtering the stored field. One run
**RIGHT**, exit 0: `findAll().map { withFulfilment(...) }` **first**, then filtering the recomputed
value, *"repository has no fulfilment filter."*

**The whole difference between a pass and a fail on this ticket is `map` before `filter`.** That is
what makes it a usable fork: it is a single early decision, it is cheap under the right shape and
needs a rewrite under the wrong one, and a deterministic gate executes on it. It is also why the
planner's method text (Q6 option A) is *"per read path, whether the value is stored or computed and
where it is computed"* and says **nothing** about fulfilment, filters, amendments or this ticket — a
RIGHT reached from a generic method says something about pipelines; a RIGHT reached from a hint says
only that Haiku follows instructions.

### 4. "One bounce" is L3, and the hook that looks like it enforces it counts something else.

Q8 amends Q2: a verifier that reports an untested table row or a failing test bounces back to the
implementer **once**. So a clean run has **three** delegation events and a bounced run **five**; the
delivery proof asserts *3 or 5 and nothing else*, and **4, or 6 and up, is a finding**.

But nothing executes on that. B8's repair limit
(`build/customizations/agent-v1.1/.ai/hooks/repair-limit.sh`, fixtures `tools/verify-repair-limit.sh`,
in CI) counts **one agent's repair attempts per failure fingerprint**. It does not count
delegations, so it cannot stop a second bounce. **"Once" is a sentence in the orchestrator's body:
L3.** Making it L2 needs a new hook on the orchestrator's `Task` calls that refuses a third
implementer delegation, with its own fixture set proving it refuses.

Q8's own text records that its **first draft said the repair limit enforced this, and it does not** —
caught in the same session. That is the house failure mode by name: a control believed to cover a
scope it never covered. **This workbook labels the bounce limit L3 at §4 step 2 and does not claim
otherwise**; the hook is the builder's to propose and the author's to accept.

### 5. Two version strings for one evaluator, and the one that executes is 1.0.0.

On `agent-observatory-benchmarks` `origin/main`:
`tasks/BE-005-partial-fulfilment/evaluator.sh:58` sets `EVALUATOR_VERSION="1.0.0"` and emits it into
every run record (`:453`, `:480`), while `benchmark.yaml:10` **declares** `evaluator_version: 1.1.0`.

**The version of record for B8a is `1.0.0`**, because that is the string a run record will carry and
the one §5's independence check compares across arms. The declaration beside it **does not execute** —
nothing reads it and rejects a mismatch — so by the layer rule it is **L3 and cannot be the version
of record**. `AUTHOR-DECISION-11-CONTINUE.md` took the declaration; it is corrected in place there
with a dated note. The benchmarks-side repair is the author's (§7: the benchmark and evaluator are
theirs) and is in `author_notes`; **neither file was touched.**

### What this stop takes forward

1. **Delivery is proved by four conditions, not by a hash** (extract 1), and the optional
   `agentsHash` instrument is additive, welcome, and not load-bearing.
2. **The handoff medium exists and is empty** (extract 2) — B8a is its first writer, L1 field with an
   L3 payload.
3. **The registered outcome is `architecture-consistency`** and the trap is `map`-before-`filter`
   (extract 3), which is the defect `good-stored-consistent`'s anchor-0 cell proved that anchor can
   see — and the one variant whose defect **every deterministic gate passes**.
4. **Three of the four `tools:` lists are the executed part of the treatment**, and E-005 says the
   runtime rewrites them, so **author decision 8's `init` read-back is mandatory per arm** before any
   batch — a `tools:` file is not the treatment until the `init` record says so.
5. **Two of the design's own promises are L3**: the bounce limit (extract 4) and the method prose.
   They are labelled L3 at §4 step 2. A null at this step therefore cannot distinguish *"the split
   returned nothing"* from *"the prose was not followed"* — the same confound E-008/E-009 had to run a
   fourth cell to resolve at rung 2, and it is stated here **before** the run rather than discovered
   after it.

## Design — spine stop 17a, 2026-09-25

**None of the design choices below are mine.** Q1–Q8 of `B8A-BRAINSTORM.md` were decided in working
sessions **with the author present for every answer** (Q1–Q5 2026-09-16, Q6–Q8 2026-09-21), and
decision 11 fixed the rung, the task, the version boundary, the delivery proof and the budget before
that. What *is* mine, and what this section is for: **the layer label on every artifact**, the trap
this step claims to convert, and the honest statement of what a null here can and cannot mean.

### The step's trap — and `build/README.md` has no `#b8a` section, which is a fact and not an omission

§4 step 2 says to name the trap *from `build/README.md`*. **There is no `#b8a` block there**: checked
rather than assumed — `grep -in 'b8a\|decomposition' build/README.md` returns nothing, because
decision 11 inserted this step *after* that document's twelve B-step blocks were written, deliberately,
so that no existing anchor would move. Citing a section that does not exist would be the house failure
mode in miniature. So the trap comes from the two places that *do* define this step, and a pointer
block is added to `build/README.md#b8a` quoting them rather than inventing a thirteenth gate.

**The trap, from decision 11 item 4's §4.1 pattern and Gate B′'s five rows:**

> An early structural choice the ticket makes tempting to get wrong, a later clause of the same ticket
> that is cheap under the right shape and needs a rewrite under the wrong one, and a deterministic
> gate that executes on that clause.

On BE-005 ticket A′ that is exactly one decision: **filter and count a fulfilment value that is
*stored*, or recompute it first and filter the derived value.** Gate B′ measured the pinned model
choosing wrong on **4 of 5** plain runs. The later clause — an order's quantity amended with no
shipment event — is cheap if the value is derived and needs a rewrite if it is stored, and the
evaluator executes on it at exit 12.

**Which layer converts it, and the answer is uncomfortable: at this step, none of them fully.**

- The **evaluator** is **L2** and it *detects* the trap — it executes, and it returns 12. It does not
  prevent it; it is the measuring instrument, present identically in both arms, and it is not the
  treatment.
- The **treatment** is a four-agent pipeline whose mechanism is that *a planner meets the fork before
  anything is typed*. The planner's inability to type is **L2** (a `tools:` list the runtime
  enforces). **What the planner does with that turn is L3** — prose asking for a stored-or-computed
  table. So the treatment is an L2 shape wrapped around an L3 payload.
- Nothing here makes the wrong shape **unwritable**. There is no L1 control at this step and this
  workbook does not claim one.

### Every artifact, labelled by the rule in the workspace `CLAUDE.md`, applied in order

The rule, applied in order and stopping at the first yes: *(1) can the bad value still be written down
after the fix? no → L1. (2) does something execute and reject it? name the thing that runs → L2.
(3) otherwise → L3.*

| # | Artifact | Layer | The thing that runs, or why nothing does |
|---|---|---|---|
| 1 | `…/b8a-pipeline-v1.0/.claude/agents/planner.md` — `tools: Read, Grep, Glob` | **L2** | The **claude runtime** filters the delivered tool set. A planner with no `Edit`/`Write` cannot type. **But see the caveat below: it is not L2 until the `init` read-back says so.** |
| 2 | `…/verifier.md` — `tools: Read, Grep, Glob, Bash` | **L2** | Same mechanism. Can run `./mvnw test`, cannot write. |
| 3 | `…/implementer.md` — the full default set | **L3** | Nothing is restricted, so nothing rejects anything. Its body is prose. |
| 4 | `…/orchestrator.md` — `tools:` including `Task` | **L2** *for the capability*, **L3** *for the discipline* | `Task` present or absent is enforced by the runtime — that is what the deliberate failure attacks. *"Route only, judge no code, run no check"* is a **sentence**; nothing refuses an orchestrator that edits a file. |
| 5 | The **method prose** in `planner.md` and `verifier.md` (Q6 option A) | **L3** | Words a model reads and may or may not follow. This is E-003's finding pointed at a subagent: a 57-word instruction file, proved delivered, moved nothing. |
| 6 | **"One bounce"** (Q8) | **L3**, and this is the label most likely to be mistaken | **Nothing counts delegations.** B8's `repair-limit.sh` counts *one agent's repair attempts per failure fingerprint* — a different quantity. Q8's own first draft claimed the repair limit enforced this and was corrected in session. Making it L2 needs a new hook on the orchestrator's `Task` calls, with a fixture set proving it refuses; that hook is proposed below and is the author's call. |
| 7 | `.agent/run-state.json`'s **`handoff`** field | **L1-shaped medium, L3 payload** | The field is present or absent — a schema-level fact. But nothing executes on the *content* of `from` / `to` / `delivered` / `remains`, so a handoff that says nothing useful passes everything. |
| 8 | The **four delivery conditions** (decision 11 item 9) | **L2** | Each one executes and can refuse: `git ls-files` in the kept worktree; `customization.agentHash` against a registered sha; the `init` read-back showing `Task`; telemetry showing a delegation event per specialist. A run missing any is **row 0a, void before scoring**. |
| 9 | The **evaluator** (BE-005, version `1.0.0`) | **L2** | Executes, returns exit 0 or 12, identical in both arms. The measuring instrument, not the treatment. |
| 10 | The **registered rubric** at sha `945817b8c509` | **L2 as an instrument, L3 as a judgement** | `codex-score.sh` executes and asserts the sha on every sheet. The *score* is a model's reading of an anchor. |
| 11 | The **cost ceiling** of $9.70 | **L3 unless a script enforces it** | A number in this workbook is a number a builder chooses to respect. It becomes L2 if the batch driver reads it and stops; that is cheap and is done at §4 step 4. |
| 12 | The **deliberate failure** overlay — the same four files, `Task` removed | **L2** | The runtime is the thing that runs: no `Task`, no delegation, and the delivery proof's condition (c) refuses the run. It attacks the one proof condition that is about **capability** rather than file presence. |

**Six of twelve are L3 or part-L3.** That is not a defect to be written away; it is the measurement
this step is making. A pipeline is mostly prose, and this project has already found that prose,
proved delivered, moves very little.

### The caveat that voids an L2 label, and it is measured rather than feared

**A `tools:` file is not the treatment until its `init` record says so.** E-005 found the runtime
*rewrites* the list before the model sees it: `Read, Grep, Glob, Bash` was delivered as
`["Read", "Bash"]` on **10 of 10** runs. Author decision 8 makes the `init` read-back **mandatory**
before any B step registers an allowlist. So rows 1, 2, 4 and 12 above are **L2-pending**: each becomes
L2 only when the preflight's `init` record shows the delivered set, and if a list arrives rewritten,
**the label drops to L3 for that agent and the workbook says so** rather than the list being edited
until the label fits.

### Three decisions the design does not get to make freely

1. **The roles are not chosen from the census.** Decision 11 item 1 made the census the thing that
   would name the specialist roles under Reading B. **The census ran and returned no reading** — all 54
   kept BE-004 worktrees hold zero files, so the denominator is zero. `Reading A` is therefore **not
   quoted as having fired** either; nothing fired. The roles come from **the author's Q1**, which is a
   stronger provenance than either reading, and the consequence is recorded rather than hidden: **this
   step has no measured seam behind its role cut**, and a positive result cannot be attributed to
   having picked the right three roles from evidence.
2. **One variable, and it is a compound one.** The treated arm differs from the control by **four
   agent files at once** — a split, three tool lists and two bodies of method prose. That is one
   *configuration*, not one variable, and it is what decision 11 registered. So a positive result
   names the configuration and **cannot apportion the effect** among split, restriction and prose.
   E-007 → E-008/E-009 is the precedent: rung 2 looked null, and a fourth cell was needed to show the
   one visible effect was **prose without any split at all**. The same ambiguity is live here and no
   fourth cell is registered for it.
3. **No path allowlists in prose.** The evaluator's scope guard is the only thing that executes on
   paths, and it does so for both arms alike (Q3). A prose rule about which files a specialist may
   touch would be an L3 control masquerading as a boundary — the exact demotion stop 7 found when
   `allowed-tools` was mistaken for `tools:`.

### What this step does not build, and why

- **No shared skill.** Declined at Q7: activation depends on the description (E-004), telemetry
  redacts project skill names to `custom_skill` so the instrument could not say *which* skill loaded,
  and it would be a second variable beside the agents.
- **No rung 10.** Decision 11 item 2: rung 10 is not registered, and a `NOT DETECTABLE`, `REJECT` or
  `VOID` at rung 4 **closes the ladder** — that closure being the result.
- **Nothing from `workbench.local/`.** Decision 11 item 12: the three bundles and their duplicate are
  not ported in whole or in part. Their role *names* may be read as candidates with provenance
  recorded; they are not, here, because Q1 already fixed the cut.
- **No edit to any existing overlay.** `b8a-pipeline-v1.0/` is new. A measured version is never edited.

### One instrument PR this step may merge itself, and one hook it may only propose

- **May merge (§4 step 14, additive, moves no registered variable):** an `agentsHash` over the set of
  `.claude/agents/*.md`, written exactly as `skills_hash()` already is (`run-agent.sh:616-624`) —
  sorted, path included — with its own fixture set proving it distinguishes a renamed file from a
  changed one. Decision 11 item 9 calls this *welcome* and says the proof does not depend on it. It
  does not: **a schema field is not a control until a run record shows it written.**
- **May only propose (the author's call):** the `Task`-counting hook that would make "one bounce" **L2**
  by refusing a third implementer delegation. It is named here, costed as one hook plus a fixture set,
  and **not built**, because building it would add a second executed control to the treated arm
  mid-design and make the configuration differ by five things instead of four.

### The honest limit on what a null here can mean, written before the run

A null at this step **cannot distinguish** *"the split returned nothing"* from *"the method prose was
not followed"*, because the prose is L3 and nothing observes compliance with it. What the instrument
*can* see, per run, is: the delegation count (3 or 5), the `init` tool sets, the evaluator's exit code,
and `architecture-consistency` on the registered rubric. What it cannot see is whether the planner
actually produced a stored-or-computed table, or whether the implementer read it.

**One cheap thing narrows that**, and it is registered at §4 step 3 rather than left as a wish: the
`handoff` field's `delivered` string is the planner's own output, it is on disk in every kept worktree,
and **counting the runs whose handoff contains a per-read-path table is a co-variate that costs
nothing** — no extra run, no extra scoring call. It is **not** the registered outcome and enters no
decision-rule row; it is the thing that will say, after a null, which of the two readings to believe.

*Designed and layer-labelled by Opus 5 (claude-opus-5), autonomously, 2026-09-25. Q1–Q8 are the
author's, from `B8A-BRAINSTORM.md`; the rung, task, version boundary, delivery proof and budget are
author decision 11; the `change-focus` carve-out and the registered outcome are the author's decision
of 2026-09-25. The layer labels, the trap statement and the two limits above are mine.*

## Build — §4 step 4, 2026-09-25

The smallest thing, and nothing a later step owns. No deliberate-failure overlay exists yet: that
is §4 step 9's, and §6 forbids a future step's artifacts early.

### The four agent files

`build/customizations/b8a-pipeline-v1.0/.claude/agents/{orchestrator,planner,implementer,verifier}.md`.
A **new** overlay; no existing one is edited, because a measured version is never edited.

| File | `tools:` | Where the body comes from |
|---|---|---|
| `orchestrator.md` | `Read, Grep, Glob, Task` | Q2 (route only, judge no code, run no check) + Q8 (one bounce, three or five delegations) |
| `planner.md` | `Read, Grep, Glob` | Q3 + Q6's planner sentence |
| `implementer.md` | *(none — the full default set)* | Q3 + Q6's implementer sentence |
| `verifier.md` | `Read, Grep, Glob, Bash` | Q3 + Q6's verifier sentence |

**No file sets `model:`.** `CLAUDE_CODE_SUBAGENT_MODEL` sits above a subagent's own `model` field
(`SOURCES.md` row 220), so an explicit model there would be a **fifth variable** in a configuration
that already compounds four. The four agents reach `claude-haiku-4-5-20251001` by inheriting the
runner's `--model`, and `runtime.model` is read back per run rather than trusted from the flag. The
batch driver refuses an overlay in which any agent file pins a model (exit 6, fixture case J).

**The orchestrator's `tools:` line is the one thing Q1–Q8 left open**, and it is filled by
precedent rather than by preference: `Read, Grep, Glob, Task` is the tool list of
`orchestration-4b4-P1/.claude/agents/orchestrator.md` **verbatim** — a configuration that ran ten
times at stop 11 and never failed for want of a tool. A narrower `Read, Task` would have been a
better fit for "route only" as a sentence, and a worse fit for the evidence: matching a measured
configuration removes a way for the treated arm to die of something other than its treatment.
*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-25.*

### The batch driver, and the ceiling that now executes

`evidence/b08a/run-b8a-batch.sh`. ShellCheck clean, `cd … || exit`, pid lock.

**Layer table row 11 is discharged.** It read: *"the cost ceiling of $9.70 — **L3 unless a script
enforces it** … It becomes L2 if the batch driver reads it and stops; that is cheap and is done at
§4 step 4."* It is done. The driver sums `efficiency.estimatedCost` **from each run record**, not
from a log line, and exits 11 when the sum reaches $9.70. A run whose cost reads `null` contributes
0 **and is counted separately**, and the batch's closing report calls the total a **lower bound**
whenever that count is above zero — a ceiling that silently treated an unmeasured cost as free
would be a control reporting success over a scope smaller than it claims, which is the failure this
project keeps paying for.

Row 0a on two treated runs exits 10, and **is evaluated before the ceiling** so that a broken
delivery is never reported as a budget stop. Both checks run **after** each control/treated pair,
never between them: stopping mid-pair would leave an unpaired run in a batch whose entire design is
interleaving.

### The fixture set — every reachable exit code, and the one that is not

`evidence/b08a/verify-b8a-batch-guards.sh`: **17 of 17**, covering `0, 6, 7, 8, 10, 11`.

| case | proves | exit |
|---|---|---|
| A | the registered configuration passes every guard and runs nothing | 0 |
| B, C | a dead API / a dead OTLP endpoint is refused | 7 |
| D | a **missing specialist** is refused — the three files no hash sees | 6 |
| E | an orchestrator drifted from its registered sha is refused | 6 |
| F | an orchestrator whose `tools:` has no `Task` is refused — the deliberate failure's own shape | 6 |
| G, H, I | a stray `CLAUDE.md`, `SKILL.md` or `hooks/` in the overlay is refused | 6 |
| J | an agent file that pins `model:` is refused | 6 |
| K, K2 | a live lock refuses a second batch; a **stale** lock does not block one | 8, 0 |
| L, M | row 0a at 2 ends the step; at 1 it does not | 10, 0 |
| N, O | the ceiling fires **at** $9.70 and **not** at $9.69 | 11, 0 |
| P | row 0a is evaluated **before** the ceiling | 10 |

**Exit 9 — the claude-version drift abort — has no fixture**, because producing it needs the CLI to
move between two real runs. The fixture file says so in its header rather than leaving a reader to
discover the gap; `evidence/b08/verify-b8-batch-guards.sh` has the same gap for the same reason.

**The two stop rules are proved through the driver's own functions.** `ceiling_reached()` and
`row0a_ends_step()` are defined once and called both by the batch loop and by the fixture's
stop-rule mode, so cases L–P exercise **the expression that runs**. A fixture that re-implemented
the comparison would be testing a copy of the control — which is how a check comes to report over a
scope smaller than it claims.

**Three of the seventeen were re-derived by hand** in the main context before the green was
believed (§6): the ceiling at exactly `9.70` → exit 11, at `9.69` → exit 0, and a real copy of the
overlay missing `verifier.md` → exit 6.

### Deferred, named, not dropped

The **`agentsHash`** instrument PR (decision 11 item 9, *welcome*) is deferred to §4 step 14. The
proof does not depend on it and **cannot**: delivery condition (a) reads `git ls-files` inside the
kept worktree and therefore already sees all four agent files, which is the whole gap a set-hash
would close. A schema field is not a control until a run record shows it written.

*Built by Opus 5 (claude-opus-5), autonomously, 2026-09-25.*

## Preflight — §4 step 5, 2026-09-25, and the layer table is amended by it

Full write-up: [`evidence/b08a/preflight-20260925T085216Z/RESULT.md`](../../evidence/b08a/preflight-20260925T085216Z/RESULT.md).
Two runs on probe key `EXP-B8A-PREFLIGHT`, control `8d8505d7` and treated `a390a301`, both
`claude-haiku-4-5-20251001` on claude `2.1.282`. **`n = 1` per arm: nothing below is a result**,
and §5 forbids stating anything from `n < 5` as a property.

**All four delivery conditions are observed.** (a) all four agent files **TRACKED** by
`git ls-files` in the kept worktree; (b) `agentHash` = the registered
`sha256:1f27323694e579ec11dbca026bfbb326`; (c) `Task` present in the delivered set
(`["Read","Task","Grep","Glob"]`, `verdict=order-differs` — same set, different order);
(d) all three specialists named, **3 of 3, from the agent stream**.

**The control's assertion holds structurally**: `agentHash`, `instructionsHash` and `skillsHash`
all `null`, and **0 hook executions** — which also discharges the second half of the §0a
isolation row, on a run this stop needed anyway.

### Row 6 of the layer table was right, and one run proved it

The table called **"one bounce" L3** and named it *the label most likely to be mistaken for a
control*: **nothing counts delegations.** The treated preflight made **six** delegations against
Q8's registered 3-or-5, and **not by bouncing** — the verifier ran once — but by the orchestrator
**re-delegating to the planner three extra times**. An L3 rule is a sentence, and this is what a
sentence is worth. Q8 calls 6+ *a finding*, and it is recorded as one: the batch manifest now
carries a `deleg_q8` column classifying every run `q8-ok-3`, `q8-ok-5` or `finding-<n>`. It is
**not** row 0a — decision 11 item 9's four conditions do not include the count.

### Rows 1 and 2 are AMENDED: L2 → L3, on measurement, 2026-09-25

The treated transcript holds **three `system`/`init` records and all three are the orchestrator's
list**. `init.agents` names the agents and carries no tool sets. **There is no `init` record for a
subagent**, so the planner's `Read, Grep, Glob` and the verifier's `Read, Grep, Glob, Bash`
**cannot be read back by any instrument this project has.**

| # | Artifact | Was | **Now** | Why |
|---|---|---|---|---|
| 1 | `planner.md` — `tools: Read, Grep, Glob` | L2 | **L3** | No subagent `init` record exists; author decision 8's read-back cannot be performed for it |
| 2 | `verifier.md` — `tools: Read, Grep, Glob, Bash` | L2 | **L3** | Same. Its list is additionally the one E-005 says arrives rewritten — but that is not even observable here |

The caveat section said these rows were **L2-pending** and would become L2 *"only when the
preflight's `init` record shows the delivered set"*. The preflight has run and there is no such
record, so the pending is **discharged downward**. A list that is never observed is not better off
than one that arrives wrong. **The `tools:` lines are not edited** — they are the author's Q3, the
labels are mine, and the label is what moves.

**What this costs the step, stated plainly:** the treated arm's compound configuration was *a
split, three `tools:` lists and two bodies of method prose*, of which the tool lists were the one
part carrying an executed mechanism. **Only the orchestrator's list is now an observed control.**
Seven of twelve rows of the layer table are L3 or part-L3, not six. That makes this step even more
clearly a measurement of prose and structure than the design already said it was, and it is
registered here **before** the batch rather than discovered after it.

### Two instrument defects the preflight caught, either of which would have destroyed the batch

1. **The wire tool name is `Agent`, not `Task`.** `"name":"Task"` appears **zero** times in a
   transcript with six real delegations. The driver's first condition (d) grepped `events.jsonl`
   for the run id, **found 70 lines**, never reached its stream fallback, and would have returned
   `fail-0-of-3` on **every** treated run — row 0a each time, **batch dead at pair 2 with exit 10**,
   reporting a delivery failure that had not happened.
2. **A line count is not a call count.** The delegation column returned **19** for **six** calls.
   It now counts distinct `tool_use` ids.

Both are fixed and **re-derived by hand against this run's own transcript and the control's**:
treated 6 delegations / 3 of 3 specialists, control 0 / 0 of 3. A query that cannot tell the arms
apart is not a measurement. `verify-b8a-batch-guards.sh` still passes 17 of 17 after the fix.

### Budget, transferred to the batch before it runs

One interleaved pair cost **$1.2222** ($0.414733 + $0.807472). Against the registered **$9.70**
ceiling that is **7.9 pairs**, so the batch is expected to stop at **n ≈ 8 per arm**, not 10, with
the population that occurred reported — exactly as E-016 did at `n = 7`. The treated arm ran
**1.95× the cost** and **2.7× the duration** of the control, inside decision 11 item 11's
2–4× expectation.

*Observed by Opus 5 (claude-opus-5), autonomously, 2026-09-25.*

## Score and report — §4 steps 7 and 8, 2026-09-25

Full numbers, with every exclusion decision and its reason, are in **`evidence/b08a/REPORT.md`**;
the arithmetic is re-derivable by `evidence/b08a/tally.py` and its output is kept at
`evidence/b08a/tally-20260925.txt`. This section carries only what a reader of the workbook needs.

**The population is `n = 8` per arm, 16 runs, because the batch stopped on its registered cost ceiling**
(decision-rule row 0b, $9.70, at $9.7948 after pair 08). Registered behaviour, not a shortfall.

| registered row | prediction | measured | verdict |
|---|---|---|---|
| **P1 — `architecture-consistency`**, the registered outcome | treated median **2** vs control **0** | treated **0** (n = 7) vs control **0** (n = 3) | **REFUTED** |
| **P2 — evaluator pass rate** | treated ≥ **8 of 10** vs control **2 of 10** | **7 of 8** vs **3 of 8**, Fisher **p = 0.1189** | **does not separate** |
| **P3 — shape classification** | treated ≥ **8 of 10** vs control **2 of 10** | **8 of 8** vs **2 of 8**, Fisher **p = 0.0070** | **separates** |
| **P4 — delegations in {3,5}** | **10 of 10** | **6 of 8**; 12 and 8 on the two outliers | **REFUTED** (registered as the one most likely to be wrong) |
| **P5 — cost 2–4×** | 2–4× | **1.83×** ($0.7149 vs $0.3912) | **REFUTED, below the band** |
| **P6 — `modelCalls` ≥ 90** | ≥ 90 | median **82.5** (control 43) | **REFUTED** |
| **P7 — handoff table ≥ 8 of 10** | ≥ 8 of 10 | **5 of 8** fully per-path, 8 of 8 planner delegations | below threshold; **enters no decision-rule row** |

**Five of seven registered predictions are refuted, including the registered outcome.** Two of those
refutations were predicted in the experiment file itself, with the mechanism: P1 (*"I predict this
prediction cannot be measured"* — the control's rubric population is `n = 3`) and P4 (*"this is the
prediction I expect to be wrong"* — "one bounce" is L3 and nothing counts delegations).

### The result of this stop, so far, is about the instrument and not about the split

**P2's mechanism is measured and it is false.** It read: *"the evaluator returns 12 on the wrong shape and
0 on the right one, so pass rate* is *shape on this ticket."* The two rows disagree on **4 of 16 runs, in
both directions** — the evaluator passes two wrong-shaped controls (`4ec4cb7a`, `33b4c452`) and fails two
right-shaped submissions (`4319e882`, `b755f13f`). P2 was registered as *"the strongest thing the
instrument will have"*; it is not measuring what it was registered to measure.

**And `baseline-report.py` — the command §4 step 8 names — discards a complete control run.** The runner
marks `F13` when a run failed *and* `tail -3` of its log matches an infrastructure signature. It fired on
two controls; `ed58787c` deserves it (47 HTTP 529s, one changed file) and **`4abf7f01` does not** (12
changed files, 41 model calls against a control median of 43, 230 s against a median of 230 s, a complete
submission both blind readers classified on all three read paths — and a log tail reading `API error`). The
rule is **not changed** and the run is **not excluded**; `REPORT.md` §7 records the decision, its three
grounds, and the third population that shows what the rule costs (P2 → 0.2448, P3 → 0.0150). It is an
`author_notes` item, not a halt.

### Layer table, amended again by measurement

| row | artifact | label before | label now | what moved it |
|---|---|---|---|---|
| the shape classification | `evidence/b08a/shape/SHAPE-RULE.md` | — | **L3, said in the file** | nothing executes it; two blind readers plus written adjudication replace the author confirmation Gate B′ had, and they are weaker. 16 of 16 class agreement and 48 of 48 per-path agreement is the error bar |
| the `$9.70` ceiling | L2 at §4 step 4 | **L2, confirmed by firing** | exit 11 fired at $9.7948 and stopped the batch. A number in a workbook is L3; this one executed |
| P7's medium (`handoff.delivered`) | assumed present | **does not exist in this arm** | the overlay installs four agent files and no `CLAUDE.md` or hook, so nothing writes a handoff. Answered from the planner's plan in the stream, with the source recorded |

### The exit gate is not answered here

§4 step 11 answers it, and it has a problem to resolve first that is written down rather than smoothed
over: **no decision-rule row fires.** Row 2 requires *both* rates at p ≤ 0.05 (P2 is 0.1189); row 3
requires a *lower* treated rate; row 4 fires only when *neither* rate separates (P3 is 0.0070). The rule
was written assuming the two secondaries would agree. They did not.

---

## Deliberate failure — §4 step 9, 2026-09-25, `n = 5`

Full table, run ids, the refusal text and the cost arithmetic are in
[`experiments/E-020-decomposition-depth-BE005.md`](../../experiments/E-020-decomposition-depth-BE005.md)
`## Deliberate failure — the result`. This section carries only what a reader of the workbook needs.

**The same four overlay files with `Task` removed from the orchestrator's `tools:` line.** New overlay
`build/customizations/b8a-pipeline-v1.0-notask/`; `diff -r` against the measured `b8a-pipeline-v1.0`
returns **exactly one changed line** and the three specialists are byte-identical. **The measured overlay
was not touched.** Own probe key `EXP-B8A-DF-NOTASK`, excluded by name from both registered arms.
`n = 5` rather than 3 because the prediction is stated as a property and §5 forbids that below 5.

**Before a dollar was spent, the registered batch driver was pointed at the broken overlay and refused
it: exit 6**, `evidence/b08a/deliberate-failure-guard-refusal.txt`. The deliberate failure could not have
entered the registered population by accident. That is an **L2** result of this step in its own right,
and it is why the runs needed a separate driver
(`evidence/b08a/run-b8a-deliberate-failure.sh`, ShellCheck clean, fixture set **12 of 12**, its own Task
guard **inverted** so it refuses the *registered* overlay — case D, re-derived by hand).

**All three registered clauses held, and they are the only registered predictions at this stop that did.**

| clause | measured | verdict |
|---|---|---|
| the `init` read-back shows no `Task` | `n=3 ["Read","Grep","Glob"]`, verdict `match`, **5 of 5** | **held** |
| telemetry shows zero delegation events | `0 / 0` both sources, **5 of 5** | **held** |
| 5 of 5 runs classed row 0a | **5 of 5**, on conditions (c) and (d), with (a) and (b) `ok` every run | **held** |

**The watch clause did not fire, and the near-miss is the finding.** Run 01 emitted one `tool_use` named
`"Task"` for `subagent_type: "planner"`; the runtime **refused** it —
`Error: No such tool available: Task. Task is disabled for this session, in subagents as well as here.`
No delegation happened, so the delivery proof stands. Two consequences:

1. **`tools:` withheld a capability here.** E-005 (stop 9) concluded *"`tools:` filters names, not
   capabilities"* from an experiment that **added** `Bash`. Removing `Task` produced a named runtime
   refusal that extends to subagents. Both results are true; the list is not a boundary when it grants
   and is one when it withholds the dispatch tool.
2. **Condition (d)'s grep counts an attempt, not a completion.** It matched the refused call's
   `"subagent_type":"planner"` and returned `fail-1-of-3-stream` where the truth is 0 of 3. It changed no
   verdict here and nothing in the registered arm, but **as written it is not sound** — `author_notes`.

**Cost: $0.1694 for five runs against a $4.00 ceiling and a $3.60 estimate.** The estimate was **21×
too high**. Median **$0.0339** against the treated arm's **$0.7149**; `modelCalls` **1–4** against a
treated median of **82.5**; `changedFiles` **0** and evaluator exit **12**, five times out of five. An
orchestrator holding only `Read, Grep, Glob` cannot write a line of Kotlin. **The cheapness is the
failure, not a saving** — and it is the clearest single number available for what the three specialists
were doing.

## Decide — §4 step 10, 2026-09-25

**Kept as a measured configuration, not promoted, not carried forward.** `b8a-pipeline-v1.0/` stays on
disk because §6 forbids editing a measured version; **nothing installs it after this stop**.

It is **not removed**. §4 step 10's *"a rule with no measured effect is removed"* governs rules this
project **carries** — B3's `instructions-v0.1` was removed under it because it was installed on every
run. The pipeline was never carried: it is a candidate configuration, tested once, answered.

**Promotion is refused on its own terms, and by arithmetic rather than by judgement.** B13's
`tokens_per_accepted_task: { maximum_allowed_increase: 0.15 }` allows **15 %**; the measured figure is
**1.83×**, so the clause fails by a factor of about twelve **regardless of quality** — and the registered
quality outcome showed no effect at all (P1: treated median **0**, control median **0**). The expected
verdict written into `build/README.md#b8a` before the run was *"measured, kept, not promoted"*. That is
what happened.

**The ladder closes.** Decision 11 item 2 makes rung 10 proposable **only if** rung 4's rule fires
`IMPROVED`. It did not. The closure follows from the permissive clause, which is well defined on this
outcome — not from row 4, which is not.

## The learning block and the exit gate — §4 step 11, 2026-09-25

```yaml
learning:
  what_was_added: >
    A four-file agent overlay — one routing orchestrator and three phase specialists
    (planner, implementer, verifier) — installed by --customization and dispatched by
    --agent orchestrator, on BE-005, at n = 8 per arm against a concurrent plain control
    that is also BE-005's baseline measurement.
  why_it_exists: >
    Author decision 11. The nearest rung (one orchestrator, one implementer, stop 11)
    was measured NOT DETECTABLE and its one visible effect was then reattributed to the
    implementer's prose delivered with no split at all. Rung 4 was registered as a ladder
    with a stop rule so that a null would close it rather than invite a bigger proposal.
  observed_effect: >
    On the registered outcome, none. architecture-consistency treated median 0 (n = 7)
    against control median 0 (n = 3), predicted 2 vs 0. Shape classification separates
    (8/8 vs 2/8, p = 0.0070); the evaluator pass rate does not (7/8 vs 3/8, p = 0.1189);
    and the two disagree on 4 of 16 runs in BOTH directions, which measures P2's
    registered mechanism and finds it false. Cost 1.83x, modelCalls median 82.5 vs 43.
  unexpected_effect: >
    The decision rule does not resolve. It has no row for exactly one of its two rates
    separating, because it was written assuming they would agree. This file's own MDE
    section predicted that composition failure before the batch. Separately, the $9.70
    ceiling fired at $9.7948 and stopped the batch at n = 8 — an L2 control confirmed by
    firing — and baseline-report.py's F13 rule discards a complete control run.
  keep_or_remove: >
    Kept as a measured configuration, not promoted (B13's 15% token clause fails by ~12x),
    not carried forward, not edited. The ladder closes: rung 10 is not proposable, because
    decision 11 item 2 makes that conditional on IMPROVED firing and it did not.
  next_question: >
    Not "does a deeper pipeline help". That question is closed at this rung by its own
    stop rule. The open question is instrumental: this stop composed a registered outcome
    in a rubric category, Decision D's gate filter, and a task the model usually fails,
    and got an instrument that could not see its own registered outcome. What is the
    smallest change to that composition — outcome, filter or task — that would let the
    next B step's rule resolve?
```

### The exit gate, answered

**`build/README.md#b8a` is a pointer, not a thirteenth gate**, and it fixes the gate in two halves that
answer different questions. Both are answered here from evidence, and the first one is answered with its
own failure stated rather than smoothed over.

**Half 1 — *did it do anything?*** The registered decision rule's rows are evaluated in order, first to
fire wins. **Row 0b fired** ($9.70 reached at $9.7948) and is discharged by reporting the population that
occurred, `n = 8` per arm. Then **row 0a** no (0 of 8), **row 1** no (delivery 8 of 8, model pinned
16 of 16), **row 2** no (its conjunction requires *both* rates at `p ≤ 0.05`; P2 is 0.1189), **row 3** no
(it requires a *lower* treated rate), **row 4** no (it fires only when *neither* rate separates; P3 is
0.0070). **No substantive row fires, and the verdict is recorded as `NO ROW FIRES`** rather than rounded
to the nearest registered word. What *is* decided, and by a clause that is well defined on this outcome:
**`IMPROVED` is unavailable, so under item 2 the ladder closes.**

**Half 2 — *is it worth it?*** **No**, and not marginally. B13's
`tokens_per_accepted_task: { maximum_allowed_increase: 0.15 }` against a measured **1.83×** fails by
about twelve times, and `quality_score` on the registered outcome moved by **0**. Clauses 6 and 7 (a
human reviewed the qualitative diff; rollback is defined) are satisfied in shape — the PR is the author's
to read and the overlay is a directory not on `main`'s default path — but nothing reaches them, because
the token clause is dispositive on its own. **Measured, kept, not promoted.**

### Was this the agent, or the harness?

**Mostly the harness, and that is the finding.** Four things at this stop were properties of the
instrument rather than of the agent under test: the decision rule that cannot resolve; `agentHash`
covering one file of four, so the delivery proof had to be four hand-written conditions; condition (d)'s
grep counting an attempt as a completion; and `baseline-report.py`'s `F13` rule discarding a complete
control run. The one clean agent-level reading — the shape classification, 8/8 vs 2/8 at `p = 0.0070` —
sits under an **L3** proof (`evidence/b08a/shape/SHAPE-RULE.md`, nothing executes it; two blind readers
and a written adjudication stand in for the author confirmation Gate B′ had). **So the strongest signal
this stop produced is the one with the weakest proof**, and saying so is the honest exit.

### The registered outcome could not see the thing that moved

Worth stating plainly, because it is the transferable lesson and not a complaint. The registered outcome
was `architecture-consistency` on codex, filtered by Decision D to gate-passing runs. On a task the
pinned model usually fails, that filter left the **control at `n = 3`**. The thing that did move — the
*shape* the model reaches for — is not a rubric category, and the rubric's own `change-focus`, the
category nearest to it, is `unmeasured` by the author's decision of 2026-09-25. **The composition chose
an outcome the design could not populate, and the answer was fixed before the batch ran.**

## §5 validation table — §4 step 13, 2026-09-25

Clauses are quoted from [`build/README.md#b8a`](../../build/README.md#b8a), which quotes author decision
11; that block is a **pointer, not a thirteenth gate**, so the clauses below are the step's design
commitments and its two-half gate. **The layer column is about the proof, not the artifact** (§5). Every
command in the "re-derives" column was re-run immediately before this table was written; the three whose
output decides a row are pasted under it.

| Gate clause (verbatim) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "one orchestrator and three specialists — **planner → implementer → verifier**, cut **by phase**, the orchestrator **routing only**" | `build/customizations/b8a-pipeline-v1.0/.claude/agents/{orchestrator,planner,implementer,verifier}.md`; orchestrator `tools: Read, Grep, Glob, Task` and no write tool | **L1** — the orchestrator holds no write tool, so "routing only" cannot be violated by it; the cut itself is prose, **L3** | `ls build/customizations/b8a-pipeline-v1.0/.claude/agents/` and `sed -n 4p` of each |
| "A new overlay …; **no existing overlay edited, no skill**" | `git log --diff-filter=M --name-only -- build/customizations/` shows no modification to any prior overlay on this branch; driver guards refuse a `SKILL.md`/`CLAUDE.md`/`hooks/` in the overlay | **L2** — `run-b8a-batch.sh:122-133`, proved refusing by `verify-b8a-batch-guards.sh` and (for the deliberate-failure driver) cases F and G of `verify-b8a-deliberate-failure-guards.sh` | run either `verify-*-guards.sh`; both are guards-only and spend nothing |
| "All four agents on `claude-haiku-4-5-20251001`" | `runtime.model` on **21 of 21** run records (16 registered + 5 deliberate failure); driver aborts if any agent file sets `model:` | **L2** — the guard executes (`verify-b8a-deliberate-failure-guards.sh` case H, exit 6) and the read-back is from the record, not the flag | `awk -F'\t' 'NR>7{print $7}' evidence/b08a/batch-*/manifest.tsv` and `$6` of the deliberate-failure manifest |
| "Handoff medium is B8's `.agent/run-state.json` `handoff` field, written **reserved** at B8 and **first used here**" | **NOT MET, and measured so.** `evidence/b08a/REPORT.md` §6: the `handoff` block is written by agent-v1.1's `CLAUDE.md` and `.ai/hooks/repair-limit.sh`; this overlay installs four agent files and nothing else, so **no handoff artifact exists on disk in either arm**. P7 was answered from the planner's returned plan in the stream, with the substitution recorded | **L3** — a stream read, not an artifact; the clause's own medium is absent | `find evidence.local/b08a-worktrees/<treated id> -name run-state.json` returns nothing; `.claude/agents/*.md` are the only non-`sample-service` files |
| "**Task: `BE-005` only** … reference population is **its own concurrent plain control at this stop, `n = 10`**, which is also BE-005's baseline" | `benchmarkId` `BE-005` on all 21 runs; control arm registered as the baseline before the batch in `E-020 ## Runs`; the population that occurred is **`n = 8`**, by row 0b | **L2** for the task (the driver passes `--benchmark BE-005` and the record carries it); **L3** for "is also the baseline", which is a registration in prose | `jq -r .benchmarkId` over `evidence/b08a/worktrees/*/run-record.json` |
| Gate half 1 — "**Did it do anything?** The experiment's own decision-rule rows … `VOID` · `NOT DETECTABLE` · `REJECT` · `IMPROVED`" | **`NO ROW FIRES`.** Row 0b fired and is discharged at `n = 8` per arm; rows 0a/1/2/3/4 each evaluated against `evidence/b08a/REPORT.md` §§1–4 and none fires. Recorded in E-020 `## Results` and above | **L3** — the rows are applied by a reader; nothing executes them. The *inputs* are L2 (`tally.py`, the manifests, the sheets) | re-run `evidence/b08a/tally.py`; compare its P2 `p = 0.1189` and P3 `p = 0.0070` against the rows in `E-020 ## Decision rule` |
| Gate half 2 — "**Is it worth it?** B13's seven clauses, verbatim … `tokens_per_accepted_task: { maximum_allowed_increase: 0.15 }`" | **Failed.** `1.83×` ($0.7149 treated median vs $0.3912 control), `evidence/b08a/REPORT.md` §5. `quality_score` on the registered outcome moved by **0** (§2). **Measured, kept, not promoted** | **L3** — the clause is read and applied by a person; the numbers under it are **L2** | `awk` the `cost` column of `evidence/b08a/batch-*/manifest.tsv` by arm and take medians |
| "Per-arm delivery proof … four conditions, per run, before scoring … **A run missing any is row 0a**" | Registered arm: `cond_a`…`cond_d` all `ok` on **8 of 8** treated (`evidence/b08a/batch-20260925T091510Z/manifest.tsv`). Deliberate failure: **5 of 5** row 0a on (c) and (d) | **L2** — the conditions are evaluated by the driver per run and written to the manifest before any sheet exists. **Caveat, measured:** condition (d)'s grep counts an *attempt*, not a completion — run `d78ef2c8` | `awk -F'\t' 'NR>7{print $11,$12,$13,$14,$15}'` on either manifest |
| "The ladder's stop rule … rung 10 … **only** if rung 4's own rule fires `IMPROVED`" | `IMPROVED` unavailable — row 2's conjunction requires both rates at `p ≤ 0.05` and P2 is `0.1189`. **Ladder closed** | **L3** — a reading of a written clause | the same `tally.py` output |
| "**Cost ceiling $9.70** = 25 × $0.388" | Fired: exit **11** at **$9.7948** after pair 08, `evidence/b08a/batch-20260925T091510Z/window.txt` | **L2, confirmed by firing** — the same `awk` expression the fixture set proves (`verify-b8a-batch-guards.sh`, stop-rule-only mode) | `tail window.txt`; `B8A_STOPRULE_ONLY=1 B8A_TEST_COST=9.70 evidence/b08a/run-b8a-batch.sh` → exit 11 |
| "The registered outcome is **`architecture-consistency`** on rubric sha **`945817b8c509`**, scored by **codex**, **hand re-read before any sheet is opened**" | 10 codex sheets, `evidence/b08a/sheets-codex.tsv`; hand reading committed **before** any sheet was opened, `evidence/b08a/hand-reading/` and `REPORT.md` §8 — **and it agreed** | **L2** — the sheets are produced by a harness against a pinned rubric sha; the hand re-read is **L3** and is the check on it | `grep rubric_sha findings/codex/score-observatory-run-*.yaml \| sort -u`; open the hand reading and the sheet for the same run id |
| "**`change-focus` is `unmeasured`** and enters no row, no MDE and no exit gate" | Excluded everywhere: `E-020 ## Decision rule`, `REPORT.md` §2, and the weighted total stated as **85 measured points on a 100-point scale** and **not comparable to BE-004's** | **L3** — an exclusion honoured by the writer; nothing refuses a reader who ignores it | `grep -n 'change-focus' experiments/E-020-decomposition-depth-BE005.md evidence/b08a/REPORT.md` |
| "**Ends early** … a preflight that cannot show all four delivery conditions · row 0a on 2 or more treated runs" | Neither fired: preflight showed all four (`evidence/b08a/preflight-20260925T085216Z/`), row 0a `0 of 8` | **L2** — `row0a_ends_step()` is one expression, proved firing at 2 by `verify-b8a-batch-guards.sh` in stop-rule-only mode | `B8A_STOPRULE_ONLY=1 B8A_TEST_ROW0A=2 evidence/b08a/run-b8a-batch.sh` → exit 10 |
| §4 step 9 — the deliberate failure | `evidence/b08a/deliberate-failure-20260925T151315Z/manifest.tsv`, 5 runs, exit 0; guard refusal `evidence/b08a/deliberate-failure-guard-refusal.txt` (exit 6); prediction commit `2514c7f` **15:13:08Z** vs run 01 `startedAt` **15:13:16Z** | **L2** — both the refusal and the five row-0a classifications are produced by executing code and written before any interpretation | `git show -s --format=%cI 2514c7f`; `jq -r .startedAt` on run `d78ef2c8-dbf8-4f24-aab9-4d6a482f5ff3` |

**At least one scored cell re-read by hand** (§5): `REPORT.md` §8 — the hand reading was committed before
any sheet was opened, and agreed with the registered sheet.

**Independence check** (§5): what else changed between arms? `instructionsHash` **null on all 16
registered and all 5 deliberate-failure runs**; `skillsHash` **null on all 21**; `runtime.model` the pinned
id on all 21; rubric sha `945817b8c509` unchanged throughout; benchmark `BE-005` at one commit. The
registered treated arm carries `agentHash` `1f27323694e5…` and the deliberate-failure arm `c0c5aab3e7d4…`;
**neither value appears in the other's manifest**. Read from the run records, not from the flags.

**Every number quoted above has its `n`** (§5): the registered arms are `n = 8` each, the rubric-scored
control population is `n = 3` (Decision D's gate filter) and is stated as such wherever P1 appears, and
the deliberate failure is `n = 5`.

**Re-run immediately before this table was written, output pasted** (§5: *"Run every verification command
again immediately before writing 'done', and paste the output"*). The two header rows of each manifest and
one trailing blank line appear in the `uniq -c` counts and are labelled here rather than filtered away:

```
$ B8A_STOPRULE_ONLY=1 B8A_TEST_COST=9.70 evidence/b08a/run-b8a-batch.sh
stop-rule: COST CEILING $9.70 REACHED at $9.70 (exit 11)
exit=11

$ B8A_STOPRULE_ONLY=1 B8A_TEST_ROW0A=2 evidence/b08a/run-b8a-batch.sh
stop-rule: ROW 0a on 2 treated runs — the step ends (exit 10)
exit=10

$ model column, both manifests, all 21 runs
  21 claude-haiku-4-5-20251001
   2 model            <- the two manifest header rows
   1                  <- one trailing blank line

$ instructionsHash / skillsHash, both manifests, all 21 runs
  21 instr=null skills=null
   2 instr=instr_hash skills=skills_hash    <- the two manifest header rows
   1 instr= skills=                         <- one trailing blank line

$ ./evidence/b08a/verify-b8a-deliberate-failure-guards.sh
verify-b8a-deliberate-failure-guards: 12 passed, 0 failed.
```
