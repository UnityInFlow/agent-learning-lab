# batch-20260927T085830Z — a failed launch, kept

**Nothing ran. No money was spent. No run id exists, in the API or anywhere else.** This
directory is kept because §6 forbids deleting evidence, and because what it records is a defect
in the driver rather than a fact about the experiment.

**What happened.** `run-b9-deliberate-failure.sh` assigned `API=http://127.0.0.1:8081` without
`export`. `run-agent.sh:31` reads `API` from its own environment and defaults to
`http://localhost:8080`, so the driver's own `curl` probe answered `200` against 8081 while every
run of the batch went to 8080 and died at once:

```
run-agent: Observatory API not reachable at http://localhost:8080; run 'make up' first
```

**The second defect is the one worth carrying.** The driver wrote **five rows** of
`none / rc=1 / eval=null / cost=null` in **two seconds** and finished with
`done: 5 runs, spent $0 of $1.0047`. A reader — or a later script — counting rows would have found
`n = 5` and a complete batch. That is the house failure mode: *a control reporting success over a
scope smaller than it claims*, in a driver written to measure exactly that failure mode in
something else.

**Both are fixed at the source, not worked around.** `export` on all five endpoint variables
(matching `run-b9-batch.sh:80-84`), and a new **exit 14**: a run that produces no run id keeps its
row and **stops the batch**. Fixture cases O and P of `evidence/b09/verify-b9-df-guards.sh` drive
it, through the `B9DF_RUNNER` stub — because the first version of case O stubbed the *API* and
thereby invoked the real runner, which can start a paid run. That version was killed after 110
seconds; `find` over `$TMPDIR` shows no worktree and no knowledge log, and the API's newest run id
was still `0f163eb9` from 2026-09-26T19:53:44Z, so nothing was spent there either.

*Recorded by Opus 5 (claude-opus-5), autonomously, 2026-09-27. The real batch is
`batch-20260927T090320Z`.*
