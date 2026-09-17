# Gate B round 2 — five runs, five readings, **awaiting the author's confirmation of each row**

Five runs, 2026-09-17 12:53:39Z → 13:15:16Z, driver `run-gate-b2.sh`, key
`EXP-B8A-GATEB2-BE005-PROBE`, benchmarks `main` `fac772d216c0c63f7947b489a162debb5cb58251`
(ticket A' as merged, PR #31), `claude-haiku-4-5-20251001`, claude CLI 2.1.274, plain baseline,
no customization. Manifest: `manifest.tsv`. Each run's record, full staged diff, diff stat and
reading: `runs/<run id>/`.

Classified by Claude Opus 5 from each `diff.patch` alone, by `RULE.md` §2, evaluator exit
recorded beside the shape and not used by it. **Nothing below is called until the author has
confirmed or overruled each row; the manifest's `shape` column stays `PENDING` until then.**

| seq | run id | shape (proposed) | evaluator | the deciding fact |
|---|---|---|---|---|
| 01 | `d2a58c88` | **WRONG** | 12 | `findAllByFulfilment` / `countByFulfilment` select on the stored field; controller enriches after |
| 02 | `a3604c83` | **WRONG** | 12 | `findByFulfilmentStatus` filters `it.fulfilment?.status`; `enrichWithFulfilment` applied to the filtered list |
| 03 | `d86d4b84` | **WRONG** | 12 | `findByFulfilmentStatusPaginated` filters and takes `total` from the stored value before enrichment |
| 04 | `16e8cf7a` | **WRONG** | 12 | `findAllPaged` → `findAll(status)` filters the stored field; `withUpdatedFulfilment` mapped afterwards |
| 05 | `fe943ecf` | **RIGHT** | 0 | `findAll().map { withFulfilment(...) }` **first**, then filters the recomputed value; repository has no fulfilment filter |

**Tally on this reading: WRONG 4 of 5. Threshold: 3 of 5.** Not called here.

## What the five runs say, whichever way the rows go

- **All five put a `fulfilment` field on `Order`.** Not one derived without it. The field itself is
  not the fault line — `RULE.md` §2 says so, and run 05 shows why: the same field, recomputed before
  every read, is a placeholder and passes.
- **The fault line is the filter, in 4 of 5.** Each of the four recomputes correctly for
  `GET /orders/{orderId}` and for the list *body*, and then selects on the stale stored value for the
  `fulfilment` filter. The object a caller sees is right; the set of objects is wrong.
- **Not one of the five maintained the stored value from the shipment side** — zero
  `orderRepository.save/update` calls in any `ShipmentController`, including run 04, which injects
  `orderRepository` and never uses it. The `good-stored-consistent` shape that round 1 saw twice did
  not occur here at all.
- **So the amendment clause is not what these runs died on.** They die on the placeholder filter —
  the shape round 1 discovered and A' added `known-bad-placeholder-filter` for. `known-bad-stale-amend`
  is proved to work by `verify-evaluator.sh` (17 of 17 on main) but was not the trap any run fell into.
- Cost and time, for decision 11 item 11's budget line: median $0.388 (0.330–0.426), total $1.95;
  median 230 s (188–273 s); median 43 model calls; 10–13 files changed per run.

## The rows the author has to read

Row 05 is the one to check hardest: it is the only RIGHT, it is the only evaluator pass, and the
whole reading turns on statement order inside one function — `map` before `filter`. If row 05 reads
WRONG to the author, the tally is 5 of 5 and the gate passes by more. If any of 01–04 reads RIGHT,
the tally is 3 of 5 and the gate still passes. **The threshold is reached on every reading of a
single row**, which is worth stating plainly: no single row decides this gate.

## One changed variable between the rounds

Round 1 ran on claude CLI **2.1.272**; this round ran on **2.1.274**. The model pin is unchanged and
`RULE.md` pins the model, not the CLI. Each round's tally stands on its own five runs, but any
A-versus-A' comparison carries this confound. Recorded before the rows were read, not after.
