# Track B validation, third pass — 2026-09-04

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-04, third run of the day.` Read-only; nothing outside this file was edited. Same
independence caveat as before: this validator ran in the session that authored the prompt, and
it also wrote the two earlier passes, one of which this pass has to correct.

Inputs: `TRACK-B-STATE.md` at `288ceee` (`status: running`, stop 9 not started),
`findings/track-b-2026-09-04.md`, `phases/03-skills/README.md`, `experiments/E-004-skill-activation.md`,
PRs lab#58, lab#59, obs#72.

## Verdicts

| Stop | Verdict | Notes |
|---|---|---|
| 4–7 | **CONFIRMED** (unchanged from the second pass) | no new claims; the report's stop 4 row says `n = 5` claude where the baseline is `n = 9` with 5 scored — wording only |
| 8 — Phase 3 | **CONFIRMED WITH CORRECTIONS** | result reproduced from the telemetry file and the kept worktrees; four corrections, one of them to this validator's own second pass |

## Stop 8 — what was reproduced, and how

| §9 check | Result |
|---|---|
| 1 evidence exists | `EXP-P3-SKILL-DESC`: 15 runs in `GET /api/runs`, interleaved A/B/C, 11:03:44Z–11:32:47Z, `evaluation.exitCode 0` on all 15. The excluded run `62deb6c5` is present with `exitCode 12` at 10:50:29Z. 15 codex sheets on disk, every one at `rubric_sha 396e1799eb2b`. `evidence/p03/skill-delivery-probe-…` and `skill-flag-probe-…` open. Overlays `build/customizations/skill-v0.2{,-misdescribed}` exist |
| 2 prediction before run | Corrected design `f8ff084` **10:34:48Z**, pinned source `7cf5adb` 10:40:29Z, contamination rule `35abde7` 10:46:37Z. First batch run 11:03:44Z; the excluded run 10:50:29Z is also after all three. **All three commits are reachable from `origin/main`** (`git merge-base --is-ancestor`), the first stop in the track where that is true — author decision 4 worked. The Predictions section is **byte-identical** between `f8ff084` and `main`. The F13 exclusion text is present at `f8ff084`, so the exclusion of `62deb6c5` was registered before the data |
| 3 cells re-derived **by this validator** | From the kept worktrees (17 `.kt` each): `45a70775` matched → `val updated = when (…)`, no `else`, consumed by `save` → **2** (sheet 2, builder's hand 2). `d671d1b7` control → `if` chain with `else` → **0** (sheet 0). `95f42409` misdescribed → `return when (…)`, no `else` → **2** (sheet 2). Builder's hand re-read commit `40f38e2` 11:39:51Z precedes the first sheet `…T113956Z` by five seconds; ordering holds |
| 4 treatment reached one arm only | **Independent recount over `events.jsonl`** (resource-level `observatory.run.id`, record body `claude_code.skill_activated`, attribute `skill.source`): matched **1, 1, 1, 1, 1**, all `projectSettings`; misdescribed **0 × 5**; control **0 × 5**; excluded run 0. `hook_execution_start` **0 on all 16**. `customization.*Hash` `null` on all 15, as prediction 4 says |
| 5 n<5 property | None. Every count carries `n = 5` and "true of these runs"; the flag matrix is stated as `n = 3` per cell pooled; the −7.6 % cost is explicitly not a property |
| 6 layer labels | Two rows carry the same L2-on-L3 label the first pass corrected in B2 — see correction (c) |
| 7 registered variables | Rubric, evaluator `1.0.0`, benchmark `0448643`, model `claude-haiku-4-5-20251001`: unchanged and single-valued. **Harness `2.1.260`** on all 15 — see correction (a) |
| 8 keep/remove | Keeps are the registered arms and the four new controls, each with an executing fixture set (`verify-skill-activation` **28 passed**, `check-overlay-parity --allow-differ description` exit 0 with body `d10a2c3988be520e`; the observatory sets not re-run here). The one REMOVE, the runner's blanket "any Skill call is a plugin leak" rule, cites run `46ffad94` as the measured false exclusion; not re-derived by this validator |

Also verified: `skill-activation.sh` on `d6aec246` → `status: measured`, `activations_by_source:
projectSettings=1`, `invocation_triggers: claude-proactive=1`; `check-overlay-parity` reports
exactly one undeclared difference per overlay when `description` is not allowed, and none when it
is. The §5 table in `phases/03-skills/README.md` exists, is filled, and labels the "they were
read" and "the reading itself" rows L3 on its own.

**Corrections.**

- **(a) The harness version moved and the move is undisclosed.** B3 and E-002 ran on Claude Code
  `2.1.259`; every stop 8 run, including the 07:08Z preflight, is `2.1.260`. E-004 states "one
  harness version across all 15", which is true, and nowhere names the change from the previous
  stop (`grep 2.1.259` finds nothing in E-004 or the workbook). Within-batch the comparison is
  sound. Across stops this is the third harness move in the track, after `2.1.251 → 2.1.259` and
  obs#72's runner changes, and it belongs in the same disclosed list.
- **(b) `--enable-skills` on the control arm is asserted, not recorded.** E-004 says it "is
  passed on ALL THREE ARMS, including the control … registered here as a controlled variable".
  Nothing executes that for arm A: the runner's refusal only fires when an overlay contains a
  `SKILL.md`, arm A has no overlay, and the run record's `runtime` block still lacks the V6
  surface fields, so the resolved flag set is not on the record. By the layer rule that row is
  **L3**. The cheap L2 is a flags hash or the resolved `CLAUDE_ARGS` on the run record; the
  cheaper L3 is to say "asserted" in the controlled-variables row.
- **(c) Two rows labelled L2 where nothing executes.** "the prediction preceded the runs — L2,
  both sides read from git and the API" and "a scored cell is re-read by hand — L2 for the
  ordering, git decides it". Git and the API *write* the timestamps; a human *compares* them, and
  nothing rejects a run that started early. This is the identical correction the first pass made
  to B2's table, applied there and not carried here. Both are **L3**. The stop's closure does not
  depend on the label.
- **(d) This validator's second pass confirmed a block that was on the wrong premise.** The
  second pass reproduced root-versus-nested `/probe` registration with `--setting-sources project`
  and the model flag only, and wrote "the block is CONFIRMED by independent reproduction". The
  registry facts reproduced were true; the conclusion drawn from them, that a nested skill cannot
  be delivered to a run, was wrong, because the reproduction dropped `--disable-slash-commands`,
  exactly the flag that decided the outcome. The builder's flag probe found this
  (`evidence/p03/skill-flag-probe-20260904T102230Z.md`: 6 of 6 activate without the flag at both
  paths, 0 of 6 with it) and its criticism of the hand probe applies to the validator's probe
  word for word. **Withdrawn here rather than by editing the second-pass file**, which stays as
  the record. The lesson is the house one: a reproduction that does not use the harness's exact
  flag set is a control reporting over a smaller scope than it claims.
- **(e) Wording.** The report's stop 4 row gives "`n = 5` claude"; the baseline is `n = 9`
  claude runs, of which 5 were scored.

**Two process facts a stranger should know, both already disclosed by the builder in
`process_violations_this_session`.** Commit `b20719b` (the stop 8 state handover) was pushed
directly to `main` with admin rights, bypassing branch protection; it stands, and its follow-up
fix went through lab#59 correctly. And `E-004` was truncated to zero bytes mid-session and
recovered from git; the diff on `main` shows no loss.

## The single finding most likely to overturn the track's result

**The co-variate, reproduced from the sheets: on `maintainability`, the arm that never activated
the skill scores like the arm that did.** Matched 5 of 5 at anchor 2, misdescribed **4 of 5**,
control 1 of 5. Anchor 2 is word-for-word the first bullet of the skill body. Activation, as
measured by a `Skill` tool_use, is therefore not the only channel through which a skill file
changes behaviour on this instrument — a tracked `SKILL.md` read as an ordinary file is the
obvious other one, and the builder measured that as possible (1 of 6 flag-off runs emitted the
body's marker after a plain read).

If that is what is happening, the activation result stands exactly as stated and **every
behavioural claim about a skill on this instrument is confounded until a fourth arm separates
"selected" from "read"** — including everything B6, the specialist-skill step, would want to
claim. It is `blocked_on_author` item A. It does not block stop 9. It should be decided before
B6 at stop 13, not after, because B6's gate is "runs with and without compared on quality", which
is precisely the reading the confound sits under.
