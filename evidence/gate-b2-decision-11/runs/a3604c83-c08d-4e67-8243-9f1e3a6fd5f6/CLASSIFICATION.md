# Run 02 — a3604c83 — shape: **WRONG** (AUTHOR-CONFIRMED 2026-09-24, as proposed)

- run id: `a3604c83-c08d-4e67-8243-9f1e3a6fd5f6`
- evaluator exit: **12** — recorded beside the shape, and by RULE.md §2 it does not decide it
- classified by Claude Opus 5 (claude-opus-5), 2026-09-17, from `diff.patch` alone
- ticket A' as merged, benchmarks `main` `fac772d`, key `EXP-B8A-GATEB2-BE005-PROBE`

## The deciding fact

`Order` carries `fulfilment: FulfilmentInfo? = null`, set at create to `UNALLOCATED`, never written again.

`GET /orders/{orderId}` and the list body both go through `enrichWithFulfilment(order)`, which recomputes from `shipmentRepository.findByOrderId`.

**The filter trusts the copy**: `orderRepository.findByFulfilmentStatus(status)` resolves to `store.values.filter { it.fulfilment?.status == status }`, and `enrichWithFulfilment` is applied to the already-filtered list. Selection happens on the stale value.

## What would flip this row

Evidence that `findByFulfilmentStatus` recomputes per order rather than reading the stored field.
