# Track B validation, fourth pass — 2026-09-04

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-04T15:40Z, fourth run of the day.` Read-only; nothing outside this file was edited.
Same independence caveat as the three earlier passes.

Inputs: `TRACK-B-STATE.md` on branch `stop9/validator-pass-3-corrections` (pushed, no PR yet;
`origin/main` is still `288ceee`), `findings/track-b-2026-09-04.md`, the three earlier
validation files, the observatory API, git.

## Verdicts

| Stop | Verdict | Notes |
|---|---|---|
| 4–8 | **CONFIRMED** (unchanged) | no stop has closed since the third pass; the third pass's corrections are applied on the branch, honestly |
| 9 | **not closed, not claimed closed** | Phase 4A is at its first phase boundary (extract done, lab not run); zero runs since 11:32Z. Not validated: §9 covers closed stops only |

## What this pass checked

**Nothing new is closed.** The API holds no run after the stop 8 batch, the state file says
stop 9 at `loop_step: 2`, and `phases/04a-agents-permissions/README.md` reads "In progress".
The prompt sha in the state file (`6b8be13c3daa`) matches the file on disk, so the builder
re-read the prompt after the per-phase and model-per-role changes and is now stopping at phase
boundaries, which is why this pass finds an open stop rather than a 70 % session.

**The third pass's five corrections are applied as amendments, not rewrites.** On the branch
(`9e42194`, `2c3c4c8`, `520365a`, `5b2bd48`, `de097e1`), `git diff origin/main..HEAD` under
`experiments/` and `phases/03-skills/` removes exactly two lines — the two rows relabelled from
L2 to L3 — and adds three dated amendment blocks quoting the validator file:

- (a) the undisclosed `2.1.259 → 2.1.260` harness move is now disclosed in E-004, named as the
  third harness move in the track, with its consequence stated (constrains cross-stop
  comparisons without a concurrent control; does not touch the within-batch `p = 0.0079`);
- (b) "`--enable-skills` on all three arms" is now labelled **asserted, L3**, with the reason a
  reader needs — the runner's refusal is unreachable on an arm that installs nothing, and the
  run record lacks the surface fields — and a cheap L2 named for the next skill arm;
- (c) the two L2 rows are L3 in the table;
- (d) the withdrawal of the second pass's "block CONFIRMED" is carried into the workbook with
  the reason, the dropped flag, stated;
- (e) the report's stop 4 row now reads `n = 9` claude runs, of which 5 were scored, and says
  what it read before.

All three validation files are listed in `validation_processed`. No prediction, result, sheet
or run folder changed: `git diff origin/main..HEAD -- experiments/` is additions only apart
from nothing.

**One thing to know about where this lives.** The amendments exist only on the pushed branch
`stop9/validator-pass-3-corrections`. Until that branch merges, `main` still carries the two L2
labels and the undisclosed harness move. The builder is on that branch at a phase boundary and
will carry it into stop 9's PR; a reader of `main` today sees the pre-correction text.

## One observation for stop 9, recorded and not judged

Stop 9 opened with the probe stop 8 should have run first: the same flag matrix, this time for
a project **subagent** rather than a skill. `evidence/p04a/subagent-registry-probe-20260904T151724Z.md`
reports the marker present in 2 of 3 runs with `--disable-slash-commands` and 2 of 3 without,
and adds the negative control the table lacked (an unknown `--agent` name exits 1 and lists the
available agents, including the probe). Read as a structural fact — subagents are not switched
off by the flag that switches off skills — it is the right first question for Phase 4A and it
was asked before any experiment file was written. It is `n = 3` per cell and the workbook says
so. Nothing here is validated; it is not closed.

## The single finding most likely to overturn the track's result

Unchanged from the third pass: the stop 8 co-variate. On `maintainability` the misdescribed arm,
which never activated the skill, scores like the matched arm (4 of 5 vs 5 of 5) and unlike the
control (1 of 5). Until a fourth arm separates "selected" from "read", every behavioural claim
about a skill on this instrument is confounded, and B6 at stop 13 is built on exactly such a
claim. It is `blocked_on_author` item A and it does not block stop 9.
