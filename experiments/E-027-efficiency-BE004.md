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

`OTLP_GRPC_PORT` was passed by the batch driver and `events.jsonl` was confirmed to grow
before any telemetry-sourced number was trusted (stop 11's rule):
`infra/telemetry-out/events.jsonl` **2 812 885 bytes at launch → 12 305 271 at batch end →
12 418 914 at the step-8 read**. No number below is telemetry-sourced; every one comes from the
API run record or from a codex sheet.

## Results

`n = 10` per arm, 20 runs, one interleaved batch, tag `20260930T115342Z`, the same batch as
E-026 and a separate experiment from it — **no verdict is computed across tasks** (author
decision 9). **`check-run-gate.sh` admitted 40 of 40 runs across both tasks;
`evaluation.exitCode = 0` on 10 of 10 in each arm of this task, so the scored population is the
whole population and neither arm is thinned.** Report generated by
`evidence/b11/report-b11-batch.py` → `evidence/b11/batch-20260930T115342Z/report/`; MDE and
permutation tests by `evidence/b11/mde-b11-batch.py` → `MDE.md`, `mde.json`.

**Median and range, never a mean alone. Treated = v1.2 overlay, control = v1.1.**

| outcome | control median | control range | treated median | treated range | delta | exact perm `p` |
|---|---|---|---|---|---|---|
| **context total (primary)** | 515 872 | 472 238 – 665 397 | 527 854 | 476 571 – 771 827 | **+11 982 = +2.32 %** | **0.851** |
| `inputTokens` | 210 | 186 – 250 | 202 | 194 – 258 | −3.81 % | 1.000 |
| `cachedTokens` | 483 626 | 439 182 – 631 260 | 493 493 | 446 488 – 734 400 | +2.04 % | 0.851 |
| `cacheCreationTokens` | 32 916.5 | 30 569 – 37 104 | 32 813.5 | 29 775 – 37 169 | −0.31 % | 0.954 |
| `outputTokens` | 17 759 | 16 203 – 18 920 | 18 057.5 | 15 223 – 21 179 | +1.68 % | 0.683 |
| `estimatedCost` | $0.204315 | 0.187615 – 0.223146 | $0.205938 | 0.185686 – 0.253931 | +0.79 % | 0.928 |
| `durationMs` | 172 500 | 156 000 – 200 000 | 178 000 | 126 000 – 209 000 | +3.19 % | 0.540 |
| `behavior.modelCalls` | 26 | 23 – 31 | 25 | 24 – 32 | −3.85 % | 1.000 |
| `behavior.toolCalls` | 25 | 22 – 30 | 24 | 21 – 31 | −4.00 % | 1.000 |
| `architecture-consistency` | 2 | 2 – 2 | 2 | 2 – 2 | 0 | 1.000 |
| `maintainability` | 0 | 0 – 1 | 0 | 0 – 1 | 0 | 1.000 |
| `test-quality` | 1 | 1 – 2 | 1 | 1 – 2 | 0 | 1.000 |
| `change-focus` **(report-only on this task)** | 0.5 | 0 – 2 | 0 | 0 – 2 | **−0.5** | **1.000** |

`p` is an **exact** two-sided permutation test on the difference of medians over all
`C(20,10) = 184 756` relabellings of this task's 20 runs.

### The MDE, re-derived

As in E-026, the method of re-derivation was not specified before the run, so all three
readings are reported:

| reading | value | does the +2.32 % clear it? |
|---|---|---|
| registered transferred MDE | ±8 % of the control median (±41 270) | **no** — well inside |
| re-derived: half-width of a 95 % bootstrap CI of the **control** median (20 000 resamples, seed 20260930) | ±48 460 = **±9.39 %** | **no** — inside |
| exact permutation test, no MDE at all | `p = 0.851` | **no** — not separated |

All three agree. Note the re-derived MDE on this task (±9.39 %) is close to the transferred
±8 %, where on BE-003 it was ±24.03 % — **BE-004's control arm is the tighter population**, as
its ranges show throughout the table above.

### The decision rule, walked in order — and the one row that needs an argument

| row | condition | fired? |
|---|---|---|
| 0a | a treated run's delivery proof fails | **no** — `overlay_files` 8/8 on 20 of 20 treated, `ABSENT-as-registered` on 20 of 20 control; row 0a fired 0 times |
| 0b | the computed cost ceiling reached before `n = 10` | **no** — **$4.1496** of the computed $4.5056, summed from the manifest's 20 rows with my own `awk`; `window.txt` prints $4.1495, a last-digit float-rounding difference and not a disagreement about the population |
| 0c | `H₂ ≤ 2` **and** `H₃ ≤ 2` **and** `H₅ ≤ 2` | **no** — 20 / 20 / 20 of 20 |
| 1 | any rubric category median **drops**, or treated acceptance below P4 | **no, under the registered carve-out — see below.** Acceptance 10 of 10 ≥ 8 |
| 2 | context total median drops by ≥ the MDE | **no** — it rose |
| 3 | context total median rises by ≥ the MDE | **no** — +2.32 % is inside ±8 % and inside ±9.39 % |
| **4** | \|delta\| inside the re-derived MDE | **FIRES** |

**Row 1 is the one place in this stop where two registered sentences point opposite ways, and
it is resolved here in the open rather than quietly.**

- Row 1's own text says *"any rubric category median drops"*. `change-focus` dropped from 0.5
  to 0. **Read literally, row 1 fires and this task's verdict is `REJECT`.**
- P5's text, registered in the same commit and specific to this task, says: *"`change-focus` is
  therefore reported and **enters no decision-rule row on this task**."*

**The carve-out is adopted, and the literal reading is recorded beside it so a reader can
overrule me without re-deriving anything.** Four reasons, in order of weight:

1. The carve-out is **task-specific and narrower**; row 1 is the general clause. Both were
   registered **before** the run, in commit `2552b75`, so neither is a post-hoc convenience.
2. Its stated reason is **measured, not procedural**: `change-focus`'s direction reversed
   across a machine sleep at B8 on this task (permutation `p = 0.2378`). It was carved out
   because it is known-unstable here, which is the correct reason to carve something out.
3. It follows an established precedent in this track — **author decision 10.3**, which makes a
   report-only category enter "no decision-rule row, no MDE and no exit-gate answer", and stop
   17a, which did the same.
4. **The drop does not survive its own test.** `p = 1.000` on an exact permutation over
   184 756 relabellings: the two arms' `change-focus` distributions are indistinguishable. The
   median moved because these are integers in `{0,1,2}` at `n = 10`, where `0.5` means exactly
   five runs at 0 and five at ≥ 1 — one run crossing moves the median half a point. Firing a
   `REJECT` on a statistic that a permutation test cannot separate at all would be the weakest
   verdict this track has produced.

**If the author rejects the carve-out, this task's verdict is `REJECT` and nothing else in
this file changes** — every number above is the same number.

### Verdict — `NOT DETECTABLE` at `n = 10`

The registered primary outcome moved **+2.32 %** against a registered MDE of ±8 %, at
`p = 0.851`. **The direction matches P1; the magnitude does not reach its 3 % floor.** No
secondary on this task separates either: the largest is `toolCalls` at −4.00 %, `p = 1.000`.

**The disposition — keep, modify or remove, per §4 step 10 — is NOT decided here.** Step 8 is
the report, row 4 states no disposition, and §6 forbids reaching a later step's decision early.

### This task carries no CLI version confound, and E-026's does

All 20 runs of this task — both arms — ran on claude **2.1.285**. `baseline-report.py` run at
step 8 prints **no** runtime-version warning for `EXP-B11-EFFICIENCY-BE004`, and prints
`WARNING: this arm mixes 2 runtime versions: 2.1.284 (Claude Code), 2.1.285 (Claude Code)` for
`EXP-B11-EFFICIENCY-BE003`. A registered instrument, not this prose, establishes the
asymmetry. **BE-004 is the cleaner task at this stop; these two headlines are not equals.**

### Where the arms are provably comparable

- `instructionsHash` takes **exactly one value per arm, no crossover**: control
  `sha256:a94237242e8c1308fb1d434a06a03463` on 10 of 10, treated
  `sha256:1cb0ea105099353da3e8048b1a923687` on 10 of 10, checked per run against the API.
- `agentHash` `sha256:b3450564b6f32d6193e8580db766210e` and `agentsHash`
  `sha256:cad6d876852f517b4dc64052b8dace1c` identical on all 40 runs; `hooksHash` `null` on all
  40 and **not used as a proof**.
- `runtime.model` `claude-haiku-4-5-20251001` on 40 of 40; rubric sha `6252778b8472` read back
  from all 20 of this task's sheets; API `variant` agrees with the manifest's `arm` on 40 of 40.

## Which predictions held

Predictions are never edited after their run (§4 step 12).

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | context total up 3–12 % | **REFUTED on magnitude; direction held** | **+2.32 %** (`p = 0.851`), below the registered 3 % floor and far inside the MDE |
| 2 | `H₁ ≤ 3 of n`, `H₄` unmeasured | **HELD** | `H₁` = **0 of 20** treated runs across the batch (`classify=ABSENT` on 40 of 40 rows); `H₄` unmeasured as registered **before** the batch |
| 3 | `H₂`, `H₃`, `H₅` each `≥ 8 of n` | **HELD** | **20 of 20** each; every control left 0/0/0 |
| 3a | the version's measured content is its hooks, not its instructions | **HELD** — P2 and P3 both held | The three mechanisms that execute arrived on every treated run; the one delivered as prose arrived on none |
| 4 | acceptance ≥ 8 of 10 | **HELD** | **10 of 10** treated, 10 of 10 control. The registered risk that `max_files_before_design: 15` would refuse a read this five-file task needs **did not materialise on any run** |
| 5 | no rubric category median moves | **REFUTED** | `change-focus` 0.5 → **0** (`p = 1.000`) — the knife-edge case; the other three are flat |
| 6 | `durationMs` rises, inadmissible as time-to-green | **HELD on direction** | **+3.19 %** (`p = 0.540`). Inadmissible as time-to-green either way, as registered |

## Failure analysis

Two instrument defects, both found by checking the instrument against itself, both recorded and
**neither patched mid-batch** (§4 step 4 forbids editing a tool while a run of it is in flight).
They are carried into the §5 validation table at §4 step 13 and into one additive instrument PR
at §4 step 14. They are described once, in E-026's Failure analysis, and apply to this batch
equally: **`manifest_header_defect`** (the driver prints stop 20's prediction commit into every
manifest header) and **`driver_summary_scope_defect`** (`window.txt`'s delivery header says
"over 9 treated run(s)" above manifest-wide counts of 20).

**A third is this file's own:** the MDE table says "re-derived from this batch's control"
without saying how. Three re-derivations are reported above because none was registered.

## Sanity checks

- **Prediction commit precedes the first run, from git and the API and not from prose.**
  Prediction commit **`2552b75`**, `%cI` = **2026-09-29T21:30:40+02:00 = 2026-09-29T19:30:40Z**
  — the commit that *added* this file, by `git log --diff-filter=A`. Earliest `startedAt` among
  the batch's 40 run records = **2026-09-30T11:53:45Z**. **16 h 23 min of margin.** The manifest
  header's `ef2c6c0 / 2026-09-26` is stop 20's commit and is ignored — see E-026's Failure
  analysis 1.
- `customization.*Hash` compared across arms per run; `hooksHash` `null` everywhere and not a
  proof. Rubric sha `6252778b8472` read back from all 20 of this task's sheets.
- Scored population = gate-admitted population; 40 of 40 admitted by `check-run-gate.sh` against
  run documents fetched from the API.

### The hand re-read, and it found the hand wrong

§5 requires one scored cell re-read by hand off the kept worktree, written down next to the
sheet's value. **The previous session's "scored once by hand" meant codex was *invoked* by
hand; that is not a human reading, so the hand re-read was still owed and was done at step 8.**

- **Run** `f1e82607-a314-4e84-951c-d0ff90c72783` (BE-004, **treated**, seq 10), scored off
  `evidence.local/b11-worktrees/<run_id>/` against `benchmark/rubrics/backend-quality-be004.yaml`
  re-hashed on disk at **`6252778b8472`**, the registered sha.
- **Cell chosen:** `change-focus` — deliberately the one cell this task's verdict argument turns
  on.
- **My hand reading, written before the sheet was opened: `1` (anchor 1, the residual).**
  Reasoning: in `src/main`, `getById` and `list` on both controllers and `OrderController.create`
  do not appear in the diff at all; everything present is inside the ticket's permitted set —
  the new `cancel` (`OrderController.kt:50-85`), the cancelled-order guard inside
  `ShipmentController.create` (`ShipmentController.kt:38-45`), `Order` gaining a status field and
  enum, one added repository query (`ShipmentRepository.kt:26-27 findByOrderId`), one added
  constant (`ApiError.kt:34 ORDER_CANCELLED`). **Beyond that list I found two class headers
  differing** — `OrderController.kt:21` adds `private val shipmentRepository: …` where baseline
  `OrderController.kt:17-19` had one parameter, and `ShipmentController.kt:26` adds
  `private val orderRepository: …` where baseline `ShipmentController.kt:22-24` had one. A
  constructor parameter list is not a method, so anchor 0's "two or more **methods**" did not
  apply and anchor 1's "every named method is character-identical but something outside them
  differs" did.
- **The sheet's value: `0` (anchor 0)**, reason *"Both test reset methods changed despite being
  unnamed by the ticket"*, evidence `baseline/OrderControllerTest.kt:34, OrderControllerTest.kt:37,
  baseline/ShipmentControllerTest.kt:34, ShipmentControllerTest.kt:39`.
- **§4 step 7 says go to the diff and say which fact was wrong. The diff says mine was.**
  `OrderControllerTest.reset()` changes from the expression body `fun reset() = repository.clear()`
  to a block adding `shipmentRepository.clear()`, and `ShipmentControllerTest.reset()` changes
  identically. Anchor 0's text names that exact transformation — *"an expression body turned into
  a block"* — and two such methods satisfy its "two or more". **Score 0 is correct and my 1 was
  not.** The sheet also cites **both trees**, which is what this rubric's anchors require and
  what the second-reader harness has historically failed to do.
- **The correction this produces, which applies to both experiments and to any later use of this
  rubric:** `change-focus` is scored over **every attached changed file, including the test
  files**, because Decision D attaches the files the agent changed in full with their pre-agent
  sides. My error was scoping the category to `src/main` by assumption.
- **The second-order observation, recorded and not acted on:** adding a cross-repository
  dependency on this task makes the two `reset()` helpers a near-forced edit, so `change-focus`
  on BE-004 is partly measuring a mechanical consequence of the ticket rather than a choice by
  the agent. That is an argument about the rubric, the rubric's sha is registered, and §6 forbids
  moving it mid-track. It goes to the author as a note, not into this result.

## Decision

*Owed to §4 step 10 (keep / modify / remove, per mechanism) and §4 step 11 (the exit gate and
the learning block). Not decided at step 8.*

## Follow-up

*Owed to §4 steps 10–14.* On record for it:

1. Row 1's literal reading versus P5's task-specific carve-out — resolved above in favour of the
   carve-out, with the alternative verdict (`REJECT`) stated so the author can overrule it.
2. A median over a three-valued score at `n = 10` is the statistic decision-rule row 1 is written
   on, and it moved half a point on a difference a permutation test puts at `p = 1.000`.
3. `change-focus` on this task partly measures a forced test-helper edit — a note for the author,
   not a change to a registered sha.

## Amendment 1 — the §4a review found the row-1/P5 collision independently, and it is a registration defect

*Added 2026-10-05 by Opus 5 (claude-opus-5), autonomously, at §4 step 13a. **Nothing above is
edited** — not the decision rule, not P5, not the verdict (§4 step 12).*

The §4a review round of 2026-10-05 (`findings/opencode/review-README-20261005T190718Z.md`) flagged
the same collision in **three** of its sections, and the gate raised it as non-blocking finding 2:

> decision-rule row 1 says *"any rubric category median drops"* → `REJECT`, while P5 — registered in
> the **same commit `2552b75`** — says `change-focus` *"enters no decision-rule row on this task"*.
> `change-focus` dropped 0.5 → 0. **Two pre-registered sentences point opposite ways on one datum.**

**That is correct, and it is not answered by preferring one of them.** The disposition already on
record stands: the carve-out was adopted, with four reasons, and the `REJECT` reading is written
beside it in this file so the author can overrule without re-deriving anything — including that the
drop is at exact permutation `p = 1.000`, so the arms are indistinguishable and the median moved
because 0.5 at `n = 10` on a `{0,1,2}` score means five runs each side and one run crossing.

**What the review adds is the defect, not the answer: a decision rule and a prediction that can both
fire on the same datum is a registration defect, and it should have been caught when they were
written, not after the batch.** It is the second defect of that kind at this stop — the first is the
MDE table saying *"re-derived from this batch's control"* without saying how. Both share one shape:
**a registration that leaves a choice to be made after the numbers are seen.**

**The forward rule, registered here for the next prediction commit:** when a prediction narrows or
excludes a metric that a decision-rule row also reads, the prediction must say **which row it
overrides and in what order they are evaluated**, in the same commit. A carve-out whose precedence is
implicit is a researcher degree of freedom wearing a pre-registration.

*Found by `ollama-cloud/glm-5.2` and the `minimax-m3` acceptance gate, 2026-10-05; recorded, not
rewritten.*
