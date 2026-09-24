# Run 01 — d2a58c88 — shape: **WRONG** (AUTHOR-CONFIRMED 2026-09-24, as proposed)

- run id: `d2a58c88-2e73-477f-a471-edbdf1a5fc6e`
- evaluator exit: **12** — recorded beside the shape, and by RULE.md §2 it does not decide it
- classified by Claude Opus 5 (claude-opus-5), 2026-09-17, from `diff.patch` alone
- ticket A' as merged, benchmarks `main` `fac772d`, key `EXP-B8A-GATEB2-BE005-PROBE`

## The deciding fact

`Order` carries `fulfilment: Fulfilment? = null`, written once at create as `UNALLOCATED` and never updated — no shipment-side write to `orderRepository` anywhere in the diff.

`GET /orders/{orderId}` and the body of `GET /orders` both recompute via `withFulfilment(shipmentRepository)`, so those two read paths are right.

**The filter is not.** `OrderRepository.findAllByFulfilment` selects with `store.values.filter { it.fulfilment?.status == status }` and `countByFulfilment` counts the same way — both over the stored value — and the controller only enriches *afterwards* (`orders.map { it.withFulfilment(...) }`). RULE.md §2: "A filter that runs over the stored value before a later step recomputes it is a read path that trusts the copy." One trusting read path is enough for WRONG.

## What would flip this row

Evidence that `fulfilment` on `Order` is recomputed or maintained before the repository filter reads it. I found no write to it outside `create`.
