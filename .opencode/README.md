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
./tools/opencode-review.sh <artifact> [more...]     # → findings/opencode/review-*.md
./tools/opencode-score.sh  <rubric> <impl-dir>      # → findings/opencode/score-*.yaml
```

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
