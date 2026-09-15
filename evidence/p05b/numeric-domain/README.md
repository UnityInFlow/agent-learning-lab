# The numeric domain defect, and the proof that fixing it moved nothing

Written 2026-09-15 by Opus 5, autonomous, at §4a step 2 of spine stop 16 — the disposition of
two findings from the round-2 review of `classify-permission-block.sh`. **No benchmark run was
made and no money was spent.** This directory is additive: nothing under `evidence/p05b/replay/`
is edited, and the tables there stay as they were written.

## The defect, reproduced before it was fixed

The classifier admitted `^[0-9]+$` as "a number". That set is not the set bash arithmetic can
evaluate. Reproduced against the file at sha `84e860f76f23`:

| input | what the old script did | what it should do |
|---|---|---|
| `permissionDenials: "08"`, 0 changed | `[[: 08: value too great for base` on stderr, comparison **false**, prints **"nothing was refused"**, **exit 0** | refuse |
| `permissionDenials: "09"`, 0 changed | same | refuse |
| `permissionDenials: "9223372036854775808"`, 0 changed | **no error at all**, prints "nothing was refused", **exit 0** | refuse |
| changed count `"08"`, 1 denial | error on stderr, falls through to "the run produced work", exit 0 | refuse |

The first row is the one that matters: **a run with eight refusals and no output was reported as
a run where nothing was refused**, at a success exit code. That is this project's house failure
mode — a control reporting over a scope smaller than it claims — inside the guard built to catch
it. The overflow row is worse, because it does not even print an error.

Note the shape of the trap: `07` is fine (valid octal, and `7 > 0` is the right answer by luck),
so the defect fires only on leading-zero strings containing an 8 or a 9. A fixture set that
happened to test `"07"` would have gone green.

## The fix

The pattern is now a canonical decimal integer, `^(0|[1-9][0-9]{0,17})$`, on **both** conjuncts.
Anything outside it is **refused at exit 3, never cleared** — which is the principle the script's
own header already stated for the changed-file count ("refused, never coerced") and had not
applied to itself. Classifier now at sha `817e6eef00ea`.

The fixture set went from **29 to 39 cases**, and the new ones include two guards against the fix
being *over*-tight: a legitimate `0` must still classify, and a large in-range count must still
block.

**One fixture failed twice, in two different directions, and the second failure is a finding of
its own.** It asserted that a JSON number above 2^53 is refused, because `jq -r` renders
`999999999999999999` as `1e+18`. That passed locally and **failed in CI** — and the cause is not
the classifier:

| environment | `jq --version` | `jq -r` on `999999999999999999` | classifier verdict |
|---|---|---|---|
| this machine | `jq-1.6` | `1e+18` | **refused, exit 3** |
| CI | 1.7 | `999999999999999999` | **block, exit 2** |

**Same record, same script, two answers, decided by the jq on the machine.** The fixture was
removed rather than tuned, because it was testing jq and not this script, and pinning either
answer would make the suite fail on the other jq. Fixture set is therefore **39**, not 40.

Recorded rather than dropped, because it is a real property of the input pipeline: **if a count
above 2^53 could ever reach this script, its classification would not be reproducible across
environments.** No value in any population here exceeds 15, so nothing measured is affected — but
that is a fact about the data, not a guarantee from the tool, and the distinction is the whole
point of this directory. The comment in the fixture file carries the same note so the next reader
does not re-add the case.

The in-range guard uses `9007199254740991` (2^53−1), which every jq renders exactly, and it
passes in both environments.

## The proof that the stop's result did not move

Every row of both replay tables re-run against the fixed classifier, same inputs, same caller
shape:

| table | rows | runId, changed-count and **exit code** identical | reason string |
|---|---|---|---|
| `../replay/batch1-replay.tsv` | 20 | **20 of 20** | recorded text is a prefix of the re-run text on 20 of 20 (the recorded TSV truncates the column) |
| `../replay/stored-replay.tsv` | 15 | **15 of 15** | same |

Totals, unchanged: batch 1 **5 blocked / 15 not**; stored **1 blocked / 14 not** (the one is
`c5ce5d78`, the co-variate preflight, which entered no decision row). P5's stored half stays
**0 of 6**; P6 stays **0 of 7**.

**Why it could not have moved, stated so the identity is not mistaken for luck:** every value in
both populations is a JSON *number* between 0 and 15, which `jq -r` renders without a leading
zero. The defect needs a numeric-looking *string* with a leading zero, or a value above 2^53.
Neither has ever been produced by `claude-telemetry.sh` or returned by the API. **That is also
why this is a latent defect and not a correction to the stop's finding** — and why it is fixed
rather than disputed: the guard's own contract is to refuse what it cannot evaluate, and on these
inputs it did not refuse, it answered wrongly.

Re-run files: `batch1-replay-after-fix.tsv`, `stored-replay-after-fix.tsv` (columns: runId,
changed, exit, reason).

`Found by the §4a round-2 review; reproduced, fixed and re-proved by Opus 5 (claude-opus-5),
autonomous, 2026-09-15.`
