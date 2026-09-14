# Deliberate failure, stop 16 — result

Run 2026-09-14, after `PREDICTION.md` was committed at `81ea8e6` and before anything was broken.
The break is one character: `&&` → `||` at line 89 of `classify-permission-block.sh`, applied to
a **copy** (`classify-permission-block.DISJUNCTIVE.sh`). `diff` shows exactly one changed line and
`git status` in `agent-observatory` is empty — **the registered file was never touched**, and no
benchmark run was made.

## The four count predictions: all held exactly

`flip-table.tsv` — every run classified twice, once by the registered conjunctive script and once
by the broken copy, and the difference recorded per run.

| population | n | registered prediction | observed flips | verdict |
|---|---|---|---|---|
| `EXP-4B-ORCH-OVERHEAD`, denials > 0 | 6 | **6 of 6** | **6 of 6** | HELD |
| control (`plain`) | 10 | **0 of 10** | **0 of 10** | HELD |
| arm D (`blocked-deny-5b5`) | 5 | **4 of 5** | **4 of 5** | HELD |
| arm H (`blocked-hook-5b5`) | 5 | **0 flips, 5 of 5 still blocked** | **0 flips** | HELD |

The two worth having written down are the two that predicted the break is **narrower** than it
looks. The control does not flip — it has 0 denials *and* changed 2–3 files, so neither disjunct
fires. And arm D flips on four, not five: `3bd8fcd8` has 0 denials and 3 changed files and
satisfies neither disjunct either. A break that only fires where a signal already exists is
easier to miss than one that fires everywhere.

**What the break does, in one line:** it converts **six runs that passed the evaluator** into
discards. That is obs#47's own sentence — *"a permission block silently converted into a
passing-looking dataset is how this class of bug survives"* — running in reverse, and it is the
exact failure the classifier's header says it rejected the disjunction to avoid.

**And the break is invisible on the arm the fix was built for.** Arm H is unchanged at 5 of 5,
because both conjuncts are true there and conjunction and disjunction agree. A confirmation batch
run only on the blocking channel would have shown this defect nothing at all.

## Prediction 5 is REFUTED, and that is the better outcome

I predicted the 29-case fixture set would **not** catch the break — that it would pass 29 of 29 or
fail fewer than half — on the grounds that `review_lesson` in `TRACK-B-STATE.md` records exactly
that failure: *"Eleven fixtures passed over the first two broken versions … a fixture set tests
the cases its author thought of."*

**It caught it. 20 passed, 9 failed** (`fixtures-against-broken.txt`).

The reason it caught it is the thing to carry forward, because it is a repeatable technique rather
than a lucky fixture:

> **Six of the nine failing cases are real runs from this store, named by run id** — `c0b6721e`,
> `2744a92c`, `fb894d7d`, `beae5092`, `1f806f3d`, `4d7c537d`, the `EXP-4B-ORCH-OVERHEAD` runs with
> `denials 1–2, toolCalls 14–25, changed 3, passed true`. They are not invented cases. They are
> **the counter-examples that motivated the conjunction, embedded in the fixture set as fixtures.**

A fixture set built from imagined cases tests its author's imagination. A fixture set built from
the real data that forced the design tests the design. The three remaining failures are synthetic
boundary cases — *one changed file is still work*, and the two `0 denials, 0 changed` rows — and
they are the ones that would have been written either way.

**This refutes prediction 5 and it does not rescue `review_lesson`'s warning, which still stands
for fixture sets written the other way.** The difference between the skill-activation tool that
passed eleven fixtures over two broken versions and this one is not care; it is that this one has
real runs in it.

*Result recorded by Opus 5 (claude-opus-5), autonomous, 2026-09-14. Prediction 5 was wrong and is
left exactly as written (§4 step 12).*
