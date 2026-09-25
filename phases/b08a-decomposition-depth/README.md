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
