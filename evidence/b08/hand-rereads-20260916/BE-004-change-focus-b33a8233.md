# Hand re-read — BE-004, `change-focus`, run `b33a8233`, 2026-09-16

**Written and committed BEFORE any scoring sheet for this batch exists**, same ordering and same
reason as the BE-003 re-read beside it.

- **Run:** `b33a8233-3bb0-4faa-acd9-d5bd9a250e89`, BE-004 seq 10, **treated** (`agent-v1.1`)
- **Rubric:** `benchmark/rubrics/backend-quality-be004.yaml`, sha **`6252778b8472`**, `change-focus` only
- **Baseline:** worktree `HEAD` = `96dbb49 experiment setup: install customization for variant 'agent-v1.1'`;
  the agent's work is uncommitted against it, so the diff is `git diff HEAD`.

## The diff, re-derived in the main context

```
 api/ApiError.kt                |   2 +
 order/Order.kt                 |  12 +
 order/OrderController.kt       |  34 +
 shipment/ShipmentController.kt |  12 +
 order/OrderControllerTest.kt   | 109 +-   (-1)
 shipment/ShipmentControllerTest.kt | 37 +- (-3)
 6 files changed, 202 insertions(+), 4 deletions(-)
```

**All four production files are pure additions; the only 4 deleted lines are in test files**, which
`change-focus` does not score. Verified rather than accepted: no repository file is touched at all —
the agent used an inline `shipmentRepository.findAll().filter { ... }` — and `ApiError.kt` adds
exactly `ORDER_HAS_CONFIRMED_SHIPMENT,` and `ORDER_CANCELLED,`.

## The reading

**`change-focus` = 2**, matched to:

> Every method the ticket did not name is identical to the baseline once invisible whitespace is
> normalised. The ONLY differences are: the new `cancel` method and the imports it requires BY
> SYMBOL; the cancelled-order guard inside the shipment controller's `create` and the imports it
> requires; `Order` gaining a status field and its enum; one added query method on the shipment
> repository; added `ErrorCode` constants. Anything beyond that list is a difference.

`getById` and `list` are byte-identical in **both** controllers; the only additions are `cancel`, the
guard inside `create`, `Order.status` with its enum, and the two `ErrorCode` constants — every one on
the permitted list.

## The same ambiguity as BE-003, on a different rubric — and the two readers resolved it oppositely

**Both controllers' primary constructors gained a dependency parameter** —
`OrderController.kt:21` takes `InMemoryShipmentRepository`, `ShipmentController.kt:26` takes
`InMemoryOrderRepository` — and **anchor 2's whitelist names imports but not constructor
parameters.** The parameters are inert outside the named method bodies and are the same kind of
unavoidable scaffolding as the imports the anchor does permit; the anchor does not say so.

**This is the finding, and it is bigger than either cell.** Two hand re-reads, two tasks, two
rubrics, two independent readers with no knowledge of each other, both hit the identical structural
defect: **`change-focus` anchor 2 enumerates a closed whitelist of permitted accompanying changes,
and a correct additive solution requires changes that are not on it.**

| | what the correct solution required | on anchor 2's whitelist? | the reader scored |
|---|---|---|---|
| BE-003, `6e5cac9b` | a new `ErrorCode` constant `confirm` needs | **no** — imports only | **1** (residual) |
| BE-004, `b33a8233` | constructor parameters the named methods need | **no** — imports only | **2** (anchor 2) |

**Same defect class, opposite resolutions.** That is not a reader being careless; it is the anchor
failing to determine the score, and it is direct evidence for a mechanism behind something already
on record: decision 10.3 registers `change-focus` as the one category where codex and opencode part
company — 18 of 34 runs on BE-003, always in the same direction. An anchor whose enumeration is
narrower than the solution demands will split readers exactly this way.

**Registered before scoring, so whatever the codex sheets return on this category is a known
disagreement rather than a reconciliation.** Neither rubric can be edited here: both shas are
registered variables cited across four experiments, and §6 forbids moving one mid-experiment. This
is an author decision at a version boundary, and it is the single most useful thing this step has
produced about the instrument rather than about the agent.

*Hand re-read by a sonnet subagent; HEAD, diffstat, the constructor parameters, the untouched
repository files, the two `ErrorCode` constants and the location of all 4 deletions re-derived in
the main context by Opus 5 before this file was written (§4b). Opus 5 (claude-opus-5), autonomous,
2026-09-16.*
