# BE-005 rubric fixture proof — RESULT: **three dimensions separate, `change-focus` DOES NOT.**

**This is a §7 halt under author decision 9** — *"a dimension that does not separate is a §7 halt,
not something to edit past"* — and the rubric is therefore **NOT registered**. No B8a run is
scored, decision 11 is **not** recorded as adopted, and §4 step 1 is not opened.

Rubric under proof: `benchmark/rubrics/backend-quality-be005.yaml`, version `2-be005`,
sha **`945817b8c509`**. Predictions: `PREDICTIONS.md`, committed at **`300b6ca`,
2026-09-25T05:30:15Z** — before the first sheet, whose `scored_utc` is **`20260925T053037Z`**.
Seven codex calls, exit 0 each, `codex-cli 0.154.0`, one sheet per fixture, codex and nothing
else (author decision 10.2). Benchmarks tree at `main` = `2fc445d`, with
`verify-evaluator.sh` re-run there this session at 17 of 17.

## The measured cells, all 28

Every cell was read twice, independently: once by the scoring subagent from the sheet it wrote,
and once by me with `grep` over the same seven files. **The two readings agree on all 28 cells.**
`P` is the prediction registered in `PREDICTIONS.md`; a cell in **bold** is one where the
measurement refutes it.

| fixture | architecture-consistency | maintainability | test-quality | change-focus |
|---|---|---|---|---|
| `known-good` | 2 (P 2) | 2 (P 2) | `null` (P `null`) | `null` (P `null`) |
| `good-inline-envelope` | 0 · V (P 0) | 2 (P 2) | `null` (P `null`) | **1** (P 2) |
| `good-stored-consistent` | 0 · V (P 0) | 2 (P 2) | `null` (P `null`) | **0** (P 2) |
| `good-nested-ifs` | 2 (P 2) | 0 · V (P 0) | `null` (P `null`) | **0** (P 2) |
| `good-noisy-diff` | 2 (P 2) | 2 (P 2) | `null` (P `null`) | 0 · V (P 0) |
| `good-strong-tests` | 2 (P 2) | 2 (P 2) | 1 · V (P 1) | 2 (P 2) |
| `good-weak-tests` | 2 (P 2) | 2 (P 2) | 0 · V (P 0) | 2 (P 2) |

Sheets, in scoring order: `findings/codex/score-known-good-20260925T053037Z.yaml`,
`…score-good-inline-envelope-20260925T053121Z.yaml`,
`…score-good-stored-consistent-20260925T053141Z.yaml`,
`…score-good-nested-ifs-20260925T053210Z.yaml`,
`…score-good-noisy-diff-20260925T053230Z.yaml`,
`…score-good-strong-tests-20260925T053301Z.yaml`,
`…score-good-weak-tests-20260925T053326Z.yaml`. Every one carries `rubric_sha: 945817b8c509`.

## The four separation rows

| dimension | row | verdict |
|---|---|---|
| architecture-consistency | `good-inline-envelope` 0 and `good-stored-consistent` 0, each strictly below all five non-varying cells (all 2) | **SEPARATES** |
| maintainability | `good-nested-ifs` 0, strictly below the other six (all 2) | **SEPARATES** |
| test-quality | `good-weak-tests` 0 strictly below `good-strong-tests` 1; the five no-test-file fixtures `null` and excluded | **SEPARATES** |
| change-focus | `good-noisy-diff` 0 is **NOT** strictly below `good-stored-consistent` 0 or `good-nested-ifs` 0 | **DOES NOT SEPARATE** |

## Both registered predictions most likely to be wrong held; three I did not flag were refuted

- **`good-strong-tests` at `test-quality` = 1 held exactly.** The scorer applied the fifth clause
  (e) — the amendment read-back — and no fixture's tests call `PUT /orders/{orderId}/quantity`, so
  anchor 2 is unreached by any fixture, as the port note predicted before the run. The dimension
  still separates at 1 versus 0.
- **`good-stored-consistent` at `architecture-consistency` = 0 held.** This was named as the single
  most consequential cell in the table: it is the only variant whose defect **every gate passes**,
  and the rubric is the only instrument that can see it. It sees it, at anchor 0, citing the three
  shipment-side write sites: *"Shipment create, deliver, and cancel add unrequired stored-fulfilment
  writes"*. B8a's registered outcome can live in this dimension.
- **Refuted: `good-inline-envelope`, `good-stored-consistent` and `good-nested-ifs` on
  `change-focus`** — predicted 2, 2, 2; measured 1, 0, 0. All three in one column, and together
  they are the failure.

## Why `change-focus` cannot separate here, and it is not a scorer error

The two 0-cells are not noise. The scorer names its reason and cites both trees:

- `good-stored-consistent`: *"Shipment create, deliver, and cancel add unrequired stored-fulfilment
  writes"*, evidence `good-stored-consistent/shipment/ShipmentController.kt:68,88,98;
  known-good/shipment/ShipmentController.kt:61,84,88`.
- `good-nested-ifs`: *"withFulfilment, shipment create, and transition contain unrequired
  rewrites"*, evidence `good-nested-ifs/OrderController.kt:112; known-good/OrderController.kt:112;
  good-nested-ifs/ShipmentController.kt:45; known-good/ShipmentController.kt:45`.

**Both citations name `known-good` as the tree compared against, and that is what the harness
attaches.** `tools/codex-score.sh:161` sets `BASELINE="$(dirname "$TARGET")/known-good"` when the
target is a fixture, and the prompt labels it *"The BASELINE submission — the reference, NOT the
work under test"* (`:251`). In the `--run-id` path the same variable is empty and the baseline is
instead the **pre-agent HEAD of the changed files** (`:158-159`, Decision D).

So `change-focus` is the one dimension whose meaning changes with which reference is attached:

- against the **pre-agent HEAD** — what a real run is scored against — it asks *did the agent touch
  what no clause required?*, which is the construct;
- against **`known-good`** — what a fixture is scored against — it asks *does this differ from the
  reference solution?*, which **every quality variant does by construction, since each one is
  `known-good` plus one defect.**

The draft's change #4 is what exposed this. BE-004's anchor 0 fired only on *"two or more **unnamed**
methods"*, and the other variants' defects sit in methods the ticket names, so they never tripped
it — the draft says so itself while explaining why the qualifier had to go: BE-005's ticket names
nearly every method, so *"the BE-004 anchor 0 ('two or more unnamed methods') would score
`good-noisy-diff` 1 and the variant would not separate"*. Dropping the qualifier fixed
`good-noisy-diff` and removed the only thing that was keeping the dimension orthogonal under a
`known-good` baseline. **BE-004's `change-focus` row passed for a reason unrelated to what it
claimed to prove**, which is this project's house failure mode pointed at its own instrument.

## What was NOT done, and why each is the author's

Author decision 9 says a non-separating dimension is a halt, **not something to edit past**, and
that sentence is aimed exactly at what is tempting here. So:

- **The `change-focus` anchor was not narrowed until it separated.** Fitting an anchor to the
  fixtures makes the proof a tautology. The change that would do it — restoring some form of
  BE-004's "unnamed" qualifier, or exempting differences another dimension already penalises — is a
  rubric design decision on a task whose fixtures are the author's.
- **The proof procedure was not changed either.** Attaching the pre-agent tree instead of
  `known-good` for `change-focus` alone would very likely separate it, and may well be the right
  reading of the dimension — but that changes what a registered instrument's proof means, and
  `tools/codex-score.sh` is the harness both tasks' numbers come from. It is not the builder's to
  move mid-track.
- **No fixture was edited.** A benchmark fixture is a registered variable (§6) and BE-005 is the
  author's build.
- **The sha was not registered and decision 11 was not recorded as adopted.** The author's standing
  instruction's `>= 3 WRONG` branch orders the port, then the proof, then the registration; the
  proof did not pass, so the third act does not happen.

## Three ways forward, all the author's, with what each costs

1. **Narrow `change-focus` and re-prove.** Cheapest in money (seven codex calls, a few dollars)
   and the most dangerous epistemically: any narrowing chosen after seeing these cells is fitted
   to them. If it is taken, the honest form is to write the new anchor and its predicted 28 cells
   **before** re-scoring, as this proof did.
2. **Score `change-focus` against the pre-agent tree in fixture mode.** Arguably a correction
   rather than a fit — it makes the fixture proof ask the question a run is scored on. Costs a
   harness change (`codex-score.sh`, plus `opencode-score.sh` to keep the second reader
   comparable), its own fixture set proving the new branch, and a re-score of BE-004's proof to
   see whether *its* `change-focus` row survives the same treatment.
3. **Register the rubric with `change-focus` marked `unmeasured`, and take B8a's registered
   outcome from `architecture-consistency`.** The trap B8a exists for — the stored/placeholder
   fulfilment shape that Gate B′ caught 4 of 5 times — lands in `architecture-consistency`, which
   separated, and `good-stored-consistent`'s 0 is the proof that the anchor sees the exact defect.
   This is the precedent author decision 10.3 set when it carved `change-focus` out of the
   Decision H fallback and made such a cell *"unmeasured"* rather than computed. It costs nothing
   and it narrows what B8a can claim — the 15 % weight would carry no measurement, so the weighted
   total is not comparable to BE-004's.

Option 3 is the only one that needs no new instrument and no re-score, and it has a precedent in
the author's own decision 10.3. **It is still not mine to take**: it changes what the registered
rubric measures, and B13's `quality_score` clause reads the weighted total.

*Measured and written by Opus 5 (claude-opus-5), autonomously, 2026-09-25. The predictions this
result refutes are in `PREDICTIONS.md` at `300b6ca` and are not edited — three of them were wrong
and their being wrong is the finding.*

---

## §5's hand re-read, done on the cell that decides the most

§5 requires at least one scored cell per step re-read by hand, with the hand reading written beside
the sheet's. There is no kept worktree here — a fixture proof reads directories — so the equivalent
is re-reading the fixture source against the anchor text. The cell chosen is the one `PREDICTIONS.md`
named most consequential: **`good-stored-consistent` / `architecture-consistency`**.

Anchor 0 (ii) requires, verbatim: *"an order-side field, property or store … holds a fulfilment
status, an allocated count or a delivered count, AND a method in the SHIPMENT package writes it —
`orders.save(...)`, a setter, a `copy(...)` of an order, or a call into the order package on a
create, confirm, deliver or cancel path."*

What is on disk, read by me:

| clause | evidence, by hand |
|---|---|
| an order-side field holds a fulfilment status and both counts | `good-stored-consistent/…/order/Order.kt:17` — `val fulfilment: Fulfilment = Fulfilment(0, 0, FulfilmentStatus.UNALLOCATED)` |
| a method in the **shipment** package writes it, on create | `…/shipment/ShipmentController.kt:64` — `orders.save(order.copy(fulfilment = order.fulfilment.updated(order.quantity, allocatedDelta = request.quantity)))` |
| …on deliver | `ShipmentController.kt:87` — same shape, `deliveredDelta = delivered.quantity` |
| …on cancel | `ShipmentController.kt:97` — same shape, `allocatedDelta = -cancelled.quantity` |
| and the reference does not do this | `known-good/…/shipment/ShipmentController.kt` contains **0** occurrences of `orders.save` |

**Hand value: 0. Sheet value: 0. They agree**, and the anchor is met on every clause rather than
inferred from one.

**One small instrument note, from doing this by hand.** The sheet cites
`ShipmentController.kt:68,88,98`; the three writes are at **64, 87 and 97**. The substance is exactly
right — the same three statements, on the same three paths — and the line numbers are off by 1 to 4.
Worth knowing before a validator treats a codex line citation as exact: it locates the statement, it
does not index it. This is not a scoring error and changes no cell.

*Hand re-read by Opus 5 (claude-opus-5), 2026-09-25, after the sheet existed; the sheet's value was
already known, so this is a confirmation and not a blind reading — §4 step 7's blind-first discipline
applies to run scoring, and this proof's equivalent is `PREDICTIONS.md`, which registered all 28
cells before any sheet existed.*
