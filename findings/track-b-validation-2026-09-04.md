# Track B validation — 2026-09-04

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md, 2026-09-04.`
Read-only. Nothing in a workbook, experiment, run folder or sheet was edited. **Independence
caveat, stated up front:** this validator ran in the session that authored the prompt, not in a
fresh one. Every check below was made against files, git objects, the observatory API and the
telemetry file, never against the builder's prose, but the reader should weigh that caveat.

Input: `findings/track-b-2026-09-03.md` (stops 4, 5, 6, 7 reported closed), `TRACK-B-STATE.md`
(stop 8 not started).

## Verdicts

| Stop | Verdict | Failing or corrected rows |
|---|---|---|
| 4 — B2 | **CONFIRMED WITH CORRECTIONS** | two L2 labels on proofs nothing executes; PR cited as lab#49 does not exist; prediction commits are squash-orphaned; the five B2 sheets cannot be rebuilt |
| 5 — Phase 1 | **CONFIRMED WITH CORRECTIONS** | "48 control runs" does not reproduce (40); no §5 table in the workbook; PR cited as lab#49 |
| 6 — B3 | **CONFIRMED WITH CORRECTIONS** | no §5 table (exit-gate table lacks the layer and re-derivation columns); all nine commits in the Commit table are squash-orphaned |
| 7 — Phase 2 | **CONFIRMED WITH CORRECTIONS** | `DEFERRED` marker count is 6, the table says 5 |

No stop is NOT CLOSED. Every gate clause of every stop mapped to evidence that exists and
opens, every prediction commit precedes its first run, every re-derived cell matches, every
treatment hash separates perfectly, and no registered variable moved without disclosure.

## What was checked, per stop

### Stop 4 — B2

| §9 check | Result |
|---|---|
| 1 evidence exists | `GET /api/runs`: `EXP-B2-BASELINE-CLAUDE` n=9, `-CODEX` n=5, `EXP-B2-CONTAM-ISOLATED` n=5, `-OPEN` n=5, **all `evaluation.exitCode 0`**. Five codex sheets for `0a222393 5bd24356 8322e71b aa72e2c2 72fdc94f` on disk. `evidence/b02/baseline-report-20260901T192000Z.txt`, `worktree-decay-20260903T134500Z.txt`, `hand-reading-maintainability-4c891809.txt` all open. `./tools/check-run-gate.sh` re-run on `4c891809`: `ok: gate passed (exitCode 0)`, exit 0 |
| 2 prediction before run | `git show 59ac936`: committer 2026-09-03T15:06:30+02:00 = **13:06:30Z**. API `4c891809.startedAt` = **13:07:19Z**. 49 s margin. Read from git and the API, not prose. **But see correction (c).** |
| 3 one cell re-derived | Builder's hand reading of `4c891809` maintainability = 2, codex sheet `score-…4c891809…-20260903T133459Z.yaml` maintainability = 2. Worktree confirmed intact (17 `.kt`). Not re-read by this validator; the E-003 cell below was |
| 4 treatment reached one arm only | `customization.*Hash` **null on all 10** E-002 runs (correct: B2 installs nothing). Independent variable is hook execution: record-level query over `events.jsonl` (`body == claude_code.hook_execution_start` grouped by `observatory.run.id`) gives **0, 0, 0, 0, 0** isolated and **29, 33, 27, 31, 48** open — the workbook's "27–48" reproduces exactly |
| 5 n<5 property | None found. E-002 states "true of these runs, not as a property". The n=3 headline in the B2 README stands with its n=5 correction beside it, which is the project's rule |
| 6 layer labels | **Two rows labelled L2 where nothing executes** — see correction (a) |
| 7 registered variables | Rubric `396e1799eb2b` = `shasum -a 256 \| cut -c1-12` of the file today. Evaluator `1.0.0` everywhere. Model `claude-haiku-4-5-20251001` everywhere. Benchmark sha moved `8aadc75` → `0448643` between B2 and E-002; `git diff 8aadc75..0448643 -- tasks/ sample-service/` is **empty**, as E-002 claims. Harness moved `2.1.251` → `2.1.259`; E-002 is self-contained under `2.1.259` and says so |
| 8 keep/remove | KEEP `ISOLATE_USER_SETTINGS=1` — effect measured: +13.8 % cost, 0 vs 27–48 hook executions, `inputTokens` −88 % against a 6 % band. On record |

**Corrections.**

- **(a) L2 labels on L3 proofs.** Row "deliberate failure, prediction committed before the run"
  is labelled L2 because "both timestamps are machine-written". Row "the independent variable
  reached one arm and not the other" is labelled L2 because "the runtime emits the events".
  Apply the layer rule in order: can a run that started before its prediction commit still be
  written down? Yes. Does something execute and reject it? **No** — a human compares two
  timestamps, and a human counts two bodies. Both proofs are **L3** by the workspace rule.
  Machine-written evidence is not an executing check. Phase 2's own validation table makes
  exactly this correction on itself ("an L2 label on an L3 object"); B2's table did not.
- **(b) The PR does not exist.** The report's stop 4 and stop 5 rows cite `lab#49`. There is no
  PR 49 in `agent-learning-lab` (`gh pr view 49` fails; issue #49 is an unrelated finding).
  Stops 4, 5 and 6 shipped in **lab#53**, merged 2026-09-03T19:07:36Z as `27d67e5`, which is on
  `origin/main`.
- **(c) The prediction commits are unreachable from `main`.** `59ac936` and `0e0c6f9` exist in
  this clone only; `git log -- experiments/E-002-isolation-contamination.md` on `main` shows
  one commit, the squash `27d67e5` at 19:07Z, six hours **after** the runs. A stranger cloning
  the repo cannot perform §9 check 2 for E-002 at all. HANDOFF.md already records this hazard
  for earlier shas; it now applies to every prediction in the track.
- **(d) The five B2 sheets cannot be rebuilt.** Confirmed: the five scored B2 worktrees hold
  **1 `.kt` file each**, the 36 E-002 and B3 worktrees hold 17. The builder disclosed this and
  substituted a fresh run for the hand re-derivation. The closure's "completed rubrics" clause
  therefore rests on sheets whose inputs no longer exist. Stated, not hidden, and not fixable.

### Stop 5 — Phase 1

| §9 check | Result |
|---|---|
| 1 evidence exists | Exit gate answered 3 of 6 from `EXP-BE002-AGENTSMD-V3`, `EXP-BE002-CLAUDEMD-V2`, B2; 3 marked NOT MEASURED with what each needs. All three experiment keys exist in the API |
| 2, 3, 7 | No new runs; not applicable. Rubric untouched |
| 4 treatment reached one arm only | **39 treatment runs carry `sha256:13a7b6afb4d4b07312035d72a21c3049`** — AGENTSMD-V3 10, CLAUDEMD 11, CLAUDEMD-V2 18 — exactly as claimed. **Control runs across those three keys: 40, not 48** (10 + 12 + 18), all `null`. Separation is perfect with zero exceptions; the number 48 does not reproduce from the keys the workbook names |
| 5 n<5 property | None. `INCONCLUSIVE` on n=10+10 stands |
| 6 layer labels | The claim that obs#36's closure is L2 (field written by the runner, readable per run) holds: the field is machine-written **and** the runner refuses a customization whose instruction file the runtime does not read, which executes |
| 8 keep/remove | None taken |

**Corrections.** (a) "all 48 control runs" → **40** from the named keys; the conclusion is
unchanged. (b) **No §5 validation table exists in `phases/01-instructions/README.md`** (grep
for the table header returns 0). The exit gate is answered; the four-column table the prompt
requires was not written. (c) PR cited as lab#49 → lab#53.

### Stop 6 — B3

| §9 check | Result |
|---|---|
| 1 evidence exists | `build/customizations/instructions-v0.1/CLAUDE.md`: 57 words, `shasum -a 256 \| cut -c1-32` = `90f95226cc3d429f6f3e157e4741bbd1`, matches the run records. All six `evidence/b03/*` files open. **20 codex sheets** for the 10 + 10 arm runs, every one at `rubric_sha 396e1799eb2b`, `schema_sha 5ee1b8ec16ab`. The 5 bloat runs and the preflight have no sheet, and none is claimed |
| 2 prediction before run | `2015555` committer **16:59:55Z** → preflight `043237f5` startedAt **17:00:05Z** (10 s), first treatment `367a809d` **17:03:16Z**. Bloat arm: `97e2ed5` **17:05:09Z** → first bloat run **17:55:22Z**. Both from git objects and the API |
| 3 one cell re-derived **by this validator** | `367a809d` (treatment run 1) `ShipmentController.confirm()` read off its kept worktree: `if (status == CANCELLED) throw …` then `return if (status == CONFIRMED) shipment else save(…)` — an if-chain with an `else`, no `when`. Rubric comment: "wants an if-chain or an `else` → anchor 0". **Validator 0 · census 0 · codex sheet 0.** Three readers agree on a mechanical construct |
| 4 treatment reached one arm only | `instructionsHash` = `90f952…` on **10/10** treatment + preflight, **null on 10/10** control, `807c5d…` on **5/5** bloat. `hook_execution_start` = **0 on all 26** runs, from the telemetry file. `skillsHash`, `hooksHash` null on all |
| 5 n<5 property | Every number carries its n. One sentence to watch: *"the construct is chosen at roughly one run in three whatever the instruction file says, or whether one exists"* — pooled 8 of 25 across three arms of 10/10/5. It is stated with its n, but "whatever the file says" reads as a property; the evidence supports "on these 25 runs" only |
| 6 layer labels | The workbook applies the layer rule to the *artifacts* (line 94 section) but there is **no per-clause proof-layer column** — see correction (a). The claim "treatment delivery is now L2" holds on the same grounds as stop 5 |
| 7 registered variables | Rubric, evaluator, model unchanged. Benchmark `0448643`, byte-identical to B2's on `tasks/` and `sample-service/`. **Harness `2.1.259` vs B2's `2.1.251`** — moved, disclosed, and the reason the gate's "vs B2" was substituted with a concurrent control. The control reproduces B2 on six measures (table in the workbook) |
| 8 keep/remove | REMOVE R1: 2/10 vs 3/10 on record in the census and 20 sheets. REMOVE R2: both registered outcomes inside their pre-registered MDE, the MDE derived from measured spread before the run (E-003 "Minimum detectable effect"). REMOVE R3: 20/20 honoured both arms. No KEEP. Ordering held: hand-read `e963460` 17:07Z, census `eb02928` 17:55:38Z, first sheet 17:59:42Z, last 18:08:56Z |

**Corrections.** (a) **No §5 table.** The Exit gate table has "Gate item / Met? / Evidence" and
no "Layer of the proof" or "How a stranger re-derives it" column. The evidence column is
complete and every entry opened, so the closure stands; the table the prompt requires does
not. (b) All nine commits in the Commit table (`2015555 97e2ed5 e963460 eb02928 5d10e31
d6a13f2 225db94 d55150a 29561a2`) are squash-orphaned; only `27d67e5` is on `main`. Same
consequence as stop 4 (c).

### Stop 7 — Phase 2

| §9 check | Result |
|---|---|
| 1 evidence exists | §5 table present, eight rows, all opened. `SOURCES.md` lines 61, 89, 90, 91 are ✅. PR **lab#54** merged 2026-09-03T20:02:25Z as `df4a022`, on `origin/main` |
| 3 one claim re-derived | Fetched `code.claude.com/docs/en/skills` today: `allowed-tools` = "Tools Claude can use without asking permission during the turn that invokes this skill"; `disallowed-tools` = "Tools removed from Claude's available pool while this skill is active". **Verbatim match** to the workbook's headline finding |
| 5, 7 | n=0 disclosed on every claim; no registered variable touched |
| 6 layer labels | Honest: L2 for "URLs resolve" (check-links executes), L3 for "were read". The table corrects its own earlier L2 label |

**Correction.** `grep -c DEFERRED` returns **6**, the table says 5 (the count line in the
table itself is the sixth match). Trivial.

## The single finding most likely to overturn the track's result

**The track's only substantive result is B3's null — a delivered instruction file moved
nothing — and R1 never names the construct it was written to move.** R1 asks for the
"defensive" form abstractly; anchor 2 is a specific Kotlin object (`return when` over all
three states, no `else`). E-003 registers this as follow-up 3 and it is the cheapest
discriminator on the table: one more 10 + 10 arm with a rule that names `when` outright. If
that arm moves the construct, "instructions move nothing" becomes "this instruction was too
abstract to reach its construct", and B3's REJECT-and-do-not-replace verdict, which B4 and
the L3 count are already citing, is the wrong lesson. If it does not move it, the null
becomes a property of the mechanism rather than of one phrasing.

Second, a process risk rather than a result risk: **every prediction commit in this track is
reachable only from this laptop.** Squash merges have orphaned all eleven. The
prediction-precedes-run proof is L3 by the layer rule and now also unverifiable from `main`.
A pre-push check that refuses a workbook citing a sha `main` cannot reach, or a convention of
merge commits for stop branches, would make check 2 re-derivable by a stranger. Until then the
track's most-cited guarantee is a habit.
