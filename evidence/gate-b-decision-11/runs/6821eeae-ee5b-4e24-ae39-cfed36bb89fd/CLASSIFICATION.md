# Run 04 — `6821eeae-ee5b-4e24-ae39-cfed36bb89fd` — shape: **RIGHT** (derived at read time; a defect elsewhere)

Classified by Claude Fable 5.1 from `diff.patch` alone, 2026-09-17, by the rule in `../../RULE.md` §1.
Evaluator exit **12** (4/7: part 1 fulfilment FAIL, part 2 PASS, part 3 pagination FAIL, contract
not reached) — recorded beside the shape, **not used by it**; this is the run that shows why the
two are kept apart. 12 files changed, 319+/57−.

| rule clause | where in `diff.patch` |
|---|---|
| an order-side field holds a fulfilment status / counts | **yes, nominally:** `order/Order.kt`: `val fulfilment: OrderFulfilment? = null` on `Order` (patch line 138); the order controller stores a computed value at create (223) |
| written from a shipment-package mutation path | **no.** `shipment/ShipmentController.kt` reads the order for the allocation guard (`orderRepository.findById`, 423) and never saves one: no `orderRepository.save`, no `copy(fulfilment = …)` under `shipment/` (grep over the shipment hunks: none). `confirm`, `deliver`, `cancel` write shipments only. |
| what the read path returns | **the derived value.** `order/OrderController.kt`: one private `calculateFulfilment(orderId, quantity)` (286–298) reads `shipmentRepository.findByOrderId`, sums non-`CANCELLED` and `DELIVERED`, decides by one `when`; `getById` returns `order.copy(fulfilment = calculateFulfilment(…))` (238); `list` enriches every returned order the same way (279). |

**The defect, which is not the wrong shape:** the list FILTER runs inside the repository over the
stored placeholder (`OrderRepository.findAll(limit, offset, fulfilmentStatus)` filters
`it.fulfilment?.status == fulfilmentStatus`, 320–323) *before* the controller enriches the page
(279). The stored placeholder is set once at create and never updated by anyone, so
`GET /orders?fulfilment=FULLY_ALLOCATED` never finds an order that became fully allocated — the
part 1 failure. Part 3's failure is in the same list path (the total is counted over the stale filter).
No shipment-side site exists that could have kept the placeholder fresh; this is a derived design
with one read path that forgot to derive, not a stored design. Under the rule's definitions —
wrong = written from the shipment package; right = computed from the shipment repository at read
time — it is right, and the rule's tie-break (*what the read path returns*) points the same way for
`GET /orders/{id}`.

Not `NO-ATTEMPT`: 12 edits, 10 production files.

**Author's confirmation:** CONFIRMED as read, in session, 2026-09-17 ("confirm rows as read"). Recorded by Claude Fable 5.1.
value" as a read path returning the stored value, this run flips to WRONG. I did not read it that
way because the rule's wrong shape needs a shipment-package write, and there is none.
