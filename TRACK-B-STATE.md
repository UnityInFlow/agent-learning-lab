# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running
prompt_sha: 1dd9a22ac9b0
prompt_read_at: 2026-09-03T19:04:02Z
stop: 7
loop_step: 13a  # review round in flight; steps 3-10 do not apply, this is a Track A reading stop
branch: phase02/prompt-files-extract
in_flight:
  - "prompt changed unrecorded -> 1dd9a22ac9b0; sections applied from stop 7 step 1 onward. No earlier stop is reopened; stops 4-6 keep the provenance they were closed under"
  - "opencode-review.sh -n 2 phases/02-prompt-files/README.md started 2026-09-03T19:26Z, review 1/2 in flight"
last_verified: "PR lab#53 MERGED as 27d67e5, squash, 8 of 8 checks green on the final head - stops 4, 5 and 6 are shipped. Preflight re-run in full 2026-09-03T19:09Z, all seven rows ok, three instrument defects found (see preflight_corrections). check-links 64 ok / 0 broken, and none of Phase 2's four sources is among the 8 moved or 2 blocked"
next_action: "read the findings file for the -n 2 review of the Phase 2 workbook when it lands, fix or dispute each finding in writing, then open the stop 7 PR. Contracts sent: the workbook only. NOT sent, and to be named in the PR body: TRACK-B-STATE.md, HANDOFF.md, CLAUDE.md. No tools changed at this stop"
blocked_on_author: []
preflight:  # re-run in full at stop 7, 2026-09-03T19:09Z; all seven rows ok, three corrections below
  hook_script: ok — 19 of 19 cases pass (the itinerary says 16; the script has grown to 19), exit 0
  review_harness: ok — exit 0, findings/opencode/review-run-record-20260903T190518Z.md, 199 lines, 12 per-section finding blocks plus an acceptance REJECT, not header-only. No process left by this run; two PRE-EXISTING wedged ones were found and killed, see stray_processes
  codex_harness: ok — codex-cli 0.147.0, findings/codex/score-good-nested-ifs-20260903T190604Z.yaml, exit 0, four categories present — architecture-consistency 2, maintainability 0, test-quality null ("nothing to grade", flagged in ambiguous_categories), change-focus 2
  validators: ok — run-gate 13 + sheet-category 11 + run-record 12 + classifier 16 = 52 cases, all four exit 0
  stack: ok — 18 of 18 smoke checks against API 8081, stack already up
  isolation: ok — verify-codex-isolation.sh exit 0. Claude arm proved from telemetry, not the flag: events.jsonl logRecords with body claude_code.hook_execution_start, grouped by observatory.run.id, joined to GET :8081/api/runs. EXP-B3-CONTROL-CLAUDE 10/10 present, hook_execution_start 0 on 10/10, all five customization hashes null on 10/10; EXP-B3-INSTRUCTIONS-CLAUDE 0 x10 and EXP-B3-BLOAT-CLAUDE 0 x5 with instructionsHash non-null as designed. Positive control EXP-B2-CONTAM-OPEN shows 27-48 executions, so the query can see a leak. No new run launched
  board: ok — exit 0, 2 of 2 current, prose sha fe4e9fa408d3, built from 1d448ce
  timestamp: 2026-09-03T19:09:53Z
  stray_processes: "two wedged opencode processes, pids 48589 (ollama launch opencode --model glm-5.2:cloud) and 48612, aged 2h20m, orphaned by the PRIOR session's 164550Z review — whose findings file is complete at 180 lines and committed in 27d67e5, so nothing was destroyed. Both killed 2026-09-03T19:12Z, 0 remaining"

preflight_corrections:  # found BY the preflight, all three about instruments believing more than they measured
  - "pgrep is BLIND on this machine. Bare `pgrep -fl opencode` fails with 'Regular expression evaluation error (illegal byte sequence)' and returns nothing, which reads exactly like 'no stall'. Only `LC_ALL=C pgrep` sees the processes. CLAUDE.md and PROMPT §4a both tell the reader to check for a live opencode process before trusting a findings file; on this machine that check silently answers no. Every stall check from here uses LC_ALL=C"
  - "the previous preflight's isolation line, 'hook_execution_start = 0 across the registered population', was too broad. 129 of 209 telemetry-joined registered runs have >0, all from pre-isolation experiments. The claim holds exactly and only for the 25-run B3/E-003 population, which is the population E-003 used — so E-003 is untouched and the state file's wording was not"
  - "LAB_SCORE_DRY_RUN is a destination PATH, not a boolean — codex-score.sh:287. PROMPT §0a row 3 says to set it to 1, which writes the 502-line prompt to a file literally named ./1 in the repo root. The file was removed and the tree restored. Prompt and code disagree; per §1 the code wins. Use LAB_SCORE_DRY_RUN=./some-path.md"
review_this_stop: "opencode-review.sh -n 2 over E-003 + the B3 workbook. Line level 2 runs glm-5.2, both ok. Acceptance minimax-m3 returned REJECT. findings/opencode/review-E-003-instructions-v0.1-20260903T181703Z.md, committed. Its first blocking finding corrected the primary outcome's epistemic label and is the sharpest result of the run"
hook_wiring: unproven in print mode — the stops 4-5 push ran with LAB_REVIEW_HOOK=0 because preflight row 2 held opencode at the time, and concurrent opencode calls are this machine's known stall mode. The synchronous review is the review control for this run, and it has now been taken twice
```


## Position

| Stop | What | Status |
|---|---|---|
| 4 | B2 — plain-prompt baseline | **CLOSED**; shipped as PR lab#53, open |
| 5 | Phase 1 — custom instructions | **gate ANSWERED**, result `INCONCLUSIVE`; same PR |
| 6 | B3 — minimal global instructions | **CLOSED**; gate met on all four items, result **REJECT**. `instructions-v0.1` is removed and not replaced — all three rules failed the gate's own "remove every rule with no measured effect" clause |
| 7 | Phase 2 — prompt files | **CLOSED as extract only, labs deferred**, which is what the spine registers for a ◇ stop. Four sources read, three of them never extracted before; exit gate answered on all four items; `n = 0` runs and nothing claimed about the agent. Two findings: `allowed-tools` pre-approves where VS Code's `tools:` restricts, so Lab 2.1's read-only constraint needs `disallowed-tools`; and two GitHub pages disagree on prompt-file support by IDE |
| 8 | Phase 3 — Agent Skills | **NOT STARTED** — next. Phase 2's extract already carries the Skills frontmatter reference it will need |

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

**New from stop 6, and the first three bear on stop 7:**

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
