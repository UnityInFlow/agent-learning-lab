# Run 05 — `2059576a-9d5b-4c5c-87f5-fb6d1eb52f72` — shape: **RIGHT** (derived at read time; the same defect as run 04)

Classified by Claude Fable 5.1 from `diff.patch` alone, 2026-09-17, by the rule in `../../RULE.md` §1.
Evaluator exit **12** (4/7: part 1 FAIL, part 2 PASS, part 3 FAIL, contract not reached) — recorded
beside the shape, not used by it. 11 files changed, 331+/60−.

| rule clause | where in `diff.patch` |
|---|---|
| an order-side field holds a fulfilment status / counts | **yes, nominally:** `order/Order.kt`: `val fulfilment: Fulfilment? = null` on `Order` (patch line 155); the controller stores `Fulfilment(0, 0, UNALLOCATED)` at create (226) |
| written from a shipment-package mutation path | **no.** `shipment/ShipmentController.kt` reads the order for the allocation guard (`orderRepository.findById`, 441) and never saves one; no `orderRepository.save` / `copy(fulfilment = …)` under `shipment/`. `confirm`, `deliver`, `cancel` (497, 517, 537) write shipments only. |
| what the read path returns | **the derived value.** `order/OrderController.kt`: one private `enrichWithFulfilment(order)` (287–303) reads `shipmentRepository.findByOrderId`, sums, decides by one `when`, returns `order.copy(fulfilment = …)`; `getById` returns it (241); `list` enriches every returned item (281). |

**The defect, same class as run 04:** the list filter runs in the repository over the stored
placeholder (`findAllPaged(limit, offset, status)` filters `it.fulfilment?.status == status`, 328–330;
also `findByFulfilmentStatus`, 339–340) before the controller enriches. The placeholder is never
updated by anyone, so the filter is always answered by the value at create. Derived design, one read
path that forgot to derive; no shipment-side write exists.

Not `NO-ATTEMPT`: 14 edits, 9 production files.

**Author's confirmation:** CONFIRMED as read, in session, 2026-09-17 ("confirm rows as read"). Recorded by Claude Fable 5.1.
