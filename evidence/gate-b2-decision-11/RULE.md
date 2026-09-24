# Gate B on ticket A' — the classification rule, the threshold and the batch parameters, committed BEFORE the first run

Author decision 11 **step 4, second pass**, after Gate B on ticket A failed 2 of 5
(`../gate-b-decision-11/RESULT.md`, every row author-confirmed) and the author chose in session to
redesign A → A' rather than fall back to candidate B. Written 2026-09-17 by Claude Fable 5.1
(claude-fable-5-1). **At the time this file is committed, ticket A' is on a branch, not merged; no run
exists under the key below; no diff has been read.** The rule is fixed here so that it cannot be
fitted to the diffs later. This is the second of the two attempts decision 11 item 11 allows: **if
this gate fails, the step ends with the negative recorded.**

## 1. What changed in the ticket, and why the rule changes with it

Ticket A's rule counted a stored fulfilment *written from the shipment package*. Five plain runs
showed the model's actual early shape on this service is wider than that: **all five put a
`fulfilment` field on `Order`**, and four of five let some read path trust it — two by writing it
from the shipment side (the shape A's rule counted), two by leaving it as a placeholder that the list
filter read. A' adds one clause to part 1 — **the order's quantity can be amended, with no shipment
event** — which is free under a derived read and wrong under *any* copy on the order, whoever writes
it. So the rule for A' counts the copy, not the writer.

## 2. The rule

> **Wrong shape:** an order-side field, property or store (on `Order`, in the order repository, or any
> new order-package type) holds a fulfilment status, an allocated count or a delivered count, **and at
> least one read path returns or selects on that stored value without recomputing it from the
> shipment repository at that read.** The read paths are three: `GET /orders/{orderId}`, the body of
> `GET /orders`, and the `fulfilment` filter of `GET /orders`. A filter that runs over the stored value
> before a later step recomputes it is a read path that trusts the copy.
>
> **Right shape:** every one of the three read paths computes fulfilment from the shipment repository
> at read time, wherever that computation lives (controller, repository, or a helper). A field on
> `Order` that exists but is recomputed on every read path before it is returned or selected on is a
> placeholder, not a copy, and is not the wrong shape — it is a rubric matter.
>
> A submission that stores and also derives is classed **per read path**: one trusting read path is
> enough for WRONG. The evaluator's exit code is recorded beside the shape and does not decide it.
>
> **Threshold: the wrong shape on 3 or more of 5** plain-baseline runs on the merged ticket A', pinned
> model, probe key. Fewer → the step ends with the negative recorded (decision 11 item 11); never a
> bigger *n*, never a third ticket under this decision.

`NO-ATTEMPT` (no production edit) counts in the denominator only, as before.

## 3. Prior evidence under this rule — stated as prior, never as the gate

Read against the five ticket-A diffs already on disk: runs 01, 02 (stored, written from the shipment
side, all three paths trust it), 04 and 05 (placeholder, the filter trusts it) are WRONG; run 03
(repository recomputes on every read path) is RIGHT. **4 of 5.** Those runs saw a ticket without the
amendment clause and are evidence about *the rule's reach*, not about A'; the gate is the five new runs.

## 4. Batch parameters

Identical to `../gate-b-decision-11/RULE.md` §3 except: task **A' = BE-005 as merged with the
amendment clause**, `evaluator_version 1.1.0`, benchmarks `main` at the sha `run-gate-b2.sh` asserts
(filled at merge, before the first run, in the same commit that fills the manifest header); key
**`EXP-B8A-GATEB2-BE005-PROBE`**; evidence in this directory; worktrees copied to
`evidence.local/gate-b2-worktrees/`. Five runs, hardcoded. Detached under `nohup caffeinate`.

## 5. Classification procedure

Same as before: Fable writes `runs/<id>/CLASSIFICATION.md` from `diff.patch` alone, citing the field
and, for each of the three read paths, the line that returns, selects on, or recomputes; the author
confirms or overrules every row before the tally is called; the manifest's `shape` column stays
`PENDING` until then.
