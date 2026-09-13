# The batch stopped at run 10 of 20 because the API container was OOM-killed

*Written 2026-09-13T10:05Z by Opus 5 (claude-opus-5), autonomous. Nothing was lost and
nothing is re-run. This file exists so a reader of `manifest.tsv` does not have to infer
what ten `exit 1` rows mean.*

## What the manifest shows

| idx | arm | outcome |
|---|---|---|
| 1–10 | 5 control, 3 D, 2 H | **recorded** — run ids in `manifest.tsv`, all ten present in the API |
| 11 | control | **ran to completion, evaluator exit 12, NEVER REGISTERED** |
| 12–20 | 5 control, 2 D, 3 H | **never started** — refused before the model was called |

## The cause, read rather than guessed

`docker --context colima ps -a` — **with** `--context`, which is the distinction the
2026-09-06 false alarm turned on:

```
agent-observatory-observatory-api-1   Exited (137) 2 hours ago
```

**Exit 137 is SIGKILL — the container was OOM-killed**, in a colima VM with 3.826 GiB total.
The batch's own load is the likely cause: the 15-minute load average was still **93.23** when
this session resumed, and arm D runs are the expensive ones (run 10 took 45 minutes, run 11
about 70).

**The stack did not go away and no data was lost, checked before it was claimed:**
`docker --context colima volume inspect agent-observatory_postgres-data` reports
`created=2026-08-08T14:20:14Z` — the original volume, not a fresh one. After
`docker start` on that one container the store holds **562 runs**: 550 before this session,
plus the 2 preflight runs, plus the 10 recorded batch runs. Exact. Nothing was re-pulled,
re-created or `make up`-ed.

## Why runs 12–20 cost nothing, and that is the runner working

Their logs are **163 bytes** each:

```
run-agent: Observatory API not reachable at http://127.0.0.1:18081; run 'make up' first
```

The runner checks the API **before** it calls the model. Nine runs' worth of money was not
spent on a batch that could not have been recorded. That check is an L2 control and it is the
reason this incident is a delay rather than a loss.

**Run 11 is the exception and is the one real casualty.** Its log is 7 922 bytes: the agent
ran, the evaluator ran and returned exit 12, and *then* `curl: (56) Recv failure: Connection
reset by peer` — the API died between the run starting and the record being posted. Its
worktree is kept at `observatory-run-47a1279c-4002-4613-bdba-857e2e54dd50`.

> **Run 11 is EXCLUDED BY NAME and its folder is kept, not deleted.** It has no run record,
> therefore no telemetry, therefore no `behavior.permissionDenials` — and E-017's **P4** is
> about what a control run's *block trace* shows. A run whose block state cannot be assessed
> must not be counted as a run with no block; that is precisely the direction
> `classify-permission-block.sh` exits 3 for. Counting it would be the house failure mode in
> the arm where it is least visible.
>
> *Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-13.*

## What is owed, and what is NOT re-run

Registered: 10 control + 5 arm D + 5 arm H. Recorded: **5 control, 3 D, 2 H**.
**Owed: 5 control, 2 D, 3 H — ten runs.**

**None of idx 1–11 is re-run.** §0: *never re-run a benchmark run you cannot prove failed to
start*, and a duplicate is evidence that cannot be deleted. The resumed runs take indices
**21–30** in their own manifest (`manifest-resume.tsv`) so no index is ever reused.

## The machine was measured before the money was spent again

Not declared quiet — measured, with the probe B7 registered for exactly this:
a full `./mvnw -q -o test` in a kept worktree of this batch took **10.25 s** wall
(`user 10.95, sys 0.92`), against B7's healthy reading of 10.2 s. Load 1-minute **12.09**
against a 15-minute **93.23**, i.e. recovering, not loaded. Memory 64 % free. The seven
observatory containers total under 1 GiB of the VM's 3.8 GiB.

## Carried to `author_notes`, not fixed here

The colima VM has **3.826 GiB** and this batch OOM-killed a container in it. Nothing in the
runner or the batch script watches for that, and the failure mode is silent until a `curl`
fails mid-run. An L2 control — a memory headroom check in `otlp-preflight.sh`'s neighbourhood,
or a VM memory floor asserted at batch start — would convert it. §6 forbids building it at
this stop.
