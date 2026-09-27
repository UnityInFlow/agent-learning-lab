# §5 hand re-read — stop 21 (B10), one cell per task, BEFORE any sheet was opened

§4 step 7 requires the hand reading first: *"Read the sheets only after you have written your
own expected score for at least one run by hand from the kept worktree."* This file is that
writing, and it is committed before `evidence/b10/score-b10-batch.sh` is launched, so its
ordering is a git fact rather than a claim.

Both cells are `architecture-consistency`, which is the **registered primary run outcome** of
E-024 and E-025 — the cell that decides rows 2, 3 and 4 of both decision rules. Scoring the
registered outcome by hand rather than a convenient cell is the point.

- Read by a `sonnet` subagent (§4b) off the kept worktree, then **re-derived in the
  orchestrator's own context** from the same worktree with `git status --porcelain`, a refusal
  grep over the scored packages, and a `class .*Exception` grep over the whole main tree. The
  two readings agree on both cells. Both values below are the re-derived ones.
- Rubrics at their registered shas, re-confirmed on disk this session: BE-003
  `benchmark/rubrics/backend-quality.yaml` = `396e1799eb2b`; BE-004
  `benchmark/rubrics/backend-quality-be004.yaml` = `6252778b8472`.

## BE-003 — treated run `4df04e27-bd37-422e-bdd3-6d759558b22a`

Worktree `${TMPDIR}/observatory-run-4df04e27-bd37-422e-bdd3-6d759558b22a`, present at read time.

**Hand score `architecture-consistency` = 2.**

| what the anchor asks | what the worktree says |
|---|---|
| anchor 0: an `ApiError(…)`/`ApiErrorBody(…)` literal or a refusal-path map inside a controller method | `grep -rn 'ApiError\|ApiErrorBody\|mapOf('` over `shipment/` returns **nothing** → not anchor 0 |
| anchor 2 clause 1: every refusal throws an `ApiException` subclass | four refusal paths, all `throw`: `ShipmentController.kt:25` `ConflictException`, `:45` `ResourceNotFoundException`, `:53` `ResourceNotFoundException`, `:61` `ConflictException`. No `check(`, `require(`, `!!` or bare `throw` anywhere in the package |
| anchor 2 clause 2: the subclass **already exists in the baseline** | both declared in `api/ApiExceptions.kt:19` and `:23`, subclasses of the `sealed class ApiException` at `:11`. That file is **absent from `git status --porcelain`** → untouched by the submission → baseline, not introduced |
| the `ResponseEntity<Any>` tell | absent: `create()` returns `ResponseEntity<Shipment>` (`:23`), `confirm()` returns `Shipment` (`:51`) |

Changed files: `shipment/ShipmentController.kt` (modified), `shipment/ShipmentControllerTest.kt`
(modified). Two files.

## BE-004 — treated run `05611c81-ca61-4f50-b40e-dc7e29c63ec6`

Worktree `${TMPDIR}/observatory-run-05611c81-ca61-4f50-b40e-dc7e29c63ec6`, present at read time.

**Hand score `architecture-consistency` = 2.**

The BE-004 anchor spans **two packages** and names the cancelled-order shipment guard
specifically, so both were checked rather than the order package alone.

| what the anchor asks | what the worktree says |
|---|---|
| anchor 0 | `grep` for `ApiError\|ApiErrorBody\|mapOf(` over **both** `order/` and `shipment/` returns **nothing** → not anchor 0 |
| anchor 2, every refusal in **either** package | seven, all `throw`: `order/OrderMutationService.kt:21` `ResourceNotFoundException` (missing order), `:35` `ConflictException` (the blocked cancel), `:51` `ConflictException` (**the cancelled-order shipment guard**), `order/OrderController.kt:25` `ConflictException`, `:40` `ResourceNotFoundException`, `shipment/ShipmentController.kt:31` `ConflictException`, `:51` `ResourceNotFoundException`. No `check(`, `require(` or `!!` refusal in either package |
| the subclasses already exist in the baseline | `api/ApiExceptions.kt:19` and `:23`; that file is **absent from `git status`** → baseline. A `class .*Exception` grep over the whole `main/kotlin` tree finds **no new exception type**: the only declarations are the baseline `ApiException`, `ResourceNotFoundException`, `ConflictException`, `ValidationException` |

**One thing a validator will notice, recorded rather than hidden:** `api/ApiError.kt` **is**
modified in this run (`M` in `git status`) — the submission added its new `ErrorCode` constants
there. That does **not** reach anchor 0, which asks whether an `ApiError(…)` *literal is
constructed inside a controller method in the order or shipment package*; a new enum constant in
the `api` package is neither a literal nor in a scored package. The anchor's own words —
*"appears inside a controller method"* — are what decide it, and no such occurrence exists. The
value is 2 with that read stated, not 2 by overlooking the modified file.

## What this cell can and cannot be used for

It is one cell of one run per task, so it is **not** a median and it decides no row by itself.
Its job is the §5 clause: *at least one scored cell per step is re-read by hand off the kept
worktree and the hand reading is written down next to the sheet's value.* When the codex sheets
for these two run ids exist, their `architecture-consistency` values are written beside the 2s
above, and any disagreement is resolved by going to the diff (§4 step 7), not by averaging.

`Hand-read and re-derived by Opus 5 (claude-opus-5), autonomously, 2026-09-27; the author did
not review before the run.`
