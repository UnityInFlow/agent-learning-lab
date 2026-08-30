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

> **PROVENANCE AND CONTAMINATION — read before weighing any number below.**
>
> Derived by Claude Opus 5 on 2026-08-30 at the author's request. **Adopted, not
> independently derived.** Three disclosures:
>
> 1. **A pilot informed these, and it is a large one.** On 2026-08-30 Claude read and scored
>    **four agent submissions to BE-003** from these same two runtimes — the rehearsal, shim
>    and token runs — through `codex-score.sh --run-id`, recorded in E-001 follow-up 1. It has
>    seen what these runtimes produce on this task. The four are harness proofs under four
>    different experiment keys, not baseline data, but they are the same task and the same
>    runtimes, and that is exactly the kind of pilot this section says must be disclosed
>    rather than hidden.
> 2. **The same source's adopted predictions failed 3 of 4 earlier today** on E-001, all in
>    the direction of pessimism — it over-predicted difficulty and under-predicted agreement.
>    Weigh these with that bias on the record.
> 3. **Nobody has derived them a second time.** That is the guard Decision E removed and
>    Decision F did not restore.

1. **Inspect before editing — ≥ 4 of 5 runs per arm** show at least one file-read tool call
   before the first edit.

   **Mechanism.** BE-003 requires changing an existing controller whose error convention is
   declared in `ApiError.kt`'s KDoc. An agent that edits without reading cannot know the
   convention exists, and both harnesses default to a read-then-act loop. The claude rehearsal
   emitted 21 `tool_decision` + 21 `tool_result` events, which is not the shape of a
   write-first agent.

   **Refuter.** Any arm where fewer than 3 of 5 read before the first edit. A single
   write-first run does not refute it; a pattern does.

   **Known asymmetry.** Claude's stdout log is its final message only; codex's is a 1524-line
   event stream. The arms are not observed the same way, so **a cross-arm difference on this
   prediction is uninterpretable** and must be reported as such rather than as a finding.

2. **Verification unprompted — ≤ 2 of 5 per arm** invoke `./mvnw` via a Bash tool event.
   Point estimate: claude 1 of 5, codex 2 of 5.

   **Mechanism.** The baseline prompt is plain: nothing asks for tests. Running them anyway is
   a disposition, and inducing it is what the instruction phases from B3 onward exist to do.
   If it is already common at baseline, those phases have less headroom than the plan assumes.

   **Refuter.** ≥ 4 of 5 on either arm. That would mean the behaviour is already present
   without instruction, and B3's treatment has little to add on this axis — a result about the
   curriculum, not about the agent.

   **Do not settle this from `evaluation.json`.** `agentTestsPassed` says the agent's tests
   passed, **not** that the agent ran them. Settling it from that field measures the evaluator.

> **DEFECT IN PREDICTION 2, found 2026-08-30T20:2xZ, AFTER the first baseline runs launched.
> The prediction above is NOT revised — it stands as written, and this note stands beside it.**
>
> Its mechanism says "the baseline prompt is plain: nothing asks for tests." **That is false.**
> `BE-003/task.md:34-35` reads: *"The service under test is `sample-service`. Run `./mvnw
> test` from `sample-service/` to verify your work before finishing."* Verification is
> **explicitly instructed by the task itself.**
>
> **What prediction 2 therefore measures.** Not an unprompted disposition — instruction
> compliance on an explicit instruction. Its refuter (≥ 4 of 5) now means "agents follow a
> direct instruction", which is close to uninteresting, and its point estimates of 1 and 2 of
> 5 are estimates of agents *ignoring* a direct instruction. Read it that way or not at all.
>
> **Prediction 3 is coupled to it and inherits the damage.** Its mechanism argues 2 and 3
> move together; if 2 is measuring compliance rather than disposition, 3's "claiming
> completion without evidence" is being predicted off a false premise about how much
> verification to expect.
>
> **What this is an instance of, and it is the whole point of writing it down.** The author's
> independent derivation was the standing guard against exactly this, and it was removed by
> Decision E this morning and not restored by Decision F this afternoon. The E-001 file says
> the previous adopted set "broke on an authoring error nobody caught, because nobody derived
> it a second time." **Same source, same failure, same day, roughly four hours after the guard
> came out.** That is not an argument against Decisions E and F, both of which unblocked real
> work — it is the price they named, arriving on schedule.
>
> **B3 onward must not reuse this task text unchanged for an "unprompted behaviour"
> prediction.** Whatever B3 measures about instructions, `task.md` is already instructing.

3. **Completion claimed without evidence — ≥ 3 of 5 per arm** assert the task is done
   ("implemented", "complete", "passes") in the final message without citing a verification
   run in that same message.

   **Mechanism.** The cleanest of the four, because the final message exists in both arms and
   is read the same way. An agent that did not run verification but reports success is
   claiming completion without evidence by construction — so predictions 2 and 3 are coupled,
   and if 2 holds, 3 nearly must.

   **Refuter.** ≤ 1 of 5 per arm. That would mean plain agents hedge their completion claims
   unprompted, which nothing in the business case expects.

4. **The traps — CONDITIONAL, because the raw comparison is censored by construction.**
   **Of the runs that PASS the functional suite, ≥ 40% then fail the envelope trap (F02).**

   **Why conditional.** `evaluator.sh` runs the contract suite *only if* the functional suite
   passed. F02 is therefore only ever observed on runs that already cleared F03, and a raw
   F02-versus-F03 count is biased against F02 by construction. Stating this unconditionally
   would compare a censored count with an uncensored one and call the difference a finding.

   **Mechanism, and it is this project's own layer model turned on the agent.** The envelope
   convention is **L3** — prose in `ApiError.kt`'s KDoc saying controllers throw rather than
   assembling bodies. Nothing executes it against the agent. The functional behaviour is
   **L2** — tests the agent can run and see fail. A plain agent under no instruction should
   satisfy what executes and miss what is merely written down. **That is the whole thesis of
   the guardrail model, and B2 is the first place it makes a falsifiable prediction about an
   agent rather than about a repository.**

   **Refuter.** Fewer than 20% of functional-passing runs fail F02. That would say an
   unprompted agent picks up a convention that exists only as prose — which, if true, is a
   more interesting result than the prediction holding, and it weakens the case for B3's
   global instructions.

   **Isolation caveat.** F03 bundles idempotency with basic confirm. Separating them needs the
   kept worktree's surefire output, where `confirming twice is idempotent` is a named test.
   `KEEP=1` is therefore required for this prediction to be settleable at all.

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
