# Two harnesses on the same 30 runs — and the hand re-read called the fork before either scored

**§4 step 7's second reader, `ollama-cloud/deepseek-v4-pro`, over the same run ids codex scored.**
Decision C is unchanged: codex produces the registered numbers, this is a concordance measurement
and **not a vote**. Coverage: **30 of 36** sheets carry scores. The six missing are opencode
`external_directory` permission auto-rejections on the baseline copy in `$TMPDIR`, not refusals
about the rubric — recorded in the driver's results file as they occurred.

## The concordance, per category

| category | agreement | |
|---|---|---|
| architecture-consistency | **29 / 30** | 97 % |
| maintainability | **29 / 30** | 97 % |
| test-quality | **26 / 30** | 87 % |
| **`change-focus`** | **17 / 30** | **57 %** |

**This replicates decision 10.3 almost exactly.** That decision recorded, from 34 runs, the two
harnesses agreeing on the other three categories and parting on `change-focus` **18 of 34** — 53 %.
Here, on a different stop, a different overlay and two tasks: **17 of 30, 57 %.** One category is
the outlier and it is the same category.

## What the disagreement looks like, and it is not noise

| task | codex | deepseek | when they differ |
|---|---|---|---|
| BE-003, `n = 17` | `1` on **all 17** | `1 ×9`, `2 ×5`, `null ×3` | deepseek **higher 5, lower 0** |
| BE-004, `n = 13` | `2 ×5`, `1 ×4`, `0 ×4` | `2 ×8`, `1 ×5`, **never 0** | deepseek **higher 4, lower 1** |

**Every disagreement on BE-003 runs one way** — deepseek reads 2 where codex reads 1, five times,
never the reverse. Decision 10.3 recorded the same property: *"always in the same direction"*.

## And the hand re-read named this fork before any sheet existed

The BE-003 hand re-read, committed at `8c56ba8` **before scoring began**, scored `change-focus = 1`
and registered the alternative in a table:

| reading | value | argument |
|---|---|---|
| the added `ErrorCode` constant is outside anchor 2's enumerated set | **1** | the list is exhaustive as written |
| it is "part of `confirm`'s change" by analogy to a required import | **2** | the constant exists only because `confirm` needs it |

**Codex took the first reading on 17 of 17. Deepseek took the second on 5 of 17.** The fork the hand
reader identified in the anchor text is the fork the two harnesses split along, in the direction
predicted, with no case going the other way.

**And on BE-004 the same prediction holds in its second form.** The BE-004 hand re-read named
constructor parameters as the unlisted-but-required change, and anchor 0 requires *two or more
unnamed methods to differ* — which is false on every one of those runs. **Deepseek never returns 0
on BE-004.** Codex returns it four times, on runs where the anchor's own condition does not hold.

## What this establishes

**The `change-focus` anchors are under-determined on both rubrics, and that is now shown three
independent ways:**

1. **Two hand readers** on two rubrics found the same defect — a closed whitelist narrower than a
   correct solution requires — and resolved it oppositely.
2. **Two harnesses** split 17/30 on that category alone while agreeing 97 %, 97 % and 87 % on the
   others, with the disagreement one-directional.
3. **One harness split against itself** on BE-004: six structurally identical runs scored
   `2,2,0,0,0,0`, and the one value the anchors support was returned on none of them.

**This supplies the mechanism decision 10.3 recorded without one.** That decision made
`change-focus` report-only under the Decision H fallback because a swap moved one cell on 18 of 34
runs in one direction. The reason is now visible: **the anchor does not determine the value**, so
which harness reads it decides the number — and a number decided by the reader is not a measurement
of the agent.

**It also narrows my own earlier note.** An addendum in
`change-focus-scorer-defect.md` said the scatter is specific to the BE-004 port, on the grounds that
codex scored BE-003 `1` on twenty of twenty. That is true of **codex**, and the concordance shows it
is not true of the category: on BE-003 the two harnesses disagree on 8 of 17. **Codex's stability on
BE-003 is one harness resolving an ambiguous anchor consistently — not an anchor that determines its
answer.** *Narrowed again by Opus 5, 2026-09-16, from the second reader's own numbers.*

## What does not change

Codex remains the registered scorer and every registered number in E-018 and E-019 is its. Nothing
here is a vote, nothing here re-scores a cell, and **no verdict moves**: BE-003 was a clean null on
all four categories before this analysis and remains one, and BE-004's `change-focus` was already
recorded as unmeasurable rather than `IMPROVED`.

*Opus 5 (claude-opus-5), autonomous, 2026-09-16.*
