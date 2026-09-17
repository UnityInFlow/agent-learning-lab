# Run 03 — `427f427c-77cb-4533-9beb-2f8e65525aa6` — shape: **RIGHT** (derived at read time, by the rule's tie-break)

Classified by Claude Fable 5.1 from `diff.patch` alone, 2026-09-17, by the rule in `../../RULE.md` §1.
Evaluator exit **0** (7/7) — recorded beside the shape, not used by it. 12 files changed, 291+/13−.

This is the case the rule's last sentence exists for — *"a submission that stores and also derives is
classed by what the read path returns"* — and it is the one run of the five so far that needed it.

| rule clause | where in `diff.patch` |
|---|---|
| an order-side field holds a fulfilment status / counts | **yes, nominally:** `order/Order.kt`: `val fulfilment: FulfilmentStatus` on `Order` (patch line 109); the order controller stores `FulfilmentStatus(0, 0, UNALLOCATED)` at create (192) |
| written from a shipment-package mutation path | **no.** `shipment/ShipmentController.kt` reads the order for the allocation guard (`orderRepository.findById`, 379) and never saves one: no `orderRepository.save`, no `copy(fulfilment = …)` anywhere under `shipment/` (checked by grep over the shipment hunks: none). `confirm`, `deliver`, `cancel` write shipments only. |
| what the read path returns | **the derived value.** `order/OrderRepository.kt`: `findById` and `findAll` both pass every order through a private `updateFulfilment(order)` (279–302) that calls `shipmentRepository.findByOrderId`, sums non-`CANCELLED` and `DELIVERED` quantities, decides the status by one `when`, and returns `order.copy(fulfilment = …)` — the stored field is overwritten on every read and never trusted. The list filter runs over `findAll()` (276–277), so it filters the derived value. The shipment repository reaches the order repository through an `ObjectProvider` (`shipmentRepositoryProvider.getIfAvailable()`), which is how the run avoided the circular bean. |

So: one derivation, in one place (the repository rather than the controller), reached by both order
read paths; a cancelled shipment releases its quantity by being `CANCELLED`, and no shipment-side
site has to remember anything. The placeholder field on `Order` is dead weight, not a second owner
of the fact — a rubric question (architecture-consistency anchor 1 territory), not a Gate B one.

Not `NO-ATTEMPT`: 13 edits, 10 production files.

**Author's confirmation:** _pending_ — this is the classification most worth a second pair of eyes,
because the field exists and a reader who stops at `Order.kt` would call it stored.
