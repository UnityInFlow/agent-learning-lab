# The census result: it could not be run, and the reason is still happening

Author decision 11 item 1, run 2026-09-15 by Opus 5, autonomous, against the rule committed in
`RULE.md` at **`8c6a9c9`, 2026-09-15T12:23:32Z** — **before** any worktree was opened. This file is
committed after. **No new run was made and no money was spent.**

---

## The result in one line

**All 54 kept BE-004 worktrees are `UNREADABLE`. The denominator is zero. Neither Reading A nor
Reading B fires, and `RULE.md` §5 registered in advance that such a result is reported as such and
decides nothing.**

## What was found, and how it was checked

The population is exactly the 54 runs decision 11 named — confirmed by `stat` on the path each
manifest records, not inferred from `--keep`:

| stop | experiment | manifest | control | treated |
|---|---|---|---|---|
| 12 (B5) | E-011 | `evidence/b05/batch-BE-004-20260909T094351Z/manifest.tsv` | 10 | 10 |
| 13 (B6) | E-013 | `evidence/b06/batch-BE-004-20260909T182606Z/manifest.tsv` | 10 | 10 |
| 15 (B7) | E-016 | `evidence/b07/batch-20260910T183731Z/manifest.tsv` (`task == BE-004`) | 7 | 7 |

**All 54 directories are PRESENT. All 54 contain zero files.**

```
TOTAL across 54 worktrees:  files = 0   dirs = 6568   kilobytes = 0
```

Per worktree, `evidence/census-decision-11/hollowing.tsv`. On the first of them: `ls -la` reports
`total 0` with `.claude/`, `.git/` and `sample-service/` still present; `find` returns **123
entries and not one regular file**; `du -sh` reports **0B**; `git -C … status` answers *"not a git
repository"* because `.git/HEAD` is gone while `.git/` stands.

**This is `$TMPDIR` reaping, and it was predicted here by name.** macOS deletes files untouched for
about three days and leaves the directory tree, so `ls -d <path>` — the RUNBOOK's own proof that a
run's evidence survived — **passes on a worktree whose contents are gone**. `RULE.md` §2 anticipated
exactly this and fixed the handling in advance: *"A worktree that is present but hollow is
`UNREADABLE`, never `none`."* That clause is the only reason this is a reported result rather than
54 runs quietly classified as having no design failure.

The reaper ran on these at **2026-09-15T03:54:59Z**, this morning, hours before the census.

## Why there is no substitute, and why one was not improvised

- **The API has no patch.** `GET /api/runs/<id>` returns `result` with exactly three keys —
  `addedLines`, `deletedLines`, `changedFiles` — and `changedFiles` is a list of **paths**. No run
  record in this store has ever held file content or a diff. Checked, not assumed.
- **The rubric sheets exist and may not be used for this.** `RULE.md` §4 says, in the commit that
  precedes this one by forty minutes: *"The rubric sheet is a second input, never the deciding one
  … no run is classed `design` on a sheet alone."* Reaching for the sheets now — **because the
  method I registered turned out to be impossible** — would be choosing the instrument after seeing
  that the preferred one failed. That is the move this project exists to refuse, and the rule was
  written before the failure was known precisely so that it would bind here.
- **A file-level census cannot decide any of the three forks.** All three (idempotence, atomicity,
  cross-feature status) are about ordering and branching **inside `OrderController.kt`**. A list of
  filenames cannot see any of them.

## What this does and does not do to decision 11

- **B8a's specialist roles cannot be chosen from the census.** Decision 11 item 2 routes them
  through the seam; there is no seam and no evidence of one either way.
- **BE-005's trap must be designed from the §4.1 shape alone**, which is what *Reading A's
  consequence* says — but **Reading A did not fire, and saying it did would be false.** Reading A
  is a measured claim that design failures are rare. What happened is that nothing was measured.
  The practical route is the same; the evidential standing is not, and a later reader must not find
  "Reading A" in this file and treat the ceiling as having been estimated. **Gate B's five
  plain-baseline runs on the finished BE-005 ticket are now the *only* ceiling evidence there will
  be**, which raises what rests on them.
- **Nothing else in decision 11 moves.** The census is not a §7 halt, it moved no registered
  variable, and BE-005 is still the author's to design with Claude Fable 5.1.

## The co-variate that did survive, fenced off from everything above

`result.changedFiles` persists for all 54. It is recorded because it was free and because it bounds
what was lost — **it decides no fork and enters no reading**:

- **54 of 54 runs pass the evaluator, exit 0.** That extends the "BE-004 has never failed on the
  pinned model" record to `n = 54` across three stops and six arms.
- **43 of 54 runs (80 %) change the *identical seven files*.** Two runs in 54 introduced a new file
  at all (`OrderStatus.kt` once, `OrderRepository.kt` once).
- Changed-file counts sit at 5–8 with no arm separating: B5 control 5–7, B5 treated 6–8, B6 both
  6–8, B7 both 6–7.

**At file granularity BE-004 has almost no design variance.** That is consistent with E-006's
finding — the one author decision 9 rests on — and it is worth the BE-005 designers' minute: a
ticket whose file set is fixed on four runs in five leaves a planner very little to get wrong.
**It is not evidence about the forks**, which live inside one file.

## The finding that outranks the census, and it is urgent

**The same reaper is eating stop 16's evidence right now.** Of 412 `observatory-run-*` directories
on disk, **20 still contain files**, and all 20 are stop 16's BE-003 batch:

| batch half | runs | files per worktree now |
|---|---|---|
| ran 2026-09-13 | 10 | **153–244** — intact |
| ran 2026-09-11 | 10 | **11–63** — being eaten as of today |

Stop 16 closed **yesterday**. Its §5 validation table, its delivery proof and its P3 refutation all
cite those worktrees — the changed-file counts that refuted P3 at 5 of 10 were read with
`git status --porcelain` in them, *because* `behavior.changedFiles` is null on all twenty records.
**Half of that evidence is already gone and the rest goes in about two days.**

This is not a new discovery. `HANDOFF.md` and both boards have carried it since 2026-09-02 as *"the
kept worktrees are being deleted, files first"*, listed as **the author's decision** — *where kept
worktrees live*. It has now cost a census, and it is three days from costing stop 16's.

**What would fix it is one line and it is the author's call, because it changes what the runner
archives on every future run:** point `--keep` at a path outside `$TMPDIR`, or have the runner
archive the diff beside the run record. Nothing here does that unasked — `run-agent.sh` is the
observatory's registered instrument and changing where it writes is not the builder's to take.

`Run by Opus 5 (claude-opus-5), autonomous, 2026-09-15, against the rule committed at 8c6a9c9
before any worktree was opened.`
