# §4 step 7 — scoring E-006 batch 2

`Scored 2026-09-05 by Opus 5 (claude-opus-5), autonomously. Codex is the registered scorer
(Decision C); opencode is the second reader, not a vote. Rubric v2 sha 396e1799eb2b, unmoved.`

**Order, and it matters.** The gate ran first, the hand score was committed second, and only
then were any sheets produced or read. Step 7: *"Read the sheets only after you have written
your own expected score for at least one run by hand."*

| step | result |
|---|---|
| `check-run-gate.sh` on all 20 | **20 admitted, 0 refused** |
| hand score, run `1c905fc9`, committed at `d375cdc` **before any sheet existed** | 2 / 0 / 1 / 1, total 55.0 |
| `codex-score.sh --run-id`, registered | **20 of 20**, every exit 0 |
| `opencode-score.sh --run-id`, second reader | **14 of 20** — stopped on the ollama **weekly** usage limit |

## The hand score against the registered scorer

| category | my hand score | codex | agree? |
|---|---|---|---|
| architecture-consistency | 2 | 2 | yes |
| **maintainability** | **0** | **0** | **yes — and this is the cell I registered as contestable first** |
| test-quality | 1 | 1 | yes |
| change-focus | 1 | 1 | yes |

Four of four. The maintainability cell is the one that carries weight: I wrote down *0*, with
the competing reading (*1*, on the literal text *"an `if` / `else if` / `else` chain"*) and a
12.5-point swing spelled out, **before** codex ran. Codex reached 0 independently. And on
change-focus codex's stated reason is the hand score's reasoning in its own words — *"ApiError
enum changes outside confirm while unnamed controller methods remain identical."*

## Codex, the registered numbers

| category | treatment `n=10` | control `n=10` |
|---|---|---|
| architecture-consistency | **2 × 10** | **2 × 10** |
| maintainability | 0 × 7, **2 × 3** | 0 × 9, **2 × 1** |
| test-quality | 1 × 10 | 1 × 8, 2 × 1, **null × 1** |
| change-focus | **1 × 10** | **1 × 10** |

The one `null` is run `67547dbc`, and it is a **measurement**: opencode's sheet gives the
reason — *"no file under `src/test/` among attachments"*. That run's diff touches 2 files, not
3. Both harnesses null it independently.

## Cross-harness: 47 of 56 cells exact, and every disagreement is one category

| category | exact agreement |
|---|---|
| architecture-consistency | **14 of 14** |
| maintainability | **14 of 14** |
| test-quality | **14 of 14** |
| **change-focus** | **5 of 14** |

All nine disagreements are `change-focus`, all in the same direction — codex `1`, opencode `2`.

### Where they disagree, go to the diff. The diff says codex

The rubric's `change-focus` anchor 2 requires *"Only `confirm`, and imports required BY SYMBOL
for `confirm`, differ."*

**All 20 runs modify `ApiError.kt`**, adding an `ErrorCode` constant. That is neither `confirm`
nor an import. Anchor 2 therefore cannot hold on any run in this batch, and `1` is correct on
all 20.

The two harnesses' own evidence fields show the mechanism exactly:

| | cites | verdict |
|---|---|---|
| **opencode** on `2eab4597` | `ShipmentController.kt:57` — **one file, one tree** | *"only confirm added, unnamed methods and imports identical to baseline"* — true of that file, and not the question |
| **codex** on `2eab4597` | `ApiError.kt:36; baseline/ApiError.kt:36` — **both files, both trees** | *"ApiError enum changed outside confirm and its imports"* |

**This is a repeat, not a discovery, and that is what makes it worth recording.**
`agent-learning-lab/CLAUDE.md` already documents it: on the first cross-harness comparison
opencode *"named methods and cited one tree"* while a pre-agent tree sat attached and unread,
and *"the diff sided with codex"* — specifically over *"a new `ErrorCode` constant in a second
attached file"*. That was four occurrences and was called a property of the harness. **This
batch adds nine more, on the same category, against the same construct, in the same
direction.** It is an argument for Decision C at a much larger `n`, and it is a fact about the
scorer rather than about the agent.

## The second reader ran out, and the experiment's numbers did not

Opencode stopped after 14 runs on the **ollama weekly** usage limit — two runs exited 1
(infrastructure, discarded per §4a, not counted as findings) and four were never attempted:
`2a8a616e`, `323591a9`, `57a61b29`, `502bf6f1`.

**§4c anticipates the opposite failure.** Its protocol is for *codex* exhausting quota, where
the registered numbers are the casualty and the exit gate must wait. Here the **registered
scorer completed 20 of 20** and only the second reading is short. So:

- no registered number is missing, and the exit gate is not blocked on this
- Decision H is **not** triggered: it fires on a codex outage, and codex had none
- the four unscored second readings are **owed, not waived** — the runs are kept, and
  `opencode-score.sh` on those four ids is the first thing to do when the weekly limit clears
- nothing is scored by a substituted model. Picking a different opencode model to finish the
  batch would put an unmeasured scorer into a comparison, which §4c forbids in terms

## What is data here and what is not

Recorded as data: every cell above. **Not answered here:** the exit gate, the keep/modify/
remove decision, and any claim about whether the boundary worked — those are §4 steps 8–11,
and the report (`make baseline-report`) has not been run.

Two observations are flagged for those steps rather than interpreted now:

1. **`change-focus` is 1 on 20 of 20 under the registered scorer.** P2 registered exactly this
   with an MDE of `none`. The dead-category count reaches **60 of 60** across five experiments.
2. **`architecture-consistency` is 2 on 20 of 20, both arms, zero variance** — and it carries
   **35 of the 100 points**. It was never registered as dead. On this batch it behaves like
   `change-focus` does, and that belongs in the exit gate and in the note to the author.
