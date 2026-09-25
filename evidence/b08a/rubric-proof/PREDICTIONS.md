# BE-005 rubric fixture proof — the predicted directions, written BEFORE the first scoring call

The rubric under proof is `benchmark/rubrics/backend-quality-be005.yaml`, **version `2-be005`,
sha `945817b8c509`** (`shasum -a 256 … | cut -c1-12`). It is the port of
`../backend-quality-be005.DRAFT.yaml` (sha `a36508802670`) with the two additions the author's
standing instruction named; the port note in the file itself says what each addition costs.

This file exists so the proof can be refuted. **It is committed before `codex-score.sh` is
invoked once**, and the commit timestamp beside the first sheet's `scored_utc` is the evidence
of that ordering — the same discipline E-011 used at `c42120b` before the BE-004 proof
(`experiments/E-011-workflow-phases-BE004.md:320-322`).

## The registered pass condition, carried verbatim from the BE-004 proof

> Among the variants, all scored under identical conditions (same rubric, `known-good` attached
> as baseline to each): in each dimension's column, the variant that varies it scores **strictly
> below every other cell** in that column.

— `experiments/E-011-workflow-phases-BE004.md:397`

Two readings that BE-004's proof settled and this one inherits unchanged:

- **A `null` is a measurement, not a missing cell, and it does not enter any separation row**
  (`E-011:350-351`). Five of the seven fixtures carry no file under `src/test/` — verified by
  `find <fixture> -path '*src/test*' -name '*.kt'`, which returns 0 for `known-good`,
  `good-inline-envelope`, `good-nested-ifs`, `good-noisy-diff` and `good-stored-consistent`, and
  1 for each of `good-strong-tests` and `good-weak-tests`. So `test-quality` separates **on its
  own pair** and the other five cells are structural nulls.
- **`known-good` is scored with no baseline attached** and the scorer's prompt says so
  (`tools/codex-score.sh:30`), so its `change-focus` cell hits that category's precondition and
  is `null`. E-011 had to correct exactly this cell before its first scoring call (`27b54ab`);
  it is registered here in advance instead.

### One reading this proof has to add, because BE-005 is the first task with TWO variants on one dimension

BE-004 had five variants, one per dimension. BE-005 has six, and **`architecture-consistency`
has two**: `good-inline-envelope` varies convention (i), the error envelope, and
`good-stored-consistent` varies convention (ii), where fulfilment lives. Both are predicted at
0, because the rubric's anchor 0 fires on **either** convention — so neither can be "strictly
below" the other. The condition is therefore read, for that column only, as: **each varying
variant scores strictly below every cell that does not vary that dimension.** Two variants
tying at 0 is the anchor working as written, not a failure to separate. Registered here, before
the scoring, so it cannot be a reading adopted after seeing a tie.

## The predicted cells — all seven fixtures, all four dimensions

`V` marks the dimension the fixture varies. Anything not `V` is predicted at the reference
value because that fixture's other files are byte-identical to `known-good`.

| fixture | architecture-consistency | maintainability | test-quality | change-focus |
|---|---|---|---|---|
| `known-good` | 2 | 2 | `null` (no test file) | `null` (no baseline attached) |
| `good-inline-envelope` | **0 · V (i)** | 2 | `null` | 2 |
| `good-stored-consistent` | **0 · V (ii)** | 2 | `null` | 2 |
| `good-nested-ifs` | 2 | **0 · V** | `null` | 2 |
| `good-noisy-diff` | 2 | 2 | `null` | **0 · V** |
| `good-strong-tests` | 2 | 2 | **1 · V (high)** | 2 |
| `good-weak-tests` | 2 | 2 | **0 · V (low)** | 2 |

## The four separation rows, and what refutes each

| dimension | the row that must hold | what refutes it |
|---|---|---|
| architecture-consistency | `good-inline-envelope` = 0 **and** `good-stored-consistent` = 0, each strictly below all five non-varying cells | either variant at 1 or 2, or any non-varying cell at 0 |
| maintainability | `good-nested-ifs` strictly below the other six | `good-nested-ifs` ties or exceeds any other cell |
| test-quality | `good-weak-tests` strictly below `good-strong-tests` (the five nulls excluded) | the two tie, or a fixture with no test file returns a number instead of `null` |
| change-focus | `good-noisy-diff` strictly below the five non-null non-varying cells | `good-noisy-diff` ties any of them, or `known-good` returns a number instead of `null` |

**A dimension that does not separate is a §7 halt** (author decision 9), not something to edit
past. If one fails, the rubric is not registered, no B8a run is scored, and the halt names the
dimension and the two cells.

## The two predictions most likely to be wrong, named in advance

1. **`good-strong-tests` at `test-quality` = 1, not 2.** This is the cost of addition 2 and the
   port note states it: no fixture's tests call `PUT /orders/{orderId}/quantity`, so clause (e)
   is unmet and the top anchor is predicted unreached by any fixture. If the scorer returns 2
   here it has ignored clause (e), and that is a finding about the rubric's readability, not a
   pass. If it returns 1 the separation still holds at 1 versus 0 — but **no fixture will have
   demonstrated that anchor 2 is reachable**, which is raised for the author as a recommended
   eighth fixture rather than fixed here: a benchmark fixture is a registered variable (§6) and
   BE-005 is the author's build.
2. **`good-stored-consistent` at `architecture-consistency` = 0.** This variant is new to this
   benchmark and is the only one whose defect **every gate passes** — its fixture note says the
   evaluator "cannot tell it from `known-good` and must not try (exit 0)". The rubric is the only
   instrument that can see it. If it scores 1 or 2, B8a loses the registered outcome its trap
   lives in, and that is the single most consequential cell in this table.

## How it is scored

Seven calls, one per fixture, the shape E-011 used (`E-011:415-417`):

```
./tools/codex-score.sh benchmark/rubrics/backend-quality-be005.yaml \
    ../agent-observatory-benchmarks/tasks/BE-005-partial-fulfilment/fixtures/<fixture>
```

**codex and nothing else** (author decision 10.2). A deepseek or any opencode sheet does not
substitute and is not sought here; on 34 runs the two harnesses agree 34/34 on three categories
and only 18 of 34 on `change-focus`, which is why 10.2 exists. The §0a preflight for this session
put codex at `codex-cli 0.154.0`, exit 0, with all four categories present on a live sheet, so
Decision H is not fired.

The benchmarks tree is at `main` = `2fc445d2a65b13a793ccddf537e1460f63cd784d`, and
`tasks/BE-005-partial-fulfilment/verify-evaluator.sh` was re-run there in this session at
**17 of 17, exit 0**.

*Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-25; the author did not review before
the proof. The two additions to the rubric were made under the author's standing instruction of
2026-09-17 (`AUTHOR-DECISION-11-CONTINUE.md`), whose `>= 3 WRONG` branch named them; their
design — an AND rather than an OR for clause (e), and a package-independent fourth write site —
is mine and is argued in the rubric's port note.*
