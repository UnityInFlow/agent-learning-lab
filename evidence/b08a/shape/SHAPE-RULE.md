# B8a shape classification — the rule, the population and the procedure, committed BEFORE any run is classified

Decision rule row 2 of `experiments/E-020-decomposition-depth-BE005.md` requires a **shape
classification alongside the evaluator pass rate**, and P3 registers its threshold. The classification
instrument did not exist when the batch ran. This file creates it, and it is committed **before a single
one of the sixteen diffs has been read for shape**, so that it cannot be fitted to them.

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-25.`

## 1. The rule is not new and is not mine

It is `evidence/gate-b2-decision-11/RULE.md` §2, **verbatim, unchanged**, written 2026-09-17 by Claude
Fable 5.1 before ticket A′ was merged and before any B8a run existed. That is the whole reason to use it:
it is **the same instrument the ceiling evidence used** (Gate B′, `n = 5`, wrong shape 4 of 5), so B8a's
rate is comparable to the number its own MDE was transferred from.

> **Wrong shape:** an order-side field, property or store (on `Order`, in the order repository, or any
> new order-package type) holds a fulfilment status, an allocated count or a delivered count, **and at
> least one read path returns or selects on that stored value without recomputing it from the shipment
> repository at that read.** The read paths are three: `GET /orders/{orderId}`, the body of `GET /orders`,
> and the `fulfilment` filter of `GET /orders`. A filter that runs over the stored value before a later
> step recomputes it is a read path that trusts the copy.
>
> **Right shape:** every one of the three read paths computes fulfilment from the shipment repository at
> read time, wherever that computation lives (controller, repository, or a helper). A field on `Order`
> that exists but is recomputed on every read path before it is returned or selected on is a placeholder,
> not a copy, and is not the wrong shape — it is a rubric matter.
>
> A submission that stores and also derives is classed **per read path**: one trusting read path is
> enough for WRONG. The evaluator's exit code is recorded beside the shape and does not decide it.

`NO-ATTEMPT` (no production edit) counts in the **denominator only**.

**What is deliberately NOT carried over:** RULE.md §2's *threshold* ("3 or more of 5") and §4's batch
parameters. Those belong to Gate B′ on its own five probe runs. B8a's threshold is P3's, registered in
E-020: **≥ 8 of 10 treated against ≤ 2 of 10 control, p ≤ 0.05 by Fisher** — and the population that
occurred is `n = 8` per arm, because the batch stopped on its registered cost ceiling (row 0b).

## 2. The population

The **sixteen runs of `evidence/b08a/batch-20260925T091510Z/manifest.tsv`**, both arms, gate-passing and
gate-failing alike. Shape is read from the diff, not from the exit code, so the gate does not filter it —
that independence is the entire point of having both P2 and P3.

**Excluded by name:** the two preflight runs (`8d8505d7`, `a390a301`) and any deliberate-failure run.
Neither is in the manifest and neither is pooled into an arm.

## 3. What is read, and nothing else

For each run id, in its kept worktree copy `evidence.local/b08a-worktrees/<id>/`:

```
git diff HEAD -- sample-service
```

`HEAD` in that copy is the experiment setup commit (`experiment setup: install customization …` for a
treated run, `initial commit` for a control), so this diff is exactly what the agent wrote and contains
no overlay file. Final file state under `sample-service/src/` may be read to resolve a call chain.
`.claude/` and `target/` are not read.

## 4. The procedure, and the honest layer label

**The classification is L3.** Nothing executes it. It is a reading of Kotlin against a prose rule, and
in Gate B′ the author confirmed every row before the tally was called. **No author is available to this
run**, so two things replace that confirmation and neither of them is as strong:

1. **Two independent blind readers.** Two subagents classify the same sixteen diffs from the rule text
   above, each without seeing the other's answer and without seeing any rubric sheet or evaluator exit
   code. Each must cite, per run: the order-side field's declaration, and for **each of the three read
   paths** the `path:line` that returns, selects on, or recomputes.
2. **Every disagreement is adjudicated by me at the diff**, in writing, naming the line that decided it.
   A disagreement is reported as a disagreement even after it is resolved; the agreement rate is the
   instrument's own error bar and goes in the workbook beside the tally.

Per-run rows land in `evidence/b08a/shape/classifications.tsv` with both readers' calls, the adjudicated
value, and the citations. **The author may overrule any row**; the tally is labelled "unconfirmed by the
author" until they do.

## 5. What this rule cannot do

It reads a copy-versus-derivation shape. It says nothing about whether the amendment clause is handled
correctly, nothing about test quality, and nothing about whether a RIGHT-shaped submission passes the
evaluator — `evidence/gate-b2-decision-11/RESULT.md` already shows those can come apart. A disagreement
between P2 (exit code) and P3 (shape) is therefore **a result, not a defect in this file**, and E-020
registers it as the more informative outcome of the two.
