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


---

## B2 baseline — RUN 2026-08-30T20:13Z – 2026-08-31T06:31Z

**Read the contamination finding first. Two of the four registered outcomes are unusable from
this batch, and the arms are not comparable to each other.**

### What was recorded

| | claude arm | codex arm |
|---|---|---|
| experiment key | `EXP-B2-BASELINE-CLAUDE` | `EXP-B2-BASELINE-CODEX` |
| model | `claude-haiku-4-5-20251001` | `gpt-5.6-sol` |
| **n** | **9** (asked for 5) | **5** |
| passed | **9 / 9** | **5 / 5** |
| failureClass | none | none |
| duration median | 83s | 121s |
| duration range | **70 – 3790s** | **97 – 35342s** |
| behaviour counters | present (13–24 model calls, 14–20 tool calls) | **null — no telemetry path** |
| tokens | null | 28 835 – 50 231 |

**n = 9 on the claude arm is an operator error, not a design choice.** A `nohup`ed batch was
torn down between tool calls and relaunched without accounting for what the first batch had
already recorded. The runbook says report the real `n`; it is 9.

### BLOCKING FINDING — the two arms are not the same experiment

`runner/run-agent.sh` gives the arms different worlds:

```
CLAUDE_ARGS=( --permission-mode acceptEdits
              --strict-mcp-config
              --disable-slash-commands
              --allowedTools "Bash(./mvnw:*)" "Bash(mvn:*)"
              [--setting-sources project] [--model …] )

CODEX_ARGS=(  --sandbox danger-full-access --color never [--model …] )
```

The claude agent may run **two** shell commands, `./mvnw` and `mvn`, gets no MCP servers and
no slash commands. The codex agent has **full filesystem access and an unrestricted shell**.

**This is not a theoretical asymmetry. It fired on the first codex run.** From the batch log,
run `77c7d1c3`:

```
codex
I'll trace the shipment feature through Memtrace first, including its existing API/error
conventions and any recorded design constraints.
exec /bin/zsh -lc "sed -n '1,240p' /Users/jirihermann/.agents/skills/memtrace-first/SKILL.md
                && sed -n '1,260p' /Users/jirihermann/.agents/skills/memtrace-preflight/SKILL.md"
```

The agent reached **outside the worktree, into the operator's home directory**, read two
global skill files, and announced it would follow them — in a run labelled *plain baseline*.
Those skills instruct a specific code-discovery methodology. **That is a treatment, and it was
inside the control.**

**`verify-codex-isolation.sh` is not wrong, and that is the lesson.** It proves
`$CODEX_HOME/AGENTS.md` does not **auto-load**. It cannot prove the agent will not go and
**read instructions itself**, and under `danger-full-access` nothing stops it. **A fourth
control in this project reporting success over a scope smaller than believed** — and the first
one found by reading an agent's own transcript rather than by testing the control.

The layer reading: `CODEX_HOME` isolation is **L1** for auto-loading (the file is not there)
and **nothing at all** for deliberate reads (the file is there, on the host, and the agent has
a shell).

### Duration is unusable from this batch

Ranges of 70–3790s and 97–35342s are not task variance. Runs were suspended across a machine
sleep — `77c7d1c3` started 2026-08-30 and finished 06:31 the next morning. **Do not compute a
duration statistic from this batch**, and do not read the medians above as a cross-arm
comparison; they are printed only to show how far apart the tails are.

### Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | inspect before editing, ≥ 4 of 5 per arm | **not settled** | needs per-event ordering. claude's counters give tool *counts* (14–20) not ordering; codex's counters are null. The observation asymmetry named in the prediction is worse than stated — one arm has no behaviour telemetry at all |
| 2 | verification unprompted, ≤ 2 of 5 per arm | **void** | its mechanism was false before the run — `task.md` instructs `./mvnw test`. See the defect note above the prediction |
| 3 | completion claimed without evidence, ≥ 3 of 5 | **not settled** | coupled to 2, and inherits its broken premise |
| 4 | of functional-passing runs, ≥ 40% fail the envelope (F02) | **REFUTED** | **0 of 14.** Every run passed every gate. Refuter was < 20%; actual is 0% |

**Prediction 4's refutation is the substantive result of B2, and it is the interesting
direction.** Its mechanism was this project's own guardrail model turned on an agent: the
envelope convention is L3 — prose in `ApiError.kt`'s KDoc — while the functional behaviour is
L2, tests the agent can run and watch fail. It predicted a plain agent would satisfy what
executes and miss what is merely written down.

**Fourteen out of fourteen plain agents, two runtimes, picked up the L3 convention with no
instruction at all.** Under the caveat that the codex arm was reading operator skills, the
claude arm was tightly sandboxed and did it too — 9 of 9.

That is a real finding about the layer model's reach: **L3 prose sitting in a KDoc adjacent to
the code an agent must edit is read, and followed, without being enforced.** It weakens the
case for B3's global instructions on this axis specifically — if the convention is already
picked up at baseline, an instruction telling the agent to follow it has nothing to add here.
**B3 must find an axis where the baseline actually fails, or it will measure nothing.**

### What must be re-run, and what need not

- **Re-run required for any cross-arm claim.** The arms must be brought to parity — either
  codex gets a tool allowlist and a sandbox that is not `danger-full-access`, or the claude
  arm's restrictions come off. Until then, arm differences are configuration differences.
- **Re-run required for duration.** Machine sleep, not task variance.
- **Not a re-run: the pass rate and prediction 4.** 14 of 14 passing every gate is robust to
  both defects. A *more* capable, less isolated agent passing is not surprising; the tightly
  sandboxed claude arm passing 9 of 9 is what carries the finding.

---

## Rubric sheets on baseline runs — 2026-09-01

**Three runs scored. Selection was by start time, not by result** — the three oldest claude
baseline runs, picked before any sheet existed, so nothing here is chosen for what it says.

    ./tools/codex-score.sh benchmark/rubrics/backend-quality.yaml --run-id <id>

Rubric `396e1799eb2b`, scorer `gpt-5.6-sol`, fresh ephemeral session per run,
`--ignore-user-config --ignore-rules --sandbox read-only`. All three sheets pass
`check-sheet-categories.sh`: 4 categories, exactly the rubric's.

| run | architecture 35 | maintainability 25 | test-quality 25 | change-focus 15 | total |
|---|---|---|---|---|---|
| `0a222393` | 2 | **0** | 1 | 1 | 55/100 |
| `5bd24356` | 2 | **0** | 1 | 1 | 55/100 |
| `8322e71b` | 2 | **0** | 1 | 1 | 55/100 |

**Zero null cells of twelve.**

### RUNBOOK §0.5 is satisfied, and it cost no run

The step this phase flagged as unavoidably costing a run — inspect the attachment set on a
real worktree — was answered by a surviving one. `LAB_SCORE_DRY_RUN` on run `0a222393`
reports **3 files under test, 3 baseline**. Not 25. The whole service is not attached,
`test-quality`'s null precondition can fire, and **Decision A is not silently disabled
between B1 and B2**. The three sheets confirm it from the other side: `test-quality` scored
1, not null, on all three — the attachments included the test file the agent wrote.

### Follow-up 1, on unseen work

E-001's follow-up 1 asks whether the rubric measures the rubric or the fixture set: score a
submission the anchors were **not** written against and watch the null rate. These are agent
submissions, not fixtures. **The null rate stayed at 0.** The rubric is doing work on unseen
code.

### What the maintainability column is actually measuring

This is the guardrail model pointed at an agent, and it is worth reading the anchor rather
than the number:

- **2** — one `when (shipment.status)` in EXPRESSION position, no `else`. Kotlin forces such
  a `when` to be exhaustive, so a new status constant is **a compile error at this site**.
  That is **L1**: the bad state cannot be written down.
- **0** — an `if` chain. A new status constant compiles and takes the fallback path
  unannounced. Nothing executes against it.

**All three runs wrote `if` chains, and the scorer cited the line in each:**
*"Status decisions use if chains"* (`:56`), *"…use separate if statements"* (`:62`),
*"…use separate if statements with a fallback return"* (`:65`).

**3 of 3 chose the construct that is not compiler-enforced**, on a task where the enforced
one is available, shorter, and idiomatic Kotlin.

### A cross-arm pattern that is NOT a finding, recorded so it can be tested

Reading the construct directly out of the diffs: **4 of 5 codex runs used
`when (shipment.status)`; 3 of 3 scored claude runs used `if`.**

**This must not be reported as an arm difference.** observatory#65: the arms ran under
different policies, and all seven codex logs open by reading the operator's
`memtrace-first` skill, which instructs the agent to check recorded conventions before
editing. Model and treatment are not separable here. What this is: **a specific, cheap
hypothesis for the parity re-run** — score both arms after parity and see whether the split
survives. It is more than #65 had to offer before, and it is worth one line in that issue.

## What was learned about the plain agent that 0A did not teach

**It satisfies what it reads and what executes against it. It does not reach for constructs
that make a future mistake impossible.**

Three instruments, two repositories, one shape:

| | measurement |
|---|---|
| **prediction 4**, this phase | followed an L3 prose convention that nothing enforces — **14 of 14**, including 9 of 9 on the tightly sandboxed arm |
| **the rubric**, this phase | did not choose the L1 construct that turns a future enum addition into a compile error — **0 of 3** |
| **WW-001**, `evidence.local/ww-001-plain-vs-instructed/` | did not extract the shared helper the codebase's own precedent called for — **0 of 6**, both arms, on an unrelated repo. `GN-018` in the books corpus, `severity: should` |

0A's lesson was that a word a human reads is not a control. **B2's is the same lesson from
the other side: an agent reads the words fine — better than predicted, three times over —
and that is exactly why the words are not the control.** What the plain agent does not do is
close the door behind itself. Prediction 4 was refuted because the reading half is easy; the
maintainability column is 0 because the defending half is not.

**What this hands B3.** An instruction telling an agent to follow a convention it already
follows measures nothing — WW-001 shows that at 3/3 versus 3/3 with a real `CLAUDE.md`
carrying the exact conventions in question. **B3's axis has to be somewhere the baseline
reliably falls short**, and two candidates are now on record with numbers behind them: the
L1-construct choice (0/3 here) and `GN-018` (0/6 there). Both are about defending code
rather than writing it, which is a narrower and more testable claim than "instructions help".

### Still open on this phase

- **The deliberate-failure run.** One run deliberately un-isolated, compared against the
  isolated baseline, to *measure* the contamination rather than assume it. Never done — and
  newly interesting, because #65 shows the codex arm was accidentally un-isolated and nobody
  can size the effect.
- **Prediction 1 on the claude arm.** Unsettled and probably unsettleable from what exists:
  that arm's log is a final message with no ordering, and a tool count is not a tool order.
