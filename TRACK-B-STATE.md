# Track B — state

Owned by the autonomous run. `run-track-b.sh` reads `status:`. Everything the next session
needs is in this file; nothing lives in a conversation.

```yaml
status: running
stop: 4
loop_step: 14
branch: b02/close-the-gate  # agent-learning-lab
in_flight:
  - "stops 4 and 5 are closed on disk and UNSHIPPED: 5 commits unpushed, 4 files modified, 3 untracked, no PR"
last_verified: "2026-09-03 re-derivation of stop 4 and 5: 14/14 evaluator-passed, E-002 10/10, prediction commit 59ac936 13:06:30Z precedes run 4c891809 startedAt 13:07:19Z"
next_action: "0a preflight, all seven rows, delegated per 4b"
blocked_on_author: []
preflight: {}
hook_wiring: unproven
```

## Position

| Stop | What | Status |
|---|---|---|
| 4 | B2 — plain-prompt baseline | CLOSED on disk, ship (§4 step 14) outstanding |
| 5 | Phase 1 — custom instructions | gate ANSWERED, result `INCONCLUSIVE`, ship outstanding |
| 6 | B3 — minimal global instructions | not started |

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
