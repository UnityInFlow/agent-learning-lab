# Hand re-reads, stop 15 (B7), batch `20260910T183731Z`

**Written and committed BEFORE any scoring sheet for this batch existed**, as §4 step 7 requires
(*"Read the sheets only after you have written your own expected score for at least one run by hand
from the kept worktree"*) and as §5 requires (*"At least one scored cell per step is re-read by hand
off the kept worktree and the hand reading is written down next to the sheet's value"*).

Two cells, one per task, because author decision 9 makes each task its own experiment. Both were
produced by a `sonnet` subagent under §4b, given the worktree path and the rubric path and
**explicitly forbidden** from reading anything under `findings/codex/` or `findings/opencode/` or
`experiments/`, so the reading is independent of any machine sheet and prior to it. At the time both
were produced, `findings/codex/` held **no sheet for any of the 34 run ids in this batch**.

At this timestamp codex — the registered scorer, Decision C — was refusing on an auth error (see
`TRACK-B-STATE.md` `codex_auth`), so **no registered sheet exists yet for either cell**. The
"sheet value" column is therefore empty on purpose and is filled when codex returns. That is §4c
step 3 behaviour: the hand reading is one of the parts that needs no registered number, so it was
done rather than deferred.

## Cell 1 — BE-003, `test-quality`

| | |
|---|---|
| run id | `f82835ea-5860-4e74-9729-91f0e4118795` (BE-003 seq 01, **treated**, `verify-v1.0`) |
| worktree | `/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T/observatory-run-f82835ea-5860-4e74-9729-91f0e4118795` |
| rubric | `benchmark/rubrics/backend-quality.yaml` at sha256 prefix **`396e1799eb2b`** — the value registered in E-015, verified by `shasum` at read time |
| **hand value** | **`test-quality = 1`** |
| registered sheet value | *(empty — codex unavailable, §4c)* |
| second-reader value | *(filled below when the opencode sheet lands)* |

**Reasoning, with `path:line` inside the worktree.** Precondition (no test file, or a test file with
no assertion → `null`) is **not** met: a test file exists and asserts, so the anchors are reached.
Anchor 0 is ruled out — assertions read response **bodies**, not only status:
`sample-service/src/test/kotlin/com/unityinflow/sample/shipment/ShipmentControllerTest.kt:103-104`
(`jsonPath("$.shipmentId")`, `jsonPath("$.status")`). Anchor 2 needs **all three** clauses:
clause 1 **holds** — `confirm` is called twice, `:98` and `:101`, and the second response's body is
asserted at `:103-104`; clause 3 **holds** — a refusal asserts the envelope's `$.error.code` at
`:114` and `:121`; clause 2 **fails** — nothing re-reads the persisted state through a separate
`get(...)` after confirming. The only `get(...)` calls in the file (`:62`, `:69`, `:79`) belong to
pre-existing tests of an unrelated flow. One clause of three absent ⇒ the residual, **anchor 1**.

**What would flip it:** a `get(...)` re-reading confirmed shipment state anywhere in the added
tests. Then clause 2 holds and the value is 2.

## Cell 2 — BE-004, `change-focus`

| | |
|---|---|
| run id | `e0075ad9-80e1-44a0-be83-d25f28c9eca1` (BE-004 seq 01, **treated**, `verify-v1.0`) |
| worktree | `/var/folders/jr/lwzz65cx5pndqqdgzhnym1pc0000gn/T/observatory-run-e0075ad9-80e1-44a0-be83-d25f28c9eca1` |
| rubric | `benchmark/rubrics/backend-quality-be004.yaml` at sha256 prefix **`6252778b8472`** — the value registered in E-016, verified by `shasum` at read time |
| **hand value** | **`change-focus = 0`** |
| registered sheet value | *(empty — codex unavailable, §4c)* |
| second-reader value | *(filled below when the opencode sheet lands)* |

**Reasoning, with `path:line`.** Precondition (no baseline tree → `null`) is met: a baseline exists
at `HEAD`, and `HEAD`'s parent touched only `.ai/` and `.claude/` harness files, not
`sample-service/`, so `HEAD` is a valid baseline for every file below. All **five** main-source
diffs fall exactly inside anchor 2's permitted list — `cancel` plus its imports in
`order/OrderController.kt`, the cancelled-order guard inside `create` plus its imports in
`shipment/ShipmentController.kt`, `Order` gaining a status field and its enum in `order/Order.kt`,
one added query method (`findByOrderId`) in `shipment/ShipmentRepository.kt`, and two added
`ErrorCode` constants in `api/ApiError.kt`. `create`, `getById` and `list` are untouched in both
controllers. **Anchor 0 nevertheless fires, on the test fixtures:** `reset()` in
`order/OrderControllerTest.kt` went from an expression body (baseline `:33`) to a block adding
`shipmentRepository.clear()` (worktree `:39-42`) — anchor 0's literal *"an expression body turned
into a block"*; `reset()` in `shipment/ShipmentControllerTest.kt` underwent the identical
restructuring (baseline `:32` → worktree `:39-42`); and `createShipment(shipmentId: String)`
(baseline `:34`) gained an `orderId` default parameter with a changed body (worktree `:44-49`).
Three pre-existing, unnamed methods differing beyond invisible whitespace satisfies anchor 0's
*"two or more"* clause, which also rules out anchor 1 (*"typically exactly one"*) and anchor 2.

**What would flip it — and this is a finding about the rubric, not about the run.** Anchor 2's
closing sentence, *"Cite `create`, `getById` and `list` in both trees for both controllers"*, can be
read as scoping the category to the two named **controllers'** methods. Under that reading the test
fixtures are out of scope and this cell is **2**, not 0 — a two-point swing on the same tree and the
same rubric text.

### The ambiguity is recorded, not repaired

`change-focus` on `backend-quality-be004.yaml` does not say whether a **test fixture** is a
*"method the ticket did not name"*. Anchor 0's enumeration is method-shaped and unrestricted by
directory; anchor 2's citation instruction names controllers only. On this tree the two readings
differ by two points.

**It is not edited.** The rubric is a registered variable at sha `6252778b8472` (E-016, controlled
variables), and §6 forbids moving one mid-experiment while §7 makes *"any proposed change to … the
rubric's categories or weights"* a halt. The correct handling is the one taken here: record the
ambiguity, state which reading this hand value used (**the broad one — anchor 0's text governs,
because it is the anchor being applied and it names no directory**), and let the registered codex
sheet be compared against it when codex returns. **If the codex sheet says 2 where this hand read
says 0, the disagreement is the measurement**, and §4 step 7's rule applies: go to the diff and say
which fact was wrong. That is more informative than a rubric silently patched to agree with itself.

A rubric clarification for BE-004 `change-focus` is therefore in `author_notes` as an instrument
note for a future step, never as an edit to this one.

*Both cells read by a `sonnet` subagent under §4b and recorded by Opus 5 (claude-opus-5),
autonomous, 2026-09-11, before any sheet for this batch existed.*
