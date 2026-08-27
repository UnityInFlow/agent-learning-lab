# agent-learning-lab

The workbook. What is committed here is **evidence** — predictions made before a run, results
that contradicted them, and the reasoning in between. The artifact is not the deliverable;
the learning is.

The instrument lives in `agent-observatory`. Tasks and fixtures live in
`agent-observatory-benchmarks`. Nothing that interprets a result belongs here.

## Read first

`LEARNING-PATH.md` is the single plan — it merges four earlier roadmaps that each numbered
their phases from zero. "Phase 4" meant four different things before it existed. Do not take
an ordering from `CURRICULUM.md` or anything in `businesscase/`; those are the inputs it
merged.

`GUARDRAILS.md` holds the layer model every phase points back to. `build/README.md` is the
Track B index.

## Commands

```bash
./tools/check-links.sh                        # re-verify every source in SOURCES.md
./tools/opencode-review.sh -n 2 <artifact>    # adversarial review, unioned across N runs
./tools/opencode-score.sh <rubric> <impl-dir> # blind second scoring → findings/opencode/
./tools/verify-run-record-validator.sh        # 11 fixtures, each with its registered exit code
./tools/verify-score-output-classifier.sh     # 8 fixtures, each with its registered class
```

CI runs `bash -n` + ShellCheck (`-S warning`) on `tools/`, parses every YAML contract, and
runs the link check weekly. **ShellCheck is a required check** — `cd` needs `|| exit`.

## The review harness — measured facts, not assumptions

`.opencode/agent/` holds two agents. Neither will rewrite an artifact or supply replacement
text; that is deliberate, so the writing stays with whoever is learning from it.

**The critic under-reports; it does not hallucinate.** Two runs at temperature 0 over the
same artifact disagreed on 2 of 12 sections, and both flips were real findings the earlier
run had missed. A single run is a **lower bound** — use `-n 2` or more, and read the
recurrence column as a detection threshold, not a truth value. The two most structural
findings we got appeared at 1/2.

**The scorer emits `null` rather than guessing** when a rubric's anchors cannot separate two
scores. That is the contract working. If it returns nothing at all, the anchors are asking
for something it cannot see — it has no test runner, no diff, and no evaluator output.

**"Nothing" was five different things.** `tools/classify-score-output.sh` splits them, and
`opencode-score.sh` exits with its code: `0` a sheet (all-`null` cells included — that is a
result, not an absence), `2` off contract, `3` empty, `4` the default agent answered, `5` the
scorer declared the rubric unusable. Only `1` and `4` are infrastructure to discard; the rest
are findings. Collapsing them is how an experiment throws away its own strongest signal, and
E-001 nearly did.

**Score anything yourself before reading its output.** Reading first produces agreement that
measures nothing.

### Models that hang

`opencode-go/kimi-k3`, `opencode-go/glm-5.3` and `ollama-cloud/kimi-k2.6` hang indefinitely
on non-interactive runs — zero output past nine minutes, no error. Working:
`ollama-cloud/deepseek-v4-pro` (the default), `gpt-oss:120b`, `gpt-oss:20b`. Two of the
user's `opencode run` processes were wedged for over a week for this reason.

`opencode run`'s `-f` is a **yargs array flag**: it swallows a following message as a
filename. The prompt must come first. `--dir` repoints the project root, so `.opencode/agent/`
is looked up in the target and opencode **silently falls back to the default full-tool agent
and exits 0** — both scripts grep for that warning and fail.

## Where B1 stands

`benchmark/rubrics/backend-quality.yaml` is **v2, four categories, sha `dbf6f64fdfdc`**,
written 2026-08-27 (lab#21). The seven-category file it replaced is in git history as a
**worked example of a specific mistake**. Two independent defects killed it:

1. Anchors cited evaluator exit codes the scorer cannot see
2. Worse — the rubric only scores **gate-passing** submissions, so any anchor restating a
   gate is a *constant* across everything it can score. 60% of the weight carried no
   information

v2 is four categories (architecture-consistency 35, maintainability 25, test-quality 25,
change-focus 15), anchored on constructs visible in the five gate-passing variants and the
attached baseline. `functional-correctness` and `requirement-completeness` are dropped: the
gates own them, and restating a gate is a constant across everything this rubric can score.

**What v2 could not solve, and hands forward:** `test-quality` holds 25 of the 100 and is
decidable on two of the five variants — the other three submitted no test file. Three of
E-001's twenty cells are null before an anchor is read. A structural null is honest where a
constant was not, but the fixture set needs tests or the weight is wrong.

**The test for any anchor: could a reviewer cite `path:line` to justify it?** If not, the
scorer will null it and deserves to.
