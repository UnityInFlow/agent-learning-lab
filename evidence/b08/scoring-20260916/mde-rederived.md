# The MDE re-derived from the population that occurred — §4 step 8, 2026-09-16

E-018 and E-019 registered their limits as **transferred** from E-015/E-016 and said in as many
words that they would be *"re-derived from this batch's own control before any verdict is written"*.
Decision 11 item 10 prescribes the same for a task with no stored population. This is that
re-derivation. Formula, unchanged: `MDE = 2.8 · sd · sqrt(2/n)`.

**The re-derived limits are much TIGHTER than the transferred ones**, so this is not a loosening
that lets a null through — it is the opposite, and every observed delta still fails to clear it.


## BE-003 — control `n = 10`, treated `n = 10`

| outcome | control mean ± sd | transferred MDE | **re-derived MDE** | observed median delta | reading |
|---|---|---|---|---|---|
| `estimatedCost` | 0.1201 ± 0.0130 | $0.045 (30 %) | **0.0163** (13.6 %) | +0.0028 | **inside → not detectable** |
| `modelCalls` | 20.9000 ± 2.4244 | 6 calls (29 %) | **3.0358** (14.5 %) | -2.0000 | **inside → not detectable** |

## BE-004 — control `n = 7`, treated `n = 9`

| outcome | control mean ± sd | transferred MDE | **re-derived MDE** | observed median delta | reading |
|---|---|---|---|---|---|
| `estimatedCost` | 0.2000 ± 0.0060 | $0.045 (30 %) | **0.0089** (4.5 %) | +0.0088 | **inside, but only just** → not detectable, and the margin is reported |
| `modelCalls` | 27.8571 ± 2.2678 | 6 calls (29 %) | **3.3941** (12.2 %) | +0.0000 | **inside → not detectable** |


## The one number that deserves a sentence rather than a row

**BE-004 `estimatedCost` clears its re-derived limit by `$0.0001`.** The observed median delta is
`+$0.0088` against an MDE of `+$0.0089`. It is inside, and *"inside the MDE"* is what the decision
rule reads — but a margin of one ten-thousandth of a dollar is not a comfortable null and is not
reported as one. The reason the limit is so tight is that BE-004's control arm is unusually
consistent: `sd = $0.0060` on a `$0.20` mean, a 3 % spread, against BE-003's 11 %.

**This is also where the lost runs bite.** That `n = 7` raises the MDE by `sqrt(10/7) = 1.20×`
against a full arm; at `n = 10` the same spread would give an MDE near `$0.0074`, and the observed
`+$0.0088` would then sit **outside** it. So the F13 exclusions did not merely shrink the sample —
**they moved this particular row from "detectable" to "not detectable"**, and that is stated here
rather than discovered by a validator. It does not change the registered verdict, because the rule
reads the population that occurred and P5's own band (+2 % to +8 %) contains the observed +4.4 %.
It does mean the cost row on BE-004 is the first thing a clean re-run would resolve.

*Opus 5 (claude-opus-5), autonomous, 2026-09-16.*
