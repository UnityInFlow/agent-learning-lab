# Gate B — result, awaiting the author's confirmation of each classification

Five runs, 2026-09-17 08:24:51Z → 08:45:46Z, driver `run-gate-b.sh`, key `EXP-B8A-GATEB-BE005-PROBE`,
benchmarks `main` `a662c96`, `claude-haiku-4-5-20251001`, claude CLI 2.1.272, plain baseline, no
customization. Manifest: `manifest.tsv`. Every run's record, full staged diff, diff stat and
classification: `runs/<run id>/`. Worktrees copied the moment each run ended to
`evidence.local/gate-b-worktrees/<run id>/`. One launch was aborted by the operator before any
record existed: `aborted-launch/README.md`.

Classified by Claude Fable 5.1 from each `diff.patch` alone, by `RULE.md` §1, evaluator exit
recorded beside the shape and not used by it. **Nothing below is called until the author has
confirmed or overruled each row; the manifest's `shape` column stays `PENDING` until then.**

| seq | run id | shape (Fable's reading) | evaluator | the deciding fact |
|---|---|---|---|---|
| 01 | `e7cf60e7` | **WRONG** | 0 (7/7) | `Order.fulfilment` stored; `ShipmentController` writes it at create, deliver, cancel via three `calculateFulfilment*` functions; both order read paths return the stored value |
| 02 | `171cce49` | **WRONG** | 0 (7/7) | `Order.fulfilment` stored; one `updateOrderFulfilment` in `ShipmentController` called from create, deliver, cancel; order read paths return the stored value; an injected shipment repository in the order controller is never used |
| 03 | `427f427c` | **RIGHT** (tie-break) | 0 (7/7) | `Order` carries a `fulfilment` field, but `OrderRepository.findById`/`findAll` recompute it from `ShipmentRepository.findByOrderId` on every read; no shipment-package write of any order |
| 04 | `6821eeae` | **RIGHT** | 12 (parts 1, 3) | derived in `OrderController.calculateFulfilment` for `getById` and the list page; no shipment-package write; the list FILTER reads a never-updated placeholder field in the repository |
| 05 | `2059576a` | **RIGHT** | 12 (parts 1, 3) | same as 04: `enrichWithFulfilment` for both read paths; no shipment-package write; filter over the stale placeholder |

**Tally on Fable's reading: WRONG 2 of 5. Threshold: 3 of 5. The gate does not pass.**

## What the five runs say, whichever way the two edge rows go

- **The trap as designed was reached for on 2 of 5.** Both of those runs got the stored shape *right* at
  all three sites and passed 7/7 — exactly `good-stored-consistent`, the case the evaluator cannot see
  and Gate B was built to count.
- **3 of 5 derived** — 1 in the repository, 2 in the controller — and that is the census's surviving
  co-variate showing up: this model injects repositories across packages freely.
- **The failure the model actually makes on this ticket is one nobody registered:** a placeholder
  `fulfilment` field left on `Order` "for the response", and a list filter that trusts it. Runs 04 and
  05 both failed part 1 *and* part 3 on that, while their `GET /orders/{id}` was correct. That is an
  early shape (a field on the entity) punished by a later clause (the filter) — the §4.1 pattern — but
  it is not the fork the rule names, because no shipment-side write is involved.
- Cost and time, for the budget line decision 11 item 11 asks for: median $0.341 (0.282–0.379), total
  $1.70; median 207 s (203–252 s); median 40 model calls; 11–12 files changed per run.

## The rows the author has to read

- **Run 03:** the field exists; a reader who stops at `Order.kt` calls it stored. The rule's last
  sentence classes it by the read path, which derives. Fable: RIGHT.
- **Runs 04 and 05:** the wrong shape in `RULE.md` has two conjuncts — an order-side field, *and*
  written from a shipment-package mutation path — and the second is absent. The list filter does
  answer from the stored placeholder, so a reading that takes "what the read path returns" to include
  a filtered list would flip both to WRONG and the tally to 4 of 5. Fable did not read it that way,
  because the rule defines the wrong shape by the write, and stated so on each row before the tally
  was known to matter.

Whatever the author decides on those rows is recorded on the row, and the tally is recomputed from
the rows. The rule is not edited after the fact; if the author finds it ambiguous, that is a finding
about the rule and goes in the adoption record, not into a re-read of the diffs.

## If the gate fails (2 of 5 stands)

Decision 11 item 4: back to step 2, never to a bigger `n`. The registered fallback is candidate **B**
(order amendment with optimistic locking and version history, `BE-005-CANDIDATES.md`), a different
failure class. A second failure ends the step with the negative recorded (item 11). What this batch
adds to a redesign, and did not exist before it: the model's actual early-shape failure on this
service is *a placeholder field on the entity that a later read path trusts*, and a redesigned trap
that punishes that shape has five runs of evidence behind it where candidate A's had none.

---

## Called, 2026-09-17, in session

**The author confirmed all five rows as read.** WRONG 2 of 5, threshold 3: **Gate B FAILED on ticket A.**
First of the two failures decision 11 item 11 allows. The rule stands unedited.

**The author's decision at step 2: redesign A → A', not candidate B.** Part 1 gains one clause that
changes fulfilment with no shipment event — an order quantity amendment, refused below the allocated
total, after which the status must reflect the new quantity. Under a derived shape it costs nothing;
under a stored copy it is a fourth write site in a different package; under the placeholder shape runs
04 and 05 reached for, it is simply wrong. A' gets its own Gate B with its own rule written before its
runs; the five diffs here are prior evidence for that rule, not its gate.
