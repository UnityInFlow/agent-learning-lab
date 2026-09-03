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
| predictions committed | **`59ac936`, 2026-09-03T13:06:30Z** |
| clerical timestamp fix | `0e0c6f9`, 13:06:46Z — changed the `Predicted by` clock only, no prediction touched |
| **first run `startedAt`** | **`4c891809`, 2026-09-03T13:07:19Z** |
| ordering | **the prediction commit precedes the first run by 33 seconds.** Read from `git log --date=iso-strict-local` and from `GET /api/runs/4c891809.../startedAt`, not from prose |
| last run `startedAt` | `017c2654`, 13:29:17Z |

**One irregularity, flagged here rather than left for a validator to find.** The
control-assertion amendment is `3fc71c1` at **13:13:10Z**, which is *after* run 1
(13:07:19Z) and *before* runs 2–10 (13:13:28Z onward). Its commit message says "zero runs of
the batch exist at this commit"; that is wrong as written — run 1 existed and had finished.
What is true, and what matters: **no prediction was altered at any point**, the amendment
changed only which channel proves the manipulation, and run 1's manipulation result (0 hook
executions) was already recorded before the amendment was written. Nine of ten runs postdate
it.

## Observed telemetry

`claude_code.hook_registered`, `claude_code.hook_execution_start` and
`claude_code.plugin_loaded`, filtered on `observatory.run.id` in
`agent-observatory/infra/telemetry-out/events.jsonl`.

**Both assertions hold on all ten runs, with no overlap between the arms:**

| arm | hooks registered | **hooks executed** | plugins loaded |
|---|---|---|---|
| isolated, n=5 | 23, 23, 23, 23, 23 | **0, 0, 0, 0, 0** | 0 on all five |
| open, n=5 | 24, 24, 24, 24, 24 | **27, 29, 31, 33, 48** (median 31) | **2 on all five** |

Registration is near-identical and execution is disjoint — the distinction this project
already paid to learn, reproduced on demand. The open arm also registers **one more** hook
than the isolated arm (24 vs 23) and loads two plugins the isolated arm never sees.

## Results

Median and range. No mean is computed anywhere below.

| outcome | isolated n=5 | range | open n=5 | range | Δ median |
|---|---|---|---|---|---|
| duration (ms) | 90,000 | 64,000 – 112,000 | 105,000 | 70,000 – 121,000 | **+16.7 %** |
| **`inputTokens`** | **1,416** | 1,392 – 1,424 | **170** | 106 – 250 | **−88.0 %** |
| `cacheCreationTokens` | 26,119 | 19,522 – 29,901 | 30,573 | 25,688 – 32,973 | **+17.1 %** |
| `cachedTokens` | 671,203 | 557,246 – 788,835 | 781,631 | 450,002 – 1,188,265 | +16.5 % |
| `outputTokens` | 6,675 | 5,502 – 8,983 | 7,087 | 5,616 – 7,504 | +6.2 % |
| `estimatedCost` | $0.1541 | $0.1237 – $0.1850 | $0.1754 | $0.1246 – $0.2177 | **+13.8 %** |
| `toolCalls` | 18 | 15 – 22 | 18 | 17 – 28 | **0** |
| `modelCalls` | 22 | 19 – 23 | 21 | 13 – 31 | −4.5 % |
| files changed | 3 | 3 – 3 | 3 | 3 – 3 | **0** |
| evaluator passed | **5/5** | — | **5/5** | — | 0 |

**The duration tail did not reproduce, so duration is settleable.** The registered exclusion
said duration would be dropped if either arm produced a run beyond 10× its arm's median. The
worst ratio here is **1.75×** (64 s to 112 s), against a factor of 54 in the 2026-08-30 batch.
Two things differed: the runs were interleaved rather than batched per arm, and the machine
did not sleep. This does not identify the 2026-08-30 cause — it removes duration from the list
of things E-002 cannot see.

## Which predictions held

**One of four.** The predictor over-predicted magnitude for the third time running.

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | duration median ≥ +20 % higher (est. +35 %) | **NO** | **+16.7 %.** Below the threshold, and *closer to the ~13 % prior from `EXP-BE002-NOHOOKS` on a different task than to the +35 % estimate that dismissed it.* The refuter fired exactly as written |
| 2 | `cacheCreationTokens` ≥ +15 % **and** `inputTokens` not moving beyond its 6 % baseline spread | **NO** | **first half held (+17.1 %), second half refuted catastrophically: `inputTokens` fell 88 %.** The refuter named this as the more informative failure, and it was |
| 3 | both arms pass the evaluator 5 of 5 | **YES** | **5/5 and 5/5.** Also 3 changed files on all ten runs |
| 4 | `toolCalls` median ≥ +2 higher (est. +3) | **NO** | **0.** Medians identical at 18, ranges overlapping |

### Prediction 2 is the one worth reading twice

The mechanism said injection would land on the cached prefix and leave `inputTokens` alone.
It was half right in a way that matters more than being wrong: the prefix did grow, **and
`inputTokens` collapsed by an order of magnitude** — 1,392–1,424 isolated against 106–250
open, two bands that do not come close to touching.

**The contamination does not only add tokens. It moves them between buckets.** With hook
output prepended, the ~1,400-token task prompt lands *inside* the cached prefix, so what is
counted as uncached input is only the small remainder. Total context went **up** (+17 % cache
creation, +16.5 % cached, +13.8 % cost) while the column named `inputTokens` went **down 88 %**.

**Anyone comparing `inputTokens` across isolation regimes would conclude the contaminated arm
was 88 % cheaper on that axis.** It is 14 % more expensive. `inputTokens` is not comparable
between an isolated and an un-isolated run, and nothing in the run record says so.

The observatory's own CLAUDE.md states the general case: *"A metric that changes definition
silently makes two experiments incomparable while both still look valid — which is
indistinguishable, later, from an effect."* Nobody changed a definition here. **The
environment changed which bucket the tokens fall into, which has the same consequence and no
commit to point at.**

## Failure analysis

> Before blaming the agent, ask what else changed.

Nothing failed: 10 of 10 runs passed the evaluator and every run changed the same three files.
The interesting failures are in the predictions and in the instrument.

**The instrument, and it is the session's larger finding.** The API serving these runs is a
container built 2026-08-30 in the colima docker context. It returns a four-key `runtime`
block and **silently drops `userSettingsIsolated`, `shimsStripped` and `surface`** — the V6
fields `run-agent.sh:850` sends on every run. Meanwhile the *runner-side* validator from
obs#70 is live on the host and **accepts and asserts those same fields**: feeding it a payload
carrying `userSettingsIsolated: true` exits 0.

So the record is **validated on the way out and truncated on the way in.** V6's surface
recording, which `HANDOFF.md` and both `CLAUDE.md` files describe as done, is **L3 on the
running instrument**: a migration file exists, a runner sends the values, a validator checks
them, and nothing persists them. That is this project's signature failure mode — a control
reporting success over a scope smaller than it claims — sitting inside the instrument that
judges everything else.

**It was not the agent, and it was not the hooks.** It was a four-day-old process.

## Sanity checks

- [x] **Did any dramatic number appear? Has it been explained *and* the explanation tested?**
      Yes — `inputTokens` −88 %. Explained by cache-bucket migration. **The explanation is
      testable and has passed one test:** if the tokens had genuinely vanished, total cost
      would have fallen; cost rose 13.8 %, and `cacheCreationTokens` rose 17.1 %, which is
      where the mechanism says they went. It has **not** been tested against a run with hooks
      but no injected text, which would separate "prefix grew" from "prefix grew *because of
      hook output*". Registered as follow-up 2.
- [x] **Did any flattering number appear? Has it been disbelieved twice?** Yes, and it is the
      one that flatters the *runbook*: "isolation removes contamination" is easy to read into
      +16.7 % duration and +13.8 % cost. Disbelieved twice: (1) prediction 1's own threshold
      was not met, so the effect is smaller than this file predicted; (2) **the two behavioural
      columns did not move at all** — identical tool-call medians, identical changed-file
      counts, 5/5 both arms. On the outcomes measured, contamination bought a bill, not a
      different answer.
- [x] **If a fix motivated this run, did the original symptom actually disappear?** The
      original symptom was the 2026-08-30 duration tail. It did **not** appear here — but
      nothing was fixed, so this is a non-reproduction under a different design, not a repair.
      Recorded as such.

## Decision

**INCONCLUSIVE, leaning REJECT-as-stated** — the third row of the registered decision table,
fired exactly as written: *predictions 1, 2 and 4 all fail and 3 holds*.

The registered consequence is *"isolation would be buying something this experiment cannot
see. Record it; do not remove the flag on one experiment."* That is the verdict and it stands.

**What that verdict does and does not mean.** It does **not** mean the contamination is
absent — it is present and consistent, at **+13.8 % cost, +17.1 % cache creation, +16.7 %
duration, 31 hook executions and 2 plugins per run**. It means every threshold this file
registered in advance was set too high, and the outcomes that would have made isolation a
*validity* control rather than a *cost* control did not move: same verdict 10/10, same three
files changed 10/10, same tool-call median.

**So on BE-003, at n=5 per arm, and on the outcomes measured, `ISOLATE_USER_SETTINGS=1` is a
cost control.** Stated as true of these runs, not as a property.

**The reason not to weaken the runbook on this evidence is in what was not measured: quality.**
The rubric was applied to one run of ten. Contamination could change *what* the agent writes
without changing pass/fail, tool counts or file counts, and `toolCalls` is a weak proxy for
behaviour. Until both arms are scored, "isolation is a cost control" is a claim about
efficiency and outcome only, and the flag stays mandatory.

**KEEP `ISOLATE_USER_SETTINGS=1` in the runbook**, now with a number attached instead of an
argument, and with the argument corrected: it is not that you would measure your hooks instead
of the baseline — you would measure the same baseline and pay 14 % more for it, in a record
whose `inputTokens` column would be uncomparable.

## Adversarial review, and what it changed

`tools/opencode-review.sh -n 2` over this file and the B2 workbook, 2026-09-03.
**Findings: [`findings/opencode/review-E-002-isolation-contamination-20260903T134641Z.md`](../findings/opencode/review-E-002-isolation-contamination-20260903T134641Z.md)**
· line-level `lab-critic` on `ollama-cloud/glm-5.2`, 2 runs, both completed (188 s, 239 s)
· acceptance `lab-acceptance` on `ollama-cloud/minimax-m3` → **ACCEPT**, `blocking: []`.

**It was run explicitly, because the push hook did not fire.** `.claude/settings.json` wires
it as `PostToolUse` with `if: Bash(git push:*)`, and no findings file was written by any push
this session — the known cause is that the settings watcher does not arm a hook it did not see
at session start. `experiments/*.md` is in `CONTRACT_GLOBS`, so this file was in scope and
would have shipped unread.

**Finding 2 is the one that changes what this experiment may claim, and it is right.**

> *"The decision table has no row for 'predictions unsettleable by MDE rather than refuted' — a
> state the MDE column itself admits is possible."*

The registered MDE for duration is **±20 %** and the observed difference is **+16.7 %**. The
MDE for `toolCalls` is **±2** and the observed difference is **0**. **Both fall inside the band
this file registered as its own detection limit.** Prediction 1's refuter fired literally —
"median difference below +20 %" — but a +16.7 % observation cannot separate a true +16.7 %
effect from a true +20 % one at n=5. Calling those two predictions **refuted** overstates the
evidence; the accurate word is **not detectable at this n**.

**This is corrected here rather than by editing the predictions or the results.** The
predictions stand as written, the *Which predictions held* table stands as written, and this
section is the amendment:

| # | as stated above | corrected reading |
|---|---|---|
| 1 | refuted, +16.7 % < +20 % | **inside the registered MDE.** Direction is positive and consistent, magnitude is not resolvable from ±20 % at n=5 |
| 4 | refuted, Δ 0 | **inside the registered MDE** of ±2 calls. "No effect" and "an effect smaller than 2 calls" are the same observation here |
| 2 | refuted | **stands as refuted.** `inputTokens` moved 88 % against a 6 % band — an order of magnitude outside any reading of the MDE |
| 3 | held | **stands as held.** 10/10 is not a threshold question |

**What survives, and what does not.** The *Decision* below is unchanged — it already read
**INCONCLUSIVE**, and finding 2 strengthens the INCONCLUSIVE half rather than moving the row.
What does not survive is any sentence implying this experiment *measured* the duration and
tool-call effects to be small. **It measured them to be smaller than it can see.** The costs
that are resolvable are `inputTokens` (−88 % against a 6 % band), `cacheCreationTokens`
(+17.1 % against a 14 % band — marginal), and the hook and plugin counts, which are disjoint
and not threshold-limited at all.

**The other four findings, answered.**

1. **"MDE entries equal the prediction thresholds, conflating what-matters with a statistical
   minimum detectable effect."** **Accepted, and it is the root of finding 2.** The MDE column
   was populated with the same numbers as the refuters instead of being derived from each
   outcome's variance and n. A real MDE at n=5 per arm, given the isolated arm's duration
   spread, is considerably wider than ±20 %. **Registered as follow-up 6:** the next experiment
   derives its MDE from the measured arm before writing any threshold, and if the threshold
   lands inside the MDE the prediction is not worth registering in that form.
2. **"'settleable' is used in two senses."** **Accepted.** Tail-exclusion not firing and the
   detection limit being reached are different things, and this file used one word for both.
   Duration is *admissible* here — no run exceeded 10× its arm's median — and simultaneously
   *not resolvable* at ±20 %. Both are now stated separately above.
3. **"Prediction 2's text and its refuter give two different thresholds."** **Accepted as a
   drafting defect.** The text says `inputTokens` "is NOT [≥15 % higher]"; the refuter says
   "moving by more than its own baseline spread (>6 %)". Both land on the same row in this
   outcome, and the refuter is the reading used — an 88 % fall refutes either. Recorded, not
   silently reconciled: **a prediction with two thresholds is one prediction too few.**
4. **"The cache-migration explanation is asymmetric."** **Accepted, and completed here.** The
   isolated arm has no hook output, so the ~1,400-token task prompt is the *first* thing in the
   context and is counted as uncached input on the first turn. The open arm prepends hook
   output, so the prompt sits behind a cache breakpoint and only the remainder is counted as
   input. Same prompt, same tokens, different column.

**The disputed finding was disputed correctly**, and by the acceptance model rather than by me.
The critic claimed the B2 README's *"three times out of three"* is stale against CLAUDE.md's
3-of-5 amendment. It is not: the README sentence is about `change-focus` disagreement on the
first three scored runs, and the amendment is about the five-run cohort. Different claims about
different populations. **No change made.**

## Follow-up

1. **Score both arms, 5 and 5, on the registered rubric.** This is the only way to test the
   decision above. One isolated run is scored (`4c891809`: architecture 2, **maintainability
   2**, test-quality 1, change-focus 1 — the B2 baseline profile with maintainability at 2),
   and the hand re-derivation of its maintainability cell agrees at 2. Nine runs unscored.
2. **A hooks-without-injection arm**, to separate "the prefix grew" from "the prefix grew
   because hooks wrote into it". Needs a settings file with `PreToolUse`/`PostToolUse` hooks
   and no `SessionStart`/`UserPromptSubmit` ones.
3. **`inputTokens` needs a comparability warning in the analyzer**, the way telemetry gaps got
   one. Two arms differing in isolation regime cannot have this column compared, and today
   nothing says so. Observatory issue.
4. **Rebuild the observatory API** so V6 lands, and re-check `userSettingsIsolated` on a fresh
   run. Deliberately not done inside this batch: it migrates the database holding all 201 runs
   and simultaneously introduces a Spring Boot minor and a Kotlin major merged the same day.
6. **Derive the MDE from the measured arm before writing a threshold**, and refuse to
   register a prediction whose threshold sits inside it. Raised by the adversarial review;
   see *Adversarial review* above.
7. **The codex sheet cited `ShipmentController.kt:64` for the `when` that is on line 65.** The
   score is right and the hand reading agrees; the citation is one line off. Small, and the
   same *class* as the opencode citation tic already on record — an anchor's citation
   instruction is prose nothing executes.
