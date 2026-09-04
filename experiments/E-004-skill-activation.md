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

> **LIMIT OF WHAT THIS DESIGN CAN ESTABLISH — added 2026-09-04 after the §4a gate found it at
> 2/2, and it constrains how the result may be read.** The contrast identifies that **changing
> the description changes activation**. It does **not** identify that the body plays no part: a
> selector reading *both*, in which an unrelated description vetoes an otherwise matching body,
> produces exactly the same 5-of-5 against 0-of-5. The exclusive *"not the body"* half of this
> hypothesis is **not identifiable from this design** and must not be reported as measured.

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

   > **PINNED 2026-09-04T10:40Z, before the batch: `skill.source` is `projectSettings`.** The
   > outcome of this experiment is the count of `skill_activated` events carrying that exact
   > value. Every other source is excluded by name. See *Preflight result* below.
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

> **AMENDMENT 2026-09-04, from `findings/track-b-validation-2026-09-04-3.md` correction (b) —
> that sentence is ASSERTED, not recorded, and its layer is L3.** Apply the layer rule in order:
> can the bad value still be written down? Yes — a run could be launched without the flag and
> nothing would notice. Does something execute and reject it? **No, not for arm A.** The runner's
> refusal (`run-agent.sh` §5, proved by `runner/verify-skill-delivery.sh` check A) fires only
> when a customization installs a `SKILL.md`; **arm A installs no customization at all**, so on
> the control arm that guard is unreachable by construction. And the run record's `runtime` block
> still lacks the V6 surface fields (`userSettingsIsolated`, `shimsStripped`, `surface` are
> **absent, not null** — carried correction 2 in `TRACK-B-STATE.md`), so the resolved flag set is
> not on the record either. Therefore: **the flag was passed on all three arms by the same
> `make` invocation, and for arm A that is my word, at L3.** It is not load-bearing for the
> result — arm A's prediction is a zero, and a control that was accidentally *denied* skills
> would produce the same zero it produced — but it must not be read as a measured control.
> The cheap L2, for whoever builds the next skill arm: put a hash of the resolved `CLAUDE_ARGS`
> on the run record, or restore the V6 `runtime.surface` fields. Carried into
> `TRACK-B-STATE.md` as a note against stop 9, which is the next stop that passes flags per arm.
> `Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

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
`tools/verify-overlay-parity-checker.sh`: **13 cases, 13 passed** (8 when first written; the §4a gate found five more). On the registered arms:

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
own bucket. `tools/verify-skill-activation.sh`: **28 cases, 28 passed** (was 15 when the halt was written; 21 after the damage state, then 24 and 28 as the §4a gate found more). The real 31 MB
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

### PREFLIGHT RESULT, 2026-09-04T10:35–10:40Z — the denominator prediction 2 was missing is now pinned

**Registered before the batch, which has not run.** Two runs, one per treated arm, key
`EXP-P3-PREFLIGHT2`, `--enable-skills` on both, overlays `skill-v0.2{,-misdescribed}` at the
worktree root. Preflight runs carry a preflight key and **can never join an `n`.**

| run | arm | `activations_by_source` | `skill_names` | `invocation_triggers` | status |
|---|---|---|---|---|---|
| `46ffad94` | matched | **`projectSettings=1`** | `custom_skill=1` | `claude-proactive=1` | measured |
| `b9f9f3b9` | misdescribed | `-` | `-` | `-` | measured |

**`skill.source` for a project-scope skill is the literal string `projectSettings`.** No
project-scope skill had ever been recorded on this instrument; this is the first, and it is the
value prediction 2 said had to be pinned before any batch is read. **Prediction 2 is now
readable**: the control arm's outcome is `projectSettings` activations, and every other bucket —
`bundled`, `plugin`, source-less, and any future source — is excluded by name rather than by an
open *everything-else-is-mine* rule.

**Three things follow, and only the first is a delivery fact:**

1. **Delivery is proved, by the strongest available evidence: the model loaded the skill.** Not
   that the file was installed, committed or hashed — that it was *used*. The trigger is
   `claude-proactive`, which is implicit selection from the description, the exact mechanism this
   experiment tests.
2. **Prediction 5 holds at `n = 1`.** It predicted `skill.name` would be redacted to the literal
   `custom_skill` for a project-scope skill, extrapolating across a scope boundary from `plugin`,
   and called itself the one most likely to be wrong. It is not wrong. `n = 1`, stated as nothing
   more.
3. **The misdescribed arm recorded zero.** That is `n = 1`, it is the direction prediction 3
   predicts, and **it is not evidence for it.** One run per arm cannot separate "the description
   did not match" from "this run happened not to load it". That is what the batch is for.

**`customization.skillsHash` is `null` on both treated runs** — prediction 4's mechanism,
observed again. It is why the delivery proof above is telemetry and not a hash.

Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-04, before the batch.

### The preflight found a second instrument defect, and this one would have voided the batch silently

**Registered before the batch.** Run `46ffad94` — the matched arm, the run that proved delivery —
was recorded by the runner as:

```
!! CONTAMINATED: a plugin skill executed 1× despite --disable-slash-commands (harness bug #13)
   recorded as F15 (infrastructure) … EXCLUDE this run from comparisons
```

Its telemetry says `plugin_activations: 0` and `activations_by_source: projectSettings=1`. **The
skill it loaded was the one this experiment installed.** The runner counted `Skill` *tool calls*
and reported every one of them as a leaked plugin skill.

**What that would have done to this experiment, unwatched:** every run of the matched arm loads a
skill, so every run of the matched arm would have been marked infrastructure failure and excluded.
The batch would have finished with arm B at `n = 0`, arms A and C intact, and a report saying the
treatment arm produced no usable runs. **A guard that excludes the treatment arm does not look
like a bug. It looks like a null result.**

**And it is the same shape, for the fourth time in this stop.** `tools/skill-activation.sh` had an
open *everything-else-is-mine* bucket three times, each fix naming one more scope. This is the
mirror image — *every skill is theirs* — and it lands on the **treatment** arm rather than the
control. The category was wrong in both directions.

The rule was correct when it was written: with `--disable-slash-commands` unconditional, nothing
could legitimately call a skill, so any call was a leak. Adding `--enable-skills` falsified its
premise, and nothing in the harness noticed.

**Fixed by source, in `agent-observatory/runner/lib/classify-skill-contamination.sh`**, with
16 fixtures (`runner/verify-skill-contamination.sh`, 16 passed):

| skills | source | verdict |
|---|---|---|
| disabled | any | **contaminated** — unchanged, and this is every run recorded before 2026-09-04 |
| enabled | `bundled` | clean — Claude Code ships its own, equally in every arm |
| enabled | `projectSettings` | clean **only if this run installed a skill**; on an arm that installed none it is the control being contaminated |
| enabled | anything else (`plugin`, `user`, `enterprise`, unseen) | **contaminated** |

It is an **allowlist**, so a source nobody has seen yet fails outside it rather than into it.

**Run `46ffad94`'s F15 record is left exactly as it stands.** It is a true record of what the
harness decided at the time, it is a preflight run that can never join an `n`, and rewriting it
would destroy the evidence for this finding. The batch runs under the fixed guard.

Recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-04, before the batch.

## Controlled variables

- [x] starting commit / benchmark revision SHA — `agent-observatory-benchmarks` at `0448643`, the same as B3
- [x] task + revision — **BE-003 confirm-shipment, unchanged.** No new task; §7 reserves that for the author
- [x] harness + version — one `claude` CLI version for all 15 runs, recorded in *Sanity checks*
- [x] model — **`claude-haiku-4-5-20251001`**, exact id, the controlled variable of the whole track
- [x] permissions / permission mode — identical across arms, runner defaults
- [x] environment: hooks, plugins, skills, MCP servers, settings sources — `ISOLATE_USER_SETTINGS=1` on every run; **verified by observing `hook_execution_start = 0` per run in telemetry, not by trusting the flag.** **CORRECTED 2026-09-04 after the §4a gate, which found it at 2/2: a zero hook count is evidence about HOOKS and about nothing else on that list.** A user-scope setting or MCP server defining no hook would leak while this check stayed green. Separately evidenced: **plugin skills**, by `plugin_activations` = 0 across all 28 isolated runs and by `/gsd-help` returning `Unknown command` under `--setting-sources project`. **Settings sources and MCP servers rest on the flags alone and are therefore L3 here**
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

**AMENDED 2026-09-04 after the §4a gate, at 2/2 — two dispositions this list did not name.** Both
are recorded as gaps rather than applied retroactively: **no run in this batch hit either**, and
all 15 report `status: measured` with `malformed_lines: 0` and `damaged_records: 0`.

- **`PARTIAL-telemetry-damaged` (exit 4) had no registered disposition.** Its count is a *lower
  bound*, so a `0` from a damaged stream must not be entered as a real zero. The rule for any
  future batch: **a `PARTIAL` run is excluded from the activation outcome and reported with its
  count**, exactly as a non-joining run is.
- **A permission block caused by the treatment itself is not infrastructure.** If an activated
  skill asks for a command needing approval and the run dies, that is downstream of the treatment,
  and excluding it would delete the treatment's own effect. This list did not separate those from
  exogenous blocks. Unexercised here, registered for the next batch.

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

`EXP-P3-SKILL-DESC`, 15 runs, interleaved A/B/C × 5, 2026-09-04T11:03–11:34Z. One further run,
`62deb6c5` (arm A, 10:50Z), died mid-run on a claude session limit — **F13, exit 12, 2 tool
calls — and is a registered exclusion**, not a data point. The batch was re-driven to a full 15
after the limit cleared.

Outcome = count of `claude_code.skill_activated` events carrying **`skill.source =
projectSettings`**, the value pinned by the preflight before any of this was read.

| run | arm | activations | source | trigger | gate | cost | tool calls |
|---|---|---|---|---|---|---|---|
| `d671d1b7` | A control | 0 | — | — | pass | 0.1485 | 18 |
| `7b4428be` | A control | 0 | — | — | pass | 0.1751 | 21 |
| `394ee79a` | A control | 0 | — | — | pass | 0.1123 | 15 |
| `ff7bffed` | A control | 0 | — | — | pass | 0.1710 | 21 |
| `c51a7a0c` | A control | 0 | — | — | pass | 0.1283 | 14 |
| `d6aec246` | **B matched** | **1** | `projectSettings` | `claude-proactive` | pass | 0.1283 | 19 |
| `45a70775` | **B matched** | **1** | `projectSettings` | `claude-proactive` | pass | 0.1219 | 17 |
| `2cf0c720` | **B matched** | **1** | `projectSettings` | `claude-proactive` | pass | 0.2113 | 27 |
| `33a4090d` | **B matched** | **1** | `projectSettings` | **`nested-skill`** ‖ | pass | 0.1373 | 17 |
| `8998ef3b` | **B matched** | **1** | `projectSettings` | **`nested-skill`** ‖ | pass | 0.1374 | 16 |
| `95f42409` | C misdescribed | 0 | — | — | pass | 0.1522 | 18 |
| `fc3665a7` | C misdescribed | 0 | — | — | pass | 0.1272 | 14 |
| `77c60831` | C misdescribed | 0 | — | — | pass | 0.1111 | 13 |
| `cc41f3f0` | C misdescribed | 0 | — | — | pass | 0.1545 | 19 |
| `946144c3` | C misdescribed | 0 | — | — | pass | 0.1458 | 18 |

Every run reports `status: measured`, `malformed_lines: 0`, `damaged_records: 0`. **No `bundled`
and no `plugin` activation occurred on any arm**, so no exclusion was ever exercised. `check-run-gate.sh`
returns 0 on all 15 and refuses `62deb6c5` with `REFUSED: the evaluator failed this run — passed=false
exitCode=12 class=F13`.

**‖ AMENDMENT 2026-09-04 — the trigger column was wrong on two of the five matched runs, and it
is the column that names the mechanism.** Sources: `findings/track-b-validation-2026-09-04-6.md`,
re-derived independently by `-7.md`, `-8.md` and `-9.md`. The two rows above read
`claude-proactive` until today; the telemetry says **`nested-skill`**, and so does this
repository's own instrument — `./tools/skill-activation.sh <events.jsonl> 33a4090d-…` prints
`invocation_triggers: nested-skill=1`. Corrected in place above. **Four passes on two model
families found the same thing before this experiment's author did**, which is itself the useful
part: the value was transcribed once and then re-read from the transcription.

**What does and does not move.** The registered outcome — an activation attributable to the
project scope this experiment installed — is **5 / 0 / 0, `p = 0.00794`, unchanged**. The
*mechanism* sentence narrows. This file defines `claude-proactive` as implicit selection from the
description. Counting only that trigger as description-driven selection gives 3 of 5 against
0 of 5 (**`p = 0.16667`**) or 3 of 5 against the pooled 0 of 10 untreated (**`p = 0.02198`**).
**The claim that survives at `p = 0.0079` on every reading is the narrower one: a matched
description produces an activation and a mismatched one does not.** The hypothesis as titled —
*the description decides whether a skill loads* — is ahead of its evidence on 2 of 5 runs, and
**this amendment does not repair that by reinterpreting the data after the fact**. It records the
gap and registers the question.

**Registered follow-up, not answered here: what is `nested-skill` emitted for, and does it
consult the description?** It needs no new arm and no new runs. The thirteen `stream-json`
transcripts from the flag probe are now committed at
[`evidence/p03/flagprobe/`](../evidence/p03/flagprobe/) and the kept telemetry for `33a4090d`
and `8998ef3b` is on disk. Settle it before B6 opens at stop 13, because B6's gate compares runs
with and without a specialist skill and inherits whatever "with a skill" turns out to mean.

**AMENDMENT 2026-09-04 — "the runner did not change during the batch" is true of the run path,
not of `runner/`.** From `-9.md` correction 8.D, re-derived here against the observatory repo.
Two commits touch `runner/` in the batch window: **`487fe8e` at 11:07:24Z**, while runs 3–15 were
in flight, and **`90c8ac6` at 11:38:49Z**. Neither moved the run path under any run.
`git show --name-only 487fe8e` is exactly one file, `runner/verify-skill-delivery.sh` — a fixture
verifier **no run executes**. `90c8ac6` *does* touch `run-agent.sh`, but it landed 11:38:49Z and
the last run started 11:32:47Z and had finished; it is after the batch, not inside it. The last
commit to `run-agent.sh` or `runner/lib/` **before** the first run is **`f332681` at 10:46:08Z**.
**The registered variable did not move.** The sentence should say *the run path*, because a
reader who runs `git log -- runner/` across the window finds two commits while the text tells
them there are none.

`Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`

## Hand re-read — written and committed BEFORE the scorer ran

§4 step 7: *read the sheets only after you have written your own expected score for at least one
run by hand from the kept worktree.* §5: *at least one scored cell per step is re-read by hand and
the hand reading is written down next to the sheet's value.*

**Run `45a70775-e32e-49bf-b57f-40372f4085a5`, arm B (matched), category `maintainability`,
rubric `benchmark/rubrics/backend-quality.yaml` at sha `396e1799eb2b`.**

Read from the kept worktree at `$TMPDIR/observatory-run-45a70775-…`, `git diff HEAD` against the
setup commit.

```kotlin
// sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt
val updated = when (shipment.status) {
    ShipmentStatus.CREATED   -> shipment.copy(status = ShipmentStatus.CONFIRMED)
    ShipmentStatus.CONFIRMED -> shipment
    ShipmentStatus.CANCELLED -> throw ConflictException(
        ErrorCode.SHIPMENT_CANNOT_CONFIRM_CANCELLED,
        "Cannot confirm a cancelled shipment",
    )
}

return repository.save(updated)
```

**My hand score: `maintainability = 2`.** Anchor 2 asks for one `when (shipment.status)` in
EXPRESSION position carrying no `else`, and for the construct that consumes its value to be
cited. All three are present: the `when` is assigned to `val updated`, that value is consumed by
`repository.save(updated)`, and there is no `else` branch. I did not count branches against
`ShipmentStatus` — the rubric explicitly forbids it, because that enum is not among the
attachments.

**A second cell I am deliberately NOT calling, and why.** `change-focus` is ambiguous on this
submission and the ambiguity is already on record in `agent-learning-lab/CLAUDE.md`: the diff
adds one `ErrorCode` constant in a second attached file, which is neither a method the ticket left
alone nor an import, so anchor 2's clause list does not reach it and anchor 1's illustration does
not either. **1 or 2 are both defensible readings and that is a rubric defect, not a scorer
defect.** Recorded here rather than resolved, because moving a rubric sha mid-experiment is a §6
violation.

Written by Opus 5 (claude-opus-5), autonomous, 2026-09-04, before any sheet for this run existed.

## Results

**Matched 5 of 5. Misdescribed 0 of 5. Control 0 of 5.**

Two-sided Fisher, matched against misdescribed: **p = 0.0079**. That is the `(5,0)` cell, one of
exactly three the MDE table registered as reaching `p < 0.05` at this `n`.

Cost, median and range, `n = 5` per arm — reported **beside** the verdict, never as a condition
on it:

| arm | median $/run | range | tool calls, median |
|---|---|---|---|
| A control | 0.1485 | 0.1123 – 0.1751 | 18 |
| B matched | 0.1373 | 0.1219 – 0.2113 | 17 |
| C misdescribed | 0.1458 | 0.1111 – 0.1545 | 18 |

Matched against control: **−7.6 %**. The registered cost row fires at **> +25 %**; it does not
fire. **A −7.6 % median difference at `n = 5` with these ranges is not a finding — the arms
overlap almost entirely — and it is reported only to show the cost row was evaluated.**

### Quality co-variate

Scored with the registered scorer, `codex-score.sh` against `benchmark/rubrics/backend-quality.yaml`
at sha `396e1799eb2b`. **15 of 15 sheets, four categories each, zero nulls.** The primary outcome
of this experiment is not a rubric score; these are reported as a co-variate.

| arm | total, median | range | architecture | maintainability | test-quality | change-focus |
|---|---|---|---|---|---|---|
| A control | 55.0 | 55.0 – 80.0 | 2,2,2,2,2 | **2,1,0,0,0** | 1,1,1,1,1 | 1,1,1,1,1 |
| B matched | **80.0** | 80.0 – 80.0 | 2,2,2,2,2 | **2,2,2,2,2** | 1,1,1,1,1 | 1,1,1,1,1 |
| C misdescribed | **80.0** | 55.0 – 80.0 | 2,2,2,2,2 | **2,2,2,2,0** | 1,1,1,1,1 | 1,1,1,1,1 |

Three of the four categories are **constant across all fifteen runs**. The entire spread is
`maintainability`, whose anchor 2 — *one `when (shipment.status)` in expression position, no
`else`* — is word-for-word the first bullet of the skill body.

#### The thing this experiment did not predict, and it points at its own control

**Arm C scores like arm B and unlike arm A — and arm C never activated the skill.** Counting
"scored 2 on maintainability":

| comparison | counts | two-sided Fisher |
|---|---|---|
| control vs matched | 1/5 vs 5/5 | **p = 0.048** |
| control vs misdescribed | 1/5 vs 4/5 | p = 0.206 |
| matched vs misdescribed | 5/5 vs 4/5 | p = 1.0 |
| control vs both treated arms pooled | 1/5 vs 9/10 | **p = 0.017** |

**THIS IS NOT A RESULT, AND IT IS NOT ALLOWED TO BECOME ONE HERE.** `maintainability` was never a
registered outcome of E-004; the registered outcome is the activation count. An unregistered
outcome that reaches `p < 0.05` after the data is in is a hypothesis, and this project already
has one on the shelf for exactly this reason — B3's test-writing asymmetry (4 of 10 vs 0 of 10,
p = 0.087), which is still recorded as *"never a registered outcome, so it is not a result"*.
This gets the same treatment.

**But it must be written down, because if it is real it is a caveat on this experiment's own
design.** Two mechanisms would produce it and this design cannot separate them:

1. **The file was read, not selected.** Arm C's `SKILL.md` sits in the worktree and is a tracked
   file. An agent exploring the repository can open it and follow its conventions with **no
   activation event at all**. This is not speculative — the flag probe measured it directly: of
   six runs with skills disabled, **one emitted the skill body's marker after reading `SKILL.md`
   as an ordinary file**, which is why the detector for this experiment is a `Skill` tool_use and
   not a text marker.
2. **The two treated arms differ from the control by something other than the skill** — most
   obviously that arm A has no `.claude/` directory at all, so its repository is not
   byte-identical to the treated arms' at the setup commit.

**Both mean the same thing for any behavioural claim: arm C is a clean control for ACTIVATION and
is not a clean control for BEHAVIOUR.** The activation result is untouched by this — activation is
counted from telemetry and arm C recorded zero on 5 of 5 — but nothing about *quality* may be
attributed to skill selection on this evidence.

**Why it is not settled here.** It cannot be settled from what is on disk: the observatory's
`tool_result` events carry `tool_name` but no file path, and the kept agent logs hold only the
final message. Settling it needs **a fourth arm** — the same file present where the runtime cannot
register it — and §7 reserves a new arm for the author. Raised in HANDOFF rather than run.

## Which predictions held

**All five.** That is an uncomfortable result in a project whose house rule is to disbelieve its
own headline, and the *Failure analysis* below is written against it rather than around it.

| # | prediction | outcome |
|---|---|---|
| 1 | [one-arm] matched loads on **≥ 4 of 5** | **HELD — 5 of 5.** If the true rate were 0.2, ≥ 4 of 5 has p = 0.0067 |
| 2 | [structural] control records **0** installed-scope activations on 5 of 5 | **HELD — 0 of 5**, and readable at all only because the preflight pinned `projectSettings` first |
| 3 | [between-arm] misdescribed loads **≤ 1 of 5**, at least 3 fewer than matched | **HELD — 0 of 5**, a difference of 5, p = 0.0079 |
| 4 | [instrument] `customization.skillsHash` is `null` on 5 of 5 in **both** treated arms | **HELD — null on all 10**, and on all five control runs too. The field hashes `.github/skills.md`, a path no Claude Code skill uses |
| 5 | [instrument, low confidence — *"the one most likely to be wrong"*] `skill.name` is redacted to the literal `custom_skill` for a project-scope skill | **HELD — `custom_skill` on 5 of 5.** It extrapolated across a scope boundary from `plugin` to `project` and it was right |

## Failure analysis

**What would have to be true for this result to be wrong, and what was done about each.**

1. **The misdescribed skill was never delivered, so its zero measures nothing.** This is the
   circularity the §4a gate found and it is the only threat that would void the headline. It is
   closed **by explicit invocation, which does not consult the description**: in each arm-C kept
   worktree, `claude … -p "/shipment-service-conventions"` with the runner's own flags. Result
   across the six arm-C worktrees probed (five batch runs plus preflight `b9f9f3b9`): **four
   loaded the skill and quoted its body, two returned an off-topic answer, and `Unknown command`
   came back zero times.**

   **The observable that separates the three outcomes, since the §4a gate found it undefined at
   2/2:** `Unknown command: /shipment-service-conventions` is a **refusal** — the runtime says the
   skill is not registered. A reply quoting the body (*"exhaustive `when`"*, *"no `else` branch"*)
   is a **positive load**. Anything else is **inconclusive**: the model answered a different
   question, which happened in both cases in worktrees the agent had already modified, where it
   responded to the pending change instead.

   **What that buys, stated at its weakest.** Delivery is *positively* demonstrated on **4 of 6**
   arm-C worktrees, including two of the five batch runs. It is not demonstrated on the other two,
   and it is **refuted on none**. The registered `(5,0)` result is computed over all five arm-C
   runs; **a reader who insists on positive delivery proof per run would compute it over the two
   proven ones, giving `(5,0)` against `n = 2` — still in the predicted direction, no longer at
   `p < 0.05`.** That reading is written here rather than argued away, and the cheap repair is
   named in *Follow-up*: probe every worktree before it is reaped, not a sample.
2. **Something other than the description differed between B and C.** Closed at L1/L2:
   `shasum` of the bodies below the frontmatter is `d10a2c3988be520e` on both, and
   `tools/check-overlay-parity.sh` executes the whole comparison — same path set, symlinks
   compared as symlinks, every non-`SKILL.md` file byte-identical, frontmatter compared as raw
   lines with only `description` declared. It exits 2 on any undeclared difference and 3 if the
   two arms are identical.
3. **A registered variable moved.** Checked from the run records, not from flags: one model
   (`claude-haiku-4-5-20251001`) across all 16, one evaluator (`1.0.0`), one benchmark (`BE-003`
   at `0448643`, and the benchmarks repository has an empty `git status`), one rubric sha
   (`396e1799eb2b`).
4. **The harness attributed someone else's skill to the treatment.** No `bundled` and no `plugin`
   activation occurred anywhere in the batch, so the question never arose — but the machinery
   that would have caught it is in place and has fixtures: `skill-activation.sh` counts per
   source and labels none of them "mine", and `classify-skill-contamination.sh` refuses any
   source outside its allowlist.

**And the limits, stated as limits.**

- **`n = 5` per arm, one task, one model, one runtime.** Everything here is true of these runs.
- **The two descriptions are at maximal semantic distance** — a Kotlin Spring shipment backend
  against CSS keyframe animations. This shows the description selects **when the contrast is
  total.** It says nothing about how close two descriptions can get before selection degrades,
  and that is the interesting question this design cannot reach.
- **The instrument cannot tell which project skill loaded, only that one did.** `skill.name` is
  redacted to `custom_skill` — prediction 5, held. With one installed skill that is unambiguous.
  **With two, this outcome would not be measurable at all**, and any follow-up installing more
  than one skill must solve that before it runs.
- **One runtime.** All three vendors claim the description selects; this measures Claude Code.
  Codex is untested here and no claim is made about a Copilot-run agent (Decision G).

## Sanity checks

- [x] **prediction commit timestamp precedes the first run's `startedAt`** — read from git and the
      API, not from prose. The design was first registered at `5d14182` (07:03:58Z); the corrected
      design, after the flag finding, at **`f8ff084` (10:34:48Z)**; the pinned `skill.source` at
      `7cf5adb` (10:40:29Z); the contamination finding at `35abde7` (10:46:37Z). **The first batch
      run started 11:03:44Z.** Every one of those precedes it, the closest by 17 minutes.
      Reachable from `main` after this stop's PR because stop branches now merge with a merge
      commit, never a squash (author decision 4, 2026-09-04).
- [x] **the two `SKILL.md` bodies are byte-identical; only the frontmatter differs** — `sha256`
      of the body below the frontmatter is `d10a2c3988be520e` on both arms. Asserted by executing
      code, `tools/check-overlay-parity.sh`, not by a hash pasted into a table.
- [x] **`hook_execution_start = 0` on all 15 runs** — `ISOLATE_USER_SETTINGS=1` on every run, and
      isolation observed from telemetry rather than from the flag. The §0a preflight established
      the join is not blind by finding a positive control (run `d312ab16`, 44 hook records).
- [x] **`runtime.model`, `evaluatorVersion`, benchmark sha and rubric sha identical across all 15**
      — `claude-haiku-4-5-20251001`, `1.0.0`, `BE-003` at `0448643`, `396e1799eb2b`. The
      benchmarks repository was never touched: `git status --porcelain` is empty.
- [x] **one harness version and one runner commit across all 15** — Claude Code `2.1.260`; the
      runner did not change during the batch. The runner changes for this stop all landed
      **before** the first batch run, and the one deferred fix
      (`classify-skill-contamination.sh`) was held precisely because a batch was in flight.

> **AMENDMENT 2026-09-04, from `findings/track-b-validation-2026-09-04-3.md` correction (a) —
> the harness version moved between stop 6 and stop 8, and this file did not say so.** The bullet
> above is true within the batch and was silent across stops. B3/E-003 and E-002 ran on Claude
> Code **`2.1.259`**; every run of `EXP-P3-SKILL-DESC` and the 07:08Z
> preflight ran on **`2.1.260`**. `grep 2.1.259` returned nothing in this file or in
> `phases/03-skills/README.md`, which is the defect: the move was real and undisclosed.
> **This is the third harness move in the track**, after `2.1.251 → 2.1.259` (B2 → B3, disclosed
> in [`E-003`](E-003-instructions-v0.1.md) and `phases/b03-global-instructions/README.md`) and
> obs#72's runner changes (disclosed in the harness-changes table above). It does **not** change
> this experiment's decision: all 15 runs and all three arms are on one version, so the
> within-batch comparison that produced `p = 0.0079` is untouched. It **does** constrain any
> later step that compares a stop-8 number against a B3 or B2 number without a concurrent
> control, exactly as `2.1.251 → 2.1.259` did for B3. Nothing above is rewritten; this note is
> the disclosure.
> `Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`
>
> **SECOND AMENDMENT to the note above, 2026-09-04, from `-9.md` correction 8.A.** As first
> written this note listed *"every run of `EXP-P3-SKILL-DESC`, `EXP-P3-NESTED-PROBE` and the
> 07:08Z preflight"*. **`EXP-P3-NESTED-PROBE` has no runs on the instrument.** The API holds three
> keys for this stop — `EXP-P3-PREFLIGHT`, `EXP-P3-PREFLIGHT2`, `EXP-P3-SKILL-DESC` — and no run
> under that name, so the sentence cited a harness version for runs that do not exist under the
> id it gave. The key has become a name for the **scratch-repository probe**, which is where
> author decision 1 was actually answered. Struck from the sentence above.
>
> **The deviation behind it is recorded in `phases/03-skills/README.md` rather than left
> implicit.** Author decision 1 asked for *"5 nested-path runs with the REQUIRED description
> under a new experiment key"* on the observatory; what ran was a 12-call matrix in a scratch
> repository at **`n = 3` per cell**, off the observatory, with **no run record** — a tenth of the
> cost, and it did answer the question. Disclosed inside the flag-probe evidence file at the
> time; not disclosed in any workbook row until now. **A citation to an experiment key that
> returns nothing is the same failure shape this stop found four times in its own instruments** —
> a reference that looks checkable and is not — and it appeared inside an amendment written to
> fix a disclosure gap.
> `Amended by Opus 5 (claude-opus-5), autonomous, 2026-09-04`
- [x] **the treated arms were not distinguished by `customization.*Hash`** — all five hashes are
      `null` on all 15 runs, control and treated alike. That is prediction 4, and it is the
      reason delivery is proved from telemetry.

## Decision

**CONFIRM**, by decision-rule row 1: the pair `(matched, misdescribed) = (5, 0)` reaches
two-sided Fisher `p = 0.0079` in the predicted direction, and `(5,0)` is one of the three cells
the MDE table registered as decidable at this `n`. The cost row was evaluated and did not fire
(−7.6 %, threshold > +25 %).

**What is now measured, and it was not before:** on this instrument, on BE-003, at
`claude-haiku-4-5-20251001`, **changing only a skill's `description` — with the body held
byte-identical — changes whether the skill loads, from 5 of 5 to 0 of 5.** Three vendors document
that mechanism and none of them showed a measurement. This is one, with its `n`.

**Stated exactly, because the §4a gate found both looser readings at 2/2.** *"The description
decides"* is shorthand for two narrower claims: (i) the description is **causally sufficient** to
change activation under this contrast — measured; and (ii) the body plays **no** part — **not
identifiable from this design**, since a selector reading both, where an unrelated description
vetoes a matching body, fits the data equally. Nor is the effect **deterministic**: a repeat at
4 of 5 would still satisfy the registered `CONFIRM` rule.

**What is NOT measured, and must not be read out of this:** how *close* two descriptions can get
before selection degrades. The two here are at maximal semantic distance. The result establishes
that the description is the selector; it does not characterise the selector.

**Keep / modify / remove**, per §4 step 10:

| artifact | decision | why |
|---|---|---|
| `build/customizations/skill-v0.2{,-misdescribed}` | **keep, unedited** | they are the registered arms of a closed comparison |
| `build/customizations/skill-v0.1{,-misdescribed}` | **keep, unedited** | preflight run `c090f67e` used them; deleting them makes that run unreproducible |
| `build/customizations/skill-probe-diagnostic` | **keep** | evidence for the delivery probe; explicitly not an arm |
| `tools/skill-activation.sh` | **keep** | it produced the outcome, and it is the only thing separating a real zero from a missing one and now from a damaged one |
| `tools/check-overlay-parity.sh` | **keep** | it is what makes "one variable" an executing claim rather than a sentence |
| `--enable-skills`, the runner guard, the force-add | **keep** | without them no skill treatment is deliverable at all, which is the finding this stop opened with |
| `runner/lib/classify-skill-contamination.sh` | **keep** | the rule it replaced excluded the treatment arm |
| the runner's old blanket "any Skill call is a plugin leak" rule | **REMOVED**, and the removal is the finding | it was measured to condemn a legitimate treatment on run `46ffad94` |

## Follow-up

Registered here rather than acted on, because each needs its own prediction first.

1. **How close can the descriptions get?** The obvious next design is a ladder of descriptions
   between "shipment confirmation in a Kotlin Spring service" and "CSS keyframe animations", and
   the outcome is where selection stops. It needs a solution to the `custom_skill` redaction
   first if more than one skill is installed at a time.
2. **Two skills, one run.** `skill.name` is redacted to `custom_skill` for project scope, so this
   instrument cannot currently attribute an activation to one of two installed skills. Anything
   that installs two must fix that before it runs, not after.
3. **Progressive disclosure, still unmeasured.** Phase 3's economics claim — the body costs
   nothing until selected — is now testable on exactly this apparatus: arm C is a run where the
   body was present and never loaded. The token records for these 15 runs already hold the data
   and nothing here has read them for that question.
4. **The `change-focus` ladder gap.** A submission adding one `ErrorCode` constant in a second
   attached file matches neither anchor 1's illustration nor anchor 2's clause list. Recorded in
   the hand re-read above; a rubric round, never a sha moved mid-experiment.
5. **One runtime.** Codex documents the same mechanism and is untested here.
6. **Probe every treated worktree for delivery, not a sample, and do it before `$TMPDIR` reaps
   them.** Two of six arm-C probes came back inconclusive, and a strict reader can shrink this
   experiment's effective `n` on that basis. Six extra `claude -p "/name"` calls at the end of a
   batch close it permanently.
