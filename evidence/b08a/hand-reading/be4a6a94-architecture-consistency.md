# Hand reading — `architecture-consistency` on treated run `be4a6a94`, written BEFORE any B8a sheet was opened

§4 step 7 and §5 both require it: *"read the sheets only after you have written your own expected score for
at least one run by hand from the kept worktree."* At the commit that adds this file, **no B8a rubric sheet
exists on disk** and none has been requested. Stop 11 did this in the same order and it is what makes a
sheet checkable rather than merely believable.

- **Run:** `be4a6a94-eb20-4da6-8c8d-99f3dad3a3ac` — TREATED, pair 01, gate exit 0 (scoring permitted)
- **Rubric:** `benchmark/rubrics/backend-quality-be005.yaml`, version `2-be005`, sha `945817b8c509`
- **Category:** `architecture-consistency`, weight 35 — the registered outcome of E-020 (P1)
- **Evidence read:** `git diff HEAD -- sample-service` in `evidence.local/b08a-worktrees/be4a6a94…/`, where
  `HEAD` is the experiment setup commit, plus final file state under `sample-service/src/`. No sheet, no
  `evaluation.json`, no exit code.
- **Read by:** a `sonnet` subagent under §4b with the anchors quoted to it verbatim; the value below and its
  interpretation are mine. `Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-25.`

## The hand value: **1** (the residual)

**What decided it:** anchor 0 does not fire on either condition, and anchor 2 clause (ii) fails on one
literal word. `Order.kt:17` still declares `val fulfilment: FulfilmentStatus? = null` — so the order type
*holds* a fulfilment status, which clause (ii) forbids outright ("`Order` and the order repository hold NO
fulfilment status") — while **nothing ever writes a non-null value into it**, which is why anchor 0 (ii)
does not fire either. Neither end of the scale is reachable; the residual is.

| What the anchors ask | What the diff shows | `path:line` |
|---|---|---|
| anchor 0 (i) — an error body assembled in a controller on a refusal path | none. 26 throw sites across the three packages, all throwing | `order/OrderController.kt:35,43,51,73,88,94,111,141,148,161` · `shipment/ShipmentController.kt:35,43,58,80,92,98,116,122,136,142,156,162` · `customer/CustomerController.kt:33,45,51` |
| anchor 0 (ii) — an order-side fulfilment value **written** on a path that changes it | the field exists but **no write site assigns it**. Shipment create/confirm/deliver/cancel write shipments only; the amendment path saves `quantity` only and the enriched copy is response-only, never re-saved | field `order/Order.kt:17` (`allocated` :21, `delivered` :22, `status` :23) · `shipment/ShipmentController.kt:65,129,149,169` · `order/OrderController.kt:168` (save) with `:169` (response-only enrichment) |
| anchor 2 (ii) — the three read paths compute from the shipment repository in ONE function | **all three do, through one shared function** | `GET /orders/{orderId}` → `order/OrderController.kt:77` · `GET /orders` body → `:119` · the `fulfilment` filter → `:122`, filtering `enrichedOrders`, i.e. already-recomputed values |
| anchor 2 (i) — every refusal throws an `ApiException` subclass, none constructs a body | holds, with one wrinkle that does not break it: `order/OrderController.kt:108` throws a bare `IllegalArgumentException`, caught by the same `try`'s `catch (e: Exception)` and re-thrown as `ValidationException` at `:111`, so the exception that ends the request is an `ApiException` subclass | new subclass at `api/ApiExceptions.kt:33` |

**So the cell is 1 and the reason is a vestigial declaration, not a behaviour.** That is the disagreement I
expect to find with the sheet, and it is registered here before the sheet is read: a scorer that reads
clause (ii) as *"no order-side copy is trusted"* returns **2**; one that reads it as written — *"hold NO
fulfilment status"* — returns **1**. The anchor's words are the contract, so **1** is my reading.

**And this is the same submission the shape rule calls RIGHT**, because `evidence/b08a/shape/SHAPE-RULE.md`
counts a field that every read path recomputes as a *placeholder*, not a copy. **The two instruments
disagree by construction, not by error**, and E-020's P3 says a P2/P3 disagreement is the more informative
outcome. Recorded here so that when the tally shows it, it is not mistaken for a defect.
