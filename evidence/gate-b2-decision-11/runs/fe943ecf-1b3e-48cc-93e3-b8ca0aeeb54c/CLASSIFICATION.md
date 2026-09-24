# Run 05 — fe943ecf — shape: **RIGHT** (AUTHOR-CONFIRMED 2026-09-24, as proposed)

- run id: `fe943ecf-1b3e-48cc-93e3-b8ca0aeeb54c`
- evaluator exit: **0** — recorded beside the shape, and by RULE.md §2 it does not decide it
- classified by Claude Opus 5 (claude-opus-5), 2026-09-17, from `diff.patch` alone
- ticket A' as merged, benchmarks `main` `fac772d`, key `EXP-B8A-GATEB2-BE005-PROBE`

## The deciding fact

`Order` carries `fulfilment: FulfilmentStatus? = null`, set at create to `UNALLOCATED` — so the field exists, exactly as in the four rows above.

**But every read path recomputes before it returns or selects.** The list path is `repository.findAll().map { it.withFulfilment(shipmentRepository) }` **first**, and only then `orders.filter { it.fulfilment?.status == state }` — the filter selects on the *recomputed* value, not the stored one. `GET /orders/{orderId}` returns `order.withFulfilment(shipmentRepository)`. `InMemoryOrderRepository` has no fulfilment filter at all; it only sorts.

RULE.md §2: "A field on `Order` that exists but is recomputed on every read path before it is returned or selected on is a placeholder, not a copy, and is not the wrong shape — it is a rubric matter."

## What would flip this row

Evidence of a read path that selects on or returns `order.fulfilment` without a preceding `withFulfilment`. I found none across the three paths.
