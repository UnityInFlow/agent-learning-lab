# Stop 17 preflight and batch run artefacts

**What is here and what is not, and the split is deliberate.** Each `<run id>/` directory holds
the small, load-bearing artefacts of one run — the run record as the API served it, the `init`
tool-set read-back (author decision 8), the policy-gate log, and for treated runs the
**run-state file**, which is B8's only per-run delivery proof because `run-agent.sh:625-629`
computes no hook hash at all.

**The worktrees themselves are at `evidence.local/b08-worktrees/<run id>/`, which is gitignored
by `*.local`.** They are ~27 MB each and a full batch would be over a gigabyte. This follows the
convention the stop-16 rescue set (`evidence/p05b/rescued-worktrees/`).

**They are copied off `$TMPDIR` the day the run is made, and that is not caution.** The reaper on
this machine empties a kept worktree's files in about three days and **leaves the directory
standing**, so `ls -d` passes on a hollowed one. The author decision 11 census returned **no
reading at all** because all 54 kept BE-004 worktrees had already been emptied when it opened
them. A copy made later is a copy of nothing.
