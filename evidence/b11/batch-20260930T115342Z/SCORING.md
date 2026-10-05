# B11 scoring — §4 step 7, what was run and what went wrong first

Batch `20260930T115342Z`, 40 runs, two tasks, two experiments (E-026 BE-003, E-027 BE-004).
Registered scorer codex (Decision C). **This file is step 7 only: the gate, the sheets and
their provenance. No median, no comparison and no verdict is stated here — those are step 8's
and step 10's, and §6 forbids a future step's artifacts.**

## 1. The gate, before any scoring

`tools/check-run-gate.sh` was run against each of the 40 run documents fetched from
`GET /api/runs/{id}`, which is the split the tool's own header requires — it decides, the
caller fetches. **40 PASS, 0 gate-fail, 0 fetch-fail.** This is an independent confirmation of
the manifest's `eval=0` on 40 of 40: the manifest records what the driver saw, this records
what the API returns now. The per-run decisions were taken in a scratchpad and are not evidence;
the API documents are, and they are reachable at the ids in `run-ids.tsv`.

The registered scorer repeats this check internally in `--run-id` mode, so every sheet below
was produced through a gate check as well as behind one.

## 2. Attempt 1 failed on all 40 rows, and the cause was known in advance

`codex-sheets-attempt1-tmpdir-reaped.tsv` (41 lines) and `score-attempt1-tmpdir-reaped.log` are
kept under §6. Every row reads `score_exit=1  sheet=none`. Zero sheets were produced and codex
was never called, so the attempt cost nothing but is recorded anyway.

Cause: `codex-score.sh` in `--run-id` mode derives the target as
`${TMPDIR}/observatory-run-<id>` — deliberately, so that the directory cannot disagree with the
record (see its Path B comment). The batch ran 2026-09-30; scoring ran 2026-10-05; `$TMPDIR`
reaps kept worktrees in about three days, so all 40 derived paths were gone and the scorer
refused 40 times with *"A run scored from a deleted worktree is not something this can
reconstruct."*

**`TRACK-B-STATE.md` had already recorded this** — `worktree_path_rule` says the originals are
gone from `$TMPDIR` and *"the copies under evidence.local/ are the only surviving trees, so
score from them."* The launch ignored a warning that was already in the state file. Recorded
because the house failure mode here is a control that passes for a reason nobody checked, and
its twin is a launch that proceeds past a note nobody re-read.

## 3. What attempt 2 changed, and why it is not a flag

The 40 kept copies under `evidence.local/b11-worktrees/<run_id>/` were each copied back to
`${TMPDIR}/observatory-run-<run_id>`, the path the runner itself used and the scorer derives.
Checked per row rather than assumed: **40 restored, 0 missing**, each with `.git` as a real
directory (they are self-contained repositories, not linked worktrees — `git -C <copy> status`
and `git log` both work and show the agent's own diff over `d2ff5ab`).

This keeps the scorer's invariant intact. The alternative — passing the copy as a directory
argument — is Path A, which does **not** check the gate, and the scorer's header is explicit
that `--dir X --run-id Y` is refused because *"a flag is a promise by the caller, which is
Layer 3 wearing Layer 2's clothes."* Restoring the derived path keeps the directory derived
from the id; supplying it would have made the mismatch representable again. **No flag was
added and no scorer line was edited.**

## 4. One run has two sheets, by name

`5cc74707-f2e8-44a4-9ccf-df241effaac3` was scored once by hand at `20261005T114423Z` to prove
the restored path produced a complete sheet before 40 runs were committed to it, and again by
the driver at `20261005T114655Z`. **Both are kept (§6)**; `codex-sheets.tsv` references the
driver's. The trial sheet is the one artefact here that no manifest row points at, and it is
named so a reader does not have to work that out.

## 5. The sheets, verified rather than trusted

Driver `evidence/b11/score-b11-batch.sh` (commit 98bf37f), `rc = 0`, 40 rows in
`codex-sheets.tsv`, `score_exit = 0` on all 40. Verified per row afterwards, by name and not by
position:

- **40 distinct sheets** for 40 run ids.
- **`rubric_sha` matches the registered value for that task on 40 of 40** — `396e1799eb2b`
  (E-026, BE-003) on the 20 BE-003 sheets, `6252778b8472` (E-027, BE-004) on the 20 BE-004
  sheets. Two experiments, two rubrics, one batch.
- **`run_id` inside each sheet equals the manifest's run id on 40 of 40** — so no sheet is
  attributed to the wrong run.
- **Exactly four `score:` lines per sheet, 0 null**, and the four category names are identical
  across all 40 sheets in one order, so a positional read and a read by name agree here. Later
  work should still key on the name.
- Scorer provenance per sheet: `scorer: lab-scorer`, `model: gpt-5.6-sol`,
  `isolation: --ignore-user-config --ignore-rules --sandbox read-only`, `wall_budget_s: 2700`.

## 6. A defect in the driver, inherited and not fixed here

The header claims stall rows are *"marked by the `stall`/`timeout` rc in the progress file with
sheet `none`, so a later invocation retries them rather than reading them as zeros."* The code
does not do that: the resume test is `grep -q "\t$rid\t" "$OUT"`, which matches **any** row for
that run id, including one written with `sheet=none`. A resumed invocation therefore **skips**
stalled runs instead of retrying them.

This is why attempt 2 could not simply re-run the driver: all 40 rows were already present as
`none`, and a resume would have skipped the entire population and reported 40 rows of nothing.
The attempt-1 file was renamed rather than deleted and the driver wrote a fresh `codex-sheets.tsv`.

The defect is b09's and b10's too — identical code, same lineage — so **b10's and b09's own
stall rows, if any, were also skipped rather than retried on any resumed invocation they had.**
Not fixed here: the driver is this stop's instrument and changing it mid-step changes a
registered variable (§6). It belongs in its own instrument PR, and the claim in b10's and b09's
headers should be corrected at the same time rather than left reading as a guarantee.
