# Experiment E-004 — does the *description* decide whether a skill loads?

**Stop 8 of the spine, Phase 3 (Agent Skills). Track A lab that runs the benchmark, so the whole
§4 loop applies.**

> ## ⛔ THIS EXPERIMENT HAS NOT RUN, AND MUST NOT RUN AS IT STANDS
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

## Independent variable

**Exactly one thing: the `description:` line in the skill's frontmatter.**

Arms B and C install a skill at the same path, with the same `name`, and with a **byte-identical
body below the frontmatter**. Arm A installs nothing. The body's identity is asserted mechanically
in *Sanity checks*, not by eye.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `--customization build/customizations/skill-v0.1/` (arm B) and `.../skill-v0.1-misdescribed/` (arm C), each containing `sample-service/.claude/skills/shipment-service-conventions/SKILL.md` (see the amendment below). The runner `cp -R`s the overlay into the worktree and commits it as a setup commit *before* the agent starts |
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
