# Experiment E-017 — a permission-blocked run is recorded as a capability failure

**Key:** `EXP-5B5-PERMISSION-BLOCK-BE003` · **Spine stop 16** (Phase 5B, Lab 5B.5) ·
**Task:** BE-003 only · **Agent under test:** `claude-haiku-4-5-20251001`

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-11T10:5xZ; the author did not
review before the run.`

> Everything down to and including **Decision rule** was written and committed **before the
> first run**. The prediction commit sha and the first run's `startedAt` are written into
> *Sanity checks* after the batch.

## Question

When the harness withholds a permission the agent needs, what does the instrument record —
and can anything in the record tell that apart from an agent that produced a wrong answer?

This is `agent-observatory` **#47**, whose acceptance criteria are still open, and **Lab
5B.5**: *"harness bug #7, reproduced deliberately and then fixed."*

## Hypothesis

**The instrument records a permission block as a capability failure, and nothing in the run
record distinguishes the two.** The mechanism is a single condition, not a general weakness.

`run-agent.sh:1203` holds the only guard that can override the evaluator's verdict before it
is posted:

```
PRODUCED_NOTHING == true  &&  toolCalls == 0   →   ABORT_CLASS="F13"
```

Its own comment states the reason it is narrow: *"a run that explored and then stalled has
tool calls, so it is untouched and keeps counting against its arm — which is what must happen
when the thing under test is what made the agent hesitate."* That is correct when the
**treatment** made the agent hesitate and wrong when the **harness** did, and the guard cannot
tell the two apart because it never looks at *why*.

A blocked agent reads files before it is stopped, so `toolCalls > 0`, the guard does not fire,
and the run falls to `tasks/BE-003-confirm-shipment/evaluator.sh:377-383` — a pure worktree
ladder that has no access to the transcript, the telemetry or the permission state and
therefore **cannot** classify a block however it is written.

## Predictions

*Each states its direction, its magnitude, and the mechanism it rests on. P1 is the registered
primary.*

1. **(primary, one-arm binomial) Every blocked run is recorded with a capability failure class.
   10 of 10 treated runs carry one of `F02`/`F03`/`F04`/`F05`/`F07`; 0 of 10 carry `F10`, `F13`
   or `F15`.** *Mechanism:* named to the line above — the only pre-evaluator guard requires
   `toolCalls == 0`, no other branch of `run-agent.sh` reads permission state, and the
   evaluator's ladder is a function of the worktree alone. **Refuted by a single treated run
   classed as infrastructure.**

2. **The two blocking channels leave *different* traces, and the deny channel may leave none.
   Arm H (hook, exit 2) records `permissionDenials > 0` on ≥ 4 of 5; arm D (deny rule) I
   predict at 0 of 5.** *Mechanism:* `permissionDenials` counts `tool_decision` events whose
   `decision != "accept"` (`runner/lib/claude-telemetry.sh:68-70,109`). A hook that blocks an
   *attempted* call should produce such an event; a `permissions.deny` rule may suppress the
   call before any decision event is emitted. **This is the prediction I expect to be wrong,
   and it is registered because the answer decides what a classifier can key on.** obs#47's own
   evidence points this way: *"`permissionDenials` was 0 throughout: nothing was refused."*

3. **The block is total. 10 of 10 treated runs change zero files** (`PRODUCED_NOTHING == true`).
   *Mechanism:* `Edit`, `Write` and `NotebookEdit` are all withheld, and those are the only
   write paths the agent has.

4. **The control is clean and it works. 0 of 10 control runs show any block trace, and ≥ 8 of
   10 pass.** *Mechanism:* the control passes no `--customization`, so no overlay file exists
   in its worktree. haiku passed this task 10 of 10 in `EXP-BE002-MODEL-TIER` and every BE-003
   arm since.

5. **(after the fix) The fix reclassifies every blocked run and no passing one. 10 of 10
   confirmation runs are recorded as infrastructure and excluded from a registered analysis;
   replaying the classifier over the 6 stored runs with `permissionDenials > 0` reclassifies
   0 of 6.** *Mechanism:* the condition is a conjunction requiring an empty changed-file set,
   and all six of those runs changed files and passed.

6. **(registered because I expect the fix to be incomplete) The fix does not close obs#47's
   own observed failure. Replaying the classifier over `EXP-BE002-MODEL-TIER`'s 7 `F05` sonnet
   runs reclassifies 0 of 7.** *Mechanism:* those runs have `permissionDenials == 0` — verified
   in the store before this was written, toolCalls 11/12/18 — so the telemetry conjunct is
   false whatever the changed-file conjunct does. **If this prediction fails, the classifier is
   over-firing and P5's second half is in doubt**; that is the outcome to watch for, not a
   bonus.

*A prediction you did not write down is always retroactively correct.*

## Independent variable

**Whether the agent is permitted to write.** One thing.

The treated arm has writes withheld; the control does not. Both arms are otherwise the same
runner invocation, model, benchmark commit and evaluator.

The treated arm is delivered by **two channels**, 5 runs each, and this is a registered
decision rather than an extra variable: *the treatment is identical in both* — writes are
withheld — and only the **channel** differs. It is registered because the channel is exactly
what obs#47 is about: *"the block span reports that a tool was blocked, not why — `decision`
and `source` both come back `unknown`."* Measuring what each channel leaves in the record is
the measurement, not a confound in it.

> **Decision: two delivery channels in the treated arm, 5 runs each rather than 10 of one.**
> This is not the *"new arm"* §7 reserves for the author. No version is defined at this stop,
> nothing is promoted, the task is unchanged, and both sub-arms carry the same treatment. It is
> registered here before any run, with its own prediction (P2). The alternative — picking one
> channel — would have made P2 unanswerable and left the classifier keying on a signal nobody
> had checked exists.
> *Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-11.*

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism, arm D | `--customization build/customizations/permission-block-deny-5b5`, carrying `.claude/settings.json` with `permissions.deny: ["Edit","Write","NotebookEdit"]`, read because the runner passes `--setting-sources project` under `ISOLATE_USER_SETTINGS=1` |
| Mechanism, arm H | `--customization build/customizations/permission-block-hook-5b5`, carrying a `PreToolUse` hook on `Edit\|Write\|NotebookEdit` that exits 2 |
| Content hash, arm D | `.claude/settings.json` = `sha256:5db13bc81cc1` |
| Content hash, arm H | `.claude/settings.json` = `sha256:c50f5628c4a7` · `.ai/hooks/block-writes.sh` = `sha256:a714b7239e6d` |
| Preflight assertion | **Not a hash.** See below. `--check-customization` must report every overlay file **tracked in the setup commit** (`git ls-files`, not "the file is in the worktree"), and one real run per channel must show the block occurring: for arm H, `.ai/block-writes.log` exists with **line count equal to the independently counted write-tool calls**; for arm D, zero files changed with `toolCalls > 0` |
| Control assertion | No `--customization` is passed, so no overlay path exists in the worktree; `git ls-files` over the overlay paths returns 0, `.ai/block-writes.log` is absent, and the control's changed-file set is non-empty |

> **Why the delivery proof is not a hash, which is the thing this experiment found before it
> ran.** `run-agent.sh:626-629` records exactly three customization hashes — `instructionsHash`
> (`CLAUDE.md`), `skillsHash` (the `SKILL.md` set) and `agentHash`
> (`.claude/agents/<name>.md`). **There is no `settingsHash`.** An overlay whose only payload is
> `.claude/settings.json` is therefore `null` in all three, and a run record cannot show it was
> delivered. B7 hit the same wall and used its hook's own log; its handoff then recorded that
> *"the log exists iff the hook executed"* cannot separate *"no hook installed"* from *"hook
> broken, denying everything"* — both leave no log. **Count agreement can**, so arm H's hook
> writes one line per invocation and the assertion is `lines == write-tool calls`, not
> `lines > 0`.
>
> Arm D has no such self-proof available, and that asymmetry is real rather than an oversight:
> it is why arm D's delivery assertion is the *behavioural* one (zero files changed while tools
> were called) and why P2 predicts it leaves no telemetry trace at all. **If arm D changes no
> file and emits no denial event, the honest reading is that the instrument cannot see a deny
> rule at all** — a stronger version of obs#47, not a failed arm.
>
> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.

## Controlled variables

- [ ] starting commit / benchmark revision SHA — one value across all arms, read back per run
- [ ] task + revision — BE-003 only; **author decision 9's second task does not apply**: it
      binds *"every B step"* from stop 12, and stop 16 is a Track A stop that builds no version
- [ ] harness + version — `claude` CLI; the mid-batch version guard that ended B7's batch stays
      armed, and a move aborts rather than mixing runtimes
- [ ] model — `claude-haiku-4-5-20251001`, exact id, read back per run
- [ ] permissions / permission mode — `--permission-mode acceptEdits` on **both** arms; the
      treated arm's withholding is layered on top by the overlay, so the flag itself never moves
- [ ] environment — `--strict-mcp-config`, `--disable-slash-commands`, `--setting-sources
      project` via `ISOLATE_USER_SETTINGS=1`; verified by observing 0 hook executions on the
      control, not by trusting the flag
- [ ] runner commit — one value, recorded; **the runner is not edited between batch 1 and the
      preflight of batch 2**, and the batch-2 change is named and hashed before it runs

## Runs

Repetitions per arm: **batch 1** — 5 arm D + 5 arm H + 10 control, interleaved · **batch 2**
(confirmation, after the fix) — 10 treated · Total **30 runs** · Budget ≈ **$4.50**

Batch 2 re-runs the treated arm only. The fix changes a classification step that executes
*after* the agent, so "does the fix leave a normal run alone" is answered by replaying the
classifier over batch 1's 10 control runs and the 6 stored denial runs — which is stronger
than 10 fresh control runs, because it is the same runs before and after.

*One run is a story. Five is a hint. Ten is the minimum for a decision.*

## Minimum detectable effect

**Derived from a measured population, before any threshold above was written.**

The reference population is every run in the store that was blocked or denied in some sense:
the **6** runs with `permissionDenials > 0` (`EXP-4B-ORCH-OVERHEAD`) and the **7** `F05` sonnet
runs of `EXP-BE002-MODEL-TIER`. **0 of those 13 carry an infrastructure class.** P1 predicts
that measured 13-of-13 pattern continues.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: infrastructure-classification rate of a blocked run | 0 of 13 across the two stored populations | at `n = 10`, a true rate **≥ 26 %** yields ≥ 1 such run with 95 % probability (`1 − 0.74¹⁰ ≈ 0.95`). **Below ~26 % this arm cannot distinguish the rate from zero** | yes |
| secondary: `permissionDenials > 0` rate per channel | no stored run of either channel exists — this is the first | at `n = 5` per channel, a true rate **≥ 45 %** yields ≥ 1 with 95 % probability. **A 0-of-5 result is consistent with any true rate up to ~45 %** and is reported as *"not observed at n = 5"*, never as *"the channel emits nothing"* | yes |

**P1 is a one-arm binomial claim** — *"this arm reaches X on ≥ k of n"* — so it is refuted by
distance from `k` regardless of the control, and needs no two-arm test. P4 is the only
two-arm statement and it is a sanity check on the harness, not the result.

**Nothing from `n < 5` is stated as a property.** Arm D and arm H are `n = 5` each: their
results are true *of those five runs* and are reported that way. Only P1, pooled over `n = 10`
treated runs, is stated as a property of the instrument.

## Deterministic evaluation

`tasks/BE-003-confirm-shipment/evaluator.sh` at its registered sha, unchanged, exit-code
contract untouched. **This experiment does not move the evaluator** — doing so is a §7 halt,
and the whole design exists because the evaluator is the wrong layer for this question.

`./tools/check-run-gate.sh` admits each run for analysis by the evaluator's recorded verdict
(Decision D).

## Exclusions

Registered now, not after seeing the data:

- A run whose `runtime.version` differs from the batch's first run — the CLI auto-updated
  mid-batch once already (B7, `2.1.267 → 2.1.268`) and the guard aborts rather than mixing.
- A run classed `F15` for **contamination** or for missing telemetry — those are the existing
  infrastructure paths and are not this experiment's subject. **A treated run classed `F13` by
  the existing narrow guard is NOT excluded**: it is a refutation of P1 and must be counted as
  one.
- **No run is excluded for being blocked.** That is the measurement.
- A run made across a machine sleep: duration is excluded, the run is not.

## Decision rule

Registered before data. Rows are exhaustive over P1's outcome, which is the primary.

| # | Condition | Verdict |
|---|---|---|
| 1 | ≥ 9 of 10 treated runs carry a capability class and 0 carry infrastructure | **CONFIRM** — the defect is reproduced under the pinned model; build the fix and run batch 2 |
| 2 | 1–4 of 10 treated runs are classed infrastructure | **CONFIRM WITH A NAMED LEAK** — reproduce, and identify which existing branch caught the minority before building anything |
| 3 | ≥ 5 of 10 treated runs are classed infrastructure | **REFUTED** — the instrument already handles this and obs#47's requirement (2) is closer to met than the code reading suggested; report that and do not build a classifier nothing needs |
| 4 | fewer than 8 of 10 treated runs are actually blocked (P3 fails) | **VOID for P1** — the treatment did not deliver; P1 is unanswerable and is reported as such, not as a null |
| 5 | the treated arm blocks and *passes* anyway | **INCONCLUSIVE, and the most interesting outcome** — the task is satisfiable without writing, which would invalidate the reproduction and say something about BE-003 |

**Cost is not a condition on any row above.** A free defect is still a defect.

**For the fix (batch 2), registered separately:** KEEP only if P5 holds in **both** halves —
10 of 10 confirmation runs reclassified **and** 0 of 6 stored passing denial-runs reclassified.
A fix that reclassifies blocked runs while also catching a passing one is **REJECTED**, not
tuned: obs#47 names that failure itself — *"a permission block silently converted into a
passing-looking dataset is how this class of bug survives."*

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

Batch of **20 runs**, `EXP-5B5-PERMISSION-BLOCK-BE003`, 10 control + 5 arm D + 5 arm H, exactly
the registered allocation, interleaved, across 2026-09-11 and 2026-09-13 (an API container OOM
split the batch; the incident is at `evidence/p05b/batch-20260911T195225Z/INCIDENT-api-oom.md`
and nothing was lost). `runtime.model` is `claude-haiku-4-5-20251001` on **all twenty** and
`runtime.version` is `2.1.268 (Claude Code)` on **all twenty**, so the registered exclusion for a
mid-batch CLI move excludes nothing.

**`behavior.changedFiles` is `null` on all twenty records.** The field this design leaned on for
P3 does not answer it. The changed-file count is taken instead from each kept worktree with
`git status --porcelain`, which is the count the fix's own caller uses.

**All five `customization.*Hash` fields are `null` on all twenty records**, control and both
treated channels alike. There is no `settingsHash` and both overlays are `.claude/settings.json`.
The delivery proof is therefore the setup commit's tracked file set at the registered sha plus the
treatment observably firing, per run, all twenty: `evidence/p05b/delivery/`.

| arm | n | median cost | cost range | median toolCalls | median duration |
|---|---|---|---|---|---|
| `plain` (control) | 10 | **$0.132** | 0.107–0.163 | 15.5 | 73 s |
| `blocked-deny-5b5` (arm D) | 5 | **$1.022** | 0.605–1.207 | 78 | 507 s |
| `blocked-hook-5b5` (arm H) | 5 | **$0.082** | 0.070–0.122 | 9 | 36 s |

## Results

**The gate.** `check-run-gate.sh` over all twenty: 11 pass, 9 refused (Decision D). Control 10 of
10; arm D 1 of 5; arm H 0 of 5. `evidence/p05b/batch-20260911T195225Z/gate/`. No run is excluded
for being blocked — that is the measurement.

**The result of this experiment is that its two delivery channels are not one treatment, and the
data says which is which.**

| | arm D — `permissions.deny` | arm H — `PreToolUse` hook, exit 2 |
|---|---|---|
| delivered? | **yes, 5 of 5** — `.claude/settings.json` tracked at `5db13bc81cc1` | **yes, 5 of 5** — both files tracked, settings at `c50f5628c4a7` |
| treatment observably in force? | **yes** — the runtime returned *"No such tool available: Edit. Edit is disabled for this session, in subagents as well as here"* on 5 of 5 | **yes** — `.ai/block-writes.log` line count **equals** the independently counted Edit calls on 5 of 5 (2=2, 3=3, 1=1, 1=1, 3=3) |
| did it withhold the capability? | **no. 0 of 5 blocked.** 2–13 files changed | **yes. 5 of 5 blocked.** 0 files changed |
| what the agent did next | attempted `Edit` exactly **once**, then completed the task with **29–91 `Bash` calls** | attempted `Edit` 1–3 times, then **stopped**: 8–11 tool calls total |
| cost against the control | **7.7×** | 0.62× |

**`permissions.deny` on `Edit`/`Write`/`NotebookEdit` is not a write boundary; it is a speed
bump — and an expensive one.** It removes three tool *names* from the registry and leaves `Bash`,
which writes files. This is position 9's finding arriving by a second road: *a tool list filters
names, not capabilities.* There the list was `tools:` on an agent overlay; here it is
`permissions.deny` in project settings; both leave the capability in the pool.

## Which predictions held

| | prediction | registered | observed | verdict |
|---|---|---|---|---|
| **P1** | *(primary)* 10 of 10 treated carry `F02`/`F03`/`F04`/`F05`/`F07`; 0 carry `F10`/`F13`/`F15` | 10 / 0 | 8 carry a capability class · **1 carries `F13`** (`b2453820`) · 1 carries none (`3bd8fcd8`, passed) | **VOID — see the decision rule below.** Not a null |
| **P2** | arm H `permissionDenials > 0` on ≥ 4 of 5; **arm D on 0 of 5** | ≥4 / 0 | arm H **5 of 5** (1,1,2,3,3) · arm D **4 of 5** (0,1,4,8,15) | arm H **HELD** · arm D **REFUTED** |
| **P3** | the block is total: 10 of 10 treated change zero files | 10 of 10 | **5 of 10**, and it splits **exactly by channel**: arm H 5 of 5 at zero, arm D 0 of 5 | **REFUTED** |
| **P4** | control clean: 0 of 10 show a block trace and ≥ 8 of 10 pass | 0 / ≥8 | **0 of 10** denials · **10 of 10** passed | **HELD** |
| **P5** | *(after the fix)* 10 of 10 confirmation runs reclassified **and** 0 of 6 stored denial runs reclassified | 10 / 0 | second half **0 of 6, HELD**. First half **not answerable as written** — see below | **half held, half unanswerable** |
| **P6** | *(registered expecting the fix to be incomplete)* replay over the 7 `F05` sonnet runs reclassifies 0 of 7 | 0 of 7 | **0 of 7** | **HELD** |

**P2 was registered as the one I expected to be wrong, and it was wrong in a way worth having.**
Arm D carries denials of 0, 1, 4, 8 and 15 while making exactly **one** write attempt per run.
`permissionDenials` is not counting the blocked writes. `3bd8fcd8` has **0 denials** and was still
told *"No such tool available: Edit"* — a tool removed from the registry emits no `tool_decision`
event to count. So the field is unusable as a block signal for this channel, which is the second
independent reason on record after `permissionRequests == toolCalls`.

**P5's first half is not answerable as written, and no number of extra runs fixes that.** It says
*"10 of 10 confirmation runs are recorded as infrastructure"*, which presupposes that a treated
run is a blocked run. P3 refutes that presupposition. Replayed over batch 1's treated arm the
classifier reclassifies **5 of 10** — precisely the five that were blocked — and the other five
are runs that produced two to thirteen files, which the conjunction is built to leave alone. This
is reported as *unanswerable*, not as a failure of the fix and not as a pass.

## Failure analysis

**The decision rule, applied as registered.** Two rows are live on this data and the precedence
matters, so it is stated rather than chosen:

- **Row 2** — *1–4 of 10 treated runs classed infrastructure → CONFIRM WITH A NAMED LEAK* — fires
  on the single `F13` (`b2453820`).
- **Row 4** — *fewer than 8 of 10 treated runs are actually blocked (P3 fails) → **VOID for P1***
  — fires, because only 5 of 10 were blocked.

**Row 4 governs, and it governs because it is a precondition and row 2 is an outcome.** Row 4
says P1 *is unanswerable*; a row that reads an answer cannot outrank a row that says there is no
answer to read. **P1 is VOID.** It is reported as void, not as a null — the treatment did not
deliver on half the treated arm.

**The temptation this stop has to refuse in writing.** On arm H alone — the five runs where the
treatment did withhold the capability — P1's question has a clean answer: **5 of 5 carry `F03`, a
capability class; 0 of 5 carry an infrastructure class.** That is exactly the result P1 predicted,
and quoting it as the finding would be a rescue. §5 and this experiment's own MDE section forbid
it: *"Arm D and arm H are `n = 5` each: their results are true of those five runs and are reported
that way. Only P1, pooled over `n = 10` treated runs, is stated as a property of the instrument."*
So: **true of those five runs, and not a property of the instrument.** The pooled claim is void
and stays void.

**Row 5 does not fire, and it is worth saying why not.** Row 5 is *"the treated arm blocks and
passes anyway"*. `3bd8fcd8` passed the evaluator at exit 0 — but it did **not** block: it changed
three files. A run that was never blocked cannot satisfy a row about blocking while blocked. BE-003
is not shown to be satisfiable without writing; it is shown to be satisfiable without `Edit`.

**The design limit this batch exposed, recorded before anyone reads the split as settled.** The
two channels differ in more than their mechanism — they differ in **what the model is told**. The
hook returns *"Permission to modify files has not been granted for this session"*, a session-scoped
statement about the capability. The deny rule returns the runtime's own *"No such tool available …
Edit is disabled for this session"*, which names one tool and invites trying another. So *"the hook
blocked and the deny rule did not"* **cannot be attributed to mechanism rather than to wording by
this design.** The IV section asserted the treatment was identical in both channels; on the
evidence it is identical in intent and differs in message. Separating them needs a fourth arm — a
deny rule whose refusal carries the hook's wording — and nobody has run one.

## Sanity checks

- **One variable, checked against the records and not against a flag.** `runtime.model`
  `claude-haiku-4-5-20251001` on 20 of 20; `runtime.version` `2.1.268` on 20 of 20; benchmark
  `BE-003` and the evaluator at its registered sha, unmoved. The control's setup commit tracks
  **no** overlay file on 10 of 10; each treated arm tracks exactly its own registered files.
- **The prediction commit precedes the first run by construction**, and it was checked against
  the API rather than asserted: `02690e265e9071d6bace5d2e8f2587a1f2386694` at
  `2026-09-11T10:38:28Z`, with **0 runs on the experiment key** at that moment. First run
  `f50cc968` started `2026-09-11T19:53:04Z`.
- **The hand re-read was written down while zero sheets existed for the batch**, and checked to be
  so with `grep -rl` over `findings/` for every new run id: run `79c7d7c6`, category
  `test-quality`, rubric `396e1799eb2b`, **hand value 1** (the residual, not 2), justified at
  `ShipmentControllerTest.kt:100-102` and `:118-119` — two of anchor 2's three clauses hold and the
  third does not, since no test re-reads persisted state through a separate `get(...)`. Committed
  at `3854aad`.
- **The fix's fixture set executes and refuses**: `verify-permission-block-classifier.sh`, **29 of
  29**, re-run immediately before the replay.
- **The rubric has no registered role at this stop.** E-017 names no rubric, no scorer and no
  sheet: the registered outcome is the recorded failure class, read from the run record. Sheets
  taken at this stop are a reported population and enter no decision row.

## Rubric sheets — a reported population, entering no decision row

**The rubric has no registered role at this stop.** E-017 names no rubric, no scorer and no sheet;
the registered outcome is the recorded failure class. These eleven sheets exist because §4 step 7
takes them and §5 requires one hand-scored cell beside a sheet's value. They are reported and they
decide nothing.

Population: the **11 gate-passing runs** (Decision D). Registered scorer codex `gpt-5.6-sol`,
rubric `396e1799eb2b` on 11 of 11, re-shasummed unchanged. Values re-derived by me from the sheet
files, not taken from the subagent's table.

| category | control, `n = 10` | `3bd8fcd8` (arm D, `n = 1`) |
|---|---|---|
| `architecture-consistency` | **2** on 10 of 10 — zero variance | 2 |
| `maintainability` | median **0**, range 0–2 (seven 0s, three 2s) | 0 |
| `test-quality` | **1** on 9 of 9 scored — zero variance; one `null` (`5ece8350`) | 1 |
| `change-focus` | **1** on 10 of 10 — zero variance | **0** |

### Two things worth having, neither of them a verdict

**1. Three of four categories have zero variance across ten runs, which independently replicates
the finding that created BE-004.** Author decision 9 rests on E-006's *"50 of 100 rubric points at
zero variance across both arms"* on BE-003 at this model. Here, on a fresh `n = 10` control batch,
`architecture-consistency`, `test-quality` and `change-focus` are each **constant**, and only
`maintainability` moves at all. The instrument discriminates on one of four categories on this
task. That is decision 9's premise, re-measured, and it is the reason a second task exists.

**2. The one run that routed around the write block is the only one of eleven below the control's
`change-focus` floor — and the reason is the routing.** `3bd8fcd8` is the arm-D run that was told
*"No such tool available: Edit"*, did the whole task with 91 `Bash` calls, and passed the
evaluator. Its `change-focus` is **0** against a control that is **1 on 10 of 10**, and codex's
stated reason is *"Unnamed `create` and `getById` methods both changed message interpolation"* —
collateral edits outside the task's scope. It changed 3 files, the same as the control's median,
so this is not a file-count effect; it is what the shell did inside them.

**`n = 1`. This is true of that run and is not a property of anything** — not of the deny channel,
not of `Bash`-driven editing. It is recorded because it was predicted in the state file **before
the sheets were taken** — *"arm D runs changed 2–13 files including unrelated ones, so change-focus
will see them: that is a measurement, not a defect to tidy"* — and a prediction that came true
before its data is worth more than one found after. Whether writing through the shell costs
change-focus is a question for a design that registers it, at an `n` that could answer it.

### The §5 hand re-read, in the order §4 step 7 requires

Run `79c7d7c6`, `test-quality`. **Hand value committed at `3854aad`, when `grep -rl` over
`findings/` returned nothing for any run id in this batch: 1**, the residual, because *"no test
re-reads persisted state through a separate `get(...)`"*. The codex sheet, written 2026-09-14:
**1**, reason *"Repeat body and refusal envelope are asserted, but persisted state is never
re-read"*. Same value, same clause identified as the missing one, derived independently and in the
registered order.

## Decision

**The reproduction is CONFIRMED on one channel and VOID pooled, and the fix is KEPT ON DISK BUT
NOT PROMOTED.**

1. **P1: VOID** by decision-rule row 4, as registered. Reported as void.
2. **The hook channel is the reproduction.** Five runs, treatment proved in force per run, all
   five blocked, all five recorded `F03` — a capability failure — when the cause was the harness.
   That is obs#47's defect, reproduced under the pinned model, and it is true of those five runs.
3. **The deny channel is not a reproduction and is a finding in its own right.**
   `permissions.deny` on three tool names does not withhold the capability, costs **7.7×** the
   control, and leaves a `permissionDenials` count that bears no relation to the writes it
   refused.
4. **The classifier is KEPT on disk and NOT PROMOTED to a registered control.** Its registered
   KEEP condition — P5 in *both* halves — is **not met as written**, and restating it after seeing
   the data is the thing this project does not do. What is measured: over 33 runs it reclassified
   **5**, every one of which produced nothing under a denial, and **0** of the 21 that produced
   work, including all 11 that passed the evaluator; its fixture set is 29 of 29. That is an
   instrument worth having on disk and it is not a control until a stop registers it as one.
5. **Batch 2 is not run.** The reasoning is in `evidence/p05b/replay/README.md` and it is a
   decision, not an omission: P5's first half is unreachable while arm D is in the treated arm,
   E-017's own argument for preferring the replay covers the treated arm for the same reason (the
   step under test runs *after* the agent), and a batch of arm H alone would be `n = 5` of a
   channel whose result §5 already forbids stating as a property.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-14.*

## Follow-up

- **The fourth arm this design needs and did not have:** a deny rule whose refusal carries the
  hook's wording, to separate mechanism from message. Not run; it is a new arm and §7 reserves
  those for the author.
- **What would promote the classifier:** a stop that registers it, with a treated arm delivered by
  a channel that actually blocks, and a KEEP condition written against *blocked* runs rather than
  against *treated* ones.
- **obs#47 is not closed and this experiment says so on purpose.** Its own observed failure is an
  **abstention** — the agent asks a human and stops without calling the tool — so no
  `tool_decision` event exists, `permissionDenials` is 0, and the first conjunct is false. P6 held
  at 0 of 7 and that is the confirmation. The only vocabulary-free signal an abstention leaves is
  that the turn ended with the task unattempted, which is the **completion contract** (Lab 5B.4)
  and is not built here.

