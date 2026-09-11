# Second-reader sheets for batch `20260910T183731Z` — 34 of 34, and what they are not

**These are not the registered number.** Decision C makes `codex-score.sh` the registered scorer and
`opencode-score.sh` the second reader. codex refused on auth throughout this session, so §4c step 2
applied: *"Score every waiting run **now** with `opencode-score.sh` … These sheets are the second
reading you owed anyway, so nothing is wasted. Mark each in the workbook as `second-reader sheet,
produced before the registered sheet`."* That is what these are, and **P7 is not answered from
them** on either task.

Model `ollama-cloud/deepseek-v4-pro` on **34 of 34** — the only fallback §4c permits, and the only
opencode model with measured concordance against codex. Per-sheet values:
`second-reader-sheets.txt`.

| | |
|---|---|
| complete sheets | **34 of 34** |
| `rubric_sha` | **`396e1799eb2b` on all 20 BE-003 sheets**, **`6252778b8472` on all 14 BE-004 sheets** — the registered value for each task, no cross-contamination |
| scorer model | `ollama-cloud/deepseek-v4-pro`, 34 of 34 |
| incomplete artefacts kept, not deleted | **2** — `52962863…-20260911T072853Z.yaml` (2 535 B) and `e0075ad9…-20260911T074559Z.yaml` (1 074 B). Both ids were retried once and both retries produced a complete sheet; both first attempts are kept on disk |

## A mistake I made reading these, caught within minutes, recorded because the rule already existed

I read `2635dc3b`'s sheet at 1 040 bytes with **zero** `score:` lines and concluded it was a stall —
CLAUDE.md's documented artefact (*"the provenance header is written before opencode is invoked, so a
stall leaves a header-only file"*). **It was not a stall. It was mid-write.** The scorer *appends*
to the sheet, so a header-only read means *either* a stall *or* a call still in flight, and three
minutes later the same file carried all four scores.

CLAUDE.md already says the thing that would have prevented it — *"Check for a live process before
reading one as a finding — that mistake has already been made and reported once"* — and I read the
file before checking the process. On the next id (`e0075ad9`) I checked the process **first**, then
watched the file for growth over a timed 25-second window, and only then called it incomplete.
That one was genuinely incomplete, and the retry fixed it.

**A second lesson, about my own counting.** My progress counter was
`grep -c "score-observatory-run-<id>"` summed over the 34 ids, and it read **34 of 34 while one id
had no sheet at all** — because a retried id contributed two files. A counter that counts *sheets*
answering a question about *ids covered* is the house failure mode in one line of shell, inside the
session that keeps finding it elsewhere. The corrected derivation selects, per id, a sheet with at
least four `score:` lines, and reports `complete sheets: 34 of 34` against a denominator of ids.

## Two things worth flagging before codex scores these — as signals, not results

### 1. On BE-003 the second reader puts `maintainability` two points apart

| BE-003, second reader | treated (n = 10) | control (n = 10) | Δ median |
|---|---|---|---|
| architecture-consistency | 2 | 2 | 0 |
| **maintainability** | **2** | **0** | **+2** |
| test-quality | 1 | 1 | 0 |
| change-focus | 1 (8 scored, 2 null) | 2 (8 scored, 2 null) | −1 |

**P7 registered *"no rubric category's treated median differs from the control's by more than 1
point"*.** A Δ of +2 would refute it. **This is not that refutation**, because P7's instrument is
codex and this is not codex. It is recorded as the thing most likely to decide the stop when codex
returns, and it is recorded *before* codex runs so that the prediction cannot later be described as
having been checked against a number that was already known.

Note the direction: the *treated* arm scores **higher**. If codex reproduces it, the honest reading
is not "the guardrail improved maintainability" — nothing in the gate's design touches how code
inside an allowed path is written — but that something moved which the design says cannot move,
which is decision-rule **row 4, INCONCLUSIVE**, not a win.

### 2. On BE-004 the second reader lands on `change-focus = 2` for the run the hand read scored 0

`e0075ad9`, the BE-004 hand-read run: **hand value 0, second reader 2.** That is **exactly the
two-point swing** the hand re-read predicted from the rubric's unresolved scope question — anchor 0
enumerates method-shaped changes and names no directory, anchor 2's citation instruction names the
two controllers only, and the three restructured **test fixtures** fall on opposite sides of the two
readings. The hand read took the broad reading and said so in writing; the second reader took the
narrow one.

**This makes the ambiguity a measured disagreement rather than a hypothetical one**, and it did so
without anyone editing the rubric. It also means the BE-004 `change-focus` column cannot be
interpreted until codex scores it — and under author decision 10.3, a fallback-scored `change-focus`
is report-only even after Decision H fires, so this column waits on codex specifically.

### And one co-variate worth keeping

`change-focus` returned **`null` on 4 of 20 BE-003 sheets and 0 of 14 BE-004 sheets.** The BE-004
rubric was ported deliberately so that its `change-focus` anchor 2 is reachable by the reference
solution (its header block says so, citing validator pass 12 C2). Zero nulls against four is
consistent with that intent. It was **not a registered outcome**, so it is a co-variate and not a
result.

| BE-004, second reader | treated (n = 7) | control (n = 7) | Δ median |
|---|---|---|---|
| architecture-consistency | 2 | 2 | 0 |
| maintainability | 0 | 0 | 0 |
| test-quality | 1 | 2 | −1 |
| change-focus | 2 | 2 | 0 |

*Every value in both tables was re-derived by me from the sheet files, not taken from the scoring
subagents' reports; where the two overlap they agree. Produced by Opus 5 (claude-opus-5),
autonomous, 2026-09-11.*
