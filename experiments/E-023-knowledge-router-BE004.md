# Experiment E-023 — the knowledge router, BE-004

**Key:** `EXP-B9-ROUTER-BE004` · **Spine stop 20 (B9)** · **version v1.2** ·
**Workbook:** [`phases/b09-knowledge-router/`](../phases/b09-knowledge-router/README.md)

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-26T09:20Z; the author did not review
before the run.`

> Everything down to and including **Decision rule** is filled in before the first run, and this
> file is committed before it.

Author decision 9: BE-003 is a **separate** experiment,
[`E-022`](E-022-knowledge-router-BE003.md). Separate key, separate prediction commit, separate
concurrent control, separate MDE table, separate decision rule. **No verdict is computed across
the two**, and the one-variable rule applies within this task only.

The design reasoning, the layer labels, the confound this stop registers rather than resolves,
and the constraint on what the corpus may contain are in the workbook's *Design* section and in
`E-022`; they are not restated here. **What differs on this task is the baseline, and it differs
completely** — which changes the test, the thresholds and the decision rule.

---

## Question

Same question as `E-022`, on a task where the outcome is not bimodal but **floored**: does routed
knowledge move `maintainability` off an anchor-2 rate of zero that has held across every arm ever
measured on BE-004?

## Hypothesis

BE-004's `maintainability` anchor 2 is reachable — `E-011:344` records the `known-good` fixture
deciding on *"an exhaustive `when (order.status)` in expression position"*, and the variant it
separates from is *"an `if`/`else if`/`else` chain on the same values"*. So the construct exists
on this task, the rubric can see it, and the pinned model has never produced it in 36 recorded
runs.

A floor is a better test than a spread, for one reason and against one risk. The reason: **any
movement is unambiguous**, and the two-arm test is decidable at `n = 10` where on BE-003 it is
not. The risk: a floor can be a floor because the task makes the construct *harder to reach*
rather than because the model lacks the fact — BE-004 is a cross-module cancel with an
all-or-nothing cascade and a guard on shipment creation, so status dispatch is one clause of a
larger ticket and may simply get less of the model's attention. **If that is why the floor
exists, knowledge will not lift it**, and the null is about the task's shape rather than about
retrieval. Registered here so it is not discovered in the write-up.

## Predictions

1. **PRIMARY — two-arm.** The treated arm reaches `maintainability` **anchor 2 on ≥ 5 of 10**
   scored runs against a control at or near 0, `Fisher p ≤ 0.0325`. *Mechanism:* as `E-022` —
   the corpus states the Kotlin exhaustiveness rule and the router surfaces it before the branch
   is written. The threshold is the MDE itself, which is what a floored baseline buys.
2. **SECONDARY — one-arm, and decidable lower.** The treated arm reaches anchor 2 on **≥ 3 of
   10**, tested against `p0 = 0.0798`, the 95 % one-sided upper bound on the rate after 0 of 36:
   `P(X ≥ 3 | n = 10) = 0.0399`. So a smaller effect than prediction 1 is still separable from
   the historical floor even though it is not separable from a concurrent control.
3. **THE ROUTER IS USED.** `.agent/knowledge-log.jsonl` is non-empty on **≥ 7 of 10** treated
   runs. *Mechanism and consequence:* identical to `E-022` prediction 3 — an L3 instruction can
   produce zero uptake, and if it does, this batch measured an instruction nobody followed.
   **Registered as the most likely of the five to be wrong on this task specifically**: BE-004's
   ticket is longer and has more clauses competing for attention than BE-003's.
4. **COST.** `estimatedCost` median rises by **≤ +10 %** against the concurrent control. B8's
   BE-004 medians were `$0.209355` treated and `$0.200527` control, +4.4 % (`E-019:337`).
5. **NOTHING ELSE MOVES**, with one carve-out that is not mine to make: `architecture-consistency`
   and `test-quality` medians are identical between arms. **`change-focus` is not predicted**,
   because `E-019` declared it unmeasurable on this task and author decision 10.3 already carves
   it out of the fallback scorer; it is reported with that label and enters no row of the
   decision rule.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing: the customization overlay** — the same two overlays as `E-022`, treated
`build/customizations/agent-v1.2-knowledge/` against control `build/customizations/agent-v1.1/`,
v1.1 unmodified. **The corpus is byte-identical between the two tasks**: it names a language
rule, not a ticket, so nothing in it is BE-004-specific and its `knowledgeHash` is the same value
on both. That is a property worth stating because it makes the two tasks' arms comparable in
delivery even though **no verdict is computed across them**.

The control is v1.1 and is run **concurrently**, for the same reason as `E-022`: B8's BE-004
batch ran on CLI `2.1.272` and this one runs on `2.1.283`. B8's stored numbers transfer the MDE
and the cost baseline and nothing else.

## How the treatment is delivered — and proved

Identical to `E-022`'s table — `--customization`, the new `knowledgeHash` over the set of files
under `.ai/knowledge/`, and the three preflight conditions — run **again, under this experiment's
own key**, because author decision 9 requires a per-arm preflight on BE-004 with the `init.tools`
read-back before any batch, exactly as author decision 8 requires for an overlay on BE-003.

| | |
|---|---|
| Mechanism | `--customization build/customizations/agent-v1.2-knowledge/` (`run-agent.sh:338`, force-added at `:371`), found by the runner with `BENCHMARK=BE-004` |
| Content hash | `knowledgeHash`, to be built at §4 step 4; the same value as on BE-003, asserted rather than assumed |
| Preflight assertion | one run per arm under `EXP-B9-ROUTER-BE004`: `knowledgeHash` set / `null`; `.agent/knowledge-log.jsonl` ≥ 1 line on treated and absent on control; corpus shas match the overlay; plus the `init.tools` read-back (decision 8) |
| Control assertion | no `.ai/knowledge/` path in the control overlay → `knowledgeHash: null`, no log file, both read back from the record and the kept worktree |

**If the preflight's log condition fails, the batch does not start.** The scorers read BE-004's
own `QUALITY_VARIANTS` line from its `verify-evaluator.sh`; that is unchanged.

## Controlled variables

- [ ] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` `2fc445d`
- [ ] task + revision — `BE-004-cancel-order`, on `main` since benchmarks#29 → `eea144ef`
- [ ] harness + version — `claude` **`2.1.283 (Claude Code)`**, read back from `runtime.version`
- [ ] model — **`claude-haiku-4-5-20251001`**
- [ ] permissions / permission mode — as B8's BE-004 batch
- [ ] environment — `ISOLATE_USER_SETTINGS=1`, with only the observable half of the isolation
      claimed (the record has no hook-execution field)
- [ ] runner commit — the same `agent-observatory` sha on both arms, recorded per run

## Runs

Repetitions per arm: **10**, interleaved · Total budget: **≤ $5.20** for this task
(20 batch runs at B8's `$0.21` median = `$4.20`, plus 2 preflight runs, plus headroom).
BE-004 runs take 2–4 minutes each (decision 9).

Prediction commit: **`ef2c6c0`, 2026-09-26T09:20:40Z** (`2026-09-26T11:20:40+02:00`) — the same commit as `E-022`; both prediction files went in together, before any run of either. · First run of the registered BE-004 batch `startedAt`: **2026-09-26T18:45:27Z** — **9 h 25 min later**. The earliest BE-004 run under this key at all is the preflight at **2026-09-26T12:52:45Z**, also after the commit. Both read from git and from the archived run records, not from prose. *Filled 2026-09-27 at §4 step 8, as the placeholder required.*

## Minimum detectable effect

**Derived from the measured arms first.** The reference population is every BE-004 arm whose
per-run `maintainability` values are recorded:

| arm | anchor-2 count | source |
|---|---|---|
| B6 treated / control | 0 / 10 · 0 / 10 — *"floored at 0 on 20 of 20"* | `E-013:601` |
| B8 treated / control | 0 / 9 · 0 / 7 — treated values `[0 ×8, 1]`, and **the single non-zero is a 1, the residual, not anchor 2** | `E-019:353` |
| **pooled, per-run values only** | **0 of 36** | computed |
| B7 treated / control | medians 0 and 0 at `n = 7` each, per-run values not tabulated (`E-016:481`) | **consistent with the floor and not counted into it** |
| B5 | recorded as floored at stop 12, cited forward at `E-013:601` | not counted |

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: `maintainability` anchor-2 count, two-arm Fisher vs the concurrent control | 0 of 36 → a control expected at 0 of 10 | **5 of 10.** `5/10 vs 0/10 → p = 0.0325`; `4/10 → 0.0867`; `3/10 → 0.2105`; `2/10 → 0.4737` | yes |
| secondary: same count, one-arm binomial vs `p0 = 0.0798` (Clopper–Pearson 95 % upper bound after 0 of 36) | the 36 runs above | **3 of 10**, at `p = 0.0399`; `4 of 10 → 0.0058` | yes |
| secondary: `estimatedCost` median | B8's `$0.209355` [0.195181–0.257077] treated, `$0.200527` [0.191364–0.208626] control (`E-019:337`) — **transferred** | B8's treated interval is about **±15 %** wide, so +10 % is a *bound*, not a detection | yes |
| reported, decides nothing: hit rate | no prior (6B finding 4) | first measurement | yes |
| **not predicted, reported with its label:** `change-focus` | `E-019:466` declared it unmeasurable on this task | none — it enters no row | yes |

**Derived against the interval, not the point estimate**, and on this task the interval is the
useful part: the control's plausible range is `0` to about `1` of 10, since the only non-zero in
36 runs was a 1 at anchor 1. **The 5-of-10 threshold survives a reduced scored population**,
which decision 9 requires be registered before the run because BE-004's pass rate is a result
rather than a nuisance: at `n = 8` per arm `5/8 vs 0/8 → p = 0.0256`, and at `n = 7`
`5/7 vs 0/7 → p = 0.0210`. So **prediction 1's threshold is stated as a count, 5, and holds down
to `n = 7` per arm.** Below 7 scored runs in either arm the primary is reported as
`NOT COMPUTED — population below the registered floor`.

| the prediction says | what tests it | what a null means |
|---|---|---|
| P1 *"the arms differ, ≥ 5 of 10 against ~0"* | two-arm Fisher against the control that occurred | inside the MDE → **not detectable** |
| P2 *"this arm reaches anchor 2 on ≥ 3 of 10"* | one-arm binomial vs the historical floor | far from 3 → **refuted** |

## Deterministic evaluation

`BE-004-cancel-order`'s own deterministic evaluator, BE-003's exit-code contract, two
evaluator-owned suites, proved by `verify-evaluator.sh` — re-run on a clean `main` at 12 of 12
when benchmarks#29 merged. `./tools/check-run-gate.sh` admits a run on the evaluator's recorded
verdict. Rubric scoring is **codex only** (Decision C, and author decision 10.2 makes codex the
*only* admissible proof on this task) with `benchmark/rubrics/backend-quality-be004.yaml` at sha
**`6252778b8472`** — registered and unmoved. `opencode-score.sh` on the same ids is the second
reader; on `change-focus` the two harnesses agree only 18 of 34 (lab#70), which is one more
reason that category enters no row here.

## Exclusions

As `E-022`, and one addition this task needs: **an evaluator failure is a result on BE-004, not
an exclusion from the report.** BE-004 is built so a capable model can fail it (decision 9).
Failed runs are excluded from *rubric* analysis, counted in the pass-rate line, and if the scored
population falls below **7 per arm** the primary is `NOT COMPUTED` rather than computed on a
smaller population than the MDE was registered against.

## Decision rule

Registered before data. `M` = treated anchor-2 count out of the scored treated runs; `C` = the
control's; `H` = treated runs with a non-empty `.agent/knowledge-log.jsonl`; `n_t`, `n_c` = the
scored populations.

| # | condition | verdict | disposition (§4 step 10) |
|---|---|---|---|
| 0 | `n_t < 7` or `n_c < 7` | **NOT COMPUTED — population below the registered floor.** The batch is reported, the pass rate is the finding, and no verdict is claimed | corpus unchanged, pending |
| 1 | `H ≤ 2` | **VOID — THE TREATMENT WAS NOT TESTED**, at any `M`. E-005's description arm | not promoted; the finding is about the instruction |
| 2 | `H ≥ 3` and `M ≥ 5` and `Fisher(M,C) ≤ 0.05` | **KEEP — IMPROVED.** P1 held | promoted into v1.2 on this task |
| 3 | `H ≥ 3` and `M ≥ 5` and `Fisher(M,C) > 0.05` | **INCONCLUSIVE — THE CONTROL MOVED OFF ITS FLOOR.** A control above 0 after 36 runs at 0 means something other than the treatment changed between B8 and now; the historical floor is then not this batch's comparator and must not be substituted for it | not promoted; the control's move is investigated before anything is claimed |
| 4 | `H ≥ 3` and `M` is 3 or 4 | **INCONCLUSIVE — SEPARATED FROM THE HISTORICAL FLOOR, NOT FROM ITS OWN CONTROL.** P2 held, P1 refuted | not promoted; the `n` it would need is recorded |
| 5 | `H ≥ 3` and `M ≤ 2` | **REJECT.** Consulted and changed nothing. P1 and P2 both refuted | **removed**, and the removal is the finding |

And one row that fires **alongside** whichever of 0–5 applies:

| # | condition | what it adds |
|---|---|---|
| 6 | `estimatedCost` median delta vs the concurrent control **> +25 %** | **COST OBJECTION**, its own row and never a second condition on a failure row. On row 2 it downgrades to **KEEP WITH A COST OBJECTION** |

**The combination that reaches no row: none, and it is executed rather than asserted.**
Population first, then `H`, then `M` partitioned into `≥ 5`, `{3,4}`, `≤ 2`, with `≥ 5` split by
the Fisher result. `evidence/b09/verify-decision-rule-exhaustive.py` enumerates every
`(n_t, n_c, M, H, Fisher)` combination, exits 1 on a gap and 2 on a dead row, and exits 0 here:

```
E-023: every (nt,nc,M,H,fisher) combination, 0 gaps, verdicts reachable =
       INCONCLUSIVE-control-moved, INCONCLUSIVE-floor-only, KEEP, NOT-COMPUTED, REJECT, VOID
```

Its three exit codes were each provoked by a mutant before this file was committed; the mutant
list is in `E-022`'s decision rule. Row 6 is additive and sits outside the partition.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

*§4 step 6. Filled 2026-09-27 from the manifest and the 40 archived run records. The collector
rotated at 2026-09-26T19:46:35Z, so a `jq` over `events.jsonl` alone sees three runs of this batch
and returns a number; nothing below needs it.*

| observation | treated | control |
|---|---|---|
| runs | 10 | 10 |
| evaluator exit 0 | **10 of 10** | **10 of 10** |
| `check-run-gate.sh` exit 0 | **10 of 10** | **10 of 10** |
| `.agent/knowledge-log.jsonl` non-empty (`H`) | **1 of 10** | 0 of 10 |
| first log line is the index lookup | 1 of 10 | n/a |
| `router_denied` | **0 of 10** | 0 of 10 |
| `customization.knowledgeHash` | `sha256:0770219ae7f4281a80071d78dadea285` on 10 of 10 | **null on 10 of 10** |
| `runtime.model` | `claude-haiku-4-5-20251001` on 10 of 10 | same |

**Prediction 3 was registered as the most likely of the five to be wrong on this task
specifically**, on the ground that BE-004's ticket is longer and has more clauses competing for
attention than BE-003's. Uptake here is **1 of 10** against BE-003's 2 of 10 — the same direction
the prediction named, from a rate that was already too low to test anything.

**BE-004 still has never failed the evaluator on this model.** 10 of 10 in both arms, which takes
the running total to 9 + 20 + 20 + 14 + 20 and no exit-code failure anywhere in it.

## Results

*Filled 2026-09-27 from the 20 codex sheets of batch `20260926T151319Z`, every one at rubric sha
`6252778b8472` — the registered sha, re-derived on disk before scoring and again by the scoring
driver, which refuses to start if it has moved. Index:
`evidence/b09/batch-20260926T151319Z/codex-sheets.tsv`. Values read by a `sonnet` subagent and
re-derived in the orchestrator's own context with an independent parser over the same files.*

### The registered outcome

| | treated | control |
|---|---|---|
| `maintainability` anchor 2 (`M`, `C`) | **0 of 10** | **0 of 10** |
| `maintainability` median | 0 | 0 |
| two-sided Fisher | **`p = 1.0000`** | |

The treated arm's only non-zero cell is a single **1** on `03342809`. Every other cell in both
arms is **0**. The historical floor this task has sat on since B5 — 0 of 36 — is unmoved at 0 of
56.

### Every category, both arms

| category | treated median | control median | treated values | control values |
|---|---|---|---|---|
| `architecture-consistency` | 2 | 2 | ten 2s | ten 2s |
| `maintainability` | 0 | 0 | nine 0s, one 1 | ten 0s |
| `test-quality` | **1** | **1.5** | 1×7, 2×3 | 1×5, 2×5 |
| `change-focus` *(report-only, 10.3)* | **1** | **2** | 0×3, 1×4, 2×3 | 0×2, 1×2, 2×6 |

No nulls in any cell of either arm, on either precondition category.

### Cost, tokens and calls — the registered population only

| metric | treated median (min–max) | control median (min–max) |
|---|---|---|
| `estimatedCost` | **$0.207919** ($0.1759–$0.3263) | **$0.205583** ($0.1562–$0.2592) |
| model calls | 25.5 (23–41) | 27 (15–34) |
| tool calls | 24.5 (22–38) | 26 (14–33) |

**Cost median delta +1.14 %.** Duration is not reported as a result for the same reason as
`E-022`: the batch spanned rate-limit windows.

### The API cannot produce this report for this key

`run-b9-preflight.sh:134` gives the preflight pair the batch's own experiment key, so
`EXP-B9-ROUTER-BE004` holds **24** runs where the registered population is 20.
`analyze-experiment.py --expect-n 10` **refuses, exit 2**, naming the over-count;
`make baseline-report` pools silently. Numbers above come from
`evidence/b09/report-b9-registered.py`, which reads the 40 archived records **by run id**. Both
API outputs, refusal included, are kept under `evidence/b09/reports/`.

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | anchor 2 on ≥ 5 of 10, `Fisher p ≤ 0.0325` | **REFUTED** | **0 of 10**, `p = 1.0000` |
| 2 | anchor 2 on ≥ 3 of 10 against `p0 = 0.0798` | **REFUTED** | **0 of 10** |
| 3 | router used on ≥ 7 of 10 | **REFUTED** | **1 of 10.** Registered as the most likely of the five to be wrong on this task, and it was |
| 4 | cost ≤ +10 % | **HELD** | **+1.14 %** |
| 5 | `architecture-consistency` and `test-quality` medians identical between arms | **HALF HELD, HALF REFUTED** | `architecture-consistency` identical (2 vs 2, every value 2). `test-quality` **NOT** identical: **1 vs 1.5**, and the difference favours the CONTROL |

**Prediction 5's refuted half is the most instructive line in this experiment and it is not a
result about the treatment.** The treated arm consulted the router on **one** run out of ten. An
arm that never used its treatment is a control with a different hash, so a half-point median gap
on `test-quality` — and a full point on the report-only `change-focus`, also favouring the control
— is this instrument's **noise floor on BE-004 at `n = 10`**, measured here by accident. Had
uptake been high, the same two numbers would have been read as evidence that the knowledge router
makes tests and scope *worse*. They are recorded now, under `H = 1`, so that no later step can
read a gap of this size on this task as an effect without first clearing this bar.

## Failure analysis

**Delivered, not denied, not used.** `knowledgeHash` set on 10 of 10 treated records and null on
10 of 10 controls; `router_denied` no on 10 of 10. The corpus was in the worktree and the
instruction was in the overlay. Nine of ten runs did not open the log.

**Why lower than BE-003's 2 of 10, and it was predicted.** Prediction 3 named the mechanism in
advance: BE-004's ticket is longer and carries more clauses — the all-or-nothing cascade, the
cancelled-order guard on shipment creation — competing for the same attention the router
instruction needs. The instruction is L3 on both tasks and it loses to a longer ticket.

**`M = 0` cannot separate this from a `REJECT`, and the rule already knew that.** Row 5 of the
decision rule (`H ≥ 3` and `M ≤ 2`) is the `REJECT` row, and it is unreachable at `H = 1` by
construction. So the batch cannot distinguish *"the corpus was consulted and did not help"* from
*"the corpus was not consulted"* — it only observed the second. Writing `REJECT` here would be
claiming a measurement of a thing that did not happen.

**What would overturn it.** The same as `E-022`: a delivery mechanism that is not a sentence in a
`CLAUDE.md`. E-004 established that a skill's *description* decides whether it loads; nothing in
this track has yet tested an index delivered that way. That is a different treatment, and on this
task it would also need the ticket-length effect controlled.

## Sanity checks

- [x] **Did any dramatic number appear?** `03342809` at 41 model calls against a treated median of
      25.5, and `5bc8b735` at $0.3263 against a median of $0.2079. Both are inside the control
      arm's own spread on other batches and neither changes a median. Neither is excluded.
- [x] **Did any flattering number appear?** No number here flatters the treatment. The two that
      move at all — `test-quality` and `change-focus` — both favour the **control**, and they are
      disbelieved in the same direction they would have been believed: at `H = 1` the treated arm
      is not a treated arm, so they measure this instrument's noise, not a harm.
- [x] **If a fix motivated this run, did the original symptom disappear?** The Amendment 3
      preflight fix held: 20 of 20 BE-004 cells ran, 0 denied.
- [x] **Sheet against hand, and an ambiguity that was registered before it could be argued.**
      `3fc93ff4` `maintainability`: hand **0** (597dceb, committed 08:10:51Z, before the sheet
      started at 08:18:56Z), sheet **0**. Agreement. The hand re-read registered in advance that
      anchor 0 names *"an `if` / `else if` / `else` chain"* while this diff has a bare `if`, so a
      scorer could defensibly have returned the residual **1**. It did not: codex read the
      consequence clause the same way the hand reading did. **The ambiguity is real and did not
      bite**, and it is on record as a rubric-wording item for whoever ports this category next.
- [x] **Independence.** `knowledgeHash` treated/null by arm on 20 of 20; `runtime.model`,
      benchmark and rubric sha identical across arms and unmoved from registration.

## Decision

**`VOID — THE TREATMENT WAS NOT TESTED`, by decision-rule row 1 (`H ≤ 2`), with `H = 1 of 10`**,
at any `M`.

**Row 0 does not fire:** `n_t = n_c = 10`, both at or above the registered floor of 7. The
population is complete and the verdict is not a population failure.

**Rows 2–5 are all unreachable at this `H`**, by the rule's own partition — including row 5, the
`REJECT` row. That is the rule working as written, not a gap: it was enumerated by
`evidence/b09/verify-decision-rule-exhaustive.py` before the batch, over every
`(n_t, n_c, M, H, Fisher)` combination, 0 gaps and no dead row.

**Row 6 does not fire:** cost median delta **+1.14 %**, far inside +25 %.

**Disposition (§4 step 10): not promoted; the corpus stays in the repository.** The finding is
about the instruction, not about the corpus, and it is the same finding on both tasks — which is
itself worth more than either task alone, because the two tickets differ in every way except the
delivery mechanism, and the delivery mechanism is what failed.

*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-27, from the rule committed before the
batch. The author did not review before the run or before this verdict.*

## Follow-up

- **BE-004's noise floor at `n = 10` is now measured** — a 0.5 median gap on `test-quality` and a
  1.0 gap on `change-focus` between two arms that differ only in a hash. Any later step claiming
  an effect of that size on this task has to clear this bar first. It belongs in the MDE inputs
  for every BE-004 step after this one.
- **`change-focus` remains report-only on this task** under author decision 10.3 and `E-019`'s
  finding, and nothing here changes that; it is reported above and enters no row.
- **The preflight-key defect** (`run-b9-preflight.sh:134`) makes `analyze-experiment.py` refuse
  every B-step dataset that has a preflight. It refused correctly. Additive instrument PR under
  §4 step 14.
- **B8a's `handoff` field and B9's corpus are both artifacts nothing consulted.** Two steps in a
  row have now produced a well-delivered L3 artifact with near-zero uptake. That pattern, not
  either step, is what the §5 table for this stop should carry forward.

## Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation

*Amended by Opus 5 (claude-opus-5), autonomously, 2026-09-26, at §4 step 4 — **after the
prediction commit `ef2c6c0` and before any run of this experiment exists.** Nothing above is
rewritten; this section is the whole change.*

**What was registered.** The delivery proof and prediction 3 name
`.agent/knowledge-log.jsonl` — a file the router writes **inside the worktree under test**.

**Why it could not be that, read off BE-004's own evaluator rather than transferred from
BE-003's.** `tasks/BE-004-cancel-order/evaluator.sh` computes its changed-file set as
`git diff --name-only "$BASELINE_SHA"` **plus** `git ls-files --others --exclude-standard`
(`:124`), and its only ignore pattern is
`(^|/)(target/|\.mvn/|\.git/)|\.(log|class|jar)$|^(run|evaluation)\.json$` (`:119`) — the same
expression byte for byte as BE-003's. Its allowed production prefixes are
`…/order/`, `…/shipment/` and `…/api/` (`:98-102`), test sources are always allowed, and
anything else is an AC7 scope violation counted at `:296-302` and scored **exit 21** (`:39`).
A `.jsonl` under `.agent/` matches no ignore rule, is untracked, and would therefore be counted
as an unrelated production file **on every treated run of this task too**. Making it tracked in
the overlay changes nothing: it would then appear in the `git diff` half instead.

**This is not a new discovery; it is a repeat.** B7's preflight pair `2077432c` (BE-003) and
`88b861f3` (BE-004) **solved their tasks** — build, existing tests, functional suite, error
contract and dependency guard all passed — and were both scored exit 21 because the single
unrelated file was the guardrail's own log (`E-016-verification-policies-BE004.md:227-237`).
v1.1 carries the consequence in its own source: `policy-gate.sh:27-47` and
`repair-limit.sh:30-37` both write **outside** the worktree, under
`${TMPDIR}/…-$(basename "$CLAUDE_PROJECT_DIR")`, and both say why in the file. **The treatment
this stop adds inherits that convention rather than re-learning it at the cost of a batch.**

**What changes, and what deliberately does not.**

| | registered at `ef2c6c0` | as built |
|---|---|---|
| log path | `.agent/knowledge-log.jsonl`, inside the worktree | `${KNOWLEDGE_EVENT_LOG:-${TMPDIR:-/tmp}/knowledge-log-$(basename "$ROOT").jsonl}`, outside it, with the run id in the file's own name — the worktree basename is `observatory-run-<runId>` |
| what the log contains | one JSON line per lookup, on a hit **and** a miss | unchanged |
| `H` in the decision rule | treated runs whose log is non-empty | unchanged in every respect but where the file is read from |
| prediction 3's thresholds | ≥ 7 of 10 non-empty; ≥ 5 of 10 with the index lookup first | unchanged |
| preflight assertion (b) | present with ≥ 1 line on treated, absent on control | unchanged, read at the new path |

**Why this is not a §7 halt and not a registered-variable edit.** §6 forbids editing a
registered variable *mid-experiment*; this experiment has no runs, no run ids and no sheets —
`TRACK-B-STATE.md` records `NOTHING HAS RUN` at the boundary this amendment is written on. The
independent variable (corpus + router + instruction, present or absent), the outcome
(`maintainability` anchor 2), the rubric sha, the model, the evaluator and the decision rule are
all untouched. What moved is the filesystem location of the treatment's own bookkeeping, in the
direction that stops the instrument from measuring itself. Had it been found *after* the batch,
the batch would have been the finding.

**The claim this amendment gives up.** Preflight condition (b) no longer proves anything about
the worktree's contents, so *"the log is in the run's own tree"* — which would have made the
retrieval record an artifact of the run rather than of `$TMPDIR` — is not available at this
stop. Phase 6B's finding 3 named that as one of the two routes to a retrieval record the
harness does not have; **neither route is built here**, and the workbook's §5 layer column says
so in the row it applies to.

---

## Amendment 2 — the preflight refused the batch, and the cause was the harness, not the instruction

*Amended by Opus 5 (claude-opus-5), autonomously, 2026-09-26, at §4 step 5. The four preflight runs
below are kept as evidence and are **not** part of any population. Nothing above is rewritten.*

### What the preflight found

`evidence/b09/preflight-20260926T124800Z/` — four runs, one per arm per task, exit **2**.

| task | arm | run id | eval | `knowledgeHash` | corpus in worktree | router log | cost |
|---|---|---|---|---|---|---|---|
| BE-003 | treated | `fbdebf75` | **0** | `sha256:0770219ae7f4281a80071d78dadea285` | MATCH | **ABSENT** | $0.1499 |
| BE-003 | control | `ff1f8d03` | **0** | `null` | absent as registered | absent as registered | $0.110291 |
| BE-004 | treated | `5a16fd3e` | **0** | `sha256:0770219ae7f4281a80071d78dadea285` | MATCH | **ABSENT** | $0.227893 |
| BE-004 | control | `5ea203ac` | **0** | `null` | absent as registered | absent as registered | $0.289222 |

**Conditions (i) and (iii) held on every run.** The corpus was delivered, hashed, and proved present
in the treated worktrees and absent in the controls. The `init.tools` read-back author decision 8
requires returned `n=4 ["Read","Edit","Write","Bash"]` with verdict `match` on **all four** runs — so
unlike E-005's arm F, the runtime did not rewrite the tool list. All four runs **solved their task**.

**Condition (ii) failed on both treated arms**, and that is why no batch was started.

### The cause, and it is not what an absent log looks like

On `fbdebf75` the agent called the router **on its own initiative, at its first opportunity**:

```
.ai/knowledge/router.sh "state transition validation error codes"
```

and that call is in the run's **`permission_denials`** array. The treatment's own hooks did not
refuse it — `repair-limit.sh` recorded **nine allows and zero blocks** on the same run, and its
run-state file carries them. What refused it was `run-agent.sh`'s own allowlist: with
`--permission-mode acceptEdits` and `--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"`, **every Bash
command that is not mvn is denied**, and in `claude -p` there is no human to approve one.

**So the batch, had it run, would have recorded `H = 0`, fired **this file's decision-rule row 1**
(`H <= 2`), and reported `VOID — an L3 instruction nobody acted on` about an agent that acted on it
immediately.** That is a harness refusal read as a null result, which is this project's house
failure mode, and it is the same shape as stop 8's `--disable-slash-commands`.

**The two absences are not the same absence, and the instrument now separates them.** On
`5a16fd3e` (BE-004) the agent never mentioned the router at all — no attempt, no denial. Same
`ABSENT`, opposite meanings: one is a refused instruction, the other is an unfollowed one, and only
the second is what the VOID row is about. Both drivers now record `router_mentions` and
`router_denied` per run, hand-checked against these four logs (BE-003 treated 3 mentions / denied
`yes`; the other three 0 / `no`), and a treated denial now prints *"do NOT report this as the
decision rule's VOID row"*. **`n = 1` per arm per task: the BE-004 non-attempt is true of that run
and is not a property of the task** (§5).

### The fix, chosen by probe rather than by reasoning

Three arms, one model call each, `evidence/b09/router-permission-probe-20260926T130051Z/`:

| arm | `permission_denials` | router log |
|---|---|---|
| overlay settings as shipped | non-empty, names the router | none |
| **overlay `permissions.allow`** for the router | non-empty — **the entry was ignored** | none |
| **runner `--allowedTools` entry** | **`[]`** | **`{"status":"hit","topic":"kotlin-exhaustive-when",…}`** |

The overlay route was tried **first**, because a treatment's precondition belongs in the treatment.
The runtime refuses it and says why: *"Ignoring 1 permissions.allow entry from
.claude/settings.json: this workspace has not been trusted … or set
`projects[...].hasTrustDialogAccepted: true` in `~/.claude.json`."* Every benchmark worktree is a new
temp directory, untrusted by construction, and the remedy offered is a user-scope mutation that
`--isolate-user-settings` exists to prevent. **A treatment in this harness cannot grant itself a Bash
permission** — a finding worth more than this stop.

So the fix is in the runner (obs#90): `Bash(.ai/knowledge/router.sh:*)` added to `--allowedTools`,
**unconditionally, on every claude run of every arm**, for the reason the runner's own stream-json
comment gives about itself — a flag passed to the treatment arm only makes the launch a between-arm
difference. An allow rule for a path that does not exist cannot change a control run's behaviour.

### What it costs this experiment, stated rather than left to be inferred

- **Every run of this stop executes under a three-entry allowlist where every earlier stop's runs
  had two.** Both arms move together and the registered comparison is against a **concurrent**
  control, so the change is inside the comparison, not across it.
- **Every number transferred from a stored run was measured under the two-entry list.** That is the
  MDE inputs, the historical `maintainability` anchor-2 floor on this task (0 of 36 runs with
  recorded per-run values) and B8's cost baseline. They are still the registered MDE — they are what was on
  record before this batch — and every place they appear now carries this sentence.
- The four preflight runs above were made under the **two**-entry list. They are the evidence of the
  defect. They are not a population, they set no MDE, and the decision-13 pair cost is taken from
  the **re-run** preflight under the fixed runner, not from them.
- Nothing else moved: model, rubric sha, evaluator, benchmark sha (`2fc445d`), overlays, corpus,
  decision rules and every prediction are exactly as committed at `ef2c6c0`.

---

## Amendment 3 — the second preflight, the in-worktree proof, and the decision to run the batch anyway

*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-26, **before the batch started**. The
decision it resolves is a contradiction inside the workbook's own design section, which is the
builder's text from the previous session, not an author gate. Nothing above is rewritten.*

### The second preflight: the harness no longer refuses, and the agent no longer asks

`evidence/b09/preflight-20260926T131746Z/`, four runs, exit **2**, $0.7103, under the fixed runner
(obs#90 → `dfe5f02`, and the flag list is now echoed into each run's log:
`--allowedTools Bash(./mvnw:*) Bash(mvn:*) Bash(.ai/knowledge/router.sh:*)`).

| task | arm | run id | eval | `knowledgeHash` | corpus | router log | `router_denied` | cost |
|---|---|---|---|---|---|---|---|---|
| BE-003 | treated | `8f61203e` | 0 | registered | MATCH | ABSENT | **no** | $0.149849 |
| BE-003 | control | `9e3060de` | 0 | `null` | absent as registered | absent | no | $0.131132 |
| BE-004 | treated | `863f4436` | 0 | registered | MATCH | ABSENT | **no** | $0.218369 |
| BE-004 | control | `b1d0e311` | 0 | `null` | absent as registered | absent | no | $0.211 |

All four solved their task. Conditions (i) and (iii) held again; the `init.tools` read-back was
`n=4 ["Read","Edit","Write","Bash"]` / `match` on all four. **No denial on any run, and no attempt
on either treated run.** So the cause of the absent log has changed: it was a refusal, and now it
is a non-attempt.

**`router_mentions` reads 1 on every row of this manifest and that 1 is the runner's own echo, not
the agent.** The detector counts the string in the whole log and the runner now prints its flag
list, which contains the router's path. Corrected in both drivers after this preflight — never
during it (§4 step 4 forbids editing a tool while a run of it is in flight) — and stated here so no
reader takes `1` for an attempt.

**Uptake across both preflights: 1 attempt in 4 treated runs, and the one attempt was refused.**
`n = 4`. Under §5 that is *true of those runs* and is **not** a property of the treatment.

### The mechanism is proven in a real worktree, which is what the gate was protecting

`evidence/b09/inworktree-permission-probe-20260926T132958Z/`: a **copy of treated run
`863f4436`'s own kept worktree**, placed in a fresh temp directory so it is untrusted exactly as a
benchmark worktree is, driven by `claude -p` with the runner's exact flag set. Result:
`permission_denials":[]`, the router **executed**, it wrote
`{"status":"hit","topic":"kotlin-exhaustive-when",…}`, and the model reported both absolute paths.
Nothing of the evidence was touched — the probe's log went to a path of its own.

So: the corpus is delivered (condition i, iii, twice), and the router **can** be executed by the
agent under the registered harness (this probe). What remains unmeasured is only whether the agent
**chooses** to call it.

### The contradiction, and how it is resolved

The workbook's design section says both of these:

> *"If it never does, the hit rate is `0 / 0`, the corpus is a file nobody opened, and the
> experiment has measured an instruction nobody followed — **which is a result**, and the same shape
> as E-005's description arm."*

> *"A preflight that fails (2) is reported and the batch is **not** started until the instruction is
> the thing being tested rather than the thing being hoped for."*

The first calls zero uptake a result; the second forbids the batch that would measure it. Both are
the builder's own words from the previous session. **The resolution taken, with its reasons:**

1. **The gate exists to stop a batch that cannot test the treatment.** Deliverability is now proven
   in-harness by the probe above, so the batch can test it. Before obs#90 it could not, and the gate
   was right to fire — it saved $8 and it saved a VOID report about an agent that had obeyed.
2. **What remains is a registered outcome, not an unknown.** Prediction 3 registers uptake at
   **≥ 7 of 10** treated runs (`E-023` prediction 3) with the mechanism *"an L3 disposition can produce zero uptake"*, and
   **this file's row 1** gives `H ≤ 2` its own verdict. E-005's description arm — the case the
   design compares this to — **was run at `n = 10` and reported**, not skipped.
3. **At `n = 4` nothing can be said as a property (§5).** The batch is the only way to answer a
   prediction that is already on record.
4. **The spend is bounded by a control, not by optimism.** Author decision 13's ceilings, computed
   by the driver from this preflight's pairs: BE-003 `$0.280981 × 11 = $3.0908`, BE-004
   `$0.429369 × 11 = $4.7231`.

**The argument against, recorded because it may well be the right one.** If uptake is ~0 the treated
arm is v1.1 plus an unread corpus plus one unread `CLAUDE.md` section — and *that* comparison is
E-003's, already `REJECT` at `n = 10` per arm. On that reading the batch spends about $7.81 to
re-measure E-003 and returns `VOID`, which the rule itself says is *"not a result about knowledge
routing, at any M"*. If it lands there, this amendment is the record that the cost was known in
advance and accepted for one reason only: prediction 3 is on record and `n = 4` cannot answer it.

**What was deliberately *not* done.** The `CLAUDE.md` clause was **not** rewritten to make uptake
more likely. That would be tuning the treatment's own content against an outcome already observed,
after the prediction commit — the one move this project's method exists to prevent. Its sha stays
`sha256:ebf489800a60a156986f98ea4f127848`, the guards still assert it, and if a later version wants
a stronger instruction it is a new treatment with a new prediction commit.

## Amendment 4 — pointer: the batch deaths, the throughput decision and `--resume`

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-26.*

BE-004's arms run in the same interleaved batch as BE-003's, so the two batch deaths of 2026-09-26,
the decision to keep `n = 10` per arm per task rather than reduce it, the duration exclusion for runs
paced by a saturated five-hour rate window, the orphan-replacement rule as applied to
`413bcf23-65f4-49d3-a789-c29b3dcf1b48`, and the `--resume` instrument change with its four new
fixtures are all recorded **once**, in
[`E-022` Amendment 4](E-022-knowledge-router-BE003.md#amendment-4--the-batch-died-twice-the-deaths-were-the-harness-and-the-throughput-decision-is-recorded-here-before-it-was-acted-on).
Two facts from it bear directly on this task:

- **No BE-004 run had started when either batch died.** The interleaved loop finishes BE-003's ten
  pairs before BE-004's, so every BE-004 row of this experiment is run after the rate window reset at
  16:30:00Z and none of them needs the duration exclusion. BE-004's `$0` seeded spend against its
  computed ceiling of **$4.7234** is the driver's own resume output, not an assumption.
- **Row 0 of this experiment's decision rule is unmoved**: `n_t < 7 or n_c < 7 ⇒ NOT COMPUTED` was
  the reason reducing `n` was refused, not a consequence of it.

---

## Hand re-read — written 2026-09-27, BEFORE any BE-004 scoring sheet for this batch exists

*§5: "At least one scored cell per step is re-read by hand off the kept worktree and the hand
reading is written down next to the sheet's value." `E-022` carries the BE-003 cell, re-read on
2026-09-26 when no sheet of any kind existed. This is the BE-004 cell, and its ordering is weaker
than `E-022`'s and is stated rather than glossed: codex returned early and the registered scoring
run was already in flight when this was written — but it scores `run-ids.tsv` in file order, all
twenty BE-003 pairs before the first BE-004 pair, and at the time of writing it had produced four
sheets, all BE-003, and `grep -c BE-004 evidence/b09/batch-20260926T151319Z/codex-sheets.tsv`
returned **0**. So no sheet for this run, this task or this rubric existed to anchor the reading.
Written by Opus 5 (claude-opus-5), autonomously, 2026-09-27.*

| field | value |
|---|---|
| run | `3fc93ff4-4b85-4f3c-9d97-360c3853c056` — BE-004, **treated**, eval exit 0, gate exit 0 |
| worktree read | `$TMPDIR/observatory-run-3fc93ff4-4b85-4f3c-9d97-360c3853c056` |
| rubric | `benchmark/rubrics/backend-quality-be004.yaml`, `shasum -a 256 \| cut -c1-12` = **`6252778b8472`** — the registered sha, re-derived twice |
| cell | `maintainability`, the registered outcome of this stop |
| **hand value** | **0** |
| sheet value | *no BE-004 sheet existed when this was written; the row is filled when the scoring run reaches this id* |

Anchor 2 (`backend-quality-be004.yaml:79`) asks for *"One `when (order.status)` in EXPRESSION
position, carrying no `else`"*. It fails on the cheapest possible evidence: `grep -n 'when *(\|else'`
over `sample-service/src/main/kotlin/com/unityinflow/sample/order/OrderController.kt` returns
**nothing at all**. There is no `when` in the file and no `else` in the file.

The decision in `cancel` is a bare `if` at `OrderController.kt:56`
(`if (order.status == OrderStatus.CANCELLED) { return ResponseEntity.ok(order) }`), and the method
falls through past it to the cancel path.

**The anchor text and the anchor's own stated rationale disagree on this shape, and the reading is
recorded with that disagreement rather than without it.** Anchor 0 names *"an `if` / `else if` /
`else` chain"*; a single `if` with no `else` is not literally a chain, which would push this to
anchor 1, the residual. The category's rationale comment
(`backend-quality-be004.yaml:71-73`) names the property the anchor is for: *"an if-chain, or a
`when` with an `else`, makes it fall through silently"* — and a new `OrderStatus` constant compiles
without touching this method and takes the fall-through path unannounced, which is exactly the
0 condition's consequence clause, *"a new status constant compiles without touching this method
and takes the fallback path unannounced"*. **The hand value is 0 on the consequence clause.** A
scorer reading only the first sentence of anchor 0 could defensibly return 1 here, and if the codex
sheet returns 1 that is the anchor's wording, not a scorer defect — it is recorded now, before the
sheet, so that it cannot be constructed afterwards to explain a disagreement away.

**Re-derived in the orchestrator's own context, as §4b requires of any delegated value.** A `sonnet`
subagent produced the reading; the `sed -n '48,80p'` over `OrderController.kt` and the `grep` for
`when` / `else` were then run again by hand here and agree, and the anchor text was read out of the
rubric at its registered sha in this context rather than taken from the subagent's quotation.

**What this cell does and does not establish.** `n = 1`, true of this run, never stated as a
property (§5). It is a fixed point for the sheet to be compared against, and it is on the treated
arm — the arm whose corpus states the Kotlin exhaustiveness rule this category scores. That the
treated run does not use `when` at all is consistent with this batch's uptake finding (1 of 10
treated BE-004 runs opened the knowledge log at all) and is not independent evidence for it.

## Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-004 the difference is zero, and the zero is the result

*Added 2026-09-27 by Opus 5 (claude-opus-5), autonomously, at §4 step 9, from a read-only census of
runs already on disk. **Nothing above is rewritten. The registered decision rule is not touched and
the verdict does not move.** The census is `evidence/b09/corpus-access-census.sh`, ShellCheck clean,
fixture set `tools/verify-corpus-access-census.sh` at 15 of 15.*

### What was found

`H` is registered in this file as *"treated runs whose `.agent/knowledge-log.jsonl` is non-empty"*.
That log is written by `.ai/knowledge/router.sh` and by nothing else, so **`H` counts router
invocations.** It does not count a run that opened `.ai/knowledge/summaries/*.md` with the `Read`
tool, `cat`-ed it, or read `index.yaml` and followed the path by hand. Such a run consulted the
corpus and scores `H = 0`, indistinguishable in the decision rule from a run that ignored the
instruction entirely.

Per treated run of batch `20260926T151319Z`:

| run | router invoked | corpus read directly | `H` scores it | classification |
|---|---:|---:|---:|---|
| BE-004 08 | 1 | 1 (summary) | **1** | `router+direct` |
| the other nine | 0 | 0 | 0 | `no-contact` |

So on BE-004 **router invocations and corpus contact are the same number, 1 of 10.** The gap the
census exists to find is **zero here**, and that is the result for this task: it was looked for and
it was not there.

### Why it does not change the verdict, and why that is the right answer rather than a convenient one

`H` was registered **before any data**, in this file, as the log being non-empty. §6 and §4 step 12
forbid editing a prediction, a decision rule or a registered definition after its run, and
*especially* when the edit would change the verdict. So `H = 1 of 10` stands and row 1 stands.

**It is worth stating exactly what the other reading would have done**, because a reader who cannot
see that has to take this paragraph on trust: on this task the two readings agree: `H = 1` either way, row 1
fires either way, and no alternative definition available here reaches `H ≥ 3`. The census's value
on BE-004 is the negative — it looked for the gap E-022 found and did not find one.

### What it does change

1. **The `§5` layer column.** *A lookup was recorded* is **L2** only for lookups that went through
   the router. *The corpus was consulted* is **L3** — nothing executes to record a direct read.
2. **The hit-rate number carries its scope from now on.** It is a **router hit rate**, not a
   knowledge hit rate, and the build gate's phrase *"hit rate measured"* is answered at that scope.
3. **The instrument that would close it is named and not built** (§6, one step at a time): the
   corpus would have to be reachable only through something that records, or the record would have
   to come from the runtime's own file-read events rather than from the artifact's own log. Phase 6B
   finding 3's second route, still not built, and `author_notes` carries it.

*The census re-scores nothing, re-runs nothing, and moves no registered variable.*
