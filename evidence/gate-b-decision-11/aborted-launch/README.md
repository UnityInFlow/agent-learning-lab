# Aborted launch, 2026-09-17 08:23:53Z — before any run record existed

The first launch of `run-gate-b.sh` was started under the Claude Code harness's background
command, which is killed at 10 minutes. A five-run batch cannot finish inside that, and a kill
mid-batch would have left runs under the probe key that the driver correctly refuses to add to.
The operator (Fable) stopped it about a minute into run 01 — run id `ac7ed540-e55e-4fee-a232-451c99e1bc0e`,
worktree created, agent started, **no run record persisted** (the API held 0 runs under the key
at the kill, checked) — and relaunched detached with `nohup`, as `run-b8-batch.sh` and the
Track B driver are launched. The killed run's log is kept here and it joins no count. Same
class of mistake the state file records for the Makefile's OTLP defaults: an environment fact
the launcher had to know and the script could not check.
