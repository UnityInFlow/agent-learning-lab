# Experiment E-026 — B11 efficiency, v1.2, on BE-003-confirm-shipment

**Spine stop 26 · step B11 · version v1.1 → v1.2 · task BE-003-confirm-shipment · experiment key `EXP-B11-EFFICIENCY-BE003`**
Author decision 9: each task is its own experiment, and **no verdict is computed across tasks**.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-29T20:05Z; the author did not review before the run.`

## Question

Do the five efficiency mechanisms of `BACKEND-AGENT-EFFICIENCY-SELF-LEARNING-DESIGN.md` §6 —
task classifier, retrieval budget, file-summary cache, verification planner, command
deduplication — reduce what a run **consumes** on BE-003-confirm-shipment without reducing what it
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

**P4 — acceptance does not degrade: ≥ 9 of 10 evaluator exit 0 in the treated arm.**
*Mechanism:* 22 of 22 stored v1.1 runs passed; a one-run allowance is the same tolerance E-019 registered. The budget hook's refusals are recoverable — B8 recorded one refused
`Bash` that was not retried and cost nothing.
*The registered risk:* `max_files_before_design: 15` may refuse a read the task needs. If it
bites, acceptance falls and **decision-rule row 2 fires — REJECT — regardless of any saving.**

**P5 — no rubric category median moves on either arm.** *Mechanism:* every treatment since B7
has moved all four category medians by 0. The rubric scores the shape of the diff; nothing in
this overlay changes what to write, only what to read. BE-003 has **50 of 100 rubric points at zero variance** on this model (E-006 batch 2, validator passes 12–13), so the rubric is a weak detector here and is registered as a non-regression check rather than as the effect.

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
| task | BE-003-confirm-shipment | `benchmarkId` per run |
| rubric | `benchmark/rubrics/backend-quality.yaml`, sha `396e1799eb2b` | read back from every sheet |
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
| **primary: context total median** (`inputTokens + cachedTokens + cacheCreationTokens`) | v1.1 294 493 (B8, `n=10`) and 343 987 (B9 control, `n=12`) — the two stored v1.1 medians differ by themselves | **transferred: ±8 %**; re-derived from this batch's control | yes, as transferred |
| primary: evaluator exit 0 | 22 of 22 stored v1.1 runs | a 2-run difference at `n = 10` (Fisher 10/10 vs 8/10 → `p = 0.47`; 10/10 vs 5/10 → `p = 0.033`) | yes |
| secondary: `estimatedCost` median | v1.1 $0.1198 (B8) / $0.126 (B9) | reported, no verdict | yes |
| secondary: `behavior.toolCalls` median | v1.1 17.5 (B8) / 20 (B9) | reported, no verdict | yes |
| secondary: `inputTokens` median alone | v1.1 1 392 (B8) / 170 (B9) | reported **beside** the context total so the semantic gap stays visible | yes |
| secondary: `durationMs` | v1.1 111 000 (B8) / 106 500 (B9) | **no verdict** — whole-run, not time-to-green, and the BE-004 v1.1 population holds two sleep-contaminated runs (9 226 000 ms, 15 090 000 ms) | yes |
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
12 418 914 at the step-8 read**. No number below is telemetry-sourced; every one of them comes
from the API run record or from a codex sheet, so the growth check is a liveness proof here
rather than a provenance one.

## Results

`n = 10` per arm, 20 runs, one interleaved batch, tag `20260930T115342Z`.
**`check-run-gate.sh` admitted 40 of 40 runs across both tasks; `evaluation.exitCode = 0` on
10 of 10 in each arm of this task, so the scored population is the whole population and
neither arm is thinned.** Report generated by `evidence/b11/report-b11-batch.py` →
`evidence/b11/batch-20260930T115342Z/report/` (`per-run.tsv`, `REPORT.md`, `summary.json`);
MDE and permutation tests by `evidence/b11/mde-b11-batch.py` → `MDE.md`, `mde.json`. Both
scripts re-derive every figure from the manifest, the API and the 40 registered sheets.

**Median and range, never a mean alone. Treated = v1.2 overlay, control = v1.1.**

| outcome | control median | control range | treated median | treated range | delta | exact perm `p` |
|---|---|---|---|---|---|---|
| **context total (primary)** | 346 697 | 263 894 – 859 139 | 321 179 | 246 339 – 471 397 | **−25 518 = −7.36 %** | **0.417** |
| `inputTokens` | 170 | 130 – 282 | 158 | 122 – 194 | −12 = −7.06 % | 0.349 |
| `cachedTokens` | 323 853 | 242 611 – 817 222 | 300 612.5 | 226 754 – 443 644 | −7.18 % | 0.406 |
| `cacheCreationTokens` | 23 936.5 | 20 111 – 41 635 | 20 440.5 | 18 645 – 27 559 | −14.61 % | 0.014 |
| `outputTokens` | 10 278 | 8 702 – 12 305 | 8 663.5 | 7 344 – 11 121 | −15.71 % | 0.022 |
| `estimatedCost` | $0.131298 | 0.112497 – 0.226094 | $0.114920 | 0.097802 – 0.155281 | −12.47 % | 0.036 |
| `durationMs` | 117 500 | 99 000 – 161 000 | 104 000 | 85 000 – 130 000 | −11.49 % | 0.276 |
| `behavior.modelCalls` | 21 | 16 – 35 | 19.5 | 15 – 24 | −7.14 % | 0.349 |
| `behavior.toolCalls` | 20 | 15 – 32 | 18.5 | 14 – 23 | −7.50 % | 0.428 |
| `architecture-consistency` | 2 | 2 – 2 | 2 | 2 – 2 | 0 | 1.000 |
| `maintainability` | 0 | 0 – 2 | 0.5 | 0 – 2 | **+0.5** | 0.650 |
| `test-quality` | 1 | 1 – 1 | 1 | 1 – 2 | 0 | 1.000 |
| `change-focus` | 1 | 0 – 1 | 1 | 1 – 1 | 0 | 1.000 |

`p` is an **exact** two-sided permutation test on the difference of medians over all
`C(20,10) = 184 756` relabellings of the task's 20 runs. It assumes nothing and depends on no
choice made after the run.

### The MDE, re-derived — and the one place a reader should watch me

The MDE table registered **±8 % transferred**, "re-derived from this batch's control". **The
re-derivation *method* was never specified before the run**, so picking one after seeing the
delta is a researcher degree of freedom, and it is named here rather than exercised quietly.
Three readings are reported and all three are reported whatever they say:

| reading | value | does the −7.36 % clear it? |
|---|---|---|
| registered transferred MDE | ±8 % of the control median (±27 740) | **no** — inside |
| re-derived: half-width of a 95 % bootstrap CI of the **control** median (20 000 resamples, seed 20260930) | ±83 300 = **±24.03 %** | **no** — far inside |
| exact permutation test, no MDE at all | `p = 0.417` | **no** — not separated |

**All three agree**, so the verdict does not depend on the unspecified choice. That is luck,
not design, and the registration defect is recorded as a defect regardless.

### The decision rule, walked in order

| row | condition | fired? |
|---|---|---|
| 0a | a treated run's delivery proof fails | **no** — `overlay_files` 8/8 on 20 of 20 treated, `ABSENT-as-registered` on 20 of 20 control; row 0a fired 0 times |
| 0b | the computed cost ceiling reached before `n = 10` | **no** — $2.5830 of the computed $2.8380 |
| 0c | `H₂ ≤ 2` **and** `H₃ ≤ 2` **and** `H₅ ≤ 2` | **no** — 20 / 20 / 20 of 20 |
| 1 | any rubric category median **drops**, or treated acceptance below P4 | **no** — no category median drops on this task (`maintainability` *rises* 0 → 0.5; the other three are flat); acceptance 10 of 10 ≥ 9 |
| 2 | context total median drops by ≥ the MDE | **no** — −7.36 % is inside ±8 % and inside ±24.03 % |
| 3 | context total median rises by ≥ the MDE | **no** — it did not rise |
| **4** | \|delta\| inside the re-derived MDE | **FIRES** |

### Verdict — `NOT DETECTABLE` at `n = 10`

The registered primary outcome moved **−7.36 %** against a registered MDE of ±8 %, at
`p = 0.417`. **The sign is the opposite of the one P1 registered** and the magnitude does not
clear the threshold, so the honest reading is that this instrument cannot tell the v1.2
overlay from v1.1 on BE-003's context total at ten runs per arm.

**The disposition — keep, modify or remove, per §4 step 10 — is NOT decided here.** Step 8 is
the report. Row 4 states no disposition (only row 3 does), and §6 forbids reaching a later
step's decision early.

### Three secondaries moved while the registered primary did not, and that is the interesting part

`outputTokens` −15.71 % (`p = 0.022`), `cacheCreationTokens` −14.61 % (`p = 0.014`) and
`estimatedCost` −12.47 % (`p = 0.036`) are all outside the registered ±8 % with small
permutation `p`. **Every one of them is registered "reported, no verdict"**, and they are
reported as exactly that. Converting a secondary into the headline after seeing it is moving a
registered variable after the run, which §6 forbids and which this file will not do.

What they are evidence *for* is a property of the instrument, not of the agent: **the
registered primary is ~93 % `cachedTokens`** (323 853 of 346 697 on the control median), and
`cachedTokens` is the noisiest term in the sum — its control range spans 242 611 to 817 222, a
3.4× spread inside one arm. A composite outcome dominated by its own noisiest component is a
weak detector, and it swallowed three component-level movements that each separate on their
own. **That is a finding about how the primary outcome was defined, and it belongs to the next
version's registration, not to this one's result.**

### Where the arms are provably comparable, and the one place they are not

- `instructionsHash` takes **exactly one value per arm, with no crossover**: control
  `sha256:a94237242e8c1308fb1d434a06a03463` on 10 of 10, treated
  `sha256:1cb0ea105099353da3e8048b1a923687` on 10 of 10. Checked against the API record per
  run, not against the driver's summary.
- `agentHash` `sha256:b3450564b6f32d6193e8580db766210e` and `agentsHash`
  `sha256:cad6d876852f517b4dc64052b8dace1c` are identical on all 40 runs of the batch.
  `hooksHash` is `null` on all 40 — the known schema gap, and **it is not used as a proof**.
- `runtime.model` is `claude-haiku-4-5-20251001` on 40 of 40; rubric sha `396e1799eb2b` read
  back from all 20 of this task's sheets; `variant` on the API record agrees with the
  manifest's `arm` on 40 of 40 (0 consistency problems from `report-b11-batch.py`).
- **The exception, stated rather than buried: the claude CLI moved mid-batch.** See below.

### Named limitation — the CLI version partition, and why BE-004 is the cleaner task

The claude CLI updated itself between the first and second halves of this population.
Recorded on **2.1.284**: treated seq 01–06 = 6 runs, control seq 01–05 = 5 runs. Recorded on
**2.1.285**: treated 07–10 = 4, control 06–10 = 5. **So this task's treated arm is 6/4 across
the boundary and its control arm is 5/5 — a one-run imbalance in an unregistered variable.**

It is not a technicality. The registered primary is a token sum, and a CLI point release can
move system-prompt size or prompt-caching behaviour, which lands directly on it. The decision
to **resume rather than restart** was registered in `TRACK-B-STATE.md`
(`claude_cli_version_boundary`) **before the resume ran**, not after the result; its reasons
were the registered `--resume, NEVER a fresh batch` instruction, §6's ban on orphaning
evidence, and author decision 13's computed ceiling, which a fresh batch would have breached
at driver exit 11. The manifest is self-describing: `# claude 2.1.285 at resume` sits at line
23 and partitions the population, so a stranger can split it without asking anyone.

**`baseline-report.py` independently flags it** — run at step 8 it prints
`WARNING: this arm mixes 2 runtime versions: 2.1.284 (Claude Code), 2.1.285 (Claude Code)`
for `EXP-B11-EFFICIENCY-BE003` and prints **no such warning** for `EXP-B11-EFFICIENCY-BE004`.
A registered instrument, not this prose, is what establishes the asymmetry.

**E-027's BE-004 population ran entirely on 2.1.285 in both arms and carries no version
confound at all. BE-004 is the cleaner task at this stop, and these two headlines are not
equals.**

## Which predictions held

Predictions are never edited after their run (§4 step 12). Both refutations stand as written.

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | context total up 3–12 % | **REFUTED — on sign and on magnitude** | **−7.36 %** (`p = 0.417`). The registered risk fired: P1 itself named the flip path — "if the retrieval budget bites hard enough … the sign flips. That path is exactly what `H₂` is registered to detect" — and `H₂` fired on 20 of 20. It was registered as "the prediction most likely to be wrong"; it was |
| 2 | `H₁ ≤ 3 of n`, `H₄` unmeasured | **HELD** | `H₁` = **0 of 20** treated runs (`classify=ABSENT` on 40 of 40 manifest rows); `H₄` unmeasured as registered **before** the batch |
| 3 | `H₂`, `H₃`, `H₅` each `≥ 8 of n` | **HELD** | **20 of 20** each; every control left 0/0/0 |
| 3a | the version's measured content is its hooks, not its instructions | **HELD** — P2 and P3 both held | The only mechanisms that reached the run are the three that execute. The one delivered as prose reached 0 of 20, beside B9's `H = 2 of 10` on the same delivery route |
| 4 | acceptance ≥ 9 of 10 | **HELD** | **10 of 10** treated, 10 of 10 control |
| 5 | no rubric category median moves | **REFUTED** | `maintainability` 0 → **0.5** (`p = 0.650`). See the knife-edge note below |
| 6 | `durationMs` rises, inadmissible as time-to-green | **REFUTED on direction** | `durationMs` **fell** 11.49 % (`p = 0.276`). Inadmissible as time-to-green either way, as registered |

**The knife-edge note, which applies to P5 on both tasks.** These scores are integers in
`{0,1,2}` and `n = 10`, so a median of `0.5` means exactly five runs at 0 and five at ≥ 1. One
run crossing moves the median by half a point while the permutation test sees nothing
(`p = 0.650` here, `p = 1.000` for BE-004's `change-focus`). **A median is a poor summary of a
three-valued score at `n = 10`, and decision-rule row 1 is written on exactly that statistic.**
P5 is recorded refuted because that is what it says and what happened; the reader is owed the
observation that neither movement is distinguishable from relabelling.

## Failure analysis

**Two instrument defects were found by checking the instrument against itself, and neither was
patched mid-batch.** Both are carried into the §5 validation table at §4 step 13 and into one
additive instrument PR at §4 step 14.

1. **`manifest_header_defect`.** `evidence/b11/run-b11-batch.sh:349` prints a **hardcoded**
   `# prediction commit ef2c6c0 at 2026-09-26, BEFORE any run here` into every manifest header.
   `ef2c6c0` is real but it is **stop 20's** prediction commit (`stop 20 §4 step 3: PREDICTION
   COMMIT — E-022 and E-023`), carried over when this driver was derived from stop 20's. It is
   L3 prose and moves no behaviour, but it is a provenance line a reader would trust. **The
   ordering check in Sanity checks below is therefore computed from `git %cI` and the API's
   `startedAt`, never from this header.** Not fixed during the batch: §4 step 4 forbids editing
   a tool while a run of it is in flight, and 11 rows of this population had already been
   produced by that exact file.
2. **`driver_summary_scope_defect`.** `evidence/b11/batch-20260930T115342Z/window.txt` prints
   `DELIVERY, PER MECHANISM, NEVER POOLED, over 9 treated run(s):` and then lists H₂/H₃/H₅ = 20
   and H₁ = 0. **The mechanism counts are manifest-wide and correct; the `9` is the third
   launch's treated count only.** A reader who trusts the header divides by the wrong `n`. This
   is the house failure mode — a control reporting over a scope smaller than it claims — wearing
   a new costume, and it was caught by re-deriving the counts with an independent `awk` over the
   manifest rather than by reading the driver's own summary.

**A third defect sits in this experiment's own registration, and it is mine, not the driver's:**
the MDE table says "re-derived from this batch's control" without saying *how*. Three
re-derivations are reported above because no single one was registered. They agree here; next
time the method goes in the prediction commit.

## Sanity checks

- **Prediction commit precedes the first run, from git and the API and not from prose.**
  Prediction commit **`2552b75`**, `git show -s --format=%cI` = **`2026-09-29T21:30:40+02:00`
  = 2026-09-29T19:30:40Z** (`Stop 26 (B11): open the stop, answer its conditional gate,
  register both predictions`; it is the commit that *added* this file, by
  `git log --diff-filter=A`). Earliest `startedAt` among the batch's 40 run records =
  **`2026-09-30T11:53:45Z`**, run `5cc74707-f2e8-44a4-9ccf-df241effaac3` (BE-003 01 treated).
  **16 h 23 min of margin.** The manifest header's `ef2c6c0 / 2026-09-26` is stop 20's and is
  ignored here — see Failure analysis 1.
- `customization.*Hash` compared across arms per run against the API record; `hooksHash` is
  `null` on every run ever recorded and is **not** used as a proof.
- Rubric sha `396e1799eb2b` read back from all 20 of this task's sheets, by name.
- **One scored cell re-read by hand, and the hand reading was the one that was wrong.** Recorded
  in full in E-027 (the cell is on BE-004); the correction it produced applies to both files:
  **`change-focus` is scored over every attached changed file, including the test files**, which
  Decision D attaches with their pre-agent sides.
- Scored population = gate-admitted population: 40 of 40 admitted by `check-run-gate.sh`
  against the run documents fetched from the API, an independent confirmation of the manifest's
  `eval=0` rather than a re-reading of it.

## Decision

*Owed to §4 step 10 (keep / modify / remove, per mechanism) and §4 step 11 (the exit gate and
the learning block). Not decided at step 8.*

## Follow-up

*Owed to §4 steps 10–14.* Three items are already on record for it:

1. The registered primary outcome is ~93 % `cachedTokens` and is a weak detector; three
   component-level secondaries separated while it did not.
2. `H₁` reached 0 of 20 — the third independent measurement on this track that a mechanism
   delivered as prose does not arrive.
3. Both instrument defects above go into one additive instrument PR at §4 step 14.
