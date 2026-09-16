# The only non-zero delta in this batch is a scorer defect, and it is demonstrable from the diffs

**Written 2026-09-16 at §4 step 7, before the step-8 verdict, from the 36 registered codex sheets.**

## What the medians say

All sixteen category medians are equal between arms except **one**:

| task | category | treated median | control median | delta |
|---|---|---|---|---|
| BE-003 | all four | 2 / 0 / 1 / 1 (`n = 10`) | 2 / 0 / 1 / 1 (`n = 10`) | **0, 0, 0, 0** |
| BE-004 | architecture-consistency, maintainability, test-quality | 2 / 0 / 1 (`n = 9`) | 2 / 0 / 1 (`n = 7`) | **0, 0, 0** |
| BE-004 | **`change-focus`** | **1** (`n = 9`) | **0** (`n = 7`) | **+1** |

A one-point median move in the better direction is the exact condition of **decision-rule row 6,
`IMPROVED`** — and row 6, as registered before the batch, carries its own warning: *"B8's treatment
has no mechanism by which it should, so a positive here is first a reason to check the delivery
proof."* The delivery proof is not the problem: P1 held on 20 of 20 treated and 17 of 17 scored
control runs. So the check went to the runs themselves.

## The distributions, and a sign flip no treatment effect can produce

```
BE-004 change-focus
  treated n=9   [0,1,1,1,1,2,2,2,2]   median 1   mean 1.333
  control n=7   [0,0,0,0,1,2,2]       median 0   mean 0.714
  exact two-sided permutation test on the full arms: p = 0.2378   (11 440 labellings)
```

**The full-arm test does not separate the arms.** Stratifying by the clamshell sleep shows why:

| stratum | treated | control | medians | exact p |
|---|---|---|---|---|
| pre-sleep | `[0,1,1,2]` | `[1,2,2]` | 1 vs **2** — *control higher* | 0.3714 |
| post-sleep | `[1,1,2,2,2]` | `[0,0,0,0]` | **2** vs 0 | 0.0079 |

**The direction reverses at the lid close.** Before it, the control scores higher; after it, the
treated does. A treatment effect does not change sign when a laptop lid shuts, and the control arm's
`change-focus` collapsing to `0,0,0,0` is the whole of the median delta.

**And the sleep cannot be acting on the scorer**: all 36 sheets were produced in one continuous
25-minute window on 2026-09-16, long after every run finished. Whatever differs, it is in the runs
or in the reading of them — not in the machine at scoring time.

## So the runs were compared, and they are not different

Six BE-004 control runs, three scored **2** and four scored **0**:

| run | change-focus | hunk contexts in both controllers | deletions in `src/main` | methods added |
|---|---|---|---|---|
| `5bbd7910` | **2** | `class OrderController(`, `class ShipmentController(`, one import | none | `cancel` only |
| `e8bb7e73` | **2** | identical | none | `cancel` only |
| `67129732` | **0** | identical | none | `cancel` only |
| `94a6b3a6` | **0** | identical | none | `cancel` only |
| `af75aeeb` | **0** | identical | none | `cancel` only |
| `e352ec58` | **0** | identical | none | `cancel` only |

**No hunk in any of the six lands inside an unnamed method. There are no deletions in `src/main` on
any of them.** A run scored 2 and a run scored 0 open with byte-identical additions:

```
+import com.unityinflow.sample.shipment.InMemoryShipmentRepository
+import com.unityinflow.sample.shipment.ShipmentStatus
+    private val shipmentRepository: InMemoryShipmentRepository,
+    @PostMapping("/{orderId}/cancel")
```

## Against the anchor text, neither 2 nor 0 is supportable — and the scorer never once returned 1

Anchor **0** requires *"**Two or more** methods the ticket did not name differ from the baseline in
anything beyond INVISIBLE WHITESPACE"*. **Zero unnamed methods differ on all six runs**, so the 0
condition is factually false on the four runs that received it.

Anchor **2** requires that the only differences be a closed list — `cancel` and the imports it
requires by symbol, the `create` guard and its imports, `Order`'s status field and enum, one
repository query method, and new `ErrorCode` constants. **Every one of the six adds a constructor
parameter**, which is not on that list, so anchor 2 is not fully satisfied either.

What the anchors actually support for all six is **anchor 1, the residual** — *"neither the 0
condition nor every clause of 2"*. **The registered scorer returned 1 on none of them.** It split
six structurally equivalent runs across the two anchors whose conditions are demonstrably not met,
and returned the one anchor that fits on zero of them.

## What this is, and what it is not

**It is not a treatment effect**, and the `IMPROVED` row must not be claimed from it. **It is not
the clamshell sleep either** — the sleep split the arm in time, but the runs on both sides are
structurally identical, so the sleep is a coincidence of ordering here rather than a cause.

**It is the `change-focus` instrument**, and it is the third independent line of evidence pointing
at the same place in one step:

1. the BE-003 hand re-read found anchor 2's whitelist too narrow for a correct solution (a required
   `ErrorCode` constant);
2. the BE-004 hand re-read found the same defect on a different rubric (required constructor
   parameters) and resolved it the opposite way;
3. and now the registered scorer, on six equivalent runs, returns `2,2,0,0,0,0` and never 1.

Decision 10.3 already records `change-focus` as the one category where codex and opencode disagree
— 18 of 34 on BE-003, always in the same direction. **This step supplies the mechanism: an anchor
set whose 2 is unreachable for a correct solution and whose 0 is unreachable for a clean one, which
leaves the reader choosing between two anchors that do not fit.**

**Nothing here can be fixed at this stop.** Both rubric shas are registered variables cited by four
experiments, and §6 forbids moving one mid-experiment. What this step owes is the finding, recorded
with its evidence, and a `change-focus` row that is **reported as unmeasurable on BE-004 rather than
read as `IMPROVED`**.

*Opus 5 (claude-opus-5), autonomous, 2026-09-16. Every diff fact above was derived in the main
context from the kept worktrees, not from a subagent's report.*

---

## Addendum, same day, written after the BE-003 arm was tabulated — this NARROWS the claim above

**The section above says "the `change-focus` instrument". The BE-003 numbers say that is too broad,
and the correction belongs here rather than as an edit to what was already written.**

On **BE-003, `change-focus` is perfectly stable: `1` on all ten treated runs and `1` on all ten
control runs — twenty of twenty, no scatter at all** — and `1` is exactly what the BE-003 hand
re-read arrived at independently. So on that rubric the anchor ambiguity the hand re-read identified
is real *in the text* and yet the scorer resolved it consistently, and consistently the same way a
careful human reader did.

**The scatter is specific to the BE-004 rubric.** Six structurally equivalent BE-004 control runs
returned `2,2,0,0,0,0` and never the residual, while twenty BE-003 runs returned `1` every time.

| | runs | `change-focus` values | scatter |
|---|---|---|---|
| BE-003, rubric `396e1799eb2b` | 20 | all `1` | **none** |
| BE-004, rubric `6252778b8472` | 16 | `0,0,0,0,1,1,1,1,1,2,2,2,2,2,2,2` | wide |

**So the refined finding is:** both rubrics carry a `change-focus` anchor 2 whose whitelist is
narrower than a correct solution requires — that much the two hand re-reads established on the text
— but **only the BE-004 port produces an unstable score from it.** The BE-004 anchors differ from
BE-003's in having a longer permitted list covering two controllers, two packages and a repository
method, and its anchor 2 ends *"Anything beyond that list is a difference"* with a citation
requirement across four methods in two trees. That is a great deal more for a reader to hold, and
it is the one that scatters.

**What this does to the verdict is nothing — BE-004's `change-focus` row is unmeasurable either
way.** What it does to the *recommendation* is make it specific: the instrument to look at is the
**BE-004 rubric's `change-focus` anchors**, not the category in general, and BE-003's stability at
`n = 20` is the evidence that a `change-focus` anchor set *can* be stable on this scorer.

*Narrowed by Opus 5 (claude-opus-5), autonomous, 2026-09-16, from the BE-003 arm's own numbers.
The section above is left exactly as written.*
