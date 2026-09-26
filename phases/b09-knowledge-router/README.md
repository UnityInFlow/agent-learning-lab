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

- **BE-003 is bimodal with real headroom and high variance.** Anchor-2 rates across eight
  measured arms run 2 of 10 to 6 of 10; pooled, **17 of 50**. No arm has ever reliably reached
  it, and no treatment has ever moved it beyond noise.
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

## Predict before you run

Registered in two experiment files, one per task (author decision 9), each committed before its
first run:

- BE-003 — [`experiments/E-022-knowledge-router-BE003.md`](../../experiments/E-022-knowledge-router-BE003.md), key `EXP-B9-ROUTER-BE003`
- BE-004 — [`experiments/E-023-knowledge-router-BE004.md`](../../experiments/E-023-knowledge-router-BE004.md), key `EXP-B9-ROUTER-BE004`

**No verdict is computed across the two.** The hit rate appears in both as a reported number
that decides nothing, for the reason the trap table gives.

## Lab B9.1 — measure against B8 (v1.1)

<!-- TODO: context metrics are the comparison, not just quality. -->

## Deliberate failure

<!-- TODO: put a wrong summary in the index and see whether the agent
     trusts it. This is the Layer 3 untrusted demonstration — retrieved
     text is input, and input can be wrong or hostile. -->

## Exit gate

**From the build track:** retrieval order recorded per run (index → summary → full) · hit rate
measured · context metrics compared against B8.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
