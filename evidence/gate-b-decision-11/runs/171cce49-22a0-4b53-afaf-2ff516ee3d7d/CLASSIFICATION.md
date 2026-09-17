# Run 02 — `171cce49-22a0-4b53-afaf-2ff516ee3d7d` — shape: **WRONG** (stored, written from the shipment package)

Classified by Claude Fable 5.1 from `diff.patch` alone, 2026-09-17, by the rule in `../../RULE.md` §1.
Evaluator exit **0** (7/7) — recorded beside the shape, not used by it. 12 files changed, 328+/17−.

| rule clause | where in `diff.patch` |
|---|---|
| an order-side field holds a fulfilment status / counts | `order/Order.kt`: `val fulfilment: Fulfilment = Fulfilment(0, 0, FulfilmentStatus.UNALLOCATED)` on `Order` (patch line 143); `data class Fulfilment(allocated, delivered, status)` (129–133) |
| written from a shipment-package mutation path | `shipment/ShipmentController.kt`: one private `updateOrderFulfilment(orderId)` (494–509) recomputes from the shipments and writes `order.copy(fulfilment = …)` + `orderRepository.save(updatedOrder)` (508–509); called from `create` (396), `deliver` (469) and `cancel` (490). `confirm` does not call it (correct: confirm moves no count). |
| what the read path returns | `order/OrderController.kt` returns the stored `Order`; the list filter reads the stored field through `OrderRepository.findByFulfilment` (`it.fulfilment.status == fulfilment`, 287–288; call at 253). An `InMemoryShipmentRepository` is injected into the order controller (181) and **never used** — nothing derives at read time. |

One recompute function called from three shipment-side sites, the release written at `cancel`.
Same class as run 01 (`good-stored-consistent`), tidier. Not `NO-ATTEMPT`: 12 edits, 10 production files.

**Author's confirmation:** _pending_
