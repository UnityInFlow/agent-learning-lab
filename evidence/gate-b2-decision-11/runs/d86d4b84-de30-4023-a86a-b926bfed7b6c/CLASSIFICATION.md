# Run 03 — d86d4b84 — shape: **WRONG** (AUTHOR-CONFIRMED 2026-09-24, as proposed)

- run id: `d86d4b84-de30-4023-a86a-b926bfed7b6c`
- evaluator exit: **12** — recorded beside the shape, and by RULE.md §2 it does not decide it
- classified by Claude Opus 5 (claude-opus-5), 2026-09-17, from `diff.patch` alone
- ticket A' as merged, benchmarks `main` `fac772d`, key `EXP-B8A-GATEB2-BE005-PROBE`

## The deciding fact

`Order` carries `fulfilment: Fulfilment = Fulfilment(0, 0, UNALLOCATED)` — non-null with a default, written at create only.

Both object read paths recompute through `enrichWithFulfilment`.

**The filter does not**: `findByFulfilmentStatusPaginated` filters `store.values.filter { it.fulfilment.status == status }` and takes `total` from that filtered list *before* the controller enriches. Both the selection and the reported `X-Total-Count` come from the stored value.

## What would flip this row

Evidence that the repository recomputes before filtering, or that the count is derived rather than taken from the stale filter.
