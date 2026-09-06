# Hand re-read — run `207ff23d`, category `maintainability`

**Written and committed BEFORE any codex or opencode sheet for this batch existed.** §5 requires
one scored cell per step be re-read by hand off the kept worktree, and §4 step 7 requires that
reading be written down before the sheets are opened, because reading first produces agreement
that measures nothing.

`Claude Opus 5 (claude-opus-5), autonomous, 2026-09-06.`

| | |
|---|---|
| run | `207ff23d-d00b-4b5a-8a5e-8fbb2dcc0061` (arm O, pair 01, `EXP-4B-ORCH-OVERHEAD`) |
| worktree | `$TMPDIR/observatory-run-207ff23d-d00b-4b5a-8a5e-8fbb2dcc0061`, verified present |
| rubric | `benchmark/rubrics/backend-quality.yaml`, sha **`396e1799eb2b`**, re-derived by `shasum` today |
| category | `maintainability`, weight 25, `precondition: none` |
| **my score** | **0** |

## The construct

`sample-service/src/main/kotlin/com/unityinflow/sample/shipment/ShipmentController.kt`, inside
`fun confirm(...): ResponseEntity<Shipment>`:

```kotlin
when (shipment.status) {
    ShipmentStatus.CANCELLED -> throw ConflictException(
        ErrorCode.SHIPMENT_CANNOT_CONFIRM_CANCELLED,
        "Cannot confirm a shipment that is CANCELLED",
    )
    ShipmentStatus.CREATED -> {
        val confirmed = shipment.copy(status = ShipmentStatus.CONFIRMED)
        repository.save(confirmed)
        return ResponseEntity.ok(confirmed)
    }
    ShipmentStatus.CONFIRMED -> return ResponseEntity.ok(shipment)
}
```

It is the last statement of a block-bodied function. All three branches either `throw` or
`return`; **the `when`'s own value is consumed by nothing** — not returned, not assigned, not
passed as an argument, not the last expression of a lambda. There is no `else`. All three
`ShipmentStatus` constants (`CREATED`, `CONFIRMED`, `CANCELLED`, from `Shipment.kt:23-27`) are
covered.

## Applying the anchors, in order

- **Anchor 2** requires *"one `when (shipment.status)` in EXPRESSION position, carrying no
  `else`"*, and defines expression position as the value being *"USED — returned, assigned,
  passed as an argument, or the last expression of a lambda; anything but discarded."* Here the
  value **is** discarded. **Anchor 2 does not hold.**
- **Anchor 0** names three constructs, the third being *"a `when` in STATEMENT position — its
  value discarded, used by nothing."* That is exactly this construct. **Anchor 0 holds.**
- Anchor 1 is the residual and is only reached if neither 0 nor 2 applies.

**Score: 0.** Cited at `ShipmentController.kt`, the `when (shipment.status)` block above, whose
value no construct consumes.

## One thing I want on the record, and it is not a reason to change the score

Anchor 0's *justification* is that in all three of its constructs *"a new status constant
compiles without touching this method and takes the fallback path unannounced."* **For this
particular construct that rationale is false on modern Kotlin**: since Kotlin 1.7 a
non-exhaustive `when` **statement** over an enum subject is a compile **error**, not a warning,
so adding a fourth `ShipmentStatus` constant would break the build at this site — which is the
very property anchor 2 exists to reward.

I am **not** rescoring on that basis. The rubric's own comment block says the anchor was
deliberately made decidable *by position and `else` alone*, from the attached files, without
reference to the enum — that positional rule is what I applied, and it yields 0. Changing the
anchor is a **§7 halt** (categories and weights are registered), and the sha stays
`396e1799eb2b`.

But it belongs beside the question already held for the author — *on BE-003 with
`claude-haiku-4-5-20251001`, which rubric categories can move at all?* If agents reliably write
the status decision as a `when` **statement** with returns in the branches, then `maintainability`
scores 0 for a construct that is in fact compiler-enforced, and the anchor is measuring **where
the `when` sits**, not **whether the case list is enforced** — which is what it says it wants to
measure. That is a rubric question, for the author, not a scoring liberty for me.
