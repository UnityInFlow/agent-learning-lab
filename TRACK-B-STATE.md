# Track B — state

`Written by Claude Opus 5 (1M context), 2026-09-03, at the author's instruction.` Every claim
below was **re-derived on this machine today**, not copied from `HANDOFF.md` or from
`findings/track-b-2026-09-03.md`. Where a re-derivation disagreed with the document it was
checking, the disagreement is recorded here rather than reconciled quietly.

## Verdict

**The current spine stop is 6 — B3, minimal global instructions. It is REFUSED.**

Not blocked, and not closed. The three words are not interchangeable here:

| word | means | who can clear it |
|---|---|---|
| **closed** | the registered gate is met and its evidence is on record | nobody — it is done |
| **blocked** | something outside the runner's authority prevents the measurement | whoever owns that thing |
| **refused** | the work is runnable, and was declined because the next decision is the author's | the author, by deciding |

B3 is **refused**: nothing prevents its first run technically. What is missing is two decisions
that change what the benchmark measures, and an unattended session is not entitled to take
them. One of the two also has a **live blocker** underneath it, verified below — so clearing
the refusal is a decision, and executing it then needs a fix.

## Position

| Stop | What | Status | Verified how, today |
|---|---|---|---|
| **4** | **B2 — plain-prompt baseline** | **CLOSED** | `GET /api/runs` over **201 runs**: `EXP-B2-BASELINE-CLAUDE` n=9 **9 exit 0**, `-CODEX` n=5 **5 exit 0** → 14/14. Deliberate failure `EXP-B2-CONTAM-ISOLATED` / `-OPEN`, **5 + 5, 10 exit 0**. Prediction commit `59ac936` at **13:06:30Z**, first contaminated run `4c891809` `startedAt` **13:07:19Z** — 49 s, prediction first. All four evidence files present in `evidence/b02/` |
| **5** | **Phase 1 — custom instructions** | **gate ANSWERED**, phase result `INCONCLUSIVE` | Gate table live in `phases/01-instructions/README.md`. 3 of 6 items answered from measurement, **3 answered "not measured"** with what each needs. One of those three is itself a **refusal for cause** (Copilot arm, Decision G) — see *What changed under the documents* |
| **6** | **B3 — minimal global instructions** | **REFUSED — not started** | `phases/b03-global-instructions/README.md` is scaffold: `Goal`, `Required reading`, `Extract`, `Predict`, `Lab B3.1`, `Deliberate failure` and `Commit` are all `<!-- TODO -->`. No experiment key, no predictions, no runs |

Stops 1–3: 0A never started (Decision F — it gates nothing), 0B built, B1 closed 2026-08-30.

## The two reasons B3 is refused, and what is true about each today

### 1. `findings/` versus the evaluator's scope guard — a decision about what the benchmark measures

**Confirmed present, in code.** In `agent-observatory-benchmarks`:

- `tasks/BE-003-confirm-shipment/evaluator.sh:117` collects `git ls-files --others
  --exclude-standard` — untracked files count as changed files.
- `:112` `IGNORE_RE='(^|/)(target/|\.mvn/|\.git/)|\.(log|class|jar)$|^(run|evaluation)\.json$'`
  — **`findings/` is not in it.**
- `.gitignore` covers `target/`, `*.log`, `evaluation*.json`, `run*.json`, `.DS_Store`,
  `.memdb/`, `.idea/`, `.vscode/`, `*.pid`, `*.swp`, `.claude/*` — **`findings/` is not in it
  either**, and the repo *commits* its findings (`findings/opencode/review-20260903T075753Z.md`
  is tracked).
- `:383` `SCOPE_GUARD_PASSED != true → EXIT_CODE=21`, failure class `F07`.

So a review file that lands untracked inside the evaluated tree fails the run for something no
agent did. **Either fix changes a registered variable:** adding `findings/` to `IGNORE_RE`
changes what counts as a scope violation and exit codes are a contract; gitignoring it diverges
from this project's practice of committing findings as evidence. That is the author's call, and
B3 is the first step whose runs interleave with pushes that write findings.

**One naming inconsistency found while checking this:** `BE-003`'s log line `:332` prints
**`AC7` scope discipline**, while `:34`'s exit-code table and the repo `README.md:54` both call
the scope guard **AC6**. Same guard, two names, one of which is what a reader greps for.

### 2. The instrument still truncates the isolation fields — and the standing description of this is too strong

**Live, re-checked today.** `GET /api/runs/4c891809-…` returns a **four-key** `runtime` block:
`provider`, `product`, `version`, `model`. `userSettingsIsolated`, `shimsStripped` and `surface`
are **absent — not null**. `run-agent.sh:850` sends all three; obs#70's `validate-run-record.py`
asserts them. **V6's surface recording is L3 on the running instrument.**

**But the sharper statement is not the one on record.** `findings/track-b-2026-09-03.md` says
*"the instrument cannot currently record the thing B3 must prove."* It can. B3's gate needs the
treatment to be provably in one arm and not the other, and `customization.instructionsHash`
**persists and separates perfectly** — see below. What the instrument cannot record is the
**isolation regime the runs happened under**, which for B3 is a co-variate rather than the
dependent claim, because B3's treatment channel *is* settings-and-memory.

That is still a real reason not to register a B3 comparison today. It is a weaker reason than
the document states, and the difference matters: **B3's own gate is recordable at L2 right now.**

## What changed under the documents

Three facts that were true when the current documents were written and are not true now, or
never reconciled.

**1. The Copilot arm's stated blocker has lapsed.** `gh api /copilot_internal/user` reads
`premium_interactions`: **entitlement 300, remaining 300, 100 % remaining, overage not
permitted.** The monthly counter reset on the 1st. Decision G and spine Decision 2 both rest on
*"Copilot's quota is exhausted on this account"*, and Phase 1's sixth gate item is marked
`NOT MEASURED, and blocked by Decision G`. **The ground under that has cleared.**
⚠️ **The CLI was not invoked** — doing so spends the author's premium interactions without being
asked. This is a **quota fact, not a working-arm fact**; whether `copilot` runs is untested.

**2. `instructionsHash` separates better than the gate claims, and two of the gate's three
numbers do not reproduce.** Across all **201** runs: **55 carry
`sha256:13a7b6afb4d4b0731…`, 146 carry `null`, and the split is exactly `variant ==
"instructions"` — 55/55 and 146/146, zero exceptions.** Phase 1's gate says *"all 39 treatment
runs across `AGENTSMD-V3` (10), `CLAUDEMD-V2` (18) and `CLAUDEMD` (11), null on all 48
controls"*. The 39 checks out for those three keys. The controls in those three keys total
**40, not 48**, and the remaining **16** hash-bearing runs sit in two keys the gate never names
— `EXP-BASELINE-COPILOT` (5) and `EXP-BE002-NOHOOKS` (11). **The claim holds and understates
itself; its arithmetic is not re-derivable as written.** obs#36's closure is L2 either way.

**3. The lab repo has received no push since 2026-09-01.** `origin` holds exactly one branch,
`main` at `003b07e`. `b02/close-the-gate` exists only locally. So the finding *"the push hook
did not fire on any push this session"* has, in this repo, **no push behind it** — there was
nothing for it to fire on. Two further facts about that hook, checked in `.claude/settings.json`
and `.claude/hooks/opencode-review.sh`: the two `PostToolUse` entries differ only in an `if`
gate (`Bash(git push:*)`, `Bash(gh pr create:*)`), and the script **re-checks the command
itself** at `:74`, so it self-filters whether or not `if` is honoured. **Whether the hook arms
mid-session is still untested.** E-002 is in `CONTRACT_GLOBS` and its review was run by hand:
`findings/opencode/review-E-002-isolation-contamination-20260903T134641Z.md`, `acceptance:` at
line 8, and its load-bearing finding — **the MDE column was populated with the prediction
thresholds instead of derived from variance and `n`** — stands.

## The largest state fact: none of this has left the machine

`agent-learning-lab`, branch `b02/close-the-gate`:

- **5 commits ahead of `origin/main`, 0 behind, never pushed** — `59ac936`, `0e0c6f9`,
  `3fc71c1`, `af216bc`, `33c6bbb`.
- **4 files modified, uncommitted:** `HANDOFF.md`, `experiments/E-002-isolation-contamination.md`,
  `phases/01-instructions/README.md`, `phases/b02-plain-baseline/README.md`.
- **3 files untracked:** `findings/track-b-2026-09-03.md`,
  `findings/codex/score-observatory-run-4c891809-…yaml`,
  `findings/opencode/review-E-002-isolation-contamination-…md`.
- **No PR exists.** `findings/track-b-2026-09-03.md` cites *"PR lab#49"* on stops 4 and 5;
  **lab#49 is an issue** (*"A ten-agent planning pipeline drifted its shared sealed types"*).
  The last merged PR is **#48**, `docs/stale-state-after-b2`, 2026-09-02.

**So stop 4 is closed on disk and unreviewable by anyone else**, and the closure includes the
one thing a reviewer would attack first — the rubric row whose worktrees have since hollowed
out. Both sibling repos are clean, in sync, and have **zero open PRs**
(`agent-observatory` `4e58553`, `agent-observatory-benchmarks` `0448643`).

## Held for the author — nothing below can be delegated

1. **`findings/` versus the scope guard.** Changes a registered variable either way. **Blocks
   B3.**
2. **Rebuilding the observatory API.** V6 fields have been dropped from every run record since
   2026-08-30. The rebuild migrates the database holding **all 201 runs** and simultaneously
   pulls in a Spring Boot minor and a Kotlin major. **Blocks a clean B3 co-variate record.**
3. **Where kept worktrees live.** `$TMPDIR` is reaped by macOS — files deleted, tree left
   standing, so `RUNBOOK.md` §0.5 check #2 passes on a hollow skeleton. Moving them changes a
   registered path; leaving them means no scored run is re-derivable after ~3 days.
4. **The parity re-run's prediction** — still blank, still the only TODO in the B2 workbook.
   B2's gate is single-arm and closed without it; it blocks a ten-run batch and nothing else.
5. **Whether the Copilot arm reopens now that quota has reset** — and if so, whether Decision 2
   and Decision G are amended in place or superseded, since both name a condition that has
   lapsed.
6. **B10/B12 placement** — prerequisite order versus version order, unresolved in
   `LEARNING-PATH.md`. Decide before either is written.
7. **0A** — 19 checkboxes, position 1, never started. Decision F says it gates nothing.
8. **lab#44** — the scorer admits fixtures by name and B2's output has none.

## What must be true before B3's first run

Derived, not registered — a proposal for the author, and B3's `Predict before you run` block
must still be filled in writing before anything is launched.

1. Decision 1 above is taken, and the evaluator's contract records which way.
2. B3's candidate rule list is **filtered against B2's measured behaviour**, not against
   `build/README.md#b3`. Phase 1's gate already names the reason: B2's prediction 4 — a plain
   agent will miss L3 prose — was **refuted 0-of-14**, so a rule the agent already follows
   unprompted earns no always-on context.
3. The treatment is asserted by **hash on the run record**, one arm set and one arm `null`,
   before the batch — not by the file being present. This is the failure that cost this project
   ~$4 and twenty runs when `AGENTS.md` was installed for a runtime that reads `CLAUDE.md`.
4. The isolation regime is stated per run **from telemetry** (`claude_code.hook_execution_start`
   counts: 0 isolated, 27–48 open) for as long as the API drops the field.
5. A fresh experiment key. **`EXP-BE003-CLAUDEMD` is already taken** by 17 runs from
   2026-08-10…12, **all `variant: baseline`, all `instructionsHash: null`** — a key named for a
   treatment that holds only controls, with `runtime.model` recorded as `haiku` rather than a
   resolved id (obs#35's open half). Those runs cannot serve as B3's control arm.
6. E-002 follow-up 1 is either taken or explicitly deferred: **9 of its 10 runs are unscored**,
   and its conclusion — *isolation is a cost control, not a validity control* — rests on
   outcomes that cannot see quality. Scoring 5 and 5 would confirm or reverse it.

## Where the versions stand

```
stops 3–6     no version yet — the instrument and the baseline.  ← here, at stop 6
stop  15      v1.0 closes at B7
stop  17      v1.1 closes at B8
stop  26      v1.2 closes at B11
stop  27      v1.3 closes at B12 — do not build early
```

**Eleven of the thirteen B workbooks are still scaffold** — B3 through B13, every one reading `Status: ⬜ not started`. From B3 onward every gate includes a
measured comparison against the previous version, which is thirteen more controlled experiments
against BE-003.
