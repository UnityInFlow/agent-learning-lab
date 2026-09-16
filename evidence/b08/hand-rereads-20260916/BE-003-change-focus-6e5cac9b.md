# Hand re-read — BE-003, `change-focus`, run `6e5cac9b`, 2026-09-16

**Written and committed BEFORE any scoring sheet for this batch exists.** That ordering is the
whole point: a hand reading produced after a sheet is a reconciliation, not a control. §5 requires
one re-read cell per step; stop 11 onward has done it in this order and this is the same.

- **Run:** `6e5cac9b-5719-498d-8ff3-052944e393c3`, BE-003 seq 01, **treated** (`agent-v1.1`)
- **Rubric:** `benchmark/rubrics/backend-quality.yaml`, sha **`396e1799eb2b`**, category `change-focus` only
- **Baseline:** the worktree's `HEAD`, `91fa164 experiment setup: install customization for variant 'agent-v1.1'`.
  The agent's work is **uncommitted against that HEAD** — there is no agent commit — so the diff is
  `git diff HEAD`, taken across staged and unstaged state.

## The diff, re-derived in the main context rather than taken from the subagent

```
 .../api/ApiError.kt                  |  1 +
 .../shipment/ShipmentController.kt   | 25 +++++++++++++
 .../shipment/ShipmentControllerTest.kt | 43 ++++++++++++++++++++++
 3 files changed, 69 insertions(+)
```

**69 insertions, 0 deletions — the change is purely additive.** Verified by hand, not accepted:
`ApiError.kt` adds exactly one line, `+    SHIPMENT_INVALID_STATUS,`; `ShipmentController.kt` has
**zero** `+import`/`-import` hunks; exactly one method is added,
`+    fun confirm(@PathVariable shipmentId: String): ResponseEntity<Shipment> {`.

## The reading

**`change-focus` = 1** (the residual), with the anchor matched verbatim:

> THE RESIDUAL — neither the 0 condition nor every clause of 2. Typically exactly one unnamed
> method differs; also the case where every named method is character-identical but something
> outside them — a reordered import `confirm` does not require, a moved blank line — differs.
> Name what differs and cite both trees.

`create`, `getById` and `list` are byte-identical to baseline at `ShipmentController.kt:26-55`, and
the only method addition is `confirm` at `ShipmentController.kt:57-80`. The 0 condition (two or more
unnamed methods differing) does not hold. What keeps it off 2 is `ApiError.kt:36`: a new enum
constant `SHIPMENT_INVALID_STATUS` in `enum class ErrorCode`, which anchor 2 does not enumerate.

## The ambiguity, and it is the reason this cell was chosen

**Anchor 2 permits exactly two kinds of difference — `confirm` itself, and "imports required by
symbol for `confirm`". An added enum constant in a second file is literally neither**, and the
rubric does not say whether a *declaration* the new method requires is treated like an *import* the
new method requires. Both readings are defensible on the text:

| reading | value | argument |
|---|---|---|
| the enum constant is outside the enumerated set | **1** | anchor 2's list is exhaustive as written |
| it is "part of `confirm`'s change" by analogy to a required import | **2** | the constant exists only because `confirm` needs it; the diff is otherwise perfect |

**This is registered here so that a codex sheet returning 2 is a known disagreement rather than a
reconciliation.** Decision 10.3 already records `change-focus` as the one category where two
harnesses part company — 18 of 34 on BE-003 — and this is a plausible mechanism for part of that
spread: an anchor whose enumeration is narrower than the changes a correct solution requires.

**It is not fixable here.** Editing the rubric moves sha `396e1799eb2b`, which §6 forbids
mid-experiment and which four experiments cite. It is an author decision at a version boundary.

*Hand re-read by a sonnet subagent on the brief in this file; every factual claim above — HEAD,
diffstat, the ApiError line, the zero import hunks, the single added method — re-derived in the
main context by Opus 5 before the file was written. Opus 5 (claude-opus-5), autonomous, 2026-09-16.*
