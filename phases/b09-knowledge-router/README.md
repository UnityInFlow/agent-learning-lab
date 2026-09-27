# B9 — Knowledge router and hit rate

**Track A first:** [Phase 6A](../06a-code-intelligence/) + [Phase 6B](../06b-knowledge-retrieval/) · **Layer 3 — untrusted**
**Version:** **v1.2**
**Spine position:** 20 of 28 · after [Phase 6B](../06b-knowledge-retrieval/) · before [B10](../b10-second-runtime-adapter/)
**Status:** 🟨 open — spine stop 20, opened 2026-09-26 on `stop20/b9-knowledge-router`

> Build and Exit gate are quoted from [`build/README.md`](../../build/README.md#b9).
> Everything else is yours to fill.

---

## Goal

Build the knowledge router the requirement asks for — `knowledge/index.yaml`, triggers →
summary → full document — instrument the hit rate it asks for, and then measure the thing the
gate does **not** ask for: whether any of it changed the run.

The gate has three clauses, and they are not equally closable by this instrument. Phase 6B
measured that, and its finding is the reason this stop's design is what it is:

| Gate clause | Closable here? | By what |
|---|---|---|
| retrieval order recorded per run (index → summary → full) | **not by the telemetry** | only by the router writing its own log inside the run's tree — which makes the record an artifact of the **treatment**, not of the instrument, and that has to be said in the §5 table's layer column rather than hidden in it |
| hit rate measured | yes | the same self-written log |
| context metrics compared against B8 | yes, in the one sense the instrument has | five token counters on the run record; there is no field that measures a corpus or a retrieval footprint |

**So the honest shape of this stop is: two of the three clauses close on an artifact the
treatment writes about itself, and the third closes on token counts.** A gate that measures
the retrieval and not the consequence can pass with nothing changed — `build/README.md#b9`
says so itself (*"you can prove RAG **ran**, not that it **helped**"*), and this workbook's
registered outcome is therefore a property of the run and not a property of the router.

Both tasks, per author decision 9: **BE-003 and BE-004**, separate experiment keys, separate
prediction commits, separate concurrent controls, separate MDE tables, separate §5 rows, and
**no verdict computed across tasks**.

## Required reading

### Internal — the requirement

Opened and quoted, not listed. Line numbers are as of `1d9e26a`.

| Source | Lines | What it gives this stop | Layer of the thing it describes |
|---|---|---|---|
| [`businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md`](../../businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md) §10.9 | 491-505 | `.ai/knowledge/index.yaml` and its exact shape: `topics: <topic>: triggers: […] summary: … details: …`. Its stated why: *"The agent should discover relevant knowledge without loading the whole knowledge base."* | **L3** — a YAML example in a design document; nothing reads it |
| same, FR-009 | 675-677 | *"The agent should load index, summary, and full knowledge progressively."* | **L3** — the word is *should*, and no script checks it |
| same, FR-010 | 679-681 | *"Where observable, unchanged documents should be reused from a cached summary or artifact."* — note **"where observable"**: the requirement itself concedes the measurement may not exist, and Phase 6B measured that it does not | **L3** |
| same, source principle 8 | 55 | *"Knowledge should be loaded progressively: index, summary, then full document."* — the principle the `index → summary → full` clause in the gate is quoting | **L3** |

Four citations, four L3s. **Not one clause of this requirement executes anywhere in the three
repositories today**, and that is the distance this stop has to cover — the same distance B8
faced at stop 17 with §10.6's seven completion clauses.

### Internal — Track A, and the six findings that constrain this stop

Phases 6A (stop 18) and 6B (stop 19) are closed and merged. Their extracts are not re-derived
here (§1). Six of their findings decide what this stop may claim, and every one of them is a
measurement rather than a reading.

- **6B finding 3** (`../06b-knowledge-retrieval/README.md:139`) — B9's clause *retrieval order
  recorded per run* cannot be closed by this instrument. Three independent facts: no run-record
  key can carry a read; tool arguments are deleted at ingest on purpose; the per-tool-name
  breakdown is computed and then dropped.
- **6B finding 4** (`:177`) — there is no router, no `index.yaml` and no `knowledge/` directory
  anywhere in the three repos, so **B9 has no baseline hit rate to beat**. Its first number is a
  first measurement, not an improvement.
- **6B finding 6** (`:225`), **with the narrowing correction appended to it at `:248-256`** —
  this project has measured twice that prose delivered **unconditionally** into context moves
  nothing it can see (E-003 `REJECT` at n = 10 per arm; E-009 at 0 of 10 with the words
  verbatim). The correction is load-bearing and is honoured below: retrieval is **conditional**
  delivery, which neither null tested, so those nulls are a **strong prior and not a result**
  for this stop.
- **6B finding 7** (`:260`) — just-in-time retrieval is what this harness already does by
  Anthropic's own definition, and it has **never been a treatment** in this track. Only the
  pre-loaded half of the hybrid has been measured, and it was null.
- **6A findings 3 and 4** (`../06a-code-intelligence/README.md:106`, `:136`) — the MCP route to a
  corpus is doubly unavailable: the approval prompt does not fire in `claude -p` (every run this
  project makes), and `mcpHash` is null by construction on every run ever recorded, so a
  corpus delivered over MCP could be neither refused nor proved. **This stop's corpus is
  therefore files in the worktree, not an MCP server** — a design consequence of a measurement,
  not a preference.

### External — the technique

**Nothing new is read for this stop, and that is a decision, not an omission.** The technique
B9 implements is progressive disclosure, and its canonical source —
`https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents` — is
already in [`SOURCES.md`](../../SOURCES.md) under `### Context and knowledge` at `:202`,
verified at stop 19 and read there. The other three entries in that section (`:203-205`, the
MCP specification, the MCP resources spec and the LSP spec) were read at stops 18 and 19 and
produced 6A findings 3–5 and 6B findings 1–2 — which is precisely why this stop does not use
MCP.

`SOURCES.md` therefore gains no new entry at this step and `check-links.sh` has nothing new to
check. It was run anyway, to record the current state rather than assert it:

```
$ ./tools/check-links.sh
ok=66 moved=11 blocked=2 unverified=0 broken=0
exit 0
```

Adding a fresh RAG or vector-search citation here would be decoration: the build spec forbids
a vector DB, and the one thing an embeddings source could tell us is the thing this stop exists
to measure first.

## Extract

Not a reading of documents. **Six facts measured off the three repositories at `1d9e26a`**,
each one re-derived in the main context after a subagent reported it, because each constrains
what this stop can claim. Four of them change what the build has to be.

### 1. B9 builds from zero, and that is now `find`-proved rather than read

```
$ find agent-learning-lab agent-observatory agent-observatory-benchmarks -type d -name knowledge …
0
$ find … -name 'index.yaml' …
0
```

and `grep -rln 'knowledge_hit_rate\|knowledge/index\|hit_rate'` over `*.sh *.py *.yaml *.yml
*.ts *.kt *.md` returns **8 hits, every one of them a `.md`** — two business-case documents,
`phases/09-memory/README.md`, `build/README.md`, the two Track A workbooks, and two opencode
review files. **Zero hits in any executable extension.** There is no router to regress
against, no stored hit rate, and nothing to port. 6B finding 4 stands, re-measured.

### 2. Clause (a) is still unclosable by the instrument — the probe was re-run, not cited

`evidence/p06b/retrieval-trace-probe.sh`, re-run this session over all three
`events*.jsonl` files:

```
exit 0
verdict: NO FILE-NAMING VALUE FOUND over a non-empty population, at ANY of the three
         sensitivities — including PATHY, which needs no extension.
population: run_ids=638  read_events=12894  log_records=71353
```

Exit 0 is defined in the probe's own header (`:66`) as *scan completed, population non-empty,
and no value matched* — i.e. **the instrument cannot record a retrieval**; exit 6 (`:74-79`)
would have meant the schema moved. It did not. 12 894 `Read` events across 638 runs name no
file at any sensitivity.

The consequence for this stop is exact: **the only way a retrieval gets recorded is if the
router records it**, and a record the treatment writes about itself is evidence about the
treatment's own behaviour, not independent evidence that the retrieval happened. That goes in
the §5 layer column as what it is.

### 3. "Context metrics" exist, but only as five token counters — there is no context metric

The gate's third clause is computable, and it is worth being precise about what it computes.
The authoritative field list, read in `agent-observatory/observatory-web/src/api.ts` and
confirmed against a live record from `http://127.0.0.1:8081/api/runs?limit=1`:

| Type | Fields | Token/context-sized? |
|---|---|---|
| `Behavior` (`api.ts:11-21`) | `modelCalls`, `toolCalls`, `toolFailures`, `retries`, `permissionRequests`, `permissionDenials` | **none** |
| `Efficiency` (`api.ts:23-30`) | `durationMs`, `inputTokens`, `outputTokens`, `cachedTokens`, `cacheCreationTokens`, `estimatedCost` | `inputTokens`, `outputTokens`, `cachedTokens`, `cacheCreationTokens` |

The live record carries one more, `reportedTotalTokens`, which is **not in the TypeScript
type** — a drift worth recording, not a new kind of measurement.

So *"context metrics compared against B8"* means **five ordinary LLM token counters**. Nothing
on the record measures how much of the context was knowledge, how much was the corpus, or
what fraction of a retrieval was used. A router that loads a summary instead of a whole
document is a claim about context composition, and **context composition is not measurable
here at any fidelity** — only the total is. Clause (c) closes; what it closes on is cost.

### 4. The comparison target is a stop that moved nothing, on both tasks

B8 (stop 17) is what clause (c) compares against, and its numbers are the reference population
for this stop's MDE. From the closed experiments:

| | BE-003, `EXP-B8-RUNSTATE-BE003` | BE-004, `EXP-B8-RUNSTATE-BE004` |
|---|---|---|
| `n` scored | 10 treated, 10 control (`E-018`) | 9 treated, 7 control (`E-019`) |
| all four rubric categories | **every delta 0** (`E-018:352-357`) | three deltas 0, `change-focus` +1 and declared unmeasurable (`E-019:350-355`) |
| `estimatedCost` median | `$0.119766` [0.102048–0.144211] treated · `$0.116974` [0.101403–0.140168] control (`E-018:335`) | `$0.209355` [0.195181–0.257077] treated · `$0.200527` [0.191364–0.208626] control (`E-019:337`) |
| verdict | `KEEP AS L2, WITH NO MEASURED EFFECT` (`E-018:450`) | same on three categories (`E-019:466`) |

**A comparison against B8 is a comparison against a null.** That is not a complaint about B8 —
its own workbook predicted it — but it fixes what clause (c) can mean: the B8 cost medians
above are the baseline interval, and anything inside them is inside the noise of a stop that
changed nothing.

### 5. The overlay reaches the worktree, and **nothing hashes a corpus**

The delivery mechanism exists and is proved per run for three artifact classes and not for a
fourth:

- `agent-observatory/runner/run-agent.sh:338` — `cp -R "$CUSTOMIZATION_DIR"/. "$WORKTREE"/`, with
  the tracked-file list built at `:360-362` and forced past `.gitignore` with `git add -f` at
  `:365-371`. So a `knowledge/` directory in an overlay **does** arrive in the run's tree.
- the hash block at `:572-648` emits exactly four fields (`:640-645`): `instructionsHash`
  (one file), `skillsHash` (`:616`, the set of `SKILL.md`), `agentHash` (the one dispatched
  agent file) and `agentsHash` (`:631-638`, the set of `.claude/agents/*.md` — **new, obs#88
  merged at stop 17a**).

**A corpus is hashed by none of them.** This is the third time the same hole has decided a
design: B8 met it at stop 17 (finding 3, "no hash can prove B8's treatment was delivered"),
B8a met it at 17a and fixed the agents half with `agentsHash`, and B9 meets it for
`knowledge/`. The delivery proof for this stop therefore cannot be a run-record hash and has
to be built — which makes it the same class of artifact as B8's, and it is designed below
rather than assumed.

### 6. The leak check greps names, so the corpus's *content* is uncontrolled

`run-agent.sh:259-262` asserts the worktree holds a single commit and then greps the reachable
git object paths for `^tasks/`. It matches **path names only**. So a corpus file whose text
reproduces benchmark material passes undetected — 6B finding 5, re-derived.

This is a constraint on what may go in the corpus, and it is a hard one: **nothing in the
corpus may be derived from the task's own tests, fixtures or evaluator.** Section *Design*
below states where the corpus content does come from, and why that source is the one B6 already
used.

### What this stop takes forward

1. The router has to write its own retrieval log, because nothing else can (fact 2).
2. The registered outcome has to be a property of the run, because the hit rate is a property
   of the router and the gate cannot see the difference (Goal, 6B finding 6 as narrowed).
3. There is no baseline, so the first number is a first measurement (fact 1).
4. The delivery proof has to be built; no hash covers a corpus (fact 5).
5. Clause (c) is a cost comparison against a stop that moved nothing (facts 3 and 4).
6. The corpus may not be derived from the task's own test material (fact 6).

## Build

**Build:** `knowledge/index.yaml` — triggers → summary → full document. **Not a vector DB.**

```yaml
topics:
  spring-transactions:
    triggers: [transactional, rollback, multiple repositories]
    summary: summaries/spring-transactions.md
    details: documents/spring-transactions-deep-dive.md
```

**Then instrument it:**

```
knowledge_hit_rate = useful knowledge matches / knowledge lookups
```

That number is what later justifies — or refuses — embeddings. Without it you can prove RAG
*ran*, not that it *helped*.

**Do not build a code or symbol index.** memtrace already provides `find_symbol`,
`find_code`, the AST graph and Cortex decision memory, and you pay for it every session.
Building vector search over your own repository duplicates a tool you already run. See
[Phase 9 — Architecture](../09-memory/README.md#architecture-you-already-run-three-memory-systems).

## Design — spine stop 20, 2026-09-26

*Designed by Opus 5 (claude-opus-5), autonomously, 2026-09-26; the author did not review before
the run.*

### The trap, named from `build/README.md#b9`, and the layer that converts it

The build spec names two traps and the workbook header names a third.

| Trap, verbatim | What it would look like if it caught us | The layer that converts it |
|---|---|---|
| *"Without it you can prove RAG **ran**, not that it **helped**."* | a closed gate: retrieval order logged, hit rate 0.8, cost compared — and not one number about the code the run produced | **L2 by registration**: the primary outcome is a rubric category, a property of the run. The hit rate is reported and **decides nothing** — it is written into the decision rule as a row that cannot fire |
| *"Do not build a code or symbol index. memtrace already provides `find_symbol`, `find_code` […]"* | an embedding store over our own repo | **L1 structural**: there is nothing to embed. The corpus is four hand-written files about one language construct and the router is trigger matching. A vector index cannot be written down in this design because no vector is computed anywhere in it |
| the header's own **Layer 3 — untrusted** | trusting a retrieved summary because it was retrieved | **L3, and deliberately left there.** Retrieved text is input and input can be wrong. Nothing in this stop validates a summary's content. §4 step 9's deliberate failure puts a **wrong** summary in the index and measures whether the agent follows it — which is the demonstration, not a fix |

### The artifacts, and their layers

Applying the workspace `CLAUDE.md` rule in order, stopping at the first yes.

| Artifact | What it is | Layer of the artifact | Why that layer and not the one above it |
|---|---|---|---|
| `knowledge/index.yaml` | §10.9's shape exactly: `topics: <topic>: triggers: […] · summary: … · details: …` | **L3** | a wrong trigger list is writable and nothing executes to reject it |
| `knowledge/summaries/*.md` and `knowledge/documents/*.md` | the corpus: one topic, a summary and a detail document | **L3** | prose read by a model |
| `.agent/knowledge-router.sh` | takes a query string, matches triggers case-insensitively against `index.yaml`, prints the summary path and then the details path, and **appends one JSON line per lookup to `.agent/knowledge-log.jsonl`** | **L2 for "a lookup was recorded"** · **L3 for "a lookup happened at the right point"** | it executes and it writes, so the record is not a claim. But it enforces nothing: it cannot make the agent call it, and it cannot make the agent read what it returned |
| the overlay `CLAUDE.md` clause telling the agent the router exists and to consult it before writing status-branching code | words in context | **L3** | and this is the load-bearing L3 of the whole stop: if the agent ignores it the treatment is inert. That is measured at preflight, not assumed — see below |
| `knowledgeHash` in `run-agent.sh` + its fixture set | the per-run delivery proof extract fact 5 says does not exist: hashes the **set** of corpus files the way `skills_hash()` hashes the set of `SKILL.md`s, and is `null` where there is no corpus | **L2** | it runs on every run and its value differs when the corpus differs; the fixture set is what proves it refuses rather than that it agrees |
| `tools/verify-knowledge-router.sh` | fixture set proving the router's exit codes — a hit, a miss, a malformed index, an unreadable corpus path, a trigger that matches two topics | **L2** | *a control that has never been shown to reject anything is indistinguishable from one that rejects nothing* |

**The corpus lives in the overlay directory, not in an MCP server.** That is 6A findings 3 and 4
applied: over MCP the approval prompt does not fire in `claude -p`, so the corpus could not be
refused, and `mcpHash` is null by construction on every run ever recorded, so it could not be
proved. Files in the worktree can be both.

### The registered outcome, and why it is `maintainability`

The outcome must be a property of the run (Goal). Four things on the record are: the four rubric
categories. Of those, one has a measured, repeated, **untreated** failure — and B6, the track's
only clean positive, is the precedent for choosing a treatment from exactly that.

**`maintainability` anchor 2 across every B step that measured it, per task:**

| Step | BE-003 anchor-2 count | BE-004 anchor-2 count |
|---|---|---|
| B5 (stop 12) | `0 ×7, 2 ×3` in **both** arms — 3 of 10 each, `p = 1.0`, *"the identical distribution"* (`E-010:668`) | floored at 0 (recorded at stop 12, cited forward at `E-013:601`) |
| B6 (stop 13) | **2 of 10** treated · **5 of 10** control, `p = 0.35` (`E-012:659`) | **0 of 10** treated · **0 of 10** control — *"floored at 0 on 20 of 20"* (`E-013:601`) |
| B7 (stop 15) | `0 0 0 0 2 2 2 2 2 2` treated (6 of 10) · `0 0 0 0 0 0 2 2 2 2` control (4 of 10) (`E-015:406`) | median 0 both arms, `n = 7` each, per-run values not tabulated (`E-016:481`) |
| B8 (stop 17) | `[0 ×7, 2 ×3]` **both** arms — 3 of 10 each (`E-018:355`) | `[0 ×8, 1]` treated · `[0 ×7]` control — **the single non-zero is a 1, the residual, not anchor 2** (`E-019:353`) |

Two different shapes, and each is useful for a different reason:

- **BE-003 is bimodal with real headroom and high variance.** Anchor-2 rates across the eight
  measured arms run **2 of 10 to 6 of 10**; pooled over all eight, **29 of 80 = 0.3625**, and over
  the four control arms alone, **15 of 40 = 0.375**. No arm has ever reliably reached anchor 2,
  and no treatment has ever moved it beyond noise.

  > **Correction, same day, same session.** The first version of this paragraph — carried into
  > commit `c90b157`'s message, where it cannot be edited — read *"pooled, 17 of 50"*. That number
  > was summed in prose rather than computed, which is the exact error stop 19's method lesson
  > names. Computed: `3+2+6+3 = 14` of 40 treated and `3+5+4+3 = 15` of 40 control, **29 of 80**.
  > The direction of the finding is unchanged; the denominator was wrong by 30 runs.
  > *Corrected by Opus 5 (claude-opus-5), autonomously, 2026-09-26, before the first prediction
  > commit and therefore before any run.*
- **BE-004 is a floor.** Across the arms whose per-run values are recorded — E-013's 20 runs and
  E-019's 16 — anchor 2 was reached on **0 of 36**. B7's 14 runs report medians of 0 without
  per-run values, so they are consistent with the floor and are **not counted into it**. Anchor 2
  is nevertheless *reachable* on this task: E-011's fixture proof records `known-good` deciding
  on *"an exhaustive `when (order.status)` in expression position"* (`E-011:344`). The model
  simply never gets there.

**Why this category and not another.** What anchor 2 asks for is a *fact about Kotlin*: a `when`
in expression position must be exhaustive, so the compiler enforces the case list, and an
`if`/`else if` chain silently routes a new enum constant down the fallback path
(`benchmark/rubrics/backend-quality.yaml:138-161`). That is knowledge — the thing a knowledge
corpus is for. Every treatment this track has tried since B3 has been a *process* instruction:
phases, a verification gate, a run-state file, a repair limit, an agent boundary. **None of them
was a technical fact, and a knowledge router is the first step whose payload can be one.**

**Why it is untreated.** B6's skill is the nearest thing to a technical treatment this track has
built, and it is about tests only — its own *When this does NOT apply* section opens *"You are
not writing a test. This skill has nothing to say about production code."*
(`build/customizations/skill-v1.1-testing/.claude/skills/testing-and-verification/SKILL.md`).
It never names `when`, expression position or enum dispatch. E-012's maintainability cell moved
*down* under it, 2 of 10 against 5 of 10 at `p = 0.35` — noise, and in the wrong direction.

**The cost of this choice, registered rather than discovered.** B6's skill body is written from
`test-quality`'s anchor clauses very nearly verbatim — the separate `get(...)`, the body
assertion, the error envelope's code are all three in the anchor and all three in the skill. So
writing this corpus from `maintainability`'s anchor is **methodologically identical to the
track's one clean positive**, and that is the reason it is allowed here. What it costs is stated
in both experiment files as a limit on the claim: **the outcome measures whether routed
knowledge reaches the model and is used, not whether the model could have discovered the
construct unaided.** The second question needs a corpus written from something other than the
measuring instrument, and this stop does not ask it.

Extract fact 6 binds the rest of the content: **nothing in the corpus is derived from either
task's tests, fixtures or evaluator.** The source is the rubric's own anchor text plus the Kotlin
language rule it depends on, and the corpus names neither `confirm` nor `cancel`.

### One variable, and the confound this design registers rather than resolves

**Independent variable:** the knowledge corpus, its router and the instruction to consult it —
present as one overlay, or absent. Everything else is B8's v1.1 overlay unchanged, so the arm
this stop adds sits on top of a version whose own measured effect was zero.

**The confound, stated before the run:** a positive result here cannot be attributed to the
*routing* rather than to the *prose*. Distinguishing them needs a third arm carrying the same
text unconditionally — and **a new arm is a §7 halt** (§7, final bullet), so this design
registers the confound instead of resolving it.

What narrows it, and how far: E-003 (`REJECT`, n = 10 per arm) and E-009 (0 of 10) both measured
prose delivered unconditionally and both found nothing. **But both delivered generic *process*
prose** — 57 words of house rules, and an implementer's four-row report shape — never a
task-specific technical fact. 6B finding 6 carries that narrowing itself, appended at
`../06b-knowledge-retrieval/README.md:248-256`: those nulls are a **strong prior for this stop
and not a result about it**, and neither experiment file cites them as one.

### What this step does not build, and why

- **No embeddings and no vector store.** The build spec forbids it and memtrace already answers
  the question it would answer. There is no vector anywhere in this design, which is why that is
  L1 here rather than a rule someone follows.
- **No 6B write path.** A corpus the agent writes to is self-learning, which is stop 27 (§6).
- **No MCP server.** 6A findings 3 and 4: unrefusable in `claude -p`, unprovable in the record.
- **No loosening of `infra/otel-collector/config.yaml:48`'s scrub.** It is deliberate and
  documented, so changing it changes a repo convention and is the author's — carried as
  `author_notes` item H since stop 19.
- **`toolBreakdown` is not promoted into the `Run` type**, and this is the one omission worth
  naming twice. Doing it (`runner/lib/claude-telemetry.sh:136-139` already computes the value;
  `observatory-web/src/api.ts:11-21` drops it) would make a retrieval record **independent of the
  treatment**, which is exactly the weakness fact 2 forces this design to carry. It is a
  separate instrument PR with a schema migration, it is not this stop's build, and it is
  recorded in `TRACK-B-STATE.md` `author_notes` as *the single change that would most improve
  this stop's evidence*.

### The assumption that gets proved at preflight rather than asserted here

**That the agent, told an L3 instruction, calls the router at all.** If it never does, the hit
rate is `0 / 0`, the corpus is a file nobody opened, and the experiment has measured an
instruction nobody followed — which is a **result**, and the same shape as E-005's description
arm, where a read-only description produced zero write attempts and therefore tested nothing.
It is not an assumption this design gets to make.

So §4 step 5's preflight checks, on one run per arm and before any batch:

1. `knowledgeHash` is set on the treated run and `null` on the control.
2. `.agent/knowledge-log.jsonl` exists in the treated run's kept worktree and has **at least one
   line**; it does not exist in the control's.
3. the corpus files are present in the treated worktree at the same sha they have in the overlay.

A preflight that fails (2) is reported and the batch is **not** started until the instruction is
the thing being tested rather than the thing being hoped for — B8's stop-17 preflight and B6's
stop-13 preflight both stopped a batch on exactly that check.

## As built — §4 step 4, 2026-09-26, and the one thing the design got wrong

*Built by Opus 5 (claude-opus-5), autonomously, 2026-09-26. Nothing above is rewritten. Two
corrections are recorded here rather than by editing the design table, because a design that is
quietly corrected teaches nothing.*

### The files, with the shas the batch driver asserts

| path | sha256 (first 32) | note |
|---|---|---|
| `build/customizations/agent-v1.2-knowledge/CLAUDE.md` | `ebf489800a60a156986f98ea4f127848` | v1.1's 59 lines **byte-identical**, verified by `diff <(head -59 …) agent-v1.1/CLAUDE.md`, plus one appended section naming the router |
| `.claude/agents/backend-feature-phases.md` | `b3450564b6f32d61…` | byte-identical to v1.1 — the same value B8's driver asserts as `EXPECT_AGENT_HASH` |
| `.claude/settings.json` | `925a382322daada4…` | byte-identical to v1.1 |
| `.ai/policies/protected-paths.yaml` | `76c4c34c0f4ca5eb…` | byte-identical to v1.1 |
| `.ai/hooks/policy-gate.sh` | `f432abbcbf1f3b90…` | byte-identical to v1.1 |
| `.ai/hooks/repair-limit.sh` | `fa38193a5093c09b…` | byte-identical to v1.1 |
| `.ai/hooks/repair-record.sh` | `7339e63045fa4e2a…` | byte-identical to v1.1 |
| `.ai/knowledge/index.yaml` | new | §10.9's shape, one topic, ten triggers |
| `.ai/knowledge/summaries/kotlin-exhaustive-when.md` | new | 30 lines |
| `.ai/knowledge/documents/kotlin-exhaustive-when.md` | new | 117 lines |
| `.ai/knowledge/router.sh` | new | ShellCheck clean, `cd … || exit`, six exit codes |

A measured version is never edited (§3), so v1.1 was **copied** and the six files above are
proved identical rather than assumed to be. The corpus names **no** task word: `grep -ci
'confirm\|cancel\|shipment\|order'` returns `0` on all three corpus files.

### Correction 1 — the design table named the router in the wrong place

The artifact table above reads `.agent/knowledge-router.sh`. The registered experiment file reads
`.ai/knowledge/router.sh` (`E-022:89`, in the independent-variable table); `E-023` names the
same set as *"under `.ai/knowledge/`"* (`E-023:88`, `:97`) without naming the script, and
`TRACK-B-STATE.md`'s `next_action` reads `.ai/knowledge/router.sh` too. **The experiment file is the registered contract and it wins**: the router is at
`.ai/knowledge/router.sh`, inside the set `knowledgeHash` covers. The design table's cell is left
as written.

### Correction 2 — the log could not go where it was registered, and this is the load-bearing one

The registered delivery proof was `.agent/knowledge-log.jsonl`, **inside the worktree**. It is
now written **outside** it, at
`${KNOWLEDGE_EVENT_LOG:-${TMPDIR:-/tmp}/knowledge-log-$(basename "$ROOT").jsonl}`, with the run
id in the file's own name. The full reasoning, the evaluator lines it was read off, and what the
change gives up are recorded as **Amendment 1** in both `experiments/E-022-knowledge-router-BE003.md`
and `experiments/E-023-knowledge-router-BE004.md`. In one line: both evaluators count untracked
files outside the allowed prefixes as an AC7 scope violation and score **exit 21**
(`BE-003 evaluator.sh:110-127,279-296`; `BE-004 evaluator.sh:119-127,296-302`), `.jsonl` matches
no ignore rule, and B7 already lost two correct runs to exactly this
(`E-016:227-237`) — which is why v1.1's own two hooks write under `$TMPDIR` and say so in their
headers (`policy-gate.sh:27-47`, `repair-limit.sh:30-37`).

**The layer consequence, stated rather than buried:** preflight condition (b) still proves *a
lookup was recorded* (L2), and no longer proves anything at all about the run's own tree. Phase
6B finding 3's second route — a retrieval record that is an artifact of the run rather than of
`$TMPDIR` — is **not built at this stop**, and the §5 table's layer column says so in the row it
applies to.

### The control that was shown to refuse

`tools/verify-knowledge-router.sh` — 15 cases, **18 assertions, 18 passed, exit 0**, ShellCheck
clean. It drives every documented exit code on the real script against synthetic indexes: hit
(0), an upper-case query, a multi-word trigger, miss (2), no query (1), index missing (3), no
`topics:` key (3), zero topics parsed (3), a topic with no `details:` (3), an absent summary file
(4), an absent details file (4), two topics matching one query (5), the log carrying one line per
invocation with all six statuses present, and the **shipped** index answering the query the
overlay's own `CLAUDE.md` tells the agent to ask.

Two things make it more than a green tick. **Case O mutates the router** — makes a miss exit 0 —
and asserts that case D would then fail; a fixture set that cannot fail is indistinguishable from
one that tests nothing. And **case L was re-derived by hand** outside the verifier, at
`/tmp/b9hand`, returning `rc=5`, stderr `2 topics match (alpha, beta)` and a log line with
`"matches":2`.

**Case M's expected count was wrong on its first run and the failure is kept in this record**: it
read 13 where twelve invocations precede the check. Counted rather than summed — A B C D E F G H I
J K L, with `A order` re-reading A's stdout and case N running after the check. That is stop 19's
method lesson landing on its own author inside the same session.

## §4 step 5 — the preflight refused the batch, and the refusal is the finding

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-26. The full record, with every path and
number, is **Amendment 2** in `experiments/E-022-knowledge-router-BE003.md` and
`experiments/E-023-knowledge-router-BE004.md`. This section is the short version and the layer
reading.*

Four runs, `evidence/b09/preflight-20260926T124800Z/`, exit **2**. All four solved their task.
Conditions (i) and (iii) **held** — `knowledgeHash` set on treated and `null` on control, the corpus
in each treated worktree hashing to the overlay's registered value, and the `init.tools` read-back
returning `["Read","Edit","Write","Bash"]` with verdict `match` on all four. Condition (ii) — the
router's own log — was **ABSENT on both treated runs**, so no batch was started.

**The cause was the harness.** On BE-003's treated run `fbdebf75` the agent called
`.ai/knowledge/router.sh "state transition validation error codes"` at its first opportunity and the
call is in the run's `permission_denials` array. `repair-limit.sh` recorded nine allows and zero
blocks, so the treatment's own hooks did not refuse it; `run-agent.sh`'s allowlist did — with
`--permission-mode acceptEdits` and `--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"`, every Bash
command that is not mvn is denied and `claude -p` has nobody to ask.

**Had the batch run, it would have reported this stop's registered VOID row about an agent that
followed the instruction immediately.** That is the design section's own *"the assumption that gets
proved at preflight rather than asserted here"*, and it is the reason that paragraph exists — but it
named the wrong failure. It anticipated an agent that ignores an L3 instruction. What happened is an
**L2 control in the harness forbidding the treatment's only mechanism**, which no amount of L3
uptake could have overcome.

### The layer correction this forces, and it belongs in the §5 table

The design table calls `.ai/knowledge/router.sh` **L2 for "a lookup was recorded"** and **L3 for "a
lookup happened at the right point"**. Both still hold. What the table did not say is that the
*ability to record a lookup at all* sits behind an **L2 control the treatment does not own**: the
runner's Bash allowlist. A treatment whose mechanism is a command is only deliverable if something
outside the overlay permits that command — and the probe below shows the overlay **cannot** permit it
itself.

| what | who owns it | layer | observed |
|---|---|---|---|
| the corpus reaching the worktree | the overlay | **L2** — `knowledgeHash`, `git`-committed setup commit | held, 2 of 2 treated runs |
| permission to execute the router | **the runner, not the overlay** | **L2** | **refused**, 1 of 1 attempts, until obs#90 |
| the agent choosing to call the router | nobody — it is a sentence | **L3** | attempted unprompted on BE-003; not attempted on BE-004 (`n = 1` each) |

### The fix was chosen by probe, and the probe's negative result is the transferable finding

`evidence/b09/router-permission-probe-20260926T130051Z/`, three arms, one model call each. Settings
as shipped: **denied**. A `permissions.allow` entry in the overlay's own `.claude/settings.json`:
**denied, and the entry ignored** — *"this workspace has not been trusted"*. The runner's
`--allowedTools`: **`permission_denials":[]`** and the router wrote
`{"status":"hit","topic":"kotlin-exhaustive-when",...}`.

The overlay route was tried first because a treatment's precondition belongs in the treatment. It
does not work, and the reason generalises past this stop: **every benchmark worktree is a new temp
directory, untrusted by construction, and the runtime's own remedy is a user-scope mutation that
`--isolate-user-settings` exists to prevent. A treatment in this harness cannot grant itself a Bash
permission.** Any later step whose treatment is a command inherits that constraint.

### What the instrument learned, and it is one line in two drivers

An absent log had **two** causes and the first version of the check conflated them: BE-003 treated
attempted the router and was refused; BE-004 treated never attempted it. Same `ABSENT`, opposite
meanings, and only the second is what the VOID row is about. Both drivers now record
`router_mentions` and `router_denied` per run — hand-checked against these four logs — and a treated
denial prints *"do NOT report this as the decision rule's VOID row"*.

Its own counting expression was wrong twice before it was right, both times in ways this repository
already records: `grep -c` counts **lines** with a match, so two calls on one stream-json line count
once (the b08 driver's note says exactly this), and `grep -c … || echo 0` prints grep's `0` **and**
the fallback `0`, putting a newline inside a manifest field. Corrected to `grep -o … | wc -l`, and
the column is named `router_mentions` rather than `router_calls` because one call appears in the
stream three times.

## §4 step 6 — the batch, and the two things that had to be decided before it could continue

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-26. The numbers and their derivations are
in [`E-022` Amendment 4](../../experiments/E-022-knowledge-router-BE003.md); this section records the
two decisions and their layers, which is what a workbook is for.*

**Decision 1 — the population stays at `n = 10` per arm per task (option (a)).** The account spent
the 15:13Z–16:30Z stretch inside a saturated five-hour rate window: every call `allowed`, none
refused, and 11–17 minute gaps between them, so one treated run took 90 minutes where the preflight
measured 127 seconds. The window reset at 16:30:00Z, utilization came back at **0.02**, and the runs
after it took ~2 minutes again. Reducing `n` would have forfeited E-022's prediction 1 (a one-arm
binomial at ≥ 8 of 10) and E-023's whole verdict (row 0: `n_t < 7 or n_c < 7` ⇒ NOT COMPUTED) to buy
time the account had already returned. This is **not** a §7 halt — that bullet is about exhaustion
that does not clear after one retry past its published reset, and nothing here was ever refused — so
it is recorded in `author_notes` and the run continues.

**Decision 2 — the batch is resumed, never restarted.** Four runs and one unrowed-but-complete run
already existed. Re-running them would have created duplicate benchmark evidence, which §6 forbids
deleting and §0 forbids creating. So the driver learned to resume.

| artifact | what it is | layer, by the rule in order | what converts the trap |
|---|---|---|---|
| `run-b9-batch.sh --resume <TAG>` | re-enters one manifest, skips recorded cells, seeds the per-task cost | **L2** — it executes, and it refuses at exit 13 | a resume that joined a differently-registered batch would pool two populations under one tag; three refusals (no manifest, wrong corpus/agent/instruction shas, wrong `n`) make that unwritable-after-the-fact |
| its detached launch (`os.setsid()`) | the batch is no longer a child of the claude session | **L2** — a process-session boundary the OS enforces | the §0 phase-boundary rule requires the launching session to end; twice today that killed the batch |
| `verify-b9-batch-guards.sh` cases N–Q | 17 of 17, four of them new | **L2** — the fixtures run and two of them failed first | case O passed for the wrong reason in its first version, which is the house failure mode inside a control; case Q exists because a dry run mutated a real manifest |
| E-022 Amendment 4 | the record of both decisions and the exclusions they imply | **L3** — words, and labelled as such | nothing executes to keep a workbook honest; this row says so |

**What was decided about the runs already on disk, and nothing about their scores.** `durationMs` is
excluded for the runs paced inside the saturated window and the runs are kept — E-022's Exclusions
already register that treatment for a batch split by a machine sleep, and no registered outcome reads
duration. The one complete-but-unrowed run is excluded and **replaced**, under the same registered
rule and the same precedent `ORPHAN.md` set four hours earlier in this stop; its log, worktree and API
record stay on disk and are named. Author decision 13's multiplier of 11 against a population of 10
is what pays for the replacement.

## Predict before you run

Registered in two experiment files, one per task (author decision 9), each committed before its
first run:

- BE-003 — [`experiments/E-022-knowledge-router-BE003.md`](../../experiments/E-022-knowledge-router-BE003.md), key `EXP-B9-ROUTER-BE003`
- BE-004 — [`experiments/E-023-knowledge-router-BE004.md`](../../experiments/E-023-knowledge-router-BE004.md), key `EXP-B9-ROUTER-BE004`

**No verdict is computed across the two.** The hit rate appears in both as a reported number
that decides nothing, for the reason the trap table gives.

## Lab B9.1 — measure against B8 (v1.1)

<!-- The TODO is kept verbatim: `context metrics are the comparison, not just quality.` It is
     answered below, and the answer includes what the instrument cannot supply. -->

**The comparison is against v1.1 as B8 closed it, and it is the same 40 runs.** The B9 control arm
*is* v1.1 — `agent-v1.1`, `instructionsHash sha256:a94237242e8c1308fb1d434a06a03463`, the same
agent file and the same four v1.1 guardrail files as the treated arm. So "compared against B8" needs
no second batch: the control is B8's version, run concurrently and interleaved, which is a stronger
comparison than a stored one.

### There is no "context metric" here, and that is a measurement about the instrument

Extract fact 3 of this stop found it before the batch: nothing in the record is a context metric.
What exists is **five token counters**, and two of their names in the schema doc are not the names
in the record — `cachedTokens`, not `cacheReadTokens`; `reportedTotalTokens`, not `totalTokens`. The
first version of `evidence/b09/context-metrics-b9-vs-b8.py` used the doc's names and printed two
rows of dashes, which reads as *the instrument does not carry them* when it does. **A field name
taken from prose rather than from `.efficiency | keys` is the house failure mode in miniature**, and
it is recorded in that script's own header.

### The four counters that exist, treated (v1.2) against control (v1.1), `n = 10` per arm per task

From the **archived** records by run id — `evidence/b09/reports/context-metrics.txt`, regenerated by
`evidence/b09/context-metrics-b9-vs-b8.py <manifest> <run-records>`. Not from the API, which moves.

| counter | BE-003 treated | BE-003 control | Δ | BE-004 treated | BE-004 control | Δ |
|---|---:|---:|---:|---:|---:|---:|
| `inputTokens` | 182 | 170 | **+7.06 %** | 206 | 218 | **−5.50 %** |
| `outputTokens` | 9 560 | 10 216 | **−6.42 %** | 18 004 | 17 102 | **+5.27 %** |
| `cachedTokens` | 342 784 | 321 460 | **+6.63 %** | 501 262 | 495 840 | **+1.09 %** |
| `cacheCreationTokens` | 22 547 | 22 199 | **+1.57 %** | 33 942 | 33 008 | **+2.83 %** |
| `reportedTotalTokens` | — | — | — | — | — | — |

`reportedTotalTokens` is **null on every claude run** and always has been: it is written only from
codex's own log (`run-agent.sh:1240-1245`). That is a measured absence with a named cause, not a gap.

**Every delta points in the opposite direction on the two tasks except the two cache counters**, and
the largest is 7 %. **Read this against uptake before reading it as an effect: the treatment was
consulted on 2 of 10 BE-003 runs and 1 of 10 BE-004 runs.** Eight or nine runs per arm are two
copies of the same configuration differing only in a corpus nobody opened, so these deltas are
mostly **the instrument's noise floor at `n = 10` on this model, measured by accident** — the same
thing E-023's `test-quality` 0.5 and `change-focus` 1.0 differences are. That number is the single
most useful thing Lab B9.1 produces, because every later step's MDE has to clear it.

**What the lab does not claim.** It does not claim the corpus is cheap: at `H = 2` there is no
population of consulting runs to price. `estimatedCost` medians are `+1.09 %` (BE-003) and
`+1.14 %` (BE-004), which is the cost of *carrying* four files into a worktree, not the cost of
*using* them. Those two numbers answer prediction 4 in both experiments and nothing else.

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-27.*

## Deliberate failure — §4 step 9, prediction registered 2026-09-27, `n = 5`

<!-- The original TODO is kept verbatim below. It is NOT what ran, and the reason is arithmetic,
     not preference. -->

> <!-- TODO: put a wrong summary in the index and see whether the agent
>      trusts it. This is the Layer 3 untrusted demonstration — retrieved
>      text is input, and input can be wrong or hostile. -->

### Why the registered wrong-summary demonstration is deferred, with the arithmetic

The batch measured corpus contact at **3 of 10** treated runs on BE-003 and **1 of 10** on BE-004
(`evidence/b09/corpus-access-census.sh 20260926T151319Z`). A wrong summary can only be trusted by a
run that reads it, so an `n = 5` arm would put the wrong text in front of **one or two** runs and a
trust rate computed on that is not a measurement — §5 forbids stating an `n < 5` result as a
property, and this would be `n ≈ 1`. Reaching five readers needs about **17 runs** at the observed
rate, and comparing a trust *rate* against anything needs more. That is a step of its own, not a
step 9.

**What replaced it is the failure the batch made decidable**, and it is on the path
`TRACK-B-STATE.md` named before this session opened: the instruction-to-call path, broken — not the
router's content and not the corpus.

*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-27; the author did not review before the
run. Nothing above is rewritten.*

### The break: one mode bit, and nothing else

`build/customizations/agent-v1.2-knowledge-noexec/` — a copy of the measured
`agent-v1.2-knowledge/` in which `.ai/knowledge/router.sh` **loses its executable bit**. Every byte
of every file is identical, proved by `diff -r` returning nothing; the only difference is a
permission, proved by `find . -perm`. **The measured overlay is not touched** (§6: a measured
version is never edited). Own probe key **`EXP-B9-DF-NOEXEC`**, excluded by name from both
registered arms, and it runs on **BE-003 only** — BE-004's contact rate is 1 of 10 and it would add
no decidable clause.

`CLAUDE.md` still tells the agent, in the same bytes, to run `.ai/knowledge/router.sh`. So the
instruction is intact and the thing it names cannot execute. `n = 5`, not 3, because clause 4 is
stated as a property.

### The registered predictions

Every clause is decidable at `n = 5` **without depending on the agent choosing to consult
anything** — which is the mistake the wrong-summary version would have made.

| # | prediction | mechanism | how it is decided |
|---|---|---|---|
| 1 | **The registered batch driver does NOT refuse the broken overlay.** `B9_GUARDS_ONLY=1 B9_OVERLAY_T=…-noexec evidence/b09/run-b9-batch.sh` exits **0** | the corpus assertion at `run-b9-batch.sh:181` and `knowledge_hash()` at `run-agent.sh:653-662` both digest **(path, content)** pairs. A mode bit is neither. The overlay is installed with `cp -R` (`run-agent.sh:338`), which preserves modes — so the break survives the copy and no guard sees it | one command, no run. Inverse of stop 17a, where the same guard refused a broken overlay at exit 6 |
| 2 | `knowledgeHash` **equals** the registered `sha256:0770219ae7f4281a80071d78dadea285` on **5 of 5** | same mechanism as 1 | the run record's `customization.knowledgeHash` |
| 3 | `instructionsHash` **equals** the treated arm's registered `sha256:ebf489800a60a156986f98ea4f127848` on **5 of 5** | the clause is byte-identical; one variable moved | the run record's `customization.instructionsHash` |
| 4 | **`H` as registered cannot tell an unexecutable router from an abstention, and can tell every break the script survives.** A hand call in a broken worktree writes **zero** log lines; the same router with its index removed writes **one**, `status=malformed` | the shell refuses the exec at 126 *before* line 1, so `emit()` never runs. Every in-script failure path calls `emit()` first (`router.sh:70,75,105,131,136,143,151`) | two hand calls, free. `H` is registered as *"treated runs whose log is non-empty"* (`E-022:222`) |
| 5 | Evaluator exit **0** on **5 of 5** | BE-003 has never failed on this model, and the corpus names no task word | `evaluation.exitCode` |
| 6 | **Reported, deciding nothing, with its `n`:** how many of the 5 runs *attempt* the call, by `router_exec` in the census, and whether the manifest's `router_mentions` separates an attempt from a no-contact run where `H` does not | at 3-of-10 contact this is expected to be **0–2 of 5** and is explicitly **not** stated as a property | `corpus-access-census.sh` + `manifest.tsv` |

**What would refute clause 4, and it is the honest half:** the manifest carries `router_mentions`
beside `log_lines`, and a refused or failed `tool_use` still appears in the stream. If any broken run
attempts the call, `router_mentions ≥ 1` with `log_state=ABSENT` **does** separate it. Clause 4 is
therefore a claim about **the registered decision rule**, not about the instrument as a whole, and
clause 6 is what tests whether the column rescues it. Stated this way before the run rather than
discovered after it.

**Cost ceiling $1.00** — 5 × the treated arm's BE-003 median `$0.133958`, plus margin. Not a knob.

*Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-27T09:2xZ; the author did not review
before the run.*

### The result — `n = 5`, batch `20260927T090320Z`, 09:03:20Z → 09:19:37Z, `$0.658351`

Runs `14fd7ef4`, `f6602243`, `61a677b5`, `93fa27f1`, `d5231fd3`. Driver
`evidence/b09/run-b9-deliberate-failure.sh`, ShellCheck clean, fixture set
`evidence/b09/verify-b9-df-guards.sh` at **16 of 16** with case A — the inverted guard refusing the
measured overlay — re-derived by hand. Manifest
`evidence/b09/deliberate-failure/batch-20260927T090320Z/manifest.tsv`.

| # | prediction | measured | verdict |
|---|---|---|---|
| 1 | the registered driver does **not** refuse the broken overlay | **exit 0**, output **identical** to the measured overlay, both files kept | **HELD** |
| 2 | `knowledgeHash` = `sha256:0770219ae7f4281a80071d78dadea285` | **5 of 5** | **HELD** |
| 3 | `instructionsHash` = `sha256:ebf489800a60a156986f98ea4f127848` | **5 of 5**; `agentHash` `sha256:b3450564b6f32d6193e8580db766210e` 5 of 5 too | **HELD** |
| 4 | unexecutable router → **0** log lines; index removed → **1** | **exit 126, 0 lines** / **exit 3, 1 line `status=malformed`** / **exit 0, 1 line `status=hit`** | **HELD** |
| 5 | evaluator exit **0** on 5 of 5 | **5 of 5**, `changedFiles = 3` every run | **HELD** |
| 6 | reported only: attempts expected **0–2 of 5** | **3 of 5** (runs 02, 03, 05) | **the expectation was WRONG** |

**Clause 1 is the one to carry, and it is the inverse of stop 17a.** There the registered driver
refused the broken overlay at exit 6, so the deliberate failure could not enter the registered
population by accident. Here it **accepts** it, with byte-identical output to the measured overlay,
because `run-b9-batch.sh:181` and `run-agent.sh:knowledge_hash()` both digest **(path, content)**
pairs and a mode bit is neither, while `cp -R` (`run-agent.sh:338`) preserves modes. **So
`knowledgeHash` is not a delivery proof for an *executable* artifact** — it proves a script's text
arrived, not that it can run. Every later step that ships a script inside an overlay inherits that.
The separation had to be built here instead, as an inverted guard.

**Clause 6's expectation was wrong and the honest reading is that it decides nothing.** 3 of 5
against the registered arm's 2 of 10 is **two-sided Fisher `p = 0.2507`** — not separable, and there
is no mechanism by which an unreadable mode bit could raise an attempt rate, since nothing reveals it
until the call is made. It is registered as reported-only for exactly this reason and it stays that
way. What matters is the other half of clause 6, and it held: **`router_exec` separates an attempt
from an abstention where `H` does not.** Runs 02, 03 and 05 read `rx = 1, log = ABSENT/0`; runs 01
and 04 read `rx = 0, log = ABSENT/0`. **E-022 computed its verdict from `H` and the column that
would have separated them was already in its own manifest, unused.**

### Three things nobody predicted, and the first is the L3-untrusted demonstration in a stronger form

**(a) The agent's own defensive idiom turned a permission failure into the answer "No match found",
and then it looked straight at the cause and drew no conclusion.** Runs 02 and 03 both wrote:

```bash
.ai/knowledge/router.sh "error code for state conflict" 2>/dev/null || echo "No match found"
```

and received exactly `"No match found"`, `is_error: false`. Run 02 then ran
`ls -la .../.ai/knowledge/` and its own tool result came back reading
`.rw-r--r--@ 7.4k … router.sh` — **the missing executable bit, in its context** — and it moved on to
`pom.xml` without a word. **The idiom was invited by the overlay's own clause**, which reassures the
reader that the router *"exits 2 and prints nothing when no topic matches — that is an answer, not a
broken command."* A clause written to stop the agent treating an empty answer as a fault taught it to
treat a fault as an empty answer.

**This is what §4 step 9 was for, and it is a sharper result than the registered wrong-summary
version would have produced.** That version asked *does the agent trust a retrieved document that is
wrong?* This one answered *does the agent trust a retrieval that never happened?* — **yes**, on 2 of
the 3 runs that tried, with the evidence of the failure visible in the transcript. **Layer 3 —
untrusted** is the workbook header's own label for this stop and it is now demonstrated rather than
asserted.

**(b) Run 05 called the router by absolute path and the harness denied it — `router_denied = yes`,
1 of 5.** The runner's allowlist is `Bash(.ai/knowledge/router.sh:*)` (`run-agent.sh:840`), which a
`/private/var/folders/…/observatory-run-…/.ai/knowledge/router.sh` invocation does not match.
**The registered batch recorded `router_denied = no` on 20 of 20, and that is now shown not to mean
the allowlist is adequate** — only that no agent in those twenty runs happened to reach for the
absolute form. So the treated arm's uptake of 2 of 10 sits above a latent denial path the batch
never observed firing, and **`H = 2` is a floor rather than a point estimate**. The mechanism was
found by the deliberate failure, at `n = 5`, for $0.66.

*The driver's `router_denied` detector was checked and is sound: run 03 also had one denial and the
detector correctly said `no`, because that denial was `./mvnw test … | tee test-output.log`, not the
router. A detector defect was suspected here and is not one.*

**(c) Every `estimatedCost`, `modelCalls` and `toolCalls` in all five records is `null`, and the
control built to prevent exactly that certified the broken path.** The cause is one missing scheme:
this driver exported `OTLP_GRPC_ENDPOINT=localhost:4317` where the registered driver exports
`http://localhost:4317` (`run-b9-batch.sh:84`). The runner's OTLP preflight printed
`otlp preflight grpc localhost:4317 answered 200` — and the registered batch's log reads
`grpc http://localhost:4317 answered 200`. **The same 200, opposite outcomes**, because `curl`
normalises a scheme-less `host:port` and the Claude Code OTLP exporter does not; probed directly,
both forms return 200 from the same command the preflight uses. `otlp-preflight.sh`'s own header says
it exists because *"a collector that never answers produces a record with null modelCalls, toolCalls,
tokens and cost … That has happened to two batches"*. **It is now three, and this time the preflight
was green.** An additive fix is owed in `agent-observatory` and is recorded in `author_notes`.

**The costs are recoverable, and from the runtime rather than from the collector:** `total_cost_usd`
in the stream-json `result` line. `$0.114885 · 0.145589 · 0.143896 · 0.124188 · 0.129793` — median
**`$0.129793`**, total **`$0.658351`**, **65.5 %** of the `$1.0047` ceiling. Against the registered
treated median of `$0.127337` that is **+1.93 %**, which says only that a mode bit costs nothing.

**(d) The cost ceiling could not have fired, and that is a defect in this driver.** `SPENT`
accumulates from the record's `estimatedCost`, which was `null` on all five, so `SPENT` stayed `$0`
and the stop rule was inert. It did not matter — `$0.658` against `$1.0047` — and **a stop rule that
reads a field the run did not populate is not a control.** Recorded rather than patched after the
fact; the fix belongs with (c), because a populated record is what makes it work.

### What the deliberate failure does **not** do

It does not move E-022's or E-023's verdict, touch a registered prediction, or enter either
experiment's population: its key is `EXP-B9-DF-NOEXEC` and its overlay variant is
`agent-v1.2-knowledge-noexec`. It does not license a claim about trust rates — 2 of 3 is `n = 3` and
§5 forbids stating that as a property; it is true of those runs, and the *mechanism* it exhibits is
what transfers. And the registered wrong-summary demonstration **is still owed**, at the `n ≈ 17`
its arithmetic requires.

*Run and recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-27.*

## Exit gate — §4 step 11, 2026-09-27

**From the build track, verbatim:** *retrieval order recorded per run (index → summary → full) · hit
rate measured · context metrics compared against B8.*

| clause | answered | with what |
|---|---|---|
| retrieval order recorded per run | **yes, and the order was index-first on every lookup that happened** — 3 of 3, one lookup each | `knowledge-log.jsonl` per run, `first_status = hit` on all three; `log_hits` column of `manifest.tsv` |
| hit rate measured | **yes: 2 of 10 on BE-003, 1 of 10 on BE-004 — a *router* hit rate, at that scope** | `manifest.tsv` `log_lines`; scope fixed by Amendment 5 in both experiments |
| context metrics compared against B8 | **yes, on the four counters that exist**; the fifth is null by construction | Lab B9.1 above, `evidence/b09/reports/context-metrics.txt` |

**`hit rate measured` is a measurement, not a gap, and its `n` travels with it.** 2 of 10 and 1 of 10
are numbers the batch produced; the decision rule's `VOID` row is what they fire, not a failure to
measure. What Amendment 5 changes is the *scope*: it is the rate at which the **router** was
invoked, and on BE-003 corpus **contact** was 3 of 10 because one run read the summary by hand.

### Plus, for this to count as a learned phase

**Was this the agent, or the harness?** **The agent, and the answer is stronger than "zero
denials".** `router_denied = no` on 20 of 20 treated runs, so nothing in the registered batch was
refused a permission. **But the deliberate failure then showed the denial path exists** — run 05
called the router by absolute path and was denied, 1 of 5 — so 20 of 20 means *no agent in those
twenty reached for the form the allowlist misses*, not *the allowlist cannot bite*. `H = 2` is
therefore a **floor**. That is a harness caveat on an agent result, and it was found by breaking
something rather than by reading the column.

**What was learned that a file existing would not have shown.**

1. **An L3 instruction delivered by hash to 20 of 20 runs was followed by 3 of them.** The corpus
   arrived — `knowledgeHash` set on 20 of 20 treated and `null` on 20 of 20 controls — and the
   sentence telling the agent to use it did not carry. That is E-005's description arm again, at
   `n = 20`, on a different mechanism: **delivery is not uptake, and only the first of the two has a
   hash.**
2. **The instrument could not tell "consulted" from "invoked the router", and the verdict turned on
   the difference.** One run on one task. Amendment 5 carries it; the registered `VOID` stands
   because `H` was defined before the data, and the `REJECT` the other definition would have given —
   which *removes* the corpus — is written down beside it.
3. **A retrieval that never happened was trusted.** Two of the three runs that called a broken
   router received `"No match found"` from their own `|| echo` fallback and proceeded; one of them
   had the non-executable mode bit in its context and said nothing. **Retrieved text is input and
   input can be wrong** is the header's Layer 3 label, and the strong form is that *retrieved
   nothing* is also input.
4. **`knowledgeHash` is not a delivery proof for an executable artifact.** It hashes text. The
   registered driver's own guard passed a corpus whose router could not run, at exit 0, with output
   identical to the measured overlay.
5. **The noise floor of this instrument at `n = 10` on this model was measured by accident** — every
   token counter within 7 %, every rubric delta at or near 0, in a comparison where the treatment was
   used once or twice in ten runs. Every later step's MDE has to clear that.

**Nothing here justifies embeddings, and that was the build spec's whole point.** *"Without it you
can prove RAG ran, not that it helped."* This stop cannot prove either: it proved the corpus
**arrived** and that the agent **did not ask for it**. The next question is delivery, not retrieval
quality, and E-004 already showed which mechanism decides selection.

## Commit — §4 step 14, 2026-09-27

| what | where |
|---|---|
| version | **v1.2 candidate, NOT promoted.** `build/customizations/agent-v1.2-knowledge/` stays on disk; nothing installs it after this stop |
| experiments | [`E-022`](../../experiments/E-022-knowledge-router-BE003.md) `EXP-B9-ROUTER-BE003` · [`E-023`](../../experiments/E-023-knowledge-router-BE004.md) `EXP-B9-ROUTER-BE004` |
| verdict | **`VOID — THE TREATMENT WAS NOT TESTED`** on both tasks. E-022 row 0 (`H = 2 of 10`), E-023 row 1 (`H = 1 of 10`). Row 4 also fires on both: `Fisher = 1.0000`, `NOT DETECTABLE` on the two-arm reading. Row 5 does not fire: cost `+1.09 %` / `+1.14 %` |
| disposition (§4 step 10) | **corpus KEPT in the repository, NOT promoted, NOT removed.** The `REJECT` rows that remove it need `H ≥ 3`; removing an artifact nothing consulted would record a measurement nobody made |
| deliberate failure | `EXP-B9-DF-NOEXEC`, `n = 5`, `$0.658351`. Five of six clauses held; clause 6 was registered as reported-only and its expectation was wrong |
| predictions refuted | **three of five on each task**, including — on both — the one registered in advance as most likely to be wrong (prediction 3, uptake) |
| instrument PRs merged with this stop | the preflight's own experiment key (`-PF`) · `LAB_SCORE_TIMEOUT` in `tools/codex-score.sh` · `LAB_SCORE_OUTDIR` |
| still owed | the wrong-summary demonstration at `n ≈ 17`; the OTLP-preflight scheme fix in `agent-observatory`; a retrieval record that is an artifact of the run rather than of `$TMPDIR` |

## §5 validation table — spine stop 20

Written before the PR. **The layer column is about the proof, not the artifact.**

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| *retrieval order recorded per run (index → summary → full)* | `evidence/b09/batch-20260926T151319Z/manifest.tsv`, columns `log_state / log_lines / log_hits / first_status`; `first_status = hit` on runs `ab8b2398`, `e0e4bb0e`-row BE-003 09, and BE-004 08 | **L2** for the three lookups that happened — the router writes the line before it returns (`router.sh:156`) — and **L3** for "at the right point", which nothing executes to check | `awk -F'\t'` the four columns out of the manifest; or re-run `.ai/knowledge/router.sh "state transitions"` in a kept worktree and read the new line |
| *hit rate measured* | `2 of 10` BE-003, `1 of 10` BE-004, from the same four columns, `n = 10` per arm per task | **L2** at the scope *router invocations*; **L3** for *corpus consultations*, per Amendment 5 | `./evidence/b09/corpus-access-census.sh 20260926T151319Z` — 17-case fixture set, `tools/verify-corpus-access-census.sh` |
| *context metrics compared against B8* | `evidence/b09/reports/context-metrics.txt`, four counters, `n = 10` per arm per task, off the **archived** records | **L2** — the numbers come from `evidence/b09/batch-20260926T151319Z/run-records/*.json`, which do not move | `python3 evidence/b09/context-metrics-b9-vs-b8.py evidence/b09/batch-20260926T151319Z/manifest.tsv evidence/b09/batch-20260926T151319Z/run-records` |
| the treatment reached the model | `customization.knowledgeHash = sha256:0770219ae7f4281a80071d78dadea285` on **20 of 20** treated records | **L2** — `knowledge_hash()` runs on every run and differs when the corpus differs (`run-agent.sh:653-662`) | `jq -r '.customization.knowledgeHash' evidence/b09/batch-20260926T151319Z/run-records/*.json \| sort \| uniq -c` |
| …and not the control | `knowledgeHash = null` on **20 of 20** control records; `run-b9-batch.sh:178` refuses a control overlay that has `.ai/knowledge` | **L2** both halves, and the refusal is in the guard fixture set | the same `jq`; then `B9_GUARDS_ONLY=1 B9_OVERLAY_C=<a copy with .ai/knowledge> ./evidence/b09/run-b9-batch.sh` → exit 6 |
| …but **not** that it can *run* | `evidence/b09/deliberate-failure/clause1-guards-broken-overlay.txt` exit **0**, byte-comparable to `clause1-guards-measured-overlay.txt` | **L2 negative** — the guard was executed against the break and did not refuse | `B9_GUARDS_ONLY=1 B9_OVERLAY_T=$PWD/build/customizations/agent-v1.2-knowledge-noexec ./evidence/b09/run-b9-batch.sh BE-003; echo $?` |
| one variable moved | `instructionsHash` `ebf489800a60…` treated / `a94237242e8c…` control; `agentHash b3450564b6f3…` **both** arms; `runtime.model claude-haiku-4-5-20251001` on 40 of 40; benchmarks `2fc445d` | **L2** — asserted by the driver before any run (`run-b9-batch.sh:165-183`), and independently readable in every record | `jq -r '[.customization.instructionsHash,.customization.agentHash,.runtime.model]\|@tsv' …/run-records/*.json \| sort \| uniq -c` |
| the rubric did not move | BE-003 `396e1799eb2b`, BE-004 `6252778b8472`, asserted per sheet by the scoring driver, which refuses a moved sha | **L2** — proved by mutant, recorded at `evidence/b09/verify-score-driver-guards.sh` 13 of 13 | `./evidence/b09/verify-score-driver-guards.sh` |
| a scored cell re-read by hand | **two**, both written before their sheet existed: `maintainability = 2` on `c49eec44` (commit `78d5af5`) and `maintainability = 0` on `3fc93ff4` (commit `597dceb`); both agree with the sheet | **L2** for the ordering — the commit predates the sheet's mtime — and **L3** for the reading itself, which is a human judgement | `git show 78d5af5` and `git show 597dceb`, then `stat -f '%Sm'` the two sheets |
| the prediction preceded the run | prediction commit `ef2c6c0` (2026-09-26) vs first `startedAt` in `manifest.tsv`; deliberate-failure prediction commit **`fd5dcae`** vs batch tag `20260927T090320Z` | **L2** — two timestamps, neither written by hand | `git show -s --format=%cI ef2c6c0 fd5dcae`; `head -6 evidence/b09/deliberate-failure/batch-20260927T090320Z/manifest.tsv` |
| the decision rule is exhaustive | `evidence/b09/verify-decision-rule-exhaustive.py` — 121 pairs, 0 gaps, **shown to refuse by three mutants** | **L2** | `python3 evidence/b09/verify-decision-rule-exhaustive.py` |
| the router's exit codes | `tools/verify-knowledge-router.sh` — 15 cases, 18 assertions, exit 0 | **L2** | `./tools/verify-knowledge-router.sh` |
| the deliberate failure could not enter the registered population | key `EXP-B9-DF-NOEXEC`, variant `agent-v1.2-knowledge-noexec`; the DF driver **refuses an executable router at exit 6** (case A, re-derived by hand) | **L2** — and it had to be built, because the registered guard was shown not to help | `B9DF_OVERLAY=$PWD/build/customizations/agent-v1.2-knowledge ./evidence/b09/run-b9-deliberate-failure.sh --guards-only; echo $?` → 6 |
| the break is one mode bit | `diff -r` between the two overlays returns **nothing**; both corpora hash to `sha256:0770219ae7f4281a80071d78dadea285` | **L2** | `diff -r build/customizations/agent-v1.2-knowledge build/customizations/agent-v1.2-knowledge-noexec; stat -f '%Sp %N' both routers` |
| `H` cannot see a router that cannot execute | `evidence/b09/deliberate-failure/clause4-log-blindness.txt` — exit **126** / 0 lines, exit **3** / 1 line, exit **0** / 1 line | **L2** — three executed calls, three recorded outcomes | copy either overlay to a scratch dir, `KNOWLEDGE_EVENT_LOG=… .ai/knowledge/router.sh "status transitions enum when"`, count the lines |
| the cost of the stop | **`$0.658351`** DF (from `total_cost_usd` in the stream-json) + the registered batch's recorded costs; ceiling `$1.0047`, **65.5 %** used | **L3 for the DF arm**, and that is the honest label: `estimatedCost` is `null` on 5 of 5 records, so the number comes from the runtime's own log and not from the instrument | `python3 -c` over `"total_cost_usd"` in each `BE-003-0N.log` |
| *nothing in the record proves the collector received anything* | `no telemetry found — behaviour metrics stay empty rather than guessed`, `BE-003-01.log:173`, on all five DF runs, **after** `otlp preflight grpc localhost:4317 answered 200` at `:22` | **L2 negative, and it is a finding about the control** — the preflight executed, returned 200, and certified a path the exporter could not use | compare `:22` and `:171-173` of any DF log against the same lines of `evidence/b09/batch-20260926T151319Z/BE-003-02-treated.log` |

**Every number quoted in prose above carries its `n`.** The only `n < 5` statements are about the
deliberate failure's three attempting runs, and they are written as *true of those runs*.

**Independence check, re-run immediately before this table was written**, not trusted from a flag:
`instructionsHash`, `agentHash`, `knowledgeHash`, `runtime.model` and the benchmarks sha were read
back out of the archived records; `agentHash` and `runtime.model` are identical across all 40 runs,
`instructionsHash` takes exactly two values and they are the two registered ones, and `knowledgeHash`
takes exactly two: the registered corpus sha on the 20 treated, `null` on the 20 controls. Pasted
rather than described:

```
$ jq -r '[.customization.instructionsHash,.customization.agentHash,.customization.knowledgeHash,.runtime.model]|@tsv' \
    evidence/b09/batch-20260926T151319Z/run-records/*.json | sort | uniq -c
  20 sha256:a94237242e8c1308fb1d434a06a03463  sha256:b3450564b6f32d6193e8580db766210e                                    claude-haiku-4-5-20251001
  20 sha256:ebf489800a60a156986f98ea4f127848  sha256:b3450564b6f32d6193e8580db766210e  sha256:0770219ae7f4281a80071d78dadea285  claude-haiku-4-5-20251001
```

Two rows, twenty each. Nothing else moved.
