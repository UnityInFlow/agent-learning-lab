# Experiment E-001 — does the four-category rubric decide anything?

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`. We got
> that wrong once and voided nine runs.

**Status: unregistered. Two blockers remain.**

1. **The rubric this experiment measures does not exist yet.** `benchmark/rubrics/backend-quality.yaml`
   is still the seven-category worked example — sha `21aa658d030d`, its own header says
   "Do not read a score from this file". The four-category replacement is lab#21 and is
   unwritten. Everything below describes 4 categories × 5 variants = 20 cells; against the
   file on disk it would be 7 × 5 = 35, and the run would measure the artifact this
   experiment exists to replace. An earlier draft of this line said predictions were the
   only blocker, which was wrong the moment the rubric rewrite slipped.
2. **Predictions below are empty.** Do not run `opencode-score.sh` until they are filled in
   and committed, and check the commit timestamp precedes the first run.
3. ~~benchmarks#20 — the fixtures named their own varied dimension in a comment the scorer
   reads.~~ **Cleared 2026-08-27** by benchmarks#21 (`8aadc75`): all eight fixtures now open
   with the same neutral class doc and the prose moved to `fixture-notes/`, outside the
   overlay. It was eight fixtures, not four — `good-strong-tests` announced itself without
   the phrase that had been grepped for, and `known-good` labelled itself the reference.

This is the first record in `experiments/`. B1 is the experiment contract, so the first
experiment it produces is about the instrument rather than about an agent — there is no
agent until stop 10.

## Question

Applied to the **five gate-passing variants**, each scored against `known-good` as the
attached baseline, does the four-category rubric produce scores that **differ between
fixtures**, and does the second scorer produce them **at all**?

4 categories × 5 variants = **20 cells**, everywhere in this record. `known-good` is the
baseline, not a member of the scored population — see the grid below for why, and
**Superseded: the six-cell population** for what changed.

### The grid this experiment is actually run over

| | arch **35** | maint **25** | test **25** | change **15** |
|---|---|---|---|---|
| `good-inline-envelope` | **↓** | · | **S** | · |
| `good-nested-ifs` | · | **↓** | **S** | · |
| `good-noisy-diff` | · | · | **S** | **↓** |
| `good-strong-tests` | · | · | ↑ | · |
| `good-weak-tests` | · | · | **↓** | · |

**↓** the cell the fixture was built to depress · **↑** its high-quality pair ·
**S** structurally unscoreable: no test file, so Decision A nulls it before the anchors are
read.

Dimension assignments are from `fixture-notes/` in benchmarks, which sit outside the scorer's
glob since benchmarks#21. Each note states the variance **and** asserts what is held, which is
what makes the one-cause property checkable rather than claimed:

| Variant | Note says | Held constant |
|---|---|---|
| `good-inline-envelope` | "architecture-consistency only" | behaviour identical to `known-good`; error bodies byte-identical, so the contract suite is satisfied |
| `good-nested-ifs` | "maintainability only" | "byte-identical to known-good: same exceptions, same error codes, same messages, same status codes"; the architecture convention is respected |
| `good-noisy-diff` | "change-focus only" | "`confirm` is character-for-character identical to known-good"; the convention and the exhaustive `when` are untouched |
| `good-strong-tests` / `good-weak-tests` | the test-quality pair | "production code byte-identical to `known-good`" — verified, per the worksheet |

If a note's held-constant claim is wrong, that column's discrimination test has two candidate
causes and the result is not interpretable. It is an assertion in prose, so **L3**: nothing
executes to check that `good-nested-ifs` did not also drift on architecture.

Two facts fall straight out of it, and both are load-bearing:

- **Discrimination is a comparison among these five, not against `known-good`.** Each variant
  depresses exactly one dimension, and all five are scored under identical conditions — same
  rubric, same baseline attached. The test is whether the **↓** cell in a column scores below
  the other cells in that column. For `test-quality` that is the pair: weak below strong.
- **`test-quality` carries 25% of the weight and is decidable on 2 of the 5 variants.** Three
  of twenty cells are null before the rubric is read. The first rubric died because 60% of its
  weight was constant across everything it could score; this is not that defect, but it is the
  same family, and it is a question for lab#21 rather than for this record.

### Superseded: the six-cell population

An earlier draft scored `known-good` too — "the reference every other cell is read against, so
it is scored too" — for a denominator of 24. That was correct **while the comparison had to
happen between sheets.** Decision B moved the baseline *inside* every variant's evidence set,
so the separate `known-good` sheet has no consumer, and its four cells are the worst four in
the grid to keep:

- `test-quality` — no test files. Structural null.
- `change-focus` — it *is* the baseline, so there is nothing to compare it against. Structural
  null. Which also means the earlier KEEP condition, "scores below `known-good` on its own
  dimension", had **no reference value for 2 of the 4 categories** — not an asymmetry to
  adjust for, a missing number.
- `architecture-consistency`, `maintainability` — scored, but from a one-tree evidence set
  while every other cell in the grid saw two. The only cross-condition cells there were.

The MDE table said 20 before it was reconciled to 24 on 2026-08-27. That reconciliation picked
the wrong side, and defensibly: Decision B was written down as built, and was not built until
later the same day. **Provenance: this correction is Claude's derivation from the fixture grid,
at the user's request, 2026-08-27. It was not independently derived by the author, and the
superseded reasoning is left above rather than deleted.**

Three failure modes, and they are not the same:

- **Undecidable, per cell** — the scorer emits `null` for a category because an anchor cites
  something it cannot see. Its contract working, and a rubric defect.
- **Undecidable, wholesale** — no sheet at all, or a sheet whose every cell is `null`. The
  seven-category draft produced exactly this: "an empty body. Not a bad score. Nothing." It
  is the strongest result this experiment can produce, and until 2026-08-27 the harness gave
  it the same exit code as a crash and the Exclusions below told the reader to discard it as
  infrastructure. `lab-acceptance` rejected this record on that, blocking. See
  [`tools/classify-score-output.sh`](../tools/classify-score-output.sh) for where the
  distinction now executes, and the decision rule for where the outcome is filed.
- **Constant** — the scorer emits a score, but the same score for every fixture. Looks like
  success. Carries no information. This is what killed 60% of the weight in the first draft
  and was only visible once the first failure was diagnosed.

**The cell boundary, stated once so two readers cannot split on it.** A sheet is a sheet when
it carries `scorer: lab-scorer` and a `categories:` block, *whatever is in the cells*. A sheet
of `null`s is a result and is tallied as nulls; it is not "no output". "No output"
means no `categories:` block at all, and that is a different class with a different exit code.

## Hypothesis

<!-- TODO — yours. What do you predict, and BY WHAT MECHANISM? A hypothesis without a
     mechanism cannot be interestingly wrong. -->

### Evidence already on file — read before predicting, do not treat as a prediction

Recorded observations from the runs in `findings/opencode/`, not forecasts:

| Observation | Where |
|---|---|
| Probe rubric, 3 categories: 2 anchored on source-visible facts, 1 anchored on `1: "Reasonable." / 2: "Good."` → scorer returned **2 scored, 1 null**, and nulled exactly the vague one | `score-known-good-20260824T202809Z.yaml` |
| Seven-category rubric, anchors citing `exit 12` and `BE003ContractTest passes` → scorer emitted **an empty body**. Not a bad score. Nothing | `score-known-good-20260825T135039Z.yaml` |
| Critic at temperature 0, two independent sessions: 6 sections, **2 of 12 section-runs flipped**. Both flips were real findings the earlier run missed — under-reporting, not hallucination | `review-run-record-20260824T200929Z.md` |
| The scorer has read-ish tools ON deliberately; with every tool off it hung rather than answered | `.opencode/agent/lab-scorer.md` |
| **The attachment set was `*.kt` under the fixture — nothing else.** No diff, no test runner, no evaluator output, no `known-good`. ~~Each fixture is scored in isolation~~ — **superseded 2026-08-27 by Decision B, and by the script finally doing it.** The baseline is now attached, and until that commit both this row and the worksheet described an attachment set the instrument never assembled | `tools/opencode-score.sh` |
| **`known-good` cannot be scored on the same footing as the variants** — it is the baseline, so `change-focus` has nothing to compare it against and it has no test files either. It left the scored population for that reason; `baseline_state` is still stamped per run so any future run against it is provably a different condition | `tools/opencode-score.sh` |
| **Three of the five variants carry no test files at all.** `good-inline-envelope`, `good-nested-ifs` and `good-noisy-diff` attach 2 files each; only the two test variants attach 3. So does `known-good`, which is why it could not fill the gap | `find` over `fixtures/` |
| ~~All eight fixtures announced their own varied dimension in a class KDoc the scorer reads~~ — **fixed 2026-08-27**, benchmarks#21. They now share one neutral class doc; the prose lives in `fixture-notes/`, outside the scorer's glob | benchmarks#20 |

So the instrument has nulled for a vague anchor, nulled wholesale for undecidable anchors,
and under-reported at temperature 0. It has never yet been shown to **discriminate between
two submissions**, because until benchmarks#10 there was only one it was allowed to score.

Three of those rows constrain the answer before any intuition does. The derivation grid
is in [`E-001-prediction-worksheet.md`](E-001-prediction-worksheet.md) — 20 cells, of which
three are structurally predicted and seventeen are yours.

- **`change-focus` had no diff to look at** — the scorer sees one fixture's final files, and
  whether `create` was "restyled for no reason" is a statement about a change. **Decision B,
  2026-08-27: `known-good` is attached as a baseline**, so the change is visible and the
  anchor is citable at `path:line` in both trees. The cost is registered in the worksheet: a
  baseline is available to *all four* categories, not only this one, and may turn
  `architecture-consistency` and `maintainability` into spot-the-difference — an easier task
  and a different measurement. Prediction 3 is the trap for it.
- **`test-quality` has no tests to look at in three of the five variants.** **Decision A,
  2026-08-27: the anchors carry a precondition — no test file means `null`, not `0`.** A `0`
  would assert the tests are bad when none were submitted. Those three cells are *predicted*
  nulls, not guaranteed ones: the precondition is YAML read by a model, nothing executes to
  reject a `0`, and `lab-critic` flagged the earlier "guaranteed" wording as exactly the L3
  worn as L2 that this project keeps re-learning.
- **The labels are gone, and that changes what a good result means.** While they were there,
  a high score and a low null rate were consistent with the scorer having read a comment —
  unfalsifiable in the flattering direction. Since benchmarks#21 the fixtures are silent about
  what they vary, so discrimination now has to come from the code. If the scorer still
  separates them cleanly, that is evidence. If it stops separating them, **that is also
  evidence**, and it is the more interesting of the two: it would mean the earlier confidence
  was the label talking.

## Predictions

Numbered, specific, falsifiable. Include the direction and rough magnitude.
**Yours — not adopted.** The set on file before this was drafted by Claude and adopted, and
the one that broke (`known-good` scores 90–100) broke on an authoring error in the rubric,
which is exactly the kind of thing an independently derived prediction catches.

At minimum, predict:

1. **Null rate.** Of the 4 categories × 5 variants = **20 cells**, how many come back `null`?
   Predict **two numbers, not one**: the 3 `test-quality` cells with no test file are
   structurally null before the anchors are read, so a single rate mixes "this anchor is
   undecidable" with "this fixture had no tests". Report defect-nulls over the **17** cells
   where a score was possible, and the structural 3 separately.
   <!-- TODO: both numbers + mechanism -->
2. **Discrimination.** In each column, does the **↓** cell score below the other cells in that
   column? Four columns, and `test-quality` is a two-cell comparison. Name the column you are
   least confident about.
   <!-- TODO -->
3. **Agreement with your blind scores.** How many of the 20 cells will the scorer and you
   agree on exactly, and where will you diverge?
   <!-- TODO -->

*A prediction you did not write down is always retroactively correct.*

## Independent variable

The fixture. Everything else is held: same rubric, same scorer agent, same model, same
prompt, fresh session per run.

**One thing.** Each of the five variants differs from `known-good` on exactly one dimension,
which is the property benchmarks#10 was built to provide — an observed score difference has
one candidate cause. `known-good` is held constant as the baseline attached to all five, which
is what makes the five commensurable with each other.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `opencode run --agent lab-scorer -m <model>` with the rubric, the fixture's source files, **and the `known-good` baseline** attached — Decision B, and executed since 2026-08-27. `LAB_SCORE_BASELINE` overrides the path; a missing baseline fails the run rather than silently producing the pre-Decision-B measurement. `known-good` is not itself scored; if it ever is, no baseline is attached, the prompt says so, and `baseline_state` records that the run was a different condition |
| Rubric | `benchmark/rubrics/backend-quality.yaml` · sha `21aa658d030d` — **this is the seven-category worked example, not the rubric under test.** Blocker 1. Record the four-category sha here when lab#21 lands, and re-read the 20-cell denominator: it is 4 × 5 and assumes that rewrite |
| Reviewing this record | two models since 2026-08-27: `lab-critic` on `ollama-cloud/glm-5.2` line-level, `lab-acceptance` on `ollama-cloud/minimax-m3` for the gate. Everything reviewed before that date was `deepseek-v4-pro` doing both jobs |
| Agent | `.opencode/agent/lab-scorer.md` · sha `cb371384fa19` |
| Preflight assertion | **L2.** `opencode-score.sh` fails when `--dir` repoints the project root and opencode silently falls back to the default full-tool agent exiting 0. The agent definition is L3; that guard is the L2 version |
| Control assertion | **L1 through this script, L3 outside it.** `opencode-score.sh` has no flag and no branch that reaches `--continue`, so a remembering scorer cannot be requested through the registered mechanism. Running `opencode run --continue` by hand bypasses it, and nothing detects that — the provenance header records `session: fresh` because the script wrote it, not because anything checked |
| Output guard | **L2, and it no longer collapses.** `tools/classify-score-output.sh` returns one exit code per outcome: `0` sheet (all-`null` cells included), `2` off contract, `3` empty, `4` default-agent fallback, `5` the scorer declaring the rubric unusable. Only `1` and `4` are infrastructure. `tools/verify-score-output-classifier.sh` registers eight fixtures with the class each must produce, and CI runs it — a classifier that stopped discriminating would be indistinguishable from the single guard it replaced |

## Controlled variables

- [x] benchmark revision — `agent-observatory-benchmarks` @ `ad1cc78`
- [x] task — BE-003-confirm-shipment
- [x] harness — opencode 1.18.21
- [x] model — `ollama-cloud/deepseek-v4-pro` (pin it; `LAB_REVIEW_MODEL` overrides, and an
      unpinned scorer model is an unregistered variable)
- [x] temperature — 0, set in the agent frontmatter
- [x] session — fresh per run
- [ ] rubric sha — pending the #21 rewrite
- [ ] your blind scores recorded **before** any scorer output is read

> Three models hang indefinitely on non-interactive runs and must not be used here:
> `opencode-go/kimi-k3`, `opencode-go/glm-5.3`, `ollama-cloud/kimi-k2.6`.

## Runs

Repetitions per fixture: ____ · Total: ____

The critic disagreed with itself on 2 of 12 section-runs at temperature 0, so for **the
critic** a single run is a lower bound rather than a value. That figure is `opencode-review.sh`,
a different instrument with a different contract: the critic decides what to report, and
under-reporting is the failure mode measured. The scorer's contract fixes the output shape
in advance — one cell per rubric category — so its variance would show up as a cell flipping
value or nulling, which nobody has measured. **Treat 2/12 as a reason to ask the question
about the scorer, not as an answer for it.** `opencode-score.sh` has no `-n`;
`opencode-review.sh` does.
<!-- TODO: decide whether one run per fixture is enough here, and say why. If you want the
     scorer's own repeatability, that is a second experiment — same fixture, same rubric, n
     runs — and it is not this one. -->

## Minimum detectable effect

| Outcome | MDE | Registered before the run? |
|---|---|---|
| primary: score gap between a column's **↓** cell and the other cells in that column | | |
| secondary: defect-null rate across the 17 scoreable cells | | |
| secondary: structural nulls, predicted at 3 of 20 | | |

<!-- TODO: a 0–2 scale with weights 35/25/25/15 means one category moving by 1 point moves
     the normalised total by a fixed amount. Work out what that is per category, and decide
     what gap you would call a real difference rather than noise. -->

## Deterministic evaluation

None. **This experiment has no deterministic evaluator, by design** — that is the whole
reason it exists. `evaluator.sh` has already decided pass/fail for all six gate-passing
fixtures — the five variants and the baseline they are read against — and all six passed.
Since benchmarks#21 that is executed rather than asserted: every gate-passing variant is a
registered `run_case`, so a fixture that quietly stopped clearing the gates would fail CI
instead of silently leaving the scored population. The baseline is covered by the same
guard, which matters more now that it is attached to every run rather than scored on its own.

What is being measured here is whether a *non-deterministic* instrument can discriminate
among things a deterministic one cannot.

The check on the rubric is agreement with an independent human scorer, which is why step 2
below is blind.

## Exclusions

Registered now, not after seeing the data:

- A run where opencode exits non-zero (`1`), or where the default agent answered instead of
  `lab-scorer` (`4`) — infrastructure, re-run, do not score. **These two only.** An earlier
  draft excluded "exits 0 with no scores", which swept up the wholesale-undecidable outcome
  the evidence table records as a rubric defect; the experiment would have discarded its own
  primary signal and called it a broken script
- A run classed `empty` (`3`) is **not** excluded and **not** yet a datum: re-run once on the
  same rubric and fixture. A second `empty` is a finding and is recorded as wholesale
  undecidable. One `empty` followed by a sheet is infrastructure, and both runs are recorded
  with that reasoning — the file cannot tell you which it was, so the repeat is what decides
- A run classed `off contract` (`2`) or `declared error` (`5`) is recorded, not re-run. It is
  what this scorer did when handed this rubric
- A run against a fixture that does not pass `evaluator.sh` — the rubric only scores
  gate-passing submissions and `known-bad-*` are not in the population
- A cell where the scorer's `evidence` cites a file not in the attachment set — it went
  hunting, and the result is not from the evidence it was given. **L3, and weaker than it
  looks**: the check fires on a *citation*, and `lab-scorer` has read-ish tools deliberately
  ON — turning them all off made the model hang — so anything it reads without citing is
  invisible to this exclusion. What that reaches is bounded by opencode's project root, which
  is this repo. `fixture-notes/`, where every variant names its own varied dimension, lives in
  the benchmarks repo and is therefore outside it; reaching it *should* hit an
  `external_directory` prompt a non-interactive run cannot answer. **Should. Nothing has
  tested that, and nothing records what the scorer read.** The L2 version is a tool-call log,
  and it does not exist

**"Excluded" means dropped from the denominator, not scored as a null.** Which cells that is,
and what each outcome does to the rate, is one table in the decision rule below. It is there
rather than here because an exclusion is only meaningful next to the arithmetic it changes.

## Decision rule

Registered before data. What result produces KEEP / REJECT / INCONCLUSIVE?

> **The denominator is 20** — 4 categories × 5 variants, `known-good` excluded because it is
> the baseline rather than a submission. Of those 20, **3 are structurally null** (`test-quality`
> where no test file was submitted), so the *defect*-null rate — the one that says something
> about the anchors — is over **17**. Report both, always. A draft on 2026-08-27 said 24 after
> reconciling to the wrong side of a 20/24 split; see **Superseded: the six-cell population**.

<!-- TODO — yours. Suggested shape, not an answer:
     KEEP         if the null rate is at or under your predicted number AND each fixture
                  the ↓ cell in each column scores below the other cells in that column AND
                  the non-↓ cells in that column are equal to each other — without the second
                  half, a fixture that is simply worse everywhere satisfies KEEP while
                  discriminating nothing
     REJECT       if any category is constant across all five variants — it carries no
                  information regardless of how defensible its anchors read
     INCONCLUSIVE if nulls are concentrated in one category — that is a defect in that
                  category's anchors, not a verdict on the rubric
     Note what you would do differently in each case, or the rule decides nothing. -->

### What every outcome does to the arithmetic

The rule above is a rate, so every outcome has to say which tally it joins and what it does to
the denominator. Registered 2026-08-27 before any run, because "excluded" read two ways is a
33%-or-35% ambiguity and that flips a verdict on identical data.

**Three tallies, never one number.** A null is not a null: the three have different causes and
three different fixes, and a single rate makes them indistinguishable.

| Tally | What it means | What fixes it |
|---|---|---|
| **defect** | the anchor could not separate two scores from evidence the cell actually had | rewrite that anchor |
| **structural** | a score was impossible before any anchor was read — `test-quality` with no test file. Predicted at **3 of 20** | different fixtures, or drop the category |
| **wholesale** | nothing decided for a whole variant — every remaining cell `null`, a confirmed `empty`, or a `declared error` | rewrite the rubric, not an anchor |

| Outcome | Joins | Denominator | Verdict contribution |
|---|---|---|---|
| Cell scored 0–2 | — | counts in the 17 | feeds discrimination |
| Cell `null`, anchor undecidable | **defect** | counts in the 17 | feeds the defect rate |
| Cell `null`, `test-quality` with no test file | **structural** | in the 20, out of the 17 | none — predicted before the run |
| Every *remaining* cell `null` for a variant | **wholesale**, not defect | its cells leave the 17 | **REJECT** for that variant |
| `empty` (3) confirmed by a repeat | **wholesale**, not defect | its cells leave the 17 | **REJECT** for that variant |
| `declared error` (5) | **wholesale**, not defect | its cells leave the 17 | **REJECT** for that variant — the scorer named the rubric as the cause, which is the strongest form of the same finding |
| `off contract` (2) | — | **drops those cells** | none. The rubric did not decide and did not fail to decide; the scorer left the contract. Recorded as an instrument outcome |
| Cell that went hunting | — | **drops that 1** | none. The score exists but is not from the evidence the cell was given, so it is not a measurement of this rubric |
| Exit `1` or `4` | — | run discarded whole | none |
| `empty` (3) followed by a sheet | as the sheet | as the sheet | as the sheet — the first run was infrastructure and is recorded as such |

**Why wholesale is not just four defect nulls.** Folding it in reports "the anchors are
defective, X / 17" when the finding is "the rubric decided nothing at all for this variant".
Same arithmetic, different diagnosis, and the second one does not get fixed by rewriting an
anchor. The cell boundary in the Question section makes the same distinction one level down;
this is that distinction carried into the tally.

**Remaining, not four.** A variant whose cells are 3 nulls and 1 hunted has no cell left that
decided anything, and is wholesale on 3 of 3 — the hunted cell left the denominator, so "all
four null" would never fire and two readers would tally the same run differently. Record the
remaining-cell count with the verdict: wholesale on 4 of 4 and wholesale on 1 of 1 are not the
same claim, and the second is mostly a statement about how much of the variant was excluded.
For `test-quality`'s three structural nulls the same applies in advance: `good-inline-envelope`,
`good-nested-ifs` and `good-noisy-diff` each have 3 scoreable cells, not 4.

**A rate without its exclusion count is not a result.** Report all three tallies with the
denominator every time — `defect 6 / 17 (0 excluded) · structural 3 · wholesale 0` and
`defect 6 / 13 (4 excluded) · structural 3 · wholesale 1 variant` are different findings, and
the second is mostly a finding about the scorer rather than about the rubric.

<!-- TODO — yours: at what excluded-cell count does the run stop being interpretable at all?
     The shape is registered above; the threshold is a number, and numbers are yours. -->

**What the table registers, and what it does not.** It registers where each *outcome* is
filed — which cells count, which drop out, which fixtures are REJECT on their own. It
registers no *threshold*: the null rate that separates KEEP from the rest, and the score gap
that counts as discrimination rather than noise, are the TODO above and are yours. Both parts
are needed and neither substitutes for the other.

**The ordinary case has no verdict of its own, and that is deliberate.** A fixture with some
cells scored and some `null` is neither REJECT nor INCONCLUSIVE by itself — its cells feed the
rate, and the verdict comes from the threshold you register. REJECT-on-its-own is reserved for
a fixture where nothing decided at all; INCONCLUSIVE for nulls concentrated in one *category
across fixtures*. Everything else is arithmetic waiting on a number.

> **Why a wholesale-undecidable run is REJECT and not INCONCLUSIVE.** INCONCLUSIVE is
> reserved for nulls concentrated in one *category across fixtures*, which indicts that
> category's anchors rather than the rubric. A fixture that nulls in all four categories
> indicts the rubric. Without this line the same output could be read as a rubric defect, as
> infrastructure, or as an unregistered mode, and three readers reach three verdicts on
> identical data.

## The procedure, from #21

1. `./tools/opencode-review.sh -n 2 benchmark/rubrics/backend-quality.yaml` — critique the
   rubric before applying it
2. Score all **five variants** yourself, blind, into `E-001-blind-scores.yaml`, and commit
   before reading any scorer output. Read each one against `known-good` the way the scorer
   does — the baseline is your evidence too, not a sixth sheet to fill
3. `./tools/opencode-score.sh benchmark/rubrics/backend-quality.yaml <fixture>` on each
4. Compare. That gap is B1's exit-gate evidence — five gate-passing variants against the
   baseline, and against each other, not one point

---
*Everything below is filled in AFTER the runs.*
---

## Observed telemetry

## Results

Raw, then summary. **Median and p25/p75. Never an average alone.**

## Which predictions held

| # | Prediction | Held? | Actual |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

## Failure analysis

> Before blaming the instrument, ask what else changed.

## Sanity checks

- [ ] Did any dramatic number appear? Has it been explained *and* the explanation tested?
- [ ] Did any **flattering** number appear? Has it been disbelieved twice?
- [ ] Did the scorer agree with you suspiciously often? Check whether it read your scores.

## Decision

## Follow-up
