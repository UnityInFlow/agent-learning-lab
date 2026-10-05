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

> **Corrected 2026-10-05 at §4 step 13a**, from the §4a review round's non-blocking finding 1
> (`findings/opencode/review-README-20261005T190718Z.md`), which is right: *"two … and one"* counts
> **three** impaired clauses where Extract §3's own table finds **five**. Only clauses 1 and 2 are
> measurable as written. Clause 4's **count** is measurable and its word *"unnecessary"* is not;
> clause 6 is a **proxy only**. The sentence above is kept and this correction stands beside it,
> because the audit it summarises was always the longer table — the summary was the thing that was
> short. Step 11 answers all seven one by one.

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

**BE-003 22 of 22. BE-004 21 of 22. Pooled 43 of 44 (97.7 %).**

> **Scope corrected 2026-10-05 at §4 step 13a**, from the §4a review round's non-blocking finding 3,
> which is right that *"every claude-runtime run … that has ever been recorded"* claims more than the
> table counts — though not for the reason it guessed. The runs the table omits are not B7's (B7 is
> not v1.1): they are **preflight and deliberate-failure runs**. Queried against the live API this
> session, the runs carrying v1.1's `instructionsHash` `sha256:a94237242e8c1308fb1d434a06a03463`
> outside the four registered batch arms are `EXP-B8-RUNSTATE-BE003-PREFLIGHT` (1),
> `EXP-B8-RUNSTATE-BE004-PREFLIGHT` (1) and `EXP-B8-RUNSTATE-BE003-DELIBERATE-FAILURE` (1) —
> **three runs, all `exitCode 0`**, so the pooled figure including them is **46 of 47 (97.9 %)** and
> the verdict does not move. **The criterion should have read "every registered batch arm"**: every
> other census in this stop excludes preflight and deliberate-failure runs by name, and the §4a
> review caught this one claiming otherwise — the same scope error as the one corrected in §4 step
> 9's census the same day, found by a different reader. The original sentence is kept. The single failure is
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

## What was built at §4 step 4 — and the two things the build itself measured

*Written 2026-09-29/30 by Opus 5 (claude-opus-5), autonomously, after the build and before any
benchmark run of this stop. Nothing here is a result of Lab B11.1.*

### The overlay

`build/customizations/agent-v1.2-efficiency/` — **v1.1's seven files byte for byte, plus eight new
ones.** `CLAUDE.md` gains a `# v1.2 — efficiency` section and nothing above it changed; the
registered instructionsHash is **`sha256:1cb0ea105099353da3e8048b1a923687`** against v1.1's
`sha256:a94237242e8c1308fb1d434a06a03463`. `settings.json` necessarily differs — it is the wiring —
and the guards assert the control's copy is still v1.1's and names none of the new hooks.

| mechanism | files | layer | how it is counted |
|---|---|---|---|
| 1 classifier | `.ai/efficiency/classify-task.sh` | L3 | `H₁` — `task-classification-<worktree>.yaml` exists |
| 2 retrieval budget | `.ai/hooks/retrieval-budget.sh` + `.ai/policies/retrieval-budget.yaml` | **L2** | `H₂` — a line in `budget-log-<worktree>.jsonl` |
| 3 file-summary cache | `.ai/hooks/summary-cache.sh` (PreToolUse) + `.ai/hooks/summary-cache-record.sh` (PostToolUse) | **L2** | `H₃` — a line in `cache-log-<worktree>.jsonl` |
| 4 verification planner | `.ai/efficiency/verification-profiles.yaml` + the table in `CLAUDE.md` | L3 | `H₄` — **`unmeasured`, registered before the batch** |
| 5 command dedup | `.ai/hooks/command-dedup.sh` | **L2** | `H₅` — a line in `dedup-log-<worktree>.jsonl` |

**Mechanism 3 is two hook files and the registration says "the cache hook".** One event cannot
honestly do both jobs: the refusal must be `PreToolUse` (a `PostToolUse` exit 2 does not enforce —
`phases/05a-guardrails/README.md:58-60`), and the recorder must be `PostToolUse` or the cache would
hold entries for reads the retrieval budget then refused — a "you already have this" about content
the model never saw. Recorded as a refinement of the delivery row, not a change to it.

**The logs live OUTSIDE the worktree and the registered paths stay `.agent/*.jsonl`.** This is B8's
convention inherited (`.agent/run-state.json` is documented and the file is under `$TMPDIR`), and
the reason is measured: B7's preflight pair `2077432c` and `88b861f3` **solved their tasks** and
were scored exit 21 for "unrelated production files changed", where the single unrelated file was
the guardrail's own log (`E-016:227-237`); B9 hit it again (`E-022` Amendment 1). The evaluator's
ignore pattern is a registered variable, so teaching it to ignore `.agent/` is a §7 halt and is not
attempted.

**One spec line is NOT converted, and saying so is the point.** `build/README.md#b11` step 2 says
exceeding a limit "requires a recorded reason". There is no override channel, because an override
the model can write is an override it can write *without* a reason — which is the L2→L3 demotion
stop 7 recorded for `allowed-tools`. The limit refuses; the refusal is logged with its cause. The
`max_similar_implementations: 2` limit is likewise **`enforced: false`** in the policy file, with
the reason in the file: deciding that two files are the same *shape* is a semantic judgement, and
phrase-matching it is the trap the observatory's failure classifier paid for four times.

### The controls that execute, and the fixtures that prove they refuse

| fixture set | cases | what it proves that a batch cannot |
|---|---|---|
| `tools/verify-retrieval-budget.sh` | **24, exit 0** | the 6th search and the 16th file are refused; both limits STOP at the first edit; the log rule survives the phase change; a bounded `.log` read is allowed; an unreadable or non-integer policy **fails open and records that it did** |
| `tools/verify-summary-cache.sh` | **19, exit 0** | a hash match is refused and a hash MISMATCH is allowed with the entry dropped; the refusal carries a summary and **not the file body**; a `Grep` on the shared matcher is neither decided nor logged |
| `tools/verify-command-dedup.sh` | **22, exit 0** | a repeat under unchanged code is refused; **a gitignored `target/` write does not unlock it**; a tracked edit does; a quoted command logs intact; no git repo at all fails open |
| `evidence/b11/verify-b11-preflight-guards.sh` | **14, exit 0** | every one-variable guard refuses, including a new hook file present but **not wired**, and the fixture gate itself refuses in both directions |
| `evidence/b11/verify-b11-batch-guards.sh` | see §5 | author decision 13's ceiling is computed per task, refuses when it cannot be computed, and fires at `>=` |

A batch can only show that a refusal *happened*. It cannot show that a refusal was *right*, and on
a task the model passes nearly always, it may show no refusal at all — `build/README.md#b8`'s
problem one stop earlier. These five sets are the part that executes.

### Where the fixture sets stand at the end of step 4, exactly

| set | result | note |
|---|---|---|
| `tools/verify-retrieval-budget.sh` | **24 / 24, exit 0** | |
| `tools/verify-summary-cache.sh` | **19 / 19, exit 0** | |
| `tools/verify-command-dedup.sh` | **22 / 22, exit 0** | ~2 min: ~30 hook calls, each paying process startup (Finding 1) |
| `evidence/b11/verify-b11-preflight-guards.sh` | **14 / 14, exit 0** | |
| `evidence/b11/verify-b11-batch-guards.sh` | **16 / 17, exit 1** | case Q returns **exit 7 — a dead API**, not a wrong answer. It is the only case that needs a live stack, and the stack went down mid-build (see below). It is UNVERIFIED, not failing, and it is re-run before the batch. |

> **The last sentence of that row was a promise, nothing executed to keep it, and the §4a review
> round found that out (non-blocking finding 4). Recorded 2026-10-05 at §4 step 13a.** The batch
> driver's pre-batch fixture gate ran **three** sets — `verify-retrieval-budget`,
> `verify-summary-cache`, `verify-command-dedup` — and **not** `verify-b11-batch-guards.sh`, so the
> 40-run batch did run with that set last recorded at 16 of 17. Two things were done about it, in
> this order: it was **re-run at §4 step 13 and is 17 of 17 at exit 0** (the §5 table carries the
> fresh output), and the driver's gate **now includes it**, overridable only by `B11_BATCH_GUARDS`
> so a stub can prove the gate refuses — case I of `verify-b11-resume-seeding.sh`. **An L3 promise
> in a workbook row became an L2 gate in the driver, which is the only honest ending for this
> finding.**

The first three are wired into CI beside `verify-repair-limit.sh`, so they run on every push rather
than when someone remembers. **The two driver guard sets are not**, and the reason is case Q: they
need a live API and a live OTLP endpoint, which CI has not got.

Case O of the batch guards **passed for the wrong reason on its first run** and is worth recording:
it was carried over from B9, where the population is registered by a corpus hash, and it still
passed `mkbatch` the argument `knowledge`. The helper no longer knows that word, so it wrote the
REAL treated hash, the driver's grep found it, and the case reported "refuses a different
population" at exit 0 — a fixture reporting over a scope smaller than it claims, inside the file
whose own comment two functions higher warns about exactly that.

### The stack died during step 4, and the diagnosis is in the state file, not here

`agent-observatory-observatory-api-1` exited **137 (SIGKILL — OOM)** while the fixture sets were
running, and would not restart: the colima VM has **4 GiB with no swap**, and a container belonging
to another project on this machine (`repo-context-neo4j`, started mid-session, now **unhealthy**)
holds **1.48 GiB**, leaving **64 MB available**. §0a row 5 passed at 19:47Z — `All 18 checks
passed` — so the stack was healthy when the preflight was authorised and was not when it was
reached. **§4 step 5 is therefore not started**, and no run of this stop exists. The fix is one
command and it is the author's, because it touches a container outside these three repositories;
both options are in `TRACK-B-STATE.md` `author_notes`.

### Finding 1 — on this machine a hook's cost is dominated by process startup, not by its logic

Measured 2026-09-29 while building, not inferred: **`jq` costs ≈ 0.68 s per invocation here**
(2.72 s for four no-op calls) and `git status --porcelain` + `git diff` ≈ 0.6 s cold and ≈ 1.8 s
under load. The first version of `command-dedup.sh` made **five** `jq` calls and ran at **4.08 /
6.56 / 6.46 s per Bash tool call**. At roughly a hundred tool calls per run that is ten minutes of
pure hook latency — and it brings the 15-second hook timeout into range, where **a timed-out hook
is a control that silently did not run.**

Two consequences, both applied before any run: every hook now parses its stdin **once** and reads
its state **once**, and the four new hooks are registered with a **60-second timeout** while
v1.1's three keep 15 (so v1.1's carried-over files stay byte-identical). **This is why P6 predicts
`durationMs` rises and registers it as inadmissible** — and it is now clear that the rise is partly
*the number of hooks*, which is a property of the version rather than of the model's behaviour.
Nothing here is a measurement of the agent.

### Finding 2 — the fixture set caught a defect in my own optimisation, which is what it is for

Cutting the `jq` calls introduced `IFS=$'\t' read -r A B <<<"$(jq ... | @tsv)"`. **A tab is IFS
whitespace**, so bash strips it when it leads the string: a legitimately empty first field
disappears and every later field shifts left. On a store with no entry for a fingerprint that
turned `("", "?")` into `("?", "")` — so **a first run read as a repeat**, and the dedup hook would
have refused nothing while logging that it had. `verify-command-dedup.sh` case 1 failed on exactly
that, one line, before a single dollar was spent. All four hooks now read one value per line with
`IFS= read -r`, which preserves empty fields.

It is the same shape as `grep -c` counting lines and `ls -t` eating its argument: **a plausible
wrong answer, produced confidently.** The fixture sets were written because a batch cannot test a
refusal; this one paid for itself against the build instead.

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

**This section is the measurement record (§4 step 8). The seven exit-gate conditions are
answered at §4 step 11, below, not here.**

One interleaved batch, tag `20260930T115342Z`, `n = 10` per arm per task, 40 runs,
`--keep` throughout, `claude-haiku-4-5-20251001` on 40 of 40, benchmarks `2fc445d`.
Treated = the v1.2 overlay, control = v1.1. **Each task is its own experiment and no verdict is
computed across them** (author decision 9).

| | BE-003 (E-026) | BE-004 (E-027) |
|---|---|---|
| gate-admitted / run | 20 / 20 | 20 / 20 |
| evaluator exit 0 | 10 of 10 treated, 10 of 10 control | 10 of 10 treated, 10 of 10 control |
| **context total median (primary)** | 346 697 → 321 179 = **−7.36 %** | 515 872 → 527 854 = **+2.32 %** |
| registered MDE | ±8 % | ±8 % |
| re-derived MDE (bootstrap of the control median) | ±24.03 % | ±9.39 % |
| exact permutation `p` (184 756 splits) | 0.417 | 0.851 |
| **decision rule** | row 4 fires | row 4 fires |
| **verdict** | **`NOT DETECTABLE`** at `n = 10` | **`NOT DETECTABLE`** at `n = 10` |
| spend vs computed ceiling | $2.5830 / $2.8380 | $4.1496 / $4.5056 |
| claude CLI | **mixed 2.1.284 / 2.1.285** — named limitation | 2.1.285 on all 20 — no confound |

**Delivery, per mechanism, never pooled**, over the batch's **20** treated runs (not the 9 the
driver's own header claims — see `driver_summary_scope_defect`):

| | mechanism | layer | treated | control |
|---|---|---|---|---|
| H₁ | task classifier (prose-delivered) | L3 | **0 of 20** | 0 of 20 |
| H₂ | retrieval budget hook | L2 | **20 of 20** | 0 of 20 |
| H₃ | file-summary cache hook | L2 | **20 of 20** | 0 of 20 |
| H₄ | verification planner | — | **unmeasured**, registered so *before* the batch | — |
| H₅ | command-dedup hook | L2 | **20 of 20** | 0 of 20 |

`overlay_files` 8/8 on 20 of 20 treated and `ABSENT-as-registered` on 20 of 20 control, so
**row 0a fired 0 times**; `H₂`, `H₃` and `H₅` all at 20 of 20, so **row 0c does not fire and the
batch is scoreable**.

**`H₁ = 0 of 20` is a result, not a missing measurement.** It confirms P2 and the preflight's
0 of 2, and it sits beside B9's `H = 2 of 10` on the same prose-delivered route. **Three of the
five mechanisms reached every treated run; the two that did not are the two that do not
execute.** That is P3a, and it is B9's finding reached a second time by a different road.

**The TODO this section replaced pointed at `EXP-BE002-CLAUDEMD-V2`'s cache-creation finding —
carrying a context file cost ~5 300 cache-creation tokens, two thirds of it the extra *work*
prescribed rather than the context occupied — and warned that shrinking context may not recover
what you expect. On BE-003 the warning reads the other way and is worth keeping on record:**
`cacheCreationTokens` fell **14.61 %** (`p = 0.014`) and `outputTokens` fell **15.71 %**
(`p = 0.022`) while the registered primary moved only −7.36 % at `p = 0.417`. The primary is
~93 % `cachedTokens`, the noisiest term in its own sum (control range 242 611 – 817 222, a 3.4×
spread inside one arm), and it absorbed component movements that separate on their own. **Every
one of those components is registered "reported, no verdict" and is reported as exactly that**;
the finding is about how the primary outcome was defined, and it belongs to the next version's
registration, not to this stop's verdict.

Full numbers, both tasks: `experiments/E-026-efficiency-BE003.md` and
`experiments/E-027-efficiency-BE004.md` (Results). Re-derivable from
`evidence/b11/batch-20260930T115342Z/report/` — `per-run.tsv`, `REPORT.md`, `MDE.md`,
`summary.json`, `mde.json` — by re-running `evidence/b11/report-b11-batch.py` and
`evidence/b11/mde-b11-batch.py` against the same batch directory.

## Deliberate failure — §4 step 9, prediction registered 2026-10-05, five repetitions per case

**The registered probe is run as registered.** The original TODO is kept verbatim and it is what
runs; nothing below replaces it with an easier question.

> <!-- TODO: feed the file-summary cache a stale entry and confirm the hash
>      check refuses it. -->

### Why this runs as five repetitions of an executed case and not as five benchmark runs

The batch already measured how often the stale path occurs by itself: **4 `stale-refused` events on
2 of the 20 treated runs** (`evidence/b11/worktrees/*/cache-log.jsonl`, runs `40af8ffb` ×3 and
`1d38c74c` ×1). An `n = 5` live arm would therefore put a stale entry in front of **about one run**,
and a refusal rate computed on that is not a measurement — §5 forbids stating an `n < 5` result as a
property. This is b09's step-9 arithmetic reached again on a different mechanism, and the same
answer follows: **the clause that cannot be decided at the available `n` is not bought with money.**

What a live arm *would* have added is bought for nothing instead, because the hook is **delivered
into every treated worktree** and those worktrees are kept: `evidence.local/b11-worktrees/<runId>/.ai/hooks/summary-cache.sh`
hashes **`e78e6623725b426ffc241461711a7e318205fe674aecc3c76f0970e60d357df9`**, byte for byte the
registered overlay's copy. So the probe drives **the delivered artifact against that worktree's own
real files**, not a fixture tree — which is the one thing `tools/verify-summary-cache.sh` cannot
claim, and the reason it is not merely re-run here.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-10-05. Nothing above is rewritten.*

### What the batch already says about this mechanism, free, and it is the reason the break matters

Across the **22 copied cache logs** of the registered batch — **443 decisions** in total — the
tally is:

> **Scope correction, 2026-10-05, written by Opus 5 (claude-opus-5) the same session, after §4 step
> 10 re-derived the same tally against the manifest's run ids.** *"The 22 copied cache logs of the
> registered batch"* is **wrong by two logs**: `evidence/b11/worktrees/` holds 44 directories, of
> which 20 are the registered treated runs, 20 are controls (no hook, no log) and the rest are
> preflight runs — and **two preflight runs, `45bdc7c1` and `602a753c`, carry cache logs**. The
> registered population is therefore **20 logs and 403 decisions**, not 22 and 443. The table below
> is left exactly as it was computed and the corrected per-population figures are in §4 step 10,
> which is where the disposition is decided from. **Every qualitative claim is unchanged — `block
> hash-match` is 0 in both scopes — and the correction is recorded rather than applied in place
> because a count that quietly changes is worse than one that is visibly wrong once.** This is the
> house failure mode caught in my own prose, in the step whose whole subject is a control reporting
> over the wrong scope.

| decision · reason | count | what it is |
|---|---|---|
| `record stored` | 211 | the recorder half wrote an entry |
| `allow miss` | 207 | no entry for that path yet |
| `allow target-not-a-file` | 21 | the path did not resolve to a file |
| `allow stale-refused` | **4** | **the "never trust a stale summary" half executed** |
| `block hash-match` | **0** | **the "reuse only on hash match" half NEVER fired in a delivered run** |

**`cache_blocks = 0` on 20 of 20 treated runs**, and the same is true of the other two L2
mechanisms: `budget_blocks = 0` on 20 of 20 and `dedup_blocks = 0` on 20 of 20 (manifest columns
16, 18 and 21). So `H₂ = H₃ = H₅ = 20 of 20` says those hooks **ran and allowed**; it does not say
they refused anything. The driver's own comment said so before the batch
(`run-b11-batch.sh:400-403`), and it is now a measured fact rather than a caution. That is the
honest reading of the delivery metrics and it is carried into §4 step 10.

### The break: the mismatch branch deleted, and nothing else

`evidence/b11/deliberate-failure-<tag>/broken/summary-cache.sh` — a **copy** of the delivered hook
with lines 85–91 (the `[[ "$CACHED" != "$SHA" ]]` branch) removed, so a stale entry falls through to
the hash-match refusal. Every other byte is identical, proved by `diff`. **The measured overlay is
not touched** (§6: a measured version is never edited), and the probe lives under `evidence/`, not
under `build/customizations/`.

The failure this exposes is not a lost saving. It is a **correctness** failure produced by an
efficiency mechanism: the model is told *"you already read this file at this exact content"* about
content it has never seen.

### The registered predictions — every clause decided by an exit code or a log line

| # | prediction | mechanism | how it is decided |
|---|---|---|---|
| D1 | **A stale entry is refused, not reused**: the delivered hook exits **0** on **5 of 5** and writes `decision":"allow"`, `reason":"stale-refused"` | `summary-cache.sh:85-91` drops the entry and lets the read through | the hook's exit code and the `cache-log` line it appends |
| D2 | **The stale entry is deleted from the store, not merely ignored**: an immediately repeated identical call logs `reason":"miss"` on **5 of 5** | `jq 'del(.[$p])'` at `:88` rewrites the store before the allow | the second call's log line, and `jq 'has($p)'` on the store |
| D3 | **A fresh entry IS refused**: with the stored sha equal to the file's current sha the hook exits **2** on **5 of 5**, `decision":"block"`, `reason":"hash-match"` | `:93-107` | exit code and log line |
| D4 | **The refusal carries metadata and not the file**: the stderr of D3 contains the path, the sha and the byte/line count, and **zero** lines of the file's body, on **5 of 5** | the store holds `{sha, ts, bytes, lines}` and no content — there is no body to leak | `grep -F` of the file's first non-blank source line against the captured stderr |
| D5 | **THE BREAK: with the mismatch branch removed the same stale entry is refused** — exit **2** on **5 of 5**, and the refusal names content the file no longer has | deleting `:85-91` makes the stale path reach `:93` | exit code of the patched copy on the identical input |
| D6 | **The seed is produced by the delivered recorder, not hand-written**: `summary-cache-record.sh` writes the entry whose `{sha,ts,bytes,lines}` the reader then judges, on **5 of 5** | the pair is the mechanism; a hand-written store would test a shape the system never produces | `record stored` in the log and the store's key set |

**Registered as the one most likely to be wrong:** D2. The delete is a read-modify-write through a
temp file and `mv`; if `jq` fails the `&&` leaves the old store in place and the entry survives,
which would make the second call a second `stale-refused` rather than a `miss`. Nothing in the
fixture set distinguishes those two outcomes on a store that is *writable but busy*.

**Cost: $0, no benchmark run, no model call.** The probe is five repetitions of six executed cases
against a kept worktree, and the ceiling is therefore not a money ceiling: it is that **no case may
need the live observatory, the registered scorer or any run id**, so a probe that reaches for one is
abandoned rather than widened.

*Predicted by Opus 5 (claude-opus-5), autonomously, 2026-10-05T18:5xZ; the author did not review
before the run.*

### The result — 45 of 45 assertions, five repetitions, `$0`, tag `20261005T185653Z`

Driver `evidence/b11/run-b11-deliberate-failure.sh`, ShellCheck clean, fixture set
`evidence/b11/verify-b11-deliberate-failure.sh` at **10 of 10, exit 0**, proving all four of the
driver's exit codes **and** that it can fail: case C registers the broken copy's own sha so the
sha refusal is bypassed, and the driver then fails **on D1 and D2 specifically** while D3 still
passes. A probe that has never been shown to fail would have been worth nothing here.

Record: [`evidence/b11/deliberate-failure-20261005T185653Z/RESULT.md`](../../evidence/b11/deliberate-failure-20261005T185653Z/RESULT.md),
with per-repetition stores, logs and captured refusals under `per-rep/1…5/`.

| clause | registered | observed | verdict |
|---|---|---|---|
| D1 | stale entry allowed, `stale-refused`, exit 0, 5 of 5 | 5 of 5 | **HELD** |
| D2 | entry deleted; the repeat call is a `miss`, 5 of 5 | 10 of 10 assertions | **HELD** |
| D3 | fresh entry refused, `hash-match`, exit 2, 5 of 5 | 5 of 5 | **HELD** |
| D4 | the refusal carries path + sha + size and no file body, 5 of 5 | 10 of 10 assertions | **HELD** |
| D5 | the break refuses a **changed** file, exit 2, 5 of 5 | 5 of 5 | **HELD** |
| D6 | the seed is written by the delivered recorder, 5 of 5 | 10 of 10 assertions | **HELD** |

**D2 was registered as the one most likely to be wrong and it held.** The read-modify-write through
`$STORE.tmp.$$` and `mv` dropped the key on 5 of 5, and the immediately repeated call logged `miss`
rather than a second `stale-refused` — which is the observation that separates *deleted* from
*ignored*, and the fixture set does not make it.

**One recorded refinement, not a changed prediction.** The prediction says the probe drives the
delivered hook against the worktree's own real files. A stale entry is produced by **changing** the
file, and changing a file inside `evidence.local/b11-worktrees/` would rewrite evidence, which §6
forbids. So the subject is a **byte copy** of
`…/40af8ffb…/sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt`,
and both shas are recorded in `RESULT.md` as identical —
`9a1bd8cc53095e9a016d17e122fc96229a4cf30522cfd95bcf050aaf89199ed4`. The hook itself is executed
**in place**, from the kept worktree, at the registered sha. *Recorded as a refinement of the
delivery, in the manner the workbook recorded mechanism 3's two hook files, rather than as an
amendment to a registered prediction.*

**And the subject's sha is one of the four natural stale events.** `9a1bd8cc` is the `sha` of the
third `stale-refused` line in run `40af8ffb`'s own cache log — the post-edit content the hook
hashed during the paid run. The probe therefore starts from a state the batch actually reached.

### What the break produced, and it is worse than a lost saving

With lines 85–91 removed, the delivered refusal text is handed to the model **about content it has
never seen**:

```
BLOCKED by the file-summary cache: you already read this file at this exact content.
  path        …/broken-subject.kt
  sha256      ef6f29c2bccdf6222279c4fc2b8ebef3e4ae54776e40f2e2ff96806e7afd684b
  size        2940 bytes, 82 lines
```

The sha printed is the **current** content; the size and line count are the **stale** entry's. So
an efficiency mechanism, with one branch missing, produces a **correctness** failure: the model is
told it already has a file it has not read, and is handed metadata for two different versions of it
in the same message. `build/README.md#b11` step 3's *"never trust a stale summary"* is therefore a
load-bearing clause and not a caution — removing exactly it, and nothing else, is sufficient.

**The break is self-reporting, and that is an instrument this stop did not have.** The broken hook's
own log line is internally contradictory:

```json
{"decision":"block","reason":"hash-match","sha":"ef6f29c2bccd…","cachedSha":"9a1bd8cc5309…"}
```

`reason:"hash-match"` with `sha ≠ cachedSha` cannot be true. So **`sha == cachedSha` on every
`hash-match` line is a checkable invariant of the cache log**, and a check that asserts it would
have caught this break from the log alone, with no probe. It does not exist. It is an additive
instrument, it moves no registered variable, and it is recorded here and in `author_notes` rather
than built mid-stop — §6 forbids a future step's artifacts early and this stop's build is measured.
In the registered batch the invariant holds trivially: there are **no** `hash-match` lines at all.

### What this does and does not license

- It establishes that mechanism 3's two decisions **both execute as specified**, in the delivered
  artifact, at the registered sha. That is the layer claim: **L2, proved by execution.**
- It establishes **nothing** about how often either decision is reached by the agent under test.
  The batch answers that and the answer is: `stale-refused` 4 times on 2 of 20 treated runs,
  `hash-match` **0 times in 443 decisions**. A mechanism that executes correctly and is never
  reached cannot save anything, and that is the finding §4 step 10 acts on — not a shortfall of
  this probe.

## §4 step 10 — keep, modify, remove: one decision per mechanism, from 847 hook decisions

*Written 2026-10-05 by Opus 5 (claude-opus-5), autonomously, after §4 steps 8 and 9 and from no
other input. The rule applied is §4 step 10's own: **"a rule with no measured effect is removed, and
its removal is recorded as the finding."** The row-4 verdict (`NOT DETECTABLE`, both tasks) states
no disposition, which is why this section exists.*

### The measurement the disposition rests on, re-derived this session over exactly the 20 registered treated runs

Every log of every registered treated run is present — **20 of 20 for each of the three
mechanisms** — and the three tallies are complete, not sampled:

| hook | log lines | the refusals | what was never reached |
|---|---|---|---|
| retrieval budget (`H₂`) | **324** | **0 `block`** | `searches` max = **0 on 20 of 20** against `max_initial_searches: 5`; `distinctFiles` max **7–13, median 12** against `max_files_before_design: 15` |
| file-summary cache (`H₃`) | **403** | **0 `block hash-match`**; 4 `allow stale-refused` on 2 runs | no file was ever re-read **at unchanged content** |
| command dedup (`H₅`) | **120** | **0 `block`**; 119 `first-run`, 1 `repeat-after-code-changed` | no command was ever repeated **under unchanged code** |

**847 decisions. Zero refusals.** `H₂ = H₃ = H₅ = 20 of 20` means those hooks *ran*; it does not
mean they *did* anything, and this is the number that separates the two. The driver said so before
the batch (`run-b11-batch.sh:400-403`) and the batch has now filled it in.

**And `searches = 0 on 20 of 20` is not a wiring defect — the wiring was checked.**
`settings.json` puts `retrieval-budget.sh` on `PreToolUse` `Read|Grep|Glob` as well as on
`Edit|Write|NotebookEdit`, so a `Grep` or a `Glob` attempt would have been seen and logged by the
same hook that logged 207 `Read` lines. There are **none**. The agent under test, on these two
tasks, does not search — it reads. *(An earlier reading of this file's wiring looked like a defect
and was mine: a `jq` one-liner joined each entry's commands and then stripped to the last `/`,
hiding the first command of every pair. Checked again, printed per command, before anything was
decided on it.)*

### The disposition, and the ground named for each

| # | mechanism | layer | disposition | the ground, and it is measured |
|---|---|---|---|---|
| 1 | task classifier | L3 | **REMOVE** | `H₁ = 0 of 20`. Prose in a `CLAUDE.md` asking the model to run a script is now measured twice on this instrument — B9's `H = 2 of 10` and this stop's 0 of 20 — and the second measurement is the stronger one because the file was *proved delivered* on 20 of 20 by `instructionsHash`. §4 step 10's rule applies literally. **The removal is the finding: delivery is not invocation.** |
| 2 | retrieval budget | **L2** | **KEEP the control, REMOVE the efficiency claim** | It refuses — 24 fixture cases prove it, including both limits and the fail-open paths — and it refused **nothing in 324 live decisions**. A control that executes and is never reached has no measured effect *on this population*; removing it would also remove a proved refusal, which is not what the rule is for. So the file stays and **v1.2 claims nothing from it**. The next version re-registers the two limits against the measured distribution, which is now on record: **13 of 15 files at the maximum, 0 of 5 searches ever.** |
| 3 | file-summary cache | **L2** | **KEEP the stale branch, REMOVE the reuse claim** | The two halves have different fates and must not be disposed of together. *"Never trust a stale summary"* **executed in paid runs** — 4 times, on 2 of 20 — and §4 step 9 showed that removing exactly that branch produces a correctness failure, so it is load-bearing. *"Reuse only on hash match"* fired **0 times in 403 decisions**: no file was re-read at unchanged content, so there was never a repeat to prevent. The mechanism keeps the half that fired and claims nothing from the half that did not. |
| 4 | verification planner | L3 | **REMOVE**, on a different ground, and the difference matters | `H₄` was registered **`unmeasured` before the batch**, and it is still unmeasured: a planner followed in the model's head leaves no artifact. This is **not** a measured null — it is an unmeasurable mechanism, and removing it is an instrument decision, not a result. Condition of re-entry, registered here: a planner returns only if it is delivered in a form that **writes the sequence it chose**, so that following it and ignoring it are distinguishable. |
| 5 | command dedup | **L2** | **KEEP the control, REMOVE the efficiency claim** | Same shape as 2. 22 fixture cases prove it refuses, including that a gitignored `target/` write does not unlock a repeat; 120 live decisions produced 119 `first-run` and one `repeat-after-code-changed` — which is the hook **correctly allowing** a repeat because the code had changed. There was no waste of this kind to remove. |

**Three removals and two claim-withdrawals is the honest total, and the version survives as its
hooks.** P3a predicted *"the version's content is its hooks, not its instructions"* and it held —
but the step-10 reading is sharper than the prediction: **the version's content is three hooks that
are correct, proved by 65 fixture cases, and inert, proved by 847 live decisions.**

### What this does not license

- **It is not "the mechanisms do not work."** Every one of the three L2 refusals is proved to fire
  by a fixture set that executes; two of them have never had the chance in a paid run, and the
  third fired on the one path the task reaches.
- **It is not "efficiency work is pointless."** It is that *this* waste — repeated reads of
  unchanged files, repeated commands under unchanged code, unbounded search — **is not present in
  this agent on these two tasks**, measured, 847 decisions, `n = 20`.
- **It does not reach the disposition of v1.2 as a version.** That is the exit gate, below.

## Exit gate

**From the build track — all must hold vs v1.1:** same or better acceptance · same hidden-test
success · fewer repeated reads · fewer unnecessary tool calls · lower median input tokens ·
lower median time-to-green · **no increase in material review corrections.**

> Efficiency improvements are rejected when quality declines. No exceptions.

### The seven clauses, answered one by one — §4 step 11

*Answered 2026-10-05 by Opus 5 (claude-opus-5), autonomously, from the batch, the hook logs and the
stored run records. Every clause is answered or recorded unanswerable; none is left to be inferred
from a neighbour.*

| # | clause | answer | evidence |
|---|---|---|---|
| 1 | same or better acceptance | **HOLDS, at equality** — `passed: true`, `acceptanceRate: 1` on **10 of 10 in all four arms** | the 40 stored `run-record.json` under `evidence/b11/worktrees/<runId>/` |
| 2 | same hidden-test success | **HOLDS, at equality** — `testsPassed: true` on **10 of 10 in all four arms**; `buildPassed` and `staticAnalysisPassed` likewise | same |
| 3 | fewer repeated reads | **UNANSWERABLE, registered so before the batch** (Extract §3). The cache log counts repeated reads *by target* — the one thing telemetry cannot — but **only in the treated arm**, because the control has no hook. One-armed: no comparison exists. What it did measure: **0 re-reads at unchanged content and 4 at changed content, in 403 decisions** | `evidence/b11/worktrees/*/cache-log.jsonl`; `infra/otel-collector/config.yaml:48` |
| 4 | fewer unnecessary tool calls | **COUNT answered, "unnecessary" UNANSWERABLE.** `toolCalls` median 20 → 18.5 on BE-003 (**−7.50 %**, exact perm `p = 0.428`) and 25 → 24 on BE-004 (−4.00 %, `p = 1.000`). Neither separates. No instrument distinguishes a necessary call from an unnecessary one | `report/REPORT.md:17,45`; `report/MDE.md:20,38` |
| 5 | lower median input tokens | **DOES NOT HOLD.** Read as registered (context total, because `inputTokens` is 0.3–0.5 % of the context a run consumes): **−7.36 % at `p = 0.417`** on BE-003 and **+2.32 % at `p = 0.851`** on BE-004. Row 4 on both tasks: **`NOT DETECTABLE`** | `experiments/E-026…`, `E-027…`; `report/MDE.md` |
| 6 | lower median time-to-green | **PROXY ONLY, registered so.** `durationMs` is whole-run and sleep-contaminated: **−11.49 % at `p = 0.276`** on BE-003, **+3.19 % at `p = 0.540`** on BE-004. P6 predicted a rise and is **refuted on BE-003**. Neither separates, and the field is not time-to-green either way | `report/MDE.md:18,36` |
| 7 | no increase in material review corrections | **UNANSWERABLE.** `humanReviews` has length **0 on 40 of 40**; no human reviewer exists in this instrument | the 40 stored records |

**The gate reads "all must hold". Three clauses cannot be answered by this instrument, one is a
proxy, and the one measurable efficiency clause did not hold. So the gate is NOT MET and v1.2 is
NOT PROMOTED.** That outcome was registered before the batch — *"four of the gate's seven clauses
have no instrument, so v1.2 cannot be promoted at this stop even on an `IMPROVED` row"* — and it did
not get an `IMPROVED` row either. B7 is the precedent for that being a result.

**The "no exceptions" sentence did not fire, and it matters that it did not.** *"Efficiency
improvements are rejected when quality declines"* — quality did not decline: acceptance, hidden
tests, build and static analysis are identical in all four arms, and all four rubric medians moved
by 0 on BE-003. On BE-004 `change-focus` moved 0.5 → 0 at exact perm `p = 1.000`, carved out of the
decision rule by P5 as registered before the run, with the `REJECT` reading written beside it in
E-027 for the author to overrule without re-deriving anything. **v1.2 is kept, not promoted** — the
disposition per mechanism is §4 step 10 above, and it is three removals and two withdrawn claims.

### Was this the agent, or the harness?

**Neither. It was the task population, and that is measurable rather than rhetorical.**

- Not the **harness**: the treatment was proved delivered on 20 of 20 treated runs by
  `instructionsHash` and by 8/8 overlay files in the setup commit's tree, and absent on 20 of 20
  controls; the three hooks executed, logging **847 decisions**; `report-b11-batch.py`'s consistency
  gate found **0 problems on 40 runs**; and the fixture sets prove all three refusals fire — 65
  cases across the three, plus 14 preflight guards and the step-9 set at 10.
- Not the **agent's capability**: it solved both tasks in every arm, 40 of 40 gate-admitted, 10 of
  10 accepted in each of the four arms.
- It was the **absence of the waste the version targets**. In 847 decisions the agent never re-read
  a file at unchanged content, never repeated a command under unchanged code, and never issued a
  single `Grep` or `Glob` — and it read **7–13 distinct files against a limit of 15**. Three
  mechanisms were built to remove three behaviours that this agent, on these two tasks, does not
  exhibit.
- **The harness did contribute one thing, and it is the registered primary's definition.** Context
  total is ~93 % `cachedTokens`, whose control range spans 242 611–817 222 — a 3.4× spread inside
  one arm — and it absorbed three component movements that separate on their own
  (`outputTokens` −15.71 %, `p = 0.022`; `cacheCreationTokens` −14.61 %, `p = 0.014`;
  `estimatedCost` −12.47 %, `p = 0.036`, all BE-003). Those are registered **"reported, no
  verdict"** and are reported as exactly that. **Promoting one to the headline after seeing it would
  be moving a registered variable after the run (§6).** It is an argument about the *next* version's
  registration.

### The learning block

```yaml
learning:
  what_was_added: >
    v1.2 — eight files over v1.1: a task classifier (L3, prose-invoked), a retrieval-budget
    PreToolUse hook with a policy file (L2), a two-part file-summary cache, reader plus recorder
    (L2), a verification-planner profile table (L3), and a command-dedup PreToolUse hook (L2).
    Registered as ONE variable, the version, with a per-mechanism delivery metric H1..H5.
  why_it_exists: >
    build/README.md#b11: caches, budgets and dedup, "only after correctness is stable" — the
    conditional gate was answered first from 44 stored runs and no new runs.
  observed_effect: >
    On the registered primary, nothing an instrument can see: context total -7.36 % at exact
    perm p = 0.417 (BE-003) and +2.32 % at p = 0.851 (BE-004), both inside every one of the
    three MDE readings. Row 4, NOT DETECTABLE, on both tasks at n = 10. Acceptance, hidden
    tests, build and static analysis identical in all four arms. All four rubric medians 0 on
    BE-003. 847 hook decisions produced ZERO refusals.
  unexpected_effect: >
    Three things. (1) Duration FELL 11.49 % on BE-003 where P6 predicted a rise - refuted.
    (2) Three secondaries on BE-003 moved outside the registered band and separate on their own
    (outputTokens, cacheCreationTokens, estimatedCost) while the composite primary did not,
    which is a property of how the primary was defined, not a finding about the treatment.
    (3) The agent issues no Grep and no Glob at all on these tasks, so one of the two registered
    budget limits guards a behaviour that does not occur.
  keep_or_remove: >
    Per mechanism, never pooled. REMOVE the classifier (H1 = 0 of 20) and the verification
    planner (unmeasurable by registration, with a condition of re-entry). KEEP all three L2
    hooks and REMOVE the efficiency claim from the budget and the dedup; KEEP the cache's
    stale branch, which fired in paid runs and is load-bearing for correctness (step 9),
    and withdraw the reuse claim, which fired 0 times in 403 decisions. v1.2 is kept and
    NOT promoted; the gate is not met and four of its seven clauses have no instrument.
  next_question: >
    The one this stop can pose and not answer: does the waste exist at all on a task large
    enough to produce it? Every mechanism here is correct and inert, and inertness was measured
    on two tasks the agent passes 40 of 40. BE-005 is the first task in this track built to be
    failable, so the question belongs to whatever step runs on it - registered there, before any
    run, with the limits re-derived from the distribution this stop measured: 13 of 15 files at
    the maximum, 0 of 5 searches ever.
```


## Validation — §5, every row filled

*Built 2026-10-05 by Opus 5 (claude-opus-5), autonomously, at §4 step 13. Every verification command
in the right-hand column was **re-run in this session immediately before this table was written**,
not quoted from an earlier one; the fresh output is in the rows. Evidence is a path, a sha or a run
id — never a sentence.*

**The six fixture sets, re-run now, 106 cases:**

```
verify-retrieval-budget.sh        rc=0  24 ok  all 24 cases behaved as specified.
verify-summary-cache.sh           rc=0  19 ok  all 19 cases behaved as specified.
verify-command-dedup.sh           rc=0  22 ok  all 22 cases behaved as specified.
verify-b11-preflight-guards.sh    rc=0  14 ok
verify-b11-batch-guards.sh        rc=0  17 ok     <-- 16/17 and UNVERIFIED at §4 step 4
verify-b11-deliberate-failure.sh  rc=0  10 ok  all 10 cases behaved as specified.
```

**`verify-b11-batch-guards.sh` is now 17 of 17 at exit 0.** At §4 step 4 it was **16 of 17, exit 1**,
with case Q returning exit 7 — a dead API — because the stack went down mid-build. The workbook
recorded it then as *"UNVERIFIED, not failing, and it is re-run before the batch."* It was, and this
is the re-run that closes it: author decision 13's per-task cost ceiling is computed, refuses when it
cannot be computed, and fires at `>=`.

| Gate clause (verbatim from the step) | Evidence (path, sha, run id) | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| "same or better acceptance" | `evaluation.passed: true`, `acceptanceRate: 1` on 10 of 10 in all four arms — the 40 records at `evidence/b11/worktrees/<runId>/run-record.json` | **L2** — the evaluator executes and sets the field | `for r in $(awk -F'\t' '!/^#/&&NF>20{print $4}' evidence/b11/batch-20260930T115342Z/manifest.tsv); do jq -r '.evaluation.passed' evidence/b11/worktrees/$r/run-record.json; done \| sort \| uniq -c` → `40 true` |
| "same hidden-test success" | `evaluation.testsPassed: true` on 10 of 10 in all four arms, same 40 records; `buildPassed` and `staticAnalysisPassed` likewise | **L2** — the two evaluator-owned suites run | same loop on `.evaluation.testsPassed` |
| "fewer repeated reads" | **UNANSWERABLE, registered before the batch** (Extract §3). Instrument reason: `infra/otel-collector/config.yaml:48` deletes `tool.arguments`. One-armed substitute, treated only: `evidence/b11/worktrees/*/cache-log.jsonl` — **403 decisions, 0 at unchanged content, 4 `stale-refused`** | **L3 for the clause** (nothing executes that could compare the arms); L2 for the substitute measurement | `cat evidence/b11/worktrees/<20 treated ids>/cache-log.jsonl \| jq -r .reason \| sort \| uniq -c`; the control dirs hold `cache-log-absent.txt` |
| "fewer unnecessary tool calls" | count: `report/REPORT.md:17` BE-003 20 → 18.5 (−7.50 %), `:45` BE-004 25 → 24 (−4.00 %); `report/MDE.md:20,38` exact perm `p = 0.428` / `1.000`. "unnecessary": **no instrument** | **L2** for the count; **L3** for "unnecessary" | `python3 evidence/b11/report-b11-batch.py evidence/b11/batch-20260930T115342Z` and `mde-b11-batch.py` — seed 20260930, byte-identical re-derivation |
| "lower median input tokens" | **DOES NOT HOLD.** Registered reading = context total: 346 697 → 321 179 = **−7.36 %**, exact perm `p = 0.417` (BE-003); 515 872 → 527 854 = **+2.32 %**, `p = 0.851` (BE-004). `report/MDE.md`, `summary.json`, `mde.json` | **L2** — the numbers come from 40 API records via a script that refuses to print if a consistency check fails | re-run both scripts against `evidence/b11/batch-20260930T115342Z/`; `per-run.tsv` carries all 40 rows × 21 columns |
| "lower median time-to-green" | **PROXY ONLY, registered so.** `durationMs` −11.49 % at `p = 0.276` (BE-003), +3.19 % at `p = 0.540` (BE-004): `report/MDE.md:18,36` | **L3** — the field is whole-run and sleep-contaminated; it is not the clause's quantity | same scripts; the field is `efficiency.durationMs` in each record |
| "no increase in material review corrections" | **UNANSWERABLE.** `humanReviews` length **0 on 40 of 40** | **L3** — no reviewer exists in the instrument | the same loop on `.humanReviews \| length` → `40 0` |
| "Only after correctness is stable" (the step's precondition) | Extract §1, answered from **44 stored v1.1 runs** before anything was built, 43 of 44 accepted | **L3** — nothing executes to stop a builder opening B11 on an unstable v1.1; the audit is prose over stored data | the stored run records the extract cites; the gap is a candidate instrument PR, named in the workbook |
| Prediction precedes the first run (§4 step 3) | prediction commit **`2552b75`**, `git show -s --format=%cI` = **2026-09-29T19:30:40Z**; earliest `startedAt` over the 40 records = **2026-09-30T11:53:45Z**, run `5cc74707` — **16 h 23 min** of margin | **L2** — both timestamps are machine-written, one by git and one by the API | `git show -s --format=%cI 2552b75`; `jq -r .startedAt` over the 40 records, `sort \| head -1` |
| Treatment delivered, and absent from the control (§4 step 5) | `instructionsHash` `sha256:1cb0ea105099353da3e8048b1a923687` on **20 of 20 treated**, `sha256:a94237242e8c1308fb1d434a06a03463` on **20 of 20 control**; `overlay_files` **8/8 in the setup commit's tree** on 20 of 20 treated and `ABSENT-as-registered` on 20 of 20 control → **row 0a fired 0 times** | **L2** — the hash is computed per run by the runner; the file list is `git ls-files` in the kept worktree, not a directory listing | `manifest.tsv` columns 11 and 23; `evidence/b11/worktrees/<runId>/git-ls-files.txt` |
| One variable moved (§6 independence) | `agentHash` **equal in both arms** (`sha256:b3450564b6f32d6193e8580db766210e`); rubric sha constant per task — `396e1799eb2b` on 20 of 20 BE-003, `6252778b8472` on 20 of 20 BE-004; benchmarks **`2fc445d`**; `runtime.model` **`claude-haiku-4-5-20251001` on 40 of 40** | **L2** — read from the run records, not from the flags that were passed | `awk -F'\t' 'NR>1{print $1,$17}' report/per-run.tsv \| sort \| uniq -c`; `manifest.tsv` header lines 2–6 |
| …**with one named exception, and it is not hidden** | the claude CLI moved inside the batch: BE-003 is **treated 6/4, control 5/5** across 2.1.284 → 2.1.285; BE-004 is **2.1.285 on all 20**. An unregistered variable with a one-run imbalance on one task | **L2** for the observation (`runtime.version` per record), **L3** for the judgement that it is tolerable | `awk -F'\t' 'NR>1{print $1,$2,$5}' report/per-run.tsv \| sort \| uniq -c`; `make baseline-report` prints `WARNING: this arm mixes 2 runtime versions` for BE-003 and nothing for BE-004 |
| A scored cell re-read by hand (§5) | `change-focus` on run **`f1e82607`** (BE-004 treated seq 10), rubric re-hashed on disk at **`6252778b8472`**: my hand reading **1**, the sheet **0**. The diff decided it and **the sheet is right** — both test `reset()` helpers turn an expression body into a block, which anchor 0 names verbatim. Written up in E-027 "Sanity checks" | **L2** — the disagreement was resolved against the diff, which executes nothing but is the artifact both readings describe | open `evidence.local/b11-worktrees/f1e82607…`, diff the attached files, read anchor 0 of the rubric at that sha |
| Deliberate failure (§4 step 9) | `evidence/b11/deliberate-failure-20261005T185653Z/RESULT.md` — **45 assertions, 0 failures**, 5 repetitions, 6 clauses; driver ShellCheck clean; fixture set **10 of 10** proving all four exit codes **and** that the driver can fail (case C fails on D1/D2 while D3 still passes) | **L2** — the delivered hook at the registered sha `e78e6623…`, executed | `./evidence/b11/verify-b11-deliberate-failure.sh` then `./evidence/b11/run-b11-deliberate-failure.sh` |
| `manifest_header_defect` — a wrong prediction-commit line in every manifest header | `run-b11-batch.sh:349` prints a hardcoded `# prediction commit ef2c6c0 at 2026-09-26`. **`ef2c6c0` is stop 20's prediction commit**, carried over when this driver was derived from stop 20's. Stop 26's is `2552b75`. The ordering check above is answered from `git %cI` and the API, **never from this header** | **L3** — the header is prose and moves no behaviour; the defect is that a reader could trust it | `sed -n '349p' evidence/b11/run-b11-batch.sh`; `git log --oneline ef2c6c0 -1` shows stop 20 |
| `driver_summary_scope_defect` — a summary header that divides by the wrong `n` | `evidence/b11/batch-20260930T115342Z/window.txt` prints `DELIVERY … over 9 treated run(s):` and then `H₂/H₃/H₅ = 20`. The counts are manifest-wide and correct; the **`9`** is the treated count of the third launch only | **L3** — prose; the numbers beside it are right | `grep -n 'treated run(s)' evidence/b11/batch-20260930T115342Z/window.txt`; re-derive 20 with `awk -F'\t' '$3=="treated"'` over the manifest |
| Both defects' disposition | **not fixed mid-batch**, by §4 step 4 (never edit a tool while a run of it is in flight — 11 rows of this population were already produced by that file). They travel into **one additive instrument PR** after this stop's review, which is the builder's own merge under §4 step 14 | **L3** — a decision, recorded | the two blocks in `TRACK-B-STATE.md` and this row |

**Every number above carries its `n`, and the two that are `n < 5` are stated as true of those
runs and not as properties:** the 4 `stale-refused` events occur on **2 of 20** treated runs, and
the single `repeat-after-code-changed` occurs on **1 of 20**. Neither is a rate.

## §4a — the review round, finding by finding

*Taken 2026-10-05 at §4 step 13a by Opus 5 (claude-opus-5), autonomously. Two rounds, `-n 2` each,
`ollama-cloud/glm-5.2` line-level and `minimax-m3` as the acceptance gate. Every finding below is
either **fixed with the commit that fixed it** or **disputed with the reason its failure scenario
cannot occur** — §4a allows nothing else, and "stylistic" is not a dispute.*

| round | subject | file | gate | findings |
|---|---|---|---|---|
| A | the three contracts: this workbook, `E-026`, `E-027` | `findings/opencode/review-README-20261005T190718Z.md` | **ACCEPT** | 0 blocking, 5 non-blocking; 7 line-level findings collapsing to 4 distinct issues |
| B | the step-9 tools: `run-b11-deliberate-failure.sh`, `verify-b11-deliberate-failure.sh` | `findings/opencode/review-run-b11-deliberate-failure-20261005T190720Z.md` | **REJECT** | **1 blocking**, 3 non-blocking |
| B, round 2 | the same two tools, revised | `findings/opencode/review-run-b11-deliberate-failure-20261005T194122Z.md` | **REJECT** | **3 blocking**, 2 non-blocking — *every one of them a comment claiming more than the code does* |
| B, round 3 | the same two tools, revised again | see the PR body | the last round §4a allows | — |

### Round B, round 2 — three blocking findings, and all three are my comments outrunning my code

**This is the sharpest thing the review produced at this stop.** Each blocking finding is a sentence
I wrote that described behaviour the code did not have — the same defect class as the vacuous D4
check, committed *inside the fix for it*.

| round 2 finding | disposition |
|---|---|
| blocking 1: *"The default is the sha … run 40af8ffb recorded"* — **there was no default.** The round-1 fix guarded the comparison with `if [[ -n "${DF_EXPECT_SUBJECT_SHA:-}" ]]`, so an unpinned run pinned nothing | **FIXED** — the default is real: `EXPECT_SUBJECT_SHA="${DF_EXPECT_SUBJECT_SHA:-9a1bd8cc…}"`, and an override must now be deliberate |
| blocking 2: the verifier **had no case** exercising the subject-sha gate it claimed to verify | **FIXED** — **case K**: a copy of the subject with one byte appended is refused at exit 3, naming both shas |
| blocking 3: case C's comment claimed *"D3/D5 must still pass"* and **only D3 is checked** | **FIXED by correcting the comment, not by adding the assertion.** In case C the hook under test is already the broken copy, so the D5 copy is built by deleting lines 85–91 of a file those numbers no longer describe. What D5 does under a double break is a coincidence, not a property, and asserting it would be asserting the coincidence. D5's proof is case A, against the delivered hook |
| non-blocking 4: `BODY_LINE`'s pattern included `import`, so the "no body leaked" check could be looking for a **header** line | **FIXED** — the pattern is `class|fun|val|var`; a refusal echoing the import block would have satisfied a check named *no body leaked* |
| non-blocking 5: case F asserted exit 4 without checking its reason | **FIXED** — it now requires `PREREQ: recorder not executable` |

**And the new default immediately broke case H, which is the fixture set earning its keep on
itself.** With the subject pinned by default, case H's no-body substitute was refused at exit 3
*before* reaching the prerequisite it exists to test. It now pins its own sha deliberately and then
tests what it is named for. **`verify-b11-deliberate-failure.sh`: 15 of 15, exit 0.** The probe was
re-run again — tag `20261005T195104Z`, **45 of 45** — and both earlier records are kept.


### Round B — the blocking finding, and it is the house failure mode in my own probe

> **D4's "no body leaked" check is vacuous when `BODY_LINE` is empty.**
> `evidence/b11/run-b11-deliberate-failure.sh:127-131`

**FIXED at `85aa432`, and the finding is exactly right.** The check read
`if [[ -n "$BODY_LINE" ]] && grep -qF ... ; then FAIL else PASS`, so a subject file with no
`class`/`fun`/`import` line — a Kotlin file of only `package` and top-level `val`s, which the
`DF_SUBJECT` override can select — would have reported *"no body leaked"* **having tested nothing**.
A control that cannot fail is indistinguishable from one that does not run, which is the sentence
this project repeats to itself at every step, and it was in the step whose entire subject is a
control reporting over the wrong scope. An empty `BODY_LINE` is now a **refusal at exit 4 naming
D4**, and **case H** of the fixture set proves it.

**The probe was re-run under the stricter checks rather than its old result reinterpreted:** tag
`20261005T191930Z`, **45 of 45**, with D4 now matching the subject's **literal sha** instead of the
substring `sha256`, and the subject itself pinned by `DF_EXPECT_SUBJECT_SHA`. The first run's record
at `20261005T185653Z` is **kept untouched** (§6), and both are on disk.

| round B finding | disposition |
|---|---|
| blocking: D4 vacuous on an empty `BODY_LINE` | **FIXED**, `85aa432` — exit 4 + fixture case H |
| non-blocking 1: case F claimed "not executable" but pointed at a path never created | **FIXED**, `85aa432` — it now copies the real recorder and removes the bit |
| non-blocking 2: the subject's sha was recorded and never gated | **FIXED**, `85aa432` — `DF_EXPECT_SUBJECT_SHA`, plus a refusal if the copy differs from its source |
| non-blocking 3: D4's second assertion matched the substring `sha256`, which a debug line would satisfy | **FIXED**, `85aa432` — it matches the subject's own sha |
| the gate's own disputed item (it disputed the line-level pass on D5's double break in case C) | **nothing to do** — the gate and the line-level pass disagreed with each other; the gate's reading is the one the code supports, and case C's own assertions (fails on D1/D2, passes D3) are what the set checks |

### Round A — four issues, three fixed in place and one disputed

| round A finding | disposition |
|---|---|
| 1. the Goal says *"two … and one"* = 3 impaired clauses; Extract §3's table finds **five** | **FIXED**, `85aa432` — a dated correction beside the original sentence. Only clauses 1 and 2 are measurable as written |
| 2. `E-027` row 1 (*"any rubric category median drops"* → `REJECT`) and P5's `change-focus` carve-out, **registered in the same commit**, both fire on one datum | **FIXED by naming it**, `85aa432` — `E-027` **Amendment 1**: this is a **registration defect**, not a choice to be made after the numbers; the disposition already on record stands, with the `REJECT` reading beside it, and the forward rule is registered for the next prediction commit. No registered row, prediction or verdict is edited (§4 step 12) |
| 3. Extract §1 claims *"every claude-runtime run … ever recorded"* and the table counts four batch arms | **FIXED**, `85aa432` — and the reviewer was right about the overstatement while wrong about which runs were missing. They are **preflight and deliberate-failure runs**, queried from the live API: three of them, **all `exitCode 0`**, pooled **46 of 47**. The verdict does not move; the criterion should have read *"every registered batch arm"* |
| 4. the batch-guard set was recorded at 16/17 with *"it is re-run before the batch"* and **nothing executed to keep that promise** | **FIXED TWICE**, `85aa432` — the set is **17 of 17** as of §4 step 13, and the driver's pre-batch gate **now includes it**. An L3 promise in a workbook row became an L2 gate in the driver |
| 5. *"`ebf9e05e` at stop 17"* is said to conflict with attributing the B8 arm to B8, *"which would be stop 18"* | **DISPUTED.** The failure scenario cannot occur because the premise is wrong: `PROMPT-opus5-track-b.md` §3's itinerary puts **B8 at spine position 17**, B8a at 17a, and **Phases 6A/6B at 18–19**. *"stop 17"* and *"the B8 treated arm"* name the same batch. Nothing to fix |

### And the fix for finding 4 recursed, which is a finding of its own

Adding `verify-b11-batch-guards.sh` to the driver's pre-batch gate made the driver invoke the set
**that invokes the driver seventeen times**. It multiplied for about ten minutes before it was
killed; no run, no cost and no record were produced, and the leftover synthetic fixture directories
were removed. The gate is now **skipped in every `*_ONLY` mode** — the modes in which nothing is
run, spent or recorded, which are the modes the guard fixture uses — and **cases I and J** prove
both directions with stubs: a failing stub aborts at exit 6 naming the set, a passing stub is
passed through and the *next* guard stops the driver. **No fixture case is able to start a batch**,
which is the property that matters more than either direction. `verify-b11-resume-seeding.sh`:
**8 of 8, exit 0.**

**A gate whose own fixture set cannot run is not a gate — and the only reason that was found in
minutes rather than at the next batch is that the fixture set existed and was run.**

## Commit

<!-- TODO -->
