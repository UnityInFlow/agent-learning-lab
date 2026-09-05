# Hand score — run `1c905fc9`, written before any sheet existed

`Scored by hand by Opus 5 (claude-opus-5), autonomously, 2026-09-05, from the kept worktree
and the rubric at its registered sha. Committed BEFORE codex-score.sh or opencode-score.sh
was run on any batch-2 run, so the comparison measures something.`

§4 step 7: *"Read the sheets only after you have written your own expected score for at least
one run by hand from the kept worktree."* Reading first produces agreement that measures
nothing.

| | |
|---|---|
| run | `1c905fc9-f7bf-4308-9a34-5a86a7497545`, batch 2, **treatment** arm (`agent-v1.0`) |
| worktree | `$TMPDIR/observatory-run-1c905fc9-…`, kept; archived at `~/agent-observatory-worktrees/b04-batch2/01-treatment-1c905fc9-….tgz` |
| diff | `evidence/b04/batch-20260905T095044Z/diffs/01-treatment-1c905fc9-….diff`, 3 files |
| rubric | `benchmark/rubrics/backend-quality.yaml` v2, sha `396e1799eb2b`, unmoved |
| ladder | closed by rule: **0** if the 0 anchor holds; **2** if EVERY clause of 2 holds; **1** otherwise |

## architecture-consistency (weight 35) → **2**

Anchor 0 fails: no `ApiError(...)` or `ApiErrorBody(...)` literal and no assembled map appears
anywhere in the shipment package, on a refusal path or otherwise.

Anchor 2 holds on every clause, and the decisive one is *"ALREADY EXISTS IN THE ATTACHED
BASELINE"*, which I checked rather than assumed:

- missing shipment → `throw ResourceNotFoundException(ErrorCode.SHIPMENT_NOT_FOUND, …)`
- state refusal → `throw ConflictException(ErrorCode.SHIPMENT_ALREADY_CANCELLED, …)`
- both types are in the baseline: `git show HEAD:…/ShipmentController.kt` has
  `import com.unityinflow.sample.api.ConflictException` at line 3 and
  `import …ResourceNotFoundException` at line 5, and already throws both at lines 29 and 49.
  The submission introduces **no** exception subclass.

**The one thing that could move this cell.** The submission adds an `ErrorCode` constant,
`SHIPMENT_ALREADY_CANCELLED`. Anchor 2 is written about exception **subclasses** existing in
the baseline, not about enum constants, so a new constant does not make this anchor 1. A
scorer reading "existing" as covering the whole error vocabulary would score 1.

## maintainability (weight 25) → **0**, and this is the cell I expect a scorer to dispute

There is **no `when` at all** — `git diff HEAD | grep -c '^\+.*\bwhen\b'` returns `0`. So
anchor 2 fails outright: it requires `when (shipment.status)` in expression position.

The status decision is two sequential `if` statements:

```kotlin
if (shipment.status == ShipmentStatus.CANCELLED) { throw ConflictException(...) }
if (shipment.status == ShipmentStatus.CONFIRMED) { return shipment }
val confirmed = shipment.copy(status = ShipmentStatus.CONFIRMED)
```

**I score 0, and the reason is the property anchor 0 exists to detect**: a new
`ShipmentStatus` constant compiles without touching this method and falls past both `if`s
into the unconditional confirm, unannounced. That is exactly the failure the category is
about.

**The competing reading, recorded because it is reasonable.** Anchor 0's literal text is
*"an `if` / `else if` / `else` chain"*, and these are two independent `if` statements with no
`else if` and no `else`. A scorer holding to the letter finds neither anchor 0's named shapes
nor anchor 2's clauses, and lands on the residual, **1**. This is the ladder gap the rubric
itself documents for this category, arriving in a shape its note did not list.

**Registered before the sheets: if codex says 1 here, I do not treat it as a scorer error.**
The disagreement is a rubric defect about what "chain" covers, and it belongs in a rubric
round, not in a sha moved mid-experiment.

## test-quality (weight 25) → **1**

Precondition passes: a test file with assertions exists, so this is not `null`.

Anchor 0 fails: assertions read the body (`jsonPath("$.status")`, `jsonPath("$.error.code")`),
not status codes alone.

Anchor 2 needs all three clauses and **the second is absent**:

| clause | holds? | citation |
|---|---|---|
| confirm called twice, the **second response's body** asserted | **yes** | `confirms an already CONFIRMED shipment…` posts confirm twice; the second asserts `jsonPath("$.status").value("CONFIRMED")`, not status alone |
| persisted state re-read through a **separate `get(...)`** | **NO** | none of the four added tests performs a `get(...)` after confirming. Every assertion is on the mutating call's own response body |
| a refusal asserts `$.error.code` | **yes** | `rejects confirming a CANCELLED shipment…` asserts `$.error.code` = `SHIPMENT_ALREADY_CANCELLED` |

Two of three → residual → **1**.

## change-focus (weight 15) → **1**

Precondition passes: the baseline tree is attached.

Anchor 0 fails: no method the ticket did not name differs. `list`, `create`, `getById` are
untouched; the controller diff is purely the added `confirm`.

Anchor 2 fails on its exclusivity clause: `ApiError.kt` gains `SHIPMENT_ALREADY_CANCELLED`,
which is neither `confirm` nor an import required by symbol for `confirm`.

**This is the dead category, and it is landing exactly where it was predicted to.** E-006's P2
registered `change-focus = 1` on 10 of 10 with an MDE of `none`, because BE-003 acceptance
criterion 4 requires an error response consistent with the rest of the API, which forces the
`ApiError.kt` change that anchor 2 forbids. This run is that mechanism, cited. **A `1` here is
not a finding when it appears** — it is the prediction holding.

## Total

`100 × (35·2 + 25·0 + 25·1 + 15·1) / (2 × 100)` = `100 × 110 / 200` = **55.0**, four of four
categories scored, none null.

Under the competing maintainability reading (`1`): `100 × 135 / 200` = **67.5**. The two
readings differ by 12.5 points of the normalised total, on one cell.
