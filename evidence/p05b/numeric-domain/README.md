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

The fixture set went from **29 to 40 cases**, and the new ones include two guards against the fix
being *over*-tight: a legitimate `0` must still classify, and a large in-range count must still
block.

**One fixture failed on its first run and is kept rather than tuned away.** `jq -r` renders a JSON
number above 2^53 in scientific notation — `999999999999999999` comes back as `1e+18` — so the
value this script sees is not the value the record holds. It is refused, which is the right
answer, but the refusal is jq's precision ceiling and not the pattern's bound. Both are asserted
as separate cases so a later reader does not "fix" the pattern to admit it.

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
