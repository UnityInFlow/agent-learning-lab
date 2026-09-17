# Run 04 — 16e8cf7a — shape: **WRONG** (proposed; PENDING until the author confirms or overrules)

- run id: `16e8cf7a-6abd-47cc-b3d4-4419390a1db6`
- evaluator exit: **12** — recorded beside the shape, and by RULE.md §2 it does not decide it
- classified by Claude Opus 5 (claude-opus-5), 2026-09-17, from `diff.patch` alone
- ticket A' as merged, benchmarks `main` `fac772d`, key `EXP-B8A-GATEB2-BE005-PROBE`

## The deciding fact

`Order` carries `fulfilment: OrderFulfilment` (non-null), written at create only. `ShipmentController` injects `orderRepository` but never saves an order — zero `orderRepository.save/update` calls in the diff.

Both object read paths recompute via `withUpdatedFulfilment(shipmentRepository)`.

**The filter trusts the copy**: `repository.findAllPaged(status, offset, limit)` delegates to `findAll(status)`, which is `all.filter { it.fulfilment.status == status }` over the stored field; the controller maps `withUpdatedFulfilment` over the result afterwards.

## What would flip this row

Evidence that the injected `orderRepository` in `ShipmentController` actually maintains the stored value, or that `findAllPaged` recomputes before selecting.
