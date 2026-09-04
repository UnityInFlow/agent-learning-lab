# Experiment E-004 — does the *description* decide whether a skill loads?

**Stop 8 of the spine, Phase 3 (Agent Skills). Track A lab that runs the benchmark, so the whole
§4 loop applies.**

> ## ⚠️ THIS EXPERIMENT HAS NOT RUN. THE TWO THINGS THAT BLOCKED IT ARE NOW CLOSED
>
> **Both blocks are resolved, and the history of each is kept rather than tidied away.**
>
> **1. Delivery — RESOLVED, and the original diagnosis was wrong.** The first halt read the
> block as a *path* problem. It was a *flag*: the runner passed `--disable-slash-commands`
> ("Disable all skills") on every claude run, so no skill could load at any path. Measured at
> 6 of 6 against 0 of 6, Fisher p = 0.0022 —
> [`evidence/p03/skill-flag-probe-20260904T102230Z.md`](../evidence/p03/skill-flag-probe-20260904T102230Z.md).
> The runner now has `--enable-skills` (default off), a guard that **refuses** a skill overlay
> when skills would be disabled, and a force-add so the documented root skill location can be
> committed. See the second amendment below.
>
> **2. The §4a acceptance gate returned `REJECT` on all three permitted rounds — and that verdict
> STANDS as recorded.** It is not retroactively upgraded, and this file is not claimed to have
> passed a gate it did not pass. What has changed is that **the three findings left open after
> round 3 are now closed by executing code**, each with a fixture set proving it rejects:
>
> | round-3 finding | closed by | proof |
> |---|---|---|
> | arm C's delivery proof is circular with the prediction it confirms | the overlay moves to the **root** path, where explicit `/name` settles delivery without consulting the description | `runner/verify-skill-delivery.sh`, 6 of 6 |
> | nothing mechanically asserts that only the `description` differs | `tools/check-overlay-parity.sh` | `tools/verify-overlay-parity-checker.sh`, 8 of 8 |
> | partial telemetry corruption is not separated from absent telemetry | `tools/skill-activation.sh` gains `PARTIAL-telemetry-damaged`, exit 4 | `tools/verify-skill-activation.sh`, 21 of 21 |
>
> **What is still open and is not pretended otherwise:** `skill.source` for a project-scope skill
> is unknown, so prediction 2 has no denominator until the preflight pins it. The preflight is
> the thing that pins it, and the batch does not start until it has.
>
> Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-04. The original banner, written at the
> halt, is preserved verbatim below.
>
> <details><summary>The banner as written at the halt, 2026-09-04T08:14Z</summary>
>
> 
> **Two things block it, and both are recorded rather than worked around.**
> 
> **1. Delivery.** A Claude Code project skill cannot be installed into a BE-003 run at all —
> the path the runner can commit is not the path the runtime registers. See the amendment below
> and [`evidence/p03/skill-delivery-probe-20260904T072000Z.md`](../evidence/p03/skill-delivery-probe-20260904T072000Z.md).
> Unblocking it is one line and it is the author's call (HANDOFF, *BLOCKED ON YOU* item 1).
> 
> **2. The §4a acceptance gate returned `REJECT` on all three permitted rounds.** Five blocking
> findings were fixed across rounds 1 and 2; round 3 returned four more, and §4a caps the loop at
> three rounds. **`REJECT` after round three is recorded as such and is not a pass.** The
> deepest finding is fixed below — the measurement script no longer claims to know which
> activation was the installed skill — but **at least three of round 3's findings are open**:
> arm C's delivery proof is circular with the prediction it is meant to confirm; nothing
> mechanically asserts that only the `description` differs between arms; and the script does not
> separate partial telemetry corruption from absent telemetry.
> 
> **Whoever runs this must resolve those first.** The predictions below are registered and
> unfalsified; the design around them is not yet sound.
> 
> Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-04
>
> </details>

`Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-04T07:0XZ; the author did not review
before the run.` The exact commit and first-run timestamps are written into *Sanity checks*
after the batch, and the commit must precede the first `startedAt`.

## Question

Three vendors state, in their own documentation, that an agent chooses a skill by matching the
task against the skill's **description**. None of them shows a measurement. On this instrument,
on one task, at one model: **does changing only the description — with the skill body held
byte-identical — change whether the skill loads?**

And underneath it, the question this stop exists to answer at all: **can the observatory record
skill activation?**

## Hypothesis

Skill selection is driven by the description, not the body. A skill whose description names the
task's domain will be loaded; the *same* skill body behind a description naming an unrelated
domain will not. Activation is therefore a property of the description text, and is visible in
`claude_code.skill_activated` telemetry per run.

## Predictions

Numbered, specific, falsifiable. Direction and magnitude stated. Each says which *kind* of claim
it makes — one-arm (binomial, needs no control) or between-arm (needs the control that occurred).

1. **[one-arm] The matched arm loads the skill on ≥ 4 of 5 runs.** Mechanism: all three vendors
   document implicit selection as a match between the prompt and the description; arm B's
   description names BE-003's exact domain (Kotlin Spring service, shipment confirmation,
   controller/service conventions), so the match is direct rather than inferential.
2. **[structural] The control arm records 0 installed-scope skill activations on 5 of 5.** Not a
   statistical claim — no skill is installed, so there is nothing to load. **Every scope this
   experiment did not install is excluded from the outcome by definition**: `bundled` (Claude
   Code ships its own), `plugin` (the operator may have some), and events carrying no
   `skill.source` at all.

   **This prediction is not yet measurable, and the reason is a correction the gate forced three
   times.** `tools/skill-activation.sh` now reports a count **per `skill.source`** and refuses to
   label any bucket "the installed skill". Its first three versions each kept an open
   *everything-else-is-mine* bucket — not-`bundled`, then not-`bundled`-or-empty, then
   not-`bundled`-or-`plugin` — and every one of them would have put a user-scope, enterprise or
   future-source activation on the **control** arm, the arm that installs nothing. Naming one
   more scope each round was patching a category that was wrong.

   **So the outcome has no denominator yet.** No project-scope skill has ever been recorded on
   this instrument, so the value `skill.source` carries for one is unknown. **The preflight must
   pin that value and this prediction must then name it explicitly**, before any batch is read.
3. **[between-arm] The misdescribed arm loads on ≤ 1 of 5, at least 3 fewer than the matched
   arm.** Mechanism: the `SKILL.md` **body is byte-identical** between arms B and C; only the
   frontmatter `description` differs. If selection reads the body, C loads as often as B; if it
   reads the description, C does not load on a shipment task.
4. **[instrument] `customization.skillsHash` is `null` on 5 of 5 runs in *both* treated arms,**
   despite a skill being installed, committed by the runner as a setup commit, and (per 1)
   loading. Mechanism: `agent-observatory/runner/run-agent.sh:328` computes it as
   `hash_of .github/skills.md` — one fixed file, at a path this treatment does not create,
   because a Claude Code project skill lives at `.claude/skills/<name>/SKILL.md`. **Falsifiable:
   a non-null `skillsHash` refutes this outright.**
5. **[instrument, low confidence — the one most likely to be wrong] For a project-scope skill,
   `skill.name` is redacted to the literal string `custom_skill`.** Basis: on this instrument the
   only custom skills ever recorded are plugin-scope, and all 20 report `custom_skill`, while the
   10 bundled records report a real name (`run`). **No project-scope skill has ever been recorded
   here**, so this extrapolates across a scope boundary from `plugin` to `project` and may simply
   be wrong. `skill.source` for a project skill is likewise **unknown and is not predicted.**

*A prediction you did not write down is always retroactively correct.*

### AMENDMENT — 2026-09-04, from the §9 validator's second pass

Source: [`findings/track-b-validation-2026-09-04-2.md`](../findings/track-b-validation-2026-09-04-2.md),
corrections (a) and (c). Applied additively: no prediction, result, sheet or run folder was
rewritten.

**Correction (a) — the registration citation is stale, and prediction 2 was rewritten after it.**
This file has been cited here, in [`phases/03-skills/README.md`](../phases/03-skills/README.md)
and in `TRACK-B-STATE.md` as *"registered `5d14182` before any run"*. `5d14182` is where the
predictions were first committed and is still where the design was registered — but the text a
reader sees is not the text at `5d14182`. Four later commits edited it. **All four landed before
any batch run and under the §4a gate's REJECTs**, so no evidence was destroyed and no wrong
prediction was revised; the citation is nevertheless no longer true of what a reader sees.

The whole pre-run edit history, so a stranger does not have to reconstruct it:

| commit | committed (UTC) | what it changed in this file |
|---|---|---|
| `5d14182` | 2026-09-04T07:03:58Z | predictions first registered |
| `1d503ec` | 2026-09-04T07:08:52Z | delivery amendment — overlay path moved root → nested |
| `0075565` | 2026-09-04T07:36:16Z | §4a round 1 REJECT — decision rule restated in Fisher's test |
| `d169b74` | 2026-09-04T07:57:48Z | §4a round 2 REJECT — prediction 2 tightened, decision row 0 added |
| `5a14711` | 2026-09-04T08:14:48Z | §4a round 3 — banner added, prediction 2 gains its no-denominator paragraph |

**The last pre-run edit is `5a14711`.** §9 check 2 — *does the prediction commit precede the first
run's `startedAt`* — must be applied against `5a14711` for any run of this experiment's registered
batch, not against `5d14182`.

Those six shas are reachable in this clone and in `refs/pull/56/head`, and **not from `main`**,
which squashed them. That is the same process defect the first validator pass raised; from stop 8
on, stop branches merge with a merge commit (`--merge`), never a squash — author decision 4,
2026-09-04.

**The superseded text of prediction 2, kept rather than lost.** As registered at `5d14182`:

> 2. **[structural] The control arm records 0 project-scope skill activations on 5 of 5.** Not a
>    statistical claim — no skill is installed, so there is nothing to load. Bundled skills
>    (`skill.source = bundled`) may still activate and are **excluded from the outcome by
>    definition**, because the outcome counts only the installed skill.

It was superseded because the §4a gate demonstrated twice that *"the outcome counts only the
installed skill"* is a claim the instrument could not keep: every version of
`tools/skill-activation.sh` implemented it as an open *everything-else-is-mine* bucket, which on
the **control** arm would have credited a user-scope, enterprise or future-source activation to a
treatment that installs nothing. The current text makes the same structural claim without the part
the tool cannot support.

**Correction (c) — the run record cannot see this treatment, so §5's independence check must not
use it.** `customization.skillsHash` is `null` on both treated probe runs (`c090f67e`,
`d8be2b5f`), because `agent-observatory/runner/run-agent.sh:328` hashes `.github/skills.md` and
nothing else. Prediction 4 registers exactly that, so it is not a surprise — but it has a
consequence this file had not written down:

> **For any skill arm in this track, `customization.*Hash` cannot distinguish treatment from
> control.** It is `null` in both. Delivery proof rests entirely on telemetry, and the value
> `skill.source` carries for a project-scope skill is — by `tools/skill-activation.sh`'s own
> header — still unknown.

Prediction 2's *"the outcome has no denominator yet"* paragraph and this row are the same problem
seen from two sides. Pinning that value is the first thing any run of this experiment must do.

Applied by Opus 5 (claude-opus-5), autonomous, 2026-09-04

## Independent variable

**Exactly one thing: the `description:` line in the skill's frontmatter.**

Arms B and C install a skill at the same path, with the same `name`, and with a **byte-identical
body below the frontmatter**. Arm A installs nothing. The body's identity is asserted mechanically
in *Sanity checks*, not by eye.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | ~~`--customization build/customizations/skill-v0.1/` (arm B) and `.../skill-v0.1-misdescribed/` (arm C), each containing `sample-service/.claude/skills/shipment-service-conventions/SKILL.md`~~ — **superseded 2026-09-04T10:40Z by the second amendment below: the arms are `skill-v0.2{,-misdescribed}` installing at the worktree root `.claude/skills/…`, with `--enable-skills` on all three arms.** (see both amendments below). The runner `cp -R`s the overlay into the worktree and commits it as a setup commit *before* the agent starts |
| Content hash | recorded per arm in *Sanity checks* after the build: `sha256` of each `SKILL.md`, and separately of the **body alone** (the two body hashes must be equal) |
| Preflight assertion | one run per treated arm before the batch. Proof that the skill reached the model is **`claude_code.skill_activated` present in telemetry for that run id** — the model loading it, not the file existing. `skillsHash` is *not* usable as the delivery proof, which is prediction 4 |
| Control assertion | arm A installs no customization: `--customization` is not passed, so the overlay never exists in the worktree. Structural, not merely uninstalled. Verified per run by `customization.*Hash` all `null` **and** zero installed-scope `skill_activated` events |

> Placing a file is not delivering a treatment. Phase 1 cost ~$4 and 20 runs to learn this.
> **This experiment cannot use the runner's own `skillsHash` as its delivery proof**, because
> prediction 4 says that field is blind to this treatment. The delivery proof is the activation
> event itself, which is a stronger assertion — it shows the model *used* the file, not that the
> harness *placed* it.

### AMENDED 2026-09-04T07:12Z, before any measured run — the delivery path moved

**No run has produced data.** The first preflight attempt died before the agent started, and
this amendment is written before the batch, in the open, as `E-002` did when its control
assertion had to move. The predictions above are **unchanged** — they are about description
versus body, not about a path.

**What happened.** The overlay was written to `.claude/skills/shipment-service-conventions/`
at the worktree root, which is the documented Claude Code project-skill location. The run
failed at setup:

```
run 16cd4378-5730-4bb2-a2dc-97931f35b2dd
On branch main
nothing to commit, working tree clean
run-agent: failed to commit the customization overlay
```

**Cause, confirmed:** `agent-observatory-benchmarks/.gitignore:19` is `.claude/*`, allowlisting
only `!.claude/hooks/` and `!.claude/settings.json`. `git check-ignore -v` on the installed file
returns that line. The runner installs an overlay with `cp -R` and then `git add -A`, which
respects `.gitignore`, so the skill was copied to disk and then excluded from the setup commit.

**This is the runner's L2 guard working, and it is worth naming.** In Phase 1 a treatment was
installed at a path the runtime does not read, and every check the harness had reported success
for twenty runs. Here the harness **refused to start a run whose treatment it could not commit.**
A loud failure at setup is the outcome that phase was supposed to buy.

**Where the skill goes instead:** `sample-service/.claude/skills/shipment-service-conventions/`.
That path is *not* ignored — `.claude/*` contains a separator, so it is anchored to the
`.gitignore`'s own directory and does not match nested `.claude/` directories. Verified with
`git check-ignore -q`, which returns 1 (not ignored) for the nested path and 0 for the root one.

**The caveat this buys, stated before the runs rather than after.** The runner starts the agent
with `cd "$WORKTREE"`, so the worktree root is the project directory and `sample-service/` is
*below* it. Claude Code documents two different loading rules:

> "Project skills load from `.claude/skills/` in the directory where you start Claude Code **and
> in every parent directory up to the repository root**."
> "Skills **also** load from nested `.claude/skills/` directories below your working directory.
> **When Claude reads or edits a file in a subdirectory**, skills from that subdirectory's
> `.claude/skills/` become available."

So this skill is **not in the listing at turn 1.** It becomes available only once the agent
touches a file under `sample-service/` — which this task requires, since `task.md` says *"The
service under test is `sample-service`"* — but the timing is a real condition, not a formality.

**What that does and does not damage:**

- **Prediction 3, the between-arm contrast, is unaffected.** Arms B and C install at the *same*
  nested path, so both become available at the same moment in the run. The only difference
  between them remains the `description`. This is the experiment's primary comparison and it is
  intact.
- **Prediction 1, the one-arm rate, is now a joint claim** — "the agent reached
  `sample-service/` *and* the description matched". A miss can no longer be attributed to the
  description alone. Recorded as a **known confound on prediction 1 only**, registered here
  before the data.

**What was refused.** The alternative fix is one line in the benchmark repository's
`.gitignore` (`!.claude/skills/`). That file is load-bearing for the evaluator's scope guard —
its own comments say the guard's second source is `git ls-files --others --exclude-standard`,
"which respects this file". Editing it changes what the evaluator can flag as an unrelated
changed file, and **§7 makes any change to what the evaluator measures a halt.** It was not
made. It is raised to the author instead.

`.agents/skills/` was also considered and rejected: it is not ignored, but Claude Code's
"Where skills live" table does not list it, so delivering there would repeat Phase 1 exactly —
a file installed, hashed, and never read.

Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-04

### AMENDED 2026-09-04T10:40Z, still before any measured run — the block was on the wrong premise, and all three open gate findings are closed

**No run has produced data.** Everything below is registered before the batch. The five
predictions are **unchanged**: they are about description versus body, and nothing here touches
that.

#### 1. The delivery block was misdiagnosed, and the misdiagnosis would have manufactured a result

The amendment above blames the *path*. The cause is a **flag**:
`agent-observatory/runner/run-agent.sh` passes `--disable-slash-commands` on every claude run,
and `claude --help` defines it as **"Disable all skills"**. Measured, not read —
[`evidence/p03/skill-flag-probe-20260904T102230Z.md`](../evidence/p03/skill-flag-probe-20260904T102230Z.md),
3 repetitions per cell, detector is a `Skill` tool_use in the stream:

| | root `.claude/skills/` | nested `sample-service/.claude/skills/` |
|---|---|---|
| without the flag | **3 of 3 activated** | **3 of 3 activated** |
| with it (every run so far) | **0 of 3** | **0 of 3** |

Pooled, 6 of 6 against 0 of 6, two-sided Fisher **p = 0.0022**.

**So this experiment would have batched fifteen runs with skills switched off**, recorded zero
activations in all three arms, found them in perfect agreement, and concluded that the
description does not decide whether a skill loads. Every harness check would have passed. That is
the third instance of this shape in this project and the second inside this stop.

**And the reason the first halt could not see it:** its registration probe was run by hand as
`claude --setting-sources project --model … -p "/name"` — the runner's flag set *minus the flag
that decides the outcome*. A reproduction of a harness that drops one of the harness's flags is a
control reporting success over a smaller scope than it claims.

#### 2. What changed in the instrument, and what it costs

| change | where | why |
|---|---|---|
| `--enable-skills`, **default off** | `run-agent.sh` | off, so every run recorded before today keeps its exact meaning; askable, because otherwise a skill treatment is undeliverable |
| a guard that **refuses** a skill overlay when skills would be disabled | `run-agent.sh` §5 | the same guard already there for an instruction file aimed at the wrong runtime, extended to the one treatment class it did not cover |
| the overlay's own paths are **force-added** into the setup commit | `run-agent.sh` §5 | the root skill path is gitignored in the benchmarks repo. **Disclosed harness move**, the second in this track. The alternative — one line in `agent-observatory-benchmarks/.gitignore` — is refused under §7, because the evaluator's scope guard reads that file |
| `--check-customization` | `run-agent.sh` | stops after the §5 guards, so they can be **proved** to reject instead of assumed to |
| `runner/verify-skill-delivery.sh` | new | 6 checks, two-sided: A refuses, B admits, C leaves a skill-free customization alone, F force-adds and tracks 1 of 1, D is the positive control that the skill really does activate, E that it does not with the flag. **6 passed, 0 failed** |

**`--enable-skills` is passed on ALL THREE ARMS, including the control**, so the switch is not
itself a difference between arms. Registered here as a controlled variable.

**The isolation the default bought is not lost.** `--disable-slash-commands` exists because the
operator's user-scope plugin skills leaked into runs (harness bug #13, a plugin skill in 5 of 23
runs of `EXP-BE002-CLAUDEMD`). `--setting-sources project` already closes that on its own:
`-p "/gsd-help"` returns a real user plugin skill's body without it and `Unknown command` with it.
Corroborated with its `n`: 0 of the 28 runs launched with `--isolate-user-settings` carry a
plugin-scope activation, against 18 of 183 earlier ones — Fisher **p = 0.139**, so the telemetry
alone does not resolve it and is not the proof. The execution test is.

#### 3. The overlay moves to the root path, and this is what closes the circularity finding

The arms are now **`build/customizations/skill-v0.2{,-misdescribed}`**, installing at
`.claude/skills/shipment-service-conventions/`. The `SKILL.md` bytes are **identical** to
`v0.1`'s; only the install path differs, and `v0.1` is left untouched because preflight run
`c090f67e` used it.

**Round 3's open finding — "arm C's delivery proof is circular with the prediction it is meant to
confirm" — is closed by this, not argued away.** At a nested path the only evidence that the skill
was available to a run is an activation, and arm C's prediction is that there is none; *"the
description did not select it"* and *"it was never there"* are then the same observation. At the
root path the skill is in the `/name` registry at session start, so:

> **Delivery proof, per arm, independent of the outcome:** in the kept worktree of one run of
> each treated arm, the runner's own flag set with skills enabled —
> `claude --permission-mode acceptEdits --strict-mcp-config --setting-sources project --model
> claude-haiku-4-5-20251001 -p "/shipment-service-conventions"`, i.e. every flag the run used and
> no `--disable-slash-commands` — must load the skill and quote its body. This is **explicit**
> invocation and does not consult the description, so it holds for arm C exactly as it does for
> arm B.
>
> **Delivery proof, per run:** `git ls-files` in the run's worktree shows the overlay tracked in
> the setup commit, and the run's invocation records `--enable-skills`.

The **known confound registered on prediction 1** by the previous amendment — that a miss was a
joint failure of *description matched* and *agent reached `sample-service/` in time* — **is
withdrawn**, because the root path is available from turn 1. Prediction 1 is a clean one-arm
claim again. The previous amendment's text stands above, unedited; this is the later fact.

#### 4. Round 3's other two open findings, both closed by something that executes

**"Nothing mechanically asserts that only the `description` differs between arms."** True: the
assertion was a `shasum` pasted into a table by hand, once. `tools/check-overlay-parity.sh` now
executes it — same path set, every non-`SKILL.md` file byte-identical, every `SKILL.md` body
byte-identical, and frontmatter differing **only** in keys named by `--allow-differ`. It exits 2
on any undeclared difference and **3 when the declared key is identical in both arms**, because a
treatment that was never applied looks like a working experiment from every other angle.
`tools/verify-overlay-parity-checker.sh`: **8 cases, 8 passed**. On the registered arms:

```
body identical: .claude/skills/shipment-service-conventions/SKILL.md sha256:d10a2c3988be520e
declared difference: … frontmatter 'description'
parity holds; the arms differ only in description
```

**"The script does not separate partial telemetry corruption from absent telemetry."** Also true:
an unparseable line was skipped with `continue`, so a run whose stream was partly corrupt reported
`measured` with a clean-looking zero. `tools/skill-activation.sh` gains a third state,
`PARTIAL-telemetry-damaged`, **exit 4**, counting `malformed_lines` and `damaged_records`
separately; a damaged stream yields a **lower bound**, never a zero. Absence still outranks damage.
An activation carrying no `skill.source` is explicitly **not** damage — it parses, and it has its
own bucket. `tools/verify-skill-activation.sh`: **21 cases, 21 passed** (was 15). The real 31 MB
stream reports `malformed_lines: 0, damaged_records: 0`, so nothing already on record moves.

**The banner above said all three had to be resolved before this could run. All three are, and
each is closed by executing code with a fixture set that proves it rejects.** The §4a gate's
verdict on the *file* stands as recorded — three rounds, three `REJECT`s, not a pass — and is
not retroactively upgraded.

#### 5. What is still not known, and is not predicted

`skill.source` for a project-scope skill is **still unknown** — no project-scope skill has ever
been recorded on this instrument. Prediction 2 has no denominator until the preflight pins it,
and the preflight below is the thing that pins it. Until then no number in
`skill-activation.sh` means *"my skill loaded"*, and this experiment must not pretend one does.

Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-04

## Controlled variables

- [x] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` at `0448643`, the same as B3
- [x] task + revision — **BE-003 confirm-shipment, unchanged.** No new task; §7 reserves that for the author
- [x] harness + version — one `claude` CLI version for all 15 runs, recorded in *Sanity checks*
- [x] model — **`claude-haiku-4-5-20251001`**, exact id, the controlled variable of the whole track
- [x] permissions / permission mode — identical across arms, runner defaults
- [x] environment: hooks, plugins, skills, MCP servers, settings sources — `ISOLATE_USER_SETTINGS=1` on every run; **verified by observing `hook_execution_start = 0` per run in telemetry, not by trusting the flag**
- [x] runner commit — one commit for all 15 runs, recorded in *Sanity checks*

**The one thing that is deliberately *not* controlled** is bundled-skill activation: Claude Code
ships its own skills and may load one on any arm. That is why the outcome counts project-scope
activations only, and why `skill.source` is read on every event rather than assumed.

## Runs

Repetitions per arm: **5** · three arms, **15 runs** + 2 preflight runs · Total budget: ~**$2.60**
at B3's observed $0.152/run.

Arms are **interleaved** (A, B, C, A, B, C, …) so drift in the machine or the hour lands on all
three. That practice has already saved one experiment in this project.

*One run is a story. Five is a hint. Ten is the minimum for a decision.* **This experiment is at
five, and says so in every claim it makes.** Five is chosen because the predicted effect is
near-total presence-versus-absence rather than a shift in a distribution — see the MDE, which
states exactly what five can and cannot resolve.

## Minimum detectable effect

**Derived before any threshold above was written, from the Fisher exact test on the registered
`n`, not from the predictions.** There is no measured baseline for skill activation on this
instrument — the outcome has never been recorded for a project-scope skill — so the MDE is
derived from the *test's* resolving power at `n = 5`, and the absence of a baseline is itself
registered as a limitation.

| Outcome | measured spread it comes from | MDE at the registered `n` | registered before the run? |
|---|---|---|---|
| primary: installed-scope activation rate, matched vs misdescribed | **none exists** — never measured here. Derived from Fisher exact at n=5+5 | only **near-total separation resolves**: 5/5 vs 0/5 → p = 0.0079; 4/5 vs 0/5 → p = 0.048; **4/5 vs 1/5 → p = 0.206, NOT detectable** | yes |
| primary, one-arm form: matched arm ≥ 4 of 5 | binomial | if the true rate were 0.2, observing ≥4 of 5 has p = 0.0067 — so a *pass* is informative; a 3-of-5 result is **neither** a pass nor a refutation | yes |
| secondary: `skillsHash` null rate | 0 of 228 runs on this instrument have ever carried a non-null `skillsHash` | any single non-null value refutes prediction 4; **n=1 suffices** because it is an existence claim | yes |

**Derive it against the *interval* of the baseline, not the point estimate** — E-003's lesson.
Here there is no baseline interval to derive against, which is the honest statement of the
problem: **at n=5 per arm this design can only distinguish "always" from "never".** Any middling
result (2–3 of 5 in either treated arm) lands inside the MDE and will be recorded as **NOT
DETECTABLE at this n**, with the `n` that would resolve it computed and registered as follow-up —
not as a refutation, and not as a hint dressed up as a finding.

## Deterministic evaluation

`agent-observatory-benchmarks/tasks/BE-003-confirm-shipment/evaluator.sh` at evaluator version
`1.0.0`, unchanged. `./tools/check-run-gate.sh` admits a run to scoring only on the evaluator's
recorded pass. Rubric `benchmark/rubrics/backend-quality.yaml` at `396e1799eb2b`, unchanged, used
for the **quality co-variate only** — the primary outcome of this experiment is not a rubric
score.

## Exclusions

Registered now, not after seeing the data:

- Infrastructure failures (F13/F15), permission blocks and quota exhaustion are excluded from
  every arm and reported with their count.
- A run whose telemetry does not join to `observatory.run.id` is excluded from the **activation**
  outcome and reported; it is *not* excluded from cost or quality.
- Runs spanning a machine sleep have their **duration** excluded, not the run.
- Bundled-skill activations (`skill.source = bundled`) are excluded from the outcome by
  definition, in every arm equally.

## Decision rule

Registered before data. Rows are exhaustive over (matched arm loads?) × (arms separate?), and
**cost is a separate row, never a second condition on a failure row** — E-003's repaired defect.

**CORRECTED 2026-09-04, before any data, after the §4a gate returned REJECT.** The first version
fired `CONFIRM` on *"matched ≥ 4/5 and matched − misdescribed ≥ 3"*, which **contradicted this
experiment's own MDE table**: a 4-vs-1 result has a raw difference of 3 and a Fisher `p = 0.206`,
so one reader would have recorded `CONFIRM` and another `NOT DETECTABLE` from identical data. A
raw difference is the wrong variable — the same difference is decidable or not depending on where
it sits. **The rule is now stated in the test, and the decidable cells are enumerated.** All
two-sided Fisher, 5 per arm:

| matched vs misdescribed | 0/5 | 1/5 | 2/5 | 3/5 |
|---|---|---|---|---|
| **5/5** | **0.0079** ✓ | **0.0476** ✓ | 0.1667 | 0.4444 |
| **4/5** | **0.0476** ✓ | 0.2063 | 0.5238 | 1.0000 |
| **3/5** | 0.1667 | 0.5238 | 1.0000 | 1.0000 |

**Exactly three cells reach `p < 0.05`: (5,0), (5,1), (4,0).** Everything else is not detectable
at this `n`, and the rule below says so.

| # | Condition | Verdict |
|---|---|---|
| 0 | **misdescribed > matched** by any margin | **DIRECTION REVERSED — record it, do not classify it below.** Every row beneath assumes the hypothesis' direction. Report the pair and its `p`, and stop. *Added 2026-09-04: the §4a gate found rows 1–4 enumerate only matched ≥ misdescribed, so a reverse result could be classified two ways on identical data.* |
| 1 | The pair reaches **Fisher `p < 0.05`** *in the predicted direction* — (matched, misdescribed) is (5,0), (5,1) or (4,0) | **CONFIRM** — the description selects, and it is measured here |
| 2 | Matched ≥ 4/5, **and** the pair does **not** reach `p < 0.05` | **PARTIAL** — the skill loads, and this `n` cannot show the description is what selected it. Register the `n` that could |
| 3 | Matched 2–3 of 5 | **NOT DETECTABLE at n=5**, whatever the misdescribed arm does. Register the `n` that would resolve it |
| 4 | Matched ≤ 1/5 | **prediction 1 REFUTED as a one-arm claim** — if the true rate were 0.8, ≤1 of 5 has p = 0.0067. **No attribution follows**: by the amendment above, a miss on this delivery path is a joint failure of *description matched* and *agent reached `sample-service/` in time*, and this design cannot separate them. Do **not** record it as "the vendors' mechanism does not reproduce" |
| 5 | Any arm records 0 activations *and* zero events of any kind for the run | **VOID that run** as an instrument failure, not a result; re-run it under a new id. `tools/skill-activation.sh` exits 3 on exactly this and reports `null`, never `0` |
| Cost | separate row, applied to whichever verdict above is reached | if the skill arm costs > +25 % against control, that is reported **beside** the verdict and does not change it. **A skill that works and is expensive is a different decision from one that does not work** |

**The instrument rows are decided independently of the above**, because they are existence claims
about the harness rather than about the agent:

| Condition | Verdict |
|---|---|
| `skillsHash` null on all 10 treated runs | prediction 4 **holds**: the field is blind to a Claude project skill, and it is a provenance claim that cannot see its own subject. Raise to the author |
| `skillsHash` non-null on any treated run | prediction 4 **refuted**; record the value and the path it hashed |
| `skill.name` = `custom_skill` on project-scope events | prediction 5 holds |
| `skill.name` = anything else | prediction 5 **refuted**; record the actual value. This is the prediction most likely to be wrong and it costs nothing to be wrong about |

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

## Results

## Which predictions held

## Failure analysis

## Sanity checks

- [ ] prediction commit timestamp precedes the first run's `startedAt` — both read from git and the API, not from prose
- [ ] the two `SKILL.md` **bodies** are byte-identical; only the frontmatter differs
- [ ] `hook_execution_start = 0` on all 15 runs
- [ ] `runtime.model`, `evaluatorVersion`, benchmark sha and rubric sha identical across all 15
- [ ] one harness version and one runner commit across all 15

## Decision

## Follow-up
