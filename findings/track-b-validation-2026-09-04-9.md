# Track B validation, ninth pass — 2026-09-04

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-04T19:10Z.` Read-only. Nothing outside this file was created, edited or deleted — no
workbook, experiment, run folder, sheet or state file was touched. Two verifier fixture sets and
`check-links.sh` were executed; they write nothing into the repository.

**Why the `-9` suffix.** §9 names the output `findings/track-b-validation-<date>.md`. That name
and `-2` … `-8` are taken by today's eight earlier passes, and overwriting one would destroy
evidence. This is the only deviation from §9 here.

**Independence.** §9 asks for a model different from the builder's and a fresh session. Both
hold: the builder is `claude-opus-5`; this is `claude-fable-5-1` in a context started with
`/clear`, with no memory of the earlier passes beyond what is on disk. Every number below was
recomputed here — own OTLP parser over the raw telemetry, own Fisher, own readings off the kept
worktrees, own census classifier — and nothing was accepted because a workbook or an earlier
pass said it.

**Inputs.** `PROMPT-opus5-track-b.md` §5 and §9; `findings/track-b-2026-09-03.md` and
`-2026-09-04.md`; `TRACK-B-STATE.md`; the five §5 tables; `E-002`, `E-003`, `E-004`;
`evidence/b02/`, `evidence/b03/`, `evidence/p03/`; 249 run records from the live API on `:8081`;
`agent-observatory/infra/telemetry-out/events.jsonl` (3 855 lines, 0 malformed); the codex sheets;
the runner and the BE-003 evaluator; the kept worktrees under `$TMPDIR`; the flag-probe transcripts
in a previous session's scratchpad; the eight earlier passes.

**Repository state.** `agent-learning-lab` HEAD `03496ca` on `stop9/validator-pass-3-corrections`,
`origin/main` `288ceee`, branch **not merged** — so every stop-8 correction from passes 3–8 is
still invisible to a reader of `main`. Untracked: passes `-6`, `-7`, `-8` and this file. Pass
`-8` was modified on disk while this pass ran (its independence paragraph was corrected); noted,
not acted on. `agent-observatory` `5179432`; `agent-observatory-benchmarks` `0448643`, `git
status --porcelain` empty.

**Scope.** `TRACK-B-STATE.md` and `findings/track-b-2026-09-04.md` report stops **4, 5, 6, 7, 8**
closed and stop 9 in progress at §4 step 8. Stop 9 is out of scope and is not validated here in
either direction.

---

## Verdicts

| Stop | Verdict | One line |
|---|---|---|
| **4 — B2 plain baseline** | **CONFIRMED WITH CORRECTIONS** (2, both wording) | Every gate clause opens; telemetry, gate, no-mean test and prediction timing re-derived; the benchmark-sha independence check now shown immaterial on these runs, and one amendment sentence is false as written |
| **5 — Phase 1 instructions** | **CONFIRMED WITH CORRECTIONS** (1, carried from pass 8) | 39 hash / 40 null / one digest re-derived; the L2 label on the context row still describes a refusal narrower than the clause |
| **6 — B3 global instructions** | **CONFIRMED WITH CORRECTIONS** (2, wording) | 2/10 vs 3/10 re-derived by a mechanical classifier agreeing with all 20 sheets; bloat 3/5 re-derived; hashes and timing hold; same two wording corrections as stop 4 |
| **7 — Phase 2 prompt files** | **CONFIRMED** | `n = 0` and the table says so; `grep` → 3; link check re-run twice, none of the four sources moved or blocked |
| **8 — Phase 3 skills** | **CONFIRMED WITH CORRECTIONS** (4 new, 3 carried and still unapplied) | 5/0/0 and `p = 0.0079` re-derived from raw telemetry; delivery re-derived from the worktrees at L1 and from the runner guard at L2; but E-004 cites an experiment key with **zero runs on the instrument**, and the evidence behind the `p = 0.0022` flag result lives in a temp directory outside every repository |

**No stop is NOT CLOSED.** Every gate clause in every §5 table maps to evidence that exists and
opens, with the one exception passes 6–8 already recorded (the arm-C probe, correction 8.2
below), and that row's gate is met by the matched arm's five activations independently.

---

## What was re-derived here, and what it returned

| Claim | Where | This pass's value | Agrees? |
|---|---|---|---|
| Stop 8: matched 5/5, misdescribed 0/5, control 0/5 | E-004, §5 | own parser over `events.jsonl`: `d6aec246 45a70775 2cf0c720 33a4090d 8998ef3b` = 1 each, all `projectSettings` / `custom_skill`; 0 on all ten untreated; `hook_registered = 23` on all 16, so every run is in the file | yes |
| Stop 8 triggers | E-004 results table, README row | `claude-proactive` on 3, **`nested-skill` on `33a4090d` and `8998ef3b`** | table is wrong on 2 of 5 (pass 6's 8.1, confirmed a fourth time) |
| Fisher `p = 0.0079`; `0.0022`; `1.0`; `0.017` | headlines, co-variate | 0.00794; 0.00216; 1.0 (2/10 v 3/10); 0.01698 (9/1 v 1/4) | yes |
| Stop 8 delivery, per arm, from the kept worktrees | §5 "reached the model / could not reach the control" | arm A: no `.claude` path, `git ls-files -- .claude` empty on 5/5 and on `62deb6c5`; arms B and C: `SKILL.md` **tracked** (ls-files = 1) on 10/10, body `sha256:d10a2c3988be520e` on all ten by an independent frontmatter strip, description lines exactly the two overlays' | yes — L1, off the artifacts themselves |
| Arms B and C could not have started with skills disabled | §5 "harness would refuse" | the `die` at `run-agent.sh:354–361` exists at `d0d62c8` (10:27:16Z) and at `f332681` (10:46:08Z), the last run-path commit before the first batch run at 11:03:44Z | yes — the guard predates the batch |
| Overlay parity; fixture sets 28 / 16 / 16 / 7 | §5 | `check-overlay-parity.sh` exit 0, same digest; `28 passed`, `16 passed`, `16 passed`, `7 passed`, 0 failed | yes |
| Stop 8 cost −7.6 % | E-004 | medians 0.1485 / 0.1373 / 0.1458, matched vs control **−7.6 %**, ranges overlap | yes |
| Stop 6: treatment 2/10, control 3/10, bloat 3/5 | E-003, census, §5 | **mechanical classifier** over `confirm()` in all 25 kept worktrees (regex: `when (shipment.status)` in `return`/`=` position, no `else ->`): treatment `b93d0f9f a472f54c`; control `b1daa5db d04bb5d6 42c67dd8`; bloat `97a39231 aeb3c05a b7c17ec5`. **Agrees with all 20 codex sheets, cell for cell** | yes — a fourth instrument agreeing |
| `instructions-v0.1` 57 words, `90f95226cc3d429f6f3e157e4741bbd1`; bloat 1 455 words, `807c5d03…` | stop 6 §5, run records | `wc -w` 57 / 1 455; `shasum` first 32 = `90f95226cc3d429f6f3e157e4741bbd1`; `807c5d03f77cc661`; on 10/10 + preflight, `null` on 10/10, `807c5d…` on 5/5 | yes |
| Stop 6 and stop 4 isolation: `hook_execution_start` | §5 rows | B3 all 26 = 0 (`hook_registered` 23 each); E-002 isolated 0,0,0,0,0 (23 each), open 29, 33, 27, 31, 48 (24 each); stop 8 all 21 = 0 | yes |
| Stop 5: 39 hash / 40 null | §5 row 3 | 79 runs over the three keys: 39 non-null, 40 null, one digest `sha256:13a7b6af…` | yes |
| Stop 4: B2 sheets exist; gate admits them | §5 rows 1–2 | five codex + five opencode sheets on disk; `check-run-gate.sh` **exit 0** on all five; **exit 2** on `62deb6c5` | yes |
| Stop 4: no mean in the baseline report | §5 row 3 | `runner/test_baseline_report.py` `NoMeanAnywhere` — 19 tests, OK | yes, and the test executes |
| Prediction precedes first run | all §5 tables | `59ac936` 13:06:30Z < `4c891809` 13:07:19Z (49 s); `2015555` 16:59:55Z < `367a809d` 17:03:16Z (3 m 21 s); `97e2ed5` 17:05:09Z < bloat `97a39231` 17:55:22Z; `f8ff084` 10:34:48Z < `d671d1b7` 11:03:44Z (28 m 56 s). All read with `git show -s --format=%cI` and the API | yes |
| The pre-run commits contain what the tables say | — | `f8ff084` already holds the `(5,0)` cell and the F13 exclusion; `2015555` holds R3 "moves nothing"; `59ac936` holds the Predictions section; `97e2ed5` holds DF2 | yes |
| Hand re-read precedes the scorer | stop 6, stop 8 | `e963460` 17:07:34Z; census `eb02928` 17:55:38Z; first B3 sheet `scored_utc 17:59:42Z`. `40f38e2` 11:39:51Z; first stop-8 sheet `scored_utc 11:39:56Z` — **5 s**, and `scored_utc` is the scorer's *start* (`stamp` at `codex-score.sh:175`, `codex exec` at `:326`) | yes — see 8.C |
| Reachability | stop 4 (c), stop 6 (b), stop 8 | eleven stop 4–6 shas **not** reachable from `origin/main`; `f8ff084 7cf5adb 35abde7 40f38e2` reachable; but `59ac936`, `2015555` **are on GitHub** (`gh api …/commits/<sha>` returns them, via `refs/pull/53/head`) | see 4.B / 6.B |
| Flag probe 6/6 vs 0/6 | `evidence/p03/skill-flag-probe…`, workspace `CLAUDE.md` | recounted from the 12 raw `stream-json` transcripts with the probe's own detector: root-noflag 3/3, root-flag 0/3, nested-noflag 3/3, nested-flag 0/3, and `nested-flag-3` = `read_skillmd=1 text_marker=1 skill_tool=0` exactly as the file says | yes — see 8.B for where those transcripts are |
| Stop 7 | §5 | `grep -c "^## .*DEFERRED"` → **3**; `check-links.sh` run twice: `ok=64 moved=8 blocked=2 broken=0`, then **`ok=63 moved=9`** minutes later (a new OWASP redirect); the four Phase 2 URLs are in neither MOVED nor BLOCKED list on either run | yes; the counts are time-dependent and the row already half-says so |
| `.gitignore` between `8aadc75` and `0448643` (pass 8's 4.1) | stop 4, stop 6 independence checks | 16-line diff confirmed; **and** no stop 4–6 kept worktree (5 B2, 10 E-002, 3 sampled B3) holds any `.claude` entry or any untracked file, so the changed lines could not have altered the guard's output on those runs | 4.1 is right about scope and the diff is immaterial on these runs — see 4.A |
| Mid-batch runner commits | E-004 sanity "runner did not change during the batch" | B3 and E-002 batches: no `runner/` commit in window. Stop 8: `487fe8e` at **11:07:24Z**, inside 11:03–11:34Z, touching only `runner/verify-skill-delivery.sh` (a fixture verifier, not on the run path) | true for the run path; see 8.D |

**Scored cells re-derived by hand, one or more per step that ran anything, all on cells no earlier
pass used**, rubric verified at `396e1799eb2b` by `shasum -a 256 | cut -c1-12`:

- **`2cf0c720`** (stop 8, matched): `val confirmed = when (shipment.status) { … }` then
  `repository.save(confirmed)`; expression position, no `else`. **Validator 2 · sheet 2.**
- **`cc41f3f0`** (stop 8, misdescribed): `return when (shipment.status) { … }`, no `else`.
  **Validator 2 · sheet 2.**
- **`d6aec246`** (stop 8, matched, the run with 18 `.kt` files): the controller now delegates —
  `fun confirm(...) = service.confirm(shipmentId)` — and the `when` sits in a **new**
  `ShipmentService.kt:20`, assigned to `updatedShipment`, no `else`. The sheet scores 2 citing
  `ShipmentService.kt:19`. Under Decision D a new changed file is attached, so the reading is
  admissible. **Validator 2 · sheet 2**, with the note that a rubric anchored on
  "one `when (shipment.status)`" is silent on which file it may live in.
- **`a472f54c`** (stop 6, treatment) and **`d04bb5d6`** (stop 6, control): both `return when`,
  no `else`. **Validator 2 · sheet 2** on each.
- **`9fcf4a92`** (stop 4, E-002 isolated, unscored): `return when`, no `else` — anchor 2; no
  sheet to compare. Recorded so the hand reading exists for a second E-002 run.

---

## Corrections, per stop

### Stop 4

**4.A — carried from pass 8's 4.1, now closed by measurement.** The independence checks in stop 4
and stop 6 say the benchmark is byte-identical between `8aadc75` and `0448643` on `tasks/` and
`sample-service/`. The runner archives a third path, `.gitignore`, and it differs by 16 lines
(`.claude/` → `.claude/*` with two `!` re-includes). The evaluator's scope guard runs
`git -C "$REPO_ROOT" ls-files --others --exclude-standard` against that file. **This pass checked
the runs, not just the diff**: none of the five scored B2 worktrees, none of the ten E-002
worktrees and none of the three B3 worktrees sampled contains any `.claude` path or any untracked
file. The changed lines could not have changed the guard's output on any run in stops 4–6. The
sentence still needs its third path named; the measurement it needs is above.

**4.B — one amendment sentence is false as written.** Correction (c) reads: *"`59ac936` and
`0e0c6f9` exist in this clone only."* They do not: `gh api repos/UnityInFlow/agent-learning-lab/commits/59ac936`
returns the commit with its 13:06:30Z timestamp, because `refs/pull/53/head` still holds it. The
true statement — and the one `TRACK-B-STATE.md` author decision 4 already makes — is
*unreachable from `main`, retrievable from the remote's PR ref*. A stranger **can** perform the
prediction-precedes-run check for stops 4–6 by fetching `refs/pull/53/head`; the workbook tells
them they cannot. Same sentence in stop 6's correction (b).

### Stop 5

**5.1 — carried from pass 8, confirmed, unapplied.** The row *"Can I prove the instruction entered
the model's context on a given run?"* is labelled L2 because *"the runner refuses a customization
whose instruction file the runtime does not read."* I read the refusal at `run-agent.sh:358–368`:
it fires only when a **foreign** filename (`AGENTS.md` for a `claude` run) is present and the
runtime's own filename is absent. Nothing executes that checks the correctly named file was read.
E-003 says exactly this (*"the filename half … L2. The content half is still this table's job"*);
the stop 5 table does not. Split the row: hash present and recorded, L2; entered the context, L3.

### Stop 6

**6.A — same as 4.A.** **6.B — same as 4.B.** Pass 8's 6.2 (the word "deleted"; the file is on
disk and must be) is confirmed: `build/customizations/instructions-v0.1/CLAUDE.md` is present, 57
words, hash matching.

One thing checked that no earlier pass wrote down: **R3's "planted predicted-inert" claim is
verifiable from the pre-run object.** `git show 2015555:experiments/E-003-instructions-v0.1.md`
line 53 reads *"R3 — the convention rule moves nothing at all"* at 16:59:55Z, three minutes before
`367a809d` started. The removal clause was armed before the data existed.

### Stop 7

No corrections. One observation for the row that cites `check-links.sh` counts: the counts moved
between two runs eleven minutes apart (`ok=64 moved=8` → `ok=63 moved=9`, a new redirect on the
OWASP page). The row's re-derivation instruction — read the counts, then check the four URLs
against the MOVED/BLOCKED lines — survives that, because it anchors on the four URLs and not on
the totals. Leave it as is.

### Stop 8

**8.A — NEW. E-004 cites an experiment key that has zero runs on the instrument.** The 2.1.260
amendment in E-004 (line 895, applied from pass 3's correction (a)) says: *"every run of
`EXP-P3-SKILL-DESC`, `EXP-P3-NESTED-PROBE` and the 07:08Z preflight ran on `2.1.260`."* The API
holds **no run under `EXP-P3-NESTED-PROBE`** — the keys on record for this stop are
`EXP-P3-PREFLIGHT`, `EXP-P3-PREFLIGHT2` and `EXP-P3-SKILL-DESC`. What author decision 1 asked for
was *"5 nested-path runs with the REQUIRED description under a new experiment key"* on the
observatory; what ran was a 12-call matrix in a scratch repository at `n = 3` per cell, outside
the observatory, with no run record. The flag-probe evidence discloses the substitution
(*"answered here at `n = 3` per cell for about a tenth of the cost"*), and E-005 line 34 later
calls `EXP-P3-NESTED-PROBE` *"a new probe on a scratch repository"* — so the key has become a
name for the scratch probe. Two things follow. The E-004 sentence cites runs that do not exist
under the id it gives, which is §9 check 1's failure shape, inside an amendment written to fix a
disclosure. And **author decision 1 was not executed as specified and no workbook row says so**:
the deviation (`n = 3` not 5; scratch repo not BE-003; no run record) is spread across an
evidence file and a later experiment. Correction: strike the key from the E-004 amendment, and
record the decision-1 deviation in `phases/03-skills/README.md` where decisions 1–2 are quoted as
adopted.

**8.B — NEW. The evidence behind `p = 0.0022` is not in any repository.** The flag probe's file
says *"Script kept at `scratchpad/flagprobe/matrix.sh`; the twelve raw `stream-json` transcripts
sit beside it."* That relative path resolves to nothing in `agent-learning-lab`. The files exist
today at
`/private/tmp/claude-501/…/6ce5cae6-7a0b-4e41-9aad-252aa7ddfa1c/scratchpad/flagprobe/` — a
previous session's scratch directory under the same `/private/tmp` that macOS reaps and that
already hollowed the B2 worktrees. I recounted all twelve with the probe's own detector and the
matrix reproduces exactly (see the table above). But the result that the workspace `CLAUDE.md`
tells every future session to read first rests on 13 files one cleanup away from gone, cited by a
path that does not exist. Same shape as 8.2 (the arm-C probe, whose transcripts are already
gone). Correction: copy `matrix.sh` and the thirteen `sj-*.jsonl` into `evidence/p03/` and fix
the path. The builder's call, not this validator's.

**8.C — NEW, wording. The hand re-read row's re-derivation instruction points at a value that has
already changed.** The row says *"`git show 40f38e2` versus the sheet's mtime in
`findings/codex/`"*. Every stop-8 sheet's mtime is now **12:09:49Z** (all fifteen were rewritten
by a checkout at 14:09:49+02:00), which is 30 minutes after the scoring and tells a stranger
nothing. The stable field is inside the sheet: `scored_utc: 20260904T113956Z`, which is the
scorer's **start** time (`stamp=$(date -u …)` at `codex-score.sh:175`, `codex exec` at `:326`).
`40f38e2` is 11:39:51Z, so the claim holds by **5 seconds** — the scorer was started the moment
the commit landed. True, thin, and re-derivable only by the field the row does not name.

**8.D — NEW, wording. "The runner did not change during the batch" is true of the run path and
not of `runner/`.** `487fe8e` (11:07:24Z, *"verify-skill-delivery: identify the skill by name"*)
landed while runs 3–15 were in flight. It touches only `runner/verify-skill-delivery.sh`, a
fixture verifier that no run executes; the last commit to `run-agent.sh` or `runner/lib/` before
the batch is `f332681` at 10:46:08Z. The registered variable did not move. The sentence should
say *the run path*, because a reader who runs `git log -- runner/` over the batch window finds a
commit and the sentence tells them there is none.

**8.1, 8.2, 8.3 — carried from passes 6, 7 and 8, all three still unapplied, all three
re-confirmed here from raw data:** the `claude-proactive` column is wrong on `33a4090d` and
`8998ef3b` (E-004 lines 663–667 and the README row at line 666 unchanged); `evidence/p03/` still
holds exactly two files and no arm-C probe transcript; the row's `jq` still returns 16 because it
does not filter `exitCode`.

**Verified here and worth stating because it closes a door.** Pass 3 relabelled *"`--enable-skills`
on all three arms"* L3 because flags are not on the run record and the runner guard is unreachable
on arm A. For arms B and C the guard **is** reachable and it predates the batch: the `die` at
`run-agent.sh:354` is in `d0d62c8` (10:27:16Z) and in `f332681` (10:46:08Z), the run path in
effect at 11:03:44Z. A misdescribed-arm run could not have started with skills disabled. Combined
with the tracked `SKILL.md` in all ten treated worktrees (L1, above), the only way arm C's zero
is manufactured is a runtime bug, not a harness flag. The activation headline is sound on its own
evidence; what remains open is the mechanism sentence (8.1).

---

## The §9 checks, answered

1. **Every gate clause maps to evidence that opens?** Yes, with two exceptions already on record
   and one new: the arm-C probe (8.2, no artifact); the flag-probe transcripts (8.B, artifact
   outside every repo, still present today); and an experiment key with no runs (8.A, in an
   amendment rather than a gate row). Every cited sheet, evidence file, overlay, fixture set and
   run id opened.
2. **Prediction commit before first `startedAt`, from git and the run record?** Yes for stops 4, 6
   and 8, by 49 s, 3 m 21 s and 28 m 56 s; and the pre-run objects contain the predictions the
   tables cite. Stops 4–6's eleven shas are unreachable from `main` but present on the remote's PR
   ref (4.B).
3. **One scored cell per step re-derived from the kept worktree at the registered rubric sha?**
   Six cells above, none used by an earlier pass, all agreeing; plus a mechanical census over all
   25 B3 worktrees agreeing with 20 of 20 sheets. Stops 5 and 7 have no scored cells.
4. **Treatment reached the model and not the control, from the run records?** Stops 5 and 6:
   `instructionsHash` separates perfectly, one digest per arm. Stop 4/E-002: 0×5 against 27–48×5
   hook executions. Stop 8: `customization.*Hash` is `null` on all 16 and cannot separate the
   arms — registered as prediction 4 — so delivery was re-derived from the worktrees (L1) and the
   telemetry, and the control's five worktrees hold no `.claude` path at all.
5. **A property stated from `n < 5`?** Yes, outside the workbooks: the workspace `CLAUDE.md` and
   `findings/track-b-2026-09-04.md` both say *"at both the root and the nested path"* / *"at both
   paths"* on `n = 3` per cell, stating the pooled 6 and not the per-path 3 — pass 6's 8.4, still
   unapplied. The flag-probe file itself says *"The nested path activates"* and *"Mid-run … it
   loads"* from 3 of 3. The workbook states `n = 3` per cell honestly at line 695.
6. **L1/L2 on something that does not execute?** Stop 5's context row (5.1). The two L2→L3
   relabels pass 3 made to stop 8 are present in the file. Every other L2 in the five tables names
   a thing I ran or read: four fixture sets, the parity checker, the run gate, the no-mean test,
   the evaluator, the runner's two `die`s.
7. **A registered variable moved between B2 and a later step?** Three harness moves, all now
   disclosed (`2.1.251` → `2.1.259` → `2.1.260`). Model, evaluator `1.0.0` and rubric
   `396e1799eb2b` are single-valued across all 66 Track B runs. Benchmark `8aadc75` → `0448643`
   is disclosed and, as of this pass, shown immaterial to the guard on the runs it touches (4.A).
   No run-path commit landed inside any batch window (8.D).
8. **Every "remove" measured, every "keep" measured?** Stop 6's three removals carry their
   instruments — R1 2/10 v 3/10 by census, sheets and this pass's classifier; R2 inside its MDE;
   R3 20/20 with the pre-run object showing it was planted. Stop 8's one removal (the blanket
   plugin-leak rule) is an existence claim measured on `46ffad94`. Nothing in a closed stop is
   kept on an assumed effect.

---

## The single finding most likely to overturn the track's result if pursued

**Pass 8's finding stands and this pass tried its cheapest route; the route does not resolve it.**
The track's one substantive result is B3's null, and nothing in the repository observes the
runtime receiving the instruction file's bytes: delivery is proved from disk layout and a hash,
and the one deterministic assay — DF2, `cacheCreationTokens ≥ +1 500` for a 1 455-word file —
came out `+610`, not detectable. Pass 8 named route (1): look for the file in the cache
accounting already on the run records. Done here:

| | treatment (n=10) | control (n=10) | bloat (n=5) |
|---|---|---|---|
| `cachedTokens` median | 637 790 | 697 031 | 722 027 |
| `modelCalls` median | 22 | 22 | 22 |
| **cached tokens per model call**, median | 30 364 | 31 373 | 31 949 |

Bloat minus treatment is **+1 585 cached tokens per call**, which is about the size of the added
1 400 words and is exactly what a file sitting in the cached prefix on every call would produce.
But treatment minus control is **−1 009 per call** for a 57-word difference — the noise between
two arms that should differ by ~80 tokens is the same size as the signal. So the accounting is
*consistent with* delivery and cannot *show* it at this `n`. Route (2) — one positive-control run
whose instruction file demands a token the task cannot otherwise produce — is still the cheapest
thing that converts B3's delivery proof from inference to observation, costs about \$0.15, and
should run before B4 at stop 10 registers another instruction-shaped treatment on the same
unexamined proof.

**Second, and new, because it is about the evidence rather than the result:** stop 8's two
strongest supporting numbers — `p = 0.0022` for the flag and *"4 of 6"* for arm-C delivery —
are backed by transcripts in a per-session temp directory and by no transcripts at all,
respectively (8.B, 8.2). The activation headline survives without either, as shown above. The
*narrative* of stop 8 — that the halt was a flag, not a path — does not survive a `/tmp` cleanup,
and the workspace `CLAUDE.md` tells every future session to read that narrative first.

---

## For the builder, not verdicts

- `validation_processed` ends at pass 4. Passes 5–8 and this one are unprocessed. The stop-8
  corrections now number seven across five passes (8.1, 8.2, 8.3, 8.4, 8.A, 8.B, 8.C, 8.D) plus
  4.A/4.B, 5.1, 6.A/6.B — all additive, none rewriting a prediction, result, sheet or run folder.
  Stop 9's PR is already carrying pass 3's five; these should ride with it, and if stop 9 halts
  before that PR, ship the stop-8 amendments alone.
- 8.B is the one correction with a clock on it: copy the flag-probe transcripts into
  `evidence/p03/` before the scratch directory is reaped.
