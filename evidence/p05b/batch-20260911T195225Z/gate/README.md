# §4 step 7, the gate — all 20 runs of the stop-16 batch

`./tools/check-run-gate.sh` was run over every run of `EXP-5B5-PERMISSION-BLOCK-BE003`,
2026-09-14, by Opus 5. Each run document was fetched with
`curl http://127.0.0.1:18081/api/runs/<id>` — the **colima tunnel**, never `localhost:8081`,
which answers about a second and empty stack — and written beside this file as `<id>.json`, so
the gate's input is on disk and a stranger can re-run the decision without the API.

`gate-results.tsv` is `runId · variant · exit code · first line of the message`.

## What the gate says

| arm | n | gate exit 0 (scorable) | gate exit 2 (evaluator failed) |
|---|---|---|---|
| `plain` (control) | 10 | **10** | 0 |
| `blocked-deny-5b5` (arm D) | 5 | **1** | 4 |
| `blocked-hook-5b5` (arm H) | 5 | **0** | 5 |
| **total** | **20** | **11** | **9** |

## What that means for step 7, and what it does not

**Decision D governs: the rubric scores only submissions that cleared every gate.** So the
rubric population for this batch is **11 runs, not 20** — the ten controls and the single arm-D
run `3bd8fcd8` that passed the evaluator outright at exit 0 with 78 tool calls. The nine refused
runs are **not excluded from the experiment**: E-017's registered outcome is the recorded
*failure class*, which is read from the run record and does not need a rubric sheet. E-017's
Exclusions section is explicit — *"No run is excluded for being blocked. That is the
measurement."*

So two different populations do two different jobs at this stop, and conflating them is the
error to avoid:

- **P1, P2, P3 and the decision rule** are answered over **all 20** runs from the run records.
- **The rubric sheets** are taken over the **11** gate-passing runs only.

An exit-2 row here is therefore evidence *for* the experiment, not a run lost from it.

*Written by Opus 5 (claude-opus-5), autonomous, 2026-09-14.*
