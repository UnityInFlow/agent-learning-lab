# Experiment E-007 — orchestration overhead on a task too small to split

**Stop:** 11 (Phase 4B, Lab 4B.4) · **Workbook:** [`phases/04b-orchestration/README.md`](../phases/04b-orchestration/README.md)
**Experiment key:** `EXP-4B-ORCH-OVERHEAD` · **Benchmark:** BE-003 · **Agent under test:** `claude-haiku-4-5-20251001`
**Status:** predictions registered, no runs

`Predicted by Claude Fable 5.1 (claude-fable-5-1), autonomously, 2026-09-06T05:2xZ (see the commit
for the exact time); the author did not review before the run.` Written after the §4 step 2 probe
(`evidence/p04b/lab-4b4/probe-20260906T050917Z/`) and before any run on the experiment key.

## Question

On BE-003, what does an orchestrator–worker decomposition cost, and what does it return, against
a concurrent plain baseline — with delegation counted from telemetry rather than assumed from
the transcript?

## Hypothesis

Decomposing a three-file, ~70-line change into an orchestrator that cannot write and a worker
that can costs more tokens, more wall-clock and more tool calls than doing it in one session, and
returns nothing the evaluator or the rubric can see. The mechanism is the one the vendor names:
the split does not reduce what the parent must hold, because the parent holds almost nothing to
begin with; it only adds a second context that re-reads the repository and a summary round trip.

## Predictions

Reference population: E-006 batch 2's **concurrent plain control**, `n = 10`, all exit 0,
2026-09-05T09:50–10:36Z, runtime 2.1.261: `estimatedCost` median **$0.156** (q1 0.139, q3 0.175,
range 0.115–0.192); `durationMs` median **97 s** (85–102, range 68–116); `toolCalls` median
**20** (17–22, range 14–22); `modelCalls` median **22** (20–26); `addedLines` median 69;
`changedFiles` 3 on 9 of 10; `maintainability` anchor 2 on **1 of 10**; evaluator pass **10 of
10**. Re-derived from the API on 2026-09-06T05:05Z, not copied from E-006's prose.

| # | Outcome | Direction · magnitude | Mechanism |
|---|---|---|---|
| **O1** | delegation — `tool_result` events with `tool_name` ∈ {`Task`, `Agent`} per run, from the observatory telemetry | arm O ≥ 1 on **10 of 10**; arm C **0 of 10**; exactly 1 on ≥ 7 of 10 arm-O runs | the orchestrator's delivered pool is `Read, Task, Grep, Glob` (probe, 3 of 3): there is no other route to a diff. Second delegations only on a reported failure. **Registered as least likely to be wrong** |
| **O2** | `estimatedCost` median | **+60 %** on the control median (≈ $0.25); refuted below **+25 %** (the MDE) or above **+150 %** | a second agent with its own system prompt and its own cache prefix re-reads what the first skimmed; cost here is dominated by cached input, and two contexts create two cache prefixes |
| **O3** | `durationMs` median | **≥ +40 %** (≈ 135 s or more) | sequential handoff: the worker starts after the orchestrator has read the ticket, and the summary round trip adds at least one model call at the end |
| **O4** | `toolCalls` median | **≥ +5** (≥ 25), quartiles not overlapping the control's | the worker does roughly the control's work (≈ 20 calls) and the orchestrator adds its own reads |
| **O5** | `modelCalls` median | **≥ +4** (≥ 26) | one orchestrator turn to delegate, one to read the report, one to summarise, plus the worker's own |
| **O6** | evaluator pass rate, arm O | **≥ 8 of 10**, and not lower than arm C by 3 or more | the ticket is passed verbatim by instruction, so the error cases survive the handoff. **Registered as the one most likely to be wrong**: a small orchestrator paraphrases, and BE-003's gate lives in the error cases |
| **O7** | `maintainability` anchor 2 (codex, rubric `396e1799eb2b`) | **1–3 of 10**, no change; only ≥ 9 of 10 would be detectable | nothing in the split touches how the worker writes Kotlin |
| — | `changedFiles`, `addedLines`, `change-focus` | **report only** | `changedFiles` at the floor on 19 of 19 historical controls; `change-focus` = 1 on 70 of 70 scored runs. Not outcomes |

**The gate's number, in the form this task can give it.** If O2 and O3 hold and neither O6 nor O7
improves, then the task size below which decomposition costs more than it returns is **at least
3 files / 69 added lines** (BE-003, `n = 10`) — a lower bound, never a threshold. The threshold
needs a second size and that is BE-004 at stop 12.

## Independent variable

The presence of the `orchestration-4b4-P1` overlay delivered with `--agent orchestrator`. One
directory, two files:

| File | sha256 (prefix) | Layer |
|---|---|---|
| `build/customizations/orchestration-4b4-P1/.claude/agents/orchestrator.md` | `4f2af4ba7f740c33` | `tools:` line **L2** (runtime refuses absent tools by name; observed, stop 9); body **L3** |
| `build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md` | `6096f5ea35383112` | **L3**; no `tools:` key, inherits the session pool (probe, 3 of 3) |

Both `model:` pins are `claude-haiku-4-5-20251001` — L3, observed on 6 of 6 probe streams,
nothing rejects a wrong one.

**Everything else is the plain baseline.** The worker carries a four-line body so that it has a
report shape; it is disclosed that the treatment is *the split including that minimal prose*,
and the deliberate failure at step 9 (variant P2) removes the structural line and keeps the
prose, which is what separates the two.

## How the treatment is delivered — and proved

| | Arm O | Arm C |
|---|---|---|
| Mechanism | `run-agent.sh --customization <overlay dir> --agent orchestrator` — the overlay is copied into the worktree, force-added and committed (author decision 2), the session starts as `orchestrator` | no `--customization`, no `--agent` |
| Delivered schema | `init.tools` per run, checked by `runner/lib/check-init-schema.sh` against `Read, Grep, Glob, Task`; **probe: `["Read","Task","Grep","Glob"]` on 3 of 3** | recorded only; expected the full 29 |
| Activation | O1 — ≥ 1 `Task`/`Agent` event | 0 events |
| Preflight assertion (§4 step 5) | one run on `EXP-4B-ORCH-PREFLIGHT`: `--agent` accepted, schema verdict `matches`, ≥ 1 delegation event, evaluator exit recorded | one run: hashes all `null`, 0 delegation events |
| What cannot be proved from the run record | no `customization.*Hash` field tracks a Claude agent overlay (unchanged since stop 10). Independence rests on the `init` record, the setup commit's tree and the telemetry, as E-006 §5 did |

## Controlled variables

Held equal to E-006 batch 2 and recorded per run in the batch manifest: `runtime.model`,
Claude Code version, benchmark commit, `evaluator.sh` version 1.0.0, rubric sha `396e1799eb2b`,
`ISOLATE_USER_SETTINGS=1`, `KEEP=1`, `--disable-slash-commands` (no skill is a treatment here),
the runner's flag array, interleaving O/C pairs, no machine sleep, no other benchmark, scorer or
review process running (checked with `LC_ALL=C pgrep` before each pair).

## Runs

**10 O + 10 C, interleaved as pairs, one experiment key.** Preflight pair first on its own key.
Budget ≈ 10 × $0.25 + 10 × $0.16 ≈ **$4.10** plus scoring. Batch driver: a copy of
`evidence/b04/run-e006-armG.sh`'s pair loop (§4 step 4, with its `verify-*.sh` set), not the
bare Makefile target, because the manifest row per run is the progress record.

## Minimum detectable effect

From the reference population above, before any threshold was written:

| Outcome | spread it comes from | MDE at `n = 10` per arm |
|---|---|---|
| O1 delegation | control 0 of 38 (telemetry on file) | Fisher 10/10 vs 0/10: `p = 0.00001`. Anything below 9 of 10 is a delivery failure, not a result |
| O2 cost | control q1–q3 $0.139–0.175 (ratio 1.26) | **≥ +25 %** on the median, as E-003 and E-006 registered |
| O3 duration | control range 68–116 s | **≥ +40 %** on the median and no sleep contamination |
| O4 `toolCalls` | control q1–q3 17–22 | **≥ +5** with non-overlapping quartiles |
| O5 `modelCalls` | control q1–q3 20–26 | **≥ +4** with non-overlapping quartiles |
| O6 pass rate | control 10 of 10 | Fisher 10/10 vs 7/10: `p = 0.21`, **not detectable**; vs 5/10: `p = 0.033`. A drop of 1–2 is reported, not claimed |
| O7 `maintainability` | control 1 of 10 | 9 of 10 → `p = 0.0011`; 6 of 10 → `p = 0.057`, not detectable |

A result inside its MDE is **NOT DETECTABLE at this `n`**, never refuted.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` 1.0.0 decides correctness per run — exit 0 or the
registered non-zero code. Gate-failing runs are reported per arm and not scored.

## Exclusions, registered before the data

1. A run whose evaluator exit code is not 0 is reported per arm (it is O6's numerator) and not
   sent to the rubric.
2. A run whose `runtime.model` is not `claude-haiku-4-5-20251001` is void and reported.
3. An arm-O run whose `init.tools` verdict is not `matches` is **row 0a — void before scoring**
   (author decision 8) and voids the batch's arm O, which is then redesigned, not resumed.
4. Duration only is excluded (never the run) on any run during which another process of this
   lab ran, as the 17:34Z preflight taught.
5. F13 session-limit exits are reported with their count and excluded from every median.

## Decision rule, fixed before the run

| # | Condition | Verdict |
|---|---|---|
| 0a | any arm-O run with schema verdict ≠ `matches`, or O1 < 9 of 10 | **VOID** — the treatment was not delivered; nothing below is read |
| 1 | O2 ≥ +25 % **and** O3 ≥ +40 % **and** O6 not higher than arm C **and** O7 < 9 of 10 | **CONFIRM** — decomposition loses at this size; the gate's lower bound is set |
| 2 | O6 lower than arm C by ≥ 3 | **CONFIRM, stronger reading** — decomposition loses *correctness*; failure analysis classifies each failure handoff-loss / worker-failure by the rule in the workbook |
| 3 | O7 ≥ 9 of 10 in arm O | **REFUTE** — the split returned quality the gate can see; the hypothesis is wrong regardless of cost |
| 4 | O2 < +25 % and O3 < +40 % and nothing improved | **NOT DETECTABLE** — overhead below the instrument's floor; the lower bound is not set |
| 5 | O6 higher than arm C by ≥ 3 | **REFUTE** — the split returned correctness |

Rows 3 and 5 outrank row 1. The hypothesis is confirmed only by row 1 or row 2.

## Threats to validity, registered before the run

- **The worker's four-line body is prose the control does not have.** It is minimal and it is
  the same on P1 and P2, so step 9's deliberate failure isolates the structural line from it, but
  this batch does not isolate the prose from the split. Disclosed, not worked around.
- **Cost is dominated by cached input tokens** (the sample control: 507 k cached of 534 k). Two
  contexts mean two cache prefixes; O2's mechanism depends on that and it is not independently
  verified before the run. If O2 holds for a different reason the failure analysis says so.
- **Telemetry attribution of the worker's tool calls.** The probe shows the worker's `Write` in
  the parent's *stream*; whether the observatory's `tool_result` events carry the worker's calls
  under the same run id is unverified until the preflight pair. If they do not, `toolCalls` on
  the run record under-counts arm O and O4 is reported with that caveat rather than claimed.
- **Delegation depth.** The worker can itself delegate (docs: three layers). A worker that
  spawns a sub-worker is counted in O1 and reported; it does not void anything.
- **One task, one size.** The gate wants a threshold; this gives a bound. Said in three places.

## Deliberate failure — registered at §4 step 9, not here

Candidate fixed now, prediction written then: variant **P2** — the same overlay with the
orchestrator's `tools:` line removed (`1b259ccc09066cad`), prose intact. The question it asks is
whether an L3 instruction to delegate delegates when nothing structural forces it, which is the
L2-vs-L3 demonstration this stop exists to make.

## Observed telemetry

*(after the run)*

## Results

*(after the run)*

## Which predictions held

*(after the run)*

## Failure analysis

*(after the run)*

## Sanity checks

*(after the run: prediction commit timestamp precedes first `startedAt`; per-run schema verdicts;
`runtime.model` on 20 of 20; benchmark sha and evaluator version equal across arms; a hand
re-read of one `maintainability` cell written before any sheet is opened.)*

## Decision

*(after the run)*

## Follow-up

- The threshold, not the bound: the same design on BE-004 at stop 12 under author decision 9.
- Whether the observatory attributes a subagent's tool calls to the parent run (threat 3) is an
  instrument question for the observatory repo if the preflight pair answers it badly.
