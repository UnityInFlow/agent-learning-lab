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
| Rubric | **`benchmark/rubrics/backend-quality-be004.yaml`, sha registered at §4 step 4 and not before** — it does not exist at this commit. **No BE-004 run is scored until the fixture proof passes** (author decision 9 + 10.2). | asserted on every sheet, not eyeballed |
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

<!-- filled at step 4, BEFORE any run of this experiment is scored.
     Five gate-passing variants against known-good, every dimension separating in the predicted
     direction, codex only (author decision 10.2). The registered sha goes in Controlled variables. -->

## §4 step 5 — the preflight pair

<!-- filled at step 5, before the batch -->

## §4 step 6 — the batch

<!-- filled at step 6 -->

## Results

<!-- filled at step 8. Median AND range, never a mean alone.
     Includes BE-004's reference population for B6/B7 — see the MDE section's closing obligation. -->

## Which predictions held

<!-- filled at step 8. Wrong predictions stay wrong. -->

## Decision

<!-- filled at step 10 -->
