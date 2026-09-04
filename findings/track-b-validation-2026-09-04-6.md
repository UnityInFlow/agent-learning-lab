# Track B validation, sixth pass — 2026-09-04

`Validated by Claude Opus 5 (claude-opus-5), section 9 of PROMPT-opus5-track-b.md,
2026-09-04, sixth run of the day.` Read-only. Nothing outside this file was created, edited
or deleted; no workbook, experiment, run folder or sheet was touched.

**Why the `-6` suffix.** §9 names the output `findings/track-b-validation-<date>.md`. That
name and `-2` … `-5` are already taken by today's five earlier passes. Writing to the base
name would have destroyed another pass's output, so this file follows the directory's
established convention instead. That choice is the only deviation from §9 in this file.

**Independence.** This session was started fresh with no prior context on the track. It shares
the builder's model family, which is the standing caveat on every pass so far — §9 asks for a
different model and has not yet got one. Where a claim could be re-derived from raw data rather
than read, it was: the activation result was recomputed from `events.jsonl` with this
validator's own parser, the rubric cells from the kept worktrees, the p-values from a Fisher
implementation written here, and the cost deltas from `GET /api/runs`.

**Inputs.** `findings/track-b-2026-09-04.md` first, then `TRACK-B-STATE.md`, then the §5
validation tables in `phases/b02-plain-baseline/`, `phases/01-instructions/`,
`phases/b03-global-instructions/`, `phases/02-prompt-files/` and `phases/03-skills/`, then
`experiments/E-002`, `E-003`, `E-004`, the `evidence/` tree, 58 sheets in `findings/codex/`,
`agent-observatory/infra/telemetry-out/events.jsonl` (3 855 lines), 249 run records from the
live API on 8081, and 88 kept worktrees under `$TMPDIR`.

**Repository state at validation time.** `agent-learning-lab` HEAD `03496ca` on
`stop9/validator-pass-3-corrections`; `origin/main` `288ceee`; branch not merged.
`agent-observatory-benchmarks` clean at `0448643`.

**Scope.** §9 covers closed stops. Stops 4, 5, 6, 7 and 8 are reported closed by
`findings/track-b-2026-09-04.md` and by the Position table in `TRACK-B-STATE.md`. Stop 9 is
reported in progress at §4 step 8 and is **not validated here**, consistent with the fourth and
fifth passes.

---

## Verdicts

| Stop | Verdict | One line |
|---|---|---|
| **4 — B2** | **CONFIRMED WITH CORRECTIONS** (2) | Every gate clause maps to evidence that opens; the deliberate failure re-derived exactly from raw telemetry; two corrections about *where the proof lives*, not about the result |
| **5 — Phase 1** | **CONFIRMED** | The one measurable row re-derived to the digit (39 hash / 40 null, zero exceptions); the three "NOT MEASURED" rows are labelled as having no proof at any layer, which is the honest label |
| **6 — B3** | **CONFIRMED WITH CORRECTIONS** (1) | Primary outcome recounted independently from the sheets (2/10 vs 3/10), medians and p-values reproduce; one correction, shared with stop 4, about prediction-commit recoverability |
| **7 — Phase 2** | **CONFIRMED** | `n = 0`, and the table says so; every re-derivation command in it was run here and returned the stated value |
| **8 — Phase 3** | **CONFIRMED WITH CORRECTIONS** (4) | The headline is re-derived exactly and stands. But a value in the §5 proof row and in E-004's results table **is wrong on 2 of 5 treated runs**, and it is the value that names the mechanism |

No stop is NOT CLOSED.

---

## Stop 4 — B2 plain-prompt baseline

### The eight checks

**1. Every gate clause maps to evidence that exists and opens.** Seven rows in the §5 table at
`phases/b02-plain-baseline/README.md:479`. All seven opened.

- Row 1, *"≥3 run folders with diffs, verification results"* — `EXP-B2-BASELINE-CLAUDE` returns
  **9** runs and `-CODEX` **5**, every one `evaluation.exitCode 0`. Re-derived from the live API.
- Row 2, *"and completed rubrics"* — all five named codex sheets and all five opencode sheets are
  on disk. `check-run-gate.sh` re-run here on all five run records: **5 of 5 exit 0**.
- Row 3, *"median and range, never an average alone"* — `evidence/b02/baseline-report-20260901T192000Z.txt`
  opens (2 014 bytes). The L2 claim rests on an executing test; I ran it:
  `python3 -m unittest runner.test_baseline_report` → **19 tests, OK**, including
  `test_the_module_computes_no_mean`, which bans `mean`/`fmean`/`average` and division by `len()`.
  **The L2 label is earned.**
- Rows 4 and 5 were relabelled L3 by the first pass and are L3 here.
- Row 6 — `evidence/b02/hand-reading-maintainability-4c891809.txt` opens (2 806 bytes).
- Row 7 — prose, labelled L3.

**2. Prediction precedes run — and the table is missing the row that matters most.** The table
checks the *deliberate failure's* ordering only. I checked it and then checked the one it omits.

| what | commit | committer time (UTC) | first run | `startedAt` | margin |
|---|---|---|---|---|---|
| deliberate failure (E-002) | `59ac936` | 2026-09-03T13:06:30Z | `4c891809` | 13:07:19Z | **49 s** |
| **the baseline batch itself** | `85973dc` *"B2's four predictions, adopted, with the pilot disclosed"* | **2026-08-30T20:12:42Z** | `5bd24356` | **20:13:57Z** | **75 s** |

Both hold, both read from `git show -s --format=%cd` and the run record, not from prose. The
second is **not in the §5 table** and should be — it is the ordering that covers nine of the
stop's fourteen runs. Recorded as correction 4.2, and it is an omission that *strengthens* the
stop once filled in.

`ff9b462` *"Prediction 2's mechanism is false"* lands at 20:15:30Z, **after** the first run
started. The workbook already states this and leaves the prediction unrevised. Correct handling.

**3. A scored cell re-derived by hand.** `maintainability` on `4c891809`, from the kept
worktree at `$TMPDIR/observatory-run-4c891809-…` (17 `.kt` files, intact) against the rubric at
`396e1799eb2b` (`shasum -a 256 benchmark/rubrics/backend-quality.yaml | cut -c1-12` run here →
`396e1799eb2b`).

The method body is `return when (shipment.status) { CANCELLED -> throw …; CREATED -> …;
CONFIRMED -> shipment }`. One `when (shipment.status)`; in expression position, value returned;
no `else`. Every clause of anchor 2 holds.

> **My value: 2. Sheet: 2. Committed hand reading: 2.** Three-way agreement.

**4. Treatment reached one arm and not the other.** B2's arms are hook isolation, not a
customization: `customization.*Hash` is **null on all 10** E-002 runs, as the workbook says. The
independent variable is hook execution, and I recounted it from raw telemetry with my own parser:

| arm | `hook_execution_start` per run | `hook_registered` |
|---|---|---|
| isolated (`4c891809 9fcf4a92 b0c1d993 7dd11b68 6d61a1c7`) | **0, 0, 0, 0, 0** | 23 on all five |
| open (`67d43a07 a485d5e6 d46599d8 083bd598 017c2654`) | **29, 33, 27, 31, 48** | 24 on all five |

Reproduces `0×5` against `27–48×5` exactly. `hook_registered > 0` on all ten, so the join is
not blind.

**5. Anything stated as a property from `n < 5`?** No. The workbook's own lesson 3 — *"a number's
`n` is part of the number… `maintainability` read 0-of-3 and then 1-of-5 on the same rule"* —
is left standing unedited, which is the rule working.

**6. L1/L2 where nothing executes?** Rows 4 and 5 were already corrected. I re-applied the layer
rule to the remaining L2 rows and found each backed by a named executable: `evaluator.sh`,
`check-run-gate.sh`, `test_baseline_report.py`. **No further mislabels found.**

**7. Registered variables.** Rubric `396e1799eb2b` (recomputed). Evaluator `1.0.0` on all 14.
Model `claude-haiku-4-5-20251001` on all 9 claude runs. Benchmark **moved** `8aadc75` → `0448643`
between the baseline batch and E-002 — disclosed at `README.md:462`, and I verified the
justification rather than trusting it: `git diff 8aadc75..0448643 -- tasks/ sample-service/` in
`agent-observatory-benchmarks` is **empty**. Harness moved `2.1.251` → `2.1.259`, disclosed at
`README.md:466`, and E-002 is internally matched under `2.1.259`.

**8. Keep / remove decisions.** B2 registers no artifact removal. The one *"held for the author"*
item (the parity re-run's prediction) is carried, not silently dropped.

### Corrections

**4.1 — "exist in this clone only" is factually wrong, and the true recovery path is not written
down.** `phases/b02-plain-baseline/README.md:518` says `59ac936` and `0e0c6f9` *"exist in this
clone only"*. They do not. Checked against the remote today:

```
git ls-remote --heads origin
  288ceee…  refs/heads/main
  03496ca…  refs/heads/stop9/validator-pass-3-corrections
```

**Every earlier stop branch has been deleted from the remote** — my local `origin/b02/close-the-gate`
and `origin/phase03/skills-activation` refs are stale. But `refs/pull/*/head` survives, and the
commits are reachable from it:

| commit | reachable from |
|---|---|
| `85973dc` (B2 baseline predictions) | `refs/pull/43/head` (`2958ca6e`) |
| `59ac936`, `0e0c6f9` (E-002) | `refs/pull/53/head` (`f18b6cde`) |
| `2015555`, `97e2ed5` (B3, E-003) | `refs/pull/53/head` |
| `5d14182`, `5a14711` (E-004 registration) | `refs/pull/56/head` (`169ad949`) |

So the honest sentence is stronger than the one on record: a stranger **can** perform the
prediction-precedes-run check, with `git fetch origin refs/pull/43/head` and the same for 53 and
56. `E-004:168` already says this for stop 8's own shas; the B2 and B3 amendments do not, and
`TRACK-B-STATE.md:42` asserts *"the workbooks now say so"* when two of them say the opposite.
**Nothing about the result changes. What changes is that the check is re-derivable and is
currently documented as impossible.**

**4.2 — the §5 table omits the baseline batch's own prediction ordering.** Filled in above:
`85973dc` at 20:12:42Z against `5bd24356.startedAt` 20:13:57Z. L3 by the same rule that demoted
the other two ordering rows — git writes both timestamps, a human compares them.

---

## Stop 5 — Phase 1, custom instructions

**Result on record: `INCONCLUSIVE`.** Six gate rows, three of them *"NOT MEASURED"* and labelled
**L3, no proof**. That is the correct label and it is the phase's result rather than a hedge.

**The one row with a measurement, re-derived.** Row 3 claims `customization.instructionsHash` =
`sha256:13a7b6afb4d4b07312035d72a21c3049` on 39 runs and `null` on 40 across three named keys.
Recounted from the live API:

| key | total | hash | null | distinct hash values |
|---|---|---|---|---|
| `EXP-BE002-AGENTSMD-V3` | 20 | 10 | 10 | 1 |
| `EXP-BE002-CLAUDEMD-V2` | 36 | 18 | 18 | 1 |
| `EXP-BE002-CLAUDEMD` | 23 | 11 | 12 | 1 |
| **total** | **79** | **39** | **40** | **`sha256:13a7b6afb4d4b07312035d72a21c3049`** |

**39 / 40, zero exceptions**, and the hash tracks `variant == "instructions"` perfectly in all
three keys. Exact.

**The L2 label on that row is earned, and I checked the executable rather than the sentence.**
The row justifies L2 by *"the runner refuses a customization whose instruction file the runtime
does not read."* That refusal is at `agent-observatory/runner/run-agent.sh:357–365`: a `die` on
a foreign instruction file, with the failure it was written for named in the comment above it
(`EXP-BE002-AGENTSMD-V3` installed `AGENTS.md` against a runtime that reads `CLAUDE.md`). It
executes and exits non-zero. **L2 confirmed.**

**Items 2, 3, 4, 8** are not applicable: no run was launched at this stop, no cell was scored
here, no arm was created, no artifact was kept or removed. Item 5: no `n < 5` claim. Item 6: no
L1/L2 label survives that I could refute. Item 7: no registered variable moved, because nothing
ran.

**Verdict: CONFIRMED.** No corrections.

---

## Stop 6 — B3, minimal global instructions

### The eight checks

**1. Evidence opens.** Five evidence files cited; all five open, sizes 1 747 – 6 KB. The
`build/customizations/instructions-v0.1-bloated/CLAUDE.md` link resolves.

**2. Prediction precedes run.** `2015555` *"E-003: predict what a 57-word instruction file
moves"* at **2026-09-03T16:59:55Z**; first treated run `367a809d.startedAt` **17:03:16Z**
(margin **3 m 21 s**); first control `f8877c4c` 17:05:32Z. Deliberate failure `97e2ed5` at
**17:05:09Z**; first bloat run `97a39231` **17:55:22Z** (margin **50 m**). Both hold. Read from
`git log --all` and the run records.

**3. A scored cell re-derived by hand.** `maintainability` on `367a809d`, worktree intact
(17 `.kt`). The body is an `if (status == CANCELLED) { throw … }` guard followed by
`return if (status == CONFIRMED) shipment else repository.save(…)`. Anchor 0's first clause —
*"an `if` / `else if` / `else` chain"* — holds, and the ladder stops at the first anchor whose
condition holds.

> **My value: 0. Sheet: 0. Committed hand reading: 0.**

**And I recounted the primary outcome rather than re-reading one cell of it.** Parsing all
twenty sheets with my own parser:

| arm | maintainability cells | anchor 2 |
|---|---|---|
| `EXP-B3-INSTRUCTIONS-CLAUDE` | `0 2 2 0 0 0 0 0 0 0` | **2 of 10** |
| `EXP-B3-CONTROL-CLAUDE` | `0 0 0 2 2 0 0 2 0 0` | **3 of 10** |

**2 / 10 against 3 / 10, exactly as reported**, and it agrees with
`evidence/b03/construct-census-20-runs-…` which was read off the source *before* any scorer ran.

**4. Treatment reached one arm and not the other — this is the cleanest arm separation in the
track.** From the run records:

| arm | `instructionsHash` | n |
|---|---|---|
| instructions | `sha256:90f95226cc3d429f6f3e157e4741bbd1` | **10 of 10** |
| control | `null` | **10 of 10** |
| bloat | `sha256:807c5d03f77cc66106aa90d72fe50245` | **5 of 5** |

Single-valued per arm, no leakage, and the two treated files carry distinct hashes.

**5. `n < 5` claims.** None. The bloat arm is `n = 5` and every one of its numbers is quoted with
it. The one sentence that over-generalised (*"whatever the instruction file says"*) was struck by
the first pass and the strike is still in place at `README.md:279`, with the overreach preserved
as the finding.

**6. L1/L2 where nothing executes.** The exit-gate clause *"remove every rule with no measured
effect"* is explicitly labelled **L3, not a control** at `README.md:328` — *"the safeguard is the
study design, not the clause."* Correct, and unusually honest about it. No mislabel found.

**7. Registered variables.** Model, evaluator `1.0.0`, benchmark `0448643` and rubric
`396e1799eb2b` identical across all 25. Harness `2.1.259` on all 25 — moved from B2's `2.1.251`,
which is disclosed and is why the gate's *"vs B2"* was substituted with a concurrent control.

**8. Remove decisions and their measured no-effect.** The stop removes `instructions-v0.1` and
does not replace it. Every number behind that is on record; I recomputed the continuous ones from
`GET /api/runs` (medians, as the table uses):

| outcome | treatment | control | delta | recomputed here |
|---|---|---|---|---|
| `estimatedCost` (median) | 0.151968 | 0.155888 | **−2.5 %** | ✔ |
| `durationMs` (median) | 89 000 | 100 500 | **−11.4 %** | ✔ |
| `toolCalls` (median) | 18 | 18 | 0 | ✔ |
| maintainability anchor 2 | 2/10 | 3/10 | — | ✔ |

And the Fisher p-values, recomputed with an implementation written in this session:

| comparison | reported | recomputed |
|---|---|---|
| treatment 2/10 vs control 3/10 | 1.00 | **1.0** |
| bloat 3/5 vs treatment 2/10 | 0.25 | **0.2507** |
| bloat 3/5 vs control 3/10 | 0.33 | **0.3287** |

The deliberate failure's `+4.2 %` is the bloat median against the **treatment** median
(0.158287 / 0.151968 = +4.16 %), which is what the arm registered as its comparator. Correct.

**One thing worth naming that is not a defect:** the bloat arm has **no rubric sheets** — its
registered outcomes are cost and the construct census, and the census is on disk with a per-run
table. Nothing claims a rubric result for it.

### Correction

**6.1 — the same recoverability wording as stop 4.** `phases/b03-global-instructions/README.md:334`
lists nine commits as *"exist in this clone only"*. `2015555` and `97e2ed5` are reachable from
`refs/pull/53/head`, which still resolves on the remote today. Same fix, same non-effect on the
result.

---

## Stop 7 — Phase 2, prompt files

`n = 0`. Nine rows, seven of them L3 by their own text, and the table corrects itself in two
places — one row records that it said *"L2 flat, which is an L2 label on an L3 object"* and was
caught by the stop's own review. That is the layer rule applied against the author's interest.

**Every re-derivation command in the table was run here:**

| the table says | I ran | result |
|---|---|---|
| `./tools/check-links.sh` → the four sources resolve, none among moved/blocked | ran it | `ok=64 moved=8 blocked=2 unverified=0 broken=0`, exit 0; **none of the four Phase-2 URLs appears in the 8 MOVED or 2 BLOCKED lines** |
| `SOURCES.md` lines 61, 89, 90, 91 carry the four sources | `sed -n '61p;89p;90p;91p'` | the Copilot feature matrix, VS Code prompt files, Copilot response customization, Claude Code Skills — all ✅ |
| `grep -c "^## .*DEFERRED"` returns 3 | ran it | **3** |

**Item 5** — no `n < 5` claim, because there is no `n`. **Item 7** — nothing moved; nothing ran.
**Item 8** — the deferred labs are marked deferred, not quietly dropped; the headline finding
(`allowed-tools` pre-approves, `disallowed-tools` narrows) is labelled **documentation-derived
and unobserved**, and the workbook says so in the row itself.

**Verdict: CONFIRMED.** This is the best-labelled table in the track, and it is the one with no
data in it — which is the point.

---

## Stop 8 — Phase 3, Agent Skills

### The headline is re-derived and it stands

I recomputed the result from `events.jsonl` with my own parser, not with
`tools/skill-activation.sh`, and then re-ran the project's tool as a cross-check:

| arm | runs | `projectSettings` activations |
|---|---|---|
| skill-matched | `d6aec246 45a70775 2cf0c720 33a4090d 8998ef3b` | **1, 1, 1, 1, 1 → 5 of 5** |
| skill-misdescribed | `95f42409 fc3665a7 77c60831 cc41f3f0 946144c3` | **0 of 5** |
| control | `d671d1b7 7b4428be 394ee79a ff7bffed c51a7a0c` | **0 of 5** |

No `bundled` and no `plugin` activation anywhere in the batch. Two-sided Fisher recomputed:
matched vs misdescribed **p = 0.0079**, matched vs control **p = 0.0079**, matched vs the pooled
ten controls **p = 0.00033**. `skill.name` is `custom_skill` on all five — prediction 5, the one
registered as most likely to be wrong, holds.

The flag finding re-derives too: `6 of 6` against `0 of 6`, **p = 0.0022**. And its corroborating
telemetry claim — *"across the 202 earlier runs, 183 join and 18 of those carry a plugin-scope
activation, 20 activations"* — I recounted independently and got **18 runs, 20 activations**,
exact.

Overlay parity re-run here: `check-overlay-parity.sh --allow-differ description` on the two arms
→ *"body identical … `sha256:d10a2c3988be520e`; declared difference: frontmatter `description`"*,
exit 0. The cited sha is the sha.

Every verifier the table names was re-run in this session:

```
tools/verify-skill-activation.sh          28 passed, 0 failed        exit 0
tools/verify-overlay-parity-checker.sh    16 passed, 0 failed        exit 0
runner/verify-skill-delivery.sh            7 passed, 0 failed        exit 0
runner/verify-skill-contamination.sh      16 passed, 0 failed        exit 0
tools/verify-run-gate-checker.sh          all 13 cases behaved       exit 0
tools/verify-sheet-category-checker.sh    all 11 cases behaved       exit 0
```

**Prediction precedes runs.** `f8ff084` **2026-09-04T10:34:48Z**, first batch run
`d671d1b7.startedAt` **11:03:44Z**; the excluded `62deb6c5` at 10:50:29Z is also after it. And
`f8ff084`, `7cf5adb`, `35abde7`, `40f38e2` all return **YES** to
`git merge-base --is-ancestor <sha> origin/main` — author decision 4 worked, and this is the
first stop in the track where the ordering is re-derivable from `main` alone.

**Registered variables.** Model, evaluator `1.0.0`, benchmark `0448643`, rubric `396e1799eb2b`,
single-valued across all 16 runs; benchmarks repo `git status --porcelain` empty. Harness moved
`2.1.259` → `2.1.260` — disclosed by pass 3's correction (a), and the within-batch comparison is
under one version.

**The co-variate re-derived.** `maintainability` anchor 2: matched **5 of 5**, misdescribed
**4 of 5**, control **1 of 5**; matched vs misdescribed p = 1.0, pooled treated vs control
**p = 0.017**. And the workbook's supporting claim that *"three of the four rubric categories are
constant across all fifteen runs"* is exactly true: `architecture-consistency` = 2 on 15 of 15,
`test-quality` = 1 on 15 of 15, `change-focus` = 1 on 15 of 15.

### Correction 8.1 — the proof row names a value that is wrong on 2 of 5 treated runs

`phases/03-skills/README.md:666`, the §5 row for **"the treatment reached the model"**, reads:

> the model *used* it: **5 of 5 matched runs carry an activation with
> `invocation_trigger = claude-proactive`**

`experiments/E-004-skill-activation.md:663–667` records `claude-proactive` in the trigger column
for all five matched runs. **The telemetry does not.** Read with this validator's parser and then
confirmed with the project's own tool:

```
./tools/skill-activation.sh …/events.jsonl <run-id>

d6aec246   activations_by_source: projectSettings=1   invocation_triggers: claude-proactive=1
45a70775   activations_by_source: projectSettings=1   invocation_triggers: claude-proactive=1
2cf0c720   activations_by_source: projectSettings=1   invocation_triggers: claude-proactive=1
33a4090d   activations_by_source: projectSettings=1   invocation_triggers: nested-skill=1
8998ef3b   activations_by_source: projectSettings=1   invocation_triggers: nested-skill=1
```

**Three `claude-proactive`, two `nested-skill`.** The rest of E-004's results table is accurate —
I spot-checked cost and tool-call columns against the API and they match to the digit — so this
is one column carried forward wrongly, not a fabricated table.

**Why it is more than a typo.** `README.md:397` and `E-004:456` both define `claude-proactive` as
*"implicit selection from the description, the exact mechanism this experiment tests"*, and
`README.md:634` treats `nested-skill` as a **different** trigger when it appears on run
`899232bb`. So on 2 of 5 matched runs the recorded mechanism is not the one the L2 proof row
names, and no artifact in the stop acknowledges it.

**What it does and does not move.** The registered outcome is *an activation from the scope this
experiment installed*, decided before the run. That is 5/5 vs 0/5 vs 0/5 and it is untouched —
narrowing the outcome now would be revising a prediction after its data, which this project
rightly forbids. But the sensitivity is worth having on record:

| outcome | matched | control | misdescribed | Fisher (vs one arm) |
|---|---|---|---|---|
| any `projectSettings` activation **(registered)** | 5/5 | 0/5 | 0/5 | **p = 0.0079** |
| `claude-proactive` only *(not registered — illustrative)* | 3/5 | 0/5 | 0/5 | **p = 0.1667** |

So the *result* is robust and the *mechanism sentence* is directly evidenced on three runs, not
five. The fix is two edits and one sentence of disclosure, not a re-run.

### Correction 8.2 — one scored cell disagrees with the project's own hand-reading rule, and with the identical construct in stop 6

Re-deriving a stop-8 cell by hand, I took `ff7bffed` (control arm) rather than one of the three
pass 3 had already taken. Its `confirm` body and that of **`369b9d03`** — a *stop 6 treatment*
run — are **byte-identical**:

```
diff <(awk '/fun confirm/,/^    \}$/' $TMPDIR/observatory-run-369b9d03-…/…/ShipmentController.kt) \
     <(awk '/fun confirm/,/^    \}$/' $TMPDIR/observatory-run-ff7bffed-…/…/ShipmentController.kt)
→ no output, exit 0
```

Same rubric sha `396e1799eb2b`, same scorer harness, model `gpt-5.6-sol`, `agent_sha b181a9bc5df0`,
`schema_sha 5ee1b8ec16ab`. The sheets disagree:

| run | stop | sheet | maintainability | reason given |
|---|---|---|---|---|
| `369b9d03` | 6 | `score-observatory-run-369b9d03-…-20260903T180109Z.yaml` | **0** | "Status decisions use if constructs" |
| `ff7bffed` | 8 | `score-observatory-run-ff7bffed-…-20260904T114156Z.yaml` | **1** | "The status decision is split across two independent if constructs." |

`evidence/b03/construct-census-20-runs-…` — the hand census, read off the source before any
scorer ran — classifies this shape as `if-chain → anchor 0`. **By the project's own rule
`ff7bffed` should be 0.**

**A real rubric gap sits underneath it, and it is a new one.** Anchor 0 enumerates three
constructs — an `if`/`else if`/`else` chain, a `when` with `else`, a `when` in statement
position. `ff7bffed`/`369b9d03` is **two independent `if` guards with early returns and no `else`
anywhere**, which is none of the three by the letter, while matching anchor 0's stated rationale
exactly (a new `ShipmentStatus` constant compiles here and takes the fallback path unannounced).
The rubric documents four ladder gaps; this is a fifth, in `maintainability`, and it is not the
one already recorded there.

**Consequence, stated at its true size:** none of the reported numbers move. Both 0 and 1 are
"not anchor 2", and every headline in stops 6 and 8 counts anchor 2 — B3's primary outcome stays
2/10 vs 3/10, stop 8's co-variate stays 5/5, 4/5, 1/5. What it means is that one stop-8 cell is
scored inconsistently with a stop-6 cell on identical bytes, and no human had read that cell.
A rubric round, never a sha moved mid-experiment.

### Correction 8.3 — one §5 row's evidence is a sentence, which §5 forbids

The same row 666 supports arm C's delivery with *"explicit `/shipment-service-conventions` in the
kept worktrees loaded the skill and quoted its body in **4 of 6** probed."* There is **no artifact
on disk** for that probe. `evidence/p03/` holds the delivery probe and the flag probe, each with
a dated file and raw transcripts named; the arm-C probe has neither. §5's rule is *"Evidence is a
path or an id, never a sentence,"* and the re-derivation column offers a command whose output
today would be a **new** measurement on worktrees that `$TMPDIR` is actively reaping.

E-004 itself is scrupulous about this at line 832 — it writes out the weakest reading (`n = 2`
positively proven, *"no longer at p < 0.05"*) — and the §5 table quotes only the stronger half.
E-004 follow-up 6 already names the repair: probe every treated worktree before reaping, six
`claude -p` calls at the end of a batch.

### Correction 8.4 — the "at both paths" half is an `n = 3` claim quoted without its `n`

`phases/03-skills/README.md:695` states it correctly: *"The flag matrix is `n = 3` per cell,
pooled to 6 versus 6."* `findings/track-b-2026-09-04.md:21` and the workspace `CLAUDE.md` both
quote *"6 of 6 activated without it, 0 of 6 with it, **at both paths**, p = 0.0022"* — the pooled
`n` is there, but the both-paths half is a per-cell `n = 3` claim and §5 says nothing from
`n < 5` is stated as a property. The evidence file makes the same move in bold: **"The nested
path activates."** Related, and disclosed in the same file: author decision 1 asked for the
premise probe at **`n = 5`**; it was run at **`n = 3` per cell**. The deviation is written down
where it happened, which is why this is a correction and not a failure.

### The process risk pass 4 raised is confirmed, and it has grown

`git diff origin/main..HEAD` restricted to every stop 4–8 artifact removes **exactly two lines**,
and they are the two `L2` rows replaced by their `L3` versions. Everything else is additions.
The third pass's corrections were applied honestly; I verified that rather than taking it on
trust.

But they are still only on `stop9/validator-pass-3-corrections`, which is **not merged and has no
open PR**. A reader of `main` today still sees the two `L2` labels and no disclosure of the
`2.1.259 → 2.1.260` harness move. Since pass 4 the branch has grown by roughly 1 200 lines of
stop-9 work, so four validator passes' corrections to a **closed** stop are now hostage to an
**open** stop's PR. If stop 9 halts before its PR, ship the corrections alone.

**Verdict: CONFIRMED WITH CORRECTIONS.** The gate clauses are met, the headline is re-derived
exactly, and four corrections attach to how it is written down.

---

## The single finding most likely to overturn the track's result if pursued

**Two of the five activations that carry stop 8's headline were triggered by something other than
the description, and nobody has asked what `nested-skill` means.**

The four passes before this one, and the author's decision 7, name the stop-8 **behaviour**
co-variate as the thing to chase — the misdescribed arm scoring like the matched arm on
`maintainability` while never activating the skill. That is a real question and the fourth arm is
approved. But it is a question about a co-variate that was **never a registered outcome**. The
finding above is about the **registered one**.

E-004's title claim is that *the description decides whether a skill loads*, and the evidence that
the description did the deciding is the trigger value `claude-proactive`, which the experiment
itself defines as implicit selection from the description. On `33a4090d` and `8998ef3b` the
runtime recorded `nested-skill` instead. Nothing in the stop explains what that trigger is, why
it fired on a skill installed at the worktree **root**, or whether it consults the description at
all. If it does not, then description-driven selection is evidenced on 3 runs against 5 controls
— **p = 0.1667**, and the strongest statement left is the weaker one that *a matched description
produces an activation and a mismatched one does not*, which is still true and still `p = 0.0079`.

It is cheap to settle and it needs no new arm: the twelve raw `stream-json` transcripts from the
flag probe and the kept telemetry for the two runs are already on disk, and `skill.name` being
redacted to `custom_skill` does not block it, because there is only one installed skill per run.
Read what `nested-skill` is emitted for. Do it before B6 at stop 13, for the same reason the
co-variate has that deadline: B6's gate compares runs with and without a specialist skill, and
both of these questions are about what "with" actually means on this instrument.

**Second, and structural rather than empirical:** this is the sixth validation pass and the fifth
run today on the builder's own model family. The three findings above that are new — the trigger
column, the cross-stop scorer disagreement on byte-identical code, and the missing arm-C probe
artifact — all survived three §4a review rounds and five validator passes. §9's instruction to
run the validator on a **different model** has not been honoured once. That is the control this
project has specified for itself and never taken.
