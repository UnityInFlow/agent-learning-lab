# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running
prompt_sha: 1dd9a22ac9b0
prompt_read_at: 2026-09-03T19:04:02Z
stop: 8            # stop 7 CLOSED and merged; 8 is Phase 3 (Agent Skills) and is NOT started
loop_step: 1       # nothing of stop 8 has been opened
branch: main       # phase02/prompt-files-extract merged as df4a022 and deleted
in_flight: []      # nothing running, nothing unmerged
last_verified: "TWO PRs merged. lab#53 as 27d67e5 (stops 4, 5, 6 shipped) and lab#54 as df4a022 (stop 7), both squash, both 8 of 8 checks green on their final heads. Boards republished at position 8 and re-checked ON MAIN AFTER the squash: 2 of 2 current at prose 4119c4abf58f, exit 0. Preflight re-run in full, all seven rows ok. check-links 64 ok / 0 broken"
next_action: "OPEN STOP 8 - Phase 3, Agent Skills - at loop step 1. It is a Track A stop that the itinerary gives a lab: 'reading, extract, one lab that records skill activation on the observatory', closing on that lab's evidence on disk. So unlike stop 7 it DOES need runs, and the whole loop applies, not the reading subset. Read phases/03-skills/README.md first. Phase 2's extract already carries the Claude Code Skills frontmatter reference it needs, including that no field is required and that description+when_to_use is capped at 1536 chars in the listing - do not re-fetch that page without reason"
blocked_on_author: []
preflight:  # re-run in full at stop 7, 2026-09-03T19:09Z; all seven rows ok, three corrections below
  hook_script: ok — 19 of 19 cases pass (the itinerary says 16; the script has grown to 19), exit 0
  review_harness: ok — exit 0, findings/opencode/review-run-record-20260903T190518Z.md, 199 lines, 12 per-section finding blocks plus an acceptance REJECT, not header-only. No process left by this run; two PRE-EXISTING wedged ones were found and killed, see stray_processes
  codex_harness: ok — codex-cli 0.147.0, findings/codex/score-good-nested-ifs-20260903T190604Z.yaml, exit 0, four categories present — architecture-consistency 2, maintainability 0, test-quality null ("nothing to grade", flagged in ambiguous_categories), change-focus 2
  validators: ok — run-gate 13 + sheet-category 11 + run-record 12 + classifier 16 = 52 cases, all four exit 0
  stack: ok — 18 of 18 smoke checks against API 8081, stack already up
  isolation: ok — verify-codex-isolation.sh exit 0. Claude arm proved from telemetry, not the flag: events.jsonl logRecords with body claude_code.hook_execution_start, grouped by observatory.run.id, joined to GET :8081/api/runs. EXP-B3-CONTROL-CLAUDE 10/10 present, hook_execution_start 0 on 10/10, all five customization hashes null on 10/10; EXP-B3-INSTRUCTIONS-CLAUDE 0 x10 and EXP-B3-BLOAT-CLAUDE 0 x5 with instructionsHash non-null as designed. Positive control EXP-B2-CONTAM-OPEN shows 27-48 executions, so the query can see a leak. No new run launched
  board: ok — exit 0, 2 of 2 current. RE-CHECKED after both merges: prose 4119c4abf58f, built from 34d7657, still current on main after the squash
  timestamp: 2026-09-03T19:09:53Z
  stray_processes: "two wedged opencode processes, pids 48589 (ollama launch opencode --model glm-5.2:cloud) and 48612, aged 2h20m, orphaned by the PRIOR session's 164550Z review — whose findings file is complete at 180 lines and committed in 27d67e5, so nothing was destroyed. Both killed 2026-09-03T19:12Z, 0 remaining"

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
