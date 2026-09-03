# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running
stop: 7
loop_step: 1
branch: b02/close-the-gate  # stops 4-6 all ship on this branch; b3/ was never cut and is not needed
in_flight:
  - "adversarial review of E-003 + the B3 workbook, opencode-review.sh -n 2, started 2026-09-03T18:15Z"
last_verified: "E-003 complete at 25 of 25 registered runs. Hash separation perfect: 10/10 treatment sha256:90f95226, 10/10 control null, 5/5 bloat sha256:807c5d03. All 25 evaluator exit 0. Twenty codex sheets written, and the scorer agrees with the pre-scorer hand census on all twenty runs cell for cell"
next_action: "read the review; fold any blocking finding into the artifacts BEFORE the PR; then republish both boards (the one deferred preflight remedy) and push stops 4-6 as one PR"
blocked_on_author: []
preflight:
  hook_script: ok — 19 of 19 cases pass (the itinerary says 16; the script has grown to 19)
  review_harness: ok — exit 0, findings/opencode/review-run-record-20260903T164550Z.md, 14 finding sections, no stray process
  codex_harness: ok — codex-cli 0.147.0, and since re-proved by 20 consecutive scoring runs, exit 0 on every one
  validators: ok — 13 + 11 + 12 + 16 = 52 cases, exit 0
  stack: ok — 18 of 18 smoke checks against API 8081
  isolation: ok — proved per run from telemetry, hook_execution_start = 0 across the registered population
  board: fail — both boards describe an older HANDOFF.md; remedy is one republish at the end of the run, still deferred, now the last open item
  timestamp: 2026-09-03T16:56:12Z
hook_wiring: unproven in print mode — the stops 4-5 push ran with LAB_REVIEW_HOOK=0 because preflight row 2 held opencode at the time, and concurrent opencode calls are this machine's known stall mode. The synchronous review is the review control for this run, and it has now been taken twice
```


## Position

| Stop | What | Status |
|---|---|---|
| 4 | B2 — plain-prompt baseline | **CLOSED**; shipped as PR lab#53, open |
| 5 | Phase 1 — custom instructions | **gate ANSWERED**, result `INCONCLUSIVE`; same PR |
| 6 | B3 — minimal global instructions | **CLOSED**; gate met on all four items, result **REJECT**. `instructions-v0.1` is removed and not replaced — all three rules failed the gate's own "remove every rule with no measured effect" clause |
| 7 | Phase 2 — prompt files | **NOT STARTED** — inherits a measured null to beat rather than an assumption |

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

1. `findings/` versus the benchmarks scope guard — `BE-003/evaluator.sh:112` `IGNORE_RE` omits
   it, `:117` collects untracked files, `:383` exits 21.
2. Rebuilding the observatory API so V6 fields persist.
3. Where kept worktrees live — `$TMPDIR` is reaped by macOS.
4. The parity re-run's prediction.
5. lab#44; 0A; B10/B12 placement (the itinerary pre-makes the last one as version order).
