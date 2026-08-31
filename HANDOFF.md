# Handoff — 2026-08-30 (fifth session)

Read `CLAUDE.md` first; it carries the operational facts and is loaded automatically. This
file is the *state*: what is in flight, what is blocked, and on whom.

## Position

**Spine 4 of 28 — B2 HAS RUN. B1 CLOSED 2026-08-30.** No agent exists and none should until
stop 10.

**B2 produced data, and half of it is unusable. Read `phases/b02-plain-baseline/README.md`
from "B2 baseline — RUN" before quoting any number.** 14 runs, 14 passed. Prediction 4
refuted 0-of-14, and that refutation is the session's substantive finding. But the two arms
ran under different policies, so **no cross-arm claim survives**, and duration is void because
runs were suspended across a machine sleep.

**B1's exit-gate evidence is on record**: `925563c`. Two harnesses scored all five variants,
the decision rule returned KEEP on every clause, and the rubric is registered for B2 at
`396e1799eb2b`. Read *Which predictions held* and *Sanity checks* in
`experiments/E-001-rubric-null-rate.md` before quoting the result — the headline number is
20/20 and it is explicitly flagged as a number to disbelieve once more.

**What closed it was a design change, not the blocked work.** DECISION E, 2026-08-30: the
second scorer is a second HARNESS, not the author. The human blind sheet had blocked B1 for
four sessions at zero cells written. `E-001-blind-scores.yaml` is marked superseded and left
unfilled on purpose — a measurement designed and not taken is evidence. It cannot be revived
for these five variants: the machine sheets have been read.

**The cost is recorded, not glossed.** E-001 no longer answers whether a *person* can apply
this rubric, and the guard that an independently-derived human column provided — the one that
would have caught the authoring error the previous adopted set died on — is gone. Predictions
were adopted from Claude with provenance and the contamination disclosed, and **they failed
3 of 4.**

## Branch state

`lab21/the-ladder-had-gaps`, **28 commits**, ahead of `main`. `main` is at `0f58203`
(PR #18, merged 2026-08-27, five CI checks green). All five CI jobs pass locally on this
branch, shellcheck included.

## What is BLOCKED ON YOU, and cannot be delegated

**Superseded in part on 2026-08-30.** B1's two blockers — the four prediction blanks and the
17-cell blind sheet — are **closed**, the first by adoption with recorded provenance and the
second by Decision E replacing the human column with a second harness. Neither was completed
as originally designed. The text that stood here described work that is no longer on the
critical path; it is in git history at `84ab009` if you want to read what was given up.

**What remains blocked on you, and genuinely cannot be delegated:**

1. **B2's four predictions.** Untouched by Decision E. Committed before the first baseline
   run, with an earlier commit timestamp. Doing that backwards once voided nine runs.
2. **0A — 19 checkboxes**, ~5 hours of reading. Position 1 of 28, never started, and it
   blocks B2 independently of anything B1 did.
3. **RUNBOOK §0.5**, the one step that costs a run: rehearse one run per arm with `--keep`,
   then inspect the attachment set with `LAB_SCORE_DRY_RUN`. If it lists 25 files the whole
   service is attached, `test-quality`'s null precondition can never fire, and Decision A is
   silently disabled between B1 and B2.

**A standing hazard is now spent, and this is the honest way to say it:** Claude had read all
five BE-003 fixtures and was withholding anchor placements to protect the blind sheet. Under
Decision E that sheet will not be written, both machine grids have been read, and the
protection no longer has anything to protect. `E-001-blind-scores.yaml` stays on disk unfilled
as the record of that.

## After B1, the spine does not move

**B2 needs 0A, and 0A has never been done.** Position 1 of 28 — "depends on nothing, blocks
everything". Reading and extraction, no build, ~5 hours. Links re-verified 2026-08-28:
0 broken, 8 moved (four OpenAI Codex docs migrated to `learn.chatgpt.com` and sit in 0A's
Tier 1 list — `SOURCES.md` needs updating before anyone reads it).

Links re-verified again 2026-08-28 (third check): `ok=64 moved=8 blocked=2 unverified=0
broken=0` over the same 76 URLs, the same eight redirects, no drift in eighteen days.
`SOURCES.md` is updated and re-stamped. **Correcting this file's own earlier claim: the four
migrated Codex docs are NOT in 0A's Tier 1 list** — 0A cites the openai.com agent-loop
article, which did not move. The four live in `SOURCES.md` and `CURRICULUM.md` only, and
were already annotated. 0A needs no link work before it is read.

0A teaches hard controls versus words a human reads. This project paid for that lesson
**six times in twenty hours**: a schema note that constrained nothing, Decision B written as
built and unbuilt for two days, an exclusion blind to an uncited read, the gate-filter
assumption nothing enforced, a ranking inversion, and a header describing a control that by
then existed. Every one arrived as a bug rather than as reading.

## The rubric, and its critique loop

`benchmark/rubrics/backend-quality.yaml` — **sha `396e1799eb2b`**, four categories,
architecture 35 / maintainability 25 / test-quality 25 / change-focus 15.

Step 1 of E-001's procedure is to critique it *before* applying it. It has been rejected
**six times** and every round found something real. Rounds so far: gaps in the anchor ladder;
an anchor counting against an enum that is not attached; a ranking inversion; four textual
ambiguities; two undefined domain terms. The last full panel could not complete because both
opencode families stalled.

**Round 7 ran on 2026-08-28 and the gate returned ACCEPT** — the first accept in seven
rounds, both families completing, neither stalling. Findings in
`findings/opencode/review-backend-quality-20260828T085728Z.md`.

The gate disputed four of the six line-level findings, all on the same ground: anchor 1 is
an ILLUSTRATION of the residual (lines 67-70) and "1 otherwise" (lines 62-66) catches
everything that is neither 0 nor 2, so a finding that anchor 1's literal text fails to reach
some case is not a defect. That reasoning is sound.

**One finding survived, and both families found it.** `test-quality`'s null precondition
turns on "a test file that makes no assertion at all", and the rubric never says which
constructs are assertions. A submission asserting only `verify(exactly = 1) { save(any()) }`
scores 1 under a reader who counts mock verification and `null` under one who does not —
87.5 versus 100. That is a change of denominator, not a one-point disagreement, so the two
totals are not the same measurement.

**DECIDED 2026-08-28, third session: accept as-is.** The sheet is filled against
`396e1799eb2b`; the assertion gap is named, not fixed first. The argument, the cost, and what
it means for reading a `test-quality` disagreement on the two test-bearing rows are recorded
in `experiments/E-001-rubric-null-rate.md` under "Step 1 is closed". Short version: the
trigger is only reachable on `good-strong-tests` and `good-weak-tests`, a known-undecidable
anchor is what the null rate measures, and benchmarks#22's ordering constraint ("assertion"
defined before a NEW test fixture lands) is untouched by filling the sheet now. **Step 1 of
E-001's procedure is closed.**

**A defect in the harness, not the rubric:** the recurrence table counts families per
SECTION NAME. Both families found the assertion gap, under different headings, so the one
finding with 2/2 support shows up as two separate 1/2 rows. Every row in that table reads
1/2 and at least one of them understates its support.

**What the rubric could not solve, written into its own header:** `test-quality` holds 25 of
100 and is decidable on **two of five** variants, because three submitted no test file.
Either the fixture set grows tests or the weight is wrong. That is a question for the
benchmarks repo, not this one — **now open as UnityInFlow/agent-observatory-benchmarks#22**,
with both obvious fixes shown to be illegal there (adding tests to the three test-less
variants breaks the one-dimension rule; adding them to `known-good` re-breaks
`default-error-body` 13 → 11 and does not reach the variants anyway, since `apply_variant`
copies a quality variant alone). The issue also carries the ordering constraint: whichever
direction wins, "assertion" must be defined in the rubric BEFORE a new test fixture lands,
because a new fixture is what makes the round-7 finding reachable. The rubric header itself
does not link the issue — writing the number into it would move the sha.

## B2 is built and waiting on you — 2026-08-28, late

Everything B2 needs exists except the two things only you can do. See
[`phases/b02-plain-baseline/RUNBOOK.md`](phases/b02-plain-baseline/RUNBOOK.md) — it carries
the exact commands with the traps in the order they bite.

**DECISION D, adopted from Claude and labelled as adopted.** The scorer takes `--run-id` and
scores a B2 run: admission by the evaluator's recorded verdict rather than a fixture name,
attaching **the files the agent changed, in full, plus their pre-agent versions** — not the
whole worktree. The reason is not tidiness: `sample-service` already ships
`ShipmentControllerTest.kt`, so attaching all 25 files would put a test file among the
attachments on every run and `test-quality`'s null precondition could never fire. Decision A
would be silently disabled between B1 and B2. **CONFIRMED by the author on 2026-08-28, third session.** It was proposed by Claude and built
under the instruction "provide it all"; it was unratified for one session and is not any
more. `build/README.md#b2` now records it as closed with its provenance, and `CLAUDE.md`
says who proposed it.

**`agent-observatory` branch `b2/expose-keep-worktree` is PUSHED** (2026-08-28, third
session). `make run-benchmark` passed eight flags and not `--keep`, so the documented path
could not preserve the worktree the scorer reads. One commit, `f204c9f`, now on origin and
tracking. No PR opened.

**The panel rejected this session's own tooling, and it was right.**
`findings/opencode/review-check-run-gate-20260828T160312Z.md`: `check-sheet-categories.sh`,
the control built that morning to catch silent category loss, *lost categories* — it scanned
by indent rather than by block, so a category filed under any other key counted as present.
Fixed and registered as a fixture. deepseek returned "no finding" on that file; codex caught
it; the gate disputed deepseek. One model run twice would have shipped it.

**`tools/*.sh` is now in the push hook's scope**, which it was not when nine tools changed on
this branch. Contracts are reviewed before tools, at most `LAB_REVIEW_MAX_ARTIFACTS` (4) per
push, and every dropped file is named.

**The blind-sheet workbench is REBUILT and on disk** at `workbench.local/` — one file per
variant, gitignored via `*.local`, with a README carrying the one-line rebuild command. Each
file is the *exact* prompt `codex-score.sh` sends, produced by the scorer's own
`LAB_SCORE_DRY_RUN` path rather than reassembled by hand: same contract, same rubric text,
same attachment set, same order. No diff — the scorer does not get one, and the sheet's own
header warns against letting the one-dimension design tell you what to score. The attachment
counts confirm the sheet's arithmetic independently: inline-envelope, nested-ifs and
noisy-diff attach 2 files and nothing under `src/test/`, strong-tests and weak-tests attach 3.
20 cells, 3 structural nulls, 17 judgements. **Rebuild it if the rubric sha ever moves** — the
prompts inline the rubric verbatim but do not carry its sha.

**Standing hazard for any future session:** Claude has read all five BE-003 fixtures and
derived anchor placements for the two test-bearing variants while working benchmarks#22. It
did not write them down and must not. Anything it says about those cells contaminates 2 of
your 17.

## Fixed on 2026-08-28, second session

Five controls that reported success over a scope smaller than believed, all found by
re-verifying a green check by hand rather than by a failure:

| Control | Was |
|---|---|
| link checker UA | two live pages reported broken, exit 1 |
| link checker `PRIVATE` skip | two public URLs never fetched, counted as neither ok nor broken |
| CI links job | read 2 of the 33 files SOURCES.md claims to verify |
| scorer schema + classifier | a 3-of-4-category sheet validated and read as complete |
| `lab_dirty` / recurrence table | could not tell artifact-moved from unrelated-edit; the best-corroborated finding looked the loneliest |

The scorer one is the one to know about: **a missing cell is not a null cell.** `null` is a
measurement; an absence is not, and E-001's dependent variable is a ratio whose denominator
is the cell count. `codex-score.sh` now pins the schema per run to the rubric's own category
names and count, both scorers re-check the set on disk, `check-sheet-categories.sh` fails
closed, and CI runs 9 cases proving it still rejects. **Neither registered variable moved** —
rubric `396e1799eb2b`, base schema `5ee1b8ec16ab`.

Scorer preconditions verified before first use: 6/6 targets resolve, registry admits all
five variants, baseline attaches, codex authenticated, contract 56 lines, harness already
proven end-to-end by a probe run. **First contact will not fail.**

## 0A is next, and its Copilot arm is DEFERRED — not dropped

0A has **zero TODOs**: the extract was written 2026-08-09 and the phase is authored. What is
open is 19 checkboxes — the tiered reading, three labs, and a six-point exit gate. Lab 0A.1
has its own instructor skill at `.claude/skills/lab-0a-1/`, which blocks on predictions and
builds the disposable target with an allowlist. Use `/lab-0a-1` rather than improvising one.

Readiness checked 2026-08-28: `claude` 2.1.250, `codex` 0.147.0 and `copilot` all installed;
`templates/experiment.md` and `templates/run-record.yaml` both present. **The local hook
count is 22, not the ~21 the phase README says** — across 8 events including `SessionStart`
and `UserPromptSubmit`. Un-isolated, all 22 join the lab.

**Copilot's premium quota is exhausted and Lab 0A.1 runs without it, for now.** 300/300 used,
`remaining: -1`, `overage_permitted: false`, **resets 2026-09-01**. `chat` and `completions`
report `unlimited: true`, so the account is alive. Read it with
`gh api /copilot_internal/user` (`quota_snapshots`); the CLI only shows it in an interactive
footer.

**Corrected 2026-08-28, third session, by measurement.** This file implied the arm could be
run anyway because `gpt-5.4-mini` costs 0 premium requests. **It cannot.** Because
`overage_permitted` is false, a premium call must be *refused* and a successful call would
prove it cost none — so the test is one-sided and cheap. It was run:
`copilot --model gpt-5.4-mini --allow-all-tools --no-color --prompt "Reply with exactly:
READY"` → **`You have no quota`**, `Requests 0 Premium`. The CLI is gated by the premium
counter regardless of model; the 11 runs in `EXP-BASELINE-COPILOT` predate exhaustion.
**The deferral to 2026-09-01 was right and the workaround was wrong.**

**What deferring it costs, stated so it is not forgotten:** Copilot is the runtime the
business case names for backend agent v1. Running 0A.1 on Claude + Codex alone means the
harness whose behaviour matters most from B2 onward is the one left unobserved. The fix is
cheap — 0A.1 is read-only, and `gpt-5.4-mini` costs 0 premium requests on this account, so
the Copilot arm can be added after 2026-09-01 for approximately nothing. **Add it before B2,
not after.** A three-way comparison missing its target runtime is not a two-thirds result.

## Where you actually are, in five lines

**B1 is closed. B2 has run. Nothing is blocked on you that has not been decided.**
B2 needs its 4 predictions committed before its first run — that rule is untouched by
Decision E and is the only thing between here and the first baseline runs. 0A also still
blocks B2 and still has zero of its 19 boxes done. Everything else — harness, isolation,
scorer, gate, report — is built, tested and pushed.

**Before B2 leans on the rubric, run follow-up 1** in `E-001-rubric-null-rate.md`: score a
submission the anchors were NOT written against. `codex-score.sh --run-id` already does it.
If the null rate stays at 0 on unseen work the rubric is doing real work; if it jumps, the
B1 grid measured the fixture set rather than the rubric.

**Readable view of this file:** https://claude.ai/code/artifact/e023a84c-8f0c-49ee-a2cb-cf33eb5b78cc
— **STALE as of 2026-08-31 and not yet republished.** It still describes B1 as blocked on
seventeen blind cells, which Decision E superseded. A second board,
https://claude.ai/code/artifact/f2294fb0-ca98-4681-a42a-a51a8b5afad3, is stale for the same
reason. **This file is the source of truth; both links are views, and both are behind it.**

`tools/check-board-freshness.sh` now exists to stop that being invisible, and CI runs it. It
compares each board's declared `built-from:` sha against this file's own last commit:

    <!-- board: https://claude.ai/code/artifact/<id> built-from: <sha> -->

**No marker is declared yet, deliberately.** Declaring one for a board that is already behind
would hand the next session a red build for a defect it did not create. Add the marker in the
same commit as the republish, and the check starts guarding from that point. Until then it
reports "nothing claimed, nothing to check" — which is honest, and is also exactly the L3 gap
the check was written to close, left open on purpose and named here rather than forgotten.

## On disk but not in git, so a new machine or a `$TMPDIR` purge loses it

Nothing here is evidence and nothing blocks you — recorded so it is not looked for later.

| what | where | matters? |
|---|---|---|
| `workbench.local/` — the blind-sheet workbench, 5 variants + README | the lab repo, gitignored via `*.local` | **rebuild it** if lost; the one-line command is in its README |
| 6 kept worktrees, 4 agent logs | `$TMPDIR/observatory-run-*`, `observatory-agent-*.log` | no — every run today was a harness proof, none is baseline data |

## What the fourth session changed, 2026-08-29

Five defects, every one of which would have produced a confident wrong number rather than a
crash. All fixed, all with the same argument: **zero batch runs exist, so changing the
instrument costs nothing today and costs the baseline permanently once runs are on record.**

| # | was | commit |
|---|---|---|
| 1 | the codex arm forwarded no `--model`, had no sandbox policy and no isolation — a "plain baseline" would have loaded `~/.codex/AGENTS.md` | `b288625` |
| 2 | `behavior` counters reported `0` for "not measured" while `efficiency` reported `null` in the same record | `5ed158e` |
| 3 | nothing could produce B2's gate item — a single-arm report with median and range | `1b843c4` |
| 4 | **a terminal wrapper on `$PATH` added 26 hook executions to every run**, invisible to the record | `b46f4e6` |
| 5 | codex printed its token total to a log nobody read; the arm recorded null tokens | `fd5ef00` |

**#4 is the one to re-read if you read only one.** `which claude` resolved to a cmux shim
that execs a wrapper appending `--settings` with 12 hooks; the codex shim injects
`--dangerously-bypass-hook-trust`. Measured both ways: shim present → 12 registered, **26
executions**; shim stripped → **0 and 0**. `run-agent.sh` now strips `*/cmux-cli-shims*`
before resolving any binary and prints which binary it got. **Read that line before a batch.**

It also corrected a claim this file had been making: `--setting-sources project` **works**.
The 22 user-scope hooks are *registered* in an isolated run and **none execute**. Registration
is not execution, and the count that was being quoted as contamination was a registration
count.

## Runs on record from this session — none of them are baseline data

| experiment | why it exists | reusable? |
|---|---|---|
| `EXP-B2-REHEARSAL-CLAUDE` / `-CODEX` | proved Decision D on a real worktree | **no** — launched through the wrapper, carry 26 hook executions |
| `EXP-SHIM-CONTROL` | proved the shim fix: 0 flagSettings, 0 hook executions | no |
| `EXP-CODEX-TOKENS` | proved token capture: `reportedTotalTokens: 50891` | no |

All under their own keys so they can never join a batch's `n`. Delete them or leave them;
they must not be counted.

## B2 readiness — assessed 2026-08-28, third session

`phases/b02-plain-baseline/READINESS.md` is the artifact and the RUNBOOK now carries the
corrections. It was written first and attacked by three families before anything was built
from it: 12 findings, 10 accepted, and one of its own hypotheses died under test (Copilot,
above).

**Three defects fixed in `agent-observatory` `b288625`, all in the codex arm, none of which
would have surfaced as a crash:**

| was | consequence |
|---|---|
| `--model` accepted, never forwarded to codex | the record wrote the model the CALLER asked for — a provenance field wrong on the experiment's own independent variable, in the direction that looks correct |
| `--isolate-user-settings` ignored on codex | a "plain baseline" loading `~/.codex/AGENTS.md` (which imports a 32-line shell-routing file), 3 MCP servers, 71 skills, 66 agents. **B3's treatment inside B2's control** |
| `baseline-runs` counted nothing | five banners and exit 0 could mean n=2 |

**`--ignore-user-config` does not isolate codex, and that is measured rather than read.**
With a marker instruction in `$CODEX_HOME/AGENTS.md` the model still emitted the marker under
the flag; a `CODEX_HOME` holding `auth.json` alone dropped it.
`runner/verify-codex-isolation.sh` reproduces both sides — positive control first, because a
one-sided test passes when codex is simply broken. **It is L2, not L1**: nothing stops someone
writing an `AGENTS.md` into that directory, and what makes it a control is that the runner
rebuilds it per run.

**Now green:** `make smoke` 18/18 — use it, not `make urls`, which prints configuration and
connects to nothing. `check-run-gate.sh` proven against two live records. `KEEP=1` reaches
`--keep`. BE-003 resolves and `sample-service` is present.

**The 172 runs already in the observatory cannot be SCORED.** Every worktree is gone; they
predate `--keep` by sixteen days. They stay good evidence for anything read off the record
itself — pass rate, failure class, duration, cost — and they are not rubric input. B2 starts
from zero scoreable runs, not from the seventeen BE-003 rows.

**The one step that still costs a run:** RUNBOOK §0.5 — rehearse ONE run per arm with
`--keep`, then inspect the attachment set with `LAB_SCORE_DRY_RUN`. **If it lists 25 files
the whole service is attached, `test-quality`'s null precondition can never fire, and
Decision A is silently disabled between B1 and B2.** That cannot be checked without a real
worktree, and no existing run has one.

**Fixed 2026-08-29 before the baseline, `agent-observatory` `5ed158e`:** a behaviour counter
of 0 and an absent measurement were the same value. The codex arm has no telemetry path, so
its runs recorded a complete-looking set of zeros — the rehearsal added 64 lines with
`modelCalls: 0`. Migration `V4` makes the six counters nullable; 18 historical rows became
null and 156 kept their measurements. `analyze-experiment.py` had been correcting this alone
since before the fix, while the API, the web UI and Prometheus all read the zeros literally;
the correction now lives in the record. **Codex still reports honest nulls rather than real
numbers, so `behavior.*` and `efficiency.*` are not comparable across arms** until
observatory#10 — the record now says so itself.

**Filed:** observatory#64 — three hook events fire on every codex run including a fully
isolated one, and `~/.codex/hooks.json` currently fails to parse, so the operator's hooks are
absent by luck rather than by control. Comments on observatory#35 (resolved-model identity is
still open, and #35 prescribes `--bare` which the RUNBOOK forbids — someone must decide
which loses), #49, #10, and lab#44, lab#27.

## Known and unfixed

- **The `test-quality` assertion trigger is undefined.** The one surviving round-7 finding,
  found by both families independently. Fixing it moves the rubric sha. See above.
- **Five zombie `opencode run` processes**, aged 10–12 days, belong to *other* projects.
  Not touched. They may hold sessions or quota.
- **`opencode` still runs the acceptance gate and the critic**, and still hangs. Both now
  have a stall budget; that bounds the cost, it does not fix the cause.
- **The review harness reads the artifact, not the artifact beside its inputs.** That is how
  an anchor citing an unattached enum survived two review passes. A rubric anchor can only be
  checked against the attachment set by hand.
- **`lab_dirty` cannot tell an unrelated edit from the artifact moving.** Round 7's header
  says `lab_dirty: true` because `tools/check-links.sh` was edited while the run was in
  flight. The reviewed artifact was stamped `396e1799eb2b` and did not move. Do not read
  that flag as "the rubric shifted mid-review" without checking the artifact sha.
- **Three controls in two days reported success over a scope smaller than believed**: the
  stall budget covering three of four opencode calls, the link checker's `PRIVATE` skip
  excusing two URLs from being fetched, and the scheduled link job reading 2 of 33 files.
  All three now fixed. When you meet a green control here, ask what it did not read.

## Do not repeat these

- **Never edit a tool while a run of it is in flight.** bash reads scripts incrementally; an
  edit shifts byte offsets under the running instance. It killed a review mid-run with a
  syntax error at the line being edited, and `bash -n` passed the whole time.
- **A header-only findings file is a stall, not an empty result.** Check for a live process.
- **Bundling an edit script and a commit in one background command** produced a commit whose
  message described changes an aborted script never made.


## What the fifth session changed, 2026-08-30

**B1 closed, and three machine-level defects fixed that would each have produced a confident
wrong number.**

| what | detail |
|---|---|
| **B1 CLOSED** | `925563c`. Decision E, predictions committed 17:43:03Z, ten runs 17:43–17:47Z, KEEP on every clause |
| **Decision E** | `90266f4`. Second scorer is a harness. Human sheet superseded, unfilled, unrevivable |
| **scorer could hang forever** | `3e0ac2d`. `opencode-score.sh` had no stall budget while its sibling had one since 08-27. Worse: a killed run leaves a header-only file that classifies as EMPTY — and EMPTY means the rubric was wholesale undecidable, E-001's most informative result. A harness hang would have manufactured the headline finding |
| **three wedged `opencode run` processes killed** | aged 12–14 days, ~75 min CPU each, invisible because the hook that spawned them detached and wrote to `/dev/null` |
| **`ai-memory` hook bounded** | now in PR #213 with the concurrent session's own improvement — their `79ba689` fixed a staleness guard that read a *checkout* as a push and was discarding valid verdicts |
| **reaper armed** | `~/.local/bin/reap-stale-opencode.sh`, launchd every 10 min, 30-min threshold, kills process groups, logs every kill. Deliberately NOT a `$PATH` shim — that is the cmux mechanism that put 26 invisible hook executions into every run |

**The opencode arm did not stall once, 5 of 5.** Do not read that as the stall being fixed.
One clean batch, and the budget added that morning was never called on.

**One finding arrived as evidence rather than as a bug**, which had not happened here before:
`change-focus` anchor 0 says "cite the line in both trees". codex did; opencode named the
methods and cited one tree. Nothing executes that instruction. L3, caught by a run instead of
by a debugging session.


## B2's result, and the two things that spoil half of it — 2026-08-31

**14 runs, 14 passed, both arms, every gate.** `EXP-B2-BASELINE-CLAUDE` n=9 (asked for 5 —
operator error, a torn-down `nohup` batch relaunched without counting what had recorded) and
`EXP-B2-BASELINE-CODEX` n=5.

**The finding: prediction 4 refuted, 0 of 14 against a <20% refuter.** Its mechanism was this
project's guardrail model turned on an agent for the first time — the envelope convention is
L3 prose in `ApiError.kt`'s KDoc, the functional behaviour is L2 tests the agent can run and
watch fail, so a plain agent should satisfy what executes and miss what is written down.
**Every agent picked up the L3 convention unprompted, including 9 of 9 on the tightly
sandboxed claude arm.** L3 prose adjacent to the code an agent must edit is read and followed
without enforcement.

**What that does to B3:** an instruction telling an agent to follow a convention it already
follows at baseline measures nothing. **B3 must find an axis where the baseline actually
fails**, or it will produce another INCONCLUSIVE like phase 1's.

**BLOCKING — the arms are not the same experiment. Filed as observatory#65.**
`run-agent.sh` gives claude `--strict-mcp-config`, `--disable-slash-commands` and an allowlist
of two shell commands; it gives codex `--sandbox danger-full-access` and nothing else. On the
first codex run the agent shelled into the operator's home directory, read
`~/.agents/skills/memtrace-first` and `memtrace-preflight`, and announced it would follow them
— a treatment inside the control. The run record says `mcpHash`, `skillsHash` and
`instructionsHash` are all null, so **the record claims uncustomized while the transcript
shows otherwise.**

`verify-codex-isolation.sh` is not wrong: it proves `AGENTS.md` does not AUTO-LOAD. It cannot
prove the agent will not go read instructions itself, and under `danger-full-access` nothing
does. **Fourth control here reporting success over a scope smaller than believed — and the
first found by reading an agent's transcript rather than by testing the control.**

**Duration is void from this batch.** 70–3790s and 97–35342s; one run was suspended 9.8 hours
across a machine sleep. Not task variance.

**Re-run needed for:** any cross-arm claim (after parity), and duration. **Not needed for:**
the pass rate and prediction 4, both robust to the contamination.

**Predictions 1 and 3 are unsettled** — settling them needs per-event ordering, and the codex
arm has no behaviour telemetry at all. **Prediction 2 was void before the run**, on a false
premise I wrote: it asserts "nothing asks for tests" and `task.md:34` instructs `./mvnw test`.
Recorded beside the prediction, not revised.

**The pattern worth carrying forward:** Decision E removed the second-derivation guard in the
morning; an adopted prediction broke on an unchecked premise four hours later, exactly the way
the previous adopted set broke. Both decisions were still right. The cost was real and it
arrived on schedule.

## Decisions taken 2026-08-30/31, all reversible, all recorded

| | what | where |
|---|---|---|
| **E** | second scorer is a harness, not the author. Human blind sheet superseded, unfilled, unrevivable | `90266f4` |
| **F** | 0A does not gate B2. **Not** a completion claim — its exit gate is untouched. Reversal condition recorded | `a1f1c8a` |

**Two dependencies dissolved in one day.** Both correct locally. That is also what losing the
plan to the schedule looks like from inside, and the third should be argued harder than either.
