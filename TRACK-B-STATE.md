# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running
stop: 6
loop_step: 6
branch: b3/instructions-v0.1  # agent-learning-lab — not yet cut; work is on b02/close-the-gate
in_flight:
  - "EXP-B3-INSTRUCTIONS-CLAUDE + EXP-B3-CONTROL-CLAUDE: 10+10 interleaved batch started 2026-09-03T17:03Z"
  - "PR lab#53 open for stops 4-5; board check red until both boards are republished"
last_verified: "E-003 preflight run 043237f5 — instructionsHash sha256:90f95226cc3d429f6f3e157e4741bbd1 (the overlay's own bytes), 0 hook executions of 22 events, evaluator exit 0, startedAt 17:00:05Z after the prediction commit 2015555 at 16:59:55Z"
next_action: "when the batch finishes: assert n=10 per arm from the API, hand-read one treatment run's maintainability cell BEFORE any scorer touches it, then score both arms with codex"
blocked_on_author: []
preflight:
  hook_script: ok — 19 of 19 cases pass (the itinerary says 16; the script has grown to 19)
  review_harness: ok — exit 0, findings/opencode/review-run-record-20260903T164550Z.md, 14 finding sections, no stray process
  codex_harness: ok — codex-cli 0.147.0, findings/codex/score-good-nested-ifs-20260903T164645Z.yaml, architecture 2 / maintainability 0 / test-quality null / change-focus 2
  validators: ok — 13 + 11 + 12 + 16 = 52 cases, exit 0
  stack: ok — 18 of 18 smoke checks against API 8081
  isolation: ok — run 05b4081f, 0 hook executions of 17 events, all customization hashes null, kept worktree holds 17 .kt files
  board: fail — both boards describe an older HANDOFF.md; remedy is the republish in §4 step 14, deferred to one republish at the end of the run rather than two
  timestamp: 2026-09-03T16:56:12Z
hook_wiring: unproven in print mode — the stops 4-5 push ran with LAB_REVIEW_HOOK=0 because preflight row 2 held opencode at the time, and concurrent opencode calls are this machine's known stall mode. §4a's synchronous review is the review control for this run
```

## Position

| Stop | What | Status |
|---|---|---|
| 4 | B2 — plain-prompt baseline | **CLOSED**; shipped as PR lab#53, open |
| 5 | Phase 1 — custom instructions | **gate ANSWERED**, result `INCONCLUSIVE`; same PR |
| 6 | B3 — minimal global instructions | **RUNNING** — `instructions-v0.1` registered as E-003, predictions committed `2015555`, deliberate failure committed `97e2ed5` |

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
