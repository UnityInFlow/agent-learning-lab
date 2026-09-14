# Deliberate failure, stop 16 — the disjunctive classifier

**This file is committed BEFORE the break is made and before anything is run.** §4 step 9:
*"Prediction first, committed, then break it, then record."*

## What I am going to break, and why this break and not another

`classify-permission-block.sh` is **conjunctive**. It calls a run a permission block only when
*both* hold: a denial signal (`behavior.permissionDenials > 0`) **and** nothing produced (the
changed-file count is 0). Its header argues for that at length, and names the tempting
alternative it rejected:

> The tempting rule — *"permissionDenials > 0 means the run was blocked"* — is WRONG ON THIS
> STORE'S OWN DATA … SIX runs of 550 have `permissionDenials > 0`. ALL SIX PASSED.

So the break is to make it **disjunctive** — `denials > 0` **OR** `changed == 0` — which is the
version a reasonable person writes first, and the version obs#47's own sentence describes
failing: *"a permission block silently converted into a passing-looking dataset is how this class
of bug survives."*

This is the right break because it attacks the one design decision the fix actually rests on. A
break that scrambled the JSON parsing would only re-prove that the parser refuses bad input,
which the 29 fixtures already prove.

**Nothing is edited in place.** The broken copy is written to
`evidence/p05b/deliberate-failure/classify-permission-block.DISJUNCTIVE.sh`, the registered file
under `agent-observatory/runner/lib/` is not touched, and no benchmark run is made.

## Predictions, with direction, magnitude and mechanism

1. **The six stored `EXP-4B-ORCH-OVERHEAD` runs flip from clean to blocked: 0 of 6 → 6 of 6.**
   *Mechanism:* all six have `permissionDenials` of 1 or 2 and `changedFiles` of 3. Under the
   conjunction the second conjunct is false and they are clean; under the disjunction the first
   disjunct alone fires. **These six all PASSED the evaluator**, so the disjunctive version
   converts six passing runs into discards — the failure obs#47 names, running in reverse.

2. **The ten control runs of this batch flip from clean to blocked: 0 of 10 → 10 of 10.** This is
   the one I want on record most, because it is the one a `denials > 0` reading would *not*
   predict. *Mechanism:* the control has **0 denials**, so the first disjunct is false — but it
   changed 2–3 files… which makes the second disjunct false too. **So I predict 0 of 10, not 10
   of 10.** *Corrected before committing: the control is safe from this break, and the break is
   therefore narrower than it looks.*

3. **The five arm-D runs flip from clean to blocked: 0 of 5 → 5 of 5.** *Mechanism:* denials of
   1, 4, 8 and 15 satisfy the first disjunct on four of them; `3bd8fcd8` has 0 denials and 3
   changed files and satisfies **neither**, so I predict **4 of 5**, not 5 of 5.

4. **The five arm-H runs are unchanged at 5 of 5 blocked.** *Mechanism:* both conjuncts are true
   there, so conjunction and disjunction agree. **The break is invisible on the arm the fix was
   built for** — which is the point of running it.

5. **The fixture set does NOT catch this.** `verify-permission-block-classifier.sh` passes 29 of
   29 against the broken copy, or fails on fewer than half its cases. *Mechanism:* the fixtures
   were written by the same author as the guard; a fixture set tests the cases its author thought
   of, and `review_lesson` in `TRACK-B-STATE.md` records exactly this failure — *"Eleven fixtures
   passed over the first two broken versions."* **If the fixture set does catch it, prediction 5
   is refuted and that is a better outcome than my being right.**

**Summary of the registered numbers, so none of them can be chosen afterwards:**
`EXP-4B-ORCH-OVERHEAD` **6 of 6** · control **0 of 10** · arm D **4 of 5** · arm H **5 of 5
unchanged** · fixtures **29 of 29 still passing**.

*Predicted by Opus 5 (claude-opus-5), autonomously, 2026-09-14T14:1xZ; the author did not review
before the run.*
