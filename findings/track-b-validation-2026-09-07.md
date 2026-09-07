# Track B validation — 2026-09-07 (pass 17)

`Validator: Claude Fable 5.1 (claude-fable-5-1), pass 17, 2026-09-07T00:3xZ, the same fresh
session that wrote pass 16, continued by the author with the one word "continue". Section 9
only. Scope: was pass 16 processed honestly? The same check pass 4 made of pass 3.`

Read-only. `git fetch`, `git log`/`diff`/`show`, `gh pr view`, `gh issue view`, `gh api
…/timeline`, `grep`, `sed`, and one run of `check-board-freshness.sh`. Nothing outside this file
created, edited or deleted.

## What the builder did with pass 16

Two PRs, both genuine two-parent merges on `origin/main` (`074e9f1`), 8 of 8 checks green on
each: lab#66 → `c81cd5c` (corrections at `d14d1ec`, state write `45ef6b5`, a §4a round at
`257d6dd`) and lab#67 → `074e9f1` (state close). Boards `current at 12716f4646e1`, built from
`d14d1ec`. `status: blocked`, `stop: 12`, `loop_step: 0`; benchmarks#29 re-checked `OPEN`.

**Deleted lines, `git diff 58154f7 origin/main`, every file except the state file:** 22 in
total across 10 files, and all of them are one of three things — a status header replaced in
place with the old text quoted beneath it (E-007 `Status:`, workbook `Status:`), a §5 table
cell edited in place with a note beside it (the hand-re-read row, the no-registered-variable
row, the `1,000 agents` cap row), or a HANDOFF pointer sentence updated (item 0 → item 000;
"stays open" → "stays open … REOPENED"). No prediction, result value, sheet, run folder or
evidence file lost a line. The state file's rewrites are its own rolling fields, as every
session's are.

## The eight corrections, each checked against the file rather than the entry

| # | Correction | Applied? | Where, and how it was checked |
|---|---|---|---|
| 1 | reopen lab#14 | **yes** | `gh api …/issues/14/timeline`: `reopened 2026-09-06T21:03:42Z`; comment at `21:03:41Z` names 4B.1, 4B.2, 4B.3 with their deferral reasons and cites pass 16. Issue `OPEN` |
| 2 | halt paperwork | **yes** | `findings/track-b-2026-09-06.md` exists (73 lines, stop 11 and stop 12 rows, three findings, a passes table, the owed list); HANDOFF gains `### 000. HALT — STOP 12 CANNOT OPEN UNTIL YOU MERGE … PR #29` ahead of items 00 and 0, and the file's opening pointer now sends a reader there first |
| 3 | three stale headers | **yes** | E-007 lines 5–7 now `CLOSED — verdict NOT DETECTABLE`, old text quoted; workbook line 4 `✅ closed … lab#64 → c085508`, old text quoted; workspace `CLAUDE.md:37` `position 12 (B5 — workflow phases), NOT OPENED — halted` |
| 4 | hand-re-read ordering L2 → L3 | **yes** | §5 row reads `L3 for the ordering (relabelled from L2, see note ‡)` |
| 5 | `70 of 70 / dead category` | **yes, additively** | E-007 line 61 (registered row) untouched, a quote-block correction at lines 63–81 beneath it; workbook line 367 untouched, correction at 369–372. Both cite E-006 §C2, `73 of 73`, `514b094e` |
| 6 | report `addedLines` / `changedFiles` | **yes** | E-007 line 922: `addedLines` **90** (81–102, range 68–106) vs **64** (62–67, 56–72), **+26** — the entry says it was re-derived from the API rather than adopted from pass 16, and the quartiles it adds (81–102, 62–67) are ones pass 16 did not compute, which is consistent with that |
| 7 | §5 no-registered-variable row | **yes** | the row now carries `2.1.261 → 2.1.263, and this row's clause is false as written` |
| 8 | "Four of seven held" | **yes, additively** | sentence kept at line 1230; quote-block correction beneath it counts held O1/O5/O6, refuted O2, below threshold O3/O4, outside band O7 |

**One more the builder found itself.** The §4a round at `257d6dd` (codex, 34 findings, review
file `review-E-007-orchestration-overhead-20260906T221333Z.md`, 627 lines) caught that the §5
table's *deterministic code* row still labelled the `1,000 agents per run` cap **L1** while the
exit gate four hundred lines away had already corrected it to L2. Pass 16 checked the exit gate
sentence and not that row. Relabelled with a note. Correct by the rule in order, and a fair
catch against pass 16.

## The one thing in the processing that does not hold

**The state file's pass 16 entry and HANDOFF line 65 both say the closing finding "goes to
`blocked_on_author`" / "is recorded in `blocked_on_author`". It is not there.** The
`blocked_on_author:` list has eleven items — the benchmarks#29 halt, the no-backup exposure,
the concurrent-orchestrator halt, B3's unobserved delivery, `change-focus`, the `tools:`
rewrite, items B and C, decision 7's fourth arm, `nested-skill`, and `run-e005.sh` — and none
of them is E-007's fourth cell (plain baseline plus the implementer's four lines, no split,
`n = 10`). It exists in three narrative places: HANDOFF lines 59–66 under the pass-16 session
section, `findings/track-b-2026-09-06.md`'s *overturn* column, and the `validation_processed`
entry itself. **None of those is the list the author is told to read for decisions**, and the
HANDOFF's *What is BLOCKED ON YOU* section has no numbered item for it either.

This is the house shape at its smallest: a sentence reporting that something was filed in a
place it was not filed. It matters because decision 7's fourth arm — the E-004 co-variate cell
approved on 2026-09-04 — is in that list and has not run in three days; a follow-up that is
only in prose is one that will be forgotten by the session that opens stop 12 under author
decision 9, which is the session that needs it. **Correction: add the fourth cell as a
`blocked_on_author` item and a lettered HANDOFF item, beside decision 7's, with the same
deadline logic pass 3 gave that one — before the next stop whose gate reads `test-quality`.**

## Verdict

**Pass 16 was processed honestly and completely: eight of eight corrections applied,
additively, each verifiable in the merged file, plus one the §4a round added.** Stop 11 stays
CONFIRMED WITH CORRECTIONS and its closure stands. One filing error in the processing, above,
and nothing is reopened.

## The single finding most likely to overturn the track's result if pursued

Unchanged from pass 16: whether `test-quality` 5 of 10 vs 0 of 10 is the decomposition or the
implementer's four lines of prose. The fourth cell decides it. It is now recorded in three
narrative places and in no decision list, which is the reason to record it in one before stop
12 registers an experiment on BE-004 that inherits the same overlay body.
