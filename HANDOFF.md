# Handoff — 2026-08-28

Read `CLAUDE.md` first; it carries the operational facts and is loaded automatically. This
file is the *state*: what is in flight, what is blocked, and on whom.

## Position

**Spine 3 of 28 — B1, the experiment contract.** No agent exists and none should until stop
10. B1 builds the instrument that decides whether anything later is true.

## Branch state

`lab21/the-ladder-had-gaps`, **10 commits**, ahead of `main`. **No PR yet** — open one.
`main` is at `0f58203` (PR #18, merged 2026-08-27, five CI checks green).

## What is BLOCKED ON YOU, and cannot be delegated

These are deliberately empty. A prediction adopted from someone else measures nothing, and
the previous adopted set broke on an authoring error nobody caught because nobody derived it
independently.

1. **`experiments/E-001-rubric-null-rate.md`** — hypothesis *mechanism*, three predictions,
   MDE, repetitions per fixture, the decision-rule thresholds.
2. **`experiments/E-001-blind-scores.yaml`** — five variants, 20 cells, three of them
   structural `null` up front. **17 judgements.**

**Order matters and is enforced by nothing but you:** predictions committed *before* the
first run, with the commit timestamp preceding it. Doing that backwards once voided nine
runs. And do not read any scorer output before the blind sheet is committed — read it first
and you will agree with it, and that agreement measures nothing.

Then: run the scorer on five variants, compare, record the gap. That gap is B1's exit-gate
evidence, and it closes B1.

## After B1, the spine does not move

**B2 needs 0A, and 0A has never been done.** Position 1 of 28 — "depends on nothing, blocks
everything". Reading and extraction, no build, ~5 hours. Links re-verified 2026-08-28:
0 broken, 8 moved (four OpenAI Codex docs migrated to `learn.chatgpt.com` and sit in 0A's
Tier 1 list — `SOURCES.md` needs updating before anyone reads it).

0A teaches hard controls versus words a human reads. This project paid for that lesson
**six times in twenty hours**: a schema note that constrained nothing, Decision B written as
built and unbuilt for two days, an exclusion blind to an uncited read, the gate-filter
assumption nothing enforced, a ranking inversion, and a header describing a control that by
then existed. Every one arrived as a bug rather than as reading.

## The rubric, and its critique loop

`benchmark/rubrics/backend-quality.yaml` — **sha `396e1799eb2b`**, four categories,
architecture 35 / maintainability 25 / test-quality 25 / change-focus 15.

Step 1 of E-001's procedure is to critique it *before* applying it. It has been rejected
**six times** and every round found something real. Rounds so far: gaps in the anchor ladder;
an anchor counting against an enum that is not attached; a ranking inversion; four textual
ambiguities; two undefined domain terms. The last full panel could not complete because both
opencode families stalled.

**Next action on it:** `./tools/opencode-review.sh -P codex,deepseek-v4-pro <rubric>` and fix
what comes back. It is not converged. Do not fill the blind sheet against a rubric that is
still moving — the grid has already shifted twice.

**What the rubric could not solve, written into its own header:** `test-quality` holds 25 of
100 and is decidable on **two of five** variants, because three submitted no test file.
Either the fixture set grows tests or the weight is wrong. That is a question for the
benchmarks repo, not this one.

## Known and unfixed

- **Five zombie `opencode run` processes**, aged 10–12 days, belong to *other* projects.
  Not touched. They may hold sessions or quota.
- **`opencode` still runs the acceptance gate and the critic**, and still hangs. Both now
  have a stall budget; that bounds the cost, it does not fix the cause.
- **The review harness reads the artifact, not the artifact beside its inputs.** That is how
  an anchor citing an unattached enum survived two review passes. A rubric anchor can only be
  checked against the attachment set by hand.

## Do not repeat these

- **Never edit a tool while a run of it is in flight.** bash reads scripts incrementally; an
  edit shifts byte offsets under the running instance. It killed a review mid-run with a
  syntax error at the line being edited, and `bash -n` passed the whole time.
- **A header-only findings file is a stall, not an empty result.** Check for a live process.
- **Bundling an edit script and a commit in one background command** produced a commit whose
  message described changes an aborted script never made.
