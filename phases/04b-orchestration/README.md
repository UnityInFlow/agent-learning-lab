# Phase 4B — Agent orchestration and multi-layer design

**Guardrail layer: L3 — unless the split is structural, in which case L1.**
**Status:** 🟨 open — spine stop 11, §4 step 1 · **Depends on:** Phase 4A (closed 2026-09-04, lab#60)

> Opened by the autonomous run on 2026-09-05, branch `stop11/phase-4b-orchestration`.
> **Provenance note:** this session's orchestrator is Claude Fable 5.1 (`claude-fable-5-1`),
> started by the author with the driver's build sentence in an interactive session. The prompt's
> provenance line names Opus 5; writing that here would be false, so every line this stop adds
> reads `Claude Fable 5.1 (claude-fable-5-1), autonomous`. The agent under test is unchanged:
> `claude-haiku-4-5-20251001`.

## Goal

Phase 4A built *one* specialized agent. This is about *many* — decomposition, layering,
handoffs, and the question most multi-agent material skips: **when not to.**

This phase does not exist in the original curriculum. It is the gap between "a single
custom agent" and "that agent running unattended", and it is where the
ANALYSIS → DESIGN → IMPLEMENTATION → VERIFICATION → REVIEW → DONE workflow in your backend
agent v1 actually gets designed.

## Verified reading

How the ticks below were earned, 2026-09-05: a subagent fetched each page and returned quotes;
the orchestrator then downloaded the raw HTML with `curl` and searched it for every quoted
fragment. **A quote is in the extract only if the fragment was found in the raw page.** The
fetch tool paraphrases — for *Building effective agents* it returned five "one-sentence
definitions" of the patterns that are **not on the page**; those were discarded and the real
sentences pulled from the HTML by hand. Raw pages are in the session scratchpad, not committed.

- [x] ✅ [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) — re-read 2026-09-05, 14 fragments verified
  > *Workflow or agent — who chooses the next step?*

  **Extracted in [Phase 0A](../00a-agent-mechanics/README.md#extract).** Re-read the five
  patterns here: prompt chaining, routing, parallelization, orchestrator–workers,
  evaluator–optimizer. Your v1 workflow is **prompt chaining** with an evaluator-optimizer
  loop bolted on at VERIFICATION.
- [x] ✅ [Anthropic — Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) — extract below predates this stop (read 2026-08-09); not re-fetched
  > *What does orchestrator/worker cost in tokens, and when does that pay?*
- [x] ✅ [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents) — re-read 2026-09-05, 8 fragments verified; page title now *Create custom subagents*
  > *What exactly is isolated — context, tools, model, permissions?*
- [x] ✅ [Claude Code — Agent teams](https://code.claude.com/docs/en/agent-teams) — read 2026-09-05, 6 fragments verified
- [x] ✅ [Claude Code — Dynamic workflows](https://code.claude.com/docs/en/workflows) — read 2026-09-05, 9 fragments verified
  > *When should orchestration be deterministic code rather than a model decision?*
- [x] ✅ [A harness for every task](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) — read 2026-09-05, 10 fragments verified
- [x] ↪️ [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) · ✅ [Copilot custom agents](https://docs.github.com/en/copilot/reference/custom-agents-configuration) — **not re-read**; both were read and extracted at stop 9 ([Phase 4A](../04a-agents-permissions/README.md#extract)) and nothing here depends on them beyond what 4A carries: codex has no `tools:` field, capability there is `sandbox_mode`

## The real reason to decompose

Not "specialization." **Context isolation.**

From the Phase 0A extract: context rot means recall degrades as the window fills. A
sub-agent works in a clean window and returns a condensed summary, so the parent never
pays for the worker's exploration. That is the mechanism — everything else is a story.

Which gives you the test: **if a split does not reduce what the parent must hold, it is
overhead.**

---

## Extract

From *Multi-agent research system*, read 2026-08-09. Quotes verbatim.

### The architecture

A lead agent "analyzes [queries], develops a strategy, and spawns subagents to explore
different aspects simultaneously." Subagents run in parallel, **each with its own context
window**, and return findings to the lead for synthesis.

### The numbers — read these before designing anything

> - "agents typically use about **4× more tokens** than chat interactions, and multi-agent
>   systems use about **15× more tokens** than chats"
> - "a multi-agent system with Claude Opus 4 as the lead agent and Claude Sonnet 4 subagents
>   **outperformed single-agent Claude Opus 4 by 90.2%**"
> - "token usage by itself explains **80% of the variance**" in browsing agent performance

15× cost for a 90% gain is an excellent trade — **on the right task.** Which brings us to the
sentence that matters most for you:

### The warning aimed directly at this project

> "**Most coding tasks involve fewer truly parallelizable tasks than research.**"

Multi-agent suits "heavy parallelization, information that exceeds single context windows,
and interfacing with numerous complex tools" — breadth-first queries with independent
directions.

It is **poorly suited** to domains requiring "all agents to share the same context or
involve many dependencies between agents."

> A backend feature implementation is dependency-dense and context-shared. That is the
> profile the article names as a poor fit. Your v1 pipeline (ANALYSIS→DESIGN→…) is
> **prompt chaining**, not parallel fan-out — sequential stages, one context handed forward.
> That is the right pattern, and it is worth knowing you chose correctly for a reason rather
> than by luck.

### Scaling effort to complexity

> "Simple fact-finding requires just **1 agent with 3–10 tool calls**, direct comparisons
> might need **2–4 subagents with 10–15 calls each**, and complex research might use **more
> than 10 subagents**."

Put this in the orchestrator's prompt. Without it:

> "Without detailed task descriptions, agents duplicate work, leave gaps, or fail to find
> necessary information."

### Failure modes

> - "agents spawning **50 subagents for simple queries**, scouring the web endlessly for
>   nonexistent sources"
> - "minor changes cascade into large behavioral changes"
> - errors compound because "agents can run for long periods of time, maintaining state
>   across many tool calls"

The first is Lab 4B.4 in the wild. The second is why you change one variable at a time.

### On evaluating them

LLM-as-judge with a rubric — factual accuracy, citation accuracy, completeness, source
quality, tool efficiency — but: **"Human evaluation catches what automation misses,"**
including edge cases and source-selection bias.

---

### Read at stop 11 — five pages, every quote found in the raw HTML

`Extracted by Claude Fable 5.1 (claude-fable-5-1), autonomous, 2026-09-05.` Quotes verbatim;
anything in square brackets is mine.

#### *Building effective agents* — who chooses the next step

> "Workflows are systems where LLMs and tools are orchestrated through predefined code paths."
> "Agents … are systems where LLMs dynamically direct their own processes and tool usage,
> maintaining control over how they accomplish tasks."

**The five patterns, in the page's own sentences:**

| Pattern | The page's definition |
|---|---|
| Prompt chaining | "decomposes a task into a sequence of steps, where each LLM call processes the output of the previous one. You can add programmatic checks (see 'gate' in the diagram below) on any intermediate steps" |
| Routing | "classifies an input and directs it to a specialized followup task. This workflow allows for separation of concerns, and building more specialized prompts" |
| Parallelization | "LLMs can sometimes work simultaneously on a task and have their outputs aggregated programmatically" — two variants: "Sectioning: Breaking a task into independent subtasks run in parallel. Voting: Running the same task multiple times to get diverse outputs" |
| Orchestrator-workers | "a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results" — "well-suited for complex tasks where you can't predict the subtasks needed" |
| Evaluator-optimizer | "one LLM call generates a response while another provides evaluation and feedback in a loop" — "particularly effective when we have clear evaluation criteria, and when iterative refinement provides measurable value" |

**Which one v1 uses:** ANALYSIS → DESIGN → IMPLEMENTATION → VERIFICATION → REVIEW → DONE is
**prompt chaining** — sequential, each stage consuming the previous output — with the
VERIFICATION stage as an evaluator-optimizer loop. The "gate" the page draws between steps is
exactly where B7's deterministic checks go. Nothing in v1 is routing, parallel, or
orchestrator-workers.

**When agents, and at what price:** "Agents can be used for open-ended problems where it's
difficult or impossible to predict the required number of steps, and where you can't hardcode a
fixed path." The cost: "higher costs, and the potential for compounding errors." And the rule
this whole stop is built on: "optimizing single LLM calls with retrieval and in-context examples
is usually enough" — add complexity "only when it demonstrably improves outcomes."

#### *Create custom subagents* (the Claude Code subagents page) — what exactly is isolated

> "Each subagent runs in its own context window with a custom system prompt, specific tool
> access, and independent permissions."

So four things are isolated: **context, system prompt, tool set, permissions.** Model is a
fifth, chosen per subagent (`model:` — "sonnet, opus, haiku, fable, a full model ID such as
claude-opus-5, or inherit").

**The sentence that decides what a split can and cannot be here:**

> "Subagents inherit the built-in tools and MCP tools available in the main conversation,
> narrowed by two filters: the first removes a short list of tools from every subagent, and the
> second reduces the built-in tool set for subagents that run in the background, which is the
> default."

**A subagent's tool set is a subset of its parent's.** There is no configuration in which the
orchestrator lacks `Edit` and its worker has it. **A capability partition between orchestrator
and worker — the thing the business case's "boundaries" language implies when it separates who
analyses from who changes code — is not expressible in this runtime.** Only the context is
partitioned. The `tools:` field on a subagent "Inherits every tool available to subagents if
omitted", and can only narrow.

> **Corrected by observation, 2026-09-06T05:11Z — the paragraph above is what the page says,
> and it is not what the runtime does when the parent is an `--agent` overlay.** The §4 step 2
> probe (`evidence/p04b/lab-4b4/probe-20260906T050917Z/`, 3 runs per variant, flags verbatim from
> the runner) delivered the main session `["Read","Task","Grep","Glob"]` on **3 of 3** P1 runs —
> the file's four names, no rewrite, no `Edit`/`Write`/`Bash` — and on **3 of 3** the worker
> subagent made a `Write` call visible in the parent's stream and `probe.txt` existed afterwards
> containing `ok`. **The worker inherited the *conversation's* pool, not the main agent's
> narrowed list.** "Main conversation" in the page's sentence is the session, and an `--agent`
> overlay's `tools:` narrows the agent, not the session. So a structural split *is* available:
> the orchestrator cannot write and the worker can. The claim above stays as written because it
> is what a reader of the page would conclude, and this stop's first result is that the page
> under-describes the runtime. Two more things the probe recorded: the delegation tool is listed
> as `Task` in `init.tools` and appears as `Agent` in `tool_use` blocks — outcome 1 counts either
> name; and every `model` value in all six streams was `claude-haiku-4-5-20251001`, so the
> worker's `model:` pin held on 6 of 6 (observed, still nothing rejects a wrong one).

Depth: "By default, a subagent can spawn subagents of its own, up to three layers below the main
conversation." Return path: "Only the top-level subagent's summary returns to you" — the
handoff back is a summary, which is Lab 4B.3's failure mode stated as a feature.

**The page's own advice against splitting a task like BE-003:** "Use the main conversation
when: The task needs frequent back-and-forth or iterative refinement. Multiple phases share
significant context, such as planning, implementation, and testing. You're making a quick,
targeted change. Latency matters." BE-003 is a planning-implementation-testing sequence on one
controller, i.e. three of the four.

#### *Agent teams* — the other axis, and its price

> "Agent teams let you coordinate multiple Claude Code instances working together."
> "Subagents report results back to the main agent. In agent teams, teammates share a task
> list, claim work, and communicate directly with each other."

Cost, in the page's comparison table: subagents "Lower: results summarized back to main
context"; teams "Higher: each teammate is a separate Claude instance" — "Agent teams use
significantly more tokens than a single session." And the sentence that closes the door for this
project's task class: **"For sequential tasks, same-file edits, or work with many dependencies,
a single session or subagents are more effective."** Teams are "experimental and disabled by
default" (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), so they are not a treatment this track can
register.

#### *Dynamic workflows* — when orchestration is code

> "A dynamic workflow is a JavaScript script that orchestrates many subagents at once."
> "A workflow moves the plan into code. With subagents, skills, and agent teams, Claude is the
> orchestrator: it decides turn by turn what to spawn or assign next, and every result lands in
> a context window." "A workflow script holds the loop, the branching, and the intermediate
> results itself, so Claude's context holds only the final answer."

That is the answer to the gate's last question, in the vendor's words: **orchestration should be
code when the loop, the branching and the intermediate results would otherwise land in a model's
context.** Primitives: "agent() spawns one subagent, pipeline() runs one per item in a list, and
parallel() runs a set of agent tasks at the same time and waits for all of them." Results come
back typed — an `agent()` call takes a JSON `schema:` and "resolves to null if you stop it
mid-run or it hits an unrecoverable API error" — so a null is a measurement here too. Cost: "a
single run can use meaningfully more tokens than working through the same task in
conversation"; limits "Up to 16 concurrent agents" and "1,000 agents total per run — Prevents
runaway loops" (the 50-subagent failure mode above, made structural — an L1 cap).

#### *A harness for every task* — the vendor's own restraint

> "Claude can now write its own harness on the fly, custom-built for the task at hand."
> "Dynamic workflows execute a javascript file with a few special functions that help spawn and
> coordinate subagents."

And immediately: "they are not needed for every task and may end up using significantly more
tokens." "For regular coding tasks, try and ask yourself: does it really need more compute? For
example, most traditional coding tasks do not need a panel of 5 reviewers." Three named failure
modes worth carrying into B5 and B8: premature completion — Claude "declares the job done after
partial progress, for example addressing 35 of the 50 items in a security review"; self-
preferential bias — "Claude's tendency to prefer its own results or findings, especially when
asked to verify or judge them against a rubric"; goal drift — "the gradual loss of fidelity to
the original objective across many turns, especially after compaction." Fan-out joins at "a
barrier — it waits for all the fan-out agents, then merges their structured outputs into one
result", which is Lab 4B.2's slow-worker problem stated as the design.

### What this project's own instrument already says about decomposition on BE-003

- **The agent under test never delegates on this task.** The observatory's telemetry file
  (`agent-observatory/infra/telemetry-out/events.jsonl`, 38 runs on file as of
  2026-09-05T19:43Z) records `tool_result` events with a `tool_name` on 1 628 calls across those
  38 runs; the names are `Bash` (700), `Read` (684) and `Edit` (244) and nothing else. **Zero
  `Task` calls on 38 of 38 runs** — `Task` being the delegation tool's name in the delivered pool
  (`evidence/b04/init-schema/`, `n = 29` tools, `Task` first in the list). *True of these runs*;
  the file is a rolling window, not the 147 BE-003 runs the API holds.
- **The delivered pool already contains the orchestration tools.** `Task`, `Workflow`,
  `SendMessage`, `ListAgents` are all in the 29 delivered to a plain baseline. Nothing stops the
  model from decomposing today; it chooses not to, which is the vendor's advice above followed
  without being told.
- **From stop 9 (E-005):** the runtime told a tool-restricted subagent *"Write is disabled for
  this session, in subagents as well as here"* — the inheritance rule above, observed. And a
  `tools:` list is rewritten before delivery (`Read, Grep, Glob, Bash` → `["Read","Bash"]`), so
  any orchestrator/worker overlay here needs author decision 8's init probe **per agent file**
  before its prediction commit.

### The consequence for this stop's one lab

The real reason to decompose (above) is context isolation, and the test is *does the split reduce
what the parent must hold*. Two things are now fixed by evidence rather than by taste:

1. **A structural (L1) split of *capability* is unavailable inside one Claude Code session**
   (inheritance rule). The only L1 decomposition is process-level — separate `claude -p`
   sessions with a file as the handoff — and that is B5's build at stop 12. §6 forbids creating
   it here.
2. **A split of *context* is available and cheap to force** — an `--agent` overlay whose main
   agent is told to delegate implementation to a worker subagent — and its activation is
   **L2-observable**: a `Task` call in the run's telemetry, where the plain baseline shows 0 of 38.

So the one lab is **Lab 4B.4 — when decomposition loses**, on BE-003, which the vendor's own
page classifies as a task that should stay in the main conversation. It measures the overhead of
an orchestrator–worker split on a task too small to split, against a concurrent plain control,
with delegation counted rather than assumed. Labs 4B.1, 4B.2 and 4B.3 are **deferred by the
autonomous run**: 4B.1 is B5's measurement, 4B.2 needs a task with independent parts (BE-004,
after benchmarks#29), and 4B.3's handoff-fidelity question is folded into 4B.4's design as a
registered outcome (the worker must receive one ticket detail the orchestrator has no reason to
forward). Design and layers in §4 step 2 below.

---

## §4 step 2 — design, layers, and the trap

`Decided by Claude Fable 5.1 (claude-fable-5-1), autonomous, 2026-09-06, before any run.`

### The lab: E-007 — orchestration overhead on a task too small to split

**Question.** On BE-003, what does an orchestrator–worker decomposition cost, and what does it
return, against a concurrent plain baseline — with delegation *counted*, not assumed?

**Arms.** `n = 10` per arm, interleaved, one experiment key, same runner, benchmark commit,
evaluator, model (`claude-haiku-4-5-20251001`) and rubric sha (`396e1799eb2b`) as E-006 batch 2.

| Arm | Delivered as | What the model sees |
|---|---|---|
| **O** — orchestrated | `--customization build/customizations/orchestration-4b4-P<1\|2>/ --agent orchestrator` | the main session *is* `orchestrator`, whose only job is to hand the ticket to the `implementer` subagent and verify its report; `implementer` is the second file in the same overlay |
| **C** — concurrent control | no overlay, no `--agent` | the plain baseline, exactly as E-006's control |

**Two overlay variants exist and the probe below picks one before the prediction commit.**

- **P1** — `orchestrator` carries `tools: Read, Grep, Glob, Task`. It cannot `Edit`, `Write` or
  run `Bash`; the only way the ticket gets done is through the worker. **A structural split** —
  *if* the worker still inherits a pool that can write.
- **P2** — no `tools:` key on either file. The split is prose: the orchestrator is told to
  delegate and told not to edit. **An L3 split whose activation is L2-observable.**

The extract's reading of the subagents page says P1 cannot work — a subagent's pool is its
parent's, narrowed — and a `tools:` list is rewritten before delivery (E-005). Neither is taken on
faith. **Author decision 8 applies to both files**: the init-schema probe runs each variant three
times off the observatory, reads the main session's delivered `init.tools`, and observes whether
the worker could write a file when the parent could not. The rule, fixed now:

> **P1 is the treatment iff, on 3 of 3 P1 probe runs, the parent's delivered pool lacks
> `Edit`/`Write`/`Bash` *and* the worker wrote the file.** Otherwise P2 is the treatment and the
> P1 result is recorded as the extract's inheritance claim, observed rather than read.

**Probe result, 2026-09-06T05:09–05:11Z — P1 admitted, 3 of 3.** `probe-20260906T050917Z/`:
P1 delivered `["Read","Task","Grep","Glob"]` ×3, parent cannot write, `probe.txt` = `ok` ×3, one
`Agent` (`Task`) call per run; P2 delivered the full 29 ×3, `probe.txt` = `ok` ×3, one call per
run. **The treatment is `orchestration-4b4-P1`** (orchestrator `4f2af4ba7f740c33…`, implementer
`6096f5ea35383112…`, sha256 prefixes). P2 (`1b259ccc09066cad…`, implementer byte-identical) is
now the natural §4 step 9 deliberate failure — *remove the structural line and see whether the
orchestrator still delegates* — and its prediction is written at step 9, not here.

**Registered outcomes** (magnitudes and mechanisms in E-007):

1. **Delegation** — `Task` `tool_result` events per run in the observatory telemetry. L2: the
   count comes from something that executes. Control: 0 of 38 on file.
2. **Cost** — `efficiency.estimatedCost` median vs the concurrent control.
3. **Duration**, **`toolCalls`**, **`modelCalls`** — medians with quartiles.
4. **Correctness** — evaluator exit code per arm; pass rate is a result, not a nuisance.
5. **Quality** — `maintainability` anchor 2 reached, codex sheet, rubric `396e1799eb2b`.
6. **Report-only, not outcomes:** `changedFiles` (3 on 19 of 19 historical controls — at the
   floor), `addedLines`, `change-focus` (1 on 70 of 70 scored runs — a dead category).

**Lab 4B.3 folded in — handoff fidelity, with its classification rule fixed before the run.**
The orchestrator is instructed to pass the ticket *verbatim*. BE-003's gate checks the error
cases, which is where a paraphrase loses a detail. Rule: an arm-O run that fails the evaluator is
opened and classified **handoff loss** if the worker's delegated prompt (in the kept transcript)
omits or alters an acceptance criterion the ticket states; **worker failure** otherwise. This is
an L3 reading of a transcript and is labelled so; the *count* of failures is L2.

**The gate's number, in the only form one task can give it.** BE-003 is 3 files and a median of
69 added lines (concurrent control, `n = 10`). If arm O costs more and returns nothing the gate
can see, the size below which decomposition loses is **at least this size** — a lower bound with
its `n`, not a threshold. The threshold needs a second size, which is BE-004 at stop 12.

### Every artifact, labelled — the rule applied in order, stopping at the first yes

| Artifact | Layer | Why |
|---|---|---|
| `--agent orchestrator` delivery | **L2** | `claude --agent <unknown>` exits 1 and prints the registry (observed at stop 10); the runner's guard refuses an agent overlay without `--agent` (9 fixtures) |
| `orchestrator` `tools:` line (P1 only) | **L2 if the probe admits P1** — the runtime refuses an absent tool by name (observed, stop 9). **Not present under P2** | the bad value can be written down, so not L1; something executes and rejects |
| the orchestrator's *delegate, do not edit* prose | **L3** | nothing executes it. Its effect is measured by outcome 1 |
| the `implementer` body | **L3** | prose |
| `model:` pins on both files | **L3** | observed on `runtime.model` (main session) but nothing rejects a wrong pin; the worker's model is not on the run record at all — see the probe |
| the init-schema probe | **L2** | an executing check over the `init` record, `verify-init-schema-check.sh` 17 fixtures |
| delegation count from telemetry | **L2 as observation** | `tool_result` events with `tool_name = Task`, per run id, `jq` over `events.jsonl` |
| `customization.agentHash` | **not available** | unchanged since stop 10: no field tracks a Claude agent overlay; independence rests on the `init` record, the setup commit and the telemetry, as E-006 §5 did |

### The trap, and which layer converts it

Two, and they face opposite ways.

1. **The orchestrator does the work itself and *narrates* delegation.** A transcript that reads
   as decomposed with 0 `Task` calls is the plain baseline wearing a costume. Converted by
   **outcome 1 at L2**: the telemetry count, never the transcript.
2. **The worker inherits a narrowed pool and cannot do the task**, so arm O measures an agent
   that cannot write, not decomposition — E-005's *"an agent that cannot do what the task
   instructs is not being measured on the task"*. Converted by **the probe at L2, before the
   prediction commit**, which is why P1 is conditional and P2 is the fallback.

The workbook's own trap — *"if a split does not reduce what the parent must hold, it is
overhead"* — is what the cost and `modelCalls` outcomes measure directly.

### Delivery proof, per arm

- **Arm O:** `--agent orchestrator` accepted (exit ≠ 1 at start); `init.tools` per run diffed
  against the variant's declared list by the runner's `check-init-schema.sh` (verdict `matches`
  for P1, `recorded-only` for P2); ≥ 1 `Task` event in telemetry; the overlay directory's tree
  hash in the setup commit.
- **Arm C:** no overlay directory in the worktree; `customization.*Hash` all `null`; 0 `Task`
  events.
- **Both:** `runtime.model = claude-haiku-4-5-20251001`, benchmark sha and evaluator version
  equal to E-006 batch 2, recorded per run in the batch manifest.

> **Amended 2026-09-06 at §4 step 5, after the preflight pair. Three things above this line are
> wrong and the originals are kept so the correction can be checked.**
> `Claude Opus 5 (claude-opus-5), autonomous.`
>
> 1. **"verdict `matches` for P1" is not what happens and could not have been.** The runtime
>    permutes the declared list: declared `[Read,Grep,Glob,Task]`, delivered
>    `["Read","Task","Grep","Glob"]`, on 3 of 3 probes **and on the live preflight run
>    `075857fe`**. The verdict is `order-differs`, which is *set* equality — admissible and
>    recorded. A `mismatch` (different **set**) remains row 0a. Full reasoning, both readings
>    and the runner fix it forced: `experiments/E-007-orchestration-overhead.md`,
>    § *Amendment 2026-09-06*.
> 2. **`customization.*Hash` cannot support arm C's row.** They are `null` on *both* arms —
>    including `agentHash` on a run that provably carried an agent overlay. The arms are
>    separated by `init.tools` (**4 vs 29**) and by delegation events (**1 vs 0**), not by a
>    hash. Arm C's bullet asserts something true that discriminates nothing.
> 3. **"benchmark sha and evaluator version equal to E-006 batch 2" holds; the Claude Code
>    version does not.** The binary moved to **2.1.263** at 04:38Z on 2026-09-06, before both
>    the probe and the prediction commit. Disclosed as the fifth harness move in E-007; the
>    within-batch O-vs-C comparison is unaffected because both arms run on one binary in one
>    window.
>
> Also observed and worth keeping: **arm C's 29-tool pool contains `Task`**, so its zero
> delegations are a fact about behaviour, not about capability.

---

## Predict before you run

1. Four agents (analyze/plan/execute/verify) vs one agent, same task — which uses more
   total tokens? By how much?
2. Which uses more *wall-clock*?
3. What will stage 3 not know that stage 1 knew?
4. At what task size does decomposition start to pay?

## Lab 4B.1 — Pipeline vs monolith

The same task twice: as one agent, and as ANALYSIS → DESIGN → IMPLEMENTATION →
VERIFICATION → REVIEW.

Measure total tokens, wall-clock, correctness, diff size, and scope discipline.

> Expect the pipeline to cost **more** tokens and produce a **tighter** diff. If it costs
> more and produces the same diff, you have found overhead.

## Lab 4B.2 — Orchestrator/worker fan-out

A task with genuinely independent parts. Fan out, then join.

Where does parallelism pay, and where does coordination eat the gain? Watch for the
barrier: if one worker is slow, the whole join waits.

## Lab 4B.3 — Handoff fidelity

Give stage 1 a piece of information that stage 3 needs and stage 2 has no reason to
forward. Does it survive?

This is the failure mode that makes multi-agent systems mysteriously worse than a single
agent — **nobody loses information visibly.** Design the handoff contract explicitly, then
test that it carries what you think it carries.

## Lab 4B.4 — When decomposition loses

**The most important lab here.** Run a task too small to split.

Most multi-agent material assumes more agents is better. You have an instrument that can
prove otherwise. Measure the overhead and write it down.

> "Consider adding complexity **only** when it demonstrably improves outcomes."

## Exit gate

- [ ] Workflow vs agent — who chooses the next step
- [ ] Name all five patterns and which one your v1 uses
- [ ] Why context isolation, not specialization, is the reason to split
- [ ] What your handoff contract carries, and what it drops
- [ ] **The task size below which decomposition costs more than it returns — as a number**
- [ ] When orchestration should be deterministic code rather than a model decision

## Commit

```
.claude/agents/*.md · workflow definition
findings/B4b-orchestration.md
```
