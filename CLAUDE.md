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
./tools/verify-model-output-classifier.sh     # 16 fixtures over 3 output contracts
```

CI runs `bash -n` + ShellCheck (`-S warning`) on `tools/`, parses every YAML contract, and
runs the link check weekly. **ShellCheck is a required check** — `cd` needs `|| exit`.

**Never edit a tool while a run of it is in flight.** bash reads a script incrementally, so
an edit shifts the byte offsets under the running instance. Observed 2026-08-27: editing
`opencode-review.sh` during a two-run review killed it with `syntax error near unexpected
token 'done'` at the line being edited, after opencode had already been invoked with
garbled arguments. `bash -n` passed on the file the whole time — the thing on disk was
correct and the thing executing was not, which is the house failure mode wearing a shell.
A cloud review takes minutes. Wait for it, or copy the script aside and edit the copy.

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

**"Nothing" was five different things.** `tools/classify-model-output.sh <contract> <file>`
splits them for all three agents — `score`, `critic`, `acceptance` — and both scripts exit
with its code: `0` the contract was met (for `score` that includes an all-`null` sheet, which
is a result and not an absence), `2` off contract, `3` empty, `4` the default agent answered,
`5` the agent declared its input unusable. Only `1` and `4` are infrastructure to discard;
the rest are findings. Collapsing them is how an experiment throws away its own strongest
signal, and E-001 nearly did. `opencode-review.sh` had no equivalent check at all until
2026-08-27: a line-level pass returning nothing would have written a header, built an empty
recurrence table and exited 0.

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

`benchmark/rubrics/backend-quality.yaml` is **v2, four categories, sha `06fb70ec9354`**,
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
