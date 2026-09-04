# B2 — Plain-prompt baseline

**Track A first:** [Phase 0A](../00a-agent-mechanics/) + [Phase 0B](../00b-observatory/)
**Version:** — (pre-v1.0)
**Spine position:** 4 of 28 · after [B1](../b01-experiment-contract/) · before [Phase 1](../01-instructions/)
**Status:** ✅ **GATE CLOSED 2026-09-03** — claude 9/9, codex 5/5, `maintainability` 1 of 5 on five runs scored by two harnesses; deliberate failure taken as a matched pair ([E-002](../../experiments/E-002-isolation-contamination.md), n=5+5, 10/10 passed) · **Evidence:** [`baseline-report`](../../evidence/b02/baseline-report-20260901T192000Z.txt) · [`worktree-decay`](../../evidence/b02/worktree-decay-20260903T134500Z.txt) · [`hand-reading`](../../evidence/b02/hand-reading-maintainability-4c891809.txt) · validation table under *Commit* · **Still held for the author:** the parity re-run's prediction, which the single-arm gate does not require

> Scaffold. **Build** and **Exit gate** moved from [`build/README.md`](../../build/README.md#b2).
> Everything else is yours to fill.

---

## Goal

B2 builds nothing. The capability that appears is **a number every later version is compared
against** — how a plain agent, under no instruction beyond the task, performs on BE-003.

What makes it trustworthy is not the number's size but four properties of how it was taken:
the model is pinned to an exact id rather than an alias, the environment is isolated so the
operator's machine is not part of the measurement, the sample is large enough that the spread
is visible (`n=9`, reported as median and range and never as a mean), and the verdict comes
from an evaluator that runs rather than from the agent's own account of itself.

**Everything downstream inherits whichever of those four is weakest.** This phase found that
out twice: once when the two arms turned out to be running under different policies, and once
when its own headline claim shrank from 0-of-3 to 1-of-5 on two more runs.

## Required reading

### Internal — the requirement

| source | what it fixes here |
|---|---|
| [`BUSINESS-REQUIREMENTS` §16.1 *Keep constant*](../../businesscase/BACKEND-AI-AGENT-BUSINESS-REQUIREMENTS.md) (line 994) | names the eight things held constant across a comparison — commit, task version, acceptance criteria, provider, model, environment, verification commands, rubric. B2 is where that list stops being advice: `runtime.model`, `repository.commitSha` and `evaluation.evaluatorVersion` are all *fields in the run record*, so seven of the eight are checkable after the fact rather than promised before it |
| §16.2 *Repeat runs* (line 1009) | three per configuration early, five to ten later. B2 ran nine on the claude arm and five on codex. The reason to prefer five over three is on this page: at `n=3` `maintainability` read 0-of-3 and at `n=5` it read 1-of-5 |
| P2 *One main variable per experiment* (line 172) | *"Do not add an agent, several skills, hooks, a new model, and a changed task in the same comparison."* B2 violated this without meaning to — the two arms differed in isolation policy as well as runtime — which is why no cross-arm claim survives |
| P3 *Same starting conditions* (line 176) | the same list from the other direction. **The environment is in it**, which is what makes an un-isolated run a different starting condition rather than a noisier one |

### External — the technique

**Isolation is settled as of 2026-08-10, and not the way the curriculum first assumed.**

- `--strict-mcp-config` and `--disable-slash-commands` do **not** stop hooks. 21 hooks and 2
  plugins loaded on all 20 runs of `EXP-BE002-CLAUDEMD-V2`.
- `--bare` does stop them and is still the wrong flag: it also disables `CLAUDE.md`
  discovery — which is B3's treatment — and does not authenticate on a subscription account
  at all.
- The right flag is `--setting-sources project`, which the runner exposes as
  `--isolate-user-settings`. Verified: **0 hook executions, `CLAUDE.md` still loads, auth
  works.**

**Registration is not execution, and this phase has already confused the two once.** The 22
user-level hooks are still *registered* inside an isolated run; none of them fire. A
registration count read as a contamination count is a number about the settings file, not
about the run.

**What isolation is worth was an argument until this phase measured it.** `EXP-BE002-NOHOOKS`
sized hooks at ~13 % of every run on BE-002, on both arms almost equally. That number was
carried forward on a different task for three weeks. [E-002](../../experiments/E-002-isolation-contamination.md)
re-measures it on BE-003 with a matched pair, and its result is in *Deliberate failure* below.

## Extract

Five things this phase is on the hook for, each already paid for once:

1. **A baseline is a measurement of a machine, not of a model.** Every unpinned thing on the
   operator's laptop — hooks, a global memory file, a terminal wrapper that prepends flags —
   is inside the number unless something removes it. The runner strips terminal CLI shims and
   reports it on a `shims` line, because the first rehearsal silently gained **26 hook
   executions** from a wrapper nobody had looked for.
2. **A flag is a promise; a field is a fact.** `--isolate-user-settings` was typed on all nine
   baseline runs, and those records carry `userSettingsIsolated: null` — *not measured*.
   Observatory V6 added the field so the claim became readable off the record instead of off
   the command line. This is the same L2-versus-L3 distinction the whole project runs on,
   arriving in the instrument rather than in the agent.
3. **Never an average alone.** Over the 17 BE-003 runs already recorded, median duration is
   101 s and the maximum is 1711 s; the mean is 262, a number no run produced.
   `baseline-report.py` computes no mean and a test asserts that against the parsed tree.
4. **A gate the agent cannot see is a different kind of gate.** BE-003's error-envelope
   convention lives only in `ApiError.kt`'s KDoc — L3 — while its functional behaviour is
   tests the agent can run and watch fail — L2. Prediction 4 turned that into a falsifiable
   claim about an agent and was **refuted 0-of-14**.
5. **The sample size has to assert itself.** `make baseline-runs` counts recorded runs before
   and after and exits 1 naming any shortfall, because a batch of five where three died used
   to print five banners and exit 0. A baseline reported at `n=5` that is really `n=2` is not
   noisy — it is a different measurement.

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

**Date:** 2026-08-30 → 2026-09-01 · **Runtimes:** claude, codex · **Model:**
`claude-haiku-4-5-20251001` (exact id, not the `haiku` alias) · **Benchmark:** BE-003 at
`8aadc75` · **Evaluator:** `1.0.0` · **Rubric:** `396e1799eb2b`

**Evidence:** [`evidence/b02/baseline-report-20260901T192000Z.txt`](../../evidence/b02/baseline-report-20260901T192000Z.txt)
· [`evidence/b02/dry-run-attachment-set-0a222393.txt`](../../evidence/b02/dry-run-attachment-set-0a222393.txt)

### What the runs produced

`n=9` claude, `n=5` codex, **14 of 14 passed the evaluator.** Median and range, never a mean —
`baseline-report.py` computes no mean and a test asserts that against the parsed tree.

| outcome | claude n=9 median | range | codex n=5 median | range |
|---|---|---|---|---|
| duration (s) | 83 | 70 – 3790 | 121 | 97 – 35342 |
| estimated cost | $0.1487 | $0.1085 – $0.1674 | — | **not measured on any run** |
| total tokens | 7,812 | 6,606 – 8,916 | 42,396 | 28,835 – 50,231 |
| tool calls | 17 | 14 – 20 | — | **not measured on any run** |
| model calls | 20 | 13 – 24 | — | **not measured on any run** |

**The `—` cells are the instrument telling the truth about itself.** They read `null`, not
`0`, because observatory V4 made those columns nullable after the rehearsal exposed the codex
arm recording `modelCalls: 0` while writing 64 lines of working code. Before V4 this table
would have shown the codex arm as the most efficient in the comparison.

**Duration is excluded from every claim on this page**, both arms. The spread is a factor of
54 on claude and 364 on codex, and what produced the tail is *not established* — the machine
was awake for run 9, so the sleep explanation offered earlier was wrong for that arm. Queue
contention is a candidate and not a finding. The narrower true statement is that duration is
contaminated by something the run record does not capture, which is the standing argument for
observatory#53.

### The rubric on those runs

Five claude runs scored, by **two harnesses**, on the registered rubric:

| category | weight | score | what moved it |
|---|---|---|---|
| architecture-consistency | 35 | **2** on 5 of 5 | both refusal paths throw existing `ApiException` subclasses |
| **maintainability** | 25 | **2 on 1 of 5**, 0 on the other four | `aa72e2c2` used an exhaustive `when`; the rest used `if` chains |
| test-quality | 25 | **1** on 5 of 5 | repeat body and refusal envelope asserted, persisted state never re-read |
| change-focus | 15 | **1** on 5 of 5 | something outside `confirm` moved on every run |

**Zero null cells across twenty, on ten sheets.** That answers E-001's follow-up: these are
agent submissions rather than the five fixtures the anchors were written against, so the null
rate holding at 0 says the rubric measures the rubric and not the fixture set it was authored
beside.

### Where prediction and reality diverged

Three of four adopted predictions were refuted, and the fourth is the one that matters:

**Prediction 4 was refuted 0-of-14.** It said that of the runs passing the functional suite,
≥ 40 % would then fail the envelope trap — the guardrail model's own thesis, turned into a
falsifiable claim about an agent: *a plain agent should satisfy what executes (L2 tests) and
miss what is merely written down (L3 KDoc prose)*. **Fourteen of fourteen picked up the
convention that exists only as prose.** Its own refuter says this outcome "weakens the case
for B3's global instructions", and that is the finding B3 inherits rather than a footnote.

**One prediction was defective when written, and it stands unrevised.** Prediction 2's
mechanism claimed "the baseline prompt is plain: nothing asks for tests" — `task.md:34-35`
explicitly instructs `./mvnw test`. It measures instruction compliance, not disposition. The
defect was found *after* the runs launched and is recorded beside the prediction rather than
corrected inside it.

### Was this the agent, or the harness?

- [x] **I checked what else changed between runs** — and the answer voided a whole class of
      claim. The two arms ran under different isolation policies, so no cross-arm claim
      survives this batch. That is a harness fact, not an agent fact.
- [x] **I verified the independent variable actually reached the agent** — for the rubric
      half, via the dry-run attachment set: 3 files under test and 3 baseline, not 25. For the
      isolation half, **only via the flag that was typed**; the records carry
      `userSettingsIsolated: null`. That gap is what [E-002](../../experiments/E-002-isolation-contamination.md)
      exists to close.
- [x] **If the result flatters my hypothesis, I have tried to disprove it** — the n=3 headline
      *"the plain agent does not close the door behind itself"* did not survive two more runs.
      It is left standing on this page rather than edited, because a claim that shrank when the
      sample grew is the record worth keeping.

## Deliberate failure

**Experiment:** [`E-002 — the size of the contamination B2's isolation removes`](../../experiments/E-002-isolation-contamination.md)
· prediction committed `0e0c6f9`, before the first run

**The deliberate failure is not one un-isolated run.** It is a matched pair — five isolated,
five open, interleaved, one harness version, one benchmark tree. The reason is that the
comparison originally specified, one open run against the nine on record, cannot be validated:
those nine carry `userSettingsIsolated: null`, which means *not measured*, so "they were
isolated" rests on the flag that was typed. `Decided by Opus 5 (claude-opus-5), autonomous,
2026-09-03`

### The independent variable, proved rather than trusted

| arm | hooks registered | **hooks executed** | plugins |
|---|---|---|---|
| isolated, n=5 | 23 on all five | **0 on all five** | 0 |
| open, n=5 | 24 on all five | **27, 29, 31, 33, 48** | **2 on all five** |

Registration near-identical, execution disjoint. The counter was validated before use against
a number it was never fitted to: `RUNBOOK.md` records a terminal shim adding *"26 hook
executions"* to the first rehearsal, and the counter returns exactly 26 on that run.

### What the contamination costs

| outcome | isolated n=5 | open n=5 | Δ median |
|---|---|---|---|
| duration (ms) | 90,000 · 64k–112k | 105,000 · 70k–121k | **+16.7 %** |
| **`inputTokens`** | **1,416** · 1,392–1,424 | **170** · 106–250 | **−88.0 %** |
| `cacheCreationTokens` | 26,119 | 30,573 | **+17.1 %** |
| `estimatedCost` | $0.1541 | $0.1754 | **+13.8 %** |
| `toolCalls` | 18 · 15–22 | 18 · 17–28 | **0** |
| files changed | 3 on all five | 3 on all five | **0** |
| evaluator passed | **5/5** | **5/5** | 0 |

**Three of the four predictions were refuted as written — but only one of the three is resolvable at this `n`, and the adversarial review is what established that.** Duration (+16.7 % against a registered ±20 % MDE) and tool calls (Δ 0 against ±2) both fall **inside** the detection limit this experiment registered for itself, so the honest word for them is *not detectable at n=5*, not *refuted*. The correction is in [E-002 → *Adversarial review*](../../experiments/E-002-isolation-contamination.md) and the predictions are left standing as written. **The one that is resolvable is `inputTokens`**, and it is the informative one.

The prediction said the cached prefix would grow and `inputTokens` would hold. The prefix grew —
and `inputTokens` **fell by an order of magnitude**, 1,392–1,424 against 106–250, two bands
that never touch. The contamination does not only add tokens; it **moves them between
buckets**. With hook output prepended, the ~1,400-token task prompt lands inside the cached
prefix, so what is counted as uncached input is only the remainder.

**Anyone comparing `inputTokens` across isolation regimes would read the contaminated arm as
88 % cheaper on that axis. It is 14 % more expensive.** Nothing in the run record says the
column is uncomparable. That is the observatory's own warning — *"a metric that changes
definition silently makes two experiments incomparable while both still look valid"* — arriving
without anyone having changed a definition.

**The duration tail did not reproduce.** Worst ratio 1.75×, against 54× on 2026-08-30. The
runs were interleaved rather than batched and the machine did not sleep. That does not identify
the old cause; it removes duration from what this experiment cannot see.

### The verdict the registered rule produces

**INCONCLUSIVE, leaning REJECT-as-stated** — every threshold this experiment set in advance was
set too high, and the outcomes that would make isolation a *validity* control did not move:
same verdict 10/10, same three files 10/10, same tool-call median.

**So on BE-003, at n=5 per arm, on the outcomes measured, `ISOLATE_USER_SETTINGS=1` is a cost
control** — true of these runs, not stated as a property. **The flag stays mandatory**, because
quality was measured on one run of ten: contamination could change *what* the agent writes
without touching pass/fail, file count or tool count. The runbook's argument is corrected
rather than removed — it is not that you would measure your hooks instead of the baseline; you
would measure the same baseline, pay 14 % more for it, and record an `inputTokens` column
nobody may compare.

## Exit gate

**From the build track:** ≥3 run folders with diffs, verification results and completed rubrics ·
a baseline report with **median and range**, never an average alone.

| gate clause | met | evidence |
|---|---|---|
| ≥3 run folders with diffs and verification results | **yes**, 9 + 5 | `EXP-B2-BASELINE-CLAUDE` n=9, `EXP-B2-BASELINE-CODEX` n=5, 14/14 evaluator-passed |
| completed rubrics | **yes**, 5 runs × 4 categories × 2 harnesses | `findings/codex/score-observatory-run-*.yaml`, `findings/opencode/score-observatory-run-*.yaml`; 20 cells, **0 null** |
| baseline report with median and range, never an average alone | **yes** | [`evidence/b02/baseline-report-20260901T192000Z.txt`](../../evidence/b02/baseline-report-20260901T192000Z.txt) — `baseline-report.py` computes no mean and a test asserts that |
| deliberate failure, prediction first | **yes** | [`E-002`](../../experiments/E-002-isolation-contamination.md), predictions committed `59ac936` 13:06:30Z, first run 13:07:19Z |

**Plus, for this to count as a learned phase — what B2 taught that 0A could not.**

0A teaches the layer model as a claim about repositories: hard controls versus words a human
reads. **B2 is where that claim was pointed at an agent and lost.**

1. **Prediction 4 said a plain agent would satisfy what executes (L2 tests) and miss what is
   merely written down (L3 KDoc prose). It was refuted 0-of-14.** Every run picked up the
   error-envelope convention that exists only as prose in `ApiError.kt`. An L3 instruction
   carried more than its layer predicts — the same shape E-001 found when Decision A's "no
   test file → null" held six times out of six with nothing executing it. **The layer model
   predicts what a control *guarantees*, not what a model will *do*.** B3 inherits that: its
   whole treatment is L3, and B2 says L3 is not inert.
2. **The instrument is inside the measurement, and it fails silently in both directions.**
   This phase found the codex arm recording `modelCalls: 0` while writing working code; found
   the two arms running under different policies after the batch; found `userSettingsIsolated`
   being validated on the way out and dropped on the way in; and found the kept worktrees
   hollowing out while `ls -d` still reported them present. Not one of those crashed. 0A
   cannot teach this because it has no instrument to be wrong.
3. **A number's `n` is part of the number.** `maintainability` read 0-of-3 and then 1-of-5 on
   the same rule. The claim is left standing in this file rather than edited.
4. **Isolation is now a measured quantity rather than an argument** — and the measurement
   partly disagreed with the argument.

## Commit

**Rubric** `396e1799eb2b` · **evaluator** `1.0.0` · **benchmark** `8aadc75` for the baseline
batch, `0448643` for E-002, and `git diff 8aadc75..0448643 -- tasks/ sample-service/` is
**empty** — the measured artifact is byte-identical, only reviewer and CI scaffolding moved ·
**model** `claude-haiku-4-5-20251001` on every run of both.

**Harness version is NOT constant across the two batches** — `2.1.251` for the baseline,
`2.1.259` for E-002. That is why E-002 is an internal matched pair and makes no comparison to
the nine.

**Held for the author, and the only TODO left in this file:** the parity re-run's prediction.
B2's registered gate is single-arm and does not need it. Cross-arm claims stay blocked as a
design fact — codex has no tool-allowlist mechanism and claude reads files through native tools
that need no shell, so parity by flag is unreachable and the surface is recorded rather than
equalized.

## Validation — every gate clause, its evidence, and the layer of the proof

| Gate clause (verbatim) | Evidence (path / id) | Layer of the **proof** | How a stranger re-derives it |
|---|---|---|---|
| "≥3 run folders with diffs, verification results" | `GET /api/runs` → `EXP-B2-BASELINE-CLAUDE` (9), `-CODEX` (5); each `evaluation.exitCode 0` | **L2** — the evaluator executes and records its own verdict | `curl $API/api/runs`, filter `experimentKey`, read `evaluation.exitCode` |
| "and completed rubrics" | `findings/codex/score-observatory-run-{0a222393,5bd24356,8322e71b,aa72e2c2,72fdc94f}-*.yaml` + the five opencode sheets | **L2** — admission runs: `check-run-gate.sh` refuses a run with no recorded pass | `./tools/check-run-gate.sh <run.json>` on each; re-run 2026-09-03, **5 of 5 exit 0** |
| "a baseline report with median and range, never an average alone" | `evidence/b02/baseline-report-20260901T192000Z.txt` | **L2** — a test asserts no mean exists in the parsed tree | `make baseline-report EXPERIMENT=EXP-B2-BASELINE-CLAUDE`, then grep the tree for a mean |
| deliberate failure, prediction committed before the run | `59ac936` @ 13:06:30Z vs `4c891809.startedAt` 13:07:19Z | **L3** — *corrected 2026-09-04, see amendment below.* Both timestamps are machine-written, but **a human compares them.** Apply the rule in order: can a run that started before its prediction commit still be written down? Yes. Does something execute and reject it? No. Machine-written evidence is not an executing check | `git log --date=iso-strict-local` and `GET /api/runs/4c891809.../startedAt`, then compare them yourself |
| the deliberate failure's independent variable reached one arm and not the other | `claude_code.hook_execution_start` in `agent-observatory/infra/telemetry-out/events.jsonl`: **0×5 isolated, 27–48×5 open**, with `hook_registered` > 0 on all ten | **L3** — *corrected 2026-09-04, see amendment below.* The runtime emits the events, but **a human counts them** and nothing rejects a run whose counts came out wrong. The counter still reproduces `RUNBOOK.md`'s independent figure of 26 on the rehearsal run | filter the JSONL on `observatory.run.id`, count the two bodies yourself |
| one scored cell re-derived by hand | `evidence/b02/hand-reading-maintainability-4c891809.txt` — hand **2**, sheet **2** (`findings/codex/score-observatory-run-4c891809-*.yaml`) | **L1 for the reading itself** (the construct either is a no-`else` `when` in expression position or is not; Kotlin decides), **L3 for the agreement** — two readers concurring is not a control | open the controller in the kept worktree, apply anchor 2's three clauses |
| "what did you learn that 0A did not teach" | this file, *Exit gate* | **L3** — prose a human reads. It is not a control and is not claimed as one | read it |

> **AMENDMENT 2026-09-04 — the independence check below names two of the three paths the runner
> actually hands the agent.** Sources: `findings/track-b-validation-2026-09-04-8.md` correction
> 4.1 and `-9.md` correction 4.A. The benchmark sha moved `8aadc75` → `0448643` between the B2
> baseline arm and E-002, and both this table and B3's justify the move as *"byte-identical on
> `tasks/` and `sample-service/`"*, which is true. But `run-agent.sh:211` reads
> `WORKTREE_KEEP=(sample-service .gitignore)` — **`.gitignore` is archived into every worktree
> too**, and it is *not* byte-identical: 16 lines change, `.claude/` → `.claude/*` plus
> `!.claude/hooks/` and `!.claude/settings.json`. That is the file the evaluator's scope guard
> reads through `git ls-files --others --exclude-standard`, and the one author decision 2 refused
> to touch for exactly this reason.
>
> **Closed by measurement rather than by argument, and re-derived here on all 44 runs rather than
> on a sample:** every stop 4–6 worktree is still on disk (44 of 44 — 9 B2 baseline, 10 E-002,
> 25 B3), and **none contains any `.claude` path and none has a single untracked file**
> (`git ls-files --others --exclude-standard` returns empty on all 44). The changed lines govern
> `.claude/` re-inclusion and untracked-file reporting; with neither present on any run, they
> **could not have changed the guard's output** anywhere in stops 4–6. The sha move is therefore
> immaterial *on these runs* — stated as a measurement over `n = 44`, not as a property of the
> two shas.
>
> The check as written was narrower than what it reported, which is this project's own named
> failure mode. It is corrected by naming the third path, not by re-running anything.
> `Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

**Independence check — what else changed between the arms of E-002?** Confirmed from the run
records, not from flags: `runtime.model` identical on all ten; `runtime.version` `2.1.259` on
all ten; `repository.commitSha` `0448643` on all ten; `evaluation.evaluatorVersion` `1.0.0` on
all ten; `customization.*Hash` **null on all ten** (no treatment installed in either arm — this
is B2, nothing is customized). The one thing that differs is hook execution, and it differs
27–48 against 0.

### Amendment — 2026-09-04, from the §9 validator

Source: [`findings/track-b-validation-2026-09-04.md`](../../findings/track-b-validation-2026-09-04.md).
Verdict on this stop: **CONFIRMED WITH CORRECTIONS.** Every gate clause mapped to evidence that
exists and opens; the prediction commit precedes the first run by 49 s read from git and the
API; the re-derived cell matched; no registered variable moved without disclosure. Four
corrections, applied here without rewriting any prediction, result, sheet or run folder:

**(a) Two proof rows were labelled L2 and are L3.** Corrected in the table above. The rows were
*"prediction committed before the run"* and *"the independent variable reached one arm and not
the other"*, justified by the evidence being machine-written. **That is not the test.** The rule
asks whether something *executes and rejects the bad value*. Nothing does: a human compares two
timestamps, and a human counts two event bodies. **Machine-written evidence is not an executing
check** — and this is the same error Phase 2's table later caught on itself. Two of this table's
strongest-looking rows were the weakest kind of proof, and the validator was right to open with
them.

**(b) `lab#49` does not exist.** Stops 4, 5 and 6 shipped in **lab#53**, merged
2026-09-03T19:07:36Z as `27d67e5`. Corrected in `findings/track-b-2026-09-03.md`. The wrong
number was in the track report, not in this workbook.

**(c) The prediction commits are unreachable from `main`, and this is now a track-wide hazard.**
~~`59ac936` and `0e0c6f9` exist in this clone only.~~ **This half of (c) is FALSE and is corrected
below — see the 2026-09-04 amendment following this block.** On `main`,
`git log -- experiments/E-002-isolation-contamination.md` shows one commit — the squash
`27d67e5` at 19:07Z, **six hours after the runs it was supposed to precede.** So a stranger
cloning this repository **cannot perform the prediction-precedes-run check at all**, for any
stop in this track. The check is L3 by (a), and now it is L3 *and* unreproducible off this
laptop. **Raised to the author** rather than fixed here: the fix is a repo-convention change —
merge commits for stop branches instead of squashes, or a pre-push check refusing a workbook
that cites a sha `main` cannot reach — and §7 reserves convention changes for the author.

### Amendment — 2026-09-04, correcting (c) above

Sources: [`findings/track-b-validation-2026-09-04-6.md`](../../findings/track-b-validation-2026-09-04-6.md)
correction 4.1 and [`-9.md`](../../findings/track-b-validation-2026-09-04-9.md) correction 4.B,
two independent passes on different models reaching the same finding.

**(c) said the prediction commits "exist in this clone only" and that a stranger "cannot perform
the prediction-precedes-run check at all". Both halves are false.** Every stop branch has indeed
been deleted from the remote — `git ls-remote --heads origin` returns exactly `main` and the
current stop-9 branch — but **`refs/pull/*/head` survives deletion**, and every prediction commit
in this track is reachable from one.

**Re-derived here by fetching from the remote, not by reading either validator's table:**

| commit | PR ref it is reachable from | timestamp |
|---|---|---|
| `85973dc` — B2 baseline predictions | `refs/pull/43/head` | 2026-08-30T20:12:42Z |
| `59ac936`, `0e0c6f9` — E-002 | `refs/pull/53/head` | 13:06:30Z, 13:06:46Z |
| `2015555 97e2ed5 e963460 eb02928 5d10e31 d6a13f2 225db94 d55150a 29561a2` — B3 / E-003 | `refs/pull/53/head` | 16:59:55Z → 18:13:41Z |
| `5d14182`, `5a14711` — E-004 registration | `refs/pull/56/head` | 07:03:58Z, 08:14:48Z |

All fourteen checked with `git merge-base --is-ancestor` against the fetched refs. **The command
a stranger runs is `git fetch origin refs/pull/53/head`** (and `43`, `56`), after which
`git log --format=%cI -1 <sha>` answers, and `git cat-file -t 59ac936` returns `commit` — both
executed here against a freshly fetched ref.

**What this changes.** The ordering rows stay **L3** — correction (a) is untouched, because git
writes both timestamps and a human compares them, and nothing executes to reject a run that
started before its prediction. What changes is *reproducibility*: the check is re-derivable by
anyone with the remote, and this workbook told them it was impossible. A guarantee documented as
unverifiable is worth less than one that is merely unenforced, and it was the former only in the
telling. The squash-orphan hazard is real and narrower than (c) stated: **unreachable from
`main`, retrievable from the PR ref.**

`Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

### Amendment — 2026-09-04, from pass 6 correction 4.2 (missing row)

The §5 table above records the *deliberate-failure* run's prediction ordering and omits the
**baseline batch's own**. Filled: prediction `85973dc` at **2026-08-30T20:12:42Z** against
`5bd24356.startedAt` **20:13:57Z** — 75 s. **L3**, by the same rule that demoted the other two
ordering rows. The omission strengthened nothing and hid nothing; it was simply absent.

`Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

**(d) The five B2 sheets can no longer be rebuilt.** Confirmed independently: the five scored
B2 worktrees hold **1 `.kt` file each** where the 36 E-002 and B3 worktrees hold 17. The
closure's *"and completed rubrics"* clause therefore rests on sheets whose inputs are gone.
This was disclosed before the validator ran, and a fresh run was substituted for the hand
re-derivation. **Not fixable, and recorded rather than quietly carried.**

**Two rows a validator should attack first.**

- **The `userSettingsIsolated` row does not exist in this table**, because the field cannot be
  read on this instrument. It is replaced by the telemetry row above. See E-002's *AMENDED*
  block for why that is a stronger proof and not a weaker one.
- **The "completed rubrics" row is evidence that can no longer be re-derived.** The five sheets
  are on disk and were produced while the worktrees were intact. The worktrees are now hollow —
  `evidence/b02/worktree-decay-20260903T134500Z.txt` — so a stranger can open the sheets but
  cannot rebuild them. **That is a real weakness in this closure and it is stated rather than
  hidden.** The hand re-derivation was therefore taken on a fresh E-002 run instead.


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

**AMENDED 2026-09-01, eighth session — the mechanism above is wrong for the claude arm, and
the conclusion is narrower than it was stated.** The run record's own timestamps:

```
 #  runId      arm      started    finished     durS
 1  5bd24356   claude   20:13:57   20:15:16       79
 2  0a222393   claude   20:15:46   20:16:56       70
 3  8322e71b   claude   20:16:27   20:17:50       83
 4  aa72e2c2   claude   20:17:25   20:18:45       80
 5  72fdc94f   claude   20:18:19   20:19:37       78
 6  656da203   claude   20:19:13   20:21:42      149
 7  491ee5e1   claude   20:20:05   20:26:44      399
 8  d72a1ec9   claude   20:26:48   20:49:49     1381
 9  192f2211   claude   20:27:13   21:30:23     3790
10  77c7d1c3   codex    20:27:39   06:16:41    35342   <- the sleep
11  34a01f57   codex    06:17:11   06:19:06      115
```

**Only run 10 can have spanned the sleep.** Run 9 finished at 21:30 with the machine
demonstrably awake, and the claude arm's spread from 149s to 3790s happened inside a
seventy-minute window that evening. So the sleep explains one codex run and does not explain
the arm it was being used to void.

What did degrade runs 6–9 is **not established**. Start times are ~55s apart while runs take
~80s, so two runs are always in flight and the queue deepens — contention on one laptop is
the obvious candidate and it is **not proven**. Do not write it up as the cause.

**What this changes.** "Re-run required for duration" below was justified by a mechanism that
does not cover the claude arm. The narrower true statement is: *the duration tail on both arms
is contaminated by something the run record does not capture, and the record cannot presently
separate a contaminated run from a clean one.* Cost, token and call-count statistics are
untouched by any of this — they are not wall-clock measurements — which is why the baseline
report at `evidence/b02/baseline-report-20260901T192000Z.txt` is reported over the **full
pre-registered arm** rather than over a post-hoc subset. Selecting the five fast runs would
have been exactly the post-hoc selection this phase exists to avoid.

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

The dry-run output itself is committed at
[`evidence/b02/dry-run-attachment-set-0a222393.txt`](../../evidence/b02/dry-run-attachment-set-0a222393.txt)
— the exact prompt the scorer would have sent, unedited, so the count above can be recounted
rather than taken on trust. It reached the repository under the filename `1`, from a
redirect, and is renamed here rather than deleted: it is the evidence that §0.5 was
satisfied, and §0.5 is a gate item.

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

### The same three runs, scored by a second harness — 2026-09-01

`opencode-score.sh` gained the `--run-id` path this repo's own `CLAUDE.md` said made a
cross-harness check on B2 "not currently possible". **Decision C is untouched**: codex remains
the registered scorer and owns the numbers; opencode is the second reader B1 had and B2 did
not. Both paths admit a run by the same rule and attach the same set, so the sheets are
comparable by construction rather than by caveat.

All three scored runs, rubric `396e1799eb2b`, **zero nulls on any of the six sheets**:

| run | architecture | maintainability | test-quality | change-focus |
|---|---|---|---|---|
| `0a222393` | 2 / 2 | 0 / 0 | 1 / 1 | **1 / 2** |
| `5bd24356` | 2 / 2 | 0 / 0 | 1 / 1 | **1 / 2** |
| `8322e71b` | 2 / 2 | 0 / 0 | 1 / 1 | **1 / 2** |

*codex / opencode.* **9 of 12 exact — and the three disagreements are one category, one
direction, three times out of three.** That is not noise, and it is not a coin landing the
same way; it is the same mechanism firing on every run.

**What is certainly wrong is opencode's fact, not its judgement.** Its reason is a variant of
*"create/getById/list and imports identical to baseline, only confirm added"* on all three
runs. Something outside `confirm` had changed every time, and the diff says so:

| run | what actually moved outside `confirm` |
|---|---|
| `0a222393` | a five-line class KDoc **deleted** — in the very file opencode cited |
| `5bd24356` | `SHIPMENT_CANNOT_BE_CONFIRMED` added to `ApiError.kt` — a second attached file it never cited |
| `8322e71b` | `SHIPMENT_CANCELLED` added to `ApiError.kt` — likewise |

**Whether that should score 1 or 2 is a genuine rubric question, and it is not settled here.**
For `0a222393` the deletion is unrelated to the feature and codex's 1 is plainly right. For the
other two the new enum constant is *required* by the code the ticket asked for, so "outside
`confirm`" is a strict reading and a defensible 2 exists. **The rubric does not say which**, and
that is a real ambiguity to take to `benchmark/rubrics/backend-quality.yaml` — separately, and
not by editing the sha mid-experiment.

**The harness finding is the solid one, and it is a repeat.** `change-focus` anchor 0 says
*"cite the line in both trees."* On 2026-08-30 codex did and opencode named methods and cited
one tree. Here opencode cited a single file, in the target tree only, on all three runs —
`ShipmentController.kt:52-72`, `:57-78`, `:26-55` — while a pre-agent tree and, in two cases, a
second changed file sat attached and unread. **Nothing executes that instruction.** One
occurrence was a curiosity; four is a property of the harness, and an argument *for* Decision C
rather than against it.

**Do not read 9/12 as an agreement rate.** Three runs of one task, and the harnesses are not
fed the same way — codex receives one inlined prompt, opencode receives file attachments. What
this establishes is that the second path exists, admits the same population, and found
something checkable on its first use.


---

## The claude arm at n=5 — and the headline finding is now 1 of 5, not 0 of 3

**2026-09-01, eighth session.** Runs 4 and 5 by start time (`aa72e2c2`, `72fdc94f`) were the
two scored-population members that had never been scored. Selection rule unchanged and
pre-registered: *by start time*, the same rule that picked runs 1–3. Both harnesses, rubric
`396e1799eb2b`, zero nulls on four new sheets, no opencode stall.

| # | run | architecture | maintainability | test-quality | change-focus |
|---|---|---|---|---|---|
| 1 | `5bd24356` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / **2** |
| 2 | `0a222393` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / **2** |
| 3 | `8322e71b` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / **2** |
| 4 | `aa72e2c2` | 2 / 2 | **2 / 2** | 1 / 1 | 1 / 1 |
| 5 | `72fdc94f` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / 1 |

*codex / opencode.* **18 of 20 exact.**

### The correction, stated plainly

**`maintainability` is 1 of 5 on the claude arm, not 0 of 3.** Everything written above this
section on the strength of "0 of 3" — including *"the plain agent does not close the door
behind itself"* — was true of the three runs it was computed from and is **too strong at
n=5**. It is left standing above rather than edited, because a claim that shrank when the
sample grew is the record worth keeping.

**Both columns of the decision procedure agree, so this is not a rubric defect.** The diff was
read by hand from the kept worktrees, independently of the sheets:

- `aa72e2c2` — `return when (shipment.status)` in expression position, all three constants,
  **no `else`**. A new `ShipmentStatus` constant is a compile error. Anchor 2, **L1**.
- `72fdc94f` — two `if` guards then a bare `return repository.save(...)` fallback. Compiles
  and takes the fallback unannounced. Anchor 0, **L3**.

The rubric cell and the hand-read diff return the same value on both. The scorer being codex
did not distort this one.

### Two things this does to claims made earlier in this file

1. **opencode's `change-focus` disagreement is 3 of 5, not 3 of 3.** It agreed with codex on
   runs 4 and 5. *"The same mechanism firing on every run"* was written at n=3 and does not
   survive n=5. The harness finding underneath it — opencode citing one tree where anchor 0
   says "cite the line in both trees" — is untouched and is still the solid one.
2. **The prior behind the blank prediction below has moved.** It was written against
   *"4 of 5 codex runs used `when`, 3 of 3 scored claude runs used `if`"*. The claude half of
   that is now **4 of 5 used `if`, 1 of 5 used `when`** — measured, not estimated. Anyone
   writing that prediction should write it against this number, and should know it was
   produced after the prediction block was created and before the prediction was written.

---

## The parity re-run — HELD, waiting on one prediction

**Status: not started, and it must not start.** Everything the batch needs is built,
tested and pushed. The one thing missing is a prediction, and writing it after the runs is
the mistake that voided nine runs on 2026-08-30.

### What changed under the batch since the last one

`agent-observatory` PR #66, two commits, both measured rather than argued:

| | was | is |
|---|---|---|
| operator skills | every one of seven codex runs opened by reading ~240 lines of `~/.agents/skills/*/SKILL.md` | per-run `HOME`, `.m2` symlink only. `--sandbox workspace-write` was tested as the fix and **does not work** — it restricts writes, not reads |
| network plugins | codex installed `deep-research-work@0.1.14`, `openai-templates@0.1.1`, `plugin-management@0.1.0` into the "isolated" home on startup, one of them shipping `skills/deep-research/SKILL.md` | `--disable plugins`. `--disable remote_plugin`, the obviously-named flag, installs all three anyway |
| the record | `mcpHash`/`skillsHash`/`instructionsHash` all null, which reads as *uncustomized* | V6: `userSettingsIsolated`, `shimsStripped`, and a codex `surface` inventory **measured off the isolated directories after the run** |

**What is still NOT at parity, and it cannot be fixed with a flag.** This file's own
criterion asks for "codex gets a tool allowlist and a sandbox that is not
`danger-full-access`, or the claude arm's restrictions come off". Neither is available:
codex has no allowlist mechanism, and claude reads files through native tools that need no
shell at all. The two products have different tool *shapes*. So the surface is now recorded
rather than equalized, and **cross-arm claims stay blocked**. That costs less than it
sounds: B2's registered gate is single-arm — ≥3 run folders and a report with median and
range — and `baseline-report.py` says so in its own docstring.

**Both arms are being re-run, n=5 each.** Not only codex. Duration was void on both from
machine sleep, `n=9` on claude was operator error rather than design, and a batch split
across two versions of the runner is two batches.

### How the new prediction will be settled — written before the prediction, as always

The observation on record, from the scored runs and from a note that explicitly refused to
call itself a result: **4 of 5 codex runs used `when`, 3 of 3 scored claude runs used `if`.**

| decidable from | how |
|---|---|
| the rubric cell | `./tools/codex-score.sh benchmark/rubrics/backend-quality.yaml --run-id <id>`, `maintainability`. Anchor 2 is an exhaustive `when` in expression position — a new enum constant is a compile error, **L1**. Anchor 0 is an `if` chain — it compiles and takes the fallback unannounced, **L3**. The scorer cited the line every time on the three runs already scored |
| the diff, independently | in the files the agent changed, does the new code discriminating on `ShipmentStatus` use a `when` expression covering the constants with no `else`, or anything else? Readable by hand from the kept worktree, and it does not depend on the rubric |

**Two caveats that belong here rather than in the write-up.**

1. **The scorer is codex, and one arm's submissions are codex's own output** (Decision C).
   A self-scoring arm is not a neutral instrument. The second column above exists so the
   claim can be checked without the rubric at all; if the two columns disagree, the diff
   wins and the rubric has a defect to report.
2. **`KEEP=1` is required**, as it was for prediction 4 — neither column is readable
   without the kept worktree.

### The prediction — BLANK, and blocking

> **This is the author's to write.** Claude has read every B2 agent log and both scored
> grids, so anything it proposes here is contaminated in the way the provenance note above
> describes, and this set is not being adopted.

<!-- TODO, before a single run of the parity batch:

     5. MECHANISM — why would an arm reach for the L1 construct or not? State the cause,
        not the number. "Codex used `when` more often" is an observation; a prediction says
        what about the arm, the task, or the runtime produces it.

     PREDICTION  — of 5 runs per arm, how many score maintainability 2 (exhaustive `when`)?
     REFUTER     — the number at which you would call this refuted, per arm, stated now.

     Then: commit this file BEFORE launching, and check `git log -1 --format=%cI` against
     the first run's startedAt. -->

**Do not run `make baseline-runs` until the block above is filled and committed.**
