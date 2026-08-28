# Experiment E-001 — does the four-category rubric decide anything?

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`. We got
> that wrong once and voided nine runs.

**Status: unregistered. One blocker remains, and it is the predictions.**

1. ~~The rubric this experiment measures does not exist.~~ **Cleared 2026-08-27** — lab#21
   is written: `benchmark/rubrics/backend-quality.yaml` v2, sha `396e1799eb2b`, four
   categories, every anchor citable at `path:line` from the attachments alone. Drafted by
   Claude from the fixture sources at the user's request; the anchors have never been
   applied to anything, which is what E-001 exists to change. The rubric's own header
   carries forward the one thing it could not solve: `test-quality` holds 25 of the 100 and
   is decidable on two of the five variants.
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
what makes the one-cause property *auditable* — a reader can open a note and disagree with
a specific sentence. Auditable is not enforced; the layer note under the table says what that
is worth:

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
  [`tools/classify-model-output.sh`](../tools/classify-model-output.sh) for where the
  distinction now executes, and the decision rule for where the outcome is filed.
- **Constant** — the scorer emits a score, but the same score for every fixture. Looks like
  success. Carries no information. This is what killed 60% of the weight in the first draft
  and was only visible once the first failure was diagnosed.

**The cell boundary, stated once so two readers cannot split on it.** A sheet is a sheet when
it carries `scorer: lab-scorer` and a `categories:` block, *whatever is in the cells*. A sheet
of `null`s is a result and is tallied as nulls; it is not "no output". "No output"
means no `categories:` block at all, and that is a different class with a different exit code.

## Hypothesis

> **PROVENANCE — read this before using any of what follows.** The mechanism below was
> derived by Claude Opus 5 on 2026-08-28, at the author's request, and is **adopted, not
> independently derived**. It is recorded as adopted because an unrecorded adopted prediction
> measures nothing, and because the previous adopted set broke on an authoring error that
> went uncaught precisely because nobody derived it a second time. **Predictions 1–3 and the
> decision-rule thresholds were deliberately left blank by the same author for the same
> reason** — they leak expected cell values into the blind sheet, and this one does not.
> Check the mechanism against the evidence table below rather than taking it on trust.

**An anchor is decidable by this scorer iff its discriminating condition can be checked
against a token that appears in the attachment set.** The attachment set is `*.kt` under the
fixture, plus — since Decision B — `*.kt` under `known-good`. No diff, no test runner, no
evaluator output, no enum.

That one property has **two failure modes**, and the two nulls already on file are one of
each. This is why they look nothing alike on disk:

**(a) No referent at all.** The probe rubric's third category anchored on `1: "Reasonable."`
/ `2: "Good."` Those name a judgement, not a feature, so there is no token to look for and
no `path:line` to cite. The scorer nulled **that cell** and answered the other two.

**(b) A real referent that is absent.** The seven-category rubric cited `exit 12` and
`BE003ContractTest passes`. Both are perfectly concrete — they are simply not in the
attachment set. The scorer returned **an empty body**, not four nulls.

The difference between (a) and (b) is **a threshold, not a kind**. Under (a) the scorer still
has footing: most anchors are decidable, one is not, so it answers and marks the one. Under
(b) the majority of anchors point outside the evidence set, it has footing nowhere, and it
declines wholesale rather than emitting a sheet of nulls.

**What makes this falsifiable rather than a restatement:** wholesale-empty is a function of
the PROPORTION of undecidable anchors, not of their presence. Every v2 anchor names a
construct visible in the `.kt` files, so mode (b) cannot fire. **v2 should therefore never
come back empty, and every null it does produce should be per-cell.** A wholesale empty on
any variant falsifies the mechanism itself, not merely a number attached to it.

### Where the mechanism says the nulls will be

| category | referents its anchors name | in the attachment set? | null risk |
|---|---|---|---|
| architecture-consistency | `ApiException` subclasses, `ApiError`/`ApiErrorBody` construction, `check(`/`require(`/`!!`/`throw` | yes, all textual | low |
| maintainability | `when` position, `else` branch, exhaustiveness | yes, syntactic — and anchor 2 explicitly forbids counting against the enum, so the one hazard is pre-empted *in the anchor* | low |
| test-quality | assertions, response bodies, a second `get(...)`, `$.error.code` | yes for the two variants carrying a test file; the precondition fires for the other three | 3 structural, low defect |
| change-focus | every method identical to the baseline modulo whitespace; imports required BY SYMBOL | yes, but **only because Decision B attached the baseline** | **highest** |

`change-focus` concentrates the risk for two reasons that are not the same reason:

1. It is the only category requiring a **cross-tree comparison**, and Decision B was built
   2026-08-27 and has never been exercised in a scored run. The capability is new and
   unproven at the point this experiment depends on it.
2. "Imports required BY SYMBOL, not by declaration" is decidable in principle but requires
   resolving each import against `confirm`'s body. It is the most work any anchor in this
   rubric asks for, and effort is where a model hedges rather than where it errs.

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

> **These three are blank on purpose, and the blank is load-bearing.** Everything else in
> this file was filled on 2026-08-28 from an adopted mechanism, recorded as adopted under
> *Hypothesis*. These three were not, because each of them leaks an expected cell value into
> `E-001-blind-scores.yaml` — and a blind sheet written by someone who has read a prediction
> of its contents is not blind. The mechanism does the hard part; deriving these from it is
> the short step. Do not skip it.

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
| Rubric | `benchmark/rubrics/backend-quality.yaml` **v2 · sha `396e1799eb2b`** — four categories, written 2026-08-27 as lab#21, and closed over its own boundary gaps after `lab-acceptance` rejected the first cut for having three anchors that did not partition the space of submissions. The ladder is now total by rule: `0` if the 0 condition holds, `2` if every clause of 2 holds, `1` otherwise — so anchor 1's text illustrates the residual rather than defining it. Every anchor names a construct rather than a difference, because with the baseline attached "differs from `known-good`" is answerable without reading the rubric at all. The seven-category draft it replaces, sha `21aa658d030d`, stays in git history as the worked example of the two mistakes |
| Reviewing this record | two models since 2026-08-27: `lab-critic` on `ollama-cloud/glm-5.2` line-level, `lab-acceptance` on `ollama-cloud/minimax-m3` for the gate. Everything reviewed before that date was `deepseek-v4-pro` doing both jobs |
| Agent | `.opencode/agent/lab-scorer.md` · sha `cb371384fa19` — the same contract for both harnesses, body and all, never a paraphrase |
| **Harness** | **`codex`, registered 2026-08-28 before any scoring run.** See *Decision C* below. The harness is a variable in its own right, not a detail of the model: a sheet from `codex` and a sheet from `opencode` are not interchangeable, and comparing them measures the harnesses rather than the rubric |
| Preflight assertion | **L2.** `opencode-score.sh` fails when `--dir` repoints the project root and opencode silently falls back to the default full-tool agent exiting 0. The agent definition is L3; that guard is the L2 version |
| Control assertion | **L1 through this script, L3 outside it.** `opencode-score.sh` has no flag and no branch that reaches `--continue`, so a remembering scorer cannot be requested through the registered mechanism. Running `opencode run --continue` by hand bypasses it, and nothing detects that — the provenance header records `session: fresh` because the script wrote it, not because anything checked |
| Output guard | **L2, and it no longer collapses.** `tools/classify-model-output.sh score` returns one exit code per outcome: `0` contract met (all-`null` cells included), `2` off contract, `3` empty, `4` default-agent fallback, `5` the scorer declaring the rubric unusable. Only `1` and `4` are infrastructure. `tools/verify-model-output-classifier.sh` registers sixteen fixtures across the three agents' contracts, and CI runs it — a classifier that stopped discriminating would be indistinguishable from the single guard it replaced. The same check now guards `opencode-review.sh`, which had none |

### Decision C, 2026-08-28: `codex` is the scoring harness

Registered before a single cell has been scored, because after the first run this costs a
re-run rather than a paragraph.

**Why.** The scorer produces this experiment's actual numbers — the sheet your blind sheet is
read against. It ran only through `opencode run`, and on 2026-08-28 `opencode run` hung on
**five of eight** non-interactive calls across three model families. Five processes on this
machine were wedged for up to twelve days, each having burned about an hour of CPU before it
stopped returning, from other projects and other commands. In the panel run that prompted
this decision, **both opencode families stalled at the 600s budget and `codex` was the only
one that answered.** A single point of failure on the instrument that produces the
measurement is not a maintenance concern; it is the experiment being unable to run.

**What is held identical**, so the two harnesses are comparable at all: the contract is
`.opencode/agent/lab-scorer.md` itself; the evidence set is the rubric plus every source file
plus the `known-good` baseline, inlined to exactly what `-f` attaches; the gate filter is the
same registry check; and `known-good` is still scored with no baseline, with the prompt
saying so.

**What differs, and is the point.** A different agent loop, system prompt and turn shape —
and `--output-schema`, which forces the sheet's shape at the API. The opencode scorer is
*asked* for YAML in prose and usually complies. This one cannot do otherwise, which makes
`null` a value the schema admits rather than a behaviour the model has to remember. That is a
stronger contract, and it is a **difference between the two harnesses that must not be read
as a difference in the rubric.**

**The cost, registered rather than discovered.** `tools/opencode-score.sh` still exists and
still works. Every sheet records `harness:` in its provenance header. **Do not mix harnesses
within one comparison** — five fixtures scored by codex and one by opencode is a measurement
of the harnesses. If the harness has to change mid-experiment, every prior cell is void and
re-run, exactly as a model change would be.

**What this does not fix.** `opencode` still runs the acceptance gate and the line-level
critic, and still hangs. Those are reviews, not measurements: a stalled review costs time,
a stalled scorer costs the experiment. The panel's stall budget is the mitigation there.

## Controlled variables

- [x] benchmark revision — `agent-observatory-benchmarks` @ `ad1cc78`
- [x] task — BE-003-confirm-shipment
- [x] harness — **`codex` for scoring** (Decision C); `opencode` 1.18.21 for review only
- [x] model — `ollama-cloud/deepseek-v4-pro` (pin it; `LAB_REVIEW_MODEL` overrides, and an
      unpinned scorer model is an unregistered variable)
- [x] temperature — 0, set in the agent frontmatter
- [x] session — fresh per run
- [x] rubric sha — `396e1799eb2b`, `benchmark/rubrics/backend-quality.yaml` v2
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
**REGISTERED: n = 1 per fixture for this grid, plus a separate calibration that must run
before any 1-point gap is read as evidence.** (Adopted 2026-08-28 — see the provenance note
under *Hypothesis*.)

The reasoning, which matters more than the number: on a 0–2 integer scale the smallest
possible gap in any column is **exactly 1 raw point**. At n = 1 a 1-point gap and a single
cell flip are **literally the same observation**, and the scorer's run-to-run variance has
never been measured. So n = 1 does not make the grid worthless — it makes exactly one class
of result uninterpretable, and it is the smallest class.

Registering n = 1 without saying that would be the dishonest version. It is registered here
**with** the consequence: *until the calibration below exists, a 1-point gap in this grid is
not evidence of discrimination.* A 2-point gap is unaffected and is what the ↓ cells are
designed to produce.

**The calibration**, which the doc is right to call a separate experiment: one fixture, this
rubric, the scorer run twice. Its only job is to say whether a cell flips. It must run
**after the blind sheet is committed**, because it produces scorer output, and reading any
scorer output before the sheet is committed voids the comparison.

## Minimum detectable effect

| Outcome | MDE | Registered before the run? |
|---|---|---|
| primary: score gap between a column's **↓** cell and the other cells in that column | **1 raw anchor point** — set by the instrument, not chosen. But **2 points** until the calibration under *Runs* exists, because at n = 1 a 1-point gap is indistinguishable from a cell flip | yes — 2026-08-28, adopted |
| secondary: defect-null rate across the 17 scoreable cells | **1 cell**, expressed as a count and never as a percentage | yes — 2026-08-28, adopted |
| secondary: structural nulls, predicted at 3 of 20 | **0** — these are not detected, they are predicted. Any value other than exactly 3 is a finding about Decision A's precondition, which is L3 and executes nothing | yes — 2026-08-28, adopted |

**The arithmetic, from the rubric's own formula** at `backend-quality.yaml:77` —
`score = 100 * sum(w_i * s_i) / (2 * sum(w_i))`, nulls excluded from both sums. One raw
anchor point is worth:

| category | all four scored | `test-quality` null |
|---|---|---|
| architecture-consistency | 17.50 | 23.33 |
| maintainability | 12.50 | 16.67 |
| test-quality | 12.50 | — |
| change-focus | 7.50 | 10.00 |

**Three consequences, and the first is the one that decides the MDE.**

**The primary MDE was never a free choice.** Columns are categories, cells are variants, and
scores are integers on 0–2. The smallest non-zero gap in any column is 1 point; there is no
finer effect for this instrument to resolve. The real question is not *how small a gap can
be seen* but *how small a gap can be believed*, and that is a question about variance, which
is why this row is coupled to the n = 1 decision above rather than standing on its own.

**Renormalisation makes the totals lie to you.** A three-category variant scored over weight
75 and a four-category variant scored over weight 100 can both total exactly 100. The rubric
warns about this at line 80; the arithmetic above is why. The primary outcome compares
*within* a column and so is immune — **any total reported later is not.**

**The same point is worth different amounts in different variants.** `architecture-consistency`
moves the total 17.50 where all four score, and 23.33 in the three variants where
`test-quality` nulls structurally. Two variants are therefore being measured on differently
scaled instruments, which is a fact about the fixture set rather than about the rubric, and
it is the arithmetic behind benchmarks#22.

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

<!-- TODO — yours. The THRESHOLDS are the blanks. The structure is registered, because
     two earlier forms of it could not fire on the data this grid produces.

     KEEP         if the defect-null rate is at or under your predicted number
                  AND in each column the ↓ cell scores below the other SCORED cells
                  AND those other scored cells are equal to each other
                  AND the ↓ cell's evidence cites the construct its anchor names, not
                      merely a difference from the baseline

                  The first two together: without the second, a variant that is simply
                  worse everywhere satisfies KEEP while discriminating nothing. The fourth
                  is the one Decision B made necessary. With `known-good` in the evidence
                  set a scorer can mark the ↓ cell low because it DIFFERS from the baseline
                  rather than because it violates the convention the anchor names — an
                  easier task and a different measurement. Both KEEP sub-conditions fire
                  either way, so without this clause the experiment declares success on the
                  contamination Decision B registered as its own cost. Prediction 3 is the
                  trap for it.

     REJECT       if any category is constant across the cells that CARRY A SCORE in it
                  — not "across all five variants". `test-quality`'s five cells are three
                  structural nulls and the strong/weak pair, so "constant across all five"
                  can never fire, and the grid's only two-cell comparison would have had no
                  REJECT guard at all: strong and weak both scoring 1 would pass unnoticed

     INCONCLUSIVE if defect nulls are concentrated in one category — a defect in that
                  category's anchors, not a verdict on the rubric
                  OR if a ↓ cell is low but its evidence cites only a difference from the
                  baseline. That column measured the contamination, not the rubric, and
                  neither KEEP nor REJECT is a statement about the anchors

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

**REGISTERED (adopted 2026-08-28 — see the provenance note under *Hypothesis*): the run
stops being interpretable at EITHER of two conditions, whichever comes first.**

1. **5 or more of the 17 scoreable cells excluded.** Five is one full column's worth, and at
   12 remaining cells one null is worth 8.3% against the 5.9% the design registered — the
   resolution of the secondary outcome has degraded by more than a third, so a rate computed
   over it is not the rate this experiment set out to measure.
2. **Any column losing its ↓ cell**, at any exclusion count. The primary outcome is the ↓
   cell against the others in its column; without the ↓ cell the column has no comparison to
   make, and three intact columns plus one absent one is not a weaker version of the result.
   `test-quality` is stricter still by construction: it has two cells, so losing *either* one
   ends that column.

Both are structural rather than statistical, which is deliberate — a threshold expressed as a
percentage drifts as cells drop out, and the count it is computed over is exactly what is
moving.

**What the table registers, and what it does not.** It registers where each *outcome* is
filed — which cells count, which drop out, which fixtures are REJECT on their own.

**The score gap that counts as discrimination is now registered** under *Minimum detectable
effect*: 1 raw anchor point, and 2 until the calibration run exists, because at n = 1 a
1-point gap and a cell flip are the same observation. **The null rate that separates KEEP
from the rest is still blank and is still yours**, because it is a restatement of
prediction 1 and cannot be written without it. Both parts are needed and neither substitutes
for the other.

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
