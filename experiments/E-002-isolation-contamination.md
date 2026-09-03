# Experiment E-002 — the size of the contamination B2's isolation removes

> **Everything down to and including Predictions was written and committed BEFORE the first
> run.** The commit timestamp and the first run's `startedAt` are both recorded under
> *Timestamp check*, below, and were compared after the runs rather than asserted before them.

**This is B2's deliberate-failure step**, promoted from one un-isolated run to a matched pair
because the comparison it was originally specified against cannot be verified. See *Why a
matched pair* below.

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-03`

## Question

`ISOLATE_USER_SETTINGS=1` is mandatory in B2's runbook, and the reason given is that without
it "you are measuring your ~21 local hooks, not the baseline." That is an argument, not a
number. **How large is the effect it removes, on this task, this model and this machine — and
does it change the verdict or only the cost?**

## Why a matched pair, rather than one un-isolated run against the nine on record

The workbook's Deliberate-failure block asks for *one* un-isolated run compared against the
existing baseline. That comparison cannot be validated above L3, for three reasons found
while preparing it:

1. **The nine baseline runs record `userSettingsIsolated: null`.** They predate observatory
   V6. `null` means *not measured*, not *false* — so the claim "those nine were isolated"
   rests on the flag that was typed, and §5's independence check exists precisely to forbid
   trusting a flag. A fresh isolated arm records `true` and makes the contrast **L2**.
2. **The harness version has moved**, `2.1.251` → `2.1.259`, which the run record carries as
   `runtime.version`. It is a controlled variable in `templates/experiment.md` and it is no
   longer constant against the 2026-08-30 batch.
3. **Duration in the 2026-08-30 batch is already known to be contaminated** by something the
   run record does not capture — median 83,000 ms with a maximum of 3,790,000 ms. Comparing a
   new run's duration to that range would inherit the contamination into the one outcome this
   experiment most wants to measure.

A matched pair run back to back under one harness version, one benchmark tree and one machine
state answers the question the deliberate-failure step was actually asking, and does it
without depending on any of the three.

**The nine baseline runs are not re-analysed here and their `n` is untouched.** This
experiment adds two new experiment keys and takes nothing away from `EXP-B2-BASELINE-CLAUDE`.

## Hypothesis

The operator's user-level settings reach an un-isolated run through **two channels that are
not the same size**, and separating them is the point:

- **Injection.** `SessionStart` and `UserPromptSubmit` hooks write text into the model's
  context before it sees the task. On this machine that includes a skills preamble and a
  memory-recall hook. **This is a global instruction file arriving inside the control** —
  structurally the same defect the runbook records for the codex arm's `~/.codex/AGENTS.md`,
  which is why the codex arm gets a scrubbed `CODEX_HOME`.
- **Overhead.** `PreToolUse` / `PostToolUse` hooks fire per tool call and each spawns a
  process. Measured on 37 un-isolated runs already on record: **median 23 hook executions per
  run**, range 2–43, dominated by `PostToolUse:Read` (190), `PreToolUse:Bash` (121) and
  `PreToolUse:Edit` (79).

The mechanism predicts these land on **different outcomes**: injection lands on context size
and on what the agent does; overhead lands on wall-clock and on nothing else. If the
contamination were purely overhead, isolation would be a performance flag rather than a
validity control, and the runbook's insistence on it would be overstated.

**What would make this uninteresting:** the operator's hooks cannot deny a tool call on this
path. `gsd-validate-commit.sh` is the only user hook that exits 2, and only on `git commit`,
which BE-003 never invokes — the evaluator diffs the worktree instead. So no *blocking*
effect is predicted, and a pass-rate difference would need a different explanation.

## Predictions

> `Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-03T13:06:30Z (this file's commit); the author did
> not review before the run.`
>
> **Contamination disclosure.** The predictor has read all nine B2 baseline run records,
> both scored grids, and the hook-execution counts of 37 un-isolated runs already on file.
> Magnitudes below are anchored on those, so they are calibrated forecasts rather than blind
> ones. What the predictor has **not** seen is any run of either arm in this experiment.
>
> The same predictor's adopted set was refuted 3 of 4 on E-001 and 3 of 4 on B2, both times
> by **over-predicting difficulty**. Weigh these with that bias on the record.

1. **Overhead — the contaminated arm's median wall-clock is ≥ 20 % higher.**
   Point estimate **+35 %**.

   **Mechanism.** ~23 hook executions per run, each a `node` or `bash` process spawn on the
   critical path of a tool call. Node startup alone is ~50–120 ms on this machine; 23 of them
   is 1–3 s against an isolated median that will sit near 80 s, so process spawn *alone* does
   not reach 20 %. The rest must come from the hooks doing work — the memtrace `PreToolUse`
   curl carries `--max-time 2`, and `PostToolUse:Read` fired 190 times across 37 runs. The
   prior on record is *"hooks were ~13 % of every run"* from `EXP-BE002-NOHOOKS`, on a
   different task; **+35 % says this task is more tool-dense than that one**, which is the
   part of this prediction that can be wrong on its own.

   **Refuter.** Median difference below +20 %, or the isolated arm slower. Either says
   isolation is not buying wall-clock and the runbook should stop implying it does.

2. **Injection — the contaminated arm's `cacheCreationTokens` median is ≥ 15 % higher, and
   `inputTokens` is NOT.** Point estimate **+25 % on `cacheCreationTokens`**.

   **Mechanism.** `SessionStart` and `UserPromptSubmit` hook output is prepended to the
   conversation, so it lands in the cached prefix that is *created* on the first turn, not in
   the per-turn `inputTokens`. The isolated arm's `inputTokens` sits in a very tight band —
   1,344–1,434 across nine runs, a 6 % spread — which is what a fixed task prompt looks like.
   If injection is real, the two token columns must move differently. **If both move together,
   the mechanism is wrong** and something is inflating the whole context rather than its
   prefix.

   **Refuter.** `cacheCreationTokens` under +15 %, **or** `inputTokens` moving by more than
   its own baseline spread (>6 %). The second half can refute this while the first half holds,
   and that would be the more informative failure.

3. **The verdict does not move — both arms pass the evaluator 5 of 5.**

   **Mechanism.** No user hook can deny a tool call on this path, and the injected text is
   generic developer guidance, not task guidance: nothing in it mentions shipments,
   idempotency or error envelopes. BE-003 was passed 14 of 14 times by two runtimes already.
   **A plain agent under this contamination should still clear the gates.**

   **Refuter.** Any evaluator failure in either arm. If it happens in the contaminated arm,
   the correct classification is the one `GUARDRAILS.md` insists on: check whether the run was
   **blocked** rather than **wrong** before recording it as a capability failure. This project
   has already recorded a permission-blocked run as F05, incorrect code, once.

4. **Tool calls rise in the contaminated arm — median ≥ +2 calls.** Point estimate **+3**.

   **Mechanism.** The injected preamble on this machine instructs an agent to prefer specific
   discovery tools and to check things before acting. That is a disposition to *look more*.
   The isolated arm's median is 17 tool calls, range 14–20.

   **Refuter.** Median difference of 0 or negative. That would mean context injection of this
   size changes cost without changing behaviour — which would make prediction 2's channel
   real but inert, and would be the strongest single argument that isolation is a
   cost-control rather than a validity control.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

Exactly one: **whether `--setting-sources project` is passed to `claude`.**

`run-agent.sh` line 417 adds that flag and nothing else when `--isolate-user-settings` is set.
Every other claude argument is identical in both arms and is constructed unconditionally at
lines 407–411: `--permission-mode acceptEdits`, `--strict-mcp-config`,
`--disable-slash-commands`, `--allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"`, `--model`.

**`--strict-mcp-config` is on in both arms**, so MCP servers are not part of this treatment.
The contamination measured here is user settings and user memory, not tools.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | Absence of `--setting-sources project`, which lets `~/.claude/settings.json` and user-level memory load |
| Content hash | `~/.claude/settings.json` sha256 `d1dd328b9316`, 23 registered hook entries across 8 events · `~/.claude/CLAUDE.md` sha256 `5fd1bc2ee124`, 24 lines |
| Preflight assertion | **≥ 1 `claude_code.hook_execution_start` log record carrying this run's `observatory.run.id`**, read from `infra/telemetry-out/events.jsonl` |
| Control assertion | **Exactly 0 such records** for every isolated run id, with `claude_code.hook_registered` > 0 on the same run |

### AMENDED 2026-09-03T13:35Z, before the batch — the run-record half of both assertions is struck

Both rows above originally also required `userSettingsIsolated` to read `false` on the
treatment and `true` on the control. **That field cannot be read on this instrument**, and the
amendment is made here, in the open and before the data, rather than by quietly reporting
against a weaker rule. The observatory's own CLAUDE.md says why that matters: *"Do not add an
escape hatch. If you need one, the registration was wrong and should be amended in the open."*

**What was found.** The API serving `localhost:8081` returns a four-key `runtime` block —
`provider`, `product`, `version`, `model` — and no `userSettingsIsolated` at all, not even
`null`. The container is `agent-observatory-observatory-api-1` in the **colima** docker
context, **built 2026-08-30**. Migration `V6__agent_surface.sql` and the fields it adds were
merged after that and are on `main`; `run-agent.sh:850` sends
`userSettingsIsolated`, `shimsStripped` and `surface` on every run, and the process receiving
them has no columns to put them in. The first E-002 run, `4c891809`, went in with
`--isolate-user-settings` and came back with the key absent.

**This is a finding about the instrument, not a workaround for the experiment**, and it is
recorded as one in `HANDOFF.md`. The project's documents describe V6's surface recording as
done. On the running instrument it is **L3**: a migration file exists, a runner sends the
values, and nothing persists them. That is this project's signature failure mode — a control
that reports success over a scope smaller than it claims — appearing in the instrument that
judges everything else.

**Why the batch proceeds rather than halting.** The replacement proof is stronger than the one
it replaces, and it was already the primary assertion:

- `userSettingsIsolated` records **what the runner was told to do** — configuration.
- `claude_code.hook_execution_start` records **what actually ran** — execution.

The project has already paid once for confusing those two. Run `4c891809` demonstrates the
distinction live: **23 `claude_code.hook_registered` and 0 `claude_code.hook_execution_start`.**
The operator's 23 hook entries were registered in the isolated run and not one of them fired,
which is exactly what `RUNBOOK.md` claims for `--setting-sources project` and is here observed
rather than trusted. `hook_registered > 0` is retained in the control assertion as the
two-sided guard: it proves the telemetry channel for that run is alive, so a zero execution
count means *no hooks ran* rather than *no data arrived*.

**Not done here, deliberately.** Rebuilding the API would apply V5 and V6 to the database
holding all 191 runs on record, while simultaneously introducing a Spring Boot minor and a
Kotlin major bump merged today that have never run against this data. That is a change to the
instrument and a migration of the only copy of the project's evidence, and it is not something
to do unattended in the middle of a batch. B2's gate does not require it.

**Run `4c891809` stays in the isolated arm.** It started at 13:07:19Z, after this file's
prediction commit at 13:06:46Z, under the same harness, model and benchmark tree as the rest.
Nothing about it is disqualifying; it is run 1 of 5.

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.

**The counter was validated two-sided AND against a documented number before being used**,
because a counter that returns 0 on everything is indistinguishable from an isolated run:

| population | runs | runs with hook events | total |
|---|---|---|---|
| `EXP-BE002-CLAUDEMD-V2` — un-isolated | 36 | **36** | 618 |
| `EXP-BE002-AGENTSMD-V3` — un-isolated | 20 | **20** | 661 |
| `EXP-B2-BASELINE-CLAUDE` — isolated | 9 | **0** | 0 |
| `EXP-BE002-NOHOOKS` — isolated | 21 | **0** | 0 |
| `EXP-B2-REHEARSAL-CLAUDE` — the cmux-shim run | 1 | 1 | **26** |

The last row is the check that matters. `RUNBOOK.md` §0 records, from before this counter
existed, that a terminal shim *"added **26 hook executions** to the first rehearsal."* The
counter reproduces that number exactly, on a run it was never fitted to.

**Registration is not execution**, and this project has already made that mistake once: the
22 user hooks are still *registered* in an isolated run and none of them run. The counter
counts `hook_execution_start`, so it measures execution.

## Controlled variables

- [x] starting commit / benchmark revision SHA — `0448643`, and `git diff 8aadc75..0448643 -- tasks/ sample-service/` is **empty**: the measured artifact is byte-identical to the one the nine baseline runs used, only reviewer and CI scaffolding moved
- [x] task + revision — BE-003 `confirm-shipment`, unchanged
- [x] harness + version — `claude-code 2.1.259`, identical across both arms of THIS experiment
- [x] model — `claude-haiku-4-5-20251001`, the exact id the B2 claude arm registered
- [x] permissions / permission mode — `acceptEdits` + the same two-entry `--allowedTools`, both arms
- [x] environment — `--strict-mcp-config` and `--disable-slash-commands` in both arms; the shim strip is reported per run and asserted equal
- [x] runner commit — recorded per arm; identical across arms

**Known to have moved since the nine baseline runs, and named rather than hidden:** the
harness version, the observatory runner (obs#70 wired the run-record schema into an executing
validator), and the observatory API's own dependencies. None of the three differs *between
the two arms of this experiment*, which is why the comparison is internal.

## Runs

Repetitions per arm: **5** · Total budget: ~$1.60 at the baseline arm's median of $0.1487

*One run is a story. Five is a hint. Ten is the minimum for a decision.* At n=5 per arm
nothing below is stated as a property — every result is reported as *"true of these runs"*.

Keys, named so an arm cannot be mistaken for a treatment of the baseline:

- `EXP-B2-CONTAM-ISOLATED` — control, `ISOLATE_USER_SETTINGS=1`
- `EXP-B2-CONTAM-OPEN` — treatment, flag omitted

## Minimum detectable effect

Derived from `EXP-B2-BASELINE-CLAUDE`, n=9, which is the only measured arm of this task.

| Outcome | baseline median | baseline spread | MDE at n=5/arm | registered before the run? |
|---|---|---|---|---|
| primary: `durationMs` | 83,000 ms | 70,000–3,790,000 | **±20 %** on medians | yes |
| secondary: `cacheCreationTokens` | 24,396 | 20,123–26,974 (±14 %) | **±15 %** | yes |
| secondary: `inputTokens` | 1,402 | 1,344–1,434 (±6 %) | **±6 %** | yes |
| secondary: `toolCalls` | 17 | 14–20 | **±2 calls** | yes |
| gate: evaluator `passed` | 9/9 | — | any failure | yes |

**The duration MDE is the weak one and it is weak by inheritance.** The baseline's own
duration range spans a factor of 54 because of the unexplained tail. The matched pair is what
makes ±20 % readable at all, and if the new isolated arm reproduces that tail, duration is
excluded from this experiment too and prediction 1 is recorded as **unsettleable** rather than
refuted.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` at benchmarks `0448643`, evaluator version
`1.0.0`, exit codes unchanged. The evaluator decides pass/fail, not the agent and not this
file. Rubric scoring, where used, is `benchmark/rubrics/backend-quality.yaml` at its
registered sha `396e1799eb2b` via `codex-score.sh --run-id`, admitted only through
`check-run-gate.sh`.

## Exclusions

Registered now, before the data exists:

- F13 / F15 infrastructure failures — discarded and named, per the shared exclusion rule in
  `baseline-report.py`
- a run missing a measurement is excluded **from that metric only** and still counted in the
  output; it is not dropped from the arm
- an F03 is **kept** — the agent being wrong is the measurement
- a run whose `shimsStripped` differs from its arm's others is excluded and named: a run
  launched under a terminal wrapper is a different experiment
- **duration is excluded wholesale if either arm reproduces the 2026-08-30 tail** (any run
  beyond 10× its arm's median), and prediction 1 then reports as unsettleable

## Decision rule

Registered before data.

| result | verdict |
|---|---|
| ≥ 2 of predictions 1, 2, 4 hold **and** prediction 3 holds | **KEEP** the isolation requirement, and B2's runbook keeps its mandatory `ISOLATE_USER_SETTINGS=1` with a measured number attached instead of an argument |
| prediction 3 fails in the contaminated arm | **KEEP, and escalate** — contamination changes the verdict, not just the cost, which makes isolation a validity control and raises the severity of every un-isolated run already on record |
| predictions 1, 2 and 4 all fail and 3 holds | **INCONCLUSIVE, leaning REJECT-as-stated** — isolation would be buying something this experiment cannot see. Record it; do not remove the flag on one experiment |
| the preflight or control assertion fails | **VOID.** No treatment was delivered, or the control received it. Nothing below is reportable |

---
*Everything below is filled in AFTER the runs.*
---

## Timestamp check

| | |
|---|---|
| this file committed at | *(filled after the runs, from `git log`)* |
| first run `startedAt` | *(filled after the runs, from the run record)* |

## Observed telemetry

## Results

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |

## Failure analysis

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

## Follow-up
