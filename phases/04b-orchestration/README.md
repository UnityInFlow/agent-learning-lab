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
