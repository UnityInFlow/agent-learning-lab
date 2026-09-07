# The second-reader debt from stops 10 and 11, discharged 2026-09-07

Thirty-four `opencode-score.sh` sheets were owed and recorded as **not waived**: fourteen from
stop 10 (`EXP-B4-DELIBERATE-NOTOOLS` ×10, `EXP-B4-AGENT-BOUNDARY` batch 2 ×4) and twenty from
stop 11 (`EXP-4B-ORCH-OVERHEAD`). Both debts were blocked on the ollama-cloud **weekly** usage
limit, first seen 2026-09-05T18:06Z and re-confirmed still in force by the preflight of
2026-09-06T20:5xZ.

**The limit has lifted.** It was found by the §0a preflight of 2026-09-07T07:27Z: the *default*
`opencode-review.sh` panel — the ollama one — returned
`findings/opencode/review-run-record-20260907T072723Z.md`, 14 534 bytes with twelve finding
sections, where the same command on 2026-09-06 returned
`findings/opencode/review-run-record-20260906T205858Z.md`, **903 bytes with zero sections**: a
header-only stall. Those two files, not a remembered timestamp, are what the claim rests on.

The scoring route was then proved **separately**, not inferred from the review route — they are
different opencode entry points and one working does not imply the other: one sheet on `e8d881b9`
at 07:38:50Z —
`findings/opencode/score-observatory-run-e8d881b9-5fb2-406e-947a-d32e107e157a-20260907T073850Z.yaml`,
1 926 bytes, four categories with scores 2 / 0 / 2 / 2, zero nulls, `rubric_sha 396e1799eb2b`. It is
in the set counted below, and it is not the header-only file of 2026-09-05 that carries the same
run id: that one is `…-20260905T180650Z.yaml` and has no `categories:` key.

Nothing here is a re-measurement of the agent. No benchmark run was started; every sheet reads a
run record and a kept worktree that already existed. Decision C is untouched — **codex remains the
registered scorer and produced every number these stops report**; these are the second readings,
and their only job is to measure cross-harness distance.

## What was produced

| | |
|---|---|
| sheets owed at session start | 34 |
| sheets carrying a measurement | 34 — the `e8d881b9` probe plus the 33-id batch |
| YAML files written | 35 — the 34 above plus `abd08a80`'s first attempt, which carries no `categories:` key and is therefore not a measurement |
| scorer | `ollama-cloud/deepseek-v4-pro`, opencode 1.18.27 — §4c's registered fallback and no other |
| rubric | `benchmark/rubrics/backend-quality.yaml` at `396e1799eb2b`, the same sha every registered codex sheet asserts |
| API | `LAB_OBSERVATORY_API=http://127.0.0.1:18081` (the SSH tunnel; the colima host forward on 8081 is dead and reads as healthy) |
| batch logs | `20260907-batch-1of33.log`, `20260907-batch-32of33.log` |
| run ids | `owed-run-ids.txt` |

**34 against 35 is not a hand count.** The split is drawn by the registered checker, not by me:
`./tools/check-sheet-categories.sh benchmark/rubrics/backend-quality.yaml <sheet>` over all 35 files
admits **34** and refuses **1**, and the one it refuses is exactly the file called out below —
`20260907-sheet-category-check.txt`. That is an **L2** boundary: something executes and rejects.

Shape is not coverage, though — thirty-four well-formed sheets could be two sheets for one run and
none for another. `verify-sheet-coverage.sh` (ShellCheck clean, added at round 3's request) asserts
the **identity** side: for each of the 34 owed run ids, exactly one of this session's sheets is
admitted. `20260907-sheet-coverage.txt`: *34 run id(s) with exactly one admitted sheet, 0 without*,
exit 0.

`abd08a80` exited 2 on its first attempt: opencode asked itself for an `external_directory`
permission and auto-rejected, so the sheet stops after its header. **A missing cell is not a null
cell**, so it is not a measurement; it is kept, not deleted, and labelled here. The retry at
08:14:57Z returned a full sheet. Both files remain on disk.

The first batch script attempted **one** id and printed `BATCH COMPLETE`, because the scorer's
child consumed the loop's stdin. It is recorded rather than quietly fixed: a batch runner that
reports success over one of thirty-three is this project's house failure mode — a control
reporting over a scope smaller than it claims — and it was caught only because the log carried a
count. The fix is `</dev/null` on the scorer call.

## The result: 118 of 136 cells exact, and every disagreement is in one category

`20260907-concordance.txt`, re-derivable with `concordance.py`.

| category | exact agreement, codex vs deepseek |
|---|---|
| architecture-consistency | 34 / 34 |
| maintainability | 34 / 34 |
| test-quality | 34 / 34 |
| **change-focus** | **16 / 34** |

Eighteen disagreements, **all of them in `change-focus`**: fifteen where the second reader scores
**2** against codex's 1, three where it emits **`null`** against codex's 1. Not one runs the other
way.

### The distribution is the finding, not the agreement rate

| harness | `change-focus` over the same 34 runs |
|---|---|
| codex (registered) | `1` × 34 |
| deepseek-v4-pro (second reader) | `2` × 15, `1` × 16, `null` × 3 |

**codex returns one value across the batch; the second reader returns three.** The 34 runs are 34
different diffs, but they are the same *shape* of change in the one respect the category asks
about: every one of them touches exactly the same two main-source files, `ShipmentController.kt`
and `ApiError.kt`, and no others — `20260907-adjudication.txt`, re-derivable with
`adjudicate-all-18.py`, which reads `git diff HEAD --name-only` in each kept worktree.

They are **not** identical inputs, and an earlier draft of this file leant on a claim that they
were. Round 3 of the review objected that unexamined differences — the shape of the `confirm`
implementation, say — might be what sorts the second reader's answers, and the objection is right.
Tested and conceded: `diff-cluster.py` hashes each run's normalised main-source diff and finds
**34 distinct diffs across 34 runs** (`20260907-diff-clusters.txt`). There is no pair of
byte-identical changes scored differently, so **the "same input, different answer" reading is not
established and is withdrawn.** The class-KDoc split, the one input feature examined, does not sort
them either — 15 runs rewrite it and 19 do not, and both groups produce all three outputs (1/2/null
= 8/5/2 and 8/10/1) — but one feature ruled out is not all features ruled out.

**The correctness result does not rest on that claim and is unaffected.** Whatever sorts the second
reader's answers, the rubric decides what the answer should be, and the next section evaluates the
rubric on all 34 runs directly.

### All eighteen adjudicated, not two

The rubric closes the ladder by rule: `0` if the 0 anchor holds, `2` only if **every** clause of
anchor 2 holds, `1` otherwise. Anchor 2's binding clause is *"Only `confirm`, and imports required
BY SYMBOL for `confirm`, differ."*

**Both anchors have to be evaluated, and the first draft of this file evaluated only one.** The
acceptance gate rejected it for exactly that — *"the rubric's anchor 0 is never quoted or evaluated;
only anchor 2 is shown to fail"* — and the gate was right: a run where anchor 0 holds scores **0**,
not the residual, so failing anchor 2 alone establishes nothing.

**Anchor 0**, verbatim: *"Two or more methods the ticket did not name differ from the baseline in
anything beyond INVISIBLE WHITESPACE."* The unnamed methods are `create`, `getById` and `list`.
`anchor0-check.py` reads each kept worktree's `git diff HEAD -U0` against the baseline line ranges
of those three methods and asks how many of them any hunk touches. Result, `20260907-anchor0.txt`:

    runs checked: 34
    anchor 0 holds (2+ unnamed methods differ): 0
    exactly one unnamed method differs      : 0
    no unnamed method differs               : 34

Not one unnamed method is touched in any of the 34 runs, so anchor 0 fails on all 34. Both
harnesses' own stated reasons say the same thing independently — *"create/getById/list identical to
baseline"* appears in the second reader's text and *"unnamed methods match"* in codex's.

*(The first version of this check said `fun list` differed in 31 of 34 runs. It was wrong: `list` is
the last method in the baseline, so an extractor that reads "to the next blank line" swallowed the
appended `confirm` block on the treated side and compared it against nothing on the baseline side.
The number was implausible enough to look at — a parser that finds a difference in 31 of 34 runs in
the one method nobody edited — and the rewrite works from hunk ranges instead. It is recorded
because the failure is this project's own: a check reporting over a scope it does not actually
cover.)*

**Anchor 2**'s binding clause fails too. `ApiError.kt` is a second source file, neither `confirm`
nor an import, and it differs from the baseline in all 34 runs — the 18 that disagree and the 16
that agree alike.

Anchor 0 fails on 34 of 34 and anchor 2 fails on 34 of 34, so by the rubric's own closing rule the
score is the residual, **`1`, on 34 of 34 — and codex's `1` × 34 is correct**. There is no
unexamined cell in which the second reader's `2` could be the right answer, and none in which a `0`
could be. The adjudication is structural and covers the whole set, not a sample of two.

Two cells were additionally re-derived by hand at the line level, one per stop:

1. **`207ff23d`** (stop 11). codex 1, *"Class documentation outside confirm differs from baseline"*,
   `ShipmentController.kt:14`. `git diff HEAD` in the kept worktree: the class KDoc loses three
   lines and gains one — `Baseline shipment API: create, read, list.` → `Shipment API: create,
   read, list, and confirm.` The second reader's stated reason, *"only confirm added;
   create/getById/list and imports identical to baseline"*, is true and does not address the doc.
2. **`a06e80c5`** (stop 10). codex 1, *"Unnamed methods match, but ApiError.kt also changes"*.
   `git diff HEAD --stat`: three changed files, `ApiError.kt` gaining one line,
   `SHIPMENT_INVALID_STATUS,`. The second reader's reason — *"create/getById/list identical to
   baseline, only confirm added, no import change"* — again describes only the controller.

### The mechanism, stated only as far as the evidence carries it

`deepseek-v4-pro` states its `change-focus` reasons in terms of **the controller's methods and
imports**; codex states its in terms of **the whole change**, naming `ApiError.kt` or the class doc.
On the sixteen runs where the second reader scores 1 it is agreeing with codex about a file its own
stated reason never mentions.

Three readings fit that, and this batch does not separate them:

1. the second reader does not look outside the controller, and scores 1 for other reasons when it does;
2. it looks, and judges `ApiError.kt` irrelevant — a stated reason that omits a file is not proof the
   file went unread;
3. it is unstable on this dimension, with an upward bias.

**Nothing here decides between them**, and the earlier draft of this file claimed reading 3 on
evidence that does not support it. What all three share is the only thing this file needs: on 18 of
34 runs the second reader returns a value the rubric does not allow, and on 34 of 34 codex returns
the value the rubric requires. That is a statement about correctness against a registered
instrument, not about the scorer's internals, and it holds whichever reading is true.

Stated with its `n`: **true of these 34 runs**, all on BE-003, all scored against
`backend-quality.yaml` at `396e1799eb2b`. Nothing here is claimed as a property of the scorer on
another task or another rubric — and the one rubric it will next meet, BE-004's, has a
`change-focus` anchor 2 that is *deliberately* reachable, which is a different shape again.

### What this changes, and what it does not

- **It changes nothing about stops 10 and 11.** Both closed on codex sheets under Decision C, and
  every number they report is unmoved. Stop 10 stays `INCONCLUSIVE`, stop 11 stays `NOT DETECTABLE`.
  Nor does it change any *other* category: three of four agree 34/34, which is also the reason to
  believe the batch ran correctly at all.
- **This is not a new finding. It is a recorded one, confirmed at seven times the `n` and
  adjudicated.** `agent-learning-lab/CLAUDE.md` has said since 2026-09-01, at `n = 5`: *"Where they
  disagreed, opencode's fact was wrong"* — naming **a deleted class KDoc on one run and a new
  `ErrorCode` constant in a second attached file on two others**, which are the same two causes this
  batch finds at `n = 34`. It also already names the harness behaviour: opencode *"named methods and
  cited one tree"* where the anchor says *"cite the line in both trees"*, called a property of the
  harness at four occurrences and an argument **for** Decision C. **Any claim here to have exposed
  something new would be false**, and an earlier draft of this file made exactly that claim — that
  the previous concordance was *"taken on a set too small to expose this"*. The set was small; it
  exposed it anyway. What this batch adds is scale (3 of 5 → 18 of 34), a direction that is
  **uniform** across all 18, and an adjudication against both anchors on all 34 that turns
  *"opencode's fact was wrong"* from a reading of three diffs into a rule-based verdict on every run
  in the set.
- **What that record left open is now closed.** CLAUDE.md called the score itself a live question —
  *"whether that deserves 1 or 2 is a live rubric question — a required enum constant is arguably
  part of the change — and it belongs in a rubric round"*. It does not need a rubric round. Anchor 2
  requires that **only** `confirm` and its by-symbol imports differ; `ApiError.kt` is neither, so
  anchor 2 fails whatever one concludes about enum constants, and with anchor 0 also failing the
  residual `1` is the rubric's own answer as written. The rubric was not ambiguous here — it had
  simply never been evaluated end to end on these runs.
- **It puts a measured condition on §4c's Decision H.** Decision H would promote
  `deepseek-v4-pro` to registered scorer on a codex outage longer than twelve hours. On this
  evidence that swap would change the `change-focus` cell on **18 of 34** runs of this shape — 15
  scored `2` where the registered scorer scores `1`, and 3 more returned as `null`, which is a
  measurement and not a moved score, so the count of *wrong numbers* is 15 and the count of *cells
  that would not match* is 18 — in one direction, and silently, since the second reader's stated
  reasons read as correct in isolation. Decision H remains the author's and is **not amended
  here**; what it now has is a number attached to a mechanism that was already on record.
- **It is a live condition on stop 12.** Author decision 9 already requires the BE-004 rubric to be
  proved on its five fixtures before any BE-004 run is scored. This adds that the `change-focus`
  separation must be demonstrated **on codex**: a separation shown by the second reader would not
  substitute, on this dimension, on this evidence.

## §4a review disposition — `-P codex`, two rounds

### Round 1 — `findings/opencode/review-README-20260907T082230Z.md`, seven sections

Invoked with `-A`, which **skipped the acceptance gate**. That is recorded as an error of mine, not
a pass: §4a's gate is the thing that decides whether a round ends, and I ran the round without it.

| # | finding | disposition |
|---|---|---|
| 1 | the blocking preflight is cited only as `2026-09-06T20:5xZ`, so two logged attempts could be confused | **fixed** — the claim now rests on two named files, the 903-byte 0-section `review-run-record-20260906T205858Z.md` against this session's 14 534-byte 12-section one |
| 2 | the counts do not reconcile: 33 owed plus two files for `abd08a80` is 35, not 34 | **fixed, and it was a real defect** — 34 measurements against 35 files, and the split is now drawn by `check-sheet-categories.sh`, which admits 34 and refuses 1 |
| 3 | a biased-upward stochastic scorer would produce the same one-directional pattern from noise | **conceded, not refuted** — "noise is symmetric" is gone and the instability reading is stated as a surviving alternative that does not change the conclusion |
| 4 | — | no finding raised |
| 5 | only 2 of 18 disagreements were re-derived; an unexamined run could contradict the mechanism | **fixed** — all 18 adjudicated structurally, and the 16 agreements with them |
| 6 | if one unexamined codex `1` wrongly satisfied anchor 2, Decision H would correct rather than inflate | **fixed** — anchor 2 fails on all 34, so no such cell exists in this set |
| 7 | a 16-cell evidentiary gap between what was adjudicated and what was claimed | **fixed** by finding 5's adjudication |

Five corrected, one conceded, one not a finding. Round 1's own summary of this table said "right on
six of six", which round 2 caught as an overstatement: conceding an alternative is not the same as
correcting an error.

### Round 2 — `findings/opencode/review-README-20260907T082839Z.md`, nine sections, gate **REJECT**

**The gate's objection was correct and is the most useful thing any reviewer said today:**

> The artifact's load-bearing reasoning claim — "codex's `1` × 34 is correct on all 34 by the rule"
> — does not follow from the rule alone, because the rubric's anchor 0 is never quoted or
> evaluated; only anchor 2 is shown to fail.

That was true. The conclusion rested on half the ladder. **Fixed by running the check that was
missing**: `anchor0-check.py` evaluates anchor 0 on all 34 runs and it fails on all 34 — no unnamed
method is touched at all. The write-up above now quotes both anchors and shows both failing, and
the first version of that check was wrong in a way worth keeping on record.

| # | finding | disposition |
|---|---|---|
| 1 | the `e8d881b9` probe sheet is claimed but not identified, and shares a run id with the 2026-09-05 header-only file | **fixed** — both paths named, with sizes and the presence or absence of `categories:` |
| 2 | "34 measurements" excludes a file by a rule that is stated but does not execute | **fixed** — `check-sheet-categories.sh` over all 35 files, 34 admitted / 1 refused; the boundary is now L2, not prose |
| 3 | — | no finding raised |
| 4 | runs that rewrite the class KDoc are not structurally identical to those that do not, so the inputs are not invariant | **fixed** — the claim of identity is withdrawn; the KDoc split is now cross-tabulated (15/19) and shown not to sort the three outputs, with the direction it *does* lean stated |
| 5 | anchor 0 is never evaluated, yet the residual is concluded | **fixed** — see the gate objection above; anchor 0 now evaluated on 34 of 34 |
| 6 | a scorer that does not mention `ApiError.kt` may have read it and judged it irrelevant | **fixed by weakening the claim** — that reading now survives per cell and is answered across the set, and the "innocent reading is ruled out" sentence is gone |
| 7 | "roughly half" conflates 15 score changes with 3 nulls | **fixed** — 15 wrong numbers, 18 non-matching cells, both stated |
| 8 | "six of six" miscounts a concession as a correction | **fixed** — round 1's table now reads five corrected, one conceded |
| 9 | cross-cutting: reviewers would diverge most on whether anchor 0's omission invalidates all 34 | **fixed** by finding 5 |

### Round 3 — `findings/opencode/review-README-20260907T083556Z.md`, five sections, gate **REJECT**

Round 2's disposition originally said the round would not be re-run and argued that a gate re-run
by the author of the fix is a weaker record than the objection plus its answer. **Round 3's gate
objected to precisely that**, and was right to:

> The last executing gate verdict on this file is REJECT ... and the author records it as REJECT
> rather than re-running it to green, then declares all 16 findings "fixed or conceded." The
> author's claim of closure therefore rests on self-assessment, not on a fresh executing control.
> §4a still allows a third round, so the stop condition is choice, not exhaustion.

So the round was run, which is what makes that paragraph obsolete rather than defended.

| # | finding | disposition |
|---|---|---|
| 1 | `check-sheet-categories.sh` admits by shape, not identity — 34 well-formed sheets could be two for one run and none for another | **fixed** — `verify-sheet-coverage.sh` added, ShellCheck clean, asserting exactly one admitted sheet per owed run id; 34 of 34, exit 0 |
| 2 | only the class-KDoc split was cross-tabulated; an unexamined difference such as the `confirm` implementation shape could be sorting the scores | **conceded and the claim withdrawn** — `diff-cluster.py` finds 34 distinct diffs across 34 runs, so no two identical inputs were scored differently and the "same input, different answer" reading is not established |
| 3 | "nothing in the input sorts the answers" is unproved; the split could be reproducible-conditional rather than unstable | **conceded, same withdrawal** — the mechanism section now lists three readings and says this batch separates none of them |
| 4 | closure was declared without re-running the rejected gate | **fixed by running it** — this round is that re-run |
| 5 | cross-cutting: non-KDoc input differences uncontrolled, no executing acceptance result for the post-fix version | **partly fixed, partly standing** — the uncontrolled differences are conceded above; the gate verdict below is what it is |

### Where this stops, and what the record says

§4a allows at most three rounds and they are spent. Every finding across all three — sixteen in
rounds 1 and 2, five in round 3 — is **fixed or explicitly conceded; not one is disputed.** Two
substantive claims were **withdrawn** under review rather than defended: that the inputs were
invariant, and that the second reader is demonstrably unstable.

**The gate's last executing verdict on this file is REJECT**, and it is recorded that way. The
version it rejected is not the version this file now is, and no fourth round is permitted to say
whether the fixes moved it — so the honest statement is *round-3 findings addressed, gate not
re-run, verdict REJECT standing*, and **not** that this artifact passed. Under §4a a review that
ends `UNDECIDED` after round three "is recorded as such and is not a pass"; the same applies here,
more strongly, to one that ends REJECT.

What survives the whole exchange is narrower than the first draft and better founded than it: over
34 runs on BE-003 the registered scorer returns the value the rubric requires on all 34, the
fallback scorer returns a different value on 18, and the anchors were evaluated rather than
asserted. The parts that did not survive are named above.

*Produced and interpreted by Opus 5 (claude-opus-5), autonomous, 2026-09-07. The batch was run under
the orchestrator's direction; the two hand re-derivations, the anchor evaluations, the cross-tab,
the mechanism and the Decision H caveat are the orchestrator's own and were not taken from any
sheet or any subagent.*
