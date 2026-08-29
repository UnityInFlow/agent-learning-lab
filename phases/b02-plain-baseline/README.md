# B2 — Plain-prompt baseline

**Track A first:** [Phase 0A](../00a-agent-mechanics/) + [Phase 0B](../00b-observatory/)
**Version:** — (pre-v1.0)
**Spine position:** 4 of 28 · after [B1](../b01-experiment-contract/) · before [Phase 1](../01-instructions/)
**Status:** ⬜ not started

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b2).
> Everything else is yours to fill.

---

## Goal

<!-- TODO: this step builds nothing. The capability that appears is
     a number everything downstream is compared against. Say that in
     one sentence, and say what makes it trustworthy. -->

## Required reading

### Internal — the requirement

<!-- TODO: candidates:
     BUSINESS-REQUIREMENTS §16.1 keep constant
     BUSINESS-REQUIREMENTS §16.2 repeat runs
     BUSINESS-REQUIREMENTS P2    one main variable per experiment
     BUSINESS-REQUIREMENTS P3    same starting conditions -->

### External — the technique

<!-- TODO. Note: isolation is settled as of 2026-08-10, and not the way
     the curriculum first assumed.

     --strict-mcp-config + --disable-slash-commands do NOT stop hooks:
     21 hooks and 2 plugins loaded on all 20 runs of CLAUDEMD-V2.
     --bare does stop them, and is still the wrong flag — it also
     disables CLAUDE.md discovery, and does not authenticate on a
     subscription account at all.

     Use --setting-sources project (runner: --isolate-user-settings).
     Verified: 0 hook executions, CLAUDE.md still loads, auth works.
     EXP-BE002-NOHOOKS sized what it buys: hooks were ~13% of every run,
     sitting on both arms almost equally. -->

## Extract

<!-- TODO -->

## Build

**Build:** nothing. Measure.

No agent, no skill, no hook, no instructions. Task prompt only. Same provider, same **exact
model ID**, same commit, same verification.

**Three runs minimum, five preferred.** One run is a story.

**Run it isolated** — `--setting-sources project --strict-mcp-config` for Claude (the runner
exposes this as `--isolate-user-settings`), `--no-custom-instructions` for Copilot. Without
that you are measuring your ~21 local hooks, not the baseline.

**Record per run:** which files it inspected · did it understand the architecture · did it
verify its own work · what needed correction · which metrics were even available.

> Everything after this is measured against B2. If B2 is sloppy, nothing downstream means
> anything.

## Predict before you run

### Registered first: what was already observed

**A pilot was run before these predictions were written, and it is disclosed rather than
hidden.** A pilot may inform a prediction; a hidden one makes the prediction worthless. On
**2026-08-29**, two rehearsal runs — one claude, one codex, under `EXP-B2-REHEARSAL-*` so
they can never join a batch's `n` — were executed to prove the pipeline end to end. Both
passed the evaluator. What was seen, and by whom:

| observed | author | Claude |
|---|---|---|
| both arms passed, `exitCode 0` | yes | yes |
| files changed per arm (claude touched `ApiError.kt`, codex did not) | yes | yes |
| claude's counters: 24 model calls, 21 tool calls, 21 permission requests | yes | yes |
| codex reports no behaviour or efficiency telemetry at all | yes | yes |
| the claude run's final message text | no | yes |
| the codex run's full event log | no | yes |

**A reader should discount any prediction below in proportion to what that table gave
away.** The original fourth candidate — "which metrics will be absent" — is deleted rather
than answered: it is now a known fact, and the B2 telemetry gap was fixed in
`agent-observatory` `5ed158e` before this was written.

### How each prediction will be settled

Written **before** the predictions deliberately, so a prediction cannot be quietly shaped to
fit whatever turns out to be measurable. Verified against the harness 2026-08-29.

| # | subject | decidable from | caveat |
|---|---|---|---|
| 1 | did it inspect before editing | `infra/telemetry-out/events.jsonl`, filtered on `observatory.run.id` — the claude rehearsal emitted **21 `tool_decision` + 21 `tool_result`** events with tool names and ordering. For codex, the raw agent log at `$TMPDIR/observatory-agent-<run-id>.log` | **asymmetric.** Claude's stdout log is its final message only (28 lines); codex's is a 1524-line event stream. Two different sources, so the two arms are not observed the same way |
| 2 | did it run verification unprompted | same two sources — a `Bash` tool event invoking `./mvnw`. `evaluation.json` carries `agentTestsPassed`, which says the agent's tests passed, **not** that the agent ran them | same asymmetry |
| 3 | did it claim completion without evidence | the agent's final message, present in both arms' logs | the cleanest of the four |
| 4 | which of BE-003's two traps catches agents more | `evaluation.failureClass` — **F02** is the ApiError-envelope trap, **F03** is the functional suite (which contains idempotency) | **structurally censored — read the note below before writing this one** |

**The censoring on prediction 4, and it is not a detail.** `evaluator.sh` runs the contract
suite *only if the functional suite passed*:

```bash
if [[ $FUNCTIONAL_PASSED == true ]]; then
  ... BE003ContractTest ...
fi
```

The reasoning is sound for a gate — "if nothing refuses anything there is no error response
to judge the shape of" — but it means **the envelope trap is only ever observed on runs that
already cleared the functional suite.** A raw count of F02 versus F03 is biased against F02
by construction. So prediction 4 must either be stated **conditionally** (of the runs that
pass the functional suite, how many then fail the envelope) or state a different decision
procedure. `F03` also bundles idempotency with basic confirm; isolating it needs the kept
worktree's surefire output, where `confirming twice is idempotent` is a named test.

### The predictions

<!-- Four predictions, each with a MECHANISM — the causal story that makes it falsifiable —
     and each naming what result would REFUTE it. A number with no mechanism is a guess, and
     a prediction nothing can refute is not a prediction.

     1.
     2.
     3.
     4.
-->

## Lab B2.1 — establish the baseline

<!-- TODO: ≥3 runs, ideally 5. Same commit, same exact model ID.
     Report median and range. Never an average alone. -->

## Deliberate failure

<!-- TODO: run one deliberately un-isolated (hooks and plugins on) and
     compare. That number is the size of the contamination you are
     avoiding, and it is worth knowing rather than assuming. -->

## Exit gate

**From the build track:** ≥3 run folders with diffs, verification results and completed rubrics ·
a baseline report with **median and range**, never an average alone.

**Plus, for this to count as a learned phase:**

<!-- TODO: what did you learn about the plain agent that you did not
     know from Phase 0A? -->

## Commit

<!-- TODO -->
