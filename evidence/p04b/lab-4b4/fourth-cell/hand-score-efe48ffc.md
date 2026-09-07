# Hand re-read — run `efe48ffc`, category `test-quality` (E-009)

**Written and committed BEFORE any codex or opencode sheet for the E-009 batch existed.** §5
requires one scored cell per step be re-read by hand off the kept worktree, and §4 step 7
requires that reading be written down before the sheets are opened, because reading first
produces agreement that measures nothing.

At this write (2026-09-07T12:5xZ) `findings/codex/` holds **no sheet for any run of
`EXP-4B-FOURTH-CELL-2`**; the newest file in it is
`score-observatory-run-582c0b39-…-20260907T122712Z.yaml`, which belongs to **E-008** — a
different, void batch — and is itself unread. The E-009 batch was still running (pair 1 of 10).

`Claude Opus 5 (claude-opus-5), autonomous, 2026-09-07T12:5xZ.`

| | |
|---|---|
| run | `efe48ffc-8e18-4cab-8bc9-c01ad5a4175b` (arm F, pair 01, `EXP-4B-FOURTH-CELL-2`) |
| worktree | `$TMPDIR/observatory-run-efe48ffc-8e18-4cab-8bc9-c01ad5a4175b`, verified present |
| rubric | `benchmark/rubrics/backend-quality.yaml`, sha **`396e1799eb2b`** |
| category | `test-quality`, weight 25; precondition: a test file with assertions exists → not `null` |
| **my score** | **1** |

## The construct

`sample-service/src/test/kotlin/com/unityinflow/sample/shipment/ShipmentControllerTest.kt`, four
tests appended after line 84, plus one added import (`MockMvcResultMatchers.content`):

- `confirms a CREATED shipment and moves it to CONFIRMED` — body asserted (`$.shipmentId`, `$.status`)
- `confirming an already CONFIRMED shipment succeeds and changes nothing` — confirm called
  **twice**, the second response's **body** asserted (`$.status` = `CONFIRMED`)
- `confirming a CANCELLED shipment returns 409` — asserts `$.error.code` = `SHIPMENT_CANCELLED`
- `confirming a non-existent shipment returns 404` — asserts `$.error.code` = `SHIPMENT_NOT_FOUND`

## Anchor by anchor

- **Anchor 0** (every assertion a status code): fails — seven `jsonPath` body assertions. Not 0.
- **Anchor 2**, three clauses, each must be citable:
  1. *confirm called twice, second response's body asserted* — **holds**, second test.
  2. *persisted state re-read through a separate `get(...)` rather than trusted from the
     mutating call's own body* — **absent**. The file imports `get` and uses it in the
     pre-existing list/fetch tests, but **no GET follows a confirm anywhere in the diff**;
     "changes nothing" is asserted from the second confirm's own response.
  3. *at least one refusal asserts `$.error.code`* — **holds**, the 409 and the 404 tests.
- **Anchor 1** (the residual): **this run.** Body read, clause 2 absent.

**Score 1.** The codex sheet for this run must be compared against **1**; a sheet saying 2 is a
disagreement to take to the diff, and this file says where to look — a GET after a confirm,
which is not there.

**The import is a detail, not a score.** `MockMvcResultMatchers.content` is imported and, as far
as the diff shows, never used. Nothing in `test-quality` reads imports, so it changes no anchor;
noted so a later reader does not mistake it for an unexamined difference.

**One run of twenty**, and it is the check §4 step 7 and §5 require — not a validation of the
harness, and not evidence about the arm.
