# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running   # UNBLOCKED 2026-09-04 by the author. Decisions are in `author_decisions` below; the stop 8 blocker in HANDOFF.md item 1 is decided, not merely deferred
prompt_sha: 0580d5332a2b
prompt_read_at: 2026-09-04T06:32:02Z
stop: 8            # stop 7 CLOSED and merged; 8 is Phase 3 (Agent Skills), REOPENED at §4 step 3 after the second validator pass
loop_step: 5       # steps 1-4 done this session; at the preflight assertion. REOPENED 2026-09-04 by author decisions 1-2. Registering EXP-P3-NESTED-PROBE (§4 step 3) - the probe that decides whether the stop-8 block is on the right premise
branch: phase03/nested-probe   # in agent-learning-lab; stop branches now merge with --merge, never squash (author decision 4)
in_flight:
  - "§0a preflight re-run after the halt, delegated; seven rows"
validation_processed:
  - "findings/track-b-validation-2026-09-04-2.md - read in full 2026-09-04. Stops 4-7 CONFIRMED; stop 8 NOT CLOSED and never claimed closed, with the block itself CONFIRMED by independent reproduction. All four corrections applied additively: (a) the E-004 registration citation moved from 5d14182 to the last pre-run edit 5a14711, with the full pre-run edit table and the SUPERSEDED text of prediction 2 preserved in E-004 rather than lost; (b) three citations quoting the round-2 field names installed_scope_activations / installed_scope 0 fixed in the workbook and the probe evidence, with the merged tool's real output pasted, and 0 project-scope activations relabelled as an inference from 0 in every bucket; (c) recorded in E-004 that customization.*Hash cannot separate treatment from control for any skill arm, so §5 independence rests on telemetry alone; (d) fixture count 11 -> 15 in the workbook learning block and in this file. Nothing rewritten: no prediction, result, sheet or run folder. The validator's closing finding is ADOPTED, not disputed - the block proves absence from the /name registry at session start and not absence of mid-run activation, which is what E-004 measures"
  - "findings/track-b-validation-2026-09-04.md - read in full, all four verdicts CONFIRMED WITH CORRECTIONS, none NOT CLOSED, so no stop reopened. Every correction applied as a dated amendment in the workbook it names; no prediction, result, sheet or run folder rewritten. The one process risk (squash-orphaned prediction commits) went to blocked_on_author because fixing it changes a repo convention"
last_verified: "PR lab#56 MERGED as 049e871, 8 of 8 checks green; the merge of origin/main into the branch was resolved keeping this file and the complete 981-byte OFF-CONTRACT review, and all three validator amendments survive on main. Boards 2 of 2 current at 144a48bca1e3 AFTER the squash. Stop 8 HALTED at the preflight. Delivery block proved BOTH ways by execution: `claude -p \"/shipment-service-conventions\"` loads the skill and quotes its body at the root path, and answers `Unknown command` at the nested one, same binary/model/flags. Runs 16cd4378 (died at setup), c090f67e and d8be2b5f (completed, evaluator 0, zero project-scope activations with telemetry PRESENT). verify-skill-activation 15/15 (this line said 11/11 - the count before the last two gate rounds; corrected 2026-09-04 from the second validator pass), check-links 64 ok / 0 broken, shellcheck clean. EARLIER: three PRs merged. lab#53 as 27d67e5 (stops 4, 5, 6 shipped) and lab#54 as df4a022 (stop 7), both squash, both 8 of 8 checks green on their final heads. Boards republished at position 8 and re-checked ON MAIN AFTER the squash: 2 of 2 current at prose 4119c4abf58f, exit 0. Preflight re-run in full, all seven rows ok. check-links 64 ok / 0 broken"
next_action: "E-004 preflight, §4 step 5: ONE run per treated arm with ENABLE_SKILLS=1 KEEP=1 ISOLATE_USER_SETTINGS=1 MODEL=claude-haiku-4-5-20251001, key EXP-P3-PREFLIGHT2, overlays build/customizations/skill-v0.2 and skill-v0.2-misdescribed. Then (a) read both with tools/skill-activation.sh and PIN what skill.source a project skill emits - prediction 2 has no denominator until that value is named; (b) prove delivery in each kept worktree with the runner flag set minus --disable-slash-commands and -p /shipment-service-conventions. Only if BOTH arms deliver: batch 15 runs interleaved A,B,C under EXP-P3-SKILL-DESC. If the preflight shows no activation on the MATCHED arm, do NOT batch - that is prediction 1 failing at n=1 and it needs diagnosis, not 15 runs"
blocked_on_author: []   # cleared 2026-09-04: the squash item is decided (author_decisions 4); stop 8 is decided (author_decisions 1-2)
author_decisions:  # by the author, 2026-09-04, adopting the §9 validator's recommendation of the same day; provenance recorded so adoption measures something
  - "1. STOP 8 PREMISE CHECK BEFORE ANY FILE MOVES: run 5 nested-path runs with the REQUIRED description under a new experiment key before choosing between HANDOFF item 1 (a) and (b). The block proves absence from the /name registry at session start; E-004 measures mid-run activation, telemetry already carries a nested-skill trigger on run 899232bb, and the builder's own scratch test loaded a nested skill after a file read. n=1 per condition is not enough to halt on"
  - "2. IF THE PROBE IS ZERO ON 5 OF 5: option (b), the runner force-add (`git add -A -f -- <overlay paths>` in run-agent.sh section 5). NOT option (a): the benchmarks .gitignore is read by the evaluator's scope guard and changing it changes what the benchmark measures. Record (b) as a disclosed harness move, the second in the track after 2.1.251 -> 2.1.259"
  - "3. OLLAMA HOURLY LIMIT: the critic already runs on codex. Run reviews with -P codex -A and write `acceptance gate skipped: ollama rate limit <timestamp>` into the review provenance. Defer opencode second-reader sheets until the limit clears; never skip them, runs are kept. This is a control substitution, not a registered variable"
  - "4. SQUASH-ORPHANED PREDICTION COMMITS: from this stop on, merge stop branches with a merge commit (`gh pr merge --merge --admin`), never squash, so prediction commits stay reachable from main. Do not rewrite history for stops 4-8; their commits live in this clone and in refs/pull/*/head, and the workbooks now say so. A pre-push check refusing a workbook that cites a sha main cannot reach is welcome but not required before continuing"
  - "5. The first-pass validator file is already processed; the second (-2.md) is not. Process it before opening stop 8 work"
blocked_on_author_history:
  - "SQUASH MERGES HAVE ORPHANED EVERY PREDICTION COMMIT IN THIS TRACK - all eleven. On main, `git log -- experiments/E-002-isolation-contamination.md` shows only the squash 27d67e5 at 19:07Z, SIX HOURS AFTER the runs it was supposed to precede. B3's nine commits are the same. So the prediction-precedes-run guarantee - the track's most-cited - CANNOT BE RE-DERIVED BY A STRANGER cloning the repo, and by the §9 validator's layer correction it is L3 as well. The fix is a repo-convention change and §7 reserves those for the author: merge commits for stop branches instead of squashes, or a pre-push check that refuses a workbook citing a sha main cannot reach. Raised by findings/track-b-validation-2026-09-04.md"
preflight:  # re-run in full after the halt, 2026-09-04T10:13:30Z. SEVEN of seven rows ok on the first pass, no row re-run
  hook_script: ok — 19 of 19 cases behaved as specified, exit 0
  review_harness: ok — exit 0, findings/opencode/review-run-record-20260904T100831Z.md, 6749 bytes, 12 finding sections each with Verdict/Failure/Layer/Anchor bodies below the header. Family codex, returned in 40s; acceptance gate SKIPPED by -A (ollama hourly rate limit, author decision 3). 0 bin/opencode processes after, checked with LC_ALL=C
  codex_harness: ok — codex-cli 0.147.0. Dry run 502 lines / 28415 bytes written to the PATH given (LAB_SCORE_DRY_RUN is a path, not a boolean). Real sheet findings/codex/score-good-nested-ifs-20260904T100937Z.yaml, all four categories: architecture-consistency 2, maintainability 0, test-quality null (in ambiguous_categories), change-focus 2. No stray ./1 created
  validators: ok — run-gate 13 + sheet-category 11 + run-record 12 + classifier 16 = 52 cases, chained exit 0
  stack: ok — 18 of 18 smoke checks against API 8081, exit 0, stack already up
  isolation: ok — verify-codex-isolation.sh 3 of 3 (no-autoload, no-discoverability, plugins-blocked) for codex-cli 0.147.0. OBSERVED FROM TELEMETRY, not the flag: c090f67e 0 hook_execution records of 100; d8be2b5f 0 of 73; both carry null on all five customization hashes. POSITIVE CONTROL: run d312ab16 returns 44 hook records, so the join is not blind — the previous preflight had no such control
  board: ok — 2 of 2 boards current at 144a48bca1e3, exit 0
  timestamp: 2026-09-04T10:13:30Z
  stray_processes: "0 remaining, nothing needed killing; both LC_ALL=C pgrep counts 0"

preflight_findings_20260904:  # two new instrument discrepancies, both the house shape: a control reporting over a scope smaller than it claims
  - "opencode-review.sh HARD-REQUIRES `opencode models` to succeed before any panel resolves, so a codex-only panel (-P codex, which never touches opencode) still exits 1 when opencode auth is unavailable. The panel appears to have escaped the dependency and has not. This matters now, because author decision 3 routes every review of this stop through -P codex specifically to get out from under the ollama rate limit"
  - "verify-run-record-validator.sh and verify-model-output-classifier.sh print no `all N cases behaved as specified` summary line, unlike the other two verifiers. Chained with && the caller gets exit 0 and no statement of the scope actually covered. §0a row 4 says `every fixture returns its registered exit code`; two of the four scripts do not say how many fixtures that was"

critic_family_defect:  # new at stop 8, and it decides which family §4a uses from here
  - "ollama-cloud/glm-5.2, the DEFAULT line-level critic, has now failed three consecutive invocations across two sessions: two stalls on 2026-09-03 (24 min against a 600s budget, no STALLED line, wedged processes left behind) and one OFF CONTRACT on 2026-09-04 (prose instead of the section format, exit 1, 981-byte findings file). codex has succeeded on all four invocations it has been given in the same window. USE `-P codex` FOR §4a REVIEWS until the author decides otherwise. This is a family substitution in the review harness, which is a control and not a registered experimental variable - no experiment's numbers come from the critic"
  - "process checks must match the opencode BINARY (`pgrep -f 'bin/opencode'`), not the wrapper argv. Polling shells carry `opencode-review.sh` in their own command lines and register as a live harness for as long as they run - the preflight agent was fooled for ~11 minutes by its own poller. Combined with the LC_ALL=C blindness this is now two independent ways the stall check reports a process that is not there, or misses one that is"

preflight_corrections:  # found BY the preflight, all three about instruments believing more than they measured
  - "pgrep is BLIND on this machine. Bare `pgrep -fl opencode` fails with 'Regular expression evaluation error (illegal byte sequence)' and returns nothing, which reads exactly like 'no stall'. Only `LC_ALL=C pgrep` sees the processes. CLAUDE.md and PROMPT §4a both tell the reader to check for a live opencode process before trusting a findings file; on this machine that check silently answers no. Every stall check from here uses LC_ALL=C"
  - "the previous preflight's isolation line, 'hook_execution_start = 0 across the registered population', was too broad. 129 of 209 telemetry-joined registered runs have >0, all from pre-isolation experiments. The claim holds exactly and only for the 25-run B3/E-003 population, which is the population E-003 used — so E-003 is untouched and the state file's wording was not"
  - "LAB_SCORE_DRY_RUN is a destination PATH, not a boolean — codex-score.sh:287. PROMPT §0a row 3 says to set it to 1, which writes the 502-line prompt to a file literally named ./1 in the repo root. The file was removed and the tree restored. Prompt and code disagree; per §1 the code wins. Use LAB_SCORE_DRY_RUN=./some-path.md"
review_this_stop: "THREE rounds over E-004 + tools/skill-activation.sh, family codex (glm-5.2 failed §0a OFF CONTRACT). ALL THREE RETURNED REJECT - recorded as REJECT, which §4a says is NOT a pass. R1 review-E-004-...-072705Z.md, 3 blocking, all fixed. R2 ...-074639Z.md, 2 blocking, both fixed. R3 ...-080814Z.md, 4 blocking: ONE fixed (the deepest), THREE STILL OPEN - arm C's delivery proof is circular with the prediction it confirms, nothing mechanically asserts only the description differs, and partial telemetry corruption is not separated from absent telemetry. A fourth file ...-073617Z.md at 850 bytes is a KILL ARTIFACT from a 10-minute tool timeout, not a stall; ...-075753Z.md exited 1 (infrastructure) and was discarded per §4a rather than counted as a round"

review_lesson: "The same defect was found in three consecutive rounds and each fix named one more scope instead of rejecting the category. skill-activation.sh classified anything not 'bundled' as the installed skill; then anything not bundled-or-empty; then anything not bundled-or-plugin. Every version would have credited a user-scope or enterprise activation to the treatment ON THE CONTROL ARM. Eleven fixtures passed over the first two broken versions, which is the point: a fixture set tests the cases its author thought of. The tool now reports per-source counts and labels NOTHING as the installed skill"

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
| 8 | Phase 3 — Agent Skills | **REOPENED 2026-09-04 at §4 step 3** by author decisions 1–2, after the §9 validator's second pass found the halt may rest on the wrong premise: the block proves a nested skill is absent from the `/name` registry *at session start*, and E-004's outcome is *mid-run* activation. `EXP-P3-NESTED-PROBE` (5 runs, nested path, REQUIRED description) decides it before any file §7 protects is moved. PREVIOUSLY: **BLOCKED at §4 step 5.** Reading and extract done; E-004 registered at `5d14182` before any run; `tools/skill-activation.sh` built and proved by 11 fixtures; two overlays with byte-identical bodies. **The lab cannot run**: a Claude Code project skill cannot be delivered to a BE-003 run. Root `.claude/skills/` is gitignored so the runner refuses; nested `sample-service/.claude/skills/` commits fine and the runtime answers `Unknown command`. Three runs spent proving it, zero measured. Unblocking is one line and it is the author's call |

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

**From stop 8 — DECIDED by the author 2026-09-04, no longer held:**

F. ~~**Stop 8 needs one line changed, and there are two candidates.**~~ **Decided.** The premise is
   probed first (`EXP-P3-NESTED-PROBE`, 5 runs at the nested path with the REQUIRED description);
   only if that is zero on 5 of 5 does a line move, and the line is the **runner's**
   (`run-agent.sh` force-adds the overlay it installed), never the benchmarks `.gitignore` — the
   evaluator's scope guard reads that file, so changing it changes what the benchmark measures.
   Recorded as author decisions 1–2 above.

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
