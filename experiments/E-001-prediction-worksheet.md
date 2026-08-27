# E-001 — deriving the predictions instead of guessing them

Not part of the experiment record. This is the working that produces the numbers you write
into `E-001-rubric-null-rate.md`, kept so the derivation is auditable rather than a number
that appeared.

The null rate is not one intuition. It is 20 small decidability judgements, and you already
have the facts for most of them. Fill the grid, count, and the count **is** the prediction.

---

## The question for every cell

> **Read this with Decision B in force** — it was written before that decision and describes
> the pre-Decision-B evidence set. Since 2026-08-27 `known-good` IS beside the fixture, in
> your evidence set and the scorer's. Judge with it.
>
> Given the `.kt` files under this one fixture — and, since Decision B, `known-good` beside it,
> no test runner, no evaluator output — can this category's anchor separate a 0 from a 1 from
> a 2, and can I cite `path:line` for the answer?
>
> **Yes → scoreable. No → the scorer will null it, and it should.**

Mark each cell `S` (scoreable), `N` (will null), or `?` (you genuinely do not know — those are
the interesting ones, and a `?` is a finding about the anchor).

## What each fixture actually hands the scorer

| Fixture | Files attached | Test file? | Differs from `known-good` in |
|---|---|---|---|
| `known-good` | `ApiError.kt`, `ShipmentController.kt` | **no** | — the reference |
| `good-inline-envelope` | `ApiError.kt`, `ShipmentController.kt` | **no** | builds the envelope by hand, returns `ResponseEntity` instead of throwing |
| `good-nested-ifs` | `ApiError.kt`, `ShipmentController.kt` | **no** | exhaustive `when` → `if`/`else if`; the comment explaining the idempotent repeat deleted |
| `good-noisy-diff` | `ApiError.kt`, `ShipmentController.kt` | **no** | `confirm()` character-identical; `create`, `getById`, `list` restyled |
| `good-strong-tests` | + `ConfirmShipmentTest.kt` | yes | **production code byte-identical to `known-good`** (verified); tests call confirm twice, assert the envelope, re-read the shipment |
| `good-weak-tests` | + `ConfirmShipmentTest.kt` | yes | **production code byte-identical to `known-good`** (verified); tests assert almost nothing |

> `lab-critic` flagged that the record asserted "differs on exactly one dimension" without
> the artifact stating whether the two test variants also change production code — a reader
> had to go and look. Both were diffed on 2026-08-27: `ApiError.kt` and `ShipmentController.kt`
> are identical to `known-good` in both. The one-cause property holds.

## The grid — 20 cells

`known-good` is the **baseline**, not a row. Three cells are already settled by Decision A
below. Seventeen judgements are left.

|  | arch-consistency (35) | maintainability (25) | test-quality (25) | change-focus (15) |
|---|---|---|---|---|
| `good-inline-envelope` | | | **N** *(predicted)* | |
| `good-nested-ifs` | | | **N** *(predicted)* | |
| `good-noisy-diff` | | | **N** *(predicted)* | |
| `good-strong-tests` | | | | |
| `good-weak-tests` | | | | |

**Count of `N` + half your `?`s → prediction 1.** Three are predicted already — predicted, not
fixed — and they are structural, so report them separately from the defect nulls: the rate
that says something about the anchors is over the **17** cells where a score was possible.

> **The degenerate cell, resolved 2026-08-27.** An earlier version of this grid had a sixth
> row and asked what to do about scoring `known-good` against itself: "It is one cell, but it
> changes the denominator." It changed four. Scoring the baseline was only ever needed while
> the variant-to-reference comparison had to happen *between sheets*; Decision B put the
> baseline inside every variant's evidence set, so the sixth row lost its consumer. Two of its
> cells were structural nulls and the other two would have been the only cells in the grid
> produced from a one-tree evidence set. `known-good` left the population. Denominator 20.

---

## Two decisions that move whole rows before you count

Both settled on 2026-08-27, before any anchor was written. Recorded here with the
consequence each one carries.

### A. `test-quality` on a fixture with no test file — **DECIDED 2026-08-27: null**

The anchors carry a precondition. A submission with no test file in the evidence set is
undecidable for this category and the scorer emits `null`, not `0`. Absence is not a low
score — asserting `0` would be a claim about tests that were never submitted, which is the
same shape as a gap reading as a zero.

```yaml
test-quality:
  precondition: at least one test file in the evidence set
  if absent -> score: null, reason: no tests submitted
  0: tests exist but assert only status codes
  1: asserts the response body, single call path
  2: calls confirm twice and compares; asserts the error envelope; re-reads the shipment
```

**Consequence:** 25% of the weight rests on a single pair. Whether that is enough to call
`test-quality` discriminating is a real question for the decision rule.

> **Corrected 2026-08-27 after `lab-critic` flagged it, L2.** An earlier version of this
> paragraph said the four no-test cells were *"guaranteed nulls"* and that the scorer
> *"emits `null`, not `0`"*. That was false in the specific way this project keeps
> re-learning. The precondition is a line of YAML read by a language model. **Nothing
> executes and rejects a `0`.** It is Layer 3, and "guaranteed" was a prediction about
> model behaviour wearing a control's clothes.
>
> So the three cells are **predicted** nulls, not guaranteed ones — which is better, because
> now the prediction can be wrong. If the scorer emits `0` for a fixture that submitted no
> tests, prediction 1 is falsified and the finding is about the anchors, not the model.
>
> The L2 version, if this matters after the run: a post-processing check on the scorer's
> YAML that fails any `test-quality` score that is not `null` when the attachment set
> contains no test file. Not built. Do not describe it as if it were.

### B. `change-focus` with no diff — **DECIDED 2026-08-27: attach `known-good` as the baseline**

`opencode-score.sh` attaches the `known-good` tree alongside the fixture, so a change is
visible and the anchor can be cited at `path:line` in both trees. **Built 2026-08-27** — it
was decided, written here and in the record as though already done, and the script attached
only the fixture until that commit. A missing baseline now fails the run. The baseline is another
submission, not evaluator output, so the scorer stays orthogonal to the gates.

```
-f rubric.yaml  -f <fixture>/**.kt  -f known-good/**.kt
anchor: "Methods the ticket did not name are character-identical to the baseline."
```

**Registered risk — this is the cost of the decision, not an argument against it.** A baseline
in the evidence set is available to *all four* categories, not only `change-focus`. It may turn
`architecture-consistency` and `maintainability` from "judge this submission" into "spot the
difference", which is an easier task and a different measurement. Two consequences to watch:

- discrimination may improve for a reason that is not the rubric working
- the scorer is effectively told which tree is the reference, which is a strong hint

Scoping the baseline to `change-focus` in the rubric text is **L3** — the scorer may read the
whole evidence set regardless. If this matters, the L2 version is a separate baseline-free
pass for the other three categories. **Prediction 3 is where this gets caught:** if agreement
on `architecture-consistency` and `maintainability` is far higher than the probe run's, suspect
the baseline before crediting the anchors.

---

## Prediction 2 — discrimination

The comparison is **within the five**, not against `known-good`. All five variants are scored
under identical conditions — same rubric, same baseline attached — so their cells are
commensurable with each other. `known-good` has no sheet to compare against, and would not be
commensurable if it had one.

For each column, will the scorer put the depressed variant **below the other cells in that
column**?

| Column | Depressed by | Compared against | Your call | Least confident? |
|---|---|---|---|---|
| arch-consistency | `good-inline-envelope` | the other four variants | | |
| maintainability | `good-nested-ifs` | the other four variants | | |
| test-quality | `good-weak-tests` | `good-strong-tests` only — the other three are structural nulls | | |
| change-focus | `good-noisy-diff` | the other four variants | | |

And the one that actually matters: **which category will be constant across all five?** A
constant category looks like a working score and carries no information — it is the failure
that hid behind the undecidable one last time.

## Prediction 3 — agreement with your blind scores

Of the 20 cells, how many will you and the scorer land on exactly? Where do you expect to
diverge, and in which direction — will it score higher than you, or lower?

The critic under-reported at temperature 0 rather than hallucinating: 2 of 12 section-runs
flipped, and both flips were real findings the earlier run missed. Whether the scorer shares
that bias is a separate question, and this is where you find out.

---

## The mechanism

For each number above, one sentence: **why**. Not "I think about 6" — "6, because
`test-quality` nulls on the three variants with no tests, and `change-focus` holds elsewhere
because X."

*A hypothesis without a mechanism cannot be interestingly wrong.*
