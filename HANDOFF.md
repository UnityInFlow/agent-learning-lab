# Handoff — 2026-08-28 (second session)

Read `CLAUDE.md` first; it carries the operational facts and is loaded automatically. This
file is the *state*: what is in flight, what is blocked, and on whom.

## Position

**Spine 3 of 28 — B1, the experiment contract.** No agent exists and none should until stop
10. B1 builds the instrument that decides whether anything later is true.

## Branch state

`lab21/the-ladder-had-gaps`, **16 commits**, ahead of `main`. `main` is at `0f58203`
(PR #18, merged 2026-08-27, five CI checks green). All five CI jobs pass locally on this
branch, shellcheck included.

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

Links re-verified again 2026-08-28 (third check): `ok=64 moved=8 blocked=2 unverified=0
broken=0` over the same 76 URLs, the same eight redirects, no drift in eighteen days.
`SOURCES.md` is updated and re-stamped. **Correcting this file's own earlier claim: the four
migrated Codex docs are NOT in 0A's Tier 1 list** — 0A cites the openai.com agent-loop
article, which did not move. The four live in `SOURCES.md` and `CURRICULUM.md` only, and
were already annotated. 0A needs no link work before it is read.

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

**Round 7 ran on 2026-08-28 and the gate returned ACCEPT** — the first accept in seven
rounds, both families completing, neither stalling. Findings in
`findings/opencode/review-backend-quality-20260828T085728Z.md`.

The gate disputed four of the six line-level findings, all on the same ground: anchor 1 is
an ILLUSTRATION of the residual (lines 67-70) and "1 otherwise" (lines 62-66) catches
everything that is neither 0 nor 2, so a finding that anchor 1's literal text fails to reach
some case is not a defect. That reasoning is sound.

**One finding survived, and both families found it.** `test-quality`'s null precondition
turns on "a test file that makes no assertion at all", and the rubric never says which
constructs are assertions. A submission asserting only `verify(exactly = 1) { save(any()) }`
scores 1 under a reader who counts mock verification and `null` under one who does not —
87.5 versus 100. That is a change of denominator, not a one-point disagreement, so the two
totals are not the same measurement.

**The decision that is yours: is ACCEPT-with-one-open-item converged enough to fill the
blind sheet against?** Fixing the assertion gap changes `backend-quality.yaml`'s sha, and
that sha is a registered variable cited in both `E-001-blind-scores.yaml` and the prediction
doc. Fix-then-re-run costs one more round and moves the grid once more; accepting as-is
means the blind sheet is filled against a rubric with a known undecidable trigger on the
category that already carries the most weight-versus-decidability trouble. Nobody else can
make that call for you — it is the same class of choice as the predictions.

**A defect in the harness, not the rubric:** the recurrence table counts families per
SECTION NAME. Both families found the assertion gap, under different headings, so the one
finding with 2/2 support shows up as two separate 1/2 rows. Every row in that table reads
1/2 and at least one of them understates its support.

**What the rubric could not solve, written into its own header:** `test-quality` holds 25 of
100 and is decidable on **two of five** variants, because three submitted no test file.
Either the fixture set grows tests or the weight is wrong. That is a question for the
benchmarks repo, not this one — **now open as UnityInFlow/agent-observatory-benchmarks#22**,
with both obvious fixes shown to be illegal there (adding tests to the three test-less
variants breaks the one-dimension rule; adding them to `known-good` re-breaks
`default-error-body` 13 → 11 and does not reach the variants anyway, since `apply_variant`
copies a quality variant alone). The issue also carries the ordering constraint: whichever
direction wins, "assertion" must be defined in the rubric BEFORE a new test fixture lands,
because a new fixture is what makes the round-7 finding reachable. The rubric header itself
does not link the issue — writing the number into it would move the sha.

## Known and unfixed

- **The `test-quality` assertion trigger is undefined.** The one surviving round-7 finding,
  found by both families independently. Fixing it moves the rubric sha. See above.
- **Five zombie `opencode run` processes**, aged 10–12 days, belong to *other* projects.
  Not touched. They may hold sessions or quota.
- **`opencode` still runs the acceptance gate and the critic**, and still hangs. Both now
  have a stall budget; that bounds the cost, it does not fix the cause.
- **The review harness reads the artifact, not the artifact beside its inputs.** That is how
  an anchor citing an unattached enum survived two review passes. A rubric anchor can only be
  checked against the attachment set by hand.
- **`lab_dirty` cannot tell an unrelated edit from the artifact moving.** Round 7's header
  says `lab_dirty: true` because `tools/check-links.sh` was edited while the run was in
  flight. The reviewed artifact was stamped `396e1799eb2b` and did not move. Do not read
  that flag as "the rubric shifted mid-review" without checking the artifact sha.
- **Three controls in two days reported success over a scope smaller than believed**: the
  stall budget covering three of four opencode calls, the link checker's `PRIVATE` skip
  excusing two URLs from being fetched, and the scheduled link job reading 2 of 33 files.
  All three now fixed. When you meet a green control here, ask what it did not read.

## Do not repeat these

- **Never edit a tool while a run of it is in flight.** bash reads scripts incrementally; an
  edit shifts byte offsets under the running instance. It killed a review mid-run with a
  syntax error at the line being edited, and `bash -n` passed the whole time.
- **A header-only findings file is a stall, not an empty result.** Check for a live process.
- **Bundling an edit script and a commit in one background command** produced a commit whose
  message described changes an aborted script never made.
