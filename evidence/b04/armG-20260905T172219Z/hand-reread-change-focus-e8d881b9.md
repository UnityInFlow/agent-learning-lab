# Hand re-read — `change-focus`, run `e8d881b9` (arm G, 01-armG)

`Scored by Opus 5 (claude-opus-5), autonomously, 2026-09-05T18:0xZ. **Written and committed
BEFORE any codex sheet for this run was read.** Prompt section 4 step 7: "Read the sheets only
after you have written your own expected score for at least one run by hand from the kept
worktree." The commit timestamp of this file is the proof; the codex sheets for this batch were
being produced by a subagent at the same time and none had been opened.`

**Instrument:** `benchmark/rubrics/backend-quality.yaml`, registered sha `396e1799eb2b`,
re-derived at scoring time and unmoved. Category `change-focus`, weight 15.
**Source read:** `diffs/01-armG-e8d881b9-5fb2-406e-947a-d32e107e157a.diff`, taken from the kept
worktree `$TMPDIR/observatory-run-e8d881b9-5fb2-406e-947a-d32e107e157a`.
**Ticket names exactly one method:** `confirm` (BE-003).

## Applying the rubric's closing rule, in its order

The rubric closes the ladder by rule, not by anchor text: `0` if the 0 anchor's condition holds,
else `2` if EVERY clause of the 2 anchor holds, else `1`.

**Anchor 0 — does not hold.** It requires two or more methods the ticket did not name to differ
beyond invisible whitespace. **Zero unnamed methods differ.** `createShipment`, `getById` and
`list` in `ShipmentController.kt` appear in no hunk, and the five baseline tests in
`ShipmentControllerTest.kt` appear in no hunk — the only test-file hunks are the class KDoc at
`@@ -13,10 +13,10` and a pure append at `@@ -81,4 +85,63`.

**Anchor 2 — fails, and on its second clause only.** Its first clause holds: every unnamed method
is identical. Its second clause is *"Only `confirm`, and imports required BY SYMBOL for `confirm`,
differ"*, and three things outside `confirm` differ, none of them an import:

| What differs | Where | Is it `confirm` or an import? |
|---|---|---|
| class KDoc replaced — *"Baseline shipment API… There is deliberately no way to confirm a shipment. That is BE-003."* → *"Shipment API: create, read, list, confirm."* | `ShipmentController.kt`, hunk `@@ -13,9 +13,7` | no |
| `SHIPMENT_CANNOT_BE_CONFIRMED` added to `enum class ErrorCode` | `ApiError.kt`, hunk `@@ -33,5 +33,6` | no |
| class KDoc replaced, plus new helper `confirmShipment` and five new `@Test` methods | `ShipmentControllerTest.kt`, hunks `@@ -13,10 +13,10` and `@@ -81,4 +85,63` | no |

**Anchor 1 covers this shape explicitly**: *"also the case where every named method is
character-identical but something outside them … differs."*

## My value

**`change-focus` = 1.**

Not `null`: `null` is reserved for a failed precondition or evidence that cannot decide the 0
condition, and both anchors were decidable here off a 152-line diff with a baseline present.

## What this cell can and cannot settle

It is **one cell of one run of five**. It is consistent with F5's registered `change-focus = 1 on
5 of 5`, and it is not evidence for the other four runs. Its job is to say whether the registered
scorer is reading the same diff I am; the comparison against the codex sheet is written beside
this value once that sheet exists, and if they disagree the diff decides, not the majority.
