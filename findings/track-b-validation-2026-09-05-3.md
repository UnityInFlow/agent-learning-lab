# Track B validation — 2026-09-05, third pass (pass 13)

`Validated by Claude Fable 5.1 (claude-fable-5-1), section 9 of PROMPT-opus5-track-b.md,
2026-09-05T16:29–16:50Z.` Read-only. Nothing outside this file was created, edited or deleted in
any repository. The builder was **not** running during this pass: tree clean at `107c3c8`, no
sheet newer than `20260905T111424Z`, `in_flight` empty and confirmed by `pgrep`.

**Independence.** Builder `claude-opus-5`; validator `claude-fable-5-1`. This validator wrote
pass 12, which the builder processed in `4b28fb0`. Checking one's own corrections were applied is
a weaker position than a stranger's; every number below was recomputed from sheets, the API and
git, not read off the state file.

**Inputs.** `TRACK-B-STATE.md` at `107c3c8`; the three commits since pass 12 (`d0067f5` step 7,
`4b28fb0` pass-12 processing, `107c3c8` step 8); `evidence/b04/scoring-batch2.md`,
`evidence/b04/report-e006.py`, `evidence/b04/hand-score-1c905fc9.md`; all 20 codex and 16
opencode sheets for the batch-2 run ids; `E-006`; the B4 README; the API on `:8081` (292 runs,
unchanged since pass 12); the overlay file.

**Repository state.** `origin/main` still `b86401c`. Lab branch `stop10/b4-agent-boundary` at
`107c3c8`, pushed; observatory `stop10/b4-agent-delivery` at `968b498`, pushed. No PR in either
repo. Overlay sha256 prefix still `59c2b5db71f4c01e22a51589a1febdf9` — **the treatment was not
edited** when pass 12's C1 was applied, as required.

**Scope.** Closed stops **4–9** unchanged: `git diff --stat 5393704 HEAD` over every closed-stop
path is empty, as at pass 12. Stop 10 is **open at step 9** (phase boundary 3) and is not claimed
closed; this pass audits steps 7 and 8 and the processing of pass 12.

---

## Stops 4, 5, 6, 7, 8, 9 — CONFIRMED, unchanged

---

## Stop 10 (B4) — OPEN at step 9, audit of steps 7–8 and the pass-12 processing

### Pass 12's five corrections — applied, additively, and verified before applying

| | applied where | additive? | verified by the builder first? |
|---|---|---|---|
| C1 `16 of 16` → `19 of 19`, `36` → `45` | E-006 (original sentence kept, amendment beneath), state file, `run-agent.sh` comment, `check-init-schema.sh`; **overlay deliberately untouched** | yes | yes — its table re-derived from the 48 transcripts and matches mine row for row |
| C2 the "structural" mechanism refuted | E-006 new section *C2 — the mechanism under P1 and P2 is REFUTED* with the 5 / 6 split and the `514b094e` sheet; state Position row | yes | yes — adds `runtime.product`, names the codex scorer model `gpt-5.6-sol` |
| C3 `:431` → `:525`; "what the runner stores" | E-006 delivery rows, in place | table cell | yes — and notes `:431` was right on `origin/main` and the builder's own step-4 edit moved it |
| C4 `model:` pin L2 → L3 | README layer table, in place with the reason | table cell | yes |
| C5 batch-1 sleep spans 2 → 1 | state Position row | yes | yes |

Across the three commits, **3 lines were deleted outside the state file** — exactly the three
table cells named above (two E-006 delivery rows, one README layer row), each replaced by a
corrected cell that quotes what it replaced. No prediction, result, sheet or run folder was
rewritten.

**Two places still carry the refuted claim without an amendment, and a reader who opens them
first will believe it:**

- `TRACK-B-STATE.md` line 46, `blocked_on_author`: *"`change-focus` IS A DEAD CATEGORY ON BE-003
  … THE MECHANISM IS STRUCTURAL, NOT CHANCE … the agent MUST add an `ErrorCode` constant"* —
  unamended. This is the item the author is asked to decide on, and it still poses the wrong
  question (E-006's C2 section says which question replaces it).
- `phases/b04-agent-boundary/README.md` line 202, *"`change-focus` is a constant on BE-003, and
  the mechanism is structural"* and the paragraph under it — unamended.
- `evidence/b04/scoring-batch2.md` line 107, *"The dead-category count reaches 60 of 60 across
  five experiments"* — written before pass 12 was processed, and true of the haiku population
  named, but "dead" is the word C2 retired.

**Correction 13.1:** amend those three additively, pointing at E-006's C2 section.

### Step 7 — scoring, re-derived from the sheets

All 20 codex sheets and all 16 opencode files for the batch-2 ids were parsed independently
and joined to the API by `run_id`:

| category | codex, treatment `n=10` | codex, control `n=10` |
|---|---|---|
| architecture-consistency | 2 × 10 | 2 × 10 |
| maintainability | 0 × 7, 2 × 3 | 0 × 9, 2 × 1 |
| test-quality | 1 × 10 | 1 × 8, 2 × 1, null × 1 |
| change-focus | 1 × 10 | 1 × 10 |

Cell for cell what `scoring-batch2.md` reports. The null is `67547dbc`, the 2-file control run
with no test file — a measurement under the rubric's precondition, and both harnesses null it.
Scorer model pinned to `gpt-5.6-sol` on all 20 codex sheets; rubric sha `396e1799eb2b` on all.

Second reader: **14 valid opencode sheets, 2 header-only files** (`9b27ba37`, `d79e3964`:
provenance block then *"you have reached your weekly usage limit"* — infrastructure, correctly
discarded and not counted as findings), **4 never attempted** (`2a8a616e`, `323591a9`,
`57a61b29`, `502bf6f1`). Cross-harness on the 14: architecture-consistency, maintainability and
test-quality **14 of 14 each**; change-focus **5 of 14**, all nine disagreements codex `1` /
opencode `2`. The builder's claim that the diff sides with codex holds: every one of the 20 diffs
adds an `ErrorCode` constant in `ApiError.kt`, which anchor 2 excludes by its own text, and
opencode's evidence field on the disputed runs cites one file in one tree. That is the harness
property `agent-learning-lab/CLAUDE.md` already records, now at 13 occurrences.

The hand score (`d375cdc`, 10:52:04Z) precedes the first sheet (10:52:58Z) by git and file
timestamps; its four cells match codex, opencode and this validator's own pre-sheet hand score
from pass 12.

The builder's handling of the second-reader shortfall is right on §4c's own terms: the
registered scorer completed, Decision H is a codex-outage rule and does not fire, the four are
owed and not to be filled by an unmeasured model. **Owed before the PR, not waived** — the state
file says so.

### Step 8 — the report

`make baseline-report` was not run, and the reason given is correct: it selects by
`experimentKey` alone and would fold the aborted batch 1 into batch 2 and both variants into one
arm. `evidence/b04/report-e006.py` filters on `runtime.version == 2.1.261` and splits on
`variant`; it prints no mean (grep confirms; the docstring and the closing line say so). **Run by
this validator, its output matches pass 12's independently derived table on every metric**:
toolCalls 27 vs 19.5 (Q1 23 / Q3 22 non-overlapping), cost 0.144 vs 0.153, duration 124 s vs
95.5 s, addedLines 72 vs 68.5, changedFiles 3 vs 3, test file 10/10 vs 9/10. Maintainability
anchor 2 at 3/10 vs 1/10 and change-focus 1 on 20/20 are re-derived above.

**The decision-rule gap the builder recorded is real and is the right thing to have recorded
rather than resolved at step 8.** Rows 0a–4 do not fire; row 5 requires *everything* inside its
MDE and `toolCalls` is not. The ladder is not total. Resolving it is step 11's job, and the
resolution must be written before it is applied: either row 5 is read as *"no outcome the gate
asks about moved"* — tool calls are a cost co-variate P5 registered, not a gate outcome — or a
row is added, dated, marked as added after the data, and the verdict computed both ways. The
builder's own note names the first reading's risk correctly: a rule written after seeing the
result is not a rule.

**Correction 13.2 — a self-correction the builder made and one it missed.** It corrected its
earlier *"there is no `durationMs` field"* (it is `efficiency.durationMs`). Not corrected: the
`status:` and `stop:` header comments still read *"§4 steps 1-6 DONE … step 7 next … ZERO
scored"* while `loop_step: 9` and `last_verified` say step 8 is done and 20 are scored. The
Position row for stop 10 opens *"OPEN at §4 step 6 complete, ZERO runs scored"* for the same
reason. `run-track-b.sh` reads only `status:`, so nothing breaks, but the three lines a re-entry
reads first contradict the two it reads next. Amend the comments.

### The §9 checks that still apply at this step

1. Cited artifacts exist: `scoring-batch2.md`, `report-e006.py`, `hand-score-1c905fc9.md`, 36
   sheet files, three review files from the re-run preflight — all present at the cited paths.
2. Prediction precedes run: unchanged from pass 12 (`2498dc7` 06:42:48Z; P6 at 08:33:06Z; batch
   2 from 09:50:45Z). Nothing in E-006 above the *Runs* heading changed in these three commits
   except the two C3 cells and the C1/C2 amendments, which are dated and additive.
3. Scored cell re-derived: done at pass 12 before any sheet; matched 4 of 4 then, and the
   remaining 19 codex sheets parsed here agree with the builder's tabulation cell for cell.
4. Delivery: unchanged — init record per run, `agentHash` null on both arms, disclosed.
5. n < 5 claims: *"maintainability anchor 2 at 3/10 vs 1/10"* is reported as NOT DETECTABLE, not
   as a difference — correct. The shipped-overlay `3 of 3` is still labelled n = 3.
6. Layers: the C4 relabel is applied; the init-schema check and the guard remain L2, re-run
   green by the builder after it accidentally stripped their executable bits and by this
   validator at pass 12.
7. Registered variables: rubric, evaluator, benchmark sha, model unchanged; scorer model pinned
   and identical on all 20 sheets.
8. Keep / remove: not reached (step 10–11).

### Process note

The builder's disclosure that its Python rewrites dropped the executable bit on
`run-agent.sh` and `check-init-schema.sh`, caught only by re-running the verifiers, is the
house failure mode caught by the control built for it, and it is recorded rather than tidied.
`git ls-files -s` shows both at `100755` now. Nothing in that episode reached a run.

---

## Corrections for the builder, all additive

- **13.1** Amend the refuted "structural / MUST add an `ErrorCode` constant / dead category"
  wording in `TRACK-B-STATE.md` `blocked_on_author` (line 46), the README (line 202 ff.) and
  `scoring-batch2.md` (line 107), each pointing at E-006's C2 section. The author reads the
  state file's item, not E-006's appendix.
- **13.2** Update the `status:` / `stop:` header comments and the Position row's opening
  clause to the step the file's own `loop_step` and `last_verified` record.
- **13.3** Before step 11 applies the decision rule, write down how row 5 is read with
  `toolCalls` outside its MDE, dated, and compute the verdict under both readings.

---

## The single finding most likely to overturn the track's result if pursued

Unchanged from pass 12 in substance, sharpened by step 7's data: **two of the rubric's four
categories — 50 of 100 points — carried zero variance across both arms of this batch
(`architecture-consistency` 2 × 20, `change-focus` 1 × 20), and a third (`test-quality`) moved
on one control run.** The builder flagged the first as never having been registered as dead.
Combined with C2 — the anchor is reachable, the model under test does not reach it — the
instrument question for the author is no longer *"repair one anchor"* but *"on BE-003 with
`claude-haiku-4-5-20251001`, which rubric categories can move at all?"* Until that is answered,
any B-step KEEP verdict on this rubric rests on the one category that has moved at n = 10, and
its MDE needs 9 of 10.
