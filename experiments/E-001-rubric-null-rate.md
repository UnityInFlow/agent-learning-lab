# Experiment E-001 — does the four-category rubric decide anything?

> **Fill in everything down to and including Predictions BEFORE the first run.**
> Commit it, and check the commit timestamp precedes the first run's `startedAt`. We got
> that wrong once and voided nine runs.

**Status: unregistered. One blocker remains, and it is the predictions.**

1. **Predictions below are empty.** Do not run `opencode-score.sh` until they are filled in
   and committed, and check the commit timestamp precedes the first run.
2. ~~benchmarks#20 — the fixtures named their own varied dimension in a comment the scorer
   reads.~~ **Cleared 2026-08-27** by benchmarks#21 (`8aadc75`): all eight fixtures now open
   with the same neutral class doc and the prose moved to `fixture-notes/`, outside the
   overlay. It was eight fixtures, not four — `good-strong-tests` announced itself without
   the phrase that had been grepped for, and `known-good` labelled itself the reference.

This is the first record in `experiments/`. B1 is the experiment contract, so the first
experiment it produces is about the instrument rather than about an agent — there is no
agent until stop 10.

## Question

Applied to five submissions that all pass every gate, does the four-category rubric produce
scores that **differ between fixtures**, and does the second scorer produce them **at all**?

Two failure modes, and they are not the same:

- **Undecidable** — the scorer emits `null` because an anchor cites something it cannot see.
  Its contract working, and a rubric defect.
- **Constant** — the scorer emits a score, but the same score for every fixture. Looks like
  success. Carries no information. This is what killed 60% of the weight in the first draft
  and was only visible once the first failure was diagnosed.

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
| **The attachment set is `*.kt` under the fixture — nothing else.** No diff, no test runner, no evaluator output, no `known-good` to compare against. Each fixture is scored in isolation | `tools/opencode-score.sh` |
| **Four of six fixtures carry no test files at all.** `known-good`, `good-inline-envelope`, `good-nested-ifs` and `good-noisy-diff` attach 2 files each; only the two test variants attach 3 | `find` over `fixtures/` |
| ~~All eight fixtures announced their own varied dimension in a class KDoc the scorer reads~~ — **fixed 2026-08-27**, benchmarks#21. They now share one neutral class doc; the prose lives in `fixture-notes/`, outside the scorer's glob | benchmarks#20 |

So the instrument has nulled for a vague anchor, nulled wholesale for undecidable anchors,
and under-reported at temperature 0. It has never yet been shown to **discriminate between
two submissions**, because until benchmarks#10 there was only one it was allowed to score.

Three of those rows constrain the answer before any intuition does. The derivation grid
is in [`E-001-prediction-worksheet.md`](E-001-prediction-worksheet.md) — 24 cells, of which
four are already predicted and seventeen are yours.

- **`change-focus` had no diff to look at** — the scorer sees one fixture's final files, and
  whether `create` was "restyled for no reason" is a statement about a change. **Decision B,
  2026-08-27: `known-good` is attached as a baseline**, so the change is visible and the
  anchor is citable at `path:line` in both trees. The cost is registered in the worksheet: a
  baseline is available to *all four* categories, not only this one, and may turn
  `architecture-consistency` and `maintainability` into spot-the-difference — an easier task
  and a different measurement. Prediction 3 is the trap for it.
- **`test-quality` has no tests to look at in four of six fixtures.** **Decision A,
  2026-08-27: the anchors carry a precondition — no test file means `null`, not `0`.** A `0`
  would assert the tests are bad when none were submitted. Those four cells are *predicted*
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

1. **Null rate.** Of the 4 categories × 6 fixtures = **24 cells**, how many come back `null`?
   (Six, not five: `known-good` is the reference every other cell is read against, so it is
   scored too.)
   <!-- TODO: number + mechanism -->
2. **Discrimination.** Does each fixture's intended dimension score lower than `known-good`
   on that dimension and equal elsewhere? Name the pair you are least confident about.
   <!-- TODO -->
3. **Agreement with your blind scores.** How many of the 24 cells will the scorer and you
   agree on exactly, and where will you diverge?
   <!-- TODO -->

*A prediction you did not write down is always retroactively correct.*

## Independent variable

The fixture. Everything else is held: same rubric, same scorer agent, same model, same
prompt, fresh session per run.

**One thing.** Each of the five fixtures differs from `known-good` on exactly one dimension,
which is the property benchmarks#10 was built to provide — an observed score difference has
one candidate cause.

## How the treatment is delivered — and proved

| | |
|---|---|
| Mechanism | `opencode run --agent lab-scorer -m <model>` with the rubric and the changed source files attached |
| Rubric | `benchmark/rubrics/backend-quality.yaml` · sha `21aa658d030d` **(pre-rewrite — record the new sha here once #21 lands)** |
| Reviewing this record | two models since 2026-08-27: `lab-critic` on `ollama-cloud/glm-5.2` line-level, `lab-acceptance` on `ollama-cloud/minimax-m3` for the gate. Everything reviewed before that date was `deepseek-v4-pro` doing both jobs |
| Agent | `.opencode/agent/lab-scorer.md` · sha `cb371384fa19` |
| Preflight assertion | `opencode-score.sh` fails when `--dir` repoints the project root and opencode silently falls back to the default full-tool agent exiting 0. The agent definition is L3; that guard is the L2 version |
| Control assertion | Fresh session every run, never `--continue`. A scorer that remembers its last sheet is not an independent second scorer |
| Output guard | The script fails the run when opencode exits 0 having produced no scores, rather than reporting an empty success |

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

The critic disagreed with itself on 2 of 12 section-runs at temperature 0, so a single run is
a lower bound rather than a value. `opencode-score.sh` has no `-n`; `opencode-review.sh` does.
<!-- TODO: decide whether one run per fixture is enough here, and say why. -->

## Minimum detectable effect

| Outcome | MDE | Registered before the run? |
|---|---|---|
| primary: score gap between a fixture and `known-good` on its own dimension | | |
| secondary: null rate across the 24 cells | | |

<!-- TODO: a 0–2 scale with weights 35/25/25/15 means one category moving by 1 point moves
     the normalised total by a fixed amount. Work out what that is per category, and decide
     what gap you would call a real difference rather than noise. -->

## Deterministic evaluation

None. **This experiment has no deterministic evaluator, by design** — that is the whole
reason it exists. `evaluator.sh` has already decided pass/fail for all five fixtures, and all
five passed. What is being measured here is whether a *non-deterministic* instrument can
discriminate among things a deterministic one cannot.

The check on the rubric is agreement with an independent human scorer, which is why step 2
below is blind.

## Exclusions

Registered now, not after seeing the data:

- A run where opencode exits non-zero, or exits 0 with no scores — infrastructure, re-run,
  do not score
- A run against a fixture that does not pass `evaluator.sh` — the rubric only scores
  gate-passing submissions and `known-bad-*` are not in the population
- A cell where the scorer's `evidence` cites a file not in the attachment set — it went
  hunting, and the result is not from the evidence it was given

## Decision rule

Registered before data. What result produces KEEP / REJECT / INCONCLUSIVE?

> **The denominator is 24** — 4 categories × 6 fixtures, `known-good` included. Every rate
> below is over 24. An earlier draft said 20 in the MDE table and 24 here; on 8 observed
> nulls that is 33% or 40%, and two reviewers reading different sections first reach opposite
> verdicts on identical data. `lab-acceptance` caught it, blocking, on 2026-08-27.

<!-- TODO — yours. Suggested shape, not an answer:
     KEEP         if the null rate is at or under your predicted number AND each fixture
                  scores below known-good on its own dimension AND is equal to it elsewhere
                  — without the second half, a fixture that is simply worse everywhere
                  satisfies KEEP while discriminating nothing
     REJECT       if any category is constant across all six fixtures — it carries no
                  information regardless of how defensible its anchors read
     INCONCLUSIVE if nulls are concentrated in one category — that is a defect in that
                  category's anchors, not a verdict on the rubric
     Note what you would do differently in each case, or the rule decides nothing. -->

## The procedure, from #21

1. `./tools/opencode-review.sh -n 2 benchmark/rubrics/backend-quality.yaml` — critique the
   rubric before applying it
2. Score all **six** fixtures yourself, blind, into `E-001-blind-scores.yaml`, and commit
   before reading any scorer output. Six, not five: `known-good` is the reference every other
   cell is read against, so it has to be scored too or there is nothing to compare against
3. `./tools/opencode-score.sh benchmark/rubrics/backend-quality.yaml <fixture>` on each
4. Compare. That gap is B1's exit-gate evidence — five gate-passing variants against the
   reference, not one point

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
