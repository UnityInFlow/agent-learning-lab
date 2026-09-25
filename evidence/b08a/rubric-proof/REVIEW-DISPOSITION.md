# §4a review of the ported rubric — one round, gate **REJECT**, and every finding is CARRIED, not fixed

Review file: `findings/opencode/review-backend-quality-be005-20260925T053937Z.md`, 18 KB, 10 `###`
sections, **no live `opencode` process when it was read** (`LC_ALL=C pgrep -fl opencode-review` empty),
so it is a review and not a stall. Panel `-P codex,deepseek-v4-pro`, as §4a requires for anything that
will be a registered variable. **Both families returned and neither refused** — codex in 41 s,
`ollama-cloud/deepseek-v4-pro` in 170 s. The acceptance gate is a third role,
`ollama-cloud/minimax-m3`, and its verdict is `## Acceptance — REJECT`.

## Why nothing here is fixed, and this is not the same as disputing it

§4a gives two dispositions per finding: fix it and record the sha, or dispute it with the concrete
reason its failure scenario cannot occur. **Neither applies while this rubric is under a §7 halt**, and
the reason is mechanical rather than a matter of taste:

**Editing the rubric changes its sha, and its sha is the only thing binding the seven sheets to the
file they scored.** Every sheet carries `rubric_sha: 945817b8c509`. Fix one word and the file on disk
no longer hashes to that, so the proof would document a rubric that no longer exists and a re-score
would be owed before anything could be claimed. And all three ways forward in `RESULT.md` — narrow the
anchor, change the fixture-mode baseline, or register with `change-focus` marked `unmeasured` — either
edit this file or re-prove it. **Every one of these findings belongs in that same edit**, made once,
after the author decides, with its predicted cells written first.

So each row below is **CARRIED**: not accepted, not disputed, not silently dropped, and named here so
the next session cannot mistake an unaddressed finding for an absent one.

## The findings, and what each one is worth

| # | recurrence | the claim | where | disposition |
|---|---|---|---|---|
| 1 | **2/2** | The rubric does not say whether a framework-generated request-validation refusal counts as a "refusal" that must travel through an `ApiException`, and the two readings differ by the full two points | `architecture-consistency` anchor 2 | **CARRIED.** Real, and it did not bite this proof: all seven fixtures scored 2 or 0 with no disagreement between the readings, because every fixture's refusals are hand-written. It would bite a *run*, where a model may lean on framework validation. Fix in the author's edit. |
| 2 | **2/2** | *"nested THREE or more deep"* and *"a chain of depth one"* do not say whether `else if` adds depth, a full two-point divergence | `maintainability` anchors 0 and 2 | **CARRIED.** Real and the most likely to bite a run. It did not bite the proof: `good-nested-ifs` scored 0 and every other fixture 2, which is the separation the dimension needed. Fix in the author's edit. |
| 3 | **2/2** | A test that reads a body through `jsonPath` but asserts only a status code satisfies neither anchor 0 nor anchor 1's positive definition | `test-quality`, the 0/1 boundary | **CARRIED, and it came within one line of mattering.** `good-weak-tests` **imports `jsonPath` and never uses it**; had it used it on a status-only assertion, this gap would have decided the cell that the whole `test-quality` separation rests on. That is a near-miss worth the author's attention on its own. |
| 4 | **2/2** | Anchor 2's permitted-difference list refers to *"what part 2 asks for"* — i.e. `task.md` — which the rubric's own header says the scorer never receives | `change-focus` anchor 2 | **CARRIED, and it is independent corroboration.** This text is **byte-identical to the author's draft**; the port did not introduce it. Two families found `change-focus` anchor 2 under-specified by reading it, and the fixture proof found the same dimension broken by running it — from a different cause. Both go into the same decision. |
| 5 | 1/2 | No duplicated pass/fail gate; names `maintainability`'s `else if` ambiguity as the section with the greatest expected reviewer divergence | cross-cutting | **CARRIED**, and it is finding 2 restated as a ranking. Recorded because §4a says a 1/2 finding is still a finding — recurrence is a detection threshold, not a truth value. |

## The thing this round actually proves, which is not about any single finding

**The review did not find the defect that stopped the stop.** Ten sections across two families, both
returning, and not one of them noticed that `change-focus` is scored against `known-good` in fixture
mode and against the pre-agent HEAD in run mode — the asymmetry that makes the dimension unable to
separate. It could not have: the harness sends it the rubric, not `codex-score.sh`, and not the seven
trees the rubric would be applied to.

That is §4a's own warning landing on this stop: *"What a review cannot do, so you still must: it has no
test runner, no diff and no evaluator output."* Here the fixture proof **was** the thing that executes,
and it caught what the thing that reads could not. Both were run; only one found it; and the one that
found it cost seven codex calls and about ten minutes.

**One round, not three.** §4a allows up to three rounds per artifact and stops early when every
remaining finding is disputed. Rounds 2 and 3 are not run because they would review a file that cannot
be edited until the author decides, and a second `REJECT` on an unchanged file measures the panel's
consistency, not the rubric. **This is recorded as `REJECT`, not as `ACCEPT` and not as `UNDECIDED`.**

*Disposed by Opus 5 (claude-opus-5), autonomously, 2026-09-25. The findings' extraction was delegated;
the disposition of each one is mine, and finding 4's byte-identity with the draft was checked against
the draft rather than assumed.*
