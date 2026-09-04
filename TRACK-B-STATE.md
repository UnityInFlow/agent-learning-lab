# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running
prompt_sha: 0580d5332a2b
prompt_read_at: 2026-09-04T06:32:02Z
stop: 8            # stop 7 CLOSED and merged; 8 is Phase 3 (Agent Skills) and is NOT started
loop_step: 1       # stop 8 OPEN. Track A stop whose lab runs the benchmark, so the WHOLE §4 loop applies
branch: phase03/skills-activation   # cut from main after 93ee5f7
in_flight:
  - "prompt changed 1dd9a22ac9b0 -> 0580d5332a2b; sections applied from stop 8 step 1 onward. The change adds validation_processed: and the §0 rule that a validator file is processed BEFORE any stop is opened or continued. Stops 4-7 were closed under the old text and are not reopened for that reason alone"
  - "validator file PROCESSED; corrections applied to four workbooks and the track report. Stop 8 not yet opened"
validation_processed:
  - "findings/track-b-validation-2026-09-04.md - read in full, all four verdicts CONFIRMED WITH CORRECTIONS, none NOT CLOSED, so no stop reopened. Every correction applied as a dated amendment in the workbook it names; no prediction, result, sheet or run folder rewritten. The one process risk (squash-orphaned prediction commits) went to blocked_on_author because fixing it changes a repo convention"
last_verified: "TWO PRs merged. lab#53 as 27d67e5 (stops 4, 5, 6 shipped) and lab#54 as df4a022 (stop 7), both squash, both 8 of 8 checks green on their final heads. Boards republished at position 8 and re-checked ON MAIN AFTER the squash: 2 of 2 current at prose 4119c4abf58f, exit 0. Preflight re-run in full, all seven rows ok. check-links 64 ok / 0 broken"
next_action: "stop 8 step 1: read the three unextracted Phase 3 sources and write the extract. Then design a THREE-ARM lab on BE-003 - control (no skill) / treatment (skill whose description matches the task) / deliberate failure (IDENTICAL skill body, mismatched description) - measured from claude_code.skill_activated in telemetry, which exists and carries observatory.run.id, invocation_trigger and experiment.variant. Overlays go in build/customizations/skill-v0.1 and skill-v0.1-misdescribed, per the instructions-v0.1 precedent"
blocked_on_author:
  - "SQUASH MERGES HAVE ORPHANED EVERY PREDICTION COMMIT IN THIS TRACK - all eleven. On main, `git log -- experiments/E-002-isolation-contamination.md` shows only the squash 27d67e5 at 19:07Z, SIX HOURS AFTER the runs it was supposed to precede. B3's nine commits are the same. So the prediction-precedes-run guarantee - the track's most-cited - CANNOT BE RE-DERIVED BY A STRANGER cloning the repo, and by the §9 validator's layer correction it is L3 as well. The fix is a repo-convention change and §7 reserves those for the author: merge commits for stop branches instead of squashes, or a pre-push check that refuses a workbook citing a sha main cannot reach. Raised by findings/track-b-validation-2026-09-04.md"
preflight:  # re-run in full at stop 8, 2026-09-04T06:51Z. SIX rows ok on the first pass; row 2 FAILED and was fixed and re-run, see review_harness
  hook_script: ok — 19 of 19 cases behaved as specified, exit 0
  review_harness: ok — ON THE SECOND ATTEMPT, AND THE FAMILY HAD TO CHANGE. First attempt FAILED clean: `-n 1` on the default critic ollama-cloud/glm-5.2 returned OFF CONTRACT after 352s (prose, not the section format), harness exit 1, findings/opencode/review-run-record-20260904T063339Z.md at 981 bytes with zero finding sections. Not a stall - it terminated itself and said why. Re-run as `-P codex`: exit 0, findings/opencode/review-run-record-20260904T065312Z.md, 11672 bytes, 12 finding sections, content below the header. Acceptance returned REJECT on templates/run-record.yaml, which is a verdict about that template and not a harness failure
  codex_harness: ok — codex-cli 0.147.0, findings/codex/score-good-nested-ifs-20260904T063409Z.yaml, four categories: architecture-consistency 2, maintainability 0, test-quality null ("nothing to grade", listed in ambiguous_categories), change-focus 2
  validators: ok — run-gate 13 + sheet-category 11 + run-record 12 + classifier 16 = 52 cases, all four exit 0
  stack: ok — 18 of 18 checks, API on 8081, GET /api/runs returns 200 and 228 runs
  isolation: ok — verify-codex-isolation.sh all three checks hold for codex-cli 0.147.0. From telemetry, not the flag: events.jsonl (31 MB) joined on observatory.run.id to GET :8081/api/runs. 228 registered, 222 distinct telemetry run ids, 209 joined. SCOPED CORRECTLY: 129 of the 209 joined runs have hook_execution_start > 0, all pre-isolation; across the 25-run B3/E-003 population (CONTROL 10, INSTRUCTIONS 10, BLOAT 5) all 25 joined and every one is 0, and the 10 control runs carry null on all five customization hashes while the 15 treated carry non-null
  board: ok — exit 0, 2 of 2 current at prose 4119c4abf58f
  timestamp: 2026-09-04T06:57:30Z
  stray_processes: "one orphaned opencode binary (pid 77546, started 06:50:41Z) outlived the preflight agent that spawned it. Killed 06:57:30Z; 0 remaining. It did NOT come from the row-2 re-run, which left nothing"

critic_family_defect:  # new at stop 8, and it decides which family §4a uses from here
  - "ollama-cloud/glm-5.2, the DEFAULT line-level critic, has now failed three consecutive invocations across two sessions: two stalls on 2026-09-03 (24 min against a 600s budget, no STALLED line, wedged processes left behind) and one OFF CONTRACT on 2026-09-04 (prose instead of the section format, exit 1, 981-byte findings file). codex has succeeded on all four invocations it has been given in the same window. USE `-P codex` FOR §4a REVIEWS until the author decides otherwise. This is a family substitution in the review harness, which is a control and not a registered experimental variable - no experiment's numbers come from the critic"
  - "process checks must match the opencode BINARY (`pgrep -f 'bin/opencode'`), not the wrapper argv. Polling shells carry `opencode-review.sh` in their own command lines and register as a live harness for as long as they run - the preflight agent was fooled for ~11 minutes by its own poller. Combined with the LC_ALL=C blindness this is now two independent ways the stall check reports a process that is not there, or misses one that is"

preflight_corrections:  # found BY the preflight, all three about instruments believing more than they measured
  - "pgrep is BLIND on this machine. Bare `pgrep -fl opencode` fails with 'Regular expression evaluation error (illegal byte sequence)' and returns nothing, which reads exactly like 'no stall'. Only `LC_ALL=C pgrep` sees the processes. CLAUDE.md and PROMPT §4a both tell the reader to check for a live opencode process before trusting a findings file; on this machine that check silently answers no. Every stall check from here uses LC_ALL=C"
  - "the previous preflight's isolation line, 'hook_execution_start = 0 across the registered population', was too broad. 129 of 209 telemetry-joined registered runs have >0, all from pre-isolation experiments. The claim holds exactly and only for the 25-run B3/E-003 population, which is the population E-003 used — so E-003 is untouched and the state file's wording was not"
  - "LAB_SCORE_DRY_RUN is a destination PATH, not a boolean — codex-score.sh:287. PROMPT §0a row 3 says to set it to 1, which writes the 502-line prompt to a file literally named ./1 in the repo root. The file was removed and the tree restored. Prompt and code disagree; per §1 the code wins. Use LAB_SCORE_DRY_RUN=./some-path.md"
review_this_stop: "THREE rounds over phases/02-prompt-files/README.md, ACCEPT with blocking:[] in all three. R1 codex+deepseek review-README-20260903T193910Z.md, 5 non-blocking, all fixed. R2 same panel review-README-20260903T194325Z.md, 4 non-blocking, all fixed - the sharpest was an L2 label on an L3 object in the validation table, the exact failure mode the same file names two sections earlier. R3 codex alone review-README-20260903T194705Z.md, 2 non-blocking, both DISPUTED in the PR body because the artifact already records them. A FOURTH file, review-README-20260903T191414Z.md at 767 bytes, is a STALL not a review - kept as evidence"

review_harness_defect: "LAB_REVIEW_TIMEOUT DID NOT FIRE. The first stop-7 review sat at 'review 1/2' for 24 minutes against a 600s budget with both processes sleeping, printed no STALLED line, and was killed by hand. run_limited() at tools/opencode-review.sh:232 polls and is supposed to kill the process group; it did not. The re-run used -P codex,deepseek-v4-pro and codex returned in under a minute, as it always has here. NOT FIXED - routed around. Two separate stalls today, both on glm-5.2, both leaving wedged processes"
hook_wiring: unproven in print mode — and STILL unproven after stop 7, deliberately. Every push this session ran with LAB_REVIEW_HOOK=0, because a synchronous review was in flight each time and concurrent opencode calls are this machine's known stall mode. The synchronous review of §4a is the review control for this run and has now been taken five times
```


## Position

| Stop | What | Status |
|---|---|---|
| 4 | B2 — plain-prompt baseline | **CLOSED and MERGED**, PR lab#53 → `27d67e5` |
| 5 | Phase 1 — custom instructions | **gate ANSWERED**, result `INCONCLUSIVE`; merged in the same PR |
| 6 | B3 — minimal global instructions | **CLOSED and MERGED**, same PR; gate met on all four items, result **REJECT**. `instructions-v0.1` is removed and not replaced — all three rules failed the gate's own "remove every rule with no measured effect" clause |
| 7 | Phase 2 — prompt files | **CLOSED as extract only, labs deferred**, which is what the spine registers for a ◇ stop. Four sources read, three of them never extracted before; exit gate answered on all four items; `n = 0` runs and nothing claimed about the agent. Two findings: `allowed-tools` pre-approves where VS Code's `tools:` restricts, so Lab 2.1's read-only constraint needs `disallowed-tools`; and two GitHub pages disagree on prompt-file support by IDE |
| 8 | Phase 3 — Agent Skills | **NOT STARTED** — next, and unlike stop 7 it **needs runs**: the itinerary gives it "one lab that records skill activation on the observatory". Phase 2's extract already carries the Skills frontmatter reference it will need |

## Corrections carried forward, re-derived 2026-09-03

1. **`instructionsHash` separates 55 / 146 across all 201 runs, exactly `variant ==
   "instructions"`, zero exceptions.** Phase 1's gate says 39 treatment / 48 control; the 39 is
   right for the three keys it names, the controls in those keys total 40, and 16 hash-bearing
   runs sit in `EXP-BASELINE-COPILOT` (5) and `EXP-BE002-NOHOOKS` (11), which it does not name.
   The claim holds and understates itself.
2. **"The instrument cannot record the thing B3 must prove" is too strong.**
   `customization.instructionsHash` persists and separates. What the API drops is the
   *isolation* block — `GET /api/runs/<id>` returns a four-key `runtime`, with
   `userSettingsIsolated`, `shimsStripped` and `surface` **absent, not null**. For B3 that is a
   co-variate, and §0a row 6 already prescribes proving isolation from telemetry instead.
3. **Copilot premium quota reads 300 of 300 remaining** — the monthly counter reset. Decision G
   and spine Decision 2 both rest on it being exhausted. The CLI was not invoked, so this is a
   quota fact, not a working-arm fact. Decision G still governs: no claim about a Copilot-run
   agent.

## Held for the author

**New from stop 7 — two instrument defects, and neither is about an agent:**

D. **The stall check has been answering without looking, and the stall mitigation does not
   fire.** Bare `pgrep` is blind here (illegal byte sequence → empty output → reads as "no
   stall"), and `LAB_REVIEW_TIMEOUT` let a review run 24 minutes against a 600 s budget without
   printing `STALLED`. Both are fixed only at L3, in words. **The L2 versions are one small
   change to `tools/opencode-review.sh`** — force the locale in its stall check, and make
   `run_limited()` actually kill. Not built, because a review of the very artifact being shipped
   was in flight and *never edit a tool while a run of it is in flight* outranks fixing it fast.
   **This is now the oldest unfixed thing that can silently corrupt a review verdict.**
E. **`allowed-tools` versus `disallowed-tools` is unverified.** Stop 7's headline finding is
   sound from the documentation and **no lab here has observed either field behave**. Lab 2.1
   is the natural place to check it, and Lab 2.1 is deferred. Ten minutes of Phase 3 would
   settle it.

**Carried from stop 6, and the first three still bear on the next stop that runs:**

A. **Does the brevity recommendation survive?** Three documents here argue for short instruction
   files and the cost half of that case rests on `EXP-BE002-CLAUDEMD-V2`'s +39 %, from a
   comparison that moved more than one variable. Holding size alone at 25x gives **+4.2 %**.
   Re-justify, withdraw, or run the arm that would settle it.
B. **The test-writing asymmetry — register it, or drop it?** 4 of 10 treated runs wrote no test
   file against 0 of 10 controls, Fisher p = 0.087, on the arm carrying "run the verification
   command". **Never a registered outcome**, so it is not a result. Making it one needs n >= 20
   per arm and the outcome declared first.
C. **B3's 25 kept worktrees stop being re-derivable around 2026-09-06.** This turns item 3 below
   from a preference into a deadline.

**Carried:**

1. `findings/` versus the benchmarks scope guard — `BE-003/evaluator.sh:112` `IGNORE_RE` omits
   it, `:117` collects untracked files, `:383` exits 21.
2. Rebuilding the observatory API so V6 fields persist.
3. Where kept worktrees live — `$TMPDIR` is reaped by macOS.
4. The parity re-run's prediction.
5. lab#44; 0A; B10/B12 placement (the itinerary pre-makes the last one as version order).
