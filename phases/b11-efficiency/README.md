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

### The result

<!-- Written after the probe. §4 step 12: nothing above is edited. -->

## Exit gate

**From the build track — all must hold vs v1.1:** same or better acceptance · same hidden-test
success · fewer repeated reads · fewer unnecessary tool calls · lower median input tokens ·
lower median time-to-green · **no increase in material review corrections.**

> Efficiency improvements are rejected when quality declines. No exceptions.

**Plus, for this to count as a learned phase:**

<!-- TODO -->

## Commit

<!-- TODO -->
