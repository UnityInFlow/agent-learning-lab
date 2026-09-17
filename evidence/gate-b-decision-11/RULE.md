# Gate B — the classification rule, the threshold and the batch parameters, committed BEFORE the first run

Author decision 11 **step 4** (design step 4, builder item 4), run in the design session decision 11
names, with the author present. Written 2026-09-17 by Claude Fable 5.1 (claude-fable-5-1). Opus 5
contributed nothing. **At the time this file is committed, no BE-005 benchmark run exists under
the probe key below, and no diff has been read.** The commit timestamp of this file against the
manifest's first row is how a stranger checks that ordering.

Gate B is the only ceiling evidence BE-005 will have: the census (`../census-decision-11/RESULT.md`)
returned a zero denominator, so the trap was designed from the §4.1 shape alone, and these five
runs are the first time the model meets it. **Nothing here is a B8a result.** It decides one
thing: whether the ticket, as merged, makes the wrong shape tempting enough for a plain run to
reach for it often enough that a decomposition step could measurably stop it.

---

## 1. The rule, verbatim from the design page (`BE-005-DESIGN.html`, "Gate B — written before the five runs, decidable from the diff")

> **Wrong shape:** an order-side field or store (on `Order`, in `OrderRepository`, or any new
> order-package type) that holds a fulfilment status or an allocated or delivered count and is
> **written from a shipment-package mutation path**. **Right shape:** fulfilment computed from the
> shipment repository at read time, in one place. A submission that stores *and also* derives is
> classed by **what the read path returns**.
>
> **Threshold:** the wrong shape on **3 or more of 5** plain-baseline runs on the finished ticket,
> pinned model, probe key. Fewer → back to step 2, never to a bigger *n*. Failing twice ends the
> step with the negative recorded (decision 11 item 11).
>
> Because the shape is a property of the diff, **a run that passes with the wrong shape still
> counts** toward the ceiling.

The classification is made **from the diff, never from the evaluator's exit code**. Exit code and
shape are recorded side by side so the two can be seen to be independent. A run that made no
production edit at all (`edits = 0`, `changedFiles` empty) is `NO-ATTEMPT`, counts in the
denominator and not in the numerator, and is reported as such.

Each run's classification is written to `runs/<run id>/CLASSIFICATION.md` with the file and line
in `diff.patch` that decides it, by Fable, and **confirmed or overruled by the author before the
gate is called**. The author's word is recorded on the same file.

## 2. The registered fallback if the gate fails

`BE-005-CANDIDATES.md` (author's choice, 2026-09-16): candidate **B — order amendment with
optimistic locking and version history** is the registered redesign, a different failure class.
Not a bigger *n*, not a reworded ticket A.

## 3. The batch parameters, fixed here and asserted by the driver

| parameter | value | why |
|---|---|---|
| runs | **5**, sequential, hardcoded in `run-gate-b.sh` with no override | decision 11 item 4: five; "never a bigger *n*" |
| task | `BE-005` from `agent-observatory-benchmarks` **`main` at `a662c966f7fc2c2653cce29deb40e6b84f511b66`** (PR #30 merge commit, two parents `eea144ef` + `cdb1830`), clean tree | "on the finished ticket": the merged one, not the branch |
| runtime / model | `--runtime claude`, `--model claude-haiku-4-5-20251001` | the pinned population model of every Track B stop |
| variant | `baseline`, **no `--customization`**, no `--agent` | plain |
| isolation | `--isolate-user-settings` | the operator's user-scope hooks and skills are not part of "plain"; the same flag every BE-004 control arm carried |
| skills | runner default (`--disable-slash-commands` on) | unchanged from every recorded baseline |
| probe key | `EXP-B8A-GATEB-BE005-PROBE` | a probe key, as item 4 says; joins no experiment's *n* |
| endpoints | API `http://127.0.0.1:18081`, OTLP `http://localhost:14318` / `14317` | the colima tunnel; `8081` and `4318` answer 000 on this machine |
| evidence | `runs/<run id>/{run-record.json, diff.patch, diff.stat, CLASSIFICATION.md}`, worktree copied to `evidence.local/gate-b-worktrees/<run id>/` **the moment the run ends** | `$TMPDIR` reaper: the census read nothing because every kept worktree had been hollowed |
| driver | `run-gate-b.sh` in this directory | manifest-as-progress-record, pid lock, claude-version drift abort, one API read per run |

Operator choices the author may veto before the batch starts, none of which changes what a run
measures: the probe key's spelling, the `--isolate-user-settings` flag, and this evidence path.

## 4. What was expected, and where that expectation comes from

Not a new prediction. `BE-005-CANDIDATES.md` registered candidate A's Gate B risk as **Medium**
with two mechanisms pulling against each other, quoted so the provenance is on record:

- *toward the wrong shape:* clause 1 ("an order gains a quantity … `GET /orders/{id}` reports
  `fulfilment`") reads like BE-004's "an order gains a status", which produced a stored enum on
  54 of 54 runs; the list filter is a one-liner on a stored field; the service has no derived
  value anywhere for the model to copy.
- *toward the right shape:* on BE-004 this model injected repositories across packages without
  trouble, and the census's one surviving co-variate says it shows almost no design variance on
  this service at file granularity — which "cuts both ways and is not evidence about this fork".

## 5. What this file does not do

It does not open B8a, name a workbook, or write anything under `phases/`. It moves no registered
variable. It is not a §7 halt. The result goes in `RESULT.md` beside this file, after the five
runs and after the author has confirmed every classification.
