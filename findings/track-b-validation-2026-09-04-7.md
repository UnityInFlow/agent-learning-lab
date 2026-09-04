# Track B validation, seventh pass — 2026-09-04

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-04T18:40Z.` Read-only; nothing outside this file was edited. This pass ran in the
session that authored the prompt; the sixth pass, written minutes earlier by a fresh
`claude-opus-5` session, did not, and this file spends most of its length checking that pass
against the raw data rather than repeating earlier work.

Inputs: `TRACK-B-STATE.md` at `03496ca` on `stop9/validator-pass-3-corrections` (unchanged since
the fifth pass; `origin/main` still `288ceee`), `findings/track-b-validation-2026-09-04-6.md`
(untracked, by another session), `events.jsonl`, the kept worktrees, the codex sheets.

## Verdicts

| Stop | Verdict | Notes |
|---|---|---|
| 4–7 | **CONFIRMED** (unchanged) | |
| 8 — Phase 3 | **CONFIRMED WITH CORRECTIONS** — the sixth pass's four, three of them re-derived here and one accepted | the headline stands; one column of the results table and one §5 proof row are wrong on 2 of 5 runs |
| 9 | **not closed, not claimed closed** | still at the report boundary; nothing changed since the fifth pass |

## The sixth pass, checked

| Its correction | This validator's check | Holds? |
|---|---|---|
| **8.1** — the results table and the §5 "treatment reached the model" row say `invocation_trigger = claude-proactive` on all five matched runs; the telemetry says `nested-skill` on two | Dumped every `skill_activated` record for the five matched ids from `events.jsonl` with my own `jq`: `d6aec246`, `45a70775`, `2cf0c720` → `claude-proactive`; **`33a4090d`, `8998ef3b` → `nested-skill`**; all five `skill.source = projectSettings`, `skill.name = custom_skill` | **yes** |
| **8.2** — a stop 8 control cell (`ff7bffed`, maintainability 1) and a stop 6 treatment cell (`369b9d03`, maintainability 0) were scored differently on byte-identical `confirm()` bodies | `diff` of the two `confirm()` bodies from the kept worktrees: **identical**. Sheets: `369b9d03` 0, `ff7bffed` 1, same rubric sha, same scorer. The hand-census rule for this shape (two `if` guards, early returns, no `else`) is anchor 0 | **yes** — and its size is stated correctly: neither value is anchor 2, so no headline in stop 6 or stop 8 moves; it is a fifth ladder gap for a rubric round |
| **8.3** — the arm-C delivery proof ("4 of 6 probed") has no artifact on disk | `evidence/p03/` holds exactly two files, the delivery probe and the flag probe; the third pass listed the same two. No arm-C probe file exists | **yes** |
| **8.4** — "at both paths" is an `n = 3` per-cell claim quoted without its `n` in the report and the workspace CLAUDE.md, and decision 1 asked for `n = 5` | Not re-derived; the workbook itself states `n = 3` per cell and the deviation is disclosed where it happened | accepted |

**What this does to the result, stated once.** The registered outcome is *an activation from
the installed scope*. It is 5/5, 0/5, 0/5 and untouched: two runs activating through a
`nested-skill` trigger are still activations of the installed skill, on the matched arm, and
zero on the misdescribed arm that had the same nested file in the same place. The sentence that
is wrong is narrower: **"the description did the selecting" is directly evidenced by a
`claude-proactive` trigger on three runs, not five**, and nothing in the stop says what
`nested-skill` consults. The sixth pass's illustrative sensitivity (3/5 vs 0/5, `p = 0.167`) is a
sensitivity, not a re-registration, and it is right to label it so.

**A miss of my own, on record.** The third pass recounted activations per run by `skill.source`
and ran the project's tool on one matched run, `d6aec246`, which happens to be one of the three
`claude-proactive` runs. It never grouped by trigger and never ran the tool on the other four.
The builder's table copied one value down a column, and this validator checked the one row that
agreed with it. A fresh session with no prior reading of the workbook caught it; the point of
§9's "different model" line is exactly that, and the sixth pass is the first pass to have that
property in full.

**One correction to the sixth pass.** It says §9's different-model instruction "has not been
honoured once". Passes one through five and this one ran on `claude-fable-5-1`, which is not the
builder's `claude-opus-5`; the sixth pass itself ran on `claude-opus-5`. What none of the first
five had was a fresh context — they shared the session that wrote the prompt — and that, not the
model id, is the independence that mattered here.

## Where things are, for the builder

- The sixth pass's file is **untracked** and the state file does not list it in
  `validation_processed`; the seventh is now beside it. Both need processing before stop 9
  continues, per §0. Corrections 8.1 and 8.3 are edits to a closed stop's workbook and experiment
  (an amendment, not a rewrite of the table); 8.2 is a rubric-round item, not an edit; 8.4 is two
  sentences.
- The process risk stands and has grown: every stop 8 correction from four passes is on the
  unmerged stop 9 branch. If stop 9 halts before its PR, ship the stop 8 amendments alone.

## The single finding most likely to overturn the track's result

The sixth pass's, adopted: **what `nested-skill` is emitted for, and whether it consults the
description.** It is cheaper than the fourth arm — the twelve flag-probe transcripts and the two
runs' telemetry are already on disk — and it bears on the registered outcome rather than on a
co-variate. If `nested-skill` fires without reading the description, the strongest true sentence
becomes *a matched description produces an activation and a mismatched one does not*, which is
still `p = 0.0079` and still the stop's result; the mechanism sentence in the title would then be
wider than its evidence. Settle it before B6 at stop 13, alongside decision 7's fourth arm, since
both are about what "with a skill" means on this instrument.
