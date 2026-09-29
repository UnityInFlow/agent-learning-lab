# Experiment E-027 — B11 efficiency, v1.2, on BE-004-cancel-order

**Spine stop 26 · step B11 · version v1.1 → v1.2 · task BE-004-cancel-order · experiment key `EXP-B11-EFFICIENCY-BE004`**
Author decision 9: each task is its own experiment, and **no verdict is computed across tasks**.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-29T20:05Z; the author did not review before the run.`

## Question

Do the five efficiency mechanisms of `BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` §6 —
task classifier, retrieval budget, file-summary cache, verification planner, command
deduplication — reduce what a run **consumes** on BE-004-cancel-order without reducing what it
**achieves**, against a concurrent v1.1 control?

## Hypothesis

They do not, and they cost more than they save. Every mechanism is delivered as more overlay
content and more prescribed work; nothing in the set removes context except the retrieval
budget, which removes *file content the model then works around*. The measured history of
this track is that carrying instructions costs (E-003: ~5 300 cache-creation tokens, two
thirds of the premium being the prescribed work rather than the occupancy) and that an
executing L2 control changes nothing the rubric can see (B7: 17 of 17 fired, all four BE-004
deltas 0, +5.02 % cost).

**Registered before the run: the expected verdict is that v1.2 does not clear its own gate,
and is measured, kept and not promoted.** B7 is the precedent for that being a result.

## Predictions

Each has a direction, a magnitude and a mechanism. Registered before the first run.

**P1 — the context total goes UP, not down: median `+3 %` to `+12 %` against the concurrent
control.** *Mechanism:* the overlay's own files are read on every run, and the classifier,
cache and planner each prescribe steps that cost model calls. No mechanism in the set reduces
occupancy. E-003 and B7 both measured a positive premium for carrying a control.
*This is the prediction most likely to be wrong, and the magnitude is the part most likely to
be wrong in it* — if the retrieval budget bites hard enough to truncate a genuinely wasteful
read pattern, the content it removes could exceed the overlay's own cost and the sign flips.
That path is exactly what `H₂` is registered to detect.

**P2 — the two L3 mechanisms are not invoked: `H₁ ≤ 3 of n`, and `H₄` is `unmeasured`.**
*Mechanism:* B9 delivered a script plus a sentence telling the agent to run it and recorded
`H = 2 of 10`. Nothing about how an instruction carries has changed since stop 20. `H₄` is
registered unmeasurable **before** the batch: a verification plan followed in the model's head
leaves no artifact distinguishable from the commands v1.1 already runs.

**P3 — the three L2 mechanisms fire on `≥ 8 of n`.** *Mechanism:* a `PreToolUse` hook fires on
the runtime's dispatch, not on the model's compliance. B7's policy gate executed on 17 of 17;
B8's hooks ran 48 `PreToolUse` / 47 `PostToolUse`.

**P3a — the registered consequence of P2 and P3 both holding:** the version's measured content
is **its hooks and not its instructions**. That is B9's finding reached a second time by a
different route, and if it holds it is the strongest thing this stop returns.

**P4 — acceptance does not degrade: ≥ 8 of 10 evaluator exit 0 in the treated arm.**
*Mechanism:* 21 of 22 stored v1.1 runs passed, and the one failure (`ebf9e05e`, exit 11, F05) was on this task — a two-run allowance is registered because the failure is on record and a one-run allowance would make the clause unfalsifiable. The budget hook's refusals are recoverable — B8 recorded one refused
`Bash` that was not retried and cost nothing.
*The registered risk:* `max_files_before_design: 15` may refuse a read the task needs. If it
bites, acceptance falls and **decision-rule row 2 fires — REJECT — regardless of any saving.**

**P5 — no rubric category median moves on either arm.** *Mechanism:* every treatment since B7
has moved all four category medians by 0. The rubric scores the shape of the diff; nothing in
this overlay changes what to write, only what to read. BE-004 is the task that **has** failed on this model, once, and its `change-focus` direction reversed across a machine sleep at B8 (permutation `p = 0.2378`). `change-focus` is therefore reported and enters no decision-rule row on this task.

**P6 — `durationMs` rises and is not admissible as *time-to-green*.** *Mechanism:* hooks add
per-call latency, and the field is whole-run rather than time-to-first-green. It is reported
and enters no decision-rule row.

## Independent variable

**One variable: the version.** `agent-v1.1` → `agent-v1.2-efficiency`. P2 of
BUSINESS-REQUIREMENTS forbids several things in one comparison; the version is the level at
which this track registers a variable, on the precedent of B7 (policy file + gate hook +
protected-paths list = one variable) and B8 (run state + repair limits + completion contract =
one variable). Per-mechanism attribution is carried by `H₁…H₅`, registered below.

**The B9 knowledge router is NOT carried into this overlay.** B9 closed `VOID — the treatment
was not tested` at `H = 2 of 10`, so the router is a kept-but-unmeasured artifact, not part of
a measured version. Including it would put a second untested variable into this comparison.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | overlay directory `build/customizations/agent-v1.2-efficiency/`, installed by the runner's `--customization`: `CLAUDE.md`, `.claude/settings.json`, `.claude/agents/backend-feature-phases.md`, `.ai/policies/`, `.ai/hooks/` (v1.1's three plus the budget, cache and dedup hooks), `.ai/core/context-policy.md`, `.ai/efficiency/` |
| Content hash | `customization.instructionsHash`, `agentHash`, `agentsHash` and `hooksHash` read back per run. **`hooksHash` has been `null` on every run ever recorded** (stop 16 author note), so it is NOT relied on; the four L2 hook files are proved delivered by `git ls-files` in the kept worktree, as author decision 11 item 9 required for a multi-file overlay |
| Preflight assertion | one treated run before the batch: `instructionsHash` equals the overlay's registered sha, `git ls-files` in the kept worktree lists every overlay file by name, and at least one of `.agent/budget-log.jsonl`, `.agent/cache-log.jsonl`, `.agent/dedup-log.jsonl` is non-empty |
| Control assertion | one control run before the batch: `instructionsHash` equals **v1.1's** sha and not v1.2's, and none of the three `.agent/*-log.jsonl` files exists |

**A run missing its delivery proof is row 0a — void before scoring**, exactly as E-007 and
E-020 registered it. This is not optional bookkeeping: at stop 13 the preflight found the
treatment was not delivered and no batch was started, which saved a batch.

## Delivery metrics — per mechanism, never pooled

`H_i` = treated runs on which mechanism *i* left its own artifact, counted from the kept
worktree and not from telemetry, because the collector deletes `tool.arguments`
(workbook Extract §3).

| metric | mechanism | layer | artifact | registered |
|---|---|---|---|---|
| `H₁` | task classifier | L3 | `.agent/task-classification.yaml` naming a `task_type` | measured |
| `H₂` | retrieval budget | L2 | a line in `.agent/budget-log.jsonl` | measured |
| `H₃` | file-summary cache | L2 | a line in `.agent/cache-log.jsonl` | measured |
| `H₄` | verification planner | L3 | none exists | **`unmeasured`, registered before the batch** |
| `H₅` | command dedup | L2 | a line in `.agent/dedup-log.jsonl` | measured |

B9's Amendment 5 is why these are separate: a pooled `H` there counted invocations of one
thing and was read as consultation of another.

## Controlled variables

| variable | value | proved by |
|---|---|---|
| model | `claude-haiku-4-5-20251001` | `runtime.model` per run |
| runtime | claude, `--isolate-user-settings` | `runtime.userSettingsIsolated`, `shimsStripped` |
| task | BE-004-cancel-order | `benchmarkId` per run |
| rubric | `benchmark/rubrics/backend-quality-be004.yaml`, sha `6252778b8472` | read back from every sheet |
| evaluator | unchanged exit-code contract | `evaluation.evaluatorVersion` |
| benchmark sha | one commit for the whole batch | `repository.commitSha` per run |
| scorer | codex (Decision C) | sheet provenance header |
| interleaving | treated/control alternating in one batch | batch manifest order |

## Runs

`n = 10` per arm, interleaved, one batch, `--keep` always. **Cost ceiling: author decision
13 — 11 × the measured preflight-pair cost for this task, computed by the batch driver and
not carried as a flat number.** The driver reads the preflight manifest, sums the treated +
control cost, multiplies, and exits on reaching it, reporting the population that occurred
(row 0b, E-016's precedent at `n = 7`). Decision 13 item (iv) is explicit that a
multiplication living in prose is L3 again, so it is computed in the driver or it is not a
control. The known defect of the stop-20 driver — an `awk` sum over a column that was
sometimes `no`, yielding a `$0.0000` ceiling that fired on the first pair — gets its own
fixture in this step's `verify-*.sh`.

## Minimum detectable effect

**Transferred from the stored v1.1 populations, and stated as transferred**, then re-derived
from this stop's own concurrent control before any verdict — exactly as author decision 9
item 3 and E-011 did for BE-004, and decision 11 item 10 for BE-005. The reason it must be
re-derived here is measured, not procedural: **`inputTokens` on these two tasks moved ~8×
between stop 17 and stop 20 with no treatment intending it** (BE-003 median 1 392 → 170,
BE-004 1 643 → 222), so a stored baseline for anything token-shaped is not comparable across
stops.

| Outcome | measured spread it comes from | MDE at `n = 10` | registered before the run? |
|---|---|---|---|
| **primary: context total median** (`inputTokens + cachedTokens + cacheCreationTokens`) | v1.1 565 842 (B8, `n=10`) and 547 063 (B9 control, `n=12`) — the two stored v1.1 medians differ by themselves | **transferred: ±8 %**; re-derived from this batch's control | yes, as transferred |
| primary: evaluator exit 0 | 21 of 22 stored v1.1 runs | a 2-run difference at `n = 10` (Fisher 10/10 vs 8/10 → `p = 0.47`; 10/10 vs 5/10 → `p = 0.033`) | yes |
| secondary: `estimatedCost` median | v1.1 $0.2142 (B8) / $0.209 (B9) | reported, no verdict | yes |
| secondary: `behavior.toolCalls` median | v1.1 26.5 (B8) / 26 (B9) | reported, no verdict | yes |
| secondary: `inputTokens` median alone | v1.1 1 643 (B8) / 222 (B9) | reported **beside** the context total so the semantic gap stays visible | yes |
| secondary: `durationMs` | v1.1 191 000 (B8) / 176 500 (B9) | **no verdict** — whole-run, not time-to-green, and the BE-004 v1.1 population holds two sleep-contaminated runs (9 226 000 ms, 15 090 000 ms) | yes |
| quality non-regression: four rubric category medians | v1.1's stored distributions | any category median dropping fires row 2 | yes |

## Deterministic evaluation

The benchmark's own evaluator, unchanged exit-code contract, `evaluation.exitCode` per run.
`check-run-gate.sh` admits a run to scoring; only gate-admitted runs are compared.

## Exclusions

Registered before the batch:

1. A run whose delivery proof fails → **row 0a, void before scoring**.
2. An `api_error` / F13 infrastructure abort with 0 edits → excluded and **not topped up**,
   as E-019 excluded three control runs by registration.
3. A run spanning a machine sleep → **duration excluded, the run kept** (§4 step 6).
4. The cost ceiling stopping the batch → the population that occurred is reported (row 0b).

## Decision rule

Evaluated in order; the first row that fires is the verdict.

| row | condition | verdict / disposition |
|---|---|---|
| **0a** | a treated run's delivery proof fails | that run is void before scoring |
| **0b** | the computed cost ceiling is reached before `n = 10` per arm | report the population that occurred; continue to the rows below at that `n` |
| **0c** | `H₂ ≤ 2 of n` **and** `H₃ ≤ 2 of n` **and** `H₅ ≤ 2 of n` | **`VOID — THE TREATMENT WAS NOT TESTED`**, B9's row 0 |
| **1** | any rubric category median drops, **or** treated acceptance below the P4 threshold | **`REJECT`** — *"efficiency improvements are rejected when quality declines. No exceptions."* Disposition: v1.2 not promoted, overlay kept, the mechanism that cost the quality named |
| **2** | context total median drops by ≥ the re-derived MDE **and** row 1 does not fire | **`IMPROVED`** — v1.2 clears its measurable clauses; promotion still requires the four clauses this instrument cannot answer, which are recorded `unmeasured` |
| **3** | context total median rises by ≥ the re-derived MDE | **`REGRESSION ON THE REGISTERED OUTCOME`** — the efficiency step made the agent heavier. Disposition: not promoted; per §4 step 10 each mechanism with `H_i ≥ 8` and no measured saving is **removed**, and the removal is the finding |
| **4** | \|delta\| inside the re-derived MDE | **`NOT DETECTABLE`** at this `n` |

**Four of the gate's seven clauses cannot be answered by this instrument** (workbook Extract
§3: repeated reads, unnecessary tool calls, time-to-green, material review corrections). They
are recorded `unmeasured` with their reason, on the precedent of author decision 10.3 and
stop 17a's `change-focus`. **The gate is all-or-nothing, so v1.2 cannot be promoted at this
stop even on an `IMPROVED` row** — and that is registered here, before the run, rather than
discovered as a disappointment after it.

## Observed telemetry

*To be filled after the batch. `OTLP_GRPC_PORT` passed, and `events.jsonl` confirmed to grow
before any telemetry-sourced number is trusted (stop 11's rule).*

## Results

*To be filled after the batch.*

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | context total up 3–12 % | | |
| 2 | `H₁ ≤ 3 of n`, `H₄` unmeasured | | |
| 3 | `H₂`, `H₃`, `H₅` each `≥ 8 of n` | | |
| 3a | the version's content is its hooks, not its instructions | | |
| 4 | acceptance ≥ 8 of 10 | | |
| 5 | no rubric category median moves | | |
| 6 | `durationMs` rises, inadmissible as time-to-green | | |

## Failure analysis

*To be filled after the batch.*

## Sanity checks

- Prediction commit timestamp precedes the first run's `startedAt` — both written into this
  file after the batch, read from git and the run record and not from prose.
- `customization.*Hash` compared across arms; `hooksHash` is `null` on every run ever
  recorded and is **not** used as a proof.
- Rubric sha `6252778b8472` read back from every sheet.
- One scored cell re-read by hand off the kept worktree before any sheet is opened.

## Decision

*To be filled after the batch.*

## Follow-up

*To be filled after the batch.*
