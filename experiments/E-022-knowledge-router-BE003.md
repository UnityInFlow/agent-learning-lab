# Experiment E-022 — the knowledge router, BE-003

**Key:** `EXP-B9-ROUTER-BE003` · **Spine stop 20 (B9)** · **version v1.2** ·
**Workbook:** [`phases/b09-knowledge-router/`](../phases/b09-knowledge-router/README.md)

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-26T09:20Z; the author did not review
before the run.`

> Everything down to and including **Decision rule** is filled in before the first run, and this
> file is committed before it. The commit timestamp and the first run's `startedAt` are written
> into *Runs* after the batch.

Author decision 9: BE-004 is a **separate** experiment,
[`E-023`](E-023-knowledge-router-BE004.md), with its own prediction commit, its own concurrent
control, its own MDE table and its own decision rule. **No verdict is computed across the two.**

---

## Question

Does a knowledge corpus, reached through a router the agent has to call, change the code a run
produces — on the one rubric dimension where this task has a measured, repeated, untreated
failure?

And separately, because `build/README.md#b9` asks for it and because the answer is not the same
question: can this instrument record that a retrieval happened at all?

## Hypothesis

`maintainability` anchor 2 asks for one `when (shipment.status)` in **expression** position with
no `else`, because Kotlin requires such a `when` to be exhaustive and therefore makes a new enum
constant a compile error at that site (`benchmark/rubrics/backend-quality.yaml:138-161`). Runs
fail it by writing an `if` / `else if` chain, which compiles and routes a new state down the
fallback path unannounced.

**That failure is a missing fact, not a missing capability.** Every treatment this track has
tried since B3 has been a *process* instruction — phases, a verification gate, a run-state file,
a repair limit, an agent boundary — and each moved nothing the instrument could see. A knowledge
router is the first step whose payload can be a technical fact, and the mechanism proposed here
is narrow: the corpus states the Kotlin rule, the router surfaces it, and the run writes the
construct the rule names.

**The mechanism by which this fails is equally specific, and it is the stronger prior.** B6 is
this track's only clean positive and its payload was delivered as a **skill**, which the runtime
*selects* on its description — E-004 measured that the description decides whether a skill loads,
matched arm 5 of 5 against 0 of 5. This stop's payload is a file plus a sentence telling the
agent to go and get it: **no runtime selection mechanism at all**. E-009 measured exactly that
shape — the same prose, delivered as project memory with nothing dispatching it — at **0 of 10**.
So the honest hypothesis is *conditional delivery of a technical fact moves this cell*, and the
honest competing hypothesis is *a sentence asking the agent to fetch something is ignored, and
the corpus is a file nobody opened.*

## Predictions

1. **PRIMARY — one-arm.** The treated arm reaches `maintainability` **anchor 2 on ≥ 8 of 10**
   scored runs. Under the historical rate of 0.3625 (29 of 80 across the eight arms B5–B8
   measured) that is `P(X ≥ 8 | n = 10) = 0.0062`. *Mechanism:* the corpus names the construct
   the anchor scores and the router puts it in front of the agent before it writes the branch.
   **This is the prediction registered as most likely to be wrong**, for the reason the
   hypothesis gives: the delivery has no selection mechanism and the one measured instance of
   that shape returned 0 of 10.
2. **SECONDARY — two-arm, and registered as expected-null.** Treated minus control is **≥ +4
   anchor-2 runs**. The MDE table below shows the two-arm test is decidable at `n = 10` **only if
   the treated arm reaches 10 of 10**, across the control's plausible range of 3–5 of 10. So a
   real effect of the size prediction 1 describes is expected to return **NOT DETECTABLE** on
   this test, and that is registered here rather than explained afterwards.
3. **THE ROUTER IS USED, and this decides whether anything was tested.** `.agent/knowledge-log.jsonl`
   is non-empty on **≥ 7 of 10** treated runs, and on **≥ 5 of 10** its first line is the index
   lookup rather than a direct document read. *Mechanism:* the instruction is L3. E-005's
   read-only description arm made zero write attempts and therefore tested nothing; an L3
   disposition can produce zero uptake, and if it does here the batch has measured an instruction
   nobody followed.
4. **COST — clause (c) of the gate.** `estimatedCost` median rises by **≤ +10 %** against the
   concurrent control. *Mechanism:* the corpus is read conditionally, once, not carried on every
   turn; B7's always-on Layer 2 gate cost +5.02 % and B8's cost delta against its control was
   +2.4 % (`$0.119766` vs `$0.116974`, `E-018:335`).
5. **NOTHING ELSE MOVES.** `architecture-consistency`, `test-quality` and `change-focus` medians
   are each **identical between arms**. *Mechanism:* the corpus names one construct and says
   nothing about tests, scope or service structure.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Exactly one thing: the customization overlay.**

| arm | `--customization` | what it is |
|---|---|---|
| treated | `build/customizations/agent-v1.2-knowledge/` | **v1.1 exactly as it closed at B8**, plus `.ai/knowledge/index.yaml`, `.ai/knowledge/summaries/<topic>.md`, `.ai/knowledge/documents/<topic>.md`, `.ai/knowledge/router.sh`, and one clause in the overlay `CLAUDE.md` naming the router |
| control | `build/customizations/agent-v1.1/` | **v1.1 exactly as it closed at B8**, unmodified — a measured version is never edited (§3 pre-made decision) |

**The control is v1.1, not plain**, and that is the gate's own wording: `build/README.md#b9`
asks for *"context metrics compared against B8"*. This experiment makes **no claim against a
plain baseline**; B7 and B8 own theirs and neither is recomputed here.

**The control is run concurrently, and at this stop that matters more than at any previous one.**
B8's batch ran on CLI `2.1.272` (`E-018:217`); this batch will run on **`2.1.283`** — an
eleven-version move. Comparing against B8's *stored* v1.1 runs would put that move inside the
comparison. The stored numbers are used **only** to transfer the MDE and the cost baseline, and
are labelled as transferred wherever they appear.

**What a null here cannot be attributed to.** The overlay adds the corpus, the router and the
instruction **together**, because that is what a knowledge router is. A third arm carrying the
same text unconditionally would separate routing from prose — and **a new arm is a §7 halt**
(§7, final bullet), so this experiment registers the confound instead of resolving it. E-003 and
E-009's nulls narrow it but do not close it: both delivered generic *process* prose, never a
task-specific technical fact, and Phase 6B's finding 6 carries that narrowing itself at
`phases/06b-knowledge-retrieval/README.md:248-256`.

**What the corpus content may not be.** `run-agent.sh:259-262`'s leak check greps object path
**names** only, so content is uncontrolled by the harness (workbook extract fact 6). Registered
constraint: **nothing in the corpus derives from BE-003's tests, fixtures or evaluator.** Its
source is the rubric's own anchor text plus the Kotlin language rule that anchor depends on, and
it names neither `confirm` nor `ShipmentController`.

**And the limit that choice puts on the claim.** B6's skill body is written from `test-quality`'s
anchor clauses very nearly verbatim, so writing this corpus from `maintainability`'s anchor is
methodologically identical to the track's one clean positive. What it costs is registered here:
**the outcome measures whether routed knowledge reaches the model and is used — never whether
the model could have discovered the construct unaided.** That second question needs a corpus
written from something other than the measuring instrument, and this experiment does not ask it.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `--customization build/customizations/agent-v1.2-knowledge/`, copied into the worktree by `run-agent.sh:338` and force-added at `:371` |
| Content hash | **`knowledgeHash`** — a new run-record field over the **set** of files under `.ai/knowledge/`, written the way `skills_hash()` (`run-agent.sh:616`) hashes the set of `SKILL.md`s and `agents_hash()` (`:631-638`) the set of agent files. **It does not exist yet**: the four fields the runner emits today are `instructionsHash`, `skillsHash`, `agentHash`, `agentsHash` (`:640-645`) and **none covers a corpus** (workbook extract fact 5). Building it is §4 step 4's job, in its own `agent-observatory` PR with a fixture set, exactly as `agentsHash` was built at stop 17a (obs#88) |
| Preflight assertion | one run per arm before the batch: (a) `knowledgeHash` **set** on treated and **`null`** on control; (b) `.agent/knowledge-log.jsonl` present and **≥ 1 line** in the treated kept worktree, **absent** in the control's; (c) the corpus files in the treated worktree hash to the same values as in the overlay directory |
| Control assertion | the control overlay contains no `.ai/knowledge/` path, so `knowledgeHash` is `null` and no log file exists — both read back from the record and the kept worktree, never inferred from the flag |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this — and
> preflight condition (b) is the one that matters here, because a corpus can be delivered
> perfectly and never read. **If (b) fails, the batch does not start.** B6's stop-13 preflight
> and B8's stop-17 preflight both stopped a batch on exactly this check.

## Controlled variables

- [ ] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` `2fc445d`
- [ ] task + revision — `BE-003-confirm-shipment`, unchanged since B2
- [ ] harness + version — `claude` **`2.1.283 (Claude Code)`**, read back from `runtime.version`
      on every run, never from the flag
- [ ] model — **`claude-haiku-4-5-20251001`**, exact id, the pinned agent under test
- [ ] permissions / permission mode — as B8's batch, unchanged
- [ ] environment: hooks, plugins, skills, MCP servers, settings sources — `ISOLATE_USER_SETTINGS=1`,
      and **the isolation half that is observable is the only half claimed**: all five
      `customization.*Hash` read back, because the run record has **no hook-execution field**
      (§0a row 6 defect, recorded in `TRACK-B-STATE.md` `preflight:`)
- [ ] runner commit — `agent-observatory` at whatever sha the `knowledgeHash` PR merges to; the
      **same sha for both arms**, recorded per run

## Runs

Repetitions per arm: **10**, interleaved · Total budget: **≤ $3.20** for this task
(20 batch runs at B8's `$0.12` median = `$2.40`, plus 2 preflight runs, plus headroom)

Prediction commit: **`ef2c6c0`, 2026-09-26T09:20:40Z** (`2026-09-26T11:20:40+02:00`) · first run of the registered batch `startedAt`: **2026-09-26T15:13:20Z** (`c49eec44`, BE-003 01 treated) — **5 h 52 min later**. The earliest run under this experiment key at all is the preflight pair at **2026-09-26T12:48:02Z**, also after the commit; every run of every kind that touched this key postdates the prediction. Both read from git and from the archived run records, not from prose. *Filled 2026-09-27 at §4 step 8, as the placeholder required.*

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

**Derived from the measured arms, before any threshold above was written.** The reference
population is `maintainability` anchor-2 counts in every BE-003 arm B5–B8 measured, computed
rather than summed in prose:

| arm | anchor-2 count | source |
|---|---|---|
| B5 treated / control | 3 / 10 · 3 / 10 | `E-010:668` |
| B6 treated / control | 2 / 10 · 5 / 10 | `E-012:659` |
| B7 treated / control | 6 / 10 · 4 / 10 | `E-015:406` |
| B8 treated / control | 3 / 10 · 3 / 10 | `E-018:355` |
| **pooled** | **29 of 80 = 0.3625**; controls alone **15 of 40 = 0.375** | computed |

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: `maintainability` anchor-2 count, one-arm binomial vs `p0 = 0.3625` | the eight arms above | **≥ 7 of 10** already clears `p = 0.0318`; **≥ 8 of 10** is registered, at `p = 0.0062`, for margin | yes |
| secondary: same count, two-arm Fisher vs the concurrent control | the control arms' range, **3 to 5 of 10** | **10 of 10 and nothing less.** `10/10 vs 5/10 → p = 0.0325`; `9/10 vs 5/10 → 0.1409`; `8/10 vs 5/10 → 0.3498`. Against a control at 3 of 10, `9/10 → 0.0198` and `8/10 → 0.0698` | yes |
| secondary: `estimatedCost` median | B8's `$0.119766` [0.102048–0.144211] treated, `$0.116974` [0.101403–0.140168] control (`E-018:335`) — **transferred**, so the concurrent control supersedes it | a shift of about **+18 %** is the width of B8's own treated interval; **+10 % is inside the noise of a stop that moved nothing** and prediction 4 is therefore a *bound*, not a detection | yes |
| reported, decides nothing: hit rate | no prior exists (6B finding 4) | **first measurement**, no MDE | yes |

**Derived against the *interval* of the control, not its point estimate**, which is the whole
reason the two-arm row reads as it does. The control has landed at 3, 3, 4 and 5 of 10 in four
consecutive stops. E-003's lesson applied: asking what `n` keeps an 8-of-10 effect decidable
against a control at 5 of 10 gives roughly **30 per arm** — 60 runs on this task alone, about
`$7.20`, against decision 9's whole-step budget of about `$6` for two tasks. **So `n = 10` is
registered with the two-arm test declared underpowered rather than run and then excused**, and
the primary claim is the one-arm binomial, which the template explicitly provides for and which
needs no control.

| the prediction says | what tests it | what a null means |
|---|---|---|
| P1 *"this arm reaches anchor 2 on ≥ 8 of 10"* | one-arm binomial vs the historical 0.3625 | far from 8 → **refuted** |
| P2 *"the arms differ by ≥ 4"* | two-arm Fisher against the control that occurred | inside the MDE → **not detectable**, never refuted |

Both claims are made and **both are reported**.

## Deterministic evaluation

`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment`'s evaluator decides correctness, by
its exit-code contract, unchanged since B2. `./tools/check-run-gate.sh` admits a run to scoring
only on the evaluator's recorded verdict (Decision D). Rubric scoring is **codex only**
(Decision C) with `benchmark/rubrics/backend-quality.yaml` at sha **`396e1799eb2b`** — the
registered instrument, unmoved. `opencode-score.sh` on the same run ids is the second reader and
is not a vote.

## Exclusions

Registered now, not after seeing the data:

- runs the evaluator failed → excluded from rubric analysis, **counted in the pass-rate line**
- `check-run-gate.sh` refusals → excluded, reason recorded per run
- infrastructure failures of the F13/F15 class, permission blocks, quota exhaustion → excluded,
  and a run excluded for infrastructure is **replaced**, so the scored `n` stays 10 per arm
- a batch that spans a machine sleep → **duration excluded, the run kept** (§4 step 6). B8's
  BE-004 batch was split by a clamshell sleep and that is how it was handled there
- **no run is excluded for its score**, and no run folder, sheet or evidence file is overwritten
  or deleted at any point (§6)

## Decision rule

Registered before data. `M` = treated `maintainability` anchor-2 count out of the scored treated
runs; `C` = the same for the control; `H` = treated runs whose `.agent/knowledge-log.jsonl` is
non-empty.

**The rows are exhaustive over every `(M, H)` pair**, checked by enumeration before this file was
committed:

| # | condition | verdict | disposition (§4 step 10) |
|---|---|---|---|
| 0 | `H ≤ 2` | **VOID — THE TREATMENT WAS NOT TESTED.** An L3 instruction nobody acted on tested nothing; this is E-005's description arm, where a read-only description produced zero write attempts. Not a result about knowledge routing, at any `M` | corpus kept in the repo, **not** promoted; the finding is about the instruction, not the corpus |
| 1 | `H ≥ 3` and `M ≥ 8` | **KEEP — IMPROVED.** P1 held | corpus and router promoted into v1.2 |
| 2 | `H ≥ 3` and `M` is 6 or 7 | **INCONCLUSIVE — SEPARATED FROM HISTORY, NOT FROM ITS OWN CONTROL.** The one-arm test clears at 7 (`p = 0.0318`) and the two-arm test cannot see it at this `n` | not promoted; the `n` this would need is recorded for the author |
| 3 | `H ≥ 3` and `M ≤ 5` | **REJECT.** The corpus reached the model, was consulted, and changed nothing. P1 refuted | **removed** from the overlay, and the removal *is* the finding (§4 step 10) |

And two rows that fire **independently of, and alongside, whichever of 0–3 applies**:

| # | condition | what it adds |
|---|---|---|
| 4 | `Fisher(M, C) > 0.05` | **NOT DETECTABLE on the two-arm reading.** Always reported. Never the verdict on its own, because P2's MDE says this is the expected shape of even a real effect here |
| 5 | `estimatedCost` median delta vs the concurrent control **> +25 %** | **COST OBJECTION.** Its own row, never a second condition on a failure row: *a free useless rule is still a rule someone has to read, trust and maintain*, and an expensive useful one is a separate fact. On row 1 it downgrades the verdict to **KEEP WITH A COST OBJECTION** |

**The combination that reaches no row: there is none, and that is executed rather than asserted.**
`evidence/b09/verify-decision-rule-exhaustive.py` enumerates all 121 `(M, H)` pairs for this rule
and every `(n_t, n_c, M, H, Fisher)` combination for `E-023`'s, exits **1** on a gap and **2** on a
row that can never fire. Unmutated it exits **0**:

```
E-022: 121 combinations, 0 gaps, verdicts reachable = INCONCLUSIVE-hist-only, KEEP, REJECT, VOID
Both rules are exhaustive and neither has a dead row.
```

**And it was shown to refuse**, because a control that has never rejected anything is
indistinguishable from one that rejects nothing (§6). Three mutants, run: narrowing row 3 from
`M ≤ 5` to `M ≤ 4` leaves 8 uncovered combinations and exits **1**; disabling row 2 leaves 16 and
also exits **1** (a disabled row shows up as a gap before it shows up as a dead row, which is
worth knowing); adding an unreachable verdict to the expected set exits **2**. Rows 4 and 5 are
additive by construction and sit outside the partition the script checks.

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

*§4 step 6. Filled 2026-09-27 from the manifest and the 40 archived run records, not from a
telemetry file — and the reason is recorded rather than glossed: the collector ROTATED at
2026-09-26T19:46:35Z, so `events.jsonl` holds only the last three runs of this batch and a `jq`
over it alone SEES THREE RUNS AND RETURNS A NUMBER. Any telemetry claim here needs both
`events-2026-09-26T19-46-35.355.jsonl` and `events.jsonl`. The numbers below need neither: they
come from the run records, which are now archived in this repository at
`evidence/b09/batch-20260926T151319Z/run-records/`.*

| observation | treated | control |
|---|---|---|
| runs | 10 | 10 |
| evaluator exit 0 | **10 of 10** | **10 of 10** |
| `check-run-gate.sh` exit 0 | **10 of 10** | **10 of 10** |
| `.agent/knowledge-log.jsonl` non-empty (`H`) | **2 of 10** | 0 of 10 |
| first log line is the index lookup | **2 of 10** | n/a |
| `router_denied` | **0 of 10** | 0 of 10 |
| `customization.knowledgeHash` | `sha256:0770219ae7f4281a80071d78dadea285` on 10 of 10 | **null on 10 of 10** |
| `runtime.model` | `claude-haiku-4-5-20251001` on 10 of 10 | same |
| permission denials | 0 | 0 |

**Uptake is the whole story of this batch and it is not a harness failure.** Zero runs were
denied the router. On the two runs that used it, it was called once each and the first line was
the index lookup, as designed. The other eight read the instruction and did not act on it.

## Results

*Filled 2026-09-27 from the 20 codex sheets of batch `20260926T151319Z`, every one at rubric sha
`396e1799eb2b`, every one complete at four categories. The index is
`evidence/b09/batch-20260926T151319Z/codex-sheets.tsv`; the per-run sheets are under
`findings/codex/`. The four values per run were read by a `sonnet` subagent (§4b) and then
**re-derived in the orchestrator's own context with an independent parser over the same 20
files**; the two readings agree cell for cell on all 80 cells.*

### The registered outcome

| | treated | control |
|---|---|---|
| `maintainability` anchor 2 (`M`, `C`) | **5 of 10** | **4 of 10** |
| `maintainability` median | 1.5 | 0.0 |
| two-sided Fisher on the anchor-2 counts | **`p = 1.0000`** | |

### Every category, both arms

| category | treated median | control median | treated values | control values |
|---|---|---|---|---|
| `architecture-consistency` | 2 | 2 | ten 2s | ten 2s |
| `maintainability` | 1.5 | 0 | 0,0,0,1,1,2,2,2,2,2 | 0,0,0,0,0,0,2,2,2,2 |
| `test-quality` | 1 | 1 | ten 1s | ten 1s |
| `change-focus` | 1 | 1 | ten 1s | ten 1s |

No nulls in any cell of either arm.

### Cost, tokens and calls — the registered population only

From `evidence/b09/reports/registered-population-report.txt`, `n = 10` per arm:

| metric | treated median (min–max) | control median (min–max) |
|---|---|---|
| `estimatedCost` | **$0.127337** ($0.1097–$0.1518) | **$0.125968** ($0.1015–$0.1497) |
| model calls | 22.5 (18–27) | 21 (15–28) |
| tool calls | 20.5 (17–26) | 20 (14–26) |

**Cost median delta +1.09 %.**

**Duration is excluded and the exclusion is registered, not chosen after seeing it.** Run
`c49eec44` records 5420 s against a batch median near 117 s, because the batch spanned a
rate-limit window. §4 step 6: exclude duration, keep the run.

### The report came from the records, not from the API, and that is a finding about the instrument

`run-b9-preflight.sh:134` gives the preflight pair the **same experiment key as the batch**, with
the comment `REGISTERED`. So `EXP-B9-ROUTER-BE003` holds **25** runs where the registered
population is 20 — four preflight runs and the recorded orphan `6d728d76` share the key.

- `make baseline-report EXPERIMENT=EXP-B9-ROUTER-BE003` **pools them silently** and prints
  `25 measuring run(s)` with a median that is not this experiment's.
- `analyze-experiment.py … --expect-n 10` **refuses, exit 2**: *"arm `agent-v1.1` has 12 measuring
  runs, expected 10"*. A control that rejects the contaminated dataset is the only reason this was
  found rather than quoted. Both outputs are kept under `evidence/b09/reports/`, the refusal
  included.
- The numbers above therefore come from `evidence/b09/report-b9-registered.py`, which reads the 40
  archived records **by run id** off `run-ids.tsv`, so no run outside the batch can enter a number.

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | anchor 2 on ≥ 8 of 10 | **REFUTED** | **5 of 10.** Registered in advance as the one most likely to be wrong, and it was |
| 2 | treated − control ≥ +4 | **REFUTED** | **+1** (5 vs 4), Fisher `p = 1.0000` |
| 3 | router used on ≥ 7 of 10; index first on ≥ 5 | **REFUTED, both clauses** | **2 of 10** and **2 of 10**. This is the row that decides the verdict |
| 4 | cost ≤ +10 % | **HELD** | **+1.09 %** |
| 5 | no other category moves | **HELD** | `architecture-consistency`, `test-quality` and `change-focus` medians identical between arms, and every individual value identical too |

Four of five registered predictions are answerable and three of them are refuted. Prediction 3's
mechanism paragraph said exactly what its failure would mean — *"an L3 disposition can produce
zero uptake, and if it does here the batch has measured an instruction nobody followed"* — and
that is what happened. The prediction that was registered as most likely to be wrong was wrong,
and the one nobody doubted (cost) held.

## Failure analysis

**The treatment was delivered and was not used.** Delivery is proved per run and not by a flag:
`customization.knowledgeHash` is `sha256:0770219ae7f4281a80071d78dadea285` on 10 of 10 treated
records and `null` on 10 of 10 controls. The router was never denied — `router_denied` is `no` on
20 of 20 treated rows across both tasks. So this is not a permission failure, not a delivery
failure and not a harness failure: the corpus was in the worktree, the instruction to consult it
was in the overlay `CLAUDE.md`, and on eight of ten runs the agent did not consult it.

**That is the same shape as E-005's description arm**, which the decision rule named in advance:
a read-only *description* made zero write attempts, so nothing tested the boundary. Here an L3
*instruction to consult* produced two consultations, so almost nothing tested the corpus. The
rule's row 0 exists because this outcome was foreseen; it is not a surprise being retrofitted.

**What `M = 5` is and is not.** It is not evidence for the router. Five of the ten treated runs
reached anchor 2 and **eight of them never opened the log**, so at most two of those five could
have been influenced by the corpus at all. The control reached 4 of 10 unaided. The honest reading
is that `maintainability` on BE-003 sits near half on this model with or without the treatment,
which is what E-006 found when it measured 29 of 80 across the eight arms of B5–B8, and 5 vs 4 is
that same rate twice.

**The one thing that would overturn this result** is an uptake mechanism that is not an
instruction — a hook that injects the index, or a skill whose description selects it, the way
E-004 showed a description decides whether a skill loads. That is a different treatment and a
different step, not a re-run of this one at larger `n`. Raising `n` with `H = 2 of 10` buys a
tighter estimate of how often the model ignores a sentence.

## Sanity checks

- [x] **Did any dramatic number appear?** Yes — a 5420 s duration on `c49eec44`, 46× the batch
      median. Explained by the rate-limit window the batch spanned, and the explanation is
      testable: the neighbouring runs in the same window show the same gaps, and the run's own
      token and cost figures are unremarkable ($0.1414, 26 model calls). Duration is excluded
      under §4 step 6; the run is kept.
- [x] **Did any flattering number appear?** `M = 5` against a control of 4 could be written as
      *"the treated arm scored higher"*. Disbelieved twice: (a) Fisher `p = 1.0000`; (b) eight of
      the ten treated runs never opened the knowledge log, so the arm is mostly control runs
      wearing a hash. It is reported as `VOID`, not as a small positive.
- [x] **If a fix motivated this run, did the original symptom disappear?** The preflight fix
      (Amendments 2 and 3) was for the harness refusing the batch. It did not recur: 40 of 40
      cells ran and 0 of 20 treated rows were denied.
- [x] **Sheet against hand.** `c49eec44` `maintainability`: hand **2** (78d5af5, written before
      any sheet existed), sheet **2**. Agreement.
- [x] **Independence.** `knowledgeHash` set on every treated record and null on every control;
      `instructionsHash` differs between arms by design and is constant within each arm; model,
      benchmark and rubric sha identical across arms and unmoved from registration.

## Decision

**`VOID — THE TREATMENT WAS NOT TESTED`, by decision-rule row 0 (`H ≤ 2`), with `H = 2 of 10`.**
The row is unconditional on `M` and `M = 5` therefore decides nothing here.

**Row 4 also fires and is reported, as the rule requires:** `Fisher(5, 4) = 1.0000 > 0.05`, so the
two-arm reading is `NOT DETECTABLE`. Prediction 2 registered that as the expected shape even of a
real effect at this `n`, so it adds nothing beyond what was already written down.

**Row 5 does not fire:** cost median delta is **+1.09 %**, far inside the +25 % objection
threshold and inside prediction 4's +10 %.

**Disposition (§4 step 10): the corpus is KEPT IN THE REPOSITORY AND NOT PROMOTED**, exactly as
row 0 specifies. It is not removed — row 3, the `REJECT` row that removes it, requires `H ≥ 3`,
and removing an artifact that was never consulted would record a measurement nobody made. **The
finding is about the instruction, not about the corpus.**

*Decided by Opus 5 (claude-opus-5), autonomously, 2026-09-27, from the rule committed before the
batch. The author did not review before the run or before this verdict.*

## Follow-up

- **B9's gate clause "hit rate measured" is answered by this batch, and the answer is 20 %**
  (2 of 10 treated runs consulted the router; of those, 2 of 2 went index-first). That is a
  measurement, not a failure to measure, and it belongs in the §5 table with this `n`.
- **The preflight key defect is an instrument fix owed to every later step**, not to this one:
  `run-b9-preflight.sh:134` must give the preflight its own key, or `analyze-experiment.py` will
  keep refusing every B-step dataset that has a preflight. It refused correctly here. Filed for
  §4 step 14 as an additive instrument PR.
- **`codex-score.sh` has no timeout**, proved by a 61-minute wedge during this step's scoring. The
  mitigation is in the B9 scoring driver only; the registered scorer is unchanged, deliberately.
- **Nothing here licenses a rung-up re-run at larger `n`.** With `H = 2` the next question is
  delivery, and E-004 already showed which mechanism decides selection.

## Amendment 1 — the log path, changed before any run, because the registered one would have scored every treated run a scope violation

*Amended by Opus 5 (claude-opus-5), autonomously, 2026-09-26, at §4 step 4 — **after the
prediction commit `ef2c6c0` and before any run of this experiment exists.** Nothing above is
rewritten; this section is the whole change.*

**What was registered.** The delivery proof and prediction 3 name
`.agent/knowledge-log.jsonl` — a file the router writes **inside the worktree under test**.

**Why it could not be that, read off the evaluator rather than remembered.** BE-003's
evaluator computes its changed-file set as `git diff --name-only "$BASELINE_SHA"` **plus**
`git ls-files --others --exclude-standard`
(`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/evaluator.sh:110-127`), and its
only ignore pattern is
`(^|/)(target/|\.mvn/|\.git/)|\.(log|class|jar)$|^(run|evaluation)\.json$`. Anything outside
`…/shipment/`, `…/api/` and `src/test/` is an AC7 scope violation and the run is scored
**exit 21** (`:279-296`). A `.jsonl` under `.agent/` matches no ignore rule, is untracked, and
would therefore be counted as an unrelated production file **on every treated run**. Making it
tracked in the overlay changes nothing: it would then appear in the `git diff` half instead.

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

**So the batch, had it run, would have recorded `H = 0`, fired decision-rule row 0 (E-022) / row 1
(E-023), and reported `VOID — an L3 instruction nobody acted on` about an agent that acted on it
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
  MDE inputs, the historical `maintainability` anchor-2 rates (BE-003 pooled 29 of 80; BE-004's
  floor 0 of 36) and B8's cost baseline. They are still the registered MDE — they are what was on
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
   **≥ 7 of 10** treated runs with the mechanism *"an L3 disposition can produce zero uptake"*, and
   E-022 row 0 / E-023 row 1 give `H ≤ 2` its own verdict. E-005's description arm — the case the
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

## Amendment 4 — the batch died twice, the deaths were the harness, and the throughput decision is recorded here before it was acted on

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-26, at the re-entry after the
context-guard stop. Nothing above this line is edited. This amendment covers both tasks; E-023
carries a pointer to it rather than a second copy.*

### Two deaths, two different causes, one shape

| batch | launched | died | cause | runs recorded | runs unrowed |
|---|---|---|---|---|---|
| `batch-20260926T133740Z` | 13:37:40Z | ~13:40Z, inside run 1 | `line 303: rv: unbound variable` — two manifest columns carried over from the b08 driver without their two `jq` reads, and `set -u` is fatal at the `printf` **after** the run | 0 | 1 (`6d728d76-5b1d-4b56-8e1f-154ea27ae82b`, documented in that batch's `ORPHAN.md`) |
| `batch-20260926T151319Z` | 15:13:19Z | 17:45:01Z, between a run and its row | the driver is a **child of the claude session that launched it**, and §0's phase-boundary rule requires that session to end | 4 (BE-003 pairs 01, 02) | 1 (`413bcf23-65f4-49d3-a789-c29b3dcf1b48`, BE-003 03 treated, eval 0, log complete) |

The second cause is the one worth carrying out of this stop. The `EXIT` trap fired — the pid lock
was gone — so the driver was terminated by a catchable signal, not by a crash: `set -uo pipefail`
has no `-e`, no unassigned local is read in that window, and the same code path had just completed
four times. **A batch launched from a session that the prompt obliges you to end is a batch the
prompt obliges you to kill.** That is a harness property, not a B9 property, and it applies to every
later stop whose §4 step 6 is longer than one session.

### The throughput decision — option (a), let it run at n = 10, and the reason is not stubbornness

The previous session recorded the choice as open, with three options and their costs. The evidence
that settles it arrived inside the run logs and was not available when the options were written:

- the paced window has **reset**. `rate_limit_event` in `BE-003-03-treated.log` at 17:45:01Z reads
  `"five_hour":{"utilization":0.02,"resetsAt":1790458200}` (= 2026-09-26T21:30Z) and
  `"seven_day":{"utilization":0.1}`. The window that produced 11–17 minute gaps reset at
  **16:30:00Z** (`resetsAt":1790440200`).
- the measured effect of that reset is in the manifest: BE-003 01 treated `durationMs` **5 420 000**
  (≈ 90 min, inside the saturated window), 01 control **160 000**, 02 treated **118 000**,
  02 control **123 000**. Runs after the reset are back to the 127 s the 12:48Z preflight measured.
- so option (b), reducing `n`, would forfeit prediction 1 (a one-arm binomial registered at ≥ 8 of
  10, unevaluable below n = 10, exactly as stop 17a's E-020 was) and E-023 row 0's verdict
  (`n_t < 7 or n_c < 7` ⇒ NOT COMPUTED) **to buy time the account has already given back**.
- and option (c) is not available: §7's claude bullet is *exhaustion that does not clear within one
  retry after its published reset time*. Nothing was ever refused — `status":"allowed"` on every
  event. This is `author_notes` material, and it is recorded there.

**Decided: (a). n stays 10 per arm per task.** *Decided by Opus 5 (claude-opus-5), autonomous,
2026-09-26.*

### What the pacing costs the experiment, stated rather than left to be inferred

`durationMs` is **excluded for every run that executed inside the saturated window**, and the run is
kept — the Exclusions section already registers exactly this treatment for a batch split by a
machine sleep, and a five-hour rate window is the same class of contamination: wall clock moves,
the model's work does not. Concretely that is BE-003 01 treated (5 420 000 ms) and, conservatively,
its pair partner 01 control. **No registered outcome reads duration**, so this removes nothing the
decision rule needs; it removes a number that would otherwise be quoted and be wrong. `cost`,
`modelCalls`, `toolCalls` and the router log are unaffected by pacing and are kept for all four.

### The orphan, and why it is replaced rather than recovered

`413bcf23-65f4-49d3-a789-c29b3dcf1b48` completed — evaluator ran, worktree kept, log complete — and
its manifest row was never written. Its data is all still readable from the API and the log, so a
row *could* be reconstructed by hand. It is not. The Exclusions section registers *"infrastructure
failures … → excluded, and a run excluded for infrastructure is replaced, so the scored `n` stays 10
per arm"*, `ORPHAN.md` applied that rule to `6d728d76` four hours earlier in the same stop, and a
hand-built row in a manifest whose every other row was written by the driver is a different kind of
evidence wearing the same clothes. **Excluded and replaced; the log, the worktree and the API record
are kept and are named here.** The cost it spent (~$0.14) is absorbed by author decision 13's
multiplier of **11** against a population of 10 — one pair of headroom is exactly what a replacement
needs, which is the first time that choice has been load-bearing.

### The instrument change, and what proves it

`run-b9-batch.sh` gained `--resume <TAG>`: it re-enters the **same** manifest, skips every
`(task, seq, arm)` cell already recorded in it, and **seeds the per-task cost** so decision 13's
ceiling still bounds the whole batch rather than its tail. Three refusals, all at **exit 13** and all
before the endpoints and the lock: no manifest at that tag; a manifest that does not register this
driver's corpus / agent / two `CLAUDE.md` shas; a manifest registering a different `n`.

`verify-b9-batch-guards.sh` goes 13 cases → **17, all passing**: N (no manifest), O (a different
registered corpus), P (`n` mismatch), Q (the skip set, the seeded cost, a `null` cost **not** summed
as zero, and the manifest byte-identical after a dry run). Q exists because the first version of the
resume code appended its banner *before* the plan-only exit and a dry run mutated a real manifest;
those three lines are kept in `batch-20260926T151319Z/manifest.tsv` with a correction beneath them
rather than deleted (§6). Case O's first version changed the hash only in the header comment, left
the real hash in the data rows, and **passed for the wrong reason** — a fixture reporting over a
scope smaller than it claims, the house failure mode arriving inside its own control; it is fixed
and the reason is a comment in the file.

Hand re-verification of a green check, as §6 requires: the driver seeded BE-003 at **$0.5830**;
`0.141425 + 0.149739 + 0.151752 + 0.140060 = 0.582976`, by hand, from the four manifest rows.

**The launcher, not the script, fixes the deaths.** The resumed batch is started in its own process
session (`python3 -c "os.setsid()"` — macOS has no `setsid`), so ending a claude session no longer
signals it. The script does not do this for itself: a driver that detached itself would also be a
driver no fixture could run in the foreground.

## Hand re-read — written 2026-09-26, BEFORE any scoring sheet for this batch exists

*§5: "At least one scored cell per step is re-read by hand off the kept worktree and the hand reading
is written down next to the sheet's value." Codex is refused until ~2026-09-30T16:29Z and
ollama-cloud is at its weekly limit, so no sheet for this batch exists yet — which makes this the
cleanest possible version of that rule: the hand value cannot have been anchored by a sheet, because
there is none. §4 step 7's ordering ("read the sheets only after you have written your own expected
score for at least one run by hand") is satisfied in advance rather than in retrospect.
Written by Opus 5 (claude-opus-5), autonomously, 2026-09-26.*

| field | value |
|---|---|
| run | `c49eec44-10fe-4996-ba2b-edd31e3a79e8` — BE-003, **treated**, seq 01, eval exit 0 |
| worktree read | `evidence.local/b09-worktrees/c49eec44-10fe-4996-ba2b-edd31e3a79e8` |
| rubric | `benchmark/rubrics/backend-quality.yaml`, `shasum -a 256 | cut -c1-12` = **`396e1799eb2b`** — the registered sha |
| cell | `maintainability`, the registered outcome of this stop |
| **hand value** | **2** |
| sheet value | *no sheet exists yet; this row is filled when codex returns* |

Anchor 2 reads (`backend-quality.yaml:160`): *"One `when (shipment.status)` in EXPRESSION position,
carrying no `else`. Expression position means its value is USED … Cite the `when`, the construct that
consumes its value, and the absence of `else`."* All three citations, from the changed files the run
record lists (`ApiError.kt`, `ShipmentController.kt`, `ShipmentControllerTest.kt`):

- the `when`, in expression position with its value assigned — `ShipmentController.kt:65`
  (`val updated = when (shipment.status) {`)
- three arms, `CREATED` / `CONFIRMED` / `CANCELLED`, and **no `else` anywhere in the file** —
  `ShipmentController.kt:66-71`, and `grep -n 'else'` over the whole file returns nothing
- the value consumed, not discarded — `ShipmentController.kt:74` (`val saved = repository.save(updated)`)

No ambiguity: no clause of anchor 0 holds and every clause of anchor 2 does.

**The reading was produced by a `sonnet` subagent (§4b) and then re-derived in the orchestrator's own
context off the same file**, because §4b requires exactly that of any delegated value that decides a
gate — a subagent misreading a sheet is the same failure as a control reporting over a smaller scope
than it claims. The `sed -n '60,78p'` and the `grep -n 'else'` were run by hand and agree.

**What this cell does and does not establish.** It is `n = 1` and it is stated as true of this run,
never as a property (§5). Its job is to be the fixed point the codex sheet is compared against when
codex returns: if the registered sheet scores this cell anything but 2, the disagreement is a fact
about the harness on a run whose diff has already been read, and §4 step 7 says to go to the diff
and say which fact was wrong.

## Amendment 5 — `H` counts router invocations, not corpus consultations, and on BE-003 the difference is one run and one word

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
| BE-003 02 | 1 | 1 (summary) | **1** | `router+direct` |
| BE-003 **06** | **0** | **2** (`index.yaml` + summary) | **0** | **`DIRECT-ONLY-invisible-to-H`** |
| BE-003 09 | 1 | 1 (summary) | **1** | `router+direct` |
| the other seven | 0 | 0 | 0 | `no-contact` |

So **router invocations are 2 of 10 and corpus contact is 3 of 10.** Run 06 listed
`.ai/knowledge/`, read `index.yaml`, read the summary the index names, and never ran the command
the `CLAUDE.md` clause gives it.

### Why it does not change the verdict, and why that is the right answer rather than a convenient one

`H` was registered **before any data**, in this file, as the log being non-empty. §6 and §4 step 12
forbid editing a prediction, a decision rule or a registered definition after its run, and
*especially* when the edit would change the verdict. So `H = 2 of 10` stands and row 0 stands.

**It is worth stating exactly what the other reading would have done**, because a reader who cannot
see that has to take this paragraph on trust: had `H` been registered as *the run consulted the corpus*, it
would read **3**, row 0 would not fire, and row 3 (`H ≥ 3` and `M ≤ 5`, with `M = 5`) would — a
**`REJECT`** whose §4 step 10 disposition is to **remove** the corpus from the overlay. **The
verdict turns on one run and on one word.** That is written down here so a later reader weighs the
registered `VOID` knowing what the alternative definition gave, rather than discovering it.

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
