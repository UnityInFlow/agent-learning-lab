# The census classification rule, and both readings — written and committed BEFORE the first worktree is opened

Author decision 11 item 1, at the boundary after stop 16 closed and before stop 17 opens. Written
2026-09-15 by Opus 5, autonomous. **No worktree has been opened, no diff has been read, and no
rubric sheet has been consulted at the time this file is committed.** That ordering is the only
thing that makes the result worth anything, and the commit timestamp of this file against the
timestamp of `RESULT.md` is how a stranger checks it.

The census is **read-only over runs already on disk**. No new run, no money. It moves no registered
variable and it is **not a §7 halt**.

---

## 1. What the census is for, stated narrowly

Decision 11, as amended, no longer lets the census decide whether BE-005 is built — the author
decided that. It decides **two smaller things**:

1. which specialist roles B8a's overlay gets, and
2. whether BE-005's trap has to be **invented** or can be **scaled up** from a failure the model
   already makes on BE-004.

It answers those by asking one question of each kept BE-004 run: **does this diff show a shape
chosen early that a later clause of the same ticket punished?**

## 2. The population

Every **kept BE-004 batch worktree** from the three stops that ran BE-004 batches:

| stop | experiment | arms | expected worktrees |
|---|---|---|---|
| 12 (B5) | E-011 | treated + control | 10 + 10 |
| 13 (B6) | E-013 | treated + control | 10 + 10 |
| 15 (B7) | E-016 | treated + control | 7 + 7 |

Each path is **confirmed by `stat` on the path the run's own manifest or record names**, never
inferred from the `--keep` flag having been passed.

**Excluded by name, per decision 11:** every preflight worktree and every deliberate-failure
worktree. They are not batch runs and they join no `n`.

**A worktree that is present but hollow is `UNREADABLE`, never `none`.** `$TMPDIR` is reaped by
macOS: it deletes *files* untouched for about three days and leaves the *directory*, so `ls -d`
passes on a worktree whose contents are gone. Every one of these batches is older than that
window. A run whose diff cannot be read is reported as `UNREADABLE` with the reason, and
**`UNREADABLE` runs are excluded from both the numerator and the denominator of the reading in
§5**, with the surviving denominator stated.

## 3. What "design" means on BE-004, derived from the ticket alone

BE-004's ticket states a requirement in clause order. Three of its clauses are **later clauses
that punish an early shape** — the §4.1 pattern — and they are the only places on this task where
planning is separable from typing:

| fork | the early choice | the later clause that punishes it | ticket text |
|---|---|---|---|
| **F1 — idempotence** | how the cancel path guards on current status | **clause 3** | *"Cancelling an order that is already `CANCELLED` succeeds and changes nothing. Customers retry this call, and a retry must not fail."* |
| **F2 — atomicity** | whether the order/shipment writes happen before or after the rejection decision | **clause 4** | *"If any shipment of the order is `CONFIRMED`, the cancel is rejected with HTTP 409 **and nothing changes** … A rejected cancel is all-or-nothing."* |
| **F3 — cross-feature status** | where order status lives and how another feature reads it | **clause 6** | *"Once an order is `CANCELLED`, creating a shipment for it (`POST /shipments`) is rejected with HTTP 409."* |

**This is not a taste judgement and must not become one.** Each fork below has a *good shape*, a
*punished shape*, and a **decidable test over the diff**. A run is a design failure on a fork only
when the punished shape is present **and** the later clause's cost is visible in the same diff.

## 4. The rule, per run

Classify each run into exactly one of three classes.

### `design` — an early shape a later clause punished

At least one fork below fires. Record **which fork(s)**, and the `path:line` that decides it.

- **F1 fires when** the cancel path contains **a guard that rejects a non-`ACTIVE` order** *and,
  separately*, **a special case that re-admits `CANCELLED`** — two branches where one early return
  would do. The punished shape is "reject anything not ACTIVE", chosen from clause 2, then patched
  for clause 3.
  *Does not fire* on a single early return for `CANCELLED` placed before the work, or on a `when`
  over the status enum written as one expression.

- **F2 fires when** a write to the order's status, or to any shipment, appears **textually before**
  the last read that decides the 409 — that is, the code mutates and then discovers it should not
  have — **and** the all-or-nothing property is restored by rollback or by an explicit undo rather
  than by the ordering.
  *Does not fire* on a check-all-then-mutate ordering. **It also does not fire on a
  `@Transactional` method whose reads all precede its writes**: a transaction is a legitimate
  design here and the ticket does not forbid it. The failure is *mutate-then-discover*, not the
  annotation.

- **F3 fires when** the shipment-creation path learns the order's status by a means **introduced by
  this diff that duplicates or bypasses the order feature's own accessor** — a second status
  constant, a direct repository read placed in a controller, or a copy of the status enum — rather
  than by calling the order feature's service/port.
  *Does not fire* when the shipment path calls an existing or newly added order-side accessor, nor
  when the two features already share the `api` package the ticket names.

### `execution` — the shape is right and something is typed wrong

No fork fires, **and** the diff carries a defect that a re-type fixes without changing the shape:
a wrong constant, a wrong HTTP status on an otherwise correct branch, a dead or unreachable
branch, a test asserting the wrong field, an unused import left behind.

**Note the asymmetry, stated in advance because it will shape the result:** BE-004 has **never
failed its evaluator on the pinned model** — 9 of 9 before stop 12, 10 of 10 in both arms at B5 and
B6, 7 of 7 in both arms at B7. So an `execution` classification here can **never** be an exit code.
It is a rubric- or diff-visible defect only, and that makes this class systematically weaker
evidence than `design`. It is reported, not leaned on.

### `none`

Neither. The shape is one of the good shapes on all three forks and no typed defect is visible.

### The tie-breaks, fixed now

- **A run can fire more than one fork; it is still one `design` run.** Fork counts are reported
  separately and never summed into the run count.
- **`design` outranks `execution`.** A run with both is `design`, because the question is whether
  a seam exists, not how many defects a run has.
- **The rubric sheet is a second input, never the deciding one.** A sheet may corroborate a fork
  (a low `maintainability` or `change-focus` cell on a run already classed `design`); **no run is
  classed `design` on a sheet alone.** The diff decides; the sheet is recorded beside it.
- **When the diff is ambiguous on a fork, the fork does not fire.** The rule is one-sided on
  purpose: a census that resolves doubt toward the interesting answer measures the censor.

## 5. Both readings, registered now

The line is **5 of 10 control runs**, or the same fraction of the pooled controls, taken from
E-007's own MDE row: Fisher 10/10 vs 5/10 gives `p = 0.033` and 10/10 vs 7/10 gives `p = 0.21`, so
five is the fewest design failures a treatment could be *seen* to remove at `n = 10`.

**The denominator is the plain-control runs only**, across all three stops pooled, excluding
`UNREADABLE`. Treated runs are classified and reported but do **not** set the line: each stop's
treated arm carries a different treatment, and pooling them would be pooling three experiments.

- **Reading A — no seam.** Design failures in the pooled plain-control runs are **below** that
  fraction. Nothing on disk tells the designers where the model plans badly; **BE-005's trap is
  designed from the §4.1 shape alone**, and Gate B is the only ceiling evidence. B8a's specialist
  roles are then chosen from the trap rather than from the census.
- **Reading B — a seam exists.** Design failures are **at or above** that fraction. The seam
  names the specialist roles B8a's overlay gets and names the failure BE-005 scales up, and the
  census becomes a first ceiling estimate that Gate B confirms on the new ticket.
- **Neither.** A result that fits neither — for example too few readable control runs to place the
  line at all — **is reported as such** and decides nothing. It is not rounded to whichever reading
  is nearer.

## 6. What this census may not do

- It may not open, sketch or draft **BE-005**. That is the author's work with Claude Fable 5.1
  (decision 11, and the author's standing instruction on this run).
- It may not start a run of any kind.
- It may not edit any experiment, workbook, prediction, sheet or run folder. It adds files.
- It may not reopen stop 16 or pre-empt stop 17. §6 forbids a future step's artifacts early.

`Written by Opus 5 (claude-opus-5), autonomous, 2026-09-15, before any worktree was opened.`
