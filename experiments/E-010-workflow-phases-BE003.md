# Experiment E-010 — workflow phases v1.0 on BE-003

**Spine stop 12 (B5) · task `BE-003-confirm-shipment` · experiment key `EXP-B5-PHASES-BE003`**
**Status:** REGISTERED, no runs yet.

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-09T05:5xZ; the author did not review
before the run.`

**Author decision 9 governs.** This experiment covers BE-003 only. Its sibling,
[E-011](E-011-workflow-phases-BE004.md), covers BE-004 under key `EXP-B5-PHASES-BE004`. They have
separate prediction commits, separate concurrent controls, separate decision rules and separate §5
rows. **No verdict is computed across the two files.**

---

## Question

Does a **six-phase procedure declared to a single agent** — `ANALYSIS → DESIGN → IMPLEMENTATION →
VERIFICATION → REVIEW → DONE`, each announced by a literal marker, each with an output contract —
change what a backend feature run *does*, or only what it *says*, and what does it cost?

The build track (`build/README.md#b5`) states the purpose as *"prevent premature coding and false
completion"* and the cost as *"tokens"*, and instructs: **measure both.**

## Hypothesis

The phases are **L3**: prose the model reads and chooses to follow. Nothing executes them
(`§4 step 2` of the workbook applies the layer rule in order and lands on L3 three times out of
four; the one L2 artifact at this stop is the *checker*, not the workflow). The hypothesis is
therefore **not** that the phases prevent anything. It is:

> The agent will **adopt the procedure as narration** — markers present, in order — and will
> **also follow it in position**, because the marker instruction is in the system prompt and is
> read every turn rather than once. The measurable price is **turns**: six announced phases with
> six output contracts cost extra assistant turns and extra output tokens on a single, growing
> context. **The measurable return is nothing the rubric can see**, because this project has
> already measured that the same procedure delivered as prose to a single agent returns nothing
> ([E-009](E-009-fourth-cell-second-registration.md): 0 of 10 against its control's 1 of 10,
> `p = 1.0`).

## Predictions

Every prediction has a direction, a magnitude and a mechanism. `n = 10` per arm.

**P1 — delivery (a void condition, not an outcome).** All 10 treated runs carry
`customization.agentHash = sha256:b3450564b6f32d6193e8580db766210e` and all 10 controls carry
`null`; each treated run's `init` record names `backend-feature-phases` as the delivered agent and
its `init.tools` read-back contains `Edit` **and** `Write`. *Mechanism:* `--customization` +
`--agent`, with `agentHash` populated since `obs#76` (`27b3a7d`, 2026-09-08) — before that commit
every run in this project recorded `null` here and this prediction could not have been written.
*Magnitude:* 10 of 10 / 0 of 10. **Below 9 of 10 → VOID (decision-rule row 0).**

**P2 — markers, the first gate clause.** The six markers appear **once each, in the registered
order**, in **≥ 9 of 10** treated runs, by `check-phase-contract.py` check 1. Control: **0 of 10**,
mechanically — the control is never told the markers exist, so this comparison is **not a finding**
and is registered as a floor, not as a separation. *Mechanism:* the overlay states the literal
syntax and requires the marker *before the first line of work* in each phase; an agent definition
is delivered as the system prompt, so unlike a skill it is not selected — it is present every turn.

**P3 — code order, the second gate clause and the one that decides the stop.** The first mutating
`tool_use` (`Edit`/`Write`/`MultiEdit`/`NotebookEdit`/`str_replace_editor`) falls **after** the
`DESIGN` marker in **≥ 9 of 10** treated runs, by check 2. *Mechanism:* the marker is emitted
in-band as the model works, so an agent that writes first must either emit `DESIGN` after its
write (check 2 fails) or emit all six markers retroactively in its closing summary (check 1's
ordering still passes, check 2 still fails). **This is the trap converted:** a text-level check
passes the retroactive-narration shape — verifier fixture C, which `naive-phase-checker.py`
passes and `check-phase-contract.py` fails.

**P4 — the registered blind spot.** The count of `Bash` calls carrying a write shape **before** the
`DESIGN` marker is **0 in ≥ 8 of 10** treated runs. *Mechanism:* `MUTATING` deliberately excludes
`Bash` (`tools/check-phase-contract.py:63-68`) because `bash -c "grep …"` is a read; the checker
instead counts pre-`DESIGN` `Bash` write shapes and prints them as a NOTE
(`:155, :187-195, :267-269`). The treatment's tool list contains `Edit` and `Write`, so a heredoc
is the harder route and the model should not take it. **This is registered as an outcome, not as
commentary**, because a run with zero `Edit`/`Write` before `DESIGN` and three pre-`DESIGN` `Bash`
writes has met the letter of check 2 and not the clause the gate asks about.

**P5 — turns, the overhead the build track calls the trap.** `modelCalls` median in the treated arm
is **higher than its concurrent control by ≥ +4** with **non-overlapping quartiles**. *Mechanism:*
six announcements plus six output contracts are assistant turns the control never takes. *Prior:*
[E-007](E-007-orchestration-overhead.md)'s structural split produced exactly `+4` (26 vs 22) and
that was the only cost outcome that cleared its MDE.

**P6 — money, and the mechanism here is NOT E-007's.** `estimatedCost` median in the treated arm is
**≥ +25 %** over its concurrent control, with non-overlapping quartiles. *Mechanism, stated because
the direction contradicts the nearest prior:* E-007's split was **13.4 % cheaper** than its control,
because the implementer ran in a fresh, small context. **There is no subagent here.** One agent
carries one growing context through six phases, so every extra turn re-reads everything before it
and the input cost compounds. If this prediction is wrong in the E-007 direction, the compounding
mechanism is wrong and that is worth more than the prediction.

**P7 — quality, the prediction I most expect to hold and which is most damaging if it fails.**
`test-quality` anchor 2 count in the treated arm is **≤ 3 of 10** and specifically **not ≥ 5 of 10**
(the split's number). *Mechanism:* [E-009](E-009-fourth-cell-second-registration.md) measured the
same shape — a procedure as prose to one agent, no split — at **0 of 10 against its control's 1 of
10, `p = 1.0`**, and `p = 0.0325` against the split's 5 of 10. Markers change what is narrated, not
what is in the context window at the moment the tests are written. **If the treated arm reaches
≥ 7 of 10, then declared phases return what the structural split returned without the split, and
[E-007](E-007-orchestration-overhead.md)'s "the effect is the split" needs a dated amendment.**
That is decision-rule row 4 and it fires regardless of which other row fires.

**P8 — correctness floor.** Evaluator pass rate in the treated arm is **≥ 9 of 10** and is not lower
than the control's by ≥ 3. *Mechanism:* every arm ever run on BE-003 here has passed 10 of 10;
this is a floor, and a break in it is the finding.

## Independent variable

**One thing changes:** the treated arm runs with
`--customization build/customizations/phases-v1.0 --agent backend-feature-phases`. The control runs
with neither. Everything else in `Controlled variables` is pinned identically and read back from
the run records rather than trusted from a flag.

## How the treatment is delivered — and proved

| | Treated arm | Control arm |
|---|---|---|
| Mechanism | `--customization build/customizations/phases-v1.0` + `--agent backend-feature-phases` | no `--customization`, no `--agent` |
| Content hash | file `shasum -a 256` = `b3450564b6f32d6193e8580db766210e35c1bfaa90589a705b3e9236fdb18a41` (64 hex). The **run record stores a 32-char prefix** — `sha256:b3450564b6f32d6193e8580db766210e` — because `agent-observatory/runner/run-agent.sh:575` is `printf '"sha256:%s"' "$(shasum -a 256 "$path" | cut -c1-32)"`. **Both forms are registered here** so a stranger re-deriving the hash with `shasum` does not find a mismatch against the record. | — |
| Preflight assertion (§4 step 5, one run per arm before the batch) | run record `customization.agentHash` equals the hash above; `init` names `backend-feature-phases`; `init.tools` read-back contains `Edit` and `Write` | `customization.agentHash` is `null` and `instructionsHash` is `null` |
| Per-run proof | `customization.agentHash` on every run record | `null` on every run record |

**The `init.tools` read-back is not optional here and this is why.** Validator pass 18's closing
finding was that if the delivered tool list drops `Edit`/`Write`, every treated run scores
*"nothing was implemented"* and the stop opens with an instrument that fails its own treatment arm.
Position 9 measured the runtime rewriting a `tools:` list before the model saw it —
`Read, Grep, Glob, Bash` delivered as `["Read", "Bash"]` on 10 of 10 runs — so **author decision 8
makes the read-back mandatory before any B step registers an allowlist**, and the overlay declares
`tools: Read, Edit, Write, Bash`.

**Disclosure — the overlay predates this stop.** `backend-feature-phases.md` was written and merged
on **2026-09-08 in lab#77**, an instrument PR, while stop 12 was unopened. That is a **§6
violation** (*"never create a future step's artifacts early"*), inherited rather than committed
here; it is not deleted, because §7 forbids destroying evidence, and this stop **adopts it as a
pre-existing draft** with its date, PR and sha on the record. Any change from here is a new version
directory, never an edit. **No BE-003 run has ever been made with this overlay** — verified against
the observatory API at registration time: 382 run records, 3 carry this `agentHash`, all 3 are
`BE-004` under `EXP-P12-PREFLIGHT-INITTOOLS-BATCHENV`, **0 are BE-003**. So the overlay has not
been tuned against any run this experiment will score.

## Controlled variables

| Variable | Value | Read back from |
|---|---|---|
| Agent under test | `claude-haiku-4-5-20251001` | `runtime.model` on every run record |
| Benchmark task | `BE-003-confirm-shipment` | `benchmarkId` |
| Benchmark commit | `agent-observatory-benchmarks` at the sha recorded at §4 step 6 | run record + `git rev-parse` at launch |
| Evaluator | BE-003's own, exit-code contract unchanged since B2 | `evaluation.exitCode` |
| Rubric | `benchmark/rubrics/backend-quality.yaml`, sha `396e1799eb2b`, four categories | asserted on every sheet, not eyeballed |
| Registered scorer | `codex` (Decision C) | sheet provenance header |
| Second reader | `opencode-score.sh` with `ollama-cloud/deepseek-v4-pro` | sheet provenance header |
| Isolation | `ISOLATE_USER_SETTINGS=1` on both arms | `customization.*Hash` null on control, 0 hook executions |
| Worktrees | `KEEP=1` (`--keep`), never `--bare` | worktree path per run |
| Telemetry | `OTLP_GRPC_PORT=14317 OTLP_HTTP_PORT=14318 API_PORT=18081` — the SSH tunnels, because every colima host forward on this machine is dead and reads as healthy | `events.jsonl` **must grow** before any telemetry-sourced number is trusted |

## Runs

`n = 10` per arm, **interleaved** treated/control pair by pair, as E-007 and E-009 ran. Both arms
launched from the same script in the same session, same machine, no run across a machine sleep.
Budget ≈ 20 runs × $0.15 ≈ $3, ≈ 45 min.

## Minimum detectable effect

**Derived from the measured reference population before any threshold above was written**, as
E-002's follow-up 6 requires. The reference population is **BE-003's plain control, and it is the
strongest one this project has**: three independent concurrent-control batches, `n = 10` each,
`n = 30` total.

| Metric | E-006 batch 2 control | E-007 arm C | E-009 control | Registered MDE at `n = 10`/arm |
|---|---|---|---|---|
| `modelCalls` median | 22 (q1 20, q3 26) | 22 | 21.5 (q1 19, q3 24) | **+4 on the median AND treated q1 > 26** |
| `estimatedCost` median | $0.156 (q1 0.139, q3 0.175) | $0.1462 | $0.1535 (q1 0.1281, q3 0.1629) | **+25 % on the median AND treated q1 > 0.175** |
| `durationMs` median | 97 s (q1 85, q3 102) | 88 s | — | **+40 % on the median AND treated q1 > 102 s** |
| `addedLines` median | 69 | 64 | 67.5 | report-only, no threshold |
| `test-quality` anchor 2 | — | 0 of 10 | 1 of 10 | **≥ 7 of 10 treated** (two-sided Fisher against 1 of 10: 7 vs 1 → `p = 0.0198`; 6 vs 1 → `p = 0.0573`, which does not clear) |
| evaluator pass | 10 of 10 | 10 of 10 | 20 of 20 admitted | a **drop of ≥ 3** is detectable; smaller is not |

**Count outcomes** use two-sided Fisher exact at `n = 10` per arm. **Continuous outcomes** use a
registered delta on the median *plus* non-overlapping quartiles, calibrated from the control's own
measured spread — the control's `estimatedCost` IQR ratio is 1.26, so a +25 % median shift sits at
the edge of the control's own spread and is the smallest honest threshold.

## Deterministic evaluation

BE-003's evaluator, unchanged since B2, exit-code contract untouched. `./tools/check-run-gate.sh` on
every run before any sheet is opened; only gate-admitted runs enter any comparison.

## Exclusions, registered before the data

1. A run `check-run-gate.sh` refuses (no recorded evaluator verdict) is excluded from every
   comparison and the refusal is recorded.
2. A run spanning a machine sleep has **`durationMs` excluded, the run kept** (§4 step 6).
3. A run whose telemetry did not export is excluded — though the runner now **refuses to start**
   such a run (`agent-observatory` `4cdd803`), so this should be unreachable; if it is reached,
   that fact is the finding.
4. **No run is excluded for failing a phase-contract check.** A treated run that skips `DESIGN` is
   the measurement, not a defect.

## Decision rule, fixed before the run

Applied **in order**, stopping at the first row that fires.

| # | Condition | Verdict |
|---|---|---|
| 0 | P1 fails — fewer than 9 of 10 treated runs carry the agent hash, or any control carries a non-null one, or a sheet's rubric sha is not `396e1799eb2b` | **VOID** — the treatment was not delivered; nothing is claimed |
| 1 | P2 ≤ 5 of 10 | **REFUTE** — the agent does not adopt the procedure even as narration; the overlay is not a workflow, it is unread text |
| 2 | P2 ≥ 9 of 10 **and** P3 ≤ 5 of 10 | **REFUTE, and this is the trap's own result** — the markers appear and the code order does not follow them. The workflow is narration. |
| 3 | P2 ≥ 9 of 10 **and** P3 ≥ 9 of 10 **and** (P5 clears its MDE **or** P6 clears its MDE) | **CONFIRM** — phases observable, followed in position, overhead measured not assumed. The build-track gate is answered **yes** on all three clauses. |
| 4 | P2 ≥ 9 of 10 **and** P3 ≥ 9 of 10 **and** neither P5 nor P6 clears its MDE **and** nothing improved | **NOT DETECTABLE** — the phases are followed and cost nothing this `n` can resolve |
| 5 | anything else | **INCONCLUSIVE**, reported as the combination that produced it, never rounded to a neighbour |

**Row 4b, on a separate axis, recorded beside whichever row above fires:** if `test-quality`
anchor 2 in the treated arm is **≥ 7 of 10**, record *"declared phases returned what the structural
split returned, without a split"* and open a dated amendment on
[E-007](E-007-orchestration-overhead.md). E-007's registered verdict is **not edited** under any
reading.

## Threats to validity, registered before the run

1. **The `Bash` blind spot is real and is in the treatment's own tool list.** Registered as P4; the
   checker reports it rather than closing it.
2. **Marker parsing edges.** A `<<PHASE:X>>` string inside a fenced code block, or inside a tool
   result rather than assistant text, is a known parsing edge (validator pass 18, items 35c/35d).
   The checker reads assistant `content` blocks; a marker echoed by a tool result is not counted.
   If any run turns on this, the transcript is read by hand and the reading is written next to the
   checker's verdict.
3. **The compliance comparison against the control is trivial and must not be reported as a
   finding.** The control cannot emit markers. The number that means something is the treated
   arm's absolute rate.
4. **Longer context, longer duration, and this machine is shared.** Interleaving is the mitigation;
   duration is the outcome most exposed to it and carries the widest MDE for that reason.
5. **`n = 10` per arm is coarse.** Nothing from `n < 5` is stated as a property anywhere in this
   file, and a `test-quality` count of 6 of 10 does **not** clear the registered threshold even
   though it looks like an effect. That threshold was set before the data and does not move.
6. **The overlay was authored before this stop opened.** Disclosed above. It was not tuned on any
   BE-003 run because none exists with it.

7. **The treated arm is delivered four tool names and the control twenty-nine, and the difference
   was found by this stop's own §4 step 5 preflight rather than registered before it.** *Added
   2026-09-09, before the first batch run, by Opus 5 (claude-opus-5), autonomously.* The treatment
   is the six-phase procedure **bundled with** the agent definition's `tools:` line, because that is
   what a Claude Code agent is. E-005 makes most of the gap inert — `tools:` filters names, not
   capabilities, and this list carries `Bash` — and the benchmark is offline, so the `Web*`,
   `Notebook*`, `Monitor`, `Workflow` and `Cron*` names have no path to it. **`Task` is the
   exception**: the control can delegate and the treated arm cannot. Mitigation, executable:
   `check-phase-contract.py` detects delegation (fixture **J**), so **every control run is counted
   for `Task` use and the count is reported beside the batch numbers whether it is zero or not.**
   See the §4 step 5 section for the full statement.

## Deliberate failure — registered here, run at §4 step 9

Prediction first, committed, then broken. The deliberate failure is a **fifth pair** run with
`build/customizations/phases-v1.0-nomarkers-DELIBERATE-FAILURE` — the same six-phase prose with
**the marker instruction removed and nothing else changed**. **Prediction:** the markers vanish
(check 1 fails, `0 of 3`) while the *narrative* phase headings survive in the closing summary, so
`naive-phase-checker.py` still passes runs the real checker fails. *Mechanism:* the marker syntax
is the only machine-readable part; the prose is not. **If the markers survive without the
instruction, the treatment was never the marker text and P2 measured something else.**

## §4 step 4 — the build, re-verified rather than rebuilt

*Run and recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-09, before the preflight pair
and before any run of this experiment.*

**Step 4 is "build the smallest thing", and on BE-003 the smallest thing was already on disk when
this stop opened.** Two of the three pieces were merged as instrument PRs while stop 12 was
unopened — the workbook's §4 step 2 section discloses that as the §6 violation it is and adopts
them as pre-existing drafts rather than deleting them. So step 4 here is a **re-verification with
its output pasted**, not a build, and the distinction is recorded so that "the build passed" is
not read as "the build was made here".

| Piece | Path | Layer of the piece | What step 4 did to it |
|---|---|---|---|
| The treatment | `build/customizations/phases-v1.0/.claude/agents/backend-feature-phases.md` | L3 | hash re-derived, not edited |
| The instrument | `tools/check-phase-contract.py` | L2 | fixture set re-run, ShellCheck and `py_compile` re-run |
| The instrument's fixture set | `tools/verify-phase-contract-checker.sh` | L2 (it executes and refuses) | re-run in full |

### The output, pasted, from this session

```
$ ./tools/verify-phase-contract-checker.sh
  ok   — A: a clean phased run passes (exit 0)
  ok   — B: a missing phase marker is refused and named (exit 2)
  ok   — C: markers printed after the first edit are refused — the narrated phase (exit 2)
  ok   — D: phases out of registered order are refused (exit 2)
  ok   — E: a surviving template token is refused (exit 2)
  ok   — F: DONE without its completion fields is refused (exit 2)
  ok   — G: a duplicated phase marker is refused (exit 2)
  ok   — H: an empty transcript is UNUSABLE (exit 3), not a failed run
  ok   — I: a non-JSON file is UNUSABLE (exit 3), not a failed run
  ok   — J: a phased run that delegated passes, and the confound is reported (exit 0)
  ok   — K: six markers with no implementation is refused (exit 2)
  ok   — L: a Bash-only run is refused, and the refusal does not claim nothing was written
  ok   — M: the residual hole passes, and the pre-DESIGN write shapes are reported (exit 0)
  ok   — NEG: the text-only checker scores 2 passed, 11 failed against these fixtures
  ok   — NEG: fixture C — edits in turn two, six markers after — passes the text-only checker
verify-phase-contract-checker: 15 passed, 0 failed, of 15 registered cases
EXIT=0

$ shellcheck -S warning tools/verify-phase-contract-checker.sh
SHELLCHECK_EXIT=0

$ python3 -m py_compile tools/check-phase-contract.py
PY_COMPILE=ok

$ find build/customizations/phases-v1.0 -type f -name '*.md' -exec shasum -a 256 {} \;
b3450564b6f32d6193e8580db766210e35c1bfaa90589a705b3e9236fdb18a41  build/customizations/phases-v1.0/.claude/agents/backend-feature-phases.md
```

**The hash is the one registered in "How the treatment is delivered"** — `b34505…b18a41`, whose
32-character run-record prefix is `sha256:b3450564b6f32d6193e8580db766210e`. Re-derived here from
the file rather than copied from that table, because a treatment hash that only ever agrees with
itself proves nothing.

**The two negative-control cases are why the count matters.** Thirteen of the fifteen cases assert
that `check-phase-contract.py` refuses what it should refuse. The last two assert that a checker
built the obvious way — `naive-phase-checker.py`, matching the marker text in the output — passes
things this one fails: 2 passed / 11 failed against the same fixtures, and fixture C (edits in turn
two, all six markers printed afterwards) passes it. A fixture set that only proves a tool accepts
good input is a control reporting over a smaller scope than it claims, which is the house failure
mode; these two cases are the guard against it.

**Nothing was edited at this step.** §4 step 4's rule — *never edit a tool while a run of it is in
flight* — is satisfied trivially: no run of either task existed under `EXP-B5-PHASES-BE003` or
`EXP-B5-PHASES-BE004` when this ran.

**The deliberate-failure overlay `phases-v1.0-nomarkers-DELIBERATE-FAILURE` does not exist yet and
that is deliberate.** It belongs to §4 step 9; §6 forbids creating a future step's artifacts early,
and its prediction is already registered above.

## §4 step 5 — the preflight pair

*Run and read back by Opus 5 (claude-opus-5), autonomously, 2026-09-09, before any
batch run of this experiment existed.*

| Arm | `runId` | `variant` | Started | Finished | Sheet of assertions below |
|---|---|---|---|---|---|
| Treated | `64aaefcd-7e54-479f-87a1-1aa87f0f1b80` | `phases-v1.0` | 2026-09-09T07:42:46Z | 07:44:27Z | `evidence/b05-preflight/step5-init-schema/init-schema-64aaefcd-….txt` |
| Control | `7b61ad93-9900-4291-af62-27e10e967503` | `baseline` | 2026-09-09T07:45:09Z | 07:46:16Z | `evidence/b05-preflight/step5-init-schema/init-schema-7b61ad93-….txt` |

### The reading

| Assertion | Treated arm | Control arm | Verdict |
|---|---|---|---|
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` | `null` | **as registered** |
| `customization.instructionsHash` | `null` | `null` | **as registered** — this overlay is an agent file, not a `CLAUDE.md`; the field is expected null on both arms and its being null on the treated arm is not a delivery failure |
| `customization.skillsHash` | `null` | `null` | no skill is installed on either arm |
| `init.tools` delivered | `["Read","Edit","Write","Bash"]`, declared `n=4`, delivered `n=4`, **`verdict=match`** | 29 tools, `verdict=recorded-only` (no overlay to assert against) | **`Edit` and `Write` reach the model** — author decision 8's requirement, met |
| `evaluation.exitCode` | `0` | `0` | both arms cleared the evaluator |
| `behavior.modelCalls` | non-null | non-null | **telemetry is live**; no turn or cost number in this stop rests on a null |
| `repository.commitSha` | `eea144ef940fda4cb6090561fdd901aed0013c8e` | same | the registered benchmark commit, on both |
| `runtime.model` | `claude-haiku-4-5-20251001` | same | the controlled variable, read back not assumed |

**`events.jsonl` grew from 1 913 lines at 07:43:28Z to 1 974 after the fourth run — +61 lines
across four runs, read inside the window rather than inferred from an exit code.** That is stop 11's
telemetry rule discharged for this batch environment: the OTLP endpoints passed were the tunnel's
`14317`/`14318`, and they are carrying.

**The ports had to be passed as `make` command-line variables, and this is not a detail.**
`agent-observatory/Makefile` does `-include infra/.env`, whose `API_PORT=8081`,
`OTLP_GRPC_PORT=4317` and `OTLP_HTTP_PORT=4318` **beat environment variables**. All three of those
host ports are leaked `limactl` forwards with nothing behind them — verified this session: `8081`
accepts a connection and returns bytes no JSON parser will take, while `18081` returns 382 records.
A run launched with those defaults would post to a dead endpoint. `make API_PORT=18081
OTLP_HTTP_PORT=14318 OTLP_GRPC_PORT=14317 …` overrides them, confirmed with `make -n` before the
first run and by the four records afterwards.

### Kept worktrees

All four exist and each holds `evaluation.json` and `sample-service`:

```
${TMPDIR}/observatory-run-<runId>
```

**They are under `TMPDIR`, which macOS reaps.** The hand re-read at §4 step 7 depends on them, so
it is done in the same session as the batch rather than deferred — the evidence README already
records `TMPDIR` sweeping a previous set of init records.

### What these four runs are NOT

They are **preflight probes under their own keys**, `EXP-B5-PHASES-BE003-PREFLIGHT` and
`EXP-B5-PHASES-BE004-PREFLIGHT`, deliberately separate from the batch keys. **They join no `n`, and
no number below is a result.** `modelCalls` was 11 treated against 18 control on BE-003 and 26
against 31 on BE-004 — a direction opposite to "phases add turns" — and **that is `n = 1` per cell
and is stated here only so that nobody later finds it and thinks it was hidden.** The batch decides
this, not these.

### The confound this preflight found, registered before the batch

**The two arms differ in a second way, and the preflight is what made it visible.** The treated arm
is delivered `["Read","Edit","Write","Bash"]`. The control is delivered **29 tools** — the full
default set, which additionally contains `Task`, `WebSearch`, `WebFetch`, `NotebookEdit`, `Monitor`,
`Workflow`, the `Cron*` family and the rest. So the treatment is not only the six-phase procedure;
it is the procedure **bundled with a four-name tool list**, because that is what a Claude Code agent
definition is. Nothing in this experiment's registered `Threats to validity` said so before now.

**Most of that difference is inert here, and one part of it is not.**

- E-005 measured that `tools:` **filters names, not capabilities**, and that a list containing
  `Bash` does not stop writes — 10/10 write attempts, `p = 1.0` against no list at all. This list
  contains `Bash`. So the narrower list is not a capability boundary and the treated arm is not
  restricted in what it can do to the repository.
- `WebSearch`, `WebFetch`, `NotebookEdit`, `Monitor`, `Workflow` and the `Cron*` family have no
  path to this benchmark: it is an offline Kotlin service with no network step.
- **`Task` is the exception and it is the one to watch.** The control can delegate to a subagent;
  the treated arm cannot. A control run that delegates is doing something the treated arm is
  structurally unable to do, and any difference that follows has two candidate causes.

**Registered mitigation, executable rather than promised:** `tools/check-phase-contract.py` already
detects delegation — it is case **J** of the fixture set, *"a phased run that delegated passes, and
the confound is reported"*. So **every control run's transcript is counted for `Task` use, and the
count is reported beside the batch's numbers**. If it is zero across the control arm, the confound
is inert on this data and is reported as inert. If it is not zero, the affected runs are named and
the comparison is read with them called out. **The count is reported either way**, including when it
is zero — a confound that is only mentioned when it fires is a confound nobody checked.

**This is added to `Threats to validity` as item 7, dated, before the first batch run.** It is not
an edit to a prediction and it changes no threshold; it is a threat the preflight exposed, recorded
in the place threats live, which is what a preflight is for.



## §4 step 6 — the batch

Two launches, one experiment key `EXP-B5-PHASES-BE003`, `n = 10` per arm, interleaved
treated/control pair by pair so that any drift in the machine or the API is shared by both arms.

| Launch | Evidence directory | Pairs | Outcome |
|---|---|---|---|
| 1 | `evidence/b05/batch-BE-003-20260909T075939Z/` | 01–10 | pairs 01–08 completed; **pairs 09 and 10 aborted before the model was reached** |
| 2 | `evidence/b05/batch-BE-003-20260909T093440Z/` | 09–10 (`START=9 PAIRS=2`) | re-run of the two aborted pairs |

### The four aborted runs, kept and disclosed rather than quietly dropped

`09-treated 81b1d617-f5ba-40f1-84ec-d89a993ea966`, `09-control 79b9b300-f616-4825-8396-2fb5ac6a9e26`,
`10-treated f34a2eb4-f397-4157-887b-b34747839cd8`, `10-control fe6c2d96-f857-4caf-9b92-e200864ea436`.

An external DNS outage hit this machine at about `2026-09-09T08:39Z`. **The model was never
contacted on any of the four.** Three independent proofs, none a restatement of the others:

1. Every one of the four runner logs carries
   `API Error: Can't reach the API server — check your internet or DNS (ENOTFOUND)`.
2. The four logs are **12 KB**; the sixteen runs that reached the model are **150–250 KB**.
3. `evaluation.json` on all four: `taskAttempted: false`, `productionFilesChanged: 0`,
   `addedLines: 0`, `changedFiles: []`, `exitCode 12`, `failureClass F03`.

The outage was external and independently witnessed: a subagent of the orchestrating session died
on the same `ENOTFOUND` in the same minute. It struck **both arms symmetrically** — two treated,
two control — so it shortens the batch rather than biasing it.

### Why this is a re-run and not a registered exclusion

**This decision was written into `TRACK-B-STATE.md` and committed (`ea12b8d`) before the re-run
command was issued**, so it cannot have been chosen after seeing what the replacement runs said.

E-010's decision rule and MDE are written end to end in *of 10* terms — `≥ 9 of 10`, `≥ 7 of 10`,
two-sided Fisher at `n = 10` per arm. Carrying four runs in which the model was never contacted
would have forced one of two things this project refuses: counting a network outage as an agent
failure under P8, or inventing a post-hoc threshold at `n = 8` that no prediction registered.
A run in which the model was never reached is not a measurement of the agent; it is an aborted
run. §0's bar for re-running — *never re-run a benchmark run you cannot prove failed to start* —
is met three ways above.

**Nothing was deleted.** The four aborted runs keep their manifest rows, their 12 KB logs, their
worktrees, their run records and their evaluator verdicts, and they are named here by run id. The
replacement runs live in their own stamped directory, so the two attempts can never be confused
for one another. They are excluded from every comparison in the Results below, and that exclusion
is this paragraph, not a silent gap in an `n`.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*

### The one thing this cost

The registered exclusion list (four items, written before the data) does **not** contain
"the model was never reached". It should have; every previous batch in this project ran on a
network that happened not to fail. That is a gap in the registration, disclosed here rather than
back-filled into the list above, and it is the shape a later step should register in advance.

## §5 hand re-read — one scored cell, read off the worktree before any sheet was opened

§5 requires at least one scored cell per step to be re-read by hand from the kept worktree, with
the hand reading written down next to the sheet's value. **This reading was taken before any
codex or opencode sheet for this batch existed**, so it cannot have been anchored by one.

- **Run:** `5395964c-c3c0-4117-9d79-3ff7b379b6e1` — pair 01, **treated** arm.
- **Worktree:** `$TMPDIR/observatory-run-5395964c-c3c0-4117-9d79-3ff7b379b6e1`
- **Rubric:** `benchmark/rubrics/backend-quality.yaml`, sha prefix **`396e1799eb2b`**, verified by
  the reader before scoring.
- **Cell:** `test-quality`.
- **Hand value: 1.**

Anchor 2 asks for three clauses, each citable. Applying the rubric's closing rule — *0 if the 0
anchor's condition holds; 2 else if EVERY clause of the 2 anchor holds; 1 otherwise*:

| Anchor 2 clause | Holds | Evidence |
|---|---|---|
| `confirm` called twice and the **second response's body** asserted, not its status alone | yes | `sample-service/src/test/kotlin/com/unityinflow/sample/shipment/ShipmentControllerTest.kt:100,105-107` |
| persisted state re-read through a **separate `get(...)`** rather than trusted from the mutating call's own body | **no** | same file `:85-131` — no `get(...)` appears in any confirm test; `get()` occurs only in the pre-existing tests at `:62,69,79` |
| at least one refusal asserts `$.error.code` rather than the status alone | yes | same file `:123` |

Anchor 0 does not hold — assertions do read response bodies — so the cell is not 0; one clause of
anchor 2 is absent, so it is not 2. **The residual, 1.**

The value the registered sheet gives for this same cell is recorded beside it in the Results
section below. Where the two disagree, the disagreement is the finding and the diff decides it,
per §4 step 7.

*Hand reading delegated to a `sonnet` subagent with the rubric path, the worktree path and the
required answer shape, per §4b; the clause-by-clause citations above are what it returned, and the
`path:line` references are checkable against the worktree by any reader.*

## Results

<!-- filled at step 8. Median and range, never a mean alone. -->

## Which predictions held

<!-- filled at step 8. Wrong predictions stay wrong. -->

## Decision

<!-- filled at step 10 -->
