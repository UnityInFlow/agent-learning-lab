# E-001 — deriving the predictions instead of guessing them

Not part of the experiment record. This is the working that produces the numbers you write
into `E-001-rubric-null-rate.md`, kept so the derivation is auditable rather than a number
that appeared.

The null rate is not one intuition. It is 24 small decidability judgements, and you already
have the facts for most of them. Fill the grid, count, and the count **is** the prediction.

---

## The question for every cell

> Given **only** the `.kt` files under this one fixture — no diff, no `known-good` beside it,
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
| `good-strong-tests` | + `ConfirmShipmentTest.kt` | yes | tests call confirm twice, assert the envelope, re-read the shipment |
| `good-weak-tests` | + `ConfirmShipmentTest.kt` | yes | production code character-identical to `known-good`; tests assert almost nothing |

## The grid — 24 cells

|  | arch-consistency (35) | maintainability (25) | test-quality (25) | change-focus (15) |
|---|---|---|---|---|
| `known-good` | | | | |
| `good-inline-envelope` | | | | |
| `good-nested-ifs` | | | | |
| `good-noisy-diff` | | | | |
| `good-strong-tests` | | | | |
| `good-weak-tests` | | | | |

**Count of `N` + half your `?`s → prediction 1.**

---

## Two decisions that move whole rows before you count

Settle these first; each one changes 6 cells at a stroke.

### A. `test-quality` on a fixture with no test file

Four of six fixtures attach no tests. The scorer will do one of:

- emit `null` — "the evidence set contains no tests, I cannot judge their quality"
- emit `0` — which asserts the tests are bad, when what is true is that none were submitted

Those are different claims and only one is honest, but **which one happens is a property of
the anchors you write**, not of the model. Decide, then write the anchor so the scorer cannot
do the other.

### B. `change-focus` with no diff

`change-focus` is a statement about a *change*. The scorer sees one final tree. So either:

- the anchor becomes an **intrinsic** property — something visible in the file itself, e.g.
  "methods the ticket did not name show restyling inconsistent with the rest of the file" — or
- the category nulls for all six, and 15% of the weight carries nothing

Whether an intrinsic anchor is even decidable is worth a look before you commit: open
`good-noisy-diff/…/ShipmentController.kt` and ask yourself, without `known-good` beside it,
whether you could tell `create` had been restyled.

---

## Prediction 2 — discrimination

For each pair, will the scorer put the variant **below** `known-good` on that dimension?

| Pair | Dimension | Your call | Least confident? |
|---|---|---|---|
| `good-inline-envelope` vs `known-good` | arch-consistency | | |
| `good-nested-ifs` vs `known-good` | maintainability | | |
| `good-weak-tests` vs `good-strong-tests` | test-quality | | |
| `good-noisy-diff` vs `known-good` | change-focus | | |

And the one that actually matters: **which category will be constant across all six?** A
constant category looks like a working score and carries no information — it is the failure
that hid behind the undecidable one last time.

## Prediction 3 — agreement with your blind scores

Of the 24 cells, how many will you and the scorer land on exactly? Where do you expect to
diverge, and in which direction — will it score higher than you, or lower?

The critic under-reported at temperature 0 rather than hallucinating: 2 of 12 section-runs
flipped, and both flips were real findings the earlier run missed. Whether the scorer shares
that bias is a separate question, and this is where you find out.

---

## The mechanism

For each number above, one sentence: **why**. Not "I think about 6" — "6, because
`test-quality` nulls on the four fixtures with no tests, and `change-focus` holds elsewhere
because X."

*A hypothesis without a mechanism cannot be interestingly wrong.*
