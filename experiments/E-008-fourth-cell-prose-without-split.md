# Experiment E-008 — E-007's fourth cell: the worker's prose without the split

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`.

**Status: CLOSED VOID 2026-09-07 (decision rule row 0a — a control run delegated to a built-in agent). The registered question is unanswered; successor `E-009` carries it.** `Closed by Claude Opus 5 (claude-opus-5), autonomous, 2026-09-07` — the predictions above were registered by Claude Fable 5.1 earlier in the same session, before the orchestrator model was changed by the author mid-batch; neither is the agent under test. Follow-up experiment of
[`E-007`](E-007-orchestration-overhead.md), ordered by **author decision 10.1** (§3 of the
Track B prompt, prompt sha `92d4f1e3332d`), which names the arm, the `n`, the delivery route,
the registered outcome and the two readings; this file registers the numbers. Spine stop 11
(Phase 4B, `lab#14`) is closed; this cell runs **before stop 12 registers anything**, because
BE-004's B5 arms inherit the same overlay body and an unanswered cell would carry the confound
into the new task.

`Predicted by Claude Fable 5.1 (claude-fable-5-1), in a hand-started session, 2026-09-07T11:5xZ;
the author did not review before the run.` The prompt's provenance line names Opus 5; this
session is not Opus 5 and the line above says what it is, as the 2026-09-05 session's did.

Experiment key: **`EXP-4B-FOURTH-CELL`** · preflight pair on **`EXP-4B-FOURTH-CELL-PREFLIGHT`** ·
branch `stop11/fourth-cell`.

## Question

E-007 detected exactly one effect: `test-quality` anchor 2 on **5 of 10** arm-O runs and **0 of
10** controls (codex, rubric `396e1799eb2b`, two-sided Fisher `p = 0.0325`). On all twenty sheets
the difference reduces to one rubric clause — *was the persisted state re-read through a separate
`get(...)`*. The registered treatment was the **split** (orchestrator → `implementer` via `Task`)
*including* the worker's four-line body, which tells it to write *"tests for every case it
names"*. E-007's deliberate failure (P2) showed the `tools:` line moves nothing. **So: is that one
effect the decomposition, or the prose the decomposition happened to carry?**

## Hypothesis

**The prose.** The mechanism is in the task text, not in the agent topology. BE-003 names four
cases, and the second is *"confirming a shipment that is already `CONFIRMED` succeeds **and
changes nothing**"*. A test written *for that case* has to prove that nothing changed, and the
only way to prove it is to read the shipment back after the second call — which is anchor 2's
missing clause, verbatim. The plain control writes tests too (`test-quality` was **1 on 10 of 10**
E-007 controls: a body is read, but at least one clause is absent), so the instruction does not
create testing; it changes *which* cases get a test. A worker receives that instruction as its
agent body; a plain session can receive the same words as `CLAUDE.md`. If the words are the cause,
the route should not matter much. If the split is the cause — a fresh context that re-reads the
ticket from scratch instead of skimming it — the words alone should land near the control.

Second mechanism, weaker: the four-row report shape has a line *"Tests — what each new or changed
test covers"*, which makes a test per named case the thing the model has to have something to say
about. It is not separable from the first mechanism here and is not claimed separately.

## Predictions

Reference populations, both re-derived from the API rather than copied from prose:

- **E-007 arm C** (the concurrent plain control, `EXP-4B-ORCH-OVERHEAD`, `n = 10`, 2026-09-06,
  runtime 2.1.263): `test-quality` **1 on 10 of 10**, anchor 2 on **0 of 10**; `addedLines`
  median **64** (q1–q3 62–67, range 56–72); `modelCalls` median **22** (20–26); `estimatedCost`
  median **$0.1462**; `durationMs` median 88 s (54–126); evaluator pass 10 of 10.
- **E-007 arm O** (the split, same batch): anchor 2 on **5 of 10**; `addedLines` median **90**
  (81–102); `modelCalls` **26**; `estimatedCost` **$0.1266**.
- **Historical plain controls on BE-003 with this model**, from a census of every codex sheet
  on file that scored an observatory run, joined to the run record: see § Minimum detectable
  effect, row *control interval* — written before the run, from the census, and the census
  script and output are committed beside this file.

| # | Outcome | Direction · magnitude | Mechanism |
|---|---|---|---|
| **P1** (primary, the registered outcome) | `test-quality` anchor 2 count, codex, rubric `396e1799eb2b`, per arm at `n = 10` | fourth cell **4–7 of 10**, control **0–1 of 10**; two-sided Fisher against the concurrent control **`p < 0.05`**, and against arm O's 5 of 10 **`p ≥ 0.05`** — i.e. **reading (a)** | the *"changes nothing"* case + *"tests for every case it names"* → a test that re-reads state after the second confirm. **Registered as the prediction most likely to be wrong in magnitude**: a worker gets the prose as its whole system prompt; a plain session gets it as project memory beside the ticket, which is a weaker position for the same words (E-003 measured zero effect from a 57-word `CLAUDE.md`) |
| **P2** | `addedLines` median | fourth cell **≥ control + 15** (E-007's split added +26, mostly tests) | one more test method and its re-read; reported beside P1 as decision 10.1 asks |
| **P3** | `modelCalls` median | fourth cell **within ±3** of the control (22) — **no** +4 | no orchestrator turns to delegate, read the report and summarise; a difference of ≥ +4 with non-overlapping quartiles would mean the prose changes the *loop*, not only the tests, and is reported as such |
| **P4** | `estimatedCost` median | fourth cell **−10 % to +15 %** of the control; **not detectable** under E-007's +25 % MDE | one context, one cache prefix; the extra test costs output tokens only |
| **P5** | delivery — `customization.instructionsHash` | **`sha256:51f16eeb1618cd212405818c5165dcba` on 10 of 10** treatment runs, **`null` on 10 of 10** controls | the runner hashes the worktree's `CLAUDE.md`; the control's worktree has none (allowlist `sample-service` + `.gitignore`). Not an outcome — a void condition (row 0a) |
| **P6** | delegation — `tool_result` events with `tool_name ∈ {Task, Agent}` | **0 on 20 of 20** | no `.claude/agents/` is installed; a session with nothing to delegate to does not delegate. Not an outcome — a design check (row 0a) |
| — | evaluator pass rate, `durationMs`, `maintainability`, `change-focus`, `architecture-consistency` | **report only** | pass was 10/10 in both E-007 arms; the other three rubric cells did not separate the split from its control and no mechanism here reaches them |

**The two readings, written before the run, as decision 10.1 requires:**

- **(a)** the fourth cell reaches anchor 2 at a rate separated from its own control and not
  distinguishable from arm O's 5 of 10 → **the effect is the prose**. E-007's *"the split
  returned nothing the gate can see"* stands, with its one detected effect reattributed from the
  decomposition to the worker's instruction, by a dated amendment to E-007 — the registered
  verdict is not edited.
- **(b)** the fourth cell is **not** separated from its control while arm O was → **`test-quality`
  is a return from the split**. E-007 is amended to say it measured a benefit its decision rule
  could not name.
- A result that fits neither is reported as such (rows 0b and 3 below).

## Independent variable

**One thing:** the presence of `CLAUDE.md` in the worktree root carrying, byte for byte, the body
of `build/customizations/orchestration-4b4-P1/.claude/agents/implementer.md` (its lines 7–16: the
paragraph beginning *"Implement the task you were given, in this repository, with tests for every
case it names"* and the four-row report shape). **No** `.claude/agents/`, **no** `--agent`, **no**
split. The overlay directory is `build/customizations/implementer-prose-4b4/` and holds exactly
that one file.

## How the treatment is delivered — and proved

| | Fourth cell (arm F) | Control (arm C) |
|---|---|---|
| Mechanism | `run-agent.sh --customization build/customizations/implementer-prose-4b4` — copied into the worktree root, force-added and committed as the setup commit (author decision 2), **no `--agent`**. This is E-003's route, chosen by decision 10.1 so the cell is directly comparable to E-003 | no `--customization`, no `--agent` |
| Content hash | `CLAUDE.md`: full SHA-256 `51f16eeb1618cd212405818c5165dcba0c13188f411ac966f9142ef08d478d72`, 75 words, 9 lines. **The runner records the first 32 hex characters**, so the run-record value is `sha256:51f16eeb1618cd212405818c5165dcba`. Verbatim-ness is asserted by the driver: `diff <(tail -n +7 …/implementer.md) …/CLAUDE.md` must be empty | — |
| Preflight assertion (§4 step 5 / decision 10.1's read-back) | one run on `EXP-4B-FOURTH-CELL-PREFLIGHT`: run record `customization.instructionsHash` **equals** the hash above; `init.tools` recorded and carries no `Task` restriction (the full pool); 0 delegation events; evaluator exit recorded | one run on the same key: `instructionsHash` **`null`**, `skillsHash` and `agentHash` `null`, 0 delegation events |
| Per-run proof in the batch | the driver reads `instructionsHash` back from the API for every run and writes it to the manifest; a treatment run whose hash differs, or a control whose hash is non-null, is row 0a | same column |
| What cannot be proved from the run record | that the runtime *read* the file. E-003 §Delivery: the runner refuses an instruction file the runtime does not read (filename half, L2); the content half is this table. The activation proof E-004 had (`skill.source`) has no equivalent for `CLAUDE.md` |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.

## Controlled variables

Held equal to E-007 and asserted per batch by `evidence/p04b/lab-4b4/run-e008.sh` before the
first run, each guard driven to fire by `verify-run-e008.sh`:

- [x] benchmark revision: benchmarks `HEAD` is **`eea144e`** (benchmarks#29 merged), which E-007
      ran at `0448643` did not have. **The BE-003 task tree is byte-identical across the two**:
      `git rev-parse <sha>:tasks/BE-003-confirm-shipment` = `eeb15a753adc94e92bc3f74c50e1b02fc3b53030`
      at both. The driver asserts the *tree hash*, not the commit — a commit guard would either
      pin a sha that no longer exists on `main` or admit any future change to BE-003
- [x] task: BE-003 confirm-shipment, `evaluator.sh` version `1.0.0`
- [x] harness: Claude Code **`2.1.263`** — E-007's actual runtime (its file registered 2.1.261 and was
      already wrong when committed; disclosed there). Asserted by the driver; a bump stops the batch
- [x] model: **`claude-haiku-4-5-20251001`**, `MODEL=` on every run, read back from `runtime.model`
- [x] permissions: `ISOLATE_USER_SETTINGS=1` (0 hook executions, `settings` sources isolated), the
      runner's flag array unchanged including `--disable-slash-commands` (no skill is a treatment here)
- [x] environment: `KEEP=1`, interleaved F/C pairs, no machine sleep (`caffeinate -i`), no other
      benchmark, scorer or review process of this lab's during the batch (`LC_ALL=C pgrep` before
      each pair, and the driver warns), the observatory reached through the colima tunnels
      (`API_PORT=18081 OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 TEMPO_PORT=13200`)
- [x] runner commit: agent-observatory `b818c56` (obs#74, schema-verdict policy) — one commit past
      E-007's batch; the change is to the *declared-schema* verdict, which no arm here declares
- [x] rubric: `benchmark/rubrics/backend-quality.yaml` sha **`396e1799eb2b`**, asserted on every sheet

## Runs

**10 F + 10 C, interleaved as pairs, one experiment key**, preceded by one F + one C read-back
pair on `EXP-4B-FOURTH-CELL-PREFLIGHT` (not in any comparison). Budget ≈ 20 × $0.15 ≈ **$3**
plus scoring, ≈ 45 minutes. Driver: `evidence/p04b/lab-4b4/run-e008.sh`, a copy of
`run-e007-p2.sh`'s pair loop with the overlay guards replaced by this cell's — the manifest row
per run is the progress record, and the PID lockfile is the answer to *"is a batch running?"*.

## Minimum detectable effect

Derived from measured arms before any threshold above was written. The primary outcome is a
two-arm count at `n = 10` per arm; two-sided Fisher exact.

| Outcome | measured spread it comes from | MDE at `n = 10` per arm | registered before the run? |
|---|---|---|---|
| primary: anchor 2 count vs the concurrent control | E-007 control **0 of 10**; the historical control interval is the census row below | if the control is **0 of 10**: separated at **≥ 5 of 10** (`p = 0.0325`); 4 of 10 is `p = 0.087`, **not detectable**. If **1 of 10**: ≥ 6 (`p = 0.057` at 6 is *not* separated; **≥ 7**, `p = 0.020`). If **2 of 10**: **≥ 8** (`p = 0.023`) | yes |
| primary, second half: *not distinguishable from arm O's 5 of 10* | E-007 arm O 5 of 10 | any count **1–9 of 10** has `p ≥ 0.14` against 5 of 10; only **0** (`p = 0.0325`) or **10** is distinguishable. **This half has almost no power at `n = 10`**, said here so reading (b) is not over-read: a cell at 1 or 2 of 10 is "not separated from its control" *and* "not distinguishable from 5 of 10" at once | yes |
| control interval | census of historical BE-003 plain-control codex sheets on this model | **see the census line appended below before the prediction commit** | yes |
| P2 `addedLines` | control q1–q3 62–67 | **≥ +15** on the median with non-overlapping quartiles | yes |
| P3 `modelCalls` | control q1–q3 20–26 | a difference of **≥ +4** with non-overlapping quartiles is detectable (E-007 O4/O5 registered the same) | yes |
| P4 `estimatedCost` | control q1–q3 (E-007 C) | **±25 %** on the median, as E-003, E-006 and E-007 registered | yes |

**The `n` question the template asks.** Across the plausible control range 0–2 of 10 the primary
effect stays decidable only if the cell reaches 5, 7 or 8 of 10 respectively. Decision 10.1 fixes
`n = 10` per arm and the budget; **this file registers that `n` and says where it is weak** rather
than raising it: at a control of 2 of 10 the cell must *exceed* arm O to be separated, and that
outcome is read as row 3, not as a refutation. A larger `n` is the author's to fund (§7: a new
arm's size is a design change).

**A result inside its MDE is NOT DETECTABLE at this `n`, never refuted.** P1 makes the *"the arms
differ"* claim (two-arm test against the control that occurred) and not a one-arm claim.

### Census of historical plain controls — written before the prediction commit

Every codex sheet on file that scored an observatory run (95 unique run ids, 120 sheets, 25
fixture sheets excluded), joined to its run record through the API; script and output at
`evidence/p04b/lab-4b4/fourth-cell/census-test-quality.py` and
`census-test-quality-20260907T115210Z.txt`. First produced by a haiku subagent, then **re-run by
me** to produce the committed output, and two of its anchor-2 cells (`7695d0d1`, `ea2fcaa8`)
re-read by hand from the sheet and the run record (both `EXP-B3-CONTROL-CLAUDE`, `baseline`,
`instructionsHash: null`, `score: 2`).

Plain controls, `claude-haiku-4-5-20251001` on BE-003, no customization:

| batch | anchor 2 | `n` |
|---|---|---|
| E-007 concurrent control (`baseline-e007-window`) | 0 | 10 |
| E-006 batch-2 control (`EXP-B4-AGENT-BOUNDARY` / `baseline`) | 1 (+1 null) | 10 |
| E-003 control (`EXP-B3-CONTROL-CLAUDE`) | **2** | 10 |
| B2 baseline | 0 | 5 |
| arm-G window control | 0 | 5 |
| E-004 baseline (`EXP-P3-SKILL-DESC`) | 0 | 5 |
| three single-run keys (contamination-isolated, rehearsal, shim) | 0 | 3 |
| **pooled** | **3 of 48 = 6.2 %** | 48 |

**So the control interval 0–2 of 10 is the observed range, not a guess**, and the pooled rate
gives `P(c ≥ 3 at n = 10) = 0.021` — row 0b's threshold sits where a control that high is a
finding rather than noise. Treated arms that were *not* the split score like the controls:
E-003 instructions 1 of 10 (4 nulls), E-006 `agent-v1.0` 0 of 10, both E-004 skill arms 0 of 5,
arm G 1 of 5 — **2 of 35**. Arm O's 5 of 10 is the only arm of 17 on this task and model above
2. That is the size of the thing this cell is trying to reattribute.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` v1.0.0 (Kotlin build + two evaluator-owned suites),
exit code recorded per run; `tools/check-run-gate.sh` admits a run to scoring by the recorded
verdict (Decision D, path B). The evaluator decides correctness; the rubric scores only admitted
runs.

## Exclusions, registered before the data

- runs with evaluator exit ≠ 0, F13/F15 infrastructure failures, permission blocks, quota
  exhaustion: excluded from scoring and reported by count; the arm's scored `n` is reported
- `durationMs` on any run that overlapped another process of this lab's, or a machine sleep:
  duration excluded, the run kept (§4 step 6)
- a `test-quality` `null` (no test file, Decision A) counts as *not anchor 2* in P1's count and is
  reported separately; it is a measurement, not a missing cell
- the two read-back runs on the preflight key enter no comparison

## Decision rule, fixed before the run

Let `c` = control anchor-2 count and `k` = fourth-cell anchor-2 count, each out of the runs
admitted by the gate; `p_C` = two-sided Fisher of `k` vs `c`; `p_O` = two-sided Fisher of `k` vs
E-007 arm O's 5 of 10.

| # | Condition | Verdict |
|---|---|---|
| 0a | any treatment run with `instructionsHash ≠ sha256:51f16eeb1618cd212405818c5165dcba`, any control with a non-null `instructionsHash`, any run with ≥ 1 delegation event, any run on a runtime other than 2.1.263, or fewer than 8 admitted runs in either arm | **VOID** — the cell was not delivered as designed, or is under-powered past its registration; nothing below is read |
| 0b | `c ≥ 3` | **NOT DETECTABLE, and the finding is the control** — E-007's 0 of 10 is not reproduced; the plain baseline's anchor-2 rate is unstable across days and neither reading is available. Reported; E-007 is amended to say its control was low, not that its treatment was high |
| 1 | `c ≤ 2` and `p_C < 0.05` | **reading (a) — the effect is the prose.** If additionally `p_O < 0.05` (only `k = 10`), add: *the prose alone exceeded the split*, and P1's magnitude is refuted upward |
| 2 | `c ≤ 2` and `p_C ≥ 0.05` and `k ≤ 2` | **reading (b) — `test-quality` is a return from the split**, stated as *true of these runs* with `p_O` beside it (0.03–0.35): at this `n` a cell at 1–2 of 10 is also not distinguishable from 5 of 10 |
| 3 | `c ≤ 2` and `p_C ≥ 0.05` and `k ≥ 3` | **fits neither — NOT DETECTABLE at `n = 10`.** Both readings stay open; reported as such, and the cell is not re-run under this key |

Rows are exhaustive over `(c, k) ∈ 0..10 × 0..10` once row 0a has not fired: 0b takes `c ≥ 3`;
for `c ≤ 2`, rows 1–3 partition on `p_C` and then on `k`. **Cost is not a condition on any row**
(P4 is reported beside the verdict, never ANDed with it).

**Under either reading, E-007's registered verdict (`NOT DETECTABLE`, row 4) is not edited.** A
dated amendment to E-007 carries the result, and this file carries the numbers.

## Threats to validity, registered before the run

- **Same words, different seat.** In E-007 the prose was the worker's *system prompt* (an agent
  body); here it is *project memory* injected beside the ticket. A null here (row 2) means *the
  prose as an instruction file* does not reproduce the effect; it does not prove the prose did
  nothing in the worker's seat. Decision 10.1 chose this route for comparability with E-003 and
  says so; the trade is disclosed, not worked around. A third cell — the prose as
  `--append-system-prompt` — would separate seat from words and is **not** this experiment.
- **E-003 is the prior.** A 57-word `CLAUDE.md` moved nothing measurable at stop 6. If P1 holds,
  the two results differ in what the words *ask for* (a construct vs. a test per named case) and
  in the category that can see it; that contrast is reported, not resolved.
- **The prose addresses a delegate** (*"the task you were given"*, *"Report in this shape"*). A
  top-level session may treat the report shape as its final-message format; nothing scored reads
  the final message.
- **Different day than E-007.** The concurrent control exists so that day-to-day drift is in the
  comparison, not in the reference; that is why row 0b exists.
- **Codex is the registered scorer** (Decision C; decision 10.2 for BE-004). The second reader
  (`opencode-score.sh`, deepseek) is owed on every sheet and `change-focus` from it is report-only
  under decision 10.3; `test-quality` agreed 34 of 34 on the last census.
- **One hand re-read before any sheet is opened** (§4 step 7): one fourth-cell run's
  `test-quality` scored by hand off the kept worktree, committed before the first sheet exists.

## Deliberate failure

None registered. Decision 10.1 does not ask for one; this cell is itself the counterpart of
E-007's P2 arm (P2 removed the structural line and kept the prose; this removes the structure and
keeps the prose).

## §4 step 5 — the read-back pair, observed 2026-09-07T11:57–12:02Z

Key `EXP-4B-FOURTH-CELL-PREFLIGHT`, one pair, enters no comparison. Driver
`evidence/p04b/lab-4b4/fourth-cell/run-e008.sh`, manifest
`evidence/p04b/lab-4b4/fourth-cell/batch-20260907T115735Z/manifest.tsv`. Every value below was
read from the run record through the API (`/api/runs/<id>`) or from the runner's own stream in
the batch log, not from the driver's summary line.

| | arm F `0ab18564` | control `5b2d38df` |
|---|---|---|
| `customization.instructionsHash` | **`sha256:51f16eeb1618cd212405818c5165dcba`** — the registered value | **`null`** |
| `skillsHash`, `agentHash`, `hooksHash`, `mcpHash` | all `null` | all `null` |
| runner log | *"instruction file CLAUDE.md present — claude reads this"*; setup commit `14dc6cd` installs the overlay | no customization line |
| `init` record (from the stream): tool pool | **29 tools, `Task` present**, 5 built-in agents, 0 skills, version 2.1.263 | identical: 29, `Task` present, 5, 0, 2.1.263 |
| delegation events in the stream | 0 | 0 |
| `runtime.model` / version | `claude-haiku-4-5-20251001` / `2.1.263 (Claude Code)` | same |
| evaluator exit | **0** | **0** |
| `startedAt` vs prediction commit `b952e8c` (2026-09-07T11:56:51Z) | `11:57:36Z` — **45 s after** | `12:00:11Z` |
| `estimatedCost` / `durationMs` / `modelCalls` / `toolCalls` | $0.170 / 102 s / 24 / 19 (1 tool failure) | $0.134 / 79 s / 19 / 15 |
| `addedLines` / `changedFiles` | **61** / 3 | **69** / 3 |
| `events.jsonl` | grew 8 144 642 → 8 362 794 bytes across the pair (+218 KB) — telemetry is flowing through the 14317/14318 tunnels | same |

**What this proves:** the treatment reached the worktree as the registered bytes and the control
did not (P5's mechanism works on one pair each way); both arms have the same delivered pool, so
nothing narrows either; nothing delegated. **What it does not prove:** that the runtime *read* the
file — the runner's line says claude reads `CLAUDE.md`, which is the filename half (L2); the
content half is P1's job.

**One story, not a hint:** on this single pair arm F added *fewer* lines than the control (61 vs
69), against P2's direction. `n = 1`; recorded so it cannot be forgotten if the batch goes the
other way.

**The batch may start.** Nothing of this lab's was running (`LC_ALL=C pgrep`: empty) and the
tunnels were up.

## §4 step 6 — the batch, recorded 2026-09-07T12:03:34–12:25:15Z

Key `EXP-4B-FOURTH-CELL`, 5 pairs, interleaved F then control, driver
`evidence/p04b/lab-4b4/fourth-cell/run-e008.sh` (pid 92533 under `caffeinate -i`), manifest
`evidence/p04b/lab-4b4/fourth-cell/batch-20260907T120334Z/manifest.tsv`, driver exit 0,
21 min 41 s wall clock. No machine sleep; nothing else of this lab's ran (the only lab process
during the window was the one `git commit`/`git push` of the hand re-read at 12:09Z, which runs
no model and is disclosed here rather than left to be found). `events.jsonl` grew
8 362 794 → 9 544 094 bytes (+1.18 MB), so telemetry flowed for the whole batch.

| pair | arm F run | exit | `instructionsHash` | deleg. | control run | exit | `instructionsHash` | deleg. |
|---|---|---|---|---|---|---|---|---|
| 01 | `582c0b39` | 0 | `sha256:51f16eeb…` | 0 | `8b550ebe` | 0 | `null` | 0 |
| 02 | `ec338c89` | 0 | `sha256:51f16eeb…` | 0 | `8ffecb65` | 0 | `null` | 0 |
| 03 | `2b9ff36c` | 0 | `sha256:51f16eeb…` | 0 | `bcdd01f8` | 0 | `null` | 0 |
| 04 | `e87e272b` | 0 | `sha256:51f16eeb…` | 0 | `7525fad5` | 0 | `null` | 0 |
| 05 | `178eec3f` | 0 | `sha256:51f16eeb…` | 0 | `5c76c344` | 0 | `null` | 0 |

**Row 0a did not fire on delivery** (but see the instrument-fault note below: this is 5 pairs, not 10): 5 of 5 arm-F records carry the registered hash
(`sha256:51f16eeb1618cd212405818c5165dcba`, read back from the API by the driver and re-read
at step 7), 5 of 5 controls carry `null`, 10 of 10 runs show 0 delegation events in their
streams, and the evaluator passed **10 of 10**. Every run is admitted to scoring. **P5 and P6
held on these 10 runs.** *(Corrected the same hour: this paragraph first said 10/10, 10/10, 20/20 — the count of rows was read as the count of pairs.)*

Worktrees kept under `$TMPDIR/observatory-run-<runId>` for all 10 (paths in the manifest).

### An instrument fault of my own making, found after the batch and NOT worked around silently

**The batch above is half the registered `n`.** § Runs registers **10 F + 10 C**; the driver's
`PAIRS` default is **5**, copied from `run-e007-p2.sh` — whose registered `n` *was* 5 per arm —
and I launched it without overriding it, then wrote "20 of 20 admitted" above while the table
plainly shows 5 pairs. Found at §4 step 8 when `per-arm.py` printed `n = 5 pairs`. **Under row
0a as written (fewer than 8 admitted runs in either arm) this half-batch alone is VOID**; the
registration stands, so the remedy is to *complete* the batch on the same key, not to re-register
at 5.

**What had already happened when I noticed:** a sonnet scoring subagent had been started at
step 7 and had written **one** codex sheet,
`findings/codex/score-observatory-run-582c0b39-…-20260907T122712Z.yaml` (arm F, pair 01), before
it was stopped at 12:2xZ; no codex process was left running. **That sheet stays on disk (§6) and
stays unread until all 20 sheets exist** — the hand re-read of the same run (`1`, commit
`56d8cfb`, 12:09Z) precedes it by 18 minutes and is unaffected. Nothing the model sees in pairs
06–10 depends on a sheet, so the second half is not contaminated by it; what could be
contaminated is *my* reading of the second half, and the discipline against that is the same as
before: no sheet is opened before the twenty exist and the counts are produced by
`collect-sheets.py`, not by eye.

**Remedy, applied:** the driver gains `START` (row numbering only — no guard changed), its
verifier is re-run, and a second invocation `START=6 PAIRS=5` runs pairs 06–10 on the same key,
same overlay hash, same runtime, same tunnels, ≈ 15 minutes after the first ended, with its own
manifest under a second `batch-<STAMP>/` directory. The two manifests concatenate to the
registered 20 runs. The independence check in § Results reports both windows.

*Disclosed by Claude Fable 5.1 (claude-fable-5-1), hand-started session, 2026-09-07T12:3xZ.*

---
*Everything below is filled in AFTER the runs.*
---

## §4 step 6, second half — the batch ABORTED itself at pair 08, and the abort is correct

`START=6 PAIRS=5`, key `EXP-4B-FOURTH-CELL`, driver pid 43927, manifest
`evidence/p04b/lab-4b4/fourth-cell/batch-20260907T122828Z/manifest.tsv`, started 12:28:28Z,
**aborted 12:42:23Z at exit 8** after three pairs. `events.jsonl` grew +831 KB across them.

| pair | arm F run | exit | hash | deleg. (log) | control run | exit | hash | deleg. (log) |
|---|---|---|---|---|---|---|---|---|
| 06 | `1b824221` | 0 | registered | 0 | `58e44b57` | 0 | `null` | 0 |
| 07 | `5b3aeace` | 0 | registered | 0 | `137fa43b` | 0 | `null` | 0 |
| 08 | `e38838f8` | 0 | registered | 0 | **`9043f824`** | 0 | `null` | **1** |

**The control delegated.** Run `9043f824` — a plain baseline, no customization, no
`.claude/agents/` — issued:

```
{"type":"tool_use","id":"toolu_01DpQjd3E2DPeegshTK1uDgr","name":"Agent",
 "input":{"description":"Explore shipment feature structure and find key files",
          "subagent_type":"Explore","prompt":"Find the main files in the shipment feature…"}}
```

and the runtime started it: `{"type":"system","subtype":"task_started",…,"subagent_type":"Explore",
"is_backgrounded":true,"spawn_depth":1,"task_type":"local_agent"}`. It is the **built-in**
`Explore` agent. The run then finished normally — evaluator exit 0, 3 files, 69 added lines —
at `toolCalls` **37** against 16–23 for every other control, `modelCalls` **31** against 17–25,
and `estimatedCost` **$0.227** against $0.133–0.186. The delegation is real and it did real work.

### P6 is REFUTED, and its mechanism was wrong

P6 predicted **0 delegation events on 20 of 20**, by the mechanism *"no `.claude/agents/` is
installed; a session with nothing to delegate to does not delegate."* **There was always
something to delegate to.** The `init` record of *both* arms lists **five built-in agents**
(the read-back pair's own §4 step 5 table records `5` and I did not read what it implied), and
one run in sixteen used one. The prediction stays exactly as written; this is its refutation.

**A registered prediction of mine was wrong in the direction that costs the experiment**, which
is the only kind worth registering.

### The registered counter did not see it — an instrument defect, recorded and NOT repaired

P6's registered source is *"`tool_result` events with `tool_name ∈ {Task, Agent}`"* from the
observatory telemetry. For `9043f824` that counter reads **0**, over 24 events on file for that
run id. The delegation is plainly in the runner's own stream. So:

> **The telemetry delegation counter can read zero for a run that delegated.**

What differs about this delegation: it is a **built-in** agent, `is_backgrounded: true`,
`task_type: local_agent`, and its result comes back as a `system`/`task_started` record rather
than as a `tool_result` naming `Agent`. E-007's arm-O delegations — to a custom
`.claude/agents/implementer` — were seen by the same counter on 10 of 10, so it is not blind in
general; it is blind to *this shape*. **Not repaired here**: changing what the counter counts is
a harness move, and E-007's O1 was measured with it (see the amendment filed to E-007 today).

### Verdict: **VOID**, decision rule row 0a

Row 0a as registered voids on *"any run with ≥ 1 delegation event"*. It happened, so the batch
is void. Two things make that call safe to trust rather than merely stated:

1. **It was enforced before any outcome was visible.** The driver — written and its 12 guards
   fixture-proven before the first run — aborted the batch itself at 12:42:23Z. I did not
   choose this after seeing a result; the tool chose it, and the tool was the pre-registered
   reading.
2. **No score of this batch has been read.** Exactly one codex sheet exists for any of these
   runs (`582c0b39`, written 12:27:12Z by the scoring subagent before it was stopped); **it is
   on disk, it is unread, and it stays** (§6). The hand re-read of that same run (`test-quality`
   = 1, commit `56d8cfb`, 12:09:32Z) precedes it by 18 minutes. So the void was decided blind
   to `test-quality` in both arms.

**The argument for the other reading, which I considered and rejected.** Row 0a states its own
rationale — *"the cell was not delivered as designed, or is under-powered past its
registration"* — and a **control** using a built-in agent does not touch whether the *treatment*
was delivered. On that reading only an arm-F delegation should void, and this batch would stand
at `n = 8` per arm. I reject it **because I am holding the data**: E-007 settled an identical
question about its own row 0a *in writing before its batch*, noting that a reading discovered in
the results is not a reading. The strict letter also happens to be what my own tool enforced.
When the two readings differ and one of them saves my experiment, the other one is the one to
take.

**The first half is void as well, from a second, independent clause**: on its own it is `n = 5`
per arm, and row 0a voids below 8. The 16 runs and 2 read-back runs stay on disk as evidence and
as a reference population for the successor, labelled as coming from a void batch.

### What the void does NOT touch

- **P5 held on 16 of 16**: every arm-F record carries `sha256:51f16eeb1618cd212405818c5165dcba`,
  every control `null`. The delivery route works.
- The evaluator passed **16 of 16**.
- The run-record metrics below are reported **for the record only**. They are not a verdict, no
  decision-rule row is read from them, and they are the reason the successor cannot re-register
  over these runs: I have now seen P2–P4's quantities, so a new prediction about them fitted to
  these runs would measure nothing.

| metric, `n = 8` per arm | arm F median (range) | control median (range) | control excluding `9043f824` |
|---|---|---|---|
| `estimatedCost` | $0.1662 ($0.1492–0.1953) | $0.1657 ($0.1332–0.2270) | $0.1601 |
| `durationMs` | 100.5 s (77–110) | 97.5 s (84–133) | 92 s |
| `modelCalls` | 24.5 (21–28) | 23.5 (17–31) | 23 |
| `toolCalls` | 19.5 (17–24) | 20 (16–37) | 19 |
| `addedLines` | 68 (63–83) | 66.5 (64–84) | 66 |

## Decision

**VOID** (row 0a). The registered question — is E-007's `test-quality` effect the prose or the
split? — is **unanswered**, and author decision 10.1's order is not yet discharged.

Successor: **`E-009`**, same arm, same overlay hash, same model and runtime, `n = 10` per arm,
its own prediction commit before its first run, with three repairs named there and not applied
retroactively here: an arm-aware void condition, a delegation column read from **both** the
stream and the telemetry, and a `PAIRS` default that matches the registered `n`.

## Follow-up

1. **The telemetry delegation counter is blind to built-in, backgrounded sub-agents.** Filed as
   an amendment to E-007 today. It is a harness question and it is the author's.
2. **`Explore` costs about 60 % more on the runs that use it** (`$0.227` vs a $0.16 median, 37
   tool calls vs 20) and changed nothing the evaluator could see. `n = 1`; a story, not a hint.
3. **Three of my own instrument faults in one experiment** — `PAIRS=5` against a registered
   `n = 10`, a void clause whose letter and stated purpose disagree, and a delegation counter I
   trusted without asking what it could not see. All three were caught by something that
   executes (the report script, the driver, the cross-check), and none by reading the file again.
