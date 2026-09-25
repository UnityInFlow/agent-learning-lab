# Experiment E-020 — Decomposition depth on BE-005

**Spine stop 17a (B8a). Task `BE-005-partial-fulfilment`, ticket A′, ONLY.** Version-neutral, measured
against v1.1 as it closed at B8. Registered by author decision 11; the cut is the author's, from
`B8A-BRAINSTORM.md` Q1–Q8.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-25T07:05:00Z; the author did not review
before the run.`

**Nothing below is edited after a run.** A prediction that turns out wrong stays recorded as wrong.

## Question

On a task where an early structural choice is punished by a later clause of the same ticket, does
splitting one agent into **planner → implementer → verifier** behind a routing orchestrator change what
gets built — and if it does, can this instrument say so?

## Hypothesis

The pinned model fails BE-005 by **committing to a shape before it has enumerated the read paths**:
Gate B′ found it filtering or counting a *stored* fulfilment value on **4 of 5** plain runs, where the
one passing run recomputed first (`map` before `filter`). A planner that **cannot type** must spend its
turn enumerating rather than implementing, and the enumeration — per read path, stored or computed —
is written into the handoff before any file is edited. If the fork is lost to haste rather than to
ignorance, the split should move the shape. If it is lost to the model not knowing that a stored
fulfilment field is a trap, the split should move nothing, because **no agent in the pipeline is told
anything about fulfilment** (Q6 option A, method only).

## Predictions

Each has a **direction**, a **magnitude** and a **mechanism**. P1 is the registered outcome; P2–P4 are
registered secondaries; P5–P7 are reported rows that decide nothing.

**P1 — registered outcome. `architecture-consistency` (codex, rubric `945817b8c509`) is HIGHER in the
treated arm, median 2 against a control median of 0, on gate-passing runs.**
*Mechanism:* the anchor-0 clause fires when *"an order-side field holds a fulfilment status, an
allocated count or a delivered count, AND a method in the shipment package writes it."* A planner
that has written down "computed, in the order package" cannot hand an implementer a stored-write plan.
*Magnitude:* a two-step move on a 0/2 scale, i.e. the whole dimension.
***And I predict this prediction cannot be measured, for a reason that is registered here rather than
discovered afterwards — see the MDE table. I expect P1 to come back at `n < 5` per arm and therefore to
be reported as "true of these runs" and never as a property (§5).*** Registering an outcome I expect to
be unmeasurable is not a hedge: the outcome is the author's to set, the population is not mine to
choose, and saying so before the batch is the only honest form.

**P2 — evaluator pass rate rises, and this is the row that can actually carry a verdict. Treated
`≥ 8 of 10` against a control I predict at `2 of 10`.**
*Mechanism:* the evaluator returns 12 on the wrong shape and 0 on the right one, so pass rate *is* shape
on this ticket. *Magnitude:* 8/10 vs 2/10 is Fisher two-sided **p = 0.0230**; 7/10 vs 2/10 is
**p = 0.0698** and would not clear 0.05. So the registered threshold is **8 of 10**, chosen from the
arithmetic and not from hope. *Why this is not the registered outcome:* it is an exit code, and decision
11 item 10 puts the registered outcome in a rubric category. It is the strongest thing the instrument
will have, and it is registered as a secondary with that said out loud.

**P3 — the shape classification moves. Treated reaches the derived shape on `≥ 8 of 10`, control on
`2 of 10`.** *Mechanism:* the same as P2, read from the diff instead of the exit code, by
`evidence/gate-b2-decision-11/RULE.md` — a rule **committed before any B8a run existed**, which is why
it can be applied to this batch without being fitted to it. *Magnitude and threshold:* identical to P2.
*Why both:* P2 and P3 should agree, and **a disagreement between them is more informative than either**
— it would mean the evaluator and the diff disagree about what was built.

**P4 — every treated run shows exactly 3 or 5 delegation events; no treated run shows 4, or 6 or more.**
*Mechanism:* cut B is sequential by construction and Q8 allows exactly one bounce. *Magnitude:* 10 of 10,
and **1 of 10 outside {3, 5} is a finding, not noise.** *This is the prediction I expect to be wrong*,
and it is registered as such: "one bounce" is **L3** — nothing counts delegations, and B8's repair limit
counts repair attempts per failure fingerprint, a different quantity. A model asked in prose to bounce
once may bounce twice.

**P5 — cost, reported, never a verdict. Treated `estimatedCost` is 2–4× the control's.**
*Mechanism:* four agents, each with its own context, plus the orchestrator's routing turns. *Magnitude:*
control median expected near ticket A′'s **$0.388**; treated **$0.78–$1.55** per run. Decision 11 item 10
says cost is expected far outside any band and is a reported row.

**P6 — `modelCalls` rises by more than the delegation count alone explains.** Control median expected
near **43** (Gate B′). Treated **≥ 90**. *Mechanism:* each delegation is a fresh context that re-reads
the ticket and the tree.

**P7 — co-variate, and the thing that will interpret a null. The treated arm's `handoff.delivered`
contains a per-read-path stored-or-computed table on `≥ 8 of 10` runs.**
*Mechanism:* the planner is asked for exactly that and cannot do anything else with its turn.
*Why it exists:* the method prose is L3 and nothing observes compliance, so **a null on P1–P3 cannot
distinguish "the split returned nothing" from "the prose was not followed."** This row separates them,
it costs nothing — the handoff is on disk in every kept worktree — and **it enters no decision-rule row.**

## Independent variable

**One configuration, and it is a compound one, stated plainly.** The treated arm installs
`build/customizations/b8a-pipeline-v1.0/` — four agent files — and is dispatched with
`--agent orchestrator`. The control installs **nothing** and runs plain.

So the arms differ by **a split, three `tools:` lists and two bodies of method prose, simultaneously**.
That is what decision 11 registered, and the consequence is registered with it: **a positive result
names the configuration and cannot apportion the effect.** E-007 → E-008/E-009 is the precedent — rung 2
looked null and a fourth cell was needed to show the one visible effect was prose with no split at all.
No fourth cell is registered here, so that ambiguity survives this experiment by construction.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | overlay directory `build/customizations/b8a-pipeline-v1.0/.claude/agents/{orchestrator,planner,implementer,verifier}.md`, installed by the runner's `--customization`, dispatched with `--agent orchestrator` |
| Content hash | `customization.agentHash` covers **the orchestrator file only** (`run-agent.sh:609-611`, `:625-629`). **Three of the four files are files no hash sees.** Registered sha filled at §4 step 4 |
| Preflight assertion | Decision 11 item 9, **all four, per run, before scoring**: (a) `git ls-files` in the kept worktree lists every overlay file — *not* the file merely being present; (b) `customization.agentHash` equals the orchestrator's registered sha; (c) the `init` read-back shows `Task` in the orchestrator's delivered tool set; (d) telemetry shows at least one delegation event naming each of the three specialists |
| Control assertion | `customization.instructionsHash`, `skillsHash` and `agentHash` all **`null`**, read from the control's own run records — structure, not a flag |
| Row 0a | A run missing any of the four is **void before scoring**, exactly as E-007 registered. **Row 0a on 2 or more treated runs ends the step early** (item 11) |

**The `init` read-back is not optional and it can void a layer label.** E-005 found the runtime
*rewrites* `tools:` before the model sees it — `Read, Grep, Glob, Bash` delivered as `["Read","Bash"]`
on 10 of 10. Author decision 8 makes the read-back mandatory. If a specialist's list arrives rewritten,
**that agent's label drops from L2 to L3 in the workbook and the list is not edited until the label
fits.**

## Controlled variables

| Variable | Value, and how it is checked |
|---|---|
| Model | `claude-haiku-4-5-20251001`, **all four agents**, both arms. Read from `runtime.model` per run, not from the flag. Four agents are four chances for a silent substitution: `CLAUDE_CODE_SUBAGENT_MODEL` sits above a subagent's own `model` field (`SOURCES.md` row 220), and **no agent file sets `model`** |
| Runtime | `claude`. Cross-arm quality claims against any other runtime stay blocked |
| Benchmark | `BE-005-partial-fulfilment` at benchmarks `main`, sha recorded per run |
| Evaluator | **version `1.0.0`** — the string `evaluator.sh:58` sets and emits into every run record. `benchmark.yaml:10` *declares* `1.1.0`; that declaration **does not execute**, so by the layer rule it is L3 and is not the version of record. The disagreement is in `TRACK-B-STATE.md` `author_notes` and is the author's to repair |
| Rubric | `benchmark/rubrics/backend-quality-be005.yaml`, version `2-be005`, sha **`945817b8c509`**, asserted on every sheet |
| Scorer | **codex** is the registered scorer (Decision C); opencode/`deepseek-v4-pro` is the second reader and not a vote. Decision H is **unfired** |
| Flags | `KEEP=1 ISOLATE_USER_SETTINGS=1`, `--keep`, never `--bare` |
| Interleaving | Runs alternate control/treated so a drift in the service, the API or the model hits both arms alike |

## Runs

`n = 10` per arm, **two arms, one task**, interleaved, plus **one preflight run per arm** under its own
probe key before the batch. **Cost ceiling $9.70** = 25 × $0.388 (decision 11 item 11; the median is
ticket A′'s, from `evidence/gate-b2-decision-11/RESULT.md:38`, **not** the $0.34 that was Gate B round
1's median on ticket A — the ticket that failed 2 of 5 and was redesigned away). **The batch stops when
the ceiling is reached and the population that occurred is reported**, as E-016 did at `n = 7`.

**Ends early, with the negative recorded** (item 11): Gate B failed twice · a preflight that cannot show
all four delivery conditions · row 0a on 2 or more treated runs.

## Minimum detectable effect

**Transferred, and it says so.** BE-005 has no stored population, so the MDE comes from **Gate B′'s five
runs on ticket A′** plus the preflight pair, exactly as decision 9 item 3 and E-011 did for BE-004, and
is **re-derived from B8a's own control** for anything that follows.

**The spread it transfers from** (`evidence/gate-b2-decision-11/RESULT.md`, `n = 5`, stated as true of
those five runs and not as a property): wrong shape **4 of 5** · evaluator exit 12 on 4, exit 0 on 1 ·
cost median **$0.388** (0.330–0.426), total $1.95 · duration median **230 s** (188–273) · **43** model
calls · 10–13 files changed.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| **primary: `architecture-consistency` median, gate-passing runs** | no spread exists — BE-005 has never been rubric-scored on a run | ***none computable.*** With a control pass rate of 1 of 5, the expected gate-passing population is **≈ 2 of 10 per arm**, and Decision D scores only gate-passing runs (`check-run-gate.sh:6`). At `n = 2` **no rubric effect is detectable at any size** | **yes — registered as expected-unmeasurable, with the arithmetic** |
| secondary: **evaluator pass rate**, all 10 runs | 1 of 5 on Gate B′ | against a control at 2/10: **8/10 → p = 0.0230**; 7/10 → 0.0698; 6/10 → 0.1698. Against 1/10: 7/10 → 0.0198. **Registered threshold: 8 of 10** | yes |
| secondary: **shape classification**, all 10 runs | 1 of 5 right on Gate B′ | identical arithmetic; **threshold 8 of 10** | yes |
| secondary: **delegation count in {3,5}** | none — one-arm | one-arm binomial, **no control needed**; 10 of 10 expected, **1 outside is a finding** | yes |
| reported: cost, `modelCalls`, duration | $0.388 (0.330–0.426), 43 calls, 230 s | no threshold; cost is expected far outside any band (item 10) | yes, as reported rows |
| reported: **`handoff` table present** | none — one-arm co-variate | 8 of 10; **enters no decision-rule row** | yes |

**The consequence, written now.** The registered primary is very likely to be **unmeasurable**, and the
step's verdict will therefore rest on **secondaries that are exit codes and diffs**. That is not a
degradation I chose — decision 11 item 10 places the registered outcome in a rubric category, the
author's decision of 2026-09-25 names which category, and Decision D restricts scoring to gate-passing
runs. **All three are right individually and they compose into an instrument that cannot see its own
registered outcome on a task the model usually fails.** *That composition is itself a finding* and is
reported as one at the exit gate, whichever way the numbers go.

**`change-focus` is `unmeasured`** (author's decision of 2026-09-25 item 1) and reads **nothing** — no
row above, no MDE, no exit-gate answer. Its 15 % weight carries no measurement, so **BE-005's weighted
total is 85 measured points on a 100-point scale and is NOT comparable to BE-004's.** Any row reading it
is recorded *"unmeasured — author decision 2026-09-25 item 1"* rather than computed, in the same words
decision 10.3 uses. **`test-quality` anchor 2 is UNREACHABLE** in the fixture proof — no fixture's tests
call the amendment endpoint — so **no claim is made about anchor 2 in either direction.**

## Deterministic evaluation

`tasks/BE-005-partial-fulfilment/evaluator.sh`, version **`1.0.0`**, BE-003's exit-code contract, two
evaluator-owned suites, `verify-evaluator.sh` **re-run on a clean `main` at 17 of 17**. Exit 0 = passed,
12 = failed on the late clause. The evaluator is **identical in both arms** and is the measuring
instrument, not the treatment.

## Exclusions

- A run missing any of the four delivery conditions: **row 0a, void before scoring.**
- A run that crossed a machine sleep: **duration excluded, the run kept** (§4 step 6).
- A preflight or deliberate-failure run: excluded by name, never pooled into an arm.
- **Nothing is excluded for its result.** A treated run that fails the evaluator is data.

## Decision rule

Registered before the batch. Rows are evaluated **in order**; the first that fires is the verdict.

| row | fires when | verdict |
|---|---|---|
| **0a** | a treated run misses any of the four delivery conditions | that run is **void before scoring**; **2 or more ends the step** |
| **0b** | the cost ceiling of $9.70 is reached before `n = 10` per arm | the batch stops; **the population that occurred is reported**, as E-016 did at `n = 7` |
| **1 — VOID** | the treatment cannot be shown delivered on a majority of treated runs, or `runtime.model` is not the pinned id on any run | **VOID.** No comparison is computed |
| **2 — IMPROVED** | evaluator pass rate **and** shape classification both reach **≥ 8 of 10** against a control at ≤ 2 of 10 (p ≤ 0.05 by Fisher), **and** no regression in any measured rubric category on whatever population clears the gate | **IMPROVED.** The ladder stays open and rung 10 becomes proposable — *as a separate author decision, never as a consequence of this one* |
| **3 — REJECT** | either rate is **lower** in the treated arm at p ≤ 0.05 | **REJECT.** The split is removed and the removal is the finding |
| **4 — NOT DETECTABLE** | neither rate separates at p ≤ 0.05 | **NOT DETECTABLE**, at the registered `n`, with the MDE quoted beside it. **The ladder CLOSES and that closure is the result** (item 2) |

**Promotion is a different question and is not answered by any row above.** It is decided **only** by
B13's seven clauses, verbatim (item 6), with `quality_score` read as the weighted rubric total **with
the `change-focus` exclusion named in the same sentence as the number**, and
`tokens_per_accepted_task` as `estimatedCost` per evaluator-passing run against the concurrent control.
A pipeline at 2–4× the cost must clear a **15 %** token ceiling, so the **expected outcome is measured,
kept, NOT promoted** — and that is a useful result, with B7 as its precedent.

## Deliberate failure — prediction registered before it is built

**The same four overlay files with `Task` removed from the orchestrator's `tools:` list** (Q5). Five
runs.

**Prediction:** the `init` read-back shows **no `Task`**, telemetry shows **zero** delegation events,
and **5 of 5** runs are classed **row 0a — void before scoring**. *Mechanism:* it attacks the one
delivery condition that is about **capability** rather than file presence, and E-005 showed this exact
failure is easy to produce by accident. **If any run of it shows a delegation event, the delivery proof
is not a proof** and that is a far more important result than the experiment it was built to check.

### Budget, overlay and instrument — decided at §4 step 9, before a dollar was spent

*The prediction above is unchanged. Nothing below rewrites it; it records what the prompt left to the
builder (§4 step 9 registers no budget) and what was built to run it.*

**`n = 5`, not 3.** §5 forbids stating an `n < 5` result as a property, and the prediction is stated as a
property — *"5 of 5 runs are classed row 0a"*. At `n = 3` a clean sweep could only ever be reported as
"true of these three runs", which does not answer the clause the deliberate failure exists to test.
**Cost estimate:** the registered treated arm's median run is **$0.7149** (`evidence/b08a/REPORT.md`),
and a run whose orchestrator cannot delegate opens **no subagent context at all**, so it should cost
*less*, not more; five runs are estimated at **under $3.60** and expected nearer $2.
**Ceiling: $4.00**, enforced by the driver (exit 11) over `efficiency.estimatedCost` read from the run
record, by the same `awk` expression the registered batch used — not a number in a workbook.
This changes no registered variable, no arm and no task, so it is not a §7 halt.
`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-25`

**The overlay is new; the measured one was not touched.** `build/customizations/b8a-pipeline-v1.0-notask/`,
four files. `diff -r` against `b8a-pipeline-v1.0` returns **exactly one changed line**:

```
4c4
< tools: Read, Grep, Glob, Task
---
> tools: Read, Grep, Glob
```

`planner.md`, `implementer.md` and `verifier.md` are **byte-identical** (`7c78bf7fed65034ec418e3b0952a3e10`,
`2c0ccfcd87ddfeee96e5a6d21b6343f1`, `d67594e21df41f6a1adc6d67f0630a57` in both). The orchestrator's sha
moves `1f27323694e579ec11dbca026bfbb326` → `c0c5aab3e7d469ded7227b8f57280004`; the registered overlay
still hashes to the first, which is the `EXPECT_AGENT_HASH` the registered batch enforced.

**The registered batch driver refuses this overlay, and that was executed before any run.**
`run-b8a-batch.sh:118-120` requires `Task` on the orchestrator's `tools:` line; pointed at the broken
overlay in guards-only mode it returned **exit 6**, recorded verbatim at
`evidence/b08a/deliberate-failure-guard-refusal.txt`. The deliberate-failure overlay could not have
entered the registered population by accident. **That is an L2 result of this step in its own right**,
and it is the reason the runs below need a separate driver rather than a flag.

**The driver: `evidence/b08a/run-b8a-deliberate-failure.sh`**, single arm, probe key
**`EXP-B8A-DF-NOTASK`** — never `EXP-B8A-DECOMP-BE005`, and excluded by name from both registered arms.
Its Task guard is **inverted**: it refuses an overlay that *can* delegate (exit 6), because running the
registered treatment under the probe key would read as a refutation of the deliberate failure and is the
worst error available at this step. ShellCheck clean.
**Fixture set `evidence/b08a/verify-b8a-deliberate-failure-guards.sh`, 12 of 12**, no run made and no
money spent: A happy path 0, B missing specialist 6, C wrong orchestrator hash 6, **D the registered
overlay refused 6**, E an edited specialist 6, F a `CLAUDE.md` 6, G a `SKILL.md` 6, H a pinned `model:` 6,
I a dead API 7, J a held lock 8, K the ceiling at $4.00 → 11, L $3.99 → 0. **Case D was re-derived by
hand** (§6: when a check goes green, re-verify one of its cases): the refusal line is
`this orchestrator CAN delegate — that is the registered treatment, not the deliberate failure`, so it
refuses on the inverted guard and not on a hash mismatch.

## Observed telemetry

To be filled after the batch. **`OTLP_GRPC_PORT` is passed and `events.jsonl` is checked for growth
before any telemetry-sourced number is trusted** (stop 11's rule). The observatory API is
**`127.0.0.1:8081`** — *not* `18081`, which no longer exists.

## Results · Which predictions held · Failure analysis · Sanity checks · Decision · Follow-up

To be filled from evidence, after the runs, in the main context and never from a subagent's summary
alone. At least one scored cell is **re-read by hand off the kept worktree** with the hand reading
written beside the sheet's value (§5).

---

## The F13 decision — control 07, decided at §4 step 7 with its reason, both populations reported

*Belongs beside "Exclusions" above and is appended here rather than inserted, so that nothing registered
before the batch moves. `Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-25.`*

**The run:** `ed58787c-6529-42ce-a677-065d86945bc2`, control, pair 07.

**What is different about it, re-derived by `evidence/b08a/rederive-f13.sh` and written to
`evidence/b08a/batch-20260925T091510Z/f13-rederived.tsv`:**

| | control 07 | every other run of the sixteen |
|---|---|---|
| HTTP 529 lines in its log | **47** | 0–10 |
| duration | **3 751 s** | 198–1 307 s |
| `modelCalls` | **11** | 23–222 |
| files changed | **1** | 11–15 |
| the one file | `api/ApiExceptions.kt`, **+4 lines** — an exception class and nothing else | order and shipment packages |

**The decision, in four parts, each with the rule it follows:**

1. **The run stays in the population.** `Exclusions` above admits exactly three grounds and this is none
   of them; *"nothing is excluded for its result"*. Dropping a run because the network throttled it is
   still choosing a population after seeing it. **Control `n` stays 8 for the registered rate.**
2. **Its duration is excluded.** §4 step 6, verbatim: *"if a run's duration looks contaminated, say so
   and exclude duration, not the run."* 3 751 s is 13× the control median and measures the 529s.
3. **Its cost is excluded from the cost spread, and both spreads are printed.** $0.0934 is not what an
   attempt at this ticket costs; it is what 11 throttled calls cost. Cost is a reported row that decides
   nothing, so the honest form is both numbers: control cost median **$0.391 (0.093–0.504, n = 8)** and
   **$0.399 (0.279–0.504, n = 7)**.
4. **For shape it is `NO-ATTEMPT`**, which is not a judgement call but the classification rule's own
   category — `evidence/gate-b2-decision-11/RULE.md` puts `NO-ATTEMPT` (no production edit) **in the
   denominator only**. It touched no order, shipment or fulfilment logic.

**Both populations, from `evidence/b08a/tally.py`:** evaluator pass rate treated **7 of 8** against
control **3 of 8** → Fisher two-sided **p = 0.1189**; without control 07, treated **7 of 8** against
**3 of 7** → **p = 0.1189**. **The decision costs the verdict nothing: the p-value is identical to four
decimal places either way.** That is worth saying plainly, because it means no reader has to trust this
decision in order to trust the result.

## Observed telemetry

**`events.jsonl` GREW, so telemetry-sourced numbers are admissible under stop 11's rule:**
18 381 324 bytes at the batch's launch → **24 019 420 bytes** (re-measured 2026-09-25T13:53Z,
`agent-observatory/infra/telemetry-out/events.jsonl`). Growth **+5 638 096 bytes** over the batch.

**Delivery, all sixteen runs, from the manifest and re-tallied by `evidence/b08a/tally.py`:**
row 0a fires on **0 of 8** treated runs — `cond_a`/`cond_b`/`cond_c` `ok` and `cond_d`
`ok-stream-3of3` on every one; all **8 of 8** control runs carry `agentHash`, `instructionsHash` and
`skillsHash` all `null`; `runtime.model` is `claude-haiku-4-5-20251001` on **16 of 16**. **Decision-rule
row 1 (VOID) therefore does not fire.**

**Delegation counts, and the two sources do not agree on two runs.** The agent stream and the telemetry
query both answer P4, and the manifest carries both columns deliberately. They agree on **6 of 8**
treated runs and disagree on exactly the two runs that are also outside `{3, 5}`: pair 03
`stream = 12, telemetry = 15` and pair 07 `stream = 8, telemetry = 6`. **On the six runs inside `{3, 5}`
the two sources agree exactly.** P4's own registered source is the stream (`cond_d = ok-stream-3of3`),
so the stream is the number of record and the disagreement is reported beside it rather than averaged
away. *That the two instruments diverge only on the runs that bounced more than once is itself a fact
about the instruments, not about the treatment.*

The observatory API is **`127.0.0.1:8081`**, probed this session; it answered every fetch.
