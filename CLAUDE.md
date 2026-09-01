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
./tools/check-sheet-categories.sh <rubric> <sheet>   # is the sheet's category set the rubric's?
./tools/verify-sheet-category-checker.sh      # 9 cases proving that check still rejects
./tools/check-run-gate.sh <run.json>          # may this observatory run be scored? (Decision D)
./tools/verify-run-gate-checker.sh            # 13 cases proving that gate still refuses
./tools/codex-score.sh <rubric> --run-id <id> # score a B2 run instead of a fixture
./tools/opencode-score.sh <rubric> --run-id <id>     # the same run, second harness
```

CI runs `bash -n` + ShellCheck (`-S warning`) on `tools/`, parses every YAML contract, and
runs the link check weekly. **ShellCheck is a required check** — `cd` needs `|| exit`.

**The push hook reviews `tools/*.sh` too, as of 2026-08-28** — and it did not before, which
is how a blocking defect reached `check-sheet-categories.sh` with ShellCheck clean, nine
passing fixtures and a green CI job. None of those can catch *"this gate admits something it
should not"*. Contracts are reviewed before tools, at most `LAB_REVIEW_MAX_ARTIFACTS` (4) per
push, and **anything dropped is named on the way past** — every artifact lands in one prompt
per family, so a wide push does not cost more calls, it costs attention from a critic that
already under-reports.

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

**The scorer takes `--run-id` for a B2 run — Decision D, proposed by Claude, built and
confirmed by the author on 2026-08-28.** Path A scores a fixture and proves the gate by name;
Path B scores an observatory run and proves it from the evaluator's recorded verdict,
refusing when there is none. It attaches **the files the agent changed, in full, plus their
pre-agent versions** — not the whole worktree, because `sample-service` ships
`ShipmentControllerTest.kt` and attaching all 25 files would put a test file among the
attachments on every run, silently disabling Decision A's null precondition. Runbook: [`phases/b02-plain-baseline/RUNBOOK.md`](phases/b02-plain-baseline/RUNBOOK.md).
**`opencode-score.sh` has a `--run-id` path too, as of 2026-09-01, and this paragraph used to
say a cross-harness check on B2 was not possible.** It is. **Decision C is untouched** — codex
remains the registered scorer and produces the experiment's numbers; opencode is the second
reader, which is what B1 had and B2 did not. Both paths admit a run by the same rule (the
evaluator's recorded verdict, `check-run-gate.sh`) and attach the same set (Decision D), so
the two sheets are comparable by construction.

It also removes a single point of failure that FAILED: on 2026-09-01 codex hit its usage limit
mid-session and B2 was unscoreable for three hours.

**First cross-harness comparison, run `0a222393`, and it earned its keep immediately: 3 of 4
exact, and the disagreement is a defect in the second reader rather than in the rubric.**
`change-focus` — codex 1 *"the class documentation outside confirm was removed"*, opencode 2
*"only confirm added; create/getById/list identical"*. The diff settles it: the agent deleted a
five-line class KDoc that has nothing to do with `confirm`. codex is right.

**And it is a REPEAT, not a new finding.** `change-focus` anchor 0 says *"cite the line in both
trees"*; on 2026-08-30 codex did and opencode named methods and cited one tree. It just did the
same thing on a different target — `evidence: ShipmentController.kt:52-72`, the added region
only. Nothing executes that instruction, so this is the same L3 gap caught twice by two
different runs. One observation was a curiosity; two is a property of the harness.

**The scorer admits fixtures by NAME, and that runs out at B2.** `codex-score.sh` and
`opencode-score.sh` accept a target only if its basename is in `known-good` +
`QUALITY_VARIANTS`, read from the benchmarks' `verify-evaluator.sh`. The invariant is right —
only gate-passing submissions get scored — but the proof is a registry lookup, and a B2 agent
run has no fixture name. The second admission path, and the open question about attachment
sizes that comes with it, are specified in [`build/README.md#b2`](build/README.md#b2).
**Read that before the first B2 run.**

**A missing cell is not a null cell.** `null` is a measurement — the scorer read the anchor
and could not decide. A category that never appears in the sheet is an absence, and once the
sheet is on disk nothing downstream can tell them apart. E-001's dependent variable is the
null *rate*, a ratio whose denominator is the cell count, so a silently short sheet does not
add noise: it changes what was measured while reporting the same units. Until 2026-08-28
nothing caught one — the JSON schema said `minItems: 1` with no `maxItems` and `name` as a
free string, and `classify-model-output.sh` only asks whether a `categories:` key exists,
because it is never given the rubric. `codex-score.sh` now pins the schema per run to the
rubric's own category names and exact count, both scorers re-check the set on disk after the
run, and `check-sheet-categories.sh` fails closed if either parse yields nothing.

### `opencode run` hangs. It is the harness, not a list of bad models

**Corrected 2026-08-28.** This section used to name three models that hang, as if the fault
were a property of the model. The evidence says otherwise:

- `glm-5.2`, `deepseek-v4-pro` and `gpt-oss:120b` all stalled on 2026-08-28 — each had
  answered the *same artifact* in minutes earlier the same day
- five `opencode run` processes were wedged on this machine at once, aged **10–12 days**,
  from other projects and unrelated commands (`--auto --command review PR #45`,
  `--auto --pure`, `--dir . --pure`). Each had burned ~an hour of CPU before it stopped
  returning, so they were working and then stopped — not stuck from the start
- `codex`, a different harness, answered every time, in under a minute, on the same input

So: **`opencode run` fails to return on a fraction of non-interactive calls, independent of
model and project, and never times out on its own.** Roughly five of eight calls on
2026-08-28.

**A hung run looks exactly like an empty one.** The provenance header is written *before*
opencode is invoked, so a stall leaves a header-only file. Check for a live process before
reading one as a finding — that mistake has already been made and reported once.

**The mitigation is `LAB_REVIEW_TIMEOUT` (default 600s)**, which covers every panel family
*and* the acceptance gate: a stall drops that family, on the record, and the rest continue.
Nothing has ever recovered past ~10 minutes.

**The scorer does not rely on opencode at all** — see *Which harness does what*.

The three below hang totally rather than intermittently, and should simply not be used:
`opencode-go/kimi-k3`, `opencode-go/glm-5.3` and `ollama-cloud/kimi-k2.6` — zero output past nine minutes, no error. Working:
`ollama-cloud/deepseek-v4-pro` (the default), `gpt-oss:120b`, `gpt-oss:20b`. Two of the
user's `opencode run` processes were wedged for over a week for this reason.

`opencode run`'s `-f` is a **yargs array flag**: it swallows a following message as a
filename. The prompt must come first. `--dir` repoints the project root, so `.opencode/agent/`
is looked up in the target and opencode **silently falls back to the default full-tool agent
and exits 0** — both scripts grep for that warning and fail.

## Which harness does what

Two harnesses, deliberately. `codex` is not a fallback — where it is used, it is *the*
registered choice, and mixing harnesses inside one comparison measures the harnesses.

| role | harness | why |
|---|---|---|
| **scoring** | **`codex` only** (E-001 Decision C) | produces the experiment's actual numbers. `opencode` was a single point of failure on the one instrument that cannot be allowed to fail |
| second reading | `opencode`, same `--run-id` | **not a fallback and not a vote.** The registered number is codex's; this is the distance between two harnesses, which is the only thing that separates a rubric defect from a model quirk. Where they disagree, go to the diff — on the first comparison the diff sided with codex |
| line-level critic | **panel: `codex` + opencode families** | different harnesses find different *classes* of defect — see below |
| acceptance gate | `opencode` only | a review, not a measurement. A stalled gate costs time; a stalled scorer costs the experiment |

```bash
./tools/codex-score.sh <rubric> <impl-dir>     # the scorer. Decision C
./tools/codex-critic.sh <out.md> <artifact>    # one panel family, standalone
./tools/opencode-review.sh -P codex,deepseek-v4-pro <artifact>
```

**Three sources, three defect classes, on the same rubric.** None found another's list:

- `glm-5.2` — structural: gaps in the anchor ladder, an anchor citing a file that is not attached
- `deepseek-v4-pro` — phrasing that two faithful scorers read two ways, costed in points
- `codex` — domain terms never defined at all ("refusal", "the imports it requires"), shown
  with constructed Kotlin counterexamples

That is the argument for `-P`, and it is why `-n` (one model, N times) is a different knob:
`-n` measures a model's detection threshold, `-P` measures the artifact.

## Where B1 stands

`benchmark/rubrics/backend-quality.yaml` is **v2, four categories, sha `396e1799eb2b`**,
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
