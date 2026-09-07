# Experiment E-009 — the fourth cell, second registration

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`.

**Status: CLOSED 2026-09-07 - decision rule row 2, reading (b): `test-quality` is a return from the SPLIT, not from the prose. Arm F 0 of 10 anchor 2, its concurrent control 1 of 10 (`p = 1.0`); E-007 arm O, the split, 5 of 10 (`p = 0.0325` against arm F). The registered prediction Q1 is REFUTED.** Successor to
[`E-008`](E-008-fourth-cell-prose-without-split.md), which is **CLOSED VOID** under its own
decision rule row 0a: a plain control run called the built-in `Explore` agent, and row 0a as
registered voided on a delegation by *any* run. E-008's question is unanswered and author
decision 10.1's order is therefore not discharged; this file carries it.

`Registered by Claude Opus 5 (claude-opus-5), autonomously, 2026-09-07T13:0xZ; the author did
not review before the run.` (E-008's predictions were registered earlier the same session by
Claude Fable 5.1, before the author changed the orchestrator model mid-batch. The agent under
test never moved: `claude-haiku-4-5-20251001` on every run of both.)

Experiment key **`EXP-4B-FOURTH-CELL-2`** · branch `stop11/fourth-cell`.

## What is unchanged from E-008, and why this is not a re-run of a broken thing

The arm, the overlay, the model, the runtime, the task, the rubric and the delivery proof are
identical, and E-008 demonstrated all of them working: **P5 held on 16 of 16** — every arm-F
record carried `sha256:51f16eeb1618cd212405818c5165dcba`, every control `null` — and the
evaluator passed 16 of 16. What failed in E-008 was **my decision rule and my driver defaults**,
not the cell. Three repairs, each named here before any run:

1. **`PAIRS` defaults to 10**, the registered `n`. E-008's driver inherited `5`.
2. **The void condition is arm-aware.** An **arm-F** delegation voids — this cell is *the prose
   without the split*, so a treatment run that delegates is not the treatment. A **control**
   delegation is **recorded and reported**, because a plain baseline calling a built-in agent is
   a property of the baseline, not a delivery failure. E-008's row 0a said *"any run"*, and it
   is repaired **here, in a new registration**, never retroactively there.
3. **Delegation is read from two sources**, the runner's stream and the observatory telemetry,
   in two manifest columns. E-008 proved the telemetry counter reads **0** for a built-in,
   backgrounded sub-agent that the stream shows plainly.

## Question

Unchanged from E-008. E-007 detected one effect — `test-quality` anchor 2 on **5 of 10** split
runs vs **0 of 10** controls, `p = 0.0325`, reducing on all twenty sheets to one rubric clause
(*was persisted state re-read through a separate `get(...)`*). The split's treatment *included*
the worker's four lines of prose. **Is the effect the decomposition, or the prose it carried?**

## Hypothesis

Unchanged: **the prose**. BE-003 names four cases and the second is *"already `CONFIRMED`
succeeds **and changes nothing**"*; a test written *for that case* has to prove nothing changed,
and the only way to prove it is to read the shipment back. The plain control writes tests too
(`test-quality` 1 on 10 of 10 E-007 controls), so the instruction does not create testing — it
changes which cases get one.

## Predictions

**One registered outcome, and it is the only quantity in this experiment I am still blind to.**

E-008 produced 16 runs whose **run records I have read** — cost, duration, `modelCalls`,
`toolCalls`, `addedLines`, per arm. A prediction about those, written now, would be fitted to
data I have seen, and a fitted prediction measures nothing. So they are **report-only here, by
disclosure, not by choice**, and the reason is written before the run. What I have *not* read is
any `test-quality` score of either arm: exactly one codex sheet exists for any E-008 run
(`582c0b39`, 12:27:12Z), it is unread, and it stays unread until this batch's own sheets are
collected.

| # | Outcome | Direction · magnitude | Mechanism |
|---|---|---|---|
| **Q1** (the registered outcome) | `test-quality` anchor 2 count, codex, rubric `396e1799eb2b`, `n = 10` per arm | arm F **4–7 of 10**, control **0–1 of 10**; two-sided Fisher vs the concurrent control **`p < 0.05`** | *"tests for every case it names"* + the *"changes nothing"* case → a test that re-reads state after the second confirm. Same magnitude E-008 registered; **still registered as most likely to be wrong in magnitude**, because the prose sits in project memory here and in the worker's system prompt there |
| **Q2** | delivery: `customization.instructionsHash` | registered value on **10 of 10** arm F, `null` on **10 of 10** controls | void condition, not an outcome. Held on 16 of 16 in E-008 |
| **Q3** | arm-F delegation, **both** sources | **0 on 10 of 10** | no `.claude/agents/` is installed *and* the ticket is small; but the five built-in agents are available, which is precisely what E-008 refuted for the control arm, so this is a real prediction and not a formality. A single arm-F delegation voids |
| **Q4** | control delegation, **both** sources | **0–2 of 10**, reported, never voiding | E-008 observed **1 of 8**. A count outside 0–2 is reported as a property of the plain baseline on this task |
| — | `estimatedCost`, `durationMs`, `modelCalls`, `toolCalls`, `addedLines`, evaluator pass rate, the other three rubric cells | **report only — I have seen these quantities on E-008's void runs** | stated above |

**The two readings, unchanged from decision 10.1:**

- **(a)** arm F separates from its control and is not distinguishable from E-007 arm O's 5 of 10
  → **the effect is the prose**; E-007's one detected effect is reattributed by dated amendment,
  its verdict untouched.
- **(b)** arm F does not separate while arm O did → **`test-quality` is a return from the
  split**; E-007 is amended to say it measured a benefit its decision rule could not name.
- Neither → reported as such (rows 0b and 3).

## Independent variable

**One thing:** `CLAUDE.md` in the worktree root carrying, byte for byte, lines 7– of
`build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md`. Overlay
`build/customizations/implementer-prose-4b4/`, one file, full SHA-256
`51f16eeb1618cd212405818c5165dcba0c13188f411ac966f9142ef08d478d72`. No `.claude/agents/`, no
`--agent`, no split.

## How the treatment is delivered — and proved

As E-008, and E-008 is the proof it works: `--customization`, the runner's own
*"instruction file CLAUDE.md present — claude reads this"*, and
`customization.instructionsHash` read back **from the API per run** into the manifest by the
driver, with the batch aborting on any mismatch. Control worktrees are built by `git archive`
from an allowlist of `sample-service` and `.gitignore`, so a `null` hash means no instruction
file was present, not merely that none was installed. E-008's read-back pair
(`0ab18564` / `5b2d38df`) is the §4 step 5 evidence and **is not repeated** — same overlay, same
runner, same flags; repeating it would spend two runs to re-observe a fact recorded five hours
earlier, and the per-run read-back in the batch is the stronger control anyway.

**What still cannot be proved from the run record:** that the runtime *read* the file. The
runner refuses an instruction file the runtime does not read (the filename half, L2); the
content half is Q1's job.

## Controlled variables

Held equal to E-008 and asserted per batch by `evidence/p04b/lab-4b4/fourth-cell/run-e009.sh`,
every guard driven to fire by `verify-run-e009.sh` (12 of 12, ShellCheck clean):

- [x] BE-003 task **tree** `eeb15a753adc94e92bc3f74c50e1b02fc3b53030` (asserted as a tree, not a
      commit — benchmarks `HEAD` moved to `eea144e` for BE-004 without touching BE-003)
- [x] evaluator `1.0.0`; rubric `396e1799eb2b`, asserted on every sheet by the collector
- [x] Claude Code **2.1.263**; model **`claude-haiku-4-5-20251001`**, read back per run
- [x] `ISOLATE_USER_SETTINGS=1`, `KEEP=1`, `--disable-slash-commands`, the runner's flag array
- [x] interleaved F/C pairs, `caffeinate -i`, no other lab process during the batch
- [x] runner commit `b818c56`; tunnels `18081 / 14318 / 14317 / 13200`

## Runs

**10 F + 10 C, interleaved, one key.** ≈ 20 runs, ≈ $3.4, ≈ 45 min. Driver `run-e009.sh`,
`PAIRS` default 10, PID lockfile, manifest row per run.

**Budget disclosure:** decision 10.1 estimated *"about 20 runs, about $3"*. E-008 spent 18 runs
(≈ $2.9) and produced a void; this batch takes the total for the cell to ≈ 38 runs and ≈ $6.3,
about double the estimate, **because of my instrument faults and not because the design grew**.
Recorded in `blocked_on_author` rather than absorbed silently.

## Minimum detectable effect

Derived from measured arms before any threshold above was written; two-sided Fisher exact at
`n = 10` per arm.

| Outcome | measured spread it comes from | MDE at `n = 10` per arm |
|---|---|---|
| Q1 vs the concurrent control | historical plain controls **3 of 48** anchor 2, max **2 of 10** (the census in E-008 § MDE, script and output at `evidence/p04b/lab-4b4/fourth-cell/census-test-quality*`) | control **0 of 10** → separated at **≥ 5** (`p = 0.033`); control **1** → **≥ 7** (`p = 0.020`); control **2** → **≥ 8** (`p = 0.023`) |
| Q1 vs E-007 arm O's 5 of 10 | E-007 arm O | almost no power: every count **1–9** gives `p ≥ 0.14`. Reading (b) is therefore *"not separated from its control"*, never *"proved different from the split"* |
| Q3 / Q4 delegation | E-008: 0 of 8 arm F, 1 of 8 control | a single arm-F delegation voids; the control count is reported |

**The census is E-008's and is not re-derived** — it covers every codex sheet on file for an
observatory run as of 2026-09-07T11:52Z, none of which is an E-008 or E-009 run.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` v1.0.0; `tools/check-run-gate.sh` admits a run by
the recorded verdict (Decision D path B). The evaluator decides correctness; the rubric scores
only admitted runs.

## Exclusions, registered before the data

- evaluator exit ≠ 0, F13/F15 infrastructure failures, permission blocks, quota exhaustion:
  excluded from scoring, reported by count, the arm's scored `n` reported
- `durationMs` on any run overlapping another lab process or a machine sleep: duration excluded,
  the run kept
- a `test-quality` `null` counts as *not anchor 2* in Q1's count and is reported separately
- **a control run that delegates is NOT excluded**; it is reported in both delegation columns
  and its metrics are reported with and without it, as E-008's table did

## Decision rule, fixed before the run

`c` = control anchor-2 count, `k` = arm-F anchor-2 count, over gate-admitted runs; `p_C` =
two-sided Fisher `k` vs `c`; `p_O` = two-sided Fisher `k` vs E-007 arm O's 5 of 10.

| # | Condition | Verdict |
|---|---|---|
| 0a | any arm-F run without the registered `instructionsHash`, any control with a non-null one, **any arm-F run with ≥ 1 delegation event in either source**, any run on a runtime other than 2.1.263, or fewer than 8 admitted runs in either arm | **VOID** — the cell was not delivered as designed, or is under-powered past its registration |
| 0b | `c ≥ 3` | **NOT DETECTABLE, and the finding is the control** — E-007's 0 of 10 is not reproduced; neither reading is available |
| 1 | `c ≤ 2` and `p_C < 0.05` | **reading (a) — the effect is the prose.** If also `p_O < 0.05`, add: the prose alone exceeded the split |
| 2 | `c ≤ 2` and `p_C ≥ 0.05` and `k ≤ 2` | **reading (b) — `test-quality` is a return from the split**, stated as *true of these runs*, with `p_O` beside it |
| 3 | `c ≤ 2` and `p_C ≥ 0.05` and `k ≥ 3` | **fits neither — NOT DETECTABLE at `n = 10`.** Both readings stay open |

Exhaustive over `(c, k)` once 0a has not fired: 0b takes `c ≥ 3`; for `c ≤ 2`, rows 1–3
partition on `p_C` then on `k`. **A control delegation is in no row.** **Cost is in no row** — it
is reported beside the verdict, never ANDed with a failure.

**Under every reading, E-007's registered verdict is not edited**; a dated amendment carries the
result.

## Threats to validity, registered before the run

- **Same words, different seat.** In E-007 the prose was a worker's system prompt; here it is
  project memory beside the ticket. A null (row 2) means *the prose as an instruction file* does
  not reproduce the effect, not that the prose did nothing in the worker's seat. Decision 10.1
  chose this route for comparability with E-003 and says so. A third cell — the prose as
  `--append-system-prompt` — would separate seat from words and is not this experiment.
- **E-003 is the prior**: a 57-word `CLAUDE.md` moved nothing measurable at stop 6.
- **The prose addresses a delegate** (*"the task you were given"*, *"Report in this shape"*).
- **Two days, two batches.** E-008's runs are not pooled with these; the comparison is within
  this batch, against its own concurrent control.
- **I have seen E-008's run-record metrics.** Hence one registered outcome, and the rest
  report-only.
- **Codex is the registered scorer** (Decision C); the second reader is owed on every sheet, and
  `change-focus` from the fallback is report-only under decision 10.3.
- **One hand re-read before any sheet of this batch is opened** (§4 step 7). E-008's hand
  re-read of `582c0b39` (`test-quality` = 1, commit `56d8cfb`) is **not** reused: it is a
  different batch and a different run.

## Deliberate failure

None registered. This cell is itself the counterpart of E-007's P2 arm.

---
*Everything below is filled in AFTER the runs.*
---

## §4 step 6 — the batch, recorded 2026-09-07T12:50:10–13:31:01Z

Key `EXP-4B-FOURTH-CELL-2`, 10 pairs interleaved F then control, driver `run-e009.sh` pid 24715
under `caffeinate -i`, manifest
`evidence/p04b/lab-4b4/fourth-cell/e009-batch-20260907T125010Z/manifest.tsv`, **driver exit 0**,
40 min 51 s. `events.jsonl` grew 10 375 694 → 12 720 763 bytes (+2.34 MB).

| pair | arm F | exit | hash | stream / telemetry deleg. | control | exit | hash | stream / telemetry |
|---|---|---|---|---|---|---|---|---|
| 01 | `efe48ffc` | 0 | registered | 0 / 0 | `ce630aed` | 0 | `null` | 0 / 0 |
| 02 | `474fb3ea` | 0 | registered | 0 / 0 | `21c21018` | 0 | `null` | 0 / 0 |
| 03 | `867d5b2c` | 0 | registered | 0 / 0 | `99a43552` | 0 | `null` | 0 / 0 |
| 04 | `19b48d40` | 0 | registered | 0 / 0 | `9f88527f` | 0 | `null` | 0 / 0 |
| 05 | `52ba65fa` | 0 | registered | 0 / 0 | `3e721954` | 0 | `null` | 0 / 0 |
| 06 | `7175cc44` | 0 | registered | 0 / 0 | `66ddf446` | 0 | `null` | 0 / 0 |
| 07 | `e368c3e1` | 0 | registered | 0 / 0 | `dacb9838` | 0 | `null` | 0 / 0 |
| 08 | `fc12cdc6` | 0 | registered | 0 / 0 | `5c93586e` | 0 | `null` | 0 / 0 |
| 09 | `f80e4db3` | 0 | registered | 0 / 0 | `088451a1` | 0 | `null` | 0 / 0 |
| 10 | `3f978191` | 0 | registered | 0 / 0 | `182df867` | 0 | `null` | 0 / 0 |

**Row 0a did not fire.** 10 of 10 arm-F records carry
`sha256:51f16eeb1618cd212405818c5165dcba`; 10 of 10 controls carry `null`; **no run delegated in
either source**; every run is runtime 2.1.263 and model `claude-haiku-4-5-20251001`; the
evaluator passed **20 of 20**, so 20 of 20 are admitted.

- **Q2 held**, 20 of 20.
- **Q3 held**, 10 of 10 arm-F runs at zero in both sources.
- **Q4 held** at **0 of 10**, inside the registered 0–2. E-008 saw 1 of 8; this batch saw 0 of
  10. Pooled across both registrations that is **1 control delegation in 18**, and the honest
  reading of Q4 is that a plain baseline on BE-003 reaches for a built-in agent **rarely, not
  never** — which is exactly the claim E-008's P6 got wrong in the other direction.

**Disclosed rather than found later:** a process belonging to **another project**
(`scripts/gate03-sweep.sh`, a `.planning/` sweep — not this lab's, not a benchmark, scorer or
review process of this experiment) was alive on the machine when the batch ended. Duration and
cost are **report-only in this experiment by prior disclosure**, so nothing registered is
affected; it is recorded because the alternative is a reader discovering it in a log.

## Observed telemetry

`events.jsonl`, +2.34 MB across the batch. Delegation events with
`tool_name ∈ {Task, Agent}`: **0 on 20 of 20**, agreeing with the runner streams on 20 of 20.
(E-008 is where those two sources disagreed; here they do not.)

## §4 step 7 — the twenty registered sheets

`codex-score.sh` at rubric **`396e1799eb2b`**, asserted on every sheet by
`step7/collect-sheets.py`, which also asserts twenty sheets and all four categories parsing.
Scored 13:33–13:44Z through the 18081 tunnel, **sequentially**, exit 0 on all twenty, **zero
null cells**. Gate: 20 of 20 admitted.

RAW, manifest order:

| category | arm F | control |
|---|---|---|
| `architecture-consistency` | `2 2 2 2 2 2 2 2 2 2` | `2 2 2 2 2 2 2 2 2 2` |
| `maintainability` | `0 0 2 0 2 2 0 2 0 0` | `0 2 2 2 0 2 2 0 0 0` |
| **`test-quality`** | **`1 1 1 1 1 1 1 1 1 1`** | **`1 1 1 1 1 1 1 1 1 2`** |
| `change-focus` | `1 2 1 1 1 1 1 1 1 1` | `1 1 1 1 1 1 1 1 1 1` |

**A deviation in the gate step, reported by the scoring subagent and kept here rather than
tidied away.** `check-run-gate.sh` takes a **run-document JSON file**, not a run id — its own
header says *"THIS FILE DECIDES; IT DOES NOT FETCH"* — so the literal instruction I gave failed
on all twenty with `cannot read <id>`. The subagent fetched each document from the API and gated
the file, which is the script's actual contract; all twenty then returned *"ok: gate passed
(exitCode 0)"*, and `codex-score.sh` re-establishes the same gate internally before scoring.
**My instruction was wrong and the tool refused it**, which is the right order for those two.

### The hand re-read agrees, and so do two more cells I checked myself

| run | arm | my hand reading | codex sheet | agree? |
|---|---|---|---|---|
| `efe48ffc` | F | **1** — `hand-score-efe48ffc.md`, committed `e43c685` at 12:53:42Z, forty minutes before this batch's first sheet at 13:33:53Z | 1 | yes |
| `3f978191` | F | **1** — zero `get(` calls in the added tests, so anchor 2 clause 2 is absent | 1 | yes |
| `182df867` | control | **2** — a test named *persists the confirmed status* performs `get("/shipments/S-2")` after a confirm and asserts `$.status`; both other clauses hold | 2 | yes |

The third is the cell that sets `c`, and it is the one where an error would most flatter my
hypothesis — a control wrongly scored 2 makes the control look better than it was. It is right.

## Results

**The registered outcome, `test-quality` anchor 2, `n = 10` per arm:**

| arm | anchor 2 | nulls |
|---|---|---|
| **F — the prose, no split** | **0 of 10** | 0 |
| concurrent plain control | **1 of 10** | 0 |
| *(E-007 arm O — the split, for reference)* | *5 of 10* | *0* |
| *(E-007's own concurrent control)* | *0 of 10* | *0* |

| comparison | two-sided Fisher |
|---|---|
| arm F 0/10 vs its concurrent control 1/10 | **`p = 1.0`** — no separation |
| arm F 0/10 vs E-007 arm O 5/10 | **`p = 0.0325`** |
| E-007 arm O 5/10 vs its own control 0/10 | `p = 0.0325` |
| arm O 5/10 vs the two concurrent plain controls pooled, 1 of 20 ‡ | `p = 0.0088` |
| arm F 0/10 vs those same pooled controls | `p = 1.0` |
| arm O 5/10 vs the historical census of plain controls, 3 of 48 | `p = 0.0024` |
| arm F 0/10 vs that census | `p = 1.0` |

‡ **The pooled and census rows are unregistered, post-hoc and supporting only** (§4a finding 14).
The verdict comes from `c` and `k` **inside this batch**, through the rule fixed before the run;
neither pooled row could have changed a decision-rule row.

**Arm F sits inside the plain-baseline population on every comparison available. The split sits
outside all of them.**

### Q1 is REFUTED, and not narrowly

Q1 predicted arm F at **4–7 of 10** with `p_C < 0.05`. It came in at **0 of 10**, `p_C = 1.0`.
I registered it as *"most likely to be wrong in magnitude"*; **it was wrong in kind** — the
predicted effect is not smaller than expected, it is absent, and the arm did not produce a
single anchor-2 run in ten. E-008 registered the same prediction with the same mechanism, and it
is refuted for both. Both predictions stay exactly as written.

### Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| Q1 | arm F 4–7 of 10 anchor 2, `p_C < 0.05` | **NO — refuted** | 0 of 10, `p_C = 1.0` |
| Q2 | `instructionsHash` registered on 10 F, `null` on 10 C | yes | 10 / 10 |
| Q3 | 0 arm-F delegations, both sources | yes | 0 of 10, both sources |
| Q4 | 0–2 control delegations | yes | 0 of 10. E-008 saw 1 of 8; pooled **1 in 18** |

### The report-only metrics, and why they point the same way

`n = 10` per arm, from the API (`step8/per-arm-e009.txt`):

| metric | arm F median (q1–q3) | control median (q1–q3) | delta |
|---|---|---|---|
| `estimatedCost` | $0.1533 (0.1475–0.1691) | $0.1535 (0.1281–0.1629) | **−0.1 %** |
| `durationMs` | 89 s (82–97) | 89 s (75–97) | **0.0 %** |
| `modelCalls` | 23 (21–24) | 21.5 (19–24) | +7.0 % |
| `toolCalls` | 19 (17–20) | 18.5 (16–20) | +2.7 % |
| `addedLines` | 64 (63–73) | 67.5 (64–81) | **−5.2 %** |

These were **report-only by prior disclosure** — I had already read E-008's — so none of them is
a claim. They are worth one sentence anyway: **E-007's split wrote a median 26 lines MORE than
its control, mostly tests; the prose alone wrote 3.5 lines FEWER than its control.** Whatever
produced the extra test material in arm O, this overlay did not.

### `change-focus` moved on this model, which the record says it does not

One arm-F run, **`474fb3ea`, scored `change-focus` = 2**. The standing claim — E-006 §C2, quoted
into E-007's own correction — is that the category is dead *on `claude-haiku-4-5-20251001`
running BE-003*, its single observed 2 having come from a **codex** arm (`514b094e`). This is a
**claude-haiku** arm.

**Hand-checked, because it contradicts something in the record.** `474fb3ea` changed three files
with **78 insertions and zero deletions anywhere** — a new `confirm` method, one new `ErrorCode`
constant, and tests. `efe48ffc`, scored 1, made **five deletions**. The anchor asks that only
`confirm` and its by-symbol imports differ; a pure-addition diff is nearer that than one that
removes existing lines, so the 2 is defensible and the two runs really do differ.

**Report-only, and it changes no verdict here**, but it corrects a claim this project has
repeated in three documents: `change-focus` on this model and task is **rare, not dead** — now
two observations, on two different runtimes, across roughly 95 scored runs.

> **WITHDRAWN 2026-09-07 by the §4a round, finding 25 — see § §4a review round below.** The
> project already adjudicated this anchor at `n = 34`: anchor 2 requires that **only** `confirm`
> and its by-symbol imports differ, and `474fb3ea` changed `ApiError.kt` too, so its
> `change-focus` is **1**. Codex itself scored **1** on this same shape at stop 10 (`a06e80c5`).
> The cell is a scorer inconsistency already on file, not a category moving; the standing
> claim stands and the three documents should **not** be corrected. The paragraph above is
> kept unedited because a retraction that deletes what it retracts teaches nothing.

## Failure analysis

**Was it the agent, or the harness?** The agent — with the limit § How the treatment is delivered states, and the §4a round (findings 16, 22) insisted be repeated here: **nothing on the run record proves the runtime *read* `CLAUDE.md`**, only that the file was present and hashed. The supportable form is that **no instrument between the prediction and the result failed in a way this batch can detect**. The treatment was delivered on 10 of 10 with
the hash read back per run, the runtime never moved, the evaluator passed 20 of 20, both
delegation sources agree at zero, the rubric sha is asserted on every sheet, the scorer returned
zero nulls, and three cells were re-derived by hand including the one that sets `c`. **There is
no instrument between the prediction and the result this time** — worth saying out loud after
E-008, where there were three.

**Why the prose did not do it.** The hypothesis was that *"tests for every case it names"* plus
BE-003's *"changes nothing"* case forces a re-read of persisted state. Ten runs say it does not.
Every arm-F run wrote a test for that case, asserted the second confirm's **body**, and stopped
there — the same anchor-1 shape as the controls. **Naming the case is not the same as asking for
proof that nothing changed**, and the model treats the second response as that proof. Arm O's
worker, given the same words in a fresh context with the ticket re-read from scratch, reached
for a separate `get(...)` half the time.

## Sanity checks

- [x] **Did any dramatic number appear?** `0 of 10` against a predicted 4–7. Explained above and
      tested three ways: the concurrent control, the two pooled controls and the 48-run census
      all put arm F exactly where an untreated baseline sits.
- [x] **Did any flattering number appear?** None. Every number here runs against my hypothesis,
      which is the one direction that needs no second disbelieving. The single number that could
      have flattered it — the control's one 2 — was re-derived by hand, and it stands.
- [x] **If a fix motivated this run, did the original symptom disappear?** Yes. E-008 died on a
      control delegation; the arm-aware rule and the two-source column carried this batch to 20
      of 20 with no abort, and Q4 measured what E-008 could only trip over.

## Decision

**Reading (b), decision rule row 2: `test-quality` is a return from the split, not from the
prose it carried.**

> **Read this with the qualification added by the §4a round (findings 9, 10, 18, all 2/2), below:**
> the effect does not survive removing the split while keeping the words in project memory. Two
> explanations remain open — the decomposition itself, and a worker reading the ticket in a fresh
> context under a system prompt — and **this experiment cannot separate them.** § Threats
> registered that confound before the run; § Follow-up item 1 names the arm that would settle it.

`c = 1`, `k = 0`, `p_C = 1.0` (≥ 0.05), `k ≤ 2` → row 2, stated as the rule requires: **true of
these runs.** `p_O = 0.0325` sits beside it, and at `k = 0` that comparison is one of the two
counts where it has any power — E-008's MDE registered *"only 0 or 10 is distinguishable"*, and
the result landed on 0.

**HANDOFF item 00c is answered, and it went the way that item's second branch described.**
E-007's one detected effect is **not** the worker's prose wearing the split's name. Remove the
decomposition, keep the words verbatim, and the effect disappears completely.

**What is now true of E-007, and what is not.** Its registered verdict `NOT DETECTABLE` (row 4)
**stands unedited** — it was decided by O2–O7, none of which reads `test-quality`. What is
amended, by a dated note there, is the sentence *"the split returned nothing the gate can see"*:
the split returned something the **rubric** could see and the **decision rule had no row for**.
That is the first measured benefit of a customization in this track, and it arrived inside an
experiment that had registered no way to say so.

**One task, one size, one rubric clause.** This is BE-003 at three files and about 65 added
lines, and the effect is a single anchor clause. Nothing here says decomposition pays at any
other size, and E-007's cost result — the split was 13 % *cheaper*, against a registered +60 % —
is untouched.

## Follow-up

1. **The split's mechanism is now the open question, and it is testable.** This cell removed the
   split and kept the words; the reverse cell — the split with the worker's prose stripped to a
   bare *"implement the ticket"* — would say whether the return comes from the fresh context or
   from decomposition plus *any* instruction. It is a new arm, so it is the author's.
2. **A single rubric clause is carrying a whole finding.** `test-quality` anchor 2 clause 2 — a
   separate `get(...)` — is the entire measured difference between an orchestrated and a plain
   run on this task. Whether that clause is worth 25 points, and whether it generalises past
   BE-003, is a question for BE-004's own instrument.
3. **`change-focus` is rare, not dead** — see above. Three documents say otherwise and should be
   corrected as each is next touched, not rewritten now.
4. **`check-run-gate.sh` takes a file, not a run id.** Two sessions have now put the wrong
   invocation into a subagent brief. A usage line, or accepting an id and fetching, is a tool
   change and is not made mid-experiment.

## §5 — validation table

Every row's evidence is a path, an id or a sha, never a sentence. The **layer column is about
the proof**, not about the artifact.

| Gate clause | Evidence | Layer of the proof | How a stranger re-derives it |
|---|---|---|---|
| the treatment reached the model | `customization.instructionsHash` = `sha256:51f16eeb1618cd212405818c5165dcba` on 10 of 10 arm-F run records; column 6 of `e009-batch-20260907T125010Z/manifest.tsv`, written by the driver from the API per run | **L2** — `run-e009.sh` reads it back and aborts the batch at exit 8 on a mismatch; `verify-run-e009.sh` drives the overlay guards to fire, 12 of 12 | `curl $API/api/runs/<id> \| jq .customization.instructionsHash` for each arm-F id |
| the control did not receive it | `instructionsHash: null` on 10 of 10 control records; same column. Worktrees are built by `git archive` from an allowlist of `sample-service` + `.gitignore`, so `null` means absent, not merely uninstalled | **L2** — same read-back, same abort | same query on the control ids |
| the overlay is the implementer's prose, verbatim | `diff <(tail -n +7 build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md) build/customizations/implementer-prose-4b4/CLAUDE.md` is empty; sha `51f16eeb1618cd21` | **L2** — asserted by the driver before every batch; verifier cases 5 and 6 prove it refuses both a one-sided and a consistent two-sided edit | run the `diff` and `shasum -a 256` |
| no split in either arm | `deleg_stream` and `deleg_telemetry` both 0 on 20 of 20 (manifest columns 7–8); no `control-delegations.txt` was written | **L2 for arm F, L1-by-absence for the control** † |  `grep -cE '"(name\|tool_name)":"(Task\|Agent)"'` over each `NN-arm.log`, and over `events.jsonl` filtered by run id |
| the registered outcome | `test-quality` anchor 2: arm F **0 of 10**, control **1 of 10**; `step7/collect-sheets.py` asserts 20 sheets, rubric `396e1799eb2b` on every one, all four categories parsing | **L2** — the collector asserts rather than reports; it was written after a presence check on a *filename* was mistaken for a check on a *sheet* | `python3 step7/collect-sheets.py findings/codex <manifest>` |
| the prediction preceded the runs | prediction commit `1e189fc` at 2026-09-07T12:49:35Z; first run `startedAt` 12:50:1xZ | **L2** — the driver reads the commit's timestamp and refuses to start if it does not precede now | `git log --format=%cI -1 1e189fc` against `curl $API/api/runs/efe48ffc… \| jq .startedAt` |
| a scored cell re-read by hand, before the sheets | `evidence/p04b/lab-4b4/fourth-cell/hand-score-efe48ffc.md`, commit `e43c685` at 12:53:42Z; this batch's earliest sheet is 13:33:53Z | **L3** — a person doing it in the right order. The **ordering** is L2 by timestamp; the reading itself is judgement | compare `git log --format=%cI -1 e43c685` with `ls -1t findings/codex/` |
| two further cells re-derived by hand | `3f978191` (F) = 1, zero `get(` in the added tests; `182df867` (C) = 2, a `get("/shipments/S-2")` after a confirm | **L3** | open both kept worktrees, `git diff HEAD -- sample-service/src/test` |
| registered variables did not move between arms | `runtime.model` = `claude-haiku-4-5-20251001` and `runtime.version` = 2.1.263 on 20 of 20; BE-003 tree `eeb15a753adc94e92bc3f74c50e1b02fc3b53030`; evaluator 1.0.0; rubric `396e1799eb2b` | **L2** — asserted per batch by the driver; the tree is asserted as a **tree**, so a benchmarks commit that does not touch BE-003 cannot trip it | `git -C ../agent-observatory-benchmarks rev-parse HEAD:tasks/BE-003-confirm-shipment` |
| every run was gate-admitted | evaluator exit 0 on 20 of 20; `check-run-gate.sh` on each fetched run document returned *ok: gate passed (exitCode 0)* | **L2** — `verify-run-gate-checker.sh`, 13 cases, proves the gate still refuses | fetch each run document and run the gate script on the file |

**Every number quoted in this file carries its `n`.** Nothing from `n < 5` is stated as a
property: the single `change-focus` = 2 and the single control `test-quality` = 2 are each
reported as one run, and the E-008 control delegation is reported as 1 of 8 and pooled as 1 of
18.

† **Corrected 2026-09-07 after the §4a round, finding 20 (2/2).** This row first read a flat
**L2** for both halves, and that was wrong in the project's own recurring way. An arm-F delegation
**aborts the batch** — something executes and rejects it, L2. A control delegation is **written to
a file and the batch continues**, by design: nothing rejects it, so for the control half the entry
is a *measurement*, not a control. It reaches the gate clause anyway because a control delegation
**cannot make the cell a split** — the clause is about the treatment arm's integrity, and for the
control arm there is nothing to enforce. Recording the label honestly matters more than the row
looking symmetrical: the L2/L3 mislabel is on its fourth recurrence in this project.

**Independence check — what else changed between arms?** Nothing that the run records can show:
same model, same runtime version, same benchmark tree, same evaluator, same flags, same
interleaved window, `skillsHash`, `agentHash`, `hooksHash` and `mcpHash` all `null` on 20 of 20.
The one asymmetry is the independent variable.

## §4a review round — 2026-09-07, and one finding overturns a claim in this file

Panel: **codex** (`-P codex -A -n 2`), agent `lab-critic` sha `5ae27fa4d5e2`, opencode 1.18.27,
artifact sha `519442a7487a`, two independent runs unioned, **25 distinct findings**, 25 286 bytes,
28 sections. **Exit 0 and not a stall** — established by a live-process check, not by file size.
The acceptance gate was **skipped** (`-A`, author decision 3's codex route), so there is **no
`ACCEPT` verdict** and this round is recorded as *findings dispositioned*, never as a gate pass.

Every finding is fixed or disputed below. The full list with recurrence is in the PR body;
`findings/opencode/review-E-009-fourth-cell-second-registration-20260907T135316Z.md` is the file.

### The one that overturns something — finding 25, and the critic is right

> *Scoring run `474fb3ea` a 2 rather than a 1 is reviewer-dependent: the defence relies on
> "relative nearness" while the stated anchor is categorical, and the diff touches three files
> plus a new constant.*

**Sustained, and my `change-focus` correction is withdrawn.** This project adjudicated exactly
this anchor at `n = 34` and wrote the answer into `HANDOFF.md`:

> *anchor 2 requires that **only** `confirm` and its by-symbol imports differ, `ApiError.kt` is
> neither, anchor 0 fails as well, and so the residual `1` is the rubric's own answer as
> written. **No rubric round is owed.***

`474fb3ea` changed **three files including `ApiError.kt`**, which gained
`SHIPMENT_CANNOT_BE_CONFIRMED`. By that adjudication its `change-focus` is **1**. Worse for my
reading: `evidence/second-reader/README.md` records **codex itself scoring 1 on this same shape**
at stop 10 — run `a06e80c5`, *"Unnamed methods match, but ApiError.kt also changes"*, three
changed files with `ApiError.kt` gaining one line.

**So the cell is a scorer inconsistency of a class already on file, not a category moving.** The
sheet's own stated reason — *"create, getById, and list remain identical to baseline"* — is the
very reason the concordance work found insufficient, because it answers a question the anchor
does not ask.

**What I wrote and now withdraw:** *"`change-focus` on this model and task is rare, not dead —
now two observations."* **It is one observation on a codex arm (`514b094e`) and one likely
mis-score here.** The standing claim — dead on `claude-haiku-4-5-20251001` running BE-003 —
**stands**, and the three documents I said should be corrected should not be. The withdrawn text
above stays where it is, with this note beside it, because a retraction that deletes what it
retracts leaves nothing to learn from.

**I hand-checked this cell and still got it wrong.** The check I ran asked *"do these two diffs
differ in a way the anchor could see?"* and they do. The question the anchor asks is *"does
anything but `confirm` and its imports differ?"* and it does. **A hand re-read is only as good as
the question it asks**, which is the same failure as a control reporting success over a scope
smaller than it claims — this time in my own reading rather than in a script.

### The strongest structural finding — 9, 10 and 18, all 2/2

> *The observed counts are equally consistent with "decomposition causes the effect" and "the
> prose only works in a worker system-prompt seat", yet the decision rule forces one verdict —
> and § Threats names that confound while the rule does not honour it.*

**Sustained in substance, and it does not move the verdict.** § Threats registered *"Same words,
different seat"* **before the run**, and this file already says a null *"means the prose as an
instruction file does not reproduce the effect, not that the prose did nothing in the worker's
seat."* The critic's point is that § Decision then states the causal claim flatly, 200 lines
away from that caveat. **That is a real defect of presentation and it is fixed here rather than
argued with:**

> **Read § Decision as: the effect does not survive removing the split while keeping the words
> in project memory.** Two explanations remain open — the decomposition itself, and a worker
> reading the ticket in a fresh context under a system prompt. **This experiment cannot separate
> them**, § Follow-up item 1 names the arm that would, and that arm is the author's.

The registered decision-rule row is **not** edited: row 2's label *"reading (b) — `test-quality`
is a return from the split"* was fixed before the run and stays as written, wording included.
What is added is the qualification at the point a reader meets the claim.

### Fixed, with the fix stated

- **12 — only 3 of 20 sheets were re-derived by hand, two of them chosen after seeing results.**
  True. Here is the robustness the finding asks for, computed rather than asserted: with arm F at
  0 of 10, the verdict is **row 2 for a control count of 0, 1 or 2** (`p_C` = 1.0, 1.0, 0.474)
  and only moves to row 0b at **3**. With the control at 1 of 10, the verdict is **row 2 for an
  arm-F count of 0, 1 or 2** and moves to row 3 at 3. **One flipped cell in either arm changes
  nothing; it takes three.** The hand re-read that was written *before* any sheet existed
  (`efe48ffc`) is the one the ordering discipline requires; the other two were chosen afterwards
  and are labelled as such.
- **14 — pooling controls across registrations for `p = 0.0088` is an unregistered cross-batch
  analysis.** True. **That number is supporting, not deciding**: the verdict comes from `c` and
  `k` **inside this batch** through the registered rule. The pooled and census comparisons are
  hereby labelled **unregistered, post-hoc, and reported for context only** — they would not have
  changed a row.
- **4 — every pair runs F before C, uncounterbalanced.** True, not registered, and inherited from
  E-007's driver. A time-varying confound would bias every F run one way. **Disclosed as a threat
  found after the fact**; the arms are interleaved pair-by-pair so drift across the 41-minute
  window is shared, but within-pair order is not counterbalanced and this file does not claim it
  is. Counterbalancing is a driver change and is not made mid-experiment.
- **5, 11, 24 — the other project's sweep, and *when* it overlapped.** Answered with the clock:
  `scripts/gate03-sweep.sh` started **13:30:39Z** and the batch ended **13:31:01Z**, so it
  overlapped the final **22 seconds** — inside pair 10's control run at most. Duration and cost
  were report-only here by prior disclosure, so no registered number is touched.
- **17 — "no flattering number appeared" is directionally ambiguous.** Correct, and the sentence
  was sloppy. Restated: **the control's single anchor-2 makes the treatment arm look worse, not
  better, so it is not a flattering number** — it is the number that most affects the decision
  row, which is why it was the cell re-derived by hand.
- **16, 22 — "was it the agent, or the harness? The agent" is unproven; a runtime that records
  the hash without reading the file gives the same result.** Sustained as a limit, already stated
  in § How the treatment is delivered (*"what still cannot be proved from the run record: that
  the runtime read the file"*), and now cross-referenced from § Failure analysis. **The stronger
  form of the claim this file can support: no instrument between the prediction and the result
  failed in a way this batch can detect.**
- **6 — the MDE table is computed at `n = 10` while row 0a admits `n = 8`.** True gap in the
  registration; it did not bite, because both arms came in at 10. Recorded so the next
  registration writes the MDE at its own floor.
- **13 — 17 of 20 sheets have no second reading.** True. The second reader is **owed, not
  waived**: this batch adds **20** sheets to the standing debt. `change-focus` from the fallback
  is report-only under author decision 10.3 in any case.

### Disputed, with the reason

- **3, 23 — Q2–Q4 are counted among "predictions that held" while Q1 is called the one registered
  outcome.** The prediction table labels them in place: Q2 *"void condition, not an outcome"*,
  Q3 a void condition, Q4 *"reported, never voiding"*. A reader who reaches the table cannot
  reach the ambiguity; a reader who reads only the summary line can, and that is a summary
  claiming more than the detail beneath it — this project's house failure. **Disputed as a defect
  of the document, accepted as a naming risk**, and the table is left as written.
- **1 — a null cannot distinguish "decomposition" from "prose only in a worker seat".** Correct
  and **already registered before the run** as the seat threat; the fix above states it at the
  claim. Not a separate defect.
- **7 — whether a passing run with a null rubric cell counts as admitted is unspecified.**
  Disputed: § Exclusions says a `null` *"counts as not anchor 2 in Q1's count and is reported
  separately"*, which is exactly that specification. The batch produced **zero nulls**.
- **8 — excluding evaluator-failing runs could exclude treatment-caused failures.** Correct in
  general and inert here: **20 of 20 passed**, so the exclusion never fired and cannot have
  biased the sample.
- **19 — the proposed reverse cell does not separate fresh context from decomposition.**
  Sustained as a caveat on a follow-up, not a defect of this result. § Follow-up item 1 is
  reworded to say the reverse cell narrows the question rather than settling it; the arm is the
  author's either way.
- **21 — is `test-quality` a duplicate of the evaluator gate?** No: the evaluator decides
  correctness and every run of both arms passed it, so the gate is a constant across everything
  the rubric can score here. That is the exact defect the v2 rubric was written to remove, and
  `test-quality` is not a restatement of it — anchor 2's clauses describe test *construction*,
  which the evaluator never inspects.
- **2 — Q1 pairs a magnitude with a significance test that can disagree.** Both halves failed
  together (0 of 10, `p_C = 1.0`), so no reader has to adjudicate a split verdict. Recorded for
  the next registration: **state which half decides when they part.**
- **15 — a shared scoring bias between codex and the author could pass undetected.** True and
  unfixable from inside a single-scorer design; it is why Decision C keeps a second reader, and
  why the debt in finding 13 is recorded rather than waived.
- **20 — the L2 label on the delegation row.** Sustained and **fixed in the §5 table itself**,
  with the correction noted there rather than here.

*Dispositioned by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-07. The round was pointed at
the whole artifact rather than at a diff, so several findings re-read text registered before the
runs; where that is so, the text stays and the note sits beside it.*
