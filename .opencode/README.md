# The opencode review harness

Two agents and two scripts. They exist to make one claim provable:

> A rubric you score alone is a rubric you agree with by construction.

Nothing here scores code for its own sake. The output is a *disagreement measurement*.

## Why opencode, and why not Claude

The authenticated providers on this machine are `opencode-go` and `ollama-cloud` — **no
Anthropic credential**. That is a feature, not a limitation. A second opinion from the same
model family that authored the artifact is a correlated opinion; it shares the blind spots
you are trying to find. A different family disagrees for its own reasons.

## The two agents

| Agent | Job | Output |
|---|---|---|
| `lab-critic` | Attack an artifact. Every finding carries a concrete failure scenario; `no finding` is a valid verdict | Markdown, per-section verdicts |
| `lab-scorer` | Apply a rubric to an implementation, blind to your scores | YAML only, `null` where the rubric is ambiguous |

Both are `temperature: 0`, both have `write`/`edit`/`patch` disabled. Neither will rewrite
your artifact or hand you replacement text — that is deliberate. The artifact is yours to
write; the harness only tells you where it breaks.

`lab-scorer` emits `score: null` rather than guessing. That is P7 — *unknown data remains
unknown* — applied to the reviewer itself. A null is a real result: it records the rubric
failing to separate two scores. A fabricated middling score is worse than none, because it
looks like agreement.

## Usage

```bash
./tools/opencode-review.sh <artifact> [more...]        # → findings/opencode/review-*.md
./tools/opencode-review.sh -n 3 <artifact>             # 3 independent runs, findings unioned
./tools/opencode-score.sh  <rubric> <impl-dir>         # → findings/opencode/score-*.yaml
```

## The reviewer under-reports — measured, not assumed

Two runs of `lab-critic` at `temperature: 0` over the same artifact disagreed on **2 of 12
sections**. Both flips were `no finding` → a genuine finding the earlier run had missed, and
the critic classified both as **L1 — structural**, the sharpest class it has.

So the failure mode is *incomplete recall*, not invention. **A single review run is a lower
bound on findings.** That is what `-n` is for: it unions across independent sessions and
prints a recurrence column.

Read the recurrence column as a detection-threshold signal, **not** a truth signal. A section
flagged 1/3 is not one-third true — it is a finding that sits near the edge of what this
reviewer reliably notices. In our measurement, that is exactly where the two L1 findings
lived. Do not discount low-recurrence rows; they were the most structural ones we got.

## Three rules that make the output mean anything

1. **Score it yourself first.** Do not read `score-*.yaml` until your own sheet exists.
   Reading it first produces agreement that measures nothing.
2. **Pin the model, record the model.** `LAB_REVIEW_MODEL` defaults to
   `ollama-cloud/deepseek-v4-pro`. Both scripts stamp the resolved model, the opencode version, the
   agent-file sha and the artifact sha into every output. An unpinned reviewer is an
   unregistered variable — the Phase 0A lesson, applied to the instrument.
3. **Never `--continue`.** Every run is a fresh session. A scorer that remembers its last
   sheet is not an independent second scorer.

## Known sharp edge

`opencode run`'s `-f` is a yargs *array* flag: it will swallow a message that follows it as
a filename. The prompt must come **before** any `-f`. Both scripts do this and say why.
