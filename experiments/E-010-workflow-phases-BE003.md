# Experiment E-010 — workflow phases v1.0 on BE-003

**Spine stop 12 (B5) · task `BE-003-confirm-shipment` · experiment key `EXP-B5-PHASES-BE003`**
**Status:** CLOSED — `n = 10` per arm run 2026-09-09, decision rule **row 5, INCONCLUSIVE**, build
gate's three clauses each answered yes. §4 step 9's deliberate failure is the one registered piece
still outstanding; see "Deliberate failure" below. *(Header corrected after the §4a review found it
still reading "REGISTERED, no runs yet" beneath a full Results section — finding 1.)*

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

`n = 10` per arm, all 20 admitted by `./tools/check-run-gate.sh` (20 admitted, 0 refused), and the
same checker **shown to refuse** on the four aborted runs at `rc = 2` — so the admission is a
measurement and not an assumption. Medians and quartiles below; no mean is quoted alone.

### The registered scorer's own report, pasted from this session

```
$ cd ../agent-observatory && make API_PORT=18081 baseline-report EXPERIMENT=EXP-B5-PHASES-BE003
=== EXP-B5-PHASES-BE003 ===
  20 measuring run(s)
  4 discarded as harness failure (F13) — not agent behaviour, excluded from every number below

  pass rate   20/20

  outcome            n         min        p25     median        p75        max
  ---------------- ---  ---------- ---------- ---------- ---------- ----------
  duration (s)      20          56         86        100        110        300
  estimated cost    20      0.0935     0.1044     0.1216     0.1477     0.1997
  total tokens      20        5248       7807       9332      10320      11991
  tool calls        20          12         16         18         21         32
  model calls       20          14         18         22         24         31
  cache tokens      20      212907     298862     371094     697957     972406
```

**Read the second line.** The observatory's own reporter, which no one edited for this batch,
independently classifies the four aborted runs as *harness failure, not agent behaviour, excluded
from every number*. The decision recorded at `ea12b8d` — that a run in which the model was never
reached is not a measurement of the agent — was therefore not an invention of this stop; the
instrument already carried the category. That is the strongest available check on it, because it
was not consulted when the decision was made.

This report pools both arms, as a single-arm reporter must. The arm-level numbers below are
computed per arm from the same run records, and two of them were re-derived from raw telemetry
independently (see "Independence check").

### Per-arm, `n = 10` each

| Outcome | Treated (phases-v1.0) | Control (plain) | Registered threshold | Held? |
|---|---|---|---|---|
| `modelCalls` median (q1, q3) | **20.5** (18, 23) | **22** (17, 24) | treated ≥ +4 **and** treated q1 > 26 | **P5 refuted** |
| `estimatedCost` median (q1, q3) | **$0.1178** (0.1012, 0.1217) | **$0.1480** (0.1216, 0.1724) | treated ≥ +25 % **and** treated q1 > 0.175 | **P6 refuted** |
| `durationMs` median (q1, q3) | 105.5 s (97, 110) | 90.5 s (76, 111) | +40 % on the median | not cleared |
| `addedLines` median | 79 | 41.5 | report-only, no threshold | — |
| evaluator pass | 10 of 10 | 10 of 10 | ≥ 9 of 10 treated, and not ≥ 3 below control | **P8 held** |

**Threat 7, named here and not only in the independence check** *(added after the §4a review's finding
3, which was right that a reader of this table alone could not see it)*: **pair 04's control run made
one delegating call**; no treated run made any, and none could — `Task` was not among the four tools
the runtime delivered to the treated arm. Dropping that one control run moves the control's
`estimatedCost` median from $0.1480 to $0.1474 and its `modelCalls` median from 22 to 22. **The
comparison does not depend on it**, which is why it is reported rather than excluded.

**P5 and P6 are refuted in the same direction, and it is the opposite of the one registered.**
The treated arm took **fewer** model calls (−1.5 median, −6.8 %) and cost **20.4 % less**
($0.1178 against $0.1480). The registered mechanism was compounding: one agent carrying one
growing context through six phases, re-reading everything before it on every extra turn. **There
were no extra turns.** The direction is E-007's — its structural split came in 13.4 % cheaper
against a registered increase — and this is now the second time in this project that a
customization predicted to cost more has cost less.

On `modelCalls` the quartiles overlap heavily (treated 18–23, control 17–24), so the reverse
effect is **not resolvable at this `n`** and is reported as a direction, not a size. On
`estimatedCost` the quartiles all but separate — treated q3 `$0.1217` against control q1
`$0.1216`, a gap of `$0.0001` in the wrong direction for a clean claim — so the cost reduction is
stated as **20.4 % on the median with quartiles that touch at one ten-thousandth of a dollar**,
and not as "non-overlapping". A reader who wants that distinction to carry weight should run more
runs; this one will not round it.

`durationMs` runs the other way (treated slower by 16.6 %) and is the least trustworthy row here:
the control's spread is 56–300 s and its maximum, run `29f5d357` (pair 08, control), is a 300-second
outlier at only 14 model calls. Duration is reported and is **not** used in any verdict.

`addedLines` is the loudest unregistered difference: the treated arm's median is **79** against the
control's **41.5**, and the control is visibly bimodal — 19, 20, 24, 24 against 59, 62, 63, 65.
The treated arm wrote roughly twice the lines, in fewer turns, for a fifth less money. That is
report-only by registration and it is not a quality claim; it is the thing most worth a prediction
at the next stop.

### Where the money actually went — token composition, report-only and unregistered

Registered nowhere; computed after the fact from the same 20 run records, and reported because it
names the mechanism P6 got wrong. Medians, `n = 10` per arm:

| Token class | Treated | Control | Treated ÷ control |
|---|---|---|---|
| input (the task prompt) | 1 404 | 1 416 | **1.0** |
| output | **8 578** | 6 268 | **1.37** |
| cache **read** | **267 882** | **674 614** | **0.40** |
| cache creation | 19 812 | 24 346 | 0.81 |

**The treated arm produced 37 % more output while re-reading 60 % less context.** Input is
identical to within 1 %, as it must be — both arms get the same `task.md`. Cache reads run to
hundreds of thousands of tokens and are what the bill is made of at this scale, and the control
read back **2.5 times** as many of them (its worst run, 937 987, against the treated arm's worst,
339 657).

**P6's mechanism was not merely backwards; it was pointed at the wrong arm.** The registered
sentence was *"one agent carries one growing context through six phases, so every extra turn
re-reads everything before it and the input cost compounds."* Context re-reading did compound —
**in the control**, which had no procedure, took between 14 and 31 model calls, and re-read
everything it had gathered each time it decided what to do next. The treated arm's six declared
phases are a plan that already exists, so it re-derives less and writes more.

That reading is consistent with every other number in this batch and it is **still a
post-hoc explanation of an unregistered quantity**. It is written here as the hypothesis the next
stop should register in advance, not as a result of this one. The experiment that would test it
compares two arms that differ only in whether the procedure is stated up front, and this stop does
not contain one.

*Added by Opus 5 (claude-opus-5), autonomous, 2026-09-09, after the registered results above and
without altering any of them.*

### The phase contract, machine-checked on every run

`tools/check-phase-contract.py` over each run's stream-json transcript
(`$TMPDIR/observatory-agent-<run-id>.log`). This is the registered instrument for P2, P3 and P4,
and its 15-of-15 fixture set was re-run at `1031a99`.

| Clause | Treated | Control | Registered threshold | Held? |
|---|---|---|---|---|
| P2 — six markers, once each, in order (check 1) | **10 of 10** | **0 of 10** | ≥ 9 of 10 treated; control a floor, not a finding | **held** |
| P3 — first mutating `tool_use` **after** `DESIGN` (check 2) | **10 of 10** | n/a — no `DESIGN` to measure against | ≥ 9 of 10 treated | **held** |
| P4 — pre-`DESIGN` `Bash` write shapes = 0 | **9 of 10** (pair 04 had 1) | n/a | 0 in ≥ 8 of 10 | **held** |

`DESIGN` position against first mutation, per treated run: 16/17, 18/19, 16/17, 12/13, 12/13,
18/19, 14/15, 20/21, 15/16, 16/17. **The first mutating call is the very next event after the
`DESIGN` marker in all ten runs** — the agent announces the phase and then writes, with nothing
between. That is the code-order clause met as tightly as it can be met, and it is also why P4
matters: a model that wanted to write earlier had `Bash` available and did not use it (nine of ten
runs at zero pre-`DESIGN` `Bash` writes).

**The two treated runs that fail the checker overall fail neither P2 nor P3.** Runs `5a785fe7`
(pair 05) and `0e51ffdd` (pair 10) carry all six markers in order and both write after `DESIGN`;
they fail the **third** check, `completion` — *"DONE is missing contract field(s): Requirement,
Changed, Tests, Verification"*, identically in both. **8 of 10 treated runs produce a complete DONE
contract.**

That is the sharpest thing this batch says about the build's own stated purpose. B5 exists to
*"prevent premature coding and false completion"*. **Premature coding: prevented, 10 of 10.
False completion: leaked, 2 of 10.** The half of the purpose that needs the model to fill in a
structured report at the end is the half that slips, and it slips while every marker is still
present — a run can announce `DONE` correctly and still not say what it changed.

### Quality, all four categories, both arms, `n = 10` each

Registered scorer codex (`codex-cli 0.147.0`), rubric `benchmark/rubrics/backend-quality.yaml`
sha **`396e1799eb2b`** on all 20 sheets, no sheet disagreeing.

| Category | Treated distribution | Control distribution | Fisher (anchor 2) |
|---|---|---|---|
| `architecture-consistency` | **2 × 10** | **2 × 10** | — no variance in either arm |
| `maintainability` | 0 × 7, 2 × 3 | 0 × 7, 2 × 3 | `p = 1.0` — **the identical distribution** |
| `change-focus` | 1 × 9, 2 × 1 | 1 × 10 | `p = 1.0` |
| `test-quality` | 1 × 9, **2 × 1** | 1 × 5, 2 × 1, **null × 4** | `p = 1.0` |

**The §4a review's finding 5, disputed with the arithmetic** *(added 2026-09-09)*. The review
objected that the `p = 1.0` above counts the control's four `null` cells as "not anchor 2", a
denominator the registration never chose, and that excluding them — 1 of 10 against 1 of 6 — would
give a different `p` and undermine P7. **It does not.** Two-sided Fisher exact, both ways:

| denominator | table | `p` |
|---|---|---|
| nulls counted as not-anchor-2 | 1/10 vs 1/10 | **1.0000** |
| nulls excluded | 1/10 vs 1/6 | **1.0000** |

The conclusion is invariant to the choice. **And P7 does not rest on the comparison at all**: it is
registered as an absolute count in the treated arm — *"≤ 3 of 10, and specifically not ≥ 5"* — which
the control's denominator cannot touch. The Fisher figure is supplementary and was always so. The
finding was worth raising and the objection is answered by computing it rather than by asserting it.

**P7 held: `test-quality` anchor 2 in the treated arm is 1 of 10**, against a registered ceiling of
≤ 3 and specifically not ≥ 5. **Decision-rule row 4b does not fire** — the treated arm is nowhere
near 7 of 10, so declared phases did **not** return what E-007's structural split returned, and
[E-007](E-007-orchestration-overhead.md) needs no amendment from this batch. The mechanism
registered for P7 is the one that survives: markers change what is narrated, not what is in the
context window at the moment the tests are written.

**And the batch says something louder than any of its own predictions.** `architecture-consistency`
is 2 on twenty runs out of twenty. `maintainability` is 0×7/2×3 in *both* arms — not similar,
identical. That is **50 of the rubric's 100 points at zero variance across both arms**, which is
precisely the measurement [E-006](E-006-agent-boundary.md)'s batch 2 produced and precisely the
reason author decision 9 added BE-004 from this stop on. **The decision was made before this batch
and this batch is its confirmation, not its motivation.** On BE-003, with this model, there is
almost nothing left for a customization to move.

The four `null` cells are all in the control arm and all in `test-quality`. A null is a
measurement, not a gap: the rubric emits `null` when its anchors cannot separate two scores, and
four control runs gave it nothing to separate. The treated arm produced no nulls — it always wrote
enough test code to be scorable, consistent with its median 79 added lines against the control's
41.5.

### The second reader — 20 of 20 sheets, and a replication of lab#70 on fresh runs

Decision C stands: **codex produces the numbers, opencode is the second reader and is not a vote.**
Every run above was scored a second time with `./tools/opencode-score.sh`, model
`ollama-cloud/deepseek-v4-pro`, opencode `1.18.27`, against the same rubric sha `396e1799eb2b`.
**20 of 20 sheets, no stalls.**

| Category | codex vs deepseek, exact agreement |
|---|---|
| `architecture-consistency` | **20 / 20** |
| `maintainability` | **20 / 20** |
| `test-quality` | **20 / 20** |
| `change-focus` | **7 / 20** |

**Sixty of sixty on the three categories that carry every registered outcome of this experiment,
and 7 of 20 on the one that carries none.** That is [lab#70](../evidence/second-reader/README.md)'s
measurement — 34/34 on the other three, 18 of 34 on `change-focus` — **reproduced on twenty runs
it had never seen**, and reproduced worse: 35 % agreement here against 53 % there.

**This is direct, independent support for author decision 10.3**, which carves `change-focus` out
of the Decision H fallback and makes a fallback-scored `change-focus` cell report-only. The
decision was taken on 34 runs; it now has 20 more, from a different task batch, saying the same
thing more strongly. **Nothing in E-010 depends on it** — no registered prediction reads
`change-focus` — so this changes no number above; it is evidence about the instrument.

**One correction to lab#70's phrasing, offered with its `n`.** That file records the
`change-focus` disagreements as *"always in the same direction"*. On these twenty they are not:
deepseek scored **higher** in 8 cases (`1 → 2` seven times, and `null → …` aside), **lower** in 1
(`2 → 1`, pair 06 treated), and returned **`null` where codex returned 1** in 4. A mixed
disagreement is a different defect from a biased one — a bias can be corrected for, and this
cannot. The distinction matters for anyone tempted to rescue `change-focus` with an offset rather
than a re-score, and it argues that 10.3's "report-only" is the right treatment rather than a
conservative one.

*Added by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*

**And a note on how nearly this table read `0 / 20` in every row.** The first extraction of these
sheets returned `MISSING` for all eighty cells and would have been reported as total disagreement,
because the codex sheets quote their category names (`- name: "architecture-consistency"`) and the
opencode sheets do not (`- name: architecture-consistency`), and the regex required the quotes. It
was caught because a clean `0/20` across four independent categories is not a result, it is a
broken instrument — the house failure mode, met once more, in a five-line script.

### A second hand re-read, on a `null` — and what the anchor-2 count was hiding

§5 asks for one hand-read cell; this is a second, taken deliberately on the **control** arm and on
a **`null`**, because a null is the cell a reader is most likely to mistake for a gap and because
the first hand reading was on a treated run and could not test the scorer for arm bias.

- **Run:** `836269db-e038-480d-ab29-b2ebbfd3fa51` — pair 02, **control** arm. Sheet value: `null`.
- **Hand value: `null`. The sheet is right.**

The rubric's rule, quoted from the file at sha `396e1799eb2b`: *"`null` keeps exactly two jobs: a
precondition failed (no test file, no baseline), or the evidence does not let you decide whether
the 0 condition holds. Never as a shrug."* And the precondition: *"No file under `src/test/` among
the attachments, OR a test file that makes no assertion at all → `score: null`, reason: nothing to
grade. Never 0."*

The run changed `ApiError.kt` (+1) and `ShipmentController.kt` (+18) and **touched nothing under
`src/test/`**. `ShipmentControllerTest.kt` exists but is the pre-BE-003 baseline — its own docstring
says so — and contains no mention of `confirm`. **The run implemented the endpoint and wrote no
test for it.** `null` is the correct cell and it is a measurement.

**Now count the nulls, which is a thing the anchor-2 comparison cannot see.**

| | wrote scorable test code for `confirm` | wrote none (`null`) |
|---|---|---|
| treated | **10 of 10** | 0 |
| control | 6 of 10 | **4** |

Two-sided Fisher exact, `p = 0.0867`.

**This is the only quality-adjacent difference between the arms in the whole batch, and P7 is
blind to it by construction.** P7 counts anchor 2 and the two arms tie there at 1 of 10, `p = 1.0`.
But *reaching* an anchor requires test code to exist, and the plain baseline skipped writing tests
for the feature in **four of ten runs** while the phases arm never did — which is what
`<<PHASE:VERIFICATION>>` with an output contract is for.

**It is not a result of this experiment and is not claimed as one.** `p = 0.0867` does not clear
0.05; the null *rate* was registered as an outcome nowhere in E-010; and it was noticed because a
hand re-read was aimed at a null rather than by any rule written before the run. It is recorded
here, with its `n`, as **the outcome the next stop on this task should register in advance** —
"did the arm write a test at all" is a cheaper and more discriminating question on BE-003 than
"how good was the test", and BE-003's anchor distribution has been flat across every arm since
E-006.

*Added by Opus 5 (claude-opus-5), autonomous, 2026-09-09. No registered prediction or result above
is altered by it.*

### Independence check — what else moved between the arms

Read from the run records, not from the flags that were passed:

| Variable | Treated | Control |
|---|---|---|
| `runtime.model` | `claude-haiku-4-5-20251001` × 10 | `claude-haiku-4-5-20251001` × 10 |
| `customization.agentHash` | `sha256:b3450564b6f32d6193e8580db766210e` × 10 | `null` × 10 |
| `customization.instructionsHash` | `null` × 10 | `null` × 10 |
| rubric sha in every sheet | `396e1799eb2b` | `396e1799eb2b` |
| benchmark tree / baseline | `eeb15a753adc94e92bc3f74c50e1b02fc3b53030` at benchmarks `eea144ef` | same |
| evaluator | BE-003 `1.0.0`, exit-code contract untouched | same |

**One thing did differ and it is not the treatment.** Pair 04's **control** made one delegating
call (`delegating_calls = 1`); no treated run made any. That is threat 7, registered before the
run and written into the batch driver as an executable asymmetry: the control is handed 29 tools
including `Task` and may legitimately delegate, while a *treated* delegation would have been
decision-rule row 0a and would have stopped the batch. The count is written to the manifest on
every run **including when it is zero**, so this is one control run in ten, observed, not a
confound discovered afterwards.

**Two telemetry values were re-derived from the raw stream** rather than trusted from the API,
because P5 and P6 decide the gate. Counting `claude_code.api_request` log records keyed on the
resource attribute `observatory.run.id` in
`agent-observatory/infra/telemetry-out/events.jsonl`: run `5395964c` (treated) = **20** model calls,
`cost_usd` sum **0.0996592**; run `42f3f80b` (control) = **24** model calls, `cost_usd` sum
**0.172395**. The API reports 20 / 0.099659 and 24 / 0.172395. **They agree exactly.**

### P1's second half — the `init.tools` read-back on all 20 runs, and what it says about stop 9

P1 asks not only for the agent hash but for each treated run's `init` record to deliver a tool set
containing `Edit` **and** `Write`. Read from
`evidence/b05/batch-BE-003-*/init-schema/init-schema-<run-id>.txt`, one file per run, written by
the runner at `init` and not by this analysis:

| Arm | Tools delivered | `Edit` | `Write` | `Task` | Runs |
|---|---|---|---|---|---|
| treated | **4** | yes | yes | **no** | 10 of 10 |
| control | 29 | yes | yes | yes | 10 of 10 |

The overlay declares `tools: Read, Edit, Write, Bash` — **four names, and four were delivered, on
every one of ten runs.**

**That is a change from stop 9 and it should be said plainly.** [E-005](E-005-agent-tool-boundary.md)
measured the runtime *rewriting* a declared list before the model saw it: `Read, Grep, Glob, Bash`
arrived as `["Read","Bash"]` on 10 of 10 runs, which is why author decision 8 made the `init.tools`
read-back mandatory before any B step registers an allowlist. **Here the rewrite did not happen.**
Ten of ten treated runs received exactly the declared four. The probe that decision 8 requires is
the reason this can be stated rather than assumed, and this is the first batch in the run where it
came back clean.

**It also closes threat 7 mechanically rather than statistically.** No treated run could delegate:
`Task` was not in its four. The control was handed 29 tools including `Task` and used it once, in
pair 04. So "no treated delegation" is not a lucky observation about ten runs — it is a property of
what the runtime delivered, readable in a file written before the model's first turn.

*Added by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*

### The §5 hand re-read against the sheet it was taken before

| | `test-quality`, run `5395964c` | Reason given |
|---|---|---|
| Hand reading (taken first) | **1** | persisted state never re-read through a separate `get(...)` |
| Registered codex sheet | **1** | *"Repeat body and refusal envelope are asserted, but persisted state is not re-read"* |

Same value, **and the same clause**, reached independently. That is one cell of twenty and it is
not a validation of the harness in general; it is the one check §5 asks for, and it passed on both
the number and the reason.

## Which predictions held

Wrong predictions stay wrong. Nothing below was edited after the run.

| # | Prediction | Registered | Observed | Verdict |
|---|---|---|---|---|
| P1 | delivery | 10/10 hash, 0/10 null | 10/10, 0/10 | **held** |
| P2 | six markers in order | ≥ 9 of 10 | **10 of 10** (control 0 of 10) | **held** |
| P3 | first write after `DESIGN` | ≥ 9 of 10 | **10 of 10** | **held** |
| P4 | pre-`DESIGN` `Bash` writes = 0 | 0 in ≥ 8 of 10 | 0 in 9 of 10 | **held** |
| P5 | `modelCalls` ≥ +4, q1 > 26 | treated higher | treated **−1.5 (−6.8 %)**, quartiles overlap | **REFUTED, opposite direction** |
| P6 | `estimatedCost` ≥ +25 %, q1 > 0.175 | treated dearer | treated **−20.4 %** | **REFUTED, opposite direction** |
| P7 | `test-quality` anchor 2 ≤ 3 of 10 | ≤ 3, not ≥ 5 | **1 of 10** | **held** |
| P8 | evaluator pass ≥ 9 of 10 | floor | 10 of 10 both arms | **held** |

Six held, two refuted, and **the two that were refuted were refuted together and in the same
direction**. P6 said so itself before the run: *"If this prediction is wrong in the E-007
direction, the compounding mechanism is wrong and that is worth more than the prediction."* It is
wrong in the E-007 direction. **The compounding mechanism is wrong.** Six phase announcements plus
six output contracts did not add turns, so they could not compound context; the agent instead
reached its first write at event 13–21 and finished in fewer calls than a plain baseline that
wandered (control `modelCalls` range 14–31 against treated 16–24 — the treatment's visible effect
on cost is that it **narrowed the spread**, and the cheapest single run in the batch is still a
control).

## Decision

**Decision rule, walked in order, stopping at the first row that fires:**

- **Row 0** — P1 fails? No: 10 of 10 treated carry the agent hash, 0 of 10 controls do, and every
  sheet is at rubric `396e1799eb2b`. Does not fire.
- **Row 1** — P2 ≤ 5 of 10? No: P2 is 10 of 10. Does not fire.
- **Row 2** — P2 ≥ 9 **and** P3 ≤ 5? No: P3 is 10 of 10. Does not fire.
- **Row 3** — P2 ≥ 9 **and** P3 ≥ 9 **and** (P5 or P6 clears its MDE)? P2 and P3 hold; **neither
  P5 nor P6 clears**, because both were registered as increases and both were observed as
  decreases. Does not fire.
- **Row 4** — the same, **and nothing improved**? The treated arm cost **20.4 % less**. Something
  improved. Does not fire. ***The §4a review's finding 2 is that "nothing improved" is undefined,
  and it is right.*** Read as *no outcome of any kind moved*, row 4 cannot fire and row 5 does.
  Read as *no **quality** outcome moved*, row 4 fires and the verdict becomes `NOT DETECTABLE`.
  **The first reading is applied, and the reason is registration order, not preference:** row 4's own
  gloss is *"the phases are followed and **cost** nothing this `n` can resolve"* — the clause names
  cost, and cost is exactly what moved. A rule whose gloss names cost cannot be read to mean quality
  when the cost moved the wrong way. The ambiguity is a defect in the rule as written, it is recorded
  here rather than resolved silently, and **the rule is not edited** — a later step registering this
  decision rule should say which outcomes count as "improved" before the run.
- **Row 5** — anything else. **Fires.**

### Verdict: INCONCLUSIVE — and the combination that produced it, not rounded to a neighbour

> The phases are observable (10 of 10), they are followed in position (10 of 10), and the overhead
> they were built to cost was measured and came out **negative**. The decision rule cannot name
> this outcome because every row in it assumed the treatment would cost more.

This is not "NOT DETECTABLE" and must not be recorded as it: row 4 requires that nothing improved,
and a 20.4 % cost reduction is not nothing. It is not "CONFIRM" either: row 3 requires an MDE to be
cleared, and an MDE registered in one direction is not cleared by a result in the other. **The
honest verdict is row 5, and the reason row 5 exists is exactly this.**

### Stress-testing the verdict — is "nothing improved" really false?

Row 4 (`NOT DETECTABLE`) turns on the clause *"and nothing improved"*, and row 5 was chosen over it
because the cost fell. That is the single judgement in this write-up most worth attacking, so it
was attacked, and **the attack is recorded whichever way it came out**.

**The case for row 4.** Apply the registered MDE symmetrically — it asked for *"≥ 25 % on the
median **and** treated q1 > 0.175"*, so its mirror asks for a ≥ 25 % fall with treated q3 below
control q1. Observed: a **20.4 %** fall, short of 25; and treated q3 `$0.1217` sits `$0.0001`
**above** control q1 `$0.1216`, so the quartiles overlap, by one ten-thousandth of a dollar. **By
the registered instrument, read symmetrically, the reverse effect does not clear either.** On that
reading nothing cleared anything and row 4 fires.

**The case against it, from the same twenty numbers:**

```
treated  0.0986 0.0997 0.1012 0.1042 0.1174 0.1182 0.1183 0.1217 0.1224 0.1283
control  0.0935 0.1044 0.1216 0.1454 0.1474 0.1485 0.1612 0.1724 0.1975 0.1997
```

- **All 10 treated runs are cheaper than the control's median** ($0.1480). The treated *maximum*,
  $0.1283, is below it.
- The treated **median** ($0.1178) sits below the control's **first quartile** ($0.1216).
- Treated is cheaper in **81 of 100** pairwise run comparisons, no ties.
- Permutation test on the median difference, 200 000 relabelings: **two-sided `p = 0.026`**.

**Verdict on the verdict: row 5 stands.** Row 4 requires that nothing improved, and that is a
statement about the world, not about a threshold. Something improved: every treated run came in
under the control's median. A threshold registered in the opposite direction failing to be
cleared by 4.6 percentage points does not make a consistent, one-directional shift across the whole
distribution into "nothing".

**And the permutation test decides nothing here, deliberately.** It was not registered, it was run
after the data was seen, and this project's own rule is that a test chosen after the fact measures
the chooser. It is reported because it is the strongest available check on a judgement call, and it
is fenced off from the decision rule for exactly the reason it is persuasive. **What the registered
instruments say is what stands: P6 refuted, no MDE cleared in either direction, row 5.**

*Added by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*

### The build-track gate is a different question, and it is answered yes

`build/README.md#b5` asks three things, and none of them is the experiment's decision rule:

| Gate clause | Answer | Evidence |
|---|---|---|
| phase markers observable in the transcript | **yes** | `check-phase-contract.py` check 1, 10 of 10 treated, 0 of 10 control |
| no code written before DESIGN | **yes** | check 2, 10 of 10; first mutation is the next event after `DESIGN` in every run |
| overhead measured, not assumed | **yes** | measured at `n = 10` per arm from telemetry re-derived against the API; it is **−20.4 %** cost and **−6.8 %** turns |

**The gate passes and the experiment is inconclusive, and both statements are true at once.** The
gate asks whether the overhead was measured; the decision rule asks whether it was what we said it
would be. It was measured. It was not what we said.

### Keep, modify, or remove

**Keep `phases-v1.0`, unpromoted, and this is a keep on the gate, not on the decision rule.**

- It does what it claims at the level the gate can see: 10 of 10 on both observable clauses, by a
  checker whose fixture set is shown to reject the retroactive-narration shape.
- It is not free of defects: **2 of 10 runs emit `DONE` without its four contract fields**, which
  is the false-completion half of the build's purpose leaking. That is a v1.1 item, not a reason to
  remove a v1.0.
- It is **not promoted**, and nothing here promotes it. §6 forbids promotion on one batch, and the
  quality evidence is a flat 50-of-100 points with no variance in either arm — there is no measured
  quality benefit to promote on.
- **What is removed is a belief, not a file:** the compounding-context mechanism written into P6.
  It is refuted here and was refuted in the same direction by E-007, and no later step should
  register it again without new grounds.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-09.*

