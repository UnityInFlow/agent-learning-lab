# Pointer: stop 16's ten surviving worktrees were copied off `$TMPDIR` on 2026-09-15

The worktrees themselves are **not in this repository**. They are at
`agent-learning-lab/evidence.local/p05b-worktrees-rescued-20260915/`, which matches `*.local`
in `.gitignore` and is therefore on one disk and unversioned. 263 MB, ten directories, mostly
Maven `target/` output.

**This file exists so the rescue is discoverable from a clone**, because the directory holding it
is not.

Copied at the author's explicit instruction after the author-decision-11 census found that
`$TMPDIR` had emptied all 54 kept BE-004 worktrees at 2026-09-15T03:54:59Z
(`evidence/census-decision-11/RESULT.md`). Stop 16's ten 2026-09-13 runs were the only batch
worktrees in the store still holding files; its ten 2026-09-11 runs were already partly eaten and
were not copied.

**Verified after copying rather than assumed:** file counts match the source exactly, `git` still
works in every copy, and each one still reproduces the `git status --porcelain` count stop 16's
§5 table recorded from it — arm D `3bd8fcd8`=3 and `8038176a`=4, arm H `020444f2`/`cd53a065`/
`b3b76c2f`=0, the five controls 3 each. Those counts are what refuted P3 at 5 of 10, and they were
read from the worktrees in the first place **because `behavior.changedFiles` is null on all twenty
records**.

**The underlying decision is still the author's and is still open:** where kept worktrees live.
Nothing here changes `run-agent.sh`.
