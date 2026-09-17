# Run 01 — `e7cf60e7-45a3-445c-ae58-03fcbc7c97c6` — shape: **WRONG** (stored, written from the shipment package)

Classified by Claude Fable 5.1 from `diff.patch` alone, 2026-09-17, by the rule in `../../RULE.md` §1.
Evaluator exit **0** (7/7) — recorded beside the shape, not used by it. 12 files changed, 379+/11−.

| rule clause | where in `diff.patch` |
|---|---|
| an order-side field holds a fulfilment status / counts | `order/Order.kt`: `val fulfilment: FulfilmentStatus? = null` on `Order` (patch line 117); `data class FulfilmentStatus(allocated, delivered, status)` (129–131) |
| written from a shipment-package mutation path | `shipment/ShipmentController.kt`: `create` → `order.copy(fulfilment = newFulfilment)` + `orderRepository.save(updatedOrder)` (356–358); `deliver` → same (427–429); `cancel` → same (455–457); three private `calculateFulfilment*` functions in the shipment controller (463, 485, 506) |
| what the read path returns | `order/OrderController.kt` returns the stored `Order` (its `fulfilment` field) from `getById`; the list filter reads the stored field through `OrderRepository.findByFulfilmentStatus` (`it.fulfilment?.status == status`, `OrderRepository.kt` hunk; call at 223). `create` initialises the stored value to `FulfilmentStatus(0, 0, UNALLOCATED)` (197). Nothing derives from the shipment repository at read time. |

Three write sites, three recomputation functions, the release written at `cancel` — this is the
`good-stored-consistent` shape done right, the case the design page says "a passing Gate B 'wrong'
run looks like". Not `NO-ATTEMPT`: 12 edits, 10 production files.

**Author's confirmation:** _pending_
