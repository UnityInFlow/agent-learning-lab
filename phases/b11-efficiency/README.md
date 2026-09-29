# B11 — Efficiency

**Track A first:** [Phase 6B](../06b-knowledge-retrieval/) + [Phase 10](../10-production-observability/)
**Version:** **v1.2 closes here**
**Spine position:** 26 of 28 · after [Phase 10](../10-production-observability/) · before [B12](../b12-governed-self-learning/)
**Status:** 🟡 open at spine stop 26 — branch `stop26/b11-efficiency`, opened 2026-09-29

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b11).
> Everything else is yours to fill.

---

## Goal

Answer, for **v1.2**, whether the five efficiency mechanisms of
[`BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` §6](../../businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md)
— task classifier, retrieval budget, file-summary cache, verification planner, command
deduplication — reduce what a run consumes **without** reducing what it achieves, measured
against **v1.1** on both registered tasks (author decision 9).

And, before any of that: answer whether this instrument **can** decide that question. The
step's gate has seven clauses and is all-or-nothing. Two of the seven name a metric this
stack does not record, and one names a field that exists and does not mean what the clause
means by it. That audit is below, it was done before the prediction, and it is the reason
this stop registers outcomes on a subset of its own gate.

## Required reading

### Internal — the requirement

Opened for this stop, by path and line:

| Source | Lines | What it fixes here |
|---|---|---|
| [`BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md`](../../businesscase/BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md) §6 | 488–632 | The five mechanisms and the seven v1.2 acceptance criteria, verbatim — this is the specification the build implements |
| same, §5 | 354–487 | What v1.1 already is, so the treated arm is v1.1 **plus** and not v1.1 **instead** |
| [`BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md`](../../businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md) P1 | 168–170 | *"A result that uses fewer tokens but fails the task is not better."* The ordering of this stop's gate |
| same, P2 | 172–174 | One main variable — settled below as the **version**, on the B7/B8 precedent |
| same, §10.5 | 398–418 | `context-policy.md`, and its `Measure:` line naming *files read, unique files read, repeated reads* |
| same, §13.4 | 796–808 | The token/context metric list, naming *repeated reads* a second time |
| [`build/README.md#b11`](../../build/README.md#b11) | 531–553 | The gate's seven clauses as this track registers them |

### External — the technique

**None read, and that is a decision, not an omission.** The five mechanisms are specified
completely in §6 of the internal design down to the JSON shape of the cache entry and the
numeric budget limits. Nothing in this stop's build is a technique to be learned from
outside; it is a specification to be implemented and measured. Stop 7's finding stands as
the reason to be careful here — a technique imported from a neighbouring ecosystem
(`tools:` → `allowed-tools`) inverted a control's meaning. Where an external source would
have helped is the one place this stop cannot go: an instrument for *repeated reads*, and
that is an observatory change and outside this stop's one variable.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-29.*

## Extract

### 1. The conditional gate, answered first, from stored data and no new runs

§3 of the run prompt and `build/README.md#b11` both make this step conditional: *"Only if
v1.1's correctness is stable across its runs; otherwise record `correctness not stable, B11
refused` and stop."* That is a gate on **already-stored** data, it is cheaper than a batch,
and it is therefore answered before anything is built.

**The criterion, stated before the verdict:** every claude-runtime run of the `agent-v1.1`
overlay that has ever been recorded, per task, counted by `evaluation.exitCode == 0`, with
(a) no task below 90 %, and (b) no failure mode recurring — a single failure is a run, a
repeated failure class is an instability. **The data was already on disk and was read before
this criterion was written down**; the criterion is therefore not blind, and saying so is
worth more than pretending otherwise. It is stated numerically so a stranger can apply it to
a different population and get a different answer.

| task | population | source | exit 0 |
|---|---|---|---|
| BE-003 | B8 treated arm, `n = 10` | `EXP-B8-RUNSTATE-BE003`, hashes `agentHash`+`instructionsHash` | **10 of 10** |
| BE-003 | B9 control arm, `n = 12` | `EXP-B9-ROUTER-BE003`, hashes `agentHash`+`agentsHash`+`instructionsHash` | **12 of 12** |
| BE-004 | B8 treated arm, `n = 10` | `EXP-B8-RUNSTATE-BE004` | **9 of 10** |
| BE-004 | B9 control arm, `n = 12` | `EXP-B9-ROUTER-BE004` | **12 of 12** |

**BE-003 22 of 22. BE-004 21 of 22. Pooled 43 of 44 (97.7 %).** The single failure is
`ebf9e05e` at stop 17, evaluator exit 11, failure class F05 (baseline tests), recorded in
[`E-019`](../../experiments/E-019-run-state-repair-limits-BE004.md) as *"the first evaluator
failure BE-004 has ever produced on this model"* and as inside the one-run tolerance
registered before that batch. It has not recurred in the 12 v1.1 runs since.

**Verdict: v1.1's correctness is stable. B11 is not refused, and it opens.** Both clauses of
the criterion hold — no task below 90 % (100 % and 95.5 %), and no recurring failure class.

### 2. A correction owed to a closed stop, and it is load-bearing for this one

[`E-025`](../../experiments/E-025-second-runtime-adapter-BE004.md) line 637 states: **"No
batch on either model has ever produced a BE-004 evaluator failure."** That sentence is
false, and the way it is false is this project's house failure mode. The sentence is reached
by enumerating stops 12, 13, 15 and 20 — and **stop 17 is missing from the enumeration**,
which is the one stop where BE-004 did fail (`ebf9e05e`, exit 11, E-019 line 424). A claim
true over four stops is stated as a property of every batch ever run.

This is not a cosmetic defect for B11: **clause 1 of this stop's gate is *same or better
acceptance*, and the acceptance baseline it is measured against is BE-004's v1.1 rate.**
Taken from E-025 that baseline is 20 of 20; taken from the runs it is **9 of 10 at stop 17 and
21 of 22 pooled.** Registering the wrong baseline would have made "same or better
acceptance" unfalsifiable in the direction that matters, because a single BE-004 failure in
the treated arm would then have read as a regression against a rate that never existed.

E-025 is amended additively and dated; its registered verdict, predictions and numbers are
untouched (§4 step 12, §6). See
[`E-025` Amendment](../../experiments/E-025-second-runtime-adapter-BE004.md).

### 3. The instrument audit — two of seven clauses are measurable as written

The gate is *"all must hold vs v1.1"*. A clause with no instrument can neither hold nor
fail, so the audit comes before the prediction. Every row was checked against the live
stack, not against the schema document.

| # | Gate clause | Field or source | Verdict |
|---|---|---|---|
| 1 | same or better acceptance | `evaluation.exitCode`, `.passed`, `.acceptanceRate` — the evaluator executes | **MEASURABLE, L2** |
| 2 | same hidden-test success | `evaluation.testsPassed` + the two evaluator-owned suites | **MEASURABLE, L2** |
| 3 | fewer repeated reads | needs the read **target**. `tool.arguments` is **deleted by the collector** (`infra/otel-collector/config.yaml:48`), 0 occurrences in 212 lines / 1 735 018 bytes of live `events.jsonl` | **NOT MEASURABLE as written** |
| 4 | fewer unnecessary tool calls | `behavior.toolCalls`; and `tool_name` in telemetry, 500 events — Read 266, Bash 132, Edit 102 | **COUNT measurable; "unnecessary" is not** |
| 5 | lower median input tokens | `efficiency.inputTokens` exists — and is the **uncached remainder**, not the context | **FIELD EXISTS, WRONG SEMANTICS** |
| 6 | lower median time-to-green | `efficiency.durationMs` — whole-run, not time-to-first-green, and sleep-contaminated | **PROXY ONLY** |
| 7 | no increase in material review corrections | `humanReviews` is `[]` on every run ever recorded; no human reviewer exists in this instrument | **NOT MEASURABLE; proxy registered** |

**Clause 3 is unmeasurable because a privacy control works.** `tool.arguments` is deleted on
purpose — the Collector comment at `config.yaml:3-5` says so. A repeated read is *defined* by
its argument, so the one attribute that would identify it is the one the scrub removes. This
is the same processor stop 25 probed; there the finding was that its scope is smaller than
its comment claims, here the finding is that its scope is exactly large enough to remove
this stop's metric. **The requirement asks for this metric in two separate places**
(§10.5's `Measure:` line, §13.4's list) and the stack has never recorded it.

What survives as a proxy: `tool_input_size_bytes` (250 events) is present while the argument
is not, so two `Read` calls on the same path share an input size. That is **necessary and
not sufficient** — two different paths of equal length collide — and it is registered as a
proxy with that false-positive mode named, never as the metric.

**Clause 5's field exists and measures something else.** Measured across nine preflight
runs, `inputTokens` is 98–234 while `cachedTokens` is 360 677–1 005 635; on the B8 batches
it is 1 392 (BE-003) and 1 643 (BE-004) against a total context of 294 493 and 565 842 — so
**`inputTokens` is 0.3–0.5 % of the context a run actually consumes.** A clause reading
"lower median input tokens" answered from that field would be answered from the uncached
remainder. The registered outcome is therefore
`inputTokens + cachedTokens + cacheCreationTokens`, stated as **context total**, with
`inputTokens` reported beside it so the difference stays visible.

**And `inputTokens` is not comparable across stops.** Same two tasks, same model: median
1 392 / 1 643 at stop 17, median 170 / 222 at stop 20 — an 8× move with no treatment
intending it. Whatever changed, it was not a variable anyone registered. This is the
measured reason this stop uses a **concurrent** control and not a stored v1.1 baseline;
author decision 9 already required one, and this is the evidence for why.

### 4. What the track already measured about this step's mechanism of delivery

Read before designing, because it decides the design:

- **B9 (stop 20) closed `VOID` with `H = 2 of 10`.** The corpus arrived on 20 of 20 runs and
  the sentence telling the agent to call the router did not carry. Four of this stop's five
  mechanisms are, in the design's own text, instructions to the model. **The default
  expectation for a prose-delivered mechanism in this project is that it is not invoked.**
- B9's `H` was registered as *"treated runs whose `.agent/knowledge-log.jsonl` is
  non-empty"*, and its Amendment 5 records the trap: `H` counted router **invocations**, not
  corpus **consultations**, and the two differ by one run. A delivery metric must count the
  thing the treatment is.
- **B7 executed on 17 of 17 treated runs and moved all four BE-004 rubric deltas by 0, at
  +5.02 % cost.** An L2 control that fires and changes nothing is this track's most common
  outcome.
- **E-003:** carrying a context file cost ~5 300 cache-creation tokens, and roughly two
  thirds of the premium was the extra *work prescribed*, not the context occupied. An
  efficiency overlay is still an overlay.
- **B6 is the only treatment that moved anything, and it was chosen from a failure the data
  already showed.** No efficiency failure has been measured on either task: the agent passes
  both, and nothing on disk says it reads the same file twice — because, per clause 3, the
  instrument cannot say.

*Extract written by Opus 5 (claude-opus-5), autonomous, 2026-09-29.*

## Build

**Only after correctness is stable.** Efficiency work on an incorrect agent optimises the
wrong thing.

**Build, in this order:**

1. **Task classifier** — API / JPA / Kafka / cache / security / build / test-only / migration.
   Output drives what loads.
2. **Retrieval budget** — `max_similar_implementations: 2`, `max_initial_searches: 5`,
   `max_files_before_design: 15`, `max_full_log_lines: 0`. Exceeding requires a recorded reason.
3. **File-summary cache** keyed on `sha256` — reuse only on hash match; **never trust a stale
   summary.**
4. **Verification planner** — smallest safe sequence for the change type. Final independent
   verification stays unchanged.
5. **Command deduplication** against the current code fingerprint.

## Design — one variable, five mechanisms, and a layer label per mechanism

### The one-variable decision

P2 forbids adding several things to one comparison. The five mechanisms are five things.
**The registered variable is the version — `v1.1` → `v1.2` — and not a mechanism**, on the
precedent already set twice in this track: B7 registered *deterministic verification and
policies* (a policy file, a gate hook, a protected-paths list) as one variable, and B8
registered *run state, repair limits and the completion contract* as one variable. The spine
defines versions, the gate is written against a version, and §6's one-variable rule is
applied at the level the experiment registers.

**What makes that honest rather than convenient:** each mechanism gets its own delivery
metric `H₁…H₅` and its own prediction, registered before the batch, so a null aggregate can
be attributed to a mechanism rather than to the version. That is what the scaffold's own note
asked for — *"a mechanism that costs more than it saves will hide inside the aggregate unless
you predicted it"* — and it is B9's lesson applied before rather than after.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-29.*

### The trap, from `build/README.md#b11`, and which layer converts it

The step's stated trap is **"efficiency work on an incorrect agent optimises the wrong
thing"**, guarded by *"Only after correctness is stable"*. That guard is converted by the
conditional gate in Extract §1 — answered from 44 stored runs before anything was built. The
guard is **L3**: nothing executes to stop a builder opening B11 on an unstable v1.1. Making
it L2 would mean a script that reads the stored population and refuses; that is a candidate
instrument PR and not this stop's one variable.

The **second** trap is not in `build/README.md` and is the one this track has actually paid
for: *a mechanism that is an instruction is not a mechanism until a run invokes it.* B9 paid
for it at `H = 2 of 10`. It is converted per mechanism, below.

### Layer per mechanism, rule applied in order, stopping at the first yes

| # | Mechanism | Delivery | Can the bad value still be written? | Does something execute and reject it? | Layer |
|---|---|---|---|---|---|
| 1 | Task classifier | script writing `.agent/task-classification.yaml`, invoked by the overlay's prose | yes — the run can proceed unclassified | no | **L3** |
| 2 | Retrieval budget | `PreToolUse` hook counting `Read`/`Grep`/`Glob` against the §6.2 limits, refusing beyond | yes — the limit is a number in a file | **yes, the hook refuses the call** | **L2** |
| 3 | File-summary cache | `sha256`-keyed store + a reader that refuses a hash mismatch | yes — a stale entry can be written | **yes, the reader refuses it** | **L2** |
| 4 | Verification planner | prose in the overlay naming the smallest safe sequence | yes | no | **L3** |
| 5 | Command deduplication | hook comparing a command against a fingerprint log, refusing a repeat | yes | **yes, the hook refuses it** | **L2** |

**Three L2, two L3, and the two L3 are the two that cannot be made L2 without changing what
the benchmark measures.** A classifier that *refuses* an unclassified run, or a planner that
*refuses* a verification sequence, would change the task's pass condition — a §7 halt, not a
design choice. So they are registered as L3 and their predictions say so.

### Delivery metrics, per mechanism, registered before the batch

`H_i` = treated runs on which mechanism *i* left its own artifact. Counted from the kept
worktree, not from telemetry, because the collector deletes the attribute that would name it
(Extract §3):

| metric | counts | artifact |
|---|---|---|
| `H₁` | classifier ran | `.agent/task-classification.yaml` exists and names a `task_type` |
| `H₂` | budget hook fired at least once | a line in `.agent/budget-log.jsonl` |
| `H₃` | cache was consulted | a line in `.agent/cache-log.jsonl` |
| `H₄` | planner was followed | **not countable from an artifact** — registered `unmeasured`, with the reason |
| `H₅` | dedup hook fired | a line in `.agent/dedup-log.jsonl` |

**`H₄` is registered `unmeasured` before the run, not after.** A planner followed in the
model's head leaves nothing behind; the only artifact would be the verification commands
themselves, and those are indistinguishable from the commands v1.1 already runs. The
precedent for registering a cell `unmeasured` rather than computing it is author decision
10.3 (`change-focus` under Decision H) and stop 17a's `change-focus`. Saying it before the
batch is the whole point.

**And `H` is per mechanism, never pooled.** B9's Amendment 5 is the reason: a pooled `H`
counted invocations of one thing and was read as consultation of another.

## Predict before you run

**The registered predictions live in the two experiment files, one per task (author decision
9), and are committed before the first run:**

- [`E-026-efficiency-BE003.md`](../../experiments/E-026-efficiency-BE003.md) — `EXP-B11-EFFICIENCY-BE003`
- [`E-027-efficiency-BE004.md`](../../experiments/E-027-efficiency-BE004.md) — `EXP-B11-EFFICIENCY-BE004`

Six predictions each, every one with a direction, a magnitude and a mechanism. In short, and
**the experiment files are the record — this list is a mirror**:

| # | Prediction | Mechanism it rests on |
|---|---|---|
| P1 | context total goes **up** 3–12 %, not down | the overlay is read every run and prescribes work; E-003's premium, B7's +5.02 % |
| P2 | the two **L3** mechanisms are not invoked — `H₁ ≤ 3 of n`, `H₄` `unmeasured` | B9's `H = 2 of 10` on the same delivery |
| P3 | the three **L2** mechanisms fire on `≥ 8 of n` | a `PreToolUse` hook fires on dispatch, not on compliance; B7 17 of 17 |
| P3a | if P2 and P3 both hold, **the version's content is its hooks, not its instructions** | the registered consequence, not a separate guess |
| P4 | acceptance does not degrade | 43 of 44 stored v1.1 runs pass; the budget hook's refusals are recoverable |
| P5 | no rubric category median moves | every treatment since B7 moved all four by 0 |
| P6 | `durationMs` rises and is **inadmissible** as time-to-green | hooks add latency; the field is whole-run and sleep-contaminated |

**Registered as the one most likely to be wrong:** P1's magnitude, and the sign with it. If
the retrieval budget truncates a genuinely wasteful read pattern, the content it removes could
exceed the overlay's own cost. `H₂` exists to detect that path.

**And registered before the run, so it cannot be a disappointment after it:** because four of
the gate's seven clauses have no instrument (Extract §3), **v1.2 cannot be promoted at this
stop even on an `IMPROVED` row.** The expected outcome is *measured, kept, not promoted*, with
B7 as the precedent for that being a result rather than a shortfall.

## Lab B11.1 — measure against v1.1

<!-- TODO: seven conditions, all must hold. Note that the cache-creation
     finding from EXP-BE002-CLAUDEMD-V2 is directly relevant: carrying a
     context file cost ~5,300 cache-creation tokens, but roughly two
     thirds of the premium was the extra *work* prescribed, not the
     context occupied. Shrinking context may not recover what you expect. -->

## Deliberate failure

<!-- TODO: feed the file-summary cache a stale entry and confirm the hash
     check refuses it. -->

## Exit gate

**From the build track — all must hold vs v1.1:** same or better acceptance · same hidden-test
success · fewer repeated reads · fewer unnecessary tool calls · lower median input tokens ·
lower median time-to-green · **no increase in material review corrections.**

> Efficiency improvements are rejected when quality declines. No exceptions.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
