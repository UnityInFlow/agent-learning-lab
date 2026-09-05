# Track B validation — 2026-09-05

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-05T07:55Z.` Read-only. Nothing outside this file was created, edited or deleted in any
repository. Verifier scripts were not re-run this pass; the artifacts they cover have not
changed since pass 10 ran them (git tree clean, `main` unchanged).

**Independence.** Builder `claude-opus-5`; validator `claude-fable-5-1`. This validator wrote
passes 9 and 10 yesterday and checks its own corrections here, which is a weaker position than
a stranger's; every number below was recomputed from the raw artifacts again rather than
carried.

**Inputs.** Prompt at sha `952c64e4fc35` (unchanged); `TRACK-B-STATE.md` at branch
`stop10/b4-agent-boundary` (`2498dc7`); `findings/track-b-2026-09-04.md`; the six §5 tables;
`E-004`, `E-005`; `evidence/p03/flagprobe/`, `evidence/p04a/e005/` (52 transcripts);
`agent-observatory/infra/telemetry-out/events.jsonl`; the API on `:8081` (249 runs, newest
`946144c3` at 2026-09-04T11:32:47Z); GitHub issue lab#29 and project 2.

**Repository state.** `origin/main` is `b86401c` — **unchanged since pass 10 was merged**.
The builder's work since then is on `stop10/b4-agent-boundary`, pushed, unmerged, no PR: it
carries pass 10's six corrections and stop 10's §4 steps 1–3. A reader of `main` today still
sees stop 9's table before those corrections. The local checkout is on that branch, clean.

**Scope.** Closed stops are **4, 5, 6, 7, 8 and 9**, unchanged from pass 10. Stop 10 is open at
§4 step 4 with a prediction registered (`2498dc7`, 2026-09-05T06:42:48Z) and **zero benchmark
runs**; it is out of scope and is not validated in either direction.

---

## Verdicts

| Stop | Verdict | One line |
|---|---|---|
| 4, 5, 6, 7 | **CONFIRMED** | Nothing on disk changed; the applied corrections from passes 1–10 are present on the branch and, for passes 1–9, on `main` |
| 8 — Phase 3 | **CONFIRMED** | Activations 5 / 0 / 0 re-derived from raw telemetry again, triggers 3 `claude-proactive` + 2 `nested-skill`; pass 10's 8.E wording fix applied |
| 9 — Phase 4A | **CONFIRMED** | All five pass 10 corrections applied additively; the delivered-schema table in E-005 re-derived here from all 52 init records and agrees to the run |

**No stop is NOT CLOSED, and no new correction is raised.** The one residual is where the
corrections live, below.

---

## Re-derived this pass

| Claim | This pass's value | Agrees? |
|---|---|---|
| Stop 8: matched 5/5, misdescribed 0/5, control 0/5, all `projectSettings` | own parser over `events.jsonl`: `d6aec246 45a70775 2cf0c720` `claude-proactive`; `33a4090d 8998ef3b` `nested-skill`; 0 on all ten untreated | yes |
| Stop 9: delivered tool schema per arm, from every `system/init` record | C 29 tools ×13 (11 batch + 2 preflight); D 29 tools ×12; T `Read,Grep,Glob` ×17 (10 + 5 replication + 2 preflight); **F `Read,Bash` ×10**; model `claude-haiku-4-5-20251001` and version `2.1.260` on all 52 | yes — E-005's amendment table matches cell for cell |
| Pass 10 corrections applied on the branch | `git diff origin/main..origin/stop10/b4-agent-boundary` removes exactly the lines pass 10 named: the flag-probe "1 of 3" sentence, the reading row, the one-variable row, the 26-fixture row, the flag-array row, the three placeholder paths. Each has a dated replacement citing `-10.md` | yes |
| 9.1 amendment preserves the registered text | E-005's *"one word added"* header stands; the amendment beneath it carries the per-arm table and the re-derive command, and states what survives (F1–F3, row 1) and what narrows (a three-name effect, not one word) | yes |
| 9.2 | README row now *"L3, both halves"*, with the array named as a mitigation | yes |
| 9.3 | row says **27** fixtures | yes |
| 9.4 | `## Commit` lists the four overlays, E-005, the driver and script; the three placeholders are named as removed | yes |
| 9.5 | workspace `CLAUDE.md` now reads *"position 10 (B4 — agent boundary), OPEN"* | yes |
| 8.E | flag-probe sentence now *"exactly 1 activation per transcript on 3 of 3"* with the wording note | yes |
| Author decision 8 recorded and acted on | `TRACK-B-STATE.md` `author_decisions` item 8; E-006 carries a *Delivered schema* row from `init.tools` on 3 of 3 confirmation runs and a decision-rule row 0a that voids on a schema mismatch | yes — noted, not validated |

**One correction to my own pass 10.** It said *"51 transcripts"*. The kept set is 31 batch +
15 deliberate-failure + 6 preflight = **52**, which is the number E-005's amendment uses. The
counts per arm in pass 10 were right; the total was not.

---

## The §9 checks, in brief

1. Every gate clause in the six tables maps to evidence that opens; nothing moved on disk since
   pass 10 checked each path.
2. Prediction-before-run holds for stops 4, 6, 8 and 9 from git and the run records; all
   stop 8 and 9 shas are reachable from `main`, stop 4–6's from `refs/pull/53/head`.
3. Scored and counted cells re-derived across passes 1–10 all agree; this pass re-read the
   stop 9 schema cells and the stop 8 activation cells.
4. Treatment reached the model and not the control: stop 8 by telemetry and worktree contents;
   stop 9 by the init records above — the registered arms exactly as designed, the
   deliberate-failure arm not, and that is now written where a reader will find it.
5. No `n < 5` figure is stated as a property in a closed stop's workbook.
6. No L1/L2 label remains on something that does not execute; the two pass 10 found are relabelled.
7. Registered variables: model, version, rubric, evaluator, benchmark single-valued within every
   batch; the three harness moves disclosed; the arm-F schema move disclosed.
8. Every remove and keep carries its measurement.

---

## Where the corrections live, and one process note

- **Everything pass 10 asked for exists only on `stop10/b4-agent-boundary`.** `main` still shows
  the uncorrected stop 9 table, the 26-fixture count and the three placeholder paths. It resolves
  when stop 10's PR merges at §4 step 14; if stop 10 halts before that, the stop 9 amendments
  should ship alone, the same rule pass 4 stated for stop 8.
- Stop 10 opened by the new §4 step 1 rule: lab#29 has an opening comment and its card is
  In Progress. The state file notes the branch was created before the first edit, so the stop-8
  main-commit violation did not recur. E-006's prediction commit precedes any run because there
  are no runs. **Not validated here:** the 21 off-observatory probe runs under `evidence/b04/`
  and E-006's design, including that its row 0a is reported as having fired on a first probe —
  that belongs to the pass that validates stop 10 when it closes.

---

## The single finding most likely to overturn the track's result if pursued

With author decision 8 closing the delivered-schema gap for every later `tools:` list, the
standing item returns to the one passes 8, 9 and 10 each named and no stop has yet run: **B3's
instruction file has never been observed reaching the runtime.** Its REJECT is the track's only
substantive measured null and the workspace `CLAUDE.md` instructs every future session to act
on it. One positive-control run — an instruction file demanding a token the task cannot
otherwise produce — converts that delivery proof from disk layout to observation for about
\$0.15. It should run before stop 10's batch, which is the first BE-003 batch since B3 and the
first to install an instruction-shaped treatment on the observatory again.
