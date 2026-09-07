# Hand re-read — run `582c0b39`, category `test-quality`

**Written and committed BEFORE any codex or opencode sheet for this batch existed.** §5 requires
one scored cell per step be re-read by hand off the kept worktree, and §4 step 7 requires that
reading be written down before the sheets are opened, because reading first produces agreement
that measures nothing. At this write (2026-09-07T12:09Z) the newest file in `findings/codex/` is
`score-good-nested-ifs-20260907T072750Z.yaml`, the morning preflight's fixture sheet; no sheet
names any run of `EXP-4B-FOURTH-CELL`. The batch was still running (pair 2 of 5).

`Claude Fable 5.1 (claude-fable-5-1), hand-started session, 2026-09-07T12:09Z.`

| | |
|---|---|
| run | `582c0b39-aab7-4f94-9d8b-22a2f5857a07` (arm F, pair 01, `EXP-4B-FOURTH-CELL`) |
| worktree | `$TMPDIR/observatory-run-582c0b39-aab7-4f94-9d8b-22a2f5857a07`, verified present, `CLAUDE.md` at its root |
| rubric | `benchmark/rubrics/backend-quality.yaml`, sha **`396e1799eb2b`** |
| category | `test-quality`, weight 25; precondition: a test file with assertions exists → not `null` |
| **my score** | **1** |

## The construct

`sample-service/src/test/kotlin/com/unityinflow/sample/shipment/ShipmentControllerTest.kt`, four
new tests appended after line 83 (`git diff` of the kept worktree against its setup commit):

- `confirms a CREATED shipment and moves it to CONFIRMED` — body asserted (`$.shipmentId`, `$.status`)
- `confirming an already CONFIRMED shipment succeeds without changes` — confirm called **twice**;
  the second response's **body** is asserted (`$.status` = `CONFIRMED`)
- `confirming a CANCELLED shipment is rejected with 409` — asserts `$.error.code` = `SHIPMENT_CANNOT_CONFIRM`
- `confirming a non-existent shipment is rejected with 404` — asserts `$.error.code` = `SHIPMENT_NOT_FOUND`

## Anchor by anchor

- **Anchor 0** (every assertion a status code): fails — six `jsonPath` body assertions. Not 0.
- **Anchor 2**, three clauses, each must be citable:
  1. *confirm called twice, second response's body asserted* — **holds**: second test, the
     second `post(...)` is followed by `jsonPath("$.status").value("CONFIRMED")`.
  2. *persisted state re-read through a separate `get(...)` rather than trusted from the
     mutating call's own body* — **absent**. No `get("/shipments/S-5")` (or any GET) follows a
     confirm anywhere in the diff; "without changes" is asserted from the confirm response
     itself.
  3. *at least one refusal asserts `$.error.code`* — **holds**: both the 409 and the 404 test.
- **Anchor 1** (the residual: not 0, not all three of 2): **this run.** Body read, clause 2 absent.

**Score 1.** The absent clause is the one HANDOFF item 00c named as the whole difference between
E-007's arms. On this one arm-F run the prose did **not** produce it — `n = 1`, a story. The
codex sheet for this run must be compared against **1**; a sheet saying 2 is a disagreement to
take to the diff, and this file says where to look (no GET after a confirm).
