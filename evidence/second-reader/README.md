# The second-reader debt from stops 10 and 11, discharged 2026-09-07

Thirty-four `opencode-score.sh` sheets were owed and recorded as **not waived**: fourteen from
stop 10 (`EXP-B4-DELIBERATE-NOTOOLS` ×10, `EXP-B4-AGENT-BOUNDARY` batch 2 ×4) and twenty from
stop 11 (`EXP-4B-ORCH-OVERHEAD`). Both debts were blocked on the ollama-cloud **weekly** usage
limit, first seen 2026-09-05T18:06Z and re-confirmed still in force by the preflight of
2026-09-06T20:5xZ.

**The limit has lifted.** It was found by the §0a preflight of 2026-09-07T07:27Z: the *default*
`opencode-review.sh` panel — the ollama one — returned a 14 534-byte findings file with twelve
finding sections where the day before it returned a 765-byte header-only stall. The scoring route
was then proved separately, not inferred from the review route: one sheet on `e8d881b9` at
07:38:50Z, four categories, no nulls, `rubric_sha 396e1799eb2b`.

Nothing here is a re-measurement of the agent. No benchmark run was started; every sheet reads a
run record and a kept worktree that already existed. Decision C is untouched — **codex remains the
registered scorer and produced every number these stops report**; these are the second readings,
and their only job is to measure cross-harness distance.

## What was produced

| | |
|---|---|
| sheets owed at session start | 34 |
| sheets produced | 34 (33 owed + `abd08a80` twice, see below) |
| scorer | `ollama-cloud/deepseek-v4-pro`, opencode 1.18.27 — §4c's registered fallback and no other |
| rubric | `benchmark/rubrics/backend-quality.yaml` at `396e1799eb2b`, the same sha every registered codex sheet asserts |
| API | `LAB_OBSERVATORY_API=http://127.0.0.1:18081` (the SSH tunnel; the colima host forward on 8081 is dead and reads as healthy) |
| batch logs | `20260907-batch-1of33.log`, `20260907-batch-32of33.log` |
| run ids | `owed-run-ids.txt` |

One run, `abd08a80`, exited 2 on its first attempt: opencode asked for an `external_directory`
permission and auto-rejected itself, so the sheet has no `categories:` key. **A missing cell is not
a null cell**, so it is not a measurement; it is kept, not deleted, and labelled here. The retry at
08:14:57Z returned a full sheet. Both files remain on disk.

The first batch script attempted **one** id and reported `BATCH COMPLETE`, because the scorer's
child process consumed the loop's stdin. It is recorded rather than quietly fixed: a batch runner
that reports success over one of thirty-three is this project's house failure mode — a control
reporting over a scope smaller than it claims — and it was caught only because the log carried a
count. The fix is `</dev/null` on the scorer call, at `concordance.py`'s sibling script.

## The result: 118 of 136 cells exact, and every disagreement is in one category

`20260907-concordance.txt`, re-derivable with `concordance.py`.

| category | exact agreement, codex vs deepseek |
|---|---|
| architecture-consistency | 34 / 34 |
| maintainability | 34 / 34 |
| test-quality | 34 / 34 |
| **change-focus** | **16 / 34** |

Eighteen disagreements, **all of them in `change-focus`, and all in one direction**: fifteen where
the second reader scores **2** and codex scores **1**, three where the second reader emits `null`
against codex's 1. Not one runs the other way. That is not scorer noise; noise is symmetric.

### Two cells re-derived by hand, and both resolve for codex

The rubric closes the ladder by rule: `0` if the 0 anchor holds, `2` only if **every** clause of
anchor 2 holds, `1` otherwise. Anchor 2's binding clause is *"Only `confirm`, and imports required
BY SYMBOL for `confirm`, differ."*

1. **`207ff23d`** (stop 11). codex 1, *"Class documentation outside confirm differs from baseline"*,
   `ShipmentController.kt:14`. `git diff HEAD` in the kept worktree
   `/var/folders/…/T/observatory-run-207ff23d-…`: the class KDoc loses three lines and gains one —
   `Baseline shipment API: create, read, list.` → `Shipment API: create, read, list, and confirm.`
   That is outside `confirm` and is not an import, so anchor 2 fails and the residual is 1.
   **codex is right.** The second reader's stated reason is *"only confirm added; create/getById/list
   and imports identical to baseline"* — true, and it does not address the class doc.
2. **`a06e80c5`** (stop 10). codex 1, *"Unnamed methods match, but ApiError.kt also changes"*.
   `git diff HEAD --stat` shows three changed files; `ApiError.kt` gains one line,
   `SHIPMENT_INVALID_STATUS,`. A new enum constant in another file is neither `confirm` nor an
   import, so anchor 2 fails again. **codex is right.** The second reader's reason —
   *"create/getById/list identical to baseline, only confirm added, no import change"* — again
   describes only the controller.

### What the blind spot actually is, stated as a mechanism

`deepseek-v4-pro` reads `change-focus` as a question about **the controller's methods and imports**.
codex reads it as a question about **the whole change**. Every disagreement in this set is a
difference the second reader never looked at: a class comment, a second file. The two harnesses do
not disagree about a fact in a file they both read — one of them does not read it.

So the previously recorded concordance, *"18 of 20 exact, zero nulls on ten sheets, all five B2
runs"*, was measured on too small a set to expose this. 118/136 is a lower agreement rate (86.8 %
against 90 %) but the number is not the finding; the **concentration** is.

### What this changes, and what it does not

- **It changes nothing about stops 10 and 11.** Both closed on codex sheets under Decision C, and
  every number they report is unmoved. Stop 10 stays `INCONCLUSIVE`, stop 11 stays `NOT DETECTABLE`.
- **It puts a condition on §4c's Decision H.** Decision H would promote `deepseek-v4-pro` to
  registered scorer on a codex outage longer than twelve hours. On this evidence that swap would
  systematically **inflate `change-focus`** — the only dimension where the two harnesses part — and
  would do so silently, because the second reader's stated reasons read as correct in isolation.
  Decision H remains the author's and is not amended here; this file is the measurement it now has.
- **It is a live warning for stop 12.** `change-focus` is exactly the dimension whose anchor 2 the
  BE-004 draft rubric deliberately leaves reachable by `known-good` (validator pass 12, correction
  C2). The BE-004 rubric must be proved on its five fixtures **with codex**, as author decision 9
  already requires, and a `change-focus` separation demonstrated by the second reader would not
  substitute for it.

*Produced and interpreted by Opus 5 (claude-opus-5), autonomous, 2026-09-07. The batch was run
under the orchestrator's direction; the two hand re-derivations, the mechanism above and the
Decision H caveat are the orchestrator's own and were not taken from any sheet.*
