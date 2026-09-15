# The classifier replay — P5, P6, and the question batch 2 was going to ask

Run 2026-09-14 by Opus 5, autonomous, at §4 step 7/8 of spine stop 16. **No new benchmark run
was made and no money was spent.** Every row below is `classify-permission-block.sh`
(`agent-observatory` branch `stop16/permission-block-classifier`, commit `142e4a4`, fixture set
`verify-permission-block-classifier.sh` **29 of 29 passing**, re-run immediately before this
replay) called over evidence that was already on disk.

> **Amendment, 2026-09-15.** The classifier has since been fixed for a numeric-domain defect
> found by the §4a round-2 review (sha `84e860f76f23` → `817e6eef00ea`, fixture set 29 → 40).
> **Every row below is unchanged** — the replay was re-run against the fixed classifier and all
> 35 rows return the identical runId, changed-count and exit code. The sentence above stays as
> written because it records the classifier as it stood *at this replay*. See
> [`../numeric-domain/README.md`](../numeric-domain/README.md), which holds the re-run tables.

The classifier takes the run record **as JSON content, not as a path**, plus a changed-file
count the caller states. For batch 1 the count is taken from each kept worktree with
`git status --porcelain`, because `behavior.changedFiles` is **null on all twenty records**; for
the stored populations it is `.result.changedFiles | length`, which is populated there. Both are
the call shapes the script's own header names.

## Batch 1, all 20 runs — `batch1-replay.tsv`

| arm | n | classified **permission block** (exit 2) | classified not a block (exit 0) | unclassifiable (exit 3) |
|---|---|---|---|---|
| `blocked-hook-5b5` (arm H) | 5 | **5** | 0 | 0 |
| `blocked-deny-5b5` (arm D) | 5 | 0 | **5** | 0 |
| `plain` (control) | 10 | 0 | **10** | 0 |

The separation is exact and it falls on the **behaviour**, not on the arm label: every run that
produced nothing while carrying a denial is caught, and every run that produced work is left
alone — including the five arm-D runs, which carry denials of 1, 4, 8 and 15 and are *not* called
blocks because they changed 2, 3, 3, 4 and 13 files. That is the conjunction doing its job
against the arm it was most likely to over-fire on.

## The two stored populations — `stored-replay.tsv`

| population | n | reclassified | prediction | verdict |
|---|---|---|---|---|
| `EXP-4B-ORCH-OVERHEAD`, `permissionDenials > 0` | 6 | **0** | P5 second half: 0 of 6 | **HELD** |
| `EXP-BE002-MODEL-TIER`, `F05` sonnet | 7 | **0** | P6: 0 of 7 | **HELD** |

P6 holding is the one to read carefully, because it is a prediction registered *against* the
fix: obs#47's own observed failure is an **abstention**, the agent asks and stops, no tool call
is made, so `permissionDenials` is 0 and the first conjunct is false. **This classifier does not
close obs#47.** That was written into the script's header before the replay and the replay
confirms it rather than discovering it.

## Two preflight runs, reported as a co-variate and entering no decision row

`EXP-5B5-PREFLIGHT-BE003` also holds two runs with denials, and they are **this stop's own
preflight**, not batch members. E-017's registered P5 population is the **six**
`EXP-4B-ORCH-OVERHEAD` runs; the preflight pair is listed in `stored-replay.tsv` labelled
`covariate-preflight` and is excluded from every count above. They behave as the batch does:
`c5ce5d78` (hook channel, 0 files) is caught, `eda125e2` (deny channel, 19 files) is not.

## What this replaces, and the reasoning for replacing it

E-017 §Runs registers a **batch 2 of 10 treated runs after the fix**, to answer P5's first half —
*10 of 10 confirmation runs recorded as infrastructure*. That batch is **not run**, and this is
the decision, with its reasoning, rather than an omission:

1. **P5's first half is unreachable by construction now, and not for a reason more runs fix.**
   It assumes a treated run is a blocked run. P3 is refuted at 5 of 10 and splits exactly by
   channel: the deny channel does not block. A fresh batch of 5 D + 5 H would reclassify 5 of 10
   for the same reason batch 1 does, and a batch of 10 H would be `n = 10` of a channel whose
   result §5 already forbids stating as a property at `n = 5` and which nothing new would be
   learned from.
2. **E-017 itself argues the replay is the stronger instrument**, in its own §Runs: *"the fix
   changes a classification step that executes after the agent, so 'does the fix leave a normal
   run alone' is answered by replaying the classifier over batch 1's 10 control runs and the 6
   stored denial runs — which is stronger than 10 fresh control runs, because it is the same
   runs before and after."* That argument covers the treated arm for exactly the same reason:
   the step being tested runs after the agent, so the agent does not need to run again.
3. **The KEEP condition is answered in substance and in the direction that matters.** E-017's
   registered KEEP is *"reclassifies blocked runs and no passing one"*, and its registered
   REJECT is a fix that catches a passing run. Over 33 runs — 20 batch, 6 stored denial, 7 F05 —
   the classifier caught **5**, and all 5 produced nothing; it caught **0** of the 21 runs that
   produced work, including all 11 that passed the evaluator.
4. **P1 is VOID under decision-rule row 4**, so the reproduction batch 2 was to confirm is not
   established pooled. Spending a batch to confirm a reproduction the decision rule has already
   declared unanswerable measures nothing.

*Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-14. The alternative — run batch 2 anyway
— was not rejected on cost: it is about $1.50. It was rejected because the number it would
return is one §5 forbids stating as a property, on a channel whose own treatment P3 shows does
not deliver.*
