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

## Results

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |

## Failure analysis

## Sanity checks

- [ ] prediction commit sha and timestamp: ______ · first run `startedAt`: ______
- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] If a fix motivated this run, did the original symptom actually disappear?

## Decision

## Follow-up
