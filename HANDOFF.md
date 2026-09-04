# Handoff — 2026-09-04 (twelfth session)

Read `CLAUDE.md` first; it carries the operational facts and is loaded automatically. This
file is the *state*: what is in flight, what is blocked, and on whom.

**Start at "Stop 8 is CLOSED, and its own halt was the wrong diagnosis" below.** Stops 4, 5, 6
and 7 are merged. Stop 8 is closed with a measured result. The run's largest result is still
B3's — *a global instruction file, proved delivered, changed nothing measurable* — and stop 8
now sits beside it as the opposite shape: **a customization that changed something measurable,
and an instrument that would have hidden it.**

## Position

**Spine 8 of 28. Positions 4, 5, 6, 7 and 8 CLOSED.** B1 closed 2026-08-30. No agent exists and
none should until stop 10.

## Stop 8 is CLOSED, and its own halt was the wrong diagnosis — 2026-09-04

**E-004 answers a claim three vendors make and none of them measures: does a skill's
`description` decide whether it loads?** With the body held byte-identical and only the
description changed:

| arm | activations | source | trigger |
|---|---|---|---|
| B, description matches the task | **5 of 5** | `projectSettings` | `claude-proactive` |
| C, description names an unrelated domain | **0 of 5** | — | — |
| A, no skill installed | **0 of 5** | — | — |

**Two-sided Fisher p = 0.0079** — the `(5,0)` cell, one of exactly three the MDE table registered
as decidable at `n = 5`. **CONFIRM**, by decision-rule row 1. All five predictions held, including
the one registered as most likely to be wrong. Cost −7.6 % against control, which does not reach
the registered +25 % row and is not a finding at this `n`.

### The halt this stop opened with was on a wrong premise

It halted claiming a project skill *cannot be delivered at all*, blaming the path. **The cause was
a flag.** `runner/run-agent.sh` passed `--disable-slash-commands` — *"Disable all skills"* — on
every claude run this project has ever done. **6 of 6 activated without it, 0 of 6 with it, at
both paths, p = 0.0022.** The nested path activates mid-run perfectly well; it is merely absent
from the `/name` registry at session start, which is all the first probe actually tested.

**And the first probe could not have seen it**: it was hand-run as
`claude --setting-sources project --model … -p "/name"` — the runner's flags **minus the one that
decides the outcome**. A reproduction of a harness that drops one of the harness's flags is a
control reporting success over a smaller scope than it claims.

**Your decision on it was right about *where* and could not have been right about *which line*.**
Option (b), the runner force-add, is in the runner now — the root skill path needs it — but on its
own it would have committed the file into runs with skills switched off, and fifteen runs would
have agreed perfectly on a confident null. **The benchmarks repository was never touched.**

### Four instrument defects, one shape, seen from both sides

| where | the rule it had | what it did |
|---|---|---|
| `tools/skill-activation.sh` ×3 | everything not `bundled` / not `bundled`-or-empty / not `bundled`-or-`plugin` is **mine** | would have credited a foreign activation to the treatment **on the control arm** |
| `runner/run-agent.sh` guard | **every** `Skill` call is a leaked plugin skill | marked the first matched-arm run **F15, "EXCLUDE from comparisons"**, for loading the skill it was given |

Every matched-arm run loads a skill, so that guard would have ended the batch with **arm B at
`n = 0`** and a report saying the treatment produced no usable runs. **A guard that excludes the
treatment arm does not look like a bug. It looks like a null result.** Both categories are now
allowlists by name, in files with fixture sets that prove they refuse — 28, 13, 16 and 7 cases,
every count re-checked against a live run rather than against prose.

### What the instrument can now say, and what it still cannot

**Can:** `skill.source` for a project-scope skill is `projectSettings` — the first ever recorded
here. **Cannot:** tell two installed skills apart, because `skill.name` is redacted to
`custom_skill` (prediction 5, held on 5 of 5).

<details><summary>The stop-8 section as written at the halt — kept because it is the record of what was believed</summary>

### Stop 8 is BLOCKED, and the block is the finding — as written at the halt

**A Claude Code project skill cannot be delivered to a BE-003 benchmark run.** The location the
runner can commit is not the location the runtime registers, and no path satisfies both:

| location | runner can commit it? | registered at session start? |
|---|---|---|
| `.claude/skills/<name>/SKILL.md` (worktree root) | **NO** — benchmarks `.gitignore:19` is `.claude/*`; `git add -A` skips it, the setup commit fails, the run dies | **YES** — `claude -p "/name"` loads it and quotes its body |
| `sample-service/.claude/skills/<name>/` (nested) | **YES** — tracked, in the setup commit | **NO** — `Unknown command` |

Both halves were executed, not argued, with the same binary, model and flags the runner uses.
Evidence and the exact commands:
[`evidence/p03/skill-delivery-probe-20260904T072000Z.md`](evidence/p03/skill-delivery-probe-20260904T072000Z.md).

**The nested path is the dangerous one.** It installs, commits, is tracked, and its runs evaluate
clean at 7/7. Had E-004 batched its fifteen runs there, all three arms would have returned zero
activations, agreed perfectly, and produced a confident finding that *the description does not
affect whether a skill loads* — from fifteen runs in which no skill was ever registered. **That is
Phase 1's disaster with a different filename**, and §4 step 5 is the only reason it was caught
before the batch instead of after.

Three runs were spent: `16cd4378` died at setup; `c090f67e` and `d8be2b5f` completed with
evaluator exit 0 and **0** project-scope activations with telemetry present, so those zeros are
real rather than missing.

**What is NOT claimed.** Nothing about whether the description selects a skill. `E-004`'s five
predictions are registered, committed at `5d14182` before any run, and **unfalsified — not
confirmed, not refuted, not run.** The one behavioural observation is `n = 1` per condition: at a
location where the skill *was* registered, the model did not select it on the BE-003 task, even
when the description read *"REQUIRED … You must load this skill before editing
ShipmentController"*. That is the reason prediction 1 is worth running, not a result.

## What the tenth session changed, 2026-09-03 (autonomous, Opus 5)

**PR lab#53 merged as `27d67e5`**, squash, all 8 checks green on the final head. Stops 4, 5
and 6 stop being "written but unshipped".

**Stop 7 — Phase 2, prompt files — CLOSED as *extract only, labs deferred*,** which is what
the spine's itinerary registers for a ◇ stop. Three of the four required sources had never
been extracted; all four were read 2026-09-03 and the fourth re-verified. No benchmark run
was launched, so **`n = 0` and nothing in that workbook is a claim about the agent under
test.** The two findings worth carrying:

1. **`tools` reverses direction across vendors, and Lab 2.1 was about to be built on the
   wrong field.** VS Code's prompt-file `tools:` is a whitelist that narrows. Claude Code's
   `allowed-tools` is *pre-approval* — "tools Claude can use **without asking permission**" —
   which removes a prompt, not a capability. The narrowing field is `disallowed-tools`. A
   read-only `/review-change` ported by mapping `tools:` → `allowed-tools:` would be a
   write-capable agent that passes its own read-only check. Found by reading; no run needed.
2. **Two GitHub pages contradict each other on prompt-file support.** Response customization
   says *"only available in VS Code, Visual Studio, and JetBrains IDEs"*; the feature matrix
   marks Xcode 0.46.0 as `P`. The workbook's old advice — check the matrix before every lab —
   now has a mechanism: the prose page rounds `P` down to absent. Cite the matrix and its
   version, never the prose sentence.

**The preflight was re-run in full and all seven rows passed — and it found three defects in
the instruments, which is worth more than the seven passes.** They are in
`TRACK-B-STATE.md` under `preflight_corrections`; the first two need your attention:

- **`pgrep` is blind on this machine.** Bare `pgrep -fl opencode` fails with *"Regular
  expression evaluation error (illegal byte sequence)"* and returns nothing — which is
  indistinguishable from "no stall". Only `LC_ALL=C pgrep` sees the processes. Both
  `CLAUDE.md` and the run prompt's §4a tell the reader to check for a live opencode process
  before trusting a findings file. **On this machine that check has been answering "no" without
  looking.** It is the house failure mode — a control reporting success over a smaller scope
  than believed — sitting inside the procedure written to catch exactly that. Two wedged
  opencode processes aged 2h20m were found this way and killed; their review had already
  completed and is committed, so no evidence was lost.
- **The previous preflight's isolation claim was too broad.** It read
  *"hook_execution_start = 0 across the registered population"*. In fact 129 of 209
  telemetry-joined registered runs have `> 0`, all of them from pre-isolation experiments.
  The claim holds exactly and only for the 25-run B3/E-003 population — which is the
  population E-003 actually used, **so E-003's isolation proof is untouched and only the
  state file's wording was wrong.** Corrected in place.
- **`LAB_SCORE_DRY_RUN` is a destination path, not a boolean** (`codex-score.sh:287`). The run
  prompt's §0a row 3 says to set it to `1`, which writes a 502-line prompt to a file named
  `./1` in the repo root. Removed, tree restored. Prompt and code disagree; per the reading
  order the code wins.

**Nothing was newly blocked on you by this session.** The three items stop 6 left open (A, B
and C in `TRACK-B-STATE.md`) are unchanged and item C now has ~3 days left on it.

## Stop 6 closed, and the answer is a null

`Run by Opus 5 (claude-opus-5), autonomous, 2026-09-03. The author reviewed none of it.`

**`instructions-v0.1` — 57 words, three rules — is REJECTED and not replaced.**
[`E-003`](experiments/E-003-instructions-v0.1.md), 25 runs: 10 treatment and 10 control
interleaved, plus a 5-run dilution arm. All 25 exited the evaluator 0. Hash separation was
perfect — `sha256:90f95226…` on 10 of 10 treated, `null` on 10 of 10 controls — which is
precisely the assertion Phase 1 spent ~$4 and 20 runs failing to make, and it is now **L2**.

| outcome | treatment | control | p |
|---|---|---|---|
| **maintainability anchor 2** *(primary)* | **2 of 10** | **3 of 10** | 1.000 |
| `estimatedCost` | 0.152 | 0.1559 (**−2.5 %**) | 0.684 |
| `durationMs` | 89 000 | 100 500 (**−11.4 %**) | 0.165 |
| `toolCalls` | 18 | 18 (**Δ 0**) | 1.000 |
| L3 convention honoured | 10 of 10 | 10 of 10 | 1.000 |
| every rubric category | med 2 / 0 / 1 / 1 | identical | 1.000 |

**The smallest p in the experiment is 0.165, on duration, and it points the wrong way** — the
treated arm ran faster.

**Why this null is worth something.** A null is only as good as the ability to have seen a
non-null. Three checks, none assumed: the treatment was **delivered** (hash on every run, plus
a preflight run asserted before the batch); the codex scorer **agrees with a hand census
committed before it ran, on all twenty runs cell for cell**; and the control **reproduces B2**
on six measures across a harness-version boundary.

**R1's label was corrected by the acceptance gate, and the correction is worth reading.** The
artifact first defended "refuted" with *"8/10 vs 2/10 would have given p = 0.023"* — but 2/10 is
the **treatment** rate that was observed. The control that occurred was **3/10**, and against it
the registered 8/10 gives **p = 0.070**. The MDE had projected a control of 2/10 from B2's 1-of-5
and the control landed one run higher, which alone moved the design's resolving power outside its
own threshold. So R1 is **refuted as the claim it literally makes about the treated arm** — 2 of
10 against a predicted 0.8 rate has probability 0.000078, and needs no control — and **not
detectable as a between-arm difference** at this `n`. The verdict does not move. The sentence
claiming the effect was inside what the design could see is withdrawn, because it was a claim
about the instrument that had not been checked against the instrument. New follow-up: **derive
the MDE against the upper end of the baseline's interval, not its point estimate** — here that
would have registered n = 12 or 15 and made the difference decidable either way.

**The obvious rescue was tested and failed.** If 57 words got lost in context, 1 455 words
should be worse. The dilution arm — the identical three rules buried in a 19-section handbook —
reached the construct on **3 of 5**, *more* often than the concentrated file's 2 of 10. Across
all three arms the construct appears **8 of 25** and no pair separates. On this task, at this
model, it is chosen at roughly one run in three whatever the instruction file says or whether
one exists.

**The unregistered finding that arm produced is the one to act on: a 25× larger always-on
instruction file costs +4.2 %.** Three documents in these repositories argue for keeping
instruction files short, and the cost half of that argument rests on `EXP-BE002-CLAUDEMD-V2`'s
+39 % — a comparison that moved more than one variable. This arm moved file size alone. It does
not refute the +39 %; it means **the brevity recommendation cannot be made from cost** on the
evidence this project holds.

**The gate's removal clause was tested rather than trusted.** R3 — "follow the conventions
already documented in the files you are changing" — was written into the file *predicted inert*,
because B2 measured that behaviour at 14/14, so that "remove every rule with no measured effect"
would have to remove something or admit it cannot. It removed R3 (20/20 both arms, pooled 34/34
with B2). It then removed R1 and R2 as well.

**Two things are carried forward rather than tidied away:**

1. **The decision rule is defective.** Its `REJECT` row requires the file to be useless **and**
   cost more than +25 %. Cost was −2.5 %, so by the letter `REJECT` never fires and the verdict
   arrives only via the per-rule clause emptying the file. The row assumes a useless file is
   worth keeping if it is cheap. Fix it before the next experiment uses it — E-003 follow-up 4.
2. **An unregistered number that is not a result.** `test-quality` is null on 4 of 10 treatment
   runs and 0 of 10 controls, and the scorer was right — the nulls track exactly the runs that
   wrote no test file, checked twice. The arm carrying *"run the verification command before
   reporting the work complete"* wrote tests **less** often, 6 of 10 against 10 of 10, Fisher
   p = 0.087. It was **never a registered outcome** and is recorded as an untested hypothesis
   with a mechanism, not a finding. E-003 follow-up 1 makes it a registered primary outcome at
   n ≥ 20 per arm, or nothing at all.

**What halted this stop this morning was not true.** Two blockers were named; neither
materialised, and one was a directory-topology assumption that had never been checked against
the instrument. The reasoning is kept verbatim in
[`findings/track-b-2026-09-03.md`](findings/track-b-2026-09-03.md) with what each turned into.

## What the ninth session changed, 2026-09-03

**Autonomous session.** Every decision below was taken without the author and is marked
`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-03` where it lands.

### B2's gate is closed, and the deliberate failure grew into a matched pair

The workbook's last four blocks are filled from evidence and the gate table is in
`phases/b02-plain-baseline/README.md` under *Exit gate*, with a full validation table under
*Commit* — one row per gate clause, its evidence path, **the layer of the proof rather than of
the artifact**, and how a stranger re-derives it.

The deliberate-failure step asked for one un-isolated run compared against the nine on record.
**That comparison is not verifiable**, so it was replaced by an internal matched pair —
`E-002`, five isolated and five open, interleaved, one harness version. The nine baseline runs
carry `userSettingsIsolated: null`, which means *not measured*: the claim that they were
isolated rests on the flag that was typed, and the harness version has since moved
`2.1.251` → `2.1.259`.

**E-002's result, at n=5 per arm, 10/10 passing:** the contamination costs **+13.8 % cost,
+17.1 % cache creation, +16.7 % duration, 31 hook executions and 2 plugins per run** — and
moves **nothing** behavioural: identical tool-call medians, three changed files on all ten
runs, same verdict. Three of four predictions were refuted, the registered rule returned
**INCONCLUSIVE, leaning REJECT-as-stated**, and the flag stays mandatory because quality was
scored on one run of ten.

**The finding inside it is a metric, not an agent.** `inputTokens` reads **1,392–1,424**
isolated and **106–250** open — an 88 % fall while total cost rose 14 %, because hook output
pushes the task prompt inside the cached prefix. **Anyone comparing `inputTokens` across
isolation regimes reads the contaminated arm as cheaper.** Nothing in the record says the
column is uncomparable. Observatory follow-up filed as E-002 follow-up 3.

### The API has been dropping V6 fields for four days, and the runner validates them on the way out

`GET /api/runs/<id>` returns a four-key `runtime` block. `userSettingsIsolated`,
`shimsStripped` and `surface` are **absent, not null**. The container is
`agent-observatory-observatory-api-1` in the **colima** docker context, built **2026-08-30**;
`V6__agent_surface.sql` was merged after that. `run-agent.sh:850` sends all three on every run,
and obs#70's `validate-run-record.py` — live on the host — **accepts and asserts them**.

**So the record is validated on the way out and truncated on the way in.** V6's surface
recording, which this file and both `CLAUDE.md` files describe as done, is **L3 on the running
instrument**: a migration exists, a runner sends the values, a validator checks them, nothing
persists them.

**Not fixed here, deliberately.** A rebuild migrates the database holding all 201 runs and
simultaneously introduces the Spring Boot minor and Kotlin major merged the same day. That is
not an unattended action. B2's gate does not need it.

### The kept worktrees are hollowing out, and the scorer calls it agent behaviour

`$TMPDIR` is `/var/folders/.../T/`, which macOS reaps: it deletes **files** untouched for ~3
days and leaves the **directory tree** standing. Every worktree kept under `--keep` lives
there.

A complete worktree holds **17** `.kt` files. **Every scored B2 baseline run now holds 1 or 0.**
All still hold ~111 directories, so `RUNBOOK.md` §0.5 check #2 — `ls -d
${TMPDIR}observatory-run-<id>` — **still passes on all of them.** The check that exists to
prove the evidence survived cannot tell a full worktree from an empty skeleton.

Worse, the scorer's own message. Same run, same command that produced a six-attachment set on
2026-09-01:

> "the agent changed no source file … There is no submission to score. **That is a result about
> the run**, and the evaluator will have recorded it — it is not a scoring failure."

It is not a result about the run. It is a result about the operating system, reported as agent
behaviour — which `GUARDRAILS.md` names as the single most common way a guardrail corrupts a
measurement, and which this project already paid for once as harness bug #7.

**No score on disk is affected**; the five sheets were produced while the files were present.
What is gone is the ability to **re-derive** them, which is what validating a closed stop
requires. The hand re-derivation B2 owed was therefore taken on a fresh E-002 run —
`maintainability`, hand **2**, sheet **2**, written before the scorer ran. Evidence:
`evidence/b02/worktree-decay-20260903T134500Z.txt`.

### Also this session

- **Every open PR in all three repos was merged** — 13 of them, including all ten dependabot
  PRs. `obs#67` needed a hand-resolved conflict against `obs#57`; every dependabot branch was
  rebased onto current `main` and re-run before merging rather than trusted on a stale green.
- **Both review hooks had the same blinding defect and both are fixed.** `opencode` rewrites
  its bash through `rtk`, and `rtk git diff` filters `.claude/`, `.opencode/`, `.github/` and
  `findings/` out of its output — every path a hooks-only branch changes. A `bench-critic` run
  asked what had changed 43 times against 35 empty answers and died after ten minutes with no
  verdict. **The diff is now inlined into the prompt**, so there is no command left for an
  environment to filter, and a matched-but-empty diff prints BLOCKED instead of spending a
  model call. `agent-observatory`'s hook carried the identical line and was fixed before it
  could reproduce it.
- **`bench-critic` then produced a real REJECT** on the fixed hook, and its one high finding is
  **not addressed**: `findings/` is in neither `.gitignore` nor the evaluators' `IGNORE_RE`, so
  a review file written by a push counts as an untracked unrelated change and fails AC6 with
  exit 21 — the harness blaming the agent for a file the hook wrote. The fix is a semantics
  call (the sibling lab repo *commits* its findings), so it is the author's.

**Amended, eighth session: `maintainability` is 1 of 5, not 0 of 3.** Scoring the two members
of the scored population that had never been scored moved the phase's headline. Read
"What the eighth session changed" before quoting any number from the sections below.

**B2 produced data, and half of it is unusable. Read `phases/b02-plain-baseline/README.md`
from "B2 baseline — RUN" before quoting any number.** 14 runs, 14 passed. Prediction 4
refuted 0-of-14, and that refutation is the session's substantive finding. But the two arms
ran under different policies, so **no cross-arm claim survives**, and duration is void because
runs were suspended across a machine sleep.

**Amended 2026-09-01, seventh session.** The instruction and network channels behind that are
closed (PR #66) and **a ten-run re-run of both arms is held on one blank prediction**. But
cross-arm parity is **not reachable by flag** — codex has no tool allowlist, claude reads
files without a shell — so cross-arm claims stay blocked after the re-run too. That is
survivable: **B2's registered gate is single-arm.**

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

**AMENDED, eighth session: nothing is unmerged any more.** `main` is at `2b8f113` (PR #45).
`lab21/the-ladder-had-gaps` was squash-merged as PR #43 (`0be66e7`) and deleted on the remote;
**do not delete it locally** — HANDOFF and the phase READMEs cite shas on it (`925563c`,
`0dac30b`, `2958ca6`) which the squash made unreachable from `main`. They survive in this
clone and in `refs/pull/43/head`, nowhere else. That same orphaning broke the board check;
see the eighth-session section.

*Superseded, kept for the record:* `lab21/the-ladder-had-gaps`, **28 commits**, ahead of
`main`. `main` is at `0f58203` (PR #18, merged 2026-08-27, five CI checks green).

**PUSHED 2026-09-01, `84ab009..310c463`.** For four sessions this branch held B1's closure
and B2's entire result in one copy on one laptop, and this file kept saying so without the
push happening. **PR #43 is now green on the real tip — 8 of 8 checks, `MERGEABLE`,
`REVIEW_REQUIRED`.** Every earlier green on that PR was against `84ab009` and had never seen
Decision E, Decision F, the four B2 predictions or the baseline result.

</details>

## What is BLOCKED ON YOU, and cannot be delegated

### 1. ~~Stop 8 cannot proceed~~ — RESOLVED 2026-09-04, and the diagnosis behind it was wrong

**Closed. Neither of the two candidate lines was the blocker.** The item below is kept verbatim
underneath because it is the record of what was believed and what was recommended, and because
your decision on it — *fix it in the runner, never in the benchmarks `.gitignore`* — was right
about **where** and could not have been right about **which line**.

**What the blocker actually was:** `agent-observatory/runner/run-agent.sh` passed
**`--disable-slash-commands`** on every claude run, and `claude --help` defines it as *"Disable
all skills"*. No skill of any scope could load, at any path, in any run this project has ever
done. Measured — 3 repetitions per cell, detector a `Skill` tool_use in the stream:
**6 of 6 activated without the flag, 0 of 6 with it, at BOTH the root and the nested path,
two-sided Fisher p = 0.0022.** Evidence:
[`evidence/p03/skill-flag-probe-20260904T102230Z.md`](evidence/p03/skill-flag-probe-20260904T102230Z.md).

**So option (b), the force-add, would not have unblocked it on its own.** It would have put the
file in the setup commit of a run with skills switched off, and fifteen runs would have returned
zero activations in all three arms and concluded that the description does not matter. The
force-add IS in the runner now — it is needed for the **root** skill path, which is the one the
runtime registers at session start — but the flag was the thing.

**The benchmarks repository was never touched.** `git status --porcelain` in
`agent-observatory-benchmarks` is empty and `.gitignore` is unchanged.

---

## NEW, and this one IS yours — 2026-09-04

### A. E-004's control is clean for activation and is NOT clean for behaviour

Stop 8's headline is solid: matched 5 of 5, misdescribed 0 of 5, control 0 of 5, p = 0.0079.
**The co-variate is the problem.** Three of the four rubric categories are constant across all
fifteen runs; the entire spread is `maintainability`, whose anchor 2 is word-for-word the first
bullet of the skill body. And on it, **arm C scores like arm B and unlike arm A** — 4 of 5 versus
5 of 5 (p = 1.0), against the control's 1 of 5 (pooled treated vs control, p = 0.017) — **while
never having activated the skill.**

**It is not a result and I have not made it one**: `maintainability` was never a registered
outcome of E-004, so it gets the same shelf as B3's test-writing asymmetry. But two mechanisms
would produce it and this design cannot separate them:

1. **The file was read, not selected.** Arm C's `SKILL.md` is a tracked file in the worktree; an
   agent exploring the repo can open it and follow it with no activation event. **This is
   measured as possible, not speculated**: in the flag probe, 1 of 6 runs with skills *disabled*
   emitted the skill body's marker after reading `SKILL.md` as an ordinary file.
2. The arms differ by more than the skill — arm A has no `.claude/` directory at all.

**It cannot be settled from what is on disk.** The observatory's `tool_result` events carry
`tool_name` and no file path, and the kept agent logs hold only the final message.

**What would settle it is a fourth arm** — the same file installed where the runtime cannot
register it — and **§7 reserves a new arm for you.** It is cheap (5 runs, ~$0.75) and it decides
whether anything behavioural may ever be attributed to skill *selection* on this instrument.

### B. Two skills cannot be told apart by this instrument

`skill.name` is redacted to the literal `custom_skill` for project scope — E-004's prediction 5,
registered as the one most likely to be wrong, and it held on 5 of 5. With one installed skill
that is unambiguous. **With two it is not measurable at all**, so the obvious follow-up — a ladder
of descriptions between "shipment confirmation" and "CSS animations" — needs this solved first.

---

<details><summary>The item as written at the halt, 2026-09-04 morning</summary>

#### 1. Stop 8 cannot proceed — pick which half moves (NEW, 2026-09-04)

**One line unblocks it, and there are two candidates. They are not equivalent.**

**(a) `agent-observatory-benchmarks/.gitignore`** — add `!.claude/skills/` beside the existing
`!.claude/hooks/` and `!.claude/settings.json`.
*Cost:* that file is load-bearing for the evaluator's scope guard — its own comment says the
guard's second source is `git ls-files --others --exclude-standard`, "which respects this file".
Allowlisting the path changes what the evaluator can flag as an unrelated changed file if an
**agent** ever writes there. **§7 makes any change to what the evaluator measures a halt, so I did
not make it.**

**(b) `agent-observatory/runner/run-agent.sh`** — force-add the overlay it just installed, e.g.
`git add -A -f -- <paths copied from the customization>` instead of a plain `git add -A`.
*Cost:* none to the evaluator. The overlay is committed as the setup commit and **becomes the
evaluation baseline**, so a tracked `.claude/skills/` file is not in the agent's diff and is not
collected as untracked. This fixes, in the component that caused it, a problem the runner created
by requiring its own overlay to be committable.

**My recommendation is (b)**, for the reason above: it leaves what the evaluator measures exactly
where it is. It is still yours — it changes the harness mid-track, and B3 already carries one
disclosed harness move.

Either way, `E-004` is registered and ready: predictions committed at `5d14182` before any run,
two overlays whose bodies are byte-identical, and `tools/skill-activation.sh` proven by 11
fixtures. **The batch is ~15 runs and ~$2.30 and can start the hour this is decided.**


</details>

### 2. Squash merges have orphaned every prediction commit in the track (from the §9 validator)

All eleven. On `main`, `git log -- experiments/E-002-isolation-contamination.md` shows only the
squash `27d67e5` at 19:07Z — **six hours after the runs it was supposed to precede.** B3's nine
commits are the same. So *prediction precedes run*, the guarantee this track cites most, **cannot
be re-derived by a stranger cloning the repository**, and by the validator's layer correction it
is L3 rather than L2 as well.

Fixing it changes a repo convention — merge commits for stop branches instead of squashes, or a
pre-push check refusing a workbook that cites a sha `main` cannot reach — so §7 reserves it for
you.

### 3. The review harness's default critic has failed three times running

`ollama-cloud/glm-5.2` stalled twice on 2026-09-03 (once for 24 minutes against a 600 s budget,
printing no `STALLED` line and leaving wedged processes) and returned **OFF CONTRACT** on
2026-09-04. `codex` has succeeded on every invocation in the same window. **§4a reviews now run
`-P codex`** — a control substitution, not a registered experimental variable, since no
experiment's numbers come from the critic. Two related instrument facts are in `TRACK-B-STATE.md`:
bare `pgrep` is blind here without `LC_ALL=C`, and process checks must match the opencode
**binary**, not the wrapper's argv, or a poller registers as a live harness.



**Superseded in part on 2026-08-30.** B1's two blockers — the four prediction blanks and the
17-cell blind sheet — are **closed**, the first by adoption with recorded provenance and the
second by Decision E replacing the human column with a second harness. Neither was completed
as originally designed. The text that stood here described work that is no longer on the
critical path; it is in git history at `84ab009` if you want to read what was given up.

**SUPERSEDED IN PART, ninth session. The current blocked list is this one:**

1. **The parity re-run's prediction** — still blank, still the only TODO in the B2 workbook.
   B2's gate is closed without it, because the registered gate is single-arm. It blocks a
   ten-run batch and nothing else.
2. **A decision on rebuilding the observatory API.** V6 has been dropped from every run record
   for four days. The rebuild migrates the database holding all 201 runs *and* pulls in the
   Spring Boot minor and Kotlin major merged 2026-09-03. Yours, because it touches the only
   copy of the evidence.
3. **A decision on `findings/` and the evaluator's scope guard** — `bench-critic`'s high
   finding, unaddressed. Gitignoring it diverges from this repo, which commits its findings as
   evidence; adding it to `IGNORE_RE` changes what counts as a scope violation, and exit codes
   are a contract.
4. **Where kept worktrees live.** They are being deleted by the OS out of `$TMPDIR`. Moving
   them changes a registered path; leaving them means no scored run stays re-derivable for more
   than three days.
5. **0A — 19 checkboxes**, position 1 of 28, never started. Decision F means it does not gate
   anything.
6. **lab#44** stays open; closing it is yours.

*The eighth session's list, kept for the record:*

**What remains blocked on you, and genuinely cannot be delegated:**

1. ~~**B2's four predictions.**~~ **DONE 2026-08-30** — committed at 17:43:03Z before the
   first run, adopted with provenance. Three of the four are now refuted. **What replaces it
   is a fifth prediction, for the parity re-run, and it is blank** — see the seventh-session
   section at the end of this file.
2. **0A — 19 checkboxes**, ~5 hours of reading. Position 1 of 28, never started. Decision F
   (2026-08-30) means it no longer *gates* B2; it is still position 1 and still undone.
3. ~~**RUNBOOK §0.5.**~~ **SATISFIED 2026-09-01, and it cost no run** — a surviving worktree
   answered it: 3 files under test, 3 baseline, not 25. Decision A is live between B1 and B2.
   The dry-run output is committed at `evidence/b02/dry-run-attachment-set-0a222393.txt`.

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

## 0A is next, and its Copilot arm is SKIPPED — 2026-09-01, by the author

**DECISION G, 2026-09-01. The quota reset and the arm was skipped anyway.** Read with
`gh api /copilot_internal/user`: `premium_interactions` **remaining 300**, next reset
2026-10-01, `chat` and `completions` `unlimited: true`. The constraint that forced the
deferral is gone; the arm is not being added.

**What that costs, and this file has said it twice already so it is not a surprise:**
Copilot is the runtime the business case names for backend agent v1. Skipping it means the
harness whose behaviour matters most from B2 onward is the one nobody observes. It was cheap
— 0A.1 is read-only and `gpt-5.4-mini` costs 0 premium requests — so this is not a cost that
was forced. **Reversal condition: any B3-or-later claim about a Copilot-run agent must be
refused until this arm exists.** The window is 300 requests wide and closes 2026-10-01.

The section below is the record of how it got here and is left unedited.

## 0A, and how the Copilot arm came to be deferred

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

**Readable views of this file, both REPUBLISHED 2026-09-03 (ninth session), and both
carrying B3's null and the correction the acceptance gate forced:**

| board | what it answers |
|---|---|
| [Agent Observatory Handoff](https://claude.ai/code/artifact/e023a84c-8f0c-49ee-a2cb-cf33eb5b78cc) | where the project stands right now — B3's three arms, the two instrument defects still open, what is held |
| [Road to the First Agent](https://claude.ai/code/artifact/f2294fb0-ca98-4681-a42a-a51a8b5afad3) | the 28-position route, now three stops from an agent, and the cost-against-file-size figure |
<!-- board: https://claude.ai/code/artifact/e023a84c-8f0c-49ee-a2cb-cf33eb5b78cc built-from: 16e68c7 prose: aba92aa88e19 -->
<!-- board: https://claude.ai/code/artifact/f2294fb0-ca98-4681-a42a-a51a8b5afad3 built-from: 16e68c7 prose: aba92aa88e19 -->

The first had been **rebuilt but never published** — four earlier attempts were refused by the
publisher's view-guard, which will not overwrite a live artifact this session has not read. The
second was published on 08-30 and was structurally obsolete: its thesis was *"why seventeen
cells stand between you and a prompt"*, and Decision E deleted those cells. Both now carry the
current state.

`tools/check-board-freshness.sh` compares each board's declared `prose:` digest against this
file's prose, with marker lines excluded from the hash:

    <!-- board: https://claude.ai/code/artifact/<id> built-from: <sha> prose: <digest> -->

`built-from:` is provenance for a human — which commit someone built the board from. **Nothing
branches on it.** `prose:` is what is checked.

**AMENDED 2026-09-01, eighth session: the basis used to be a commit, and that could not work.**
A marker can only ever name a commit on the *branch*, and squash-merging destroys it. It
happened twice in one session — `4f71a45` from PR #43, then `bb7e316` from PR #46, the second
turning `main` red on boards that were byte-for-byte correct. No ordering avoids it: put the
marker in the PR that carries the prose and its sha is squashed away; put it in a later PR and
the prose PR is itself red. The check would have failed after every handoff update forever,
which is the "control that cries wolf" its own header warns about, and it would have been
switched off — correctly, as noise.

Moving to a prose digest makes three problems vanish rather than get handled: squash merges are
irrelevant, self-invalidation is impossible (the digest excludes marker lines, so writing a
marker cannot move it), and an unresolvable sha cannot arise. **The one exclusion is the marker
lines, and it is not a judgement about what matters** — it is what makes recording the digest
possible at all.

**From here the check is live: change this file's prose, and CI asks for a republish.** That is
the L3 gap closed, and it will occasionally demand a republish for a typo, which the tool's own
header argues for at length and is not a defect.

## On disk but not in git, so a `$TMPDIR` purge or a new machine loses it

**Updated 2026-09-01. A second row is now evidence, and the first row has been read.**

| what | where | matters? |
|---|---|---|
| **`evidence.local/b2-agent-logs/`** — 18 agent transcripts, 596 KB | the lab repo, gitignored | **YES, and now partly spent.** Predictions 2 and 3 were settled off it 2026-09-01 (see below); **prediction 1 is still open on the claude arm** and this is still its only possible source. Carries the observatory#65 evidence, which on reading is seven runs and not one |
| **`evidence.local/ww-001-plain-vs-instructed/`** — six runs, 256 KB | the lab repo, gitignored | **YES.** Rescued from `$TMPDIR` 2026-09-01. The only record of the CLAUDE.md null result and of B3's first candidate axis. Not a lab experiment — no run id, no evaluator verdict, no registered variable, and its own README says so at the top. Do not let it join a batch's `n` |
| 25 kept worktrees, **781 MB** | `$TMPDIR/observatory-run-*` | **partly.** Needed only for prediction 4's idempotency isolation, which wants the surefire output. Too large to mirror; if purged, that isolation needs fresh runs |
| `boards.local/` — two artifact sources + README | the lab repo, gitignored | no — losing them costs a rebuild, not a measurement. `b2-board.html` is rebuilt and unpublished |
| `workbench.local/` — the blind-sheet workbench | the lab repo, gitignored | **no longer.** Decision E superseded the sheet it fed. Kept as the record of a measurement designed and not taken |

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

## What the sixth session changed, 2026-09-01

**Nothing was run on the observatory. Two predictions closed by reading evidence already on
disk, one claim in this file corrected by a factor of seven, and B3 got its first candidate
axis — from a repository that is not `sample-service`.**

### Predictions 2 and 3 are settled, off the B2 logs, and both are refuted

`evidence.local/b2-agent-logs/` was rescued 2026-08-31 and not read until now. Reading it
closes two of the three open predictions without a single new run.

The arms are not observed the same way and that limit is real: the claude arm's log is its
final message only (19–33 lines), the codex arm's is a full event stream (1446–1725 lines).
So prediction 1 is settleable on codex and **not** on claude.

| | verdict | evidence |
|---|---|---|
| **1 — inspect before editing** | **HELD on codex, 5/5. UNSETTLED on claude.** | Identical shape every codex run: list files → read `Shipment.kt` + `ShipmentController.kt` → read `ApiError.kt` → edit. No write-first run. The claude arm's record shows 14–20 tool calls but carries no ordering, and a count is not an order. **Report it as unsettled there, not as agreement** |
| **2 — verification unprompted** | **REFUTED, 5/5 codex** | Predicted ≤2 of 5, refuter ≥4. Every codex run invoked `./mvnw test`; three chained it onto a `git diff` in one exec line, which is why a first pass over the exec list undercounted it at 3. Prediction 2 was already void on its premise; this measures instruction compliance, and compliance was total |
| **3 — completion claimed without evidence** | **REFUTED, 0 of 14** | Predicted ≥3 of 5 per arm, refuter ≤1. Every final message in both arms cites a verification run. claude: *"✅ All 17 tests pass"*, *"BUILD SUCCESS"*. codex: *"Verification: `./mvnw test` passed — 17 tests, 0 failures"*. Nine of nine and five of five |

**Three of four B2 predictions are now refuted, all in the same direction.** The baseline
agent is more disciplined than predicted, on every axis, every time. That is the third
consecutive adopted set to fail toward pessimism — see the provenance note in
`phases/b02-plain-baseline/README.md`, which called the bias before the runs.

### The observatory#65 contamination is seven runs, not one

This file said *"On the first codex run the agent shelled into the operator's home
directory."* **It was every codex log — 5 of 5 baseline plus the rehearsal and the token
run.** Identical first action, before touching the repo, in all seven:

    exec /bin/zsh -lc "sed -n '1,240p' ~/.agents/skills/memtrace-first/SKILL.md
                    && sed -n '1,260p' ~/.agents/skills/memtrace-preflight/SKILL.md"

followed by ~240 lines of operator skill text in context and an announcement that it would
follow them. Not an outlier. The arm's standard opening move, and the run record still says
`mcpHash`, `skillsHash` and `instructionsHash` are null.

**A visible candidate effect on output, which strengthens #65 past "a treatment was
present".** All 5 codex runs reused the existing `SHIPMENT_ALREADY_EXISTS` for a
cancelled-shipment 409 and added no error code; all 9 claude runs added a new one and
invented **six different names** for it. `memtrace-first` instructs the agent to check for
"a recorded decision, ban, convention, or contract" before editing — a plausible cause of
exactly that difference. **It is not separable from the model.** That is what the parity
defect costs, made concrete.

### WW-001 — a CLAUDE.md that states what the code already shows measures nothing

Not a lab experiment. Six runs outside the harness on `Kotlin-server-squad/writewave`
@ `13105be`, `claude-haiku-4-5-20251001`, one ticket, one variable. Full record and caveats
in `evidence.local/ww-001-plain-vs-instructed/README.md`.

The variable is whether the repo's own root `CLAUDE.md` is reachable — `backend/` copied out
of the monorepo (plain) versus the whole monorepo with the agent started in `backend/`
(instructed). **The control was measured per run, not assumed**: `claude_md_in_tree` 0/0/0
and 1/1/1, plus a separate probe asking the agent to echo its project instructions with no
tools — `NONE` in the plain tree, the full 87-line file in the instructed one.

That file states, in prose, the two conventions the ticket traps on: *"GlobalExceptionHandler
maps to HTTP status codes"* and *"`User.canAccess(template, permission)` checks ownership +
role."* Neither appears anywhere inside `backend/`. The instructed arm received **twice the
instruction text of the ticket itself** (3,633 chars against 1,831).

**6 of 6 passed. The arms are indistinguishable.** Errors thrown rather than assembled 3/3
and 3/3. `canAccess` 3/3 and 3/3. Layering, DTOs, URL shape, and reuse of two dead domain
methods: 3/3 and 3/3. Pairwise distance between the added service code does not cluster by
arm — within plain **56.7**, within instructed **37.3**, across **39.3**; the closest pair in
the batch crosses the arms at 15 lines and the furthest pair shares an arm at 67.

**This is B2's L3 finding reproduced one layer up** — not a KDoc in the file being edited,
but a real project instruction file, auto-loaded, on a working codebase.

### B3's first candidate axis, and it is a `should`

**All six runs duplicated ~30 lines rather than extracting a shared private helper**, while
the file they were editing already contains `updateTemplatePublishStatus`, extracted for the
identical publish/unpublish shape.

**Do not call this a defect.** The books corpus covers it as `GN-018` — *"extract repeated
knowledge, not merely similar-looking code"*, `severity: should`, and the rule text is
explicit that it cuts both ways and is a judgement call. What it is: **the baseline reliably
making a different call from the codebase's own precedent, 0/6, in both arms.**

B2's own conclusion was that B3 must find an axis where the baseline actually fails or it
produces another INCONCLUSIVE. This is the first candidate on record. It has a rule id, it
is measured, and — being a `should` — it will need a scoring rule agreed *before* the run,
not after.

### Static analysis exists now, and it covers about a fifth

`Kotlin-server-squad/writewave` branch `chore/backend-static-analysis` @ `a8c5b1f`, pushed
2026-09-01, no PR. detekt 1.23.6 + ktlint 12.1.2, 843 lines of config, **zero source
changes, 261 tests still green**. Current surface: detekt **247**, ktlint **713**.

Two traps recorded in the commit message because they will bite the next person who bumps a
version: detekt 1.23.7 embeds Kotlin 2.0.10 and refuses against this project's 1.9.25;
1.23.6 is built against 1.9.23 so its own classpath is pinned there, and naming anything on
the `detekt` configuration wipes its defaults, hence `detekt-cli` appearing twice. Also:
**`ktlintFormat` took the count from 2,637 to 4,226** on this tree. Configure the code style
before formatting, never after.

**What it means for the 175-rule corpus in `ai-agents/books`.** detekt ships 210 rules; a
hand mapping against the corpus lands around **19 direct hits and 14 partial — roughly one
in five**, ±3. Coroutines (49 rules) gets ~6 because detekt's coroutine ruleset is 7 rules
total; testing (15) and framework-integration (6) get **zero**. `EH-006`, `EH-007`, `EH-005`,
`GN-001`, `CO-005`, `CO-011` are exact.

**`GN-018` is not covered by either tool.** The nearest rule is `StringLiteralDuplication`,
which only sees repeated strings. The one axis with measured headroom stays L3 whatever you
install — which is the honest limit of the whole exercise: static analysis takes the
mechanical fifth and leaves every judgement call exactly where it was.

**The routing this implies**, and it follows from the null result rather than from taste:
the mechanical fifth goes to detekt and ktlint, where something executes and refuses;
`enforcement/review-rules.md` (13k tokens) goes to a *review* agent, which is what its own
header says; and an instruction file earns only the rules the baseline is measured to
violate. Everything else is inert text — 3/3 versus 3/3 is what inert looks like.

### Decision taken

| | what | where |
|---|---|---|
| **G** | Copilot arm skipped, not deferred. Quota had reset — 300 available, next reset 2026-10-01. Reversal condition recorded in the 0A section | this file |

## What the seventh session changed, 2026-09-01

**One thing is blocked on you, and a ten-run batch is held behind it.** Everything else here
is built, tested, pushed and green.

### BLOCKED ON YOU — the parity re-run's prediction

`phases/b02-plain-baseline/README.md`, last section, ends in a blank TODO block. It needs a
**mechanism**, a **number** and a **refuter**, on one question: of 5 runs per arm, how many
score `maintainability` 2 — the exhaustive `when` in expression position, where a new enum
constant is a compile error — rather than 0, the `if` chain that compiles and takes the
fallback unannounced.

The decision procedure is already written above the blank, deliberately, so the prediction
cannot be shaped to fit what turns out to be measurable. It has two columns — the rubric cell
and the diff read by hand — because **the scorer is codex and one arm's submissions are
codex's own output**, which is not a neutral instrument. If the columns disagree, the diff
wins and the rubric has a defect.

**This set is not being adopted from Claude.** It has read every B2 agent log and both scored
grids; the last two adopted sets failed 3 of 4 and 3 of 4. You asked to write this one.

**Then check the order before launching:** `git log -1 --format=%cI` against the first run's
`startedAt`. Doing that backwards once voided nine runs.

### Three baseline runs scored — `0dac30b`, and the sixth session ended before recording it here

All three claude runs 2/0/1/1 = **55/100**, **zero null cells of twelve**. Selection was by
start time, before any sheet existed.

- **E-001 follow-up 1 is answered on unseen work.** These are agent submissions, not the five
  fixtures the anchors were written against, and the null rate stayed at 0. The rubric
  measures the rubric, not the fixture set.
- **RUNBOOK §0.5 is satisfied and cost no run** — a surviving worktree reports 3 files under
  test and 3 baseline, not 25. Decision A is live between B1 and B2. The dry-run output is
  committed at `evidence/b02/dry-run-attachment-set-0a222393.txt`; it had reached the repo as
  a file named `1` from a shell redirect and is renamed rather than deleted, because it is
  the evidence for a gate item.
- **The maintainability column is 0 on all three, and that is B2's finding stated as one
  claim:** the plain agent satisfies what it reads and what executes against it, and does not
  reach for constructs that make a future mistake impossible. Prediction 4 was refuted
  because the reading half is easy; maintainability is 0 because the defending half is not.

### observatory#65 — the closable half is closed. PR #66, 3/3 green

Two commits, `b0db19d` and `f3039be`. Both measured, positive control first.

| | what | how it was found |
|---|---|---|
| operator skills | per-run `HOME`, `.m2` symlink only | `--sandbox workspace-write` was tested as the fix and **does not work** — it restricts writes, not reads |
| **network plugins, new** | `--disable plugins` | a fresh isolated `CODEX_HOME` does not stay clean: codex installs `deep-research-work@0.1.14`, `openai-templates@0.1.1`, `plugin-management@0.1.0` on startup, and `deep-research-work` ships `skills/deep-research/SKILL.md`. **`--disable remote_plugin` installs all three anyway** |
| the record | V6 — `userSettingsIsolated`, `shimsStripped`, codex `surface` | both booleans were computed at run time and printed to a terminal nobody keeps. Nullable: the 172 existing runs are *not measured*, never `false` |

**The obviously-named flag failed twice in two commits.** `workspace-write` for the HOME leak,
`remote_plugin` for the plugin channel. Both would have given a green run and no isolation.

**Not removed, deliberately:** codex seeds six skills into `skills/.system` and the agent can
see them — asked to list what it had, it named five of six. They ship in the binary and are
pinned by `codex-cli 0.147.0`, already in `runtime.version`. A plain baseline is the product
as shipped minus what varies by machine or by network, so they are recorded, not stripped.

`verify-codex-isolation.sh` is three checks now, each with its own positive control. **Check C
needs no model answer** — the install happens at startup — so it is the only one that still
works when the account is out of quota, which is how it was verified.

### Parity by flag is not reachable, and that is a finding rather than a failure

`phases/b02-plain-baseline/README.md` asked for "codex gets a tool allowlist and a sandbox
that is not `danger-full-access`, or the claude arm's restrictions come off". **Neither is
available.** Codex has no allowlist mechanism; claude reads files through native tools that
need no shell at all. The products have different tool *shapes*.

So: the surface is **recorded** rather than equalized, and **cross-arm claims stay blocked**.
That costs less than it sounds — **B2's registered gate is single-arm** (≥3 run folders, a
report with median and range), and `baseline-report.py` says so in its own docstring. Nothing
downstream of B2 needs the cross-arm number. Do not loosen the claude arm to manufacture one.

### The batch, when the block clears

**Both arms, n=5 each.** Not codex alone: duration was void on both from the machine sleep,
`n=9` on claude was operator error, and a batch split across two versions of the runner is
two batches. `KEEP=1` is required or neither column of the new prediction is readable.

**Codex quota was exhausted at 14:21 today and resets 17:27.** Hit while probing; the probes
were read-only and cheap, and check C above was verified *through* the exhaustion.

### B2 can be scored by two harnesses now, and the second one has a measurable tic

`opencode-score.sh` gained `--run-id`. **`CLAUDE.md` used to say a cross-harness check on B2
was "not currently possible"; it is, and that file now says so.** Decision C is untouched —
codex is still the registered scorer and owns the numbers. opencode is the second *reader*,
which B1 had and B2 did not, and the only mechanism that separates a rubric defect from a
model quirk. Both paths admit a run by the evaluator's recorded verdict and attach the same
set, so the sheets are comparable by construction.

It also killed a single point of failure that had already failed: codex hit its usage limit
mid-session and B2 was unscoreable for three hours.

**All three scored runs, both harnesses, zero nulls on six sheets, 9 of 12 exact:**

| | architecture | maintainability | test-quality | change-focus |
|---|---|---|---|---|
| all three runs | 2 / 2 | 0 / 0 | 1 / 1 | **1 / 2** |

**Every disagreement is one category, one direction, three of three.** opencode's *fact* is
wrong all three times — it reported "only confirm added, create/getById/list and imports
identical" while a class KDoc had been deleted on one run and a new `ErrorCode` constant added
to a second attached file on the other two. **Whether that scores 1 or 2 is a live rubric
question** (a required enum constant is arguably part of the change) and belongs in a rubric
round, not in a sha moved mid-experiment.

**The harness finding is the solid one and it is the fourth occurrence.** `change-focus`
anchor 0 says *"cite the line in both trees"*. opencode cites one file, target tree only, every
time — while a pre-agent tree sits attached and unread. Nothing executes that instruction. One
occurrence was a curiosity; four is a property of the harness, and an argument **for**
Decision C.

Three opencode calls, three returns, no stall. Do not read that as the stall being fixed.

### Two corrections to things this file and the issues assert

1. **observatory#64 says three hook events fire on every codex run including a fully isolated
   one.** Measured today: through the **cmux shim** they fire (`SessionStart`,
   `UserPromptSubmit`, `Stop`); through `/opt/homebrew/bin/codex` with the same isolated
   `CODEX_HOME`, **zero**. `run-agent.sh` strips the shim, so #64 may be describing the shim
   rather than codex. Not enough to close it — nobody has re-read the runs it was filed from
   — but do not spend a session on codex's hook loader before checking which binary produced
   the evidence.
2. **The first probe of the day went through that shim** and its hook lines are a property of
   the probe, not of the arm. Every measurement quoted above was re-taken on the real binary.


---

## What the eighth session changed, 2026-09-01

**Four green PRs merged, a fifth opened and merged, and B2's headline shrank.** Nothing is
green-and-unmerged any more, in either repo.

| merged | |
|---|---|
| lab **#43** → `0be66e7` | B1's closure and B2's entire result. Had been one copy on one laptop for four sessions |
| lab **#45** → `2b8f113` | B2 at n=5, the duration correction, the baseline report, the board-check fix |
| obs **#66** → `b39b85e` | per-run `HOME`, `--disable plugins`, V4/V5/V6 |
| obs **#50** → `13419ef` | §13.1 — compare efficiency only among runs that passed |

### `maintainability` is 1 of 5, not 0 of 3

Runs 4 and 5 by start time (`aa72e2c2`, `72fdc94f`) had never been scored. Same pre-registered
selection rule that picked runs 1–3. Both harnesses, zero nulls on four new sheets, no opencode
stall. **18 of 20 exact.**

| # | run | architecture | maintainability | test-quality | change-focus |
|---|---|---|---|---|---|
| 1 | `5bd24356` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / **2** |
| 2 | `0a222393` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / **2** |
| 3 | `8322e71b` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / **2** |
| 4 | `aa72e2c2` | 2 / 2 | **2 / 2** | 1 / 1 | 1 / 1 |
| 5 | `72fdc94f` | 2 / 2 | 0 / 0 | 1 / 1 | 1 / 1 |

**Both columns of the decision procedure agree, so this corrects the finding and not the
rubric.** `aa72e2c2` is `return when (shipment.status)` in expression position, all three
constants, no `else` — anchor 2, **L1**. `72fdc94f` is two `if` guards and a bare fallback
return — anchor 0, **L3**. Read by hand off the kept worktrees, independently of the sheets.

*"The plain agent does not close the door behind itself"* was true of three runs and is too
strong at five. The old text is left standing in the phase README; a claim that shrank when
the sample grew is the record worth keeping.

**Two knock-ons.** opencode's `change-focus` disagreement is **3 of 5, not 3 of 3** — it agreed
on runs 4 and 5, so "the same mechanism firing on every run" does not survive n=5. And the
prior behind the blank prediction has moved: the claude half is now **4 of 5 used `if`, 1 of 5
used `when`**, measured.

### The sleep explains one run, and not the arm it was used to void

Run 9 finished 21:30 with the machine demonstrably awake; the claude arm's spread from 149s to
3790s happened inside a seventy-minute window that evening. Only run 10, the codex one, spans
the gap to 06:16. What degraded runs 6–9 is **not established** — start times are ~55s apart
while runs take ~80s, so the queue deepens, but contention is a candidate and not a proof.

Narrower true statement: the duration tail on both arms is contaminated by something the run
record does not capture, and the record cannot separate a contaminated run from a clean one.
That argues for **obs#53** and for recording load, not for re-running everything.

### B2's gate is one run and four prose blocks from closed

`baseline-report.py` had never been run on this phase. It now has, over the **full
pre-registered arm** rather than a post-hoc subset — cost, tokens and call counts are not
wall-clock measurements and need no subset, and picking the five fast runs would have been
exactly the selection this phase exists to avoid.
`evidence/b02/baseline-report-20260901T192000Z.txt`:

```
claude n=9  pass 9/9  cost 0.1085–0.1674 median 0.1487  tokens 6606–8916 median 7812
codex  n=5  pass 5/5  cost / tool calls / model calls  not measured on any run
```

That last row is #66's V4 arriving in the analysis layer: an arm with no telemetry now reads as
unmeasured rather than as the most efficient arm in the comparison.

**Still owed by B2:** the deliberate-failure run (and a prediction for it first), and four
workbook blocks — Lab B2.1, deliberate failure, the exit-gate answer, and the commit line.

### The board check disagreed with itself across two machines on one commit

Squash-merging #43 orphaned `4f71a45`, the sha both board markers named. The checker gates its
self-invalidation clause on `git cat-file -e`: this clone still holds the orphaned object and
printed "2 board(s) current"; CI's clone does not and printed STALE. Same commit, same script,
opposite answers.

**It was lenient on the machine where the fix gets made** and strict only after the push, and
its message sent the reader to republish two boards that were byte-for-byte correct. An
unresolvable sha is now its own outcome — it still fails, but it names the marker rather than
the board, and says not to republish on that message alone. The verifier's tenth case asserts
the **message**, since UNVERIFIABLE and STALE both exit 1; mutation-checked against the
pre-patch checker.

**This will recur on every squash merge that touches this file.** Relabel the marker; do not
republish.

### Open, and what it needs

- **obs#51** — *"render unreported behaviour counters as unknown, not zero"* — was **superseded
  by #66** and must not be merged as it stands. It infers absence from `modelCalls == 0 &&
  toolCalls == 0`; V4 made the columns nullable, so the heuristic would now blank a genuine
  measured zero. #51's own commit message named the upstream flaw that #66 then fixed. Either
  close it as superseded, or rebase it down to just the notice block re-keyed to `null`.
  ~~**Undecided.**~~ **Resolved 2026-09-02: closed as superseded, not merged.**
- **obs#52** — *"BehaviorDto fabricates zeros: record telemetryComplete instead of inferring
  it"* — is what #66's V4 did. ~~Looks closable; nobody has checked it off.~~ **Closed
  2026-09-02.**
- **lab#22 — 0A**, position 1 of 28, still never started. Since Decision F it no longer gates
  B2; its 19 checkboxes are all still open.
- **lab#44** — *"The scorer admits fixtures by name, and B2's output does not have one"* — is
  **still open, and looks closable.** Its own comment records Decision D as built 2026-08-28
  and confirmed by the author the same day. The one caveat it left — that the attachment half
  could not be inspected because every run predated `--keep` — is now spent: B2 ran with
  `--keep`, and `maintainability` was re-read by hand off those kept worktrees. Nobody has
  checked it off. **Not closed here; that is the author's call.**

### What is blocked on you, still, and after tonight

1. **The parity re-run's prediction** — now to be written against **1 of 5**, and knowing that
   number was produced after the prediction block existed and before the prediction was written.
2. **A prediction for the deliberate-failure run**, before it runs.
3. **B2's exit-gate answer** — the material is in the phase README under "What was learned
   about the plain agent that 0A did not teach"; deciding what goes in the gate block is yours.

## What the autonomous run changed, stops 4 → 9, 2026-09-03/04

**Position: spine stop 9 of 28 closed.** Stops 4, 5, 6, 7 and 8 closed and merged before it
(lab#53 → `27d67e5`, lab#54 → `df4a022`, lab#55 → `93ee5f7`, lab#56 → `049e871`,
lab#58 → `ebd0b39`, obs#72 → `5179432`). Stop 9 is lab#60. **Still no agent under test, by
design — nothing before stop 10 builds one.**

### Stop 9's result, and the two sentences worth carrying

**A `tools:` allowlist is L2. It was observed refusing.** 30 runs, `n = 10` per arm: tool list
**0/10**, read-only description **0/10**, ungoverned control **10/10**, both treated arms
`p = 0.00001`. One transcript carries the runtime's own words — *"No such tool available: Write.
Write is disabled for this session, in subagents as well as here."* **This is the first observed
refusal in this track**, and the first time a customization class here has had a delivery proof
that executes (`--agent <bogus>` exits 1 and prints the registry).

**A read-only description held 10/10 and is still L3.** The arm made **zero** write attempts, so
nothing tested it. A disposition on this task, not a boundary — and the distinction is the whole
point of the stop.

**Then one word reopened it.** The deliberate failure added `Bash` to the allowlist and nothing
else: **10/10** tracked changes, `p = 0.000011` against the same list without it, and
**`p = 1.0` against no list at all**. Median duration 16.0 s versus the control's 16.5 s. The
mechanism was uniform — `find`, then `cat > ./calc.py` with a heredoc, then `python3 -c` to
verify. **`tools:` filters tool NAMES; nothing inspects what a permitted tool can do.**

### What that does to B4 at stop 10, which is next

B4 builds a `backend-feature-implementer` whose registered allowances include ***"run approved
commands"***. On this evidence **that allowance and a tool-list write boundary cannot both be
claimed** — the first dissolves the second. Four routes exist and **none is tested here**:
exclude `Bash`; an OS sandbox underneath; `permissionMode`; or a command-gating hook. Whichever
B4 picks needs its own arm, and the choice belongs in its design, before its runs.

### Five validator passes processed, and two of their findings were load-bearing

`findings/track-b-validation-2026-09-04-{5,6,7,8,9}.md`. **No stop was marked NOT CLOSED.**

1. **Stop 8's `invocation_trigger` column was wrong on 2 of 5 matched runs.** `33a4090d` and
   `8998ef3b` are `nested-skill`, not `claude-proactive`. **Four passes on two model families
   found it before this project's author did**, and the repository's own `skill-activation.sh`
   confirms it. The registered outcome is unchanged (5/0/0, `p = 0.00794`); the **mechanism
   sentence narrows** — counting only `claude-proactive` gives 3/5 vs 0/5, `p = 0.167`. Stop 8's
   headline is now the sentence that holds on every reading: *a matched description produces an
   activation and a mismatched one does not.* **What `nested-skill` is emitted for is not known**
   and is the first registered follow-up; it is answerable from data already on disk.
2. **The `p = 0.0022` flag-probe evidence was in `/private/tmp` and in no repository**, cited by
   a relative path that resolved to nothing. All 17 files are now at `evidence/p03/flagprobe/`
   and the matrix was re-derived **from the preserved copy**. `/private/tmp` had already hollowed
   the five scored B2 worktrees, so this was one cleanup away from gone.

Also corrected: *"exist in this clone only"* was **false** in three places — every prediction
commit is retrievable from `refs/pull/{43,53,56}/head`. The independence checks named **two of
the three paths** the runner archives into every worktree. `E-004` cited an experiment key with
**zero runs** on the instrument.

### What is BLOCKED ON YOU

1. **Item B — two skills cannot be told apart.** `skill.name` is redacted to the literal
   `custom_skill` for project scope. With one installed skill that is unambiguous; with two the
   outcome is **not measurable at all**. Any follow-up needing two skills at once is unbuildable
   until this is solved or designed around. **Unchanged by this stop.**
2. **Item C — the resolved flag set is still not on any run record.** Stop 9 was the natural
   place to fix it and **did not**: `run-e005.sh` mitigates it with one committed, diffable
   `CLAUDE_FLAGS` array used by every arm of every run, which is weaker than a record and
   stronger than a claim. The cheap L2 remains a hash of the resolved args on the run record, or
   restoring the V6 `runtime.surface` fields. **Still not built.**
3. **The fourth arm you approved (decision 7) has not run.** Five runs on BE-003 with the skill
   body present as a plain tracked file that is not a skill, to separate *selected* from *read*
   in stop 8's maintainability co-variate. Due before B6 opens at stop 13, at a phase boundary.
4. **`nested-skill` (new, from this stop's validator passes).** Cheaper than the fourth arm and
   it bears on stop 8's **registered** outcome rather than a co-variate. Also due before stop 13.

### Two things about the instruments, because both are the house shape

**A control that did not cover the class it was pointed at.** `check-overlay-parity.sh`, built at
stop 8 with 16 fixtures, recognised `SKILL.md` and nothing else — so it refused agent overlays
*whether or not the declared key was the one that differed*. It failed **closed**, which is why
this is a gap and not a defect. Now covers `.claude/agents/*.md`; fixtures **16 → 27**, and the
case count is now **asserted** rather than announced, because it claimed 16 while running 26.

**A `git add -A -f` that exited 0 while staging nothing.** Preserving the flag-probe evidence,
`sub/` turned out to be a scratch git repository, so `cp -R` brought its `.git` along and git
staged **a single gitlink** — a pointer to a repository that exists nowhere else — instead of 17
files. `git status` showed one clean `A` line. Caught by counting the staged files against the
files on disk, not by reading the exit code.

`Written by Opus 5 (claude-opus-5), autonomous, 2026-09-04.`
