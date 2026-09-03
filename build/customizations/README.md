# Customization overlays — one directory per version, installed by the runner

`Decided by Opus 5 (claude-opus-5), autonomous, 2026-09-03.` The itinerary pre-made the shape
of this decision and left the location to B3. This is the location, and the reason is below.

```
build/customizations/<version>/        # everything the runner copies into the worktree root
```

Installed with `make run-benchmark CUSTOMIZATION=../agent-learning-lab/build/customizations/<version>`,
which becomes `run-agent.sh --customization`. The runner copies the directory's *contents* to
the root of the agent's repository, commits them as a setup commit **before** the agent starts,
and moves the evaluation baseline to that commit — so the overlay is starting state and the
scope guard never blames the agent for a file the harness wrote.

## Why here and not in the observatory or the benchmarks repo

The overlay is **the treatment**, and a treatment is evidence. It belongs in the workbook repo
next to the experiment that registers it and the workbook that reports it, for the same reason
predictions live here: a stranger reading `experiments/E-003-*.md` must be able to open the
exact bytes the model was given without cloning a second repository. The observatory is the
instrument and must not carry the thing being measured; the benchmarks repo is the subject and
would leak the treatment into every run of every experiment, customized or not.

## The rule that makes a version comparable

**A version that has been measured is never edited. A change is a new version.**

Not a convention — the run records point at it. `customization.instructionsHash` is a sha256 of
the instruction file *as installed in the worktree*, recorded per run. Editing
`instructions-v0.1/CLAUDE.md` after runs exist silently splits one experiment key across two
treatments that the record still calls one, and the hash is the only thing that would ever have
shown it. If a rule must change, create `instructions-v0.2/` and register a new comparison.

## What the runner will refuse

It reads `CLAUDE.md` for `claude` and `AGENTS.md` for `codex` / `copilot`, and it **dies** if a
customization installs an instruction file the runtime does not read. That guard exists because
`EXP-BE002-AGENTSMD-V3` installed `AGENTS.md` for Claude Code, hashed it, recorded it on all ten
treatment runs, and compared baseline against baseline. Twenty runs and about $4 to learn that
installing a file proves nothing about whether a model reads it.

**The guard is L2 for the file name and L3 for everything else about the content.** It proves
the runtime reads that filename. It cannot prove a rule inside it changed anything, which is
what the experiment is for.
