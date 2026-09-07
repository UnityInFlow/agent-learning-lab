# Experiment E-009 — the fourth cell, second registration

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`.

**Status: registered, no run on the key.** Successor to
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
