# This batch made one run and recorded no row. The run id is here.

*Written by Opus 5 (claude-opus-5), autonomously, 2026-09-26, immediately after the crash.*

## What happened

`run-b9-batch.sh` exited **1** part-way through its first `one()` call, at the manifest `printf`,
with `line 303: rv: unbound variable`. `rv` (runtime version) and `rm` (runtime model) are two
manifest columns carried over from `evidence/b08/run-b8-batch.sh`; their two `jq` reads were not
carried with them, and `set -u` makes reading an unassigned local fatal.

**The crash is at the printf, which is after the run.** So the run happened, the money was spent, and
the row that would have named it was never written.

## The orphan, read from the API rather than reconstructed

| field | value |
|---|---|
| run id | **`6d728d76-5b1d-4b56-8e1f-154ea27ae82b`** |
| task / arm / seq | BE-003 / treated / 01 |
| experiment key | `EXP-B9-ROUTER-BE003` |
| variant | `agent-v1.2-knowledge` |
| evaluator exit code | **0** — the run solved the task |
| `customization.knowledgeHash` | `sha256:0770219ae7f4281a80071d78dadea285` — the registered corpus |
| `estimatedCost` | **$0.140948** |
| `modelCalls` | 22 |
| `changedFiles` | 3 |
| router log at `$TMPDIR/knowledge-log-observatory-run-6d728d76….jsonl` | **absent** |
| router mentions in its run log, excluding the runner's own `claude args:` echo | **0** |
| its run log | `BE-003-01-treated.log` in this directory |

So it is a **non-attempt**, like the two treated runs of the 13:17Z preflight: the corpus was
delivered and the agent did not call the router.

## How it is treated, under a rule registered before the batch

E-022's Exclusions: *"infrastructure failures of the F13/F15 class, permission blocks, quota
exhaustion → excluded, and a run excluded for infrastructure is **replaced**, so the scored `n` stays
10 per arm."* A driver that dies between a run and its own manifest row is an infrastructure failure
of the harness. **This run is excluded and replaced by the re-run batch**, and it is neither deleted
nor overwritten (§6) — its log stays in this directory and its record stays in the API.

**It is not silently dropped, and this file is why.** A run that exists in the API under a registered
experiment key with no row in any manifest is exactly the thing a later reader cannot interpret: the
money is spent, the evidence is on disk under a name nothing records, and the only honest reading
without this file would be *"a run happened and we do not know which"*.

## What was changed so the next omission of this class costs a row instead of a batch

1. `rv` and `rm` are assigned from the run record, beside the other nine reads.
2. **Both drivers now write a sidecar `run-ids.tsv` BEFORE the manifest row**, carrying task, seq,
   arm, run id and worktree path. A run id and a worktree path are the only two things that cannot be
   recovered after a crash in that window.

Neither ShellCheck nor the guard fixture set could have caught the defect: the variables are declared
locals, and the fixture set never enters `one()` — by design, because entering it means spending a
benchmark run. That gap is stated here rather than papered over.
