# This batch was killed twice and made two runs it never recorded. Neither has a run id.

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-30, immediately after the batch
completed on its third launch.*

## What happened

Not a script defect. **The agent harness killed the batch, twice, and the second kill was
observed with its cause.**

| launch | started (UTC) | rows when it died | how it ended |
|---|---|---|---|
| 1 | 2026-09-30T11:53:42Z | 11 | died with the previous session, ~12:18Z. Its own log directory (`/tmp/b11batch/`) no longer exists, so its exit code is **unrecoverable** |
| 2 | 2026-09-30T14:56:10Z | 22 | the harness printed *"Background command … was stopped after reaching its background time limit"* and the same poll returned `alive=0`. ~15:26Z, i.e. **30 minutes after launch** |
| 3 | 2026-09-30T15:30:24Z | **40 — complete** | driver exit **0**, recorded in `resume2-20260930T153024Z.log.rc` |

Launch 2 went through `evidence/b09/detach.py` and **its log proves the detach happened** —
`pid=95753 pgid=95753 sid=95753`. It died anyway. detach.py's docstring is right that a
process-**group** signal cannot cross a new session; the harness does not send one. **The kill
walks the process tree, and a new session leader does not stop it.**

Launch 3 differed in exactly one way: it used the harness's own background mechanism with an
**explicit two-hour timeout** instead of the invisible thirty-minute default, and the session
stayed open polling it with foreground wait loops. That is the whole fix.

## The two orphans, and why they are harder than the one in `b09/batch-20260926T133740Z/`

The b09 orphan had a run record. **These do not.** Each was killed *mid-stream*, before the
runner posted anything.

| field | orphan A | orphan B |
|---|---|---|
| task / seq / arm | BE-003 / 06 / control | BE-004 / 02 / treated |
| killed at | ~2026-09-30T12:18Z (launch 1) | ~2026-09-30T15:26Z (launch 2) |
| its run log, in this directory | `BE-003-06-control.log`, 148 842 bytes | `BE-004-02-treated.log`, 317 890 bytes |
| `"subtype":"init"` in that log | present | present |
| `"subtype":"task_started"` | present | present |
| `"type":"result"` | **absent** | **absent** |
| `"subtype":"success"` | **absent** | **absent** |
| `run record` marker | **absent** | **absent** |
| run id | **none — never assigned** | **none — never assigned** |
| API record | **none** | **none** |
| `run-ids.tsv` row | **none** | **none** |
| manifest row | **none** | **none** |
| kept worktree copy | **none** | **none** |
| `estimatedCost` | **unrecoverable** | **unrecoverable** |

Every *completed* log in this directory carries all three of `"type":"result"`,
`"subtype":"success"` and `run record`. That contrast is the evidence that these two were
terminated rather than that they failed: compare `BE-004-01-treated.log` in this directory,
which carries one of each.

**The cost is real and is gone.** `estimatedCost` lives in a run record, and there is no record.
So **any arithmetic over this manifest understates true spend by two runs** — about $0.13 and
about $0.20 at this batch's own medians, though even that is an estimate and not a measurement.
`window.txt` reports `$2.5830` for BE-003 and `$4.1495` for BE-004 against computed ceilings of
`$2.8380` and `$4.5056`; those two numbers are **exact over the recorded population and a lower
bound over the money actually spent**. The ceilings were therefore respected as author decision
13 defines them — over recorded runs — and a stricter reading that counted the orphans would put
BE-003 at about `$2.71` and BE-004 at about `$4.35`, still under. Stated so nobody has to
reconstruct it.

## How they are treated, and the one place a reader could reasonably disagree

Both cells were **re-run by `--resume`** and appear in the manifest under different run ids, so
the scored population is 10 per arm per task with nothing topped up after the fact.

The registered rule is the driver's own, fixture-proved at §4 step 4 before any run: `--resume`
**skips every `(task, seq, arm)` already in the manifest** and re-runs every cell that is not.
A cell with no manifest row was never recorded, so re-running it is the registered behaviour of
the registered instrument — not a discretionary top-up.

**The disagreement a careful reader might raise, stated rather than hidden:** E-026's
Exclusions item 2 registers that *an `api_error` / F13 infrastructure abort with 0 edits is
excluded and **not topped up***. If one read a harness kill as that class of event, the honest
consequence would be `n = 9` on those two arms rather than a replacement. The reason item 2 does
not reach these two is that it governs runs that **entered the population** — a run with an id,
a record and an abort — and these never did: there is nothing to exclude, because nothing was
ever measured. That is a distinction of kind, not of convenience, and it is written here so the
validator can overturn it against the same facts if it disagrees.

## One consequence that is not cosmetic

Orphan A's first attempt ran on claude CLI **2.1.284**; its replacement ran on **2.1.285**,
because the CLI updated itself between launch 1 and launch 3. So the harness kill is part of how
BE-003's version split came to be **treated 6/4 against control 5/5** across the version
boundary. That imbalance, its reasoning and the decision to finish rather than restart are
registered in `TRACK-B-STATE.md` under `claude_cli_version_boundary`, **written before the resume
ran**, and the manifest carries `# claude 2.1.285 at resume` at line 23 as the partition record.
BE-004 is untouched by any of it: all 20 of its runs, both arms, are on 2.1.285.

## What would stop the next one costing a run instead of a batch

1. **A long job needs an explicit timeout.** The default leash is thirty minutes and it is
   invisible from inside the session. This is now recorded in `TRACK-B-STATE.md`'s
   `next_action` trap list and in `batch_death_mechanism`.
2. **A batch must be waited on inside the session that launched it.** Ending the turn on a
   running batch has now killed three batches across two stops (two B9 batches on 2026-09-26,
   this one on 2026-09-30). The durable fix is a supervisor the harness does not own — `launchd`
   or a `nohup` wrapper — which is a change to the run kit and therefore the author's; it is in
   `author_notes`.
3. **The sidecar could not help here, and that is worth saying.** `run-ids.tsv` was added after
   the b09 orphan precisely to capture a run id before the manifest row. It cannot capture what
   was never assigned. A kill *mid-run* is a different window from a crash *after* the run, and
   no sidecar closes it: the only thing that would is the runner posting a record at start
   rather than at finish. That is an observatory change, not a driver change, and it is not
   proposed here.

Neither ShellCheck nor `verify-b11-batch-guards.sh` (17 of 17) could have caught either death.
The guard set never enters `one()` by design, because entering it means spending a benchmark
run — the same stated gap as b09's. **Nothing in this file is a defect in
`run-b11-batch.sh`**; the driver did the one thing that mattered, which was to make both deaths
recoverable with `--resume` instead of costing the batch.
