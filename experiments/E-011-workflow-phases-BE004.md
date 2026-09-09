# Experiment E-011 — workflow phases v1.0 on BE-004

**Spine stop 12 (B5) · task `BE-004-cancel-order` · experiment key `EXP-B5-PHASES-BE004`**
**Status:** REGISTERED, no runs yet.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-09T07:5xZ; the author did not review
before the run.`

**Author decision 9 governs, and this file is the half of it that has no history.** Its sibling,
[E-010](E-010-workflow-phases-BE003.md), covers `BE-003-confirm-shipment` under key
`EXP-B5-PHASES-BE003`. Separate prediction commits, separate concurrent controls, separate decision
rules, separate §5 rows. **No verdict is computed across the two files**, and the one-variable rule
applies within this file only.

---

## Question

The same question E-010 asks — does a six-phase procedure declared to a single agent change what a
run *does* or only what it *says*, and what does it cost — asked on **the task that was built
because BE-003 could not answer it.**

`agent-observatory-benchmarks/tasks/BE-004-cancel-order/benchmark.yaml` says so in its own header:
BE-003 is *"a three-file change inside one package that a capable model passes 10 of 10 on, with
two of the rubric's four categories at zero variance across both arms of a 20-run batch and the
changed-file count at its floor … B5 … claims to prevent premature coding and false completion, and
on BE-003 there is nothing to prevent."*

## What is different here, stated before anything is predicted

Read from the benchmark and from the nine BE-004 run records that already exist on the observatory
API (all nine are preflight probes under `EXP-P12-PREFLIGHT-INITTOOLS*`; none is an arm of this or
any experiment).

| | BE-003 | BE-004 | Source |
|---|---|---|---|
| Files touched by a passing run | 3, at the scope floor | **6–7**, across `order/`, `shipment/` and `api/` | `result.changedFiles` on the nine records |
| `addedLines` | median 69 (E-006 control) | **174–283**, median ≈ 201 (`n = 9`) | `result.addedLines` |
| `modelCalls` | median 22 | **23–32**, median 30 (`n = 6`; three records carry `null`, see threat 2) | `behavior.modelCalls` |
| `estimatedCost` | median $0.156 | **$0.197–$0.227**, median ≈ $0.203 (`n = 6`) | `efficiency.estimatedCost` |
| Traps | one contract envelope | **atomicity** (check-then-act, all-or-nothing cascade) · **guard** (a rule stated as a consequence, in a controller the ticket's title does not name) · the envelope | `benchmark.yaml` header |
| Evaluator exit-code contract | `10/11/12/13/20/21`, `0` on pass | **identical**, re-read line by line at `evaluator.sh:385-390` against BE-003's `:378-383` | both evaluators, read not assumed |
| Pass rate on `claude-haiku-4-5-20251001` | 10 of 10 in every batch ever run | **9 of 9**, all `exit 0`, all `7/7` acceptance | the nine records |

**That last row is the one that matters and it contradicts the reason this task exists.** Author
decision 9 says *"BE-004 is built so a capable model can fail it"* and *"pass rate is a result, not
a nuisance."* On the evidence available before this batch, **the model does not fail it**: nine of
nine, seven of seven acceptance criteria, zero evaluator refusals. `n = 9` is stated as *true of
these nine runs*, not as a property. It is registered here **before the batch** so that a 20-run
confirmation cannot be read afterwards as a discovery, and so that the opposite — a treated or
control arm that drops — is visibly a change from a measured prior rather than from an assumption.

## Hypothesis

Identical in mechanism to [E-010](E-010-workflow-phases-BE003.md) and therefore stated once here
by reference: the six phases are **L3**, nothing executes them, and the hypothesis is not that they
prevent anything. It is that the agent adopts the procedure as narration **and** follows it in
position, at a price paid in turns.

**What BE-004 adds to the hypothesis, and it is the whole reason for this file:** the phase
procedure's claimed value is *preventing premature coding*. On a three-file single-package change
there is nothing to be premature about. On a **cross-module change with an all-or-nothing cascade
and a guard the ticket never names as an endpoint**, coding before reading has somewhere to go
wrong. So this is the first arm in the project where P3 (code order) could plausibly correlate with
a correctness outcome rather than being a pure narration measure. **It is not predicted to** — see
P7 — but it is the first time the question is answerable.

## Predictions

Every prediction has a direction, a magnitude and a mechanism. `n = 10` per arm.

**P1 — delivery (a void condition, not an outcome).** All 10 treated runs carry
`customization.agentHash = sha256:b3450564b6f32d6193e8580db766210e` and all 10 controls carry
`null`; each treated run's `init` record names `backend-feature-phases` and its `init.tools`
read-back contains `Edit` **and** `Write`. *Mechanism:* `--customization` + `--agent`, with
`agentHash` populated since `obs#76` (`27b3a7d`). *Prior, and it is not an assumption:* three
BE-004 runs already carry exactly this hash (`b8e31a61`, `db318da7`, `c6d44da9`, key
`EXP-P12-PREFLIGHT-INITTOOLS-BATCHENV`), so the delivery path is known to work **on this task**.
*Magnitude:* 10 of 10 / 0 of 10. **Below 9 of 10 → VOID (decision-rule row 0).**

**P2 — markers.** The six markers appear once each, in the registered order, in **≥ 9 of 10**
treated runs, by `check-phase-contract.py` check 1. Control **0 of 10** mechanically — registered
as a floor, **not** as a separation and never reported as a finding. *Mechanism:* an agent
definition is the system prompt; it is present every turn rather than selected once.

**P3 — code order, the clause that decides this stop.** The first mutating `tool_use`
(`Edit`/`Write`/`MultiEdit`/`NotebookEdit`/`str_replace_editor`) falls **after** the `DESIGN`
marker in **≥ 9 of 10** treated runs, by check 2. *Mechanism:* the marker is emitted in-band, so a
run that writes first must either emit `DESIGN` after its write or emit all six markers
retroactively in its summary; check 2 fails on both. *Why the same threshold as BE-003 despite a
larger task:* six or seven files require more reading before the first write in **both** arms, which
pushes the treated arm's first write later for a reason that has nothing to do with the treatment.
**That confound is registered, not corrected** — it is why P3 is an absolute rate in the treated arm
and is never compared to the control, which has no `DESIGN` marker for check 2 to measure against.

**P4 — the registered blind spot, and it is weaker here than on BE-003.** The count of `Bash` calls
carrying a write shape **before** the `DESIGN` marker is **0 in ≥ 9 of 10** treated runs — one run
stricter than E-010's threshold. *Mechanism:* `MUTATING` excludes `Bash` by design
(`tools/check-phase-contract.py:63-68`); the checker counts pre-`DESIGN` `Bash` write shapes and
prints them as a NOTE (`:155, :187-195, :267-269`). A six-file Kotlin change through heredocs is a
worse route than `Edit` by a wider margin than a three-file one, so if the blind spot is going to be
exercised anywhere it is on BE-003, not here. **Registered as an outcome, not commentary.**

**P5 — turns.** `modelCalls` median in the treated arm exceeds its concurrent control by **≥ +4**
with **non-overlapping quartiles**. *Mechanism:* six announcements plus six output contracts are
assistant turns the control never takes. **The threshold is transferred from BE-003, not calibrated
on BE-004, and that is a registered weakness** (see "Minimum detectable effect"): +4 on BE-004's
observed median of 30 is a **13 %** shift where the same +4 on BE-003's 22 is **18 %**. The absolute
form is kept rather than the relative one so that the two files' thresholds remain the same object.

**P6 — money.** `estimatedCost` median in the treated arm is **≥ +25 %** over its concurrent
control, with non-overlapping quartiles. *Mechanism, stated because it contradicts the nearest
prior:* [E-007](E-007-orchestration-overhead.md)'s structural split was **13.4 % cheaper** than its
control because the implementer ran in a fresh, small context. **There is no subagent here.** One
agent carries one growing context through six phases and every extra turn re-reads everything
before it. **BE-004 makes this mechanism more testable, not less**: the context being re-read is six
files instead of three, so if compounding is the mechanism the effect should be *larger* here than
on BE-003. If E-010 clears P6 and E-011 does not, the compounding mechanism is wrong and that is
worth more than either prediction.

**P7 — quality, and here the two files genuinely part company.** On the BE-004 rubric registered at
§4 step 4, the **`test-quality` anchor 2 count in the treated arm is ≤ 3 of 10**, and specifically
not ≥ 5 of 10. *Mechanism:* [E-009](E-009-fourth-cell-second-registration.md) measured a procedure
delivered as prose to a single agent at **0 of 10 against its control's 1 of 10, `p = 1.0`**;
markers change what is narrated, not what is in the context window when the tests are written.
*What is new:* BE-004's anchor 2 has **four** citable clauses (a repeat cancel whose *body* is
asserted; state re-read through separate `get(...)` after a refused cancel; an error-envelope body
assertion; persisted state re-read rather than trusted) where BE-003's has fewer. **A four-clause
anchor is plausibly unreachable by this model on either arm**, which would put this dimension at the
same floor that made BE-003 uninformative — the exact failure decision 9 exists to escape.
**Registered consequence:** the full 0/1/2 distribution of **all four categories** is reported for
both arms, not the anchor-2 count alone, and **a floor at 0 of 10 in both arms is recorded as a
result about the rubric, not about the treatment** (decision-rule row 6).

**P8 — correctness, and this is the prediction I expect to be most informative if wrong.** Evaluator
pass rate is **≥ 8 of 10 in both arms**, and the two arms differ by **< 3**. *Mechanism:* nine of
nine existing BE-004 runs on this model passed at `7/7`, so the traps this task was built around —
atomicity and the unnamed guard — are not, on the evidence, trapping this model. **If the treated
arm passes and the control does not by ≥ 3, that is the first correctness effect any customization
has produced in this project**, it fires decision-rule row 5, and it is the single most consequential
outcome available at this stop. I am predicting it will **not** happen.

## Independent variable

**One thing changes:** the treated arm runs with
`--customization build/customizations/phases-v1.0 --agent backend-feature-phases`. The control runs
with neither. Everything in `Controlled variables` is pinned identically and read back from the run
records rather than trusted from a flag.

## How the treatment is delivered — and proved

| | Treated arm | Control arm |
|---|---|---|
| Mechanism | `--customization build/customizations/phases-v1.0` + `--agent backend-feature-phases` | no `--customization`, no `--agent` |
| Content hash | file `shasum -a 256` = `b3450564b6f32d6193e8580db766210e35c1bfaa90589a705b3e9236fdb18a41` (64 hex). The **run record stores a 32-char prefix** — `sha256:b3450564b6f32d6193e8580db766210e` — because `agent-observatory/runner/run-agent.sh:575` is `printf '"sha256:%s"' "$(shasum -a 256 "$path" \| cut -c1-32)"`. Both forms are registered so a stranger re-deriving with `shasum` does not find a mismatch. | — |
| Preflight assertion (§4 step 5, one run per arm, own key, enters no comparison) | `customization.agentHash` equals the prefix above; `init` names `backend-feature-phases`; `init.tools` read-back contains `Edit` and `Write`; **`behavior.modelCalls` and `efficiency.estimatedCost` are non-null** (threat 2) | `agentHash` **and** `instructionsHash` both `null`; same non-null telemetry assertion |
| Per-run proof | `customization.agentHash` on every run record | `null` on every run record |

**The same overlay, unedited, as E-010.** BE-004's arms inherit the identical treatment file —
author decision 10.1 required the fourth cell answered before this stop registered anything
precisely so that the overlay's prose is not a confound carried into a new task. That cell is
[E-009](E-009-fourth-cell-second-registration.md), closed, merged as lab#74 → `e342d1e`. **Its
disclosure carries here too:** `backend-feature-phases.md` was authored and merged on 2026-09-08 in
lab#77, an instrument PR, while stop 12 was unopened — a §6 violation adopted with its date and sha
rather than deleted (§7 forbids destroying evidence). Any change from here is a new version
directory, never an edit. **The overlay has never been tuned on a scored BE-004 run:** the three
BE-004 records carrying its hash are `init.tools` read-back probes under a preflight key, and no
BE-004 rubric exists yet to have scored them.

## Controlled variables

| Variable | Value | Read back from |
|---|---|---|
| Agent under test | `claude-haiku-4-5-20251001` | `runtime.model` on every run record |
| Benchmark task | `BE-004-cancel-order`, selected by `BENCHMARK=BE-004` | `benchmarkId` |
| Benchmark commit | `agent-observatory-benchmarks` at `eea144ef940fda4cb6090561fdd901aed0013c8e` (the merge of benchmarks#29) unless §4 step 6 records a later sha | run record + `git rev-parse` at launch |
| Evaluator | BE-004's own, `evaluator_version: 1.0.0`, exit-code contract read against BE-003's and found identical | `evaluation.exitCode`, `evaluation.evaluatorVersion` |
| Rubric | **`benchmark/rubrics/backend-quality-be004.yaml`, sha `6252778b8472`** — ported at `c42120b`, **proved at §4 step 4 before any run was scored** (author decision 9 + 10.2): six codex sheets, all four dimensions separating, table in the §4 step 4 section. The sha was written into this row **after** the proof passed, never before. | `rubric_sha` on every sheet, read back from the header, not eyeballed |
| Registered scorer | `codex` (Decision C), and **for the rubric proof codex and nothing else** (author decision 10.2) | sheet provenance header |
| Second reader | `opencode-score.sh` with `ollama-cloud/deepseek-v4-pro`, report-only on `change-focus` if Decision H ever fires (decision 10.3) | sheet provenance header |
| Isolation | `ISOLATE_USER_SETTINGS=1` on both arms | `customization.*Hash` null on control, 0 hook executions |
| Worktrees | `KEEP=1` (`--keep`), never `--bare` | worktree path per run |
| Telemetry | `OTLP_GRPC_PORT=14317 OTLP_HTTP_PORT=14318 API_PORT=18081` — the SSH tunnels; every colima host forward on this machine is dead and reads as healthy | `events.jsonl` **must grow**, and `behavior.modelCalls` must be non-null, before any turn or cost number is trusted |

## Runs

`n = 10` per arm, **interleaved** treated/control pair by pair, both arms from the same script in
the same session, no run across a machine sleep. **Budget: 20 runs × ≈ $0.20 ≈ $4** — priced from
BE-004's own six costed records, not from BE-003's $0.15. Decision 9 estimates 2–4 minutes per run;
the nine existing records say **175–206 s for six of them and 1100–1240 s for three**, so the wall
clock is registered as **≈ 1.5–4 h for the batch**, not the 45 min a BE-003 batch takes, and the
three-fold duration outliers are exactly why duration carries the widest threshold below.

## Minimum detectable effect

**BE-004 has no stored reference population and author decision 9 says so:** *"BE-004's reference
population is its own concurrent control at stop 12, `n = 10` — there is no stored B2 run on it.
That control's medians and ranges become the MDE inputs for B6 and B7 on BE-004."*

**So the honest statement of this section is that its continuous thresholds are transferred, not
calibrated, and that is a registered weakness of this experiment.**

| Metric | Best available prior on BE-004 | Registered threshold at `n = 10`/arm | Calibrated? |
|---|---|---|---|
| `modelCalls` median | 30 (range 23–32, `n = 6`, mixed probe keys) | **+4 on the median AND non-overlapping quartiles** | **No — transferred from BE-003** |
| `estimatedCost` median | $0.203 (range $0.197–$0.227, `n = 6`) | **+25 % on the median AND non-overlapping quartiles** | **No — transferred from BE-003** |
| `durationMs` median | bimodal: 175–206 s (`n = 6`) and 1100–1240 s (`n = 3`) | **report-only, no threshold** — a prior whose range spans 7× cannot support one | n/a |
| `addedLines` median | 201 (range 174–283, `n = 9`) | report-only, no threshold | n/a |
| `test-quality` anchor 2 | **none — the rubric does not exist yet** | **≥ 7 of 10 treated** against the concurrent control, two-sided Fisher | count outcome, needs no prior |
| evaluator pass | 9 of 9 (`n = 9`, all `7/7`) | a **between-arm difference of ≥ 3** is detectable; smaller is not | count outcome |

**Count outcomes** use two-sided Fisher exact at `n = 10`/arm and need no reference population —
which is why P2, P3, P4, P7 and P8 carry this experiment and P5/P6 are explicitly the weaker half.
**Continuous outcomes** use a registered delta on the median plus non-overlapping quartiles; the
quartile clause is what protects a transferred threshold from a spread it was not calibrated on,
because a treated q1 above the control's q3 is a separation whatever the underlying variance is.

**What this batch owes the future, and it is an obligation not a nicety:** at §4 step 8 the control
arm's `modelCalls`, `estimatedCost`, `durationMs`, `addedLines` and per-category score medians **and
quartiles** are published in the Results section as **BE-004's reference population, `n = 10`**, and
cited by key from B6 (stop 13) and B7 (stop 15). That happens whether or not any threshold above
fires.

## Deterministic evaluation

BE-004's own evaluator at `evaluator_version: 1.0.0`, exit-code contract untouched, proved by
`verify-evaluator.sh` at 12 of 12 **re-run on `main` after the benchmarks#29 merge** rather than
taken from CI. `./tools/check-run-gate.sh` on every run before any sheet is opened; only
gate-admitted runs enter any comparison.

## Exclusions, registered before the data

1. A run `check-run-gate.sh` refuses is excluded from every comparison and the refusal is recorded.
2. A run spanning a machine sleep has **`durationMs` excluded, the run kept** (§4 step 6). Given the
   7× duration spread already on record for this task, a duration outlier is **not** on its own
   evidence of a sleep and is not excluded on that reasoning alone.
3. A run whose telemetry did not export is excluded — the runner now refuses to start such a run
   (`agent-observatory` `4cdd803`), so this should be unreachable; if it is reached, that is the
   finding. **Three of the nine existing BE-004 records carry `null` `modelCalls` and `null`
   `estimatedCost`** (`aa548920`, `bb0d731d`, `a997bd30`, key `EXP-P12-PREFLIGHT-INITTOOLS-ISO`),
   which is the shape this exclusion exists for.
4. **No run is excluded for failing a phase-contract check.** A treated run that skips `DESIGN` is
   the measurement, not a defect.
5. **No run is excluded for failing the evaluator.** Pass rate is an outcome here (P8), not a filter.

## Decision rule, fixed before the run

Applied **in order**, stopping at the first row that fires.

| # | Condition | Verdict |
|---|---|---|
| 0 | P1 fails — fewer than 9 of 10 treated runs carry the agent hash, or any control carries a non-null one, or a sheet's rubric sha is not the one registered at step 4 | **VOID** — the treatment was not delivered; nothing is claimed |
| 1 | P2 ≤ 5 of 10 | **REFUTE** — the agent does not adopt the procedure even as narration |
| 2 | P2 ≥ 9 of 10 **and** P3 ≤ 5 of 10 | **REFUTE, and it is the trap's own result** — markers appear, code order does not follow them; the workflow is narration |
| 3 | P2 ≥ 9 of 10 **and** P3 ≥ 9 of 10 **and** (P5 clears **or** P6 clears) | **CONFIRM** — phases observable, followed in position, overhead measured not assumed |
| 4 | P2 ≥ 9 of 10 **and** P3 ≥ 9 of 10 **and** neither P5 nor P6 clears **and** nothing improved | **NOT DETECTABLE** — followed, and costing nothing this `n` resolves |
| 5 | evaluator pass differs between arms by **≥ 3** in either direction | **CORRECTNESS EFFECT**, recorded *beside* whichever row above fires and never instead of it. In the treated arm's favour this is the first correctness effect in the project and P8 is refuted; against it, the phases cost correctness and that is the stop's headline. |
| 6 | `test-quality` anchor 2 is **0 of 10 in both arms** | recorded beside the firing row as **"the rubric's anchor 2 is unreached on this task by this model"** — a result about the instrument. It does **not** make the stop inconclusive, and it is reported to B6 (stop 13) as a measured constraint on what a specialist skill could be built from. |
| 7 | anything else | **INCONCLUSIVE**, reported as the combination that produced it, never rounded to a neighbour |

**Row 4b, on a separate axis, recorded beside whichever row fires:** if `test-quality` anchor 2 in
the treated arm is **≥ 7 of 10**, record *"declared phases returned what the structural split
returned, without a split"*, and open a dated amendment on
[E-007](E-007-orchestration-overhead.md). E-007's registered verdict is **not edited** under any
reading.

## Threats to validity, registered before the run

1. **Every continuous threshold here is transferred from another task.** Stated in the MDE section
   rather than buried. P5 and P6 are the weak half of this experiment and are labelled as such
   before the data.
2. **Three of nine existing BE-004 records have null turn and cost telemetry.** If the batch
   reproduces that, P5 and P6 are unmeasurable and are recorded as **unmeasured**, never as
   not-detected. §4 step 5's preflight pair asserts non-null `modelCalls` **before** the batch
   starts, so this is caught at one run's cost rather than twenty's.
3. **Duration spread is 7× on the existing records** (175–206 s vs 1100–1240 s). Duration is
   report-only for that reason, and interleaving is the only mitigation applied.
4. **A larger task pushes the first write later in both arms**, independent of the treatment. P3 is
   therefore an absolute rate in the treated arm and is never compared to the control.
5. **BE-004's anchor 2 may floor at 0.** Registered as decision-rule row 6, with the full 0/1/2
   distribution of all four categories reported so a floor is visible rather than inferred.
6. **The rubric is proved on five fixtures, not on runs.** A dimension that separates the fixtures
   can still be flat on real submissions; that is what row 6 records.
7. **`n = 10` per arm is coarse.** Nothing from `n < 5` is stated as a property anywhere in this
   file, and a `test-quality` count of 6 of 10 does not clear the registered threshold even though
   it looks like an effect. That threshold was set before the data and does not move.
8. **The task's own premise is unconfirmed.** BE-004 was built so a capable model could fail it and
   has been passed 9 of 9. If both arms pass 10 of 10, this task has not yet delivered the
   discrimination decision 9 bought it for, and that is reported at stop 12 rather than deferred to
   B7 — see P8.

7. **The treated arm is delivered four tool names and the control twenty-nine, and the difference
   was found by this stop's own §4 step 5 preflight rather than registered before it.** *Added
   2026-09-09, before the first batch run, by Opus 5 (claude-opus-5), autonomously.* The treatment
   is the six-phase procedure **bundled with** the agent definition's `tools:` line, because that is
   what a Claude Code agent is. E-005 makes most of the gap inert — `tools:` filters names, not
   capabilities, and this list carries `Bash` — and the benchmark is offline, so the `Web*`,
   `Notebook*`, `Monitor`, `Workflow` and `Cron*` names have no path to it. **`Task` is the
   exception**: the control can delegate and the treated arm cannot. Mitigation, executable:
   `check-phase-contract.py` detects delegation (fixture **J**), so **every control run is counted
   for `Task` use and the count is reported beside the batch numbers whether it is zero or not.**
   See the §4 step 5 section for the full statement.

## Deliberate failure — run once, on BE-003, and here is why

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-09.` §4 step 9's deliberate failure for
stop 12 is registered in [E-010](E-010-workflow-phases-BE003.md) and is **run on BE-003 only**: a
fifth pair with `build/customizations/phases-v1.0-nomarkers-DELIBERATE-FAILURE`, the same six-phase
prose with the marker instruction removed and nothing else changed.

**Reason:** the manipulated variable is the marker instruction, and the mechanism it tests — whether
the markers survive the removal of the sentence that asks for them — is a property of the overlay
and the model, not of the task. Running it twice spends a second pair to re-measure the same
mechanism. **The condition on this decision, registered before the data:** if the BE-003 deliberate
failure produces a surprise — markers surviving their instruction's removal, or
`naive-phase-checker.py` and `check-phase-contract.py` agreeing where they are built to disagree —
it is **re-run on BE-004** before this stop closes, because in that case the result is no longer
about a task-independent mechanism.

## §4 step 4 — the rubric proof

**Written before the first scoring call of the proof, and nothing below the "Result" heading
existed when the predictions above it were committed.** Author decision 9 requires the port to
be proved as E-001 Decision B proved v2; author decision 10.2 requires codex and only codex.

### What is being proved, and what would refute it

The rubric is an instrument. The claim is *this file discriminates on BE-004's constructs*, and
the fixture set is built so that each variant differs from `known-good` in **one** dimension and
in one method — the fixture notes say so and say why they are kept outside `fixtures/`. So the
proof is a per-dimension separation, each with one candidate cause.

**A dimension that does not separate is a §7 halt** (prompt §3, author decision 9), not an edit.
If `good-inline-envelope` scores 2 on `architecture-consistency`, the anchor does not see a
hand-assembled `ApiError` on a refusal path and the file is not an instrument for that construct;
the same for each row below. I am recording that in advance so that a null result cannot be
re-read afterwards as a tolerable one.

### The predicted directions, per dimension

| Dimension | Reference cell | Variant cell | Predicted values | Separation required | Mechanism — the construct the anchor must see |
|---|---|---|---|---|---|
| `architecture-consistency` (35) | `known-good` | `good-inline-envelope` | 2 → 0 | variant **strictly below** `known-good` | the variant's `cancel` builds an `ApiError` by hand and returns `ResponseEntity<Any>`; anchor 0 names exactly that literal on a refusal path. The other three methods still throw, so one method is the candidate cause. |
| `maintainability` (25) | `known-good` | `good-nested-ifs` | 2 → 0 | variant **strictly below** `known-good` | `known-good` decides on an exhaustive `when (order.status)` in expression position; the variant is an `if`/`else if`/`else` chain on the same values. Anchor 0's first clause names the chain; anchor 2 requires the expression-position `when` with no `else`. |
| `change-focus` (15) | `known-good` | `good-noisy-diff` | 2 → 0 | variant **strictly below** `known-good` | the variant's `cancel` is character-identical to `known-good`, and `create`, `getById` and `list` are restyled — three unnamed methods, so anchor 0's "two or more" fires. `known-good` reaching 2 is the deliberate repair of validator pass 12 C2 and is itself part of what is being proved. |
| `test-quality` (25) | **`good-strong-tests`**, not `known-good` | `good-weak-tests` | 2 → 0 or 1 | **weak strictly below strong** | `known-good` carries no test file, so its cell is a **structural `null`** under Decision A and cannot be a reference. This is E-001's own construction on BE-003, in its words: *"For `test-quality` that is the pair: weak below strong."* The four clauses of anchor 2 are the four gaps the `good-weak-tests` note names. |

**Registered as expected and not as a failure:** `test-quality` is `null` on `known-good`,
`good-inline-envelope`, `good-nested-ifs` and `good-noisy-diff` — four structural nulls, the same
count-by-construction E-001 predicted at 3 of 20 on BE-003's smaller set. A `null` there is a
measurement (§6), not a missing cell, and it does not enter any separation row.

**Registered as expected on the off-dimension cells:** each variant should hold its
`known-good` value on the three dimensions it does not vary, because the fixture notes assert the
rest of each tree is identical. Where it does not, that is a finding about the rubric's specificity
and is recorded rather than smoothed — but it is **not** a §7 halt, because the halt condition is
about a dimension failing to separate, not about one being noisier than hoped.


### Amendment, written before the first scoring call and not after it

*Amended by Opus 5 (claude-opus-5), autonomously, 2026-09-09, at commit `c42120b`+1, **before any
codex call of this proof was made**. The table above is left standing, unedited, because a
prediction is not tidied here even when its author finds the fault himself. What follows corrects
its **reference cell**, not its directions — every ↓ cell above is still predicted to be the low
cell of its column.*

**The fault: three of the four rows above name `known-good` as the reference, and two of its four
cells cannot exist.** `tools/codex-score.sh:161-170` attaches `known-good` as the baseline for
every target and attaches **no baseline when `known-good` is itself the target** — the tool's own
words, *"the target IS the baseline; its cells see one tree, the others see two."* So on a
`known-good` sheet:

- `change-focus`'s precondition fires — *"No baseline tree among the attachments → score: `null`"*.
  I predicted 2. **That prediction is refuted by the instrument's construction, before it ran.**
- `test-quality`'s precondition fires — `known-good` carries no test file, deliberately. I had
  already registered that one as a structural null, and it stands.

**E-001 settled this on BE-003 and §1 says the files win over the prompt's wording.** Author
decision 9 says *"every dimension separates its variant from `known-good`"*; E-001's
"Superseded: the six-cell population" section says the opposite and gives the measurement reason:

> **Discrimination is a comparison among these five, not against `known-good`.** Each variant
> depresses exactly one dimension, and all five are scored under identical conditions — same
> rubric, same baseline attached. The test is whether the **↓** cell in a column scores below
> the other cells in that column. For `test-quality` that is the pair: weak below strong.

and, on the `known-good` sheet Decision B dropped: *"the earlier KEEP condition, 'scores below
`known-good` on its own dimension', had **no reference value for 2 of the 4 categories** — not an
asymmetry to adjust for, a missing number."* **The disagreement between this prompt and E-001 goes
into HANDOFF.md**, as §1 requires.

**So the proof runs two comparisons, and only the first one decides anything.**

| | What it is | Status |
|---|---|---|
| **Primary — the registered test** | Among the **five variants**, all scored under identical conditions (same rubric, `known-good` attached as baseline to each): in each dimension's column, the variant that varies it scores **strictly below every other cell** in that column. `test-quality`'s column has two non-null cells and the test is weak < strong. | **This is what a §7 halt is judged on.** |
| **Secondary — reported, decides nothing** | The `known-good` sheet itself, scored as a sixth target. `architecture-consistency` and `maintainability` are computable there; `change-focus` and `test-quality` are structural nulls. Its evidence set is **one tree where every other sheet sees two**, so it is a different condition and cannot carry a separation claim. | Reported because author decision 9 asks for it, labelled because E-001 measured why it cannot be the reference. |

**Predicted, before the run, for the secondary sheet:** `architecture-consistency` 2,
`maintainability` 2, `change-focus` `null`, `test-quality` `null`. If either of the first two comes
back below 2, that is a finding about the one-tree condition and is reported as such — it does not
touch the primary test, which never reads this sheet.

**Predicted for the primary test, restated with the corrected reference:**

| Dimension | The ↓ cell | Predicted for it | The other cells in that column | Separation required |
|---|---|---|---|---|
| `architecture-consistency` | `good-inline-envelope` | 0 | `good-nested-ifs`, `good-noisy-diff`, `good-strong-tests`, `good-weak-tests` at 2 | ↓ cell strictly below all four |
| `maintainability` | `good-nested-ifs` | 0 | the other four at 2 | ↓ cell strictly below all four |
| `change-focus` | `good-noisy-diff` | 0 | the other four at 2 | ↓ cell strictly below all four |
| `test-quality` | `good-weak-tests` | 0 or 1 | `good-strong-tests` at 2; the other three **structural `null`** | weak strictly below strong |


### How it is run

`./tools/codex-score.sh benchmark/rubrics/backend-quality-be004.yaml <fixture>` on six targets —
`known-good` and the five `QUALITY_VARIANTS` — Path A, which proves each target is gate-passing
from BE-004's **own** `verify-evaluator.sh` registry rather than from a flag. `known-good` is
scored with no baseline attached, by the tool's own boundary rule — which is exactly why its
sheet is the secondary comparison and not the reference.

### Result

**Six sheets, codex only (`gpt-5.6-sol`), every one asserting `rubric_sha: 6252778b8472` and its own
target path in its provenance header — read back by me from the headers, not taken from the
scorer's summary.** Run 2026-09-09T07:36:31Z–07:38:57Z, all six exit 0.

| Fixture | Sheet | `architecture-consistency` | `maintainability` | `test-quality` | `change-focus` |
|---|---|---|---|---|---|
| `good-inline-envelope` | `findings/codex/score-good-inline-envelope-20260909T073631Z.yaml` | **0** ↓ | 2 | `null` | 2 |
| `good-nested-ifs` | `findings/codex/score-good-nested-ifs-20260909T073707Z.yaml` | 2 | **0** ↓ | `null` | 2 |
| `good-noisy-diff` | `findings/codex/score-good-noisy-diff-20260909T073739Z.yaml` | 2 | 2 | `null` | **0** ↓ |
| `good-strong-tests` | `findings/codex/score-good-strong-tests-20260909T073804Z.yaml` | 2 | 2 | 2 | 2 |
| `good-weak-tests` | `findings/codex/score-good-weak-tests-20260909T073833Z.yaml` | 2 | 2 | **1** ↓ | 2 |
| *(secondary)* `known-good` | `findings/codex/score-known-good-20260909T073857Z.yaml` | `null` | 2 | `null` | `null` |

Every sheet carried exactly four category entries.

#### The primary test — PASSES on all four dimensions

| Dimension | ↓ cell | Its value | Every other cell in the column | Strictly below? | Predicted? |
|---|---|---|---|---|---|
| `architecture-consistency` | `good-inline-envelope` | 0 | 2, 2, 2, 2 | **yes** | predicted 0 — **held** |
| `maintainability` | `good-nested-ifs` | 0 | 2, 2, 2, 2 | **yes** | predicted 0 — **held** |
| `change-focus` | `good-noisy-diff` | 0 | 2, 2, 2, 2 | **yes** | predicted 0 — **held** |
| `test-quality` | `good-weak-tests` | 1 | `good-strong-tests` 2; the other three structural `null` | **yes**, on the pair | predicted 0 **or** 1 — **held** |

**No dimension failed to separate, so §7's rubric-proof halt does not fire.** Each ↓ cell is not
merely the minimum of its column — it is strictly below **every** other cell in it, which is the
stronger of the two readings and the one registered.

**The off-dimension cells held too, and that was registered as expected rather than claimed
afterwards.** Every variant scored 2 on all three dimensions it does not vary. The fixture notes'
held-constant claims are L3 prose — nothing executes to check that `good-nested-ifs` did not also
drift on architecture — and this grid is the first evidence that they are true of BE-004's set. It
is evidence, not proof: a variant that drifted in a way this rubric cannot see would look identical.

**The three `test-quality` nulls are the count registered in advance.** `good-inline-envelope`,
`good-nested-ifs` and `good-noisy-diff` carry no test file, so the precondition fires before an
anchor is read. A `null` is a measurement (§6), not a missing cell, and none of them enters a
separation row.

#### The secondary sheet — one prediction REFUTED, in the direction that strengthens the amendment

I predicted `architecture-consistency` 2 and `maintainability` 2 on the `known-good` sheet, with
`change-focus` and `test-quality` `null`. **`maintainability` came back 2. `architecture-consistency`
came back `null`**, and the sheet says why: *"ambiguous: anchors 1 and 2 require baseline exception
provenance."*

**That prediction is refuted and stays refuted.** It is also the more interesting outcome. This
rubric's `architecture-consistency` anchor 2 requires an `ApiException` subclass *"that ALREADY
EXISTS IN THE ATTACHED BASELINE"* — so with no baseline attached, the anchor is undecidable, not
false. E-001 found **2 of 4** `known-good` cells structurally null on BE-003 and called that *"not
an asymmetry to adjust for, a missing number."* On BE-004 it is **3 of 4**. The amendment written
before the run said the `known-good` sheet cannot carry a separation claim; the sheet then produced
a third null on its own, which is a sharper argument for that than the one I made.

**What it does not touch:** nothing. The primary test never reads this sheet, and the `known-good`
column of the primary grid is the baseline *attached to* the other five, which is a different object
from the sheet scored *on* `known-good`.

#### The hand re-read, §5's requirement, done on the one cell that is not at an extreme

Three of the four ↓ cells are `0` and their columns are otherwise `2`; those are the easy readings.
**The cell worth re-deriving by hand is `test-quality` on `good-weak-tests`, which came back `1`** —
the residual, the only value in the grid that is neither floor nor ceiling, and the one a wrong
reading would hide inside.

It was re-read from `CancelOrderTest.kt` and the rubric at sha `6252778b8472` alone, by a scorer
that was told not to open anything under `findings/` — so the sheet's value could not anchor it.

| Clause of anchor 2 | Hand reading | `path:line` |
|---|---|---|
| (a) cancel called twice, second response **body** asserted | **not met** — `cancel("O-4")` appears once | `CancelOrderTest.kt:79` |
| (b) after the 409, order status **and** a shipment status re-read through separate `get(...)` | **not met** — `.andExpect(status().isConflict)` is the test's last line | `CancelOrderTest.kt:79` |
| (c) a refusal asserts the error **envelope body** | **not met** — no `jsonPath("$.error…")` in the file | `CancelOrderTest.kt:79` |
| (d) persisted state after a success re-read through a separate `get(...)` | **not met** — `jsonPath("$.status").value("CANCELLED")` is asserted off the mutating call's own response | `CancelOrderTest.kt:63` |
| anchor 0's condition (*every* assertion is a bare status code) | **not met** — line 63 reads a body | `CancelOrderTest.kt:63` |

**Hand value: 1. Sheet value: 1. They agree, and they agree for the same stated reason** — line 63
reads a body, which rules out anchor 0, while none of anchor 2's four clauses is present anywhere,
which lands it on the residual.

**What this checks and what it does not.** It checks that the sheet's `1` is re-derivable from the
files by a reader who never saw it. It does **not** check the other five sheets, and it is `n = 1`.
It is stated as true of this cell.

#### Verdict on the instrument

**`benchmark/rubrics/backend-quality-be004.yaml`, sha `6252778b8472`, is proved and is registered
in `Controlled variables` above as of this section — and not one line earlier.** It discriminates on
all four of BE-004's constructs, on the fixture set built to vary one dimension at a time, scored by
the registered scorer and by no other (author decision 10.2).

**Two things it does not establish, said here so they are not read into it later.** It has never
scored a *run* — every cell above is a fixture, hand-built to be separable, and an agent's output is
not. And `maintainability`'s construct is two-valued on this task, which the rubric's own header
flags: *"the variance it can show is smaller than on a three-valued enum … a null result on this
dimension is read against the instrument first."* That warning survives the proof; separating a
hand-built if-chain from a hand-built `when` is a weaker claim than separating two runs.


## §4 step 5 — the preflight pair

*Run and read back by Opus 5 (claude-opus-5), autonomously, 2026-09-09, before any
batch run of this experiment existed.*

| Arm | `runId` | `variant` | Started | Finished | Sheet of assertions below |
|---|---|---|---|---|---|
| Treated | `3ffb338d-54fc-4e6a-a5c9-34974782d062` | `phases-v1.0` | 2026-09-09T07:46:56Z | 07:50:03Z | `evidence/b05-preflight/step5-init-schema/init-schema-3ffb338d-….txt` |
| Control | `d0f50d7f-0b3d-46c2-88f7-dff41ea7d845` | `baseline` | 2026-09-09T07:50:43Z | 07:53:28Z | `evidence/b05-preflight/step5-init-schema/init-schema-d0f50d7f-….txt` |

**Author decision 9's `preflight per arm on BE-004 under its own key` is met twice over.** Three
earlier probes in the identical batch environment — `c6d44da9`, `db318da7`, `b8e31a61`, filed in
`evidence/b05-preflight/README.md` as set 3 — already carry this `agentHash` and this `init.tools`
list on BE-004. Those are **corroboration, not a substitute**: they were run on 2026-09-08 under a
different key and before this stop opened, and a read-back taken in the session that launches the
batch is the one §4 step 5 asks for.

### The reading

| Assertion | Treated arm | Control arm | Verdict |
|---|---|---|---|
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` | `null` | **as registered** |
| `customization.instructionsHash` | `null` | `null` | **as registered** — this overlay is an agent file, not a `CLAUDE.md`; the field is expected null on both arms and its being null on the treated arm is not a delivery failure |
| `customization.skillsHash` | `null` | `null` | no skill is installed on either arm |
| `init.tools` delivered | `["Read","Edit","Write","Bash"]`, declared `n=4`, delivered `n=4`, **`verdict=match`** | 29 tools, `verdict=recorded-only` (no overlay to assert against) | **`Edit` and `Write` reach the model** — author decision 8's requirement, met |
| `evaluation.exitCode` | `0` | `0` | both arms cleared the evaluator |
| `behavior.modelCalls` | non-null | non-null | **telemetry is live**; no turn or cost number in this stop rests on a null |
| `repository.commitSha` | `eea144ef940fda4cb6090561fdd901aed0013c8e` | same | the registered benchmark commit, on both |
| `runtime.model` | `claude-haiku-4-5-20251001` | same | the controlled variable, read back not assumed |

**`events.jsonl` grew from 1 913 lines at 07:43:28Z to 1 974 after the fourth run — +61 lines
across four runs, read inside the window rather than inferred from an exit code.** That is stop 11's
telemetry rule discharged for this batch environment: the OTLP endpoints passed were the tunnel's
`14317`/`14318`, and they are carrying.

**The ports had to be passed as `make` command-line variables, and this is not a detail.**
`agent-observatory/Makefile` does `-include infra/.env`, whose `API_PORT=8081`,
`OTLP_GRPC_PORT=4317` and `OTLP_HTTP_PORT=4318` **beat environment variables**. All three of those
host ports are leaked `limactl` forwards with nothing behind them — verified this session: `8081`
accepts a connection and returns bytes no JSON parser will take, while `18081` returns 382 records.
A run launched with those defaults would post to a dead endpoint. `make API_PORT=18081
OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 …` overrides them, confirmed with `make -n` before the
first run and by the four records afterwards.

### Kept worktrees

All four exist and each holds `evaluation.json` and `sample-service`:

```
${TMPDIR}/observatory-run-<runId>
```

**They are under `TMPDIR`, which macOS reaps.** The hand re-read at §4 step 7 depends on them, so
it is done in the same session as the batch rather than deferred — the evidence README already
records `TMPDIR` sweeping a previous set of init records.

### What these four runs are NOT

They are **preflight probes under their own keys**, `EXP-B5-PHASES-BE003-PREFLIGHT` and
`EXP-B5-PHASES-BE004-PREFLIGHT`, deliberately separate from the batch keys. **They join no `n`, and
no number below is a result.** `modelCalls` was 11 treated against 18 control on BE-003 and 26
against 31 on BE-004 — a direction opposite to "phases add turns" — and **that is `n = 1` per cell
and is stated here only so that nobody later finds it and thinks it was hidden.** The batch decides
this, not these.

### The confound this preflight found, registered before the batch

**The two arms differ in a second way, and the preflight is what made it visible.** The treated arm
is delivered `["Read","Edit","Write","Bash"]`. The control is delivered **29 tools** — the full
default set, which additionally contains `Task`, `WebSearch`, `WebFetch`, `NotebookEdit`, `Monitor`,
`Workflow`, the `Cron*` family and the rest. So the treatment is not only the six-phase procedure;
it is the procedure **bundled with a four-name tool list**, because that is what a Claude Code agent
definition is. Nothing in this experiment's registered `Threats to validity` said so before now.

**Most of that difference is inert here, and one part of it is not.**

- E-005 measured that `tools:` **filters names, not capabilities**, and that a list containing
  `Bash` does not stop writes — 10/10 write attempts, `p = 1.0` against no list at all. This list
  contains `Bash`. So the narrower list is not a capability boundary and the treated arm is not
  restricted in what it can do to the repository.
- `WebSearch`, `WebFetch`, `NotebookEdit`, `Monitor`, `Workflow` and the `Cron*` family have no
  path to this benchmark: it is an offline Kotlin service with no network step.
- **`Task` is the exception and it is the one to watch.** The control can delegate to a subagent;
  the treated arm cannot. A control run that delegates is doing something the treated arm is
  structurally unable to do, and any difference that follows has two candidate causes.

**Registered mitigation, executable rather than promised:** `tools/check-phase-contract.py` already
detects delegation — it is case **J** of the fixture set, *"a phased run that delegated passes, and
the confound is reported"*. So **every control run's transcript is counted for `Task` use, and the
count is reported beside the batch's numbers**. If it is zero across the control arm, the confound
is inert on this data and is reported as inert. If it is not zero, the affected runs are named and
the comparison is read with them called out. **The count is reported either way**, including when it
is zero — a confound that is only mentioned when it fires is a confound nobody checked.

**This is added to `Threats to validity` as item 7, dated, before the first batch run.** It is not
an edit to a prediction and it changes no threshold; it is a threat the preflight exposed, recorded
in the place threats live, which is what a preflight is for.



## §4 step 6 — the batch

One launch, `evidence/b05/batch-BE-004-20260909T094351Z/`, key `EXP-B5-PHASES-BE004`, `n = 10` per
arm interleaved treated/control, started `2026-09-09T09:43:51Z`. **All 20 runs completed and all 20
were admitted** by `./tools/check-run-gate.sh` (20 admitted, 0 refused). No run was lost and none
was re-run — the DNS outage that cost BE-003 four runs had cleared before this batch started.

## Results

`n = 10` per arm. Medians and quartiles; no mean quoted alone.

### Delivery — P1, the void condition

| | Treated | Control |
|---|---|---|
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` × 10 | `null` × 10 |
| `customization.instructionsHash` | `null` × 10 | `null` × 10 |
| `init.tools` delivered | **4** — `Edit` yes, `Write` yes, `Task` **no** — × 10 | 29, including `Task`, × 10 |
| `runtime.model` | `claude-haiku-4-5-20251001` × 10 | same × 10 |

**P1 held, 10 of 10 against 0 of 10.** The declared four tools were delivered as four on every run,
so E-005's runtime rewrite did not recur here either — and no treated run *could* delegate, because
`Task` was not among them. Threat 7 is closed mechanically on this task as it was on BE-003.

### The phase contract — P2, P3, P4

`tools/check-phase-contract.py` over each run's stream-json transcript.

| Clause | Treated | Control | Registered | Held? |
|---|---|---|---|---|
| P2 — six markers, once each, in order | **10 of 10** | **0 of 10** | ≥ 9 of 10 treated; control a floor, never a finding | **held** |
| P3 — first mutating `tool_use` after `DESIGN` | **10 of 10** | n/a | ≥ 9 of 10 treated | **held** |
| P4 — pre-`DESIGN` `Bash` write shapes = 0 | **9 of 10** (pair 10 had 1) | n/a | 0 in ≥ 9 of 10 — **one run stricter than E-010** | **held, exactly at its threshold** |

`DESIGN` position against first mutation, per treated run: 18/19, 15/16, 13/14, 18/20, 17/20,
17/18, 19/20, 19/20, 21/22, 20/21. **P3's registered confound behaved as registered:** BE-004 is a
six-file change, and the first write lands later here than on BE-003 (median position 18.5 against
16) **in the control too** (control first-mutation median 14 here against 12 on BE-003), which is
why P3 was registered as an absolute rate in the treated arm and never compared to the control.

**The same two-of-ten leak, on a different task.** Pairs 04 and 05 carry all six markers in order
and write after `DESIGN`, and fail the third check — `completion`, *"DONE is missing contract
field(s)"*. **8 of 10 complete DONE contracts here, exactly as on BE-003.** Two tasks, twenty
treated runs, the same failure at the same rate: **the completion contract is where this overlay
leaks, and it is a property of the overlay rather than of either task.**

### Cost and turns — P5 and P6

| Outcome | Treated | Control | Registered | Held? |
|---|---|---|---|---|
| `modelCalls` median (q1, q3) | **28** (25, 30) | **29.5** (27, 32) | ≥ +4, quartiles non-overlapping | **P5 refuted** |
| `estimatedCost` median (q1, q3) | **$0.2171** (0.1906, 0.2218) | **$0.2409** (0.2342, 0.2546) | ≥ +25 %, quartiles non-overlapping | **P6 refuted** |
| `durationMs` median | 184 s | 155 s | +40 % | not cleared (+18.7 %) |
| `outputTokens` median | **18 191** | 13 574 | report-only | +34.0 % |
| `cachedTokens` median | **494 558** | **1 043 686** | report-only | **−52.6 %** |
| `addedLines` median | 214 | 176 | report-only | — |
| evaluator pass | **10 of 10** | **10 of 10** | ≥ 8 of 10 both arms, differing < 3 | **P8 held** |

**Both cost predictions are refuted in the same direction as on BE-003, and the replication is the
result.** Two independent tasks, two independent batches, `n = 10` per arm each: the treated arm
took fewer model calls and cost less, both times, against a registered **+25 %** and **+4** both
times.

**The token composition replicates too, and it is the mechanism.** Treated produced **34 % more
output while re-reading 53 % less context** — on BE-003 it was **37 % more output and 60 % less
context**. The registered mechanism for P6 was that one agent carrying one growing context through
six phases would compound its input cost. **Context compounding is real and it is the control's**:
the plain baseline re-read a **million** cached tokens per run here against the treated arm's half
million.

**But the effect is smaller here, and E-011 registered a prediction about exactly that.** P6 said:
*"BE-004 makes this mechanism more testable, not less: the context being re-read is six files
instead of three, so if compounding is the mechanism the effect should be larger here than on
BE-003."* The cost gap is **−9.9 % here against −20.4 % on BE-003** — **smaller on the bigger
task**, in the direction opposite to the registration on both. The distributions tell a subtler
story than the medians: on BE-004 the **quartiles separate cleanly** (treated q3 `$0.2218` below
control q1 `$0.2342`) where on BE-003 they touched, and 9 of 10 treated runs sit below the control
median (79 of 100 pairwise). A permutation test on the median difference gives **`p = 0.075`**
here against `p = 0.026` on BE-003 — **unregistered, chosen after the data, and fenced off from the
decision rule** for the same reason as there.

`modelCalls` on this task is **flat, not reversed**: −1.5 on a median of 29.5 is −5.1 %, quartiles
overlap fully, permutation `p = 0.83`. Whatever the treatment does to cost here, it is not done by
removing turns.

<!-- filled at step 8. Median AND range, never a mean alone.
     Includes BE-004's reference population for B6/B7 — see the MDE section's closing obligation. -->

### The second reader on BE-004 — and it could not finish the task

Decision C is unchanged: **codex produced every number above; opencode is a second reader and is
not a vote.** All 20 runs were sent to `./tools/opencode-score.sh` with
`ollama-cloud/deepseek-v4-pro` against the same rubric sha `6252778b8472`.

**Only 11 of 20 came back with scores.** Nine produced a **header-only sheet** — the provenance
block written, no `categories:` beneath it — which §4a and §6 both define as a **stall, not a
finding**. Each of the nine was attempted **twice**, the second time under a 300-second kill, and
stalled both times. The stall files are kept on disk and are named here; they are not counted, and
no cell is inferred from one.

| Category | codex vs deepseek, on the 11 complete sheets |
|---|---|
| `architecture-consistency` | **11 / 11** |
| `maintainability` | **11 / 11** |
| `test-quality` | **11 / 11** |
| `change-focus` | **3 / 11** |

**Thirty-three of thirty-three on the three categories that carry every registered outcome, and
3 of 11 on the one that carries none.** That is now the **third independent replication** of the
same split — lab#70's 34/34 against 18/34, this stop's BE-003 batch at 60/60 against 7/20, and
BE-004 at 33/33 against 3/11 — on three different run populations, two different tasks and two
different rubrics.

**And the stalls are themselves a finding about author decision 10.3 and Decision H.** Decision H
promotes this fallback to *registered scorer* if codex is out for more than twelve hours.
**On BE-004 the fallback could not score 9 of 20 runs at all**, twice each. BE-004's diffs are
190–290 added lines across six files against BE-003's 40–85 across three, and the failures are
concentrated in a contiguous block of pairs — so the most likely reading is that the fallback does
not scale to this task's diff size, not that it failed at random.

**If that is right, Decision H is not executable on BE-004**, and a codex outage at stop 13 or
later would leave the harder task with no registered scorer rather than with a substituted one.
That is offered as an observation with its `n`, not as a decision: **the decision is the
author's**, decision 10.3 already carves `change-focus` out of the fallback for a different
measured reason, and this adds a second and larger constraint beside it.

*Added by Opus 5 (claude-opus-5), autonomous, 2026-09-09. No number above changes: every registered
outcome of this experiment comes from the 20 complete codex sheets.*

### §5 hand re-read — one cell, read off the worktree before any sheet was opened

Taken while the registered scorer was still running and by a reader instructed not to open
`findings/` at all, so it cannot have been anchored by a sheet.

- **Run:** `fdb51fbd-4018-404a-afee-203871d54e97` — pair 01, **treated**.
- **Rubric:** `benchmark/rubrics/backend-quality-be004.yaml`, sha **`6252778b8472`**, verified by the
  reader before scoring. **Not** BE-003's `396e1799eb2b`.
- **Cell:** `test-quality`. **Hand value: 1.**

BE-004's anchor 2 has **four** citable clauses where BE-003's has three:

| Anchor 2 clause | Holds | Evidence |
|---|---|---|
| (a) `cancel` called twice on one order, the second response's **body** asserted | yes | `OrderControllerTest.kt:134-136` |
| (b) after a 409 refusal, order status **and** a shipment status re-read through separate `get(...)` and asserted unchanged | **no** | `:168,172` — direct `repository.findById()` calls, not HTTP `get(...)` requests |
| (c) at least one refusal asserts the error envelope body | yes | `:164` |
| (d) persisted state after a successful cancel re-read through a separate `get(...)` | **no** | `:107-110,132-136` — only the cancel response itself is asserted; no `get(...)` follows a successful cancel anywhere in the new tests |

Anchor 0 does not hold (body assertions exist), two of four clauses of anchor 2 are absent, so the
closing rule lands on the residual, **1**.

**The two absent clauses are the same failure BE-003's hand re-read found**, in a task built to be
harder: the agent verifies through the repository it just wrote to, rather than re-reading state
through a second request. That is the one behaviour both rubrics' anchor 2 is built around, and on
these two runs the model does not do it on either task. **The registered sheet for this run gives `test-quality: 1` — the same value**
(`findings/codex/score-observatory-run-fdb51fbd-4018-404a-afee-203871d54e97-20260909T105329Z.yaml`,
rubric `6252778b8472`). Two hand re-reads at this stop, one per task, and both agree with the
registered scorer on the value; on BE-003 they agreed on the stated reason as well.

### Quality — all four categories, both arms, `n = 10` each

Registered scorer codex, rubric `benchmark/rubrics/backend-quality-be004.yaml` sha **`6252778b8472`**
on all 20 sheets, proved on five fixtures at §4 step 4 before any run was scored.

| Category | Treated | Control | Fisher (anchor 2) |
|---|---|---|---|
| `architecture-consistency` | **2 × 10** | **2 × 10** | — no variance in either arm |
| `maintainability` | **0 × 10** | **0 × 10** | — no variance in either arm, and at the floor |
| `change-focus` | 0×5, 1×3, 2×2 | 0×1, 1×5, 2×4 | treated **worse**; see the caveat below |
| `test-quality` | 1×7, **2×3** | 1×7, **null×3** | **3 of 10 vs 0 of 10, `p = 0.2105`** |

**P7 held, exactly at its boundary: `test-quality` anchor 2 in the treated arm is 3 of 10**, against
a registered ceiling of *"≤ 3 of 10, and specifically not ≥ 5"*. **Row 4b does not fire** (it needs
≥ 7), so declared phases did not return what E-007's structural split returned, and E-007 needs no
amendment from this task either. **Row 6 does not fire**: anchor 2 is not 0 of 10 in both arms.

**This is the dimension author decision 9 built BE-004 to recover, and it recovered — partly.**
On BE-003 both arms tie at 1 of 10, `p = 1.0`, and the dimension says nothing. Here the treated arm
reaches anchor 2 **three times and the control never does**. `p = 0.2105` does not clear 0.05, so
**this is a direction and not an effect**, and it is reported as one. But it is the first BE-004
number where the two arms are distinguishable at all, and the four-clause anchor that E-011 warned
*"is plausibly unreachable by this model on either arm"* turned out to be reachable — three times,
in the arm with the procedure.

**`architecture-consistency` and `maintainability` are flat here too, and `maintainability` is worse
than flat.** It is **0 in twenty runs out of twenty** — the harder task pinned it to the floor
rather than opening it up. So **50 of this rubric's 100 points carry no information on this task
either**, which is the same finding BE-003 produced and is not the outcome decision 9 hoped for
when it added the task. What BE-004 bought was `test-quality`, not the other two.

**The `change-focus` row is the least trustworthy number in this file and is not used for
anything.** The treated arm scores worse (five 0s against one). No registered outcome reads it —
and `change-focus` is precisely the dimension where this project has now twice measured the two
scoring harnesses disagreeing: 18 of 34 in lab#70, and **7 of 20 on this stop's BE-003 batch**,
against 60 of 60 on the other three categories. Author decision 10.3 already makes a
fallback-scored `change-focus` report-only for that reason. **A dimension that two competent
scorers cannot agree on is not evidence that an arm wrote a noisier diff.**

### The nulls again, and the one shape that repeats across both tasks

| | wrote scorable test code | wrote none (`null`) | Fisher |
|---|---|---|---|
| BE-004 treated | **10 of 10** | 0 | `p = 0.2105` |
| BE-004 control | 7 of 10 | **3** | |
| *(BE-003, for reference only)* treated | 10 of 10 | 0 | `p = 0.0867` |
| *(BE-003)* control | 6 of 10 | 4 | |

**The same direction on both tasks, and neither clears 0.05 on its own.** The treated arm has now
written scorable test code on **twenty runs out of twenty** across two tasks; the plain control
skipped it seven times in twenty.

**I computed the pooled figure and am disclosing rather than using it: 20/20 against 13/20 gives
`p = 0.0083`. It is not a result and it does not enter any row of any decision rule.** Author
decision 9 is explicit — *"No verdict is computed across tasks"* — and pooling two batches to cross
a threshold neither reached alone is exactly the move that rule exists to forbid. It is written here
because computing a number and then not mentioning it is worse than fencing it, and because it
names precisely what a later stop should **register in advance**: *does the procedure make the model
write a test at all?* That question is cheap, it is answerable on either task, and on this evidence
it is where the effect is — not in how good the test is once written.

## Which predictions held

Wrong predictions stay wrong. Nothing below was edited after the run.

| # | Prediction | Registered | Observed | Verdict |
|---|---|---|---|---|
| P1 | delivery | 10/10 hash, 0/10 null, `init.tools` ⊇ {Edit, Write} | 10/10, 0/10, four tools delivered as four | **held** |
| P2 | six markers in order | ≥ 9 of 10 | **10 of 10** (control 0 of 10) | **held** |
| P3 | first write after `DESIGN` | ≥ 9 of 10 | **10 of 10** | **held** |
| P4 | pre-`DESIGN` `Bash` writes = 0 | 0 in ≥ 9 of 10 | 0 in **9 of 10** | **held, exactly at threshold** |
| P5 | `modelCalls` ≥ +4, quartiles apart | treated higher | treated **−1.5 (−5.1 %)**, quartiles overlap, permutation `p = 0.83` | **REFUTED** |
| P6 | `estimatedCost` ≥ +25 %, quartiles apart | treated dearer | treated **−9.9 %**, quartiles **do** separate, permutation `p = 0.075` | **REFUTED, opposite direction** |
| P7 | `test-quality` anchor 2 ≤ 3 of 10 | ≤ 3, not ≥ 5 | **3 of 10** | **held, at the boundary** |
| P8 | evaluator pass ≥ 8 of 10 both arms, differing < 3 | floor | **10 of 10 and 10 of 10** | **held** |

Six held, two refuted — **the same two, in the same direction, as on BE-003.**

**P8 is the one I said would be most informative if wrong, and it was not wrong.** E-011 predicted
the treated arm would *not* produce a correctness effect, and it did not: both arms passed 10 of 10
at 7/7 acceptance. BE-004 was built with an all-or-nothing cascade trap and an unnamed guard, and
**this model walked through both on twenty consecutive runs with and without a procedure.** The
traps are not trapping it, which is itself the most useful thing to hand to stop 13.

## Decision

**Decision rule, walked in order:**

- **Row 0** — P1 fails? No: 10 of 10 / 0 of 10, every sheet at rubric `6252778b8472`. Does not fire.
- **Row 1** — P2 ≤ 5? No, P2 is 10 of 10. Does not fire.
- **Row 2** — P2 ≥ 9 and P3 ≤ 5? No, P3 is 10 of 10. Does not fire.
- **Row 3** — P2 ≥ 9 and P3 ≥ 9 and (P5 or P6 clears)? Neither clears; both were registered as
  increases and both came out as decreases. Does not fire.
- **Row 4** — the same, **and nothing improved**? Cost fell 9.9 %, with **quartiles that separate**
  (treated q3 `$0.2218` below control q1 `$0.2342`) and 9 of 10 treated runs below the control
  median. Something improved. Does not fire. *(The same ambiguity the §4a review raised against
  E-010's row 4 applies here and is resolved the same way, from the row's own gloss — "costing
  nothing this `n` resolves" — which names cost.)*
- **Row 5** — evaluator pass differs between arms by ≥ 3? **No: 10 and 10, difference 0.** Does not
  fire, and P8 stands.
- **Row 6** — `test-quality` anchor 2 is 0 of 10 in **both** arms? **No: treated is 3 of 10.** Does
  not fire — and that it does not fire is decision 9's return on this task.
- **Row 7** — anything else. **Fires.**

### Verdict: INCONCLUSIVE — reported as its combination, not rounded

> The phases are observable (10 of 10) and followed in position (10 of 10) on a task three times
> the size of BE-003. The overhead they were built to cost is **negative** on this task too. The
> decision rule cannot name that, because every row assumed the treatment would cost more.

**The same verdict as BE-003 by the same route — and that is the finding, not a coincidence.** Two
tasks, two independently registered decision rules, two batches of `n = 10` per arm, and both land
on the catch-all row for the identical reason: **the cost predictions were written in the wrong
direction, twice, and neither rule has a row for being wrong that way.**

### Keep, modify, or remove

**Keep `phases-v1.0`, unpromoted — the same decision as on BE-003 and reached from this task's own
evidence, not carried across from it.**

- Observable and followed: 10 of 10 on both clauses, by a checker with a fixture set shown to reject
  the narration shape.
- **The same defect at the same rate:** 2 of 10 treated runs emit `DONE` without its four contract
  fields, exactly as on BE-003. Twenty treated runs across two tasks, four failures, all of them the
  completion contract. **That is the v1.1 item and this task confirms it is the overlay's, not
  BE-003's.**
- Not promoted. §6 forbids promotion on one batch, and half this rubric's points carry no
  information on this task.
- **What this task adds that BE-003 could not:** `test-quality` distinguishes the arms here (3 of 10
  against 0 of 10) where on BE-003 it could not. The dimension is worth carrying to stop 13; the
  other three are not.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*
